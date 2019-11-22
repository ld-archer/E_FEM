/*** \file
This is the base file that defines covariates for each dependent variable. It contains the FEM base models - based on HRS data.
*/
/**** ADJUST COVARIATES FOR MODELS IN PROGRAM init_transition.do ****/

	takestring, oldlist($allvars_hlth) newname("allvars_hearte") extlist("l2hearte fheart50 l2stroke l2lunge l2cancre l2iadl1 l2iadl2p l2adl1 l2adl2 l2adl3p ")
	takestring, oldlist($allvars_hlth) newname("allvars_stroke") extlist("l2stroke fstrok50 l2stroke l2lunge l2iadl1 l2iadl2p l2adl1 l2adl2 l2adl3p ")
	takestring, oldlist($allvars_hlth) newname("allvars_cancre") extlist("l2hearte l2stroke l2cancre l2hibpe l2diabe l2lunge fcanc50 l2iadl1 l2iadl2p l2adl1 l2adl2 l2adl3p ")
	takestring, oldlist($allvars_hlth) newname("allvars_hibpe")  extlist("l2hearte l2stroke l2cancre l2hibpe l2lunge fhibp50 l2iadl1 l2iadl2p l2adl1 l2adl2 l2adl3p ")
	takestring, oldlist($allvars_hlth) newname("allvars_diabe")  extlist("l2hearte l2stroke l2cancre l2hibpe l2diabe l2lunge fdiabe50 l2iadl1 l2iadl2p l2adl1 l2adl2 l2adl3p ")
	takestring, oldlist($allvars_hlth) newname("allvars_lunge")  extlist("l2hearte l2stroke l2cancre l2hibpe l2diabe l2lunge flung50 l2iadl1 l2iadl2p l2adl1 l2adl2 l2adl3p ")
	takestring, oldlist($allvars_hlth) newname("allvars_memrye") extlist("l2hearte l2stroke l2cancre l2hibpe l2diabe l2lunge flung50 ")
	takestring, oldlist($allvars_hlth) newname("allvars_deprsymp") extlist("l2hearte l2stroke l2cancre l2hibpe l2diabe l2lunge")
	
        takestring, oldlist($allvars_diabe) newname("allvars_insulin")
        takestring, oldlist($allvars_diabe) newname("allvars_diabkidney")
        takestring, oldlist($allvars_hibpe) newname("allvars_bpcontrol")
        takestring, oldlist($allvars_lunge) newname("allvars_lungoxy")

	*global allvars_smkstat $allvars_hlth
	takestring, oldlist($allvars_hlth) newname("allvars_smkstat") extlist("fsmokev")
        global allvars_adlstat $allvars_hlth
        global allvars_iadlstat $allvars_hlth
        global allvars_painstat $allvars_hlth
	
	global allvars_logbmi $allvars_hlth frbyr
	*** in the AD paper we used the following covariates
	*** but here we will try the kitchen sink for health variables.
	* global allvars_cogstate $dvars lage65 lage65sq lmemrye lanyiadl ldiabe lhearte lstroke llunge lcancre lunderwt lobese lsmoken lcogstate1 lcogstate2
	*** 
	global allvars_cogstate l2cogstate1 l2cogstate2 $allvars_hlth
	
	takestring, oldlist($allvars_econ1) newname("allvars_anyhi")  extlist("l2age6574 l2age75p l2dbclaim l2ssiclaim l2nhmliv l2smoken")
	takestring, oldlist($allvars_econ1) newname("allvars_diclaim")  extlist("l2age65l l2age6574 l2age75p l2ssiclaim l2ssclaim l2dbclaim l2nhmliv l2smoken")
	global allvars_diclaim $allvars_diclaim nraplus10 nraplus9 nraplus8 nraplus7 nraplus6 nraplus5 nraplus4 nraplus3 nraplus2 nraplus1 
	takestring, oldlist($allvars_econ1) newname("allvars_dbclaim")  extlist("fanydb l2ssiclaim l2dbclaim l2work l2nhmliv l2smoken")
	takestring, oldlist($allvars_econ1) newname("allvars_ssiclaim")  extlist("l2nhmliv l2smoken")
	takestring, oldlist($allvars_econ4) newname("allvars_nhmliv")  extlist("l2diclaim l2ssiclaim l2ssclaim l2dbclaim l2work l2logiearnx l2smoken")

* Incorporate a measure of meeting the Normal Retirement Age for claiming Social Security
	takestring, oldlist($allvars_econ2) newname("allvars_ssclaim")  extlist("l2ssiclaim l2ssclaim l2nhmliv l2smoken l2age6061 l2age62e l2age63e l2age64e l2age6566 l2age6770")
	global allvars_ssclaim $allvars_ssclaim at_eea at_nra yrs_before_nra yrs_after_nra 
	
	* Bryan's revisions to work model
	* Replaced:  takestring, oldlist($allvars_econ2) newname("allvars_work")  extlist("l2ssiclaim l2nhmliv l2smoken")
  takestring, oldlist($allvars_econ2) newname("allvars_work")  extlist("l2ssiclaim l2nhmliv l2smoken fanydb l2age6061 l2age62e l2age63e l2age64e l2age6566 l2age6770")
	*global allvars_work $allvars_work lage5354 lage5556 lage5758 lage5960 lage6162 lage6364 lage6566 lage6768 lage6970 lage71p unemployment
	*global allvars_work $allvars_work nraplus10 nraplus9 nraplus8 nraplus7 nraplus6 nraplus5 nraplus4 nraplus3 nraplus2 nraplus1 nraplus0 nramin1 nramin2 nramin3 nramin4 nramin5 nramin6 nramin7 nramin8 nramin9 nramin10 unemployment
	global allvars_work $allvars_work at_eea at_nra yrs_before_nra yrs_after_nra unemployment
	
	takestring, oldlist($allvars_econ3) newname("allvars_wlth_nonzero")  extlist("l2ssiclaim l2smoken l2logiearnx l2ssclaim l2dbclaim l2wlth_nonzero l2diclaim w3 w4 w9")
	global allvars_wlth_nonzero $allvars_wlth_nonzero l2logiearnuc

takestring, oldlist($allvars_econ3) newname("allvars_hicap_nonzero") extlist("l2ssiclaim l2smoken w3 w4 w7 w8 w9")
takestring, oldlist($allvars_econ3) newname("allvars_hicap") extlist("l2ssiclaim l2smoken w3 w4 w7 w8 w9 ")
takestring, oldlist($allvars_econ3) newname("allvars_igxfr_nonzero") extlist("w3 w4 w7 w8 w9")     
takestring, oldlist($allvars_econ3) newname("allvars_igxfr") extlist("w3 w4 w7 w8 w9")     
takestring, oldlist($allvars_econ3) newname("allvars_logproptax_nonzero") extlist("l2ssiclaim l2smoken ")
takestring, oldlist($allvars_econ3) newname("allvars_logproptax") extlist("l2ssiclaim l2smoken ")
takestring, oldlist($allvars_econ3) newname("allvars_proptax_nonzero") extlist("l2ssiclaim l2smoken ")
takestring, oldlist($allvars_econ3) newname("allvars_proptax") extlist("l2ssiclaim l2smoken ")

*** FOR TRANSFER OUTCOMES
  global allvars_tcamt_cpl age_yrs agesq male married black hispan hsless college l2tcamt_cpl l2ihs_hwealth_cpl l2ihs_hicap_cpl l2hicap_nonzero l2adl1p l2iadl1p l2numdisease
  global allvars_ihs_tcamt_cpl age_yrs agesq male married black hispan hsless college l2ihs_hwealth_cpl l2ihs_hicap_cpl l2hicap_nonzero l2adl1p l2iadl1p l2numdisease
  global allvars_helphoursyr l2helphoursyr age_yrs agesq male married black hispan hsless college l2ihs_hwealth_cpl l2ihs_hicap_cpl l2hicap_nonzero l2iadl1 l2iadl2p l2adl1 l2adl2 l2adl3p l2hearte l2stroke l2cancre l2hibpe l2diabe l2lunge nkid_liv10mi
  takestring, oldlist($allvars_helphoursyr) newname("allvars_helphoursyr_nonsp") extlist("l2helphoursyr") 
  global allvars_helphoursyr_nonsp $allvars_helphoursyr_nonsp l2helphoursyr_nonsp
	takestring, oldlist($allvars_helphoursyr) newname("allvars_helphoursyr_sp") extlist("married nkid_liv10mi l2helphoursyr")
	global allvars_helphoursyr_sp $allvars_helphoursyr_sp l2helphoursyr_sp

** Property tax variables only develeped for two waves - initial values and lags are the same (7/31/13)
global allvars_logproptax_nonzero $allvars_logproptax_nonzero nhmliv  /*llogproptax_nonzero*/
global allvars_logproptax $allvars_logproptax nhmliv /*llogproptax*/
global allvars_proptax_nonzero $allvars_proptax_nonzero nhmliv /*lproptax_nonzero*/
global allvars_proptax $allvars_proptax nhmliv /*lproptax*/

global allvars_volhours l2volhours age_yrs agesq male black hispan hsless college l2loghatotax l2logiearnx l2hicap l2adl1p l2iadl1p l2numdisease l2widowed nkid_liv10mi suburb exurb catholic jewish reloth relnone rel_notimp rel_someimp           
global allvars_parhelphours l2parhelphours age_yrs agesq male black hispan hsless college l2loghatotax l2logiearnx l2hicap l2adl1p l2iadl1p l2numdisease l2widowed nkid_liv10mi suburb exurb            
global allvars_gkcarehrs l2gkcarehrs age_yrs agesq male black hispan hsless college l2loghatotax l2logiearnx l2hicap l2adl1p l2iadl1p l2numdisease l2widowed nkid_liv10mi suburb exurb            
  

/*****************************************************************************************************************************************/
/**** ADJUST COVARIATES FOR MODELS IN PROGRAM ghreg_estimations.do ****/

takestring, oldlist($allvars_econ1) newname("allvars_iearn")  extlist("l2ssiclaim l2nhmliv l2smoken w3 w9")

*Bryan's addition for uncapping income model
takestring, oldlist($allvars_econ1) newname("allvars_iearnuc")  extlist("l2ssiclaim l2nhmliv l2smoken l2logiearnx flogiearnx w3 w9")
disp "$allvars_iearnuc"
global allvars_iearnuc $allvars_iearnuc l2logiearnuc 
disp "$allvars_iearnuc"	

takestring, oldlist($allvars_econ3) newname("allvars_hatota")  extlist("l2ssiclaim l2smoken l2logiearnx l2ssclaim l2dbclaim l2wlth_nonzero l2diclaim w3 w4 w9")
global allvars_hatota $allvars_hatota l2logiearnuc
