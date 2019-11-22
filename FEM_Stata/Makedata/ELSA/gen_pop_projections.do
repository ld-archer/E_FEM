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
* with male first, dropping female for now. Number44 is arbitrary, within gap 
* between sexes
drop if _n > 44

* Remove blank space
drop if missing(age)

* Generate male variable
gen male = 1
* temp save male
tempfile male
save `male'

* Back to original male and female
use `mf', clear

* drop male obs
drop if _n < 44

* Remove blank space
drop if missing(age)

* Generate male variable
gen male = 0

* temp save female
tempfile female
save `female'

* Back to male, append female to bottom
use `male', clear
append using `female'

* Reorder to bring male var to far left
order male

* Remove some characters from age string to make destring easier
replace age = subinstr(age, "+", "",.)
replace age = subinstr(age, "d", "",.)

* Remove 'Age ' from age string, destring
replace age = substr(age, 5, 2)
destring age, force replace

* Remove blank space
drop if missing(age)
* Sort for merging later
sort male age

* Make string into num, only this var (weird)
destring v2002, replace

* Temp save population estimates from 2002 to 2018
tempfile pop0218
save `pop0218'

* Import population projection data from 2016 onwards
import excel using ../../../input_data/en_ppp_opendata2016.xlsx, clear firstrow

* Loop through lettered vars and replace name with year label (plus v for type reasons)
foreach v of varlist (C-CY) {
	local x : variable label `v'
	rename `v' v`x'
}

* Rename Age to age and Sex to male for merging later
rename Age age
rename Sex male

* Sex == 2 means female, so replace with 0 now
replace male = 0 if male == 2

* Encode Age variable so we can drop all ages under 50
encode age, gen(age_code)
* Drop ages under 50
drop if age_code < 51

tempfile all_data
save `all_data'

* Keep only 90 and above for collapsing
keep if age_code > 90

* Combine by sex
collapse (sum) v*, by (male)

* Give back age var
gen age = "90"

* reorder for appending
order male age

* Temp save 90plus
tempfile 90p
save `90p'

* Back to all data
use `all_data', clear

* Drop data for ages 90+
drop if age_code > 90

* Add 90plus aggregate data in
append using `90p'

* Make age numeric
destring age, replace

sort male age

* No longer needed now age var is numeric
drop age_code

* Keep actual estimate data instead of using projections from 2016, more accurate?
drop v2016 v2017 v2018
* Save modified projections
tempfile clean_proj
save `clean_proj'

* Back to estimates 2002-2018
use `pop0218', clear

* Merge all data together to get estimates 2002-2018, then projections 2019-2116
merge 1:1 male age using `clean_proj'

* Check state of merge then drop
tab _merge
drop _merge

* reshape data to make single year variable
reshape long v, i(male age) j(year)

* reorder data for readability
order year age male

* Sort by year first, then age then male
sort year age male

save ../../../input_data/pop_projections.dta, replace
