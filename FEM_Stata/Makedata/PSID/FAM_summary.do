clear
clear mata
set more off
cap log close


include "../../../fem_env.do"

* Estimation file 
use "$outdata/psid_transition.dta", clear

* A little data cleaning that should be done at an earlier stage of the process
drop if age == 999
drop if year == 1999

* Recode adlstat and iadlstat to dummy variables (index starts at 1 for zero adl or iadl)
foreach var in ladl fadl {
	gen `var'1 = (`var'stat == 2)
	gen `var'2 = (`var'stat == 3)
	gen `var'3p = (`var'stat >= 4 & `var'stat < .)
	replace `var'1 = . if `var'stat == .
	replace `var'2 = . if `var'stat == .
	replace `var'3p = . if `var'stat == .
}
foreach var in liadl fiadl {	
 	gen `var'1 = (`var'stat == 2)
	gen `var'2p = (`var'stat >= 3 & `var'stat < .)
	replace `var'1 = . if `var'stat == .
	replace `var'2p = . if `var'stat == .
}

* Generate age dummy variables
local age_var age
	gen lage65l  = min(63,l`age_var') if l`age_var' < .
	gen lage6574 = min(max(0,l`age_var'-63),73-63) if l`age_var' < .
	gen lage75p = max(0, l`age_var'-73) if l`age_var' < . 

	* Generate obestiy splines
	gen llogbmi = log(lbmi)
	gen flogbmi = log(fbmi)	
	local log_30 = log(30)
	mkspline llogbmi_l30 `log_30' llogbmi_30p = llogbmi
	mkspline flogbmi_l30 `log_30' flogbmi_30p = flogbmi
	
	
	* Generate logbmi outcome variable
	gen logbmi = log(bmi) if bmi > 0 & bmi < .

* Summarize
codebook

********************************************************************************************************************************

* Simulation file
use "$outdata/test_simul.dta", replace

codebook

capture log close