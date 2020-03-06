clear all

quietly include ../../../fem_env.do

* Name of the scenario
local file : env scen

log using reweight_ELSA_stock_`file'.log, replace

*use ../../../input_data/cross_validation/ELSA_stock_`file'.dta, clear
use $outdata/cross_validation/ELSA_stock_`file'.dta, clear

drop if age < 51

* Merge the stock population with the projections by sex, age and year
*merge m:1 male age year using ../../../input_data/pop_projections.dta, keep(matched)
merge m:1 male age year using $outdata/pop_projections.dta, keep(matched)

if "`file'" == "CV" {
	keep if year == 2006
} 
else {
	keep if year == 2012
}

* Check the merge
tab _merge
drop _merge

* Generate the weighting var from cross-sectional weight var
gen weight = .

* Nested for loops to calculate the denominator and in turn the weight value
forvalues age = 51/90 {
	forvalues male = 0/1 {
		sum cwtresp if age == `age' & male == `male'
		scalar denom = r(sum)
		replace weight = (cwtresp * v)/denom if age == `age' & male == `male'
	}
}

if "`file'" == "base" {
	*saveold ../../../input_data/ELSA_stock.dta, replace v(12)
	saveold $outdata/ELSA_stock.dta, replace v(12)
} 
else if "`file'" == "CV" {
	*saveold ../../../input_data/ELSA_stock_`file'.dta, replace v(12)
	saveold $outdata/ELSA_stock_`file'.dta, replace v(12)
} 
else {
	*saveold ../../../input_data/ELSA_stock_`file'.dta, replace v(12)
	saveold $outdata/ELSA_stock_`file'.dta, replace v(12)
}

capture log close
