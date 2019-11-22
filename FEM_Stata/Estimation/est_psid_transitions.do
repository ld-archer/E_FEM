clear all
set more off
set mem 800m
set mat 1000

include "../../fem_env.do"

* Define paths
global workdir "$local_path/Makedata/HRS"
use "$outdata/PSIDfem", clear

keep if age03 >= 26 & age05 >= 26 & age07 >= 26

count
global c = r(N)
global c1 = $c + 1
expand 2
generate year = .
replace year = 2005 in f/$c
replace year = 2007 in $c1/l

generate head = head03 & head05 & head07
generate wife = wife03 & wife05 & wife07
drop if (head==0) & (wife==0)

gen blackNH = black03 & !hispanic03
gen hispanic = hispanic03
gen otherNH = !hispanic03 & (native03 | asian03 | hawaii03)
gen male = male03

global conditions diabetes hypertension cancer heartdisease lungdisease
* Define the transition variables
foreach var in $conditions {
  gen `var'_diag = .
}

generate lagbmi25p = .
replace lagbmi25p = bmi03 > 25 if year==2005
replace lagbmi25p = bmi05 > 25 if year==2007

gen ind_wgt = .
replace ind_wgt = ind_wgt03 if year==2005
replace ind_wgt = ind_wgt05 if year==2007

foreach var in $conditions {
  replace `var'_diag = 0 if `var'03==0 & `var'05==0 & year==2005
  replace `var'_diag = 1 if `var'03==0 & `var'05==1 & year==2005
  replace `var'_diag = 0 if `var'05==0 & `var'07==0 & year==2007
  replace `var'_diag = 1 if `var'05==0 & `var'07==1 & year==2007
}

global constvarlist male blackNH otherNH hispanic
global dynvarlist single widow medicalexpends smoke hlthstatus age educ
foreach var in $dynvarlist {
  generate lag`var' = .
  replace lag`var' = `var'03 if year==2005
  replace lag`var' = `var'05 if year==2007
}
global laglist $laglist lagbmi25p

generate laghighschoolGrad = lageduc == 12
generate lagsomeCollege = lageduc == 13 | lageduc == 14 | lageduc == 15
generate lagcollegeGrad = lageduc == 16 | lageduc == 17

global laglist lagsingle lagwidow lagmedicalexpends lagsmoke laghlthstatus lagage laghighschoolGrad lagsomeCollege lagcollegeGrad

log using "psid_incidence_probits.log", replace
desc $constvarlist $laglist
foreach var in $conditions {
  probit `var'_diag $constvarlist $laglist [pweight=ind_wgt]
}
log close
