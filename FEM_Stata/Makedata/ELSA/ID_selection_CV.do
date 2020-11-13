* Select half of harmonized ELSA's idauniq's for simulation and use the other
* half for the transition model
*
* Luke Archer
* 27/07/2019
clear
set maxvar 10000
set seed 5000

quietly include ../../../fem_env.do

log using ID_selection_CV.log, replace

use $outdata/H_ELSA_f_2002-2016.dta, clear
*use ../../../input_data/H_ELSA_f_2002-2016.dta, clear

keep idauniq r3iwstat
sum idauniq if r3iwstat == 1
* 11,050 ID's, so use roughly 5525 for simulation (=11050/2) (this true for wave 4 at least)

* keep 1 record per person
* gen rand for each person 
* split entire sample between sim and transition
* simulation sample has additional cut for r1iwstat==1
* would have more people in transition than simulation

* OR/AND
* Use full sample for transitions up to wave x, simulate from wave x onwards

* ALSO
* Start simulation from 2016 and see if there is big jumps from ELSA to FEM

* Create random numbers from uniform distribution
gen rand = runiform() if r3iwstat == 1

gen simulation = .
replace simulation = 1 if rand > 0.5 & !missing(rand)
replace simulation = 0 if rand < 0.5 & !missing(rand)

tab simulation

gen transition = .
replace transition = 1 if simulation == 0 & !missing(rand)
replace transition = 0 if simulation == 1 & !missing(rand)

save $outdata/cross_validation/crossvalidation.dta, replace
*save ../../../input_data/cross_validation/crossvalidation.dta, replace

capture log close
