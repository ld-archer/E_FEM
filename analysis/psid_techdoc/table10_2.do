/* Disease prevalence by age groups (25-44, 45-64, 65+) */


clear all
set more off
include ../../fem_env.do

local tbl 10_2


* Baseline simulation results
use $output_dir/psid_baseline/psid_baseline_summary, replace

keep if year < 2050

local agegrp 2544 4564 65p
local diseases p_cancre p_diabe p_hearte p_hibpe p_lunge p_stroke	

local i : word count `agegrp'
local j : word count `diseases'

forvalues x = 1/`j' {
	forvalues y = 1/`i' {
		local a : word `x' of `diseases'
		local b : word `y' of `agegrp'
		local c `a'_`b'
		local vars `vars' `c'
	}
}

keep year `vars'

outsheet using table`tbl'.csv, comma replace
export excel using techappendix.xlsx, sheetreplace sheet("Table `tbl'") firstrow(varlabels)




capture log close
