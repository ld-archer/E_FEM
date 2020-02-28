 /* Estimate transition models using the ELSA dataset */

quietly include ../../fem_env.do

local in_file : env INPUT

local out_file : env OUTPUT

local ster "$local_path/Estimates/ELSA" /* ster file for storing estimates */
*local ster "../Estimates/ELSA" /* ster file for storing estimates */


use $outdata/ELSA_transition.dta
*use ../../input_data/ELSA_transition.dta


* Globals for dependant variables
global bin_hlth cancre diabe hearte hibpe lunge stroke arthre psyche died asthmae parkine drink smoke_start smoke_stop smoken smokev
global bin_econ work hlthlm retemp
global ols logbmi retage ipubpen atotf itearn smokef
global order adlstat iadlstat drinkd drinkd_stat vgactx_e mdactx_e ltactx_e smkstat

*Death
global allvars_died male hsless college l2age65l l2age6574 l2age75p l2cancre l2diabe l2hearte l2hibpe l2lunge l2stroke l2adl1 l2adl2 l2adl3p l2iadl1 l2iadl2p l2logbmi l2smokev l2smoken l2drink l2drinkd_stat
* cancre
global allvars_cancre male hsless college l2age65l l2age6574 l2age75p l2logbmi smokev l2smoken l2drink l2drinkd_stat l2smokef
global allvars_diabe male hsless college l2age65l l2age6574 l2age75p l2logbmi l2smokev l2smoken l2drink l2drinkd_stat
global allvars_hearte male hsless college l2age65l l2age6574 l2age75p l2hibpe l2diabe l2logbmi l2smokev l2smoken l2smokef l2drink l2drinkd_stat
global allvars_hibpe male hsless college l2age65l l2age6574 l2age75p l2diabe l2logbmi l2smokev l2smoken l2hearte l2drink l2drinkd_stat
* lunge
global allvars_lunge male hsless college l2age65l l2age6574 l2age75p l2logbmi l2smokev l2smoken l2smokef
global allvars_stroke male hsless college l2age65l l2age6574 l2age75p l2hearte l2cancre l2hibpe l2diabe l2logbmi l2smokev l2smoken l2smokef l2drink l2drinkd_stat
global allvars_anyadl male hsless college l2age65l l2age6574 l2age75p l2hearte l2cancre l2hibpe l2diabe l2logbmi l2smokev l2smoken l2smokef l2psyche l2arthre l2drink l2drinkd_stat
global allvars_anyiadl male hsless college l2age65l l2age6574 l2age75p l2hearte l2cancre l2hibpe l2diabe l2logbmi l2smokev l2smoken l2smokef l2psyche l2arthre l2drink l2drinkd_stat
global allvars_arthre male hsless college l2age65l l2age6574 l2age75p l2hearte l2stroke l2cancre l2hibpe l2diabe l2logbmi l2smokev l2smoken l2work
global allvars_psyche male hsless college l2age65l l2age6574 l2age75p l2hearte l2stroke l2cancre l2hibpe l2diabe l2logbmi l2smokev l2smoken l2work l2drink l2drinkd l2drinkd_stat
global allvars_asthmae male hsless college l2age65l l2age6574 l2age75p l2lunge l2logbmi l2smokev l2smoken l2smokef
global allvars_parkine male hsless college l2age65l l2age6574 l2age75p l2diabe  l2stroke l2logbmi l2smokev l2smoken l2drink l2drinkd_stat

* smoke_start and smoke_stop
global allvars_smoke_start male hsless college l2age65l l2age6574 l2age75p l2logbmi l2drink l2drinkd_stat l2cancre l2diabe l2hearte l2hibpe l2lunge l2stroke l2adl1 l2adl2 l2adl3p l2iadl1 l2iadl2p l2logbmi l2psyche l2arthre l2asthmae l2parkine
***********************************
global allvars_smoke_stop male hsless college l2age65l l2age6574 l2age75p l2logbmi l2drink l2drinkd_stat l2cancre l2diabe l2hearte l2hibpe l2lunge l2stroke l2adl1 l2adl2 l2adl3p l2iadl1 l2iadl2p l2logbmi l2psyche l2arthre l2asthmae l2parkine
global allvars_drink male hsless college l2age65l l2age6574 l2age75p l2logbmi l2smoken l2smokef l2cancre l2diabe l2hearte l2hibpe l2lunge l2stroke l2adl1 l2adl2 l2adl3p l2iadl1 l2iadl2p l2logbmi l2psyche l2arthre l2asthmae l2parkine
* male hsless college l2age65l l2age6574 l2age75p l2logbmi l2drink l2drinkd_stat l2smokef
* smoken and smokev
* Look at Hymovitz et. al (1997) for justification for some of the vars as smoking predictors (like drinkd_stat. Need to add smokef to this??)(Could also add var for self-reported health measures as paper says its important)
global allvars_smoken male hsless college l2age65l l2age6574 l2age75p l2logbmi l2drink l2drinkd_stat l2atotf l2itearn l2cancre l2diabe l2hearte l2hibpe l2lunge l2stroke l2adl1 l2adl2 l2adl3p l2iadl1 l2iadl2p l2psyche l2arthre l2asthmae l2parkine
global allvars_smokev male hsless college l2age65l l2age6574 l2age75p l2logbmi l2drink l2drinkd_stat l2atotf l2itearn l2cancre l2diabe l2hearte l2hibpe l2lunge l2stroke l2adl1 l2adl2 l2adl3p l2iadl1 l2iadl2p l2psyche l2arthre l2asthmae l2parkine
* smokef is xsectional so don't use lags of chronic diseases/choices as right hand variables
global allvars_smokef male hsless college l2age65l l2age6574 l2age75p logbmi drink drinkd_stat atotf itearn cancre diabe hearte hibpe lunge stroke adl1 adl2 adl3p iadl1 iadl2p psyche arthre asthmae parkine

global allvars_work male hsless college l2age65l l2age6574 l2age75p l2hearte l2stroke l2cancre l2hibpe l2diabe l2lunge l2logbmi l2work l2adl1 l2adl2 l2adl3p l2iadl1 l2iadl2p l2psyche l2arthre l2parkine
global allvars_hlthlm male hsless college l2age65l l2age6574 l2age75p hearte stroke cancre hibpe diabe lunge logbmi adl1 adl2 adl3p iadl1 iadl2p smokev smoken smokef arthre psyche asthmae parkine drink drinkd_stat
global allvars_retemp male hsless college l2age65l l2age6574 l2age75p l2hearte l2stroke l2cancre l2hibpe l2diabe l2lunge l2logbmi l2work l2adl1 l2adl2 l2adl3p l2iadl1 l2iadl2p l2psyche l2arthre l2asthmae l2parkine l2hlthlm 

global allvars_logbmi male hsless college l2age65l l2age6574 l2age75p l2cancre l2diabe l2hearte l2hibpe l2lunge l2stroke l2adl1 l2adl2 l2adl3p l2iadl1 l2iadl2p l2logbmi l2smoken l2psyche l2arthre l2asthmae l2parkine l2drink l2drinkd_stat
global allvars_retage male hsless college l2age65l l2age6574 l2age75p l2cancre l2diabe l2hearte l2hibpe l2lunge l2stroke l2adl1 l2adl2 l2adl3p l2iadl1 l2iadl2p l2logbmi l2smokev l2work hlthlm l2arthre l2psyche l2asthmae l2parkine
global allvars_ipubpen male hsless college l2age65l l2age6574 l2age75p l2cancre l2diabe l2hearte l2hibpe l2lunge l2stroke l2adl1 l2adl2 l2adl3p l2iadl1 l2iadl2p l2logbmi l2smokev l2smoken l2itearn l2work hlthlm l2arthre l2psyche l2asthmae l2parkine
global allvars_atotf male hsless college l2age65l l2age6574 l2age75p l2cancre l2diabe l2hearte l2hibpe l2lunge l2stroke l2adl1 l2adl2 l2adl3p l2iadl1 l2iadl2p l2logbmi l2smokev l2smoken l2itearn work l2work hlthlm l2arthre l2psyche l2asthmae l2parkine
global allvars_itearn male hsless college l2age65l l2age6574 l2age75p l2cancre l2diabe l2hearte l2hibpe l2lunge l2stroke l2adl1 l2adl2 l2adl3p l2iadl1 l2iadl2p l2logbmi l2smokev l2smoken l2itearn work l2work hlthlm l2arthre l2psyche l2asthmae l2parkine l2drink l2drinkd_stat

global allvars_adlstat male hsless college l2age65l l2age6574 l2age75p l2cancre l2diabe l2hearte l2hibpe l2lunge l2stroke l2adl1 l2adl2 l2adl3p l2iadl1 l2iadl2p l2logbmi l2psyche l2arthre l2asthmae l2parkine l2drink l2drinkd_stat
global allvars_iadlstat male hsless college l2age65l l2age6574 l2age75p l2cancre l2diabe l2hearte l2hibpe l2lunge l2stroke l2adl1 l2adl2 l2adl3p l2iadl1 l2iadl2p l2logbmi l2psyche l2arthre l2asthmae l2parkine l2drink l2drinkd_stat
* drinkd_stat 
global allvars_drinkd_stat male hsless college l2age65l l2age6574 l2age75p l2logbmi l2cancre l2diabe l2hearte l2hibpe l2lunge l2stroke l2adl1 l2adl2 l2adl3p l2iadl1 l2iadl2p l2psyche l2arthre l2asthmae l2parkine
global allvars_drinkd male hsless college l2age65l l2age6574 l2age75p l2logbmi l2cancre l2diabe l2hearte l2hibpe l2lunge l2stroke l2adl1 l2adl2 l2adl3p l2iadl1 l2iadl2p l2psyche l2arthre l2asthmae l2parkine
global allvars_vgactx_e male hsless college l2age65l l2age6574 l2age75p l2cancre l2diabe l2hearte l2hibpe l2lunge l2stroke l2adl1 l2adl2 l2adl3p l2iadl1 l2iadl2p l2logbmi l2psyche l2arthre l2asthmae l2parkine l2smokev l2smoken
global allvars_mdactx_e male hsless college l2age65l l2age6574 l2age75p l2cancre l2diabe l2hearte l2hibpe l2lunge l2stroke l2adl1 l2adl2 l2adl3p l2iadl1 l2iadl2p l2logbmi l2psyche l2arthre l2asthmae l2parkine l2smokev l2smoken
global allvars_ltactx_e male hsless college l2age65l l2age6574 l2age75p l2cancre l2diabe l2hearte l2hibpe l2lunge l2stroke l2adl1 l2adl2 l2adl3p l2iadl1 l2iadl2p l2logbmi l2psyche l2arthre l2asthmae l2parkine l2smokev l2smoken
* smkstat
global allvars_smkstat male hsless college l2age65l l2age6574 l2age75p l2logbmi l2drink l2drinkd_stat l2atotf l2itearn l2cancre l2diabe l2hearte l2hibpe l2lunge l2stroke l2adl1 l2adl2 l2adl3p l2iadl1 l2iadl2p l2psyche l2arthre l2asthmae l2parkine


* selection criteria for models that only rely on lag value and not being dead
local select_died !l2died 
foreach var in cancre diabe hearte hibpe lunge stroke arthre psyche asthmae parkine anyadl anyiadl {
	local select_`var' !l2`var' & !died 
}

* Selection criteria for models that only rely on not being dead
foreach var in adlstat iadlstat smkstat work retemp atotf drink vgactx_e mdactx_e ltactx_e smoken smokev {
	local select_`var' !died
}


* Selection criteria for models with specific requirements
local select_smoke_start !died & l2smoken == 0
local select_smoke_stop !died & l2smoken == 1
local select_smokef !died & smoken==1
local select_hlthlm !died & wave > 1
local select_itearn !died
local select_ipubpen !died & work == 0
local select_retage !died & retemp == 1
local select_drinkd_stat !died & drink == 1 & wave > 1
local select_drinkd !died & drink == 1 & wave > 1
local select_logbmi !died & (wave==2 | wave==4 | wave==6) /* Only estimate bmi model using waves 2,4,6 as other waves are imputed */


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
