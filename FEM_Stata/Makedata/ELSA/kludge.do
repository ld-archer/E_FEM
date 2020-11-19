/* kludge.do */

* Kludge section -  these are all variables that will be either eliminated from the simulation or developed in the data.

* Set up var for deciding between base and CV1/CV2 
local scen `1'

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

if "`scen'" == "base" {
    local hotdeck_vars logbmi white
}
else if "`scen'" == "CV1" |  {
    local hotdeck_vars logbmi white work cancre hibpe diabe hearte stroke smokev lunge smoken arthre psyche asthmae parkine atotf drinkd ipubpen itearn retage /*smokef*/
}
else if "`scen'" == "CV2" {
    local hotdeck_vars logbmi white work cancre hibpe diabe hearte stroke smokev lunge smoken arthre psyche asthmae parkine atotf drinkd ipubpen itearn retage hchole hipe /*smokef*/
}
else {
    di "Something has gone wrong with kludge.do, this error should not be reachable"
}

*** ELSA Specific Imputation ***
* Current vars missing info should be hotdecked before any other imputation
* Removed: cancre diabe hearte hibpe lunge stroke arthre psyche
foreach var of varlist `hotdeck_vars' {
    hotdeck `var' using hotdeck_data/`var'_imp, store seed(`seed') keep(_all) impute(1)
    use hotdeck_data/`var'_imp1.dta, clear
}

* Impute some vars by simply copying lag to current and/or vice versa
foreach var of varlist atotf itearn asthmae parkine retemp exstat cancre diabe hearte hibpe lunge stroke arthre psyche drink drinkd smoken smokev hchole {
    replace `var' = l2`var' if missing(`var') & !missing(l2`var')
    replace l2`var' = `var' if missing(l2`var') & !missing(`var')
}

* Some lags still missing info
foreach var of varlist arthre asthmae cancre diabe hearte hibpe lunge psyche stroke parkine {
    replace l2`var' = 0 if missing(`var') & missing(l2`var')
}

* Retemp slightly more complicated
replace retemp = 0 if missing(retemp) & age <= 65
replace retemp = 1 if missing(retemp) & age > 65
replace l2retemp = retemp if missing(l2retemp) & !missing(retemp)
replace l2retemp = 0 if missing(l2retemp) & age <= 67
replace l2retemp = 1 if missing(l2retemp) & age > 67
* Exstat more complicated still due to dummy variables
* Exstat == 3 is most common value, 3 is moderate/heavy exercise more than once a week
replace exstat = 3 if missing(exstat)
replace l2exstat = 3 if missing(l2exstat)
replace exstat1 = l2exstat1 if missing(exstat1)
replace exstat2 = l2exstat2 if missing(exstat2)
replace exstat3 = l2exstat3 if missing(exstat3)
* Handle missing lagged exstat vars
replace l2exstat1 = exstat1 if missing(l2exstat1)
replace l2exstat2 = exstat2 if missing(l2exstat2)
replace l2exstat3 = exstat3 if missing(l2exstat3)

* Now replace any missing lag with current, and assign the lag as the value for flogbmi50
replace l2logbmi = logbmi if missing(l2logbmi) & !missing(logbmi)
gen flogbmi50 = l2logbmi

* Now handle logical accounting with drinking and smoking
replace drinkd = 0 if drink == 0
replace smokev = 1 if smoken == 1

* Still missing some l2drink
replace drink = 1 if missing(drink)
replace l2drink = 1 if missing(l2drink)
* Still missing 2 l2smoken
replace l2smoken = 0 if missing(l2smoken)
* Missing 140 odd l2smokev
replace l2smokev = 0 if missing(l2smokev)

* Replace smoke_start and smoke_stop vars
replace smoke_start = 1 if l2smoken == 0 & smoken == 1 & missing(smoke_start)
replace smoke_start = 0 if l2smoken == 0 & smoken == 0 & missing(smoke_start)
replace smoke_stop = 1 if l2smoken == 1 & smoken == 0 & missing(smoke_stop)
replace smoke_stop = 0 if l2smoken == 1 & smoken == 1 & missing(smoke_stop)
replace smoke_start = 0 if missing(smoke_start)
replace smoke_stop = 0 if missing(smoke_stop)

* Handle missing smkstat data
replace smkstat = 1 if smokev == 0 & smoken == 0 & missing(smkstat)
replace smkstat = 2 if smokev == 1 & smoken == 0 & missing(smkstat)
replace smkstat = 3 if smoken == 1 & missing(smkstat)
replace smkstat = l2smkstat if missing(smkstat)
replace l2smkstat = smkstat if missing(l2smkstat)
replace smkstat = 2 if missing(smkstat)
replace l2smkstat = 2 if missing(l2smkstat)

* Update drinkd_stat after hotdecking
replace drinkd_stat = 1 if drinkd == 0
replace drinkd_stat = 2 if (drinkd == 1 | drinkd == 2)
replace drinkd_stat = 3 if (drinkd == 3 | drinkd == 4)
replace drinkd_stat = 4 if (drinkd == 5 | drinkd == 6 | drinkd == 7)
* Set to low - moderate if still missing
replace drinkd_stat = 2 if missing(drinkd_stat)

* Now handle missing drinkd# data
replace drinkd1 = drinkd_stat==1 if missing(drinkd1)
replace drinkd2 = drinkd_stat==2 if missing(drinkd2)
replace drinkd3 = drinkd_stat==3 if missing(drinkd3)
replace drinkd4 = drinkd_stat==4 if missing(drinkd4)
replace l2drinkd1 = l2drinkd_stat==1 if missing(l2drinkd1)
replace l2drinkd2 = l2drinkd_stat==2 if missing(l2drinkd2)
replace l2drinkd3 = l2drinkd_stat==3 if missing(l2drinkd3)
replace l2drinkd4 = l2drinkd_stat==4 if missing(l2drinkd4)

