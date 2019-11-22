/* Summary stats for the estimation sample for outcomes we transition*/

clear all
set more off
quietly include ../../../../../fem_env.do

local tbl 2_1

use $outdata/psid_transition.dta


foreach v of varlist oasiclaim diclaim {
  gen i`v' = `v'==1 & l2`v'==0
}

drop smoken smokev
tabulate smkstat, gen(smoke)


gen adl0 = (adlstat == 1) if !missing(adlstat)
gen iadl0 = (iadlstat == 1) if !missing(iadlstat)


* Out of labor force, unemployed, part-time, full-time
forvalues x = 1/4 {
	gen work`x' = (workcat == `x') if !missing(workcat)
}


replace ioasiclaim = . if l2age < 60
replace idiclaim = . if l2age >= 63
replace anyhi = . if age >= 65
replace hatotax = . if !wlth_nonzero
replace hatotax = hatotax * 1000

* Relationship status
forvalues x = 1/3 {
	gen mstat`x' = (mstat_new == `x') if !missing(mstat_new)
} 

* Incident births 
forvalues x = 1/3 {
	local y = `x' - 1
	gen ibirth`y' = (births == `x') if !male
	replace ibirth`y' = (paternity == `x') if male
}

local varsout1 iheart ihibpe istroke ilunge icancre idiabe smoke1 smoke2 smoke3 logbmi adl0 adl1 adl2 adl3p iadl0 iadl1 iadl2p work1 work2 work3 work4 ioasiclaim diclaim anyhi ssiclaim educ1 educ2 educ3 educ4 mstat1 mstat2 mstat3 ibirth0 ibirth1 ibirth2
local varsout2 hatotax iearn_pt iearn_ft
local varsout3 wlth_nonzero

recode `varsout1' `varsout2' `varsout3' (-2 9=.)
collapse (mean) `varsout1' (median) `varsout2' (mean) `varsout3'

outsheet using table`tbl'.csv, replace comma
export excel using techappendix.xlsx, sheetreplace sheet("Table `tbl'") firstrow(varlabels)

* Need to handle died using HRS/PSID pooled sample

exit, STATA clear



















capture log close
