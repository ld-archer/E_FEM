/* This will generate a 1999 stock population and a 1999 stock population for for use in crossvalidation.  It will select
half of the sample for use in simulation 

We won't worry about reweighting to the full US 1999 population, as this exercise is for internal 
consistency. 

*/

quietly include common.do

use $outdata/psid_analytic.dta, replace

keep if year == 1999
do kludge.do

gen entry = 1999
replace l2age = age-2 if missing(l2age)

count

* Drop any cases with missing values
drop if missing(l2age)
drop if missing(iearn)

* Clean up vars
quietly include drop_vars.do

* Kludge of variables that aren't in 1999
foreach var of varlist l2k6score k6score satisfaction proptax srh births paternity l2cohab l2births l2paternity l2died l2iearn l2hicap l2hicap_nonzero {
	replace `var' = 0 if missing(`var')
}

compress

* Full file for simulation 1999 through present
if(floor(c(version))>=14) {
	saveold $outdata/stock_psid_1999.dta,replace v(12)
}
else{
	saveold $outdata/stock_psid_1999.dta,replace
}

* Half-sample using crossvalidation IDs
merge 1:1 hhidpn using $outdata/psid_crossvalidation.dta
tab _merge
keep if _merge == 3
drop _merge
keep if simulation == 1

if(floor(c(version))>=14) {
	saveold $outdata/stock_psid_crossvalidation_1999.dta,replace v(12)
}
else{
	saveold $outdata/stock_psid_crossvalidation_1999.dta,replace
}

capture log close
