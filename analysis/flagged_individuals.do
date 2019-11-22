/* Process cohort output for simulations comparing default and finish_hs scenarios */


local scen finish_hs more_coll finish_hs_min more_coll_min finish_hs_poor more_coll_poor

foreach scr of local scen {
	use ../output/default_`scr'_flg/default_`scr'_flg_summary.dta
	gen scen = 1
	append using ../output/`scr'_flg/`scr'_flg_summary.dta
	replace scen = 2 if missing(scen)
	append using ../output/`scr'_flg_alt/`scr'_flg_alt_summary.dta
	replace scen = 3 if missing(scen)
	
	label define scen 1 "default" 2 "changed" 3 "changed educ only" 
	label values scen scen
	label var scen "Scenario"
	
	tab scen
	* Keep through age 85
	keep if year < 2070
	gen age = year - 1984
	sort age
	save test_`scr'.dta, replace

	
	* Population
	graph twoway line m_endpop_all age if scen == 1 || line m_endpop_all age if scen == 2|| line m_endpop_all age if scen == 3, legend(label(1 "default") label(2 "changed educ and correlates") label(3 "changed educ only")) 
	graph save `scr'_flg/population.gph, replace
	
	
	* Health
	foreach var in cancre diabe hearte hibpe lunge stroke {
		/* Prevalence */
		graph twoway line p_`var'_all age if scen == 1 || line p_`var'_all age if scen == 2|| line p_`var'_all age if scen == 3, legend(label(1 "default") label(2 "changed educ and correlates") label(3 "changed educ only")) 
		graph save `scr'_flg/p_`var'.gph, replace
		/* Incidence */
		graph twoway line i_`var'_all age if scen == 1 || line i_`var'_all age if scen == 2|| line i_`var'_all age if scen == 3, legend(label(1 "default") label(2 "changed educ and correlates") label(3 "changed educ only")) 
		graph save `scr'_flg/i_`var'.gph, replace	
	
	}
	
	* Smoking
	foreach var in smokev smoken {
		graph twoway line p_`var'_all age if scen == 1 || line p_`var'_all age if scen == 2|| line p_`var'_all age if scen == 3, legend(label(1 "default") label(2 "changed educ and correlates") label(3 "changed educ only"))  
		graph save `scr'_flg/p_`var'.gph, replace
	}
	
	* BMI categories
	foreach var in overwt obese_1 obese_2 obese_3 {
		graph twoway line p_`var'_all age if scen == 1 || line p_`var'_all age if scen == 2|| line p_`var'_all age if scen == 3, legend(label(1 "default") label(2 "changed educ and correlates") label(3 "changed educ only")) 
		graph save `scr'_flg/p_`var'.gph, replace
	}
	* Average BMI
	foreach var in bmi {
		graph twoway line a_`var'_all age if scen == 1 || line a_`var'_all age if scen == 2|| line a_`var'_all age if scen == 3, legend(label(1 "default") label(2 "changed educ and correlates") label(3 "changed educ only")) 
		graph save `scr'_flg/a_`var'.gph, replace
	}
	
	* Earnings/Wealth
	foreach var in iearn hatotax {
		graph twoway line a_`var'_all age if scen == 1 || line a_`var'_all age if scen == 2|| line a_`var'_all age if scen == 3, legend(label(1 "default") label(2 "changed educ and correlates") label(3 "changed educ only")) 
		graph save `scr'_flg/a_`var'.gph, replace
	}
	
	* Work
	foreach var in workcat1 workcat2 workcat3 workcat4 {
		graph twoway line p_`var'_all age if scen == 1 || line p_`var'_all age if scen == 2|| line p_`var'_all age if scen == 3, legend(label(1 "default") label(2 "changed educ and correlates") label(3 "changed educ only")) 
		graph save `scr'_flg/p_`var'.gph, replace
	}
	
	* ADL/IADL
	foreach var in adl1 adl2 adl3p iadl1 iadl2p {
		graph twoway line p_`var'_all age if scen == 1 || line p_`var'_all age if scen == 2|| line p_`var'_all age if scen == 3, legend(label(1 "default") label(2 "changed educ and correlates") label(3 "changed educ only")) 
		graph save `scr'_flg/p_`var'.gph, replace
	}
	
	* Program participation
	foreach var in ssclaim ssiclaim diclaim {
		graph twoway line p_`var'_all age if scen == 1 || line p_`var'_all age if scen == 2|| line p_`var'_all age if scen == 3, legend(label(1 "default") label(2 "changed educ and correlates") label(3 "changed educ only")) 
		graph save `scr'_flg/p_`var'.gph, replace
	}
	
	* Medical spending
	foreach var in totmd {
		graph twoway line a_`var'_all age if scen == 1 || line a_`var'_all age if scen == 2|| line a_`var'_all age if scen == 3, legend(label(1 "default") label(2 "changed educ and correlates") label(3 "changed educ only")) 
		graph save `scr'_flg/a_`var'.gph, replace
	}
			
	* Self-reported health (cross-sectional)
	foreach var in srh1 srh2 srh3 srh4 srh5 srh3p srh2l {
		graph twoway line p_`var'_all age if scen == 1 || line p_`var'_all age if scen == 2|| line p_`var'_all age if scen == 3, legend(label(1 "default") label(2 "changed educ and correlates") label(3 "changed educ only")) 
		graph save `scr'_flg/p_`var'.gph, replace
	}	
	
	* Incidence of mortality
	foreach var in died {
		graph twoway line i_`var'_all age if scen == 1 || line i_`var'_all age if scen == 2|| line i_`var'_all age if scen == 3, legend(label(1 "default") label(2 "changed educ and correlates") label(3 "changed educ only"))
		graph save `scr'_flg/i_`var'.gph, replace
	}	
	
}


capture log close
