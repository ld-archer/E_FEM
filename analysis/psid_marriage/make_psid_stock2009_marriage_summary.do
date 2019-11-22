/** \file
summarize marital status for the 2009 stock population that has been reweighted to match population totals.
*/

* name of 2009 stock population file
local stockname test_simul

use "../../input_data/`stockname'.dta"

* dummies for marital status based on mstat_new
gen married_new = mstat_new==3 & !missing(mstat_new)
tab married_new, m
gen cohab_new = mstat_new==2 & !missing(mstat_new)
tab cohab_new, m
gen singlenpd_new = mstat_new==1 & partdied==0 & !missing(mstat_new) & !missing(partdied)
tab singlenpd_new, m
gen partdied_new = partdied==1 & !missing(partdied)
tab partdied_new, m

* index for age group
gen agegrp_new = 0 if age < 25 & !missing(age)
replace agegrp_new = 1 if age >= 25 & age < 35
replace agegrp_new = 2 if age >= 35 & age < 45
replace agegrp_new = 3 if age >= 45 & age < 55
replace agegrp_new = 4 if age >= 55 & age < 65
replace agegrp_new = 5 if age >= 65 & !missing(age)


*** Summarize prevalence of the different marital statuses
preserve
#d ;
collapse 
(mean) pmarried_new=married_new (mean) pcohab_new=cohab_new (mean) psingle_new=singlenpd_new (mean) ppartdied_new=partdied_new 
(sum) t_married_new=married_new (sum) t_cohab_new=cohab_new (sum) t_single_new=singlenpd_new (sum) t_partdied_new=partdied_new 
[fw=round(weight)], by(male agegrp_new);
#d cr
sort agegrp_new male
li
save "stock2009_marriage_prevalence_byGenderAge.dta", replace
restore

preserve
#d ;
collapse 
(mean) pmarried_new=married_new (mean) pcohab_new=cohab_new (mean) psingle_new=singlenpd_new (mean) ppartdied_new=partdied_new 
(sum) t_married_new=married_new (sum) t_cohab_new=cohab_new (sum) t_single_new=singlenpd_new (sum) t_partdied_new=partdied_new 
[fw=round(weight)], by(male);
#d cr
sort male
li
save "stock2009_marriage_prevalence_byGender.dta", replace
restore

preserve
#d ;
collapse 
(mean) pmarried_new=married_new (mean) pcohab_new=cohab_new (mean) psingle_new=singlenpd_new (mean) ppartdied_new=partdied_new 
(sum) t_married_new=married_new (sum) t_cohab_new=cohab_new (sum) t_single_new=singlenpd_new (sum) t_partdied_new=partdied_new 
[fw=round(weight)];
#d cr
li
save "stock2009_marriage_prevalence_combined.dta", replace
restore
