/* Construct an ROC analysis of ELSA FEM projections 

Using the cross-validation sample/estimates.

*/
clear all

quietly include ../../../fem_env.do

local maxrep 500
local minyr 2002
local maxyr 2012

local scenarios ELSA_ROC ELSA_minimal

foreach scn of local scenarios {

	* append all of the simulations
	forvalues yr = `minyr' (2) `maxyr' {
		forvalues rep = 1/`maxrep' {
			*append using /home/luke/Documents/E_FEM_clean/ROC_Analysis/`scn'/detailed_output/y`yr'_rep`rep'.dta
			*append using /home/luke/Documents/E_FEM_clean/E_FEM/output/ROC/`scn'/detailed_output/y`yr'_rep`rep'.dta
			append using $output_dir/ROC/`scn'/detailed_output/y`yr'_rep`rep'.dta
		}
	}
	
	* one observation per person
	* 2016 if not dead
	bys hhidpn mcrep (year): keep if _n == _N
	
	gen obese = (bmi > 30) if !missing(bmi)
	gen obese_3 = (bmi > 40) if !missing(bmi)
	
	foreach var in died cancre diabe hearte hibpe lunge stroke obese obese_3 demene alzhe anyadl anyiadl {
		rename `var' `var'_elsa
	}
	
	keep hhidpn died_elsa cancre_elsa diabe_elsa hearte_elsa hibpe_elsa lunge_elsa stroke_elsa obese_elsa obese_3_elsa demene_elsa alzhe_elsa anyadl_elsa anyiadl_elsa mcrep
	collapse died_elsa cancre_elsa diabe_elsa hearte_elsa hibpe_elsa lunge_elsa stroke_elsa obese_elsa obese_3_elsa demene_elsa alzhe_elsa anyadl_elsa anyiadl_elsa, by(hhidpn)
	
	tempfile ELSA_FEM
	save `ELSA_FEM'
	
	*use $outdata/psid_analytic.dta, replace
    *use ../../../input_data/ELSA_long.dta, replace
	use $outdata/ELSA_long.dta, replace
	keep if wave >= 3
	merge m:1 hhidpn using `ELSA_FEM'
	
	* Should we be only keeping the people in the simulation here? If we limit to only matched records then only hhidpns from simulation will be kept, will do the job that cwtresp is doing later on
	* keep if _merge == 3 ?

	tempfile FEM
	save `FEM'
	
	
	* mortality
	bys hhidpn: egen died_ever = max(died)
	
	
	bys hhidpn (year): keep if _n == _N
	save `scn'_data.dta, replace
	
	if "`scn'" == "ELSA_ROC" {
		local label1 "Full specification"
	} 
	
	else if "`scn'" == "ELSA_minimal" {
		local label1 "Minimal"
	}
    
    
	
	roctab died died_elsa
	roctab died died_elsa, graph saving($output_dir/ROC/roc_plots/`scn'_died, replace) title("2002-2012 Mortality") scheme(s1mono)
	graph export $output_dir/ROC/roc_img/`scn'_died.pdf, replace

	gen wv1Check = 0
	gen wv6Check = 0

	* Get the original dataset back before doing chronic disease stuff
	use `FEM', clear

	* Keep only if weight is present and positive
	keep if cwtresp > 0 & cwtresp < .
	* Generate flag for first year with var
	foreach var in cancre diabe hearte hibpe lunge stroke demene alzhe {	
		bys hhidpn: egen `var'_init = min(`var')
	}

	* Obesity initial var
	bys hhidpn (year): gen obese_init = bmi[1] > 30 
	* Drop waves after 6 (after 2012)
	drop if wave > 6
	* Keep last year respondent in data
	bys hhidpn (year): keep if _n == _N
	

	*bys hhidpn (year): keep if wave == 6

	save test_`scn'.dta, replace

	foreach var in cancre diabe hearte hibpe lunge stroke demene alzhe anyadl anyiadl {
		if "`var'" == "cancre" {
			local label2 "`minyr'-`maxyr' incident cancer"
			local label3 "Cancer"
		}
		else if "`var'" == "diabe" {
			local label2 "`minyr'-`maxyr' incident diabetes"
			local label3 "Diabetes"
		} 
		else if "`var'" == "hearte" {
			local label2 "`minyr'-`maxyr' incident heart disease"
			local label3 "Heart Disease"
		} 
		else if "`var'" == "hibpe" {
			local label2 "`minyr'-`maxyr' incident hypertension"
			local label3 "Hypertension"
		} 
		else if "`var'" == "lunge" {
			local label2 "`minyr'-`maxyr' incident lung disease"
			local label3 "Lung Disease"
		} 
		else if "`var'" == "stroke" {
			local label2 "`minyr'-`maxyr' incident stroke"
			local label3 "Stroke"
		}
		else if "`var'" == "demene" {
			local label2 "`minyr'-`maxyr' incident dementia"
			local label3 "Dementia"
		}
		else if "`var'" == "alzhe" {
			local label2 "`minyr'-`maxyr' incident alzheimers"
			local label3 "Alzheimers"
		}
		else if "`var'" == "anyadl" {
			local label2 "`minyr'-`maxyr' incident ADL"
			local label3 "ADL"
		}
		else if "`var'" == "anyiadl" {
			local label2 "`minyr'-`maxyr' incident IADL"
			local label3 "IADL"
		}
		
		* & if `select'
		roctab `var' `var'_elsa if `var'_init == 0 
		roctab `var' `var'_elsa if `var'_init == 0, graph saving($output_dir/ROC/roc_plots/`scn'_`var', replace) title("`label2'") scheme(s1mono)
		graph export $output_dir/ROC/roc_img/`scn'_`var'.pdf, replace
	}
	
	*obese_3
	foreach var in obese   {
		if "`var'" == "obese" {
			local label2 "`minyr'-`maxyr' obese"
		}
		else if "`var'" == "obese_3" {
			local label2 "`minyr'-`maxyr' obese_3"
		}
		
		roctab `var' `var'_elsa 
		roctab `var' `var'_elsa , graph saving($output_dir/ROC/roc_plots/`scn'_`var', replace) title("`label2'") scheme(s1mono)
		graph export $output_dir/ROC/roc_img/`scn'_`var'.pdf, replace
	}


	
	clear
	
}

*obese_3
foreach var in died cancre diabe hearte hibpe lunge stroke obese demene alzhe anyadl anyiadl {
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
	else if "`var'" == "demene" {
		local label2 "`minyr'-`maxyr' incident dementia"
	}
	else if "`var'" == "alzhe" {
		local label2 "`minyr'-`maxyr' incident alzheimers"
	}
	else if "`var'" == "anyadl" {
		local label2 "`minyr'-`maxyr' incident ADL"
	}
	else if "`var'" == "anyiadl" {
		local label2 "`minyr'-`maxyr' incident IADL"
	}
	
	graph combine $output_dir/ROC/roc_plots/ELSA_minimal_`var'.gph $output_dir/ROC/roc_plots/ELSA_ROC_`var'.gph, scheme(s1mono) title("`label2'")
	graph export $output_dir/ROC/roc_img/combined_roc_`var'.pdf, replace
}



capture log close
