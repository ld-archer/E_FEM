local uservars : env USERVARS

*** DEPENDENT VARIABLES
  global bin_econ anyhi diclaim ssclaim dbclaim ssiclaim nhmliv work wlth_nonzero hicap_nonzero igxfr_nonzero logproptax_nonzero proptax_nonzero
	global bin_hlth died hearte stroke cancre hibpe diabe lunge memrye insulin diabkidney bpcontrol lungoxy
	global order smkstat adlstat iadlstat cogstate painstat
global ols tcamt_cpl ihs_tcamt_cpl logbmi helphoursyr helphoursyr_nonsp helphoursyr_sp hicap igxfr logproptax proptax gkcarehrs parhelphours volhours
	global bin_fam (*** my dependent variables ***)

*** Demographics
	global dvars black hispan hsless college male male_hsless male_black male_hispan
*** Initial values
#d;
	global fvars fhearte fstroke fcancre fhibpe fdiabe flunge fsmokev fsmoken fiadl1 fiadl2p fadl1 fadl2 fadl3p
	fwidowed fsingle fwork flogiearnx fwlth_nonzero floghatotax 
	fshlt fanydb frdb_na_2 frdb_na_3 frdb_na_4 fanydc flogdcwlthx ;
#d cr
*** restricted variables
if `uservars'==1 {
  global rvars fraime frq
}
else {
	global rvars
}
*** values of health variables at t-1
	***global lvars_hlth lhearte lstroke lcancre lhibpe ldiabe llunge liadl1 liadl2p ladl1 ladl2 ladl3p lsmoken lwidowed 
	global lvars_hlth lhearte lstroke lcancre lhibpe ldiabe llunge liadl1 liadl2p ladl1 ladl2 ladl3p lsmoken lwidowed 
*** values of econ variables at time t-1
	global lvars_econ lwork llogiearnx lwlth_nonzero lloghatotax ldiclaim lssiclaim lssclaim ldbclaim lnhmliv

// BMI variables
global bmivars llogbmi_l30 llogbmi_30p flogbmi_l30 flogbmi_30p

*** FOR MORTALITY
	global allvars_died $dvars lage65l lage6574 lage75p $lvars_hlth $fvars
	
*** FOR CHRONIC CONDITIONS AND ORDINAL OUTCOMES
	global allvars_hlth $dvars lage65l lage6574 lage75p $lvars_hlth  $fvars $bmivars logdeltaage
*** FOR ECONOMIC OUTCOMES
  global allvars_econ1 $dvars lage65l lage6574 lage75p $lvars_hlth $lvars_econ $fvars logdeltaage $rvars
  global allvars_econ2 $dvars lage6061 lage62e lage63e lage64e lage6566 lage6770 $lvars_hlth $lvars_econ $fvars logdeltaage $rvars
** add waves 8 and 9 for validation
  global allvars_econ3 $dvars la6 la7 la7p $lvars_hlth $lvars_econ $fvars w3 w4 w5 w6 w7 w8 w9 logdeltaage $rvars
  global allvars_econ4 $dvars lage65l lage6574 lage75p $lvars_hlth $lvars_econ $fvars logdeltaage $rvars
  

local age_var age_iwe

** Sample Selection macros
foreach v in $bin_econ $order {
  local select_`v' !died
}

foreach v in hearte hibpe stroke lunge cancre diabe {
  local select_`v' !l`v' & !died
}

local select_died !ldied
local select_memrye (lmemrye!=1 & wave >= 5) & !died
local select_lungoxy lunge
local select_diabkidney diabe & inrange(wave,4,11)
local select_insulin diabe
local select_bpcontrol hibpe & inrange(wave,4,11)
local select_painstat !died

foreach v in hicap igxfr logproptax proptax {
  local select_`v'  `v'_nonzero
}

foreach v in iearn iearnuc {
  local select_`v' work == 1
}

local select_dbclaim !(fanydb == 0 | ldbclaim == 1) & !died
local select_ssclaim l`age_var' >= 60 & lssclaim == 0 & !died
local select_diclaim (l`age_var' < (65-2)) & !died
local select_ssiclaim !( inlist(hacohort, 0, 1) & inlist(wave, 3, 4)) & !died
local select_anyhi (l`age_var' < (65-2)) & !died
local select_work !died & weight > 0 & weight < . & `age_var' >= 50 & `age_var' < 80
local select_tcamt_cpl fkids >= 0
local select_ihs_tcamt_cpl fkids >= 0
local select_logbmi !missing(bmi)
local select_helphoursyr fkids >= 0 & helphoursyr >= 0
local select_helphoursyr_nonsp fkids >= 0 & helphoursyr_nonsp >= 0
local select_helphoursyr_sp fkids >= 0 & helphoursyr_sp >= 0 & married==1
local select_hatota died == 0 & !missing(hatota) & hatota != 0
local select_cogstate died==0 & age > 66 & !missing(age) & !missing(lcogstate) & !missing(cogstate)

local select_gkcarehrs wave > 4 & fkids > 0
local select_parhelphours wave > 4 
local select_volhours wave > 4 

** only estimate models that use ssclaim, lssclaim and/or dbclaim, ldbclaim using data through wave 7. waves 8 and 9 not well populated for those variables
foreach v in anyhi dbclaim hatota hicap hicap_nonzero iearn iearnuc igxfr igxfr_nonzero logproptax proptax proptax_nonzero ssclaim ssiclaim wlth_nonzero work {
  local select_`v' "`select_`v'' & wave <= 7"
}


