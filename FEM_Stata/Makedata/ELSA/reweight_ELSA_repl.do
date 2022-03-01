clear all

quietly include ../../../fem_env.do

local scen : env scen

log using reweight_ELSA_repl_`scen'.log, replace

*use ../../../input_data/ELSA_repl_base.dta, clear
*use $outdata/ELSA_repl_base.dta, clear
use $outdata/ELSA_repl_`scen'.dta, clear

* Merge the stock population with the projections by sex, age and year
*merge m:1 male age year using ../../../input_data/pop_projections.dta, keep(matched)
merge m:1 male age year using $outdata/pop_projections.dta, keep(matched)

* Check the merge
tab _merge
drop _merge

keep if inlist(age, 51, 52)

* Generate the weighting var from cross-sectional weight var 
gen weight = .
gen weight2 = .

* Nested for loops to calculate the denominator and in turn the weight value
forvalues age = 51/52 {
	forvalues male = 0/1 {
		forvalues year = 2012 (2) 2082 {
			sum cwtresp if age == `age' & male == `male' & year == `year'
			scalar denom = r(sum)
			replace weight = (cwtresp * v)/denom if age == `age' & male == `male' & year == `year'
		}
	}
}


* Reweighting by education
*merge m:1 male rbyr educ using ../../../input_data/education_data.dta
merge m:1 male rbyr educ using $outdata/education_data.dta

* Check the merge
tab _merge
drop _merge

* Nested loops over birth year, gender and education level for reweighting
forvalues rbyr = 1963/2031 {
	forvalues male = 0/1 {
		forvalues educ = 1/3 {
			sum weight if rbyr == `rbyr' & male == `male' & educ == `educ'
			scalar denom2 = r(sum)
			replace weight2 = (weight * total)/denom2 if rbyr == `rbyr' &  male == `male' & educ == `educ'
		}
	}
}

* Replace weight with weight2 (further adjusted by education) if weight2 is present
replace weight = weight2 if !missing(weight2)
* No longer need weight2
drop weight2

* Check distribution of education levels, should match distribution by year 
* seen in education_data.dta
tab rbyr educ [aw=weight] if inrange(rbyr, 1963, 1982), row


* Set weight to 0 if missing cwtresp as in stock file
replace weight = 0 if missing(cwtresp)

* Now drop cwtresp and v as no longer needed
drop cwtresp v

*saveold ../../../input_data/ELSA_repl.dta, replace v(12)
*saveold $outdata/ELSA_repl.dta, replace v(12)

if "`scen'" == "base" {
	*saveold ../../../input_data/ELSA_stock.dta, replace v(12)
	saveold $outdata/ELSA_repl.dta, replace v(12)

	* Produce altered BMI populations for interventions
	*do gen_bmi_repls.do

	* Produce altered population for alcohol interventions
	do gen_alcohol_repl.do
}
else if "`scen'" == "base_nosmoke" {
	*saveold ../../../input_data/ELSA_stock_CV.dta, replace v(12)
	saveold $outdata/ELSA_repl_nosmoke.dta, replace v(12)
}
else if "`scen'" == "base_nodrink" {
	saveold $outdata/ELSA_repl_nodrink.dta, replace v(12)
}

capture log close 
