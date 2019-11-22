
/** \file bootstrap_transition_samples.do
Create PSID bootstrap samples that will be used for transition models
This code was adapted from the HRS version
*/

include common.do

* Define paths

local bsamp : env BREP

/*********************************************************************/
* SAMPLE WITH REPLACEMENT: n-1 method (McCarthy and Snowden, 1985) via (Shao, 2003)
/*********************************************************************/
	
	use $outdata/input_rep`bsamp'/psid_bootstrap_sample.dta
	tab bsample
	local max=r(r)

	forval i = 1/`max' {	
		use $outdata/psid_transition.dta, clear 
		gen bsample=`i'
		* merge strata famno68 (non wave specific) back onto data as famo68b
		merge m:1 hhidpn_orig using $outdata/psid_hhidb.dta
		drop if _m==2
		drop _merge
		* keep data for transition sample specific to bootstrap sample based on hhidb 
		merge m:1 sestrat seclust bsample using $outdata/input_rep`bsamp'/psid_bootstrap_sample.dta
		keep if _merge==3
		drop _merge
		save $outdata/input_rep`bsamp'/psid_transition`i'.dta, replace
		}
	
	* stack when famno68 was selected more than once in sample
	use $outdata/input_rep`bsamp'/psid_transition1.dta
		forval i = 2/`max' {
			append using $outdata/input_rep`bsamp'/psid_transition`i'.dta, nolabel
			}
			
	save $outdata/input_rep`bsamp'/psid_transition.dta, replace

	forval i = 1/`max' {	
		rm $outdata/input_rep`bsamp'/psid_transition`i'.dta
		}
