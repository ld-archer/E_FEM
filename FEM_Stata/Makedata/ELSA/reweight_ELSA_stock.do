clear all

quietly include ../../../fem_env.do

local scen : env scen

log using reweight_ELSA_stock_`scen'.log, replace

*use $outdata/ELSA_stock_base.dta, clear
*use ../../../input_data/ELSA_stock_base.dta, clear
use $outdata/ELSA_stock_`scen'.dta, clear
*use ../../../input_data/ELSA_stock_`scen'.dta, clear

* Changed this from 51. Previously dropping ~110 50 YO's
drop if age < 51

* Merge the stock population with the projections by sex, age and year
*merge m:1 male age year using ../../../input_data/pop_projections.dta, keep(matched)
merge m:1 male age year using $outdata/pop_projections.dta, keep(matched)

keep if year == 2012

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

replace weight = 0 if cwtresp == 0 | v == 0 

* Save all the different variants
if "`scen'" == "base" {
	*saveold ../../../input_data/ELSA_stock.dta, replace v(12)
	saveold $outdata/ELSA_stock.dta, replace v(12)
}
else if "`scen'" == "base_CV" {
	*saveold ../../../input_data/ELSA_stock_CV.dta, replace v(12)
	saveold $outdata/ELSA_stock_CV.dta, replace v(12)
}
else if "`scen'" == "base_nosmoke" {
	saveold $outdata/ELSA_stock_nosmoke.dta, replace v(12)
}
else if "`scen'" == "base_nodrink" {
	saveold $outdata/ELSA_stock_nodrink.dta, replace v(12)
}
else if "`scen'" == "base_noImpute" {
	saveold $outdata/ELSA_stock_noImpute.dta, replace v(12)
}



capture log close
