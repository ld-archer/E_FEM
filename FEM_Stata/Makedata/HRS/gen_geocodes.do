/** \file
File used to generate a unified file of the HRS hhidpn-linked geocodes

\todo incorporate this into the general HRS Makedata process
*/

  
clear
clear mata
set more off
set mem 1000m
set seed 5243212
set maxvar 20000
cap log close

* Assume that this script is being executed in the FEM_Stata/Makedata/Census directory

* Load environment variables from the root FEM directory, three levels up
* these define important paths, specific to the user
include "../../../fem_env.do"

* Define paths
global workdir  			"$local_path/Makedata/HRS"

log using "$workdir/gen_geocodes.log", replace

clear
set trace off
set more off
set mem 500m

use "$outdata/hrs_analytic_recoded.dta"
merge hhidpn using "$ZIP/hrsxgeo92_08.dta", sort uniqusing keep(zip*)
drop if _merge==2
drop _merge

gen zipcode = ""
replace zipcode = zip92 if wave == 1 & zipcode == ""
replace zipcode = zip93 if wave == 2 & zipcode == ""
replace zipcode = zip94 if wave == 2 & zipcode == ""
replace zipcode = zip95 if wave == 3 & zipcode == ""
replace zipcode = zip96 if wave == 3 & zipcode == ""
replace zipcode = zip98 if wave == 4 & zipcode == ""
replace zipcode = zip00 if wave == 5 & zipcode == ""
replace zipcode = zip02 if wave == 6 & zipcode == ""
replace zipcode = zip04 if wave == 7 & zipcode == ""

gen GEOID2 = substr(zipcode, 1, 3)
sort GEOID2
merge GEOID2 using "$outdata/race_sex_educ_2000_score.dta", uniqusing sort keep(GEOID2 white* black* other* total_*)
drop if _merge==2
drop _merge

gen rse_score_raw = .
replace rse_score_raw = white_male_hsless if white==1 & male==1 & hsless==1
replace rse_score_raw = white_male_hsgrad if white==1 & male==1 & hsless==0 & college==0
replace rse_score_raw = white_male_colleg if white==1 & male==1 & college==1

replace rse_score_raw = white_fema_hsless if white==1 & male==0 & hsless==1
replace rse_score_raw = white_fema_hsgrad if white==1 & male==0 & hsless==0 & college==0
replace rse_score_raw = white_fema_colleg if white==1 & male==0 & college==1

replace rse_score_raw = black_male_hsless if black==1 & male==1 & hsless==1
replace rse_score_raw = black_male_hsgrad if black==1 & male==1 & hsless==0 & college==0
replace rse_score_raw = black_male_colleg if black==1 & male==1 & college==1

replace rse_score_raw = black_fema_hsless if black==1 & male==0 & hsless==1
replace rse_score_raw = black_fema_hsgrad if black==1 & male==0 & hsless==0 & college==0
replace rse_score_raw = black_fema_colleg if black==1 & male==0 & college==1

replace rse_score_raw = other_male_hsless if white==0 & black==0 & male==1 & hsless==1
replace rse_score_raw = other_male_hsgrad if white==0 & black==0 & male==1 & hsless==0 & college==0
replace rse_score_raw = other_male_colleg if white==0 & black==0 & male==1 & college==1

replace rse_score_raw = other_fema_hsless if white==0 & black==0 & male==0 & hsless==1
replace rse_score_raw = other_fema_hsgrad if white==0 & black==0 & male==0 & hsless==0 & college==0
replace rse_score_raw = other_fema_colleg if white==0 & black==0 & male==0 & college==1

gen rse_score_scaled = rse_score_raw / total_pop_zip3

keep rse_score_raw rse_score_scaled hhidpn wave zipcode white male black hispan age_yrs
qui compress

gen zcta5 = zipcode
merge zcta5 using "$outdata/race_age_sex_2000_score.dta", sort uniqusing nokeep
drop _merge

gen ras_score_raw = .
forvalues age=51/90 {
  replace ras_score_raw = whitenh_male_`age' if white==1 & male==1 & hispan==0 & age_yrs==`age'
  replace ras_score_raw = whitenh_female_`age' if white==1 & male==0 & hispan==0 & age_yrs==`age'

  replace ras_score_raw = blacknh_male_`age' if black==1 & male==1 & hispan==0 & age_yrs==`age'
  replace ras_score_raw = blacknh_female_`age' if black==1 & male==0 & hispan==0 & age_yrs==`age'

  replace ras_score_raw = othernh_male_`age' if white==0 & black==0 & male==1 & hispan==0 & age_yrs==`age'
  replace ras_score_raw = othernh_female_`age' if white==0 & black==0 & male==0 & hispan==0 & age_yrs==`age'

  replace ras_score_raw = hispan_male_`age' if hispan==1 & age_yrs==`age'
  replace ras_score_raw = hispan_female_`age' if hispan==1 & age_yrs==`age'
}

gen ras_score_scaled = ras_score_raw / total_pop_zip5

********
  **************** THESE LINES MUST ALWAYS EXECUTE
********
keep hhidpn wave rse_score_raw rse_score_scaled ras_score_raw ras_score_scaled

save "$outdata/hrs_analytic_geo.dta", replace
exit, clear STATA
