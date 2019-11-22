clear all

quietly include ../../../fem_env.do


import delimited using "../../../input_data/census_pop_estimates_02-18.csv", varnames(8)

* Loop through lettered vars and replace name with year label (plus v for type reasons)
foreach v of varlist (v2-v18) {
	local x : variable label `v'
	rename `v' v`x'
}

* Save modified file before dropping female
tempfile mf
save `mf'

* Data is structured in 2 tables, male on top and female on bottom. Work only 
* with male first, dropping female for now
drop if _n > 44

* Remove blank space
drop if missing(age)

* Generate male variable
gen male = 1

tempfile male
save `male'

use `mf', clear



/*
* Remove some characters from age string to make destring easier
replace age = subinstr(age, "+", "",.)
replace age = subinstr(age, "d", "",.)

* Remove 'Age ' from age string, destring
replace age = substr(age, 5, 2)
destring age, force replace

* Remove blank space
drop if missing(age)
/*
tempfile pop0218
save `pop0218'

import excel using ../../../input_data/ew_ppp_opendata2016.xlsx, clear firstrow

* Loop through lettered vars and replace name with year label (plus v for type reasons)
foreach v of varlist (C-CY) {
	local x : variable label `v'
	rename `v' v`x'
}

* Rename Age to age for merging later
rename Age age

* Encode Age variable so we can drop all ages under 50
encode age, gen(age_code)
* Drop ages under 50
drop if age_code < 51

* NEED TO COMBINE AGES 90+, THIS IS WRONG
drop if age_code > 91

sort Sex

merge 1:1 age using `pop0218'
