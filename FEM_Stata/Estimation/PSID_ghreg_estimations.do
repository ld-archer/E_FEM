/** \file
This is the file that runs the PSID ghreg models. 

**/
/*********************************************************************/
*	SEP UP DIRECTORIES
/*********************************************************************/

* Assume that this script is being executed in the FEM_Stata/Estimation directory

* Load environment variables from the root FEM directory, three levels up
* these define important paths, specific to the user
set more off
quietly include "../../fem_env.do"
capt ssc install estout mfx2

local defmod : env suffix

local bsamp : env BREP

local chk_bs : env CHK_BS

if missing("`chk_bs'") {
	local chk_bs = 0
}

if missing("`bsamp'") {
	log using "./PSID_ghreg_transition`defmod'.log", replace
	if !missing("`defmod'"){
		global ster "$local_path/Estimates/PSID/`defmod'"
	}
	else {
		global ster "$local_path/Estimates/PSID"
	}
}
else {
	log using "./bootstrap_logs/PSID_ghreg_transition_bootstrap`bsamp'_`defmod'.log", replace
	if !missing("`defmod'"){
		global ster "$local_path/Estimates/PSID/`defmod'/models_rep`bsamp'"
	}
	else {
		global ster "$local_path/Estimates/PSID/models_rep`bsamp'"
	}
}

adopath ++ "$local_path/Estimation"
adopath ++ "$local_path/hyp_mata"
adopath ++ "$local_path/utilities"
adopath ++ "$local_path/Makedata/HRS"



set matsize 10000


	
/*********************************************************************/
* USE DATA AND RECODE
/*********************************************************************/

dis "Current time is: " c(current_time) " on " c(current_date)

if missing("`bsamp'") {
	use "$outdata/psid_transition.dta"
}
else {
	use "$outdata/input_rep`bsamp'/psid_transition.dta"
}

quietly include psid_covariate_definitions`defmod'.do	
quietly include psid_define_models`defmod'.do

/*********************************************************************/
*ESTIMATE EARNINGS
/*********************************************************************/


preserve
clear mata

egen x = h(2*3)
egen y = h(6)
assert x == y
drop x y



foreach n in hatota {
  drop iearn hatota
  rename iearnx iearn
  rename hatotax hatota

  local x "allvars_`n'"		
  ghreg `n' $`x' if `select_`n''
  mat A = e(b)'
  matrix colnames A = Beta
  matlist A, twidth(24) title(`n')
  gen e_`n' = e(sample)
  summ `n' if e_`n' == 1
  global max = r(max)
  global theta = e(theta)
  global omega = e(omega)
  global ssr = e(ssr)
  disp "theta omega ssr max"
  disp $theta " " $omega " " $ssr " " $max
  estimates store i_`n'
  predict simu_`n', simu
  
  	if `chk_bs'==1 {
		* check that the model will behave well in bootstrap samples
		di "Checking bootstrap variation in `n' model predictors"
		foreach v in $`x' {
			qui count if missing(`v') & e_`n'==1
			if r(N) > 0 {
				di "WARNING: `v' is missing for in-sample (e_`n'==1) observations"
			}
  		chk_bootstrap_variation `v' sestrat seclust e_`n' 0.0005
		}
	}
  
  keep simu_`n' `n' year e_`n' work
  save "$outdata/`n'_simulated.dta", replace	
  restore, preserve
  
  ghreg_vars, vars($`x' _cons)
  est save "$ster/`n'.ster", replace
  
}

xml_tab i_* , save("$ster/PSID_ghreg_estimates.xml") replace sheet(ghreg) stats(N r2_a)

/*
* Estimate log models
foreach n in iearn_ft iearn_pt  {
	local x "allvars_`n'"
  reg ln`n' $`x' if `select_`n'' [aw=weight]
	est save "$ster/ln`n'.ster", replace
}
*/

clear mata
cap log close

