
/** \file
* Estimate costs models using MCBS for persons eligable for Medicare
* 10/10/2009 - Only estimate Pt A (B) costs for those enrolled in Pt A (B)

\todo add more age splines to medical expenditures

\todo stratify totmd into male and female

\todo compare totmd to totmd without ESRD patients
*/

local defmod : env suffix

clear all
set more off
est clear
set mem 500M
set maxvar 10000

* Assume that this script is being executed in the FEM_Stata/Estimation directory

* Load environment variables from the root FEM directory, two levels up
* these define important paths, specific to the user
include "../../fem_env.do"

local bsamp : env BREP

if missing("`bsamp'") {
	log using "./PSID_estimate_medcosts_mcbs`defmod'.log", replace
	if !missing("`defmod'"){
		global ster "$local_path/Estimates/PSID/`defmod'"
	}
	else {
		global ster "$local_path/Estimates/PSID"
	}
}
else {
	log using "./bootstrap_logs/PSID_estimate_medcosts_mcbs_bootstrap`bsamp'_`defmod'.log", replace
	if !missing("`defmod'"){
		global ster "$local_path/Estimates/PSID/`defmod'/models_rep`bsamp'"
	}
	else {
		global ster "$local_path/Estimates/PSID/models_rep`bsamp'"
	}
}

local seed  5654

**** Store the medical cpi into a matrix cross walk
*use "$indata/medcpi_cxw.dta"
*insheet using /nfs/sch-data-library/public-data/CPI/CPIMEDSL.csv, clear
*gen year = substr(date,5,4)
*destring year, replace
*ren value medcpi
*keep year medcpi
*mkmat medcpi, matrix(medcpi) rownames(year)


*** Define potential dependent variables used in the cost model 
global depvars age male black hispan hsless college widowed single cancre diabe hibpe hearte lunge stroke nhmliv adl3p diclaim died logiearnx
* using ages 65-69 as reference category
local agevars = "age2534 age3544 age4554 age5564 age7074 age7579 age8084 age85"

*** get the covariate definitions for defmod
include psid_mcbs_covariate_defs`defmod'.do	

	/*****************************************************************/
	/* IMPUTATION */
	/*****************************************************************/
	
	tempfile mcbs_imp`bsamp'
	
	drop _all
	use "$dua_mcbs_dir/mcbs_cost_est.dta"

* Define logiearnx
replace gross = gross/1000
egen logiearnx = h(gross)
replace logiearnx = logiearnx/100

	ren nrshom nhmliv
	keep if inrange(year,2007,2010) & age >= 25
	  
/* Generate some disparity interactions */
  gen male_black = male*black
gen male_hispan = male*hispan
gen male_hsless = male*hsless

foreach v of varlist `agevars' {
  gen died_`v' = died * `v'
}

	*** If in nursing home, no ADL limitation variables
 	foreach v in iadl1 iadl2p adl1 adl2 adl3p {
 		replace `v' = 0 if nhmliv == 1 
 	}
 	
 	
	* Hotdeck missing values 	
	gen anymiss = 0
	foreach x in $depvars {
		dis "`x'"
		count if missing(`x')
		replace anymiss = 1 if missing(`x')
		* drop if missing(`x') 
	}
	
	hotdeck $depvars using mcbs`bsamp'_, by(male) keep(year baseid) store seed(`seed')
	drop $depvars
	merge year baseid using mcbs`bsamp'_1, sort
	tab _merge
	
	* Check missing values again
	
	gen anymiss2 = 0
	foreach x in $depvars {
		dis "`x'"
		count if missing(`x')
		replace anymiss2 = 1 if missing(`x')
		* drop if missing(`x') 
	}
	qui sum if anymiss2 == 1
	if r(N) > 0 {
		dis "Wrong, still missing values"
		exit(333)
	}
	
	

	* Define possible interactions
foreach v of varlist cancre diabe hearte hibpe lunge stroke {
  gen `v'_l`v' = `v' * l`v' * !died
  local lv : var label `v'
  label var `v'_l`v' "Maintenance stage for `lv'"
  gen `v'_nl`v' = `v' * !l`v' * !died
  label var `v'_nl`v' "Diagnosis stage for `lv'"
  gen died_`v' = died * `v'
  label var died_`v' "Terminal stage for `lv'"
}

	gen diabe_hearte = diabe*hearte
	gen diabe_hibpe = diabe*hibpe
	gen hibpe_hearte = hibpe*hearte
	gen hibpe_stroke = hibpe*stroke
	gen diclaim_died = diclaim*died
	gen diclaim_nhmliv = diclaim*nhmliv
	gen died_nhmliv = died*nhmliv



	
	erase mcbs`bsamp'_1.dta
	drop anymiss*
	save `mcbs_imp`bsamp'', replace	

	/*****************************************************************/
	/* ESTIMATION	 		*/
	/*****************************************************************/

	drop _all
	use `mcbs_imp`bsamp''
	
	if !missing("`bsamp'") {
		ren weight weight_old
		gen weight = weight_old * bsample`bsamp'
	}

	/* **** No one uses these models ****
	foreach v in doctim hsptim hspnit {
		poisson `v' $cov_mcbs $cov_interactions [pw = weight]
 		if missing("`bsamp'") {
    	mfx2, nose stub(`v')
    }
		est save "$ster/`v'_mcbs.ster", replace
		matrix m`v'_mcbs = e(b)
	}
	*/

	foreach v in totmd_mcbs mcare oopmd_mcbs {
		local x = "cov_`v'"
		reg `v' $`x' $cov_interactions [pw = weight]
 		if missing("`bsamp'") {
    	mfx2, nose stub(`v')
    }
		est save "$ster/`v'.ster", replace
		matrix m`v' = e(b)
	}	

/* Medicaid is now treated as a two-step regression: eligibility then expenses */
probit medicaid_elig $cov_medicaid_elig [pw=weight]
if missing("`bsamp'") {
	mfx2, nose stub(medicaid_elig)
}
est save "$ster/medicaid_elig_mcbs.ster", replace
matrix mmedicaid_elig_mcbs = e(b)

reg caidmd_mcbs $cov_caidmd_mcbs $cov_interactions if medicaid_elig [pw=weight]
if missing("`bsamp'") {
	mfx2, nose stub(caidmd_mcbs)
}
est save "$ster/caidmd_mcbs.ster", replace
matrix mcaidmd_mcbs = e(b)

	/* Only estimate part a (b) costs for those actually enrolled in that program */

gen pta = inlist(d_care, 1,3)
gen ptb = inlist(d_care, 2,3)

foreach m in a b {
		local x = "cov_mcare_pt`m'"
		reg mcare_pt`m' $`x' $cov_interactions [pw = weight] if pt`m' == 1
 		if missing("`bsamp'") {
	    mfx2, nose stub(mcare_pt`m')
	  }
		est save "$ster/mcare_pt`m'.ster", replace
		matrix mmcare_pt`m' = e(b)
}

/*
*** for backwards compatibility
*** put estimates into matrices by MATA subroutine
*** In current version we don't want to include obesity and smoking variables as covarites

global outdata "$local_path/Input_yh"
do "$codedir/put_est.mata"


#d;
foreach var in totmd_mcbs mcare mcare_pta mcare_ptb caidmd_mcbs oopmd_mcbs {;
 		capture erase "$outdata/all/m`var'";
 		capture erase "$outdata/all/s`var'";
		mata: _putestimates("$outdata/all/m`var'","$outdata/all/s`var'" ,"m`var'");
};
foreach var in doctim hsptim hspnit  {;
 		capture erase "$outdata/all/m`var'_mcbs";
 		capture erase "$outdata/all/s`var'_mcbs";
		mata: _putestimates("$outdata/all/m`var'_mcbs","$outdata/all/s`var'_mcbs" ,"m`var'_mcbs");
};
#d cr

#d;
foreach var in totmd_mcbs mcare mcare_pta mcare_ptb caidmd_mcbs oopmd_mcbs {;
 		capture erase "$outdata/partial/m`var'";
 		capture erase "$outdata/partial/s`var'";
		mata: _putestimates("$outdata/partial/m`var'","$outdata/partial/s`var'" ,"m`var'");
};
foreach var in doctim hsptim hspnit  {;
 		capture erase "$outdata/partial/m`var'_mcbs";
 		capture erase "$outdata/partial/s`var'_mcbs";
		mata: _putestimates("$outdata/partial/m`var'_mcbs","$outdata/partial/s`var'_mcbs" ,"m`var'_mcbs");
};
#d cr
*/
***
if missing("`bsamp'") {
	xml_tab medicaid_elig_*, save($ster/cost_est_mcbs.xml) sheet(medicaid_elig) replace pvalue stats(N r2_a)
	xml_tab totmd_mcbs_* caidmd_mcbs_* oopmd_mcbs_* mcare_pt*, save($ster/cost_est_mcbs.xml) sheet(costs) append pvalue stats(N r2_a)


	* No one uses these
	* xml_tab doctim_* hsptim_* hspnit_*, save($ster/cost_est_mcbs.xml) sheet(utilization) append pvalue stats(N r2_a)	
}

shell touch $ster/psid_cost_est_mcbs.txt
