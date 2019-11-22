
clear
cap clear mata
set mem 500m
set more off
set seed 52432
*set maxvar 10000
est drop _all

***************************
*	SEP UP DIRECTORIES
****************************

global fem_path "/zeno/a/FEM/FEM_1.0"

global workdir "$fem_path/Estimation_2/test_restrictions"
global indata  "$fem_path/Input_yh"
global ster    "$fem_path/Estimates"
global outdata "$fem_path/Input_yh"
global netdir  "/homer/c/Retire/FEM/rdata"
global outdir "$fem_path/Input_yh/all"
	
cd "$fem_path/Makedata/HRS"
capt takestring
cd "$fem_path/Estimation_2"
capt estout

global ghregdir "$fem_path/Code"
* adopath ++ "\\zeno\zeno_a\zyuhui\DOL\PC"
adopath ++ "$fem_path/Makedata/HRS"
adopath ++ "$fem_path/Estimation_2"
adopath ++ "$fem_path/Code"

************************
* USE DATA AND RECODE
************************

cap log close
log using "$workdir/test_health_restriction.log", replace
dis "Current time is: " c(current_time) " on " c(current_date)

use "$netdir/hrs17r_transition.dta", clear
* FOR hacohort = 0 & 1 in wave 2 & 3 no info on SSI claiming
	replace ssiclaim = -2 if inlist(hacohort, 0, 1) & inlist(wave,3,4)

	cd  "$fem_path/Code"

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
	global bin_hlth hearte stroke cancre hibpe diabe lunge
	global order wtstate smkstat funcstat

*** GENERATE THE AGE SPLINE VARIABLES
	foreach x in lage6061 lage6263 lage64e lage6566 lage6770 lage65l lage6574 lage75l lage75p lage62e lage63e {
		cap drop `x'
	}
		
	local age_var age_iwe
	
	gen lage6061 = floor(l`age_var') == 58 | floor(l`age_var') == 59 if l`age_var' < .
	gen lage6263 = inrange(floor(l`age_var'),60,61) if l`age_var' < .
	gen lage64e = floor(l`age_var') == 62 if l`age_var' < . 
	gen lage6566 = floor(l`age_var') == 63 | floor(l`age_var') == 64 if l`age_var' < .
	gen lage6770 = inrange(floor(l`age_var'),65,68) if l`age_var' < . 
	
	gen lage65l  = min(63,l`age_var') if l`age_var' < .
	gen lage6574 = min(max(0,l`age_var'-63),73-63) if l`age_var' < .
	gen lage75l = min(l`age_var', 73) if l`age_var' < . 
	gen lage75p = max(0, l`age_var'-73) if l`age_var' < . 
	
	gen lage62e = floor(l`age_var') == 60 if l`age_var' < .
	gen lage63e = floor(l`age_var') == 61 if l`age_var' < .

	mkspline la6 58 la7 73 la7p = l`age_var'

	gen logdeltaage = log(`age_var' - l`age_var')

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
	global fvars fhearte fstroke fcancre fhibpe fdiabe flunge fsmokev fsmoken fiadl1 fadl12 fadl3 
	fwidowed fsingle fwork flogiearnx fwlth_nonzero floghatotax 
	flogaime flogq fshlt fanydb frdb_na_2 frdb_na_3 frdb_na_4 fanydc flogdcwlthx ;
#d cr
*** values of health variables at t-1
	global lvars_hlth lhearte lstroke lcancre lhibpe ldiabe llunge liadl1 ladl12 ladl3 lsmoken lwidowed 
*** values of econ variables at time t-1
	global lvars_econ lwork llogiearnx lwlth_nonzero lloghatotax ldiclaim lssiclaim lssclaim ldbclaim lnhmliv

*** FOR MORTALITY
	global allvars_died $dvars lage65l lage6574 lage75p $lvars_hlth $fvars fmemrye lmemrye
	
*** FOR CHRONIC CONDITIONS AND ORDINAL OUTCOMES
	global allvars_hlth $dvars lage65l lage6574 lage75p $lvars_hlth lobese loverwt $fvars fobese foverwt logdeltaage

	local restr_hearte lstroke llunge lcancre liadl1 ladl12 ladl3 
	local restr_stroke llunge liadl1 ladl12 ladl3
	local restr_cancre lhearte lstroke lhibpe ldiabe llunge liadl1 ladl12 ladl3
	local restr_hibpe lhearte lstroke lcancre llunge liadl1 ladl12 ladl3
	local restr_diabe lhearte lstroke lcancre lhibpe llunge liadl1 ladl12 ladl3
	local restr_lunge lhearte lstroke lcancre lhibpe ldiabe liadl1 ladl12 ladl3
	
	
	
	takestring, oldlist($allvars_hlth) newname("allvars_hearte") extlist("lhearte fhearte")
	takestring, oldlist($allvars_hlth) newname("allvars_stroke") extlist("lstroke fstroke lstroke ")
	takestring, oldlist($allvars_hlth) newname("allvars_cancre") extlist("lcancre fcancre")
	takestring, oldlist($allvars_hlth) newname("allvars_hibpe")  extlist("lhibpe fhibpe")
	takestring, oldlist($allvars_hlth) newname("allvars_diabe")  extlist("ldiabe fdiabe ")
	takestring, oldlist($allvars_hlth) newname("allvars_lunge")  extlist("llunge flunge ")
	takestring, oldlist($allvars_hlth) newname("allvars_memrye") extlist("lhearte lstroke lcancre lhibpe ldiabe llunge flunge")

	local restr_smkstat
	local restr_funcstat 
	local restr_wtstate 
	
	global allvars_smkstat $allvars_hlth
	global allvars_funcstat $allvars_hlth
	global allvars_wtstate $allvars_hlth frbyr

***ADD IN ECONOMIC VALUES***
	global allvars_hearte $allvars_hearte $lvars_econ
	global allvars_stroke $allvars_stroke $lvars_econ
	global allvars_cancre $allvars_cancre $lvars_econ
	global allvars_hibpe $allvars_hibpe $lvars_econ
	global allvars_diabe $allvars_diabe $lvars_econ
	global allvars_lunge $allvars_lunge $lvars_econ
	global allvars_wtstate $allvars_wtstate $lvars_econ
	global allvars_smkstat $allvars_smkstat $lvars_econ
	global allvars_funcstat $allvars_funcstat $lvars_econ
 
	
	


set more off

/*********************************************************************/
* ESTIMATE BINARY OUTCOMES
/*********************************************************************/
	foreach n in $bin_hlth {
		local x = "allvars_`n'"
		probit `n' $`x' if `n'!=-2&`n'!=9
		foreach k in `restr_`n''{
			test `k', a
		}
	}


* ESTIMATE ORDERED OUTCOMES

foreach n in $order {
	local x = "allvars_`n'"
	oprobit `n' $`x' if `n'!=-2&`n'!=9
		foreach k in `restr_`n''{
			test `k', a
		}
}




cd "$workdir"

log close





