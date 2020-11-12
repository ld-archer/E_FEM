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
local age_var agey
gen l2age65l = min(63, l2`age_var') if l2`age_var' < .
label var l2age65l "Min(63, two-year lag of age)"
gen l2age6574 = min(max(0, l2`age_var' - 63), 73-63) if l2`age_var' < .
label var l2age6574 "Min(Max(0, two-year lag age - 63), 73 - 63)"
gen l2age75p = max(0, l2`age_var' - 73) if l2`age_var' < .
label var l2age75p "Max(0, two-year lag age - 73)"


* Collect vars for prediction and selection criteria into local
local predict_vars male white l2age65l l2age6574 l2age75p educl ramomeduage radadeduage work retemp
* educl         - spouses harmonised education level
* ramomeduage   - Age mother stopped education
* radadeduage   - Age father stopped education

* Set ster directory as the normal ster dir
local ster "$local_path/Estimates/ELSA"

dis "oprobit educ `predict_vars'

quietly sum educ

di r(N)

if r(N)>0 {
    oprobit educ `predict_vars'
    ch_est_title "Education (educ) coefficients"
    mfx2, stub(o_educ) nose
    est save "`ster'/educ.ster", replace
    est restore o_educ_mfx
        ch_est_title "Education (educ) marginal effects"
        est store o_educ_mfx
}

predict educ_pred
sum educ educ_pred if !died [aw=cwtresp]

capture log close
