/* ADL/IADL prevalence by age groups (25-44, 45-64, 65+) */


clear all
set more off
include ../../fem_env.do

local tbl 10_4


* Baseline simulation results
use $output_dir/psid_baseline/psid_baseline_summary, replace

keep if year < 2050

local agegrp 2544 4564 65p
local adlcat p_adl1 p_adl2 p_adl3p p_iadl1 p_iadl2p 	

local i : word count `agegrp'
local j : word count `adlcat'

forvalues x = 1/`j' {
	forvalues y = 1/`i' {
		local a : word `x' of `adlcat'
		local b : word `y' of `agegrp'
		local c `a'_`b'
		local vars `vars' `c'
	}
}

keep year `vars'

outsheet using table`tbl'.csv, comma replace
export excel using techappendix.xlsx, sheetreplace sheet("Table `tbl'") firstrow(varlabels)




capture log close

