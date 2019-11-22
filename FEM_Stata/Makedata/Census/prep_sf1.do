clear
set maxvar 10000
set mem 500M
set more off
include "../../../fem_env.do"

set type double

insheet FILEID STUSAB CHARITER CIFSN LOGRECNO tot_hispan tot_hispan_male tot_hispan_male_age0-tot_hispan_male_age100 tot_hispan_male_age105 tot_hispan_male_age110 tot_hispan_female tot_hispan_female_age0-tot_hispan_female_age100 tot_hispan_female_age105 tot_hispan_female_age110 using "$indata/census2000/sl860-in-sl010-us00023.uf1", comma nonames

save hispanic.dta, replace

clear
insheet FILEID STUSAB CHARITER CIFSN LOGRECNO tot_whiteNH tot_whiteNH_male tot_whiteNH_male_age0-tot_whiteNH_male_age100 tot_whiteNH_male_age105 tot_whiteNH_male_age110 tot_whiteNH_female tot_whiteNH_female_age0-tot_whiteNH_female_age100 tot_whiteNH_female_age105 tot_whiteNH_female_age110 using "$indata/census2000/sl860-in-sl010-us00024.uf1"

save white.dta, replace

clear
insheet FILEID STUSAB CHARITER CIFSN LOGRECNO tot_blackNH tot_blackNH_male tot_blackNH_male_age0-tot_blackNH_male_age100 tot_blackNH_male_age105 tot_blackNH_male_age110 tot_blackNH_female tot_blackNH_female_age0-tot_blackNH_female_age100 tot_blackNH_female_age105 tot_blackNH_female_age110 using "$indata/census2000/sl860-in-sl010-us00025.uf1"

save black.dta, replace

clear
insheet FILEID STUSAB CHARITER CIFSN LOGRECNO tot_amerindNH tot_amerindNH_male tot_amerindNH_male_age0-tot_amerindNH_male_age100 tot_amerindNH_male_age105 tot_amerindNH_male_age110 tot_amerindNH_female tot_amerindNH_female_age0-tot_amerindNH_female_age100 tot_amerindNH_female_age105 tot_amerindNH_female_age110 using "$indata/census2000/sl860-in-sl010-us00026.uf1"

save amerind.dta, replace

clear
insheet FILEID STUSAB CHARITER CIFSN LOGRECNO tot_asianNH tot_asianNH_male tot_asianNH_male_age0-tot_asianNH_male_age100 tot_asianNH_male_age105 tot_asianNH_male_age110 tot_asianNH_female tot_asianNH_female_age0-tot_asianNH_female_age100 tot_asianNH_female_age105 tot_asianNH_female_age110 using "$indata/census2000/sl860-in-sl010-us00027.uf1"

save asian.dta, replace

clear
insheet FILEID STUSAB CHARITER CIFSN LOGRECNO tot_pacislNH tot_pacislNH_male tot_pacislNH_male_age0-tot_pacislNH_male_age100 tot_pacislNH_male_age105 tot_pacislNH_male_age110 tot_pacislNH_female tot_pacislNH_female_age0-tot_pacislNH_female_age100 tot_pacislNH_female_age105 tot_pacislNH_female_age110 using "$indata/census2000/sl860-in-sl010-us00028.uf1"

save pacisl.dta, replace

clear
insheet FILEID STUSAB CHARITER CIFSN LOGRECNO tot_otherNH tot_otherNH_male tot_otherNH_male_age0-tot_otherNH_male_age100 tot_otherNH_male_age105 tot_otherNH_male_age110 tot_otherNH_female tot_otherNH_female_age0-tot_otherNH_female_age100 tot_otherNH_female_age105 tot_otherNH_female_age110 using "$indata/census2000/sl860-in-sl010-us00029.uf1"

save other.dta, replace

clear
insheet FILEID STUSAB CHARITER CIFSN LOGRECNO tot_biracialNH tot_biracialNH_male tot_biracialNH_male_age0-tot_biracialNH_male_age100 tot_biracialNH_male_age105 tot_biracialNH_male_age110 tot_biracialNH_female tot_biracialNH_female_age0-tot_biracialNH_female_age100 tot_biracialNH_female_age105 tot_biracialNH_female_age110 using "$indata/census2000/sl860-in-sl010-us00030.uf1"

save biracial.dta, replace

foreach f in hispanic white black amerind asian pacisl other biracial {
  infix using "$indata/census2000/sl860-in-sl010-usgeo.uf1", clear
  merge logrecno using "`f'.dta", sort nokeep
  drop _merge
  save "`f'.dta", replace
}

use amerind.dta, clear
foreach f in asian pacisl other biracial {
  merge logrecno using "`f'.dta", sort nokeep keep(tot_*)
  drop _merge
}

gen tot_other = tot_amerindnh + tot_asiannh + tot_pacislnh + tot_othernh + tot_biracialnh
foreach gender in male female {
  gen tot_other_`gender' = tot_amerindnh_`gender' + tot_asiannh_`gender' + tot_pacislnh_`gender' + tot_othernh_`gender' + tot_biracialnh_`gender'
  foreach i of numlist 0/100 105 110 {
    gen other_`gender'_age`i' = tot_amerindnh_`gender'_age`i' + tot_asiannh_`gender'_age`i' + tot_pacislnh_`gender'_age`i' + tot_othernh_`gender'_age`i' + tot_biracialnh_`gender'_age`i'
  }
}

foreach f in amerind asian pacisl other biracial {
  erase `f'.dta
}
save other.dta, replace

use hispanic.dta, clear
foreach f in white black other {
  merge logrecno using "`f'.dta", sort nokeep keep(tot_*)
  drop _merge
}

foreach f in hispanic white black other {
  erase `f'.dta
}

save "$outdata/race_age_sex_2000.dta", replace
