clear

*log using generate_stock_pop.log, replace

quietly include ../../fem_env.do

use $outdata/cross_validation/CV_long.dta, clear
*use ../../../input_data/cross_validation/CV_long.dta, clear

* Keep respondents in wave 6
keep if wave == 3
gen entry = 2006 /* First wave is 2002 so 3rd is 2006 */

* Make sure no l2smkstat variables are missing (otherwise CrossSectionalModule/summary_output breaks(?))
replace l2smkstat = smkstat if missing(l2smkstat) & !missing(smkstat)
codebook l2smkstat
drop if missing(l2smkstat)

* Drop the deceased - TO DO: Fix this, as we want deceased in first year of simulation
drop if died == 1

*** KLUDGE ***
do ../../FEM_Stata/Makedata/ELSA/kludge.do

foreach var of varlist cancre diabe hearte hibpe lunge stroke arthre psyche {
    replace `var' = 0 if missing(`var')
    replace l2`var' = 0 if missing(l2`var')
}

replace l2age = age - 2 if missing(l2age)

* Save the file
saveold $outdata/cross_validation/CV_stock_base.dta, replace v(12)
*saveold ../../../input_data/cross_validation/CV_stock_base.dta, replace v(12)
