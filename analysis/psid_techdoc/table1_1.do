/* Comparison of PSID, HRS, NHIS, MEPS, MCBS, NHANES prevalence of chronic conditions (cancre, diabe, hearte, hibpe, lunge, stroke) and 
BMI (overweight, obese) by age groups.  
Include question wording for each source 

Years available:
PSID: 1999-2011
HRS: 1992-2008
MEPS: 2000-2010
MCBS: 2000-2010
NHIS: 1997-2009 
NHANES: 1999-2012
*/


clear all
set more off
include ../../fem_env.do

local tbl 1_1

tempfile psid hrs meps mcbs nhis nhanes

local sumvars cancre diabe hearte hibpe lunge stroke overwt obese

* Process PSID (2007, 2009, 2011)
use $outdata/psid_analytic.dta, clear
keep if year >= 2007
egen agecat = cut(aged), at(25,50,65,200)
collapse `sumvars' [aw=weight], by(agecat)
drop if missing(agecat)
gen src = 1
gen years = "2007-2011"
save `psid'

* Process HRS (2004, 2006, 2008)
use $outdata/hrs_analytic_recoded.dta, clear
keep if wave >= 7
cap drop agecat
egen agecat = cut(age_iwe), at(25,50,65,200)
collapse `sumvars' [aw=wtresp], by(agecat)
drop if missing(agecat)
gen src = 2
gen years = "2004-2008"
save `hrs'

* Process MEPS (2007-2010)
use $outdata/MEPS_cost_est.dta, clear
keep if yr >= 2007
egen agecat = cut(age), at(25,50,65,200)
collapse `sumvars' [aw=perwt], by(agecat)
drop if missing(agecat)
gen src = 3
gen years = "2007-2010"
save `meps'

* Process MCBS (2007-2010)
use $dua_mcbs_dir/mcbs_cost_est.dta, clear
keep if year >= 2007
egen agecat = cut(age), at(25,50,65,200)
collapse `sumvars' [aw=weight], by(agecat)
drop if missing(agecat)
gen src = 4
gen years = "2007-2010"
save `mcbs'

* Process NHIS (2007-2009)
use $outdata/FAM_nhis97plus_selected.dta, clear
keep if year >= 2007
egen agecat = cut(age), at(25,50,65,200)
collapse `sumvars' [aw=wtfa_sa], by(agecat)
drop if missing(agecat)
gen src = 5
gen years = "2007-2009"
save `nhis'

/*
* Process NHANES (2007-2010)
use $outdata/nhanes_selected.dta, clear
keep if year >= 2007 & year < 2011
egen agecat = cut(age_y), at(25,50,65,200)
* collapse `sumvars' [aw=wtmec2yr], by(agecat)
collapse `sumvars' , by(agecat)

drop if missing(agecat)
gen src = 6
gen years = "2007-2010"
save `nhanes'
*/


clear

foreach src in psid hrs meps mcbs nhis {
	append using ``src''
}

label define src 1 "PSID" 2 "HRS" 3 "MEPS" 4 "MCBS" 5 "NHIS" 
label values src src

label define agecat 25 "25-49" 50 "50-64" 65 "65+"
label values agecat agecat

sort agecat src

* Drop ages that we don't want to compre

* Under 50 and HRS
drop if agecat == 25 & src == 2
* Under 65 from MCBS
drop if agecat == 25 & src == 4
drop if agecat == 50 & src == 4

save data_compare.dta, replace








capture log close
