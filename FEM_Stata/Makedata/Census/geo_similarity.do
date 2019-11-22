*=====
  * File used to generate a geocode-based similarity metric using simple demographic variables
*=====

  
clear
clear mata
set more off
set mem 800m
set seed 5243212
set maxvar 10000
cap log close

* Assume that this script is being executed in the FEM_Stata/Makedata/Census directory

* Load environment variables from the root FEM directory, three levels up
* these define important paths, specific to the user
include "../../../fem_env.do"

* Define paths
global workdir  			"$local_path/Makedata/Census"

log using "$workdir/geo_similarity.log", replace

infile using "$indata/race_sex_educ_2000.dct"

gen white_male_hsless = P148A003 + P148A004
gen white_male_hsgrad = P148A005
gen white_male_colleg = P148A006 + P148A007 + P148A008 + P148A009

gen white_fema_hsless = P148A011 + P148A012
gen white_fema_hsgrad = P148A013
gen white_fema_colleg = P148A014 + P148A015 + P148A016 + P148A017

gen black_male_hsless = P148B003 + P148B004
gen black_male_hsgrad = P148B005
gen black_male_colleg = P148B006 + P148B007 + P148B008 + P148B009

gen black_fema_hsless = P148B011 + P148B012
gen black_fema_hsgrad = P148B013
gen black_fema_colleg = P148B014 + P148B015 + P148B016 + P148B017

gen other_male_hsless = P148C003 + P148D003 + P148E003 + P148F003 + P148G003 + P148C004 + P148D004 + P148E004 + P148F004 + P148G004
gen other_male_hsgrad = P148C005 + P148D005 + P148E005 + P148F005 + P148G005
gen other_male_colleg = P148C006 + P148D006 + P148E006 + P148F006 + P148G006 + P148C007 + P148D007 + P148E007 + P148F007 + P148G007 + P148C008 + P148D008 + P148E008 + P148F008 + P148G008 + P148C009 + P148D009 + P148E009 + P148F009 + P148G009

gen other_fema_hsless = P148C011 + P148D011 + P148E011 + P148F011 + P148G011 + P148C012 + P148D012 + P148E012 + P148F012 + P148G012
gen other_fema_hsgrad = P148C013 + P148D013 + P148E013 + P148F013 + P148G013
gen other_fema_colleg = P148C014 + P148D014 + P148E014 + P148F014 + P148G014 + P148C015 + P148D015 + P148E015 + P148F015 + P148G015 + P148C016 + P148D016 + P148E016 + P148F016 + P148G016 + P148C017 + P148D017 + P148E017 + P148F017 + P148G017

gen total_male = white_male_hsless + white_male_hsgrad + white_male_colleg + black_male_hsless + black_male_hsgrad + black_male_colleg + other_male_hsless + other_male_hsgrad + other_male_colleg
gen total_female = white_fema_hsless + white_fema_hsgrad + white_fema_colleg + black_fema_hsless + black_fema_hsgrad + black_fema_colleg + other_fema_hsless + other_fema_hsgrad + other_fema_colleg
gen total_white = white_male_hsless + white_male_hsgrad + white_male_colleg + white_fema_hsless + white_fema_hsgrad + white_fema_colleg
gen total_black = black_male_hsless + black_male_hsgrad + black_male_colleg + black_fema_hsless + black_fema_hsgrad + black_fema_colleg
gen total_other = other_male_hsless + other_male_hsgrad + other_male_colleg + other_fema_hsless + other_fema_hsgrad + other_fema_colleg
gen total_hsless = white_male_hsless + white_fema_hsless + black_male_hsless + black_fema_hsless + other_male_hsless + other_fema_hsless
gen total_hsgrad = white_male_hsgrad + white_fema_hsgrad + black_male_hsgrad + black_fema_hsgrad + other_male_hsgrad + other_fema_hsgrad
gen total_colleg = white_male_colleg + white_fema_colleg + black_male_colleg + black_fema_colleg + other_male_colleg + other_fema_colleg

gen total_pop_zip3 = total_male + total_female

save "$outdata/race_sex_educ_2000_score.dta", replace

use "$outdata/race_age_sex_2000.dta", clear

foreach race in whitenh blacknh hispan othernh {
  foreach gender in male female {
    forvalues age = 51/95 {
      gen `race'_`gender'_`age' = 0
      local agemin = `age'-5
      local agemax = `age'+5
      numlist "`agemin'/`agemax'"
      foreach a in `r(numlist)' {
        qui replace `race'_`gender'_`age' = `race'_`gender'_`age' + tot_`race'_`gender'_age`age'
      }
    }
  }
}
gen total_pop_zip5 = tot_whitenh + tot_blacknh + tot_hispan + tot_other
drop tot_*
  
save "$outdata/race_age_sex_2000_score.dta", replace

exit, clear STATA
