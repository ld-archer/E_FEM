clear

log using generate_stock_pop.log, replace

quietly include ../../../fem_env.do

local in_file "ELSA_long"

local out_file : env OUTPUT

use $outdata/ELSA_long.dta, clear
*use ../../../input_data/ELSA_long.dta, clear


* Let's drop a couple of vars we don't need from the data
drop iwindm iwindy rand


*** Need to produce multiple stock populations for cross-validation
preserve

* Keep respondents in wave 6
keep if wave == 6
gen entry = 2012 /* First wave is 2002 so 6th is 2012 */

* Drop the deceased - TO DO: Fix this, as we want deceased in first year of simulation
drop if died == 1

replace l2age = age - 2 if missing(l2age)

saveold $outdata/ELSA_stock_preImpute.dta, replace v(12)

*** KLUDGE ***
do kludge.do base

* Save the file
saveold $outdata/ELSA_stock_base.dta, replace v(12)
*saveold ../../../input_data/ELSA_stock_base.dta, replace v(12)


*** Now generate minimal population
restore
preserve

* Keep from wave 1?
keep if wave == 1
gen entry = 2002

* Drop deceased
drop if died == 1

replace l2age = age - 2 if missing(l2age)

*** KLUDGE ***
do kludge.do min

* Save data file
saveold $outdata/ELSA_stock_base_min.dta, replace v(12)

* Create a datafile with just idauniq & flag == 1. Use this to select the correct population in T-tests (minimal)
keep idauniq 
gen flag = 1
saveold $outdata/ELSA_stock_min_flag.dta, replace v(12)

*** Now generate cross-validation population 1 (CV1)
restore
preserve

* For CV1 pop:
*   Keep wave 4
*   Do processing and kludge.do
*   Merge with crossvalidation.dta (keepusing simulation))
*   Keep only simulation == 1
*   Save pop for re-weighting

* Keep respondents from wave 3, but set entry as 2002 for cross-validation
keep if wave == 2
gen entry = 2002

* Drop the deceased - TO DO: Fix this, as we want deceased in first year of simulation
drop if died == 1

replace l2age = age - 2 if missing(l2age)

*** KLUDGE ***
do kludge.do CV1

* merge on transition ID for cross-validation
merge m:1 idauniq using "$outdata/cross_validation/crossvalidation.dta", keepusing(simulation)
tab _merge
drop if _m==2
drop _merge

keep if simulation == 1

saveold $outdata/ELSA_stock_base_CV1.dta, replace v(12)
*saveold ../../../input_data/ELSA_stock_base_CV.dta, replace v(12)


*** Now cross-validation population 2 (CV2)
restore
preserve

* For CV2 pop:
*   Keep wave 5
*   Do processing and kludge.do
*   Save pop for re-weighting

* Keep respondents from wave 5, and set entry as 2010 for cross-validation
keep if wave == 5
gen entry = 2010

* Drop the deceased - TO DO: Fix this, as we want deceased in first year of simulation
drop if died == 1

replace l2age = age - 2 if missing(l2age)

*** KLUDGE ***
do kludge.do CV2

saveold $outdata/ELSA_stock_base_CV2.dta, replace v(12)
*saveold ../../../input_data/ELSA_stock_base_CV2.dta, replace v(12)

*** Now AgeUK Validation sim
restore

keep if wave == 3
gen entry = 2006

drop if died == 1

replace l2age = age - 2 if missing(l2age)

*** KLUDGE ***
do kludge.do valid

saveold $outdata/ELSA_stock_base_valid.dta, replace v(12)

capture log close
