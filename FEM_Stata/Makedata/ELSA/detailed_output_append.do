/* Appending data from detailed output for further analysis */

* Number of reps (Will change when running expts properly, set at 100 or 200)
local maxrep 10

* locals for start and stop year
local minyr 2012
local maxyr 2060

#d ;
local scenarios
ELSA_Baseline
ELSA_cohort
ELSA_pcancre100
ELSA_pdiabe100
ELSA_phearte100

;
#d cr

foreach scn of local scenarios {
	* clear dataset
	clear all
	
	* append all of the simulations
	forvalues yr = `minyr' (2) `maxyr' {
		
		forvalues rep = 1/`maxrep' {
		
			append using /home/luke/Documents/E_FEM_clean/E_FEM/output/`scn'/detailed_output/y`yr'_rep`rep'.dta
			
		}
	}
	
	* save the appended files
	save /home/luke/Documents/E_FEM_clean/E_FEM/input_data/detailed_output/`scn'_append.dta, replace
}

capture log close
