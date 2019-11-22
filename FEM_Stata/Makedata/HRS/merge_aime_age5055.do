quietly include common.do

local yyyy : env YEAR

************************************************************
*    For Age 50-55 files
*    update to year 2010
************************************************************
  use "$outdata/age5055_hrs`yyyy'.dta", clear

merge hhidpn wave using "$dua_rand_hrs/aime_all", sort nokeep
tab _merge match_hrs92, m
tab _merge match_ahd93, m
tab _merge match_wb98, m
tab _merge match_all04, m
tab _merge match_all06, m

keep if _merge == 3
drop _merge
count
* Drop if AIME is non-sensical or missing (zeroes have been recoded to 1)
drop if raime <= 0 | missing(raime)
gen aime = raime
gen fraime = raime
gen frq = rq
* Drop if quarters work is  non-sensical or missing (zeroes have been recoded to 1)
drop if missing(rq)

drop *_hrs92 *_ahd93 *_wb98 *_all04 *_all06 aime

save "$dua_rand_hrs/age5055_hrs`yyyy'r.dta", replace

exit, STATA
