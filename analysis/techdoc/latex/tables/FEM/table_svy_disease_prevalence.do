/** \file table2.do This file is used to compute Table 2 of the technical appendix.
*/

clear all
set more off
include ../../../../../fem_env.do

tempfile hrs mcbs meps nhis

use $outdata/hrs_analytic_recoded.dta
drop if age < 55
gen ageLT65 = age < 65
collapse cancre hearte stroke diabe hibpe lunge overwt obese [aw=wtresp], by(ageLT65)
gen source = 1 if ageLT65
replace source = 4 if !ageLT65
save `hrs'

use $outdata/MEPS_cost_est
drop if age < 55
gen ageLT65 = age < 65
collapse cancre hearte stroke diabe hibpe lunge overwt obese [aw=perwt], by(ageLT65)
gen source = 3 if ageLT65
replace source = 7 if !ageLT65
save `meps'

use $outdata/nhis97plus_selected.dta
drop if age < 55
gen ageLT65 = age < 65
collapse cancre hearte stroke diabe hibpe lunge overwt obese [aw=wtfa_sa], by(ageLT65)
gen source = 2 if ageLT65
replace source = 5 if !ageLT65
save `nhis'

use $dua_mcbs_dir/mcbs_cost_est.dta
drop if age < 65
collapse cancre hearte stroke diabe hibpe lunge overwt obese [aw=weight]
gen source = 6

append using `hrs'
append using `meps'
append using `nhis'

* convert proportions to percentages
foreach v in cancre hearte stroke diabe hibpe lunge overwt obese {
	replace `v' = 100*`v'
}

label define source_lbl 1 "HRS (1991-2008, 55-64)" 2 "NHIS (1997-2010, 55-64)" 3 "MEPS (2000-2010, 55-64)" 4 "HRS (1991-2008, 65+)" 5 "NHIS (1997-2010, 65+)" 6 "MCBS (2000-2010, 65+)" 7 "MEPS (2000-2010, 65+)"

label values source source_lbl
label var source "Source (years, ages)"

tabout source using svy_disease_prevalence.tex, replace sum c(mean cancre mean hearte mean stroke mean diabe mean hibpe mean lunge mean overwt mean obese) clab(Cancer Heart_Diseases Stroke Diabetes Hypertension Lung_Disease Overweight Obese) ptotal(none) h2( & \multicolumn{8}{c}{Prevalence \%}\\) style(tex) format(0p)

exit, STATA clear
