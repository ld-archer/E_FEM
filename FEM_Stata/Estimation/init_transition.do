/** \file
This is the file that runs all the HRS-based models. 
This version of the file relies on one environment variable defining covariate variables (env var is used to call a do file defining covariates).
suffix - suffix to the program define_models[sufix].do When empty, the base models are run

The program should be run from the command line as follows:
suffix=minimal stata-mp -b do init_transition.do 

\todo read Capellari 2003

\todo read Capellari 2006

\todo if feasible, use mnvp to estimate state transition matrix rather than individual transitions

*/
clear all
set mem 500m
set more off
set seed 52432
set maxvar 10000
set matsize 10000
est drop _all

*==========================================================================*
* Estimate transition
* Apr 8, 2008: add age dummies (lage62e,lage65e) to labor participation and SS claiming
* Cohort effects for weight and hh wealth
* Apr 13, 2008: For wealth, use emprical distribution,dont use log transformation
* Jun 23, 2008: For wealth, use generalized inverse hyperbolic sine  transformation - dummy variables for waves and zero/non-zero
* GET THE THETA/OMEGA/SSR SAVED.
* Sep 6, 2008: This re-estimate mortality by including those alive but not interviewed
* 							remove BMI and smoking (initial and lag) from estimation 
* Sep 21, 2008, change age dummies for ss claiming equation
* Sep 22, 2008, change age dummies for working equation, re-run all estimations
* Keep obesity and overweight variables only in disease and functional status, smoking and weight equations
* Sep 27, correct for mis-specified covariates
* 9/21/2009 - Eliminated explicit PC Stata path references. Use fem_path global instead
* 9/21/2009 - Use exact ages for estimation, age_iwe, the age at the end of the interview
* 9/21/2009 - Changed the iearnx_simu and hatotax_simu filenames to ***_simulated because they are writeprotected by AHG
* 9/21/2009 - Added logdeltaage = log(age_iwe - lage_iwe) as a covariate to account for differences in time between interviews
* 12/15/2009 - Changed rbyr to frbyr as the regressor because frbyr stays at the HRS value while rbyr increases for future incoming cohorts
*  1/13/2010 - Added memrye as a health outcome
*2/26 - expand BMI
*3/11/2010 - Change BMI estimation to be ols on log(bmi)
* 6/3/2013 - generalize the program to define covariates for models in a separate program.
* =========================================================================*

/*********************************************************************/
*	SEP UP DIRECTORIES
/*********************************************************************/

* Assume that this script is being executed in the FEM_Stata/Estimation_2 directory

* Load environment variables from the root FEM directory, three levels up
* these define important paths, specific to the user

include "../../fem_env.do"

* Define paths

local defmod : env suffix
local datain : env DATAIN
local bsamp : env BREP
local extval : env EXTVAL

if missing("`bsamp'") {
	log using "./init_transition_`defmod'.log", replace
	if !missing("`defmod'"){
		if `extval'==0{
			local ster "$local_path/Estimates/`defmod'"
			}
			else if `extval'==1{
				local ster "$local_path/Estimates/`defmod'_extval"
			}
	}
	else {
          di as error "the init_transition script now requires a suffix input"
          exit 197
	}
}
else {
	log using "./bootstrap_logs/init_transition_bootstrap`bsamp'_`defmod'.log", replace
	if !missing("`defmod'"){
		local ster "$local_path/Estimates/`defmod'/models_rep`bsamp'"
	}
	else {
          di as error "the init_transition script now requires a suffix input"
          exit 197
	}
}
	
/*********************************************************************/
* USE DATA AND RECODE
/*********************************************************************/

dis "Current time is: " c(current_time) " on " c(current_date)

if missing("`bsamp'") {
	use "`datain'"
}
else {
	use "$outdata/input_rep`bsamp'/hrs112_transition.dta"
}

* merge on transition ID flag for cross validation
merge m:1 hhidpn using "$outdata/crossvalidation.dta" , keepusing(transition)
drop if _m==2
keep if wave>4
if `extval'==1 {
	keep if wave<=7
	}

include hrs_covariate_definitions`defmod'.do	
include define_models`defmod'.do
	
set more off

/*********************************************************************/
* ESTIMATE BINARY OUTCOMES
/*********************************************************************/

	local bin_hlth_econ_names "$bin_hlth_names" "$bin_econ_names" "$bin_treatments_names"
	local i = 1
  foreach n of varlist $bin_hlth $bin_econ $bin_treatments {
  	local modname: word `i' of "`bin_hlth_econ_names'"
  	local coef_name = "`modname'" + " (`n') coefficients"
  	di "`n' - `coef_name'"
  	local mfx_name = "`modname'" + " (`n') marginal effects"
  	di "`n' - `mfx_name'"
    local x = "allvars_`n'"
    quietly sum `n' if `select_`n''
    if r(N)==0 {
    	di "Model did not run because no observations meet the selection criteria"
    }
    else {
    	probit `n' $`x' if `select_`n''
    	ch_est_title "`coef_name'"
    	mfx2, stub(b_`n') nose
    	est save "`ster'/`n'.ster", replace
    	eststo mod_`n'
    	est restore b_`n'_mfx
			ch_est_title "`mfx_name'"
			est store b_`n'_mfx
    
    	* for cross validation
   	 if missing("`bsamp'") {
    		probit `n' $`x' if `select_`n'' & transition==1
    		est save `ster'/crossvalidation/`n'.ster, replace
    		eststo cv_`n'
    	}
		}
    local i = `i'+1
  }
esttab mod_* using `ster'/estim_parameters`defmod'.csv, replace

* for cross validation
if missing("`bsamp'") {
	esttab cv_* using `ster'/crossvalidation/estim_parameters`defmod'.csv, replace
}
	
/*********************************************************************/
* ESTIMATE OLS
/*********************************************************************/

	local i = 1
	foreach n in $ols {
   	local modname: word `i' of "$ols_names"
  	local coef_name = "`modname'" + " (`n') coefficients"
  	di "`n' - `coef_name'"
  	local mfx_name = "`modname'" + " (`n') marginal effects"
  	di "`n' - `mfx_name'"
    local x = "allvars_`n'"
    quietly sum `n' if `select_`n''
    if r(N)>0{
    	reg `n' $`x' if `select_`n''
    	ch_est_title "`coef_name'"
    	mfx2, stub(ols_`n') nose
    	est save "`ster'/`n'.ster", replace
    	est restore ols_`n'_mfx
			ch_est_title "`mfx_name'"
			est store ols_`n'_mfx
			
    	*for cross validation
    	if missing("`bsamp'") {
    		reg `n' $`x' if `select_`n'' & transition==1
    		est save `ster'/crossvalidation/`n'.ster, replace
			}
		}
    local i = `i'+1
  }


/*********************************************************************/
* ESTIMATE ORDERED OUTCOMES
/*********************************************************************/

	local i = 1
  foreach n in $order {
   	local modname: word `i' of "$order_names"
  	local coef_name = "`modname'" + " (`n') coefficients"
  	di "`n' - `coef_name'"
  	local mfx_name = "`modname'" + " (`n') marginal effects"
  	di "`n' - `mfx_name'"
  	local x = "allvars_`n'"
    dis "oprobit `n' $`x' if `select_`n''"
    quietly sum `n' if `select_`n''
    if r(N)>0{
    	oprobit `n' $`x' if `select_`n''
    	ch_est_title "`coef_name'"
    	mfx2, stub(o_`n') nose
    	est save "`ster'/`n'.ster", replace
    	est restore o_`n'_mfx
			ch_est_title "`mfx_name'"
			est store o_`n'_mfx
			
    	*for cross validation
    	if missing("`bsamp'") {
	  	  oprobit `n' $`x' if `select_`n'' & transition==1
 	  	 est save `ster'/crossvalidation/`n'.ster, replace
			}
		}
    local i = `i'+1
  }

shell touch `ster'/estimates`defmod'.txt

// Stata 15 + xml_tab + ordered outcomes = ERROR
if(floor(c(version))>=14) {
  local drops drop(cut*)
}
else {
  local drops
}

*** Output models
xml_tab b_*, save("`ster'/estimates`defmod'.xls") replace sheet(binaries) pvalue
xml_tab o_*, save("`ster'/estimates`defmod'.xls") append sheet(oprobits) pvalue `drops'
xml_tab ols_*, save("`ster'/estimates`defmod'.xls") append sheet(ols) pvalue

* also write default estimates as a sheet in the file to be distributed with tech appendix
if("`defmod'" == "HRS") {
	xml_tab b_*, save("`ster'/FEM_estimates_table.xml") replace sheet(binaries) pvalue
	xml_tab o_*, save("`ster'/FEM_estimates_table.xml") append sheet(oprobits) pvalue `drops'
	xml_tab ols_*, save("`ster'/FEM_estimates_table.xml") append sheet(ols) pvalue
}
