/* This file will reweight the 25-26 year olds in 2009 to match the Census */

include common.do

*Environmental variable for expanding the sample
local expand : env EXPANDPSID

use $outdata/pop2526_projection_2081.dta

keep if year == 2009

gen racegrp = 1 if hispan == 1 
replace racegrp = 2 if hispan == 0 & black == 0
replace racegrp = 3 if hispan == 0 & black == 1

tab racegrp
			
collapse (sum) pop, by(racegrp male)
sort  racegrp male, stable

tabstat pop, stat(sum)

tempfile pop09_cen_2526
save `pop09_cen_2526'
save $outdata/cen_2526.dta, replace



* Read in psid_analytic and reweight
use "$outdata/psid_analytic.dta", clear
 
* Need lags for all people, no no new observations.
keep if year == 2009 & age >= 25 & age < 27
 
 
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

tab racegrp, m
tab male, m

					 
* Sum of weights
bys racegrp male: egen sumwt = total(weight) if died == 0
sort racegrp male, stable

* Merge with 2009 census projection
merge racegrp male, using `pop09_cen_2526'
qui count if _merge == 2
		 
if r(N) > 0 {
 	dis "Wrong, there are empty cells"
 	li racegrp male  mstat_cv if _merge == 2
 	exit(333)
}

drop _merge 
			 
qui sum weight if died==0
local oldsumwt = r(sum)

* Adjust the weights
replace weight = weight * pop / sumwt if `age_var' >= 25 & died == 0

* Keep only those 25-26, in 2009, and present in the survey
keep if age >=25 & age < 27 & year == 2009 & inyr == 1

* Expand the sample (parameter is set in expansion.makefile
di "`expand'"
multiply_persons `expand'

label data "Pop 25-26 in 2009 including new entrants, population size adjusted to 2009 Census weights"
save "$outdata/psid_all2009_pop_adjusted_2526", replace




