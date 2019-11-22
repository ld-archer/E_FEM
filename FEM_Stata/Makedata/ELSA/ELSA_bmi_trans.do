quietly include ../../fem_env.do

local in_file : env INPUT

local out_file : env OUTPUT

local ster "$local_path/Estimates/ELSA_bmi1" /* ster file for storing estimates */
*local ster "../../Estimates/ELSA" /* ster file for storing estimates */


use $outdata/transition_pop.dta
*use ../../../input_data/transition_pop.dta

drop l2logbmi

gen l2logbmi = L2.logbmi

global ols logbmi


global allvars_logbmi male hsless college l2age65l l2age6574 l2age75p l2cancre l2diabe l2hearte l2hibpe l2lunge l2stroke l2adl1 l2adl2 l2adl3p l2iadl1 l2iadl2p l2logbmi l2smokev l2smoken 


local select_logbmi !died & inlist(wave, 4, 6)


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



local ster "$local_path/Estimates/ELSA_bmi2" /* ster file for storing estimates */
*local ster "../../Estimates/ELSA" /* ster file for storing estimates */


use $outdata/transition_pop.dta, replace
*use ../../../input_data/transition_pop.dta

drop l2logbmi

gen l2logbmi = L.logbmi

*interpolate
ipolate l2logbmi wave, gen(newl2bmi)

replace l2logbmi = newl2bmi if missing(l2logbmi)

global ols logbmi


global allvars_logbmi male hsless college l2age65l l2age6574 l2age75p l2cancre l2diabe l2hearte l2hibpe l2lunge l2stroke l2adl1 l2adl2 l2adl3p l2iadl1 l2iadl2p l2logbmi l2smokev l2smoken 


local select_logbmi !died & inlist(wave, 4, 6)


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



