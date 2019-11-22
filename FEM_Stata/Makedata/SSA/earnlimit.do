/* This file will produce the Social Security Earnings limit file (earnlimit.dta) that is used when calculating AIME

*/


include common.do


insheet using $indata/SS_max_1950_2013.csv


expand 48 if year == 2013
bys year: replace year = 2013 + (_n - 1) if year == 2013 

* For 2014 and later, use a 4.3% increase in the cap.  It isn't clear where this parameter estimate comes from.
sort year
replace cap = 1.043 * cap[_n-1] if year >= 2014

* Rename variables to be consistent with previous file
rename year yr


* Fill in the diagonal
forvalues x = 1950/2060 {
	* Fill in the diagonal
	gen c`x' = cap if yr == `x'
}

* Fill in the off-diagonal
forvalues x = 1950/2060 {
	egen c`x'_temp = max(c`x')
	replace c`x' = c`x'_temp
	drop c`x'_temp 
}


label data "Historic SS Income cap from 1950-2013.  2014+ use 4.3% annual growth."

save $outdata/earnlimit.dta, replace


capture log close
