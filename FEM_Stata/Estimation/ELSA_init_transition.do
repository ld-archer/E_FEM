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

log using "./ELSA_init_transition_`defmod'.log", replace

* Use the `scen` argument from Makefile to pick the ster directory
if !missing("`defmod'") {
	* Either baseline or one of cross validation models
	if "`defmod'" == "ELSA" | "`defmod'" == "CV1" | "`defmod'" == "CV2" {
		local ster "$local_path/Estimates/ELSA"
	}
	else if "`defmod'" == "minimal" {
		local ster "$local_path/Estimates/ELSA_minimal"
	}
	else if "`defmod'" == "core" | "`defmod'" == "core_CV1" | "`defmod'" == "core_CV2" {
		local ster "$local_path/Estimates/ELSA_core"
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

if "`defmod'" == "CV1" | "`defmod'" == "CV2" {
	include ELSA_covariate_definitionsELSA.do
}
else if "`defmod'" == "core_CV1" | "`defmod'" == "core_CV2" {
	include ELSA_covariate_definitionscore.do
}
else {
	include ELSA_covariate_definitions`defmod'.do
}

include ELSA_sample_selections.do

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
		outreg using "`ster'/`n'-outreg.doc", replace
        
        * For cross validation 1
        if "`defmod'" == "CV1" | "`defmod'" == "core_CV1" {
            probit `n' $`x' if `select_`n'' & transition==1
            est save `ster'/CV1/`n'.ster, replace
            eststo cv_`n'
        }

		* For cross validation 2
        if "`defmod'" == "CV2" | "`defmod'" == "core_CV2" {
            probit `n' $`x' if `select_`n''
            est save `ster'/CV2/`n'.ster, replace
            eststo cv_`n'
        }
    }
    local i = `i' + 1
}

esttab mod_* using `ster'/estim_parameters`defmod'.csv, replace

* For cross validation
if "`defmod'" == "CV1" | "`defmod'" == "core_CV1" {
    esttab cv_* using `ster'/CV1/estim_parameters`defmod'.csv, replace
}
else if "`defmod'" == "CV2" | "`defmod'" == "core_CV2" {
	esttab cv_* using `ster'/CV2/estim_parameters`defmod'.csv, replace
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
		outreg using "`ster'/`n'-outreg.doc", replace
			
    	*for cross validation 1
    	if "`defmod'" == "CV1" | "`defmod'" == "core_CV1" {
    		reg `n' $`x' if `select_`n'' & transition==1
    		est save `ster'/CV1/`n'.ster, replace
		}

		*for cross validation 2
    	if "`defmod'" == "CV2" | "`defmod'" == "core_CV2" {
    		reg `n' $`x' if `select_`n''
    		est save `ster'/CV2/`n'.ster, replace
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
		outreg using "`ster'/`n'-outreg.doc", replace
			
    	*for cross validation
    	if "`defmod'" == "CV1" | "`defmod'" == "core_CV1" {
	  	  oprobit `n' $`x' if `select_`n'' & transition==1
          est save `ster'/CV1/`n'.ster, replace
		}

		*for cross validation 2
    	if "`defmod'" == "CV2" | "`defmod'" == "core_CV2" {
	  	  oprobit `n' $`x' if `select_`n''
          est save `ster'/CV2/`n'.ster, replace
		}
	}
    local i = `i'+1
}

/*********************************************************************/
* ESTIMATE UNORDERED OUTCOMES
/*********************************************************************/

local i = 1
foreach n in $unorder {
	local modname: word `i' of "$unorder_names"
	local coef_name = "`modname'" + " (`n') coefficients"
	di "`n' - `coef_name'"
  	local mfx_name = "`modname'" + " (`n') marginal effects"
  	di "`n' - `mfx_name'"
  	local x = "allvars_`n'"
	dis "mlogit `n' $`x' if `select_`n''"
    quietly sum `n' if `select_`n''
    if r(N)>0{
    	mlogit `n' $`x' if `select_`n''
    	ch_est_title "`coef_name'"
    	mfx2, stub(m_`n') nose
    	est save "`ster'/`n'.ster", replace
    	est restore m_`n'_mfx
			ch_est_title "`mfx_name'"
			est store m_`n'_mfx
		outreg using "`ster'/`n'-outreg.doc", replace
			
    	*for cross validation
    	if "`defmod'" == "CV1" | "`defmod'" == "core_CV1"  {
	  	  mlogit `n' $`x' if `select_`n'' & transition==1
          est save `ster'/CV1/`n'.ster, replace
		}

		*for cross validation 2
    	if "`defmod'" == "CV2" | "`defmod'" == "core_CV2" {
	  	  mlogit `n' $`x' if `select_`n''
          est save `ster'/CV2/`n'.ster, replace
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
* also write default estimates as a sheet in the file to be distributed with tech appendix
if "`defmod'" == "ELSA_core" {
	xml_tab b_*, save("`ster'/estimates`defmod'.xls") replace sheet(binaries) pvalue
	xml_tab o_*, save("`ster'/estimates`defmod'.xls") append sheet(oprobits) pvalue `drops'
	xml_tab ols_*, save("`ster'/estimates`defmod'.xls") append sheet(ols) pvalue
	*xml_tab ols_*, save("`ster'/estimates`defmod'.xls") append sheet(ols) pvalue

	xml_tab b_*, save("`ster'/FEM_estimates_table.xml") replace sheet(binaries) pvalue
	xml_tab o_*, save("`ster'/FEM_estimates_table.xml") append sheet(oprobits) pvalue `drops'
	xml_tab ols_*, save("`ster'/FEM_estimates_table.xml") append sheet(ols) pvalue
}
else if "`defmod'" == "CV1" | "`defmod'" == "core_CV1" {
	xml_tab b_*, save("`ster'/CV1/estimates`defmod'.xls") replace sheet(binaries) pvalue
	xml_tab o_*, save("`ster'/CV1/estimates`defmod'.xls") append sheet(oprobits) pvalue `drops'
	xml_tab ols_*, save("`ster'/CV1/estimates`defmod'.xls") append sheet(ols) pvalue

	xml_tab b_*, save("`ster'/CV1/FEM_estimates_table.xml") replace sheet(binaries) pvalue
	xml_tab o_*, save("`ster'/CV1/FEM_estimates_table.xml") append sheet(oprobits) pvalue `drops'
	xml_tab ols_*, save("`ster'/CV1/FEM_estimates_table.xml") append sheet(ols) pvalue
}
else if "`defmod'" == "CV2" | "`defmod'" == "core_CV2" {
	xml_tab b_*, save("`ster'/CV2/estimates`defmod'.xls") replace sheet(binaries) pvalue
	xml_tab o_*, save("`ster'/CV2/estimates`defmod'.xls") append sheet(oprobits) pvalue `drops'
	xml_tab ols_*, save("`ster'/CV2/estimates`defmod'.xls") append sheet(ols) pvalue

	xml_tab b_*, save("`ster'/CV2/FEM_estimates_table.xml") replace sheet(binaries) pvalue
	xml_tab o_*, save("`ster'/CV2/FEM_estimates_table.xml") append sheet(oprobits) pvalue `drops'
	xml_tab ols_*, save("`ster'/CV2/FEM_estimates_table.xml") append sheet(ols) pvalue
}
