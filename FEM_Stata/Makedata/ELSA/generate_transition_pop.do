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
* Generate a 'knot' at BMI == 30 to make sure we don't lose the right tail in our projections
*gen l2logbmi_l30 = min(log(30), l2logbmi) if l2logbmi < .
*gen l2logbmi_30p = max(0, l2logbmi - log(30)) if l2logbmi < .

local log_30 = log(30)
mkspline l2logbmi_l30 `log_30' l2logbmi_30p = l2logbmi

label var l2logbmi_l30 "Splined two-year lag of BMI <= log(30)"
label var l2logbmi_30p "Splined two-year lag of BMI > log(30)"

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
label variable l2logbmi_l30 "Lag: BMI less than 30"
label variable l2logbmi_30p "Lag: BMI over 30"
label variable l2heavy_smoker "Lag: Heavy smoker (20+ cigs/day)"
label variable l2hchole "Lag: High Cholesterol"
label variable l2problem_drinker "Problem Drinker (12+ drinks in a week OR 7+ drinks in a day)"
label variable l2exstat1 "Lag: Activity level - Low"
label variable l2exstat2 "Lag: Activity level - Moderate"
label variable l2exstat3 "Lag: Activity level - High"
label variable l2drink "Lag: Drank alcohol in last 12 months"
label variable l2demene "Lag: Dementia"
label variable l2employed "Lag: Employed"
label variable l2unemployed "Lag: Unemployed"


* Save the file
*save ../../../input_data/ELSA_transition.dta, replace
save $outdata/ELSA_transition.dta, replace

inspect

capture log close
