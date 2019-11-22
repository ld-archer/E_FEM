/** \file The purpose of this file is to identify trends from the American Community Survey

	Trends at age 25 we'd like:
		Never married
		Marriage
		Cohabitation
		# children
		education
		live with parents (?)
		working 
		health insurance - only 2008+
	
\todo Fix marital status using the reported status from the ACS -- see ACS_define_marstat.do
*/

log using ACS_trends_final, text replace

quietly include "../PSID/common.do"


/* Variables of interest from population files:
	serialno - household identifier
	porder - person key
	rel - relation to reference person
	agep - age
	sex - gender
	paoc - presence and age of own children (women only)
	pwgtp - PUMS person weight
	schl - educational attainment
	oc - own child (biological child of householder)
	rc - related child (biological, adopted, or step of householder)
	msp - married, 
	uwrk - worked last week
	hicov - any health insurance coverage
	sfn - subfamily number
	srf - subfamily relationship
	sch - school enrollment, yes if 2 (public) or 3 (private)
	schg - grade in which currently enrolled *response code changes in 2008, see DataDict
	esr - employment status: 1/2 employed, 3 unemployed, 4/5 armed forces, 6 not in LF
	*/

* 

local minyr 2000
local maxyr 2014

local outcomes hsless ged hsgrad somecol twoyrdegree fouryrdegree graddegree single married cohab work ownchildren employed unemployed notLF student hrs_worked hdwf

forvalues yr = `minyr'/`maxyr' {
	* Use the ACS population file & harmonize variables
	use $acs_dir/Stata/population_`yr', replace
	
	* define the survey parameters for 2000-2002
	if `yr' >= 2000 & `yr' <= 2004 {
		svyset [pw=pwgtp]
	}
	else if `yr' >= 2005 & `yr' <= 2014 {
			svyset [pw=pwgtp], sdr(pwgtp1 - pwgtp80) vce(sdr)
	}

	* Rename work varible to match 2000-2008 name 
	if `yr' >= 2009 & `yr' <= 2014 {
			rename wrk uwrk
		}
		
	/* For 2006 and later, we need to drop those in group quarters to be consistent with PSID */
	if `yr' >= 2006 & `yr' <= 2007 {
		drop if rel == "13" | rel == "14"
	}
	else if `yr' >= 2008 & `yr' <= 2009 {
		drop if rel == "16" | rel == "17"
	}
	else if `yr' >= 2010 & `yr' <= 2014 {
		if `yr' > 2009 {
			rename relp rel
		}
		drop if rel == "16" | rel == "17"
	} 

	* Recode education
	if `yr' >= 2000 & `yr' <= 2002 {
		destring schl, replace
		gen hsless = (schl >= 1 & schl <= 8)
		gen hsgrad = (schl == 9)
		* Putting 'vocational/tech/bus' in somecol
		gen somecol = (schl == 10 | schl == 11)
		gen twoyrdegree = (schl == 12)
		gen fouryrdegree = (schl == 13)
		gen graddegree = (schl >= 14 & schl <= 16)
		gen ged = .
	}
	if `yr' >= 2003 & `yr' <= 2007 {
		destring schl, replace
		gen hsless = (schl >= 1 & schl <= 8)
		gen hsgrad = (schl == 9)
		gen somecol = (schl >= 10 & schl <= 11)
		gen twoyrdegree = (schl == 12)
		gen fouryrdegree = (schl == 13)
		gen graddegree = (schl >= 14 & schl <= 16)
		gen ged = .
	}
	else if `yr' >= 2008 & `yr' < = 2014 {
		destring schl, replace
		gen hsless = (schl >= 1 & schl <= 15)
		* Can now distinguish between HS and GED
		gen hsgrad = (schl == 16)
		gen ged = (schl == 17)
		
		gen somecol = (schl == 18 | schl == 19)
		gen twoyrdegree = (schl == 20)
		gen fouryrdegree = (schl == 21)
		gen graddegree = (schl >= 22 & schl <= 24)
	}


	* Recode relationship
	if `yr' >= 2000 & `yr' <= 2007 {
		gen cohab = (rel == "10")
	}
	else if `yr' >= 2008 & `yr' <= 2014 {
		gen cohab = (rel == "13")
	}	
	
	* Recode the common variables
	gen male = (sex == "1")
	gen work = (uwrk == "1")
	
	*generating employment status: employed (includes armed forces), unemployed, out of LF
	gen employed = 1 if esr=="1"|esr=="2"|esr=="4"|esr=="5"
	replace employed = 0 if employed == .
	gen unemployed = (esr == "3")
	gen notLF = (esr == "6")
	*identifying students not in LF as a separate category
	gen student = 1 if sch=="2"|sch=="3"
	replace student = 0 if student == . 
	*identifying hours worked
	gen hrs_worked=.
	replace hrs_worked=wkhp

	* Identify children in the household
	destring oc, replace
	destring rc, replace
	bys serialno: egen ownchildren = total(oc)
	bys serialno: egen relchildren = total(rc)
	
	tab ownchildren if rel == "00"
	tab relchildren if rel == "00"
	
	* Assign married flag to household head and husband/wife
	gen married = (rel == "01")
	bys serialno: egen married_hh = total(married)
	tab married
	replace married = 1 if married_hh == 1 & rel == "00"
	
	* Assign cohabitation status to person with rel = 00 if cohabitating
	bys serialno: egen cohab_hh = total(cohab)
	tab cohab_hh
	replace cohab = 1 if cohab_hh == 1 & rel == "00"

	* Assign single to those who are not married or cohabitating
	gen single = (married == 0 & cohab == 0)
	
	* compare single, married, cohab with ACS marital status variables
	tab mar married, m
	tab mar cohab, m
	tab mar single, m
	tab msp married, m
	tab msp cohab, m
	tab msp single, m
	
		* Define a head/wife/"wife" variable consistent with PSID
	gen hdwf = (rel == "00" | married == 1 | cohab == 1)
	
	tab hdwf if age >=25 & age <=26
	tab ownchildren if hdwf == 1
	tab relchildren if hdwf == 1

	tab ownchildren if hdwf == 1 & agep >= 25 & agep <= 26
	tab relchildren if hdwf == 1 & agep >= 25 & agep <= 26
	
	* Recode race (RAC1P, racblk, hisp)
	gen hispan = .
	replace hispan = 0 if hisp == "01" & !missing(hisp)
	replace hispan = 1 if hisp != "01" & !missing(hisp) 
	
	gen black = 0 if !missing(RAC1P)
	replace black = 1 if RAC1P == "2" & hispan == 0
	
	gen white = 0 if !missing(RAC1P)
	replace white = 1 if RAC1P == "1" & hispan == 0
	
	
	
	* Make the tempfiles to be appended for predictions
	* keep if hdwf == 1 & agep >= 25 & agep <= 26
	
	* Don't worry about head and wives only
	keep if agep >= 25 & agep <= 26
	
	gen year = `yr'
	keep year pwgtp `outcomes' male hispan black white
	tempfile acs_`yr'
	save `acs_`yr'', replace
		
}




clear all

forvalues yr = `minyr'/`maxyr' {
	append using `acs_`yr''
}

***Employment status variables***

*first 0/1 variable (not in school/in school)
*use student variable generated above

*second ordinal variable (0=out of labor force, 1=unemployed, 2=employed part-time, 3=employed full-time)
gen work_stat=.
replace work_stat=0 if notLF==1
replace work_stat=1 if unemployed==1
replace work_stat=2 if employed==1 & hrs_worked<30
replace work_stat=3 if employed==1 & hrs_worked>=30

/* Education variables - now doing four levels less than HS, high school/GED/some college/AA, college, graduate+ 
gen educ = .
replace educ = 1 if hsless == 1
* This only works for 2008 and later ...
replace educ = 1 if ged == 1

replace educ = 2 if hsgrad == 1
replace educ = 2 if somecol == 1
replace educ = 2 if twoyrdegree == 1
replace educ = 3 if fouryrdegree == 1
replace educ = 4 if graddegree== 1
*/

/* Education will be done in two stages:  
1. estimate less than college, college, MA+ on 2000-2014 data
2. estimate hsless/GED, HS/somecoll/AA on 2008-2014 data (where we can differentiate between GED and high school)
*/

gen educ_allyrs = .
* lowest category for 2000-2014 estimation (GED only defined for 2008 and later)
replace educ_allyrs = 1 if hsless == 1
replace educ_allyrs = 1 if ged == 1
replace educ_allyrs = 1 if hsgrad == 1
replace educ_allyrs = 1 if twoyrdegree == 1
* second category for 2000-2014 estimation
replace educ_allyrs = 2 if fouryrdegree == 1
* third category for 2000-2014 estimation
replace educ_allyrs = 3 if graddegree == 1

label define educ_allyrs 1 "hsless/ged/hsgrad/AA" 2 "BA" 3 "MA"
label values educ_allyrs educ_allyrs
label var educ_allyrs "three levels of education for estimating trends in BA and MA 2000-2014" 

gen educ_limyrs = .
* lowest category for 2008-2014 estimation (hsless and GED recipients)
replace educ_limyrs = 1 if hsless == 1
replace educ_limyrs = 1 if ged == 1
* second category for 2008-2014 estimation (HS, some college, and AA recipients)
replace educ_limyrs = 2 if hsgrad == 1
replace educ_limyrs = 2 if twoyrdegree == 1
* third category for 20008-2014 estimation (BA and MA)
replace educ_limyrs = 3 if fouryrdegree == 1
replace educ_limyrs = 3 if graddegree == 1

label define educ_limyrs 1 "hsless/ged" 2 "hsgrad/AA" 3 "BA/MA"
label values educ_limyrs educ_limyrs
label var educ_limyrs "three levels of education for estimating trends in hsless/GED and hs/somecoll 2008-2014"


* Number of children variables
gen kids = .
replace kids = 1 if ownchildren == 0
replace kids = 2 if ownchildren == 1
replace kids = 3 if ownchildren == 2
replace kids = 4 if ownchildren == 3
replace kids = 5 if ownchildren >= 4

* Relationship status variable
gen relstat = .
replace relstat = 1 if single == 1
replace relstat = 2 if cohab == 1
replace relstat = 3 if married == 1

* Move to two-stage relationship:  if partnered and then partnership type
gen partnered = (relstat == 2 | relstat == 3)
gen partnertype = .
replace partnertype = 0 if (relstat == 2)
replace partnertype = 1 if (relstat == 3)

* Since educ

save $outdata/ACS_data_workchanged.dta, replace

use $outdata/ACS_data_workchanged.dta

gen yr = year - 2000
tab work_stat, gen(work_stat)

label define work_stat 0 "notLF" 1 "unemp" 2 "part-time" 3 "full-time"
label values work_stat work_stat

gen working=0 if work_stat==0|work_stat==1
replace working=1 if work_stat==2|work_stat==3

*Probit for not in school/in school
probit student yr [pw = pwgtp] if year<=2008 & hdwf == 1
est store pstudent

label define relstat 1 "single" 2 "cohab" 3 "married"
label values relstat relstat

tab kids, gen(kids)

* Estimate the multinomial probit single/cohab/married model
mprobit relstat yr if hdwf == 1 [pw = pwgtp] 
est store mrelstat

* Estimate the number of kids model
oprobit kids yr if hdwf == 1 [pw = pwgtp]
est store mkids

* Estimate the education trends - restricting to years where we can assign GED to hsless category
* oprobit educ yr [pw = pwgtp] if inrange(year,2008,`maxyr')
* est store meduc_all

* Estimate the education trends - restricting to heads/wives and years where we can assign GED to hsless category
* oprobit educ yr [pw = pwgtp] if inrange(year,2008,`maxyr') & hdwf == 1
* est store meduc_hdwf

* Alternative 1 - Trend in BA and MA vs other for all years, trend in hsless/GED and HS/somcall for 2008 and later
oprobit educ_limyrs yr [pw = pwgtp] if inrange(year,2000,`maxyr')
est store meduc_limyrs_all2526

oprobit educ_allyrs yr [pw = pwgtp] if inrange(year,2008,`maxyr')
est store meduc_allyrs_all2526


* Alternative 2 - Trend in BA and MA vs other for all years, trend in hsless/GED and HS/somcall for 2008 and later, require people to be heads/wives
oprobit educ_limyrs yr [pw = pwgtp] if inrange(year,2000,`maxyr') & hdwf == 1
est store meduc_limyrs_hdwf

oprobit educ_allyrs yr [pw = pwgtp] if inrange(year,2008,`maxyr') & hdwf == 1
est store meduc_allyrs_hdwf


drop _all

local obs = 2050-2009+1
set obs `obs'
gen year = 2008 + _n
gen yr = year - 2000

est restore pstudent
predict pstudent

*replace pstudent with actual values until 2011
replace pstudent=18.3 if year==2009
replace pstudent=19.7 if year==2010
replace pstudent=19.7 if year==2011

*gen pworking using actual values until 2011, and CBO projections 2012-2023, steady after
gen pworking=.
replace pworking=78.6 if year==2009
replace pworking=76.8 if year==2010
replace pworking=77.3 if year==2011
replace pworking=76.8 if year==2012
replace pworking=76.8 if year==2013
replace pworking=76.9 if year==2014
replace pworking=77.6 if year==2015
replace pworking=78.4 if year==2016
replace pworking=79.1 if year==2017
replace pworking=79.2 if year==2018
replace pworking=79.2 if year==2019
replace pworking=79.3 if year==2020
replace pworking=79.3 if year==2021
replace pworking=79.4 if year==2022
replace pworking=79.4 if year>=2023


est restore mrelstat
predict psingle, outcome(1)
predict pcohab, outcome(2)
predict pmarried, outcome(3)

est restore mkids
forvalues cnt = 1/5 {
	predict pkids`cnt', outcome(`cnt')
}


* Prefer alternative 1 ... The trends are not as steep for less than high school and MA groups when we don't limit to heads/wives
est restore meduc_limyrs_all2526
forvalues cnt = 1/3 {
	predict peduclimyrs`cnt', outcome(`cnt')
}

est restore meduc_allyrs_all2526
forvalues cnt = 1/3 {
	predict peducallyrs`cnt', outcome(`cnt')
}

* We want educ1 (hsless/GED) and educ2 (HS/somecoll) from the limyrs and educ3 (BA) and educ4 (MA) from the allyrs.  Sorry about the accounting.
gen peduc1 = peduclimyrs1
gen peduc2 = peduclimyrs2
gen peduc3 = peducallyrs2
gen peduc4 = peducallyrs3

* Rescale peduc1 and peduc2 (we believe the trend in educ3 and educ4 is more stable) so that sum(peduc1-peduc4 is 1.0)
gen peduc_num = 1-(peduc3+peduc4)
gen peduc_den = peduc1 + peduc2

replace peduc1 = (peduc_num * peduc1)/peduc_den
replace peduc2 = (peduc_num * peduc2)/peduc_den

drop peduclimyrs* peducallyrs* peduc_num peduc_den


*for all 3 above, 2031 and later values will be the ones from 2030
replace pstudent=. if year>2030
replace psingle=. if year>2030
replace pcohab=. if year>2030
replace pmarried=. if year>2030
replace pkids1=. if year>2030
replace pkids2=. if year>2030
replace pkids3=. if year>2030
replace pkids4=. if year>2030
replace pkids5=. if year>2030
replace peduc1=. if year>2030
replace peduc2=. if year>2030
replace peduc3=. if year>2030
replace peduc4=. if year>2030


*now for years 2031 and later, we use the 2030 estimates
foreach v in pstudent {
		sort year,stable
		qui sum `v' if year == 2030
		local r0 = r(mean)
		replace `v' = `r0' if year > 2030

}

foreach v in psingle {
		sort year,stable
		qui sum `v' if year == 2030
		local r0 = r(mean)
		replace `v' = `r0' if year > 2030

}

foreach v in pcohab {
		sort year,stable
		qui sum `v' if year == 2030
		local r0 = r(mean)
		replace `v' = `r0' if year > 2030

}

foreach v in pmarried {
		sort year,stable
		qui sum `v' if year == 2030
		local r0 = r(mean)
		replace `v' = `r0' if year > 2030

}


foreach v in pkids1 {
		sort year,stable
		qui sum `v' if year == 2030
		local r0 = r(mean)
		replace `v' = `r0' if year > 2030

}

foreach v in pkids2 {
		sort year,stable
		qui sum `v' if year == 2030
		local r0 = r(mean)
		replace `v' = `r0' if year > 2030

}

foreach v in pkids3 {
		sort year,stable
		qui sum `v' if year == 2030
		local r0 = r(mean)
		replace `v' = `r0' if year > 2030

}

foreach v in pkids4 {
		sort year,stable
		qui sum `v' if year == 2030
		local r0 = r(mean)
		replace `v' = `r0' if year > 2030

}

foreach v in pkids5 {
		sort year,stable
		qui sum `v' if year == 2030
		local r0 = r(mean)
		replace `v' = `r0' if year > 2030

}

foreach v in peduc1 {
		sort year,stable
		qui sum `v' if year == 2030
		local r0 = r(mean)
		replace `v' = `r0' if year > 2030

}

foreach v in peduc2 {
		sort year,stable
		qui sum `v' if year == 2030
		local r0 = r(mean)
		replace `v' = `r0' if year > 2030

}

foreach v in peduc3 {
		sort year,stable
		qui sum `v' if year == 2030
		local r0 = r(mean)
		replace `v' = `r0' if year > 2030

}

foreach v in peduc4 {
		sort year,stable
		qui sum `v' if year == 2030
		local r0 = r(mean)
		replace `v' = `r0' if year > 2030

}

gen ppartnered = 1 - psingle
gen ppartnertype = pmarried/(pmarried + pcohab)

save $outdata/acs_trends_forecast_final.dta, replace

log close
