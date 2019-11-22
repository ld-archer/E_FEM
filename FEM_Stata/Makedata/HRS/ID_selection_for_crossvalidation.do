*==========================================================================*
*	Select random half of Rand HRS hhidpn's for simulation and use the other
* half for the transition model
*	
*	Barbara Blaylock
*	11/14/2012
*==========================================================================*

include "common.do"


use $rand_hrs, clear
keep hhidpn r4iwstat
sum hhidpn if r4iwstat==1
** 21,384 ID's, so use 10692 for simulation (=21384/2)

* create random numbers from uniform distribution and sort
gen rand = uniform() if r4iwstat==1
sort rand

gen simulation = .
replace simulation = 1 in 1/10692
replace simulation = 0 in 10693/21384

tab simulation 

gen transition = .
replace transition = 1 if simulation==0
replace transition = 0 if simulation==1

save "$outdata/crossvalidation.dta", replace
