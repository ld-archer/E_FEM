***=========================================
* SELECT DATA FOR CREATION OF BOOTSTRAP SAMPLES
* Barbara Blaylock, 01/16/2015
***=========================================

*** MEPS

clear
* Clear anything thats already in memory
clear all
cap clear mata
cap clear programs
cap clear ado
discard
est clear
set more off
set mem 500m
capture log close



* Assume that this script is being executed in the FEM_Stata/Makedata/MCBS directory

* Load environment variables from the root FEM directory, three levels up
* these define important paths, specific to the user
include "../../../fem_env.do"

* Define paths
global workdir  			"$local_path/Makedata/MEPS"

adopath + "$local_path/Makedata/MEPS"

* Define paths

local maxbsamp : env MAXBREP

set seed 6060842

/*********************************************************************/
* SAMPLE WITH REPLACEMENT: n-1 method (McCarthy and Snowden, 1985) via (Shao, 2003)
/*********************************************************************/

	local frsyr = 2007
	foreach v in 07 08 09 10 11 12 {
		drop _all
		fdause "$meps_dir/csd`frsyr'.ssp"
		keep duid varpsu varstr
		ren varstr varstr
		gen year = `frsyr'
		save "$outdata/m`frsyr'.dta", replace
		local frsyr = `frsyr' + 1 
	}
	
	use "$outdata/m2012.dta"
	erase "$outdata/m2012.dta"
	forvalues i = 2011(-1)2007{
		append using "$outdata/m`i'.dta"
		erase "$outdata/m`i'.dta"
	}

	keep if inrange(year,2007,2012)
	keep varpsu varstr 
	duplicates drop
	
	forval i=1/`maxbsamp' {
	
		local state = c(seed)
		dis "`state'"
		set seed `state'

		gen bsample`i'=.
		bsample _N-1, strata(varstr) weight(bsample`i')

	}
	
	compress

	save $outdata/meps_bootstrap_weights.dta, replace

