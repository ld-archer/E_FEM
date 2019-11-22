/*********************************************************************************************************************/
****** ESTIMATE PSID MODELS
** Naming convention for models saved files: 
** VARNAME_condCONDITION.ster
** with CONDITION equal to "if" statement in the estimation line
** Store if condition - the macro saved with model not long enough so we need to save it separately. 
** Save additional file as VARNAME_condCONDITION.txt
** (The problem is resolved in Stata 13)
/*********************************************************************************************************************/

clear all
set more off

set matsize 10000

include "../../fem_env.do"

local defmod : env suffix
local datain : env DATAIN
local bsamp : env BREP
local chk_bs : env CHK_BS

if missing("`chk_bs'") {
	local chk_bs = 0
}

if missing("`bsamp'") {
	log using "./PSID_transition`defmod'.log", replace
	if !missing("`defmod'"){
		global ster "$local_path/Estimates/PSID/`defmod'"
	}
	else {
		global ster "$local_path/Estimates/PSID"
	}
}
else {
	log using "./bootstrap_logs/PSID_transition_bootstrap`bsamp'_`defmod'.log", replace
	if !missing("`defmod'"){
		global ster "$local_path/Estimates/PSID/`defmod'/models_rep`bsamp'"
	}
	else {
		global ster "$local_path/Estimates/PSID/models_rep`bsamp'"
	}
}

di "ster path:"
di "`ster'"

adopath ++ "$local_path/Estimation"
adopath ++ "$local_path/hyp_mata"
adopath ++ "$local_path/utilities"
adopath ++ "$local_path/Makedata/HRS"

if missing("`bsamp'") {
	use "$outdata/psid_transition.dta", clear
}
else {
	use "$outdata/input_rep`bsamp'/psid_transition.dta", clear
}

* Merge on the flag for cross-validation
merge m:1 hhidpn using $outdata/psid_crossvalidation.dta

* Run these after the data have been loaded so that variables can be verified to exist
include psid_covariate_definitions`defmod'.do	
include psid_define_models`defmod'.do

count
keep if age >= 25
count

/***********************************************************************/
* Estimate Probits
/***********************************************************************/

foreach n of varlist $bin_hlth $bin_econ $bin_mstat {
	local x = "allvars_`n'"	
	di "allvars_`n'"
	probit `n' $`x' if `select_`n''
	gen e_`n' = e(sample)
	if missing("`bsamp'") {
		mfx2, stub(b_`n') nose
	}
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

/*********************************************************************/
* ESTIMATE OLS models
/*********************************************************************/

	foreach n in $ols {
		local x = "allvars_`n'"	
		reg `n' $`x' if `select_`n''
		gen e_`n' = e(sample)
		if missing("`bsamp'") {
			mfx2, stub(ols_`n') nose
		}
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
			reg `n' $`x' if `select_`n'' & transition == 1
			est save "$ster/crossvalidation/`n'.ster", replace
		}
	}


/*********************************************************************/
* ESTIMATE Ordered Probits
/*********************************************************************/
foreach n in $order {
	local x = "allvars_`n'"
	oprobit `n' $`x' if `select_`n''	
	gen e_`n' = e(sample)
	if missing("`bsamp'") {
  	mfx2, stub(o_`n') nose
  }
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
		oprobit `n' $`x' if `select_`n'' & transition == 1
		est save "$ster/crossvalidation/`n'.ster", replace
	}
}


/*********************************************************************/
* ESTIMATE MULTINOMIAL LOGIT 
/*********************************************************************/
foreach n in $multlogit {
	local x = "allvars_`n'"
	mlogit `n' $`x' if `select_`n''
	gen e_`n' = e(sample)
	if missing("`bsamp'") {
  	mfx2, stub(ml_`n') nose
  }
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
		mlogit `n' $`x' if `select_`n'' & transition == 1
		est save "$ster/crossvalidation/`n'.ster", replace
	}
}


/*********************************************************************/
* ESTIMATE MULTINOMIAL PROBIT - Marriage status transitions
/*********************************************************************/
/*
*** PRELIMIARY MODELS ****
*** Estimation conditional on status in previous period: single (1), cohabitating (2) or married (3) 
*** Single includes separated, widow, divorced
*** Transitions allowed from any status to the same or any other stautus
*** Single includes separated, divorced or widow
*** To Do: add transition to widow - suggestion: estimate in a second stage, only among those transitioning 
*		from married to single, an indicator for widow (opposed to separated or divorced) 
*** Output model name mstat_newm`x'_ms`l' (x=0/1 for female/male, l=1,2,3 indicating previous period status
*** single, cohabitating, married

*****************************************************************************
***** Three level variable (single, cohab, married)

levelsof(mstat_new), local(varlvls)
di "varlvls are" `varlvls'
local cnt = 1
local mp_nv=""
local mp_ceq=""

gen simu_mstat_new_1 =.
gen simu_mstat_new_2 =.
gen simu_mstat_new_3 =.
foreach l of local varlvls{
	forvalues x = 0/1{
			local mod="mstat_new_cond`cnt'"
			
			* rename mstat_new so that the .est file will have the correct predited variable (this needs to be handled better)
			* it can be done not in the .est themselves, not in the .ster files. There is code for this approach 
			rename mstat_new `mod'
			* mprobit mstat_new ${mstat_f`l'} if l2mstat_new == `l' & male==`x' & !(mstat_new==1 & partdied & !l2partdied), iter(100)
			mlogit mstat_new ${mstat_f`l'} if l2mstat_new == `l' & male==`x' & !(mstat_new==1 & partdied & !l2partdied), iter(100)
			gen e_`mod' = e(sample)
			predict simu_1 simu_2 simu_3 if e(sample)==1
			forvalues j=1/3{
				replace simu_mstat_new_`j'=simu_`j' if e(sample)==1
				drop simu_`j'
			}
			if missing("`bsamp'") {
				mfx2, stub(mp_`mod') nose
			}
			est save "$ster/`mod'.ster",replace
			* reverse previous renaming
			rename `mod' mstat_new
			*store the "if condition" defining the subsample
			*- the macro saved with the model is not long enough so we need to save it separately. The problem is resolved in Stata 13
			!echo "l2mstat_new == `l' & male==`x'" > $ster/`mod'.txt
			local mp_nv="`mp_nv' mp_`mod'_mfx"
			local cnt=`cnt'+1

		if `chk_bs'==1 {
		* check that the model will behave well in bootstrap samples
		di "Checking bootstrap variation in `mod' model predictors"
		foreach v in ${mstat_f`l'} {
			qui count if missing(`v') & e_`mod'==1
			if r(N) > 0 {
				di "WARNING: `v' is missing for in-sample (e_`mod'==1) observations"
			}
  		chk_bootstrap_variation `v' sestrat seclust e_`mod' 0.0005
		}
	}
	}
}
*/
if missing("`bsamp'") {
	save $outdata/psid_predicted_outcomes.dta, replace
}
else {
	save $outdata/input_rep`bsamp'/psid_predicted_outcomes.dta, replace
}





*** Estimate models that use the pooled HRS/PSID sample
use "$outdata/psid_hrs_transition.dta", clear

replace source = "hrs" if missing(source)
* Merge on the crossvalidation (PSID) flags
merge m:1 hhidpn using $outdata/psid_crossvalidation.dta
replace transition = 1 if source == "hrs"


foreach n of varlist $bin_psid_hrs {
	local x = "allvars_`n'"
	probit `n' $`x' if `select_`n''
	gen e_`n' = e(sample)
	if missing("`bsamp'") {
		mfx2, stub(b_`n') nose
	}
	est save "$ster/`n'.ster", replace
	matrix m`n' = e(b) 
	predict simu_`n' if e_`n' == 1
	
	* For crossvalidation
	if missing("`bsamp'") {
		probit `n' $`x' if `select_`n'' & transition == 1
		est save "$ster/crossvalidation/`n'.ster", replace
	}
}

*** Output models

// Stata 15 + xml_tab + ordered outcomes = ERROR
if(floor(c(version))>=14) {
  local drops drop(cut*)
}
else {
  local drops
}


* Don't do this when bootstrapping a lot of reps because it takes a long time
if missing("`bsamp'") {
	* Binaries
	* xml_tab b_*, save("$ster/estimates_psid.xml") replace sheet(binaries) pvalue
	* Ordered probits
	* xml_tab o_*, save("$ster/estimates_psid.xml") append sheet(oprobits) pvalue
	* OLS
	* xml_tab ols_*, save("$ster/estimates_psid.xml") append sheet(ols) pvalue
	* Multinomial logit
	* xml_tab ml_*, save("$ster/estimates_psid.xml") append sheet(ml) pvalue 
	
	*xml_tab mp_*_mfx, save("$ster/estimates_psid_mp.xml") replace sheet(mp) 
	
	* Binary models
	foreach n of varlist $bin_hlth {
		local bin_hlth `bin_hlth' b_`n'_coef b_`n'_mfx
	} 
	xml_tab `bin_hlth', save("$ster/estimates_psid.xml") replace sheet(bin_hlth) pvalue
	foreach n of varlist $bin_econ {
		local bin_econ `bin_econ' b_`n'_coef b_`n'_mfx
	}
	xml_tab `bin_econ', save("$ster/estimates_psid.xml") append sheet(bin_econ) pvalue
	foreach n of varlist $bin_mstat {
		local bin_mstat `bin_mstat' b_`n'_coef b_`n'_mfx
	}
	xml_tab `bin_mstat', save("$ster/estimates_psid.xml") append sheet(bin_mstat) pvalue
	
	
	* Ordered probits
	foreach n of varlist $order {
		local oprobits `oprobits' o_`n'_coef o_`n'_mfx
	}
	xml_tab `oprobits', save("$ster/estimates_psid.xml") append sheet(oprobits) pvalue `drops'
	
	* OLS models
	foreach n of varlist $ols {
		local ols `ols' ols_`n'_coef ols_`n'_mfx
	}
	xml_tab `ols', save("$ster/estimates_psid.xml") append sheet(ols) pvalue
	
	* Multinomial logit
	foreach n of varlist $multlogit {
		local multlogit `multlogit' ml_`n'_coef ml_`n'_mfx
	}
	* xml_tab `multlogit', save("$ster/estimates_psid.xml") append sheet(multlogit) pvalue 
	xml_tab ml_*, save("$ster/estimates_psid.xml") append sheet(multlogit) pvalue 
	
	
	* Pooled mortality models
	foreach n of varlist $bin_psid_hrs {
		local mortality `mortality' b_`n'_coef b_`n'_mfx
	}
	xml_tab `mortality', save("$ster/estimates_psid.xml") append sheet(mortality) pvalue 
}

shell touch $ster/psid_estimates.txt

capture log close
