/*
The goal with this file is to assess the assigned distributions for new 25-26 year olds compared to the original
estimation sample
*/

use ../input_data/new25_2009_default.dta

gen group = 1

append using ../input_data/age2530_psid2009.dta
replace group = 2 if group == .

label var group "Simulant or Real"
label define group 1 "Simulant" 2 "Real"
label values group group

* Keep only the 25 and 26 year olds in the estimation sample
drop if age >= 27 & group == 2

* For some reason we have a shift in the education variables
replace educlvl = educlvl + 1 if group == 2



*** Compare the distributions of variables we assign

*** Binary and ordered
foreach var of varlist educlvl wtstate smkstat mstat_new work hibpe {
	di "Testing `var'"
	tab `var' group, col chi2
}


*** Continuous
foreach var of varlist iearnx hatotax logbmi {
	di "Testing `var'"
	ksmirnov `var', by(group)
}


save new25_dist_analysis.dta, replace



capture log close
