*tabulates marriage status from ACS data 
*this works for ACS years 2005-2012
*uses putexcel command, which doesn't seem to work w stata12 (ok w stata 13)

*the year we want marriage status prevalence for
local ACSyr : env ACSYEAR

log using acs_marriage_prevalence_`ACSyr'.log, replace

use "/nfs/sch-data-library/public-data/ACS/Stata/population_`ACSyr'.dta"

if 2005 <= `ACSyr' & `ACSyr' <= 2007 {
	include "acs_define_marstat05-07.do"
}
else if 2008 <= `ACSyr' & `ACSyr' <= 2012 {
	include "../../FEM_Stata/Makedata/ACS/acs_define_marstat.do"
}
else {
	di "Only supported for ACS years 2005-2012"
	* create an error when exiting to break make process
	gen dummy = 1
	exit
}

svyset [pw=pwgtp], sdr(pwgtp1 - pwgtp80) vce(sdr)

gen agecat=1 if agep<25
replace agecat=2 if agep>=25&agep<35
replace agecat = 3 if agep>=35 & agep<45
replace agecat = 4 if agep>=45 & agep<55
replace agecat = 5 if agep>=55 & agep<65
replace agecat = 6 if agep>=65 & agep <.

*i indicates Excel row where the data will be written into
loc i 3

*tabulate marriage status for all ages
svy: tabulate sex mstat_new, count format(%12.0fc)
matrix prop = e(b)
matrix counts = e(N_pop)*prop
putexcel B`i'=matrix(counts) using ACS_marriage_prevalence, sheet("`ACSyr'") modify
matrix drop prop counts

*tabulate marriage status for each age cat
loc ++i
forv j=1/6 {
	di "Tabulating for agecat `j'"
	svy: tabulate sex mstat_new if agecat==`j', count format(%12.0fc)
	matrix prop = e(b)
	matrix counts = e(N_pop)*prop
	putexcel B`i'=matrix(counts) using ACS_marriage_prevalence, sheet("`ACSyr'") modify
	matrix drop prop counts
	loc ++i
}

macro drop i

/* Create a .dta file of prevalence summaries */
rename agecat agegrp
gen male = 1 if sex == "1"
replace male = 0 if sex == "2"

* prevalence dummies
gen cur_married = mstat_new==3 if !missing(mstat_new)
gen cur_cohab = mstat_new==2 if !missing(mstat_new)
gen cur_single = mstat_new==1 if !missing(mstat_new)
gen cur_singlenwid = mstat_new==1 & widowed==0 & !missing(mstat_new) & !missing(widowed)
gen cur_widowed = widowed if !missing(widowed)

tempfile tfile1

* summarize population
preserve
#d ;
collapse 
(mean) pmarried=cur_married (mean) pcohab=cur_cohab (mean) psingle=cur_singlenwid (mean) pwidowed = cur_widowed
(sum) t_married=cur_married (sum) t_cohab=cur_cohab (sum) t_single=cur_singlenwid (sum) t_widowed = cur_widowed
[pw=pwgtp]
;
#d cr
save `tfile1'

* summarize by sex
restore
preserve
#d ;
collapse 
(mean) pmarried=cur_married (mean) pcohab=cur_cohab (mean) psingle=cur_singlenwid (mean) pwidowed = cur_widowed
(sum) t_married=cur_married (sum) t_cohab=cur_cohab (sum) t_single=cur_singlenwid (sum) t_widowed = cur_widowed
[pw=pwgtp]
, by(male);
#d cr
append using `tfile1'
save `tfile1', replace

* summarize by sex and age group
restore
preserve
#d ;
collapse 
(mean) pmarried=cur_married (mean) pcohab=cur_cohab (mean) psingle=cur_singlenwid (mean) pwidowed = cur_widowed
(sum) t_married=cur_married (sum) t_cohab=cur_cohab (sum) t_single=cur_singlenwid (sum) t_widowed = cur_widowed
[pw=pwgtp]
, by(male agegrp);
#d cr

append using `tfile1'
save `tfile1', replace

sort male agegrp

gen year=`ACSyr'

saveold ACS_marriage_prevalence_`ACSyr'.dta, replace 

