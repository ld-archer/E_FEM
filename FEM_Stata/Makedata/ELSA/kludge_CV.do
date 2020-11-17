/* kludge_CV.do */

* For earnings
gen iearnuc = 0
gen iearnx = 0

* handle missing work vals
replace work = 0 if missing(work) & age > 65
replace work = 1 if missing(work) & age < 65
replace l2work = work if missing(l2work)
replace l2work = 0 if missing(l2work) & age > 67
replace l2work = 1 if missing(l2work) & age > 67

* For marital status
*gen married = 0
*gen l2married = married
*gen single = 0
*gen l2single = single
*gen widowed = 0
*gen l2widowed = widowed

* for nursing home status
gen nhmliv = 0

* Race dummies
gen black = 0
gen hispan = 0

* Defined-benefit pension dummy
gen fanydb = 0
gen dbclaim = 0

* for wealth
gen wlth_nonzero = 0
gen l2wlth_nonzero = 0
gen loghatotax = 0
gen l2loghatotax = 0

* Disease status prior to starting HRS survey
foreach var in canc diabe heart hibp lung strok {
                gen f`var'50 = 0
}

* Smoking status before starting survey
gen fsmokev = 0
gen fsmoken50 = 0
 
* Claiming Supplemental Security benefits (US specific)
gen ssiclaim = 0
gen l2ssiclaim = 0

* Claiming Federal Disability benefits (US specific)
gen diclaim = 0
gen l2diclaim = 0

* Claiming Social Security retirement benefits (US specific)
gen ssclaim = 0
gen l2ssclaim = 0

* Property taxes
gen proptax_nonzero = 0
gen l2proptax_nonzero = 0

* Hours cared for grandchildren
gen gkcarehrs = 0
gen l2gkcarehrs = 0

* Capital income
gen hicap = 0
gen l2hicap = 0
gen hicap_nonzero = 0
gen l2hicap_nonzero = 0

* Government transfers (US specific)
gen igxfr_nonzero = 0

* Another birthyear variable (used in simulation)
gen frbyr = rbyr

* Fill in all zeroes here.  This will be imputed in the simulation
drop if died==1
drop if missing(age)
gen rbmonth = 7

* Medicare vars
gen mcare_pta = 0
gen mcare_ptb = 0
gen medicare_elig = 0

hotdeck logbmi using hotdeck_data/logbmi_imp, store seed(`seed') keep(_all) impute(1)
use hotdeck_data/logbmi_imp1.dta, clear

*foreach var of varlist logbmi {
*    hotdeck `var' using hotdeck_data/`var'_imp, store seed(`seed') keep(_all) impute(1)
*    use hotdeck_data/`var'_imp1.dta, clear
*}

* Now handle missing drinkd# data
replace drinkd1 = drinkd_stat==1 if missing(drinkd1)
replace drinkd2 = drinkd_stat==2 if missing(drinkd2)
replace drinkd3 = drinkd_stat==3 if missing(drinkd3)
replace drinkd4 = drinkd_stat==4 if missing(drinkd4)
replace l2drinkd1 = l2drinkd_stat==1 if missing(l2drinkd1)
replace l2drinkd2 = l2drinkd_stat==2 if missing(l2drinkd2)
replace l2drinkd3 = l2drinkd_stat==3 if missing(l2drinkd3)
replace l2drinkd4 = l2drinkd_stat==4 if missing(l2drinkd4)

replace drink = 1 if missing(drink)
replace drink = 0 if drinkd == 1

* Now replace lag with current if missing lag for all hotdecked vars
foreach var of varlist arthre asthmae cancre diabe drink hearte hibpe lunge parkine psyche retemp smoken smokev stroke exstat1 exstat2 exstat3 {
    replace l2`var' = `var' if missing(l2`var') & !missing(`var')
}

replace l2retemp = 1 if l2work == 0 & l2age > 65
replace l2retemp = 0 if l2work == 1 | l2age < 65

replace smoken = l2smoken if missing(smoken) & !missing(l2smoken)
replace l2smoken = smoken if missing(l2smoken) & !missing(smoken)
replace smoken = 0 if missing(smoken)
replace l2smoken = 0 if missing(l2smoken)

replace smokev = l2smokev if missing(smokev) & !missing(l2smokev)
replace l2smokev = smokev if missing(l2smokev) & !missing(smokev)
replace smokev = 0 if missing(smokev)
replace l2smokev = 0 if missing(l2smokev)

replace smkstat = 1 if smokev == 0 & smoken == 0 & missing(smkstat)
replace smkstat = 2 if smokev == 1 & smoken == 0 & missing(smkstat)
replace smkstat = 3 if smoken == 1 & missing(smkstat)
