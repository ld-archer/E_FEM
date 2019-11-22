/* This file will process the TaxSim output from running the RAND HRS through NBER's TaxSim program

The resulting wide file will have hhidpn and taxes for 2000, 2002, 2004, 2006, and 2008.

RAND ran each observation through TaxSim for each state.  For now, we will only keep variables for:
federal taxes (state == MI)
federal taxes (state == CA)
state taxes (state == MI)
state taxes (state == CA)

Note: Federal taxes can vary by state, due to deduction rules for state taxes paid.

*/

include common.do

local years 00 02 04 06 08

foreach yr of local years {
	tempfile tax`yr'
	if `yr' == 00 {
		local wv 5
	}
	else if `yr' == 02 {
		local wv 6
	}
	else if `yr' == 04 {
		local wv 7
	}
	else if `yr' == 06 {
		local wv 8
	}
	else if `yr' == 08 {
		local wv 9
	}
	
	use $hrs_sensitive/Taxsim/tax`yr'all.dta, replace
	gen h`wv'fedtax_ca = w`wv'fed_tax if w`wv'item_3 == 5
	gen h`wv'fedtax_mi = w`wv'fed_tax if w`wv'item_3 == 23
	gen h`wv'statax_ca = w`wv'sta_tax if w`wv'item_3 == 5
	gen h`wv'statax_mi = w`wv'sta_tax if w`wv'item_3 == 23
	
*	desc
*	codebook w`wv'fedtax_ca
*	codebook w`wv'fedtax_mi
*	codebook w`wv'statax_ca
*	codebook w`wv'statax_mi
	
	collapse (firstnm) h`wv'fedtax_ca h`wv'fedtax_mi h`wv'statax_ca h`wv'statax_mi, by(hhidpn)
	* Save the tempfile
	save "`tax`yr''"

} /* end of year loop */


* Merge the pieces together
use "`tax00'"
merge 1:1 hhidpn using "`tax02'"
drop _merge
merge 1:1 hhidpn using "`tax04'"
drop _merge
merge 1:1 hhidpn using "`tax06'"
drop _merge
merge 1:1 hhidpn using "`tax08'"
drop _merge

save $outdata/taxes59.dta, replace



capture log close
