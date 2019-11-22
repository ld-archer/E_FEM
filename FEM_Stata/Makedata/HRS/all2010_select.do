/** \file
Prepare data for 2004 51+

- 09/08/2009 - Changed to use new age variables
-            - Using age_yrs to choose 51+ in 2004
-            - Removed age splines, this should be done in simulation
- 12/16/2009 - Base cohort will now include dead persons to better calibrate medical costs in 2004
- 03/8/2010  - Keep dead spouses, using data from last alive wave

\ bug: some observations are dropped because weight for nursing home not assigned because first wave missing
*/
  include common.do
	
use "$outdata/hrs_selected.dta", clear
drop rdb_*

***************************************
* Initial and lag variables
***************************************
xtset hhidpn wave

sort hhidpn wave, stable
foreach v of varlist $timevariant proptax proptax_nonzero cogstate selfmem {
	* Generate lags if we can
	gen l2`v' = l.`v'
	* Use current state if lag doesn't exist 
	replace l2`v' = `v' if missing(l2`v')
	local vlb: var label `v'
	label var l2`v' "Two-year lag of `vlb'"
}

foreach v of varlist $flist {
	sort hhidpn wave, stable
	by hhidpn: gen f`v' = `v'[1]
	* Use current state if initial still doesn't exist
	replace f`v' = `v' if missing(f`v')
	local vlb: var label `v'
	label var f`v' "Init.of `vlb'"
}

replace l2died = 0 if year == 2010 & died == 1


***************************************
*Keep only wave 10 data
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

bys hhidpn: gen index = _n
tab index, m
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


* Merge the HRS 2010 Exit data to replace the AD variable for those who were dead in 2010, since we don't have the AD variable in prior waves

merge m:1 hhidpn wave using $outdata/exit_alzhe2010.dta
tab _merge
rename _merge _merge2

tab alzhe_ex if _merge2 == 3, m

replace alzhe = alzhe_ex if _merge2==3

drop if _merge2 == 2

drop alzhe_ex

tab alzhe if _merge2 == 3, m

 
* Keep only the wave 10 living and the dead
keep if (iwstat == 1 & wave == 10) | (iwstat == 5 & wave <= 10)

* For those in nursing home use baseline sampling weights
* replace weight = bweight if nhmliv == 1 

* For those in nursing home, use nursing home weight from tracker file as weight
replace weight = weightnh if nhmliv == 1

* Flag the records we want to keep: Persons in Wave 7 with Age >= 51 and Non zero weight, and their alive (or dead) spouse
* They also need to not have missing cogstate if they are 65 or older and alive
*gen insamp = age_yrs >= 51 & age_yrs < . & weight > 0 & weight < . & wave == 7 & ((cogstate != . | age < 65) & died==0)
* do not exclude all the people who died in wave 7 from the sample population. cogstate missingness is already taken care of in steps below
gen insamp = age_yrs >= 51 & age_yrs < . & weight > 0 & weight < . & wave == 10 

* Flag the house holds we want to keep. These must have at least 1 in sample person
bys hhid: egen hhinsamp = total(insamp )
sum hhinsamp
if r(max)>2 {
	dis "Wrong, at most 2 individuals per HH"
}

* Remove households without an insample person
keep if hhinsamp == 1 | hhinsamp == 2
drop hhinsamp

* Count number of persons per household, alive or dead
bys hhid: gen N = _N

 

* If the living person in the household is single, then remove any died persons; they are not spouses
bys hhid: egen has_single = total(single)
drop if has_single & N > 1 & died & year < 2010 
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

* Re-count number of persons per household
drop N

* Flag those that are alive
gen alive = 1 - died

		 

***************************************
* Adjust sampling weights
***************************************
* For those in nursing home, population the same as in year 2010 (total = 1378287)
sum weight if nhmliv == 1 & wave == 10 & died == 0
local nurspop = 1378287
replace weight = weight * `nurspop' / r(sum) if nhmliv == 1 & wave == 10 & died == 0

* zero sampling weight for younger than age 51
replace weight = 0 if age_yrs < 51

***************************************
* Initial cogstate, set if missing
***************************************

* For the persons age >= 65 with missing cogstate (there are 3 of them in 2004, all deceased)
* Leave missing if deceased, set to normal if living.
** tab cogstate memrye  if age>=65 & year==2010, missing
** replace cogstate = 3 if cogstate == . & age >= 65 & year == 2010 & died==0

* For persons under 65 set the cogstate to missing
* Data for cogstate among those who age<65 is available since wave 4 to wave 10
** replace cogstate = . if age < 65

*some observations are dropped because weight for nursing home not assigned because first wave missing
count
drop if missing(weight)
count

  compress
	save "$outdata/all2010.dta", replace


exit, STATA
