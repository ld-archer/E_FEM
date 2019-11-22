************************************************************************
*** Dependent variables
* Binary models estimates on pooled PSID and HRS samples
global bin_psid_hrs died partdied
* Binary health outcomes
global bin_hlth hearte stroke cancre hibpe diabe lunge smoke_start smoke_stop
* Binary econ outcomes - removing dbclaim nhmliv; anyhi (using inscat), work (using two-stage model)
global bin_econ oasiclaim diclaim  ssiclaim hicap_nonzero igxfr_nonzero wlth_nonzero fullparttime 
global ols logbmi hicap igxfr fu_fiitax_ind fu_siitax_ind ssdiamt ssiamt ssoasiamt

global multlogit laborforcestat inscat

* Ordered outcomes - removing smkstat
global order adlstat iadlstat births paternity srh satisfaction k6score

* Marriage vars
* global marriage mstat_new
global bin_mstat exitsingle_m exitsingle_f single2married_m single2married_f exitcohab_m exitcohab_f cohab2married_m cohab2married_f exitmarried_m exitmarried_f married2cohab_m married2cohab_f

************************************************************************
* Building blocks for RHS variables

global novars male l2age35l l2age3544 l2age4554 l2age5564 l2age6574 l2age75p l2age35l_male l2age3544_male l2age4554_male l2age5564_male l2age6574_male l2age75p_male
global allvars_hlth male l2age35l l2age3544 l2age4554 l2age5564 l2age6574 l2age75p
* $agerace

*** Binary Health Outcomes ***
	* Mortality
	global allvars_died $novars black hispan male_black male_hispan

	* Mortality of partner/spouse
	takestring, oldlist($allvars_died) newname("allvars_partdied") extlist("l2widowed $agevars $agerace")
	* global allvars_partdied $allvars_partdied black hispan l2age65l l2age6574 l2age75p l2age65l_male l2age6574_male l2age75p_male l2age65l_black l2age6574_black l2age75p_black l2age65l_hispan l2age6574_hispan l2age75p_hispan 	male_l2age65l_black male_l2age6574_black male_l2age75p_black male_l2age65l_hispan male_l2age6574_hispan male_l2age75p_hispan 
	global allvars_partdied $novars


*** Continuous Health Outcomes ***
	* Log BMI
	global allvars_logbmi $novars

*** Ordered Health Outcomes ***
	* ADL status
	global allvars_adlstat $novars
  * IADL status
  global allvars_iadlstat $novars
  * Smoking status
	global allvars_smkstat $novars

  * Number of birth events
	global allvars_births $novars
	global allvars_paternity $novars

*** Binary Econ Outcomes ***
	*global allvars_econ1 $dvars lage35l lage3544 lage4554 lage5564 lage6574 lage75p $lvars_hlth $lvars_econ 
	global allvars_econ1 $novars
	global allvars_econ2 $novars
	
	* mstat_new_5 model isn't converging, so simplifying ...
	global comm  black hispan hsless college l2work l2logiearnx l2loghatotax mthreduc2 mthreduc3 mthreduc4 l2numbiokids1 l2numbiokids2 l2numbiokids3p l2age l2agesq
	
	
	#d;
	global allvars_exitsingle_m 
	l2age3034d l2age3539d l2age4049d l2age5059d l2age6064d l2age65pd 
	;
	global allvars_exitsingle_f
	l2age3034d l2age3539d l2age4049d l2age5059d l2age6064d l2age65pd 
	;
	global allvars_single2married_m 
	l2age3034d l2age3539d l2age4049d l2age5059d l2age6064d l2age65pd 
	;
	global allvars_single2married_f 
	l2age3034d l2age3539d l2age4049d l2age5059d l2age6064d l2age65pd 
	;
	global allvars_exitcohab_m 
	l2age3034d l2age3539d l2age4049d l2age5059d l2age6064d l2age65pd 
	;
	global allvars_exitcohab_f 
	l2age3034d l2age3539d l2age4049d l2age5059d l2age6064d l2age65pd 
	;
	global allvars_cohab2married_m 
	l2age3034d l2age3539d l2age4049d l2age5059d l2age6064d l2age65pd 
	;
	global allvars_cohab2married_f 
	l2age3034d l2age3539d l2age4049d l2age5059d l2age6064d l2age65pd 
	;
	global allvars_exitmarried_m 
	l2age3034d l2age3539d l2age4049d l2age5059d l2age6064d l2age65pd 
	;
	global allvars_exitmarried_f 
	l2age3034d l2age3539d l2age4049d l2age5059d l2age6064d l2age65pd 
	;
	global allvars_married2cohab_m 
	l2age3034d l2age3539d l2age4049d l2age5059d l2age6064d l2age65pd 
	;
	global allvars_married2cohab_f 
	l2age3034d l2age3539d l2age4049d l2age5059d l2age6064d l2age65pd 
	;
	#d cr
	
	
	
	
	* these variables were taken out of the marital status model because they haven't been developed for the simulation yet
	* ed_0 ed_2 ed_3 ed_4 more1mb lsrh lobes_ind lkidsinfu lyrlstst lretired 


global mstat_f1 $novars
global mstat_f2 $novars
global mstat_f3 $novars



/* Selection criteria for models */

local select_died !l2died
local select_partdied l2mstat_new != 1
local select_hearte !died & !l2hearte
local select_stroke !died & !l2stroke
local select_cancre !died & !l2cancre
local select_hibpe !died & !l2hibpe
local select_diabe !died & !l2diabe
local select_lunge !died & !l2lunge
local select_anyhi !died
local select_diclaim !died  
local select_ssiclaim !died
local select_oasiclaim !died & age >= 25
local select_work !died
local select_hicap_nonzero !died 
local select_hicap !died & hicap_nonzero
local select_igxfr_nonzero !died
local select_igxfr !died & igxfr_nonzero
local select_wlth_nonzero !died
local select_adlstat !died & year >= 2005
local select_iadlstat !died & year >= 2005

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
local select_ssiamt !died & ssiclaim == 1 & inrange(age, 18, 65)
local select_ssoasiamt !died & oasiclaim == 1 & year>=2005 & age >= 25
