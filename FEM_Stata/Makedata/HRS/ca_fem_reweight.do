/* Reweight the simulation files to California Department of Finance population numbers *

stock_hrs_2010 -> stock_hrs_ca_2010
new51s_status_quo -> new51s_status_quo_ca
*/

quietly include common.do
local age_var age_yrs


*************************************
*** Reweight the stock population ***
*************************************

use $outdata/ca_dof.dta, replace

keep if year == 2010 & age >= 51
* only want even years for FEM
keep if mod(year,2) == 0
			
egen agec = cut(age), at(51,55,60,65,70,75,80,85,200)
tab age agec if age >= 51, m
gen agegrp = age
replace agegrp = agec if age >= 75 | racegrp == 4
			
collapse (sum) pop, by( agegrp racegrp male)
sort  agegrp racegrp male, stable
tempfile capop10
save `capop10'


use $outdata/stock_hrs_2010.dta, replace	

drop racegrp agec agegrp sumwt

* Race/ethnicity
gen racegrp = 1 if hispan == 1 
replace racegrp = 2 if hispan == 0 & white == 1 
replace racegrp = 3 if hispan == 0 & black == 1
replace racegrp = 4 if hispan == 0 & white == 0 & black == 0

egen agec = cut(`age_var'), at(51,55,60,65,70,75,80,85,200)
gen agegrp = `age_var'
replace agegrp = agec if `age_var' >= 75 | racegrp == 4
				 
* Sum of weights
bys agegrp racegrp male: egen sumwt = total(weight) if died == 0
sort agegrp racegrp male, stable
		 
* Merge with 2010 CA population projection
merge m:1 agegrp racegrp male using `capop10'
count if _merge == 2
list agegrp racegrp male if _merge==2
		 
if r(N) > 0 {
	dis "Wrong, there are empty cells"
	exit(333)
}
drop _merge 
			 
qui sum weight if died == 0 
local oldsumwt = r(sum)

* Adjust the weights
replace weight = weight * pop / sumwt if `age_var' >= 51 & died == 0 

label data "Pop 51+ in 2010, population size adjusted to California DOF projection"

saveold $outdata/stock_hrs_ca_2010.dta, v(12) replace


********************************************
*** Reweight the replenishing population ***
********************************************
use $outdata/ca_dof.dta, replace

keep if inlist(age,51,52)
* only want even years for FEM
keep if mod(year,2) == 0
			
gen agegrp = age
			
collapse (sum) pop, by( agegrp racegrp male year)
sort  agegrp racegrp male year, stable
tempfile capop5152
save `capop5152'


use $outdata/new51s_status_quo.dta, replace
* Race/ethnicity
gen racegrp = 1 if hispan == 1 
replace racegrp = 2 if hispan == 0 & white == 1 
replace racegrp = 3 if hispan == 0 & black == 1
replace racegrp = 4 if hispan == 0 & white == 0 & black == 0

gen agegrp = `age_var'
				 
* Sum of weights
bys agegrp racegrp male year: egen sumwt = total(weight) if died == 0
sort agegrp racegrp male year, stable
		 
* Merge with 2010 CA population projection
merge m:1 agegrp racegrp male year using `capop5152'
count if _merge == 2
list agegrp racegrp male year if _merge==2
		 
if r(N) > 0 {
	dis "Wrong, there are empty cells"
	exit(333)
}
drop _merge 
			 
qui sum weight if died == 0 
local oldsumwt = r(sum)

* Adjust the weights
replace weight = weight * pop / sumwt if `age_var' >= 51 & died == 0 
replace weight = 0 if missing(weight)

label data "Pop 51-52 replenishing cohorts with population size adjusted to California DOF projection"

saveold $outdata/new51s_status_quo_ca.dta, v(12) replace




capture log close
