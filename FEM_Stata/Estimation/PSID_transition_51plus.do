/* This file will produce transition models for the PSID population 51 and older. This is for comparison to the HRS */

clear all
set more off

include "../../fem_env.do"
global ster "$local_path/Estimates"

adopath ++ "$local_path/Estimation"
adopath ++ "$local_path/hyp_mata"
adopath ++ "$local_path/utilities"
adopath ++ "$local_path/Makedata/HRS"


use "$outdata/psid_transition_51plus.dta", clear

* A little data cleaning that should be done at an earlier stage of the process
drop if age == 999

* Recode adlstat and iadlstat to dummy variables (index starts at 1 for zero adl or iadl)
foreach var in ladl fadl {
	gen `var'1 = (`var'stat == 2)
	gen `var'2 = (`var'stat == 3)
	gen `var'3p = (`var'stat >= 4 & `var'stat < .)
	replace `var'1 = . if `var'stat == .
	replace `var'2 = . if `var'stat == .
	replace `var'3p = . if `var'stat == .
}
foreach var in liadl fiadl {	
 	gen `var'1 = (`var'stat == 2)
	gen `var'2p = (`var'stat >= 3 & `var'stat < .)
	replace `var'1 = . if `var'stat == .
	replace `var'2p = . if `var'stat == .
}

* Generate age dummy variables
local age_var age
	gen lage65l  = min(63,l`age_var') if l`age_var' < .
	gen lage6574 = min(max(0,l`age_var'-63),73-63) if l`age_var' < .
	gen lage75p = max(0, l`age_var'-73) if l`age_var' < . 

	* Generate obestiy splines
	gen llogbmi = log(lbmi)
	gen flogbmi = log(fbmi)	
	local log_30 = log(30)
	mkspline llogbmi_l30 `log_30' llogbmi_30p = llogbmi
	mkspline flogbmi_l30 `log_30' flogbmi_30p = flogbmi
	
	
	* Generate logbmi outcome variable
	gen logbmi = log(bmi) if bmi > 0 & bmi < .
	
	* To be consistent with FEM: Transform earnings and wealth into $thousands, cap earnings at 200K and wealth at 2 million
	foreach var in iearn fiearn liearn {
		replace `var' = `var'/1000
		gen `var'x = min(`var',200)
	}
	
	foreach var in hatota fhatota lhatota {
		replace `var' = `var'/1000
		gen `var'x = min(`var',2000)
	}
		
	foreach i in hatota hatotax iearn iearnx {
		egen flog`i' = h(f`i')
		replace flog`i' = flog`i'/100
		egen llog`i' = h(l`i')
		replace llog`i' = llog`i'/100
	}
	
	* Generate "nonzero" variables 
	gen wlth_nonzero = hatota != 0 if hatota < .
	gen fwlth_nonzero = fhatota != 0 if fhatota < .
	gen lwlth_nonzero = lhatota != 0 if lhatota < .
	

*** Dependent variables
* Binary health outcomes
global bin_hlth died hearte stroke cancre hibpe diabe lunge
* Binary econ outcomes - removing dbclaim nhmliv wlth_nonzero hicap_nonzero
global bin_econ anyhi diclaim oasiclaim  ssiclaim work 
* Ordered outcomes
global order adlstat iadlstat smkstat


* Building blocks for RHS variables
global dvars black hispan hsless college male 
global agevars lage65l lage6574 lage75p
* Removing iadl* variables since they aren't definted before 2003.
global lvars_hlth lhearte lstroke lcancre lhibpe ldiabe llunge ladl1 ladl2 ladl3p lsmoken lwidowed 

*** values of econ variables at time t-1  - Removing: ldbclaim lnhmliv llogiearnx lwlth_nonzero lloghatotax
	global lvars_econ lwork  ldiclaim lssiclaim loasiclaim 

* Removing fiadl* variables since they aren't defined before 2003.
#d;
	global fvars fhearte fstroke fcancre fhibpe fdiabe flunge fsmokev fsmoken fadl1 fadl2 fadl3p
	fwidowed fsingle  
	fwork flogiearnx fwlth_nonzero floghatotax
	fshlt ;
#d cr

global bmivars llogbmi_l30 llogbmi_30p flogbmi_l30 flogbmi_30p

global allvars_hlth $dvars $agevars $lvars_hlth $fvars $bmivars


*** Binary Health Outcomes ***
	* Mortality
	global allvars_died $dvars lage65l lage6574 lage75p $lvars_hlth $fvars
	* Hearte
	takestring, oldlist($allvars_hlth) newname("allvars_hearte") extlist("lhearte fhearte lstroke llunge lcancre ladl1 ladl2 ladl3p")
	* Stroke 
	takestring, oldlist($allvars_hlth) newname("allvars_stroke") extlist("lstroke fstroke lstroke llunge ladl1 ladl2 ladl3p")
	* Cancre
	takestring, oldlist($allvars_hlth) newname("allvars_cancre") extlist("lhearte lstroke lcancre lhibpe ldiabe llunge fcancre ladl1 ladl2 ladl3p")
	* Hibpe
	takestring, oldlist($allvars_hlth) newname("allvars_hibpe")  extlist("lhearte lstroke lcancre lhibpe llunge fhibpe ladl1 ladl2 ladl3p")
	* Diabe
	takestring, oldlist($allvars_hlth) newname("allvars_diabe")  extlist("lhearte lstroke lcancre lhibpe ldiabe llunge fdiabe ladl1 ladl2 ladl3p")
	* Lunge
	takestring, oldlist($allvars_hlth) newname("allvars_lunge")  extlist("lhearte lstroke lcancre lhibpe ldiabe llunge flunge ladl1 ladl2 ladl3p")

*** Continuous Health Outcomes ***
	* Log BMI
	global allvars_logbmi $allvars_hlth

*** Ordered Health Outcomes ***
	* ADL status
	global allvars_adlstat $allvars_hlth
  * IADL status
  global allvars_iadlstat $allvars_hlth
  * Smoking status
	global allvars_smkstat $allvars_hlth


*** Binary Econ Outcomes ***
	global allvars_econ1 $dvars lage65l lage6574 lage75p $lvars_hlth $lvars_econ $fvars
	takestring, oldlist($allvars_econ1) newname("allvars_anyhi") 
	takestring, oldlist($allvars_econ1) newname("allvars_diclaim")
	takestring, oldlist($allvars_econ1) newname("allvars_oasiclaim")
	takestring, oldlist($allvars_econ1) newname("allvars_ssiclaim")
	takestring, oldlist($allvars_econ1) newname("allvars_work")

**************************************************
* Estimate binary outcome
**************************************************
foreach n of varlist $bin_hlth $bin_econ {
	local x = "allvars_`n'"
	probit `n' $`x' if `n'!=-2&`n'!=9
	gen e_`n' = e(sample)
	  mfx2, stub(b_`n') nose
	est save "$ster/`n'.ster", replace
	matrix m`n' = e(b) 
	predict simu_`n' if e_`n' == 1
}

/*********************************************************************/
* ESTIMATE OLS on LOG BMI
/*********************************************************************/

	foreach n in logbmi {
		local x = "allvars_`n'"
		reg `n' $`x' if bmi < .
		gen e_`n' = e(sample)
                mfx2, stub(ols_`n') nose
		est save "$ster/`n'.ster", replace
		matrix m`n' = e(b) 
		predict simu_`n' if e_`n' == 1
	}



/*********************************************************************/
* ESTIMATE ORDERED OUTCOMES
/*********************************************************************/
foreach n in $order {
	local x = "allvars_`n'"
	oprobit `n' $`x' if `n'!=-2&`n'!=9
	gen e_`n' = e(sample)
        mfx2, stub(o_`n') nose
	est save "$ster/`n'.ster", replace
	matrix m`n' = e(b)
	predict simu_`n' if e_`n' == 1
}


save $outdata/psid_predicted_outcomes.dta, replace





 capture log close