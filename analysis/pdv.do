clear
set more off
capt log close
log using pdv.log, replace



* Assume that this script is being executed in the analysis directory

* Load environment variables from the root FEM directory, one level up
* these define important paths, specific to the user
include "../fem_env.do"



global scnrs status_quo intermed_obese extreme_obese smk_ext smk_iom whiter cure_hibpe cure_cancre cure_diabe lowgrowth higrowth  workup_mild workdown_mild workup_ext workdown_ext 

tempfile results
set obs 1 
gen blah = 1
save `results', replace

tempfile tmp


foreach i in $scnrs{
	
	clear

	use "$out_path/`i'/summary.dta"

	sort year
	merge year using "$local_root/analysis/cpi_adjust.dta", nokeep
	assert _m == 3
	drop _m
	
	foreach j in fed_tax ss_tax med_tax ss_ben di_ben ssi_ben ttl_mcare ttl_caidmd ttl_totmd{
		replace `j' = `j'*adjust
	}
	
	keep year fed_tax ss_tax med_tax ss_ben di_ben ssi_ben ttl_mcare ttl_caidmd ttl_totmd
	gen scenario = "`i'"	
	order scenario year fed_tax ss_tax med_tax ss_ben di_ben ssi_ben ttl_mcare ttl_caidmd ttl_totmd

	sort year
	
	outsheet using "$out_path/`i'/pdv_`i'.csv", c names replace

	save `tmp', replace
	use `results', clear
	append using `tmp'
	save `results', replace


}
log close
drop blah
drop if _n == 1
outsheet using "$local_root/analysis/pdv.csv", c names replace
