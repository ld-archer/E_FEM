/* NHEA total spending by payer, 2002-2010
	FAM Total spending, 2009-???

*/

clear all
set more off
include ../../fem_env.do

local tbl NHEA

insheet using "$nhea_dir/2010_Age_and_Gender/age and gender.csv", names

rename v5 y2002
rename v6 y2004 
rename v7 y2006
rename v8 y2008
rename v9 y2010

forvalues x = 2002 (2) 2010 {
	label var y`x' "`x' Spending (mil.)"
}

* For now, only interested in Total Personal Health Care
keep if service == "Total Personal Health Care"
drop service

* Only interested in both sexes
keep if gender == "Total"
drop gender

* Age groups are 0-18, 19-44, 45-64, 65-84, 85+, and "total"  Only look at 45-64, 65-84, and 85+ for now
keep if inlist(agegroup,"19-44","45-64","65-84","85+")

outsheet using table`tbl'.csv, comma replace
export excel using techappendix.xlsx, sheetreplace sheet("Table `tbl'") firstrow(varlabels)


local tbl 10_14

* Baseline simulation results
use $output_dir/psid_baseline/psid_baseline_summary, replace

keep if year < 2050

local grp 2544 4564 6584 85p

local medvar t_totmd t_mcare t_caidmd

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

foreach var of local vars {
	replace `var' = `var'/1e6
}

keep year `vars'

outsheet using table`tbl'.csv, comma replace
export excel using techappendix.xlsx, sheetreplace sheet("Table `tbl'") firstrow(varlabels)




capture log close




