/* \file
Generate AIME for individuals at each wave when possible.  For example, if a person gave permission
to access SSA records in 1998, then we can try to calculate AIME in 1992, 1994, 1996, and 1998.

*/

quietly include common.do

use "$outdata/hrs_analytic_recoded.dta", clear
xtset hhidpn wave
sort hhidpn wave, stable
gen year = (wave - 1) * 2 + 1992
keep hhidpn rssclyr hacohort rabyear wave year iearn age male work died

gen ry_earn = min(200000,iearn) if !missing(iearn)
ren rssclyr rclyr
save "$outdata/hrs_analytic_temp.dta", replace

************************************************************
*    HRS 1992 permission
* 	 Can only assign AIME values for 1992 for this permission group
************************************************************

sort hhidpn 
merge m:1 hhidpn using "$dua_rand_hrs/ssa_92.dta"
tab _merge
drop if _merge == 2
drop _merge
gen match_hrs92 = rw1991 != .
set trace off

* Year of claiming SS
local currentyr = 1991
gen clmyear = min(`currentyr',rclyr)

* Calculate aime for all years of observed wages (up to age 120, as set in calcage parameter)
forvalues yr = 1992/1992 {
	aimeUS_v3 rq_`yr' rabyear clmyear if match_hrs92 == 1 & year == `yr', gen(raime) earn("rw") fyr(1951) yr(1991) calcage(120)
	rename raime aime_ssa92_`yr' 
}

gen ssasrc = 1992 if match_hrs92 == 1
gen temp_rq = rq_1992 if ssasrc == 1992 & year == 1992
drop clmyear rw* rq*

************************************************************
*   AHEAD 1993 permission
*   Can only assign AIME values based on 1992 - later must be imputed
************************************************************
sort hhidpn
merge m:1 hhidpn using "$dua_rand_hrs/ssa_93.dta"
tab _merge
drop if _merge == 2
drop _merge
gen match_ahd93 = rw1992!=.
local currentyr = 1992
gen clmyear = min(`currentyr',rclyr)

* Calculate aime for all years of observed wages (up to age 120, as set in calcage parameter)
forvalues yr = 1994/1994 {
	aimeUS_v3 rq_`yr' rabyear clmyear if match_ahd93 == 1 & year == `yr', gen(raime) earn("rw") fyr(1951) yr(1992) calcage(120)
	rename raime aime_ssa93_`yr' 
}

* Need to assign 1994 value by updating the assigned value (since it is from 1992)

replace ssasrc = 1993 if match_ahd93 == 1
replace temp_rq = rq_1993 if ssasrc == 1993 & year == 1994
drop clmyear rw* rq*

************************************************************
*   CODA WB 1998 permission
*		Can assign for 1992, 1994, 1996, and 1998 - later must be imputed
************************************************************	
sort hhidpn
merge m:1 hhidpn using "$dua_rand_hrs/ssa_98.dta"
tab _merge
drop if _merge == 2
drop _merge
gen match_wb98 = rw1998!=.

gen clmyear = .
* Calculate aime for all years of observed wages (up to age 120, as set in calcage parameter)
forvalues yr = 1992 (2) 1998 {
	local currentyr = `yr'
	replace clmyear = min(`currentyr',rclyr)
	aimeUS_v3 rq_`yr' rabyear clmyear if match_wb98 == 1 & year == `yr', gen(raime) earn("rw") fyr(1951) yr(`yr') calcage(120)
	rename raime aime_ssa98_`yr' 
}

replace ssasrc = 1998 if match_wb98 == 1

forvalues yr = 1992 (2) 1998 {
	replace temp_rq = rq_`yr' if ssasrc == 1998 & year == `yr'
}

drop clmyear rw* rq*



************************************************************
*   All cohorts 2004 permission
* 	Can assign for 1992 - 2002.  Later must be imputed.
************************************************************
sort hhidpn
merge m:1 hhidpn using "$dua_rand_hrs/ssa_04.dta"
tab _merge
drop if _merge == 2
drop _merge
gen match_all04 = rw2003!=.

gen clmyear = .
* Calculate aime for all years of observed wages (up to age 120, as set in calcage parameter)
forvalues yr = 1992 (2) 2002 {
	local currentyr = `yr'
	replace clmyear = min(`currentyr',rclyr)
	aimeUS_v3 rq_`yr' rabyear clmyear if match_all04 == 1 & year == `yr', gen(raime) earn("rw") fyr(1951) yr(`yr') calcage(120)
	rename raime aime_ssa04_`yr' 
}
* 2004 permissions only had access to records through 2003
forvalues yr = 2003/2003 {
	local currentyr = `yr'
	replace clmyear = min(`currentyr',rclyr)
	aimeUS_v3 rq_`yr' rabyear clmyear if match_all04 == 1 & year == 2004, gen(raime) earn("rw") fyr(1951) yr(`yr') calcage(120)
	rename raime aime_ssa04_2004 
}


replace ssasrc = 2004 if match_all04 == 1
forvalues yr = 1992 (2) 2002 {
	replace temp_rq = rq_`yr' if ssasrc == 2004 & year == `yr'
}
forvalues yr = 2003/2003 {
	replace temp_rq = rq_`yr' if ssasrc == 2004 & year == 2004
}
drop clmyear rw* rq*


************************************************************
*   All cohorts 2006 permission
* 	Can assign for 1992 - 2004.  Later must be imputed
************************************************************	
sort hhidpn
merge m:1 hhidpn using "$dua_rand_hrs/ssa_06.dta"
tab _merge
drop if _merge == 2
drop _merge
gen match_all06 = rw2005!=.

gen clmyear = .
* Calculate aime for all years of observed wages (up to age 120, as set in calcage parameter)
forvalues yr = 1992 (2) 2004 {
	local currentyr = `yr'
	replace clmyear = min(`currentyr',rclyr)
	aimeUS_v3 rq_`yr' rabyear clmyear if match_all06 == 1 & year == `yr', gen(raime) earn("rw") fyr(1951) yr(`yr') calcage(120)
	rename raime aime_ssa06_`yr' 
}
* 2006 permissions only had access to records through 2005
forvalues yr = 2005/2005 {
	local currentyr = `yr'
	replace clmyear = min(`currentyr',rclyr)
	aimeUS_v3 rq_`yr' rabyear clmyear if match_all06 == 1 & year == 2006, gen(raime) earn("rw") fyr(1951) yr(`yr') calcage(120)
	rename raime aime_ssa06_2006 
}


replace ssasrc = 2006 if match_all06 == 1
forvalues yr = 1992 (2) 2004 {
	replace temp_rq = rq_`yr' if ssasrc == 2006 & year == `yr'
}
forvalues yr = 2005/2005 {
	replace temp_rq = rq_`yr' if ssasrc == 2006 & year == 2006
}
drop clmyear rw* rq*
gen rq = temp_rq

* Convert all AIME measures to 2004 dollars
egen cpicyr  = cpi(rabyear+60)
egen cpi2004 = cpi(2004)

* 1992 permission
replace aime_ssa92_1992=aime_ssa92_1992*cpi2004/cpicyr if ssasrc == 1992
* 1993 permission
replace aime_ssa93_1994 = aime_ssa93_1994*cpi2004/cpicyr if ssasrc == 1993
* 1998 permission
forvalues yr = 1992 (2) 1998 {
	replace aime_ssa98_`yr' = aime_ssa98_`yr' *cpi2004/cpicyr if ssasrc == 1998
}
* 2004 permission
forvalues yr = 1992 (2) 2004 {
	replace aime_ssa04_`yr' = aime_ssa04_`yr'*cpi2004/cpicyr if ssasrc == 2004
}
* 2006 permission
forvalues yr = 1992 (2) 2006 {
	replace aime_ssa06_`yr' = aime_ssa06_`yr'*cpi2004/cpicyr if ssasrc == 2006
}

* Impute the non-observed values for AIME and quarters worked
gen age_2yr = age - 2
gen styr = year
gen yrvar = .
egen raime = rowmax(aime_ssa*)

replace raime = . if year > ssasrc + 1
* We eventually take logs, so replace zeroes with 1
replace raime = 1 if raime == 0
replace rq = 1 if rq == 0

sort hhidpn wave, stable


* 1992 permission - need to impute 1994 - 2012
local srcyr = 1992
local maxyr = 2014

forvalues calcyr = 1994 (2) `maxyr' {
	replace yrvar = `calcyr'
	by hhidpn: replace raime = l.raime if year == `calcyr'  & ssasrc == `srcyr'
	by hhidpn: replace rq = l.rq if year == `calcyr'  & ssasrc == `srcyr'
	* Fill in non-response waves if necessary
	forvalues x = 2/12 {
		di "`x'"
		by hhidpn: replace raime = l`x'.raime if year == `calcyr'  & ssasrc == `srcyr' & raime == .
		by hhidpn: replace rq = l`x'.rq if year == `calcyr'  & ssasrc == `srcyr' & rq == .
	}
	UpdateAIME_v2 raime ry_earn age_2yr male styr if year == yrvar & ssasrc == `srcyr', gen(faime)
	replace raime = faime if year == `calcyr' & ssasrc == `srcyr'
	drop faime
	replace rq = rq + 8 if work == 1 & year == `calcyr' & ssasrc == `srcyr'
}
* 1993 permission - need to update 1994 (based on 1992 at present) and impute 1996 through 2012
local srcyr = 1993

forvalues calcyr = 1994 (2) `maxyr' {
	replace yrvar = `calcyr'
	by hhidpn: replace raime = l.raime if year == `calcyr'  & ssasrc == `srcyr' & year > 1994
	by hhidpn: replace rq = l.rq if year == `calcyr'  & ssasrc == `srcyr' & year > 1994
	* Fill in non-response waves if necessary
	forvalues x = 2/11 {
		di "`x'"
		by hhidpn: replace raime = l`x'.raime if year == `calcyr'  & ssasrc == `srcyr' & raime == . & year > 1994
		by hhidpn: replace rq = l`x'.rq if year == `calcyr'  & ssasrc == `srcyr' & rq == .& year > 1994
	}
	UpdateAIME_v2 raime ry_earn age_2yr male styr if year == yrvar & ssasrc == `srcyr', gen(faime)
	replace raime = faime if year == `calcyr' & ssasrc == `srcyr'
	drop faime
	replace rq = rq + 8 if work == 1  & year == `calcyr' & ssasrc == `srcyr'
}

* 1998 permission - need to impute 2000 through 2012
local srcyr = 1998

forvalues calcyr = 2000 (2) `maxyr' {
	replace yrvar = `calcyr'
	by hhidpn: replace raime = l.raime if year == `calcyr'  & ssasrc == `srcyr' 
	by hhidpn: replace rq = l.rq if year == `calcyr'  & ssasrc == `srcyr'
	* Fill in non-response waves if necessary
	forvalues x = 2/9 {
		di "`x'"
		by hhidpn: replace raime = l`x'.raime if year == `calcyr'  & ssasrc == `srcyr' & raime == .
		by hhidpn: replace rq = l`x'.rq if year == `calcyr'  & ssasrc == `srcyr' & rq == .
	}
	UpdateAIME_v2 raime ry_earn age_2yr male styr if year == yrvar & ssasrc == `srcyr', gen(faime)
	replace raime = faime if year == `calcyr' & ssasrc == `srcyr'
	drop faime
	replace rq = rq + 8 if work == 1  & year == `calcyr' & ssasrc == `srcyr'
}

* 2004 permission - need to impute 2006 through 2012
local srcyr = 2004

* Update 2004 values (they are from 2003)
forvalues calcyr = 2004/2004 {
	replace yrvar = `calcyr'
	UpdateAIME_v2 raime ry_earn age_2yr male styr if year == yrvar & ssasrc == `srcyr', gen(faime)
	replace raime = faime if year == `calcyr' & ssasrc == `srcyr'
	drop faime
	replace rq = rq + 4 if work == 1 & year == `calcyr' & ssasrc == `srcyr'
}

forvalues calcyr = 2006 (2) `maxyr' {
	replace yrvar = `calcyr'
	by hhidpn: replace raime = l.raime if year == `calcyr'  & ssasrc == `srcyr' 
	by hhidpn: replace rq = l.rq if year == `calcyr'  & ssasrc == `srcyr' 
	* Fill in non-response waves if necessary
	forvalues x = 2/5 {
		di "`x'"
		by hhidpn: replace raime = l`x'.raime if year == `calcyr'  & ssasrc == `srcyr' & raime == .
		by hhidpn: replace rq = l`x'.rq if year == `calcyr'  & ssasrc == `srcyr' & rq == .
	}
	UpdateAIME_v2 raime ry_earn age_2yr male styr if year == yrvar & ssasrc == `srcyr', gen(faime)
	replace raime = faime if year == `calcyr' & ssasrc == `srcyr'
	drop faime
	replace rq = rq + 8 if work == 1 & year == `calcyr' & ssasrc == `srcyr'
}

* 2006 permission - need to impute 2008 through 2012
local srcyr = 2006

* Update 2006 values (they are from 2005)
forvalues calcyr = 2006/2006 {
	replace yrvar = `calcyr'
	UpdateAIME_v2 raime ry_earn age_2yr male styr if year == yrvar & ssasrc == `srcyr', gen(faime)
	replace raime = faime if year == `calcyr' & ssasrc == `srcyr'
	drop faime
	replace rq = rq + 4 if work == 1 & year == `calcyr' & ssasrc == `srcyr'
}

forvalues calcyr = 2008 (2) `maxyr' {
	replace yrvar = `calcyr'
	by hhidpn: replace raime = l.raime if year == `calcyr'  & ssasrc == `srcyr' 
	by hhidpn: replace rq = l.rq if year == `calcyr'  & ssasrc == `srcyr' 
	* Fill in non-response waves if necessary
	forvalues x = 2/4 {
		di "`x'"
		by hhidpn: replace raime = l`x'.raime if year == `calcyr'  & ssasrc == `srcyr' & raime == .
		by hhidpn: replace rq = l`x'.rq if year == `calcyr'  & ssasrc == `srcyr' & rq == .
	}
	UpdateAIME_v2 raime ry_earn age_2yr male styr if year == yrvar & ssasrc == `srcyr', gen(faime)
	replace raime = faime if year == `calcyr' & ssasrc == `srcyr'
	drop faime
	replace rq = rq + 8 if work == 1 & year == `calcyr' & ssasrc == `srcyr'
}

* Deal with missing values (this deals with non-reponse where we don't have earnings and the deceased)
forvalues yr = 1994 (2) `maxyr'{
	replace raime = l.raime if raime == .
	replace rq = l.rq if rq == . 
}


* Calculate PIA for each respondent
gen rl = 1 if died == 0
replace rl = 0 if died == 1
* No death year, since alive
gen rdthyr = 2100 if died == 0
replace rdthyr = year if died == 1

gen rbyr = rabyear

* Calculate PIA
SsPIA_v2 raime rq rbyr rl rdthyr, gen(rpia)




save "$dua_rand_hrs/aime_all.dta", replace

exit, STATA









