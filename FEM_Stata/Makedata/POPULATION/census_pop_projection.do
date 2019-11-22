/******************************************************************************
	Script to create population projection datasets for the FEM
	based on Census population projections found here:
	http://www.census.gov/population/www/projections/downloadablefiles.html
	
	This script should be run stand alone and not as part of a larger 
	batch program. 
	
	Changes:
	9/25/2009 - File Created
	5/13/2014 - Updated to use 2012 Census projections
*/
clear
set memory 100m
set more off

include ../../../fem_env.do

* Change this to the appropriate input directory and file
global pop_proj_file "2012_Pop_Projection/NP2012_D1.csv"

insheet using $census_dir/$pop_proj_file

/* Codes in the file 
	Projected Population by Single Year of Age, Sex, Race, and Hispanic 
	Origin for the United States: July 1, 2012 to July 1, 2060
	
	File:  2012 National Population Projections 
	
	Source: Population Division, U.S. Census Bureau
	Release date:  December 2012
	
	Sort order of observations:  Hispanic origin, race, sex, and year
	Data fields (in order in which they appear):
	
	VARIABLE				DESCRIPTION
	
	ORIGIN 				     Hispanic origin code
	RACE				     Race code
	SEX				     Sex code
	YEAR				     Year of projection (July 1, 2012 to July 1, 
					     2060)
	TOTAL_POP			     Population total (all ages combined) in each 
					     year 
	(POP_0, POP_1, ...POP_99, POP_100)   Population age x as of July 1 (columns for ages
					     0, 1, 2, ...98, 99, 100 or more years old)
	
	The key for ORIGIN code is as follows:
		0 = Total
		1 = Not Hispanic
		2 = Hispanic
	
	The key for RACE code is as follows:
	 	0 = All races combined
	
	 	1 = White alone
	 	2 = Black alone
	 	3 = AIAN alone
	 	4 = Asian alone
	 	5 = NHPI alone
	 	6 = Two or more races
	
		7 = White alone or in combination
	 	8 = Black alone or in combination
	 	9 = AIAN alone or in combination
	 	10 = Asian alone or in combination
	 	11 = NHPI alone or in combination
	
	The key for SEX code is as follows:
		0 = Total
		1 = Male
	 	2 = Female
*/

* Keep years 2013 and later
keep if year >= 2013
* Drop total age variable
drop total_pop
* Drop total orgin, race, and sex observations
drop if origin == 0
drop if race == 0
drop if sex == 0

* Reshape the data
reshape long pop_, i(origin race sex year) j(age)
rename pop_ pop

keep year age sex origin race pop

* append population estimates 
append using $outdata/population_estimates_2000_2009.dta
append using $outdata/population_estimates_2010.dta
append using $outdata/population_estimates_2011.dta
append using $outdata/population_estimates_2012.dta

* Drop unneeded categories 
drop if inlist(race, 7, 8, 9, 10, 11)

/* Create the following race groups:
	1 Hispanic
      2 Non-Hispanic White
      3 Non-Hispanic black
      4 Other
*/
gen racegrp = 1 if origin == 2
replace racegrp = 2 if origin == 1 & race == 1
replace racegrp = 3 if origin == 1 & race == 2
replace racegrp = 4 if missing(racegrp)

* Who is male
gen male = 1 if sex == 1
replace male = 0 if sex == 2


collapse (sum) pop, by(year age racegrp male)
label define racegrp_lbl 1 "Hispanic" 2 "Non-Hispanic White" 3 "Non-Hispanic black" 4 "Other"
label values racegrp racegrp_lbl

* Save population projections
save $outdata/population_projection.dta, replace

preserve

* Create projections just for 51/52 year olds
keep if inlist(age, 51,52) & mod(year, 2) == 0 & year >= 2004
collapse (sum) pop, by(year racegrp male)
gen hispan = racegrp == 1
gen black = racegrp == 3
collapse (sum) pop, by(year male hispan black)
keep year male hispan black pop

* Save population projections for 51/52 year olds
save $outdata/pop5152_projection.dta, replace

restore

* Create projections just for 25/26 year olds in 2009, 2011, ...
keep if inlist(age, 25,26) & mod(year, 2) == 1 & year >= 2009
collapse (sum) pop, by(year racegrp male)
gen hispan = racegrp == 1
gen black = racegrp == 3
collapse (sum) pop, by(year male hispan black)
keep year male hispan black pop

* Save population projections for 51/52 year olds
save $outdata/pop2526_projection.dta, replace


exit, STATA
