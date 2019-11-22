/** \file This program creates a data file containing individual-
level demographic variables from the ACS.  The output can be used 
for reweighting the stock population and base cohort for new 25 -
26 year olds in the PSID-based simulation.

- December 2015 - extending this file to also keep education categories.  Currently focused on:
 1. Less than high school/GED
 2. High school/some college/AA
 3. Bachelors
 4. Masters

*/

include "../../../fem_env.do"

* Using 2009 ACS
use `acs_dir'/Stata/population_2009.dta

*** Keep demographic variables and weight: 
keep RAC* hisp sex agep mar rel serialno pwgtp schl

*** Rename, recode, and derive new variables to match PSID/HRS/FEM:
rename pwgtp weight
sum weight

* Sex
gen male = 1 if sex == "1"
replace male = 0 if sex == "2"
label variable male "Indicator for sex=male"
tab male sex, m
tab male [fw=round(weight)], m
drop sex

/* Create the following race groups:
	1 Hispanic
  2 Non-Hispanic White
  3 Non-Hispanic black
  4 Other
*/
gen racegrp = 1 if hisp != "01" & !missing(hisp)
replace racegrp = 2 if RAC1P == "1" & hisp == "01" & !missing(RAC1P)
replace racegrp = 3 if RAC1P == "2" & hisp == "01" & !missing(RAC1P)
replace racegrp = 4 if missing(racegrp) & !missing(RAC1P) & !missing(hisp)
label define racegrp_lbl 1 "Hispanic" 2 "Non-Hispanic White" 3 "Non-Hispanic black" 4 "Other"
label values racegrp racegrp_lbl
label variable racegrp "Race group"
tab racegrp RAC1P if hisp != "01" & !missing(hisp), m
tab racegrp RAC1P if hisp == "01", m
tab racegrp [fw=round(weight)], m
drop RAC*

* rename and label age variable
rename agep age_yrs
label variable age_yrs "Age in years (top coded)"
tab age_yrs, m
tab age_yrs [fw=round(weight)], m

* define marital status in ACS to match PSID definition
include acs_define_marstat.do
rename mstat_new mstat_cv
tab mstat_cv mar, m
tab mstat_cv [fw=round(weight)], m
drop mar rel serialno

* code education
destring schl, replace
gen educlvl = .
replace educlvl = 1 if inrange(schl,1,15) | schl == 17 & !missing(schl)
replace educlvl = 2 if inlist(schl,16,18,19,20) & !missing(schl)
replace educlvl = 3 if inlist(schl,21) & !missing(schl)
replace educlvl = 4 if inlist(schl,22,23,24) & !missing(schl)

label define educlvl 1 "Less than HS/GED" 2 "HS/somecoll/AA" 3 "4 year college" 4 "Masters+"
label values educlvl educlvl
label var educlvl "Education level"

label data "ACS 2009 demographics for all ages"
save $outdata/acs2009_demog.dta, replace

