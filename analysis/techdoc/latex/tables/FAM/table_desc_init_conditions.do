clear all
set more off
include ../../../../../fem_env.do

use if entry==2004 using $outdata/new51s_status_quo
append using $dua_rand_hrs/age5055_hrs1992r
replace year = 1992 if missing(year)

tabulate smkstat, gen(smoke)
tabulate rdb_ea_c if fanydb, gen(earlyretire)
tabulate rdb_na_c if fanydb, gen(normalretire)

gen adl0 = adlstat==1
gen iadl0 = iadlstat==1

gen bmi = exp(logbmi) 
gen normalwt = bmi < 25
gen overwt = inrange(bmi, 25, 30)
gen obese1 = inrange(bmi, 30, 35)
gen obese2 = inrange(bmi, 35, 40)
gen obese3 = bmi >= 40

replace ssclaim = . if l2age < 60
replace diclaim = . if l2age >= 63
replace hatotax = . if !wlth_nonzero
replace iearnx = . if !work
replace hatotax = hatotax * 1000
replace iearnx = iearnx * 1000

local varsout work wlth_nonzero hibpe hearte diabe anyhi fshlt normalwt overwt obese1 obese2 obese3 smoke* adl0 iadl0 raime rq iearnx hatotax dcwlthx anydb anydc earlyretire* normalretire* hispan black male hsless college single widow cancre lunge stroke

collapse (mean) `varsout' [aw=weight], by(year)

xpose, clear varname
format v1 v2 %10.2fc
rename _varname variable
drop if variable=="year"
rename v1 year1992
rename v2 year2004
tempfile summary
li
save `summary'

* subtables to output
local octypes binary bmistat smoking funcstat continuous censcont censdiscrete earlyagedb normalagedb covars

foreach ot in `octypes' {
	di "Outcome table: `ot'"
	* select outcomes for summary stats
	insheet using desc_init_conditions_`ot'_lblrows.csv, comma clear nonames
	gen order=_n
	li
	rename v1 variable
	merge 1:1 variable using `summary'
	drop if _merge==2
	sort order
	li
	drop _merge variable order
			
	* output to latex table format
	#d ;
	listtex using desc_init_conditions_`ot'.tex, replace rstyle(tabular) 
	;
#d cr
}

exit, STATA clear
