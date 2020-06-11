clear

quietly include fem_env.do

* First import the census projection data
import excel using $outdata/UKpop2011.xlsx, firstrow
*import excel using ../../../input_data/UKpop2011.xlsx, firstrow

* Collapse the LAD (geography) codes focussed on the ethnicities and sum grouped data
collapse (sum) M* F*, by(ETH)

* Drop unnecessary columns
drop MB FB

* Temporarily save cleaned dataset
tempfile cleandata
save `cleandata'

* Keep only male for now
keep ETH M* 

* Compute sum for the row of all male vars
egen M_total=rowtotal(M*)
* Keep only the ethnicity and total vars
keep ETH M_total

* Temp save male data
tempfile maletotal
save `maletotal'

* Back to clean data
use `cleandata', clear
* Keep only female
keep ETH F*

* Compute sum
egen F_total=rowtotal(F*)
* Drop unnecessary cols
keep ETH F_total

*Tempfile for female?
tempfile femaletotal
save `femaletotal'

* Go back to male temp data
use `maletotal', clear
* Merge 
merge ETH using `femaletotal'

* Check how the merge went
tabulate _merge
* Drop _merge column after checking
drop _merge

* Generate boolean var for ethnicity. white - 1, non-white - 0
* strpos checks where a substring exists in string, returns position of
* substring. Therefore, if return value > 0, substring is present
generate white = strpos(ETH, "WBI") > 0
replace white = 1 if strpos(ETH, "WHO") > 0

* Collapse all white and non-white together
collapse (sum) M* F*, by(white)
* Sort by white, descending
gsort -white 
drop white

* Now something a bit weird:
* Need to flatten the dataset, to bring all 4 values into one line (for later)
* Therefore, its easiest to transpose the dataset, build a dummy var and 
* swap these 2 vars around
xpose, clear

* generate total for the observation (previously variable before xpose)
egen total = rowtotal(v1 v2)

* Calculate the proportion of the total for each value and replace
replace v1 = v1 / total
replace v2 = v2 / total

* No longer need total
drop total

* duplicate data
expand 2

* Build dummy var to help swap observations around
gen change = _n
replace change = 0 if change < 3
replace change = 1 if change > 2

* Swap the obs
replace v1 = v2 if change == 1

*Drop columns no longer needed
drop v2 change

rename v1 eth_prop

* Save the output for later in the script
tempfile ethnic_prop
save `ethnic_prop'

* Duplicate and stack the ethnic proportions to prepare for merging later
local i = 0
while `i'<50 {
	append using `ethnic_prop'
	local i = `i' + 1
}

save `ethnic_prop', replace
clear

* Create kron matrix
matrix kron = (1,1 \ 1,0 \ 0,1 \ 0,0)
* Print kron
matrix list kron
* Save kron matrix as dataset
svmat int kron
* Change variable names
rename kron1 Male
rename kron2 White

tempfile kron
save `kron'

* Loop through 50 iter, append kron matrix on top of each other
* This is to build the kronecker notation needed for reweighting matrices
local i = 0
while `i'<50 {
	append using `kron'
	local i = `i' + 1
}

* Now save full kron matrix over `kron'
save `kron', replace


* Read in population projection data
import excel using $outdata/ew_ppp_opendata2016.xlsx, clear firstrow
*import excel using input_data/ew_ppp_opendata2016.xlsx, clear firstrow
*tempfile popproj 
*save `popproj'

* Loop through lettered vars and replace name with year label (plus v for type reasons)
foreach v of varlist (C-CY) {
	local x : variable label `v'
	rename `v' v`x'
}

* Encode Age variable so we can drop all ages under 50
encode Age, gen(Age_code)
* Drop ages under 50
drop if Age_code < 51

* group by Sex, collapse all
collapse (sum) v*, by(Sex)

* Drop columns with odd years (ELSA only has every 2 years, even)
drop *1 *3 *5 *7 *9

* Duplicate projection data
expand 2

* Stack variables on top of each other into one 
stack v*, into(pop_proj) clear

* sort by _stack var (maintains 1,2,1,2 ordering of pop_proj)
sort _stack

* Drop the stacking var
drop _stack
* Save in tempfile
tempfile ppp_50
save `ppp_50'

clear

* Set number of observations, then gen sequence of years from 2016 to 2116
set obs 101
egen years = seq(), f(2016) t(2116)

* Generate boolean for even and odd (odd = 1)
gen odd = mod(years, 2)
* Keep if even (odd=0) and drop odd var
keep if odd==0
drop odd

* Duplicate all observations 4 times and sort to put them together
expand 4
sort years

* Combine years and kron_full to produce completed kronecker notation
merge using `kron'
drop _merge
gen pop = 0

tempfile kron_years
save `kron_years'

* Merge population projection data with kron
merge using `ppp_50'
tab _merge
drop _merge

* Add ethnic_proportion var to dataset
merge using `ethnic_prop'
tab _merge
drop _merge

* Replace pop with projection count * ethnic_proportion
replace pop = pop_proj * eth_prop
* Drop unnecessary cols
drop pop_proj eth_prop

* Save the output
save $outdata/ethpop_projections.dta, replace
*save input_data/ethpop_projections.dta, replace
