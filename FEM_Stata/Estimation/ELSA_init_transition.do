/*
This file runs all the ELSA-based models.
The file relies on an evironment variable defining covariate variables (env var
is used to call a do file containing covariates).

suffix - suffix to the program define_models[suffix].do
suffix cannot be empty, this script will produce and error

The program will be run almost exclusively from the Makefile, but can be run 
from the command line as follows:
suffix=minimal stata-se -b do init_transitions.do

*/

clear all
set more off
set seed 5000
set maxvar 10000
set matsize 10000
est drop _all

*========================================================*
* Estimate transition
* Apr 14, 2020: First started writing the script. Using init_transition.do as template
*========================================================*

/*********************************************************************/
*	SET UP DIRECTORIES
/*********************************************************************/

* Assuming this script is being executed in the FEM_Stata/Estimation directory

* Load environment variables from the root directory, three? levels up

quietly include ../../fem_env.do

* Define paths
local defmod: env SUFFIX
local datain: env DATAIN
*local bsamp: env BREP
*local extval: env EXTVAL

log using "./init_transition_`defmod'.log", replace
if !missing("`defmod'") {
	if "`defmod'" == "CV" {
		local ster "$local_path/Estimates/ELSA"
	}
	else {
		local ster "$local_path/Estimates/`defmod'"
	}
}
else {
	di as error "The ELSA_init_transition.do script requires a suffix input"
	exit 197
}

/*********************************************************************/
* USE DATA AND RECODE
/*********************************************************************/

dis "Current time is: " c(current_time) " on " c(current_date)

* Load in data
*use "`datain'"
use $outdata/ELSA_transition.dta
*use ../../input_data/ELSA_transition.dta

* merge on transition ID for cross-validation
merge m:1 idauniq using "$outdata/cross_validation/crossvalidation.dta", keepusing(transition)
tab _merge
drop if _m==2

if "`defmod'" == "CV" {
	include ELSA_covariate_definitionsELSA.do
}
else {
	include ELSA_covariate_definitions`defmod'.do
}

include ELSA_sample_selections.do
*include define_models`defmod'.do

set more off

/*********************************************************************/
* ESTIMATE BINARY OUTCOMES
/*********************************************************************/

local bin_hlth_econ_names "$bin_hlth_names" "$bin_econ_names" /*"$bin_treatments_names" UNNECESSARY*/
local i = 1

foreach n of varlist $bin_hlth $bin_econ /*$bin_treatments*/ {
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
        
        * For cross validation
        if "`defmod'" == "CV" {
            probit `n' $`x' if `select_`n'' & transition==1
            est save `ster'/crossvalidation/`n'.ster, replace
            eststo cv_`n'
        }
    }
    local i = `i' + 1
}

esttab mod_* using `ster'/estim_parameters`defmod'.csv, replace

* For cross validation
if "`defmod'" == "CV" {
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
    	if "`defmod'" == "CV" {
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
    	if "`defmod'" == "CV" {
	  	  oprobit `n' $`x' if `select_`n'' & transition==1
          est save `ster'/crossvalidation/`n'.ster, replace
		}
	}
    local i = `i'+1
}

shell touch `ster'/estimates`defmod'.txt

/*
// Stata 15 + xml_tab + ordered outcomes = ERROR
if(floor(c(version))>=14) {
  local drops drop(cut*)
}
else {
  local drops
}
*/

*** Output models
xml_tab b_*, save("`ster'/estimates`defmod'.xls") replace sheet(binaries) pvalue
xml_tab o_*, save("`ster'/estimates`defmod'.xls") append sheet(oprobits) pvalue `drops'
xml_tab ols_*, save("`ster'/estimates`defmod'.xls") append sheet(ols) pvalue

* also write default estimates as a sheet in the file to be distributed with tech appendix
if("`defmod'" == "ELSA") {
	xml_tab b_*, save("`ster'/FEM_estimates_table.xml") replace sheet(binaries) pvalue
	xml_tab o_*, save("`ster'/FEM_estimates_table.xml") append sheet(oprobits) pvalue `drops'
	xml_tab ols_*, save("`ster'/FEM_estimates_table.xml") append sheet(ols) pvalue
}
