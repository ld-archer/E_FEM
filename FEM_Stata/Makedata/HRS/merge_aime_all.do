quietly include common.do

local yyyy : env YEAR

************************************************************
*    2004 host dataset, 1998 host dataset
*    4/2015 Added 2010 host dataset 
************************************************************

  use "$outdata/all`yyyy'.dta", clear
merge hhidpn wave using "$dua_rand_hrs/aime_all", sort nokeep	
tab _merge match_hrs92, m
tab _merge match_ahd93, m
tab _merge match_wb98, m
tab _merge match_all04, m
tab _merge match_all06, m
drop if _merge == 2
drop _merge

gen aime = raime
gen fraime = raime
gen frq = rq

gen willbedropped = (missing(aime) | aime <= 0 | missing(rq) | rq <= 0) 
tab hacohort willbedropped, row

* Remove records where the AIME or RQ is missing
drop if (missing(aime) |  missing(rq)) 
  
  * If we removed persons with dead spouses from before 2004, remove the dead spouses as well since they are no longer needed
bys hhid: egen max_hh_yr = max(year)
drop if max_hh_yr < `yyyy'
drop max_hh_yr

drop *_hrs92 *_ahd93 *_wb98 *_all04 aime aime_ssa*

save "$dua_rand_hrs/all`yyyy'r.dta", replace	

