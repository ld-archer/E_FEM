/* Obesity prevalence by age groups (25-44, 45-64, 65+) */


clear all
set more off
include ../../fem_env.do

local tbl 10_3


* Baseline simulation results
use $output_dir/psid_baseline/psid_baseline_summary, replace

keep if year < 2050

local agegrp 2544 4564 65p
local weightcat p_overwt p_obese_1 p_obese_2 p_obese_3 	

local i : word count `agegrp'
local j : word count `weightcat'

forvalues x = 1/`j' {
	forvalues y = 1/`i' {
		local a : word `x' of `weightcat'
		local b : word `y' of `agegrp'
		local c `a'_`b'
		local vars `vars' `c'
	}
}

keep year `vars'

outsheet using table`tbl'.csv, comma replace
export excel using techappendix.xlsx, sheetreplace sheet("Table `tbl'") firstrow(varlabels)




capture log close

