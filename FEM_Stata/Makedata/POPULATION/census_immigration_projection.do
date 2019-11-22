/******************************************************************************
	Script to create immigration projection datasets for the FEM
	based on Census immigration projections found here:
	http://www.census.gov/population/www/projections/downloadablefiles.html
	
	Changes:
	6/9/2014 - File Created
*/
clear
set memory 100m
set more off

include ../../../fem_env.do

* Change this to the appropriate input directory and file
* Census net international migration estimates by age and sex are not available 
* Census net international migration projections by age and sex are available from the 2000 National Population Projections
global immig_proj_2012 "2012_Pop_Projection/NP2012_D4.csv"


** Format immigration projections from 2012 **

insheet using $census_dir/$immig_proj_2012

/* Codes in the file 
Projected Net International Migration by Single Year of Age, Sex, Race, and Hispanic Origin for the United States: 2012 to 2060
File: 2012 National Population Projections
Source: U.S. Census Bureau, Population Division
Release date: December 2012
Sort order of observations: RACE_HISP, SEX, and YEAR

Data fields (in order of appearance):
	RACE_HISP: Race and Hispanic origin group (Black = Black or African American; AIAN = American Indian and Alaska Native; NHPI = Native Hawaiian and Other Pacific Islander)
	SEX: Sex
	YEAR: Year of projection (2012 to 2060)
	TOTAL_NIM: Total net number of international migrants (all ages) between July 1 of the preceding year and June 30 of the indicated year
	(NIM_0, NIM_1, ... NIM_84, NIM_85): Net number of migrants for population age x as of July 1 (columns for ages 0, 1, 2, ...83, 84, 85 or more years old)

The key for RACE_HISP is as follows:
	0 = Total population
	1 = White alone
	2 = Black alone
	3 = AIAN alone
	4 = Asian alone
	5 = NHPI alone
	6 = Two or More Races
	
	7 = Not Hispanic
	8 = Hispanic
	
	9 = Non-Hispanic White alone

The key for SEX code is as follows:
	0 = Both sexes
	1 = Male
	2 = Female
*/

* Keep years 2012 and later
keep if year >= 2012
* Drop total age variable
drop total_nim
* keep total race_hisp
keep if race_hisp == 0
* drop total sex observations
drop if sex == 0

* Reshape the data
reshape long nim_, i(race_hisp sex year) j(age)
rename nim_ nim

keep year age sex nim

save $outdata/immigration_projections_2012.dta, replace


* distribute 2000 - 2011 totals by 2012 immigrant proportions by sex and age
sum nim if year == 2012
gen proportion = nim / r(sum) if year == 2012

forval yr = 2000/2011 {
expand 2 if year == 2012, generate(check)
replace year = `yr' if check == 1
drop check
}


merge m:1 year using $outdata/immigration_estimates.dta
drop _m 

replace nim = proportion * tot_nim if inrange(year,2000,2011)


* Who is male
gen male = 1 if sex == 1
replace male = 0 if sex == 2


collapse (sum) nim, by(year age male)

* Save population projections
save $outdata/immigration_projection.dta, replace


* Create immigration tables
capture file close myfile
use $outdata/immigration_projection.dta, clear
keep if age>=51 & age<=85
sort year male age
gen obs = _n
count
local j = r(N)

file open myfile using ../../../FEM_CPP_settings/immigration_ysa.txt, write text replace
#delimit ; 
file write myfile 
	"|Source: Census projections 2012-2060 and Census estimates 2000-2011. The first line below is a list of variable names that define the cells for migration.  Each subsequent line has the variable values that define each cell followed by the net migration for that cell.  Entries can be space-delimited or tab-delimited." _n
	"year" _tab "age" _tab "male" _n;
forval i=1/`j' {;
	file write myfile
	(year[`i']) _tab (age[`i']) _tab (male[`i']) _tab (nim[`i']) _n;
};
#delimit cr
file close myfile	

collapse (mean) nim if inrange(year,2001,2010), by(male age)
gen obs = _n
count
local j = r(N)
capture file close myfile
file open myfile using ../../../FEM_CPP_settings/immigration_sa.txt, write text replace
#delimit ; 
file write myfile 
	"|Source: Census projections 2012-2060 and Census estimates 2000-2011. The first line below is a list of variable names that define the cells for migration.  Each subsequent line has the variable values that define each cell followed by the net migration for that cell.  Entries can be space-delimited or tab-delimited." _n
	"age" _tab "male" _n;
forval i=1/`j' {;
	file write myfile
	(age[`i']) _tab (male[`i']) _tab (nim[`i']) _n;
};
#delimit cr
file close myfile	

exit, STATA clear
