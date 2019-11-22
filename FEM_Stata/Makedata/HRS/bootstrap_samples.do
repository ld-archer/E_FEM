/** \file bootstrap_samples.do
Select random population with replacement

\section hist Limited Version History
- 08/08/2013 - Created

*/

include common.do

* Define paths

local maxbsamp : env MAXBREP

set seed 6060842

tempfile tfile_ids

use $rand_hrs, clear
keep hhid raestrat raehsamp
* rename hhid so does not interfere with merge later
ren hhid hhidb
duplicates drop
save `tfile_ids'


forval i=1/`maxbsamp' {

	local state = c(seed)
	dis "`state'"
	set seed `state'

/*********************************************************************/
* SAMPLE WITH REPLACEMENT: n-1 method (McCarthy and Snowden, 1985) via (Shao, 2003)
/*********************************************************************/
	
	use $rand_hrs, clear
	keep raestrat raehsamp
	duplicates drop
	bsample _N-1, strata(raestrat)
	
	merge 1:m raestrat raehsamp using `tfile_ids'
	drop if _merge==2
	drop _merge
	bysort hhidb: gen bsample=_n
	keep hhidb raestrat raehsamp bsample
	save $outdata/input_rep`i'/bootstrap_sample.dta, replace
}

shell touch bootstrap_sample_IDs.txt
