/**
Copied from HRS version
*/

include common.do

* pull family, household, and person IDs from analytic file (this file is the basis for estimation)
use $outdata/psid_analytic.dta, clear
drop if missing(famno68)
keep famno68 hhid hhidpn
ren famno68 famno68b
ren hhid hhid_orig
ren hhidpn hhidpn_orig
duplicates drop
save $outdata/psid_hhidb.dta, replace
