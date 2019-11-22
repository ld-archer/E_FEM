clear all
set more off

quietly include "../../fem_env.do"

local defmod : env suffix
local datain : env DATAIN

log using "./education_transition`defmod'.log", replace
if !missing("`defmod'"){
	global ster "$local_path/Estimates/PSID/`defmod'"
}
else {
	global ster "$local_path/Estimates/PSID"
}

adopath ++ "$local_path/Estimation"
adopath ++ "$local_path/hyp_mata"
adopath ++ "$local_path/utilities"
adopath ++ "$local_path/Makedata/HRS"


use "$outdata/psid_transition.dta", clear

quietly include psid_covariate_definitions`defmod'.do	
quietly include psid_define_models`defmod'.do

gen l2educ1 = (l2educlvl == 1)
gen l2educ2 = (l2educlvl == 2)
gen l2educ3 = (l2educlvl == 3)
gen l2educ4 = (l2educlvl == 4)


/* Acquired any more education */
gen more_educ = .
replace more_educ = 0 if educlvl == l2educlvl
replace more_educ = 1 if inlist(educlvl,2,3,4) & l2educlvl == 1
replace more_educ = 1 if inlist(educlvl,3,4) & l2educlvl == 2
replace more_educ = 1 if inlist(educlvl,4) & l2educlvl == 3

tab more_educ

forvalues x = 1/4 {
	gen l2age_l2educ`x' = l2age*l2educ`x'
}

gen agecat1 =  0 <= l2aged & l2aged < 28
gen agecat2 = 28 <= l2aged & l2aged < 38
gen agecat3 = 38 <= l2aged & l2aged < 48
gen agecat4 = 48 <= l2aged & l2aged < 58
gen agecat5 = 58 <= l2aged & l2aged < 68
gen agecat6 = 68 <= l2aged & l2aged < 78
gen agecat7 = 78 <= l2aged & l2aged < 200






capture log close
