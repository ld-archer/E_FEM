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
drop if missing(l2smkstat)

* Drop the deceased - TO DO: Fix this, as we want deceased in first year of simulation
drop if died == 1

*** KLUDGE ***
do kludge.do

/*
foreach var of varlist cancre diabe hearte hibpe lunge stroke arthre psyche {
    replace `var' = 0 if missing(`var')
    replace l2`var' = 0 if missing(l2`var')
}
*/

replace l2age = age - 2 if missing(l2age)

* Save the file
saveold $outdata/ELSA_stock_base.dta, replace v(12)
*saveold ../../../input_data/ELSA_stock_base.dta, replace v(12)

* Preserve the data so we can create a couple of variants
preserve

* merge on transition ID for cross-validation
merge m:1 idauniq using "$outdata/cross_validation/crossvalidation.dta", keepusing(simulation)
tab _merge
drop if _m==2
drop _merge

keep if simulation == 1

saveold $outdata/ELSA_stock_base_CV.dta, replace v(12)
*saveold ../../../input_data/ELSA_stock_base_CV.dta, replace v(12)


* Restore and preserve again to generate new pops
restore
preserve

* Now generate non-smoking and non-drinking populations to run the risk assessment scenarios
* Non-smoking
replace smoken = 0
replace l2smoken = 0
replace smoke_start = 0
replace smoke_stop = 0
replace smokef = 0
replace l2smokef = 0
saveold $outdata/ELSA_stock_base_nosmoke.dta, replace v(12)

* Restore original and do the next one
restore

* Non-drinking
replace drink = 0
replace l2drink = 0
replace drinkd = 0
replace l2drinkd = 0
replace drinkd_stat = 1 /* drinkd_stat == 1 is teetotal */
replace l2drinkd_stat = 1
replace drinkd1 = 1
replace l2drinkd1 = 1
replace drinkd2 = 0
replace l2drinkd2 = 0
replace drinkd3 = 0
replace l2drinkd3 = 0
replace drinkd4 = 0
replace l2drinkd4 = 0
saveold $outdata/ELSA_stock_base_nodrink.dta, replace v(12)



capture log close







