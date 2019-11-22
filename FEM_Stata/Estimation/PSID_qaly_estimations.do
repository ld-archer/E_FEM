/** Estimate a qaly model for use in FAM 
NOTE (1/30/2017): The MEPS bootstrap has not been implemented for MEPS waves before 2007. 
For this reason, the MEPS part of the QALY estimation cannot be bootstrapped.  The PSID
part of the estimation *is* bootstrapable.
*/

clear
cap clear mata
set more off
set seed 52432
set maxvar 10000
est drop _all

local defmod : env suffix

local psid_bsamp : env PSID_BREP

local chk_bs : env CHK_BS

if missing("`chk_bs'") {
	local chk_bs = 0
}

quietly include "../../fem_env.do"

if missing("`psid_bsamp'") {
	log using "./PSID_qaly_estimations`defmod'.log", replace
	if !missing("`defmod'"){
		global ster "$local_path/Estimates/PSID/`defmod'"
	}
	else {
		global ster "$local_path/Estimates/PSID"
	}
}
else {
	log using "./bootstrap_logs/PSID_qaly_estimations`psid_bsamp'_`defmod'.log", replace
	if !missing("`defmod'"){
		global ster "$local_path/Estimates/PSID/`defmod'/models_rep`psid_bsamp'"
	}
	else {
		global ster "$local_path/Estimates/PSID/models_rep`psid_bsamp'"
	}
}

* Set up the bootstrapped PSID data for later use
tempfile psid_analytic
use "$outdata/psid_analytic.dta", clear
if !missing("`psid_bsamp'") {
	use $outdata/input_rep`psid_bsamp'/psid_bootstrap_sample.dta, clear
	tab bsample
	local max=r(r)

	forval i = 1/`max' {	
		use $outdata/psid_analytic.dta, clear 
		gen bsample=`i'
		* merge strata famno68 (non wave specific) back onto data as famo68b
		merge m:1 hhidpn_orig using $outdata/psid_hhidb.dta
		drop if _m==2
		drop _merge
		* keep data for sample specific to bootstrap sample based on hhidb 
		merge m:1 sestrat seclust bsample using $outdata/input_rep`psid_bsamp'/psid_bootstrap_sample.dta
		keep if _merge==3
		drop _merge
		save $outdata/input_rep`psid_bsamp'/psid_analytic`i'.dta, replace
		}
	
	* stack when famno68 was selected more than once in sample
	use $outdata/input_rep`psid_bsamp'/psid_analytic1.dta
		forval i = 2/`max' {
			append using $outdata/input_rep`psid_bsamp'/psid_analytic`i'.dta, nolabel
			}

	forval i = 1/`max' {	
		rm $outdata/input_rep`psid_bsamp'/psid_analytic`i'.dta
		}
}
save `psid_analytic'
clear

* Use the MEPS 18+ 2001-2003 data
use "$outdata/MEPS_EQ5D", replace

* This agecat was defined only for 51+.  We want all ages 18+.
drop agecat
egen agecat = cut(age), at(18,25,35,45,55,65,75,85,200)
tab age agecat

tab srh agecat

/* Calculate the age bucket-specific mean srh values */
collapse srh [weight=round(perwt)], by(agecat)
gen mean_srh_meps_agecat = srh
drop srh

/* Save for later*/
tempfile meps_srh
save `meps_srh'

use `psid_analytic', clear

egen agecat = cut(age), at(18,25,35,45,55,65,75,85,200)

tab srh, m
* PSID is coded opposite of MEPS for srh
recode srh (1=5) (2=4) (3=3) (4=2) (5=1)
tab srh, m

/* Calculate the age bucket-specific mean srh values */
egen agecat_weight = total(weight), by(agecat)
egen agecat_srh = total(srh * weight), by(agecat)
gen mean_srh_psid_agecat = agecat_srh/agecat_weight if !missing(agecat) & !missing(srh)
drop agecat_*
  
/* Merge in the MEPS-specific srh values */
merge agecat using `meps_srh', sort uniqusing keep(mean_srh_meps_agecat) nokeep
drop _merge

/* Calculate the ratios of srh per age category */
gen srh_ratio = mean_srh_psid_agecat / mean_srh_meps_agecat

keep agecat srh_ratio
collapse (first) srh_ratio, by(agecat)

list

if missing("`psid_bsamp'") {
	save $outdata/PSID_srh_ratio, replace
}
else {
	save $outdata/input_rep`psid_bsamp'/PSID_srh_ratio, replace
}

* 
use $outdata/MEPS_EQ5D, clear
* This agecat was defined only for 51+.  We want all ages 18+.
drop agecat
egen agecat = cut(age), at(18,25,35,45,55,65,75,85,200)
if missing("`psid_bsamp'") {
	merge agecat using $outdata/PSID_srh_ratio, sort uniqusing keep(srh_ratio) nokeep
}
else {
	merge agecat using $outdata/input_rep`psid_bsamp'/PSID_srh_ratio, sort uniqusing keep(srh_ratio) nokeep
}
drop _merge

* Why do we do this???
* keep if eq5d>=0 & eq5d<=1 & eq5d ~= .

if missing("`psid_bsamp'") {
	/* Plot original weighted histogram of EQ5D values and calculate statistics */
	hist eq5d [fw = round(perwt)], bin(50)
	su eq5d [fw = round(perwt)] if eq5d==1
	su eq5d [fw = round(perwt)]

	* Histograms using EQ5D scores from 2004 paper (based on mean EQ5D assessment)
	hist eq5d if age>=25 & age<30 [fw=round(perwt)], name(panela_fam, replace) nodraw fraction bin(25) yscale(range(0 .4)) ytick(0 .1 .2 .3 .4) ylabel(0 .1 .2 .3 .4)  xtick(0 .2 .4 .6 .8 1) xlabel(0 .2 .4 .6 .8 1) xtitle("QoL") title("25-29")
	hist eq5d if age>=30 & age<35 [fw=round(perwt)], name(panelb_fam, replace) nodraw fraction bin(25) yscale(range(0 .4)) ytick(0 .1 .2 .3 .4) ylabel(0 .1 .2 .3 .4)  xtick(0 .2 .4 .6 .8 1) xlabel(0 .2 .4 .6 .8 1) xtitle("QoL") title("30-34")
	hist eq5d if age>=35 & age<40 [fw=round(perwt)], name(panelc_fam, replace) nodraw fraction bin(25) yscale(range(0 .4)) ytick(0 .1 .2 .3 .4) ylabel(0 .1 .2 .3 .4)  xtick(0 .2 .4 .6 .8 1) xlabel(0 .2 .4 .6 .8 1) xtitle("QoL") title("35-39")
	hist eq5d if age>=40 & age<45 [fw=round(perwt)], name(paneld_fam, replace) nodraw fraction bin(25) yscale(range(0 .4)) ytick(0 .1 .2 .3 .4) ylabel(0 .1 .2 .3 .4)  xtick(0 .2 .4 .6 .8 1) xlabel(0 .2 .4 .6 .8 1) xtitle("QoL") title("40-44")
	hist eq5d if age>=45 & age<50 [fw=round(perwt)], name(panele_fam, replace) nodraw fraction bin(25) yscale(range(0 .4)) ytick(0 .1 .2 .3 .4) ylabel(0 .1 .2 .3 .4)  xtick(0 .2 .4 .6 .8 1) xlabel(0 .2 .4 .6 .8 1) xtitle("QoL") title("45-49")
	hist eq5d if age>=50 & age<55 [fw=round(perwt)], name(panelf_fam, replace) nodraw fraction bin(25) yscale(range(0 .4)) ytick(0 .1 .2 .3 .4) ylabel(0 .1 .2 .3 .4)  xtick(0 .2 .4 .6 .8 1) xlabel(0 .2 .4 .6 .8 1) xtitle("QoL") title("50-54")
	hist eq5d if age>=55 & age<60 [fw=round(perwt)], name(panelg_fam, replace) nodraw fraction bin(25) yscale(range(0 .4)) ytick(0 .1 .2 .3 .4) ylabel(0 .1 .2 .3 .4)  xtick(0 .2 .4 .6 .8 1) xlabel(0 .2 .4 .6 .8 1) xtitle("QoL") title("55-59")
	hist eq5d if age>=60 & age<65 [fw=round(perwt)], name(panelh_fam, replace) nodraw fraction bin(25) yscale(range(0 .4)) ytick(0 .1 .2 .3 .4) ylabel(0 .1 .2 .3 .4)  xtick(0 .2 .4 .6 .8 1) xlabel(0 .2 .4 .6 .8 1) xtitle("QoL") title("60-64")
	hist eq5d if age>=65 & age<70 [fw=round(perwt)], name(paneli_fam, replace) nodraw fraction bin(25) yscale(range(0 .4)) ytick(0 .1 .2 .3 .4) ylabel(0 .1 .2 .3 .4)  xtick(0 .2 .4 .6 .8 1) xlabel(0 .2 .4 .6 .8 1) xtitle("QoL") title("65-69")
	hist eq5d if age>=70 & age<75 [fw=round(perwt)], name(panelj_fam, replace) nodraw fraction bin(25) yscale(range(0 .4)) ytick(0 .1 .2 .3 .4) ylabel(0 .1 .2 .3 .4)  xtick(0 .2 .4 .6 .8 1) xlabel(0 .2 .4 .6 .8 1) xtitle("QoL") title("70-74")
	hist eq5d if age>=75 & age<80 [fw=round(perwt)], name(panelk_fam, replace) nodraw fraction bin(25) yscale(range(0 .4)) ytick(0 .1 .2 .3 .4) ylabel(0 .1 .2 .3 .4)  xtick(0 .2 .4 .6 .8 1) xlabel(0 .2 .4 .6 .8 1) xtitle("QoL") title("75-79")
	hist eq5d if age>=80 & age<85 [fw=round(perwt)], name(panell_fam, replace) nodraw fraction bin(25) yscale(range(0 .4)) ytick(0 .1 .2 .3 .4) ylabel(0 .1 .2 .3 .4)  xtick(0 .2 .4 .6 .8 1) xlabel(0 .2 .4 .6 .8 1) xtitle("QoL") title("80-84")
	hist eq5d if age>=85 [fw=round(perwt)], name(panelm_fam, replace) nodraw fraction bin(25) yscale(range(0 .4)) ytick(0 .1 .2 .3 .4) ylabel(0 .1 .2 .3 .4) xtick(0 .2 .4 .6 .8 1) xlabel(0 .2 .4 .6 .8 1) xtitle("QoL") title("85+")
	graph combine panela_fam panelb_fam panelc_fam paneld_fam panele_fam panelf_fam panelg_fam panelh_fam paneli_fam panelj_fam panelk_fam panell_fam panelm_fam, cols(3) imargin(tiny)
	graph save eq5d_hists`psid_bsamp'.gph, replace

	* Histograms using EQ5D scores from 2010 paper (based on median EQ5D assessment)
	hist eq5d_median if age>=25 & age<30 [fw=round(perwt)], name(panela_fam, replace) nodraw fraction bin(25) yscale(range(0 .4)) ytick(0 .1 .2 .3 .4) ylabel(0 .1 .2 .3 .4)  xtick(0 .2 .4 .6 .8 1) xlabel(0 .2 .4 .6 .8 1) xtitle("QoL") title("25-29")
	hist eq5d_median if age>=30 & age<35 [fw=round(perwt)], name(panelb_fam, replace) nodraw fraction bin(25) yscale(range(0 .4)) ytick(0 .1 .2 .3 .4) ylabel(0 .1 .2 .3 .4)  xtick(0 .2 .4 .6 .8 1) xlabel(0 .2 .4 .6 .8 1) xtitle("QoL") title("30-34")
	hist eq5d_median if age>=35 & age<40 [fw=round(perwt)], name(panelc_fam, replace) nodraw fraction bin(25) yscale(range(0 .4)) ytick(0 .1 .2 .3 .4) ylabel(0 .1 .2 .3 .4)  xtick(0 .2 .4 .6 .8 1) xlabel(0 .2 .4 .6 .8 1) xtitle("QoL") title("35-39")
	hist eq5d_median if age>=40 & age<45 [fw=round(perwt)], name(paneld_fam, replace) nodraw fraction bin(25) yscale(range(0 .4)) ytick(0 .1 .2 .3 .4) ylabel(0 .1 .2 .3 .4)  xtick(0 .2 .4 .6 .8 1) xlabel(0 .2 .4 .6 .8 1) xtitle("QoL") title("40-44")
	hist eq5d_median if age>=45 & age<50 [fw=round(perwt)], name(panele_fam, replace) nodraw fraction bin(25) yscale(range(0 .4)) ytick(0 .1 .2 .3 .4) ylabel(0 .1 .2 .3 .4)  xtick(0 .2 .4 .6 .8 1) xlabel(0 .2 .4 .6 .8 1) xtitle("QoL") title("45-49")
	hist eq5d_median if age>=50 & age<55 [fw=round(perwt)], name(panelf_fam, replace) nodraw fraction bin(25) yscale(range(0 .4)) ytick(0 .1 .2 .3 .4) ylabel(0 .1 .2 .3 .4)  xtick(0 .2 .4 .6 .8 1) xlabel(0 .2 .4 .6 .8 1) xtitle("QoL") title("50-54")
	hist eq5d_median if age>=55 & age<60 [fw=round(perwt)], name(panelg_fam, replace) nodraw fraction bin(25) yscale(range(0 .4)) ytick(0 .1 .2 .3 .4) ylabel(0 .1 .2 .3 .4)  xtick(0 .2 .4 .6 .8 1) xlabel(0 .2 .4 .6 .8 1) xtitle("QoL") title("55-59")
	hist eq5d_median if age>=60 & age<65 [fw=round(perwt)], name(panelh_fam, replace) nodraw fraction bin(25) yscale(range(0 .4)) ytick(0 .1 .2 .3 .4) ylabel(0 .1 .2 .3 .4)  xtick(0 .2 .4 .6 .8 1) xlabel(0 .2 .4 .6 .8 1) xtitle("QoL") title("60-64")
	hist eq5d_median if age>=65 & age<70 [fw=round(perwt)], name(paneli_fam, replace) nodraw fraction bin(25) yscale(range(0 .4)) ytick(0 .1 .2 .3 .4) ylabel(0 .1 .2 .3 .4)  xtick(0 .2 .4 .6 .8 1) xlabel(0 .2 .4 .6 .8 1) xtitle("QoL") title("65-69")
	hist eq5d_median if age>=70 & age<75 [fw=round(perwt)], name(panelj_fam, replace) nodraw fraction bin(25) yscale(range(0 .4)) ytick(0 .1 .2 .3 .4) ylabel(0 .1 .2 .3 .4)  xtick(0 .2 .4 .6 .8 1) xlabel(0 .2 .4 .6 .8 1) xtitle("QoL") title("70-74")
	hist eq5d_median if age>=75 & age<80 [fw=round(perwt)], name(panelk_fam, replace) nodraw fraction bin(25) yscale(range(0 .4)) ytick(0 .1 .2 .3 .4) ylabel(0 .1 .2 .3 .4)  xtick(0 .2 .4 .6 .8 1) xlabel(0 .2 .4 .6 .8 1) xtitle("QoL") title("75-79")
	hist eq5d_median if age>=80 & age<85 [fw=round(perwt)], name(panell_fam, replace) nodraw fraction bin(25) yscale(range(0 .4)) ytick(0 .1 .2 .3 .4) ylabel(0 .1 .2 .3 .4)  xtick(0 .2 .4 .6 .8 1) xlabel(0 .2 .4 .6 .8 1) xtitle("QoL") title("80-84")
	hist eq5d_median if age>=85 [fw=round(perwt)], name(panelm_fam, replace) nodraw fraction bin(25) yscale(range(0 .4)) ytick(0 .1 .2 .3 .4) ylabel(0 .1 .2 .3 .4) xtick(0 .2 .4 .6 .8 1) xlabel(0 .2 .4 .6 .8 1) xtitle("QoL") title("85+")
	graph combine panela_fam panelb_fam panelc_fam paneld_fam panele_fam panelf_fam panelg_fam panelh_fam paneli_fam panelj_fam panelk_fam panell_fam panelm_fam, cols(3) imargin(tiny)
	graph save eq5d_median_hists`psid_bsamp'.gph, replace

	* EQ5D based on 2004 model
	table agecat [fw=round(perwt)], contents (mean eq5d p10 eq5d p50 eq5d p90 eq5d)
	* EQ5D based on 2010 median model
	table agecat [fw=round(perwt)], contents (mean eq5d_median p10 eq5d_median p50 eq5d_median p90 eq5d_median)
}

* Scaling factors for SRH
gen srh_psid = srh * srh_ratio
replace srh_psid = 5 if srh_psid > 5
replace srh_psid = 1 if srh_psid < 1


/* Create the interaction term between srh_psid and age>=75 */
gen srh_psid_75p = srh_psid
replace srh_psid_75p = 0 if age<75

/* Rename the MEPS variables to HRS conventions */
gen widowed = marry==2
gen single = inlist(marry, 3, 4, 5, 6)

/* Merge in the health variables */
merge dupersid yr using "$outdata/MEPS_cost_est.dta", uniqmaster keep(cancre diabe hibpe hearte lunge stroke bsample*) sort nokeep
drop _merge

/* Create self-reported mental health variables just to test its effect on predictive power */
gen srmh = mnhlth53
gen srmh2 = 0
replace srmh2 = 1 if srmh==2
gen srmh3 = 0
replace srmh3 = 1 if srmh==3
gen srmh4 = 0
replace srmh4 = 1 if srmh==4
gen srmh5 = 0
replace srmh5 = 1 if srmh==5

/* Create new cognitive limitations variable */
gen memrye = 0
replace memrye = 1 if coglim53 == 1

/* Create overweight variable */
gen overwt = 0
replace overwt = 1 if bmindx53 >= 25.0 & bmindx53 < 30

/* Create obesity variable */
gen obese = 0
replace obese = 1 if bmindx53 >= 30

/* Create smoking variable */
gen smoken = 0
replace smoken = 1 if adsmok42 == 1

/* Create eq5d=1 indicator variable */
gen eq5d1 = 0
replace eq5d1 = 1 if eq5d == 1


/* Generate summary statistics on regressors */
tab srh2 if srh2 ~= . [fw=round(perwt)]
tab srh3 if srh3 ~= . [fw=round(perwt)]
tab srh4 if srh4 ~= . [fw=round(perwt)]
tab srh5 if srh5 ~= . [fw=round(perwt)]
tab adlhelp if adlhelp ~= . [fw=round(perwt)]
tab iadlhelp if iadlhelp ~= . [fw=round(perwt)]
tab cancre if cancre ~= . [fw=round(perwt)]
tab diabe if diabe ~= . [fw=round(perwt)]
tab hibpe if hibpe ~= . [fw=round(perwt)]
tab hearte if hearte ~= . [fw=round(perwt)]
tab lunge if lunge ~= . [fw=round(perwt)]
tab stroke if stroke ~= . [fw=round(perwt)]
tab single if single ~= . [fw=round(perwt)]
tab widowed if widowed ~= . [fw=round(perwt)]
tab memrye if memrye ~= . [fw=round(perwt)]
tab overwt if overwt ~= . [fw=round(perwt)]
tab obese if obese ~= . [fw=round(perwt)]
tab smoken if smoken ~= . [fw=round(perwt)]

/* Drop cases with missing values for any single regressor */
count
keep if srh == 1 | srh == 2 | srh == 3 | srh == 4 | srh == 5
keep if eq5d>=0 & eq5d<=1 & eq5d ~= .
keep if coglim53 ~= -8 & coglim53 ~= -1
keep if bmindx53 ~= -9 & bmindx53 ~= -1
keep if adsmok42 ~= -9 & adsmok42 ~= -1
keep if adlhelp ~= .
keep if iadlhelp ~= .
count

/* EQ5D MEPS REGRESSION */
/* Using hybrid approach:  Indicator variables for age<75, and the adjusted single variable for age>=75 */
regress eq5d srh2_l75 srh3_l75 srh4_l75 srh5_l75 srh_psid_75p adlhelp /* iadlhelp*/ cancre diabe hibpe hearte lunge stroke /*memrye*/ obese smoken single widowed [fw=round(perwt)]
est store eq5d_fam

* Try the competing EQ5D measure
regress eq5d_median srh2_l75 srh3_l75 srh4_l75 srh5_l75 srh_psid_75p adlhelp /*iadlhelp*/ cancre diabe hibpe hearte lunge stroke /*memrye*/ obese smoken single widowed [fw=round(perwt)]
est store eq5d_median_fam








/******* BEGIN USE OF PSID DATA *********/
use `psid_analytic', clear


* Recode SRH in the other way
recode srh (1=5) (2=4) (3=3) (4=2) (5=1)

forvalues i=1/5 {
  gen srh`i' = srh==`i'
}

forvalues i=2/5 {
  gen srh`i'_l75 = srh`i' * (age < 75)
}
gen srh_psid_75p = srh * (age >= 75)

gen iadl1 = iadlstat==2 if !missing(iadlstat)
gen iadl2p = iadlstat==3 if !missing(iadlstat)

gen adl1 = adlstat==2 if !missing(adlstat)
gen adl2 = adlstat==3 if !missing(adlstat)
gen adl3p = adlstat==4 if !missing(adlstat)



/* Generate summary statistics on regressors */
tab srh2 if srh2 ~= . [aw=round(weight)]
tab srh3 if srh3 ~= . [aw=round(weight)]
tab srh4 if srh4 ~= .  [aw=round(weight)]
tab srh5 if srh5 ~= .  [aw=round(weight)]
tab cancre if cancre ~= .  [aw=round(weight)]
tab diabe if diabe ~= .  [aw=round(weight)]
tab hibpe if hibpe ~= .  [aw=round(weight)]
tab hearte if hearte ~= .  [aw=round(weight)]
tab lunge if lunge ~= .  [aw=round(weight)]
tab stroke if stroke ~= .  [aw=round(weight)]
tab single if single ~= .  [aw=round(weight)]
tab widowed if widowed ~= .  [aw=round(weight)]
tab obese if obese ~= .  [aw=round(weight)]
tab smoken if smoken ~= .  [aw=round(weight)]

*** get the covariate definitions for defmod
include PSID_qaly_covariate_defs`defmod'.do	


* Old method (based on 2004 estimation)
est restore eq5d_fam
predict qaly
regress qaly `covars_qaly' [aw=weight]
gen e_qaly = e(sample)

if `chk_bs'==1 {
	* check that the model will behave well in bootstrap samples
	di "Checking PSID bootstrap variation in qaly model predictors"
	foreach v in `covars_qaly' {
		qui count if missing(`v') & e_qaly==1
		if r(N) > 0 {
			di "WARNING: `v' is missing for in-sample (e_qaly==1) observations"
		}
		chk_bootstrap_variation `v' sestrat seclust e_qaly 0.0005
	}
}

eststo qaly
est save "$ster/qaly.ster", replace

* Competing new method (based on 2010 median estimation)
est restore eq5d_median_fam
predict qaly_alt
regress qaly_alt `covars_qaly_alt' [aw=weight]
gen e_qaly_alt = e(sample)

if `chk_bs'==1 {
	* check that the model will behave well in bootstrap samples
	di "Checking PSID bootstrap variation in qaly_alt model predictors"
	foreach v in `covars_qaly_alt' {
		qui count if missing(`v') & e_qaly_alt==1
		if r(N) > 0 {
			di "WARNING: `v' is missing for in-sample (e_qaly_alt==1) observations"
		}
		chk_bootstrap_variation `v' sestrat seclust e_qaly_alt 0.0005
	}
}

eststo qaly_alt
* est save "$ster/qaly_alt.ster", replace


egen agecat = cut(age), at(18,25,35,45,55,65,75,85,200)

table agecat [fw=round(weight)], contents (mean qaly p10 qaly p50 qaly p90 qaly)
table agecat [fw=round(weight)], contents (mean qaly_alt p10 qaly_alt p50 qaly_alt p90 qaly_alt)

xml_tab qaly, save($ster/qaly.xls) replace pvalue

sum qaly, detail
sum qaly_alt, detail


capture log close
