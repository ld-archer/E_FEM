foreach y in 2010 2030 {
	foreach s in status_quo smk_ext smk_iom {

		use new51_`y'_`s', clear
		gen flag = (obese_1 | obese_2 | obese_3) & weight > 0
		by hhid, sort: egen flag_hh = max(flag)
		keep if flag_hh	
		drop flag flag_hh
		save new51_`y'_`s'_obese, replace

		use new51_`y'_`s', clear
		gen flag = (obese_2 | obese_3) & weight > 0
		by hhid, sort: egen flag_hh = max(flag)
		keep if flag_hh	
		drop flag flag_hh
		save new51_`y'_`s'_obese2p, replace

		use new51_`y'_`s', clear
		gen flag = (obese_3) & weight > 0
		by hhid, sort: egen flag_hh = max(flag)
		keep if flag_hh	
		drop flag flag_hh
		save new51_`y'_`s'_obese3p, replace

	}
}