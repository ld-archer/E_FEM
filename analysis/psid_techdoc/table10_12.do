/* Medicaid and Medicare (A, B, D) enrollment */


clear all
set more off
include ../../fem_env.do

local tbl 10_12


* Baseline simulation results
use $output_dir/psid_baseline/psid_baseline_summary, replace

keep if year < 2050

local grp all 2544 4564 65p

local medvar p_medicaid_elig p_mcare_pta_enroll p_mcare_ptb_enroll p_mcare_ptd_enroll

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

