/** \file

EXAMINE DISTRIBUTION OF BMI STATUS <25, 25-30,30-35,35-40,40+
FOR INCOMING COHORT ESTIMATION AS WELL AS FOR HAZARDS ESTIMATION SAMPLE

\date FEB 9, 2010

\todo If this is useful, fix it

\bug This file will not run as-is
*/
  
clear
set more off
set mem 600m

* Define paths
global hrs_dir "/homer/e/RANDHRS/VerG" 
global fem_path "/zeno/a/FEM/FEM_1.0"

global workdir  "$fem_path/Makedata/HRS"
global indata   "$fem_path/Input_yh"
global outdata  "$fem_path/Input_yh"
global outdata2 "$fem_path/Indata_yh"
global netdir    "/homer/c/Retire/FEM/rdata"

*****************
* INCOMING COHORT ESTIMATION SAMPLE
*****************
cap log close
log using "$workdir/examine_BMI.log", replace


foreach y in 1992 {

	local i = (`y' == 1992) * 1 + (`y' == 1998) *  4 + (`y' == 2004) * 7
	use hhidpn r`i'bmi using "$indata/rndhrs_g.dta", clear
	ren r`i'bmi bmi
	gen wave = `i'
	sort hhidpn
	merge hhidpn using "$netdir/age5055_hrs`y'r.dta", sort 
	qui count if _merge == 2 
	if r(N) > 0 {
		dis "Wrong, unmerged cases in restricted estimation data"
		exit (333)
	}
	drop if _merge == 1
	
	sum bmi
	local maxbmi = r(max) + 1
	egen wtstate_new = cut(bmi), at(0, 25,30,35,40,`maxbmi')
	label define bminew 0 "<25" 25 "25-29.9" 30 "30-34.9" 35 "35-39.9" 40 "40+", modify
	label values wtstate_new bminew
	
	dis "***BMI Status distribution in incoming cohort estimation data: age5055_hrs`y'r.dta"
	tab wtstate_new, m
	list hhidpn bmi if missing(wtstate_new)
}

*****************
* HAZARD ESTIMATION SAMPLE
*****************


	use hhidpn r*bmi r*iwstat using "$indata/rndhrs_g.dta", clear
	forvalues i = 1/7 {
		ren r`i'bmi bmi`i'
		ren r`i'iwstat iwstat`i'
	}
	
	reshape long bmi iwstat, i(hhidpn) j(wave)
	xtset hhidpn wave
	gen lbmi = l.bmi
	keep if iwstat == 1
	drop iwstat
	sort hhidpn wave
	merge hhidpn wave using "$netdir/hrs17r_transition.dta", sort
	tab _merge
	count if _merge == 2  & iwstat == 1
	if r(N) > 0 {
		dis "Wrong, unmerged cases in restricted estimation data"
		exit (333)
	}
	drop if _merge == 1
	keep if iwstat == 1
	
	** Lagged BMI status
	qui sum lbmi
	local maxbmi = r(max) + 1
	egen lwtstate_new = cut(lbmi), at(0, 25,30,35,40,`maxbmi')
	label define bminew 0 "<25" 25 "25-29.9" 30 "30-34.9" 35 "35-39.9" 40 "40+", modify
	label values lwtstate_new bminew
	
	tabstat lbmi, by(lwtstate_new) stats(min max)
	
	** Current BMI status
	sum bmi
	local maxbmi = r(max) + 1
	egen wtstate_new = cut(bmi), at(0, 25,30,35,40,`maxbmi')
	label values wtstate_new bminew

	dis "***Current BMI Status distribution in transition estimation data hrs17r_transition.dta"
	tab wtstate_new	
	tab wave wtstate_new, r
	
	dis "***Lagged BMI Status distribution in transition estimation data hrs17r_transition.dta"
	tab lwtstate_new	
	tab wave lwtstate_new, r
	
cap log close
