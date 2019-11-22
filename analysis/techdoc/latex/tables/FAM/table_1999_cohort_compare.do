/* The goal with this program is to simulate a full PSID cohort from 1999 through present.  We will compare
forecasted outcomes to PSID and to external data sources: NHANES, NHIS, MEPS, MCBS, and HRS at appropriate ages */

clear all
quietly include ../../../../../fem_env.do

* reference year to keep populations comparable
local refyear = 1999

* Control min year and max year for plotting
local minyr 1999
local maxyr 2013

* Process simulation output
use ../../../../../output/psid_stock_cohort_1999/psid_stock_cohort_1999_summary.dta, replace
keep p_cancre_all p_diabe_all p_hearte_all p_hibpe_all p_lunge_all p_stroke_all a_bmi_all year

rename p_cancre_all cancre
rename p_diabe_all diabe
rename p_hearte_all hearte
rename p_hibpe_all hibpe
rename p_lunge_all lunge
rename p_stroke_all stroke
rename a_bmi_all bmi

tempfile fam
save `fam'


*** Process PSID (25+ in 1999, 27+ in 2001, ...) ***
use $outdata/psid_analytic.dta, replace

keep if age >= (year - `refyear' + 25)

collapse age male cancre diabe hearte hibpe lunge stroke bmi [aw=weight], by(year)

tempfile psid
save `psid'


*** Process NHANES (25+ in 1999, 27+ in 2001, ...) ***
use $outdata/nhanes.dta, replace

drop bmi
rename bmi_sr bmi
rename age_yrs age

keep if year >= `refyear'

keep if age >= (year - `refyear' + 25)
collapse age male diabe hearte hibpe bmi [aw=intw_wght], by(year)

tempfile nhanes
save `nhanes'

*** Process NHIS (25+ in 1999, 27+ in 2001, ...) ***
use $outdata/nhis97plus_selected.dta, replace

* drop weird bmi values (WHY ARE THESE CODED THIS WAY???)
count if bmi > 99 & !missing(bmi)
drop if bmi > 99 & !missing(bmi)

gen male = (sex == 1)

keep if year >= `refyear'

keep if age >= (year - `refyear' + 25)
collapse age male cancre diabe hearte hibpe lunge stroke bmi [aw=wtfa_sa], by(year)

tempfile nhis
save `nhis'

* Process MEPS (25+ in 1999, 27+ in 2001, ...)
use $outdata/MEPS_cost_est.dta, replace

keep if year >= `refyear'

keep if age >= (year - `refyear' + 25)
collapse age male cancre diabe hearte hibpe lunge stroke bmi [aw=perwt], by(year)

tempfile meps
save `meps'

/* Process MCBS (25+ in 1999, 27+ in 2001, ...)


* Process HRS (51+ in 1998, 53+ in 2001, ...) */




* Put the pieces together
clear

use `fam'
gen src = "fam"

foreach file in psid nhanes nhis meps {
	append using ``file''
	replace src = "`file'" if missing(src)
}

reshape wide age male cancre diabe hearte hibpe lunge stroke bmi, i(year) j(src) string



* Plots
foreach dis in cancre diabe hearte hibpe lunge stroke bmi {
	
	* Initialize the label
	local dis_lab "`dis'"
	
	if "`dis'" == "cancre" {
		local dis_lab "Cancer"
	}
	if "`dis'" == "diabe" {
		local dis_lab "Diabetes"
	}
	if "`dis'" == "hearte" {
		local dis_lab "Heart Disease"
	}
	if "`dis'" == "hibpe" {
		local dis_lab "Hypertension"
	}
	if "`dis'" == "lunge" {
		local dis_lab "Lung Disease"
	}
	if "`dis'" == "stroke" {
		local dis_lab "Stroke"
	}
	if "`dis'" == "bmi" {
		local dis_lab "BMI"
	}
	
	
	#d ;
	twoway 	line `dis'fam year if year <= `maxyr' ||
					line `dis'psid year if year <= `maxyr' ||
					line `dis'nhanes year if year <= `maxyr' ||
					line `dis'nhis year if year <= `maxyr' ||
					line `dis'meps year if year <= `maxyr'
					,
					saving(`dis'_`minyr'_`maxyr'.gph, replace)
					legend(
						label(1 "`dis_lab' FAM")
						label(2 "`dis_lab' PSID")
						label(3 "`dis_lab' NHANES")
						label(4 "`dis_lab' NHIS")
						label(5 "`dis_lab' MEPS")
					)
	;
	#d cr
}


* Export to pdf
foreach dis in cancre diabe hearte hibpe lunge stroke bmi {
	graph use `dis'_`minyr'_`maxyr'.gph, scheme(s1mono)
	graph export ../../FAM/img/`dis'_`minyr'_`maxyr'.pdf, replace 
}




capture log close
