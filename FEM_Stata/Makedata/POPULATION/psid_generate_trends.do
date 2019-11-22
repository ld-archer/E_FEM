/* Goal for now:
	Pass non-trends for most outcomes.
	Pass trends for obesity categories and smoking status
	*/
	
clear 
clear mata
set more off
set mem 500m

* Assume that this script is being executed in the FEM_Stata/Makedata/Population directory

* Load environment variables from the root FEM directory, three levels up
* these define important paths, specific to the user
include "../../../fem_env.do"

* Trend name
local trend_name default

* Last year to generate trends to. Will be constant from 2050 to this year.
local lastyr 2080

* Weight States: Overweight, Obese1 Obese2 Obese3
local pwtstates pwtstate2 pwtstate3 pwtstate4 pwtstate5
	
* Create our base trend2526 matrix for 2009-2050
local obs = 2050-2009+1
set obs `obs'
gen year = 2008 + _n
mkmat year, mat(trend2526)

matlist trend2526

drop _all

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
local smoking_scen sq

drop _all
use "$indata/legacy_smkscr.dta", replace
keep if year >= 2009

* Only doing status_quo for now
gen psmkstat3_sq = smoken1
gen psmkstat2_sq = smokev1

* First, male and female combined
collapse psmkstat* [pw = pop] , by(agegrp year)

* For Ever-smoked, assume that the prevalence at age 25-35 in year 2035 is the same as prevalence at age 18-25 in year 2025


foreach v in psmkstat2_sq  {
	qui sum `v' if agegrp == 18 & year == 2025
	replace `v' = r(mean) if agegrp == 25 & year == 2035
	}

* Keep only the age group 25-34
	keep if agegrp == 25
	drop agegrp
* Smooth the change of ever-smoked from 2025-2035
foreach v in psmkstat2_sq  {
	sort year , stable
	qui sum `v' if year == 2025
	local r0 = r(mean)
	qui sum `v' if year == 2035
	local r1 = r(mean)
	replace `v' = `r0' * ((`r1'/`r0')^((year - 2025)/10)) if year > 2025 & year <= 2035
	
	* Five year moving average after 2035
	qui sum `v' if year == 2030
	local r0 = r(mean)
	qui sum `v' if year == 2035
	local r1 = r(mean)
	replace `v' = `r1' * ((`r1'/`r0')^(1/5))^((year-2035)) if year > 2035 
}

* For smoking-now, after year 2025,use the moving average of the past five years
foreach v in psmkstat3_sq {
		sort year,stable
		qui sum `v' if year == 2020
		local r0 = r(mean)
		qui sum `v' if year == 2025
		local r1 = r(mean)
		replace `v' = `r1' * ((`r1'/`r0')^(1/5))^((year-2025)) if year > 2025

}

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
matrix trend2526 = trend2526, a




drop _all

* Obesity trends - Use percentile regression results from NHANES, following Ruhm
use $outdata/obesity_projections_2130_2010, replace

* Starts in 2010, copy initial value for 2009
expand 2 in 1
sort year
replace year = 2009 if _n == 1
keep if year <2051

* Find relative probability in each year
gen pwtstate2 = percentile_obese1 - percentile_overweight
gen pwtstate3 = percentile_obese2 - percentile_obese1
gen pwtstate4 = percentile_obese3 - percentile_obese2
gen pwtstate5 = 100 - percentile_obese3

drop percentile*

foreach v of varlist * {
	if "`v'" != "year" {
		sort year,stable
		replace `v' = `v'/`v'[1] if _n > 1
		replace `v' = 1 if _n == 1
	}
}

sort year, stable
mkmat pwtstate2 pwtstate3 pwtstate4 pwtstate5, mat(a)
matrix trend2526 = trend2526, a




drop _all
* Trends from American Community Survey (2000-2011) - marital status, working
use $outdata/acs_trends_forecast.dta, replace

local outcomes peduc1 peduc2 peduc3 peduc4 peduc5 peduc6 pkids1 pkids2 pkids3 pkids4 pkids5 psingle pcohab pmarried pwork ppartnered ppartnertype

* Want cumulative change in outcomes compared to 2009
foreach v of local outcomes {
	sort year,stable
	replace `v' = `v'/`v'[1] if _n > 1
	replace `v' = 1 if _n == 1
}

mkmat peduc1 peduc2 peduc3 peduc4 peduc5 peduc6 pkids1 pkids2 pkids3 pkids4 pkids5 psingle pcohab pmarried pwork ppartnered ppartnertype, mat(a)
matrix trend2526 = trend2526, a

matlist trend2526

* Any health trends from NHIS (2009-2016) - only hypertension for now
use $outdata/pred2526.dta, replace

local outcomes phibpe

sort year, stable
set obs `obs'
replace year = 2008 + _n if year > 2016

* Five year moving average
foreach v of local outcomes {
	reg `v' year
	predict `v'_new
	replace `v' = `v'_new if year > 2016
}

* Want cumulative change in outcomes compared to 2009
foreach v of local outcomes {
	sort year,stable
	replace `v' = `v'/`v'[1] if _n > 1
	replace `v' = 1 if _n == 1
}

mkmat phibpe, mat(a)
matlist a
matrix trend2526 = trend2526, a



******************
* Save trend
******************

drop _all
svmat trend2526, names(col)

sort year, stable

local nextra_yrs = `lastyr' - 2050 + 1

* Extend to year 2050 to lastyr
expand `nextra_yrs' if year == 2050
sort year, stable
replace year = 2008 + _n

save "$outdata/psid_trend_`trend_name'.dta", replace






capture log close
