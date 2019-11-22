/** \file bootstrap_samples.do
This file implements the PSID bootstrap resampling for model estimates.
More work is needed for bootstrapping the PSID input data.

\section hist Limited Version History
- 07/25/2015 - Copied and adapted from HRS version

*/

include common.do

* Define paths

local maxbsamp : env MAXBREP

set seed 25072015

local state = c(seed)
dis "`state'"
set seed `state'

local lastyr $lastyr
use `psidpub'/Stata/ind`lastyr'er.dta, clear
keep ER30001 ER31996 ER31997
rename ER30001 famno68
rename ER31996 sestrat
rename ER31997 seclust

* check that the families are constant within strata
bys famno68: egen maxstrat = max(sestrat)
bys famno68: egen minstrat = min(sestrat)
bys famno68: egen maxseclust = max(seclust)
bys famno68: egen minseclust = min(seclust)

sort famno68
li if maxstrat!=minstrat | minseclust!=maxseclust
count if maxstrat!=minstrat | minseclust!=maxseclust
gen stratdiff = maxstrat-minstrat
tab stratdiff, m
tab minseclust maxseclust, m
drop maxseclust minseclust maxstrat minstrat stratdiff
* resampling clusters, not families
drop famno68
duplicates drop

preserve
forval i=1/`maxbsamp' {
	
	restore
	preserve
	*use `fam689799', clear
	* rename famno68 so does not interfere with merge later
	*ren famno68 famno68b
	* there should be no duplicates
	* sample 1 cluster per sestrat, following (number of clusters in stratum - 1) scheme in Kolenikov, 2010 (Stata Journal)
	* sample all families in the same cluster
	bsample 1, strata(sestrat) cluster(seclust)
	bysort sestrat seclust: gen bsample=_n
	*keep famno68b sestrat seclust bsample
	keep sestrat seclust bsample
	save $outdata/input_rep`i'/psid_bootstrap_sample.dta, replace
}

shell touch bootstrap_sample_IDs.txt
