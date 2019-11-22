*prints out numbers of new marriages, divorces, widowhood by gender and age groups from ACS data
*this works for ACS years 2008-2012 (before 2008 marhm,marhw,marhd were not asked)
*uses putexcel command, which doesn't seem to work w stata12 (ok w stata 13)

local ACSyr : env ACSYEAR

log using acs_new_marriages_`ACSyr'.log, replace

use "/nfs/sch-data-library/public-data/ACS/Stata/population_`ACSyr'.dta"

svyset [pw=pwgtp], sdr(pwgtp1 - pwgtp80) vce(sdr)

gen agecat=1 if agep<25
replace agecat=2 if agep>=25&agep<35
replace agecat = 3 if agep>=35 & agep<45
replace agecat = 4 if agep>=45 & agep<55
replace agecat = 5 if agep>=55 & agep<65
replace agecat = 6 if agep>=65 & agep <.

*First excel row where data will be written into
loc i 2

*tabulate new marriages for all ages
svy: tabulate sex marhm, count format(%12.0fc)
matrix prop = e(b)
matrix counts = e(N_pop)*prop
putexcel C`i'=matrix(counts) using ACS_new_marriages, sheet("`ACSyr'") modify
matrix drop prop counts

loc ++i

*tabulate new marriages for each age cat
forv j=1/6 {
	di "Tabulating for agecat `j'"
	svy: tabulate sex marhm if agecat==`j', count format(%12.0fc)
	matrix prop = e(b)
	matrix counts = e(N_pop)*prop
	putexcel C`i'=matrix(counts) using ACS_new_marriages, sheet("`ACSyr'") modify
	matrix drop prop counts
	loc ++i
}


*tabulate new divorces for all ages
svy: tabulate sex marhd, count format(%12.0fc)
matrix prop = e(b)
matrix counts = e(N_pop)*prop
putexcel C`i'=matrix(counts) using ACS_new_marriages, sheet("`ACSyr'") modify
matrix drop prop counts

loc ++i

*tabulate new divorces for each age cat
*loc i 10
forv j=1/6 {
	di "Tabulating for agecat `j'"
	svy: tabulate sex marhd if agecat==`j', count format(%12.0fc)
	matrix prop = e(b)
	matrix counts = e(N_pop)*prop
	putexcel C`i'=matrix(counts) using ACS_new_marriages, sheet("`ACSyr'") modify
	matrix drop prop counts
	loc ++i
}


*tabulate new widowhood for all ages
svy: tabulate sex marhw, count format(%12.0fc)
matrix prop = e(b)
matrix counts = e(N_pop)*prop
putexcel C`i'=matrix(counts) using ACS_new_marriages, sheet("`ACSyr'") modify
matrix drop prop counts

loc ++i

*tabulate new widowhood for each age cat

forv j=1/6 {
	di "Tabulating for agecat `j'"
	svy: tabulate sex marhw if agecat==`j', count format(%12.0fc)
	matrix prop = e(b)
	matrix counts = e(N_pop)*prop
	putexcel C`i'=matrix(counts) using ACS_new_marriages, sheet("`ACSyr'") modify
	matrix drop prop counts
	loc ++i
}

macro drop i

/* Create a .dta file of incidence summaries */
rename agecat agegrp
gen male = 1 if sex == "1"
replace male = 0 if sex == "2"


* incidence dummies
gen new_married = 1 if marhm=="1"
replace new_married = 0 if marhm=="2"

gen new_divorce = 1 if marhd=="1"
replace new_divorce = 0 if marhd=="2"

gen new_widowed = 1 if marhw=="1"
replace new_widowed = 0 if marhw=="2"

tempfile tfile1

* summarize population
preserve
#d ;
collapse 
(mean) imarried=new_married (mean) idivorce=new_divorce (mean) iwidowed=new_widow
(sum) t_imarried=new_married (sum) t_idivorce=new_divorce (sum) t_iwidowed=new_widow
[pw=pwgtp]
;
#d cr
save `tfile1'

* summarize by sex
restore
preserve
#d ;
collapse 
(mean) imarried=new_married (mean) idivorce=new_divorce (mean) iwidowed=new_widow
(sum) t_imarried=new_married (sum) t_idivorce=new_divorce (sum) t_iwidowed=new_widow
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
(mean) imarried=new_married (mean) idivorce=new_divorce (mean) iwidowed=new_widow
(sum) t_imarried=new_married (sum) t_idivorce=new_divorce (sum) t_iwidowed=new_widow
[pw=pwgtp]
, by(male agegrp);
#d cr

append using `tfile1'
save `tfile1', replace

sort male agegrp 

gen year=`ACSyr'

saveold ACS_marriage_incidence_`ACSyr'.dta, replace 

