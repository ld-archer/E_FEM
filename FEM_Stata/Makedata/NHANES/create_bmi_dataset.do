/* August, 2012 - This file will replicate and extend the obestiy projections following Christopher Ruhm's paper from 2007 "Current
and Future Prevalence of Obesity and Severe Obesity in the United States." 

Ruhm used NHANES 2, NHANES3, and NHANES from 1999-2004 for his projections.  We will incorporate data through 2010.  Additionally, it will
allow us flexibiilty for predicting obesity prevalences in younger age cohorts.

This programs compile NHANES data in a way that is compatible with replicating the Ruhm paper.

UPDATES:
* Aug. 11 2013 - add NHANES I data to the datafile. Keep the rest as is.
*/

clear
clear mata
set more off
set mem 800m
set seed 5243212
set maxvar 10000

* Assume that this script is being executed in the FEM_Stata/Makedata/NHANES directory

* Load environment variables from the root FEM directory, three levels up
* these define important paths, specific to the user
include "../../../fem_env.do"

use $outdata/nhanes.dta

* keep those aged 20 to 74
keep if exam_age >= 20 & exam_age < 75

* age categories
gen age2529 = (exam_age > = 25 & exam_age < 30)
gen age3034 = (exam_age > = 30 & exam_age < 35)
gen age3539 = (exam_age > = 35 & exam_age < 40)
gen age4044 = (exam_age > = 40 & exam_age < 45)
gen age4549 = (exam_age > = 45 & exam_age < 50)
gen age5054 = (exam_age > = 50 & exam_age < 55)
gen age5559 = (exam_age > = 55 & exam_age < 60)
gen age6064 = (exam_age > = 60 & exam_age < 65)
gen age6569 = (exam_age > = 65 & exam_age < 70)
gen age7074 = (exam_age > = 70 & exam_age < 75)

* Following Ruhm
gen age4656 = (exam_age > = 46 & exam_age < 57)
* For PSID/FAM
gen age2535 = (exam_age > = 25 & exam_age < 36)

* normalize weights for all waves except NHANES3
gen weight_norm = .
local cohorts nhanes1972 nhanes1976 nhanes1999 nhanes2001 nhanes2003 nhanes2005 nhanes2007 nhanes2009 nhanes2011 nhanes2013 nhanes2015
foreach cht in `cohorts' {
	qui sum exam_wght if cohort=="`cht'"
	replace weight_norm = exam_wght/r(sum) if cohort=="`cht'"
}
* NHANES3 is a special case: normalize weights as if two samples
foreach ph in "Phase 1" "Phase 2" {
	qui sum exam_wght if cohort=="nhanes1988" & cohort_88=="`ph'"
	replace weight_norm = exam_wght/r(sum) if cohort=="nhanes1988" & cohort_88=="`ph'"
}

* derive since75 variable
gen since75 = .
replace since75 = exam_yr - 1975 if cohort=="nhanes1972" | cohort=="nhanes1976"
replace since75 = 1989.5 - 1975 if cohort=="nhanes1988" & cohort_88=="Phase 1"
replace since75 = 1992.5 - 1975 if cohort=="nhanes1988" & cohort_88=="Phase 2"
forvalues yr=1999(2)2009 {
	replace since75 = `yr' + 0.5 - 1975 if cohort=="nhanes`yr'"
}


drop if cohort=="nhanes1972" & (exam_wght ==. | exam_wght ==0)

rename bmi bmxbmi
rename exam_age age

keep bmxbmi male black hisp other age* since75 cohort weight_norm age exam_yr exam_wght cohort_88 bmi_sr


save $outdata/nhanes_bmi.dta, replace

desc

codebook 

sort cohort cohort_88
collapse (sum) exam_wght weight_norm, by(cohort cohort_88)
list
