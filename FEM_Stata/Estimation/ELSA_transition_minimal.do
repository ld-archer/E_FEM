/* Estimate transition models using the ELSA dataset */

quietly include ../../fem_env.do

local in_file : env INPUT

local out_file : env OUTPUT

local ster "$local_path/Estimates/ELSA/minimal" /* ster file for storing estimates */
*local ster "../Estimates/ELSA/minimal" /* ster file for storing estimates */


/* Add switch for cross-validation to use a different ster dir
	Change selection criteria for models to include transition == 1
	
	
	THIS IS PART OF USING THE SAME SCRIPTS FOR NORMAL E_FEM USE AS WELL AS CROSS_VALIDATION
	Using the same scripts would be ideal as then wouldn't need to modify multiple scripts to make a change
	Also would make the Makefile rules a lot nicer? Just better in general, easy enough to do
	
	
	
	
	Produce a minimal version of transition models with only demographic vars
	Age, sex, education
	
*/


use $outdata/cross_validation/transition_CV.dta
*use ../../input_data/cross_validation/transition_CV.dta


* Globals for dependant variables
global bin_hlth cancre diabe hearte hibpe lunge stroke arthre psyche died asthmae parkine drink smoke_start smoke_stop smoken smokev
global bin_econ work hlthlm retemp
global ols logbmi retage ipubpen atotf itearn smokef
global order adlstat iadlstat drinkd drinkd_stat vgactx_e mdactx_e ltactx_e smkstat



* Local for the demographic vars to include in models
local dvars male white hsless college

local bmivars l2logbmi


*Death
global allvars_died `dvars'

* Chronic Diseases
global allvars_cancre `dvars'
global allvars_diabe `dvars'
global allvars_hearte `dvars'
global allvars_hibpe `dvars'
global allvars_lunge `dvars'
global allvars_stroke `dvars'

global allvars_arthre `dvars'
global allvars_psyche `dvars'
global allvars_asthmae `dvars'
global allvars_parkine `dvars'

* Smoking. Look at Hymovitz et. al (1997) for justification for some of the vars as smoking predictors (Could also add var for self-reported health measures as paper says its important)
global allvars_smoke_start `dvars'
global allvars_smoke_stop `dvars'
global allvars_smoken `dvars'
global allvars_smokev `dvars'
* smokef is xsectional so don't use lags of chronic diseases/choices as right hand variables
global allvars_smokef `dvars'
global allvars_smkstat `dvars'

* Drinking
global allvars_drink `dvars'
global allvars_drinkd_stat `dvars'
global allvars_drinkd `dvars'

* Logbmi & other health
global allvars_logbmi `dvars'
global allvars_hlthlm `dvars'

* Disabilities
global allvars_anyadl `dvars'
global allvars_anyiadl `dvars'
global allvars_adlstat `dvars'
global allvars_iadlstat `dvars'

* Economic
global allvars_work `dvars'
global allvars_retemp `dvars'
global allvars_retage `dvars'
global allvars_ipubpen `dvars'
global allvars_atotf `dvars'
global allvars_itearn `dvars'

* Exercise
global allvars_vgactx_e `dvars'
global allvars_mdactx_e `dvars'
global allvars_ltactx_e `dvars'



* selection criteria for models that only rely on lag value and not being dead
local select_died !l2died 
foreach var in cancre diabe hearte hibpe lunge stroke arthre psyche asthmae parkine anyadl anyiadl {
	local select_`var' !l2`var' & !died 
}

* Selection criteria for models that only rely on not being dead
foreach var in adlstat iadlstat smkstat work retemp itearn atotf drink vgactx_e mdactx_e ltactx_e smoken smokev {
	local select_`var' !died
}


* Selection criteria for models with specific requirements
local select_smoke_start !died & l2smoken == 0
local select_smoke_stop !died & l2smoken == 1
local select_smokef !died & smoken==1
local select_hlthlm !died & wave > 1
local select_ipubpen !died & work == 0
local select_retage !died & retemp == 1
local select_drinkd !died & drink == 1 & wave > 1
local select_drinkd_stat !died & drink == 1 & wave > 1
local select_logbmi !died & (wave==2 | wave==4 | wave==6 | wave==8) /* Only estimate bmi model using waves 2,4,6,8 as other waves are imputed */


/*********************************************************************/
* ESTIMATE BINARY OUTCOMES
/*********************************************************************/

foreach n of varlist $bin_hlth $bin_econ {
	local x = "allvars_`n'"
	probit `n' $`x' if `select_`n''
  mfx2, stub(b_`n') se
  est save "`ster'/`n'.ster", replace
}

/*********************************************************************/
* ESTIMATE OLS
/*********************************************************************/

foreach n in $ols {
	local x = "allvars_`n'"
	reg `n' $`x' if `select_`n''
 	mfx2, stub(ols_`n') se
  est save "`ster'/`n'.ster", replace
  est restore ols_`n'_mfx
  est store ols_`n'_mfx
}

/*********************************************************************/
* ESTIMATE ORDERED OUTCOMES
/*********************************************************************/

foreach n in $order {
	local x = "allvars_`n'"
  oprobit `n' $`x' if `select_`n''
  mfx2, stub(o_`n') se
  est save "`ster'/`n'.ster", replace
}

* xml_tab b_*, save(test.xml) append sheet(ols) pvalue
* xml_tab ols_*, save(test.xml) append sheet(ols) pvalue
* xml_tab o_*, save(test.xml) append sheet(ordered) pvalue

 * Unsure of what to change here, modify when outputs are understood more
xml_tab b_*, save(test.xml) replace sheet(binaries) pvalue
xml_tab ols_*, save(test.xml) append sheet(ols) pvalue
xml_tab o_*, save(test.xml) append sheet(ordered) pvalue

capture log close
