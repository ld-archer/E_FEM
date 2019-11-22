/* Randomly select half of the individuals in 1999 for use in crossvalidation model estimation, the other
half will be used for simulation 

Variables needed: 
ER33503 relation to head 1999 (indicates head/wife/"wife" if 10/20/22)
ER30001 Family Number 1968 (part of ID)
ER30002 Pernon Number 1968 (part of ID)
*/

quietly include "common.do"

set seed 582019

local vars ER30001 ER30002 ER33503 

local lastyr $lastyr
use `vars' using $psid_dir/Stata/ind`lastyr'er.dta, clear

rename ER30001 famnum68
rename ER30002 pn68
rename ER33503 relhd99

* ID
gen hhidpn = famnum68*1000 + pn68
* Keep only heads, wives, or "wives"
keep if inlist(relhd99,10,20,22)

gen rand = runiform() 
gen simulation = (rand < 0.5)
gen transition = (simulation == 0)

keep hhidpn simulation transition

save "$outdata/psid_crossvalidation.dta", replace

capture log close
