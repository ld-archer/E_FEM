/** \file
This is the file that runs			 models. 
This version of the file relies on one environment variable defining covariate variables (env var is used to call a do file defining covariates).
suffix - suffix to the program define_models[sufix].do When empty, the base models are run

The program should be run from the command line as follows:
sufix=minimal stata-mp -b do ghreg_estimations.do 
**/
/*********************************************************************/
*	SEP UP DIRECTORIES
/*********************************************************************/

* Assume that this script is being executed in the FEM_Stata/Estimation_2 directory

* Load environment variables from the root FEM directory, three levels up
* these define important paths, specific to the user
set more off
include "../../fem_env.do"

* Define paths
local defmod : env suffix
local datain : env DATAIN

log using "./ghreg_estimations_`defmod'.log", replace
if !missing("`defmod'"){
	local ster "$local_path/Estimates/`defmod'"
}
else {
  di as error "The ghreg_estimations script now requires a suffix input"
  exit 197
}		
	
/*********************************************************************/
* USE DATA AND RECODE
/*********************************************************************/

dis "Current time is: " c(current_time) " on " c(current_date)

use "`datain'"
keep if wave>4

* merge on transition ID flag for cross validation
merge m:1 hhidpn using "$outdata/crossvalidation.dta" , keepusing(transition)
drop if _m==2

include hrs_covariate_definitions`defmod'.do
include define_models`defmod'.do


/*********************************************************************/
*ESTIMATE EARNINGS
/*********************************************************************/


preserve
clear mata

egen x = h(2*3)
egen y = h(6)
assert x == y
drop x y

#d ;
global ihs_names
"Earnings"
"Uncapped earnings"
"Household wealth"
;
#d cr


local i = 1
foreach n in iearn iearnuc hatota {
  drop hatota
  rename iearnx iearn
  rename hatotax hatota

  local modname: word `i' of "$ihs_names"
  local coef_name = "`modname'" + " (`n') coefficients"
  di "`n' - `coef_name'"
  local x "allvars_`n'"
  ghreg `n' $`x' if `select_`n''

  gen e_`n' = e(sample)
  summ `n' if e_`n' == 1
  global max = r(max)
  global theta = e(theta)
  global omega = e(omega)
  global ssr = e(ssr)
  disp "theta omega ssr max"
  disp $theta " " $omega " " $ssr " " $max
  ch_est_title "`coef_name'"
  estimates store i_`n'
  predict simu_`n', simu
  keep simu_`n' `n' wave e_`n' work
  save "$outdata/`n'_simulated.dta", replace	
  restore, preserve
  
  ghreg_vars, vars($`x' _cons)
  est save "`ster'/`n'.ster", replace
  
  local i = `i'+1
}


* repeat for crossvalidation

local i = 1
foreach n in iearn iearnuc hatota {

  drop  hatota
  rename iearnx iearn
  rename hatotax hatota

  local modname: word `i' of "$ihs_names"
  local coef_name = "`modname'" + " (`n') coefficients"
  di "`n' - `coef_name'"
  local x "allvars_`n'"
  ghreg `n' $`x' if `select_`n'' & transition==1

  gen e_`n'_cv = e(sample)
  summ `n' if e_`n'_cv == 1
  global max = r(max)
  global theta = e(theta)
  global omega = e(omega)
  global ssr = e(ssr)
  disp "theta omega ssr max"
  disp $theta " " $omega " " $ssr " " $max
  ch_est_title "`coef_name'"
  estimates store i_`n'
  predict simu_`n', simu
  keep simu_`n' `n' wave e_`n' work
  save "$outdata/`defmod'`n'_simulated_cv.dta", replace	
  restore, preserve
  
  ghreg_vars, vars($`x' _cons)
  est save "`ster'/crossvalidation/`n'.ster", replace

  local i = `i'+1
}

xml_tab i_* , save("`ster'/ghreg`defmod'.xls") replace sheet(ghreg) pvalue

if("`defmod'" == "") {
	xml_tab i_* , save("`ster'/FEM_estimates_table.xml") append sheet(ghreg) pvalue
}

cap log close
