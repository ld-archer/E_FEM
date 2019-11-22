
*******************************************************************
* Generate trends for FEM future incoming cohorts
* Oct 2007
* Nov 2007: Include all state variables for the incoming population
* 	work wlth_nonzero hibpe hearte diabe anyhi 
*	logiearnx loghatotax anydc anydb logdcwlthx
*	wtstate2 wtstate3 smkstat2 smkstat3 anyadl anyiadl
* Oct 10, 2008: accomandating the trends between 1992 to 2004
* 3/30/2010 Altered to work with the new FEM architecture of source control
* No longer apply the trend from 1992 to 2004 here. We will apply this adjustment in the new51_simulate code to keep this part cleaner and more understandable
* Keep trend constant from 2050 - 2080
* 3/4/2015 Generate trends starting from 2010
*******************************************************************

clear 
clear mata
set more off
set mem 500m

* Assume that this script is being executed in the FEM_Stata/Makedata/Population directory

* Load environment variables from the root FEM directory, three levels up
* these define important paths, specific to the user
include "../../../fem_env.do"

* Trend name
local trend_name status_quo

* Last year to generate trends to. Will be constant from 2050 to this year.
local lastyr 2150


* Weight States: Overweight, Obese1 Obese2 Obese3
local pwtstates pwtstate2 pwtstate3 pwtstate4 pwtstate5

***************
* Chronic conditions, rates from NHIS 1997-2010
***************

use "$outdata/pred5152.dta", clear
sort year

* Extend from last year of predictions to 2050
local lastpredyr = year[_N]
local nyears = 2050 - `lastpredyr' + 1
expand `nyears' if year == `lastpredyr'
sort year, stable
replace year = 2009 + _n

* From the end of the prediction to 2050, rate of change is the same as during last five years of prediction
foreach v of varlist * {
	if "`v'" != "year" {
		sort year,stable
		qui sum `v' if year == `lastpredyr' - 5
		local r0 = r(mean)
		qui sum `v' if year == `lastpredyr'
		local r1 = r(mean)
		replace `v' = `r1' * ((`r1'/`r0')^(1/5))^((year-`lastpredyr')) if year > `lastpredyr'
	}
}

list

* Cumulative rate of change relative to base year
foreach v of varlist * {
	if "`v'" != "year" {
		sort year,stable
		replace `v' = `v'/`v'[1] if _n > 1
		replace `v' = 1 if _n == 1
	}
}

sort year, stable
mkmat year p*, mat(trend5152)
drop _all

******************
* Obesity, use data from Chris Ruhm (2007)
******************
/*
Note: Over-weight is BMI>=25kg/m2
2005		2005-2010	2010-2015	2015-2020	2020-2025	2025-2030
Annual relative	rate of	change					


#d; 
matrix wt = (
-0.011748,-0.017407,-0.017705,-0.008446,-0.008071 \
0.015897,0.016508,0.010267,0.012149,0.001558 \
0.007577,0.023668,0.013783,-0.011009,0 \
0.037137,0.034912,0.031247,0.03131,0.034101 
)';  
#d cr



matrix colnames wt = `pwtstates'

svmat wt, names(col)
gen year = 2005 + _n*5
expand 7 if year == 2010
expand 5 if year > 2010
sort year, stable
replace year = 2003 + _n

* Expand to year 2031 to 2050
expand 21 if year == 2030
sort year, stable
replace year = 2003 + _n

* Assume annual rate of change during year 2031-2050 linearly decreases from the 2030 rate to zero in 2050 
foreach v in `pwtstates' {
	sort year, stable
	qui sum `v' if year == 2030
	replace `v' = -r(mean)/20 * (year - 2050) if year > 2030
}

sort year, stable
list


* Generate cumulative change
foreach v in `pwtstates' {
	replace `v' = 1 if year == 2004
	sort year, stable
	replace `v' = (1 + `v') * `v'[_n-1] if _n > 1
}

mkmat p*, mat(a)
matrix trend5152 = trend5152, a
matrix drop a

*/
*2/2015  updated obesity trends by NHANES 
* Obesity trends - Use percentile regression results from NHANES, following Ruhm
* Final decision reached was to use trends estimated since the 90's and to use 3, instead
* of 4, overweight categories -- see below. The trends were decided to be stopped in 2030,
* that is, for years 2031 and later, all projections represent the estimates for 2030

use $outdata/obesity_projections_4656.dta, replace
expand 1 in 1
sort year, stable
replace year = 2010 if _n == 1
keep if year <2051


**based on the instability of the obese 3 category, we restrict the states to 3 overweight categories:
* pwstate2 = overweight (bmi 25-29.99)
* pwstate3 = obese (bmi 30-34.99)
* pwstate4 = obese 2+ (bmi 35 and above)

*for years 2010-2050, use predicted trends
* Find relative probability in each year
gen pwtstate2 = percentile_obese1 - percentile_overweight
gen pwtstate3 = percentile_obese2 - percentile_obese1
gen pwtstate4 = percentile_obese3 - percentile_obese2
gen pwtstate5 = 100 - percentile_obese3
replace pwtstate2=. if year>2036
replace pwtstate3=. if year>2036
replace pwtstate4=. if year>2036
replace pwtstate5=. if year>2036

drop percentile*

list pwtstate5 year

foreach v of varlist * {
	if "`v'" != "year" {
		sort year,stable
		generate `v'_tmp = (`v'/`v'[_n-1]) - 1 if _n > 1
		replace `v'_tmp = 0 if _n == 1
  }
}

* Assume annual rate of change during year 2036-2050 linearly decreases from the 2036 rate to zero in 2050 
foreach v in pwtstate2_tmp {
	sort year, stable
	qui sum `v' if year == 2036
	replace `v' = -r(mean)/14 * (year - 2050) if year > 2036 
	
}

foreach v in pwtstate3_tmp {
	sort year, stable
	qui sum `v' if year == 2036
	replace `v' = -r(mean)/14 * (year - 2050) if year > 2036
	
}
		
foreach v in pwtstate4_tmp {
	sort year, stable
	qui sum `v' if year == 2036
	replace `v' = -r(mean)/14 * (year - 2050) if year > 2036
	
}
	
foreach v in pwtstate5_tmp {
	sort year, stable
	qui sum `v' if year == 2036
	replace `v' = -r(mean)/14 * (year - 2050) if year > 2036
	
}


* Generate cumulative change
foreach v in pwtstate2_tmp pwtstate3_tmp pwtstate4_tmp pwtstate5_tmp{
	replace `v' = 1 if year == 2010
	sort year, stable
	replace `v' = (1 + `v') * `v'[_n-1] if _n > 1
}

drop pwtstate2 pwtstate3 pwtstate4 pwtstate5

rename pwtstate2_tmp pwtstate2
rename pwtstate3_tmp pwtstate3
rename pwtstate4_tmp pwtstate4
rename pwtstate5_tmp pwtstate5


sort year, stable
mkmat pwtstate2 pwtstate3 pwtstate4 pwtstate5, mat(a)
matrix trend5152 = trend5152, a


******************
* Smoking, use trends from David Levy 2006
* Data up to year 2025 is available
******************
/*
* Description of scenarios
1)	Status quo - Tobacco control policies will be frozen in place as of the beginning of 2006, with excise tax rates assumed to be adjusted for inflation. 
2)	"IOM scenario" - The IOM prescribed policies, which are further broken down into the effects for the different policies prescribed in the IOM package. 
3)	"Extreme scenario": 
-	No new initiation under the age of 18 
-	A doubling of the quit rate for adults under 40
-	Prevalence is cut in half by 2010
4)	"Super extreme scenario" - under this scenario there is an immediate smoking cessation in year 2006 and there is no new initiation at any age. (In all four scenarios it is assumed that no one initiates smoking after age 24). 
*/

* Smoking scenario to use. Options are:
* 1. sq, for status quo
* 2. iom, for IOM scenario
* 3. ext, for extreme scenario

/*
Our trends are from Chapter 2 of the book:  
After tobacco : what would happen if Americans stopped smoking?, P.S. Bearman, K.M. Neckerman, and L. Wright, Editors. 2011, Columbia University Press: New York. p. 290-321

Chapter 12 is dedicated to FEM, which uses trends from Levy described in Chapter 2. ****/

/*
local smoking_scen sq

drop _all
use "$indata/legacy_smkscr.dta"
keep if year >= 2010

gen psmkstat3_sq = smoken1
gen psmkstat2_sq = smokev1
gen psmkstat3_ext  = smoken14
gen psmkstat2_ext  = smokev14
gen psmkstat3_iom  = smoken12
gen psmkstat2_iom  = smokev12
* First, male and female combined
collapse psmkstat* [pw = pop] , by(agegrp year)

* For Ever-smoked, assume that the prevalence at age 45-54 in year 2035 is the same as prevalence at age 35-44 in year 2025
* For Ever-smoked, assume that the prevalence at age 45-54 in year 2045 is the same as prevalence at age 25-34 in year 2025
* For Ever-smoked, assume that the annual change in prevalence at age 45-54 in year 2046-2050 the same as average in 2040-2045

foreach v in psmkstat2_sq psmkstat2_ext psmkstat2_iom {
	qui sum `v' if agegrp == 35 & year == 2025
	replace `v' = r(mean) if agegrp == 45 & year == 2035
	qui sum `v' if agegrp == 25 & year == 2025
	replace `v' = r(mean) if agegrp == 45 & year == 2045	
}

* Keep only the age group 45-54
	keep if agegrp == 45
	drop agegrp
* Smooth the change of ever-smoked from 2025-2035, 2035-2045
foreach v in psmkstat2_sq psmkstat2_ext psmkstat2_iom {
	sort year , stable
	qui sum `v' if year == 2025
	local r0 = r(mean)
	qui sum `v' if year == 2035
	local r1 = r(mean)
	replace `v' = `r0' * ((`r1'/`r0')^((year - 2025)/10)) if year > 2025 & year <= 2035
	
	sort year , stable
	qui sum `v' if year == 2035
	local r0 = r(mean)
	qui sum `v' if year == 2045
	local r1 = r(mean)
	replace `v' = `r0' * ((`r1'/`r0')^((year - 2035)/10)) if year > 2035

}

* For smoking-now, after year 2025,use the moving average of the past five years
foreach v in psmkstat3_sq psmkstat3_ext psmkstat3_iom {
		sort year,stable
		qui sum `v' if year == 2020
		local r0 = r(mean)
		qui sum `v' if year == 2025
		local r1 = r(mean)
		replace `v' = `r1' * ((`r1'/`r0')^(1/5))^((year-2025)) if year > 2025

}

* For iom and ext, we want to apply the trend that started in 2004 to instead start in 2010
foreach v in ext iom {
	foreach i in 2 3 {
	
		gen trend`i'_`v' = 1 if year <= 2010
		replace trend`i'_`v' = psmkstat`i'_`v'[_n-7]/psmkstat`i'_`v'[1] if year > 2010
		replace psmkstat`i'_`v' = trend`i'_`v'*psmkstat`i'_sq
		drop trend`i'_`v'
	}	

}

* For super-extreme scenario
gen psmkstat3_supext = 1 if year == 2010
replace psmkstat3_supext = 0 if year > 2010
gen psmkstat2_supext = psmkstat2_ext if year < 2034
replace psmkstat2_supext = 0 if year >= 2034

* Now get the cumulative change
* Cumulative rate of change relative to base year
foreach v of varlist * {
	if "`v'" != "year" {
		sort year,stable
		replace `v' = `v'/`v'[1] if _n > 1
		replace `v' = 1 if _n == 1
	}
}

sort year, stable
gen psmkstat2 = psmkstat2_`smoking_scen'
gen psmkstat3 = psmkstat3_`smoking_scen'
mkmat psmkstat2 psmkstat3, mat(a)
matrix trend5152 = trend5152, a

*/

*****************
*Smoking by NHIS
*****************
* smoking trends from NHIS 

drop _all

use $outdata/nhis_smk_projections.dta, replace

local outcomes psmkcat1_4656 psmkcat2_4656 psmkcat3_4656

* Cumulative rate of change relative to base year 2010
foreach v of local outcomes {
		sort year,stable
		replace `v' = `v'/`v'[1] if _n > 1
		replace `v' = 1 if _n == 1
}

rename psmkcat1_4656 psmkstat1
rename psmkcat2_4656 psmkstat2
rename psmkcat3_4656 psmkstat3

mkmat psmkstat1 psmkstat2 psmkstat3, mat(a)
matlist a
matrix trend5152 = trend5152, a

matlist trend5152



******************
* Trend in anyadl status
******************

drop _all
local obs = 2050-2010+1
set obs `obs'
local r = 0.0
gen year = 2009 + _n
gen panyadl = (1 + `r') ^ (year - 2010)
mkmat panyadl, mat(a)
matrix trend5152 = trend5152, a

******************
* Trend in anyiadl status
******************

drop _all
local obs = 2050-2010+1
set obs `obs'
local r = 0.0
gen year = 2009 + _n
gen panyiadl = (1 + `r') ^ (year - 2010)
mkmat panyiadl, mat(a)
matrix trend5152 = trend5152, a

******************
* Trend in working status
******************
* Hard to find a consistent trend, assume 1 for now
drop _all
local obs = 2050-2010+1
set obs `obs'
local r = 0.0
gen year = 2009 + _n
gen pwork = (1 + `r') ^ (year - 2010)
mkmat pwork, mat(a)
matrix trend5152 = trend5152, a

******************
* DB pension entitlement
* Data from Poberta et al 2007 
******************

* Assume annual relative declining rate for DB entitlement decrease by 2% a year
drop _all
local obs = 2050-2010+1
set obs `obs'
local r = -0.02

gen year = 2009 + _n
gen panydb = 1 if year == 2010
replace panydb = (1 + `r')^(year - 2010) if year > 2010
sort year, stable
mkmat panydb, mat(a)
matrix trend5152 = trend5152, a


******************
* DC pension entitlement
* Data from Poberta et al 2007 
******************
/*
Year reaching 65			2000	2005	2010	2015	2020	2025	2030	2035	2040
Year reaching 51			1986	1991	1996	2001	2006	2011	2016	2021	2026
DC %					10	15	27	41	47	50	50	57	72
Annual relative rate of change		8.4%	12.5%	8.7%	2.8%	1.2%	0.0%	2.7%	4.8%
*/

* Relative rate of change between 2010 and 2026 is: (72/50)^(1/16)
drop _all
local obs = 2050-2010+1
set obs `obs'
local r = (72/50)^(1/16) - 1
gen year = 2009 + _n
gen panydc = (1 + `r') ^ (year - 2010) if year < 2026
sort year, stable

replace panydc = panydc[_n-1] if year >= 2026

sort year, stable
mkmat panydc, mat(a)
matrix trend5152 = trend5152, a

******************
* Trend in earnings
******************
* Using HRS 1992-2010, assume mean increase by 1% per year
drop _all
local obs = 2050-2010+1
set obs `obs'
local r = 0.0
gen year = 2009 + _n
gen plogiearnx = (1 + `r') ^ (year - 2010)
mkmat plogiearnx, mat(a)
matrix trend5152 = trend5152, a

******************
* Trend in log-transformed net non-pension wealth
******************
* Hard to find a consistent trend, assume 1 for now
drop _all
local obs = 2050-2010+1
set obs `obs'
local r = 0.0
gen year = 2009 + _n
gen ploghatotax = (1 + `r') ^ (year - 2010)
mkmat ploghatotax, mat(a)
matrix trend5152 = trend5152, a

******************
* Trend in proportion with non-zero net non-pension wealth
******************
* Hard to find a consistent trend, assume 1 for now
drop _all
local obs = 2050-2010+1
set obs `obs'
local r = 0.0
gen year = 2009 + _n
gen pwlth_nonzero = (1 + `r') ^ (year - 2010)
mkmat pwlth_nonzero, mat(a)
matrix trend5152 = trend5152, a

******************
* Trend in log-transformed DC wealth
******************
* Hard to find a consistent trend, assume 1 for now
drop _all
local obs = 2050-2010+1
set obs `obs'
local r = 0.0
gen year = 2009 + _n
gen plogdcwlthx = (1 + `r') ^ (year - 2010)
mkmat plogdcwlthx, mat(a)
matrix trend5152 = trend5152, a

******************
* Trend in population size and race/ethnicity
******************
drop _all
use "$indata/census5152_byrace.dta"
gen phispan =  pop5152allRTH/ pop5152allRTT
gen pblack  =  pop5152allRBT/ pop5152allRTT
gen ppop    =  pop5152allRTT
keep if year >= 2010
foreach v in phispan pblack ppop{
	sort year, stable
	replace `v' = `v'/`v'[1] if year > 2010
	replace `v' = 1 if year == 2010
	
}

sort year, stable
mkmat phispan pblack ppop, mat(a)
matrix trend5152 = trend5152, a

******************
  * Trends in education dervied from the CPS
******************
  drop _all
use $outdata/trend_educ.dta

keep if year >= 2010
local constant 2050 - year[_N] + 1
gen realobs = 1
expand `constant' if _n==_N
replace peduc2 = 1 if missing(realobs)
replace peduc3 = 1 if missing(realobs)
replace year = 2009 + _n if missing(realobs)

if "`trend_name'" != "cps_educ" {
replace peduc2 = 1 if !missing(peduc2)
replace peduc3 = 1 if !missing(peduc3)
}

mkmat peduc2 peduc3, mat(a)
matrix trend5152 = trend5152, a

******************
* Trend in other demographic variables, assume non-changed
******************
drop _all
local obs = 2050-2010+1
set obs `obs'
local r = 0.0
gen year = 2009 + _n
foreach v in male single widowed anyhi{
	gen p`v' = (1 + `r') ^ (year - 2010)
	mkmat p`v', mat(a)
	matrix trend5152 = trend5152, a
}


******************
* Save trend
******************

drop _all
svmat trend5152, names(col)


sort year, stable

keep if year>=2010

local nextra_yrs = `lastyr' - 2050 + 1

* Extend to year 2050 to lastyr
expand `nextra_yrs' if year == 2050
sort year, stable
replace year = 2009 + _n

save "$outdata/trend_all_`trend_name'.dta", replace



keep if mod(year,10) == 0 | year ==2010

* Output according to specified order
#d; 
outsheet year pcancre pdiabe phearte phibpe plunge pstroke `pwtstates' psmkstat2 psmkstat3 panyadl panyiadl
panyhi pwlth_nonzero pwork panydb panydc plogiearnx ploghatotax plogdcwlthx 
phispan pblack peduc2 peduc3 psingle pwidowed panyhi ppop
using "$outdata/trend_all_`trend_name'.csv", replace comma nol ; 
#d cr

exit, STATA clear


******************
* Trend in mortality
******************
drop _all
use "$outdata\mortality_projection.dta"
* Keep only year 2000 to 2050, for sex = 0 (both male and female) and race = "A" and middle series and aged 51 and over
keep if inrange(year, 2000, 2050) & sex > 0 & race == "A" & series == "A" & age_begin >= 51
keep year sex age_begin Qx Ex
sort sex age year, stable
by sex age: gen r = Qx[_n]/Qx[_n-1] - 1 if _n > 1 & year <= 2010
by sex age: replace r = (Qx/Qx[_n-1])^(1/5) - 1 if year > 2010
drop if inrange(year, 2000,2009)
keep if age == 51 | mod(age,5) == 0
table age_begin year if sex == 1, c(mean r) row col
table age_begin year if sex == 2, c(mean r) row col

exit, STATA
