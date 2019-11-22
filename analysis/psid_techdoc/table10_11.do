/* Health insurance*/


clear all
set more off
include ../../fem_env.do

local tbl 10_11


* Baseline simulation results
use $output_dir/psid_baseline/psid_baseline_summary, replace

keep if year < 2050

local grp all 2564 2564_m 2564_f

local insvar p_anyhi

local i : word count `grp'
local j : word count `insvar'

forvalues x = 1/`j' {
	forvalues y = 1/`i' {
		local a : word `x' of `insvar'
		local b : word `y' of `grp'
		local c `a'_`b'
		local vars `vars' `c'
	}
}

keep year `vars'

outsheet using table`tbl'.csv, comma replace
export excel using techappendix.xlsx, sheetreplace sheet("Table `tbl'") firstrow(varlabels)




capture log close

