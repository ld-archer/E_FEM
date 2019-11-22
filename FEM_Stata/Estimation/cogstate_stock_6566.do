/** \file
 cognitive_stock_6566.do estimates the stock model for assigning
 cogstate at age 65-66.
*/

clear all
cap clear mata
clear matrix
set mem 500m
set more off
set seed 52432
set maxvar 10000
est drop _all

/*********************************************************************/
*	SEP UP DIRECTORIES
/*********************************************************************/

* Assume that this script is being executed in the FEM_Stata/Estimation_2 directory

* Load environment variables from the root FEM directory, three levels up
* these define important paths, specific to the user

include "../../fem_env.do"

* Define paths

local defmod : env suffix

dis "Current time is: " c(current_time) " on " c(current_date)

if !missing("`defmod'"){
	local ster "$local_path/Estimates/`defmod'"
}
else {
  di "The cogstate_stock6566 script now requires a suffix input"
  error
}

*** set this to memrye to include memrye as covariate
global memrye memrye

use $outdata/hrs_selected
merge m:1 hhidpn using "$outdata/crossvalidation.dta" , keepusing(transition)
drop if _m==2

* make some dummies
*
   gen obese = (logbmi >= log(30) & !missing(logbmi))
   gen underwt = (logbmi < log(18.5) & logbmi > 0 & !missing(logbmi))
   label var obese "whether obese (bmi>=30)"
   label var underwt "whether under-weight (bmi<18.5)"
   tab obese underwt, missing

   gen anyiadl = (iadlstat>1) & !missing(iadlstat)
   tab iadlstat anyiadl, missing

global demvars male hsless college black hispan 
global medvars diabe hearte stroke lunge cancre hibpe
global adlvars anyiadl
global bmivars underwt obese

global allvars  cogstate $demvars $adlvars $bmivars $medvars smoken weight

*** if age 65 to 66

gen flag_stock6566 = age >= 65 & age < 67 & cogstate < . & wave >= 4 & weight > 0 & !missing(weight) & died==0

tabstat $allvars if flag_stock6566, statistics(n, mean, sd, min, median, max) col(statistics) casewise

global covA $demvars $memrye $adlvars smoken
global medvarsB diabe stroke

oprobit cogstate $covA $medvarsB [pw=weight] if flag_stock6566
ch_est_title "Stock cognitive state coefficients"
mfx2, nose stub(cogstate_stock)
est save "`ster'/cogstate_stock.ster", replace
est restore cogstate_stock_mfx
ch_est_title "Stock cognitive state marginal effects"
est store cogstate_stock_mfx

*for cross validation
oprobit cogstate $covA $medvarsB [pw=weight] if flag_stock6566 & transition==1
est save `ster'/crossvalidation/cogstate_stock.ster, replace

// Stata 15 + xml_tab + ordered outcomes = ERROR
if(floor(c(version))>=14) {
  local drops drop(cut*)
}
else {
  local drops
}


xml_tab cogstate_stock_*, save(`ster'/cogstate_stock.xls) sheet(cogstate_stock) replace pvalue `drops'

* also write estimates as a sheet in the master file with all other estimates
xml_tab cogstate_stock_*, save("`ster'/FEM_estimates_table.xml") append sheet(cogstate_stock) pvalue `drops'


exit, STATA clear
