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
}
else if "`scen'" == "base_nosmoke" {
	*saveold ../../../input_data/ELSA_stock_CV.dta, replace v(12)
	saveold $outdata/ELSA_repl_nosmoke.dta, replace v(12)
}
else if "`scen'" == "base_nodrink" {
	saveold $outdata/ELSA_repl_nodrink.dta, replace v(12)
}



** Now generate some new repls for no loneliness and/or social isolation
preserve

* First remove loneliness and leave everything else
replace lnly = 1
replace lnly1 = 1
replace lnly2 = 0
replace lnly3 = 0
replace l2lnly = 1
replace l2lnly1 = 1
replace l2lnly2 = 0
replace l2lnly3 = 0
saveold $outdata/ELSA_repl_nolnly.dta, replace v(12)

restore
preserve

* Now remove social isolation and leave everything else
replace sociso = 1
replace sociso1 = 1
replace sociso2 = 0
replace sociso3 = 0
replace sociso4 = 0
replace sociso5 = 0
replace sociso6 = 0
replace l2sociso = 1
replace l2sociso1 = 1
replace l2sociso2 = 0
replace l2sociso3 = 0
replace l2sociso4 = 0
replace l2sociso5 = 0
replace l2sociso6 = 0
saveold $outdata/ELSA_repl_nosociso.dta, replace v(12)

restore
preserve

* Now remove both
replace lnly = 1
replace lnly1 = 1
replace lnly2 = 0
replace lnly3 = 0
replace l2lnly = 1
replace l2lnly1 = 1
replace l2lnly2 = 0
replace l2lnly3 = 0
replace sociso = 1
replace sociso1 = 1
replace sociso2 = 0
replace sociso3 = 0
replace sociso4 = 0
replace sociso5 = 0
replace sociso6 = 0
replace l2sociso = 1
replace l2sociso1 = 1
replace l2sociso2 = 0
replace l2sociso3 = 0
replace l2sociso4 = 0
replace l2sociso5 = 0
replace l2sociso6 = 0
saveold $outdata/ELSA_repl_nolnlysociso.dta, replace v(12)

restore
preserve

* Now more realistic changes. 

* 'Realistic' social isolation change - reduce by 2 levels in single and widowed men
replace sociso = sociso - 2 if male == 1 & (widowed == 1 | single == 1) & sociso >= 3
replace l2sociso = l2sociso - 2 if male == 1 & (widowed == 1 | single == 1) & l2sociso >= 3
replace sociso1 = sociso == 1 if !missing(sociso)
replace sociso2 = sociso == 2 if !missing(sociso)
replace sociso3 = sociso == 3 if !missing(sociso)
replace sociso4 = sociso == 4 if !missing(sociso)
replace sociso5 = sociso == 5 if !missing(sociso)
replace sociso6 = sociso == 6 if !missing(sociso)
replace l2sociso1 = l2sociso == 1 if !missing(l2sociso)
replace l2sociso2 = l2sociso == 2 if !missing(l2sociso)
replace l2sociso3 = l2sociso == 3 if !missing(l2sociso)
replace l2sociso4 = l2sociso == 4 if !missing(l2sociso)
replace l2sociso5 = l2sociso == 5 if !missing(l2sociso)
replace l2sociso6 = l2sociso == 6 if !missing(l2sociso)
saveold $outdata/ELSA_repl_real_sociso.dta, replace v(12)

restore
preserve

* Now more realistic changes. 

* 'Realistic' social isolation change - reduce by 2 levels in men
replace sociso = sociso - 2 if male == 1 & (widowed == 1 | single == 1) & sociso >= 3
replace l2sociso = l2sociso - 2 if male == 1 & (widowed == 1 | single == 1) & l2sociso >= 3
replace sociso1 = sociso == 1 if !missing(sociso)
replace sociso2 = sociso == 2 if !missing(sociso)
replace sociso3 = sociso == 3 if !missing(sociso)
replace sociso4 = sociso == 4 if !missing(sociso)
replace sociso5 = sociso == 5 if !missing(sociso)
replace sociso6 = sociso == 6 if !missing(sociso)
replace l2sociso1 = l2sociso == 1 if !missing(l2sociso)
replace l2sociso2 = l2sociso == 2 if !missing(l2sociso)
replace l2sociso3 = l2sociso == 3 if !missing(l2sociso)
replace l2sociso4 = l2sociso == 4 if !missing(l2sociso)
replace l2sociso5 = l2sociso == 5 if !missing(l2sociso)
replace l2sociso6 = l2sociso == 6 if !missing(l2sociso)
saveold $outdata/ELSA_repl_real_sociso2.dta, replace v(12)


restore
preserve

* 'Realistic' loneliness change - reduce by 1 level in childless women?
replace lnly = lnly - 1 if male == 0 & childless == 1 & lnly > 1
replace l2lnly = l2lnly - 1 if male == 0 & childless == 1 & lnly > 1
replace lnly1 = lnly == 1 if !missing(lnly)
replace lnly2 = lnly == 2 if !missing(lnly)
replace lnly3 = lnly == 3 if !missing(lnly)
replace l2lnly1 = l2lnly == 1 if !missing(l2lnly)
replace l2lnly2 = l2lnly == 2 if !missing(l2lnly)
replace l2lnly3 = l2lnly == 3 if !missing(l2lnly)
saveold $outdata/ELSA_repl_real_lnly.dta2, replace v(12)

restore

* 'Realistic' loneliness change - reduce by 1 level in childless women?
replace lnly = lnly - 1 if male == 0 & lnly > 1
replace l2lnly = l2lnly - 1 if male == 0 & lnly > 1
replace lnly1 = lnly == 1 if !missing(lnly)
replace lnly2 = lnly == 2 if !missing(lnly)
replace lnly3 = lnly == 3 if !missing(lnly)
replace l2lnly1 = l2lnly == 1 if !missing(l2lnly)
replace l2lnly2 = l2lnly == 2 if !missing(l2lnly)
replace l2lnly3 = l2lnly == 3 if !missing(l2lnly)
saveold $outdata/ELSA_repl_real_lnly.dta, replace v(12)



capture log close 
