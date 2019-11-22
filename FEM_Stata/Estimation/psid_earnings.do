/** \file
Estimate any earnings and earnings amount by work status 

**/
/*********************************************************************/
*	SEP UP DIRECTORIES
/*********************************************************************/

* Assume that this script is being executed in the FEM_Stata/Estimation directory

* Load environment variables from the root FEM directory, three levels up
* these define important paths, specific to the user

quietly include "../../fem_env.do"

local defmod : env suffix

local bsamp : env BREP

local chk_bs : env CHK_BS

if missing("`chk_bs'") {
	local chk_bs = 0
}

if missing("`bsamp'") {
	log using "./psid_earnings_transition`defmod'.log", replace
	if !missing("`defmod'"){
		global ster "$local_path/Estimates/PSID/`defmod'"
	}
	else {
		global ster "$local_path/Estimates/PSID"
	}
}
else {
	log using "./bootstrap_logs/psid_earnings_transition_bootstrap`bsamp'_`defmod'.log", replace
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
* USE DATA 
/*********************************************************************/

dis "Current time is: " c(current_time) " on " c(current_date)

if missing("`bsamp'") {
	use "$outdata/psid_transition.dta", clear
}
else {
	use "$outdata/input_rep`bsamp'/psid_transition.dta"
}

* Merge on the flag for cross-validation
merge m:1 hhidpn using $outdata/psid_crossvalidation.dta


quietly include psid_covariate_definitions`defmod'.do	
quietly include psid_define_models`defmod'.do

/*********************************************************************/
*ESTIMATE EARNINGS
/*********************************************************************/

* 99+% of full-time and part-time workers have earnings, so only worry about censoring in unemployed and not in labor force cases
tab any_iearn_ft
tab any_iearn_pt
tab any_iearn_ue
tab any_iearn_nl

* Models for non-zero earnings (only doing unemployed and not in labor force)
foreach n in any_iearn_ue any_iearn_nl {
	local x = "allvars_`n'"	
	probit `n' $`x' if `select_`n''
	gen e_`n' = e(sample)
	mfx2, stub(b_`n') nose
	est save "$ster/`n'.ster", replace
	matrix m`n' = e(b) 
	predict simu_`n' if e_`n' == 1

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
	
	* For crossvalidation
	if missing("`bsamp'") {
		probit `n' $`x' if `select_`n'' & transition == 1
		est save "$ster/crossvalidation/`n'.ster", replace
	}
}

* Estimate log models
foreach n in lniearn_ft lniearn_pt lniearn_ue lniearn_nl {
	local x = "allvars_`n'"
		reg `n' $`x' if `select_`n''
		gen e_`n' = e(sample)
    mfx2, stub(ols_`n') nose
		est save "$ster/`n'.ster", replace
		matrix m`n' = e(b) 
		predict simu_`n' if e_`n' == 1
		predict resid_`n' if e_`n' == 1, residuals

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
		
		*For crossvalidation
		if missing("`bsamp'") {
			reg `n' $`x' if `select_`n'' & transition == 1
			est save "$ster/crossvalidation/`n'.ster", replace
		}
	}

if missing("`bsamp'") {
	save $outdata/psid_earnings_predictions.dta, replace
}

xml_tab b_*, save("$ster/earnings_estimates_psid.xml") replace sheet(binaries) pvalue
xml_tab ols_*, save("$ster/earnings_estimates_psid.xml") append sheet(ols) pvalue

cap log close

