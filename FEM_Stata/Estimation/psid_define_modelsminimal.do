	* Hearte
	takestring, oldlist($allvars_hlth) newname("allvars_hearte")
	* Stroke 
	takestring, oldlist($allvars_hlth) newname("allvars_stroke")
	* Cancre
	takestring, oldlist($allvars_hlth) newname("allvars_cancre")
	* Hibpe
	takestring, oldlist($allvars_hlth) newname("allvars_hibpe") 
	* Diabe
	takestring, oldlist($allvars_hlth) newname("allvars_diabe") 
	* Lunge
	takestring, oldlist($allvars_hlth) newname("allvars_lunge") 
	
	*takestring, oldlist($allvars_econ1) newname("allvars_anyhi") 
	*takestring, oldlist($allvars_econ1) newname("allvars_diclaim")
	*takestring, oldlist($allvars_econ1) newname("allvars_ssclaim")
	*takestring, oldlist($allvars_econ1) newname("allvars_ssiclaim")
	*takestring, oldlist($allvars_econ1) newname("allvars_work")
	
	takestring, oldlist($allvars_econ1) newname("allvars_anyhi")  
	takestring, oldlist($allvars_econ1) newname("allvars_diclaim1")
	global allvars_diclaim $novars
	takestring, oldlist($allvars_econ1) newname("allvars_ssiclaim")
	takestring, oldlist($allvars_econ1) newname("allvars_oasiclaim1")
	global allvars_oasiclaim $novars
	takestring, oldlist($allvars_econ1) newname("allvars_work") 

	takestring, oldlist($allvars_econ2) newname("allvars_hicap_nonzero") 
	takestring, oldlist($allvars_econ2) newname("allvars_igxfr_nonzero")
	takestring, oldlist($allvars_econ2) newname("allvars_wlth_nonzero") 

	takestring, oldlist($allvars_econ2) newname("allvars_igxfr")
	takestring, oldlist($allvars_econ2) newname("allvars_hicap") 

	takestring, oldlist($allvars_econ1) newname("allvars_workstat") 
	global allvars_workstat $novars
	
	
	takestring, oldlist($allvars_econ1) newname("allvars_hatota")
	takestring, oldlist($allvars_econ1) newname("allvars_iearn")
	
	global allvars_iearn $novars
	global allvars_hatota $novars
	
	global allvars_any_iearn_ue $allvars_iearn
	global allvars_any_iearn_nl $allvars_iearn

	global allvars_lniearn_ft $allvars_iearn
	global allvars_lniearn_pt $allvars_iearn
	global allvars_lniearn_ue $allvars_iearn
	global allvars_lniearn_nl $allvars_iearn
	
	
	takestring, oldlist($allvars_econ1) newname("allvars_laborforcestat")
	global allvars_laborforcestat $allvars_laborforcestat $agesex
	takestring, oldlist($allvars_econ1) newname("allvars_fullparttime")
	global allvars_fullparttime $allvars_fullparttime $agesex
	
	global allvars_laborforcestat $novars
	global allvars_fullparttime $novars
	
	global allvars_smoke_start $novars
	global allvars_smoke_stop $novars	
	
	global allvars_srh $novars
	
	takestring, oldlist($novars) newname("allvars_inscat") extlist("l2age5564 l2age6574 l2age75p l2age5564_male l2age6574_male l2age75p_male")
	global allvars_inscat $allvars_inscat l2age55p l2age55p_male
	
	
	
	* For some reason, the interaction with male messes up the oasiclaim convergence
	global allvars_oasiclaim male l2age35l l2age3544 l2age4554 l2age5564 l2age6574 l2age75p
	global allvars_fu_fiitax_ind $novars
	global allvars_fu_siitax_ind $novars
	global allvars_ssdiamt $novars
	global allvars_ssiamt $novars
	global allvars_ssoasiamt $novars
	global allvars_satisfaction $novars
	global allvars_k6score $novars
	
	
	