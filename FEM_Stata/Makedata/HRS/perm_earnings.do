/* This file will use the restricted Social Security data to construct measures of income.
	Measures will ideally include:
		Current earnings (as reported)
		Current earnings (uncapped using a tobit model)
		Earnings up to age 50 (sum, as reported)
		Earnings up to age 50 (sum of uncapped using tobit models)
		Total permanent earnings in a given year
		Total permanent earnings in a given year (sum of uncapped using a tobit model
		*/

quietly include common.do


* make a vector of the SSA taxable maximum values
use $indata/ssa_cap.dta, replace
mkmat taxmax, mat(ssa_cap) rownames(year)
matlist ssa_cap



* Check if file exists with RAND HRS and SSA data
capture confirm file $dua_rand_hrs/perm_earnings.dta
* If not, create it
if _rc > 0 {
	use $hrs_restrict/XSumErn.dta
	destring HHIDPN, gen(hhidpn)
	drop HHIDPN
	merge 1:1 hhidpn using $rand_hrs, keepusing(hhidpn rabyear ragender inw*)
	save $dua_rand_hrs/perm_earnings.dta, replace
}

use $dua_rand_hrs/perm_earnings.dta, replace

gen trans_elig = ((inw4 == 1 & inw5 ==1) | (inw5 == 1 & inw6 == 1) | (inw6 == 1 & inw7 == 1) | (inw7 == 1 & inw8 == 1) | (inw8 == 1 & inw9 == 1))

tab _merge
drop if _merge == 1
gen no_SSA = (_merge == 2)
label var no_SSA "No SSA records on XSumErn.dta file"
drop _merge

tab no_SSA

count if !missing(ERN2005) 


* Assess top-coding all years
forvalues yr = 1951/2005 {
	di "year is `yr'"
	* Respondents non-missing (includes zeroes)"
	count if !missing(ERN`yr')
	local count1 = r(N)
	di "SSA Cap is:"
	matlist ssa_cap[rownumb(ssa_cap,"`yr'"),1]
	di "Number at cap is:"
	count if ERN`yr' == ssa_cap[rownumb(ssa_cap,"`yr'"),1] & no_SSA == 0
	local count2 = r(N)
	di "Percent at cap:"
	di `count2'/`count1'
}

* Inflate/deflate earnings to 2004 dollars
egen cpicurrent = cpi(2004)
forvalues yr = 1951/ 2005 {
	egen cpi`yr' = cpi(`yr')
	* deal with values between $0.01 and $50 - coded to .n so set to $25
	replace ERN`yr' = 25 if ERN`yr' == .n
	replace ERN`yr' = ERN`yr'*(cpicurrent/cpi`yr')
}

drop cpi*

count if !missing(ERN2005)

* Earnings at age 50
tempvar age50yr
gen `age50yr' = rabyear + 50
sum `age50yr', detail

gen fern = .
forvalues yr = 1951/ 2005 {
	replace fern = ERN`yr' if `age50yr' == `yr'
}

count if fern == . & no_SSA == 0
tab rabyear if fern == . & no_SSA == 0

tab ragender if fern == 0

* big years of missing values are birth year of 1942 and 1954 - they gave permission in either 1992 or [2004 or earlier], so only get previous records
tab SOURCE if rabyear == 1942 & fern == . & no_SSA == 0
tab SOURCE if rabyear == 1954 & fern == . & no_SSA == 0

* Age at last year of available data
gen maxage = LASTYR - rabyear
tab maxage
* flag those under age 50 
gen under50_maxage = (maxage < 51)

gen yearage20 = rabyear + 20
gen yearage30 = rabyear + 30
gen yearage40 = rabyear + 40
gen yearage50 = rabyear + 50

gen ERNage40 = 0
gen ERNage50 = 0
gen years40 = 0
gen years50 = 0

forvalues yr = 1951/2005 {
	replace ERNage40 = ERNage40 + ERN`yr' if `yr' < yearage40
	replace years40 = years40 + 1 if `yr' < yearage40
}

forvalues yr = 1951/2005 {
	replace ERNage50 = ERNage50 + ERN`yr' if `yr' < yearage50
	replace years50 = years50 + 1 if `yr' < yearage50
}

save $dua_rand_hrs/perm_earnings_temp.dta, replace


* Keep if we have SSA records
keep if no_SSA == 0
* Keep if we will estimate transition models
keep if trans_elig == 1



* Generate measures of permanent earnings

* 20-50 if not left- or right-censored
gen flag2050 = (rabyear >= 1931 & maxage >= 50)
gen perm2050 = 0
forvalues yr = 1951/2005 {
	replace perm2050 = perm2050 + ERN`yr' if flag2050 == 1 & yearage50 >= `yr' & yearage20 <= `yr'
}
replace perm2050 = . if flag2050 == 0

* 30-50
gen flag3050 = (rabyear >= 1921 & maxage >= 50)
gen perm3050 = 0
forvalues yr = 1951/2005 {
	replace perm3050 = perm3050 + ERN`yr' if flag3050 == 1 & `yr' <= yearage50 & yearage30 <= `yr'
}
replace perm3050 = . if flag3050 == 0

* 40-50
gen flag4050 = (rabyear >= 1911 & maxage >= 50)
gen perm4050 = 0
forvalues yr = 1951/2005 {
	replace perm4050 = perm4050 + ERN`yr' if flag4050 == 1 & `yr' <= yearage50  & yearage40 <= `yr'
}
replace perm4050 = . if flag4050 == 0

* 30-40
gen flag3040 = rabyear >= 1921 & maxage >= 40
gen perm3040 = 0
forvalues yr = 1951/2005 {
	replace perm3040 = perm3040 + ERN`yr' if flag3040 == 1 & yearage40 >= `yr' & yearage30 <= `yr'
}
replace perm3040 = . if flag3040 == 0


* Generate percentiles
xtile pct2050 = perm2050, n(100)
xtile pct3050 = perm3050, n(100)
xtile pct4050 = perm4050, n(100)
xtile pct3040 = perm3040, n(100)


save $dua_rand_hrs/perm_earnings_temp.dta, replace

/* To do:
		
		Generate permanent earnings at age 50
		Assess data availability for current earnings (some only gave permission through 1992)
		
		Tobit model for top-coded values (age, race, sex, education, ???)
		*/




/* Notes:

 Covered earnings include wages or self-employment income earned in a job covered
         by Social Security. In order to preserve respondent confidentiality, Annual
         Covered Earnings data have been rounded as specified in the governing MOU:
         
         1. A code of zero (0) represents a true zero dollar amount.
         
         2. A code of .N represents an amount between $0.01 and $49.99 dollars,
         inclusive.
         
         3. Amounts greater than or equal to $50 dollars and less than or equal to the
         statutory maximum were rounded to the nearest $100 dollars; amounts ending in 01
         to 49 were rounded down, and amounts ending in 50 to 99 were rounded up.
         
         4. A code of .M represents a year in which no earnings information was obtained
         for this respondent.
         
         */








capture log close
