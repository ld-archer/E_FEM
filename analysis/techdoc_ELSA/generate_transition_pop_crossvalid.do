clear

log using generate_transition_pop.log, replace

quietly include ../../../fem_env.do

local in_file : env INPUT

local out_file : env OUTPUT

*use ../../../input_data/ELSA_long.dta, clear
*use ../../../input_data/ELSA_long_imputed.dta, clear
use $outdata/ELSA_long.dta, clear

keep if wave >= 2

* Add any additional derived variables used in the transition estimation (eg. categorical BMI variables)

* ADL dummy vars
gen l2adl1 = (l2adlstat == 2) if !missing(l2adlstat)
gen l2adl2 = (l2adlstat == 3) if !missing(l2adlstat)
gen l2adl3p = (l2adlstat == 4) if !missing(l2adlstat)

* IADL dummy vars
gen l2iadl1 = (l2iadlstat == 2) if !missing(l2iadlstat)
gen l2iadl2p = (l2iadlstat == 3) if !missing(l2iadlstat)

* Age splines
local age_var agey
gen l2age65l = min(63, l2`age_var') if l2`age_var' < .
label var l2age65l "Min(63, two-year lag of age)"
gen l2age6574 = min(max(0, l2`age_var' - 63), 73-63) if l2`age_var' < .
label var l2age6574 "Min(Max(0, two-year lag age - 63), 73 - 63)"
gen l2age75p = max(0, l2`age_var' - 73) if l2`age_var' < .
label var l2age75p "Max(0, two-year lag age - 73)"

* Age squared
gen l2agesq = l2`age_var'*l2`age_var'

* BMI dummies for obese (BMI > 23.5) or not
gen l2obese = (l2bmi > 25) if !missing(l2bmi)

* Label the variables to use for technical appendix
label variable male "Male"
label variable hsless "Less than secondary school"
label variable college "More than secondary school"
label variable l2age65l "Lag: age spline less than 65"
label variable l2age6574 "Lag: age spline between 65-74"
label variable l2age75p "Lag: age spline more than 75"
label variable l2smoken "Lag: current smoker"
label variable l2smokev "Lag: ever smoked"
label variable l2obese "Lag: BMI more than 23.5"
*label variable fsmoken50 "Smoked at 50" Variable never produced (should have been in reshape_long if at all)
label variable l2diabe "Lag: diabetes"
label variable l2cancre "Lag: cancer"
label variable l2hibpe "Lag: hypertension"
label variable l2lunge "Lag: lung disease"
label variable l2stroke "Lag: stroke"
label variable l2hearte "Lag: heart disease"
label variable l2adl1 "Lag: 1 ADL"
label variable l2adl2 "Lag: 2 ADL"
label variable l2adl3 "Lag: 3 or more ADLs"
label variable l2iadl1 "Lag: 1 IADL"
label variable l2iadl2p "Lag: 2 or more IADLs"


* Save the file
*save ../../../input_data/ELSA_transition.dta, replace
save $outdata/ELSA_transition.dta, replace

inspect

capture log close
