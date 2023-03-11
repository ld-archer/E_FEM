/* kludge.do */

* Kludge section -  these are all variables that will be either eliminated from the simulation or developed in the data.

* Set up var for deciding between base, CV1/CV2, min
local scen `1'

* For earnings
gen iearnuc = 0
gen iearnx = 0

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

save $outdata/test_pre_hotdeck.dta, replace

*** ELSA Specific Imputation ***

if "`scen'" == "base" {
    local hotdeck_vars logbmi white itot educl cancre hibpe diabe hearte stroke ///
                        smokev lunge lnly sociso workstat alzhe arthre asthmae demene parkine psyche ///
                        smoken hchole smokef alcfreq logatotb logitot hhres socyr gcareinhh1w ///
                        angine hrtatte conhrtfe hrtmre hrtrhme catracte osteoe physact
}
else if "`scen'" == "CV1" |  {
    local hotdeck_vars logbmi white cancre hibpe diabe hearte stroke smokev lunge smoken arthre ///
                        psyche asthmae parkine itot educl alcfreq logatotb logitot hhres socyr gcareinhh1w ///
                        angine hrtatte conhrtfe hrtmre hrtrhme catracte osteoe lnly sociso physact
}
else if "`scen'" == "CV2" {
    local hotdeck_vars logbmi white cancre hibpe diabe hearte stroke smokev lunge smoken arthre ///
                        psyche asthmae parkine itot hchole hipe educl logatotb logitot hhres socyr gcareinhh1w ///
                        mstat lnly sociso alzhe demene workstat smokef ///
                        angine hrtatte conhrtfe hrtmre hrtrhme catracte osteoe alcfreq physact
}
else if "`scen'" == "min" {
    local hotdeck_vars logbmi white cancre hibpe diabe hearte stroke smokev lunge smoken arthre ///
                        psyche asthmae parkine itot hchole hipe educl logatotb logitot hhres socyr gcareinhh1w ///
                        lnly sociso alzhe demene workstat smokef ///
                        angine hrtatte conhrtfe hrtmre hrtrhme catracte osteoe alcfreq physact
}
else if "`scen'" == "valid" {
    local hotdeck_vars logbmi educl cancre hibpe diabe hearte stroke smokev ///
                        lunge smoken itot lnly sociso workstat alzhe arthre asthmae demene ///
                        parkine psyche hipe hchole smokef logatotb logitot hhres socyr gcareinhh1w ///
                        angine hrtatte conhrtfe hrtmre hrtrhme catracte osteoe alcfreq physact
}
else if "`scen'" == "ROC" {
    local hotdeck_vars lnly sociso logbmi white cancre hibpe diabe hearte stroke smokev lunge smoken arthre ///
                        psyche asthmae parkine itot educl workstat alzhe demene logatotb logitot hhres socyr gcareinhh1w ///
                        hchole hipe angine hrtatte conhrtfe hrtmre hrtrhme catracte osteoe alcfreq
}
else {
    di "Something has gone wrong with kludge.do, this error should not be reachable"
}

* Current vars missing info should be hotdecked before any other imputation
foreach var of varlist `hotdeck_vars' {
    hotdeck `var' using hotdeck_data/`var'_imp, store seed(`seed') keep(_all) impute(1)
    use hotdeck_data/`var'_imp1.dta, clear
}

save $outdata/test_post_hotdeck.dta, replace

* Handle missing srh data (~400 without srh data). Set to 3 (good) if still missing, median
replace srh = 3 if missing(srh)
replace srh3 = 1 if missing(srh1, srh2, srh3, srh4, srh5)
replace srh1 = 0 if srh3 == 1
replace srh2 = 0 if srh3 == 1
replace srh4 = 0 if srh3 == 1
replace srh5 = 0 if srh3 == 1

* Impute some vars by simply copying lag to current and/or vice versa
foreach var of varlist  asthmae parkine physact cancre diabe hearte hibpe ///
                        lunge stroke arthre psyche drink smoken smokev hchole srh1 srh2 ///
                        srh3 srh4 srh5 hipe mstat alzhe demene employed inactive ///
                        retired logatotb logitot hhres socyr gcareinhh1w ///
                        angine hrtatte conhrtfe hrtmre hrtrhme catracte osteoe lnly sociso {
                            
    replace `var' = l2`var' if missing(`var') & !missing(l2`var')
    replace l2`var' = `var' if missing(l2`var') & !missing(`var')
}

* Some lags still missing info
foreach var of varlist arthre asthmae cancre diabe hearte hibpe lunge psyche stroke parkine alzhe demene {
    replace l2`var' = 0 if missing(`var') & missing(l2`var')
}

replace mstat = 1 if missing(mstat)
replace l2mstat = 1 if missing(l2mstat)

* Need to refill the mstat dummies after imputing
replace married = mstat == 1
replace single = mstat == 2
replace cohab = mstat == 3
replace widowed = mstat == 4
replace l2married = l2mstat == 1
replace l2single = l2mstat == 2
replace l2cohab = l2mstat == 3
replace l2widowed = l2mstat == 4

* Handle missing values for white (only 2 missing in ageUK valid stock population)
if "`scen'" == "valid" {
    replace white = 1 if missing(white)
}

** Handle missing lnly values if STILL missing after hotdecking and assigning lag to current and vice versa
* Not hotdecking or assigning properly, or something else wrong with minimal population
* Almost 50% of ELSA_long are lnly == 1, so seems fair to assign this
replace lnly = 1 if missing(lnly)
replace l2lnly = lnly if missing(l2lnly)
replace lnly1 = 1 if lnly == 1
replace l2lnly1 = 1 if l2lnly == 1
** PROBLEM WASNT WITH MISSING DATA, just missing model definition in covariate definitions for minimal

* New chronic disease vars
replace angine = 0 if missing(angine)
replace l2angine = 0 if missing(l2angine)
replace catracte = 0 if missing(catracte)
replace l2catracte = 0 if missing(l2catracte)
replace conhrtfe = 0 if missing(conhrtfe)
replace l2conhrtfe = 0 if missing(l2conhrtfe)
replace hrtatte = 0 if missing(hrtatte)
replace l2hrtatte = 0 if missing(l2hrtatte)
replace hrtmre = 0 if missing(hrtmre)
replace l2hrtmre = 0 if missing(l2hrtmre)
replace hrtrhme = 0 if missing(hrtrhme)
replace l2hrtrhme = 0 if missing(l2hrtrhme)
replace osteoe = 0 if missing(osteoe)
replace l2osteoe = 0 if missing(l2osteoe)


* Still missing atotb, so impute with mean
quietly summ logatotb
replace logatotb = r(mean) if missing(logatotb)
replace l2logatotb = logatotb if missing(l2logatotb) & !missing(logatotb)
* Same for itot
quietly summ logitot
replace logitot = r(mean) if missing(logitot)
replace l2logitot = logitot if missing(l2logitot) & !missing(logitot)

*replace logatotb = log(atotb) if missing(logatotb)
*replace l2logatotb = log(l2atotb) if missing(l2logatotb)
*replace logitot = log(itot) if missing(logitot)
*replace l2logitot = log(l2itot) if missing(l2logitot)

* Still missing some hchole
replace hchole = 0 if missing(hchole)
replace l2hchole = 0 if missing(l2hchole)

* Now replace any missing lag with current, and assign the lag as the value for flogbmi50
replace l2logbmi = logbmi if missing(l2logbmi) & !missing(logbmi)
gen flogbmi50 = l2logbmi

* Now handle logical accounting with drinking and smoking
*replace drinkd = 0 if drink == 0
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

* Impute old 'work' variable with employed, just to keep the model happy
* ELSA version doesn't use 'work' anymore
gen work = employed if !missing(employed)
gen l2work = l2employed if !missing(l2employed)

