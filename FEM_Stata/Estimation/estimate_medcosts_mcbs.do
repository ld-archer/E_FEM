/** \file
* Estimate costs models using MCBS for persons eligable for Medicare
* 10/10/2009 - Only estimate Pt A (B) costs for those enrolled in Pt A (B)

\todo add more age splines to medical expenditures

\todo stratify totmd into male and female

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

local seed  5654

**** Store the medical cpi into a matrix cross walk
*use "$indata/medcpi_cxw.dta"
*insheet using /nfs/sch-data-library/public-data/CPI/CPIMEDSL.csv, clear
*gen year = substr(date,5,4)
*destring year, replace
*ren value medcpi
*keep year medcpi
*mkmat medcpi, matrix(medcpi) rownames(year)


*** Define dependent variables used in the cost model 
global depvars age male black hispan hsless college widowed single cancre diabe hibpe hearte lunge stroke nhmliv adl3p diclaim died logiearnx
local agevars = "age6569 age7074 age7579 age8084 age85"
local agevars_di age5559 age6064
local agevars_aged age7074 age7579 age8084 age85

// Define the covariates used in the cost models, which are the dependent variables and interaction terms
global cov_mcbs `agevars' male male_black male_hispan male_hsless black hispan hsless college widowed single cancre_nlcancre diabe_nldiabe hibpe_nlhibpe hearte_nlhearte lunge_nllunge stroke_nlstroke heartae_nlheartae alzhe_nlalzhe cancre_lcancre diabe_ldiabe hearte_lhearte hibpe_lhibpe lunge_llunge stroke_lstroke heartae_lheartae alzhe_lalzhe nhmliv adl3p diclaim died 
global cov_interactions diabe_hearte diabe_hibpe hibpe_hearte hibpe_stroke diclaim_died diclaim_nhmliv died_nhmliv died_cancre died_diabe died_hibpe died_hearte died_lunge died_stroke died_heartae died_age6569 died_age7074 died_age7579 died_age8084 died_age85 nhmliv_alzhe died_alzhe nhmliv_heartae died_heartae

* For Rx models of the age-entitled
global cov_mcbs_rx `agevars_aged' male male_black male_hispan male_hsless black hispan hsless college widowed single cancre_nlcancre diabe_nldiabe hibpe_nlhibpe hearte_nlhearte lunge_nllunge stroke_nlstroke alzhe_nlalzhe cancre_lcancre diabe_ldiabe hearte_lhearte hibpe_lhibpe lunge_llunge stroke_lstroke alzhe_lalzhe heartae_lheartae nhmliv adl3p died
* For Rx modles of the DI-entitled (under age 65)
global cov_mcbs_rx_di `agevars_di' male male_black male_hispan male_hsless black hispan hsless college widowed single cancre diabe hibpe hearte lunge stroke nhmliv adl3p died


// By default, the list of covariates for each cost measure is the same as the default
foreach v in totmd_mcbs mcare mcare_pta mcare_ptb caidmd_mcbs oopmd_mcbs {
	global cov_`v' $cov_mcbs
}

* replacing gross with logiearnx 
* Nope - removing logiearnx - the measure is too different from MCBS to HRS.  We need to either develop the Medicaid eligibility model in the HRS or develop hitot in the HRS, which is closer to gross.
global cov_medicaid_elig = "male black hispan hsless male_black male_hispan male_hsless college widowed single cancre nhmliv adl3p"
	/*****************************************************************/
	/* IMPUTATION */
	/*****************************************************************/
	
	tempfile mcbs_imp`bsamp'
	
	drop _all
	use "$dua_mcbs_dir/mcbs_drugs.dta"
	
	*** Merge on the drug utilization/expenditure
	merge 1:1 baseid year using $dua_mcbs_dir/mcbs_cost_est.dta
	tab _merge
	
	* Drop cases on drug file, but not on cost file
	drop if _merge == 1

	* Sample selection
	keep if inrange(year,2007,2012) & age >= 51
	
	* Only non-ghosts were merged on
	replace ghost = 0 if _merge == 2
	
	* Fill in the zeroes for utilization - these are non-ghosts that were on the cost file
	foreach var of varlist fills amttot {
		replace `var' = 0 if missing(`var') & !ghost 
	}
	
	* Make sure ghosts are still missing ... we will impute
	tab fills if ghost, m
	tab amttot if ghost, m
	
	drop _merge

	* Any RX expenditures
	gen anyrx_mcbs = (fills > 0) if !missing(fills)
	tab anyrx_mcbs

	rename fills rxtot_mcbs
	rename amttot rxexp_mcbs
	
	
	label var anyrx_mcbs "Any Rx in previous year"
	label var rxtot_mcbs "Count of Rx in previous year"
	label var rxexp_mcbs "Rx Expenditures in previous year"
	
	gen anyrx_mcbs_di = anyrx_mcbs if diclaim
	gen rxexp_mcbs_di = rxexp_mcbs if diclaim
	label var anyrx_mcbs_di "Any Rx in previous year - DI population"
	label var rxexp_mcbs_di "Rx Expenditures in previous year - DI population"
	
	*** Impute the outcome measures for the ghosts, by DI status ***
	egen agecat = cut(age), at(50, 55, 60, 64, 67, 70, 75, 80, 85, 200)
	hotdeck anyrx_mcbs rxexp_mcbs if diclaim == 0, by(agecat male diclaim) keep(baseid year) store seed(`seed')
	drop anyrx_mcbs rxexp_mcbs
	merge 1:1 baseid year using imp1.dta
	drop _merge
	rm imp1.dta
	
	bys agecat: sum anyrx_mcbs if diclaim == 0 & !ghost
	bys agecat: sum anyrx_mcbs if diclaim == 0 & ghost
	
	bys agecat: sum rxexp_mcbs if diclaim == 0 & !ghost
	bys agecat: sum rxexp_mcbs if diclaim == 0 & ghost
	
	*** Impute the outcome measures for the ghosts, by DI status ***
	hotdeck anyrx_mcbs_di rxexp_mcbs_di if diclaim == 1, by(agecat male diclaim) keep(baseid year) store seed(`seed')
	drop anyrx_mcbs_di rxexp_mcbs_di
	merge 1:1 baseid year using imp1.dta
	drop _merge
	rm imp1.dta
	
	bys agecat: sum anyrx_mcbs_di if diclaim == 1 & !ghost
	bys agecat: sum anyrx_mcbs_di if diclaim == 1 & ghost
	
	bys agecat: sum rxexp_mcbs_di if diclaim == 1 & !ghost
	bys agecat: sum rxexp_mcbs_di if diclaim == 1 & ghost
	
	
* Define logiearnx
replace gross = gross/1000
egen logiearnx = h(gross)
replace logiearnx = logiearnx/100

	ren nrshom nhmliv
	
	  
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
	
	hotdeck $depvars using mcbs`bsamp', by(male) keep(year baseid) store seed(`seed')
	drop $depvars
	merge year baseid using mcbs`bsamp'1, sort
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
foreach v of varlist cancre diabe hearte hibpe lunge stroke alzhe heartae {
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
	
	* new interaction term for Alzhe
gen nhmliv_alzhe = nhmliv*alzhe

gen nhmliv_heartae = nhmliv*heartae

* Clean-up any inconsistencies in the age categories post-imputation
	drop age5054 age5559 age6064 age6569 age7074 age7579 age8084 age85
	gen age5054 = inrange(floor(age), 50, 54)
	gen age5559 = inrange(floor(age), 55, 59)
	gen age6064 = inrange(floor(age), 60, 64)
	gen age6569 = inrange(floor(age), 65, 69)
	gen age7074 = inrange(floor(age), 70, 74)
	gen age7579 = inrange(floor(age), 75, 79)
	gen age8084 = inrange(floor(age), 80, 84)
	gen age85 = floor(age) > 84

	
	erase mcbs`bsamp'1.dta
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

#d ;
	global util_names
	"Num doctor visits MCBS"
	"Num inpatient visits MCBS"
	"Num nights at hospital MCBS"
	;
#d cr
	local i = 1
	foreach v in doctim hsptim hspnit {
   	local modname: word `i' of "$util_names"
  	local coef_name = "`modname'" + " (`v') coefficients"
  	di "`v' - `coef_name'"
  	local mfx_name = "`modname'" + " (`v') marginal effects"
  	di "`v' - `mfx_name'"
		poisson `v' $cov_mcbs $cov_interactions [pw = weight]
    ch_est_title "`coef_name'"
    mfx2, nose stub(`v')
		est save "$ster/`v'_mcbs.ster", replace
		matrix m`v'_mcbs = e(b)
		est restore `v'_mfx
		ch_est_title "`mfx_name'"
		est store `v'_mfx
		 
    local i = `i'+1
	}
	
#d ;
  global cost_names1
	"Total med costs MCBS"
	"Medicare costs"
	"OOP med costs MCBS"
	;
#d cr	
	local i = 1
	foreach v in totmd_mcbs mcare oopmd_mcbs {
   	local modname: word `i' of "$cost_names1"
  	local coef_name = "`modname'" + " (`v') coefficients"
  	di "`v' - `coef_name'"
  	local mfx_name = "`modname'" + " (`v') marginal effects"
  	di "`v' - `mfx_name'"
		local x = "cov_`v'"
		reg `v' $`x' $cov_interactions [pw = weight]
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
probit medicaid_elig $cov_medicaid_elig [pw=weight]
ch_est_title "Medicaid eligibility MCBS coefficients"
mfx2, nose stub(medicaid_elig)
est save "$ster/medicaid_elig_mcbs.ster", replace
matrix mmedicaid_elig_mcbs = e(b)
est restore medicaid_elig_mfx
ch_est_title "Medicaid eligibility MCBS marginal effects"
est store medicaid_elig_mfx


reg caidmd_mcbs $cov_caidmd_mcbs $cov_interactions if medicaid_elig [pw=weight]
ch_est_title "Medicaid cost MCBS coefficients"
mfx2, nose stub(caidmd_mcbs)
est save "$ster/caidmd_mcbs.ster", replace
matrix mcaidmd_mcbs = e(b)
est restore caidmd_mcbs_mfx
ch_est_title "Medicaid cost MCBS marginal effects"
est store caidmd_mcbs_mfx

	/* Only estimate part a (b) costs for those actually enrolled in that program */

gen pta = inlist(d_care, 1,3)
gen ptb = inlist(d_care, 2,3)

#d ;
  global cost_names2
	"Medicare Pt A MCBS"
	"Medicare Pt B MCBS"
	;
#d cr	
local i = 1
foreach m in a b {
		local v "mcare_pt`m'"
		local modname: word `i' of "$cost_names2"
  	local coef_name = "`modname'" + " (`v') coefficients"
  	di "`v' - `coef_name'"
  	local mfx_name = "`modname'" + " (`v') marginal effects"
  	di "`v' - `mfx_name'"

		local x = "cov_`v'"
		reg `v' $`x' $cov_interactions [pw = weight] if pt`m' == 1
		ch_est_title "`coef_name'"
		mfx2, nose stub(`v')
		est save "$ster/`v'.ster", replace
		matrix m`v' = e(b)
		est restore `v'_mfx
		ch_est_title "`mfx_name'"
		est store `v'_mfx

    local i = `i'+1
}



*** Estimate any Rx expenditures and then the amount, separately for DI and non-DI ***

*** For DI population under 65
probit anyrx_mcbs_di $cov_mcbs_rx_di if diclaim & age < 65 [pw=weight]
ch_est_title "Any Rx Expenditures DI MCBS coefficients"
mfx2, nose stub(anyrx_mcbs_di)
est save "$ster/anyrx_mcbs_di.ster", replace
matrix manyrx_mcbs_di = e(b)
est restore anyrx_mcbs_di_mfx
ch_est_title "Any Rx Expenditures DI MCBS marginal effects"
est store anyrx_mcbs_di_mfx

* Amount, if any
reg rxexp_mcbs_di $cov_mcbs_rx_di if anyrx_mcbs & diclaim & age < 65 [pw=weight]
ch_est_title "Rx cost DI MCBS coefficients"
mfx2, nose stub(rxexp_mcbs_di)
est save "$ster/rxexp_mcbs_di.ster", replace
matrix mrxexp_mcbs_di = e(b)
est restore rxexp_mcbs_di_mfx
ch_est_title "Rx cost DI MCBS marginal effects"
est store rxexp_mcbs_di_mfx

*** For aged population over 67 (ages 65 and 66 are really weird due to ghosts & selection bias)
probit anyrx_mcbs $cov_mcbs_rx if age >= 67 [pw=weight]
ch_est_title "Any Rx Expenditures MCBS coefficients"
mfx2, nose stub(anyrx_mcbs)
est save "$ster/anyrx_mcbs.ster", replace
matrix manyrx_mcbs = e(b)
est restore anyrx_mcbs_mfx
ch_est_title "Any Rx Expenditures MCBS marginal effects"
est store anyrx_mcbs_mfx

* Amount, if any
reg rxexp_mcbs $cov_mcbs_rx if anyrx_mcbs & age >= 67 [pw=weight]
ch_est_title "Rx cost MCBS coefficients"
mfx2, nose stub(rxexp_mcbs)
est save "$ster/rxexp_mcbs.ster", replace
matrix mrxexp_mcbs = e(b)
est restore rxexp_mcbs_mfx
ch_est_title "Rx cost MCBS marginal effects"
est store rxexp_mcbs_mfx

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
xml_tab medicaid_elig_*, save($ster/cost_est_mcbs.xls) sheet(medicaid_elig) replace pvalue stats(N r2_a)
xml_tab totmd_mcbs_* caidmd_mcbs_* oopmd_mcbs_* mcare_pt*, save($ster/cost_est_mcbs.xls) sheet(costs) append pvalue stats(N r2_a)
xml_tab doctim_* hsptim_* hspnit_*, save($ster/cost_est_mcbs.xls) sheet(utilization) append pvalue stats(N r2_a)
xml_tab anyrx_mcbs_*, save($ster/cost_est_mcbs.xls) sheet(rx_utilization) append pvalue stats(N r2_a)
xml_tab rxexp_mcbs_*, save($ster/cost_est_mcbs.xls) sheet(rx_costs) append pvalue stats(N r2_a)


* also write estimates as a sheet in the file to be distributed with tech appendix
xml_tab medicaid_elig_*, save("$ster/FEM_estimates_table.xml") sheet(medicaid_elig_mcbs) append pvalue stats(N r2_a)
xml_tab totmd_mcbs_* caidmd_mcbs_* oopmd_mcbs_* mcare_pt*, save("$ster/FEM_estimates_table.xml") sheet(costs_mcbs) append pvalue stats(N r2_a)
xml_tab doctim_* hsptim_* hspnit_*, save("$ster/FEM_estimates_table.xml") sheet(utilization_mcbs) append pvalue stats(N r2_a)

shell touch $ster/cost_est_mcbs.txt

save  "$dua_mcbs_dir/mcbs_temp.dta", replace


capture log close

