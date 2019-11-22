
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
* 9/21/2009 - Eliminated explicit PC Stata path references. Use fem_path global instead
* 9/21/2009 - Use exact ages for estimation, age_iwe, the age at the end of the interview
* 9/21/2009 - Changed the iearnx_simu and hatotax_simu filenames to ***_simulated because they are writeprotected by AHG
* 9/21/2009 - Added logdeltaage = log(age_iwe - lage_iwe) as a covariate to account for differences in time between interviews
* 12/15/2009 - Changed rbyr to frbyr as the regressor because frbyr stays at the HRS value while rbyr increases for future incoming cohorts
*  1/13/2010 - Added memrye as a health outcome
* =========================================================================*

/*********************************************************************/
*	SEP UP DIRECTORIES
/*********************************************************************/
global fem_path "/zeno/a/FEM/FEM_1.0"

global workdir "$fem_path/Estimation_2/test_restrictions"
global indata  "$fem_path/Input_yh"
global ster    "$fem_path/Estimates/econ_health_restr"
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

/*********************************************************************/
* USE DATA AND RECODE
/*********************************************************************/

cap log close
log using "$workdir/init_transition.log", replace
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
	global bin_hlth died hearte stroke cancre hibpe diabe lunge
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
	global allvars_died $dvars lage65l lage6574 lage75p $lvars_hlth $fvars
	
*** FOR CHRONIC CONDITIONS AND ORDINAL OUTCOMES
	global allvars_hlth $dvars lage65l lage6574 lage75p $lvars_hlth lobese loverwt $fvars fobese foverwt logdeltaage

	
	takestring, oldlist($allvars_hlth) newname("allvars_hearte") extlist("lhearte fhearte")
	takestring, oldlist($allvars_hlth) newname("allvars_stroke") extlist("lstroke fstroke lstroke ")
	takestring, oldlist($allvars_hlth) newname("allvars_cancre") extlist("lcancre fcancre")
	takestring, oldlist($allvars_hlth) newname("allvars_hibpe")  extlist("lhibpe fhibpe")
	takestring, oldlist($allvars_hlth) newname("allvars_diabe")  extlist("ldiabe fdiabe ")
	takestring, oldlist($allvars_hlth) newname("allvars_lunge")  extlist("llunge flunge ")

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
	global allvars_died $allvars_died $lvars_econ
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
		gen e_`n' = e(sample)
		estimates store b_`n'
		est save "$ster/`n'.ster", replace
		matrix m`n' = e(b) 
	}

label drop _all
cd "$ster"


* ESTIMATE ORDERED OUTCOMES

foreach n in $order {
	local x = "allvars_`n'"
	oprobit `n' $`x' if `n'!=-2&`n'!=9
	gen e_`n' = e(sample)
	estimates store o_`n'
	est save "$ster/`n'.ster", replace
	matrix m`n' = e(b)
}

	foreach n in $bin_hlth {
		capt log close
		quietly{
			log using `n'.csv, replace text
			noi di "probit"
			noi di "`n'"
			estimates use `n'
			local x = "allvars_`n'"
			foreach j in $`x' _cons{
				noi disp "`j'" "," _b[`j']
			}
			log close
		}
	}
	
	foreach n in $order {
		capt log close
		quietly{
			log using `n'.csv, replace text
			noi di "oprobit"
			noi di "`n'"
			estimates use `n'
			local x = "allvars_`n'"
			foreach j in $`x' "/cut1" "/cut2" "/cut3"{
				capt noi disp "`j'" "," _b[`j']
			}
			log close
		}
	}




*************************************************

clear mata
log close

#d cr



