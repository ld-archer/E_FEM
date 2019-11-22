
/** \file
Estimate costs models using MEPS for people not eligable for medicare (<65)

\todo split totmd in to male and female parts

\todo compare totmd to totmd without ESRD patients

*/
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

* Define Aux Directories
if !missing("`bsamp'") {
	global ster "$local_path/Estimates/HRS/models_rep`bsamp'"
}
else {
	global ster "$local_path/Estimates/HRS"
}


local seed  5654;

**** Store the medical cpi into a matrix cross walk
*use "$indata/medcpi_cxw.dta"
*insheet using /nfs/sch-data-library/public-data/CPI/CPIMEDSL.csv, clear
*gen year = substr(date,5,4)
*destring year, replace
*ren value medcpi
*keep year medcpi
*mkmat medcpi, matrix(medcpi) rownames(year)

*** Define all covariates used in cost models
global cov_medicaid_elig = "male male_black male_hispan male_hsless black hispan hsless college widowed single cancre logiearnx adl1p"
global cov_meps = "age5559 age6064 age6569 male male_black male_hispan male_hsless black hispan hsless college widowed single cancre diabe hibpe hearte lunge stroke hearta logiearnx"

* For Rx models
global cov_rx = "age5559 age6064 age6569 male black hispan hsless college male_black male_hispan male_hsless widowed single cancre diabe hibpe hearte lunge stroke hearta overwt obese"


	/*****************************************************************/
	/* IMPUTATION */
	/*****************************************************************/
	
	tempfile meps_imp
	
	use "$outdata/meps_drugs.dta"

	* Merge on the full cost file for all the covariates we need
	merge 1:1 dupersid yr using "$outdata/MEPS_cost_est.dta"
	tab _merge
	
	* Sample selection
	count
	keep if inrange(age,51,69) & inrange(yr, 2007,2010)
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
	  	
		
*	keep if inrange(age,51,64) 
	* Hotdeck missing values 	
	gen anymiss = 0
	foreach x in $cov_meps {
		dis "`x'"
		count if missing(`x')
		replace anymiss = 1 if missing(`x')
		* drop if missing(`x') 
	}
	
	hotdeck $cov_meps using meps, by(male) keep(yr dupersid) store seed(5654)
	drop $cov_meps
	merge yr dupersid using meps1, sort
	tab _merge
	
	* Check missing values again
	
	gen anymiss2 = 0
	foreach x in $cov_meps {
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
	erase meps1.dta
	drop anymiss*
	save `meps_imp', replace
	
	/*****************************************************************/
	/* ESTIMATION	 		*/
	/*****************************************************************/
  drop _all
	use `meps_imp'			

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
    mfx2, nose stub(`v')
		est save "$ster/`v'_meps.ster", replace
		matrix m`v'_meps = e(b)
		est restore `v'_mfx
		ch_est_title "`mfx_name'"
		est store `v'_mfx

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
    mfx2, nose stub(`v')
		est save "$ster/`v'.ster", replace
		matrix m`v' = e(b)
		est restore `v'_mfx
		ch_est_title "`mfx_name'"
		est store `v'_mfx

    local i = `i'+1
	}

/* Medicaid is now treated as a two-step regression: eligibility then expenses */
probit medicaid_elig $cov_medicaid_elig if age < 65 [pw=perwt]
ch_est_title "Medicaid eligibility MEPS coefficients"
mfx2, nose stub(medicaid_elig)
est save "$ster/medicaid_elig_meps.ster", replace
matrix mmedicaid_elig_meps = e(b)
est restore medicaid_elig_mfx
ch_est_title "Medicaid eligibility MEPS marginal effects"
est store medicaid_elig_mfx

reg caidmd_meps $cov_meps if medicaid_elig & age < 65 [pw=perwt]
ch_est_title "Medicaid cost MEPS coefficients"
mfx2, nose stub(caidmd_meps)
est save "$ster/caidmd_meps.ster", replace
matrix mcaidmd_meps = e(b)
est restore caidmd_meps_mfx
ch_est_title "Medicaid cost MEPS marginal effects"
est store caidmd_meps_mfx



* Esimate any Rx expenditures and then the amount
probit anyrx_meps $cov_rx [pw=perwt]
ch_est_title "Any Rx Expenditures MEPS coefficients"
mfx2, nose stub(anyrx_meps)
est save "$ster/anyrx_meps.ster", replace
matrix manyrx_meps = e(b)
est restore anyrx_meps_mfx
ch_est_title "Any Rx Expenditures MEPS marginal effects"
est store anyrx_meps_mfx

* Amount, if any
reg rxexp_meps $cov_rx if anyrx_meps [pw=perwt]
ch_est_title "Rx cost MEPS coefficients"
mfx2, nose stub(rxexp_meps)
est save "$ster/rxexp_meps.ster", replace
matrix mrxexp_meps = e(b)
est restore rxexp_meps_mfx
ch_est_title "Rx cost MEPS marginal effects"
est store rxexp_meps_mfx



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

*** put estimates into regression tables
xml_tab medicaid_elig_*, save($ster/cost_est_meps.xls) sheet(medicaid_elig) replace pvalue stats(N r2_a)
xml_tab totmd_meps_* caidmd_meps_* oopmd_meps_*, save($ster/cost_est_meps.xls) sheet(costs) append pvalue stats(N r2_a)
xml_tab doctim_* hsptim_* hspnit_*, save($ster/cost_est_meps.xls) sheet(utilization) append pvalue stats(N r2_a)

* also write estimates as a sheet in the file to be distributed with tech appendix
if(missing("`bsamp'")) {
  xml_tab medicaid_elig_*, save("$ster/FEM_estimates_table.xml") sheet(medicaid_elig_meps) append pvalue stats(N r2_a)
  xml_tab totmd_meps_* caidmd_meps_* oopmd_meps_*, save("$ster/FEM_estimates_table.xml") sheet(costs_meps) append pvalue stats(N r2_a)
  xml_tab doctim_* hsptim_* hspnit_*, save("$ster/FEM_estimates_table.xml") sheet(utilization_meps) append pvalue stats(N r2_a)
}

shell touch $ster/cost_est_meps.txt

capture log close

