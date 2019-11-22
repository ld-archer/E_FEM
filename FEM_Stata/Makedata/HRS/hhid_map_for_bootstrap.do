* only needs to run once after cleaning input_data but before bootstrap processes

include common.do

use $rand_hrs, clear
keep hhid hhidpn
ren hhid hhidb
ren hhidpn hhidpn_orig
duplicates drop
save $outdata/hhidb.dta, replace
