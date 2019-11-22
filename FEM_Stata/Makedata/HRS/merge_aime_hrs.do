quietly include common.do

************************************************************
* Wave 1-9 and Wave 1-7 files
************************************************************	
  use "$outdata/hrs$firstwave$lastwave.dta", clear
sort hhidpn, stable
merge hhidpn wave using "$dua_rand_hrs/aime_all", sort nokeep 
tab  _merge
drop _merge

gen aime = raime		 
gen fraime = raime
gen frq = rq		    
drop if missing(fraime) | missing(frq)

drop aime* match* rq*
  local fname = "$dua_rand_hrs/hrs$firstwave$lastwave" + "r.dta"
  save `fname', replace

