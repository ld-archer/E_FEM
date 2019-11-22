quietly include common.do

************************************************************
*    For Age 50-55 files
************************************************************
foreach x in hrs1992 hrs1998 hrs2004 hrs2010 {
	use "$outdata/age5055_`x'.dta", clear
	
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
	 		
	save "$dua_rand_hrs/age5055_`x'r.dta", replace
}

************************************************************
*    2010 host dataset, 1998 host dataset
************************************************************

foreach x in 1998 2010{
	use "$outdata/all`x'.dta", clear
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
	drop if max_hh_yr < `x'
	drop max_hh_yr

	drop *_hrs92 *_ahd93 *_wb98 *_all04 aime
				 
	save "$dua_rand_hrs/all`x'r.dta", replace	
}

************************************************************
* Wave 1 - last wave
************************************************************	
foreach x in 1$lastwave {
	use "$outdata/hrs`x'.dta", clear
	sort hhidpn, stable
	merge hhidpn wave using "$dua_rand_hrs/aime_all", sort nokeep 
	tab  _merge
	drop _merge
	
	gen aime = raime		 
	gen fraime = raime
	gen frq = rq		    
	drop if missing(fraime) | missing(frq)
	
	drop aime* match* rq*
	save "$dua_rand_hrs/hrs`x'r.dta", replace 
}

***************************************
* For transition files - wave 1 through last wave 
***************************************	
foreach x in 1$lastwave {
	use "$outdata/hrs`x'_transition.dta", clear
	 sort hhidpn, stable
	 merge hhidpn wave using "$dua_rand_hrs/aime_all", sort nokeep 
	 tab  _merge
	 drop _merge
	
	gen aime = raime      
	gen fraime = raime
	gen frq = rq
  drop if missing(fraime) | missing(frq)
	
	save "$dua_rand_hrs/hrs`x'r_transition.dta", replace 
}


exit, STATA
