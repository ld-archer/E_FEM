* This script will calculate the prevalence of disability in both the baseline
* case and in any intervention case, then compare

clear

log using disability_prev_comparison.log, replace

***** Number of reps
local maxrep 10

local minyr 2012
local maxyr 2060

#d ;
local diseases
cancre
diabe
hearte
;

#d cr

use ../../output/ELSA_Baseline/ELSA_Baseline_by_rep.dta, clear

codebook a_anyadl_all a_anyiadl_all

*tab a_anyadl_all rep

*tab a_anyiadl_all rep


capture log close
