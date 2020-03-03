* Select half of harmonized ELSA's idauniq's for simulation and use the other
* half for the transition model
*
* Luke Archer
* 27/07/2019
clear
set maxvar 10000

quietly include ../../fem_env.do

*use $outdata/H_ELSA.dta, clear
use ../../input_data/H_ELSA_f_2002-2016.dta, clear

keep idauniq r4iwstat
sum idauniq if r4iwstat == 1
* 11,050 ID's, so use roughly 5525 for simulation (=11050/2)

* Create random numbers from uniform distribution
gen rand = runiform() if r4iwstat == 1

gen simulation = .
replace simulation = 1 if rand > 0.5 & !missing(rand)
replace simulation = 0 if rand < 0.5 & !missing(rand)

tab simulation

gen transition = .
replace transition = 1 if simulation == 0
replace transition = 0 if simulation == 1

*save $outdata/crossvalidation.dta, replace
save ../../input_data/crossvalidation.dta, replace
