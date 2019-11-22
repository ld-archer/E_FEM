/*
This file will create new25 files of just hs dropouts under various BMI adjustment scenarios

*/

include ../../../fem_env.do

local scen no_obese 
local year 2009

/* Baseline for those with less than HS */
use $outdata/new25s_default.dta, clear
keep if year == `year'
keep if educlvl == 1
save $outdata/new25_`year'_default_all_educ1.dta, replace
* Create file with just non-whites
preserve
keep if white == 0
save $outdata/new25_`year'_default_min_educ1.dta, replace
restore
* Create file with just those in low SES as children
keep if fpoor == 1
save $outdata/new25_`year'_default_poor_educ1.dta, replace


foreach scr of local scen {
	/* Now change the BMI */
	use $outdata/new25s_`scr'.dta, clear
	keep if year == `year'
	keep if educlvl == 1
	save $outdata/new25_`year'_`scr'_all_educ1.dta, replace
	* Create file with just non-whites
	preserve
	keep if white == 0
	save $outdata/new25_`year'_`scr'_min_educ1.dta, replace
	restore
	keep if fpoor == 1
	save $outdata/new25_`year'_`scr'_poor_educ1.dta, replace
	
}


/* Alternative approach to set those HS less to have HS BMI distribution */

/* Baseline for those with less than HS */
use $outdata/new25s_default.dta, clear
keep if year == `year'

* Hotdeck values for HS less population
keep if educlvl == 1 | educlvl == 2
replace bmi = . if educlvl == 1
hotdeck bmi, by(male) keep(hhidpn) store 
drop bmi
merge hhidpn using imp1.dta, sort
drop _merge
rm imp1.dta

* Reassign variables for imputed cases
replace logbmi = log(bmi) if educlvl == 1
replace wtstate = 1 if bmi < 25 & educlvl == 1
replace wtstate = 2 if bmi >= 25 & bmi < 30 & educlvl == 1
replace wtstate = 3 if bmi >= 30 & bmi < 35 & educlvl == 1
replace wtstate = 4 if bmi >= 35 & bmi < 40 & educlvl == 1
replace wtstate = 5 if bmi >= 40 & educlvl == 1

save $outdata/new25_2009_hs_wtstate.dta, replace

keep if educlvl == 1
save $outdata/new25_`year'_hs_wtstate_all_educ1.dta, replace
* Create file with just non-whites
preserve
keep if white == 0
save $outdata/new25_`year'_hs_wtstate_min_educ1.dta, replace
restore
* Create file with just those in low SES as children
keep if fpoor == 1
save $outdata/new25_`year'_hs_wtstate_poor_educ1.dta, replace







capture log close

