/** Create a file summarizing CHF-relevant outcomes
*/

include ../../fem_env.do

/*********************** NHANES ************************/
tempfile tfile_nhanes
use $outdata/nhanes.dta
keep if year >= 2000
keep if age_yrs >= 50 & !missing(age_yrs)
gen chfe_hearte = chfe if hearte==1
* all ages
preserve
collapse (mean) hearte chfe chfe_hearte [fw=round(intw_wght)], by(year)
save `tfile_nhanes'
restore
* by age group
egen agegrp = cut(age_yrs), at(55,65,75,85,200)
keep if agegrp >= 55 & !missing(agegrp)
tab agegrp, m
collapse (mean)  hearte chfe chfe_hearte [fw=round(intw_wght)], by(year agegrp)
append using `tfile_nhanes'

gen Source="NHANES"
save `tfile_nhanes', replace

/****************** HRS Analytic File ******************/
tempfile tfile_hrs
use $outdata/hrs_analytic_recoded.dta, clear
keep if wave >= 4
gen year = 2000 + 2*(wave - 4)
tab hearte chfe, m
gen chfe_hearte = chfe if hearte==1
* all ages
preserve
collapse (mean) hearte chfe chfe_hearte [fw=round(wtresp)], by(year)
save `tfile_hrs'
restore
* by age group
egen agegrp = cut(age), at(55,65,75,85,200)
keep if agegrp >= 55 & !missing(agegrp)
tab agegrp, m
collapse (mean)  hearte chfe chfe_hearte [fw=round(wtresp)], by(year agegrp)
append using `tfile_hrs'

gen Source="Raw HRS"
save `tfile_hrs', replace

/**************** FEM Estimation Sample ****************/
tempfile tfile_femest
use $outdata/hrs19_transition.dta, clear
keep if year >= 1998
tab hearte chfe, m
gen chfe_hearte = chfe if hearte==1
* all ages
preserve
collapse (mean) hearte chfe chfe_hearte, by(year)
save `tfile_femest'
restore
* by age group
egen agegrp = cut(age), at(55,65,75,85,200)
keep if agegrp >= 55 & !missing(agegrp)
tab agegrp, m
collapse (mean) hearte chfe chfe_hearte, by(year agegrp)
append using `tfile_femest'

gen Source = "FEM Estimation Sample (HRS)"
save `tfile_femest', replace

/******** Constant and Full Model FEM Results **********/
foreach f in cons full {
	tempfile tfile_`f'chf
	use ../../output/chfe_`f'_model/chfe_`f'_model_summary.dta, clear
	drop *_sd *_wht *_f *_m *_blk *_his *_hearte_hearte*
	keep p_hearte* p_chfe* year
	foreach v in chfe hearte chfe_hearte {
		local varsfx 5564 6574 7584 85p
		local agesfx 55 65 75 85
		forvalues i=1/4 {
			local sfx = word("`varsfx'",`i')
			local age = word("`agesfx'",`i')
			rename p_`v'_`sfx' `v'`age'
		}
	}
	foreach v in chfe hearte {
		rename p_`v'_all `v'0
	}
	rename p_chfe_hearte chfe_hearte0
	reshape long hearte chfe chfe_hearte, i(year) j(agegrp)
	replace agegrp = . if agegrp==0
	
	if "`f'"=="cons" {
		gen Source = "FEM - Constant CHF Model"
	}
	else {
		gen Source = "FEM - Full CHF Model"
	}
	
	save `tfile_`f'chf'
}

/****************** Combine all files ******************/
clear
append using `tfile_nhanes' `tfile_hrs' `tfile_femest' `tfile_conschf' `tfile_fullchf'

gen Age = "55-64" if agegrp==55
replace Age = "65-74" if agegrp==65
replace Age = "75-84" if agegrp==75
replace Age = "85+" if agegrp==85


* saving in old format for R compatibility
saveold chf_summary.dta, replace
