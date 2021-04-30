/* Construct an ROC analysis of ELSA FEM projections 

Using the cross-validation sample/estimates.

*/
clear all

quietly include ../../../fem_env.do

local maxrep 100
local minyr 2006
local maxyr 2016

local scenarios ELSA_CV1 ELSA_minimal

foreach scn of local scenarios {

	* append all of the simulations
	forvalues yr = `minyr' (2) `maxyr' {
		forvalues rep = 1/`maxrep' {
			append using ../../../output/`scn'/detailed_output/y`yr'_rep`rep'.dta
		}
	}
	
	* one observation per person
	bys hhidpn mcrep (year): keep if _n == _N
	
	gen obese = (bmi > 30) if !missing(bmi)
	gen obese_3 = (bmi > 40) if !missing(bmi)
	
	foreach var in died cancre diabe hearte hibpe lunge stroke obese obese_3 {
		rename `var' `var'_elsa
	}
	
	keep hhidpn died_elsa cancre_elsa diabe_elsa hearte_elsa hibpe_elsa lunge_elsa stroke_elsa obese_elsa obese_3_elsa mcrep
	collapse died_elsa cancre_elsa diabe_elsa hearte_elsa hibpe_elsa lunge_elsa stroke_elsa obese_elsa obese_3_elsa, by(hhidpn)
	
	tempfile ELSA_FEM
	save `ELSA_FEM'
	
    * This file needs to be replaced
	*use $outdata/psid_analytic.dta, replace
    use ../../../input_data/ELSA_long.dta, replace
	merge m:1 hhidpn using `ELSA_FEM'
	
	
	* mortality
	bys hhidpn: egen died_ever = max(died)
	foreach var in cancre diabe hearte hibpe lunge stroke {	
		bys hhidpn: egen `var'_init = min(`var')
	}
	
	bys hhidpn (year): gen obese_init = bmi[1] > 30 
	
	
	bys hhidpn: keep if _n == _N
	save `scn'_data.dta, replace
	
	if "`scn'" == "ELSA_CV1" {
		local label1 "Full specification"
	} 
	
	else if "`scn'" == "ELSA_minimal" {
		local label1 "Minimal"
	}
		
	
	
	
	roctab died died_elsa
	roctab died died_elsa, graph saving(roc_plots/`scn'_died, replace) title("`label1'") scheme(s1mono)
	graph export roc_img/`scn'_died.pdf, replace
	
	
	foreach var in cancre diabe hearte hibpe lunge stroke {
		if "`var'" == "cancre" {
			local label2 "`minyr'-`maxyr' incident cancer"
		} 
		else if "`var'" == "diabe" {
			local label2 "`minyr'-`maxyr' incident diabetes"
		} 
		else if "`var'" == "hearte" {
			local label2 "`minyr'-`maxyr' incident heart disease"
		} 
		else if "`var'" == "hibpe" {
			local label2 "`minyr'-`maxyr' incident hypertension"
		} 
		else if "`var'" == "lunge" {
			local label2 "`minyr'-`maxyr' incident lung disease"
		} 
		else if "`var'" == "stroke" {
			local label2 "`minyr'-`maxyr' incident stroke"
		} 
		
		roctab `var' `var'_elsa if `var'_init == 0
		roctab `var' `var'_elsa if `var'_init == 0, graph saving(roc_plots/`scn'_`var', replace) title("`label1'") scheme(s1mono)
		graph export roc_img/`scn'_`var'.pdf, replace
	}
	
    *obese_3
	foreach var in obese  {
		if "`var'" == "obese" {
			local label2 "`minyr'-`maxyr' obese"
		} 
		else if "`var'" == "obese_3" {
			local label2 "`minyr'-`maxyr' obese_3"
		} 
		
		roctab `var' `var'_elsa 
		roctab `var' `var'_elsa , graph saving(roc_plots/`scn'_`var', replace) title("`label1'") scheme(s1mono)
		graph export roc_img/`scn'_`var'.pdf, replace
	}


	
	clear
	
}

*obese_3
foreach var in died cancre diabe hearte hibpe lunge stroke obese {
	if "`var'" == "died" {
		local label2 "`minyr'-`maxyr' mortality"
	} 
	else if "`var'" == "cancre" {
		local label2 "`minyr'-`maxyr' incident cancer"
	} 
	else if "`var'" == "diabe" {
		local label2 "`minyr'-`maxyr' incident diabetes"
	} 
	else if "`var'" == "hearte" {
		local label2 "`minyr'-`maxyr' incident heart disease"
	} 
	else if "`var'" == "hibpe" {
		local label2 "`minyr'-`maxyr' incident hypertension"
	} 
	else if "`var'" == "lunge" {
		local label2 "`minyr'-`maxyr' incident lung disease"
	} 
	else if "`var'" == "stroke" {
		local label2 "`minyr'-`maxyr' incident stroke"
	} 
	else if "`var'" == "obese" {
		local label2 "`minyr'-`maxyr' obese"
	}
	else if "`var'" == "obese_3" {
		local label2 "`minyr'-`maxyr' obese_3"
	}
	
	graph combine roc_plots/ELSA_minimal_`var'.gph roc_plots/ELSA_CV1_`var'.gph, scheme(s1mono) title("`label2'")
	graph export roc_img/combined_roc_`var'.pdf, replace
}



capture log close
