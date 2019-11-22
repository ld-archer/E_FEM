/* Summary of stock population */

clear all
set more off
include ../../../../../fem_env.do

local tbl 9_1

use $outdata/stock_psid_2009.dta, replace

*** Demographics ***

* Relationship status
forvalues x = 1/3 {
	cap drop mstat`x'
	gen mstat`x' = (mstat_new == `x') if !missing(mstat_new)
} 

* Education
forvalues x = 1/4 {
	cap drop educ`x'
	gen educ`x' = (educlvl == `x') if !missing(educlvl)
}

local demo male black hispan mstat1 mstat2 mstat3 educ1 educ2 educ3 educ4 

*** Health Conditions ***
forvalues x = 1/3 {
	gen smoke`x' = (smkstat == `x') if !missing(smkstat)
}
gen adl0 = (adlstat == 1) if !missing(adlstat)
gen adl1 = (adlstat == 2) if !missing(adlstat)
gen adl2 = (adlstat == 3) if !missing(adlstat)
gen adl3p = (adlstat == 4) if !missing(adlstat)
gen iadl0 = (iadlstat == 1) if !missing(iadlstat)
gen iadl1 = (iadlstat == 2) if !missing(iadlstat)
gen iadl2p = (iadlstat == 3) if !missing(iadlstat)

* BMI
gen overwt = (logbmi >= log(25) & logbmi < log(30)) if !missing(logbmi)
gen obese_1 = (logbmi >= log(30) & logbmi < log(35)) if !missing(logbmi)
gen obese_2 = (logbmi >= log(35) & logbmi < log(40)) if !missing(logbmi)
gen obese_3 = (logbmi >= log(25)) if !missing(logbmi)

local health hearte hibpe stroke lunge cancre diabe smoke1 smoke2 smoke3 adl0 adl1 adl2 adl3p iadl0 iadl1 iadl2p overwt obese_1 obese_2 obese_3

*** Program participation ***
local program  oasiclaim diclaim ssiclaim anyhi 

*** Economic outcomes: Working, earnings, wealth ***
forvalues x = 1/4 {
	cap drop work`x'
	gen work`x' = (workcat == `x') if !missing(workcat)
}

local econ work1 work2 work3 work4 iearnx hatotax

collapse (mean) `demo' `health' `program' `econ' [aw=weight]





outsheet using table`tbl'.csv, comma replace
export excel using techappendix.xlsx, sheetreplace sheet("Table `tbl'") firstrow(varlabels)




capture log close
