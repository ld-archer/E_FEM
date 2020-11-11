clear

log using generate_stock_pop.log, replace

quietly include ../../../fem_env.do

local in_file "ELSA_long"

local out_file : env OUTPUT

use $outdata/ELSA_long.dta, clear
*use ../../../input_data/ELSA_long.dta, clear

* Keep respondents in wave 6
keep if wave == 6
gen entry = 2012 /* First wave is 2002 so 6th is 2012 */

* Make sure no l2smkstat variables are missing (otherwise CrossSectionalModule/summary_output breaks(?))
replace l2smkstat = smkstat if missing(l2smkstat) & !missing(smkstat)
codebook l2smkstat
*drop if missing(l2smkstat)

* Drop the deceased - TO DO: Fix this, as we want deceased in first year of simulation
drop if died == 1

replace l2age = age - 2 if missing(l2age)

saveold $outdata/ELSA_stock_base_noImpute.dta, replace v(12)

*** KLUDGE ***
do kludge.do

* Save the file
saveold $outdata/ELSA_stock_base.dta, replace v(12)
*saveold ../../../input_data/ELSA_stock_base.dta, replace v(12)


capture log close
