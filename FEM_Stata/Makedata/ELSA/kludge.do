/* kludge.do */

* Kludge section -  these are all variables that will be either eliminated from the simulation or developed in the data.

* For earnings
gen iearnuc = 0
gen iearnx = 0

* handle missing work vals
replace work = 0 if missing(work)
replace l2work = work if missing(l2work)
replace l2work = 0 if missing(l2work)

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

* Smoking vars
replace smoken = 0 if missing(smoken)
replace l2smoken = 0 if missing(l2smoken)

replace smokev = 0 if missing(smokev)
replace l2smokev = 0 if missing(l2smokev)

* Medicare vars
gen mcare_pta = 0
gen mcare_ptb = 0
gen medicare_elig = 0

tab smkstat, missing
tab l2smkstat, missing

* Drop cases if missing smkstat vars
drop if missing(smkstat) & missing(l2smkstat)

tab smkstat, missing
tab l2smkstat, missing

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


* Handle missing retemp data
replace l2retemp = retemp if missing(l2retemp) & !missing(retemp)
replace retemp = l2retemp if missing(retemp) & !missing(l2retemp)

* Handle missing lag asthma data (if asthmae == 1 then l2asthmae must == 1 also)
replace l2asthmae = asthmae if missing(l2asthmae)
* Handle missing lag parkinson data, same as above
replace l2parkine = parkine if missing(l2parkine)


* Handle missing vgactx_e && mdactx_e data **THIS IS BAD!!!
replace l2vgactx_e = vgactx_e if missing(l2vgactx_e) & !missing(vgactx_e)
replace vgactx_e = l2vgactx_e if missing(vgactx_e) & !missing(l2vgactx_e)
replace l2mdactx_e = mdactx_e if missing(l2mdactx_e) & !missing(mdactx_e)
replace mdactx_e = l2mdactx_e if missing(mdactx_e) & !missing(l2mdactx_e)
* If still missing, replace with 'hardly ever or never'==5 (for exercise)
replace vgactx_e = 5 if missing(vgactx_e)
replace l2vgactx_e = 5 if missing(l2vgactx_e)
replace mdactx_e = 5 if missing(mdactx_e)
replace l2mdactx_e = 5 if missing(l2mdactx_e)

* Handle missing atotf data
replace atotf = l2atotf if missing(atotf) & !missing(l2atotf)
replace l2atotf = atotf if missing(l2atotf) & !missing(atotf)

* Handle missing itearn data
replace itearn = l2itearn if missing(itearn) & !missing(l2itearn)
replace l2itearn = itearn if missing(l2itearn) & !missing(itearn)

replace asthmae = l2asthmae if missing(asthmae) & !missing(l2asthmae)
replace l2asthmae = asthmae if missing(l2asthmae) & !missing(asthmae)

replace parkine = l2parkine if missing(parkine) & !missing(l2parkine)
replace l2parkine = parkine if missing(l2parkine) & !missing(parkine)

replace drinkd = l2drinkd if missing(drinkd) & !missing(l2drinkd)
replace l2drinkd = drinkd if missing(l2drinkd) & !missing(drinkd)

replace drinkd_stat = l2drinkd_stat if missing(drinkd_stat) & !missing(l2drinkd_stat)
replace l2drinkd_stat = drinkd_stat if missing(l2drinkd_stat) & !missing(drinkd_stat)

replace l2retemp = retemp if missing(l2retemp) & !missing(retemp)
replace retemp = l2retemp if missing(retemp) & !missing(l2retemp)
