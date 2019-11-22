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

foreach var of varlist cancre diabe hearte hibpe lunge stroke arthre psyche {
    replace `var' = 0 if missing(`var')
    replace l2`var' = 0 if missing(l2`var')
}

replace l2age = age - 2 if missing(l2age)

* Save the file
saveold $outdata/ELSA_stock_base.dta, replace v(12)
*saveold ../../../input_data/ELSA_stock_base.dta, replace v(12)


*** Now prepare different stock files for different scenarios ***

* Increase the number of people doing moderate exercise
* var used is mdactx_e and has 4 levels:
* >1/week, 1/week, 1-3/month, hardly ever or never
* We will move 20% of people in 3 lowest bands up 1 level.
* Create random numbers from uniform distribution RELIC >
*gen rand_ex = runiform() if inrange(mdactx_e, 3, 5)
* Reduce mdactx_e by 1 in 30% of people 
* (i.e. increase exercise level by 1 in 30% of people exercising once a week or less) RELIC <
* Now just increasing exercise level of everybody by 1. i.e. shift everyone up a band
replace mdactx_e = mdactx_e - 1 if mdactx_e > 2
*drop rand_ex
* Save the file
saveold $outdata/ELSA_stock_exercise1.dta, replace v(12)
*saveold ../../../input_data/ELSA_stock_exercise1.dta, replace v(12)


use $outdata/ELSA_stock_base.dta, clear
*use ../../../input_data/ELSA_stock_base.dta, clear
* Decrease number of people who drink alcohol
* var is drink, binary
* Convert 20% of drinkers to non-drinkers
gen rand_drink = runiform() if drink==1
* Switch to non-drinkers in 20% of cases
replace drink = 0 if rand_drink < 0.4
drop rand_drink
* Save
saveold $outdata/ELSA_stock_drink.dta, replace v(12)
*saveold ../../../input_data/ELSA_stock_drink.dta, replace v(12)


use $outdata/ELSA_stock_base.dta, clear
*use ../../../input_data/ELSA_stock_base.dta, clear
* Decrease number of days/week people drink alcohol
* var is drinkd_e, has 8 levels
* Ranges from 0-7, for number of days/week
* Reduce every person by 1 (except 0 for obvious reasons)
replace drinkd_e = drinkd_e - 1 if drinkd_e > 0
saveold $outdata/ELSA_stock_drinkd_e.dta, replace v(12)
*saveold ../../../input_data/ELSA_stock_drinkd_e.dta, replace v(12)


use $outdata/ELSA_stock_base.dta, clear
*use ../../../input_data/ELSA_stock_base.dta, clear
* Decrease number of people who smoke at start of sim by 30%
gen rand_smoken = runiform() if smoken==1
replace smoken=0 if rand_smoken < 0.3
drop rand_smoken
saveold $outdata/ELSA_stock_smoken.dta, replace v(12)
*saveold ../../../input_data/ELSA_stock_smoken.dta, replace v(12)

capture log close
