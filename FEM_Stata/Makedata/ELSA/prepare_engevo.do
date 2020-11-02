* This script will transform the ukevo2019.xls file into a format that can 
* be used to reweight FEM populations
capture log close

clear all

import excel "/home/luke/Documents/E_FEM_clean/E_FEM/input_data/engevo2019.xls", sheet("Table 1") cellrange(A5:U62) clear

* Empty 
drop C D E

* Rename a cell so we can destring properly
replace U = "105" if U == "105 & over"
destring U, replace

tempfile male_female
save `male_female'

* Keep only males
keep if _n > 21 & _n < 40
drop A

* Transpose so years are the variable names
xpose, clear

* Replace variables names with first row values (years). Then rename
nrow
rename _* yr*

* Generate age and gender columns and reorder the data
gen age = _n + 89
gen male = 1

order male age

tempfile male
save `male'

* Back to whole dataset
use `male_female'

* Do all the same again for females this time
keep if _n > 40
drop A
xpose, clear
nrow
rename _* yr*
gen age = _n + 89
gen male = 0
order male age
tempfile female
save `female'

* Now merge the 2 together and save as dta
append using `male'

* drop 2019 data as don't have data for ages 50-90 for 2019 (yet)
drop yr2019

* Save to input_data/
save ../../../input_data/engevo2019.dta, replace
*save $outdata/engevo2019.dta, replace
