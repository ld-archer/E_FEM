/* Creating script for cross validation.

This script will extract information from ELSA on chronic disease, ADLs and IADLs
for both men and women, and compares them to estimates produced by our FEM 
simluation. 

ELSA first wave was in 2002, and data was collected every 2 years subsequently 
(known as waves), with our current final wave (wave 6) collected in 2014.
We will therefore simulate from 2006 onwards, allowing us to see unsimulated 
ELSA data for the first 6 years, and then a comparison with simulated FEM data
from 2006-2014, finally showing only FEM simulated data from 2014 onwards.

This is to validate our early simulated data against known true trajectories 
in the raw data.

*/
clear all

quietly include ../../fem_env.do

* Measures that will be present in the simulation
quietly include ../../FEM_CPP_settings/measures_subpop_ELSA.do

* Load reshaped data
*use ../../input_data/H_ELSA_f_2002-2016.dta, clear
*use ../../input_data/ELSA_long.dta, clear
use $outdata/ELSA_long.dta, clear

* Keep people ages 55+
keep if age >= 55

* ADL measures
*gen anyadl = (adlstat > 1) if !missing(adlstat)
*gen adl3p = (adlstat == 4) if !missing(adlstat)

* IADL measures
*gen anyiadl = (iadlstat > 1) if !missing(iadlstat)
*gen iadl2p = (iadlstat == 3) if !missing(iadlstat)




* Outcomes, most of whats in measures_subpop_ELSA.do
local outcome cancre diabe hearte hibpe lunge stroke demene alzhe
*local outcome2 employed // abstainer moderate increasingRisk highRisk
local outcome3 bmi alcfreq //alcbase
local outcome4 anyadl adl3p anyiadl iadl2p
local outcome5 alcfreq1 alcfreq2 alcfreq3 alcfreq4 alcfreq5 alcfreq6 alcfreq7 alcfreq8

local seoutcome secancre=cancre sediabe=diabe sehearte=hearte sehibpe=hibpe selunge=lunge sestroke=stroke sedemene=demene sealzhe=alzhe
*local seoutcome2 seemployed=employed // seabstainer=abstainer semoderate=moderate seincreasingRisk=increasingRisk sehighRisk=highRisk
local seoutcome3 sebmi=bmi sealcfreq=alcfreq //sealcbase=alcbase
local seoutcome4 seanyadl=anyadl seadl3p=adl3p seanyiadl=anyiadl seiadl2p=iadl2p
local seoutcome5 sealcfreq1=alcfreq1 sealcfreq2=alcfreq2 sealcfreq3=alcfreq3 sealcfreq4=alcfreq4 sealcfreq5=alcfreq5 sealcfreq6=alcfreq6 sealcfreq7=alcfreq7 sealcfreq8=alcfreq8

* `outcome2' `seoutcome2'
collapse (mean) `outcome' `outcome2' `outcome3' `outcome4' `outcome5' (semean) `seoutcome' `seoutcome2' `seoutcome3' `seoutcome4' `seoutcome5' [aw=cwtresp], by(year male)

* Get bounds for CI
foreach var of varlist `outcome' `outcome2' `outcome3' `outcome4' `outcome5' {
	gen lb`var' = `var' - se`var'
	gen ub`var' = `var' + se`var'
}

* p for prevalence
foreach var of varlist `outcome' `outcome2' `outcome5' {
	rename `var' p_`var'_all_ELSA55p
}

* a for average
foreach var of varlist `outcome3' {
	rename `var' a_`var'_all_ELSA55p
}

foreach var of varlist `outcome4' {
	rename `var' p_`var'_all_ELSA55p
}

tempfile ELSA
save `ELSA'

* Is the following for restricted output? Need to add into fem_env.do if this is
* necessary, if for restricted output then probably not necessary yet
*capture confirm file "$routput_dir/vBaseline"

local output $output_dir

*merge m:1 year using `output'/ELSA_core_base/ELSA_core_base_summary.dta
merge m:1 year using `output'/COMPLETE/ELSA_core_base/ELSA_core_base_summary.dta
*merge m:1 year using ../../output/vBaseline_ELSA/vBaseline_ELSA_summary.dta

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
	
	foreach var in `outcome' `outcome2' `outcome4' `outcome5' {
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
		else if "`var'" == "demene" {
			local title "Dementia ever"
		}
		else if "`var'" == "alzhe" {
			local title "Alzheimers ever"
		}
		else if "`var'" == "employed" {
			local title "Employed"
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
		else if "`var'" == "abstainer" {
			local title "Abstains from alcohol consumption"
			replace p_`var'_all_ELSA55p = . if year < 2008
		}
		else if "`var'" == "moderate" {
			local title "Moderate alcohol consumption"
			replace p_`var'_all_ELSA55p = . if year < 2008
		}
		else if "`var'" == "increasingRisk" {
			local title "Increasing Risk alcohol consumption"
			replace p_`var'_all_ELSA55p = . if year < 2008
		}
		else if "`var'" == "highRisk" {
			local title "High Risk alcohol consumption"
			replace p_`var'_all_ELSA55p = . if year < 2008
		}
		else if "`var'" == "alcfreq1" {
			local title "Alcohol Consumption Frequency 1"
		}
		else if "`var'" == "alcfreq2" {
			local title "Alcohol Consumption Frequency 2"
		}
		else if "`var'" == "alcfreq3" {
			local title "Alcohol Consumption Frequency 3"
		}
		else if "`var'" == "alcfreq4" {
			local title "Alcohol Consumption Frequency 4"
		}
		else if "`var'" == "alcfreq5" {
			local title "Alcohol Consumption Frequency 5"
		}
		else if "`var'" == "alcfreq6" {
			local title "Alcohol Consumption Frequency 6"
		}
		else if "`var'" == "alcfreq7" {
			local title "Alcohol Consumption Frequency 7"
		}
		else if "`var'" == "alcfreq8" {
			local title "Alcohol Consumption Frequency 8"
		}

		
		twoway scatter p_`var'_all_ELSA55p year if male == `sex', mstyle(p1) msize(small) || ///
			line p_`var'_55p_`s'_l year, lpattern(shortdash) ///
			, title("`title'") legend(off) xtitle("") ylabel(,format(%9.2f) angle(horizontal)) ///
			scheme(s1mono) ///
			saving(`var'_`suf', replace)
		* Individual graphs if we want them
		graph export FEM/img/`var'_`suf'.pdf, replace
	}

	foreach var in `outcome3' {
		if "`var'" == "bmi" {
			local title "Body Mass Index (BMI)"
		}
		else if "`var'" == "alcbase" {
			local title "Alcohol Consumption (Units)"
			replace a_`var'_all_ELSA55p = . if year < 2008
		}
		else if "`var'" == "alcfreq" {
			local title "Alcohol Consumption Frequency (8 levels)"
		}

		twoway scatter a_`var'_all_ELSA55p year if male == `sex', mstyle(p1) msize(small) || ///
			line a_`var'_55p_`s'_l year, lpattern(shortdash) ///
			, title("`title'") legend(off) xtitle("") ylabel(,format(%9.2f) angle(horizontal)) ///
			scheme(s1mono) ///
			saving(`var'_`suf', replace)
		* Individual graphs if we want them
		graph export FEM/img/`var'_`suf'.pdf, replace
	}
	
	* All six chronic diseases on one graph
	graph combine cancre_`suf'.gph diabe_`suf'.gph hearte_`suf'.gph hibpe_`suf'.gph lunge_`suf'.gph stroke_`suf'.gph, scheme(s1mono) ycommon
	graph export FEM/img/chronic_diseases_`suf'.pdf, replace
	
	* ADL measures on one graph
	graph combine anyadl_`suf'.gph adl3p_`suf'.gph anyiadl_`suf'.gph iadl2p_`suf'.gph , scheme(s1mono) ycommon
	graph export FEM/img/adl_iadl_`suf'.pdf, replace

}



capture log close
