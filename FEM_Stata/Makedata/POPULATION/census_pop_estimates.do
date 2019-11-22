/******************************************************************************
	Script to create population projection datasets for the FEM
	based on Census population projections found here:
	http://www.census.gov/population/www/projections/downloadablefiles.html
	
	This script should be run stand alone and not as part of a larger 
	batch program. 
	
	Changes:
	9/25/2009 - File Created
	5/13/2014 - Updated to use 2012 Census estimates
*/
clear
set memory 100m
set more off

include ../../../fem_env.do

* Change this to the appropriate input directory and file
global pop_est_2000_2009 "2000_2010_Intercensal_Estimates/US-EST00INT-ALLDATA.csv"
global pop_est_2010 "2012_Pop_Estimates/NC-EST2012-ALLDATA-R-File02.csv"
global pop_est_2011 "2012_Pop_Estimates/NC-EST2012-ALLDATA-R-File04.csv"
global pop_est_2012 "2012_Pop_Estimates/NC-EST2012-ALLDATA-R-File06.csv"

** Format data 2000 - 2009 **

insheet using $census_dir/$pop_est_2000_2009, clear

/* Codes in the file 
		US-EST00INT-ALLDATA: Intercensal Estimates of the Resident Population by Single Year of Age, Sex, Race, and Hispanic Origin for the United States: April 1, 2000 to July 1, 2010
		File: 2000-2010 National Characteristics Intercensal Population Estimates File
		Source: U.S. Census Bureau, Population Division
		Release Date: September 2011
		
		Sort order of observations: Year, Month and Age
		
		VARIABLE DESCRIPTION
		MONTH Month : 7 = July
		YEAR Year
		AGE Age : single-year of age (0, 1, 2, ...84, 85+) and 999 is used to indicate total population
		TOT_POP Total population
		TOT_MALE Total male population
		TOT_FEMALE Total female population
		WA_MALE White alone male population
		WA_FEMALE White alone female population
		BA_MALE Black or African American alone male population
		BA_FEMALE Black or African American alone female population
		IA_MALE American Indian and Alaska Native alone male population
		IA_FEMALE American Indian and Alaska Native alone female population
		AA_MALE Asian alone male population
		AA_FEMALE Asian alone female population
		NA_MALE Native Hawaiian and Other Pacific Islander alone male population
		NA_FEMALE Native Hawaiian and Other Pacific Islander alone female population
		TOM_MALE Two or More Races male population
		TOM_FEMALE Two or More Races female population
		NH_MALE Not Hispanic male population
		NH_FEMALE Not Hispanic female population
		NHWA_MALE Not Hispanic, White alone male population
		NHWA_FEMALE Not Hispanic, White alone female population
		NHBA_MALE Not Hispanic, Black alone male population
		NHBA_FEMALE Not Hispanic, Black alone female population
		NHIA_MALE Not Hispanic, American Indian and Alaska Native alone male population
		NHIA_FEMALE Not Hispanic, American Indian and Alaska Native alone female population
		NHAA_MALE Not Hispanic, Asian alone male population
		NHAA_FEMALE Not Hispanic, Asian alone female population
		NHNA_MALE Not Hispanic, Native Hawaiian and Other Pacific Islander alone male population
		NHNA_FEMALE Not Hispanic, Native Hawaiian and Other Pacific Islander alone female population
		NHTOM_MALE Not Hispanic, Two or More Races male population
		NHTOM_FEMALE Not Hispanic, Two or More Races female population
		H_MALE Hispanic male population
		H_FEMALE Hispanic female population
		HWA_MALE Hispanic, White alone male population
		HWA_FEMALE Hispanic, White alone female population
		HBA_MALE Hispanic, Black or African American alone male population
		HBA_FEMALE Hispanic, Black or African American alone female population
		HIA_MALE Hispanic, American Indian and Alaska Native alone male population
		HIA_FEMALE Hispanic, American Indian and Alaska Native alone female population
		HAA_MALE Hispanic, Asian alone male population
		HAA_FEMALE Hispanic, Asian alone female population
		HNA_MALE Hispanic, Native Hawaiian and Other Pacific Islander alone male population
		HNA_FEMALE Hispanic, Native Hawaiian and Other Pacific Islander alone female population
		HTOM_MALE Hispanic, Two or More Races male population
		HTOM_FEMALE Hispanic, Two or More Races female population
	
	*/

* Keep years 2000 - 2009
keep if year >= 2000 & year <= 2009
* Keep population estimates for July
keep if month == 7
* Drop total age observations
drop if age == 999
* Keep population columns by ethnicity then drop aggregate columns so left with only columns by ethnicity, race and sex
keep year age nh* h*
drop nh_* h_* 

* rename columns before reshape
foreach var of varlist * {
	ren `var' pop_`var'
}
ren pop_year year
ren pop_age age

* Reshape the data
reshape long pop_, i(year age) j(cat) string
rename pop_ pop

/* Create the following ethnicity groups to match population projection file structure: 
		1 = Not Hispanic
		2 = Hispanic
*/
gen origin = 1 if substr(cat,1,1) == "n"
replace origin = 2 if substr(cat,1,1) == "h"

tab cat origin , m

/* Create the following race groups to match population projection file structure: 
	 	1 = White alone
	 	2 = Black alone
	 	3 = AIAN alone
	 	4 = Asian alone
	 	5 = NHPI alone
	 	6 = Two or more races
*/
gen race = 1 if strpos(cat,"wa") > 0
replace race = 2 if strpos(cat,"ba") > 0
replace race = 3 if strpos(cat,"ia") > 0 
replace race = 4 if strpos(cat,"aa") > 0 
replace race = 5 if strpos(cat,"na") > 0
replace race = 6 if strpos(cat,"om") > 0

tab cat race , m

/* Create the following sex groups to match population projection file structure: 
		1 = Male
	 	2 = Female
*/
gen sex = 1 if strpos(cat,"_male") > 0
replace sex = 2 if strpos(cat,"_female") > 0 

tab cat sex , m

keep year age sex origin race pop

save $outdata/population_estimates_2000_2009.dta, replace


** Format data 2010-2012 **

forval yr=2010/2012 {

insheet using $census_dir/${pop_est_`yr'}, clear

/* Codes in the file 
		NC-EST2012-alldata: Monthly Population Estimates by Age, Sex, Race, and Hispanic Origin for the United States: April 1, 2010 to July 1, 2012 (With short-term projections to dates in 2013)
		File: 7/1/2012 National Population Estimates
		Source: U.S. Census Bureau, Population Division
		Release Date: June 2013

		Sort order of observations: YEAR, MONTH and AGE

		VARIABLE DESCRIPTION
		UNIVERSE Universe : R = Resident population
		MONTH Month : 7 = July
		YEAR Year
		AGE Age : single-year of age (0, 1, 2, ...99, 100+) and 999 is used to indicate total population
		TOT_POP Total population
		TOT_MALE Total male population
		TOT_FEMALE Total female population
		WA_MALE White alone male population
		WA_FEMALE White alone female population
		BA_MALE Black or African American alone male population
		BA_FEMALE Black or African American alone female population
		IA_MALE American Indian and Alaska Native alone male population
		IA_FEMALE American Indian and Alaska Native alone female population
		AA_MALE Asian alone male population
		AA_FEMALE Asian alone female population
		NA_MALE Native Hawaiian and Other Pacific Islander alone male population
		NA_FEMALE Native Hawaiian and Other Pacific Islander alone female population
		TOM_MALE Two or More Races male population
		TOM_FEMALE Two or More Races female population
		WAC_MALE White alone or in combination male population
		WAC_FEMALE White alone or in combination female population
		BAC_MALE Black or African American alone or in combination male population
		BAC_FEMALE Black or African American alone or in combination female population
		IAC_MALE American Indian and Alaska Native alone or in combination male population
		IAC_FEMALE American Indian and Alaska Native alone or in combination female population
		AAC_MALE Asian alone or in combination male population
		AAC_FEMALE Asian alone or in combination female population
		NAC_MALE Native Hawaiian and Other Pacific Islander alone or in combination male population
		NAC_FEMALE Native Hawaiian and Other Pacific Islander alone or in combination female population
		NH_MALE Not Hispanic male population
		NH_FEMALE Not Hispanic female population
		NHWA_MALE Not Hispanic, White alone male population
		NHWA_FEMALE Not Hispanic, White alone female population
		NHBA_MALE Not Hispanic, Black or African American alone male population
		NHBA_FEMALE Not Hispanic, Black or African American alone female population
		NHIA_MALE Not Hispanic, American Indian and Alaska Native alone male population
		NHIA_FEMALE Not Hispanic, American Indian and Alaska Native alone female population
		NHAA_MALE Not Hispanic, Asian alone male population
		NHAA_FEMALE Not Hispanic, Asian alone female population
		NHNA_MALE Not Hispanic, Native Hawaiian and Other Pacific Islander alone male population
		NHNA_FEMALE Not Hispanic, Native Hawaiian and Other Pacific Islander alone female population
		NHTOM_MALE Not Hispanic, Two or More Races male population
		NHTOM_FEMALE Not Hispanic, Two or More Races female population
		NHWAC_MALE Not Hispanic, White alone or in combination male population
		NHWAC_FEMALE Not Hispanic, White alone or in combination female population
		NHBAC_MALE Not Hispanic, Black or African American alone or in combination male population
		NHBAC_FEMALE Not Hispanic, Black or African American alone or in combination female population
		NHIAC_MALE Not Hispanic, American Indian and Alaska Native alone or in combination male population
		NHIAC_FEMALE Not Hispanic, American Indian and Alaska Native alone or in combination female population
		NHAAC_MALE Not Hispanic, Asian alone or in combination male population
		NHAAC_FEMALE Not Hispanic, Asian alone or in combination female population
		NHNAC_MALE Not Hispanic, Native Hawaiian and Other Pacific Islander alone or in combination male population
		NHNAC_FEMALE Not Hispanic, Native Hawaiian and Other Pacific Islander alone or in combination female population
		H_MALE Hispanic male population
		H_FEMALE Hispanic female population
		HWA_MALE Hispanic, White alone male population
		HWA_FEMALE Hispanic, White alone female population
		HBA_MALE Hispanic, Black or African American alone male population
		HBA_FEMALE Hispanic, Black or African American alone female population
		HIA_MALE Hispanic, American Indian and Alaska Native alone male population
		HIA_FEMALE Hispanic, American Indian and Alaska Native alone female population
		HAA_MALE Hispanic, Asian alone male population
		HAA_FEMALE Hispanic, Asian alone female population
		HNA_MALE Hispanic, Native Hawaiian and Other Pacific Islander alone male population
		HNA_FEMALE Hispanic, Native Hawaiian and Other Pacific Islander alone female population
		HTOM_MALE Hispanic, Two or More Races male population
		HTOM_FEMALE Hispanic, Two or More Races female population
		HWAC_MALE Hispanic, White alone or in combination male population
		HWAC_FEMALE Hispanic, White alone or in combination female population
		HBAC_MALE Hispanic, Black or African American alone or in combination male population
		HBAC_FEMALE Hispanic, Black or African American alone or in combination female population
		HIAC_MALE Hispanic, American Indian and Alaska Native alone or in combination male population
		HIAC_FEMALE Hispanic, American Indian and Alaska Native alone or in combination female population
		HAAC_MALE Hispanic, Asian alone or in combination male population
		HAAC_FEMALE Hispanic, Asian alone or in combination female population
		HNAC_MALE Hispanic, Native Hawaiian and Other Pacific Islander alone or in combination male population
		HNAC_FEMALE Hispanic Native Hawaiian and Other Pacific Islander alone or in combination female population
	*/

* Keep residential population estimates
keep if universe == "R"
* Specify year
keep if year == `yr'
* Keep population estimates for July
keep if month == 7
* Drop total age observations
drop if age == 999
* Keep population columns by ethnicity then drop aggregate columns so left with only columns by ethnicity, race and sex
keep year age nh* h*
drop nh_* h_* 

* rename columns before reshape
foreach var of varlist * {
	ren `var' pop_`var'
}
ren pop_year year
ren pop_age age

* Reshape the data
reshape long pop_, i(year age) j(cat) string
rename pop_ pop

/* Create the following ethnicity groups to match population projection file structure: 
		1 = Not Hispanic
		2 = Hispanic
*/
gen origin = 1 if substr(cat,1,1) == "n"
replace origin = 2 if substr(cat,1,1) == "h"

tab cat origin , m

/* Create the following race groups to match population projection file structure: 
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
*/
gen race = 1 if strpos(cat,"wa_") > 0
replace race = 2 if strpos(cat,"ba_") > 0
replace race = 3 if strpos(cat,"ia_") > 0 
replace race = 4 if strpos(cat,"aa_") > 0 
replace race = 5 if strpos(cat,"na_") > 0
replace race = 6 if strpos(cat,"om_") > 0
replace race = 7 if strpos(cat,"wac") > 0 
replace race = 8 if strpos(cat,"bac") > 0 
replace race = 9 if strpos(cat,"iac") > 0 
replace race = 10 if strpos(cat,"aac") > 0 
replace race = 11 if strpos(cat,"nac") > 0 

tab cat race , m

/* Create the following sex groups to match population projection file structure: 
		1 = Male
	 	2 = Female
*/
gen sex = 1 if strpos(cat,"_male") > 0
replace sex = 2 if strpos(cat,"_female") > 0 

tab cat sex , m

keep year age sex origin race pop

save $outdata/population_estimates_`yr'.dta, replace

}

exit, STATA
