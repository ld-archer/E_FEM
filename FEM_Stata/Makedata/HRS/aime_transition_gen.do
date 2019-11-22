/* This program will produce a file that allows us to estimate transition models of AIME.  For this, we need to have current earnings, current AIME, lage AIME, and age

*/


include common.do

use "$outdata/hrs_analytic_recoded.dta", clear
sort hhidpn wave, stable
by hhidpn: keep if _n == _N
keep hhidpn rssclyr hacohort rabyear
ren rssclyr rclyr
sort hhidpn, stable
* save "$indata/hrs_roster.dta", replace


	************************************************************
		*    HRS 1992 permission
		************************************************************
		
		sort hhidpn
		merge hhidpn using "$dua_rand_hrs/ssa_92.dta", sort nokeep
		drop _merge
		gen match_hrs92 = rw1991!=.
		set trace off

		* Year of claiming SS
		local currentyr = 1991
		gen clmyear = min(`currentyr',rclyr)
		
		* Calculate aime for all years of observed wages (up to age 120, as set in calcage parameter) - look through 1991
		aimeUS_v3 rq rabyear clmyear if match_hrs92 == 1, gen(raime) earn("rw") fyr(1951) yr(1991) calcage(120)
		rename raime aime_hrs92_1991
		
		* Calculate aime for all years of observed wages (up to age 120, as set in calcage parameter) - look through 1989 (for lagged value)
		aimeUS_v3 rq rabyear clmyear if match_hrs92 == 1, gen(raime) earn("rw") fyr(1951) yr(1989) calcage(120)
		rename raime aime_hrs92_1989

		
		* Convert to 2004 dollars
		* We were doing this incorrectly.  The AIME values for each individual are in the $ of the year in which they turn 60, not the year they gave permission.
		
		egen cpicyr  = cpi(rabyear+60)
		egen cpi2004 = cpi(2004)
		replace aime_hrs92_1991 = aime_hrs92_1991*cpi2004/cpicyr
		replace aime_hrs92_1989 = aime_hrs92_1989*cpi2004/cpicyr
		
		sum cpi*
		
		drop cpicyr cpi2004
		
		drop rw*
		* Generate quarters worked and lagged (2 years prior) quarters worked
		gen rq_hrs92 = rq_1991
		gen lrq_hrs92 = rq_1989 
		desc
		drop rq clmyear rq_1* rq_2*
		desc


************************************************************
		*    AHEAD 1993 permission
		************************************************************
		clear mata
*		run aimeUS_v2.ado
		sort hhidpn
		merge hhidpn using "$dua_rand_hrs/ssa_93.dta" , sort nokeep
		drop _merge
		gen match_ahd93 = rw1992!=.
		local currentyr = 1992
		gen clmyear = min(`currentyr',rclyr)

		* Calculate aime for all years of observed wages (up to age 120, as set in calcage parameter) - look through 1992
		aimeUS_v3 rq rabyear clmyear if match_ahd93 == 1, gen(raime) earn("rw") fyr(1951) yr(1992) calcage(120)
		ren raime aime_ahd93_1992

		* Calculate aime for all years of observed wages (up to age 120, as set in calcage parameter) - look through 1990
		aimeUS_v3 rq rabyear clmyear if match_ahd93 == 1, gen(raime) earn("rw") fyr(1951) yr(1990) calcage(120)
		ren raime aime_ahd93_1990


		* Convert to 2004 dollars
		* We were doing this incorrectly.  The AIME values for each individual are in the $ of the year in which they turn 60, not the year they gave permission.
		
		egen cpicyr  = cpi(rabyear+60)
		egen cpi2004 = cpi(2004)
		sum cpi*
		replace aime_ahd93_1992 = aime_ahd93_1992*cpi2004/cpicyr
		replace aime_ahd93_1990 = aime_ahd93_1990*cpi2004/cpicyr
		drop cpicyr cpi2004
		
		drop rw*
	  * Generate quarters worked and lagged (2 years prior) quarters worked
		gen rq_ahd93 = rq_1992
		gen lrq_ahd93 = rq_1990 
		desc
		drop rq clmyear rq_1* rq_2*

		
		************************************************************
		*    CODA WB 1998 permission
		************************************************************		
		clear mata
*		run aimeUS_v2.ado
*	  run "\\homer\homer_c\Retire\yuhui\codes\aimeUS_v2.ado"		
		sort hhidpn
		merge hhidpn using "$dua_rand_hrs/ssa_98.dta", sort nokeep
		drop _merge
		gen match_wb98 = rw1997!=.
		local currentyr = 1997
		gen clmyear = min(`currentyr',rclyr)

		* Calculate aime for all years of observed wages (up to age 120, as set in calcage parameter) - look through 1997
		aimeUS_v3 rq rabyear clmyear if match_wb98 == 1, gen(raime) earn("rw") fyr(1951) yr(1997) calcage(120)
		ren raime aime_wb98_1997
	
		* Calculate aime for all years of observed wages (up to age 120, as set in calcage parameter) - look through 1995
		aimeUS_v3 rq rabyear clmyear if match_wb98 == 1, gen(raime) earn("rw") fyr(1951) yr(1995) calcage(120)
		ren raime aime_wb98_1995

		* Convert to 2004 dollars
		* We were doing this incorrectly.  The AIME values for each individual are in the $ of the year in which they turn 60, not the year they gave permission.
		egen cpicyr  = cpi(rabyear+60)
		egen cpi2004 = cpi(2004)
		replace aime_wb98_1997 = aime_wb98_1997*cpi2004/cpicyr
		replace aime_wb98_1995 = aime_wb98_1995*cpi2004/cpicyr
		drop cpicyr cpi2004
		
		drop rw* 
	   * Generate quarters worked and lagged (2 years prior) quarters worked
		gen rq_wb98 = rq_1997
		gen lrq_wb98 = rq_1995 
		desc
		drop rq clmyear rq_1* rq_2*

			
		************************************************************
		*   All cohorts 2004 permission
		************************************************************	
		clear mata
*		run aimeUS_v2.ado
		sort hhidpn
		merge hhidpn using "$dua_rand_hrs/ssa_04.dta", sort nokeep
		drop _merge
		gen match_all04 = rw2003!=.
		local currentyr = 2003
		gen clmyear = min(`currentyr',rclyr)

		* Calculate aime for all years of observed wages (up to age 120, as set in calcage parameter) - look through 2003
		aimeUS_v3 rq rabyear clmyear if match_all04 == 1, gen(raime) earn("rw") fyr(1951) yr(2003) calcage(120)
		ren raime aime_all04_2003
		
		* Calculate aime for all years of observed wages (up to age 120, as set in calcage parameter) - look through 2001
		aimeUS_v3 rq rabyear clmyear if match_all04 == 1, gen(raime) earn("rw") fyr(1951) yr(2001) calcage(120)
		ren raime aime_all04_2001
	
		* Convert to 2004 dollars
		* We were doing this incorrectly.  The AIME values for each individual are in the $ of the year in which they turn 60, not the year they gave permission.
		egen cpicyr  = cpi(rabyear+60)
		egen cpi2004 = cpi(2004)
		replace aime_all04_2003 = aime_all04_2003*cpi2004/cpicyr
		replace aime_all04_2001 = aime_all04_2001*cpi2004/cpicyr			
		drop cpicyr cpi2004
	
		drop rw*					
	  * Generate quarters worked and lagged (2 years prior) quarters worked
		gen rq_all04 = rq_2003
		gen lrq_all04 = rq_2001 
		desc
		drop rq clmyear rq_1* rq_2*




	************************************************************
		*   All cohorts 2006 permission
		************************************************************	
		clear mata
*		run aimeUS_v2.ado
		sort hhidpn
		merge hhidpn using "$dua_rand_hrs/ssa_06.dta", sort nokeep
		drop _merge
		gen match_all06 = rw2005!=.
		local currentyr = 2005
		gen clmyear = min(`currentyr',rclyr)

		* Calculate aime for all years of observed wages (up to age 120, as set in calcage parameter) - look through 2005
		aimeUS_v3 rq rabyear clmyear if match_all06 == 1, gen(raime) earn("rw") fyr(1951) yr(2005) calcage(120)
		ren raime aime_all06_2005
		
		* Calculate aime for all years of observed wages (up to age 120, as set in calcage parameter) - look through 2003
		aimeUS_v3 rq rabyear clmyear if match_all04 == 1, gen(raime) earn("rw") fyr(1951) yr(2003) calcage(120)
		ren raime aime_all06_2003
		
		
		
		* Convert to 2004 dollars
		* We were doing this incorrectly.  The AIME values for each individual are in the $ of the year in which they turn 60, not the year they gave permission.
		egen cpicyr  = cpi(rabyear+60)
		egen cpi2004 = cpi(2004)
		replace aime_all06_2005 = aime_all06_2005*cpi2004/cpicyr
		replace aime_all06_2003 = aime_all06_2003*cpi2004/cpicyr
				
	
		drop rw*					
	  * Generate quarters worked and lagged (2 years prior) quarters worked
		gen rq_all06 = rq_2005
		gen lrq_all06 = rq_2003 
		desc
		drop rq clmyear rq_1* rq_2*




		* Save data
	 * keep hhidpn rabyear hacohort match_* aime_* rq_* aime50_*
	  sort hhidpn, stable
	



* Merge with hrs_analytic_recoded to pick up iearn for the year we care about
gen wave = .
replace wave = 1 if match_hrs92 == 1
replace wave = 2 if match_ahd93 == 1
replace wave = 4 if match_wb98 == 1
replace wave = 7 if match_all04 == 1
replace wave = 8 if match_all06 == 1


* Get earnings in correct wave
merge 1:1 hhidpn wave using $outdata/hrs_analytic_recoded.dta, keepusing(iearn age male)
keep if _merge == 3


* Rename the aime and lag aime variables
gen aime = .
gen laime = .
replace aime 	=	aime_hrs92_1991 if match_hrs92 == 1
replace laime = aime_hrs92_1989 if match_hrs92 == 1

replace aime 	=	aime_ahd93_1992 if match_ahd93 == 1
replace laime = aime_ahd93_1990 if match_ahd93 == 1

replace aime 	=	aime_wb98_1997 if match_wb98 == 1
replace laime = aime_wb98_1995 if match_wb98 == 1

replace aime 	=	aime_all04_2003 if match_all04 == 1
replace laime = aime_all04_2001 if match_all04 == 1

replace aime 	=	aime_all06_2005 if match_all06 == 1
replace laime = aime_all06_2003 if match_all06 == 1

gen rq = .
gen lrq = .

replace rq = rq_hrs92 if match_hrs92 == 1
replace lrq = lrq_hrs92 if match_hrs92 == 1

replace rq = rq_ahd93 if match_ahd93 == 1
replace lrq = lrq_ahd93 if match_ahd93 == 1

replace rq = rq_wb98 if match_wb98 == 1
replace lrq = lrq_wb98 if match_wb98 == 1

replace rq = rq_all04 if match_all04 == 1
replace lrq = lrq_all04 if match_all04 == 1

replace rq = rq_all06 if match_all06 == 1
replace lrq = lrq_all06 if match_all06 == 1



drop aime_* _merge


  save "$dua_rand_hrs/aime_transition.dta", replace


capture log close
