/** \dir Makedata/HRS This directory holds all the code used in processing the RAND HRS and the HRS Fat Files into simulation inputs.

\todo validation test: make sure oprobit dummies add to 100% exactly

*/

  /** \file gen_analytic_file.do
Select variables and reshape data from wide to long format and recode

\section hist Limited Version History
- 04/12/2009 - To be run from ZENO
 - To be included in gen_main.do
- 08/24/2009 - don't drop those who were alive but not interviewed (iwstat=4) - line 443 commented out. - NOT DONE
- 09/06/2009 - don't drop those who were alive but not interviewed (iwstat = 4)
- 09/14/2009 - for OASI, set the minimum of widower's benefits to be 50 and not 62
- 09/08/2009 - Changing path name for HRS data be seperate global
           - Keeping RABMONTH RABYEAR and RwAGEM_E/12 for Age (instead of RwAGEY_B)
           - Replaced all iwyear`i'- rabyear style age calculations with RwAGEY_E or RwAGEM_E/12
           - Add variable RwIWDELTA = # years since last interview = (RwIWBEG - R[w-1]IWBEG)/365.25
- 02/01/2012 - Bryan Tysinger - Adding transfers from parents to children from the HRS data, keeping the couple flag
- 02/07/2012 - BT - Incorporating imputed helper hours file.
- 5/18/2012 - BT - Incorporating volunteer hours and grandkid help hours
- 5/22/2013 - Updated to include cesd variable from HRS
- 6/17/2014 - Updated to Rand HRS version M
- 2/15/2015 - Updated to Rand HRS version N
              Incoporate the changes in HRSFAM.C data, including the parhelp, transferkids, gkidcare, volunteer, property tax
              Memory-related disease doesn't have wave 10 & 11, recode the memrye by r10alzhe r11alzhe r10demen r11demen 
- 12/22/2015 - Henu Zhao - added in-home health care variable from RAND HRS(r*homcar), added assisted living variables from HRS

*/
include common.do
include fatvars.do


* seed for hotdecking
local seed 14353

*** USE HRS AND KEEP SELECTED VARIABLES
	use $rand_hrs, clear
** changes with version m
** drop r*totmd (imputed total medical expenditures)
** equivalent of llb018 (number of close friends) is not available on fat file but is on the 2010 LB questionnaire. not documented as change in hrs documentation
** equivalent of llb020* (A-K aspects of life) is not available on fat file but is on the 2010 LB questionnaire. not documented as change in hrs documentation
** one income/wealth file
** add temp variables that are blank for fam file variables
** fvars at 50 changes

***Changes with version n


#d;
	keep 
	rahrsamp raahdsmp racohbyr hacohort h*hhid hhidpn r*wtresp r*wtcrnh r*wtr_nh r*wthh r*iwbeg rabyear rabmonth
	rabplace rahispan ragender raracem raeduc r*agey_e r*agem_e r*cenreg r*iwstat r*mstat 
	r*bmi r*smokev r*smoken 
	r*cancre r*hearte r*heartf r*hibpe r*diabe r*lunge r*stroke
	r*adla r1iadlww r1adlw r*iadla r*nrshom r*nhmliv r*shlt r*hosp r*homcar
	r*govmd r*govmr r*higov r*covr r*covs r*covrt r*hiothp r*hiltc r*lifein 
	r*oopmd r*doctim r*hsptim r*hspnit
	r*sayret r*lbrf r*work
	r*dstat
	r*cesd r*cesdm r*proxy
	r*issdi r*isdi r*issi 
 	r*iearn r*isret r*ipena r*iunwc r*igxfr
        r*flone r*psyche r*arthre
        r*bathh r*dressh r*walkrh
  r7jlocc r7jlocca r7jlind
 
 	h*icap h*iothr h*itot
	h*atoth h*anethb 
	h*atotf h*astck h*achck h*acd h*abond h*aothr
	h*arles h*atran h*absns h*aira 
	h*atota h*atotb h*atotn
	h*amort h*ahmln h*amrtb h*adebt
        h*cpl
	h*child
	s*iwstat s*agey_e s*agem_e s*hhidpn s*wtresp s*wtcrnh s*wtr_nh s*gender s*mstat s*racem s*hispan s*educ
	r*memrye r*alzhe r*demen
        r*igxfr
	r*jcten r*toilta 
	r*jcpen  r*peninc 
	r*jyears
	raedyrs	
	rameduc
	rafeduc
	;
#d cr 

/* Merge in the Harmonized HRS variables */
  merge 1:1 hhidpn using $harmonized_hrs, keep(master match) keepusing(`harmvars') nogen

*** ------------------------------------------

*Recode memrye for wave 10 and 11

generate r10memrye=.
replace r10memrye=1 if r10alzhe==1 | r10demen==1 
replace r10memrye=0 if r10alzhe==0 & r10demen==0
replace r10memrye=.d if r10alzhe==.d & r10demen==.d
replace r10memrye=.r if r10alzhe==.r & r10demen==.r

generate r11memrye=.
replace r11memrye=1 if r11alzhe==1 | r11demen==1
replace r11memrye=0 if r11alzhe==0 & r11demen==0
replace r11memrye=.d if r11alzhe==.d & r11demen==.d
replace r11memrye=.r if r11alzhe==.r & r11demen==.r

generate r12memrye=.
replace r12memrye=1 if r12alzhe==1 | r12demen==1
replace r12memrye=0 if r12alzhe==0 & r12demen==0
replace r12memrye=.d if r12alzhe==.d & r12demen==.d
replace r12memrye=.r if r12alzhe==.r & r12demen==.r

tab r9memrye, m
tab r10memrye, m
tab r11memrye, m
tab r12memrye, m

*Oct 2016 - comment out this section because the new HRS file has the weights redefined 
/* Merge with nursing home weights from the HRS tracker file.  Currently defined for waves 5-10, we zeroed out waves 1-4 and wave 11.  Variables are of the form r*weightnh
merge 1:1 hhidpn using $outdata/nh_weights.dta
tab _merge 
drop _merge
*/

*Oct 2016 - three types of weights are available now
*wtresp is the person level weight
*wtr_nh is the nurshing home resident analysis weight, not available for wave 1-4    
*wtcrnh is the combined respondent weight and nursing home resident weight
*we will also genrate the nursing home weights here

forvalues i = 1/4 {
	gen r`i'weightnh = 0
}

*Oct 2016 - the nursing home weights for wave 12 is not available yet. 
forvalues i = 5/11 {
	gen r`i'weightnh = r`i'wtr_nh 
}
gen r12weightnh = 0 

*** MERGE with processed variables from Shawn 
	* DB pension entitlement (current and past) and claiming
	* SS claiming
	* labor force variable

  gen anydb = . 
	label var anydb "Any DB entitlement from current job"	
	gen anydb_p = .
	label var anydb_p "Any DB entitlement from past job"
	
	/* ----------HRS cohort ------------*/
	merge hhidpn using "$hrs_sensitive/dbpen_hrs.dta", sort
  replace anydb = dbentitle_c1   == 1 if _merge == 3& !missing(dbentitle_c1) & r1iwstat == 1 
	replace anydb_p = dbentitle_p1 == 1 if _merge == 3 & !missing(dbentitle_p1)& r1iwstat == 1
	drop dbclaim*
  local dbwv = min($lastwave,$hrskeepwv)	
	forvalues i = $firstwave/`dbwv'{
		gen dbclaim`i' = dbentitle_c`i' == 2 if _merge == 3& !missing(dbentitle_c`i') & r`i'iwstat==1
	}
	
	drop dbentitle* _merge

	/* ----------WB cohort ------------*/	
	merge hhidpn using "$hrs_sensitive/dbpen_wb.dta", sort
	
  replace anydb = dbentitle_c4 == 1 if _merge == 3 & !missing(dbentitle_c4)& r4iwstat == 1 
	replace anydb_p = dbentitle_p4 == 1 if _merge == 3 & !missing(dbentitle_p4)& r4iwstat == 1
  local firstWB = max(4,$firstwave)
	forvalues i = `firstWB'/`dbwv' {
		replace dbclaim`i' = dbentitle_c`i' == 2 if _merge == 3& !missing(dbentitle_c`i')& r`i'iwstat==1
	}
  	
	drop dbentitle* _merge
	
	/* ----------EBB cohort ------------*/
	merge hhidpn using "$hrs_sensitive/dbpen_ebb.dta", sort	

  replace anydb = dbentitle_c7 == 1 if _merge == 3 & !missing(dbentitle_c7) & r7iwstat==1 
	replace anydb_p = dbentitle_p7 == 1 if _merge == 3 & !missing(dbentitle_p7)& r7iwstat==1
  local firstEBB = max(7,$firstwave)
	forvalues i = `firstEBB'/`dbwv'{
		replace dbclaim`i' = dbentitle_c`i' == 2 if _merge == 3& !missing(dbentitle_c`i') & r`i'iwstat ==1
	}	
   
	drop dbentitle* _merge

*** Recoded lbrf variable		
	merge hhidpn using "$indata/lbrf.dta", keep(hhidpn r*lbrf) sort
	tab _merge
	drop if _merge == 2
	drop _merge
	
*** SS claiming
	merge hhidpn using "$indata/ssretclaim.dta", sort
	tab _merge
	drop if _merge == 2
	drop _merge
	
*** MERGE with imputed pension wealth data
	merge hhidpn using "$indata/ipw.dta", keep(hhidpn EAGE*X NAGE*X DC*) sort
	tab _merge
	drop if _merge == 2
	drop _merge

*** MERGE with Fat Files for Social Health and other risk factor variables
*** Use symbolic link to avoid changing the code when new revisions need to be used

/* Get all the IADL help variables we need:
Skip patterns are somewhat complex - individuals in nursing home are not asked the "help" questions
For our current purposes (mapping MEPS EQ5D to HRS), we ignore those in nursing homes

										any diff	would you?	why don't		any help
1998	meals 				f2562 								f2564 			f2565		
			grocery				f2567									f2569				f2570		
			phone					f2572									f2574				f2575					
			medication		f2577			f2578				f2579				f2580

2000	meals 		  	g2860									g2862				g2863		
			grocery				g2865									g2867				g2868		
			phone					g2870									g2872				g2873		
			medication 		g2875			g2876				g2877				g2878

2002	meals 		  	hg041									hg042				hg043		
			grocery				hg044									hg045				hg046		
			phone					hg047									hg048				hg049		
			medication 		hg050			hg051				hg052				hg053

2004	meals 		  	jg041									jg042				jg043
			grocery				jg044									jg045				jg046
			phone					jg047									jg048				jg049
			medication 		jg050			jg051				jg052				jg053

2006	meals 		  	kg041									kg042				kg043
			grocery				kg044									kg045				kg046
			phone					kg047									kg048				kg049
			medication 		kg050			kg051				kg052				kg053

2008	meals 		  	lg041									lg042				lg043
			grocery				lg044									lg045				lg046
			phone					lg047									lg048				lg049
			medication 		lg050			lg051				lg052				lg053

hg041	hg042	hg043 hg044	hg045	hg046 hg047	hg048	hg049 hg050	hg051	hg052	hg053

jg041	jg042	jg043 jg044	jg045	jg046 jg047	jg048	jg049 jg050	jg051	jg052	jg053

kg041	kg042	kg043 kg044	kg045	kg046 kg047	kg048	kg049 kg050	kg051	kg052	kg053

lg041	lg042	lg043 lg044	lg045	lg046 lg047	lg048	lg049 lg050	lg051	lg052	lg053

2010 - MG041	MG042	MG043 MG044	MG045	MG046 MG047	MG048	MG049 MG050	MG051	MG052	MG053

2012 - ng041	ng042	ng043 ng044	ng045	ng046 ng047	ng048	ng049 ng050	ng051	ng052	ng053

2014 - og041 og042 og043 og044 og045 og046 og047 og048 og049 og050 og051 og052 og053

*/

merge 1:1 hhidpn using $hrs92, keep(master match) keepusing(`hrs1fat') nogen
merge 1:1 hhidpn using $hrs93, keep(master match) keepusing(`ahd1fat') nogen
merge 1:1 hhidpn using $hrs94, keep(master match) keepusing(`hrs2fat') nogen
merge 1:1 hhidpn using $hrs95, keep(master match) keepusing(`ahd2fat') nogen
merge 1:1 hhidpn using $hrs96, keep(master match) keepusing(`wave3fat') nogen
merge 1:1 hhidpn using $hrs98, keep(master match) keepusing(`wave4fat') nogen
merge 1:1 hhidpn using $hrs00, keep(master match) keepusing(`wave5fat') nogen
/* Read version c, newer than a. Versin c has 2 less individuals hhidpn=22965040 and 22965041;
*** (dropped because of missing values?) The count on the HRS website corresponds to version a.;
*** Difference between versions c and d is on the coding of unknown or refused response (adds more 9s at the beggining) ;
*** Version a has a set of duplicate variables (same name preceded by "_" doing the same thing: adjusting the length of ;
*** the variable by adding or dropping an 9 when unknown or missing answer;
*/
merge 1:1 hhidpn using $hrs02, keep(master match) keepusing(`wave6fat') nogen
merge 1:1 hhidpn using $hrs04, keep(master match) keepusing(`wave7fat') nogen
merge 1:1 hhidpn using $hrs06, keep(master match) keepusing(`wave8fat') nogen
merge 1:1 hhidpn using $hrs08, keep(master match) keepusing(`wave9fat') nogen
merge 1:1 hhidpn using $hrs10, keep(master match) keepusing(`wave10fat') nogen
merge 1:1 hhidpn using $hrs12, keep(master match) keepusing(`wave11fat') nogen
merge 1:1 hhidpn using $hrs14, keep(master match) keepusing(`wave12fat') nogen


/*Merge in self-employment income from income files */
merge 1:1 hhidpn using $hrsfat/incwlth_p, keep(master match) keepusing(r*isemp r*iosemp r*ioss r*iosdi r*iossi) nogen

/* Generate the alcohol variables */
forvalues x = 4/$lastwave {
	tokenize `r`x'alcohol'
	gen r`x'binge = .
	* Have a value from number of days in past three months question
	replace r`x'binge = `4' if inrange(`4',0,97)
	* Assign a zero if non-drinker
	replace r`x'binge = 0 if `1' == 5
	* Assign a zero for a never-drinker
	replace r`x'binge = 0 if `1' == 3
	* Those with 0 days per week drinking are not asked binge question
	replace r`x'binge = 0 if `2' == 0
}

* Won't use before wave 4
gen r1binge = -333
gen r2binge = -333
gen r3binge = -333



/* Code IADL help variables */
forvalues x = 1/$lastwave {
	gen r`x'iadlhelp = .
}

* Won't use before wave 4
replace r1iadlhelp = -333
replace r2iadlhelp = -333
replace r3iadlhelp = -333

*** Code wave-specific iadlhelp based on skip patterns ***
forvalues x = 4/$lastwave {
	gen r`x'mealshelp = .
	gen r`x'groceryhelp = .
	gen r`x'phonehelp = .
	gen r`x'medicationhelp = .
}

forvalues x = 4/$lastwave {
	foreach y in meals grocery phone medication {
		if inlist("`y'","meals","grocery","phone") {
			tokenize `r`x'`y''
			di "`1' `2' `3'"
			replace r`x'`y'help = 0 if `1' == 5
			replace r`x'`y'help = 0 if (`1' == 6 | `1' == 7) & (`2' == 5) 
			replace r`x'`y'help = 0 if `3' == 5
			replace r`x'`y'help = 1 if `3' == 1		
		}
		if inlist("`y'","medication") {
			tokenize `r`x'`y''
			di "`1' `2' `3' `4'"
			replace r`x'`y'help = 0 if `1' == 5
			replace r`x'`y'help = 0 if `1' == 7 & `2' == 5
			replace r`x'`y'help = 0 if `1' == 7 & `2' == 1 & `3' == 5
			replace r`x'`y'help = 0 if `4' == 5
			replace r`x'`y'help = 1 if `4' == 1
		}
	}
	* Fill in any zeroes we can
	replace r`x'iadlhelp = 0 if !missing(r`x'mealshelp)
	replace r`x'iadlhelp = 0 if !missing(r`x'groceryhelp)
	replace r`x'iadlhelp = 0 if !missing(r`x'phonehelp)
	replace r`x'iadlhelp = 0 if !missing(r`x'medicationhelp)
	* Fill in the ones
	replace r`x'iadlhelp = 1 if r`x'mealshelp == 1
	replace r`x'iadlhelp = 1 if r`x'groceryhelp == 1
	replace r`x'iadlhelp = 1 if r`x'phonehelp == 1
	replace r`x'iadlhelp = 1 if r`x'medicationhelp == 1
}
* Clean up unneeded variables
drop r*mealshelp r*groceryhelp r*phonehelp r*medicationhelp
sum r*iadlhelp

* Life satisfaction - only asked for wave 9 and later
forvalues wv = 1/$lastwave {
	gen r`wv'satisfaction = .
	if `wv' < 9 {
		replace r`wv'satisfaction = -999
	}
}
replace r9satisfaction = lb000
replace r10satisfaction = MB000
replace r11satisfaction = nb000
replace r12satisfaction = ob000


* get preload variable for wave 8-12
preserve

use `hrspub'/Stata/h06pr_h, clear
gen h8hhid=HHID+KSUBHH
destring h8hhid, replace
ren *, lower
tempfile h06pr_h
save `h06pr_h', replace

use `hrspub'/Stata/h08pr_h, clear
gen h9hhid=HHID+LSUBHH
destring h9hhid, replace
ren *, lower
tempfile h08pr_h
save `h08pr_h', replace

use `hrspub'/Stata/h10pr_h, clear
gen h10hhid=HHID+MSUBHH
destring h10hhid, replace
ren *, lower
tempfile h10pr_h
save `h10pr_h', replace

use `hrspub'/Stata/h12pr_h, clear
ren *, lower
gen h11hhid=hhid+nsubhh
destring h11hhid, replace
tempfile h12pr_h
save `h12pr_h', replace

use `hrspub'/Stata/h14pr_h, clear
gen h12hhid=hhid+osubhh
destring h12hhid, replace
ren *, lower
tempfile h14pr_h
save `h14pr_h', replace

restore

merge m:1 h8hhid using `h06pr_h', keep(master match) keepusing(kz089) nogen

merge m:1 h9hhid using `h08pr_h', keep(master match) keepusing(lz089) nogen

merge m:1 h10hhid using `h10pr_h', keep(master match) keepusing(mz089) nogen

merge m:1 h11hhid using `h12pr_h', keep(master match) keepusing(nz089) nogen

merge m:1 h12hhid using `h14pr_h', keep(master match) keepusing(oz089) nogen
 

/* Code assisted living variables*/

forvalues x = 1/$lastwave {
	gen r`x'retirecomm = .
	gen r`x'retirecomm_continue = .
	gen r`x'key_serv = .
	gen r`x'other_serv = .
	gen r`x'key_serv_use = .
	gen r`x'other_serv_use = .	
	gen r`x'serv = .
	gen r`x'serv_use = .
}

forvalues x = 1/3 {
	replace r`x'retirecomm = -333
	replace r`x'retirecomm_continue = -333
	replace r`x'key_serv = -333
	replace r`x'other_serv = -333
	replace r`x'key_serv_use = -333
	replace r`x'other_serv_use = -333
	replace r`x'serv = -333	
	replace r`x'serv_use = -333

}

local r4retire f2840 
local r4retire_p f306
local r4move f56
local r4groupmeal f2857
local r4key_serv f2857, f2869, f2877, f2887, f2888
local r4other_serv f2861, f2865
local r4key_serv_use f2859, f2871, f2879, f2891
local r4other_serv_use f2863, f2867
local r4retirecomm_continue f2892
local r4farm f2741
local r4mobile f2742
local r4together f521

local r5retire g3158 
local r5retire_p g306
local r5move g56
local r5groupmeal g3175
local r5key_serv g3175, g3187, g3195, g3205, g3206
local r5other_serv g3179, g3183
local r5key_serv_use g3177, g3189, g3197, g3209
local r5other_serv_use g3181, g3185
local r5retirecomm_continue g3210
local r5farm g3059
local r5mobile g3060
local r5together g562
 
local r6retire hh101 
local r6retire_p hz144
local r6move hx033
local r6groupmeal hh115
local r6key_serv hh115, hh124, hh127, hh130, hh131
local r6other_serv hh118, hh121
local r6key_serv_use hh117, hh126, hh129, hh133
local r6other_serv_use hh120, hh123
local r6retirecomm_continue hh134
local r6farm hh001
local r6mobile hh002
local r6together ha030

local r7retire jh101 
local r7retire_p jz144
local r7move jx033
local r7groupmeal jh115
local r7key_serv jh115, jh124, jh127, jh130, jh131
local r7other_serv jh118, jh121
local r7key_serv_use jh117, jh126, jh129, jh133
local r7other_serv_use jh120, jh123
local r7retirecomm_continue jh134
local r7farm jh001
local r7mobile jh002
local r7together ja030

local r8retire kh101
local r8retire_p kz089 
local r8move kx033
local r8groupmeal kh115
local r8key_serv kh115, kh124, kh127, kh130, kh131
local r8other_serv kh118, kh121
local r8key_serv_use kh117, kh126, kh129, kh133
local r8other_serv_use kh120, kh123
local r8retirecomm_continue kh134
local r8farm kh001
local r8mobile kh002
local r8together ka030

local r9retire lh101 
local r9retire_p lz089
local r9move lx033
local r9groupmeal lh115
local r9key_serv lh115, lh124, lh127, lh130, lh131
local r9other_serv lh118, lh121
local r9key_serv_use lh117, lh126, lh129, lh133
local r9other_serv_use lh120, lh123
local r9retirecomm_continue lh134
local r9farm lh001
local r9mobile lh002
local r9together la030

local r10retire MH101
local r10retire_p mz089 
local r10move MX033
local r10groupmeal MH115
local r10key_serv MH115, MH124, MH127, MH130, MH131
local r10other_serv MH118, MH121
local r10key_serv_use MH117, MH126, MH129, MH133
local r10other_serv_use MH120, MH123
local r10retirecomm_continue MH134
local r10farm MH001
local r10mobile MH002
local r10together MA030

local r11retire nh101
local r11retire_p nz089 
local r11move nx033
local r11groupmeal nh115
local r11key_serv nh115, nh124, nh127, nh130, nh131
local r11other_serv nh118, nh121
local r11key_serv_use nh117, nh126, nh129, nh133
local r11other_serv_use nh120, nh123
local r11retirecomm_continue nh134
local r11farm nh001
local r11mobile nh002
local r11together na030

local r12retire oh101
local r12retire_p oz089 
local r12move ox033
local r12groupmeal oh115
local r12key_serv oh115, oh124, oh127, oh130, oh131
local r12other_serv oh118, oh121
local r12key_serv_use oh117, oh126, oh129, oh133
local r12other_serv_use oh120, oh123
local r12retirecomm_continue oh134
local r12farm oh001
local r12mobile oh002
local r12together oa030


forvalues x = 4/$lastwave {
	local y = `x' - 1

	replace r`x'retirecomm = 1 if inlist(`r`x'retire',1,2,7)|(`r`x'retire_p'== 1 & `r`x'move'== 5) 
	replace r`x'retirecomm = 1 if r`y'retirecomm == 1 & `r`x'move'== 5	
	replace r`x'retirecomm = 0 if `r`x'retire' == 5	
	replace r`x'retirecomm = 0 if `r`x'retire_p' == 5 & `r`x'move'== 5 & mi(r`x'retirecomm)
	replace r`x'retirecomm = 0 if r`y'retirecomm == 0 & `r`x'move'== 5 & mi(r`x'retirecomm)
	replace r`x'retirecomm = 0 if `r`x'groupmeal' == 3
	replace r`x'retirecomm = 0 if (`r`x'farm' == 1 | `r`x'mobile' == 1) & mi(r`x'retirecomm)

	replace r`x'retirecomm_continue = 1 if `r`x'retirecomm_continue'== 1
	replace r`x'retirecomm_continue = 0 if `r`x'retirecomm_continue'== 5

	replace r`x'key_serv = 1 if inlist(1, `r`x'key_serv')
	replace r`x'other_serv = 1 if inlist(1, `r`x'other_serv')
	replace r`x'serv = 1 if r`x'key_serv == 1 | r`x'other_serv == 1

	replace r`x'retirecomm = 1 if r`x'serv == 1 

	replace r`x'key_serv_use = 1 if inlist(1, `r`x'key_serv_use')
	replace r`x'other_serv_use = 1 if inlist(1, `r`x'other_serv_use')
	replace r`x'serv_use = 1 if r`x'key_serv_use ==1 | r`x'other_serv_use ==1

	replace r`x'key_serv = 0 if mi(r`x'key_serv) & !mi(r`x'retirecomm)
	replace r`x'other_serv = 0 if mi(r`x'other_serv) & !mi(r`x'retirecomm)
	replace r`x'serv = 0 if mi(r`x'serv) & !mi(r`x'retirecomm)
	replace r`x'key_serv_use = 0 if mi(r`x'key_serv_use) & !mi(r`x'retirecomm)
	replace r`x'other_serv_use = 0 if mi(r`x'other_serv_use) & !mi(r`x'retirecomm)
	replace r`x'serv_use = 0 if mi(r`x'serv_use) & !mi(r`x'retirecomm)

}

* use future wave to fill in current assisted living status if the respondent didn't move between the two waves

forvalues x = 11(-1)4 {
	local y = `x' + 1
	replace r`x'retirecomm = r`y'retirecomm if mi(r`x'retirecomm) & `r`y'move' == 5
	}

* use spouse information to fill in current assisted living status if they live together

forvalues x = 4/$lastwave {
	replace h`x'hhid = floor(hhidpn/100) if mi(h`x'hhid)
	bys h`x'hhid: egen temp = max(r`x'retirecomm) if `r`x'together'==1
	replace r`x'retirecomm = temp if mi(r`x'retirecomm)
	drop temp
	}

/*
forvalues x = 8/$lastwave {
	local y = `x' - 1
	replace r`x'retirecomm = 1 if inlist(`r`x'retire',1,2,7)
	replace r`x'retirecomm = 1 if r`y'retirecomm == 1 & `r`x'move'== 5
	replace r`x'retirecomm = 0 if `r`x'retire' == 5
	replace r`x'retirecomm = 0 if r`y'retirecomm == 0 & `r`x'move'== 5
	replace r`x'retirecomm = 0 if `r`x'groupmeal' == 3
	replace r`x'retirecomm = 0 if (`r`x'farm' == 1 | `r`x'mobile' == 1) & mi(r`x'retirecomm)

	replace r`x'retirecomm_continue = 1 if `r`x'retirecomm_continue'== 1
	replace r`x'retirecomm_continue = 0 if `r`x'retirecomm_continue'== 5

	replace r`x'key_serv = 1 if inlist(1, `r`x'key_serv')
	replace r`x'other_serv = 1 if inlist(1, `r`x'other_serv')
	replace r`x'serv = 1 if r`x'key_serv == 1 | r`x'other_serv == 1

	replace r`x'retirecomm = 1 if r`x'serv == 1

	replace r`x'key_serv_use = 1 if inlist(1, `r`x'key_serv_use')
	replace r`x'other_serv_use = 1 if inlist(1, `r`x'other_serv_use')
	replace r`x'serv_use = 1 if r`x'key_serv_use ==1 | r`x'other_serv_use ==1

	replace r`x'key_serv = 0 if mi(r`x'key_serv) & !mi(r`x'retirecomm)
	replace r`x'other_serv = 0 if mi(r`x'other_serv) & !mi(r`x'retirecomm)
	replace r`x'serv = 0 if mi(r`x'serv) & !mi(r`x'retirecomm)
	replace r`x'key_serv_use = 0 if mi(r`x'key_serv_use) & !mi(r`x'retirecomm)
	replace r`x'other_serv_use = 0 if mi(r`x'other_serv_use) & !mi(r`x'retirecomm)
	replace r`x'serv_use = 0 if mi(r`x'serv_use) & !mi(r`x'retirecomm)
}
*/		

	/* code heart attack variables */
	
	* whether had any heart attack in last two years 
	
	local hearta1 v407
	local hearta2 w369
	local ahead_hearta2 b244
	* replace 0 with 9 to make it consistent with other heart attack variables
	replace b244=9 if b244==0
	local hearta3 e834
	local ahead_hearta3 d834
	* there is one with value 7 (other), replace it as 8 (don't know)
	replace d834=8 if d834==7
	local hearta4 f1162
	local hearta5 g1295
	local hearta6 hc040
	local hearta7 jc040
	local hearta8 kc040
	local hearta9 lc040
	local hearta10 MC040
	local hearta11 nc040
	local hearta12 oc040
	
	local heartpro1 v406
	local heartpro2 w367
	local ahead_heartpro2 b242
	local heartpro3 e828
	local ahead_heartpro3 d828
	local heartpro4 f1156
	local heartpro5 g1289
	local heartpro6 hc036
	local heartpro7 jc036
	local heartpro8 kc036
	local heartpro9 lc036
	local heartpro10 MC036
	local heartpro11 nc036
	local heartpro12 oc036
	
	local heartmed3 e829
	local ahead_heartmed3 d829
	local heartmed4 f1157
	local heartmed5 g1290
	local heartmed6 hc037
	local heartmed7 jc037
	local heartmed8 kc037
	local heartmed9 lc037
	local heartmed10 MC037
	local heartmed11 nc037
	local heartmed12 oc037
	
	local heartdoc3 e830
	local ahead_heartdoc3 d830
	local heartdoc4 f1158
	local heartdoc5 g1291
	local heartdoc6 hc038
	local heartdoc7 jc038
	local heartdoc8 kc038
	local heartdoc9 lc038
	local heartdoc10 MC038
	local heartdoc11 nc038
	local heartdoc12 oc038

	* copy the value of whether had heart attack in last two years, replace it to 0 if reported no heart problem
	forvalues x = 1/$lastwave {	
		gen hearta`x' = .
		replace hearta`x' = `hearta`x''
		replace hearta`x' = 0 if hearta`x' == 5
		replace hearta`x' = 0 if mi(hearta`x') & `heartpro`x'' != 1 & !mi(`heartpro`x'') & `x' <=4
		replace hearta`x' = 0 if mi(hearta`x') & !inlist(`heartpro`x'', 1, 3) & !mi(`heartpro`x'') & `x' > 4
	}
	
	* assign 0 if not taking any heart medication and didn't see doctor in the last two years for wave 3 and later waves
	forvalues x = 3/$lastwave {
		replace hearta`x' = 0 if mi(hearta`x') & `heartmed`x'' == 5 & `heartdoc`x'' == 5 
	}
	
	* add in AHEAD information for wave 2 and 3
	forvalues x = 2/3 {
		replace hearta`x' = `ahead_hearta`x'' if mi(hearta`x') 
		replace hearta`x' = 0 if `ahead_hearta`x'' == 5
		replace hearta`x' = 0 if mi(hearta`x') & `ahead_heartpro`x'' != 1 & !mi(`ahead_heartpro`x'')
	}
		replace hearta3 = 0 if mi(hearta3) & `ahead_heartmed3' == 5 & `ahead_heartdoc3' == 5  

	* for wave 10, 11 and 12, assign 0 if never had heart attack
		replace hearta10 = 0 if mi(hearta10) & MC257 == 5
		replace hearta11 = 0 if mi(hearta11) & nc257 == 5	
		replace hearta12 = 0 if mi(hearta12) & oc257 == 5	
		
		foreach var in MC276 MC277 MC258 MC259 MC043 MC044 MA500 MA501 MZ093 nc276 nc277 nc258 nc259 nc043 nc044 na500 na501 nz093 oc276 oc277 oc258 oc259 oc043 oc044 oa500 oa501 oz093 {
			replace `var' = .d if `var' == 9998 | `var' == 98
			}
	* for year of last heart attack, there are two variables, c276 and c043, 
	* if reported no last	heart attack but reported to have no heart attack after the first one, use first heart attack year as last heart attack year
	* for wave 10  11 and 12, for reinterviewees, assign 1 if last heart attack happened after last interviewed
			replace hearta10 = 1 if MZ093 - MC276 <= 0 & mi(hearta10) & MZ076 == 1
			replace hearta10 = 1 if MZ093 - MC258 <= 0 & mi(hearta10) & MZ076 == 1
			replace hearta10 = 1 if MZ093 - MC043 <= 0 & mi(hearta10) & MZ076 == 1                            
                                      
			replace hearta11 = 1 if nz093 - nc276 <= 0 &	mi(hearta11) & nz076 == 1 
			replace hearta11 = 1 if nz093 - nc258 <= 0 &	mi(hearta11) & nz076 == 1 
			replace hearta11 = 1 if nz093 - nc043 <= 0 &	mi(hearta11) & nz076 == 1 
			
			replace hearta12 = 1 if oz093 - oc276 <= 0 &	mi(hearta12) & oz076 == 1 
			replace hearta12 = 1 if oz093 - oc258 <= 0 &	mi(hearta12) & oz076 == 1 
			replace hearta12 = 1 if oz093 - oc043 <= 0 &	mi(hearta12) & oz076 == 1 
		
	* for wave 10  11 and 12, for reinterviewees, assign 0 if last heart attack happened before last interviewed
			replace hearta10 = 0 if MC276 - MZ093 < 0 & mi(hearta10) & MZ076 == 1
			replace hearta10 = 0 if MC043 - MZ093 < 0 & mi(hearta10) & MZ076 == 1
			replace hearta10 = 0 if MC258 - MZ093 < 0 & MC274 == 5 & mi(hearta10) & MZ076 == 1

			replace hearta11 = 0 if nc276 - nz093 < 0 & mi(hearta11) & nz076 == 1 
			replace hearta11 = 0 if nc043 - nz093 < 0 & mi(hearta11) & nz076 == 1 
			replace hearta11 = 0 if nc258 - nz093 < 0 & nc274 == 5 & mi(hearta11) & nz076 == 1
			
			replace hearta12 = 0 if oc276 - oz093 < 0 & mi(hearta11) & oz076 == 1 
			replace hearta12 = 0 if oc043 - oz093 < 0 & mi(hearta11) & oz076 == 1 
			replace hearta12 = 0 if oc258 - oz093 < 0 & oc274 == 5 & mi(hearta12) & oz076 == 1 
	
	* for wave 10  11 and 12, for first time respondents, assign 1 if reported heart attack in two years before the interview  
			replace hearta10 = 1 if MA501 - MC258 < 2 & mi(hearta10) 
			replace hearta10 = 1 if MA501 - MC258 == 2 & MA500 - MC259 < 0 & mi(hearta10)  
			replace hearta10 = 1 if MA501 - MC276 < 2 & mi(hearta10)                      
			replace hearta10 = 1 if MA501 - MC276 == 2 & MA500 - MC277 < 0 & mi(hearta10)  
			replace hearta10 = 1 if MA501 - MC043 < 2 & mi(hearta10)                      
			replace hearta10 = 1 if MA501 - MC043 == 2 & MA500 - MC044 < 0 & mi(hearta10)  
	    	                                                                                                               
			replace hearta11 = 1 if na501 - nc276 == 2 & na500 - nc277 < 0 & mi(hearta11)
			replace hearta11 = 1 if na501 - nc276 < 2 & mi(hearta11)                       
			replace hearta11 = 1 if na501 - nc258 == 2 & na500 - nc259 < 0 & mi(hearta11) 
			replace hearta11 = 1 if na501 - nc258 < 2 & mi(hearta11)                       
 			replace hearta11 = 1 if na501 - nc043 == 2 & na500 - nc044 < 0 & mi(hearta11) 
			replace hearta11 = 1 if na501 - nc043 < 2 & mi(hearta11)
			
			replace hearta12 = 1 if oa501 - oc276 == 2 & oa500 - oc277 < 0 & mi(hearta12)
			replace hearta12 = 1 if oa501 - oc276 < 2 & mi(hearta12)                       
			replace hearta12 = 1 if oa501 - oc258 == 2 & oa500 - oc259 < 0 & mi(hearta12) 
			replace hearta12 = 1 if oa501 - oc258 < 2 & mi(hearta12)                       
 			replace hearta12 = 1 if oa501 - oc043 == 2 & oa500 - oc044 < 0 & mi(hearta12) 
			replace hearta12 = 1 if oa501 - oc043 < 2 & mi(hearta12)
		
* for wave 10 and 11, for first time respondents, assign 0 if most recent heart attack is two years before the interview	
			replace hearta10 = 0 if MA501 - MC258 > 2  & !mi(MA501 - MC258) & MC274 == 5 & mi(hearta10)
			replace hearta10 = 0 if MA501 - MC258 == 2 & MC259 -  MA500 < 0 & mi(hearta10)  
			replace hearta10 = 0 if MA501 - MC276 > 2 & !mi(MA501 - MC276) & mi(hearta10)            
			replace hearta10 = 0 if MA501 - MC276 == 2 & MC277 -  MA500 < 0 & mi(hearta10)
			replace hearta10 = 0 if MA501 - MC043 > 2 & !mi(MA501 - MC043) & mi(hearta10)            
			replace hearta10 = 0 if MA501 - MC043 == 2 & MC044 -  MA500 < 0 & mi(hearta10)
		                                                                                                                                                               
			replace hearta11 = 0 if na501 - nc258 > 2  & !mi(na501 - nc258) & nc274 == 5 & mi(hearta11) 
			replace hearta11 = 0 if na501 - nc258 == 2 & nc259 - na500 < 0 & mi(hearta11)   
			replace hearta11 = 0 if na501 - nc276 > 2 & !mi(na501 - nc276) & mi(hearta11)          
			replace hearta11 = 0 if na501 - nc276 == 2 & nc277 - na500 < 0 & mi(hearta11) 
			replace hearta11 = 0 if na501 - nc043 > 2 & !mi(na501 - nc043) & mi(hearta11)          
			replace hearta11 = 0 if na501 - nc043 == 2 & nc044 - na500 < 0 & mi(hearta11) 
			
			replace hearta12 = 0 if oa501 - oc258 > 2  & !mi(oa501 - oc258) & oc274 == 5 & mi(hearta12) 
			replace hearta12 = 0 if oa501 - oc258 == 2 & oc259 - oa500 < 0 & mi(hearta12)   
			replace hearta12 = 0 if oa501 - oc276 > 2 & !mi(oa501 - oc276) & mi(hearta12)          
			replace hearta12 = 0 if oa501 - oc276 == 2 & oc277 - oa500 < 0 & mi(hearta12) 
			replace hearta12 = 0 if oa501 - oc043 > 2 & !mi(oa501 - oc043) & mi(hearta12)          
			replace hearta12 = 0 if oa501 - oc043 == 2 & oc044 - oa500 < 0 & mi(hearta12) 
			
	* for wave 10 11 and 12 , assign 0 if reported no heart problem on baseline
			replace hearta10 = 0 if mi(hearta10) & MZ255 == 5
			replace hearta11 = 0 if mi(hearta11) & nz255 == 5
			replace hearta12 = 0 if mi(hearta12) & oz255 == 5
	
	* for  wave 10 11 and 12, assign 1 if reported have seen doctor for heart attack
			replace hearta10 = 1 if mi(hearta10) & MC041 == 1
			replace hearta11 = 1 if mi(hearta11) & nc041 == 1
			replace hearta12 = 1 if mi(hearta12) & oc041 == 1
	
	* for  wave 10 11 and 12, assign 0 if not taking medication for heart attack and didn't see a doctor for heart attack in last two years
			replace hearta10 = 0 if mi(hearta10) & MC041 == 5	& MC042 == 5
			replace hearta11 = 0 if mi(hearta11) & nc041 == 5 & nc042 == 5
			replace hearta12 = 0 if mi(hearta12) & oc041 == 5 & oc042 == 5
	
	* for wave 10, assign 1 if in 2012 reported any heart attack within two years before the interview in 2010
	* for wave 11, assign 1 if in 2014 reported any heart attack within two years before the interview in 2012
			replace hearta10 = 1 if MZ093 - nc276 <= 0 & mi(hearta10) & MZ076 == 1 
			replace hearta10 = 1 if MZ093 - nc043 <= 0 & mi(hearta10) & MZ076 == 1 
			replace hearta10 = 1 if MZ093 - nc258 <= 0 & nc274 == 5 & mi(hearta10) & MZ076 == 1                                    
		
			replace hearta10 = 1 if MA501-nc258 < 2 & mi(hearta10)
			replace hearta10 = 1 if MA501-nc258 == 2 & MA500 - nc259 < 0 & mi(hearta10)
			replace hearta10 = 1 if MA501-nc276 < 2 & mi(hearta10)
			replace hearta10 = 1 if MA501-nc276 == 2 & MA500 - nc277 < 0 & mi(hearta10)
			replace hearta10 = 1 if MA501-nc043 < 2 & mi(hearta10)
			replace hearta10 = 1 if MA501-nc043 == 2 & MA500 - nc044 < 0 & mi(hearta10)
			
			replace hearta11 = 1 if nz093 - oc276 <= 0 & mi(hearta11) & nz076 == 1 
			replace hearta11 = 1 if nz093 - oc043 <= 0 & mi(hearta11) & nz076 == 1 
			replace hearta11 = 1 if nz093 - oc258 <= 0 & oc274 == 5 & mi(hearta11) & nz076 == 1                                    
		
			replace hearta11 = 1 if na501-oc258 < 2 & mi(hearta11)
			replace hearta11 = 1 if na501-oc258 == 2 & na500 - oc259 < 0 & mi(hearta10)
			replace hearta11 = 1 if na501-oc276 < 2 & mi(hearta11)
			replace hearta11 = 1 if na501-oc276 == 2 & na500 - oc277 < 0 & mi(hearta10)
			replace hearta11 = 1 if na501-oc043 < 2 & mi(hearta11)
			replace hearta11 = 1 if na501-oc043 == 2 & na500 - oc044 < 0 & mi(hearta10)
			

	* for wave 10, assign 0 if in 2012 reported most recent heart attack before the interview in 2010
	* for wave 11, assign 0 if in 2014 reported most recent heart attack before the interview in 2012
			replace hearta10 = 0 if nc276 - MZ093 < 0 & mi(hearta10) & MZ076 == 1 
			replace hearta10 = 0 if nc043 - MZ093 < 0 & mi(hearta10) & MZ076 == 1 
			replace hearta10 = 0 if nc258 - MZ093 < 0 & nc274 == 5 & mi(hearta10) & MZ076 == 1                                        
			
			replace hearta10 = 0 if MA501-nc258 > 2 & !mi(MA501-nc258) & mi(hearta10)
			replace hearta10 = 0 if MA501-nc258 == 2 & nc259 - MA500 < 0 & mi(hearta10)
			replace hearta10 = 0 if MA501-nc276 > 2 & !mi(MA501-nc276) & mi(hearta10)         
			replace hearta10 = 0 if MA501-nc276 == 2 & nc277 - MA500 < 0 & mi(hearta10)
			replace hearta10 = 0 if MA501-nc043 > 2 & !mi(MA501-nc043) & mi(hearta10)          
			replace hearta10 = 0 if MA501-nc043 == 2 & nc044 - MA500 < 0 & mi(hearta10)
			
			replace hearta11 = 0 if oc276 - nz093 < 0 & mi(hearta11) & nz076 == 1 
			replace hearta11 = 0 if oc043 - nz093 < 0 & mi(hearta11) & nz076 == 1 
			replace hearta11 = 0 if oc258 - nz093 < 0 & oc274 == 5 & mi(hearta11) & nz076 == 1                                        
			
			replace hearta11 = 0 if na501-oc258 > 2 & !mi(na501-oc258) & mi(hearta11)
			replace hearta11 = 0 if na501-oc258 == 2 & oc259 - na500 < 0 & mi(hearta11)
			replace hearta11 = 0 if na501-oc276 > 2 & !mi(na501-oc276) & mi(hearta11)         
			replace hearta11 = 0 if na501-oc276 == 2 & oc277 - na500 < 0 & mi(hearta11)
			replace hearta11 = 0 if na501-oc043 > 2 & !mi(na501-oc043) & mi(hearta11)          
			replace hearta11 = 0 if na501-oc043 == 2 & oc044 - na500 < 0 & mi(hearta11)

	* replace to 0 if disputed heart disease status and not having condition in later wave
		forvalues x = 1/$lastwave {
			replace hearta`x' = 0 if r`x'hearte == 0 & r`x'heartf == 6
		}	
		
		* 
		forvalues x = 1/$lastwave {
			replace hearta`x' = .r if hearta`x' == 8
			replace hearta`x' = .d if hearta`x' == 9 
		}	

* correct heart attack variable using year most recent heart attack: 
* if the reported most recent heart attack is before the last interview or before two years
* replace the value to 0

local recenthearta3 e839
local recenthearta4 f1166
local recenthearta5 g1299
local recenthearta6 hc043
local recenthearta7 jc043
local recenthearta8 kc043
local recenthearta9 lc043
local recenthearta10 MC043
local recenthearta11 nc043
local recenthearta12 oc043

local recenthearta_mo3 e840
local recenthearta_mo4 f1167
local recenthearta_mo5 g1300
local recenthearta_mo6 hc044
local recenthearta_mo7 jc044
local recenthearta_mo8 kc044
local recenthearta_mo9 lc044
local recenthearta_mo10 MC044
local recenthearta_mo11 nc044
local recenthearta_mo12 oc044

local piwyear3 e96 
local piwyear4 f219
local piwyear5 gprviwyr
local piwyear6 hz093
local piwyear7 jz093
local piwyear8 kz093
local piwyear9 lz093
local piwyear10 MZ093
local piwyear11 nz093
local piwyear12 oz093

local piwmonth3 e95 
local piwmonth4 f218
local piwmonth5 gprviwmo
local piwmonth6 hz092
local piwmonth7 jz092
local piwmonth8 kz092
local piwmonth9 lz092
local piwmonth10 MZ092
local piwmonth11 nz092
local piwmonth12 oz092

local iwyear3 e393
local iwyear4 f699
local iwyear5 giwyear
local iwyear6 ha501
local iwyear7 ja501
local iwyear8 ka501
local iwyear9 la501
local iwyear10 MA501
local iwyear11 na501
local iwyear12 oa501

local iwmonth3 e391
local iwmonth4 f697
local iwmonth5 giwmonth
local iwmonth6 ha500
local iwmonth7 ja500
local iwmonth8 ka500
local iwmonth9 la500
local iwmonth10 MA500
local iwmonth11 na500
local iwmonth12 oa500

local reiw3 e22_1
local reiw4 f26_1
local reiw5 g26_1
local reiw6 hz076
local reiw7 jz076
local reiw8 kz076
local reiw9 lz076
local reiw10 MZ076
local reiw11 nz076
local reiw12 oz076

forvalues x = 3/$lastwave {
	replace hearta`x' = 0 if `reiw`x'' == 1 & `recenthearta`x'' < `piwyear`x'' 
	replace hearta`x' = 0 if `reiw`x'' == 1 & `recenthearta`x'' == `piwyear`x'' & `recenthearta_mo`x'' < `piwmonth`x''
 	replace hearta`x' = 0 if `reiw`x'' != 1 & `recenthearta`x'' - `iwyear`x'' < -2 
 	replace hearta`x' = 0 if `reiw`x'' != 1 & `recenthearta`x'' == `iwyear`x'' - 2 & `iwmonth`x'' < `recenthearta_mo`x'' 
}
	
* whether ever had heart attack 
forvalues x = 1/$lastwave {
	gen heartae`x' = hearta`x'
}
replace heartae10 = 1 if MC257==1
replace heartae11 = 1 if nc257==1
replace heartae12 = 1 if oc257==1

forvalues x = 2/$lastwave {
	local y = `x' - 1
	replace heartae`x' = 1 if heartae`y' == 1 & !mi(heartae`x') 
	replace heartae`x' = 1 if heartae`y' == 1 & heartae`x' == 0
}
				
* age when first heart attack
gen first_hearta = MC258 if !mi(MC258) & MC258!= 9998
replace first_hearta = nc258 if mi(first_hearta) & !mi(nc258) & nc258!= 9998
replace first_hearta = oc258 if mi(first_hearta) & !mi(oc258) & oc258!= 9998 
replace first_hearta = oc258 if inlist(first_hearta, 2000, 2001, 2002) & hc040 != 1 & !inlist(oc258, 2000, 2001, 2002, 9998, .) 
replace first_hearta = oc258 if inlist(first_hearta, 2002, 2003, 2004) & jc040 != 1 & !inlist(oc258, 2002, 2003, 2004, 9998, .)
replace first_hearta = oc258 if inlist(first_hearta, 2004, 2005, 2006) & kc040 != 1 & !inlist(oc258, 2004, 2005, 2006, 9998, .)
replace first_hearta = oc258 if inlist(first_hearta, 2006, 2007, 2008) & lc040 != 1 & !inlist(oc258, 2006, 2007, 2008, 9998, .)
replace first_hearta = oc258 if inlist(first_hearta, 2008, 2009, 2010) & MC040 != 1 & !inlist(oc258, 2008, 2009, 2010, 9998, .)
replace first_hearta = oc258 if inlist(first_hearta, 2010, 2011, 2012) & nc040 != 1 & !inlist(oc258, 2010, 2011, 2012, 9998, .)
replace first_hearta = oc258 if inlist(first_hearta, 2012, 2013, 2014) & oc040 != 1 & !inlist(oc258, 2012, 2013, 2014, 9998, .)
* use the first observed year of hearta as first hearta if missing
bys hhidpn: replace first_hearta = 1992 if heartae1 == 1 
forvalues x = 2/$lastwave {
	local y = `x' - 1
	bys hhidpn: replace first_hearta = 1990 + 2*`x' if heartae`x' == 1 & heartae`y' == 0 & mi(first_hearta)
}
gen fhearta_age = first_hearta - rabyear
ta fhearta_age
replace fhearta_age = 0 if mi(fhearta_age)

* year most recent heart attack
forvalues x = 3/$lastwave {
	gen last_hearta`x' =  `recenthearta`x'' if !mi(`recenthearta`x'') & `recenthearta`x'' != 9998 & `recenthearta`x'' != 9999
}

replace last_hearta12 = oc276 if mi(last_hearta12) & !mi(oc276) & oc276 != 9998 & oc276 != 9999
replace last_hearta11 = nc276 if mi(last_hearta11) & !mi(nc276) & nc276 != 9998 & oc276 != 9999
replace last_hearta10 = MC276 if mi(last_hearta10) & !mi(MC276) & MC276 != 9998 & oc276 != 9999


gen tag = 0
forvalues x = 4/$lastwave {
	local y = `x' - 1
	replace tag = 1 if mi(last_hearta`x')
	replace last_hearta`x' = last_hearta`y' if mi(last_hearta`x') 
}

forvalues x = 3/$lastwave {
	replace last_hearta`x' = first_hearta if mi(last_hearta`x') & oc274 == 5
}

forvalues x = 3/$lastwave {
	replace last_hearta`x' = 1990 + 2*`x' if heartae`x' == 1 & mi(last_hearta`x')
}  

* add in month of the most recent heart attack

forvalues x = 3/$lastwave {
	gen last_hearta_mo`x' =  `recenthearta_mo`x'' if !mi(`recenthearta_mo`x'') & `recenthearta_mo`x'' != 9998 & `recenthearta_mo`x'' != 9999
}
replace last_hearta_mo12 = oc277 if mi(last_hearta_mo12) & !mi(oc277) & oc277 != 9998 & oc277 != 9999
replace last_hearta_mo11 = nc277 if mi(last_hearta_mo11) & !mi(nc277) & nc277 != 9998 & nc277 != 9999
replace last_hearta_mo10 = MC277 if mi(last_hearta_mo11) & !mi(MC277) & MC277 != 9998 & nc277 != 9999


forvalues x = 4/$lastwave {
	local y = `x' - 1
	replace last_hearta_mo`x' = last_hearta_mo`y' if tag == 1
}

drop tag

forvalues x = 3/$lastwave {
	replace last_hearta_mo`x' = 1 if !mi(last_hearta`x') & !mi(last_hearta_mo`x')
	gen last_hearta_time`x' = ym(last_hearta`x', last_hearta_mo`x')
	format last_hearta_time`x' %tm
	gen iw_time`x' = ym(`iwyear`x'', `iwmonth`x'')	
	format iw_time`x' %tm
}

forvalues x = 3/$lastwave {
	drop last_hearta_mo`x'
}

* generate months since last heart attack using interview year and month
forvalues x = 3/$lastwave {
	gen time_lhearta`x' = (iw_time`x' - last_hearta_time`x')/12
	drop iw_time`x' last_hearta_time`x'
	replace time_lhearta`x' = 0 if mi(time_lhearta`x')
} 

* for the first two waves in which the year/month of the first heart attack is not available, assign -2
forvalues x = 1/2 {
	gen time_lhearta`x' = -2
}


/*
Added the treatment (medication) variables for any medication and cholesterol medication

1. Create treatment (medication) variables 
2. Code whether use any prescription drug regularly - not available before wave 4 
3. Use -333 as place-holder for missing-waves
4. Cholesterol treatment only available since wave 8

*/

forvalues x=1/$lastwave {
	gen r`x'anyrx = . 
}

forvalues x=1/4 {
	replace r`x'anyrx = -333
}

* Recode the variable - 1 = yes, 5= no, 7=medication known, 8, 9 - uncertain/DK
* g2622 hn175 jn175 kn175 ln175 MN175 nn175

replace r5anyrx = 1 if g2622 == 1 | g2622 == 7
replace r5anyrx = 0 if g2622 == 5

replace r6anyrx = 1 if hn175 == 1 | hn175 == 7
replace r6anyrx = 0 if hn175 == 5

replace r7anyrx = 1 if jn175 == 1 | jn175 == 7
replace r7anyrx = 0 if jn175 == 5

replace r8anyrx = 1 if kn175 == 1 | kn175 == 7
replace r8anyrx = 0 if kn175 == 5

replace r9anyrx = 1 if ln175 == 1 | ln175 == 7
replace r9anyrx = 0 if ln175 == 5

replace r10anyrx = 1 if MN175 == 1 | MN175 == 7
replace r10anyrx = 0 if MN175 == 5

replace r11anyrx = 1 if nn175 == 1 | nn175 == 7
replace r11anyrx = 0 if nn175 == 5

replace r12anyrx = 1 if on175 == 1 | on175 == 7
replace r12anyrx = 0 if on175 == 5

* Code whether regularly taking cholesterol-lowering drugs - kn360 ln360 MN360 nn360 

forvalues x=1/$lastwave {
	gen r`x'lipidrx = . 
}

* Won't use before wave 8
forvalues x=1/7 {
	replace r`x'lipidrx = -333
}

* Recode the variable - 1 = yes, 5= no, 8, 9 - uncertain/DK

replace r8lipidrx = 1 if kn360 == 1 
replace r8lipidrx = 0 if kn360 == 5 | kn175 == 5

replace r9lipidrx = 1 if ln360 == 1
replace r9lipidrx = 0 if ln360 == 5 | ln175 == 5

replace r10lipidrx = 1 if MN360 == 1
replace r10lipidrx = 0 if MN360 == 5 | MN175 == 5

replace r11lipidrx = 1 if nn360 == 1
replace r11lipidrx = 0 if nn360 == 5 | nn175 == 5

replace r12lipidrx = 1 if on360 == 1
replace r12lipidrx = 0 if on360 == 5 | on175 == 5


/* Code Medicaid variables:
- r*govmd is RAND HRS variable for current Medicaid status
- We can also develop any Medicaid enrollment in past two years for wave 3+ from the fat files

Two variables: caidcur => currently enrolled in Medicaid, caid2yr => enrolled in Medicaid in past two years
*/

forvalues x = 1/$lastwave {
	gen r`x'caid2yr = .
	gen r`x'caidcur = .
}

* Wave 1 
replace r1caid2yr = -99999 /* not asked for first wave respondents */
* HRS
replace r1caidcur = 0 if inlist(v6602,1,5) /* HRS responded to any federal HI */
replace r1caidcur = 1 if v6604 == 1 /* HRS responded yes to Medicaid */
* AHEAD
replace r1caidcur = 0 if b1838 == 5 /* AHEAD not covered by Medicaid */
replace r1caidcur = 1 if b1838 == 1 /* Covered by Medicaid */

* Wave 2
replace r2caid2yr = -99999 /* Not asked CONSISTENTLY for second wave respondents */
* HRS
replace r2caidcur = 0 if inlist(w6700,1,5) /* HRS responded to any federal HI */
replace r2caidcur = 1 if (w6701 == 2 | w6702 == 2 | w6703 == 2 | w6704 == 2) /* Indicated Medicaid as source */
* AHEAD
replace r2caidcur = 0 if inlist(d5155,1,5) /* Lead-in question to current Medicaid status */
replace r2caidcur = 1 if d5158 == 1 /* Currently on Medicaid */


* Wave 3
replace r3caid2yr = 1 if e5135 == 1
replace r3caid2yr = 0 if e5135 == 5
replace r3caidcur = 0 if r3caid2yr == 0
replace r3caidcur = 1 if e5136 == 1
replace r3caidcur = 0 if e5136 == 5

* Wave 4
replace r4caid2yr = 1 if f5868 == 1
replace r4caid2yr = 0 if f5868 == 5
replace r4caidcur = 0 if r4caid2yr == 0
replace r4caidcur = 1 if f5869 == 1
replace r4caidcur = 0 if f5869 == 5

* Wave 5
replace r5caid2yr = 1 if g6241 == 1
replace r5caid2yr = 0 if g6241 == 5
replace r5caidcur = 0 if r5caid2yr == 0
replace r5caidcur = 1 if g6242 == 1
replace r5caidcur = 0 if g6242 == 5
                                               
* Wave 6
replace r6caid2yr = 1 if hn005 == 1
replace r6caid2yr = 0 if hn005 == 5
replace r6caidcur = 0 if r6caid2yr == 0
replace r6caidcur = 1 if hn006 == 1
replace r6caidcur = 0 if hn006 == 5                            

* Wave 7
replace r7caid2yr = 1 if jn005 == 1
replace r7caid2yr = 0 if jn005 == 5
replace r7caidcur = 0 if r7caid2yr == 0
replace r7caidcur = 1 if jn006 == 1
replace r7caidcur = 0 if jn006 == 5                          
                         
* Wave 8
replace r8caid2yr = 1 if kn005 == 1
replace r8caid2yr = 0 if kn005 == 5
replace r8caidcur = 0 if r8caid2yr == 0
replace r8caidcur = 1 if kn006 == 1
replace r8caidcur = 0 if kn006 == 5 

* Wave 9
replace r9caid2yr = 1 if ln005 == 1
replace r9caid2yr = 0 if ln005 == 5
replace r9caidcur = 0 if r9caid2yr == 0
replace r9caidcur = 1 if ln006 == 1
replace r9caidcur = 0 if ln006 == 5 

* Wave 10
replace r10caid2yr = 1 if MN005 == 1
replace r10caid2yr = 0 if MN005 == 5
replace r10caidcur = 0 if r10caid2yr == 0
replace r10caidcur = 1 if MN006 == 1
replace r10caidcur = 0 if MN006 == 5 

* Wave 11
replace r11caid2yr = 1 if nn005 == 1
replace r11caid2yr = 0 if nn005 == 5
replace r11caidcur = 0 if r11caid2yr == 0
replace r11caidcur = 1 if nn006 == 1
replace r11caidcur = 0 if nn006 == 5 

* Wave 12
replace r12caid2yr = 1 if on005 == 1
replace r12caid2yr = 0 if on005 == 5
replace r12caidcur = 0 if r12caid2yr == 0
replace r12caidcur = 1 if on006 == 1
replace r12caidcur = 0 if on006 == 5 
                                    

* Create DB pension claiming and entitlement varialbes from 2012 RNDHRS data, replace the dbclaim from wave 2 to 7, which was created by Shawn as above
* Receiving DB pension income
* The DB income variable is not available in wave 1

forvalues x = 2/7 {
	replace dbclaim`x' = .
	replace dbclaim`x' = (r`x'peninc == 1) if !missing(r`x'peninc) 
}

forvalues x = 8/12 {
	generate dbclaim`x' = .
	replace dbclaim`x' = (r`x'peninc == 1) if !missing(r`x'peninc) 
}


/* Merge in data from the in-house imputation files */
merge hhidpn using $outdata/proptximp.dta, keep(h*anyproptxa h*anyproptxb h*proptxa h*proptxb) sort unique
drop if _merge == 2
drop _merge

/* Merge with RAND Family respondent level file to get transfers to kids */
local transfers h*tcamt h*tcany
merge hhidpn using $randfamr, keep(`transfers') sort unique
drop if _merge==2
tab _merge
drop _merge

* Recode missing values to 0 for individuals who do not have children
* or otherwise missing   
foreach v of varlist `transfers' {
  replace `v' = 0 if missing(`v')

}

* Merge with dataset that includes helper hours
merge hhidpn using $outdata/helphours.dta, keep(r*helperct r*helphoursyr r*helphoursyr_nonsp r*helphoursyr_sp) sort unique
tab _merge
drop if _merge == 2
drop _merge

/*initialize for wave 12
gen r12helperct = -999 
gen r12helphoursyr = -999
gen r12helphoursyr_nonsp = -999
gen r12helphoursyr_sp = -999*/

* Merge with dataset that includes volunteer hours
merge hhidpn using $outdata/volhours.dta, keep(r*volhours catholic jewish relnone reloth rel_notimp rel_someimp suburb exurb) sort unique
tab _merge
drop if _merge == 2
drop _merge

/*initialize for wave 12
gen r12volhours = -999*/

* Merge with dataset that includes grandchild care hours
merge hhidpn using $outdata/gkcarehours.dta, keep(nkids* r*gkcarehrs kid_byravg* kid_mnage* r*nkid_liv10mi) sort unique
tab _merge
drop if _merge == 2
drop _merge

drop kid_byravg

/*initialize for wave 12
gen r12gkcarehrs = -999
gen r12nkid_liv10mi = -999*/


* Merge with dataset that includes details about respondent's and spouse's parents
local parvars r*parhelphours r*paralive r*parnotmar r*par10mi rm*alive rf*alive sm*alive sf*alive rm*livage rf*livage sm*livage sf*livage rm*liv10mi rf*liv10mi sm*liv10mi sf*liv10mi rm*married rf*married sm*married sf*married 
merge hhidpn using $outdata/parhelp.dta, keep(`parvars') sort unique
drop if _merge == 2
drop _merge

* Generate a non-time-varying variable if a parent is ever observed within 10 miles
egen par10mi_fixed = rowtotal(r*par10mi)
replace par10mi_fixed = 1 if par10mi > 0 & par10mi < .
tab par10mi

* gen as placeholders for wave 11, family data only available til wave 10

forvalues i = 11/12 {
	
	gen rm`i'alive = .
	gen rf`i'alive = .
	gen sm`i'alive = .
	gen sf`i'alive = .
	gen rm`i'livage = .
	gen rf`i'livage = .
	gen sm`i'livage = .
	gen sf`i'livage = .
	gen rm`i'married = .
	gen rf`i'married = .
	gen sm`i'married = .
	gen sf`i'married = .
	gen rm`i'liv10mi = .
	gen rf`i'liv10mi = .
	gen sm`i'liv10mi = .
	gen sf`i'liv10mi = .
	
}

	
forvalues x = 4/$lastwave {
	rename rm`x'alive   r`x'malive
	rename rf`x'alive   r`x'falive
	rename sm`x'alive   s`x'malive
	rename sf`x'alive   s`x'falive
	rename rm`x'livage  r`x'mlivage
	rename rf`x'livage  r`x'flivage
	rename sm`x'livage  s`x'mlivage
	rename sf`x'livage  s`x'flivage
	rename rm`x'married r`x'mmarried
	rename rf`x'married r`x'fmarried
	rename sm`x'married s`x'mmarried
	rename sf`x'married s`x'fmarried
	rename rm`x'liv10mi r`x'mliv10mi
	rename rf`x'liv10mi r`x'fliv10mi 
	rename sm`x'liv10mi s`x'mliv10mi 
	rename sf`x'liv10mi s`x'fliv10mi 
}

* Create industry/occupation 'initial' variables
gen fmanuf = 0
gen fpubadm = 0
gen fmanage = 0
gen fwhtcoll = 0
replace fmanuf = 1 if r7jlind == 3 | r7jlind == 4
replace fpubadm = 1 if r7jlind == 13
replace fmanage = 1 if r7jlocc == 1 | r7jlocc == 2 | r7jlocca == 1 | r7jlocca == 2
replace fwhtcoll = 1 if r7jlocc == 3 | r7jlocc == 4 | r7jlocca == 3 | r7jlocca == 4

drop r7jlocc r7jlocca r7jlind

* gen as placeholders for wave 11, family data only available til wave 10
/*
gen nkids011 = .
gen kid_byravg011 = .
gen kid_mnage011 = .
*/

* Rename kid variables to have r`yr' prefixes
local y 98
local a

rename nkids10 nkids010
rename kid_byravg10 kid_byravg010
rename kid_mnage10 kid_mnage010

* family information only available until wave 10
forvalues i=12(2)14{
	gen nkids0`i' = . 
	gen kid_byravg0`i' = . 
	gen kid_mnage0`i' = . 
}

forvalues x = 4/$lastwave {
	 rename nkids`a'`y' r`x'nkids
	 rename kid_byravg`a'`y' r`x'kid_byravg
	 rename kid_mnage`a'`y' r`x'kid_mnage
   local y = mod(`y'+2,100)
   local a = 0 
 }
 
*** ------------------------------------------

*** SPECIAL RECODING
*** Attention! after wave 7, if report never smoked, was set to .n, replace with 0
*** This applies to RAND HRS versions G through J. Starting in K, it was changed
*** to set those values to 0.
local firstSmoke = max(7,$firstwave)
forvalues i=`firstSmoke'/$lastwave {
  replace r`i'smokev = 0 if r`i'smokev == .n
  replace r`i'smoken = 0 if r`i'smoken == .n
}

*** Early/normal retirement age for current DB pension at first interview - eligibility
	gen eage_db = EAGE_92X if inlist(hacohort,3)
	replace eage_db = EAGE_98X if inlist(hacohort,4)
	gen nage_db = NAGE_92X if inlist(hacohort,3) 
	replace nage_db = NAGE_98X if inlist(hacohort,4)	
	label var eage_db "Early ret age for current DB-IPW"
	label var nage_db "Normal ret age for current DB-IPW"
	drop EAGE* NAGE*
	
*** MERGE with the DB pension eligibility age for 2004 EBB cohort (ipw only covers 1992-1998) for DB retirement years
  merge hhidpn using "$indata/dbpenage_2004.dta", sort
  tab _merge
  drop if _merge == 2
  replace eage_db = db_earlyage if hacohort == 5 & !missing(db_earlyage)
  replace nage_db = db_fullage if hacohort == 5 & !missing(db_fullage)
  drop db_earlyage db_fullage _merge
	
*** DC pension wealth (not for AHEAD) only if anydc == 1
	gen dcwlth = DC_92 if inlist(hacohort,3)
	replace dcwlth = DC_98 if inlist(hacohort,4)
	replace dcwlth = 0 if missing(dcwlth) & inlist(hacohort,3,4)
	gen anydc  = dcwlth > 0 & !missing(dcwlth) if inlist(hacohort,3) & r1iwstat == 1
	replace anydc  = dcwlth > 0 & !missing(dcwlth) if inlist(hacohort,4) & r4iwstat == 1	
	label var dcwlth "DC wealth from current  job"
	label var anydc  "DC pension from current job"
	
*** If merged 	
*** Claiming DI
forvalues i = $firstwave/$lastwave{
	gen diclaim`i' 	= inlist(r`i'dstat,20,21,22,200) if r`i'dstat <=200 & r`i'iwstat == 1
	gen ssiclaim`i' =	inlist(r`i'dstat,2,12,22,200) if r`i'dstat <= 200 & r`i'iwstat == 1
}

drop r*dstat

*** Recode missings for DB and DC pension some cohorts
	replace anydb = 0 if inlist(hacohort, 0,1,2)
	forvalues i = $firstwave/`dbwv'{
		replace diclaim`i' = 0 if inlist(hacohort,0,1,2) & r`i'iwstat == 1 | r`i'agey_e > 66
		replace ssiclaim`i' = 0 if inlist(hacohort,0,1) & inlist(`i',2,3) & r`i'iwstat == 1
	}

**	forvalues i = $firstwave/11 {
**		replace dbclaim`i' = 0 if inlist(hacohort,0,1,2) & r`i'iwstat == 1
**}
	
	replace anydc  = 0 if inlist(hacohort,0,1,2,5,6) 
	replace dcwlth = 0 if inlist(hacohort,0,1,2,5,6)
	
foreach x of varlist anydb anydc dcwlth {
	cap c & inlist(hacohort,3)
	cap replace `x' = 0 if (r4work!= 1 | r4iearn == 0) & r4iwstat == 1 & inlist(hacohort,4)
	cap replace `x' = 0 if (r7work!= 1 | r7iearn == 0) & r7iwstat == 1 & inlist(hacohort,5)
	cap replace `x' = 0 if (r7work!= 1 | r10iearn == 0) & r10iwstat == 1 & inlist(hacohort,6)
}

label define ea 1 "50" 2 "55" 3 "60"
label define na 1 "55" 2 "60" 3 "62" 4 "65"
recode eage_db (min/52=1) (53/57=2) (58/max=3), gen(rdb_ea_c)
recode nage_db (min/57=1) (58/61=2) (62/63=3) (64/max=4), gen(rdb_na_c)
replace rdb_na_c = 2 if rdb_na_c==1&rdb_ea_c==3
label values rdb_ea_c ea
label values rdb_na_c na

* Impute early and normal DB pension age categories if with anydb
drop eage_db nage_db

replace rdb_ea_c = . if anydb != 1
replace rdb_na_c = . if anydb != 1

hotdeck rdb_ea_c rdb_na_c if anydb == 1 & inlist(hacohort,3,4,5,6), by(ragender hacohort) keep(hhidpn) store seed(`seed')

drop rdb_ea_c rdb_na_c
merge hhidpn using imp1.dta, sort
drop _merge
rm imp1.dta

replace rdb_ea_c = 0 if anydb != 1
replace rdb_na_c = 0 if anydb != 1

*** 04/2015 - Create anydb variable by using the variable from RNDHRS_N data
* Any DB entitlement for current job 
forvalues x = 1/12 {
	generate anydb_n`x' = .
	replace anydb_n`x' = (r`x'jcpen == 1) if !missing(r`x'jcpen)
}
*Consistency of DB pension and job status
forvalues x = 1/12 {
	replace anydb_n`x' = 0 if (r`x'work!= 1 | r`x'iearn == 0) & r`x'iwstat == 1
}


***  Assign diabetes status at age 50, impute as needed ***

* Recode missing diabetes from 9998/9999 to missing
foreach var of varlist v329 jc214 kc214 lc214 MC214 nc214 oc214 {
	replace `var' = . if `var' > 2100
}

* Populate diabetes onset using most recent vars first
gen diab_onset = oc214
replace diab_onset = nc214 if missing(diab_onset)
replace diab_onset = MC214 if missing(diab_onset)
replace diab_onset = lc214 if missing(diab_onset)
replace diab_onset = kc214 if missing(diab_onset)
replace diab_onset = jc214 if missing(diab_onset)
replace diab_onset = v329 if missing(diab_onset)

* Flag if ever gets diab
egen diab_ever = rowmax(r*diabe)

* Diabetes onset for new cases
* We see switch from wave n to wave n+1
forvalues x = 2/$lastwave {
	local y = `x' - 1
	replace diab_onset = 1990+2*`x'-1 if r`x'diabe == 1 & r`y'diabe == 0 & missing(diab_onset)
}
* Respondent might skip a wave, so we see switch from wave n to wave n+2
forvalues x = 3/$lastwave {
	local y = `x' - 2
	replace diab_onset = 1990+2*`x'-2 if r`x'diabe == 1 & r`y'diabe == 0 & missing(diab_onset)
}
* Respondent might skip two waves, so we see switch from wave n to wave n+3
forvalues x = 4/$lastwave {
	local y = `x' - 3
	replace diab_onset = 1990+2*`x'-3 if r`x'diabe == 1 & r`y'diabe == 0 & missing(diab_onset)
}
* Respondent might skip three waves, so we see switch from wave n to wave n+4
forvalues x = 5/$lastwave {
	local y = `x' - 4
	replace diab_onset = 1990+2*`x'-4 if r`x'diabe == 1 & r`y'diabe == 0 & missing(diab_onset)
}
* Respondent might skip four waves, so we see switch from wave n to wave n+5
forvalues x = 6/$lastwave {
	local y = `x' - 5
	replace diab_onset = 1990+2*`x'-5 if r`x'diabe == 1 & r`y'diabe == 0 & missing(diab_onset)
}
* Respondent might skip five waves, so we see switch from wave n to wave n+6
forvalues x = 7/$lastwave {
	local y = `x' - 6
	replace diab_onset = 1990+2*`x'-6 if r`x'diabe == 1 & r`y'diabe == 0 & missing(diab_onset)
}
* Respondent might skip six waves, so we see switch from wave n to wave n+7
forvalues x = 8/$lastwave {
	local y = `x' - 7
	replace diab_onset = 1990+2*`x'-7 if r`x'diabe == 1 & r`y'diabe == 0 & missing(diab_onset)
}
* Respondent might skip seven waves, so we see switch from wave n to wave n+8
forvalues x = 9/$lastwave {
	local y = `x' - 8
	replace diab_onset = 1990+2*`x'-8 if r`x'diabe == 1 & r`y'diabe == 0 & missing(diab_onset)
}
* Respondent might skip eight waves, so we see switch from wave n to wave n+9
forvalues x = 10/$lastwave {
	local y = `x' - 9
	replace diab_onset = 1990+2*`x'-9 if r`x'diabe == 1 & r`y'diabe == 0 & missing(diab_onset)
}

* Respondent might skip nine waves, so we see switch from wave n to wave n+10
forvalues x = 11/$lastwave {
	local y = `x' - 10
	replace diab_onset = 1990+2*`x'-10 if r`x'diabe == 1 & r`y'diabe == 0 & missing(diab_onset)
}

* Respondent might skip ten waves, so we see switch from wave n to wave n+11
forvalues x = 12/$lastwave {
	local y = `x' - 11
	replace diab_onset = 1990+2*`x'-11 if r`x'diabe == 1 & r`y'diabe == 0 & missing(diab_onset)
}

gen fdiabe50 = .
replace fdiabe50 = 0 if missing(diab_onset) & diab_ever == 0
replace fdiabe50 = 0 if (diab_onset - rabyear > 50) & !missing(diab_onset)
replace fdiabe50 = 1 if (diab_onset - rabyear <= 50) 

count if fdiabe50 == . & diab_ever == 1
di "We'll need to impute year of diabetes onset for `r(N)' cases"

gen fdiabe50_imp = (fdiabe50 == . & diab_ever == 1)

hotdeck fdiabe50, by(ragender hacohort diab_ever) keep(hhidpn) store  seed(`seed')
drop fdiabe50
merge hhidpn using imp1.dta, sort
drop _merge
rm imp1.dta

**************************************************************************************************
**** Cancer diagnosis at age 50? 
*** Questions regarding cancer dx dates differ depending on the wave, and in some cases goes back
*** to the second last cancer dx. We take minimum date

gen rycanc = v339 if v339 > 1900 & v339 < 3000 

foreach x in w352 w342 d814 e814 f1141 g1274 hc028 jc028 kc028 lc028 MC028 nc028 oc028 {
	replace rycanc = min(rycanc,`x') if `x' > 1900 & `x' < 3000 
}
gen age_cancdx = rycanc - rabyear

** when date not available, but cancer ever flag switches from no to yes, use age at switching
gen evflag=r1cancre

forvalues x=2/$lastwave {
	replace age_cancdx = r`x'agey_e if rycanc==. & (evflag==0) & r`x'cancre==1
	replace rycanc = r`x'agey_e + rabyear if rycanc==. & (evflag==0) & r`x'cancre==1
	replace evflag = r`x'cancre if r`x'cancre !=.
}
drop evflag
label var rycanc "Earliest year known of cancer dx" 
egen canc_ever = rowmax(r*cancre) 

***** count discrepancies
gen discr= (canc_ever == 0 & rycanc <.)  
tab discr,missing
drop discr
gen discr = (r1cancre==1&v338==0)|(r2cancre==1&w341==0)|(r3cancre==1&e807==0)|(r4cancre==1&f1135==0)|(r5cancre==1&g1268==0)|(r6cancre==1&hc025==0)
tab discr,missing
drop discr
*****
** adjust canc_ever flag when cancer dx year is available
replace canc_ever = 1 if rycanc <.

gen fcanc50 = .
replace fcanc50 = 0 if missing(rycanc) & canc_ever == 0
replace fcanc50 = 1 if (rycanc - rabyear <= 50) & !missing(rycanc) 
/* There might be more than one cancer dx on the same date - at this stage we assume this is not the case */
replace fcanc50 = 0 if (rycanc - rabyear > 50) & ((w341==1 & w342 <9000) | (w341==2 & w352 <9000) | (d807==1 & d814<9000) | (e807==1 & e814<9000) | (f1135==1 & f1141<9000) | (g1268==1 & g1274<9000) | (hc025==1 & hc028<9000) )
tab fcanc50 canc_ever,missing

count if fcanc50 == . & canc_ever == 1
di "We still have some uncertainty about age for first cancer dx in `r(N)' cases"
gen fcanc50_imp = (fcanc50 == . & canc_ever == 1)
*** Assume the date for cancer dx (last or second to last cancer) was the first cancer dx - check in upstream program with sensitive data from Adams study
replace fcanc50=0 if fcanc50_imp==1 & age_cancdx <.
tab fcanc50 canc_ever,missing

gen fcanc50_imphd = (fcanc50 == . & canc_ever == 1)

hotdeck fcanc50, by(ragender hacohort canc_ever) keep(hhidpn) store  seed(`seed')
drop fcanc50
merge hhidpn using imp1.dta, sort
drop _merge
rm imp1.dta

label var fcanc50 "Cancer status at age 50 (1/0)-imputed"
label var fcanc50_imp "Flag of cancer status at age 50 imputed based on last two diagnosis date" 
label var fcanc50_imphd "Flag of cancer status at age 50 imputed using hotdeck method by gender and cohort"
tab fcanc50 fcanc50_imp,missing
tab fcanc50_imphd fcanc50_imp,missing

**************************************************************************************************
**** Heart problems at age 50? 
*** Use heart problems flag changes from wave to wave, and earliest date known of heart attack (there may have been others before)
*** use earlier answers first when available (probably more accurate since it's closer to the fact)

gen ryheartat = v408 if v408 > 1900 & v408 < 3000

foreach x in w370 d839 e839 f1166 g1299 hc043 kc043 lc043 MC043 nc043 oc043 {

	replace ryheartat = `x' if ryheartat==. & `x' > 1900 & `x' < 3000
}
label var ryheartat "Earliest year known of heart attack"

egen heartpr_ever = rowmax(r*hearte)
gen ry1heartpr=.
gen ryheartpr=.
label var ry1heartpr "Year of first heart problem"
label var ryheartpr "Earliest year know of heart problem"
gen evflag=r1hearte
forvalues x=2/$lastwave {
	disp `x'
	replace ry1heartpr = r`x'agey_e+rabyear if (evflag==0 & r`x'hearte==1) 
	replace ryheartpr = r`x'agey_e+rabyear if (evflag==0 & r`x'hearte==1) | (evflag==. & r`x'hearte==1)
	replace evflag=r`x'hearte if r`x'hearte !=.
}
drop evflag

** Use heart attack info to adjust heart problem year
replace ryheartpr=min(ryheartpr,ryheartat)
replace ry1heartpr=min(ry1heartpr,ryheartat)

** count discrepancies
gen discr = heartpr_ever ==0 & ryheartpr<.
tab discr,missing
drop discr

** assume heart problems if date for heart attack present
replace heartpr_ever = 1 if ryheartpr<.

gen age_heartpr=ryheartpr-rabyear
gen age_1heartpr=ry1heartpr-rabyear

gen fheart50 = 1 if age_1heartpr <=50 
replace fheart50 = 0 if missing(ryheartpr) & heartpr_ever == 0

count if fheart50 == . & heartpr_ever == 1
di "We still have some uncertainty about age for first heart problem in `r(N)' cases"
gen fheart50_imp = (fheart50 == . & heartpr_ever == 1)

*** Assume the date for heart problem falls on the date observed - check in upstream program with sensitive data from Adams study
replace fheart50=0 if fheart50_imp==1 & age_heartpr<.
gen fheart50_imphd = (fheart50 == . & heartpr_ever == 1)

hotdeck fheart50, by(ragender hacohort heartpr_ever) keep(hhidpn) store seed(`seed')
drop fheart50
merge hhidpn using imp1.dta, sort
drop _merge
rm imp1.dta

label var fheart50 "Heart problem status at age 50 (1/0)-imputed"
label var fheart50_imp "Flag of heart problem status at age 50 imputed based on last diagnosis date" 
label var fheart50_imphd "Flag of heart problem status at age 50 imputed using hotdeck method by gender and cohort"

tab fheart50 fheart50_imp,missing
tab fheart50_imphd fheart50_imp,missing

**************************************************************************************************
*** Health as a child variable

gen hlth_chld=f992
replace hlth_chld=. if inlist(hlth_chld,8,9,.)
replace hlth_chld=e5648 if missing(hlth_chld) & !inlist(e5648,8,9,.)
replace hlth_chld=g1079 if missing(hlth_chld) & !inlist(g1079,8,9,.)
replace hlth_chld=hb019 if missing(hlth_chld) & !inlist(hb019,8,9,.)
replace hlth_chld=jb019 if missing(hlth_chld) & !inlist(jb019,8,9,.)
replace hlth_chld=kb019 if missing(hlth_chld) & !inlist(kb019,8,9,.)
replace hlth_chld=lb019 if missing(hlth_chld) & !inlist(lb019,8,9,.)
replace hlth_chld=MB019 if missing(hlth_chld) & !inlist(MB019,8,9,.)
replace hlth_chld=nb019 if missing(hlth_chld) & !inlist(nb019,8,9,.)
replace hlth_chld=ob019 if missing(hlth_chld) & !inlist(ob019,8,9,.)


tab hacohort hlth_chld,missing

gen hlth_chld_imp = (hlth_chld == .)

hotdeck hlth_chld, by(ragender hacohort) keep(hhidpn) store seed(`seed')
drop hlth_chld
merge hhidpn using imp1.dta, sort
drop _merge
rm imp1.dta

label var hlth_chld "Health as a child-imputed"
label var hlth_chld_imp "Flag of Health as a child imputed w/hotdeck method by gender and cohort"

tab hacohort hlth_chld,missing
**************************************************************************************************
*** Generate initial value at age 50 for Stroke
gen fstrok50=.
forvalues x= 1/$lastwave {
	replace fstrok50=1 if r`x'stroke==1 & r`x'agey_e<=50
	replace fstrok50=0 if r`x'stroke==0 & fstrok50==.
}
tab fstrok50,missing

gen fstrok50_imp = fstrok50==.
hotdeck fstrok50, by(ragender hacohort) keep(hhidpn) store seed(`seed')
drop fstrok50
merge hhidpn using imp1.dta, sort
drop _merge
rm imp1.dta

label var fstrok50 "Stroke status at age 50 (1/0)-imputed"
label var fstrok50_imp "Flag of stroke status at age 50 imputed w/hotdeck method by gender and cohort" 

tab fstrok50 fstrok50_imp,missing

**************************************************************************************************
*** Generate initial value at age 50 for High Blood Preasure 
*** TOO MANY CASES FOR IMPUTATION - NEED TO REVISE****

gen fhibp50=.
forvalues x= 1/$lastwave {
	replace fhibp50=1 if r`x'hibpe==1 & r`x'agey_e<=50
	replace fhibp50=0 if r`x'hibpe==0 & fhibp50==.
}
tab fhibp50,missing

gen fhibp50_imp = fhibp50==.
hotdeck fhibp50, by(ragender hacohort) keep(hhidpn) store seed(`seed')
drop fhibp50
merge hhidpn using imp1.dta, sort
drop _merge
rm imp1.dta

label var fhibp50 "High blood preasure status at age 50 (1/0)-imputed"
label var fhibp50_imp "Flag of high blood preasure status at age 50 imputed w/hotdeck method by gender and cohort" 

tab fhibp50 fhibp50_imp,missing

**************************************************************************************************
*** Generate initial value at age 50 for lung disease
gen flung50=.
forvalues x= 1/$lastwave {
	replace flung50=1 if r`x'lunge==1 & r`x'agey_e<=50
	replace flung50=0 if r`x'lunge==0 & flung50==.
}
tab flung50,missing

gen flung50_imp = flung50==.
hotdeck flung50, by(ragender hacohort) keep(hhidpn) store seed(`seed')
drop flung50
merge hhidpn using imp1.dta, sort
drop _merge
rm imp1.dta

label var flung50 "Lung disease status at age 50 (1/0)-imputed"
label var flung50_imp "Flag of lung disease status at age 50 imputed w/hotdeck method by gender and cohort" 

tab flung50 flung50_imp,missing

**************************************************************************************************

/* Constructing if the respondent smoked at age 50 */
gen stopyear92 = .
gen stopyear98 = .
gen stopyear00 = .
gen stopyear02 = .
gen stopyear04 = .
gen stopyear06 = .
gen stopyear08 = .
gen stopyear10 = .
gen stopyear12 = .
gen stopyear14 = .

* For 1992 respondents - how many years ago when stopped (conditional on being a former smoker)
replace stopyear92 = (year(r1iwbeg) - v504) if (r1smokev == 1 & r1smoken == 0)

* For 1998 respondents
* stopped smoking ____ years ago
replace f1278 = 0 if f1278 == 96
replace f1278 = . if f1278 == 98
replace stopyear98 = (year(r4iwbeg) - f1278)
* stopped in ___ year
replace f1279 = . if f1279 == 9998
replace stopyear98 = f1279
* stopped when ____ years old
replace stopyear98 = rabyear + f1280

* For 2000 respondents
* stopped smoking ____ years ago
replace g1411 = 0 if g1411 == 96
replace g1411 = . if g1411 == 98
replace stopyear00 = (year(r5iwbeg) - g1411)
* stopped in ___ year
replace g1412 = . if g1412 == 9998
replace stopyear00 = g1412
* stopped when ____ years old
replace stopyear00 = rabyear + g1413

* For 2002 respondents
replace hc125 = 0 if hc125 == 96
replace hc125 = . if hc125 == 98
replace stopyear02 = (year(r6iwbeg) - hc125)
* stopped in ___ year
replace hc126 = . if hc126 == 9998
replace stopyear02 = hc126
* stopped when ____ years old
replace stopyear02 = rabyear + hc127

* For 2004 respondents
replace jc125 = 0 if jc125 == 96
replace jc125 = . if jc125 == 98
replace jc125 = . if jc125 == 99
replace stopyear04 = (year(r7iwbeg) - jc125)
* stopped in ___ year
replace jc126 = . if jc126 == 9998
replace stopyear04 = jc126
* stopped when ____ years old
replace stopyear04 = rabyear + jc127

* For 2006 respondents
replace kc125 = 0 if kc125 == 96
replace kc125 = . if kc125 == 98
replace kc125 = . if kc125 == 99
replace stopyear06 = (year(r8iwbeg) - kc125)
* stopped in ___ year
replace kc126 = . if kc126 == 9998
replace stopyear06 = kc126
* stopped when ____ years old
replace kc127 = . if kc127 == 98
replace stopyear06 = rabyear + kc127

* For 2008 respondents
replace lc125 = 0 if lc125 == 96
replace lc125 = . if lc125 == 98
replace lc125 = . if lc125 == 99
replace stopyear08 = (year(r9iwbeg) - lc125)
* stopped in ___ year
replace lc126 = . if lc126 == 9998
replace stopyear08 = lc126
* stopped when ____ years old
replace lc127 = . if lc127 == 98
replace stopyear08 = rabyear + lc127

* For 2010 respondents
replace MC125 = 0 if MC125 == 96
replace MC125 = . if MC125 == 98
replace MC125 = . if MC125 == 99
replace stopyear10 = (year(r10iwbeg) - MC125)
* stopped in ___ year
replace MC126 = . if MC126 == 9998
replace stopyear10 = MC126
* stopped when ____ years old
replace MC127 = . if MC127 == 98
replace stopyear10 = rabyear + MC127

* For 2012 respondents
replace nc125 = 0 if nc125 == 96
replace nc125 = . if nc125 == 98
replace nc125 = . if nc125 == 99
replace stopyear12 = (year(r11iwbeg) - nc125)
* stopped in ___ year
replace nc126 = . if nc126 == 9998
replace stopyear12 = nc126
* stopped when ____ years old
replace nc127 = . if nc127 == 98
replace stopyear12 = rabyear + nc127

* For 2014 respondents
replace oc125 = 0 if oc125 == 96
replace oc125 = . if oc125 == 98
replace oc125 = . if oc125 == 99
replace stopyear14 = (year(r12iwbeg) - oc125)
* stopped in ___ year
replace oc126 = . if oc126 == 9998
replace stopyear14 = oc126
* stopped when ____ years old
replace oc127 = . if oc127 == 98
replace stopyear14 = rabyear + oc127



* Prefer more recent response for stop year
gen stopyear = .
replace stopyear = stopyear14 if stopyear == .
replace stopyear = stopyear12 if stopyear == .
replace stopyear = stopyear10 if stopyear == .
replace stopyear = stopyear08 if stopyear == .
replace stopyear = stopyear06 if stopyear == .
replace stopyear = stopyear04 if stopyear == .
replace stopyear = stopyear02 if stopyear == .
replace stopyear = stopyear00 if stopyear == .
replace stopyear = stopyear98 if stopyear == .
replace stopyear = stopyear92 if stopyear == .

egen smokev = rowmax(r*smokev)
egen smoken = rowmax(r*smoken)

gen fsmoken50 = .
replace fsmoken50 = 0 if smokev == 0
replace fsmoken50 = (stopyear - rabyear >= 50) if smokev == 1 & !missing(stopyear)
replace fsmoken50 = 1 if smoken == 1

count if fsmoken50 == . & smokev == 1
di "We'll need to impute smoking at age 50 status for `r(N)' cases"

gen fsmoken50_imp = (fsmoken50 == . & smokev == 1)

* Impute missing cases (by ragender hacohort smokev produced 90% of imputed cases as fsmoken50 = 1)
hotdeck fsmoken50, by(ragender hacohort) keep(hhidpn) store seed(`seed')
drop fsmoken50
merge hhidpn using imp1.dta, sort
drop _merge
rm imp1.dta

* If still missing fsmoken50 (due to smokev = .m, smoken = 0), set to 0
replace fsmoken50 = 0 if missing(fsmoken50) & missing(smokev) & smoken==0
* Clean up some variables
drop smokev smoken stopyear*


*** Claiming social security retirement
/*
* FROM SHAWN
                                      Cumulative    Cumulative
finalflag    Frequency     Percent     Frequency      Percent
--------------------------------------------------------------
        D        2100        6.95          2100         6.95  
        E         571        1.89          2671         8.85  
        M        7561       25.04         10232        33.88  
        N        9869       32.68         20101        66.57  
        V        9419       31.19         29520        97.76  
        W         677        2.24         30197       100.00  
*/

gen clmwv = .
forvalues i = $firstwave/$lastwave {
	cap drop claim`i'
	gen iwyear`i' = year(r`i'iwbeg)
	gen ssclaim`i' =  iwyear`i' >= ssretbegyear if iwyear`i' < . & inlist(finalflag, .v)
	replace ssclaim`i' = 0 if inlist(finalflag,.n) & r`i'iwstat == 1
	* replace ssclaim`i' = iwyear`i'- rabyear >=65 if inlist(finalflag,.d)& r`i'iwstat == 1
	replace ssclaim`i' = r`i'agey_e >= 65 if inlist(finalflag,.d)& r`i'iwstat == 1

	 
	* replace ssclaim`i' = iwyear`i'- rabyear >= 62 if inlist(finalflag,.e)& r`i'iwstat == 1
	replace ssclaim`i' = r`i'agey_e >= 62 if inlist(finalflag,.e)& r`i'iwstat == 1
	
	*************
	* Sep 14,2008
	replace ssclaim`i' = r`i'isret > 0 & r`i'agey_e >= 62 if inlist(finalflag,.m)& r`i'iwstat == 1	
	replace ssclaim`i' = r`i'isret > 0 & r`i'agey_e >= 50 if inlist(finalflag,.w)& r`i'mstat != 1 & r`i'iwstat == 1
	*************	
	
	replace clmwv = `i' if ssclaim`i' == 1 & clmwv == .
	drop iwyear`i'
}

*** Make sure ssclaim is absorbing
forvalues i = $firstwave/$lastwave {
		replace ssclaim`i' = 1 if `i' >= clmwv & r`i'iwstat == 1
}

*** Determine year when benefits first claimed at the end of the 2004
gen rclyr = ssretbegyear if inlist(finalflag, .v)
replace rclyr = rabyear + 65 if finalflag == .d 
replace rclyr = rabyear + 62 if finalflag == .e
replace rclyr = 2100 if finalflag == .n
forvalues i = $firstwave/$lastwave {
	* replace rclyr = min(rabyear + 65, year(r`i'iwbeg)) if clmwv == `i' & inlist(finalflag, .m, .w)

	*************
	* Sep 14,2008
 	replace rclyr = year(r`i'iwbeg) if clmwv == `i' & inlist(finalflag, .m, .w)
	*************	
}


/* Bryan's alternate derivation of Social Security claiming, based on receiving SS Retirement Income 
forvalues i = $firstwave/$lastwave {
	gen ssclaim_b`i' = (r`i'iosret == 1 ) if !missing(r`i'iosret)
	gen ssclaim_c`i' = ssclaim_b`i'
	* Replace SS claiming of those under 62 (not yet eligible)
	count if ssclaim_c`i' == 1 & r`i'agey_e < 62
	replace ssclaim_c`i' = 0 if ssclaim_b`i' == 1 & r`i'agey_e < 62
}
*/

**********************
**Feb 2015 -Use variables from HRS Wealth&Income data to generate SS and DI claiming
**********************
* Social Security Retirement claim 
* Replace SS claiming for those under 62 (not yet eligible)

forvalues x = 1/12 {
	replace ssclaim`x' = .
	replace ssclaim`x' = (r`x'ioss == 1) if !missing(r`x'ioss)
	count if ssclaim`x' == 1 & r`x'agey_e < 62
	replace ssclaim`x' = 0 if ssclaim`x' == 1 & r`x'agey_e < 62	
}

/* Disability claim from Wealth&Income data
forvalues x = 1/12 {
	gen diclaim_n`x' = (r`x'iosdi == 1) if !missing(r`x'iosdi)
}
*/


*** Determine tenure for the current job for those with DB pension benefits (hacohort == 3 or 4 or 5 or 6)
gen db_tenure = .
forvalues j = $firstwave/$lastwave {
	replace db_tenure = r`j'jcten if r`j'work == 1 & inlist(hacohort,3,4,5,6) & anydb == 1 & !missing(r`j'jcten)
}
replace db_tenure = -2 if inlist(hacohort,0,1,2) | anydb != 1

*** CONVERT WAVE 1 AND PART OF WAVE 2 DATA INTO BIENNIAL 
	foreach v in oopmd doctim hsptim hspnit { 
		cap replace r1`v' = r1`v' * 2 
		cap replace r2`v' = r2`v' * 2 if hacohort == 1
	}

*** Examine the data
	tab hacohort anydb,m 
	tab hacohort anydc,m
	forvalues i = $firstwave/`dbwv' {
		tab hacohort dbclaim`i' if r`i'iwstat == 1, m
		tab hacohort diclaim`i' if r`i'iwstat == 1, m
		tab hacohort ssclaim`i' if r`i'iwstat == 1, m 
	}
	
*** Calculate the length of time from previous interview
gen r1iwdelta = .
local firstIWDelta = max(2,$firstwave)
forvalues i =`firstIWDelta'/$lastwave {
	local li = `i' - 1
	gen r`i'iwdelta = (r`i'iwbeg - r`li'iwbeg)/365.25
}

* Generate a child variable specific to the last wave
local temp $lastwave
gen fkids = .
replace fkids = h`temp'child
* Use new nkids variable instead
replace fkids = nkids
drop nkids

*** ------------------------------------------

*** RENAME/GENERATE VARIABLES FOR RESHAPING
	* No first-wave comparable functional status measure
	cap gen r1iadla = r1iadlww >=2 if r1iadlww < .
	cap gen r1adla  = r1adlw   > 0 if r1adlw < . 
	
	* Respondent 
	#d ; 
	foreach var in cenreg mstat wtresp wtcrnh wtr_nh agey_e agem_e iwstat iwbeg momliv dadliv iwdelta
	smokev smoken bmi shlt flone psyche arthre
	cancre hearte heartf hibpe diabe lunge stroke arthre psyche flone alzhe demen
	adla iadla  nrshom nhmliv hosp homcar
	retirecomm retirecomm_continue key_serv other_serv serv key_serv_use other_serv_use serv_use
		oopmd doctim hsptim hspnit
       isret isdi issi issdi iearn sayret lbrf ipena iunwc igxfr 
	work work2 jhours jhour2 jweeks jweek2 wgihr wgiwk 	
	govmd govmr higov covr covs hiothp covrt hiltc lifein memrye wthh jcten
        bathh dressh walkrh helperct helphoursyr helphoursyr_sp helphoursyr_nonsp volhours nkids gkcarehrs kid_byravg kid_mnage nkid_liv10mi
        isemp iosemp ioss iosdi iossi     
        parhelphours paralive parnotmar par10mi
        malive falive mlivage flivage mmarried fmarried mliv10mi fliv10mi
	cesd cesdm proxy toilta peninc jcpen
	caid2yr caidcur
	iadlhelp
	weightnh
	jyears
	binge
	satisfaction
	hearta heartae last_hearta time_lhearta
        hometyp 
        rxchol
	lipidrx
        { ; 
			forvalues i = $firstwave(1)$lastwave { ; 
				cap confirm var r`i'`var'; 
				if !_rc{;
					ren r`i'`var' `var'`i' ; 
				};
			} ; 
	} ; 
	#d cr 	
	
	* Household
	#d ; 
	foreach var in 	hhid icap iothr itot atoth anethb 
	atotf astck achck acd abond aothr  
	arles atran absns aira 
	atota atotb atotn 
	amort ahmln amrtb adebt child
        children10M
        anyproptxa anyproptxb proptxa proptxb
        cpl tcany tcamt iossi
        { ; 
			forvalues i = $firstwave(1)$lastwave { ; 
				cap confirm var h`i'`var'; 
				if !_rc{;
					ren h`i'`var' h`var'`i' ; 
				};
			} ; 
	} ; 
	#d cr 	
	
	* Spouse
	#d ; 
	foreach var in hhidpn iwstat agey_e agem_e wtresp gender mstat racem hispan educ malive falive mlivage flivage mmarried fmarried mliv10mi fliv10mi { ; 
			forvalues i = $firstwave(1)$lastwave { ; 
				cap confirm var s`i'`var'; 
				if !_rc{;
					ren s`i'`var' s`var'`i' ; 
				};
			} ; 
	} ; 
	#d cr
	

*** ------------------------------------------	
*** RESHAPE FROM WIDE FORMAT TO LONG FORMAT
#d;
	reshape long
	cenreg mstat wtresp wtcrnh agey_e agem_e iwstat iwbeg momliv dadliv iwdelta
	smokev smoken bmi shlt
	cancre hearte heartf hibpe diabe lunge stroke alzhe demen
	adla iadla  nrshom nhmliv hosp homcar
	retirecomm retirecomm_continue key_serv other_serv serv key_serv_use other_serv_use serv_use
	oopmd doctim hsptim hspnit
       isret issdi isdi issi iearn ipena iunwc igxfr 
	sayret lbrf work
	govmd govmr higov covr covs hiothp covrt hiltc lifein 
	hhhid
        hcpl
	hicap hiothr hitot 
	hatoth hanethb 
	hatotf hastck hachck hacd habond haothr
	harles hatran habsns haira 
	hatota hatotb hatotn
	hamort hahmln hamrtb hadebt
        hanyproptxa hanyproptxb hproptxa hproptxb
	shhidpn siwstat sagey_e sagem_e swtresp sgender smstat sracem shispan seduc smalive sfalive smlivage sflivage smmarried sfmarried smliv10mi sfliv10mi 
	dbclaim ssclaim diclaim
	htcany htcamt hchild helperct helphoursyr helphoursyr_sp helphoursyr_nonsp volhours nkids gkcarehrs kid_byravg kid_mnage nkid_liv10mi
	isemp iosemp ioss iosdi hiossi
	parhelphours paralive parnotmar par10mi malive falive mlivage flivage mmarried fmarried mliv10mi fliv10mi 
	jlocc jlocca jlind
	memrye wthh
        flone psyche arthre
        bathh dressh walkrh
	cesd cesdm proxy peninc jcpen
	jcten

	/*ssclaim_b ssclaim_c */
	ssiclaim toilta anydb_n
	caid2yr caidcur
	iadlhelp
	weightnh
	jyears
	binge
	satisfaction
	hearta heartae last_hearta time_lhearta
        hometyp 
        rxchol
	lipidrx
	,
	
	i(hhidpn rahrsamp racohbyr hacohort ragender raracem raeduc rahispan rabyear rabmonth ) j(wave);
#d cr

*** RENAME hhhid as hhid, for convenience
	ren hhhid hhid

*** FOR ANY WAVE, THEN USE THE PERVIOUS WAVE'S INFO
	sort hhidpn wave, stable
	tab cenreg, missing
	by hhidpn: replace cenreg = cenreg[_n-1] if missing(cenreg) & iwstat == 1 
	tab cenreg, missing

*** Set as missing for fat-file variables in non-corresponding waves
foreach v of varlist `hrs1fat' {
  replace `v' = . if wave!=1
}

foreach v of varlist `hrs2fat' `ahd1fat' {
  replace `v' = . if wave!=2
}

foreach v of varlist `wave3fat' `ahd2fat' {
  replace `v' = . if wave!=3
}

foreach v of varlist `wave4fat' {
  replace `v' = . if wave!=4
}

foreach v of varlist `wave5fat' {
  replace `v' = . if wave!=5
}

foreach v of varlist `wave6fat' {
  replace `v' = . if wave!=6
}

foreach v of varlist `wave7fat' {
  replace `v' = . if wave!=7
}

foreach v of varlist `wave8fat' {
  replace `v' = . if wave!=8
}

foreach v of varlist `wave9fat' {
  replace `v' = . if wave!=9
}

foreach v of varlist `wave10fat' {
  replace `v' = . if wave!=10
}

foreach v of varlist `wave11fat' {
  replace `v' = . if wave!=11
}

foreach v of varlist `wave12fat' {
  replace `v' = . if wave!=12
}



*** LABEL VARIABLES

	label var hhid 		"Wave specific household ID"
	label var hhidpn 	"R person unique identifier"
	label var iwstat	"R interview status"
	label var wtresp	"R person level weight"
	label var agey_e	"R age in integral years at interview end date"
	label var agem_e	"R age in total months at interview end date"
	label var iwdelta "Years since previous interview, missing if first interview"
	label var wave		"Wave of interview"
	label var cenreg	"Census region"
	label var mstat		"R marital status"
	label var iwbeg		"R interview begin date"
	label var shhidpn	"Spouse unique identifier"
	label var sracem	"Spouse race"
	label var shispan	"Spouse is hispanic"
	label var sgender	"Spouse gender"
	label var seduc		"Spouse education level"
	label var siwstat	"Spouse interview status"
	label var swtresp	"Spouse person level weight"
	label var smstat	"Spouse marital status"
	
	label var smokev 	"R smoke ever"
	label var smoken 	"R smokes now"
	label var bmi 		"R Body mass index"
	label var shlt          "R self-rated health"
	
	label var rxchol	"R takes meds for cholesterol"
	label var cancre 	"R ever had cancer"
	label var cesd		"R depression symptoms within last two weeks"
	label var cesdm		"R missing questions for depression symptoms"
	label var hearte 	"R ever had heart disease"
	label var hibpe 	"R ever had hypertension"
	label var diabe		"R ever had diabetes"
	label var lunge		"R ever had lung disease"
	label var stroke	"R ever had stroke"
	label var memrye	"R memory-related diseases"
	label var adla		"Number of ADL limitations"
	label var iadla		"Number of IADL limitations"
	label var nrshom 	"R had any nursing home stay"
	label var nhmliv        "R live in nursingh ome at interview"
	label var dadliv	"Dad is still alive"
	label var momliv	"Mom is still alive"
	
	label var oopmd 	"R out of pocket Med expenses in reference period"
*	label var totmd 	"R total Med expenses in reference period"
	label var hspnit 	"R number of hospital nights past 2 years"
	label var hsptim 	"R number of hospital stays past 2 years"
	label var doctim 	"R number of doctor visits past 2 years"
	
	label var govmr		"R covered by Medicare"
	label var govmd		"R covered by Medicaid"
	label var higov		"R covered by government HI"
	label var covr		"R covered by R's current or prev employer"
	label var covs		"R covered by S's current or prev employer"
	label var hiothp	"R other type of HI"
	label var hiltc		"R long-term care HI"
	label var lifein	"R life insurance"
	label var covrt		"R employer cover retiree HI"
	
	label var sayret	"R consider self retired"
	label var lbrf		"R labor force status"
	label var work		"R working for pay"
	
	label var iearn   	"Individual earnings"
	
	label var ipena		"Individual pension+annuity"
	label var iunwc		"Individual unemp+worker comp"
	label var igxfr		"Individual other gov transfer"
	label var isret   "income: R SoCSec Retirment"
	label var isdi    "IncPart - SSDI"	
  label var issi		"IncPart - SSI"
	label var hiothr	"HH other income"
	label var hicap		"HH capital income"
	label var hitot		"HH total income"
	
	label var hatota	"HH wealth,excluding secondary res"
	label var hatotb	"HH wealth,including secondary res"
	label var hatotn	"HH wealth,non-housing"
	label var hatotf	"HH non-housing financial wlth"
	label var hatoth	"HH net value of house/prim res"
	label var hanethb	"HH net value of house/sec res"
	label var hastck	"HH assets: stocks"
	label var hachck	"HH assets: checkings,savings acct"
	label var hacd		"HH assets: cds,svbonds,t-bills"
	label var habond	"HH assets: bonds"
	label var haothr	"HH assets: other svngs,assets"
	label var hadebt	"HH assets: other debts"
	label var harles	"HH assets: real estate"
	label var hatran	"HH assets: vehicles"
	label var habsns	"HH assets: business"
	label var haira		"HH assets: IRA(total)"
	
	label var hamort 	"HH mortgage prim res"
	label var hahmln 	"HH home loan"
	label var hamrtb 	"HH mortgage sec res"
	label var hadebt	"HH other debt" 	
	label var dbclaim	"Claiming DB"
	label var diclaim	"Claiming SSDI"
	label var ssclaim	"Claiming OASI - Reports receiving SS retirement income and 62+"
	label var ssiclaim "Claiming SSI"
	label var dcwlth	"DC wealth wv 1to5 only"
	label var anydb		"Any DB from current job RND VG"
	label var anydc		"Any DC from current job RND VG"
	label var ssretbegyear	"SS ret claim beg year"
	label var finalflag	"SS ret claim type flag"
	label var htcany "H Any transfers to children"
	label var htcamt "H Amount transferred to children"
	label var hchild "H Number of living children"
	label var helperct "Number of helpers"
	label var helphoursyr "Imputed total person-hours help received/year"
	label var helphoursyr_sp "Imputed total person-hours help received/year from spouse"
	label var helphoursyr_nonsp "Imputed total person-hours help received/year from non-spouse"
	label var fkids "Number of children, based on 2004 report"
  label var volhours "Imputed hours of volunteer"
  label var catholic "Catholic"
  label var jewish "Jewish"
  label var relnone "No religion"
  label var reloth "Other religion"
  label var rel_notimp "Religion not important"
  label var rel_someimp "Religion somewhat important"
  label var suburb "Lives in suburbs"
  label var exurb "Lives in exurbs" 
  label var nkids "Number of children" 
  label var gkcarehrs "Hours in past 2 years caring for gkids"
  label var kid_byravg "Average birthyear of children" 
  label var kid_mnage "Mean age of children"
  label var nkid_liv10mi "Number of children living within 10 miles"
  label var fmanuf    "Longest industry - manufacturing '04"
  label var fpubadm   "Longest industry - pub admin '04"
  label var fmanage   "Longest held occup - management '04"
  label var fwhtcoll  "Longest held occup - white collar '04"
  label var isemp "Self-employment income"
  label var iosemp	"Receives self-employment income"
  label var parhelphours "Total hours helped own and spouse's parents in past two years"
  label var paralive "Total # living parents - own and inlaws" 
  label var parnotmar "Total # unmarried parents - own and inlaws" 
  label var par10mi "Total # parents living within 10 miles - own and inlaws"
  label var malive    "Mother alive"
  label var falive    "Father alive"
  label var mlivage   "Mother's age if living"
  label var flivage   "Father's age if living"
  label var mmarried  "Mother married"
  label var fmarried  "Father married"
  label var mliv10mi  "Mother live within 10 miles"
  label var fliv10mi  "Father live within 10 miles"
  label var smalive    "Spouse's Mother alive"
  label var sfalive    "Spouse's Father alive"
  label var smlivage   "Spouse's Mother's age if living"
  label var sflivage   "Spouse's Father's age if living"
  label var smmarried  "Spouse's Mother married"
  label var sfmarried  "Spouse's Father married"
  label var smliv10mi  "Spouse's Mother live within 10 miles"
  label var sfliv10mi  "Spouse's Father live within 10 miles"
  label var par10mi_fixed "Respondent ever reported parent living within 10 miles"
  label var fdiabe50 "Diabetes status at age 50 (imputed)"
	label var fdiabe50_imp "flag indicating fdiabe50 was imputed"
	label var fsmoken50 "Smoking status at age 50 (imputed)"
	label var fsmoken50_imp "flag indicating fsmoken50 was imputed"

/*label var ssclaim_b "Reports receiving SS retirement income"
	label var ssclaim_c "Reports receiving SS retirement income and 62+" */
	label var toilta "Some difficulty using toilet"	
	label var anydb_n "Any DB from current job RNDHRS_N"
	label var caid2yr "Covered by Medicaid in past two years (Wave 3+)"
	label var caidcur "Currently covered by Medicaid"
	label var iadlhelp "Gets help with meals, groceries, phone, or medication"
	label var alzhe    "Ever had diagnosis of Alzheimer's disease, starting from wave 10"
	label var demen    "Ever had diagnosis of Dementia, starting from wave 10" 
	label var weightnh "Nursing weight from HRS Tracker file 2000-2012"
	label var jyears "Years Worked"
	lab var retirecomm "living in retirement community/senior citizens' housing/other type of housing that provides services"
	lab var retirecomm_continue "allow continue living even if substantial care needed"
	lab var key_serv "housing provides any services: groupmeal, adl, emerg. call button, nursing care"
	lab var other_serv "housing provides any other services: transportation, housekeeping"
	lab var serv "housing provides any services"
	lab var key_serv_use "using any services: groupmeal, adl, emerg. call button, nursing care"
	lab var other_serv_use "using any other services: transportation, housekeeping"
	lab var serv_use "using any services"
	label var binge "Number of days binge-drank in past three months (waves 4+)"
	label var satisfaction "Life satisfaction (waves 9+)"
	label var rameduc "Mother's education"
	label var rafeduc "Father's education"
	label var first_hearta  "R year of first heart attack"
	label var fhearta_age "R age when first had heart attack"
	label var last_hearta  "R year of most recent heart attack"
	label var time_lhearta "R time since last heart attack"
	label var heartae  "R ever had heart attack"
	label var hearta  "R had heart attack since last wave"	
	label var lipidrx "Regularly taking any cholesterol-lowering medication (wave 8-12)"


*** DROP OBSERVATIONS IF NOT INTERVIEWED(IWSTAT == 0),DIED IN PREVIOUS WAVE(IWSTAT == 6), DK IF DIED (IWSTAT == 9), OR DROPPED FROM SAMPLE (IWSTAT == 7)
	drop if inlist(iwstat, .,0,6,7,9)
	save  "$outdata/hrs_analytic.dta", replace

exit, STATA



