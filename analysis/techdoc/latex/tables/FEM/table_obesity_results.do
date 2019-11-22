clear all
set more off
include ../../../../../fem_env.do

capture confirm file "$routput_dir/vObese_80_sq"
if _rc {
  local output $output_dir
}
else {
  local output $routput_dir
}


use `output'/vObese_80_sq/vObese_80_sq_summary

keep if inlist(year, 2030, 2050)

local outvars year start_pop start_pop65p obese overwt smokev smoken diabe hearte hibpe work ry_earn ttl_ftax ttl_ss_tax ttl_med_tax ttl_ssben ttl_diben ttl_ssiben ttl_mcare ttl_caidmd ttl_totmd 
keep `outvars'
order `outvars'
gen scenario="obs80"

append using status_quo_results.dta

gen scenorder = 1 if scenario=="status quo"
replace scenorder = 2 if scenario=="obs80"
expand 2 if scenario=="obs80", generate(relchrow)
replace scenario="relative change" if relchrow==1
replace scenorder=3 if relchrow==1
drop relchrow
expand 2 if scenario=="obs80", generate(abschrow)
replace scenario="absolute change" if abschrow==1
replace scenorder=4 if abschrow==1
drop abschrow

sort scenorder year

local chvars start_pop start_pop65p obese overwt smokev smoken diabe hearte hibpe work ry_earn ttl_ftax ttl_ss_tax ttl_med_tax ttl_ssben ttl_diben ttl_ssiben ttl_mcare ttl_caidmd ttl_totmd
foreach v in `chvars' {
	replace `v' = `v'[_n-2]/`v'[_n-4] - 1 if scenario=="relative change"
	replace `v' = `v'[_n-4] - `v'[_n-6] if scenario=="absolute change"
}

drop if scenario=="status quo"

xpose, clear varname
format v1-v6 %10.2fc
rename _varname outcome
drop if outcome=="year"

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
	rename v2 rowlab
	merge 1:1 outcome using `summary'
	drop if _merge==2
	sort order
	if "``ot'_hdlbl'" != "" {
		expand 2 if _n==1, generate(headrow)
		replace order=-1 if headrow==1
		replace rowlab = "``ot'_hdlbl'" if headrow==1
		forvalues i=1/6 {
			replace v`i'=. if headrow==1
		}
		drop headrow
	}
	sort order
	li		
	drop _merge outcome order
	
	gen colspace1 = .
	gen colspace2 = .
	order rowlab v1 v2 colspace1 v3 v4 colspace2 v5 v6
	
	* output to latex table format
	listtex using obesity_results_`ot'.tex, replace rstyle(tabular) 
}

exit, STATA clear
