/*

This script is part of the non-parametric bootstrapping of the English FEM.

The script uses the built-in Stata package bsample to generate multiple samples from the 
ELSA_transition.dta dataset, and runs each sample through the ELSA_init_transition.do script 
to generate transition models and save them into the corresponding folder.

*/

* Get environment vars
quietly include ../../fem_env.do


local maxbsamp: env MAXBREP
*local defmod: env SUFFIX

*log using "./bootstrap_logs/ELSA_init_transition_bootstrap`bsamp'_`defmod'.log", replace

use $outdata/ELSA_transition.dta

* We have 10 strata in random_strata, so use 9 bsample's

display "The display function is working correctly!"

display `maxbsamp'
local defmod = "core"

forvalues i = 1/`maxbsamp' {

    log using "./bootstrap_logs/ELSA_init_transition_bootstrap`i'_`defmod'.log", replace

    di `i'

    *bsample, strata(random_strata)

    *count

    local bsamp = `i'

    do ELSA_init_transition.do `bsamp' `defmod'
}