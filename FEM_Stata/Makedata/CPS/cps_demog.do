/** \file This program creates a data file containing individual-
level demographic variables from the CPS.  The output can be used 
for reweighting the stock population and base cohort for new 25 -
26 year olds in the PSID-based simulation.
*/

include "../../../fem_env.do"

* Using CPS March 2009 supplement
* Codebook can be found here: http://www.census.gov/prod/techdoc/cps/cpsmar09.pdf
use `cps_dir'/cpsmar09/asec2009_pubuse.dta

*** Keep demographic variables and weight: 
* pehspnon = Are you Spanish, Hispanic, or Latino?
* prdthsp = follow-up to pehspnon: Mexican, Puerto Rican, Cuban, Central/South American, Other Spanish
* a_age = integer age in years if age under 80, 80 if age 80-84, and 85 if age 85+
* age1 = age bins: 2-year bins until age 25, then 5-year bins until age 60, then 2-year bins until age 65, then 5-year bin until age 70, then 75+ bin
keep p_stat prdtrace prdthsp pehspnon a_sex a_age age1 a_maritl marsupwt a_fnlwgt

*** Keep relevant population:
* Exclude Armed Forces population
drop if p_stat == 2
drop p_stat

*** Rename, recode, and derive new variables to match PSID/HRS/FEM:
* rename weight
* using a_fnlwgt instead of marsupwt because none of the March supplement (ASEC) variables are being used here
rename a_fnlwgt weight
label var weight "Person-level weight"
sum weight

* Sex
recode a_sex (2=0)
rename a_sex male
label variable male "Indicator for sex=male"
tab male, m
tab male [fw=round(weight)], m

/* Create the following race groups:
	1 Hispanic
  2 Non-Hispanic White
  3 Non-Hispanic black
  4 Other
*/
gen racegrp = 1 if pehspnon == 1
replace racegrp = 2 if pehspnon == 2 & prdtrace == 1
replace racegrp = 3 if pehspnon == 2 & prdtrace == 2
replace racegrp = 4 if missing(racegrp) & !missing(pehspnon) & !missing(prdtrace) 
label define racegrp_lbl 1 "Hispanic" 2 "Non-Hispanic White" 3 "Non-Hispanic black" 4 "Other"
label values racegrp racegrp_lbl
label variable racegrp "Race group"
bys pehspnon: tab racegrp prdtrace, m
tab racegrp [fw=round(weight)], m
drop pehspnon
drop prdthsp

* rename and label age variable
rename a_age age_yrs
label define age_lbl 80 "80-84" 85 "85+"
label values age_yrs age_lbl
label variable age_yrs "Age in years w/ bins for 80-84 and 85+"
tab age_yrs, m
tab age_yrs [fw=round(weight)], m

/* marital status
3 = married
2 = single or cohab
1 = widowed
Decision for ambiguous cases:
Separated (a_maritl==6) is still married (mstat=3)
*/
gen mstat_cv = 3 if inlist(a_maritl,1,2,3,6)
replace mstat_cv = 1 if a_maritl == 4
replace mstat_cv = 2 if inlist(a_maritl,5,7)
label define mstat_cv_lbl 3 "married" 2 "cohab or single, not widowed" 1 "widowed"
label values mstat_cv mstat_cv_lbl
label variable mstat_cv "Marital status"
tab mstat_cv a_maritl, m
tab mstat_cv [fw=round(weight)], m

label data "CPS March 2009 ASEC supplement demographics for all ages"
save $outdata/cps2009_demog.dta, replace

