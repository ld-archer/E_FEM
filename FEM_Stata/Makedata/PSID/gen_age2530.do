include common.do

use "$outdata/psid_analytic.dta", replace

preserve
count
keep if age >=25 & age < 30 & year == 1999 & inyr == 1
count
save "$outdata/age2530_psid1999.dta", replace

restore
count
preserve
keep if age >=25 & age < 30 & year == 2009 & inyr == 1
count
save "$outdata/age2530_psid2009.dta", replace

restore
count
preserve
keep if age >=25 & age < 27 & (year >= 2005 & year <= 2009) & inyr == 1
count
save "$outdata/age2526_psid0509.dta", replace

restore
count
preserve
keep if age >=25 & age < 27 & (year >= 2007 & year <= 2009) & inyr == 1
count
save "$outdata/age2526_psid0709.dta", replace
restore

count
preserve
keep if age >=25 & age < 30 & year >= 2005 & year <= 2011 & inyr == 1
count
save "$outdata/age2530_psid0511.dta", replace

restore
count
preserve
keep if age >=25 & age < 30 & year >= 2005 & year <= 2015 & inyr == 1
count
save "$outdata/age2530_psid0515.dta", replace

capture log close