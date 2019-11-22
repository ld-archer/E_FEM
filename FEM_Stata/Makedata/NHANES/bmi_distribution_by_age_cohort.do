/* \file This program assess BMI distribution for different cohorts, using NHANES survey data" 

*/
clear
clear mata
set more off
set mem 800m
set seed 5243212
set maxvar 10000

* Assume that this script is being executed in the FEM_Stata/Makedata/NHANES directory

* Load environment variables from the root FEM directory, three levels up
* these define important paths, specific to the user
include "../../../fem_env.do"

**** Read in NHANES BMI data
use "$outdata/nhanes_bmi.dta", clear
keep cohort cohort_88 male black hisp age bmxbmi weight_norm  exam_yr
rename hisp hispan
gen white =(hispan==0 & black==0)
sort cohort cohort_88 male black hispan white
drop if bmxbmi ==. 
keep if age >=50 & age <=55

* This is causing an error for 2015 data ... not sure why.  Will only keep through 2010, as that is what we've been using in FEM.  To do: assess what impact this has.
keep if exam_yr < 2011


****** List of cohorts
preserve
keep cohort cohort_88 exam_yr bmxbmi
sort cohort cohort_88
by cohort cohort_88: egen minyr = min(exam_yr)
by cohort cohort_88: egen maxyr = max(exam_yr)
gen minyr_coh = minyr - 55
gen maxyr_coh = maxyr - 50
collapse (count) grp_n=bmxbmi,by(cohort cohort_88)
list
restore

tempfile groups

******* Number different groups - compute bmi deciles for each individual, relative to their GENDER/RACE group
preserve
collapse (count) grp_n=bmxbmi,by(cohort cohort_88 male black hispan white)
gen grp = _n
local grpcnt = _N
*** Display number of age/cohort groups
di `grpcnt'
*** Distribution of number of individuals in each group
sum grp_n,detail
save "`groups'",replace
list
restore

merge m:1 cohort cohort_88 male black hispan white using "`groups'"
drop _merge 

forvalues x = 1/`grpcnt'{
	preserve
	keep if grp==`x'
	dis "Round: `x'"
	list if _n==1
	if _N < 20 {
		count
		display "Not enough observations"
		restore
		continue
	}
	xtile bmi_dec = bmxbmi [w=weight_norm],nquantile(10)
	keep cohort cohort_88 male black hispan white grp grp_n bmi_dec bmxbmi weight_norm
	if `x'==1 save "$outdata/NHANES_bmi_qtl_gr.dta",replace
	else {
		append using "$outdata/NHANES_bmi_qtl_gr.dta"
		save "$outdata/NHANES_bmi_qtl_gr.dta",replace
	}
	restore
}

******* Number different groups - compute bmi deciles for each individual, relative to their GENDER group

tempfile groups2
preserve
collapse (count) grp_n=bmxbmi,by(cohort cohort_88 male)
gen grp = _n+`grpcnt'
local grpcnt_gend = `grpcnt'+_N

*** Distribution of number of individuals in each group
sum grp_n,detail
save "`groups2'",replace
list
restore

drop grp grp_n
merge m:1 cohort cohort_88 male using "`groups2'"
drop _merge 

local beg=`grpcnt'+1
forvalues x = `beg'/`grpcnt_gend'{
	preserve
	keep if grp==`x'
	dis "Round: `x'"
	list if _n==1
	if _N < 20 {
		count
		display "Not enough observations"
		restore
		continue
	}
	xtile bmi_dec = bmxbmi [w=weight_norm],nquantile(10)
	keep cohort cohort_88 male grp grp_n bmi_dec bmxbmi weight_norm
	if `x'==1 save "$outdata/NHANES_bmi_qtl_gr.dta",replace
	else {
		append using "$outdata/NHANES_bmi_qtl_gr.dta"
		save "$outdata/NHANES_bmi_qtl_gr.dta",replace
	}
	restore
}

use "$outdata/NHANES_bmi_qtl_gr.dta",clear
sort cohort cohort_88 male black hispan white grp grp_n bmi_dec
collapse (mean) bmi_avg=bmxbmi ,by(cohort cohort_88 male black hispan white grp grp_n bmi_dec)
sum bmi_avg grp_n,detail
label var bmi_avg "Avearge BMI within decile associated to gender/race group at age 50-55" 
label var bmi_dec "BMI Decile"

save "$outdata/NHANES_bmi_cohort_qtls.dta",replace
