* Assume that this script is being executed in the FEM_Stata/Makedata/MCBS directory

* Load environment variables from the root FEM directory, three levels up
* these define important paths, specific to the user
include "../../../fem_env.do"

* Define paths
local maxbsamp : env MAXBREP

set seed 6060842

/*********************************************************************/
* SAMPLE WITH REPLACEMENT: n-1 method (McCarthy and Snowden, 1985) via (Shao, 2003)
/*********************************************************************/

use "$mcbs_dir/mcbs9212.dta", clear

keep if inrange(year,2007,2012)
keep sudunit sudstrat 
duplicates drop
	
forval i=1/`maxbsamp' {
	local state = c(seed)
	dis "`state'"
	set seed `state'
	gen bsample`i'=.
	* using sudstrat, not varstrat (varstrat is not on the 2012 Ric X file)
	bsample _N-1, strata(sudstrat) weight(bsample`i')
}

save $dua_mcbs_dir/mcbs_bootstrap_weights.dta, replace
