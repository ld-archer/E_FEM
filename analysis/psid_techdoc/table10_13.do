/* Per capita medical spending, medicare spending, medicaid spending */


clear all
set more off
include ../../fem_env.do

local tbl 10_13


* Baseline simulation results
use $output_dir/psid_baseline/psid_baseline_summary, replace

keep if year < 2050

local grp 2544 4564 65p

local medvar a_totmd a_mcare a_caidmd

local i : word count `grp'
local j : word count `medvar'

forvalues x = 1/`j' {
	forvalues y = 1/`i' {
		local a : word `x' of `medvar'
		local b : word `y' of `grp'
		local c `a'_`b'
		local vars `vars' `c'
	}
}

keep year `vars'

outsheet using table`tbl'.csv, comma replace
export excel using techappendix.xlsx, sheetreplace sheet("Table `tbl'") firstrow(varlabels)




capture log close


