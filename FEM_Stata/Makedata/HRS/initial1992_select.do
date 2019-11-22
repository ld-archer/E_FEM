/** \file
Prepare file for estimating initial condition mean and covariance.

- Modified on Apr 8, 2008
- 9/8/2009 - Modified to use the new age variables, age_iwe, age_yrs
- 6/20/2014 - Update to include 2010 cohort

\todo Figure out if this file is still needed, or has it been replaced by the Ox code.

*/
include common.do

local age_var age_yrs

use "$outdata/hrs_selected.dta", clear
* Keep only those alive and interviewed
  keep if iwstat == 1

count

tab wave if inrange(`age_var',50,55)

* Keep aged 50-55 in year 1992, 1998, 2004, 2010
#d; 
keep if (inrange(`age_var',50,55) & wave == 1) | 
(inrange(`age_var',50,55) & wave == 4)  | 
(inrange(`age_var',50,55) & wave == 7)	|
(inrange(`age_var',50,55) & wave == 10); 
#d cr

count

/*---------- Create anyadl and anyiadl for use in joint estimation     --------------*/

gen anyadl = adlstat > 1 if !missing(adlstat)
gen anyiadl = iadlstat > 1 if !missing(iadlstat)

	#d;
	keep wave hhidpn hhidpn_orig hispan black male hsless college
		single widowed married cancre deprsymp lunge stroke hearte diabe hibpe hearta heartae
		work wlth_nonzero anyhi shlt wtstate smkstat adlstat iadlstat anyadl anyiadl
		logiearnx loghatotax logdcwlthx iearnx iearnuc hatota hatotax dcwlthx
		anydb anydc rdb_ea_c rdb_na_c 
		diclaim db_tenure ssiclaim weight died logbmi
		nkid_liv10mi helphoursyr helphoursyr_sp helphoursyr_nonsp
		fdiabe50
		fsmoken50
		fcanc50
		fheart50
		fstrok50
		fhibp50
		flung50
                year
		painstat;
	#d cr
	
	* Rename
	#d; 
	foreach v of varlist single widowed cancre deprsymp lunge stroke hearte diabe hibpe hearta heartae
		work wlth_nonzero anyhi shlt wtstate smkstat adlstat iadlstat anyadl anyiadl painstat
		logiearnx loghatotax logdcwlthx anydb anydc rdb_ea_c rdb_na_c diclaim db_tenure logbmi {;
		gen f`v' = `v';
	};
	#d cr
	
foreach v of varlist * {
	qui count if missing(`v')
	dis "Obs missing for `v' is: " r(N)
}

count

foreach v of varlist * {
	*drop if missing(`v')
}

count


preserve
keep if wave == 1
count
desc, short
assert r(N) > 0
* drop wave
sum
save "$outdata/age5055_hrs1992.dta", replace
restore
count
preserve
keep if wave == 4
count
desc, short
assert r(N) > 0
* drop wave
sum
save "$outdata/age5055_hrs1998.dta", replace
restore

preserve
keep if wave == 7
desc, short
assert r(N) > 0
* drop wave
sum
save "$outdata/age5055_hrs2004.dta", replace
restore

preserve
keep if wave == 10
desc, short
assert r(N) > 0
* drop wave
sum
save "$outdata/age5055_hrs2010.dta", replace

exit, STATA
