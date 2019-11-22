/** \file Computes the adjustment factors required for the "obs80" scenario.
The adjustment factor for each obesity category will be applied in each time 
step starting with 2004.  The goal is to bring prevalence down to 1978 levels 
by 2030. 
*/

include "../../../fem_env.do"

use $outdata/nhanes.dta

drop year
gen year=1978 if cohort=="nhanes1976"
replace year=2004 if inlist(cohort, "nhanes2003")
drop if missing(year)

* Following Ruhm
gen age4656 = age_yrs >= 46 & age_yrs < 57 if !missing(age_yrs)
keep if age4656==1

* only working with BMI derived from self-report
gen wtstate3 = inrange(bmi_sr, 30, 35) if !missing(bmi_sr)
gen wtstate4 = inrange(bmi_sr, 35, 40) if !missing(bmi_sr)
gen wtstate5 = bmi_sr >= 40 if !missing(bmi_sr)

* get 1978 and 2004 prevalences
collapse (mean) wtstate* hibpe diabe smoken [pw=intw_wght], by(year)
expand 2 if year==2004, gen(raterow)
replace year=. if raterow==1

* generate annual rate of change required to get 1978 prevalences by 2030 starting in 2004
* solving for r in prev2004*(1+r)^26 = prev1978
foreach v in wtstate3 wtstate4 wtstate5 hibpe diabe smoken {
	replace `v' = exp((log(`v'[1]) - log(`v'[2]))/26) - 1 if raterow==1
}
preserve
drop raterow
li
* save table for technical appendix
save $outdata/obs80_adj_table.dta, replace

* create adjustment factors for each year in obs80 scenario
restore
keep if raterow==1
drop year raterow
gen year = 2004
expand 27
replace year = year + _n - 1
foreach v in wtstate3 wtstate4 wtstate5 hibpe diabe smoken {
	rename `v' p`v'
	replace p`v' = (1+p`v')^(year-2004)
}

* save file that can be merged in the new51 cohort generation for obs80 scenario
save $outdata/obs80_adjustments.dta, replace

