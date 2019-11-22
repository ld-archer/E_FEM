clear all
clear matrix
include "../../../fem_env.do"
set more off

use $outdata/FAM_nhis97plus_selected.dta, replace

*the weight to be used for the estimation is [pweight=wtfa_sa]
*the high blood pressure variable is hibpe

*creating a categorical smoking variable based on smoken and smokev

gen smkcat=.
replace smkcat=1 if smoken==0 & smokev==0
replace smkcat=2 if smoken==0 & smokev==1
replace smkcat=3 if smoken==1 & smokev==1

label define smkcat 1 "never smoked" 2 "ever smoked 100 cigarettes" 3 "smoking now"
label values smkcat smkcat

tab smkcat, gen(smkcat)
label variable smkcat1 "never smoked"
label variable smkcat2 "has ever smoked"
label variable smkcat3 "smoking now"

*for consistency with ACS estimates, the time variable starts
*as 0 in the first year (in this case, 1997)
gen yr=year-1997

save $outdata/nhis_hbp_smk_scenarios.dta, replace

***
***TRENDS FOR AGES 21-30***
***
drop _all
use $outdata/nhis_hbp_smk_scenarios.dta, replace
keep if age>=21 & age<=30
*probit estimation for hypertension
probit hibpe yr [pweight=wtfa_sa] //1997-2009, ages 21-30
est store mhibpe2130
probit hibpe yr [pweight=wtfa_sa] if year!=2008 //1997-2009 w/o 2008, ages 21-30
est store mhibpe2130_2
probit hibpe yr [pweight=wtfa_sa] if year<2008 //1997-2007, ages 21-30
est store mhibpe2130_3

*ordered probit estimation for smoking category
oprobit smkcat yr [pweight=wtfa_sa] //1997-2009, ages 21-30
est store msmk2130

keep hibpe smkcat1-smkcat3 wtfa_sa year 
collapse (mean) hibpe smkcat1-smkcat3 [pweight=wtfa_sa], by(year)

rename smkcat1 smkcat1_2130
rename smkcat2 smkcat2_2130
rename smkcat3 smkcat3_2130
rename hibpe hibpe_2130

local obs = 2050-1997+1
set obs `obs'
replace year = 1996 + _n
gen yr=year-1997

mkmat year, mat(trends)

*projecting trends for hypertension
est restore mhibpe2130
predict phibpe_2130

est restore mhibpe2130_2
predict phibpe_2130_2

est restore mhibpe2130_3
predict phibpe_2130_3

*projecting trends for smoking
est restore msmk2130
forvalues cnt = 1/3 {
	predict psmkcat`cnt'_2130, outcome(`cnt')
}

mkmat hibpe_2130 phibpe_2130 phibpe_2130_2 phibpe_2130_3 smkcat1_2130-smkcat3_2130 psmkcat1_2130-psmkcat3_2130, mat(t_2130)
matrix trends = trends, t_2130

***
***TRENDS FOR AGES 23-28***
***
drop _all
use $outdata/nhis_hbp_smk_scenarios.dta, replace
keep if age>=23 & age<=28
*probit estimation for hypertension
probit hibpe yr [pweight=wtfa_sa] //1997-2009, ages 23-28
est store mhibpe2328

*ordered probit estimation for smoking category
oprobit smkcat yr [pweight=wtfa_sa] //1997-2009, ages 23-28
est store msmk2328

keep hibpe smkcat1-smkcat3 wtfa_sa year 
collapse (mean) hibpe smkcat1-smkcat3 [pweight=wtfa_sa], by(year)

rename smkcat1 smkcat1_2328
rename smkcat2 smkcat2_2328
rename smkcat3 smkcat3_2328
rename hibpe hibpe_2328

local obs = 2050-1997+1
set obs `obs'
replace year = 1996 + _n
gen yr=year-1997

*projecting trends for hypertension
est restore mhibpe2328
predict phibpe_2328

*projecting trends for smoking
est restore msmk2328
forvalues cnt = 1/3 {
	predict psmkcat`cnt'_2328, outcome(`cnt')
}

mkmat hibpe_2328 phibpe_2328 smkcat1_2328-smkcat3_2328 psmkcat1_2328-psmkcat3_2328, mat(t_2328)
matrix trends = trends, t_2328

***
***TRENDS FOR AGES 25-26***
***
drop _all
use $outdata/nhis_hbp_smk_scenarios.dta, replace
keep if age>=25 & age<=26
*probit estimation for hypertension
probit hibpe yr [pweight=wtfa_sa] //1997-2009, ages 25-26
est store mhibpe2526

*ordered probit estimation for smoking category
oprobit smkcat yr [pweight=wtfa_sa] //1997-2009, ages 25-26
est store msmk2526

keep hibpe smkcat1-smkcat3 wtfa_sa year 
collapse (mean) hibpe smkcat1-smkcat3 [pweight=wtfa_sa], by(year)

rename smkcat1 smkcat1_2526
rename smkcat2 smkcat2_2526
rename smkcat3 smkcat3_2526
rename hibpe hibpe_2526

local obs = 2050-1997+1
set obs `obs'
replace year = 1996 + _n
gen yr=year-1997

*projecting trends for hypertension
est restore mhibpe2526
predict phibpe_2526

*projecting trends for smoking
est restore msmk2526
forvalues cnt = 1/3 {
	predict psmkcat`cnt'_2526, outcome(`cnt')
}

mkmat hibpe_2526 phibpe_2526 smkcat1_2526-smkcat3_2526 psmkcat1_2526-psmkcat3_2526, mat(t_2526)
matrix trends = trends, t_2526

drop _all
svmat trends, names(col)


save $outdata/nhis_hbp_smk_trends.dta, replace

keep year phibpe_2130 psmkcat1_2130-psmkcat3_2130

replace phibpe_2130=. if year>2030
replace psmkcat1_2130=. if year>2030
replace psmkcat2_2130=. if year>2030
replace psmkcat3_2130=. if year>2030

*for all years after 2030 replace with values for 2030
foreach v in phibpe_2130 {
		sort year,stable
		qui sum `v' if year == 2030
		local r0 = r(mean)
		replace `v' = `r0' if year > 2030

}

foreach v in psmkcat1_2130 {
		sort year,stable
		qui sum `v' if year == 2030
		local r0 = r(mean)
		replace `v' = `r0' if year > 2030

}

foreach v in psmkcat2_2130 {
		sort year,stable
		qui sum `v' if year == 2030
		local r0 = r(mean)
		replace `v' = `r0' if year > 2030

}

foreach v in psmkcat3_2130 {
		sort year,stable
		qui sum `v' if year == 2030
		local r0 = r(mean)
		replace `v' = `r0' if year > 2030

}

keep if year>=2009

save $outdata/nhis_hbp_smk_projections.dta, replace
