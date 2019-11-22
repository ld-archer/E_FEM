/* Show prevalence of diseases in PSID and in FAM on same plot, 1999-20?? */


quietly include ../../../../../fem_env.do

* Process the PSID
use $outdata/psid_analytic.dta

* Keep nationally representative years
keep if year >= 1999

* Keep people ages 55+
keep if age >= 25

* ADL measures
gen anyadl = (adlstat > 1) if !missing(adlstat)
gen adl3p = (adlstat == 4) if !missing(adlstat)

* IADL measures
gen anyiadl = (iadlstat > 1) if !missing(iadlstat)
gen iadl2p = (iadlstat == 3) if !missing(iadlstat)



* To do: Try to create/process this list from FEM_CPP_settings/measures_subpop_example.do

local outcome cancre diabe hearte hibpe lunge stroke 
local outcome2 anyhi diclaim oasiclaim ssiclaim work 
local outcome3 bmi
local outcome4 anyadl adl3p anyiadl iadl2p								

local seoutcome secancre=cancre sediabe=diabe sehearte=hearte sehibpe=hibpe selunge=lunge sestroke=stroke 
local seoutcome2 seanyhi=anyhi sediclaim=diclaim seoasiclaim=oasiclaim sessiclaim=ssiclaim sework=work 
local seoutcome3 sebmi=bmi	
local seoutcome4 seanyadl=anyadl seadl3p=adl3p seanyiadl=anyiadl seiadl2p=iadl2p				

collapse (mean) `outcome' `outcome2' `outcome3' `outcome4' (semean) `seoutcome' `seoutcome2' `seoutcome3' `seoutcome4' [aw=weight], by(year male)

* Get bounds for CI
foreach var of varlist `outcome' `outcome2' `outcome3' `outcome4' {
	gen lb`var' = `var' - se`var'
	gen ub`var' = `var' + se`var'
}


foreach var of varlist `outcome' `outcome2' {
	rename `var' p_`var'_all_psid25p
}

foreach var of varlist `outcome3' {
	rename `var' a_`var'_all_psid25p
}

foreach var of varlist `outcome4' {
	rename `var' p_`var'_all_psid25p
}

* 2013 looks weird ...
keep if year <= 2009

tempfile psid
save `psid'

merge m:1 year using `local_root'/output/psid_baseline/psid_baseline_summary.dta

* limit years displayed
keep if year <= 2050

* Males
forvalues sex = 0/1 {
	if `sex' == 0 {
		local suf female
		local s f
	}
	else if `sex' == 1 {
		local suf male
		local s m
	}
	
	foreach var in `outcome' `outcome4' {
		if "`var'" == "cancre" {
			local title "Cancer Ever"
		} 
		else if "`var'" == "diabe" {
			local title "Diabetes Ever"
		}
		else if "`var'" == "hearte" {
			local title "Heart Disease Ever"
		}
		else if "`var'" == "hibpe" {
			local title "Hypertension Ever"
		}
		else if "`var'" == "lunge" {
			local title "Lung Disease Ever"
		}
		else if "`var'" == "stroke" {
			local title "Stroke Ever"
		}
		else if "`var'" == "anyadl" {
			local title "Any ADL difficulties"
		}
		else if "`var'" == "adl3p" {
			local title "3 or more ADL difficulties"
		}		
		else if "`var'" == "anyiadl" {
			local title "Any IADL difficulties"
		}
		else if "`var'" == "iadl2p" {
			local title "2 or more IADL difficulties"
		}		
		
		
		twoway 	/* rcap lb`var' ub`var' year if male == `sex', lstyle(ci) ||  */ ///
						scatter p_`var'_all_psid25p year if male == `sex', mstyle(p1) msize(small)  || ///
						line p_`var'_25p_`s'_l year, lpattern(shortdash) ///
						, title("`title'") legend(off) xtitle("") ///
						scheme(s1mono) ///
						saving(`var'_`suf', replace)
		* Individual graphs if we want them				
		graph export ../../FAM/img/`var'_`suf'.pdf, replace
	}
	
	* All six chronic diseases on one graph
	graph combine cancre_`suf'.gph diabe_`suf'.gph hearte_`suf'.gph hibpe_`suf'.gph lunge_`suf'.gph stroke_`suf'.gph, scheme(s1mono) ycommon
	graph export ../../FAM/img/chronic_diseases_`suf'.pdf, replace
	
	* ADL measures on one graph
	graph combine anyadl_`suf'.gph adl3p_`suf'.gph anyiadl_`suf'.gph iadl2p_`suf'.gph , scheme(s1mono) ycommon
	graph export ../../FAM/img/adl_iadl_`suf'.pdf, replace
	
	
}




/*
foreach var in `outcome3' {
	twoway 	rcap lb`var' ub`var' year, lstyle(ci) || ///
					scatter a_`var'_all_hrs55p year, mstyle(p1)  || ///
					line a_`var'_55p_l year, lpattern(dash) ///
					, legend(off) ///
					scheme(s1mono)
					
	graph export handover/`var'.pdf, replace
}
*/





capture log close
