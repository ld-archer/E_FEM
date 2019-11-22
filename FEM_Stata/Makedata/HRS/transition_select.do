/** \file transition_select.do

Prepare data for transition estimation.

- Sep 6, 2008, remove lag missings for those not interviewed but alive
- Sep 18,2008, allow for receiving SS benefits before age 62 (widowed benefits)
- 9/08/2009 - Removed references to age dummies\
 - Added references to other age variables
- 5/22/2013 - Updated to include cesd variable from HRS

\todo move definition of all these global lists to \ref fem_env.do

*/
  include common.do

* Define the age variable used throughout
local age_var age_iwe

* Prep the unemployment data
tempfile unemployment
infile using $indata/unemployment.dct
save `unemployment'
clear


#d;			
	* Variables to be recoded as "9" if died;
	global ylist1 "hearte stroke cancre hibpe diabe lunge memrye anyhi diclaim ssiclaim ssclaim dbclaim deprsymp painstat
	  nhmliv wlth_nonzero proptax_nonzero smoken work smkstat wtstate adlstat iadlstat
          bpcontrol insulin lungoxy diabkidney chfe alzhe";
	
	* Variables to be recoded as "999" if died ;
	  global ylist2 "loghatotax logiearnx ";
	* Variables to be recoded as missing if died ;
	  global ylist3 "hatota hatotax iearnuc iearnx logbmi igxfr";

#d cr

* cap log close
* log using "transition_select_yh.log", replace

use "$outdata/hrs_selected.dta", clear

merge n:1 year using `unemployment', assert(match using) keep(match) keepusing(unemployment) nogen

/* Create the IADL and ADL Indicator Variables */
gen iadl1 = iadlstat == 2 if !missing(iadlstat)
label var iadl1 "Has exactly 1 IADL"
gen iadl2p = iadlstat==3 if !missing(iadlstat)
label var iadl2p "Has 2 or more IADLs"
gen anyiadl = (iadlstat>1) & !missing(iadlstat)
label var anyiadl "Has any IADLs"

gen adl1 = adlstat == 2 if !missing(adlstat)
label var adl1 "Has exactly 1 ADL"
gen adl2 = adlstat == 3 if !missing(adlstat)
label var adl2 "Has exactly 2 ADLs"
gen adl3p = adlstat == 4 if !missing(adlstat)
label var adl3p "Has 3 or more ADLs"
gen anyadl = (adlstat>1) & !missing(adlstat)
label var anyadl "Has any ADLs"

/* Create the Pain Indicator Variables */
gen painmild = painstat == 2 if !missing(painstat)
label var painmild "Pain mild most of the time"
gen painmoderate = painstat == 3 if !missing(painstat)
label var painmoderate "Pain moderate most of the time"
gen painsevere = painstat == 4 if !missing(painstat)
label var painsevere "Pain severe most of the time"

/* 
Generate dummy for partner death (includes widowhood).
This is only for pooled estimation in the ages 25+ 
(FAM/PSID) simulation.  In HRS, widowed appears to be
equivalent to partdied.  If we derive partdied the
same way as was done for PSID (=widowed or other member 
of household died), there are no additional
cases of partner death beyond what is encoded in widowed.
So, there's nothing special to do here.
*/
gen partdied = widowed


***************************************
* Set up the data
***************************************
xtset hhidpn wave

***************************************
* Keep only those who were interviewed in the first interview for the cohort
***************************************
sort hhidpn wave, stable
by hhidpn: gen firstwave = wave[1]
by hhidpn: gen lastwave = wave[_N]
by hhidpn: gen twave = _N

#d;
drop if (inlist(hacohort,0,3) & firstwave!=1 ) | (inlist(hacohort,1) & firstwave!= 2) |
	(inlist(hacohort,2,4) & firstwave!=4 );
#d cr

drop twave

***************************************
* Keep only those person-waves that do not transition into nonresponse
***************************************
drop if iwstat == 4

***************************************
* Drop those who were interviewed for only one wave
***************************************
tab hacohort

by hhidpn: gen twave = _N
drop if twave == 1
drop twave

tab hacohort

***************************************
* Generate lag conditions, remove invalid missing
***************************************
sort hhidpn wave, stable
foreach v of varlist $timevariant wave $outcomeonly cogstate selfmem proptax proptax_nonzero iadl1 iadl2p adl1 adl2 adl3p {
	qui gen l2`v' = l.`v'
	/* Sep 6, 2008 - drop missings for alive but not interviewed */
	qui drop if missing(l2`v') & iwstat == 4
	local vlb: var label `v'
	label var l2`v' "Two-year lag of `vlb'"
}

***************************************
* Generate initial conditions
***************************************

foreach v of varlist $flist {
	sort hhidpn wave, stable
	by hhidpn: gen f`v' = `v'[1]
	local vlb: var label `v'
	label var f`v' "Init. of `vlb'"
	
	qui count if missing(f`v')
	if r(N) > 0 {
		dis "`v'"
		dis "invalid missing for initial conditions"
		exit (333)
	}
}

********************************************************************************

* For selected, not the first observation
* foreach v in hibpe_treat hibpe_untrt memrye{
foreach v of varlist memrye proptax proptax_nonzero {
	dis "For `v'"
	sort hhidpn wave, stable
	* Non-missing values
	cap drop nmiss tnmiss firstnmiss tfirstnmiss
	by hhidpn: gen nmiss = sum(!missing(l2`v'))
	by hhidpn: gen tnmiss = nmiss[_N]
	by hhidpn: gen firstnmiss = _n if nmiss == 1
	by hhidpn: egen tfirstnmiss =total(firstnmiss)
	cap drop f`v'
	by hhidpn: gen f`v' = l2`v'[tfirstnmiss] if nmiss > 0 
	by hhidpn: replace f`v' = . if tnmiss == 0
	qui count if missing(f`v')
	if r(N) > 0 & !("`v'" == "hibpe_treat" | "`v'" == "hibpe_untrt"  | "`v'" == "memrye" | strmatch("`v'", "*proptax*")){
		dis "`v'"
		dis "invalid missing for initial conditions"
		exit (333)
	}
}
drop nmiss tnmiss firstnmiss tfirstnmiss

***************************************
* Keep only those aged 40 and older in the first wave
***************************************

  tempvar age_min
bys hhidpn (wave): gen `age_min' = `age_var'[1]
keep if `age_min' >= 40 & !missing(`age_min')
drop `age_min'


***************************************
* Correct for data inconsistencies
***************************************
replace fsmoken50 = 0 if fsmokev == 0 & died == 0

replace widowed  = 1 if l2widowed == 1 & died == 0

replace dbclaim = 0 if fanydb == 0

***************************************
* Recoding
***************************************

  /*------ DB pension eligible and not claiming ----- */
    replace dbclaim = 0 if fanydb == 0 & !missing(fanydb)

  /*------ DI benefit age <65  ------- */
    replace diclaim = 0 if `age_var' >=65 & wave == firstwave
	
/*------ Any health insurance age < 65 ------- */
  replace anyhi = 1 if `age_var' >= 65 & wave == firstwave

/*------ memory-disease only available since wave 4------- */
  replace memrye = . if wave == firstwave & wave < 4
  
/*------ Alzheimer's disease only available since wave 10------- */
  replace alzhe = . if wave == firstwave & wave < 10
  
  **replace l2alzhe = 0 if wave==10 & alzhe==1
	
  /*------ cogstate only available since wave 3 ------- */
  replace cogstate = . if wave == firstwave & wave < 3
  
  /*------ Make dummy variables for cogstate ------ */
  tab cogstate, gen(cogstate)
  tab cogstate1 cogstate2, missing
  tab l2cogstate, gen(l2cogstate)
  tab l2cogstate1 l2cogstate2, missing
     label var l2cogstate1 "Two-year lag of demented"
     label var l2cogstate2 "Two-year lag of CIND"
     label var l2cogstate3 "Two-year lag of normal cognition"
     label var cogstate1 "Demented"
     label var cogstate2 "CIND (cog impaired not demented)"
     label var cogstate3 "Normal cognition"
  cap label drop cogstate_lbl
  label define cogstate_lbl 1 "Demented" 2 "Cognitive Impairment, No Dementia" 3 "Normal"
  label values l2cogstate cogstate_lbl
  label values cogstate cogstate_lbl
  
  /*------ self-rating memory status only available since wave 3 ------- */
  replace selfmem = . if wave == firstwave & wave < 3
  
  /*------ Make dummy variables for selfmem ------ */
  tab selfmem, gen(selfmem)
  tab selfmem1 selfmem2, missing
  tab l2selfmem, gen(l2selfmem)
  tab l2selfmem1 l2selfmem2, missing
     label var l2selfmem1 "Two-year lag of good memory"
     label var l2selfmem2 "Two-year lag of fair memory"
     label var l2selfmem3 "Two-year lag of poor memory"
     label var selfmem1 "Good memory"
     label var selfmem2 "Fair memory"
     label var selfmem3 "Poor memory"
  cap label drop selfmem_lbl
  label define selfmem_lbl 1 "Good memory" 2 "Fair memory" 3 "Poor memory"
  label values l2selfmem selfmem_lbl
  label values selfmem selfmem_lbl  


  
	/*------ died in this wave replace with.------- */
	foreach x of varlist $ylist1 $ylist2 $ylist3 {
		replace `x' = . if died == 1
	}

	label var firstwave "First wave of interview"
	label var lastwave "Last wave of interview"

	

	***************************************
	* Save the data
	***************************************
	sort hhidpn wave, stable
	by hhidpn: gen period = _N
	by hhidpn: gen time = _n
	save "$outdata/hrs$firstwave$lastwave.dta", replace

***************************************
* For transition
* drop the first wave
* Beyond the first wave of interview
***************************************
	drop if wave == firstwave
	
	local log_30 = log(30)
	mkspline l2logbmi_l30 `log_30' l2logbmi_30p = l2logbmi
	mkspline flogbmi_l30 `log_30' flogbmi_30p = flogbmi
	mkspline flogbmi50_l30 `log_30' flogbmi50_30p = flogbmi50
	label var l2logbmi_l30 "Splined two-year lag of BMI <= log(30)"
        label var l2logbmi_30p "Splined two-year lag of BMI > log(30)"
        label var flogbmi_l30 "Splined init of BMI <= log(30)"
        label var flogbmi_30p "Splined init of BMI > log(30)"
        label var flogbmi50_l30 "Splined init of BMI age 50 <= log(30)"
        label var flogbmi50_30p "Splined init of BMI age 50 > log(30)"

	global bmivars l2logbmi_l30 l2logbmi_30p flogbmi_l30 flogbmi_30p fbmi50_imp
	
*** GENERATE THE AGE SPLINE VARIABLES
		
	gen l2age6061 = floor(l2`age_var') == 58 | floor(l2`age_var') == 59 if l2`age_var' < .
	gen l2age6263 = inrange(floor(l2`age_var'),60,61) if l2`age_var' < .
	gen l2age64e = floor(l2`age_var') == 62 if l2`age_var' < . 
	gen l2age6566 = floor(l2`age_var') == 63 | floor(l2`age_var') == 64 if l2`age_var' < .
	gen l2age6770 = inrange(floor(l2`age_var'),65,68) if l2`age_var' < . 
	* Bryan's addition to try to improve work transition model
	gen l2age70p = floor(l2`age_var') >= 68 if l2`age_var' < .
	gen l2age5253 = inrange(floor(l2`age_var'),50,51) if l2`age_var' < .
	gen l2age5455 = inrange(floor(l2`age_var'),52,53) if l2`age_var' < .
	gen l2age5657 = inrange(floor(l2`age_var'),54,55) if l2`age_var' < .
	gen l2age5859 = inrange(floor(l2`age_var'),56,57) if l2`age_var' < .
	gen l2age6465 = inrange(floor(l2`age_var'),62,63) if l2`age_var' < .
	gen l2age6667 = inrange(floor(l2`age_var'),64,65) if l2`age_var' < .
	gen l2age6869 = inrange(floor(l2`age_var'),66,67) if l2`age_var' < .

	* binary age dummies for work model should start with odd year
	gen l2agelt51 = floor(l2`age_var') < 49 if l2`age_var' < .	
	gen l2age5152 = inrange(floor(l2`age_var'),49,50) if l2`age_var' < .
	gen l2age5354 = inrange(floor(l2`age_var'),51,52) if l2`age_var' < .
	gen l2age5556 = inrange(floor(l2`age_var'),53,54) if l2`age_var' < .
	gen l2age5758 = inrange(floor(l2`age_var'),55,56) if l2`age_var' < .
	gen l2age5960 = inrange(floor(l2`age_var'),57,58) if l2`age_var' < .
	gen l2age6162 = inrange(floor(l2`age_var'),59,60) if l2`age_var' < .
	gen l2age6364 = inrange(floor(l2`age_var'),61,62) if l2`age_var' < .
	gen l2age6768 = inrange(floor(l2`age_var'),65,66) if l2`age_var' < .
	gen l2age6970 = inrange(floor(l2`age_var'),67,68) if l2`age_var' < .
	gen l2age71p = floor(l2`age_var') >= 69 if l2`age_var' < .	
	
	gen l2age65l  = min(63,l2`age_var') if l2`age_var' < .
        label var l2age65l "Min(63, two-year lag of age)"
	gen l2age6574 = min(max(0,l2`age_var'-63),73-63) if l2`age_var' < .
        label var l2age6574 "Min(Max(0, two-year lag age - 63), 73 - 63)"
	gen l2age75l = min(l2`age_var', 73) if l2`age_var' < .
        label var l2age75l "Min(73, two-year lag of age)"
	gen l2age75p = max(0, l2`age_var'-73) if l2`age_var' < .
        label var l2age75p "Max(0, two-year lag age - 73)"

	gen l2age62e = floor(l2`age_var') == 60 if l2`age_var' < .
	gen l2age63e = floor(l2`age_var') == 61 if l2`age_var' < .

*** Generate age spline for Alzhe model

     
  gen l2age70l = min(l2`age_var', 68) if l2`age_var' < .
        label var l2age70l "Min(68, two-year lag of age)"
  gen l2age7074 = min(max(0,l2`age_var'-68),73-68) if l2`age_var' < .
        label var l2age7074 "Min(Max(0, two-year lag age - 68), 78 - 68)"
  gen l2age7579 = min(max(0,l2`age_var'-73),78-73) if l2`age_var' < .
        label var l2age7579 "Min(Max(0, two-year lag age - 68), 78 - 68)"
  gen l2age80p = max(0, l2`age_var'-78) if l2`age_var' < .
        label var l2age80p "Max(0, two-year lag age - 78)"  

	mkspline l2a6 58 l2a7 73 l2a7p = l2`age_var'

	gen logdeltaage = log(`age_var' - l2`age_var')
        label var logdeltaage "Log of years between current interview and previous"

	gen agesq = age_yrs*age_yrs
        gen l2agesq = l2`age_var' * l2`age_var'
   gen l2age65 = l2`age_var' - 65
   gen l2age65sq = l2age65 * l2age65
				label var l2age65 "Lag of age - 65"
				label var l2age65sq "Lag of (age - 65) squared"
				
// Interactions from disparities project
local lab1: var label male
foreach v of varlist hsless black hispan {
  local lab2: var label `v'
  gen male_`v' = male * `v'
  label var male_`v' "`lab1' AND `lab2'"
}

*** GENERATE WEAVE DUMMIES
	gen w3 = wave == 3
	gen w4 = wave == 4
	gen w5 = wave == 5
	gen w6 = wave == 6
	gen w7 = wave == 7
** add waves 8 and 9 for validation
	gen w8 = wave == 8
	gen w9 = wave == 9
	gen w10 = wave == 10
	gen w11 = wave == 11
	gen w12 = wave == 12

*** DERIVE ANY NEEDED COVARIATES FOR TRANSFERS MODELS
egen numdisease = rowtotal(hearte stroke cancre hibpe diabe lunge)
egen l2numdisease = rowtotal(l2hearte l2stroke l2cancre l2hibpe l2diabe l2lunge)
gen l2adl1p = l2adl1 | l2adl2 | l2adl3p
gen l2iadl1p = l2iadl1 | l2iadl2p
gen tcamt_cpl = htcamt / (married + 1)
gen l2tcamt_cpl = l2htcamt / (l2married + 1)
egen ihs_tcamt_cpl = h(tcamt_cpl)
gen l2hatota_cpl = l2hatota / (l2married + 1)
egen l2ihs_hwealth_cpl = h(l2hatota_cpl)
gen l2hicap_cpl = l2hicap / (l2married + 1)
egen l2ihs_hicap_cpl = h(l2hicap_cpl)

***Interaction for alzhe model */
	gen hibp_stroke = hibpe * stroke 
  gen l2hibp_stroke = l2hibp * l2stroke



	* Generate variable reflecting Social Security normal retirement age based on birth year
	gen ss_nra = .
	replace ss_nra = 65 if rbyr <= 1937
	replace ss_nra = 65 + 2/12 if rbyr == 1938
	replace ss_nra = 65 + 4/12 if rbyr == 1939
	replace ss_nra = 65 + 6/12 if rbyr == 1940
	replace ss_nra = 65 + 8/12 if rbyr == 1941
	replace ss_nra = 65 + 10/12 if rbyr == 1942
	replace ss_nra = 66 if rbyr >= 1943 & rbyr < 1955
	replace ss_nra = 66 + 2/12 if rbyr == 1955
	replace ss_nra = 66 + 4/12 if rbyr == 1956
	replace ss_nra = 66 + 6/12 if rbyr == 1957
	replace ss_nra = 66 + 8/12 if rbyr == 1958
	replace ss_nra = 66 + 10/12 if rbyr == 1959
	replace ss_nra = 67 if rbyr >= 1960	
	
	gen yrs_to_nra = ss_nra - `age_var'
	gen nra_elig = (`age_var' - ss_nra >= 0)
	
		* Years to NRA dummy variables 
	gen nraplus10 	= (yrs_to_nra >= 10 )
	gen nraplus9 		= (yrs_to_nra >= 9 & yrs_to_nra < 10)
	gen nraplus8 		= (yrs_to_nra >= 8 & yrs_to_nra < 9)
	gen nraplus7 		= (yrs_to_nra >= 7 & yrs_to_nra < 8)
	gen nraplus6 		= (yrs_to_nra >= 6 & yrs_to_nra < 7)
	gen nraplus5 		= (yrs_to_nra >= 5 & yrs_to_nra < 6)
	gen nraplus4 		= (yrs_to_nra >= 4 & yrs_to_nra < 5)
	gen nraplus3 		= (yrs_to_nra >= 3 & yrs_to_nra < 4)
	gen nraplus2 		= (yrs_to_nra >= 2 & yrs_to_nra < 3)
	gen nraplus1 		= (yrs_to_nra >= 1 & yrs_to_nra < 2)
	gen nraplus0		=	(yrs_to_nra > 0 & yrs_to_nra < 1)
	gen nramin0 		= (yrs_to_nra > -1 & yrs_to_nra <= 0)
	gen nramin1 		= (yrs_to_nra > -2 & yrs_to_nra <= -1)
	gen nramin2 		= (yrs_to_nra > -3 & yrs_to_nra <= -2)
	gen nramin3 		= (yrs_to_nra > -4 & yrs_to_nra <= -3)
	gen nramin4 		= (yrs_to_nra > -5 & yrs_to_nra <= -4)
	gen nramin5 		= (yrs_to_nra > -6 & yrs_to_nra <= -5)
	gen nramin6 		= (yrs_to_nra > -7 & yrs_to_nra <= -6)
	gen nramin7 		= (yrs_to_nra > -8 & yrs_to_nra <= -7)
	gen nramin8 		= (yrs_to_nra > -9 & yrs_to_nra <= -8)
	gen nramin9 	 	= (yrs_to_nra > -10 & yrs_to_nra <= -9)
	gen nramin10 		= (yrs_to_nra <= -10)

	gen nramin5l 		= (yrs_to_nra <= -5)
	gen nraplus3p		= (yrs_to_nra >= 3 )
	
	
	* age to eea dummies for diclaim model 
	gen yrs_to_eea = 62 - `age_var'

	gen eeaplus3p 	= (yrs_to_eea >= 3 )
	gen eeaplus2 		= (yrs_to_eea >= 2 & yrs_to_eea < 3)
	gen eeaplus1 		= (yrs_to_eea >= 1 & yrs_to_eea < 2)
	gen eeaplus0		=	(yrs_to_eea > 0 & yrs_to_eea < 1)
	gen eeamin0 		= (yrs_to_eea > -1 & yrs_to_eea <= 0)
	gen eeamin1 		= (yrs_to_eea > -2 & yrs_to_eea <= -1)
	gen eeamin2l 		= (yrs_to_eea <= -2)	
	
	gen at_eea = (`age_var' >= 62 & `age_var' < 64)
	gen at_nra = (yrs_to_nra <= 0 & yrs_to_nra > -2)
	
	gen yrs_before_nra = max(yrs_to_nra,0)
	gen yrs_after_nra = max(-yrs_to_nra,0)

	label var at_eea "Respondent is at the EEA age (62) or up to two years older"
	label var at_nra "Respondent is at their NRA age or two years older"
	label var yrs_before_nra "Years to NRA for those not year at NRA"
	label var yrs_after_nra "Years past NRA for those older than NRA"

* Interactions for hearta model
foreach var in time_lhearta black hispan hsless college male male_hsless male_black male_hispan l2age65l l2age6574 l2age75p l2hibpe l2diabe l2smoken l2widowed l2hearta fstrok50 fcanc50 fhibp50 fdiabe50 flung50 fheart50 fsmokev fsmoken50 l2logbmi_l30 l2logbmi_30p logdeltaage {
	gen `var'_l2heartae = `var' * l2heartae
}	
	
** Recode the Stop and Start drug treatment

foreach x of varlist rxchol {

gen `x'_start = (`x' == 1 & l2`x' == 0)
gen `x'_stop = (`x' == 0 & l2`x' == 1)	

label var `x'_start "Started `x'"
label var `x'_stop "Stopped `x'"

}

***************************************
* Save data for transition model
***************************************
  local fname = "$outdata/hrs$firstwave$lastwave" + "_transition.dta"
	save `fname', replace

