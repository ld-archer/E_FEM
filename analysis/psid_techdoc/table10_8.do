/* Education levels*/


clear all
set more off
include ../../fem_env.do

local tbl 10_8


* Baseline simulation results
use $output_dir/psid_baseline/psid_baseline_summary, replace

keep if year < 2050

local grp 2564 2564_m 2564_f

local educvar p_educ1 p_educ2 p_educ3 p_educ4

local i : word count `grp'
local j : word count `educvar'

forvalues x = 1/`j' {
	forvalues y = 1/`i' {
		local a : word `x' of `educvar'
		local b : word `y' of `grp'
		local c `a'_`b'
		local vars `vars' `c'
	}
}

keep year `vars'

outsheet using table`tbl'.csv, comma replace
export excel using techappendix.xlsx, sheetreplace sheet("Table `tbl'") firstrow(varlabels)




capture log close

