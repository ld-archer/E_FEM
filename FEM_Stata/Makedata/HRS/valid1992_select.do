
/** \file

 Use half of the HRS sample as validation sample, the other to test

\todo get this file to actually work with the existing code

\todo move zlist1, xlist2, plist, and flist to \ref fem_env.do

\todo remove redundant definitions of global variable lists
*/

include common.do

#d;
	* Demographics;
	global zlist1 "hhid hhidpn hacohort wave weight wthh black white hispan hsless college educ male frbyr";
	
	* Initial condition only; 
	global zlist2 "single shlt smokev anydb rdb_na_2 
			rdb_na_3 rdb_na_4 rdb_ea_2 rdb_ea_3 anydc db_tenure logdcwlthx dcwlth dcwlthx
			rdb_ea_c rdb_na_c era nra   rssclyr";	
  
  * Time-varying covariants and outcomes; 
		* global plist age75l age75p age62e age65e age65l age6574 widowed married age;
		global plist "widowed married age
		died iwstat hearte stroke cancre deprsymp cesdstat hibpe diabe lunge memrye anyhi diclaim ssiclaim ssclaim dbclaim 
		nhmliv wlth_nonzero overwt obese_1 obese_2 obese_3 smoken iadl1 iadl2p adl1 adl2 adl3p work retired 
		loghatotax logiearnx hatotax iearnx hatota iearn smkstat logbmi adlstat iadlstat";
		
		global flist $plist; 
#d cr
	
local maxwv $hrskeepwv

**********************************
* Select sample using wave 1 data
* Oct 1st, 2008 - We may only choose those interviewed in wave 1-7 or die
**********************************

use "$dua_rand_hrs/hrs1`maxwv'r.dta", clear

* Select half of the initial HRS cohort
* If married, both should be in the sample
keep if wave == 1 
gen draw = uniform()
sort hhid hhidpn, stable
by hhid: egen insamp = total(draw < 0.5 & inrange(rbyr,1931,1941))
by hhid: gen hhnum = _N

drop if married & hhnum == 1
preserve 
	keep if insamp
	sort hhidpn, stable
	save $dua_rand_hrs/host92, replace
restore

drop if insamp
sort hhidpn, stable	
save $dua_rand_hrs/test92.dta, replace

**********************************
* Select longitudinal test sample
**********************************
use "$dua_rand_hrs/hrs1`maxwv'r.dta", clear

/*
* Drop those only interviewed in the first wave
sort hhidpn wave, stable
by hhidpn: gen lwv = wave[_N]
drop if lwv == 1
drop lwv
*/

* Transitions, among the host sample
sort hhidpn wave, stable
merge hhidpn using $dua_rand_hrs/host92.dta
tab _merge
keep if _merge == 3
drop _merge

save "$dua_rand_hrs/host92_all.dta", replace

**********************************
* Select longitudinal estimation sample
**********************************
use "$dua_rand_hrs/hrs1`maxwv'r_transition.dta", clear
sort hhidpn wave, stable
merge hhidpn using $dua_rand_hrs/host92.dta
tab _merge
drop if _merge == 3
drop _merge

save "$dua_rand_hrs/est92_all.dta", replace
erase $dua_rand_hrs/test92.dta

**********************************
* Initial conditions and lag conditions for the initial sample
**********************************
use $dua_rand_hrs/host92.dta
*** Drop old lags and f values
foreach v in $zlist2 $flist wave {
	drop l2`v'
}
foreach v in $zlist2 $flist{
	drop f`v'
}

*** Generate new lags

	foreach v in $wlist $plist {
		gen l2`v' = `v'
		local vlb: var label `v'
		label var l2`v' "Lag of `vlb'"
	}
	
	foreach v in $zlist2 $flist {
		cap drop f`v'
		gen f`v' = `v'
		local vlb: var label `v'
		label var f`v' "Init.of `vlb'"
	}
		drop period time
		gen period = 1
		gen time = 1		
		cap drop year			
		gen year = 1992
		gen died1992 = 0   

	* Sep 9, 2008
	*  GENERATE NEW AGE SPLINE VARIABLES

/*
	mkspline lage1 65 lage2 75 lage3 = lage
	foreach v of varlist lage1-lage3{
		local lab: var label `v'
		label var `v' "spline `lab'"
	}
	*/		

/* proptax vars don't exist for wave 1 (1992) */
replace proptax = 0 if missing(proptax)
replace proptax_nonzero = 0 if missing(proptax_nonzero)

save "$dua_rand_hrs/host92_initial.dta", replace
erase $dua_rand_hrs/host92.dta

exit, STATA
