/* Appending data from detailed output for further analysis */

quietly include ../../../fem_env.do

local scen: env scen

* Number of reps (Will change when running expts properly, set at 100 or 200)
local maxrep 10

* locals for start and stop year
if "`scen'" == "CV2" {
	local dir "COMPLETE"
	local minyr 2010
	local maxyr 2016
}
else if "`scen'" == "core_cohort" | "`scen'" == "core_remove_hearte_c" | "`scen'" == "core_remove_smoken" {
	local dir "SCENARIO"
	local minyr 2012
	local maxyr 2068
}
else if "`scen'" == "full" | "`scen'" == "alcInt_full" | "`scen'" == "cohort" | "`scen'" == "alcInt_cohort" {
	local dir "ALCOHOL"
	local minyr 2012
	local maxyr 2068
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
	
		append using $output_dir/`dir'/ELSA_`scen'/detailed_output/y`yr'_rep`rep'.dta
		
	}
}

* save the appended files
save $outdata/detailed_output/ELSA_`scen'_append.dta, replace
save $output_dir/`dir'/ELSA_`scen'/ELSA_`scen'_append.dta, replace


capture log close
