
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
*2/26 - expand BMI
*3/11/2010 - Change BMI estimation to be ols on log(bmi)
* =========================================================================*

/*********************************************************************/
*	SEP UP DIRECTORIES
/*********************************************************************/

* Assume that this script is being executed in the FEM_Stata/Estimation_2 directory

* Load environment variables from the root FEM directory, three levels up
* these define important paths, specific to the user
include "../../../fem_env.do"

* Define paths
global workdir  			"$local_path/Estimation/test_restrictions"
global ster    				"$local_path/Estimates/econ_restr"
global outdir 				"$local_path/Estimates/econ_restr"
	
cd "$local_path/Makedata/HRS"
capt takestring
cd "$local_path/Estimation"
capt estout

global ghregdir "$local_path/Code"
adopath ++ "$local_path/Makedata/HRS"
adopath ++ "$local_path/Estimation"
adopath ++ "$local_path/Code"

/*********************************************************************/
* USE DATA AND RECODE
/*********************************************************************/

cap log close
log using "$workdir/init_transition_econ.log", replace
dis "Current time is: " c(current_time) " on " c(current_date)

/* For iteration over BMI specifications
forvalues bmi_ver = 0/4 {
global ster    				"$local_path/Estimates/bmi_spline`bmi_ver'"
global outdir 				"$local_path/Estimates/bmi_spline`bmi_ver'"
*/

local bmi_ver = 2

use "$netdir/hrs17r_transition.dta", clear
* FOR hacohort = 0 & 1 in wave 2 & 3 no info on SSI claiming
	replace ssiclaim = -2 if inlist(hacohort, 0, 1) & inlist(wave,3,4)

	cd  "$local_path/Code"

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
	global order smkstat funcstat

	
	/* Definition 0 */
	if `bmi_ver' == 0 {
		global bmivars loverwt lobese_1 lobese_2 lobese_3 foverwt fobese_1 fobese_2 fobese_3
	}
	
	/* Definition 1 */
	else if `bmi_ver' == 1 {
		foreach x in lobese_1 lobese_2 lobese_3 loverwt lnormwt fobese_1 fobese_2 fobese_3 foverwt fnormwt {
			cap drop `x'
		}

		mkspline lnormwt 25 loverwt 30 lobese_1 40 lobese_2 = lbmi
		mkspline fnormwt 25 foverwt 30 fobese_1 40 fobese_2 = fbmi
		
		global bmivars lnormwt loverwt lobese_1 lobese_2 fnormwt foverwt fobese_1 fobese_2
	}
	
	/* Definition 2 */
	else if `bmi_ver' == 2 {
		foreach x in lobese_1 lobese_2 lobese_3 loverwt lnormwt fobese_1 fobese_2 fobese_3 foverwt fnormwt {
			cap drop `x'
		}
		
		local log_30 = log(30)
		mkspline llogbmi_l30 `log_30' llogbmi_30p = llogbmi
		mkspline flogbmi_l30 `log_30' flogbmi_30p = flogbmi
		
		global bmivars llogbmi_l30 llogbmi_30p flogbmi_l30 flogbmi_30p
	}
	
	/* Definition 3 */
	else if `bmi_ver' == 3 {
		foreach x in lobese_1 lobese_2 lobese_3 loverwt lnormwt fobese_1 fobese_2 fobese_3 foverwt fnormwt {
			cap drop `x'
		}
		
		mkspline lbmi_l30 30 lbmi_30p = lbmi
		mkspline fbmi_l30 30 fbmi_30p = fbmi
		
		global bmivars lbmi_l30 lbmi_30p fbmi_l30 fbmi_30p
	}
	
		/* Definition 4 */
	else if `bmi_ver' == 4 {
		foreach x in lobese_1 lobese_2 lobese_3 loverwt lnormwt fobese_1 fobese_2 fobese_3 foverwt fnormwt {
			cap drop `x'
		}
		
		global bmivars lbmi fbmi
	}


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
	global allvars_hlth $dvars lage65l lage6574 lage75p $lvars_hlth  $fvars $bmivars logdeltaage

	takestring, oldlist($allvars_hlth) newname("allvars_hearte") extlist("lhearte fhearte lstroke llunge lcancre liadl1 ladl12 ladl3")
	takestring, oldlist($allvars_hlth) newname("allvars_stroke") extlist("lstroke fstroke lstroke llunge liadl1 ladl12 ladl3")
	takestring, oldlist($allvars_hlth) newname("allvars_cancre") extlist("lhearte lstroke lcancre lhibpe ldiabe llunge fcancre liadl1 ladl12 ladl3")
	takestring, oldlist($allvars_hlth) newname("allvars_hibpe")  extlist("lhearte lstroke lcancre lhibpe llunge fhibpe liadl1 ladl12 ladl3")
	takestring, oldlist($allvars_hlth) newname("allvars_diabe")  extlist("lhearte lstroke lcancre lhibpe ldiabe llunge fdiabe liadl1 ladl12 ladl3")
	takestring, oldlist($allvars_hlth) newname("allvars_lunge")  extlist("lhearte lstroke lcancre lhibpe ldiabe llunge flunge liadl1 ladl12 ladl3")
	takestring, oldlist($allvars_hlth) newname("allvars_memrye") extlist("lhearte lstroke lcancre lhibpe ldiabe llunge flunge")

	global allvars_smkstat $allvars_hlth
	global allvars_funcstat $allvars_hlth
	
	global allvars_logbmi $allvars_hlth frbyr
	
***ADD IN ECONOMIC VALUES***
	global allvars_hearte $allvars_hearte $lvars_econ
	global allvars_stroke $allvars_stroke $lvars_econ
	global allvars_cancre $allvars_cancre $lvars_econ
	global allvars_hibpe $allvars_hibpe $lvars_econ
	global allvars_diabe $allvars_diabe $lvars_econ
	global allvars_lunge $allvars_lunge $lvars_econ
	global allvars_died $allvars_died $lvars_econ
	global allvars_logbmi $allvars_logbmi $lvars_econ
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
	
/*********************************************************************/
* ESTIMATE OLS on LOG BMI
/*********************************************************************/

	foreach n in logbmi {
		local x = "allvars_`n'"
		reg `n' $`x' if bmi < .
		gen e_`n' = e(sample)
		estimates store b_`n'
		est save "$ster/`n'.ster", replace
		matrix m`n' = e(b) 
	}



/*********************************************************************/
* ESTIMATE ORDERED OUTCOMES
/*********************************************************************/
foreach n in $order {
	local x = "allvars_`n'"
	oprobit `n' $`x' if `n'!=-2&`n'!=9
	gen e_`n' = e(sample)
	estimates store o_`n'
	est save "$ster/`n'.ster", replace
	matrix m`n' = e(b)
}
/* End iterations over BMI  specifications
}
 */
 
label drop _all
cd "$ster"

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
	
	foreach n in logbmi {
		capt log close
		quietly{
			log using `n'.csv, replace text
			noi di "regress"
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


