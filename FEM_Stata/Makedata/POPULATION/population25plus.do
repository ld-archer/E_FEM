quietly include ../../../fem_env.do

use $outdata/population_projection.dta, clear


keep if age >= 25



* Save full population estimate
preserve

collapse (sum) pop, by(year)
* Keep only odd years
keep if mod(year,2)>0

save $outdata/censuspop25plus_all.dta, replace

restore

* By gender
preserve

collapse (sum) pop, by(year male)
* Keep only odd years
keep if mod(year,2)>0

save $outdata/censuspop25plus_sex.dta, replace


restore

* By race
preserve

collapse (sum) pop, by(year racegrp)
* Keep only odd years
keep if mod(year,2)>0

save $outdata/censuspop25plus_race.dta, replace

restore

* By race/gender
preserve

collapse (sum) pop, by(year racegrp male)
* Keep only odd years
keep if mod(year,2)>0

save $outdata/censuspop25plus_racesex.dta, replace


restore

* By age 25-26 only
keep if age == 25 | age == 26
collapse (sum) pop, by(year)
* Keep only odd years
keep if mod(year,2)>0

save $outdata/censuspop25plus_2526.dta, replace

capture log close
