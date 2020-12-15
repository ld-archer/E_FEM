/* Generate the replenishing population */
clear all
quietly include ../../../fem_env.do

* This sets the scenario for use in naming files, trending variables, etc.
local scen : env scen

local expansion 1

clear all

*use ../../../input_data/ELSA_stock.dta, replace
use $outdata/ELSA_stock_base.dta, replace
*use $outdata/ELSA_long.dta, replace


* Keep respondents in wave 6
keep if inlist(year, 2010, 2012, 2014)
keep if inlist(age, 51, 52)
* Fix birth year variable for additional input years
replace rbyr = rbyr + 2 if year == 2010
replace rbyr = rbyr - 2 if year == 2014

/*
* Keep respondents in wave 6
keep if year == 2012
keep if inlist(age, 51, 52)
*/

*** Kludge section - fix these when we get the chance
*do kludge.do

/*
foreach var of varlist cancre diabe hearte hibpe lunge stroke arthre psyche {
    replace `var' = 0 if missing(`var')
    replace l2`var' = 0 if missing(l2`var')
}
*/

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


capture log close
