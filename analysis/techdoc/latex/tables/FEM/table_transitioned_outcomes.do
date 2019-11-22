clear all
set more off
include ../../../../../fem_env.do

local filename = "$outdata/hrs" + "$firstwave" + "$lastwave" + "_transition.dta"
use `filename'

foreach v of varlist hearte hibpe stroke lunge cancre diabe dbclaim ssclaim diclaim {
  gen i`v' = `v'==1 & l2`v'==0
}

drop smoken smokev
tabulate smkstat, gen(smoke)

gen adl0 = !adl1 & !adl2 & !adl3p
gen iadl0 = !iadl1 & !iadl2p

replace work = . if age >= 75
replace idbclaim = . if !fanydb
replace issclaim = . if l2age < 60
replace idiclaim = . if l2age >= 63
replace anyhi = . if age >= 65
replace hatotax = . if !wlth_nonzero
replace iearnx = . if !work
replace hatotax = hatotax * 1000
replace iearnx = iearnx * 1000

local varsout1 ihearte ihibpe istroke ilunge icancre idiabe smoke1 smoke2 smoke3 logbmi adl0 adl1 adl2 adl3p iadl0 iadl1 iadl2p work idbclaim issclaim diclaim anyhi ssiclaim nhmliv died
local varsout2 hatotax iearnx
local varsout3 wlth_nonzero

recode `varsout1' `varsout2' `varsout3' (-2 9=.)

collapse (mean) `varsout1' (median) `varsout2' (mean) `varsout3'

xpose, clear varname
format v1 %10.2fc
rename _varname variable
tempfile summary
li
save `summary'

local octypes disease smoking logbmi adlstat iadlstat lfpben financial

foreach ot in `octypes' {
	di "Outcome table: `ot'"
	* select outcomes for summary stats
	insheet using transitioned_outcomes_`ot'_lblrows.csv, comma clear nonames
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
	listtex using transitioned_outcomes_`ot'.tex, replace rstyle(tabular) 
	;
#d cr
}

exit, STATA clear
