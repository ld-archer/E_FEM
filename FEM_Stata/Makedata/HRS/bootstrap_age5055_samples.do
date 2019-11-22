
/** \file bootstrap_age5055_samples.do
Create bootstrap samples that will be used for new51 cohort creation

\section hist Limited Version History
- 08/08/2013 - Created

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

forval yr=1992(18)2010 {
	forval i = 1/`max' {	
		use $outdata/age5055_hrs`yr'.dta, clear 
		gen bsample=`i'
		* merge strata hhid (non wave specific) back onto data as hhidb
		merge m:1 hhidpn_orig using $outdata/hhidb.dta
		drop if _m==2
		drop _merge
		* keep data for transition sample specific to bootstrap sample based on hhidb 
		merge m:1 hhidb bsample using $outdata/input_rep`bsamp'/bootstrap_sample.dta
		keep if _merge==3
		drop _merge
		save $outdata/input_rep`bsamp'/age5055_hrs`yr'`i'.dta, replace
		}
	
	* stack when hhidb was selected more than once in sample
	use $outdata/input_rep`bsamp'/age5055_hrs`yr'1.dta
		forval i = 2/`max' {
			append using $outdata/input_rep`bsamp'/age5055_hrs`yr'`i'.dta, nolabel
			}
			
	save $outdata/input_rep`bsamp'/age5055_hrs`yr'.dta, replace

	forval i = 1/`max' {	
		rm $outdata/input_rep`bsamp'/age5055_hrs`yr'`i'.dta
		}
}
