/* Generate the replenishing population */
clear all
quietly include ../../../fem_env.do

* This sets the scenario for use in naming files, trending variables, etc.
local scr : env SCENARIO

local goal : env GOAL

local expansion 1

local goal_yr : env GOAL_YR

clear all

*use ../../../input_data/ELSA_stock.dta, replace
use $outdata/ELSA_stock_base.dta, replace

* Keep respondents in wave 4
keep if year == 2012
keep if inlist(age, 51, 52)

*** Kludge section - fix these when we get the chance
*do kludge.do

foreach var of varlist cancre diabe hearte hibpe lunge stroke arthre psyche {
    replace `var' = 0 if missing(`var')
    replace l2`var' = 0 if missing(l2`var')
}

* Expand the sample based on expansion factor
*multiply_persons `expansion'

tempfile base_cohort
save `base_cohort'


* Generate cohorts for each year

forvalues yy = 2012 (2) 2060 {
    di "Year is `yy'"
    use `base_cohort', replace

    replace year = `yy'
    capture drop entry
    gen entry = `yy'

    * Deal with birth year, as that is how we derive age
    replace rbyr = rbyr + (`yy'-2012)

    * Need unique IDs for each person-year
    quietly {
        recast long hhid
        desc hhid*
        tostring hhid, gen(hhidstr) usedisplayformat
        tostring hhidpn, gen(hhidpnstr) usedisplayformat
  		drop hhid hhidpn
  		gen hhid = "-`yy'" + hhidstr
  		gen hhidpn = "-`yy'" + hhidpnstr
  		destring hhid hhidpn, replace
    }

    * Save the temporary files
    tempfile cohort_`yy'
    di "Tempfile is `cohort_`yy''"
    save "`cohort_`yy''"
}

clear

* Append the temporary files
forvalues yy = 2012 (2) 2060 {
    append using `cohort_`yy''
}

replace l2age = age - 2 if missing(l2age)

* Save the stacked new cohorts file
*saveold ../../../input_data/ELSA_repl_base.dta, replace v(12)
saveold $outdata/ELSA_repl_base.dta, replace v(12)


** Now prepare different repl files for different scenarios

* Increase number of people doing moderate exercise
* More full explanation of whats happening in generate_stock_pop.do
replace mdactx_e = mdactx_e - 1 if mdactx_e > 2
* Save the file
saveold $outdata/ELSA_repl_exercise1.dta, replace v(12)
*saveold ../../../input_data/ELSA_repl_exercise1.dta, replace v(12)


use $outdata/ELSA_repl_base.dta, clear
*use ../../../input_data/ELSA_repl_base.dta, clear
* Decrease number of people who drink alcohol
* var is drink, binary
* Convert 40% of drinkers to non-drinkers
gen rand_drink = runiform() if drink==1
* Switch to non-drinkers in 40% of cases
replace drink = 0 if rand_drink < 0.4
drop rand_drink
* Save
saveold $outdata/ELSA_repl_drink.dta, replace v(12)
*saveold ../../../input_data/ELSA_repl_drink.dta, replace v(12)


use $outdata/ELSA_repl_base.dta, clear
*use ../../../input_data/ELSA_repl_base.dta, clear
* Decrease number of days/week people drink alcohol
* var is drinkd, has 8 levels
* Ranges from 0-7, for number of days/week
* Reduce every person by 1 (except 0 for obvious reasons)
replace drinkd = drinkd - 1 if drinkd > 0
saveold $outdata/ELSA_repl_drinkd.dta, replace v(12)
*saveold ../../../input_data/ELSA_repl_drinkd.dta, replace v(12)


use $outdata/ELSA_repl_base.dta, clear
*use ../../../input_data/ELSA_repl_base.dta, clear
* Decrease number of people who smoke at start of sim by 30%
gen rand_smoken = runiform() if smoken==1
replace smoken=0 if rand_smoken < 0.3
drop rand_smoken
saveold $outdata/ELSA_repl_smoken.dta, replace v(12)
*saveold ../../../input_data/ELSA_repl_smoken.dta, replace v(12)

capture log close

