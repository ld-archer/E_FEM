clear
set more off
set mem 2000M
set maxvar 10000

include "../../../fem_env.do"


use $indata/CPS.dta

*********************************************
*** Create phsless and pcollege variables ***
*********************************************

keep if (year==2004 & age==51) | (year==2005 & age==51) | (year==2006 & age==51) | ///
        (year==2007 & age==51) | (year==2008 & age>=23 & age<=51) 
replace age=age-4 if year==2008
replace age=age-3 if year==2007
replace age=age-2 if year==2006
replace age=age-1 if year==2005

replace year=2055-age
sort year

gen hsless=0
replace hsless=1 if educ<=072
replace hsless=. if educ==999

gen college=0
replace college=1 if educ>=111 & educ<=125
replace college=. if educ==999

gen hsgrad=0
replace hsgrad=1 if !hsless & !college
replace hsgrad=. if educ==999

collapse (mean) hsless hsgrad college [aweight=wtfinl], by(year age)
gen phsless_04_tmp=hsless if year==2004
egen phsless_04=min(phsless_04_tmp)
gen phsless=hsless/phsless_04

gen phsgrad_04_tmp=hsgrad if year==2004
egen phsgrad_04=min(phsgrad_04_tmp)
gen phsgrad = hsgrad/phsgrad_04

gen pcollege_04_tmp=college if year==2004
egen pcollege_04=min(pcollege_04_tmp)
gen pcollege=college/pcollege_04

ren phsless peduc1
ren phsgrad peduc2
ren pcollege peduc3

keep year peduc2 peduc3
save $outdata/trend_educ.dta, replace

exit, STATA
