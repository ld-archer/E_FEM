local uservars : env USERVARS

*** DEPENDENT VARIABLES
  global bin_econ anyhi diclaim ssclaim dbclaim ssiclaim nhmliv work wlth_nonzero hicap_nonzero igxfr_nonzero proptax_nonzero
	global bin_hlth died hearte stroke cancre hibpe diabe lunge memrye insulin diabkidney bpcontrol lungoxy deprsymp
	global order smkstat adlstat iadlstat cogstate painstat
global ols tcamt_cpl ihs_tcamt_cpl logbmi helphoursyr helphoursyr_nonsp helphoursyr_sp hicap igxfr proptax gkcarehrs parhelphours volhours
	global bin_fam (*** my dependent variables ***)

*** Demographics
	global dvars black hispan hsless college male male_hsless male_black male_hispan
*** Initial values
#d;
	global fvars fheart50 fstrok50 fcanc50 fhibp50 fdiabe50 flung50 fsmokev fsmoken50
	;
#d cr
*** restricted variables
if `uservars'==1 {
  global rvars
}
else {
	global rvars
}
*** values of health variables at t-1
	***global lvars_hlth lhearte lstroke lcancre lhibpe ldiabe llunge liadl1 liadl2p ladl1 ladl2 ladl3p lsmoken lwidowed 
	global lvars_hlth l2hearte l2stroke l2cancre l2hibpe l2diabe l2lunge l2iadl1 l2iadl2p l2adl1 l2adl2 l2adl3p l2smoken l2widowed 
*** values of econ variables at time t-1
	global lvars_econ l2work l2logiearnx l2wlth_nonzero l2loghatotax l2diclaim l2ssiclaim l2ssclaim l2dbclaim l2nhmliv

// BMI variables
global bmivars l2logbmi_l30 l2logbmi_30p flogbmi50_l30 flogbmi50_30p

*** FOR MORTALITY
	global allvars_died $dvars l2age65l l2age6574 l2age75p $lvars_hlth $fvars
	
*** FOR CHRONIC CONDITIONS AND ORDINAL OUTCOMES
	global allvars_hlth $dvars l2age65l l2age6574 l2age75p $lvars_hlth  $fvars $bmivars logdeltaage
*** FOR ECONOMIC OUTCOMES
  global allvars_econ1 $dvars l2age65l l2age6574 l2age75p $lvars_hlth $lvars_econ $fvars logdeltaage $rvars
  global allvars_econ2 $dvars l2age6061 l2age62e l2age63e l2age64e l2age6566 l2age6770 $lvars_hlth $lvars_econ $fvars logdeltaage $rvars
** add waves 8 and 9 for validation
  global allvars_econ3 $dvars l2a6 l2a7 l2a7p $lvars_hlth $lvars_econ $fvars w3 w4 w5 w6 w7 w8 w9 logdeltaage $rvars
  global allvars_econ4 $dvars l2age65l l2age6574 l2age75p $lvars_hlth $lvars_econ $fvars logdeltaage $rvars
  

local age_var age_iwe

** Sample Selection macros
foreach v in $bin_econ $order {
  local select_`v' !died
}

foreach v in hearte hibpe stroke lunge cancre diabe {
  local select_`v' !l2`v' & !died
}

local select_died !l2died
local select_memrye (l2memrye!=1 & wave >= 5) & !died
local select_lungoxy lunge
local select_diabkidney diabe & inrange(wave,4,11)
local select_insulin diabe
local select_bpcontrol hibpe & inrange(wave,4,11)
local select_painstat !died
local select_deprsymp !died

foreach v in hicap igxfr proptax {
  local select_`v'  `v'_nonzero
}

foreach v in iearn iearnuc {
  local select_`v' work == 1 & !died
}

local select_dbclaim !(fanydb == 0 | l2dbclaim == 1) & !died
local select_ssclaim l2`age_var' >= 60 & l2ssclaim == 0 & !died
local select_diclaim (l2`age_var' < (65-2)) & !died
local select_ssiclaim !( inlist(hacohort, 0, 1) & inlist(wave, 3, 4)) & !died
local select_anyhi (l2`age_var' < (65-2)) & !died
local select_work !died & weight > 0 & weight < . & `age_var' >= 50 & `age_var' < 80
local select_tcamt_cpl fkids >= 0
local select_ihs_tcamt_cpl fkids >= 0
local select_logbmi !missing(logbmi)
local select_helphoursyr fkids >= 0 & helphoursyr >= 0
local select_helphoursyr_nonsp fkids >= 0 & helphoursyr_nonsp >= 0
local select_helphoursyr_sp fkids >= 0 & helphoursyr_sp >= 0 & married==1
local select_hatota died == 0 & !missing(hatota) & hatota != 0
local select_cogstate died==0 & age > 66 & !missing(age) & !missing(l2cogstate) & !missing(cogstate)

local select_gkcarehrs wave > 4 & wave < 11 & fkids > 0
local select_parhelphours wave > 4 & wave < 11
local select_volhours wave > 4 & wave < 11

** only estimate models that use ssclaim, lssclaim and/or dbclaim, ldbclaim using data through wave 7. waves 8 and 9 not well populated for those variables
foreach v in anyhi dbclaim hicap hicap_nonzero iearn iearnuc igxfr igxfr_nonzero proptax proptax_nonzero ssclaim ssiclaim work {
  local select_`v' "`select_`v'' & wave <= 7"
}


