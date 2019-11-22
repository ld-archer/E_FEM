	* Hearte
	takestring, oldlist($allvars_hlth) newname("allvars_hearte") extlist("l2hearte fhearte l2stroke l2lunge l2cancre l2adl1 l2adl2 l2adl3p")
	* Stroke 
	takestring, oldlist($allvars_hlth) newname("allvars_stroke") extlist("l2stroke fstroke l2stroke l2lunge l2adl1 l2adl2 l2adl3p black_educ1 black_educ3 black_educ4 hispan_educ1 hispan_educ3 hispan_educ4")
	* Cancre
	takestring, oldlist($allvars_hlth) newname("allvars_cancre") extlist("l2hearte l2stroke l2cancre l2hibpe l2diabe l2lunge fcancre l2adl1 l2adl2 l2adl3p")
	* Hibpe
	takestring, oldlist($allvars_hlth) newname("allvars_hibpe")  extlist("l2hearte l2stroke l2cancre l2hibpe l2lunge fhibpe l2adl1 l2adl2 l2adl3p")
	* Diabe
	takestring, oldlist($allvars_hlth) newname("allvars_diabe")  extlist("l2hearte l2stroke l2cancre l2hibpe l2diabe l2lunge fdiabe l2adl1 l2adl2 l2adl3p")
	* Lunge
	takestring, oldlist($allvars_hlth) newname("allvars_lunge")  extlist("l2hearte l2stroke l2cancre l2hibpe l2diabe l2lunge flunge l2adl1 l2adl2 l2adl3p")
	
	* smoke_start
	takestring, oldlist($allvars_hlth) newname("allvars_smoke_start") extlist("l2hearte l2stroke l2cancre l2hibpe l2diabe l2lunge flunge l2adl1 l2adl2 l2adl3p l2smoken")
	
	* smoke_stop
	takestring, oldlist($allvars_hlth) newname("allvars_smoke_stop") extlist("l2stroke l2cancre l2hibpe flunge l2adl1 l2adl2 l2adl3p l2smokev l2smoken")
		
	*takestring, oldlist($allvars_econ1) newname("allvars_anyhi") 
	*takestring, oldlist($allvars_econ1) newname("allvars_diclaim")
	*takestring, oldlist($allvars_econ1) newname("allvars_ssclaim")
	*takestring, oldlist($allvars_econ1) newname("allvars_ssiclaim")
	*takestring, oldlist($allvars_econ1) newname("allvars_work")
	
	takestring, oldlist($allvars_econ1) newname("allvars_anyhi")  extlist("l2ssiclaim l2smoken l2anyexercise")
	takestring, oldlist($allvars_econ1) newname("allvars_diclaim1") extlist("l2age5564 l2ssiclaim l2oasiclaim l2smoken l2anyexercise") 
	global allvars_diclaim $allvars_diclaim1 l2age5561 l2age6264
	takestring, oldlist($allvars_econ1) newname("allvars_ssiclaim") extlist("l2anyexercise")
/*	takestring, oldlist($allvars_econ1) newname("allvars_oasiclaim1") extlist("l2ssiclaim l2oasiclaim l2smoken l2age35l l2age3544 l2age4554 l2age5564 l2age6574 l2age75p l2anyexercise")
	global allvars_ssclaim $allvars_oasiclaim1 $nra $lvars_marr
	*/
	takestring, oldlist($allvars_econ1) newname("allvars_work") extlist("l2ssiclaim l2smoken l2anyexercise") 

	takestring, oldlist($allvars_econ2) newname("allvars_hicap_nonzero") extlist("l2smoken l2ssiclaim l2anyexercise") 
	takestring, oldlist($allvars_econ2) newname("allvars_igxfr_nonzero") extlist("l2anyexercise")
	takestring, oldlist($allvars_econ2) newname("allvars_wlth_nonzero") extlist("l2smoken l2ssiclaim l2anyexercise") 

	takestring, oldlist($allvars_econ2) newname("allvars_igxfr") extlist("l2anyexercise")
	takestring, oldlist($allvars_econ2) newname("allvars_hicap") extlist("l2smoken l2ssiclaim l2anyexercise") 

	takestring, oldlist($allvars_econ1) newname("allvars_workstat") extlist("l2ssiclaim l2smoken l2work l2anyexercise") 
	global allvars_workstat $allvars_workstat l2workstat1 l2workstat2 l2workstat3 l2workstat4
	
	
	takestring, oldlist($allvars_econ1) newname("allvars_hatota") extlist("l2anyexercise")
	
	
	global allvars_hatota $allvars_hatota l2loghatotax $educsex $lvars_marr $lvars_marr_sex $agemarr $agesex $ageeduc $bmivars
	
	
	takestring, oldlist($allvars_econ1) newname("allvars_laborforcestat") extlist("l2anyexercise")
	global allvars_laborforcestat $allvars_laborforcestat $agesex $educsex $lvars_marr $lvars_marr_sex $bmivars
	takestring, oldlist($allvars_econ1) newname("allvars_fullparttime") extlist("l2anyexercise")
	global allvars_fullparttime $allvars_fullparttime $agesex $educsex $lvars_marr $lvars_marr_sex $bmivars
	
*	global allvars_laborforcestat male $agevars $agese lworkcat2 lworkcat3 lworkcat4
*	global allvars_fullparttime male $agevars $agesex lworkcat2 lworkcat3 lworkcat4

	global allvars_more_educ l2age l2educ1 l2educ2 l2educ3 l2educ4 l2educ5 l2age_l2educ1 l2age_l2educ2 l2age_l2educ3 l2age_l2educ4 l2age_l2educ5 
	global allvars_educ $dvars_educ $agevars l2workcat2 l2workcat3 l2workcat4 l2numbiokids1 l2numbiokids2 l2numbiokids3p l2married l2cohab l2logiearnx
	global allvars_educ_alt $dvars_educ_alt $agevars l2workcat2 l2workcat3 l2workcat4 l2numbiokids1 l2numbiokids2 l2numbiokids3p l2married l2cohab l2logiearnx
	
	takestring, oldlist($allvars_econ1) newname("allvars_inscat")  extlist("l2ssiclaim l2smoken l2anyhi l2age5564 l2age6574 l2age75p l2anyexercise")
	global allvars_inscat $allvars_inscat l2inscat1 l2inscat2 $lvars_marr $lvars_marr_sex l2age55p

	* global allvars_more_educ agecat1 agecat2 agecat3 agecat4 agecat5 agecat6 agecat7
	* global allvars_educ 
	* global allvars_educ_alt

	
	* Setup the RHS variables (will move to shared program later)

* Changed age spline to be 65p, not 6574 and 75p
#d ;
global allvars_iearn 
	 		 male 
			educ1 educ3 educ4
			male_educ1 male_educ3 male_educ4
			black hispan
			male_black male_hispan
			l2married l2cohab
			male_l2married male_l2cohab
			l2age35l l2age3544 l2age4554 l2age5564 l2age65p
			l2age35l_male l2age3544_male l2age4554_male l2age5564_male l2age65p_male 
			l2age35l_educ1 l2age3544_educ1 l2age4554_educ1 l2age5564_educ1 l2age65p_educ1 
			l2age35l_educ3 l2age3544_educ3 l2age4554_educ3 l2age5564_educ3 l2age65p_educ3 
			l2age35l_educ4 l2age3544_educ4 l2age4554_educ4 l2age5564_educ4 l2age65p_educ4 
			l2hearte l2stroke l2cancre l2hibpe l2diabe l2lunge l2adl1 l2adl2 l2adl3p l2smokev l2smoken
			l2diclaim l2ssiclaim l2oasiclaim 
			l2workcat2 l2workcat3 l2workcat4
			l2ihsiearn
			l2ihsiearn_l2workcat1 l2ihsiearn_l2workcat3 l2ihsiearn_l2workcat4
			;
#d cr

global allvars_any_iearn_ue $allvars_iearn
global allvars_any_iearn_nl $allvars_iearn

global allvars_lniearn_ft $allvars_iearn
global allvars_lniearn_pt $allvars_iearn
global allvars_lniearn_ue $allvars_iearn
global allvars_lniearn_nl $allvars_iearn

	
global allvars_k6severe $allvars_hlth $lvars_marr

* k6 score (change this later)
* global allvars_k6score $dvars $agevars $k6vars $lvars_marr $lvars_marr_sex
global allvars_k6score $allvars_hlth l2k6score


* any exercise model (will feed into health, so excluding health ... )
global allvars_anyexercise $dvars $agevars $lvars_marr $lvars_marr_sex l2anyexercise


* binge drinking model
global allvars_binge_3permo $dvars $agevars $lvars_marr $lvars_marr_sex l2binge_3permo

* Using l2binge_3permo in the mortality and smoking models, too
global allvars_died $allvars_died l2binge_3permo
global allvars_smoke_start $allvars_smoke_start l2binge_3permo
global allvars_smoke_stop $allvars_smoke_stop l2binge_3permo

