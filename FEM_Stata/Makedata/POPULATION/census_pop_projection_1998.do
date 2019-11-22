/******************************************************************************
	Script to create population projection datasets for the FEM
	based on Census population projections found here:
	http://www.census.gov/population/projections/data/national/
	
	This script should be run stand alone and not as part of a larger 
	batch program. 
	
	Changes:
	11/13/2012 - File Created by BBlaylock
*/

clear
set memory 100m
set more off

include ../../../fem_env.do

* Change this to the appropriate input directory and file
local pop_proj_file "census_projections_1998.csv"

insheet using $indata/`pop_proj_file'

/* Codes in the file 
	Projections of the Population by Age, Sex, Race, and Hispanic 
	Origin for the United States: 1995 to 2050 
	
	File citation: Day, Jennifer Cheeseman, Population Projections 
	of the United States by Age, Sex, Race, and Hispanic Origin: 
	1995 to 2050, U.S. Bureau of the Census, Current Population 
	Reports, P25-1130, U.S. Government Printing Office, Washington, 
	DC, 1996.
	
	Source: Population Division, U.S. Census Bureau
	Release date:  February 1996
	
	Format as detailed below:
	
	Sort order of observations:  Hispanic origin, race, sex, and year
	Data fields (in order in which they appear):
	
	VARIABLE				 DESCRIPTION
	
	YEAR				     1998
	AGE							 Age as of July 1
	RACEGRP					 1 Hispanic, 2 Non-Hispanic White, 3 Non-Hispanic black, 4 Other
	MALE						 1 Male, 0 Female
	POP							 Population total as of July 1
	*/

keep age tot_male tot_female hisp_male hisp_female nh_white_male nh_white_female nh_black_male nh_black_female 
gen year=1998
gen other_male = tot_male - hisp_male - nh_white_male - nh_black_male
gen other_female = tot_female - hisp_female - nh_white_female - nh_black_female

* Rename the variables
ren hisp_male pop_hisp_male
ren hisp_female pop_hisp_female
ren nh_white_male pop_nh_white_male
ren nh_white_female pop_nh_white_female
ren nh_black_male pop_nh_black_male
ren nh_black_female pop_nh_black_female
ren other_male pop_other_male
ren other_female pop_other_female

drop tot_male
drop tot_female

* Reshape the data
reshape long pop_, i(year age) j(group) string
ren pop_ pop
	
gen racegrp=1 if substr(group,1,4)=="hisp"
replace racegrp=2 if substr(group,1,8)=="nh_white"
replace racegrp=3 if substr(group,1,8)=="nh_black"
replace racegrp=4 if substr(group,1,5)=="other"
label define racegrp_lbl 1 "Hispanic" 2 "Non-Hispanic White" 3 "Non-Hispanic black" 4 "Other"
label values racegrp racegrp_lbl

gen male=1 if index(group,"_male")
replace male=0 if index(group,"female")

drop group
drop if inlist(age, "Median age","Mean age")

* Save population projections
save $outdata/population_projection_1998.dta, replace

save $indata/population_projection_1998.dta, replace


* Create projections just for 51/52 year olds
keep if inlist(age, "51 years","52 years") & mod(year, 2) == 0 & year >= 1998
collapse (sum) pop, by(year racegrp male)
gen hispan = racegrp == 1
gen black = racegrp == 3
collapse (sum) pop, by(year male hispan black)
keep year male hispan black pop

* Save population projections for 51/52 year olds
save $outdata/pop5152_projection_1998.dta, replace

save $indata/pop5152_projection_1998.dta, replace

exit, STATA
