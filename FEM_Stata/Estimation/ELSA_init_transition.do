/*
This file will run all the ELSA based models.

The file relies on an environment variable being defined in the Makefile, called 
'defmod'. The variable is used to call a do file defining covariate variables for
the scenario we are running, e.g. base models, minimal model, cross-validation.

*/

clear all
set more off
set seed 5000
set maxvar 10000

************************************************************
* Estimate Transitions
* March 27th: Script first written using init_transition.do as template.

************************************************************

* Load environment vars
quietly include ../../fem_env.do


* Define paths
local defmod : env SUFFIX
local datain : env DATAIN

log using ELSA_init_transition_`defmod'.log, replace

if !missing("`defmod'") {
	local ster "$local_path/Estimates/`defmod'"
}
else {
	di as error "The ELSA_init_transition script requires a suffix input"
	exit 197
}


************************************************************
* Use data and recode
************************************************************

* Display current time
dis "Current time is: " c(current_time) " on " c(current_date)

* Load in data specified in Makefile
use "`datain'"

* Merge on transition ID flag for cross-validation
merge m:1 hhidpn using "$outdata/crossvalidation.dta", keepusing(transition)
drop if _m==2

include ELSA_covariate_definitions`defmod'.do
include define_models`defmod'.do

set more off

/*********************************************************************/
* ESTIMATE BINARY OUTCOMES
/*********************************************************************/

* Globals for names set in 
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
