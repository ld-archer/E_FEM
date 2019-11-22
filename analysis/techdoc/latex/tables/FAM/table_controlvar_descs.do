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

label var mstat1 "Single"
label var mstat2 "Cohabitating"
label var mstat3 "Married"

* Education
forvalues x = 1/4 {
	cap drop educ`x'
	gen educ`x' = (educlvl == `x') if !missing(educlvl)
}

label var educ1 "Less than high school"
label var educ2 "High school/GED/some college/AA"
label var educ3 "College graduate"
label var educ4 "More than college"


local demo male black hispan mstat1 mstat2 mstat3 educ1 educ2 educ3 educ4 

*** Health Conditions ***
forvalues x = 1/3 {
	gen smoke`x' = (smkstat == `x') if !missing(smkstat)
}

label var smoke1 "Never smoked"
label var smoke2 "Former smoker"
label var smoke3 "Current smoker"


gen adl0 = (adlstat == 1) if !missing(adlstat)
gen adl1 = (adlstat == 2) if !missing(adlstat)
gen adl2 = (adlstat == 3) if !missing(adlstat)
gen adl3p = (adlstat == 4) if !missing(adlstat)
gen iadl0 = (iadlstat == 1) if !missing(iadlstat)
gen iadl1 = (iadlstat == 2) if !missing(iadlstat)
gen iadl2p = (iadlstat == 3) if !missing(iadlstat)

label var adl0 "No ADL limitations"
label var adl1 "1 ADL limitation"
label var adl2 "2 ADL limitations"
label var adl3p "3 or more ADL limitations"

label var iadl0 "No IADL limitations"
label var iadl1 "1 IADL limitation"
label var iadl2p "2 or more IADL limitations"

cap drop overwt obese_1 obese_2 obese_3
gen overwt = (logbmi >= log(25) & logbmi < log(30)) if !missing(logbmi)
gen obese1 = (logbmi >= log(30) & logbmi < log(35)) if !missing(logbmi)
gen obese2 = (logbmi >= log(35) & logbmi < log(40)) if !missing(logbmi)
gen obese3 = (logbmi >= log(40)) if !missing(logbmi)

label var overwt "25 < BMI < 30"
label var obese1 "30 < BMI < 35"
label var obese2 "35 < BMI < 40"
label var obese3 "BMI > 40"

local health hearte hibpe stroke lunge cancre diabe smoke1 smoke2 smoke3 adl0 adl1 adl2 adl3p iadl0 iadl1 iadl2p overwt obese1 obese2 obese3

*** Program participation ***
local program  oasiclaim diclaim ssiclaim anyhi 

label var oasiclaim "Any Social Security income LCY"
label var diclaim "Any Disability income LCY"
label var ssiclaim "Any Supplemental Security Income LCY"
label var anyhi "Any health insurance LCY"

*** Economic outcomes: Working, earnings, wealth ***
forvalues x = 1/4 {
	cap drop work`x'
	gen work`x' = (workcat == `x') if !missing(workcat)
}

label var work1 "Out of labor force"
label var work2 "Unemployed"
label var work3 "Working part-time"
label var work4 "Working full-time"

* get variable labels for later merging
preserve
tempfile varlabs
descsave, list(name varlab) saving(`varlabs', replace)
use `varlabs', clear
rename name variable
* escape out underscore and create math environment for latex compatibility
* do it twice because some variable labels have the same character appearing twice
forvalues i=1/2 {
	replace varlab = regexr(varlab,"_","\_")
	replace varlab = regexr(varlab,"<=","$<=$")
	replace varlab = regexr(varlab," < "," $<$ ")
	replace varlab = regexr(varlab,">=","$>=$")
	replace varlab = regexr(varlab," > "," $>$ ")
}
keep variable varlab
li
save `varlabs', replace
restore

local econ work1 work2 work3 work4 iearnx hatotax

logout, save(controlvar_descs) dta replace: summ `demo' `health' `program' `econ' [aw=weight]

* the logout saves variable labels as the first observation
use controlvar_descs, clear
li
rowrename 1
drop if _n==1
drop v2 v3

* merge in variable lables instead of using variable names
rename v1 variable
li
gen order = _n
merge 1:1 variable using `varlabs'
drop if _merge==2
drop _merge
replace variable = varlab if varlab != ""
sort order
drop varlab order

#d ;
listtex using controlvar_descs.tex, replace rstyle(tabular) 
head(
"\begin{tabular}{lrrrr}"
" &  & Standard &  &  \\"
"Control variable & Mean & deviation & Minimum & Maximum\\"
"\hline"
)
foot("\end{tabular}")
;
#d cr

*export excel using techappendix.xls, sheetreplace sheet("Table 8") firstrow(varlabels)

exit, STATA clear

