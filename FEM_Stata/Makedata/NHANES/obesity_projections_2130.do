/* August, 2012 - This file will replicate and extend the obestiy projections following Christopher Ruhm's paper from 2007 "Current
and Future Prevalence of Obesity and Severe Obesity in the United States." 

Ruhm used NHANES 2, NHANES3, and NHANES from 1999-2004 for his projections.  We will incorporate data through 2010.  Additionally, it will
allow us flexibiilty for predicting obesity prevalences in younger age cohorts.

This file now estimates the BMI trajectories for individuals aged 21 to 30, starting in 2004.

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


* This local specifies which year the projections begin.  Use 2004 for validation, 2010 for use in simulation
local yr = 2010


/* 
NHANES 2 - 1976-1980

Variables of interest:  	age - N2BM0190					race - N2BM0056				ancestry - N2BM0060
												gender - N2BM0055				height (cm with 1 decimal place ) - N2BM0418
												weight (kg with 2 decimal places) - N2BM0412
												Sampling weight - N2BM0288		Exam year - N2BM0188

Need to derive: BMI, since75
*/

tempfile nhanes2
use $nhanes_dir/stata/nhanes2/d_5301.dta, replace
keep seqn N2BM0190 N2BM0056 N2BM0060 N2BM0055 N2BM0418 N2BM0412 N2BM0288 N2BM0188

* gender recode
gen male = (N2BM0055 == 1)

* race/ethnicity recode
gen hisp = (N2BM0060 >= 1 & N2BM0060 <= 8)
gen black = (N2BM0056 == 2 & hisp == 0)
gen other = (N2BM0056 == 3 & hisp == 0)

* keep those aged 20 to 74
keep if N2BM0190 >= 20 & N2BM0190 < 75

* age categories
gen age2529 = (N2BM0190 > = 25 & N2BM0190 < 30)
gen age3034 = (N2BM0190 > = 30 & N2BM0190 < 35)
gen age3539 = (N2BM0190 > = 35 & N2BM0190 < 40)
gen age4044 = (N2BM0190 > = 40 & N2BM0190 < 45)
gen age4549 = (N2BM0190 > = 45 & N2BM0190 < 50)
gen age5054 = (N2BM0190 > = 50 & N2BM0190 < 55)
gen age5559 = (N2BM0190 > = 55 & N2BM0190 < 60)
gen age6064 = (N2BM0190 > = 60 & N2BM0190 < 65)
gen age6569 = (N2BM0190 > = 65 & N2BM0190 < 70)
gen age7074 = (N2BM0190 > = 70 & N2BM0190 < 75)

* Following Ruhm
gen age4656 = (N2BM0190 > = 46 & N2BM0190 < 57)
* For PSID/FAM
gen age2535 = (N2BM0190 > = 25 & N2BM0190 < 36)
gen age2130 = (N2BM0190 > = 21 & N2BM0190 < 31)

* Derive BMI = weight[kg]/(height[m])^2
gen bmxbmi = (N2BM0412/100)/(N2BM0418/1000)^2
gen since75 = N2BM0188 - 75

* normalize weights
qui sum N2BM0288
gen weight_norm = N2BM0288/r(sum)

gen cohort = "nhanes1976"

save `nhanes2'



/*  NHANES3 - 1988-1994

Variables of Interest:  	
age (months at exam) - mxpaxtmr
race - dmaracer
ethnicity - dmaethnr
gender - hssex
bmi - bmpbmi
sampling weight - WTPFEX1 (first wave) WTPFEX2 (second wave)

files:  adult.dta   exam.dta

*/

tempfile nhanes3
use $nhanes_dir/stata/nhanes3/exam.dta
keep seqn bmpbmi

merge 1:1 seqn using $nhanes_dir/stata/nhanes3/adult.dta, keepusing(mxpaxtmr dmaracer dmaethnr hssex WTPFEX1 WTPFEX2) keep(matched)
drop _merge

* recode BMI
rename bmpbmi bmxbmi
replace bmxbmi = . if bmxbmi == 8888

* gender recode
gen male = (hssex == 1)

* race/ethnicity recode
gen hisp = (dmaethnr == 1 | dmaethnr == 2)
gen black = (dmaracer == 2 & hisp == 0)
gen other = (dmaracer == 3 & hisp == 0)
 
* keep those aged 20 to 74
keep if mxpaxtmr >= 20*12 & mxpaxtmr < 75*12
 
* Age categories
gen age2529 = (mxpaxtmr > = 25*12 & mxpaxtmr < 30*12)
gen age3034 = (mxpaxtmr > = 30*12 & mxpaxtmr < 35*12)
gen age3539 = (mxpaxtmr > = 35*12 & mxpaxtmr < 40*12)
gen age4044 = (mxpaxtmr > = 40*12 & mxpaxtmr < 45*12)
gen age4549 = (mxpaxtmr > = 45*12 & mxpaxtmr < 50*12)
gen age5054 = (mxpaxtmr > = 50*12 & mxpaxtmr < 55*12)
gen age5559 = (mxpaxtmr > = 55*12 & mxpaxtmr < 60*12)
gen age6064 = (mxpaxtmr > = 60*12 & mxpaxtmr < 65*12)
gen age6569 = (mxpaxtmr > = 65*12 & mxpaxtmr < 70*12)
gen age7074 = (mxpaxtmr > = 70*12 & mxpaxtmr < 75*12)

* Following Ruhm
gen age4656 = (mxpaxtmr > = 46*12 & mxpaxtmr < 57*12)

* For PSID/FAM
gen age2535 = (mxpaxtmr > = 25*12 & mxpaxtmr < 36*12)
gen age2130 = (mxpaxtmr > = 21*12 & mxpaxtmr < 31*12)


* derive since75 variable
gen since75 = 1989.5 - 1975 if WTPFEX1 < .
replace since75 = 1992.5 - 1975 if WTPFEX2 < .

* normalize weights as if two samples
qui sum WTPFEX1
gen weight_norm = WTPFEX1/r(sum) if WTPFEX1 < .
qui sum WTPFEX2
replace weight_norm = WTPFEX2/r(sum) if WTPFEX2 < .

gen cohort = "nhanes1988"

save `nhanes3'



* NHANES 1999-2000
tempfile nhanes99
use $nhanes_dir/stata/1999-2000/bmx.dta, replace
keep seqn bmxwt bmiwt bmxht bmiht bmxbmi
merge 1:1 seqn using $nhanes_dir/stata/1999-2000/demo.dta, keepusing(riagendr ridageyr ridageex ridreth1 dmdeduc2 ridexprg wtint2yr wtmec2yr sdmvpsu sdmvstra) keep(matched)
drop _merge
gen since75 = 1999.5 - 1975

* keep only those between 20 and 74
keep if ridageex >= 20*12 & ridageex < 75*12

* reweight
qui sum wtmec2yr
gen weight_norm = wtmec2yr/r(sum)
gen cohort = "nhanes1999"
save `nhanes99'
 
* NHANES 2001-2002
tempfile nhanes01
use $nhanes_dir/stata/2001-2002/bmx_b.dta, replace
keep seqn bmxwt bmiwt bmxht bmiht bmxbmi
merge 1:1 seqn using $nhanes_dir/stata/2001-2002/demo_b.dta, keepusing(riagendr ridageyr ridageex ridreth1 dmdeduc2 ridexprg wtint2yr wtmec2yr sdmvpsu sdmvstra) keep(matched)
drop _merge
gen since75 = 2001.5 - 1975
* keep only those between 20 and 74
keep if ridageex >= 20*12 & ridageex < 75*12
* reweight
qui sum wtmec2yr
gen weight_norm = wtmec2yr/r(sum)
gen cohort = "nhanes2001"
save `nhanes01'

* NHANES 2003-2004
tempfile nhanes03
use $nhanes_dir/stata/2003-2004/bmx_c.dta, replace
keep seqn bmxwt bmiwt bmxht bmiht bmxbmi
merge 1:1 seqn using $nhanes_dir/stata/2003-2004/demo_c.dta, keepusing(riagendr ridageyr ridageex ridreth1 dmdeduc2 ridexprg wtint2yr wtmec2yr sdmvpsu sdmvstra) keep(matched)
drop _merge
gen since75 = 2003.5 - 1975
* keep only those between 20 and 74
keep if ridageex >= 20*12 & ridageex < 75*12
* reweight
qui sum wtmec2yr
gen weight_norm = wtmec2yr/r(sum)
gen cohort = "nhanes2003"
save `nhanes03'

* NHANES 2005-2006
tempfile nhanes05
use $nhanes_dir/stata/2005-2006/bmx_d.dta, replace
keep seqn bmxwt bmiwt bmxht bmiht bmxbmi
* NO ridreth2 variable *
merge 1:1 seqn using $nhanes_dir/stata/2005-2006/demo_d.dta, keepusing(riagendr ridageyr ridageex ridreth1 dmdeduc2 ridexprg wtint2yr wtmec2yr sdmvpsu sdmvstra) keep(matched)
drop _merge
gen since75 = 2005.5 - 1975
* keep only those between 20 and 74
keep if ridageex >= 20*12 & ridageex < 75*12
* reweight
qui sum wtmec2yr
gen weight_norm = wtmec2yr/r(sum)
gen cohort = "nhanes2005"
save `nhanes05'

* NHANES 2007-2008
tempfile nhanes07
use $nhanes_dir/stata/2007-2008/bmx_e.dta, replace
keep seqn bmxwt bmiwt bmxht bmiht bmxbmi
merge 1:1 seqn using $nhanes_dir/stata/2007-2008/demo_e.dta, keepusing(riagendr ridageyr ridageex ridreth1 dmdeduc2 ridexprg wtint2yr wtmec2yr sdmvpsu sdmvstra) keep(matched)
drop _merge
gen since75 = 2007.5 - 1975
* keep only those between 20 and 74
keep if ridageex >= 20*12 & ridageex < 75*12
* reweight
qui sum wtmec2yr
gen weight_norm = wtmec2yr/r(sum)
gen cohort = "nhanes2007"
save `nhanes07'

* NHANES 2009-2010
tempfile nhanes09
use $nhanes_dir/stata/2009-2010/bmx_f.dta, replace
keep seqn bmxwt bmiwt bmxht bmiht bmxbmi
merge 1:1 seqn using $nhanes_dir/stata/2009-2010/demo_f.dta, keepusing(riagendr ridageyr ridageex ridreth1 dmdeduc2 ridexprg wtint2yr wtmec2yr sdmvpsu sdmvstra) keep(matched)
drop _merge
gen since75 = 2009.5 - 1975
* keep only those between 20 and 74
keep if ridageex >= 20*12 & ridageex < 75*12
* reweight
qui sum wtmec2yr
gen weight_norm = wtmec2yr/r(sum)
gen cohort = "nhanes2009"
save `nhanes09'

use `nhanes99', replace
append using `nhanes01' `nhanes03' `nhanes05' `nhanes07' `nhanes09'





* Recode variables for 1999-2010

* Male
gen male = (riagendr == 1)

* Race/ethnicity
gen black = (ridreth1 == 4)
gen hisp =  (ridreth1 == 1 | ridreth1 == 2)
gen other = (ridreth1 == 5)

* Generate age categories based on age at exam
gen age2529 = (ridageex > = 25*12 & ridageex < 30*12)
gen age3034 = (ridageex > = 30*12 & ridageex < 35*12)
gen age3539 = (ridageex > = 35*12 & ridageex < 40*12)
gen age4044 = (ridageex > = 40*12 & ridageex < 45*12)
gen age4549 = (ridageex > = 45*12 & ridageex < 50*12)
gen age5054 = (ridageex > = 50*12 & ridageex < 55*12)
gen age5559 = (ridageex > = 55*12 & ridageex < 60*12)
gen age6064 = (ridageex > = 60*12 & ridageex < 65*12)
gen age6569 = (ridageex > = 65*12 & ridageex < 70*12)
gen age7074 = (ridageex > = 70*12 & ridageex < 75*12)

* Following Ruhm
gen age4656 = (ridageex > = 46*12 & ridageex < 57*12)
* For PSID/FAM
gen age2535 = (ridageex > = 25*12 & ridageex < 36*12)
gen age2130 = (ridageex > = 21*12 & ridageex < 31*12)

* Append the 1976-1980 and the 1988-1994 file to the 1999-2010 file
append using `nhanes2' `nhanes3'

keep bmxbmi male black hisp other age* since75 cohort weight_norm

save $outdata/nhanes_bmi.dta, replace



* Estimate the quantile regressions for all 25-35 year olds in 2003-2004
keep if age2130 == 1

local k = 99


forvalues x = 1/`k' {
	di `x'
	tempfile percentile_`x'
	qreg bmxbmi male black hisp other since75 [aw=weight_norm], quantile(`x')
	preserve
	collapse (mean) male black hisp other since75 [aw = weight_norm], by(cohort)
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

save `percentiles', replace


use `percentiles', replace

* For legibility purposes in interpolation equations
rename p_bmi pbmi

sort year percentile

* Identify the percentiles for overweight (bmi > 25), obese_1 (bmi > 30), obese_2 (bmi > 35), and obese_3 (bmi > 40) at specific years
gen wtstate1 = (pbmi >= 25)
gen wtstate2 = (pbmi >= 30)
gen wtstate3 = (pbmi >= 35)
gen wtstate4 = (pbmi >= 40)

* find the first percentile observation for each year that reaches the differnet weight states
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
save $outdata/obesity_projections_2130_`yr', replace




capture log close
