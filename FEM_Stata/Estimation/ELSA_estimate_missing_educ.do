/*
This script will estimate an oprobit model for education, then this model will be used to impute missing education information in GlobalPreInitializationModule.

Author: Luke Archer
Email:  l.archer@leeds.ac.uk
Date: 11/11/20
 */
capture log close

clear all

quietly include ../../fem_env.do

log using ELSA_estimate_missing_educ.log, replace

* Start with long data
use $outdata/ELSA_long.dta, clear


* Generate Age splines
local age_var age
gen l2age65l = min(63, l2`age_var') if l2`age_var' < .
label var l2age65l "Min(63, two-year lag of age)"
gen l2age6574 = min(max(0, l2`age_var' - 63), 73-63) if l2`age_var' < .
label var l2age6574 "Min(Max(0, two-year lag age - 63), 73 - 63)"
gen l2age75p = max(0, l2`age_var' - 73) if l2`age_var' < .
label var l2age75p "Max(0, two-year lag age - 73)"

* Generate interaction variable for married and spouse education. This way we wont be dropping cases that are unmarried just because they're missing this var
* interaction_var will == 0 when not married, and have the educ value when married
gen married_educl_interaction = married * educl
replace married_educl_interaction = 0 if missing(educl)

* Label some missing values as 0 so we don't drop them from the model. About 20,000 responses of .a so going to replace all these as 0
replace radadeduage = 0 if radadeduage == .a
replace ramomeduage = 0 if ramomeduage == .a


* Collect vars for prediction and selection criteria into local
local predict_vars male white l2age65l l2age6574 l2age75p married_educl_interaction radadeduage ramomeduage 
* educl         - spouses harmonised education level
* ramomeduage   - Age mother stopped education
* radadeduage   - Age father stopped education

* Set multiple ster directories for baseline, cross validation 1&2, and minimal runs
local ster1 "$local_path/Estimates/ELSA"
local ster2 "$local_path/Estimates/ELSA/CV1"
local ster3 "$local_path/Estimates/ELSA/CV2"
local ster4 "$local_path/Estimates/ELSA_minimal"
local ster5 "$local_path/Estimates/ELSA_core"

dis "oprobit educ `predict_vars'

quietly sum educ

di r(N)

if r(N)>0 {
    oprobit educ `predict_vars'
    ch_est_title "Education (educ) coefficients"
    mfx2, stub(o_educ) nose
    est save "`ster1'/educ.ster", replace
    est save "`ster2'/educ.ster", replace
    est save "`ster3'/educ.ster", replace
    est save "`ster4'/educ.ster", replace
    est save "`ster5'/educ.ster", replace
    est restore o_educ_mfx
        ch_est_title "Education (educ) marginal effects"
        est store o_educ_mfx
}

predict educ_pred
sum educ educ_pred if !died [aw=cwtresp]

capture log close
