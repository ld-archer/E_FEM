/** \file
Prepare data for 2004 51+

- 09/08/2009 - Changed to use new age variables
-            - Using age_yrs to choose 51+ in 2004
-            - Removed age splines, this should be done in simulation
- 12/16/2009 - Base cohort will now include dead persons to better calibrate medical costs in 2004
- 03/8/2010  - Keep dead spouses, using data from last alive wave
- 09/18/2012 - Change to 1998 (through wave 4)

\\ bug: some observations are dropped because weight for nursing home not assigned because first wave missing
*/
  include common.do


use "$outdata/hrs_selected.dta", clear
drop rdb_*
  
***************************************
*Keep only wave 4 data
***************************************
* Base-year sampling weights
sort hhidpn wave, stable
by hhidpn: gen bweight = weight[1]

* For dead persons, fill in the values for all variables except (wave iwstat died age_yrs age year) using the last wave in which they were alive (IWSTAT = 1)
* Do this by finding the last good wave for the dead person, copying these variables into it, and saving it as the wave they died in */
preserve
by hhidpn: egen ever_died = max(died)
keep if ever_died == 1 & inlist(iwstat, 1, 5)
drop ever_died
by hhidpn: gen died_nextwv = died[_n+1]
keep if died_nextwv == 1 | died == 1
drop died_nextwv
by hhidpn: gen nwaves = _N
drop if nwaves ~= 2
drop nwaves

by hhidpn: gen index = _n
foreach v of varlist wave iwstat died age_yrs age year {
	by hhidpn: replace `v' = `v'[2]
}
keep if index == 1
drop index
tempfile died_wv
save `died_wv'
restore

* Drop the waves with dead persons, and replace them with the artificial wave just created
drop if died 
append using `died_wv'
sort hhidpn wave, stable

keep if (iwstat == 1 & wave == 4) | (iwstat == 5 & wave <= 4)

* For those in nursing home use baseline sampling weights
replace weight = bweight if nhmliv == 1 

* Flag the records we want to keep: Persons in Wave 4 with Age >= 51 and Non zero weight, and their alive (or dead) spouse
gen insamp = age_yrs >= 51 & age_yrs < . & weight > 0 & weight < . & wave == 4

* Flag the house holds we want to keep. These must have at least 1 in sample person
bys hhid: egen hhinsamp = total(insamp )
sum hhinsamp
if r(max)>2 {
	dis "Wrong, at most 2 individuals per HH"
}

* Remove households without an insample person
keep if hhinsamp == 1 | hhinsamp == 2 

* Count number of persons per household, alive or dead
bys hhid: gen N = _N

 

* If the living person in the household is single, then remove any died persons; they are not spouses
bys hhid: egen has_single = total(single)
drop if has_single & N > 1 & died & year < 1998 
drop has_single 

* Re-count number of persons per household
drop N
bys hhid: gen N = _N

* Due to death and remarriage, it is possible that there are more than 2 records for a household.
* There could be the person, their original spouse that died, and a new spouse. 
* In these cases, we will keep the most recent two records
gsort hhid -year
bys hhid: gen extra_hh_person = _n > 2
drop if extra_hh_person
drop extra_hh_person
sort hhidpn wave, stable

drop N

* Flag those that are alive
gen alive = 1 - died

		 

***************************************
* Adjust sampling weights
***************************************
* For those in nursing home, population the same as in year 2002 (total = 1,656,586)
sum weight if nhmliv == 1 & died == 0 & wave == 4
local nurspop = 1656586
replace weight = weight * `nurspop' / r(sum) if nhmliv == 1 & died == 0 & wave == 4

* zero sampling weight for younger than age 51
replace weight = 0 if age_yrs < 51

***************************************
* Initial and lag variables
***************************************

foreach v of varlist $timevariant {
	gen l2`v' = `v'
	local vlb: var label `v'
	label var l2`v' "Two-year lag of `vlb'"
}

foreach v of varlist $flist {
	gen f`v' = `v'
	local vlb: var label `v'
	label var f`v' "Init.of `vlb'"
}

replace l2died = 0 if year == 1998 & died == 1

	bys hhidpn: gen period = 1
	bys hhidpn: gen time = 1
	
	save "$outdata/all1998.dta", replace
	
*exit, STATA
