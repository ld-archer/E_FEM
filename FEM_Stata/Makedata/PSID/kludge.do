/* These variables are all place-holders.  I'm generating them to get the simulation to run. */

#d ;
local placeholders dbclaim htcamt nhmliv rdb_na_2 rdb_na_3 rdb_na_4 rdb_ea_2 rdb_ea_3 logdcwlthx iearnuc
	logaime logq raime rq painstat
;

#d cr

foreach var of local placeholders {
	gen `var' = 0
	gen l2`var' = 0
	gen f`var' = 0
	label var `var' "Placeholder"
	label var l2`var' "Lag Placeholder"
	label var f`var' "Initial Condition Placeholder"
}



/* **************   KLUDGES FOR MISSING VARIABLES  ************** */
*replace black = 0 if black == .			/* set race to other if missing */
*replace hispan = 0 if hispan == .			/* set hispan to 0 if missing */
replace logbmi = 3.310685 if logbmi == .			/* impute totalheight and weight with averages, set bmi to 2009 mean if missing */
replace flogbmi = 3.310685 if flogbmi == .
gen fkids = 0
gen kid_byravg = 0
gen helphoursyr_sp = 0
gen helphoursyr_nonsp = 0
gen nra = 0
gen era = 0
gen educ = 0
*replace childses = 2 if childses == .			/* set childses to 2 if missing */

*replace lage = age-2 if lage == .			/* impute age if missing */


/* More kludges to deal with missing initial variables  iadlstat is only measured from 2003-present.  Consequently, fiadlstat is missing for many */
/* 
	 hearte - include heart attack, fill forward if hearte = 1, fill backward if hearte = 0, set hearte to 0 if still missing 
	 stroke - fill forward if stroke = 1, fill backward if stroke = 0, set stroke to 0 if still missing 
	 cancre - same as stroke
	 hibpe - same as stroke 
	 diabe - same as stroke 
	 lunge - same as stroke 
	 smokev - same as stroke
	 smoken - same as stroke
	 widowed - impute marriage status using change in marrital status, fill forward, fill backward, set to single if still missing
	 single - see widowed
	 married - see widowed
	 adlstat - fill forward, fill backward, set to single if still missing 
	 iadlstat - fill forward, fill backward, set to single if still missing
*/

local kludgevars1 anydb anydc hearte stroke cancre hibpe diabe lunge smokev smoken widowed single married work iearnx logiearnx hatota loghatotax shlt diclaim ssiclaim oasiclaim db_tenure wlth_nonzero bmi logbmi workstat workstat_alt inlaborforce hatotax
* local kludgevars1 anydb anydc work iearnx logiearnx hatota loghatotax shlt diclaim ssiclaim oasiclaim db_tenure wlth_nonzero
foreach v in `kludgevars1' {
	di "`v' is missing this many times:"
	count if `v' == . & hdwf == 1 & inyr == 1
	replace `v' = 0 if `v' == .
	di "f`v' is missing this many times:"
	count if f`v' == . & hdwf == 1 & inyr == 1
	replace f`v' = `v' if f`v' == .
	di "l2`v' is missing this many times:"
	count if l2`v' == . & hdwf == 1 & inyr == 1 & year > 1999
	replace l2`v' = `v' if l2`v' == .
}

local kludgevars2 adlstat iadlstat 
foreach v in `kludgevars2' {
	count if `v' == . & hdwf == 1 & inyr == 1
	replace `v' = 1 if `v' == .
	count if f`v' == . & hdwf == 1 & inyr == 1
	replace f`v' = `v' if f`v' == .
	count if l2`v' == . & hdwf == 1 & inyr == 1 & year > 1999
	replace l2`v' = `v' if l2`v' == .
}

replace l2age = age-2 if l2age == .

*** deal with missing and improperly coded marital status variables
* assume status did not change if missing
count if missing(l2mstat_new) 
replace l2mstat_new = mstat_new if missing(l2mstat_new)

tab everm l2everm, m
replace everm = 0 if missing(everm)
replace l2everm = everm if missing(l2everm)

tab eversep l2eversep, m
replace eversep = 0 if missing(eversep)
replace l2eversep = eversep if missing(l2eversep)

*gen widowev = widowed | lwidowed
* assume lpartdied=0 if missing
replace l2partdied=0 if missing(l2partdied)


*** deal with missing retirement status
* assume not retired if missing both current and lag status
replace retired = 0 if missing(retired) & missing(l2retired)
* assume status did not change if missing
replace retired = l2retired if missing(retired)
replace l2retired = retired if missing(l2retired)

*** deal with missing number of biological children
* assume no biological children if missing
tab numbiokids, m
tab l2numbiokids, m
replace numbiokids = 0 if missing(numbiokids)
replace l2numbiokids = numbiokids if missing(l2numbiokids)
replace l2numbiokids = 0 if missing(l2numbiokids)
* assume no yrsnclastkid if missing
replace yrsnclastkid = 0 if missing(yrsnclastkid)
replace l2yrsnclastkid = 0 if missing(l2yrsnclastkid)

*** deal with missing laborforcestat
count if missing(laborforcestat)
replace laborforcestat = 3 if missing(laborforcestat)

*** deal with missing full-time/part-time
replace fullparttime = 0 if missing(fullparttime)

*** deal with workcat missing values
replace workcat = 4 if workcat == .
replace l2workcat = workcat if l2workcat == .
replace l2workcat = 4 if l2workcat == .

*** deal with missing educlvl
replace educlvl = 2 if educlvl == .
forvalues x = 1/4 {
	replace educ`x' = 1 if educlvl == `x' & missing(educ`x')
}

replace hsless = 0 if missing(hsless)
replace college = 0 if missing(college)

forvalues x = 1/4{
	replace mthreduc`x' = 0 if missing(mthreduc`x')
	replace fthreduc`x' = 0 if missing(fthreduc`x')	
}

replace educlvl = 2 if missing(educlvl)
replace l2educlvl = educlvl if missing(l2educlvl)

replace anyhi = 0 if missing(anyhi)
replace l2anyhi = anyhi if missing(l2anyhi)

count if relhd == 88
drop if relhd == 88

replace weight = 0 if missing(weight)

replace inscat = 3 if missing(inscat)
replace l2inscat = 3 if missing(l2inscat)

replace l2smkstat = smkstat if missing(l2smkstat)
replace l2smkstat = 1 if missing(l2smkstat)
replace smkstat = 1 if missing(smkstat)

* Setting chldsrh to "good" if missing - should impute instead.
replace chldsrh = 4 if missing(chldsrh)



* Deal with missing values for k6severe and l2k6severe
replace k6severe = 0 if missing(k6severe)
replace l2k6severe = 0 if missing(l2k6severe)

bys male: egen k6scoreavg=mean(k6score)
bys male: egen l2k6scoreavg=mean(l2k6score)
replace k6score = k6scoreavg if missing(k6score)
replace l2k6score = l2k6scoreavg if missing(l2k6score)

* Deal with missings for exercise variables - most people get at least some exercise with this definition
replace anyexercise = 1 if missing(anyexercise)
replace l2anyexercise = 1 if missing(l2anyexercise)

* deal with missings for di benefits variable
replace ssdiamt = 0 if mi(ssdiamt)

capture log close
