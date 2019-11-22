************************************************************************
*** Dependent variables
* Binary models estimates on pooled PSID and HRS samples
global bin_psid_hrs died partdied nhmliv
* Binary health outcomes
global bin_hlth stroke hearte anyexercise cancre hibpe diabe lunge smoke_start smoke_stop /* k6severe */
* Binary econ outcomes - removing dbclaim nhmliv; anyhi (using inscat), work (using two-stage model)
global bin_econ oasiclaim diclaim  ssiclaim hicap_nonzero igxfr_nonzero wlth_nonzero fullparttime proptax_nonzero
global ols logbmi hicap igxfr fu_fiitax_ind fu_siitax_ind ssdiamt ssiamt ssoasiamt proptax

global multlogit laborforcestat inscat

* Ordered outcomes - removing smkstat
global order adlstat iadlstat births paternity srh satisfaction k6score


* Marriage vars
* global marriage mstat_new
global bin_mstat exitsingle_m exitsingle_f single2married_m single2married_f exitcohab_m exitcohab_f cohab2married_m cohab2married_f exitmarried_m exitmarried_f married2cohab_m married2cohab_f

************************************************************************
* Building blocks for RHS variables
* 
global dvars black hispan educ1 educ3 educ4 black_educ1 black_educ3 black_educ4 hispan_educ1 hispan_educ3 hispan_educ4 male male_black male_hispan fpoor frich chldsrh2 chldsrh3 chldsrh4 chldsrh5

* mthreduc2 mthreduc3 mthreduc4 fthreduc2 fthreduc3 fthreduc4

global dvars_alt black hispan hsless college male male_black male_hispan

* Less than high school is reference category, leduc6 is excluded since it can only transition to that category.
global dvars_educ black hispan l2educ2 l2educ3 l2educ4 male male_black male_hispan
global dvars_educ_alt male 

* global agevars lage65l lage6574 lage75p
global agevars l2age35l l2age3544 l2age4554 l2age5564 l2age6574 l2age75p
global agerace l2age35l_black l2age3544_black l2age4554_black l2age5564_black l2age6574_black l2age75p_black l2age35l_hispan l2age3544_hispan l2age4554_hispan l2age5564_hispan l2age6574_hispan l2age75p_hispan
global agesex  l2age35l_male l2age3544_male l2age4554_male l2age5564_male l2age6574_male l2age75p_male

#d ;
global agemarr l2age35l_l2married l2age3544_l2married l2age4554_l2married l2age5564_l2married l2age6574_l2married l2age75p_l2married
							 l2age35l_l2cohab l2age3544_l2cohab l2age4554_l2cohab l2age5564_l2cohab l2age6574_l2cohab l2age75p_l2cohab
;
#d cr

#d ;
global ageeduc l2age35l_educ1 l2age3544_educ1 l2age4554_educ1 l2age5564_educ1 l2age6574_educ1 l2age75p_educ1
							 l2age35l_educ3 l2age3544_educ3 l2age4554_educ3 l2age5564_educ3 l2age6574_educ3 l2age75p_educ3
							 l2age35l_educ4 l2age3544_educ4 l2age4554_educ4 l2age5564_educ4 l2age6574_educ4 l2age75p_educ4
;
#d cr

global educsex male_educ1 male_educ3 male_educ4 

* Removing iadl* variables since they aren't defineed before 2003.  Removed: l2widowed 
global lvars_hlth l2hearte l2stroke l2cancre l2hibpe l2diabe l2lunge l2adl1 l2adl2 l2adl3p l2smokev l2smoken l2anyexercise
global lvars_hlth_over65 over65_l2hearte over65_l2stroke over65_l2cancre over65_l2hibpe over65_l2diabe over65_l2lunge 

* No l2smokev since it isn't defined in HRS
global lvars_hlth_died l2hearte l2stroke l2cancre l2hibpe l2diabe l2lunge l2adl1 l2adl2 l2adl3p l2smoken

*** values of econ variables at time t-1  - Removing: ldbclaim lnhmliv llogiearnx lwlth_nonzero lloghatotax
	global lvars_claim l2diclaim l2ssiclaim l2oasiclaim 
	global lvars_work l2workcat2 l2workcat3 l2workcat4
	global lvars_money l2logiearnx l2loghatotax
	global lvars_marr l2married l2cohab
	global lvars_marr_sex male_l2married male_l2cohab

* Removing fiadl* variables since they aren't defined before 2003.
#d;
	global fvars fhearte fstroke fcancre fhibpe fdiabe flunge fsmokev fsmoken fadl1 fadl2 fadl3p
	fwidowed fsingle  
	fwork flogiearnx fwlth_nonzero floghatotax
	fshlt ;
#d cr

#d;
global chldvars poorchldhlth chldmissschool chldmeasles chldmumps  chldcknpox  chldvision  chldparsmk  chldasthma  chlddiab 
		chldresp  chldspeech  chldallergy  chldheart  chldear  chldszre  chldmgrn  chldstomach  chldhibp  chlddepress  
		chlddrug  chldpsych ;
#d cr

global bmivars l2logbmi_l30 l2logbmi_30p 
global bmivars_sex male_l2logbmi_l30 male_l2logbmi_30p
* removing: flogbmi_l30 flogbmi_30p
* include lagged k6 score in k6 stuff
global k6vars l2k6score male_l2k6 black_l2k6 hisp_l2k6

* globals for econ vars
global dinter male_hsless male_black male_hispan
global waves w01 w03 w05 w07 w09 w11
global waves

global nra nraplus4 nraplus2 nraplus1 nraplus0 nramin0 nramin1 nramin2 nramin3 nramin4 nramin5 nramin6 nramin7 nramin8 nramin9 nramin10

global allvars_hlth $dvars $agevars $agesex $lvars_hlth $bmivars 
* $agerace

*** Binary Health Outcomes ***
	* Mortality
	global allvars_died $dvars_alt $agevars $lvars_hlth_died male_hsless male_college 
	
* Variables for NHMLIV, which is an HRS model, but re-estimating here for consistency
global allvars_nhmliv $dvars_alt $agevars $lvars_hlth_died l2widowed

*	global allvars_died $dvars_alt $agevars $agesex $agerace 
	

	* Mortality of partner/spouse
	global allvars_partdied $dvars_alt black hispan l2age65l l2age6574 l2age75p male_l2age65l male_l2age6574 male_l2age75p l2age65l_black l2age6574_black l2age75p_black l2age65l_hispan l2age6574_hispan l2age75p_hispan 	male_l2age65l_black male_l2age6574_black male_l2age75p_black male_l2age65l_hispan male_l2age6574_hispan male_l2age75p_hispan 
	takestring, oldlist($allvars_partdied) newname("allvars_partdied") extlist("black hispan")
	* need to re-add black and hispan as covariates
	global allvars_partdied $allvars_partdied black hispan male_hsless male_college 

*** Continuous Health Outcomes ***
	* Log BMI
	global allvars_logbmi $dvars $agevars $bmivars $lvars_marr $lvars_marr_sex

*** Ordered Health Outcomes ***
	* ADL status
	global allvars_adlstat $allvars_hlth
  * IADL status
  global allvars_iadlstat $allvars_hlth l2iadl1 l2iadl2p
  * Smoking status
	global allvars_smkstat $dvars $agevars $lvars_marr $lvars_work l2smokev l2smoken
	
	
	* cross-sectional self-reported health ordered probit
	global allvars_srh $dvars age agesq cancre icancre diabe idiabe hearte ihearte hibpe ihibpe lunge ilunge stroke istroke adl1 adl2 adl3p iadl1 iadl2p married cohab male_married male_cohab

	* cross-sectional life satisfaction ordered probit
	global allvars_satisfaction $dvars age agesq cancre icancre diabe idiabe hearte ihearte hibpe ihibpe lunge ilunge stroke istroke adl1 adl2 adl3p iadl1 iadl2p married cohab male_married male_cohab logiearnx loghatotax numbiokids1 numbiokids2 numbiokids3p

  * Number of birth events - removing: l2yrsnclastkid l2yrsnclastkid2 since they aren't well defined for those with no kids
	global allvars_births black hispan l2age l2agesq l2numbiokids1 l2numbiokids2 l2numbiokids3p l2married l2cohab l2workcat2 l2workcat3 l2workcat4 educ1 educ3 educ4 mthreduc2 mthreduc3 mthreduc4 l2cancre
	global allvars_paternity black hispan l2age l2agesq l2numbiokids1 l2numbiokids2 l2numbiokids3p l2married l2cohab l2workcat2 l2workcat3 l2workcat4 educ1 educ3 educ4 mthreduc2 mthreduc3 mthreduc4

	* cross-sectional ssdi amount ols
	global allvars_diclaim l2age35l l2age3544 l2age4554 l2age5561 l2age6264 l2age5564 l2age6574 l2age75p male educ1 educ3 educ4 male_educ1 male_educ3 male_educ4 black hispan male_black male_hispan l2cancre l2diabe l2hearte l2hibpe l2lunge l2stroke l2adl1 l2adl2 l2adl3p y2001 y2003 y2005 y2007 y2009 y2011 y2013 l2diclaim
	global allvars_ssdiamt l2age35l l2age3544 l2age4554 l2age5564 l2age6574 l2age75p male educ1 educ3 educ4 male_educ1 male_educ3 male_educ4 /* y2001 y2003 y2005 y2007 y2009 y2011 y2013 */

	global allvars_ssiclaim l2age35l l2age3544 l2age4554 l2age5564 l2age6574 l2age75p male educ1 educ3 educ4 male_educ1 male_educ3 male_educ4 black hispan male_black male_hispan l2cancre l2diabe l2hearte l2hibpe l2lunge l2stroke l2adl1 l2adl2 l2adl3p y2001 y2003 y2005 y2007 y2009 y2011 y2013 l2loghatotax
	global allvars_ssiamt l2age35l l2age3544 l2age4554 l2age5564 l2age6574 l2age75p male educ1 educ3 educ4 male_educ1 male_educ3 male_educ4 /* y2001 y2003 y2005 y2007 y2009 y2011 y2013 */ l2loghatotax

	global allvars_oasiclaim l2age35l l2age3544 l2age4554 l2age5564 l2age6574 l2age75p l2age6061 l2age6263 l2age6566 l2age6770 male educ1 educ3 educ4 male_educ1 male_educ3 male_educ4 black hispan male_black male_hispan l2cancre l2diabe l2hearte l2hibpe l2lunge l2stroke l2adl1 l2adl2 l2adl3p y2001 y2003 y2005 y2007 y2009 y2011 y2013
	global allvars_ssoasiamt l2age35l l2age3544 l2age4554 l2age5564 l2age6574 l2age75p male educ1 educ3 educ4 male_educ1 male_educ3 male_educ4 /* y2001 y2003 y2005 y2007 y2009 y2011 y2013 */

	* Cross-sectional models for federal and state income taxes (uses real earnings variable to avoid issues in simulation
	global allvars_fu_fiitax_ind black hispan educ1 educ3 educ4 married cohab $agevars iearn_real hicap_real 
	global allvars_fu_siitax_ind black hispan educ1 educ3 educ4 married cohab $agevars iearn_real hicap_real
	
	
/*
	#d ;
	global allvars_births educ1 educ3 educ4 black hispan l2numbiokids1 l2numbiokids2 l2numbiokids3p l2age  
	black_educ1 black_educ3 black_educ4 hispan_educ1 hispan_educ3 hispan_educ4 
	l2age_educ1 l2age_educ3 l2age_educ4 ;
	
	global allvars_paternity educ1 educ3 educ4 black hispan l2numbiokids1 l2numbiokids2 l2numbiokids3p l2age 
	black_educ1 black_educ3 black_educ4 hispan_educ1 hispan_educ3 hispan_educ4 
	l2age_educ1 l2age_educ3 l2age_educ4
	;
	
	#d cr
	*/

*** Binary Econ Outcomes ***
	*global allvars_econ1 $dvars lage35l lage3544 lage4554 lage5564 lage6574 lage75p $lvars_hlth $lvars_econ 
	global allvars_econ1 $dvars $agevars $lvars_hlth $lvars_claim $lvars_work $lvars_money
	global allvars_econ2 $dvars $agevars $lvars_hlth $lvars_claim $lvars_work $lvars_money $waves
	
	local mstat_agevars l2age3034d l2age3539d l2age4049d l2age5059d l2age6064d l2age65pd 
	foreach v in `mstat_agevars' {
		local mstat_agevars `mstat_agevars' black_`v' hispan_`v'
	}
	*global comm  black hispan hsless college l2workcat2 l2workcat3 l2workcat4 l2logiearnx l2loghatotax mthreduc2 mthreduc3 mthreduc4 l2numbiokids1 l2numbiokids2 l2numbiokids3p `mstat_agevars'
	global comm  black hispan educ1 educ3 educ4 l2workcat2 l2workcat3 l2workcat4 l2logiearnx l2loghatotax mthreduc2 mthreduc3 mthreduc4 l2numbiokids1 l2numbiokids2 l2numbiokids3p
		
	* these variables were taken out of the marital status model because they haven't been developed for the simulation yet
	* ed_0 ed_2 ed_3 ed_4 more1mb lsrh lobes_ind lkidsinfu lyrlstst lretired 
	
	#d;
	global allvars_exitsingle_m l2everm l2eversep	$comm
	l2age3034d l2age3539d l2age4049d l2age5059d l2age6064d l2age65pd 
	black_l2age3034d black_l2age3539d black_l2age4049d black_l2age5059d black_l2age6064d black_l2age65pd 
	hispan_l2age3034d hispan_l2age3539d hispan_l2age4049d hispan_l2age5059d hispan_l2age60pd
	;
	global allvars_exitsingle_f l2everm l2eversep	$comm
	l2age3034d l2age3539d l2age4049d l2age5059d l2age6064d l2age65pd 
	black_l2age3034d black_l2age3539d black_l2age4049d black_l2age5059d black_l2age6064d black_l2age65pd 
	hispan_l2age3034d hispan_l2age3539d hispan_l2age4049d hispan_l2age5059d hispan_l2age60pd
	;
	global allvars_single2married_m l2everm l2eversep	$comm
	l2age3034d l2age3539d l2age4049d l2age50pd 
	;
	global allvars_single2married_f l2everm l2eversep	$comm
	l2age3034d l2age3539d l2age4049d l2age50pd 
	;
	global allvars_exitcohab_m l2everm	$comm
	l2age3034d l2age3539d l2age4049d l2age5059d l2age6064d l2age65pd 
	black_l2age3034d black_l2age3539d black_l2age4049d black_l2age50pd 
	hispan_l2age3034d hispan_l2age3539d hispan_l2age4049d hispan_l2age50pd
	;
	global allvars_exitcohab_f l2everm	$comm
	l2age3034d l2age3539d l2age4049d l2age5059d l2age6064d l2age65pd 
	black_l2age3034d black_l2age3539d black_l2age4049d black_l2age50pd 
	hispan_l2age3034d hispan_l2age3539d hispan_l2age4049d hispan_l2age50pd
	;
	global allvars_cohab2married_m l2everm	$comm
	l2age3034d l2age3539d l2age4049d l2age50pd 
	;
	global allvars_cohab2married_f l2everm	$comm
	l2age3034d l2age3539d l2age4049d l2age50pd 
	;
	global allvars_exitmarried_m $comm
	l2age3034d l2age3539d l2age4049d l2age5059d l2age6064d l2age65pd 
	black_l2age3034d black_l2age3539d black_l2age4049d black_l2age5059d black_l2age6064d black_l2age65pd 
	hispan_l2age3034d hispan_l2age3539d hispan_l2age4049d hispan_l2age5059d hispan_l2age60pd
	;
	global allvars_exitmarried_f $comm
	l2age3034d l2age3539d l2age4049d l2age5059d l2age6064d l2age65pd 
	black_l2age3034d black_l2age3539d black_l2age4049d black_l2age5059d black_l2age6064d black_l2age65pd 
	hispan_l2age3034d hispan_l2age3539d hispan_l2age4049d hispan_l2age5059d hispan_l2age6064d hispan_l2age65pd
	;
	global allvars_married2cohab_m $comm
	l2age3034d l2age3539d l2age4049d l2age50pd 
	;
	global allvars_married2cohab_f $comm
	l2age3034d l2age3539d l2age4049d l2age50pd 
	;
	#d cr

	/* NOT NEEDED FOR 2-STAGE MODEL **
	* set up covariates for transitioning each marital status - age bins collapsed to avoid collinearity
	*global mstat_f1 $comm l2everm l2eversep 
	#d ;
	global mstat_f1 $comm l2everm l2eversep 
	l2age3034d l2age3539d l2age4049d l2age5059d l2age6064d l2age65pd 
	black_l2age3034d black_l2age3539d black_l2age40pd 
	hispan_l2age3034d hispan_l2age3539d hispan_l2age40pd 
	;
	#d cr
	di "$mstat_f1"
	
	*global mstat_f2 $comm l2everm
	#d ;
	global mstat_f2 $comm l2everm 
	l2age3034d l2age3539d l2age4049d l2age5059d l2age6064d l2age65pd 
	black_l2age3034d black_l2age3539d black_l2age4049d black_l2age5059d black_l2age60pd 
	hispan_l2age3034d hispan_l2age35pd
	;
	#d cr
	di "$mstat_f2"
	
	*global mstat_f3 $comm
	#d ;
	global mstat_f3 $comm 
	l2age3034d l2age35pd
	;
	#d cr
	di "$mstat_f3"
	*/
	
/* Selection criteria for models */

local select_died !l2died
local select_nhmliv !l2died
local select_partdied l2mstat_new != 1
local select_hearte !died & !l2hearte
local select_stroke !died & !l2stroke
local select_cancre !died & !l2cancre
local select_hibpe !died & !l2hibpe
local select_diabe !died & !l2diabe
local select_lunge !died & !l2lunge
local select_anyhi !died
local select_diclaim !died & age < 65
local select_ssiclaim !died
* Treat as absorbing if over NRA
local select_oasiclaim !died & ((age >= 25 & age < 70 & l2oasiclaim == 0) | (age < 62 & l2oasiclaim == 1))
local select_work !died
local select_adlstat !died & year >= 2005
local select_iadlstat !died & year >= 2005

foreach v of any hicap igxfr wlth proptax {
  local select_`v'_nonzero !died
  local select_`v' !died & `v'_nonzero
}

* Possibly restrict to waves 2001-2003, 2007-present
local select_k6severe !died 
local select_k6score !died

* Exploring probit for smoken
local select_smoke_start !died & !l2smoken
local select_smoke_stop !died & l2smoken

local select_workstat !died 
local select_births !died & male==0 & l2age < 43 & l2age >= 23
local select_paternity !died & male==1 & l2age < 54 & l2age >= 23
local select_logbmi !died & !missing(bmi)

* Estimate earnings only for those part-time or full-time
local select_iearn_ft !l2died & workcat == 4
local select_iearn_pt !l2died & workcat == 3
* local select_iearn_ue !l2died & workcat == 2

local select_lniearn_ft !l2died & workcat == 4
local select_lniearn_pt !l2died & workcat == 3

local select_hatota !l2died & hatota != 0


local select_laborforcestat !l2died
local select_fullparttime !l2died & laborforcestat == 3
local select_inscat !l2died & l2age < 63

* respondents will only have childhood self-reported health after 2007
local select_srh !l2died & year >= 2007

* life satisfaction is only asked of respondents 2009 and later
local select_satisfaction !l2died & year >= 2009


local select_exitsingle_m !died & l2mstat_new==1 & male==1 & !(mstat_new==1 & partdied & !l2partdied)
local select_exitsingle_f !died & l2mstat_new==1 & male==0 & !(mstat_new==1 & partdied & !l2partdied)
local select_exitcohab_m !died & l2mstat_new==2 & male==1 & !(mstat_new==1 & partdied & !l2partdied)
local select_exitcohab_f !died & l2mstat_new==2 & male==0 & !(mstat_new==1 & partdied & !l2partdied)
local select_exitmarried_m !died & l2mstat_new==3 & male==1 & !(mstat_new==1 & partdied & !l2partdied)
local select_exitmarried_f !died & l2mstat_new==3 & male==0 & !(mstat_new==1 & partdied & !l2partdied)
local select_single2married_m !died & exitsingle==1 & male==1 & !(mstat_new==1 & partdied & !l2partdied)
local select_single2married_f !died & exitsingle==1 & male==0 & !(mstat_new==1 & partdied & !l2partdied)
local select_cohab2married_m !died & exitcohab==1 & male==1 & !(mstat_new==1 & partdied & !l2partdied)
local select_cohab2married_f !died & exitcohab==1 & male==0 & !(mstat_new==1 & partdied & !l2partdied)
local select_married2cohab_m !died & exitmarried==1 & male==1 & !(mstat_new==1 & partdied & !l2partdied)
local select_married2cohab_f !died & exitmarried==1 & male==0 & !(mstat_new==1 & partdied & !l2partdied)

* models for any iearnings
local select_any_iearn_ue !l2died & workcat == 2
local select_any_iearn_nl !l2died & workcat == 1

* models for non-zero amounts
local select_lniearn_ft !l2died & workcat == 4 & any_iearn_ft
local select_lniearn_pt !l2died & workcat == 3 & any_iearn_pt
local select_lniearn_ue !l2died & workcat == 2 & any_iearn_ue
local select_lniearn_nl !l2died & workcat == 1 & any_iearn_nl

local select_anyexercise !l2died 

* Currently only have tax data throgh 2011
local select_fu_fiitax_ind inlist(year,2009,2011)
local select_fu_siitax_ind inlist(year,2009,2011)

* models for social security amount in FAM
local select_ssdiamt !died & year>=2005 & diclaim == 1 & inrange(age, 25, 65)
local select_ssiamt !died & ssiclaim == 1 & age >= 25
local select_ssoasiamt !died & oasiclaim == 1 & year>=2005 & age >= 25

