/* This file will process the U.S. Census NP2012_D4: Projected Net International Migration by Single Year of Age, Sex, Race, and Hispanic Origin for the United States: 2012 to 2060

The raw file has annual net immigration projections by age, gender, and race/hispanicity.  For now, the file will produce net immigration by age and gender.

It should be able to process:
NP2012_D4 (the medium immigration forecast file)
NP2012C_D4 (the constant immigration forecast file)
NP2012L_D4 (the low immigration forecast file)
NP2012H_D4 (the high immigration forecast file)

See /nfs/sch-data1/data-library/public-data/Census/2012_Pop_Projection/methodstatement12.pdf for full details
*/


quietly include ../../../fem_env.do

insheet using "$census_dir/2012_Pop_Projection/NP2012C_D4.csv"

* Create and impute/extrapolate values for 2004-2011
forvalues x = 0/9 {
	forvalues y = 0/2 {
		expand 9 if race_hisp == `x' & sex == `y' & year == 2012
	}
}

bys year sex race_hisp: replace total_nim = . if _n > 1
forvalues z = 0/85 {
	bys year sex race_hisp: replace nim_`z' = . if _n > 1
}	

bys year sex race_hisp: replace year = 2013 - _n if year == 2012

sort sex race_hisp
by sex race_hisp: ipolate total_nim year, gen(utot) epolate
replace total_nim = utot if total_nim == .

forvalues z = 0/85 {
	by sex race_hisp: ipolate nim_`z' year, gen(u`z') epolate
	replace nim_`z' = u`z' if nim_`z' == .
}

* Expand observations through 2100, keeping immigration values at 2060 level
forvalues x = 0/9 {
	forvalues y = 0/2 {
		expand 41 if race_hisp == `x' & sex == `y' & year == 2060
	}
}
bys year sex race_hisp: replace year = 2101 - _n if year == 2060

sort year sex race_hisp


* Only want immigration for all races and then by male and female
keep if race_hisp == 0
keep if sex == 1 | sex == 2
gen male = (sex == 1)

* Reshape to have a file with age, male, net immigration
reshape long nim_, i(year male) j(age)

keep year male age nim_
rename nim_ net_migration
sort year male age


save test.dta, replace
outsheet using immigration.txt, replace

capture log close
