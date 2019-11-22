quietly include common.do

***************************************
* For transition files - wave 1 through 9 
* For transition files - wave 1 through 7
***************************************
  local inname = "$outdata/hrs$firstwave$lastwave" + "_transition.dta"
  use `inname', clear
sort hhidpn, stable
merge hhidpn wave using "$dua_rand_hrs/aime_all", sort nokeep 
tab  _merge
drop _merge

gen aime = raime      
gen fraime = raime
gen frq = rq
drop if missing(fraime) | missing(frq)

local fname = "$dua_rand_hrs/hrs$firstwave$lastwave" + "r_transition.dta"
save `fname', replace

exit, STATA

