/** \file
creates a file of summary statistics about marriage, including balance of new marriages, cohabs, etc. between
males and females. source data is the PSID analytic file used for making and estimating the simulation data.
*/

* command used for creating summary statistics -- will be applied to different subpopulations ("by" option)
local collapsecmd collapse (sum) t_married_new=married_new (mean) pmarried_new=married_new (sum) t_cohab_new=cohab_new (mean) pcohab_new=cohab_new (sum) t_singlenpd_new=singlenpd_new (mean) psinglenpd_new=singlenpd_new [fw=weight]

use "../../input_data/psid_analytic.dta"

* drop 1999 because the numbers are too high and it is not used for transition estimation
drop if year==1999

* only keep waves where a person's marital status has changed
keep if mstat_new != lmstat_new

* marriage balance
tab male year if mstat_new==3 [fw=weight]
tab married mstat_new
gen married_new = mstat_new==3

* cohab balance
tab male year if mstat_new==2 [fw=weight]
tab cohab mstat_new, m
gen cohab_new = mstat_new==2

* single (not partner death) balance
tab male year if mstat_new==1 & partdied==0 [fw=weight]
tab single mstat_new, m
gen singlenpd_new = mstat_new==1 & partdied==0

* indicator for age group
gen age25p = age >= 25

preserve
* collapse by gender, year, age
`collapsecmd', by(male year age25p)
sort age25p year male
li
save "psid_new_marriage_summary_byAgeGender.dta"


restore
preserve
* collapse by gender, year
`collapsecmd', by(male year)
sort year male
li
save "psid_new_marriage_summary_byGender.dta"

restore
preserve
* collapse by year
`collapsecmd', by(year)
sort year
li
save "psid_new_marriage_summary_combined.dta"
