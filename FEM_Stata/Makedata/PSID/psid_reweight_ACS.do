/* This file reweights the 2009 PSID population (used in the simulation as the stock population) 
to better look like the 2009 ACS figures.  The purpose of this file is to reweight using 
demographic variables that are not available in the Census estimates originally used for 
reweighting in psid_reweight.do.


Reweighting in two stages:  First for marital status/widowhood, then for education

*/

include common.do

* Determine which reweighting strategy to use.  1 is for age/race/sex/marital status, 2 is for age/race/sex/education
local reweight = 1

*Environmental variable for expanding the sample
local expand : env EXPANDPSID

use $outdata/acs2009_demog.dta
keep if age_yrs >= 25

*egen agec = cut(age_yrs), at(25,30,35,40,45,50,55,60,65,70,75,80,85,200)
egen agec = cut(age_yrs), at(25,35,45,55,65,75,85,200)
tab age_yrs agec if age_yrs >= 25, m
*gen agegrp = age_yrs
gen agegrp = agec

* Recode "other" as non-Hispanic white
replace racegrp = 2 if racegrp == 4

*replace agegrp = agec if age_yrs >= 75 | racegrp == 4
* Hispanics are not populated well for age 65+ (some ages missing entirely in psid)
*replace agegrp = agec if age_yrs >= 65 & racegrp == 1
replace agegrp = 75 if racegrp == 1 & agegrp >= 75

* treat young widows as single
replace widowed=0 if widowed==1 & age_yrs < 65
* group older blacks  where cohab is rare
replace agegrp=65 if agegrp > 65 & racegrp==3 & mstat_cv==2
* group older Hispanics where cohab is rare
replace agegrp=55 if agegrp > 55 & racegrp==1 & mstat_cv==2
* group male Hispanic widows with older age
replace agegrp=75 if agegrp==65 & racegrp==1 & widowed==1 & male==1


tab racegrp
			


*** File for marital status and widowhood ***
preserve		
collapse (sum) weight, by(agegrp racegrp male mstat_cv widowed)
sort  agegrp racegrp male mstat_cv widowed, stable
rename weight pop
tempfile pop09_acs_mstat
save `pop09_acs_mstat'
restore

*** File for education ***
* issue - very few older blacks with higher education
replace educlvl = 2 if inlist(educlvl,3,4) & racegrp == 3 & agegrp >= 65

collapse (sum) weight, by(agegrp racegrp male educlvl)
sort  agegrp racegrp male educlvl, stable
rename weight pop
tempfile pop09_acs_educ
save `pop09_acs_educ'

sort pop
li


* Read in already reweighted 2009 PSID 
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

*egen agec = cut(`age_var'), at(25,30,35,40,45,50,55,60,65,70,75,80,85,200)
egen agec = cut(`age_var'), at(25,35,45,55,65,75,85,200)
*gen agegrp = `age_var'
gen agegrp = agec
*replace agegrp = agec if `age_var' >= 75 | racegrp == 4
* Hispanics are not populated well for age 65+ (some ages missing entirely in psid)
*replace agegrp = agec if `age_var' >= 65 & racegrp == 1
replace agegrp = 75 if racegrp == 1 & agegrp >= 75

tab racegrp, m
tab agegrp, m
tab male, m

tab age agegrp, m

* create marital status variable for reweighting
gen mstat_cv = mstat_new

* treat young widows as single
replace widowed=0 if widowed==1 & age < 65
* group older blacks  where cohab is rare
replace agegrp=65 if agegrp > 65 & racegrp==3 & mstat_cv==2
* group older Hispanics where cohab is rare
replace agegrp=55 if agegrp > 55 & racegrp==1 & mstat_cv==2
* group male Hispanic widows with older age
replace agegrp=75 if agegrp==65 & racegrp==1 & widowed==1 & male==1
					 
* Sum of weights  - uncommented "if died == 0" since we care about matching the weight of the living
bys agegrp racegrp male mstat_cv widowed: egen sumwt = total(weight) if died == 0 
sort agegrp racegrp male mstat_cv widowed, stable
		 
/* 
*Sum of HH weights
		 *HH weight divided by 2 for couples
		 sort hhid hhidpn, stable
		 by hhid: replace wthh = wthh/2 if Nalive == 2
		 sort agegrp racegrp male, stable
		*/ 
		


* Reweight by age/race/sex/marital status
if `reweight' == 1 {
	* Merge with 2009 ACS for marital status
	merge agegrp racegrp male  mstat_cv widowed using `pop09_acs_mstat'
	qui count if _merge == 2
		 
	if r(N) > 0 {
 		dis "Wrong, there are empty cells"
 		li agegrp racegrp male  mstat_cv widowed if _merge == 2
 		exit(333)
	}

	drop _merge 
			 
	* Adjust the weights
	replace weight = weight * pop / sumwt if `age_var' >= 25 & died == 0
	
	* issue - very few older blacks with higher education
	replace educlvl = 2 if inlist(educlvl,3,4) & racegrp == 3 & agegrp >= 65
}

drop sumwt


bys agegrp racegrp male educlvl: egen sumwt = total(weight) if died == 0 
sort agegrp racegrp male educlvl, stable


* Reweight by age/race/sex/education
if `reweight' == 2 {
	* Merge with 2009 ACS for education
	merge agegrp racegrp male educlvl using `pop09_acs_educ'
	qui count if _merge == 2
			 
	if r(N) > 0 {
 		dis "Wrong, there are empty cells"
 		li agegrp racegrp male educlvl if _merge == 2
 		exit(333)
	}

	drop _merge 

	* Preserve the total weight
	qui sum weight if `age_var' >= 25 & died == 0
	local totweight_1 = r(sum)
			 
	* Adjust the weights (scaled by the ratio of the size of the cell in ACS vs PSID)
	replace weight = weight * ( pop / sumwt) if `age_var' >= 25 & died == 0

	qui sum weight if `age_var' >= 25 & died == 0
	local totweight_2 = r(sum)

	* Make sure we preserve the total weight
	replace weight = weight * (`totweight_1'/`totweight_2')
}


		 
/*		 * Adjust household weights too
		 qui sum weight if died==0
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

label data "Pop 25+ in 2009, population size adjusted to 2009 ACS weights"
save "$outdata/psid_all2009_pop_adjusted", replace






capture log close