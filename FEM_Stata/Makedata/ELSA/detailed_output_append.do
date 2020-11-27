/* Appending data from detailed output for further analysis */

quietly include ../../../fem_env.do

local scen: env scen

* Number of reps (Will change when running expts properly, set at 100 or 200)
local maxrep 10

* locals for start and stop year
if "`scen'" == "CV2" {
	local minyr 2010
	local maxyr 2016
}

#d ;
local scenarios
ELSA_`scen'

;
#d cr

* clear dataset
clear all

* append all of the simulations
forvalues yr = `minyr' (2) `maxyr' {
	
	forvalues rep = 1/`maxrep' {
	
		append using $output_dir/ELSA_`scen'/detailed_output/y`yr'_rep`rep'.dta
		
	}
}

* save the appended files
save $output_dir/ELSA_`scen'/ELSA_`scen'_append.dta, replace


capture log close
