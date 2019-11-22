
/** \file bootstrap_simulation_samples.do
Create bootstrap samples that will be used for simulation

\section hist Limited Version History
- 02/03/2014 - Created
- 04/09/2014 - Change sample from 2004 to 2010

*/

include common.do

* Define paths

local bsamp : env BREP

/*********************************************************************/
* SAMPLE WITH REPLACEMENT: n-1 method (McCarthy and Snowden, 1985) via (Shao, 2003)
/*********************************************************************/
	
	use $outdata/input_rep`bsamp'/bootstrap_sample.dta
	tab bsample
	local max=r(r)

	forval i = 1/`max' {	
		use $outdata/all2010.dta, clear 
		gen bsample=`i'
		* merge strata hhid (non wave specific) back onto data as hhidb
		merge m:1 hhidpn_orig using $outdata/hhidb.dta
		drop if _merge==2
		drop _merge
		* keep data for transition sample specific to bootstrap sample based on hhidb 
		merge m:1 hhidb bsample using $outdata/input_rep`bsamp'/bootstrap_sample.dta
		keep if _merge==3
		drop _merge
		save $outdata/input_rep`bsamp'/all2010`i'.dta, replace
		}
	
	* stack when hhidb was selected more than once in sample
	use $outdata/input_rep`bsamp'/all20101.dta	
		forval i = 2/`max' {
			append using $outdata/input_rep`bsamp'/all2010`i'.dta, nolabel
			}
			
	ren hhid hhid_old
	ren hhidpn hhidpn_old
			
	egen hhid = group(hhid_old bsample)
	egen hhidpn = group(hhidpn_old bsample)
	
	replace hhid = 10^5 + hhid
	replace hhidpn = 10^5 + hhidpn
	
	format hhidpn %12.0f
				
	save $outdata/input_rep`bsamp'/all2010.dta, replace

	forval i = 1/`max' {	
		rm $outdata/input_rep`bsamp'/all2010`i'.dta
		}
