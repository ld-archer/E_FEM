include common.do

* Use the reweighted 2009 file
use "$outdata/psid_all2009_pop_adjusted", clear


* This deals with variables that are not yet cleaned or are missing in PSID
do kludge.do


* Save the file to be used in the simulation
keep if year == 2009
keep if inyr == 1 | died == 1
* Doing this before reweighting
* drop if newobservation == 1

gen entry = 2009

/* Script to get rid of variables that are "present in data, but not in simulation"*/
quietly include drop_vars.do

compress

if(floor(c(version))>=14) {
	saveold "$outdata/stock_psid_2009.dta",replace v(12)
}
else{
	saveold "$outdata/stock_psid_2009.dta",replace
}

* Save the age 51+ for comparison to HRS
keep if age >= 51

if(floor(c(version))>=14) {
	saveold "$outdata/stock_psid_2009_51plus.dta",replace v(12)
}
else{
	saveold "$outdata/stock_psid_2009_51plus.dta",replace
}

capture log close
