clear

log using gen_CV_stock.log, replace

quietly include ../../../fem_env.do

local in_file "ELSA_long"

local out_file : env OUTPUT

use $outdata/ELSA_long.dta, clear
*use ../../../input_data/ELSA_long.dta, clear

* Keep respondents from wave 4, but set entry as 2002 for cross-validation
keep if wave == 3
gen entry = 2002

* Make sure no l2smkstat variables are missing (otherwise CrossSectionalModule/summary_output breaks(?))
replace l2smkstat = smkstat if missing(l2smkstat) & !missing(smkstat)
codebook l2smkstat
*drop if missing(l2smkstat)

* Drop the deceased - TO DO: Fix this, as we want deceased in first year of simulation
drop if died == 1

replace l2age = age - 2 if missing(l2age)

*** KLUDGE ***
do kludge_CV.do

* merge on transition ID for cross-validation
merge m:1 idauniq using "$outdata/cross_validation/crossvalidation.dta", keepusing(simulation)
tab _merge
drop if _m==2
drop _merge

keep if simulation == 1

saveold $outdata/ELSA_stock_base_CV.dta, replace v(12)
*saveold ../../../input_data/ELSA_stock_base_CV.dta, replace v(12)