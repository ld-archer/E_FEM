/* Estimate transition models using the ELSA dataset */

quietly include ../../../fem_env.do

local in_file : env INPUT

local out_file : env OUTPUT

if "`in_file'" == "ELSA_transition" {
	local ster "$local_path/Estimates/ELSA" /* ster file for storing estimates */
}
else {
	local ster "$local_path/Estimates/ELSA_crossvalidation"
}

*use $outdata/`in_file'.dta
*use input_data/ELSA_transition.dta
/* Need correct filename here when known */

* Globals for dependant variables
global bin_hlth cancre diabe hearte hibpe lunge stroke arthre psyche died smokev smoken smokef
global bin_econ /* Have anything for here yet? */
global ols logbmi
global order adlstat iadlstat

global allvars_died male hsless college l2age65l l2age6574 l2age75p l2cancre l2diabe l2hearte l2hibpe l2lunge l2stroke l2adl1 l2adl2 l2adl3p l2iadl1 l2iadl2p l2logbmi smokev smoken smokef
global allvars_cancre male hsless college l2age65l l2age6574 l2age75p l2logbmi smokev smoken smokef
global allvars_diabe male hsless college l2age65l l2age6574 l2age75p l2logbmi smokev smoken smokef /* Smoking vars here? */
global allvars_hearte male hsless college l2age65l l2age6574 l2age75p l2hibpe l2diabe l2logbmi smokev smoken smokef
global allvars_hibpe male hsless college l2age65l l2age6574 l2age75p l2diabe l2logbmi smokev smoken smokef l2hearte /* Heart ever here? */
global allvars_lunge male hsless college l2age65l l2age6574 l2age75p l2logbmi smokev smoken smokef
global allvars_stroke male hsless college l2age65l l2age6574 l2age75p l2hearte l2cancre l2hibpe l2diabe l2logbmi smokev smoken smokef
global allvars_anyadl male hsless college l2age65l l2age6574 l2age75p l2hearte l2cancre l2hibpe l2diabe l2logbmi smokev smoken smokef
global allvars_anyiadl male hsless college l2age65l l2age6574 l2age75p l2hearte l2cancre l2hibpe l2diabe l2logbmi smokev smoken smokef

global allvars_arthre male hsless college l2age65l l2age6574 l2age75p l2hearte l2stroke l2cancre l2hibpe l2diabe l2iadl1 l2iadl2p l2adl1 l2adl2 l2adl3p l2logbmi smokev smoken smokef
global allvars_psyche male hsless college l2age65l l2age6574 l2age75p l2hearte l2stroke l2cancre l2hibpe l2diabe l2iadl1 l2iadl2p l2adl1 l2adl2 l2adl3p l2logbmi smokev smoken smokef
global allvars_logbmi male hsless college l2age65l l2age6574 l2age75p l2cancre l2diabe l2hearte l2hibpe l2lunge l2stroke l2adl1 l2adl2 l2adl3p l2iadl1 l2iadl2p l2logbmi smokev smoken smokef

global allvars_adlstat male hsless college l2age65l l2age6574 l2age75p l2cancre l2diabe l2hearte l2hibpe l2lunge l2stroke l2adl1 l2adl2 l2adl3p l2iadl1 l2iadl2p l2logbmi /* Why no smoking vars? */
global allvars_iadlstat male hsless college l2age65l l2age6574 l2age75p l2cancre l2diabe l2hearte l2hibpe l2lunge l2stroke l2adl1 l2adl2 l2adl3p l2iadl1 l2iadl2p l2logbmi
global allvars_smokev male hsless college l2age65l l2age6574 l2age75p l2logbmi
global allvars_smoken male hsless college l2age65l l2age6574 l2age75p l2logbmi

* selection criteria for models
local select_died !l2died 
foreach var in cancre diabe hearte hibpe lunge stroke arthre psyche anyadl anyiadl{
	local select_`var' !l2`var' & !died 
}
local select_logbmi !died 
local select_adlstat !died 
local select_iadlstat !died 
local select_smoke_start !died & l2smoken == 0
local select_smoke_stop !died & l2smoken == 1

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

capture log close /* Where did log start? */
