
clear
cap clear mata
set mem 500m
set more off
set seed 52432
*set maxvar 10000
est drop _all

*==========================================================================*
* Estimate transition
* Apr 8, 2008: add age dummies (lage62e,lage65e) to labor participation and SS claiming
* Cohort effects for weight and hh wealth
* Apr 13, 2008: For wealth, use emprical distribution,dont use log transformation
* Jun 23, 2008: For wealth, use generalized inverse hyperbolic sine  transformation - dummy variables for waves and zero/non-zero
* GET THE THETA/OMEGA/SSR SAVED.
* Sep 6, 2008: This re-estimate mortality by including those alive but not interviewed
* 							remove BMI and smoking (initial and lag) from estimation 
* Sep 21, 2008, change age dummies for ss claiming equation
* Sep 22, 2008, change age dummies for working equation, re-run all estimations
* Keep obesity and overweight variables only in disease and functional status, smoking and weight equations
* Sep 27, correct for mis-specified covariates
* =========================================================================*

/*********************************************************************/
*	SEP UP DIRECTORIES
/*********************************************************************/

global workdir "\\zeno\zeno_a\DOL\Estimation_2"
global indata  "\\zeno\zeno_a\DOL\Input_yh"
global outdata "\\zeno\zeno_a\DOL\Input_ahg"
global outdata "\\zeno\zeno_a\DOL\Input_yh"
global netdir  "\\homer\homer_c\Retire\ahg\rdata2"
global outdir "\\zeno\zeno_a\DOL\Input_ahg\all"
global outdir "\\zeno\zeno_a\DOL\Input_yh\all"
	
cd \\zeno\zeno_a\DOL\\Makedata\HRS
capt takestring
cd \\zeno\zeno_a\DOL\\Estimation_2
capt estout

global ghregdir "\\zeno\zeno_a\DOL\hyp_mata"
adopath ++ "\\zeno\zeno_a\zyuhui\DOL\PC"
adopath ++ "\\zeno\zeno_a\DOL\Makedata\HRS"
adopath ++ "\\zeno\zeno_a\DOL\Estimation_2"
adopath ++ "\\zeno\zeno_a\DOL\hyp_mata"

/*********************************************************************/
* USE DATA AND RECODE
/*********************************************************************/

cap log close
log using "$workdir\init_transition_yh.log", replace
dis "Current time is: " c(current_time) " on " c(current_date)

use "$netdir\\hrs17r_transition.dta", clear
* FOR hacohort = 0 & 1 in wave 2 & 3 no info on SSI claiming
	replace ssiclaim = -2 if inlist(hacohort, 0, 1) & inlist(wave,3,4)

	cd  "\\zeno\zeno_a\DOL\hyp_mata"

*** CHANGE hatota, earnings VARIABLES
	drop floghatota floghatotax lloghatota lloghatotax llogiearn llogiearnx flogiearn flogiearnx
	set more off
	foreach i in hatota hatotax iearn iearnx{
		egen flog`i' = h(f`i')
		replace flog`i' = flog`i'/100
		egen llog`i' = h(l`i')
		replace llog`i' = llog`i'/100
	}


*** DEPENDENT VARIABLES
	global bin_econ anyhi diclaim ssclaim dbclaim ssiclaim nhmliv work wlth_nonzero
	global bin_hlth died hearte stroke cancre hibpe diabe lunge 
	global order wtstate smkstat funcstat

*** GENERATE THE AGE SPLINE VARIABLES
	foreach x in lage6061 lage6263 lage64e lage6566 lage6770 lage65l lage6574 lage75l lage75p lage62e lage63e {
		cap drop `x'
	}
	
	gen lage6061 = lage == 58 | lage == 59 if lage < .
	gen lage6263 = inrange(lage,60,61) if lage < .
	gen lage64e = lage == 62 if lage < . 
	gen lage6566 = lage == 63 | lage == 64 if lage < .
	gen lage6770 = inrange(lage,65,68) if lage < . 
	
	gen lage65l  = min(63,lage) if lage < .
	gen lage6574 = min(max(0,lage-63),73-63) if lage < .
	gen lage75l = min(lage, 73) if lage < . 
	gen lage75p = max(0, lage-73) if lage < . 
	gen lage62e = lage == 60 if age < .
	gen lage63e = lage == 61 if age < .

	mkspline la6 58 la7 73 la7p = lage

*** GENERATE WEAVE DUMMIES
	gen w3 = wave == 3
	gen w4 = wave == 4
	gen w5 = wave == 5
	gen w6 = wave == 6
	gen w7 = wave == 7

*** INDEPENDENT VARIABLES

*** Demographics
	global dvars black hispan hsless college male 
*** Initial values
#d;
	global fvars fhearte fstroke fcancre fhibpe fdiabe flunge fanyhi fsmokev fsmoken fiadl1 fadl12 fadl3 
	fwidowed fsingle fwork flogiearnx fwlth_nonzero floghatotax 
	flogaime flogq fshlt fanydb frdb_na_2 frdb_na_3 frdb_na_4 fanydc flogdcwlthx ;
#d cr
*** values of health variables at t-1
	global lvars_hlth lhearte lstroke lcancre lhibpe ldiabe llunge liadl1 ladl12 ladl3 lsmoken lanyhi lwidowed 
*** values of econ variables at time t-1
	global lvars_econ lwork llogiearnx lwlth_nonzero lloghatotax ldiclaim lssiclaim lssclaim ldbclaim lnhmliv

*** FOR MORTALITY
	global allvars_died $dvars lage65l lage6574 lage75p $lvars_hlth $fvars
	
*** FOR CHRONIC CONDITIONS AND ORDINAL OUTCOMES
	global allvars_hlth $dvars lage65l lage6574 lage75p $lvars_hlth lobese loverwt $fvars fobese foverwt

	takestring, oldlist($allvars_hlth) newname("allvars_hearte") extlist("lhearte fhearte lstroke llunge lcancre liadl1 ladl12 ladl3")
	takestring, oldlist($allvars_hlth) newname("allvars_stroke") extlist("lstroke fstroke lstroke llunge liadl1 ladl12 ladl3")
	takestring, oldlist($allvars_hlth) newname("allvars_cancre") extlist("lhearte lstroke lcancre lhibpe ldiabe llunge fcancre liadl1 ladl12 ladl3")
	takestring, oldlist($allvars_hlth) newname("allvars_hibpe")  extlist("lhearte lstroke lcancre lhibpe llunge fhibpe liadl1 ladl12 ladl3")
	takestring, oldlist($allvars_hlth) newname("allvars_diabe")  extlist("lhearte lstroke lcancre lhibpe ldiabe llunge fdiabe liadl1 ladl12 ladl3")
	takestring, oldlist($allvars_hlth) newname("allvars_lunge")  extlist("lhearte lstroke lcancre lhibpe ldiabe llunge flunge liadl1 ladl12 ladl3")

	global allvars_smkstat $allvars_hlth
	global allvars_funcstat $allvars_hlth
	global allvars_wtstate $allvars_hlth rbyr
	
*** FOR ECONOMIC OUTCOMES
  global allvars_econ1 $dvars lage65l lage6574 lage75p $lvars_hlth $lvars_econ $fvars 
  global allvars_econ2 $dvars lage6061 lage62e lage63e lage64e lage6566 lage6770 $lvars_hlth $lvars_econ $fvars 
  global allvars_econ3 $dvars la6 la7 la7p $lvars_hlth $lvars_econ $fvars w3 w4 w5 w6 w7 rbyr
  
	takestring, oldlist($allvars_econ1) newname("allvars_anyhi")  extlist("lage75p ldbclaim lssiclaim lnhmliv lsmoken")
	takestring, oldlist($allvars_econ1) newname("allvars_diclaim")  extlist("lage75p lssiclaim lssclaim ldbclaim lnhmliv lsmoken")
	takestring, oldlist($allvars_econ1) newname("allvars_dbclaim")  extlist("lage75p fwork fanydb lssiclaim ldbclaim lwork lnhmliv lsmoken")
	takestring, oldlist($allvars_econ1) newname("allvars_ssiclaim")  extlist("lnhmliv lsmoken")
	takestring, oldlist($allvars_econ1) newname("allvars_nhmliv")  extlist("ldiclaim lssiclaim lssclaim ldbclaim lwork llogiearnx lsmoken")
	takestring, oldlist($allvars_econ1) newname("allvars_iearnx")  extlist("lssiclaim lnhmliv lsmoken lage75p")

	takestring, oldlist($allvars_econ2) newname("allvars_ssclaim")  extlist("lssiclaim lssclaim lnhmliv lsmoken")
	takestring, oldlist($allvars_econ2) newname("allvars_work")  extlist("lssiclaim lnhmliv lsmoken")

	takestring, oldlist($allvars_econ3) newname("allvars_wlth_nonzero")  extlist("lssiclaim lsmoken")
	takestring, oldlist($allvars_econ3) newname("allvars_hatotax")  extlist("lssiclaim lsmoken")

exit

set more off
keep if white == 1
gen st = 1 - died
collapse died st, by(male lage fsmkstat)

cap drop pdied
gen pdied = .
foreach m in 0 1 {
	foreach s in 1 2 3 {
		cap drop pdied`m'`s'
		lowess died lage if male == `m' & fsmkstat == `s', gen(pdied`m'`s') nograph
		replace pdied = 1 - sqrt(1 - pdied`m'`s') if male == `m' & fsmkstat == `s'
	}
}

keep if lage >= 51 & lage <=99
keep lage fsmkstat male pdied
sort male fsmkstat, stable
replace pdied = 1 if lage == 99 
sort male fsmkstat lage, stable
by male fsmkstat: replace pdied = pdied[_n-1] if pdied == .

by male fsmkstat: gen small_l = 100000 if _n == 1
by male fsmkstat: replace small_l = small_l[_n-1] * (1 - pdied[_n-1]) if _n > 1

by male fsmkstat: gen big_l = small_l * (1 - 0.5 * pdied)
by male fsmkstat: gen t = sum(big_l)
by male fsmkstat: gen big_t = t[_N]
by male fsmkstat: replace big_t = big_t - t + big_l

gen big_e = big_t/big_l

keep lage male fsmokev big_e
reshape wide big_e, i(male lage) j(fsmkstat)
reshape wide big_e*, i(lage) j(male)
keep if inlist(lage,51,55,60,65,70)

exit


sort hhidpn wave, stable
by hhidpn: keep if _n == 1
