
/** \file bootstrap_transition_samples.do
Create bootstrap samples that will be used for transition models

\section hist Limited Version History
- 08/08/2013 - Created
- 04/09/2015 - Updated from h19_transition.dta to h111_transition.dta

*/

include common.do

* Define paths

local bsamp : env BREP

local fname = "$outdata/hrs$firstwave$lastwave" + "_transition.dta"
local bsfname = "$outdata/input_rep`bsamp'/hrs$firstwave$lastwave" + "_transition.dta"

/*********************************************************************/
* SAMPLE WITH REPLACEMENT: n-1 method (McCarthy and Snowden, 1985) via (Shao, 2003)
/*********************************************************************/
	
	use $outdata/input_rep`bsamp'/bootstrap_sample.dta
	tab bsample
	local max=r(r)

	forval i = 1/`max' {
          tempfile hrs`i'
		use `fname', clear 
		gen bsample=`i'
		* merge strata hhid (non wave specific) back onto data as hhidb
		merge m:1 hhidpn_orig using $outdata/hhidb.dta
		drop if _m==2
		drop _merge
		* keep data for transition sample specific to bootstrap sample based on hhidb 
		merge m:1 hhidb bsample using $outdata/input_rep`bsamp'/bootstrap_sample.dta
		keep if _merge==3
		drop _merge
		save `hrs`i''
		}
	
	* stack when hhidb was selected more than once in sample
	use `hrs1'
		forval i = 2/`max' {
			append using `hrs`i'', nolabel
			}
			
	save `bsfname', replace
