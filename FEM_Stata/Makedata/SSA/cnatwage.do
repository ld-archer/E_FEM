/* This file will produce the Average Wage Index file (cnatwage.dta) that is used when calculating AIME

*/


include common.do
 
 
* bring in 1951-2011 historic AWI
insheet using $indata/AWI_1951_2011.csv
 
* Need an observation for 1950
expand 2 if year == 1951

bys year: replace year = 1950 if year == 1951 & _n == 1 
 
* Need observations through 2060
expand 50 if year == 2011
 
bys year: replace year = 2011 + (_n - 1) if year == 2011 

/* Adjust AWI using Social Security Intermediate forecast from 2013 Trustees report

From: http://www.ssa.gov/oact/TR/TRassum.html

COLAs & AWI increases under
the intermediate assumptions
of the 2013 Trustees Report
 
Calendar year				COLA(percent)	Increase in AWI (percent)
2012								1.7						3.1
2013								2.0						1.7
2014								2.0						2.5
2015								2.5						4.5
2016								2.6						5.4
2017								2.7						5.5
2018								2.8						5.3
2019								2.8						5.0
2020								2.8						4.4
2021								2.8						4.1
2022 and later			2.8						3.9 (average increase)

*/

sort year
replace index = 1.031 * index[_n-1] if year == 2012 
replace index = 1.017 * index[_n-1] if year == 2013
replace index = 1.025 * index[_n-1] if year == 2014
replace index = 1.045 * index[_n-1] if year == 2015
replace index = 1.054 * index[_n-1] if year == 2016
replace index = 1.055 * index[_n-1] if year == 2017
replace index = 1.053 * index[_n-1] if year == 2018
replace index = 1.050 * index[_n-1] if year == 2019
replace index = 1.044 * index[_n-1] if year == 2020
replace index = 1.041 * index[_n-1] if year == 2021
replace index = 1.039 * index[_n-1] if year >= 2022


* To be consistent with previous files
rename year y60
rename index w

* Fill in the diagonal
forvalues x = 1950/2060 {
	* Fill in the diagonal
	gen w`x' = w if y60 == `x'
}

* Fill in the off-diagonal
forvalues x = 1950/2060 {
	egen w`x'_temp = max(w`x')
	replace w`x' = w`x'_temp
	drop w`x'_temp 
}
 
label data "Historic Average Wage Index from 1951-2011.  2012 through 2060 follow SSA Intermediate Assumptions."
 
save $outdata/cnatwage.dta, replace 
 
 capture log close
 
