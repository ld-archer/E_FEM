/*
This file will flag the new 25-26 year olds that are altered compared to the default scenario
*/

include ../../../fem_env.do
local scen finish_hs more_coll
local year 2009

foreach scr of local scen {
	use $outdata/new25s_default.dta, clear
	keep if year == `year'
	keep hhidpn educlvl
	rename educlvl educlvl_default
	merge 1:1 hhidpn using $outdata/new25s_`scr', keepusing(educlvl)
	gen educ_flag = (educlvl != educlvl_default)
	
	keep if educ_flag == 1
	keep hhidpn
	tempfile hhidpnlist
	save `hhidpnlist' 
	
	/* Baseline for those we change */
	use $outdata/new25s_default.dta, clear
	keep if year == `year'
	merge 1:1 hhidpn using `hhidpnlist'
	keep if _merge == 3
	save $outdata/new25_`year'_default_`scr'_flg.dta, replace
	* Create file with just non-whites
		preserve
	keep if white == 0
	save $outdata/new25_`year'_default_`scr'_min_flg.dta, replace
	restore
	* Create file with just those in low SES as children
	keep if fpoor == 1
	save $outdata/new25_`year'_default_`scr'_poor_flg.dta, replace


	/* Individuals with changes */
	use $outdata/new25s_`scr'.dta, clear
	keep if year == `year'
	merge 1:1 hhidpn using `hhidpnlist'
	keep if _merge == 3
	save $outdata/new25_`year'_`scr'_flg.dta, replace
	* Create file with just non-whites
	preserve
	keep if white == 0
	save $outdata/new25_`year'_`scr'_min_flg.dta, replace
	restore
	keep if fpoor == 1
	save $outdata/new25_`year'_`scr'_poor_flg.dta, replace
	
	/* Now, just change education without changing the correlated conditions */
	use $outdata/new25s_default.dta, clear
	keep if year == `year'
	merge 1:1 hhidpn using `hhidpnlist'
	keep if _merge == 3
	if "`scr'" == "finish_hs" {
		replace educlvl = 2 if educlvl == 1
	}
	else if "`scr'" == "more_coll" {
		replace educlvl = 3 if educlvl == 2
	}
	save $outdata/new25_`year'_`scr'_flg_alt.dta, replace
	* Create file with just non-whites
	preserve
	keep if white == 0
	save $outdata/new25_`year'_`scr'_min_flg_alt.dta, replace
	restore
	keep if fpoor == 1
	save $outdata/new25_`year'_`scr'_poor_flg_alt.dta, replace
}

capture log close

