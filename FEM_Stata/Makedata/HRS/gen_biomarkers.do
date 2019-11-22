/*
Examine the biomarker data for 2006, 2008, 2010, 2012

HRS recommends using the "NHANES" adjusted values for the five measures developed here.
See: http://hrsonline.isr.umich.edu/sitedocs/userg/Biomarker2006and2008.pdf

Five measures:
a. Total cholesterol
b. HDL cholesterol, indicators of lipid levels
c. Glycosylated hemoglobin (HbA1c) – an indicator of glycemic control
over the past 2-3 months
d. C-reactive protein (CRP), a general marker of systemic inflammation
e. Cystatin C, an indicator of kidney functioning.

*/

quietly include common.do

local years 06 08 10 12
local begyr 2006
local endyr 2012

* What are we working with here?
foreach yr in `years' {
	use $hrs_sensitive/biomk`yr'bl_r.dta, replace
	desc
}

* Process 2006-2012
foreach yr in `years' {
	use $hrs_sensitive/biomk`yr'bl_r.dta, replace
	
	if inlist("`yr'","10","12") {
		rename *, lower  
		gen hhidpn = hhid + pn
		destring hhidpn, replace
	}
	
	destring hhid, replace
	
	if "`yr'" == "06" {
		gen wave = 8
		local pre k
	}
	if "`yr'" == "08" {
		gen wave = 9
		local pre l
	}
	if "`yr'" == "10" {
		gen wave = 10
		local pre m
	}
	if "`yr'" == "12" {
		gen wave = 11
		local pre n
	}

	* NHANES equivalent A1C
	rename `pre'a1c_adj a1c_adj

	* NHANES equivalent HDL
	rename `pre'hdl_adj hdl_adj 

	* NHANES equivalent total cholesterol
	rename `pre'tc_adj tc_adj

	* NHANES equivalent Cystatin C
	rename `pre'cysc_adj cysc_adj

	* NHANES equivalent crp
	rename `pre'crp_adj crp_adj
	
	* weight for biomarker analyses
	rename `pre'biowgtr biowgtr
		
	tempfile bio20`yr'
	save `bio20`yr''
}


* Check merges for consistency (2006 should repeat in 2010, 2008 should repeat in 2012)
use `bio2006', replace
* None should merge
merge 1:1 hhidpn using `bio2008'

use `bio2006', replace
count
* Many should merge
merge 1:1 hhidpn using `bio2010'

use `bio2006', replace
* None should merge
merge 1:1 hhidpn using `bio2012'

use `bio2008', replace
* None should merge
merge 1:1 hhidpn using `bio2010'

use `bio2008', replace
count
* Many should merge
merge 1:1 hhidpn using `bio2012'

use `bio2010', replace
* None should merge
merge 1:1 hhidpn using `bio2012'


clear
* Create a long file
forvalues yr = `begyr' (2) `endyr' {
	append using `bio`yr''
}

* Make a panel
xtset hhidpn wave

* Gen 4 year lagged variables
foreach var of varlist a1c_adj hdl_adj tc_adj cysc_adj crp_adj {
	gen l4`var' = L2.`var'
}

label var a1c_adj "NHANES adjusted A1C"
label var hdl_adj "NHANES adjusted HDL"
label var tc_adj "NHANES adjusted Total Cholesterol"
label var cysc_adj "NHANES adjusted Cystatin C"
label var crp_adj "NHANES adjusted CRP"
label var biowgtr "HRS biomarker sample weight"

label var l4a1c_adj "4 year lag of NHANES adjusted A1C"
label var l4hdl_adj "4 year lag of NHANES adjusted HDL"
label var l4tc_adj "4 year lag of NHANES adjusted Total Cholesterol"
label var l4cysc_adj "4 year lag of NHANES adjusted Cystatin C"
label var l4crp_adj "4 year lag of NHANES adjusted CRP"

* Summary stats
foreach var of varlist a1c_adj hdl_adj tc_adj cysc_adj crp_adj {
	bys wave: sum `var' [aw=biowgtr], detail
}

* Correlations
foreach var of varlist a1c_adj hdl_adj tc_adj cysc_adj crp_adj {
	corr `var' l4`var' [aw=biowgtr]
}

save $dua_rand_hrs/bio_`begyr'_`endyr'.dta, replace




* Eventually, move this to estimation directory
merge 1:1 hhidpn wave using ../../../input_data/hrs111_transition.dta

save $dua_rand_hrs/bio_transition.dta, replace


* Estimate some naive models
foreach var of varlist a1c_adj hdl_adj tc_adj cysc_adj crp_adj {
	reg `var' l4`var' l2age i.male##(i.black i.hispan) i.educ l2cancre l2diabe l2hearte l2hibpe l2lunge l2stroke [aw=biowgtr]
}


capture log close
