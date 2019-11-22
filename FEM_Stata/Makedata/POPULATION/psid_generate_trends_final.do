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
* the smoking trends from Levy have been replaced with projections from the NHIS (see below)
******************

* Obesity trends - Use percentile regression results from NHANES, following Ruhm
* Final decision reached was to use trends estimated since the 90's and to use 3, instead
* of 4, overweight categories -- see below. The trends were decided to be stopped in 2030,
* that is, for years 2031 and later, all projections represent the estimates for 2030
use $outdata/obesity_projections_2130_since90_2010, replace

* Starts in 2010, copy initial value for 2009
expand 2 in 1
sort year
replace year = 2009 if _n == 1
keep if year <2051

**based on the instability of the obese 3 category, we restrict the states to 3 overweight categories:
* pwstate2 = overweight (bmi 25-29.99)
* pwstate3 = obese (bmi 30-34.99)
* pwstate4 = obese 2+ (bmi 35 and above)

*for years 2010-2030, use predicted trends
* Find relative probability in each year
gen pwtstate2 = percentile_obese1 - percentile_overweight
gen pwtstate3 = percentile_obese2 - percentile_obese1
gen pwtstate4 = percentile_obese3 - percentile_obese2
gen pwtstate5 = 100 - percentile_obese3
replace pwtstate2=. if year>2030
replace pwtstate3=. if year>2030
replace pwtstate4=. if year>2030
replace pwtstate5=. if year>2030

drop percentile*

*now for years 2031 and later, we use the 2030 estimates
foreach v in pwtstate2 {
		sort year,stable
		qui sum `v' if year == 2030
		local r0 = r(mean)
		replace `v' = `r0' if year > 2030

}

foreach v in pwtstate3 {
		sort year,stable
		qui sum `v' if year == 2030
		local r0 = r(mean)
		replace `v' = `r0' if year > 2030

}

foreach v in pwtstate4 {
		sort year,stable
		qui sum `v' if year == 2030
		local r0 = r(mean)
		replace `v' = `r0' if year > 2030

}

foreach v in pwtstate5 {
		sort year,stable
		qui sum `v' if year == 2030
		local r0 = r(mean)
		replace `v' = `r0' if year > 2030

}

*finally, make trends setting 2010=1
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
use $outdata/acs_trends_forecast_final.dta, replace

local outcomes pstudent pworking peduc1 peduc2 peduc3 peduc4 pkids1 pkids2 pkids3 pkids4 pkids5 psingle pcohab pmarried ppartnered ppartnertype

* Want cumulative change in outcomes compared to 2010
foreach v of local outcomes {
	sort year,stable
	replace `v' = `v'/`v'[2] if _n != 2
	replace `v' = 1 if _n == 2
}

mkmat pstudent pworking peduc1 peduc2 peduc3 peduc4 pkids1 pkids2 pkids3 pkids4 pkids5 psingle pcohab pmarried ppartnered ppartnertype, mat(a)
matrix trend2526 = trend2526, a

matlist trend2526

* Any health trends from NHIS - hypertension and smoking
use $outdata/nhis_hbp_smk_projections.dta, replace

**adjust below to be like ACS data

local outcomes phibpe_2130 psmkcat1_2130 psmkcat2_2130 psmkcat3_2130

* Want cumulative change in outcomes compared to 2009
foreach v of local outcomes {
	sort year,stable
	replace `v' = `v'/`v'[2] if _n != 2
	replace `v' = 1 if _n == 2
}

rename phibpe_2130   phibpe  
rename psmkcat1_2130 psmkstat1
rename psmkcat2_2130 psmkstat2
rename psmkcat3_2130 psmkstat3

mkmat phibpe psmkstat1 psmkstat2 psmkstat3, mat(a)
matlist a
matrix trend2526 = trend2526, a



******************
* Save trend
******************

drop _all
svmat trend2526, names(col)

sort year, stable

keep if year>=2010

save "$outdata/psid_trends_final.dta", replace


local nextra_yrs = `lastyr' - 2050 + 1

* Extend to year 2050 to lastyr
expand `nextra_yrs' if year == 2050
sort year, stable
replace year = 2008 + _n

save "$outdata/psid_trend_`trend_name'.dta", replace






capture log close
