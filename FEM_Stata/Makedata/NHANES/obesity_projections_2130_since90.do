/* August, 2012 - This file will replicate and extend the obestiy projections following Christopher Ruhm's paper from 2007 "Current
and Future Prevalence of Obesity and Severe Obesity in the United States." 

Ruhm used NHANES 2, NHANES3, and NHANES from 1999-2004 for his projections.  We will incorporate data through 2010.  Additionally, it will
allow us flexibiilty for predicting obesity prevalences in younger age cohorts.

This file now estimates the BMI trajectories for individuals aged 21 to 30, starting in 2004.

*/

clear
clear mata
clear matrix
set more off
set mem 800m
set seed 5243212
set maxvar 10000

local stataver = floor(c(version))
if `stataver' >= 13 {
	local wghttp pw
}
else if `stataver' == 12 {
	local wghttp aw
}

* Assume that this script is being executed in the FEM_Stata/Makedata/NHANES directory

* Load environment variables from the root FEM directory, three levels up
* these define important paths, specific to the user
include "../../../fem_env.do"


* This local specifies which year the projections begin.  Use 2004 for validation, 2010 for use in simulation
local yr = 2010
* last year of NHANES data to use in estimating trends
local maxyr = 2010

use $outdata/nhanes.dta

* Only use data from 1999 through present maxyr
keep if exam_yr >= 1999 & exam_yr <= `maxyr'

* Time since 1975
gen since75 = exam_yr + 0.5 - 1975

gen age2130 = inrange(age_yrs,21,30)
keep if age2130 == 1

* Normalize the weights
bys exam_yr: egen totwt = total(exam_wght)
gen weight_norm = exam_wght/totwt


* Some summary stats to understand the source data
egen wtstate = cut(bmi), at(0,25,30,35,40,200)
tab year wtstate [aw=weight_norm], row

local k = 99
local yr = 2010

set more off
forvalues x = 1/`k' {
	di `x'
	tempfile percentile_`x'
	qreg bmi male black hisp other since75 [`wghttp'=weight_norm], quantile(`x')
	preserve
	collapse (mean) male black hisp other since75 [`wghttp'=weight_norm], by(cohort)
	gen percentile = `x'
	gen year = substr(cohort,-4,.)
	destring year, replace
	replace year = year+1
	* name was based on 2003-2004, so change to 2004
	keep if year == `yr'
	expand 60
	replace year = year + _n - 1
	replace since75 = year - 1975
	predict p_bmi
	save `percentile_`x''
	restore
}

tempfile percentiles

use `percentile_1', replace
forvalues x = 2 (1) `k' {
	qui append using `percentile_`x''
}

save `percentiles'


use `percentiles'

* For legibility purposes in interpolation equations
rename p_bmi pbmi

sort year percentile

* Identify the percentiles for overweight (bmi > 25), obese_1 (bmi > 30), obese_2 (bmi > 35), and obese_3 (bmi > 40) at specific years
gen wtstate1 = (pbmi >= 25)
gen wtstate2 = (pbmi >= 30)
gen wtstate3 = (pbmi >= 35)
gen wtstate4 = (pbmi >= 40)

* find the first percentile observation for each year that reaches the different weight states
by year: gen first_ws1 = cond(wtstate1[_n] == 1 & wtstate1[_n-1] == 0, 1, .)
by year: gen first_ws2 = cond(wtstate2[_n] == 1 & wtstate2[_n-1] == 0, 1, .)
by year: gen first_ws3 = cond(wtstate3[_n] == 1 & wtstate3[_n-1] == 0, 1, .)
by year: gen first_ws4 = cond(wtstate4[_n] == 1 & wtstate4[_n-1] == 0, 1, .)

* Linearly interpolate between the straddling percentiles
by year: gen ws1 = cond(wtstate1 == 1 & first_ws1 == 1, (((25-pbmi[_n-1])/(pbmi[_n]-pbmi[_n-1])) * (percentile[_n]-percentile[_n-1])) + percentile[_n-1], .) 
by year: gen ws2 = cond(wtstate2 == 1 & first_ws2 == 1, (((30-pbmi[_n-1])/(pbmi[_n]-pbmi[_n-1])) * (percentile[_n]-percentile[_n-1])) + percentile[_n-1], .) 
by year: gen ws3 = cond(wtstate3 == 1 & first_ws3 == 1, (((35-pbmi[_n-1])/(pbmi[_n]-pbmi[_n-1])) * (percentile[_n]-percentile[_n-1])) + percentile[_n-1], .) 
by year: gen ws4 = cond(wtstate4 == 1 & first_ws4 == 1, (((40-pbmi[_n-1])/(pbmi[_n]-pbmi[_n-1])) * (percentile[_n]-percentile[_n-1])) + percentile[_n-1], .) 

rename ws1 percentile_overweight
rename ws2 percentile_obese1
rename ws3 percentile_obese2
rename ws4 percentile_obese3

collapse (mean) percentile_overweight percentile_obese1 percentile_obese2 percentile_obese3, by(year)
sort year

* Save this file when 
save $outdata/obesity_projections_2130_since90_`yr', replace




capture log close
