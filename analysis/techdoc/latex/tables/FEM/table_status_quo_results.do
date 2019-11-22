clear all
set more off
include ../../../../../fem_env.do

capture confirm file "$routput_dir/vBaseline_sq"
if _rc {
  local output $output_dir
}
else {
  local output $routput_dir
}


use `output'/vBaseline_sq/vBaseline_sq_summary

keep if inlist(year, 2010, 2030, 2050)

gen ttl_rev = ttl_ftax + ttl_ss_tax + ttl_med_tax
gen ttl_mcaremcaid = ttl_ssben + ttl_diben + ttl_ssiben + ttl_mcare + ttl_caidmd

local outvars year start_pop start_pop65p obese overwt smokev smoken diabe hearte hibpe work ry_earn ttl_ftax ttl_ss_tax ttl_med_tax ttl_rev ttl_ssben ttl_diben ttl_ssiben ttl_mcare ttl_caidmd ttl_mcaremcaid ttl_totmd 
keep `outvars'
order `outvars'

* save results for combining with obesity scenario results
preserve
gen scenario = "status quo"
keep if inlist(year,2030,2050)
save status_quo_results.dta, replace
restore

mkmat year-ttl_totmd, mat(omega) 
local rowname: rownames omega
li

xpose, clear varname
li
ren (_varname v1-v3) (outcome `rowname')

drop if outcome=="order" | outcome=="var" | outcome=="_rowname"

* format for display in a table
foreach v in `rowname' {
	format `v' %6.2fc
}
order outcome, first
tempfile summary
save `summary'


* subtables to output
local octypes popsize conditions labor govrev govexp totmd

* header text for subtables
local conditions_hdlbl "\textbf{Prevalence of selected conditions for ages 51+}"
local labor_hdlbl "\textbf{Labor participation for ages 51+}"
local govrev_hdlbl "\textbf{Government revenues from ages 51+ (Billion \\\$2010)}"
local govexp_hdlbl "\textbf{Government expenditures from ages 51+ (Billion \\\$2010)}"

foreach ot in `octypes' {
	di "Outcome table: `ot'"
	* select outcomes for summary stats
	insheet using obesity_results_`ot'_lblrows.csv, comma clear nonames
	gen order=_n
	li
	rename v1 outcome
	merge 1:1 outcome using `summary'
	drop if _merge==2
	sort order
	if "``ot'_hdlbl'" != "" {
		expand 2 if _n==1, generate(headrow)
		replace order=-1 if headrow==1
		replace v2 = "``ot'_hdlbl'" if headrow==1
		replace r1=. if headrow==1
		replace r2=. if headrow==1
		replace r3=. if headrow==1
		drop headrow
	}
	sort order
	li		
	drop _merge outcome order
	
	* output to latex table format
	listtex using statusquo_results_`ot'.tex, replace rstyle(tabular) 
}

exit, STATA clear
