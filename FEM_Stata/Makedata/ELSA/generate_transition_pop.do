clear

log using generate_transition_pop.log, replace

quietly include ../../../fem_env.do

local in_file : env INPUT

local out_file : env OUTPUT

*use ../../../input_data/ELSA_long.dta, clear
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
local age_var age
gen l2age65l = min(63, l2`age_var') if l2`age_var' < .
label var l2age65l "Min(63, two-year lag of age)"
gen l2age6574 = min(max(0, l2`age_var' - 63), 73-63) if l2`age_var' < .
label var l2age6574 "Min(Max(0, two-year lag age - 63), 73 - 63)"
gen l2age75p = max(0, l2`age_var' - 73) if l2`age_var' < .
label var l2age75p "Max(0, two-year lag age - 73)"

* Age sex
gen male_l2age65l = male * l2age65l
label var male_l2age65l "Male and Min(63, two-year lag of age)"
gen male_l2age6574 = male * l2age6574
label var male_l2age6574 "Male and Min(Max(0, two-year lag age - 63), 73 - 63)"
gen male_l2age75p = male * l2age75p
label var male_l2age75p "Male and Max(0, two-year lag age - 73)"

* Age squared
gen l2agesq = l2`age_var'*l2`age_var'

* BMI dummies for obese (BMI > 30.0) or not
replace l2obese = (l2logbmi > log(30.0)) if !missing(l2logbmi)

* BMI splines
local log_20 = log(20)
local log_25 = log(25)
local log_30 = log(30)
local log_35 = log(35)
local log_40 = log(40)
mkspline l2logbmi_l20 `log_20' l2logbmi_2025 `log_25' l2logbmi_2530 `log_30' l2logbmi_3035 `log_35' l2logbmi_3540 `log_40' l2logbmi_40p = l2logbmi
*mkspline l2logbmi_l30 `log_30' l2logbmi_30p = l2logbmi

*label var l2logbmi_l30 "Splined two-year lag of BMI <= log(30)"
*label var l2logbmi_30p "Splined two-year lag of BMI > log(30)"

label var l2logbmi_l20 "Splined two-year lag of BMI < log(20)"
label var l2logbmi_2025 "Splined two-year lag of BMI between log(20) - log(25)"
label var l2logbmi_2530 "Splined two-year lag of BMI between log(25) - log(30)"
label var l2logbmi_3035 "Splined two-year lag of BMI between log(30) - log(35)"
label var l2logbmi_3540 "Splined two-year lag of BMI between log(35) - log(40)"
label var l2logbmi_40p "Splined two-year lag of BMI > log(40)"

* Label the variables to use for technical appendix
label variable male "Male"
label variable hsless "Less than secondary school"
label variable college "More than secondary school"
label variable l2age65l "Lag: age spline less than 65"
label variable l2age6574 "Lag: age spline between 65-74"
label variable l2age75p "Lag: age spline more than 75"
label variable l2smoken "Lag: current smoker"
label variable l2smokev "Lag: ever smoked"
label variable l2obese "Lag: BMI more than 30"
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
*label variable l2logbmi_l30 "Lag: BMI less than 30"
*label variable l2logbmi_30p "Lag: BMI over 30"


* Save the file
*save ../../../input_data/ELSA_transition.dta, replace
save $outdata/ELSA_transition.dta, replace

inspect

capture log close
