/*** \file
This is the base file that defines covariates for each dependent variable. It contains the FEM base models - based on HRS data.
*/
/**** ADJUST COVARIATES FOR MODELS IN PROGRAM init_transition.do ****/

	takestring, oldlist($allvars_hlth) newname("allvars_hearte") extlist("lhearte fhearte lstroke llunge lcancre liadl1 liadl2p ladl1 ladl2 ladl3p ")
	takestring, oldlist($allvars_hlth) newname("allvars_stroke") extlist("lstroke fstroke lstroke llunge liadl1 liadl2p ladl1 ladl2 ladl3p ")
	takestring, oldlist($allvars_hlth) newname("allvars_cancre") extlist("lhearte lstroke lcancre lhibpe ldiabe llunge fcancre liadl1 liadl2p ladl1 ladl2 ladl3p ")
	takestring, oldlist($allvars_hlth) newname("allvars_hibpe")  extlist("lhearte lstroke lcancre lhibpe llunge fhibpe liadl1 liadl2p ladl1 ladl2 ladl3p ")
	takestring, oldlist($allvars_hlth) newname("allvars_diabe")  extlist("lhearte lstroke lcancre lhibpe ldiabe llunge fdiabe liadl1 liadl2p ladl1 ladl2 ladl3p ")
	takestring, oldlist($allvars_hlth) newname("allvars_lunge")  extlist("lhearte lstroke lcancre lhibpe ldiabe llunge flunge liadl1 liadl2p ladl1 ladl2 ladl3p ")
	takestring, oldlist($allvars_hlth) newname("allvars_memrye") extlist("lhearte lstroke lcancre lhibpe ldiabe llunge flunge ")
	takestring, oldlist($allvars_hlth) newname("allvars_deprsymp") extlist("lhearte lstroke lcancre lhibpe ldiabe llunge")
	
        takestring, oldlist($allvars_diabe) newname("allvars_insulin")
        takestring, oldlist($allvars_diabe) newname("allvars_diabkidney")
        takestring, oldlist($allvars_hibpe) newname("allvars_bpcontrol")
        takestring, oldlist($allvars_lunge) newname("allvars_lungoxy")

	global allvars_smkstat $allvars_hlth
        global allvars_adlstat $allvars_hlth
        global allvars_iadlstat $allvars_hlth
        global allvars_painstat $allvars_hlth
	
	global allvars_logbmi $allvars_hlth frbyr
	*** in the AD paper we used the following covariates
	*** but here we will try the kitchen sink for health variables.
	* global allvars_cogstate $dvars lage65 lage65sq lmemrye lanyiadl ldiabe lhearte lstroke llunge lcancre lunderwt lobese lsmoken lcogstate1 lcogstate2
	*** 
	global allvars_cogstate lcogstate1 lcogstate2 $allvars_hlth
	
	takestring, oldlist($allvars_econ1) newname("allvars_anyhi")  extlist("lage6574 lage75p ldbclaim lssiclaim lnhmliv lsmoken")
	takestring, oldlist($allvars_econ1) newname("allvars_diclaim")  extlist("lage65l lage6574 lage75p lssiclaim lssclaim ldbclaim lnhmliv lsmoken")
	global allvars_diclaim $allvars_diclaim eeaplus3p eeaplus2 eeaplus1 eeaplus0 eeamin1 eeamin2l 
	takestring, oldlist($allvars_econ1) newname("allvars_dbclaim")  extlist("fwork fanydb lssiclaim ldbclaim lwork lnhmliv lsmoken")
	takestring, oldlist($allvars_econ1) newname("allvars_ssiclaim")  extlist("lnhmliv lsmoken")
	takestring, oldlist($allvars_econ4) newname("allvars_nhmliv")  extlist("ldiclaim lssiclaim lssclaim ldbclaim lwork llogiearnx lsmoken frdb_na_4")

* Incorporate a measure of meeting the Normal Retirement Age for claiming Social Security
	takestring, oldlist($allvars_econ2) newname("allvars_ssclaim")  extlist("lssiclaim lssclaim lnhmliv lsmoken lage6061 lage62e lage63e lage64e lage6566 lage6770")
	global allvars_ssclaim $allvars_ssclaim nraplus3p nraplus2 nraplus1 nraplus0 nramin1 nramin2 nramin3 nramin4 nramin5l
	
	* Bryan's revisions to work model
	* Replaced:  takestring, oldlist($allvars_econ2) newname("allvars_work")  extlist("lssiclaim lnhmliv lsmoken")
  takestring, oldlist($allvars_econ2) newname("allvars_work")  extlist("lssiclaim lnhmliv lsmoken fanydb frdb_na_2 frdb_na_3 frdb_na_4 fanydc flogdcwlthx lage6061 lage62e lage63e lage64e lage6566 lage6770 fraime frq")
	*global allvars_work $allvars_work lage5354 lage5556 lage5758 lage5960 lage6162 lage6364 lage6566 lage6768 lage6970 lage71p unemployment
	global allvars_work $allvars_work nraplus10 nraplus9 nraplus8 nraplus7 nraplus6 nraplus5 nraplus4 nraplus3 nraplus2 nraplus1 nraplus0 nramin1 nramin2 nramin3 nramin4 nramin5 nramin6 nramin7 nramin8 nramin9 nramin10 unemployment

	takestring, oldlist($allvars_econ3) newname("allvars_wlth_nonzero")  extlist("lssiclaim lsmoken ")

takestring, oldlist($allvars_econ3) newname("allvars_hicap_nonzero") extlist("lssiclaim lsmoken ")
takestring, oldlist($allvars_econ3) newname("allvars_hicap") extlist("lssiclaim, lsmoken ")
takestring, oldlist($allvars_econ3) newname("allvars_igxfr_nonzero")
takestring, oldlist($allvars_econ3) newname("allvars_igxfr")
takestring, oldlist($allvars_econ3) newname("allvars_logproptax_nonzero") extlist("lssiclaim lsmoken ")
takestring, oldlist($allvars_econ3) newname("allvars_logproptax") extlist("lssiclaim lsmoken ")
takestring, oldlist($allvars_econ3) newname("allvars_proptax_nonzero") extlist("lssiclaim lsmoken ")
takestring, oldlist($allvars_econ3) newname("allvars_proptax") extlist("lssiclaim lsmoken ")

*** FOR TRANSFER OUTCOMES
  global allvars_tcamt_cpl age_yrs agesq male married black hispan fkids hsless college ltcamt_cpl lihs_hwealth_cpl flogiearnx lihs_hicap_cpl lhicap_nonzero ladl1p liadl1p lnumdisease
  global allvars_ihs_tcamt_cpl age_yrs agesq male married black hispan fkids hsless college lihs_hwealth_cpl flogiearnx lihs_hicap_cpl lhicap_nonzero ladl1p liadl1p lnumdisease
  global allvars_helphoursyr lhelphoursyr age_yrs agesq male married black hispan fkids hsless college lihs_hwealth_cpl flogiearnx lihs_hicap_cpl lhicap_nonzero liadl1 liadl2p ladl1 ladl2 ladl3p lhearte lstroke lcancre lhibpe ldiabe llunge nkid_liv10mi
  takestring, oldlist($allvars_helphoursyr) newname("allvars_helphoursyr_nonsp") extlist("lhelphoursyr") 
  global allvars_helphoursyr_nonsp $allvars_helphoursyr_nonsp lhelphoursyr_nonsp
	takestring, oldlist($allvars_helphoursyr) newname("allvars_helphoursyr_sp") extlist("married nkid_liv10mi lhelphoursyr")
	global allvars_helphoursyr_sp $allvars_helphoursyr_sp lhelphoursyr_sp

** Property tax variables only develeped for two waves - initial values and lags are the same (7/31/13)
global allvars_logproptax_nonzero $allvars_logproptax_nonzero nhmliv flogproptax_nonzero /*llogproptax_nonzero*/
global allvars_logproptax $allvars_logproptax nhmliv flogproptax /*llogproptax*/
global allvars_proptax_nonzero $allvars_proptax_nonzero nhmliv fproptax_nonzero /*lproptax_nonzero*/
global allvars_proptax $allvars_proptax nhmliv fproptax /*lproptax*/

global allvars_volhours lvolhours age_yrs agesq male black hispan hsless college lloghatotax llogiearnx lhicap ladl1p liadl1p lnumdisease lwidowed fsingle nkid_liv10mi suburb exurb catholic jewish reloth relnone rel_notimp rel_someimp           
global allvars_parhelphours lparhelphours age_yrs agesq male black hispan hsless college lloghatotax llogiearnx lhicap ladl1p liadl1p lnumdisease lwidowed fsingle nkid_liv10mi suburb exurb            
global allvars_gkcarehrs lgkcarehrs age_yrs agesq male black hispan hsless college lloghatotax llogiearnx lhicap ladl1p liadl1p lnumdisease lwidowed fsingle nkid_liv10mi suburb exurb            
  

/*****************************************************************************************************************************************/
/**** ADJUST COVARIATES FOR MODELS IN PROGRAM ghreg_estimations.do ****/

takestring, oldlist($allvars_econ1) newname("allvars_iearn")  extlist("lssiclaim lnhmliv lsmoken")

*Bryan's addition for uncapping income model
takestring, oldlist($allvars_econ1) newname("allvars_iearnuc")  extlist("lssiclaim lnhmliv lsmoken llogiearnx flogiearnx")
disp "$allvars_iearnuc"
global allvars_iearnuc $allvars_iearnuc llogiearnuc flogiearnuc
disp "$allvars_iearnuc"	

takestring, oldlist($allvars_econ3) newname("allvars_hatota")  extlist("lssiclaim lsmoken")
