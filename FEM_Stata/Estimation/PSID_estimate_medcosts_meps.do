
/** \file
Estimate costs models using MEPS for people not eligable for medicare (25-65)

\todo split totmd in to male and female parts

\todo compare totmd to totmd without ESRD patients

\todo Explore the following:
	- health insurance in models
	- age-gender interactions
	- under-45/over-45 interactions with health conditions
	- interact sex with cancer?  heart disease?
	- Recent children
	- ADL/IADL (see Yuhui's EQ5D harmonization for how she handled ADL/IADL differences between surveys)
	- Understand relationship between earnings and expenditures - possibly allow for bend points or curvature
	- Age in Medicaid eligibility model
	- Kinds (any or number) in Medicaid eligibility model
	- Are assets available in MEPS?

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
	log using "./PSID_estimate_medcosts_meps`defmod'.log", replace
	if !missing("`defmod'"){
		global ster "$local_path/Estimates/PSID/`defmod'"
	}
	else {
		global ster "$local_path/Estimates/PSID"
	}
}
else {
	log using "./bootstrap_logs/PSID_estimate_medcosts_meps_bootstrap`bsamp'_`defmod'.log", replace
	if !missing("`defmod'"){
		global ster "$local_path/Estimates/PSID/`defmod'/models_rep`bsamp'"
	}
	else {
		global ster "$local_path/Estimates/PSID/models_rep`bsamp'"
	}
}

local seed  5654;

*** get the covariate definitions for defmod
include psid_meps_covariate_defs`defmod'.do	


	/*****************************************************************/
	/* IMPUTATION */
	/*****************************************************************/
	
	tempfile meps_imp`bsamp'
	
	use "$outdata/meps_drugs.dta"

	* Merge on the full cost file for all the covariates we need
	merge 1:1 dupersid yr using "$outdata/MEPS_cost_est.dta"
	tab _merge
	
	* Sample selection
	count
	keep if inrange(age,25,69) & inrange(yr, 2007,2010)
	count
	keep if _merge == 3
	count
	drop _merge
	
	* Any RX expenditures
	gen anyrx_meps = (rxexp > 0) if !missing(rxexp) 
	tab anyrx_meps

	rename rxtot rxtot_meps
	rename rxexp rxexp_meps
	
	
/* Generate some disparity interactions */
 gen male_black = male*black
gen male_hispan = male*hispan
gen male_hsless = male*hsless

/* interactions b/w k6 & other outcomes */
foreach var in cancre diabe hibpe hearte lunge stroke male black hisp hsless college widowed single {
	gen k6`var' = k6severe*`var'
}
label var k6cancre "K6 Cancer Ever"
label var k6diabe "K6 Diabetes Ever"
label var k6hibpe "K6 High Blood Pressure Ever"
label var k6hearte "K6 Heart Problems Ever"
label var k6lunge "K6 Emph. Ever"
label var k6stroke "K6 Stroke Ever"
label var k6male "K6 male"
label var k6black "K6 black"
label var k6hisp "K6 Hispanic"
label var k6hsless "K6 HS Less"
label var k6college "K6 College"
label var k6widowed "K6 Widowed"
label var k6single "K6 Single"

forvalues x = 1/8 {
	gen hicat`x' = (hlthinscat == `x')
}

	
*	foreach item in exp slf mcr mcd prv va ofd wcp opr opu osr{
*		cap drop meps`item'
*		gen meps`item' = tot`item'
*		label var meps`item' "tot`item' in 2004 dollars"
*		 forvalues frsyr = 2002/2004 {
*			replace meps`item' = meps`item' * medcpi[rownumb(medcpi,"2004"), 1]/( medcpi[rownumb(medcpi,"`frsyr'"),1]) if yr == `frsyr'
*		 }
*	}
	
	gen caidmd_meps = mepsmcd
	gen totmd_meps  = mepsexp
	gen oopmd_meps  = mepsslf
	
	gen totmd_any = (totmd_meps > 0) & !missing(totmd_meps)
	gen age45p = (age >= 45) & !missing(age)

	foreach var in cancre diabe hibpe hearte lunge stroke {
		gen age45p_`var' = age45p * `var'
	}


	* Some summary tables
	tab age totmd_any, row
	
if missing("`bsamp'") {
	preserve
	collapse (mean) totmd_meps [pw = perwt], by(age male)
	graph twoway scatter totmd_meps age if male == 1
	graph save totmd_age_male.gph, replace
	
	graph twoway scatter totmd_meps age if male == 0
	graph save totmd_age_female.gph, replace
	restore
}
	
	* Hotdeck missing values 	
	gen anymiss = 0
	foreach x in $cov_meps $cov_meps_more {
		dis "`x'"
		count if missing(`x')
		replace anymiss = 1 if missing(`x')
		* drop if missing(`x') 
	}
	
	hotdeck $cov_meps $cov_meps_more using meps`bsamp'_, by(male) keep(yr dupersid) store seed(5654)
	drop $cov_meps $cov_meps_more
	merge yr dupersid using meps`bsamp'_1, sort
	tab _merge
	
	* Check missing values again
	
	gen anymiss2 = 0
	foreach x in $cov_meps $cov_meps_more {
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
	erase meps`bsamp'_1.dta
	drop anymiss*
	save `meps_imp`bsamp'', replace
	
		/*****************************************************************/
	/* ESTIMATION	 		*/
	/*****************************************************************/
  drop _all
	use `meps_imp`bsamp''			

	if !missing("`bsamp'") {
		ren perwt perwt_old
		gen perwt = perwt_old * bsample`bsamp'
	}

#d ;
	global util_names
	"Num doctor visits MEPS"
	"Num inpatient visits MEPS"
	"Num nights at hospital MEPS"
	;
#d cr
	local i = 1
	foreach v in doctim hsptim hspnit {
   	local modname: word `i' of "$util_names"
  	local coef_name = "`modname'" + " (`v') coefficients"
  	di "`v' - `coef_name'"
  	local mfx_name = "`modname'" + " (`v') marginal effects"
  	di "`v' - `mfx_name'"
		poisson `v' $cov_meps [pw = perwt]
		ch_est_title "`coef_name'"
		if missing("`bsamp'") {
	    mfx2, nose stub(`v')
	  }
		est save "$ster/`v'_meps.ster", replace
		matrix m`v'_meps = e(b)
		if missing("`bsamp'") {
			est restore `v'_mfx
			ch_est_title "`mfx_name'"
			est store `v'_mfx
		}

    local i = `i'+1
	}	
	
	
#d ;
  global cost_names1
	"Total med costs MEPS"
	"OOP med costs MEPS"
	;
#d cr	
	local i = 1	
	foreach v in totmd_meps oopmd_meps {
   	local modname: word `i' of "$cost_names1"
  	local coef_name = "`modname'" + " (`v') coefficients"
  	di "`v' - `coef_name'"
  	local mfx_name = "`modname'" + " (`v') marginal effects"
  	di "`v' - `mfx_name'"
 		reg `v' $cov_meps [pw = perwt]
    ch_est_title "`coef_name'"
		if missing("`bsamp'") {    
			mfx2, nose stub(`v')
		}
		est save "$ster/`v'.ster", replace
		matrix m`v' = e(b)
		if missing("`bsamp'") {
			est restore `v'_mfx
			ch_est_title "`mfx_name'"
			est store `v'_mfx
		}
    local i = `i'+1
	}

/* Medicaid is now treated as a two-step regression: eligibility then expenses */
probit medicaid_elig $cov_medicaid_elig if age < 65 [pw=perwt]
ch_est_title "Medicaid eligibility MEPS coefficients"
if missing("`bsamp'") {
	mfx2, nose stub(medicaid_elig)
}
est save "$ster/medicaid_elig_meps.ster", replace
matrix mmedicaid_elig_meps = e(b)
if missing("`bsamp'") {
	est restore medicaid_elig_mfx
	ch_est_title "Medicaid eligibility MEPS marginal effects"
	est store medicaid_elig_mfx
}

reg caidmd_meps $cov_meps if medicaid_elig & age < 65 [pw=perwt]
ch_est_title "Medicaid cost MEPS coefficients"
if missing("`bsamp'") {
	mfx2, nose stub(caidmd_meps)
}
est save "$ster/caidmd_meps.ster", replace
matrix mcaidmd_meps = e(b)
if missing("`bsamp'") {
	est restore caidmd_meps_mfx
	ch_est_title "Medicaid cost MEPS marginal effects"
	est store caidmd_meps_mfx
}	



* Esimate any Rx expenditures and then the amount
probit anyrx_meps $cov_rx [pw=perwt]
ch_est_title "Any Rx Expenditures MEPS coefficients"
if missing("`bsamp'") {
	mfx2, nose stub(anyrx_meps)
}
est save "$ster/anyrx_meps.ster", replace
matrix manyrx_meps = e(b)
if missing("`bsamp'") {
	est restore anyrx_meps_mfx
	ch_est_title "Any Rx Expenditures MEPS marginal effects"
	est store anyrx_meps_mfx
}

* Amount, if any
reg rxexp_meps $cov_rx if anyrx_meps [pw=perwt]
ch_est_title "Rx cost MEPS coefficients"
if missing("`bsamp'") {
	mfx2, nose stub(rxexp_meps)
}
est save "$ster/rxexp_meps.ster", replace
matrix mrxexp_meps = e(b)
if missing("`bsamp'") {
	est restore rxexp_meps_mfx
	ch_est_title "Rx cost MEPS marginal effects"
	est store rxexp_meps_mfx
}

/*
*** for backwards compatibility
*** put estimates into matrices by MATA subroutine
*** In current version we don't want to include obesity and smoking variables as covarites
global outdata "$local_path/Input_yh"
do "$codedir/put_est.mata"

#d;
foreach var in totmd_meps caremd_meps caidmd_meps oopmd_meps {;
 		capture erase "$outdata/all/m`var'";
 		capture erase "$outdata/all/s`var'";
		mata: _putestimates("$outdata/all/m`var'","$outdata/all/s`var'" ,"m`var'");
};

foreach var in doctim hsptim hspnit {;
 		capture erase "$outdata/all/m`var'_meps";
 		capture erase "$outdata/all/s`var'_meps";
		mata: _putestimates("$outdata/all/m`var'_meps","$outdata/all/s`var'_meps" ,"m`var'_meps");
};

#d cr



#d;
foreach var in totmd_meps caremd_meps caidmd_meps oopmd_meps {;
 		capture erase "$outdata/all/m`var'";
 		capture erase "$outdata/all/s`var'";
		mata: _putestimates("$outdata/all/m`var'","$outdata/all/s`var'" ,"m`var'");
};

foreach var in doctim hsptim hspnit {;
 		capture erase "$outdata/partial/m`var'_meps";
 		capture erase "$outdata/partial/s`var'_meps";
		mata: _putestimates("$outdata/partial/m`var'_meps","$outdata/partial/s`var'_meps" ,"m`var'_meps");
};

#d cr
*/
***

if missing("`bsamp'") {
	*** put estimates into regression tables
	xml_tab medicaid_elig_*, save($ster/cost_est_meps.xls) sheet(medicaid_elig) replace pvalue stats(N r2_a)
	xml_tab totmd_meps_* caidmd_meps_* oopmd_meps_*, save($ster/cost_est_meps.xls) sheet(costs) append pvalue stats(N r2_a)
	xml_tab doctim_* hsptim_* hspnit_*, save($ster/cost_est_meps.xls) sheet(utilization) append pvalue stats(N r2_a)

	* also write estimates as a sheet in the file to be distributed with tech appendix
	xml_tab medicaid_elig_*, save("$ster/FEM_estimates_table.xml") sheet(medicaid_elig_meps) replace pvalue stats(N r2_a)
	xml_tab totmd_meps_* caidmd_meps_* oopmd_meps_*, save("$ster/FEM_estimates_table.xml") sheet(costs_meps) append pvalue stats(N r2_a)
	xml_tab doctim_* hsptim_* hspnit_*, save("$ster/FEM_estimates_table.xml") sheet(utilization_meps) append pvalue stats(N r2_a)
}
shell touch $ster/psid_cost_est_meps.txt

capture log close
