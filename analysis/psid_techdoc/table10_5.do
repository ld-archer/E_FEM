/* Unemployment Rate, Labor Force Participation for those 25-64, by sex*/


clear all
set more off
include ../../fem_env.do

local tbl 10_5


* Baseline simulation results
use $output_dir/psid_baseline/psid_baseline_summary, replace

keep if year < 2050

local grp 2564 2564_m 2564_f

foreach g of local grp {
	gen p_inlabor_`g' = p_workcat2_`g' +  p_workcat3_`g' + p_workcat4_`g'
	gen p_unemploy_`g' = p_workcat2_`g' / (p_workcat2_`g' +  p_workcat3_`g' + p_workcat4_`g')
	
	label var p_inlabor_`g' "Labor Force Participation `g'"
	label var p_unemploy_`g' "Unemployment Rate `g'"
}

local workvar p_inlabor p_unemploy

local i : word count `grp'
local j : word count `workvar'

forvalues x = 1/`j' {
	forvalues y = 1/`i' {
		local a : word `x' of `workvar'
		local b : word `y' of `grp'
		local c `a'_`b'
		local vars `vars' `c'
	}
}

keep year `vars'

outsheet using table`tbl'.csv, comma replace
export excel using techappendix.xlsx, sheetreplace sheet("Table `tbl'") firstrow(varlabels)




capture log close

