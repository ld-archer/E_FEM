clear
clear mata
set more off
set seed 5243212
set maxvar 10000
cap log close

include "../../../fem_env.do"
global wkdir $local_path/Makedata/PSID

*Store intermediate files
cap mkdir "$wkdir/Output"
global temp_dir "$wkdir/Output"



log using "PSID_script.log", replace text



* Extract the economic variables
do "$wkdir/psid_fam_extract.do" 

* Recode economic variables
do "$wkdir/psid_fam_recode.do" 

* Extract variables from individual file
do "$wkdir/psid_ind_extract.do" 

* Extract and rename variables from the wealth file
do "$wkdir/psid_wealth_extract.do" 


* Merge all of the economic files together
do "$wkdir/psid_econ_merge.do" 

* Recode/rename merged file
do "$wkdir/psid_econ_recode.do" 


* Generate the master analytic file
do "gen_analytic.do"

* Generate the transition file
do "gen_psid_transition.do"

* Generate the 2009 file for the simulation
do "gen_simul2009.do"

* Generate the 25-30 files for new cohort estimation/generation
do "gen_age2530.do"

capture log close