/* Estimate utilization models using the HRS.  

These are:
number of hospital nights in past two years
number of doctor visits in past two years

These measures are being developed for comparison with other microsimulation models that
use the HRS-like survey measures for utilization.

Assessing:
Poisson
Zero-inflated Poisson
Negative Binomial
Zero-inflated Negative Binomial

*/

* Files for globals
quietly include ../../fem_env.do
include hrs_covariate_definitions.do
include define_models.do

* The outcomes we will estimate
global cnt_util doctim hspnit

* The RHS variables

global allvars_hlth $dvars l2age65l l2age6574 l2age75p $lvars_hlth

global allvars_doctim $allvars_hlth
global allvars_hspnit $allvars_hlth

* Selection for estimating the model
local select_doctim !l2died & wave > 4
local select_hspnit !l2died & wave > 4


* Use the data
use $outdata/hrs19_transition.dta, replace


* Estimate the models
foreach n of varlist $cnt_util {
	local x = "allvars_`n'"
	
	* Poisson
	poisson `n' $`x' if `select_`n''
	predict p_`n'_poi if e(sample)
	gen insamp_`n' = e(sample) 
	
	* Zero-inflated Poisson
  zip `n' $`x' if `select_`n'', inflate($`x') probit
  predict p_`n'_zip if e(sample)
  
  * Negative Binomial
  nbreg `n' $`x' if `select_`n''
  predict p_`n'_nb if e(sample)
    
  * Zero-inflated negative binomial
  zinb `n' $`x' if `select_`n'', inflate($`x') probit
  predict p_`n'_zinb if e(sample)
  
  * mfx2, stub(b_`n') nose
  * est save "`ster'/`n'.ster", replace
  * eststo mod_`n'
  * est restore b_`n'_mfx
	* ch_est_title "`mfx_name'"
	* est store b_`n'_mfx
	* predict p_`n' if e(sample)
}

save $outdata/hrs_utilization.dta, replace


* Compare the predictions
foreach var of varlist doctim p_doctim_* {
	di "Var is `var'"
	sum `var' if insamp_doctim, detail
}

foreach var of varlist hspnit p_hspnit_* {
	di "Var is `var'"
	sum `var' if insamp_hspnit, detail
}

capture log close
 