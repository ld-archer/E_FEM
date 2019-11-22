/* This file reweights the 2009 PSID population (used in the simulation and the new cohorts) to better look like the Census figures from 2009 
*/

include common.do

*Environmental variable for expanding the sample
local expand : env EXPANDPSID

/* Re-generate census population data by redefining age group */
use "$outdata/population_projection.dta", clear
keep if year == 2009 & age >= 25
			
egen agec = cut(age), at(25,30,35,40,45,50,55,60,65,70,75,80,85,200)
tab age agec if age >= 25, m
gen agegrp = age


* Recode "other" has non-Hispanic white
replace racegrp = 2 if racegrp == 4

replace agegrp = agec if age >= 75 | racegrp == 4
* Hispanics are not populated well for age 65+ (some ages missing entirely in psid)
replace agegrp = agec if age >= 65 & racegrp == 1

tab racegrp
			
collapse (sum) pop, by( agegrp racegrp male)
sort  agegrp racegrp male, stable
tempfile pop09
save `pop09', replace
save $outdata/pop09.dta, replace



* Read in psid_analytic and reweight
 use "$outdata/psid_analytic.dta", clear
 
 
 * Deal with death wave, as some variables are missing ...
 	preserve
	by hhidpn: egen ever_died = max(died)
	keep if ever_died == 1 
	drop ever_died
	by hhidpn: gen died_nextwv = died[_n+1]
	keep if died_nextwv == 1 | died == 1
	drop died_nextwv
	by hhidpn: gen nwaves = _N
	drop if nwaves ~= 2
	drop nwaves
	
	bys hhidpn: gen index = _n
	tab index, m
	foreach v in year died diedyr age aged  {
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
 
   * to deal with age = 0 for dead people
 bys hhidpn: egen birthyr = max(rbyr)
 * Give age to the dead with age = 0
 replace age = year - birthyr if age == 0 & died == 1
 drop birthyr
 
 
 * Need lags for all people, so no new observations.
 keep if (year == 2009 & age >= 25 & newobservation == 0 & died == 0) | (year == 2009 & died == 1)
  
 * Drop if race or age is missing ... need to handle this in SAS
 drop if other == .
drop if hispan == .
drop if age == .
drop if age == 999
		 
local age_var age

* no sampling weights for younger than 25
replace weight = 0 if `age_var' < 25

 
* Race/ethnicity
gen racegrp = 1 if hispan == 1 
replace racegrp = 2 if hispan == 0 & white == 1 
replace racegrp = 3 if hispan == 0 & black == 1
* replace racegrp = 4 if hispan == 0 & white == 0 & black == 0
* Recode other as non-hispanic white
replace racegrp = 2 if hispan == 0 & white == 0 & black == 0


tab racegrp, m

egen agec = cut(`age_var'), at(25,30,35,40,45,50,55,60,65,70,75,80,85,200)
gen agegrp = `age_var'
replace agegrp = agec if `age_var' >= 75 | racegrp == 4
* Hispanics are not populated well for age 65+ (some ages missing entirely in psid)
replace agegrp = agec if `age_var' >= 65 & racegrp == 1

tab racegrp, m
tab agegrp, m
tab male, m

tab age agegrp, m
					 
* Sum of weights
bys agegrp racegrp male: egen sumwt = total(weight) /* if died == 0 */
sort agegrp racegrp male, stable
		 
/* 
*Sum of HH weights
		 *HH weight divided by 2 for couples
		 sort hhid hhidpn, stable
		 by hhid: replace wthh = wthh/2 if Nalive == 2
		 sort agegrp racegrp male, stable
		*/ 

* Merge with 2009 census projection
merge agegrp racegrp male using `pop09'
qui count if _merge == 2
		 
if r(N) > 0 {
 	dis "Wrong, there are empty cells"
 	exit(333)
}

drop _merge 
			 
qui sum weight
local oldsumwt = r(sum)

* Adjust the weights
replace weight = weight * pop / sumwt if `age_var' >= 25 & died == 0
		 
/*		 * Adjust household weights too
		 qui sum weight
		 local newsumwt = r(sum)
dis "Original population size is: `oldsumwt'"
dis "Adjusted population size is: `newsumwt'"
	 
* Average weight change per HH
bys hhid: egen oldwt = total(weight) 
bys hhid: egen newwt = total(weight)
replace wthh = wthh * newwt/oldwt

drop oldwt newwt pop 
label var wthh "Household weight"
*/

label data "Pop 25+ in 2009, population size adjusted to Census Bureau projection"
save "$outdata/psid_all2009_pop_adjusted", replace





*** Now do the similar for the file that feeds new25simulate


* Read in psid_analytic and reweight
 use "$outdata/psid_analytic.dta", clear
 
 * Need lags for all people, no no new observations.
 keep if year == 2009 & age >= 25 
 
 
 * Drop if race or age is missing ... need to handle this in SAS
 drop if other == .
drop if hispan == .
drop if age == .
drop if age == 999
		 
local age_var age

* no sampling weights for younger than 25
replace weight = 0 if `age_var' < 25

 
* Race/ethnicity
gen racegrp = 1 if hispan == 1 
replace racegrp = 2 if hispan == 0 & white == 1 
replace racegrp = 3 if hispan == 0 & black == 1
* replace racegrp = 4 if hispan == 0 & white == 0 & black == 0
* Recode other as non-hispanic white
replace racegrp = 2 if hispan == 0 & white == 0 & black == 0


tab racegrp, m

egen agec = cut(`age_var'), at(25,30,35,40,45,50,55,60,65,70,75,80,85,200)
gen agegrp = `age_var'
replace agegrp = agec if `age_var' >= 75 | racegrp == 4
* Hispanics are not populated well for age 65+ (some ages missing entirely in psid)
replace agegrp = agec if `age_var' >= 65 & racegrp == 1

tab racegrp, m
tab agegrp, m
tab male, m

tab age agegrp, m
					 
* Sum of weights
bys agegrp racegrp male: egen sumwt = total(weight) if died == 0
sort agegrp racegrp male, stable
		 
/* 
*Sum of HH weights
		 *HH weight divided by 2 for couples
		 sort hhid hhidpn, stable
		 by hhid: replace wthh = wthh/2 if Nalive == 2
		 sort agegrp racegrp male, stable
		*/ 

* Merge with 2009 census projection
merge agegrp racegrp male using `pop09'
qui count if _merge == 2
		 
if r(N) > 0 {
 	dis "Wrong, there are empty cells"
 	exit(333)
}

drop _merge 
			 
qui sum weight
local oldsumwt = r(sum)

* Adjust the weights
replace weight = weight * pop / sumwt if `age_var' >= 25 & died == 0
		 
/*		 * Adjust household weights too
		 qui sum weight
		 local newsumwt = r(sum)
dis "Original population size is: `oldsumwt'"
dis "Adjusted population size is: `newsumwt'"
	 
* Average weight change per HH
bys hhid: egen oldwt = total(weight) 
bys hhid: egen newwt = total(weight)
replace wthh = wthh * newwt/oldwt

drop oldwt newwt pop 
label var wthh "Household weight"
*/



* Keep only those 25-26, in 2009, and present in the survey
keep if age >=25 & age < 27 & year == 2009 & inyr == 1

* Expand the sample (parameter is set in expansion.makefile
di "`expand'"
multiply_persons `expand'

label data "Pop 25-26 in 2009 including new entrants, population size adjusted to Census Bureau projection"
save "$outdata/psid_all2009_pop_adjusted_2526", replace






capture log close