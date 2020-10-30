/* kludge.do */

* Kludge section -  these are all variables that will be either eliminated from the simulation or developed in the data.

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
gen married = 0
gen l2married = married
gen single = 0
gen l2single = single
gen widowed = 0
gen l2widowed = widowed

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

* Drop cases if missing smkstat vars
*drop if missing(smkstat) & missing(l2smkstat)

* Handle health limits work missing values
* If missing, first try to infer from lagged value (is this a good idea?)
replace hlthlm = l2hlthlm if missing(hlthlm)
replace l2hlthlm = hlthlm if missing(l2hlthlm)
* If still missing, going to assume patient is either not currently 
* working (so can't say if health limited) or simply is not limited by health
* THIS COULD BE PROBLEMATIC, NEED TO UNDERSTAND WHY MISSING
replace hlthlm = 0 if missing(hlthlm)
replace l2hlthlm = 0 if missing(l2hlthlm)

gen flogbmi50 = l2logbmi

* Handle missing atotf data
replace atotf = l2atotf if missing(atotf) & !missing(l2atotf)
replace l2atotf = atotf if missing(l2atotf) & !missing(atotf)

* Handle missing itearn data
replace itearn = l2itearn if missing(itearn) & !missing(l2itearn)
replace l2itearn = itearn if missing(l2itearn) & !missing(itearn)

replace asthmae = l2asthmae if missing(asthmae) & !missing(l2asthmae)
replace l2asthmae = asthmae if missing(l2asthmae) & !missing(asthmae)
replace asthmae = 0 if missing(asthmae)
replace l2asthmae = 0 if missing(l2asthmae)

replace parkine = l2parkine if missing(parkine) & !missing(l2parkine)
replace l2parkine = parkine if missing(l2parkine) & !missing(parkine)

replace parkine = 0 if missing(parkine)
replace l2parkine = 0 if missing(l2parkine)

replace l2retemp = retemp if missing(l2retemp) & !missing(retemp)
replace retemp = l2retemp if missing(retemp) & !missing(l2retemp)
replace retemp = 0 if missing(retemp) & age < 65
replace retemp = 1 if missing(retemp) & age > 65
replace l2retemp = retemp if missing(l2retemp) & !missing(retemp)

replace exstat = l2exstat if missing(exstat)
replace l2exstat = exstat if missing(l2exstat)

replace exstat = 3 if missing(exstat)
replace l2exstat = 3 if missing(l2exstat)

replace exstat1 = l2exstat1 if missing(exstat1)
replace exstat2 = l2exstat2 if missing(exstat2)
replace exstat3 = l2exstat3 if missing(exstat3)

* Handle missing lagged exstat vars
replace l2exstat1 = exstat1 if missing(l2exstat1)
replace l2exstat2 = exstat2 if missing(l2exstat2)
replace l2exstat3 = exstat3 if missing(l2exstat3)


*** Cut from reshape_long to only impute these values for stock and repl population ***
** Part of trying to run FEM model with no imputation in transition model datasets. Only using COMPLETE CASES **
* Try to hotdeck all the chronic disease vars
* Removed: cancre diabe hearte hibpe lunge stroke arthre psyche
foreach var of varlist logbmi white {
    hotdeck `var' using hotdeck_data/`var'_imp, store seed(`seed') keep(_all) impute(1)
    use hotdeck_data/`var'_imp1.dta, clear
}

/*
* Try to handle missing drink and smoking data
* Removed: drink 
foreach var of varlist drinkd smoken smokev exstat {
    hotdeck `var' using hotdeck_data/`var'_imp, store seed(`seed') keep(_all) impute(1)
    use hotdeck_data/`var'_imp1.dta, clear
}
*/

* Now handle logical accounting with drinking and smoking
replace drinkd = 0 if drink == 0
replace smokev = 1 if smoken == 1

* Now replace lag with current if missing lag for all hotdecked vars
foreach var of varlist cancre diabe hearte hibpe lunge stroke arthre psyche {
    replace l2`var' = `var' if missing(l2`var')
}
foreach var of varlist drink drinkd smoken smokev exstat {
    replace l2`var' = `var' if missing(l2`var')
}

replace smkstat = 1 if smokev == 0 & smoken == 0 & missing(smkstat)
replace smkstat = 2 if smokev == 1 & smoken == 0 & missing(smkstat)
replace smkstat = 3 if smoken == 1 & missing(smkstat)

* Handle missing smkstat data
replace smkstat = l2smkstat if missing(smkstat)
replace l2smkstat = smkstat if missing(l2smkstat)

replace smkstat = 2 if missing(smkstat)
replace l2smkstat = 2 if missing(l2smkstat)

* Replace smoke_start and smoke_stop vars
replace smoke_start = 1 if l2smoken == 0 & smoken == 1 & missing(smoke_start)
replace smoke_start = 0 if l2smoken == 0 & smoken == 0 & missing(smoke_start)
replace smoke_stop = 1 if l2smoken == 1 & smoken == 0 & missing(smoke_stop)
replace smoke_stop = 0 if l2smoken == 1 & smoken == 1 & missing(smoke_stop)
replace smoke_start = 0 if missing(smoke_start)
replace smoke_stop = 0 if missing(smoke_stop)


* Update drinkd_stat after hotdecking
replace drinkd_stat = 1 if drinkd == 0
replace drinkd_stat = 2 if (drinkd == 1 | drinkd == 2)
replace drinkd_stat = 3 if (drinkd == 3 | drinkd == 4)
replace drinkd_stat = 4 if (drinkd == 5 | drinkd == 6 | drinkd == 7)

replace l2drinkd_stat = drinkd_stat if missing(l2drinkd_stat) & !missing(drinkd_stat)

* Now handle missing drinkd# data
replace drinkd1 = drinkd_stat==1 if missing(drinkd1)
replace drinkd2 = drinkd_stat==2 if missing(drinkd2)
replace drinkd3 = drinkd_stat==3 if missing(drinkd3)
replace drinkd4 = drinkd_stat==4 if missing(drinkd4)
replace l2drinkd1 = l2drinkd_stat==1 if missing(l2drinkd1)
replace l2drinkd2 = l2drinkd_stat==2 if missing(l2drinkd2)
replace l2drinkd3 = l2drinkd_stat==3 if missing(l2drinkd3)
replace l2drinkd4 = l2drinkd_stat==4 if missing(l2drinkd4)

* Handle missing education
