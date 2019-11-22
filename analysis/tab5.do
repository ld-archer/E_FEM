clear
set more off
capt log close
log using tab5.log, replace


* Assume that this script is being executed in the analysis directory

* Load environment variables from the root FEM directory, one level up
* these define important paths, specific to the user
include "../fem_env.do"


global out_path "$local_root/output/JHE"

global scnrs status_quo intermed_obese extreme_obese smk_ext smk_iom whiter cure_hibpe cure_cancre cure_diabe lowgrowth higrowth  workup_mild workdown_mild workup_ext workdown_ext

tempfile results
set obs 1 
gen blah = 1
save `results', replace

tempfile tmp

foreach i in $scnrs{
	
	use "$out_path/`i'/summary.dta", clear
	
	keep if inlist(year,2004,2030,2050)
	
	sort year
	merge year using "$local_root/analysis/cpi_adjust.dta", nokeep
	assert _m == 3
	drop _m
	replace ttl_totmd = bs_treat_new * 20 + ttl_totmd
	foreach j in ry_earn fed_tax ss_tax med_tax ss_ben di_ben ssi_ben ttl_mcare ttl_caidmd ttl_totmd{
		replace `j' = `j'*adjust
	}
	
	
	keep year end_pop end_pop65p obese overwt smokev smoken diabe hearte hibpe work ry_earn fed_tax ss_tax med_tax ss_ben di_ben ssi_ben ttl_mcare ttl_caidmd ttl_totmd
	gen scenario = "`i'"
	order scenario year  end_pop end_pop65p obese overwt smokev smoken diabe hearte hibpe work ry_earn fed_tax ss_tax med_tax ss_ben di_ben ssi_ben ttl_mcare ttl_caidmd ttl_totmd

	
	outsheet using "$out_path/`i'/tab5_`i'.csv", c names replace

	save `tmp', replace
	use `results', clear
	append using `tmp'
	save `results', replace

}
log close
drop blah
drop if _n == 1
outsheet using "$local_root/analysis/tab5.csv", c names replace
