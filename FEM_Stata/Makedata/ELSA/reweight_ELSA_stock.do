clear all

quietly include ../../../fem_env.do

local scen : env scen

log using reweight_ELSA_stock_`scen'.log, replace


use $outdata/ELSA_stock_base.dta, clear
*use ../../../input_data/ELSA_stock_base.dta, clear

* If not base, one of the other populations
if "`scen'" != "base" {
	use $outdata/ELSA_stock_base_`scen'.dta, clear
}

* Changed this from 51. Previously dropping ~110 50 YO's
drop if age < 51

* Merge the stock population with the projections by sex, age and year
*merge m:1 male age year using ../../../input_data/pop_projections.dta, keep(matched)
merge m:1 male age year using $outdata/pop_projections.dta, keep(matched)

* Different populations are based on different years
if "`scen'" == "base" {
	keep if year == 2012	
}
else if "`scen'" == "CV1" | "`scen'" == "valid" {
	keep if year == 2004
}
else if "`scen'" == "CV2" {
	keep if year == 2010
}
else if "`scen'" == "min" | "`scen'" == "ROC" {
	keep if year == 2002
}

* Check the merge
tab _merge
drop _merge

* Generate the weighting var from cross-sectional weight var
gen weight = .

summ age
local max_age = r(max)

* Nested for loops to calculate the denominator and in turn the weight value
forvalues age = 51/`max_age' {
	forvalues male = 0/1 {
		sum cwtresp if age == `age' & male == `male'
		scalar denom = r(sum)
		replace weight = (cwtresp * v)/denom if age == `age' & male == `male'
	}
}

count if weight > 0
replace weight = 0 if cwtresp == 0 | v == 0 
count if weight > 0

* Some people (for CV scenarios) are missing cwtresp variable. Can't use these, must replace weight = 0
replace weight = 0 if missing(cwtresp)

* Save all the different variants
if "`scen'" == "base" {
	*saveold ../../../input_data/ELSA_stock.dta, replace v(12)
	saveold $outdata/ELSA_stock.dta, replace v(12)
	*do gen_bmi_stocks.do
}
else if "`scen'" == "CV1" {
	saveold $outdata/ELSA_stock_CV1.dta, replace v(12)
}
else if "`scen'" == "CV2" {
	saveold $outdata/ELSA_stock_CV2.dta, replace v(12)
}
else if "`scen'" == "min" {
	saveold $outdata/ELSA_stock_min.dta, replace v(12)
}
else if "`scen'" == "valid" {
	saveold $outdata/ELSA_stock_valid.dta, replace v(12)
}
else if "`scen'" == "ROC" {
	saveold $outdata/ELSA_stock_ROC.dta, replace v(12)
}



capture log close
