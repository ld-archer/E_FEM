/** \file

Recode variables. This program is to be included in hrs_long.do

- Apr 7, 2007, use RANDHRS Version G
- 9/8/2009 - This program is called from gen_analytic_file.do
 - Add age variables: age_iwe, age, ageexact
 - Remove calculation of age dummies
- 2013, Depressive symptoms (deprsymp) is based on the binary 8-item CESD used in the HRS. A cutoff of 5 is indicated
				by the HRS documentation as the equivalent cutoff to longer forms of the CESD (Steffick, 2000). Alternatively, a 
				cutoff of 4 can be used which more closely matches the estimated prevalence of significant depressive symptoms 
				in the elderly (Blazer and Williams, 1980). 
- 6/18/2014 Update to use version M 1) totmd no longer imputed, 

\todo fix the recoding of the social health variables so that they are much more compact.
*/
include common.do

use $outdata/hrs_analytic.dta
local seed 31415

*===================*
* HEALTH-REALTED
*===================*
*** BMI STATUS
	gen obese = 0*bmi
	replace obese = 1 if bmi >=30 & bmi < .
	label var obese "whether obese (bmi>=30)"
	
	gen overwt = 0*bmi
	replace overwt = 1 if bmi >= 25 & bmi < 30
	label var overwt "whether over weight (25<=bmi<30)"
	
	gen normalwt = 0*bmi
	replace normalwt = 1 if bmi >= 18.5 & bmi < 25
	label var normalwt "whether normal weight (18.5<=bmi<25)"
	
	generate underwt = 0*bmi
	replace underwt = 1 if bmi < 18.5 & bmi > 0
	label var underwt "whether under-weight (bmi<18.5)"
	
	gen wtstate = 0*bmi
	replace wtstate = 1 if underwt  == 1 | normalwt == 1
	replace wtstate = 2 if overwt == 1
	replace wtstate = 3 if obese == 1
	label var wtstate "bmi status"
	label define wtlb 1 "1 normal or underwt" 2 "2 overweight" 3 "3 obese", modify
	label values wtstate wtlb

*** FUNCTIONAL STATUS,IGNORING NURSING HOME
	* recode ADL status variable to use 6 ADLs instead of the 5 ADLs in RAND HRS adla variable
	* toilet difficulty is not asked in waves 1 and 2H, so adlstat is 0-5 in these waves
	gen adla_new = adla
	replace adla_new = adla + toilta if !missing(adla) & !(wave <= 2 & inlist(hacohort,0,3) & missing(toilta))
	label var adla_new "Number of ADL w/ some difficulty 0-6 (0-5 in waves 1 & 2H)"
	di "Change in number of ADLs after including some diff. w/ toilet (1998-):"
	tab adla adla_new if wave>=4, m row

	/*Nursing home is missing in first two waves */
        recode adla_new (0=1) (1=2) (2=3) (nonmissing=4) (missing=.), gen(adlstat)
        recode iadla (0=1) (1=2) (nonmissing=3) (missing=.), gen(iadlstat)
        drop adla adla_new iadla

*** CESD - depressive symptoms
	tab cesd, missing
	recode cesd (missing=.), gen(cesdstat)
	
	gen deprsymp = cesdstat
	replace deprsymp = cesd >= 5 if !missing(cesdstat)

*** DIED OR NOT IN THIS WAVE
	gen died = iwstat
	recode died (0 6 9 = .) (1 4 = 0) (2 3 5 = 1) 
	label var died "whether died or not in this wave"

*** Nursing home residency set as zero in wave 1 and 2
	replace nhmliv = 0 if (wave == 1 | wave == 2) & iwstat == 1
	
*** DI claim not valid for those above NRA
	**variable from incwlth HRS data
	* Generate variable reflecting Social Security normal retirement age based on birth year
	gen ss_nra = .
	replace ss_nra = 65 if rabyear <= 1937
	replace ss_nra = 65 + 2/12 if rabyear == 1938
	replace ss_nra = 65 + 4/12 if rabyear == 1939
	replace ss_nra = 65 + 6/12 if rabyear == 1940
	replace ss_nra = 65 + 8/12 if rabyear == 1941
	replace ss_nra = 65 + 10/12 if rabyear == 1942
	replace ss_nra = 66 if rabyear >= 1943 & rabyear < 1955
	replace ss_nra = 66 + 2/12 if rabyear == 1955
	replace ss_nra = 66 + 4/12 if rabyear == 1956
	replace ss_nra = 66 + 6/12 if rabyear == 1957
	replace ss_nra = 66 + 8/12 if rabyear == 1958
	replace ss_nra = 66 + 10/12 if rabyear == 1959
	replace ss_nra = 67 if rabyear >= 1960	
	
	* Recode DI claim if above NRA
	replace diclaim =0 if ((agey_e >= ss_nra)) & iwstat == 1
	drop ss_nra 

*** Year of retirement not available
	replace ssretbegyear = -1 if ssretbegyear > 9999
	
*** Recode flag of retirement year availability
	replace finalflag = 1 if finalflag == .d 
	replace finalflag = 2 if finalflag == .e 
	replace finalflag = 3 if finalflag == .m 
	replace finalflag = 4 if finalflag == .n 
	replace finalflag = 5 if finalflag == .v 
	replace finalflag = 6 if finalflag == .w 
	
	#d; 
	ren finalflag ssretflag;
	label define flaglb 1 "1 DI recipients(start ssret at NRA" 2 "2 Earlier than 62(start ssret at 62)" 
		3 "3 Missing year" 4 "4 non-claimers" 5 "5 valid begin date(62-70)" 6 "6 Widows" 9 "-9 other missing", modify;
	#d cr
	label values ssretflag flaglb
	
*** Recode self-reported health
        gen srh = shlt
        label var srh "Self Reported Health [1-5]"
	recode shlt (1/3 = 0) (4/5 = 1)
	local vl: value label shlt
*	label drop `vl'
	label var shlt "Health fair/poor"
	label define shltlb 0 "0 E/VG/G" 1 "1 F/P", modify
	label values shlt shltlb
	
	* Life satisfaction
	replace satisfaction = . if inlist(satisfaction,8,9)
	label define satisfaction 1 "completely satisfied" 2 "very satisfied" 3 "somewhat satisfied" 4 "not very satisfied" 5 "not at all satisfied"
	label values satisfaction satisfaction

*** Recode smoking status
///!\bug Current smokers are being double-counted as current and ever, at least until the first run. smkstat is correct, though.
	gen smkstat = smokev + 1
	replace smkstat = 3 if smoken == 1
	replace smkstat = . if missing(smokev) | missing(smoken)
	label define smklb 1 "1 Never smoked" 2 "2 Ex smoker" 3 "3 Cur smoker", modify
	label values smkstat smklb
	label var smkstat "Smoking status"
	
*** Recode pain variables from fat files
*** waves 1 and 3 ask the most pain question only if the worst pain is moderate or severe. pain severity (painstat) is set to mild in these cases
*** Ahead 1 doesn't ask a follow up question about pain severity. Set to -2 to avoid dropping the observations. Only affects wave 2
gen pain = .
gen worstpain = .
gen mostpain = .
gen painstat = .

foreach v of varlist b292 v440 d911 w437 e911 f1239 g1372 hc104 jc104 kc104 lc104 MC104 nc104 oc104{
 recode `v' (1=1) (5=0) (else=.)
 replace pain = `v' if !missing(`v')
}

foreach v of varlist v441 d912 e912 {
 recode `v' (1=1) (2=2) (3=3) (else=.)
 replace worstpain = `v' if !missing(`v')
}

foreach v of varlist v442 d913 w438 e913 f1241 g1372 g1374 hc105 jc105 kc105 lc105 MC105 nc105 oc105{
 recode `v' (1=1) (2=2) (3=3) (else=.)
 replace mostpain = `v' if !missing(`v')
}

replace painstat = 0 if pain == 0
replace painstat = 1 if worstpain == 1
replace painstat = mostpain if missing(painstat)
replace painstat = -2 if wave==2 & b292==1 & missing(worstpain) & missing(mostpain) & missing(painstat)
recode painstat (0=1) (1=2) (2=3) (3=4) (missing=.)
tab wave painstat, m

label variable painstat "R level of pain most of the time"
label define pnstatlb 1 "None" 2 "Mild" 3 "Moderate" 4 "Severe"
label values painstat pnstatlb

*********************************
* HRS utilization measures
*********************************

*** Hospital nights
* Missings we are filling
tab hspnit if missing(hspnit), m
sum hspnit, detail

* Special missings (d,m,r)
gen hspnit_hold = hspnit
* Fill in the .d, .m, and .r missing
replace hspnit = . if inlist(hspnit_hold,.d,.m,.r)
hotdeck hspnit, by(hacohort ragender) keep(hhidpn wave) store seed(`seed')
drop hspnit
merge 1:1 hhidpn wave using imp1.dta
drop _merge
rm imp1.dta
	
* Replace the missing that weren't special missings
replace hspnit = hspnit_hold if inlist(hspnit_hold,.)

* Missings we are left with
tab hspnit if missing(hspnit), m
sum hspnit, detail



*** Doctor's visits
/* Lots of special missings (d,e,f,g,h,i,j,k,l,m,r)
.E indicates 1-4 times
.F indicates 6-19 times
.G indicates 21-49 times
.H indicates 51 or more times
.I indicates at least once
.J indicates 0-5 times
.K indicates 1-19 times
.L indicates 21 or more times
*/

* Create indicators for the special missing cases and set the variable to regular missing

* Missings we are filling
tab doctim if missing(doctim), m
sum doctim, detail

gen doctim_hold = doctim
foreach mvar in e f g h i j k l {
	gen doctim_`mvar' = 0
	replace doctim_`mvar' = 1 if doctim == .`mvar'
	replace doctim = . if doctim == .`mvar'
}

* Create indicators for the special missing categories and then hotdeck
replace doctim_e = inrange(doctim,1,4) if !missing(doctim)
replace doctim_f = inrange(doctim,6,19) if !missing(doctim)
replace doctim_g = inrange(doctim,21,49) if !missing(doctim)
replace doctim_h = (doctim >= 51) if !missing(doctim)
replace doctim_i = (doctim >= 1)  if !missing(doctim)
replace doctim_j = inrange(doctim,0,5) if !missing(doctim)
replace doctim_k = inrange(doctim,1,19) if !missing(doctim)
replace doctim_l = (doctim >= 21) if !missing(doctim)

quietly {
	* Hotdeck each special missing from appropriate matches
	foreach mvar in e f g h i j k l {
		di "mvar is `mvar'"
		tab doctim if missing(doctim), m
		replace doctim = . if doctim_hold == .`mvar'
		tab doctim if missing(doctim), m
		hotdeck doctim, by(doctim_`mvar') keep(hhidpn wave) store seed(`seed')
		drop doctim
		merge 1:1 hhidpn wave using imp1.dta
		drop _merge
		rm imp1.dta
	}
	* Return the other special missings to their non-imputed state
	replace doctim = doctim_hold if inlist(doctim_hold,.,.d,.m,.r)
	
	* Fill in the .d, .m, and .r missing
	replace doctim = . if inlist(doctim_hold,.d,.m,.r)
	hotdeck doctim, by(hacohort ragender) keep(hhidpn wave) store seed(`seed')
	drop doctim
	merge 1:1 hhidpn wave using imp1.dta
	drop _merge
	rm imp1.dta
	
	* Replace the missing that weren't special missings
	replace doctim = doctim_hold if inlist(doctim_hold,.)

	* Clean up the temporary variables
	drop doctim_hold
	drop doctim_e-doctim_l
}

* Missings we are left with
tab doctim if missing(doctim), m
sum doctim, detail

*==================================*
* DEMOGRAPHICS
*==================================*
*** RACE/ETHNICITY
	ren rahispan hispan
	generate black = 0*raracem
	replace black = 1 if raracem == 2 & hispan == 0
	label var black "Non-hispanic black"
	
	gen white = 0*raracem
	replace white = 1 if raracem == 1 & hispan == 0
	label var white "Non-hispanic white"

*** EDUCATIONAL LEVEL
	generate hsless = 0*raeduc
	replace  hsless = 1 if raeduc == 1
	label var hsless "Less than high school"
	
	generate hsgrad = 0*raeduc
	replace  hsgrad = 1 if raeduc == 2 | raeduc == 3
	label var hsgrad "High school graduate"
	
	generate somecol = 0*raeduc
	replace  somecol = 1 if raeduc == 4
	label var somecol "Some college"
	
	generate collgrad = 0*raeduc
	replace  collgrad = 1 if raeduc == 5
	label var collgrad "College graduate"
	
	generate college = 0*raeduc
	replace  college = 1 if raeduc == 4 | raeduc == 5
	label var college "Some college and above"


	*** Categorical education variable
	gen educ = 2 - hsless + college
	label var educ "Education recoded"
	
	* Education to be consistent with FAM
	recode raeduc (1 = 1) (2 = 1) (3 = 2) (4 = 3) (5 = 3), gen(educ_fam)
	label define educ_fam 1 "ltHS/GED" 2 "high school" 3 "some college+"
	label values educ_fam educ_fam
	label var educ_fam "Education ltHS/GED, high school, some college+"
	
	
	generate male = 0*ragender
	replace  male = 1 if ragender == 1
	label var male "Male"
	

*** RENAME AGE
rename rabmonth rbmonth

	gen age_iwe = agem_e / 12
	label var age_iwe "exact age at the end of interview"
	
	gen age_yrs = int((wave-1)*2 + 1992 - rabyear + (7-rbmonth)/12)
	label var age_yrs "Age in years at July 1st"
	
	gen age = (wave-1)*2 + 1992 - rabyear + (7-rbmonth)/12
	label var age "Exact Age at July 1st"
	
        recode age (51/54=1) (55/59=2) (60/64=3) (65/69=4) (70/74=5) (nonmiss=6), gen(agecat)

* Recode religion variables for early waves where we haven't pulled in the data yet 
replace catholic    = 0 if catholic == . & (wave == 1 | wave == 2 | wave == 3)  
replace jewish      = 0 if jewish == . & (wave == 1 | wave == 2 | wave == 3)
replace reloth      = 0 if reloth == . &  (wave == 1 | wave == 2 | wave == 3)
replace relnone     = 0 if relnone == . & (wave == 1 | wave == 2 | wave == 3)
replace rel_notimp  = 0 if rel_notimp == . & (wave == 1 | wave == 2 | wave == 3)
replace rel_someimp = 0 if rel_someimp == . & (wave == 1 | wave == 2 | wave == 3)

replace suburb = 0 if suburb == . & (wave == 1 | wave == 2 | wave == 3)
replace exurb  = 0 if exurb == . & (wave == 1 | wave == 2 | wave == 3) 


*** MARITAL STATUS
/*
           1 1. married
           2 2. married, spouse absent
           3 3. partnered
           4 4. separated
           5 5. divorce
           6 6. separated/divorced
           7 7. widowed
           8 8. never married

*/
	gen married = inlist(mstat, 1,2,3) if mstat < 999
	gen widowed = mstat == 7 if mstat < 999
	gen single = inlist(mstat, 4,5,6,8) if mstat < .
	recode mstat (1 2 3 = 1) (7 = 2) (4 5 6 8 = 3) (nonmissing = .), gen(rmstat)
	label define mrfmt 1 "married/partnered" 2 "widowed" 3 "divorce/separated/single", modify
	label values rmstat mrfmt
	label var rmstat "Marital status"
	label var married "Married"
	label var widowed "Widowed"
	label var single  "Single"

// Most of the RAND HRS production work uses the HCPL variable to determine whether there is a couple household, not the marital status, so let's use that information
// This won't necessarily change anyone's status, but it will make the marital status codes more robust and confirm that they match the RAND HRS usage.
replace married = 1 if hcpl==1 & !missing(hcpl)
replace single = 0 if hcpl==1 & !missing(hcpl)
replace widowed = 0 if hcpl==1 & !missing(hcpl)

*** CENSUS REGION
	gen regnth = cenreg == 1 if inrange(cenreg,1,5)
	label var regnth "Census reg-North"
	
	gen regmid = cenreg == 2 if inrange(cenreg,1,5)
	label var regmid "Census reg-Midwest"
	
	gen regsth = cenreg == 3 | cenreg == 5 if inrange(cenreg,1,5)
	label var regsth "Census reg-South or Other"
	
	gen regwst = cenreg == 4 if inrange(cenreg,1,5)
	label var regwst "Census reg-West"

/*
*** GROUPING BY HISPANIC ORIGIN,WHITE OR NOT,AND GENDER
	gen dmgrp = 1 if hispan == 1 & male == 0
	replace dmgrp = 2 if hispan == 1 & male == 1
	replace dmgrp = 3 if hispan == 0 & black == 1 & male == 0
	replace dmgrp = 4 if hispan == 0 & black == 1 & male == 1
	replace dmgrp = 5 if hispan == 0 & black == 0 & male == 0
	replace dmgrp = 6 if hispan == 0 & black == 0 & male == 1
	label var dmgrp "Race/ethnicity and gender group"

	#d ; 
	label define dmlb 
		1 "1 Hispan-female" 2 "2 Hispan-male" 3 "3 NonH black-female" 
		4 "4 NonH black-male" 5 "5 NonH non black-female" 6 "6 NonH non black-male", modify ; 
	#d cr
	label values dmgrp dmlb 
	tab dmgrp, m
*/


*** NATIVITY
gen bornus = rabplace
recode bornus (11=0)
replace bornus = 1 if 1 <= rabplace & rabplace <= 10
label var bornus "Born in U.S.?"

	
*==================================*
* Labor force
*==================================*
* Working for pay or not : work and lbrf
	replace work = 0 if !inlist(work,0,1) & inlist(lbrf,5,6,7)
* No earnings if not working
	replace iearn = 0 if work == 0
* Commented out: replace work = 0 if iearn == 0 since self-employed might have iearn = 0, but are actually working.
	
* Include self-employment income in iearn
* If report working, report $0 iearn, but have positive self-employment income, assign this value to iearn
	replace iearn = isemp if work == 1 & iearn == 0 & isemp > 0 & !missing(isemp)
	
	
	
// Composing property tax variable
gen proptax = 0 if !hanyproptxa & !hanyproptxb
replace proptax = max(hproptxa, hproptxb, hproptxa + hproptxb) if hanyproptxa | hanyproptxb
replace proptax = proptax/2 if married
label var proptax "Property Taxes Paid"

*==================================*
* Adjust dollar values (in 2010 dollars)
*==================================*
	// generate interview year. income measures are for the last calender year, based on iw year
	gen iwyear = year(iwbeg)
	label var iwyear "interview year"
	tab iwyear wave
	
	// CPI adjusted social security income
	global colcpi "1991 1992 1993 1994 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016"
	#d;
	matrix matcpiu = 
	(136.17,140.31,144.48,148.23,152.38,156.86,160.53,
	163.01,166.58,172.19,177.07,179.84,183.96,188.89,195.27,
	201.6, 207.3, 215.303, 214.537, 218.056, 224.939, 229.60, 233.00, 236.700, 237.00, 239.50);
	#d cr
	
	matrix colnames matcpiu = $colcpi
	matrix list matcpiu
	
	#d ;

foreach var of varlist oopmd
isret issdi isdi issi iearn ipena iunwc igxfr 
hicap
hatoth hanethb 
hatotf hastck hachck hacd habond haothr hadebt 
harles hatran habsns haira 
hatotb hatotn hatota dcwlth
htcamt proptax isemp
hitot
{; 
 replace `var' = matcpiu[1,colnumb(matcpiu,"2010")] * `var'/matcpiu[1,iwyear-1991+1];
};
	#d cr

*==================================*
* Deal with missing values for fkids, possibly deal with values for deceased
*==================================*
replace fkids = hchild if fkids == .
replace fkids = 0 if fkids == .d
replace fkids = 0 if fkids == .m
replace fkids = 0 if fkids == .r
replace fkids = 0 if fkids == .

*==================================*
* Populate waves 1-3 with 0 values for tcany and tcamt, reassign missing values to large, negative numbers
*03/2015 Change to the variables from HRS famr data
*==================================*
replace htcany = 0 if htcany == . & (wave == 1 | wave == 2 | wave == 3) 
replace htcamt = 0 if htcany == . & (wave == 1 | wave == 2 | wave == 3) 
replace htcany = 0 if htcany == . 
replace htcany = 0 if htcany == .d
replace htcany = 0 if htcany == .f
replace htcany = 0 if htcany == .m
replace htcany = 0 if htcany == .r 
replace htcamt = 0 if htcamt == . 
replace htcamt = 0 if htcamt == .d
replace htcamt = 0 if htcamt == .f
replace htcamt = 0 if htcamt == .m
replace htcamt = 0 if htcamt == .r
replace htcamt = 0 if htcamt == .g

// Remove some crazy outliers
replace htcamt = min(htcamt, 1e6)

*==================================*
* Deal with missing values for cesd variables
*==================================*
replace deprsymp = -2 if deprsymp == . 
replace cesdstat = -2 if cesdstat == .
replace cesdm = -2 if cesdm == .
replace deprsymp = 0 if wave == 1
replace cesdstat = 0 if wave == 1
replace cesdm = 0 if wave == 1

*==================================*
* Deal with missing values for helper variables
*==================================*
replace helperct = -9 if helperct == . & (wave == 1 | wave == 2 | wave == 3 ) 
* These might get dropped anyways, as iwstat will be != 1, but keeping for now
replace helperct = -9 if helperct == . & wave > 3
replace helphoursyr = -9 if helphoursyr == . & (wave == 1 | wave == 2 | wave == 3 ) 
replace helphoursyr_sp = -9 if helphoursyr_sp == . & (wave == 1 | wave == 2 | wave == 3) 
replace helphoursyr_nonsp = -9 if helphoursyr_nonsp == . & (wave == 1 | wave == 2 | wave == 3) 
* These might get dropped anyways, as iwstat will be != 1, but keeping for now
replace helphoursyr = -9 if helphoursyr == . & wave > 3
replace helphoursyr_sp = -9 if helphoursyr_sp == . & wave > 3
replace helphoursyr_nonsp = -9 if helphoursyr_nonsp == . & wave > 3

*====================================================
* Deal with missing values for parent help hours
*====================================================
replace parhelphours = -2 if parhelphours == . & (wave == 1 | wave == 2 | wave == 3 | wave==11 | wave ==12) 
replace parhelphours = 0 if parhelphours == . & wave > 3


*==================================*
* Deal with missing values for gkcarehrs volhours kid_byravg kid_mnage
*==================================*
replace gkcarehrs = 0 if gkcarehrs == . & (wave == 1 | wave ==2 | wave == 3 | wave==11 | wave ==12)
replace volhours = 0 if volhours == . & (wave == 1 | wave ==2 | wave == 3 | wave==11 | wave ==12)
replace kid_byravg = 0 if kid_byravg == . & (wave == 1 | wave ==2 | wave == 3 | wave==11 | wave ==12)
replace kid_mnage = 0 if kid_mnage == . & (wave == 1 | wave ==2 | wave == 3 | wave==11 | wave ==12)
replace nkid_liv10mi = 0 if nkid_liv10mi == . & (wave == 1 | wave ==2 | wave == 3 | wave==11 | wave ==12)
* volhours and gkcarehrs should come in capped at the number of hours in 2 years, but just in case . . . 
replace gkcarehrs = 17520 if gkcarehrs > 17520 & gkcarehrs < .
replace volhours = 17520 if volhours > 17520 & volhours < .

*==================================*
* Deal with missing values for alzhe and demen 
*==================================*
replace alzhe = -2 if alzhe == . & wave < 10

replace alzhe = . if inlist(alzhe,.d,.m,.r) & iwstat==1

*==================================*
* Health insurance variables
*==================================*
	gen anyhi = 0
	label var anyhi "Any health insurance coverage" 
	foreach v of varlist higov covr covs hiothp {
	/* hiltc */ 
		replace anyhi = 1 if inlist(`v',1,.e,.c,.t)
	}
	foreach v of varlist higov covr covs hiothp {
		replace anyhi = . if !inlist(`v',0,1,.e,.c,.t) & anyhi == 0
	}
	label var anyhi "HI cov -gov/emp/other"

* Any private HI coverage
gen hipriv = 0
foreach v of varlist covr covs hiothp{
	replace hipriv = 1 if inlist(`v',1,.c,.e,.t)
}
foreach v of varlist covr covs hiothp{
	replace hipriv = . if !inlist(`v',0,1,.e,.c,.t) & hipriv == 0
}

label var hipriv "Priv HI cov-emp/other"

*** Private HI not for AHEAD 2A: 
	replace hipriv = -1 if inlist(hacohort,1) & wave == 2 & iwstat == 1
*** Any HI, assume all AHEAD have health insurance coverage:
	replace anyhi  = 1 if inlist(hacohort,1) & wave == 2 & iwstat == 1

*==================================*
* Make DB variables consistent
*==================================*
* replace dbclaim = 0 if (age_iwe < 53 & rdb_ea_c == 2) | (age_iwe < 58 & rdb_ea_c == 3) | anydb == 0

* 04/2015 - Wendy - Replace anydb to anydb_n (variable from RAND-HRS data)

drop anydb
rename anydb_n anydb

tab dbclaim anydb, m col row

replace dbclaim = 0 if anydb == 0

tab dbclaim wave, m col

*==================================*
* Age dummies
*==================================*

/*
 
gen age65l  = min(63,age) if age < .
gen age6574 = min(max(0,age-63),73-63) if age < .
gen age75l = min(age, 73) if age < . 
gen age75p = max(0, age-73) if age < . 
gen age62e = inrange(age,60,61) if age < .
gen age65e = inrange(age,62,64) if age < . 

*/

*==================================*
* DB retirement age
*==================================*
forvalues i = 2/4{
	gen rdb_na_`i' = rdb_na_c == `i' if rdb_na_c < . 
}
forvalues i = 2/3{
	gen rdb_ea_`i' = rdb_ea_c == `i' if rdb_ea_c < . 
}

label var rdb_na_2 "Normal DB Retirement Age 60-61"
label var rdb_na_3 "Normal DB Retirement Age 62-64"
label var rdb_na_4 "Normal DB Retirement Age 65+"

label var rdb_ea_2 "Early DB Retirement Age 55-59"
label var rdb_ea_3 "Early DB Retirement Age 60+"

*** Impute early and normal DB retirement age
recode rdb_ea_c (1 = 50) (2 = 55) (3 = 60) , gen(era)
recode rdb_na_c (1 = 55) (2 = 60) (3 = 62) (4 = 65) , gen(nra)

*==================================*
* Misc
*==================================*
replace rclyr = min(2010,int(rabyear + age_iwe)) if ssclaim == 1 & missing(rclyr)
replace rclyr = 2100 if missing(rclyr) & ssclaim == 0
ren rclyr rssclyr

*=================================
* Revised SS claim measure
*=================================
/* Make ssclaim_b absorbing
xtset hhidpn wave
replace ssclaim_b = 1 if l.ssclaim_b == 1 & ssclaim_b == 0 */


/* Need to assign SS retirement claim year for ssclaim_b variable 
We can probably do better than this.
Known issues: 
1. rssclyr_b is not accurate for those claiming at first interview
sort hhidpn wave, stable
by hhidpn: egen rclwv_b = min(cond(ssclaim_b == 1, wave, .))
replace rclwv_b = 100 if missing(rclwv_b) & ssclaim_b == 0
gen rssclyr_b = 1990 + 2*rclwv_b if rclwv_b < 100
replace rssclyr_b = 2100 if rclwv_b == 100
label var rssclyr_b "Approximate year of claiming SS benefits"
*/

/*Make ssclaim absorbing*/

xtset hhidpn wave
replace ssclaim = 1 if l.ssclaim == 1 & ssclaim == 0

sort hhidpn wave, stable
by hhidpn: egen rclwv_b = min(cond(ssclaim == 1, wave, .))
replace rclwv_b = 100 if missing(rclwv_b) & ssclaim == 0
gen rssclyr_n = 1990 + 2*rclwv_b if rclwv_b < 100
replace rssclyr_n = 2100 if rclwv_b == 100
label var rssclyr_n "Approximate year of claiming SS benefits"

*==================================*
* Relabel variables for regression output
*==================================*
	label var male "Male"
	label var black "Non-Hispanic black"
	label var white "Non-Hispanic white"
	label var hispan "Hispanic"
	
	label var hsless "Less than high school"
	label var college "Some college and above"
	label var somecol "Some college"
	label var collgrad "College graduate"
	
	label var smoken "Current smoking"
	label var smokev "Ever smoked"
	
	label var obese "Obese(bmi>=30)"
	label var overwt "Overweight(25<=bmi<30)"
	label var underwt "Underweight(bmi<18.5)"
	
label var adlstat "ADL Status (of 5 ADLs waves 1 & 2H, 6 ADLs otherwise)"
label var iadlstat "IADL Status"
label define adllb 1 "No Limitations" 2 "1 ADL" 3 "2 ADLs" 4 "3+ ADLs"
label define iadllb 1 "No Limitations" 2 "1 IADL" 3 "2+ IADLs"
label values adlstat adllb
label values iadlstat iadllb

	label var nrshom "Living in nursing home"
	label var died   "Died"
	
	label var cancre "Cancer"
	label var diabe  "Diabetes"
	label var hearte "Heart disease"
	label var hibpe  "Hypertension"
	label var lunge  "Lung disease"
	label var stroke "Stroke"
/*
	label var age75l "Age spline (age<75)"
	label var age75p "Age spline (age>75)"
	label var age62e "Age 60-61"
	label var age65e "Age 62-64"
*/

*==================================*
* Recode and relabel social health variables
*==================================*

  recode bathh (.s=0)
recode dressh (.s=0)
recode walkrh (.s=0)
  gen adlhelp = .
replace adlhelp = 1 if bathh==1 | dressh==1 | walkrh==1
replace adlhelp = 0 if bathh==0 & dressh==0 & walkrh==0 
label var adlhelp "Receiving help on bathing, dressing, or walking"

gen orghours = .
label var orghours "Number of hours volunteering for organization"
gen friendhours = .
label var friendhours "Number of hours volunteering for friends"
gen neighbors = .
label var neighbors "Has good friends in neighborhood"
gen socialperwk = .
label var socialperwk "Number of social visits per week"

** 1996
replace orghours = e2169 if e2169 <= 9996 & wave == 3
replace friendhours = e2172 if e2172 <= 9996 & wave == 3
replace neighbors = e1737 == 1 if e1737 <= 5 & wave == 3
replace socialperwk = e1739*7 if e1739 < 997 & e1740==1 & wave == 3
replace socialperwk = e1739 if e1739 < 997 & e1740==2 & wave == 3
replace socialperwk = e1739/2 if e1739 < 997 & e1740==3 & wave == 3
replace socialperwk = e1739/4.4 if e1739 < 997 & e1740==4 & wave == 3
replace socialperwk = e1739/52 if e1739 < 997 & e1740==5 & wave == 3
replace socialperwk = 0 if e1739 < 997 & e1740==6 & wave == 3
** 1998
replace orghours = 0 if f2677 == 5 & wave == 4
replace orghours = f2678 if f2678 <= 9180 & wave == 4
replace friendhours = f2681 if f2681 <= 9000 & wave == 4
replace neighbors = f2244 == 1 if f2244 <= 5 & wave == 4
replace socialperwk = f2246*7 if f2246 < 995 & f2247==1 & wave == 4
replace socialperwk = f2246 if f2246 < 995 & f2247==2 & wave == 4
replace socialperwk = f2246/2 if f2246 < 995 & f2247==3 & wave == 4
replace socialperwk = f2246/4.4 if f2246 < 995 & f2247==4 & wave == 4
replace socialperwk = f2246/52 if f2246 < 995 & f2247==5 & wave == 4
replace socialperwk = 0 if f2246 < 995 & f2247==6 & wave == 4
** 2000
replace orghours = 0 if g2995 == 5 & wave == 5
replace orghours = g2996 if g2996 <= 9000 & wave == 5
replace friendhours = g2999 if g2999 <= 9000 & wave == 5
replace neighbors = g2495 == 1 if g2495 <= 5 & wave == 5
replace socialperwk = g2497*7 if g2497 < 998 & g2498==1 & wave == 5
replace socialperwk = g2497 if g2497 < 998 & g2498==2 & wave == 5
replace socialperwk = g2497/2 if g2497 < 998 & g2498==3 & wave == 5
replace socialperwk = g2497/4.4 if g2497 < 998 & g2498==4 & wave == 5
replace socialperwk = g2497/52 if g2497 < 998 & g2498==5 & wave == 5
replace socialperwk = 0 if g2497 < 998 & g2498==6 & wave == 5
** 2002
replace orghours = 0 if hg086 == 5 & wave == 6
replace orghours = hg087 if hg087 <= 9000 & wave == 6
replace friendhours = hg092 if hg092 <= 9000 & wave == 6
replace neighbors = hf175 == 1 if hf175 <= 5 & wave == 6
replace socialperwk = hf176*7 if hf176 < 998 & hf177==1 & wave == 6
replace socialperwk = hf176 if hf176 < 998 & hf177==2 & wave == 6
replace socialperwk = hf176/2 if hf176 < 998 & hf177==3 & wave == 6
replace socialperwk = hf176/4.4 if hf176 < 998 & hf177==4 & wave == 6
replace socialperwk = hf176/52 if hf176 < 998 & hf177==5 & wave == 6
replace socialperwk = 0 if hf176 < 998 & hf177==6 & wave == 6
** 2004

foreach v of varlist jg* jlb* klb* llb* {
  replace `v' = . if wave != 7
}

summarize hg087 [aweight=wtcrnh] if 0 < hg087 & hg087 < 50 & wave == 7
gen orgLT50 = r(mean)
summarize hg087 [aweight=wtcrnh] if 50 < hg087 & hg087 < 100 & wave == 7
gen org50t100 = r(mean)
summarize hg087 [aweight=wtcrnh]  if 100 < hg087 & hg087 < 200 & wave == 7
gen org100to200 = r(mean)
summarize hg087 [aweight=wtcrnh] if 200 < hg087 & hg087 <= 9000 & wave == 7
gen org200p = r(mean)

replace orghours = 0 if jg086 == 5 & wave == 7
replace orghours = orgLT50 if jg086 == 1 & jg195 == 1 & jg197==1 & wave == 7
replace orghours = 50 if jg086==1 & jg195==1 & jg197==3 & wave == 7
replace orghours = org50t100 if jg086==1 & jg195==1 & jg197==5 & wave == 7
replace orghours = 100 if jg086==1 & jg195==3 & wave == 7
replace orghours = org100to200 if jg086==1 & jg195==5 & jg196==1 & wave == 7
replace orghours = 200 if jg086==1 & jg195==5 & jg196==3 & wave == 7
replace orghours = org200p if jg086==1 & jg195==5 & jg196==5 & wave==7
drop orgLT50 org50t100 org100to200 org200p


summarize hg092 [aweight=wtcrnh] if 0 < hg092 & hg092 < 50 & wave == 7
gen friendLT50 = r(mean)
summarize hg092 [aweight=wtcrnh]  if 50 < hg092 & hg092 < 100 & wave == 7
gen friend50t100 = r(mean)
summarize hg092 [aweight=wtcrnh] if 100 < hg092 & hg092 < 200 & wave == 7
gen friend100to200 = r(mean)
summarize hg092 [aweight=wtcrnh] if 200 < hg092 & hg092 <= 9000 & wave == 7
gen friend200p = r(mean)

replace friendhours = 0 if jg198 == 5 & wave == 7
replace friendhours = friendLT50 if jg198 == 1 & jg199 == 1 & jg201==1 & wave == 7
replace friendhours = 50 if jg198==1 & jg199==1 & jg201==3 & wave == 7
replace friendhours = friend50t100 if jg198==1 & jg199==1 & jg201==5 & wave == 7
replace friendhours = 100 if jg198==1 & jg199==3 & wave == 7
replace friendhours = friend100to200 if jg198==1 & jg199==5 & jg200==1 & wave == 7
replace friendhours = 200 if jg198==1 & jg199==5 & jg200==3 & wave == 7
replace friendhours = friend200p if jg198==1 & jg199==5 & jg200==5 & wave==7
drop friendLT50 friend50t100 friend100to200 friend200p

replace neighbors = jf175 == 1 if jf175 <= 5 & wave == 7
replace socialperwk = jf176*7 if jf176 < 998 & jf177==1 & wave == 7
replace socialperwk = jf176 if jf176 < 998 & jf177==2 & wave == 7
replace socialperwk = jf176/2 if jf176 < 998 & jf177==3 & wave == 7
replace socialperwk = jf176/4.4 if jf176 < 998 & jf177==4 & wave == 7
replace socialperwk = jf176/52 if jf176 < 998 & jf177==5 & wave == 7
replace socialperwk = 0 if jf176 < 998 & jf177==6 & wave == 7

rename jlb509 spouserel
label var spouserel "Closeness to Spouse"
label define closeness 1 "Very Close" 2 "Quite Close" 3 "Not Very Close" 4 "Not At All Close", modify
label values spouserel closeness

label define frequency 1 "Three or More Per Week" 2 "Once or Twice Per Week" 3 "Once or Twice Per Month" 4 "Every Few Months" 5 "Once or Twice Per Year" 6 "Less than Once per Year or Never", modify
label values jlb512* jlb516* jlb520* frequency

rename jlb512a meetchildren
rename jlb512b phonechildren
rename jlb512c writechildren
rename jlb513 closechildren

rename jlb516a meetfamily
rename jlb516b phonefamily
rename jlb516c writefamily
rename jlb517 closefamily

rename jlb520a meetfriends
rename jlb520b phonefriends
rename jlb520c writefriends
rename jlb521 closefriends

* Recode the additional risk factors
gen bpcontrol = .
gen insulin = .
gen lungoxy = .
gen diabkidney = .

label variable bpcontrol "BP under control (missing if not hibpe and not available for wave 12)"
label variable insulin "Taking insulin (missing if not diabe)"
label variable lungoxy "Using lung oxygen (missing if not lunge)"
label variable diabkidney "Diabetes causing kidney problems (missing if not diabe and not available for wave 12"

*c008 is missing for 2014 wave
foreach v of varlist d784 e784 f1112 g1241 hc008 jc008 kc008 lc008 MC008 nc008 {
 recode `v' (1=1) (5=0) (else=.)
 replace bpcontrol = `v' if !missing(`v')
}

foreach v of varlist v336 b224 w338 d790 e790 f1118 g1249 hc012 jc012 kc012 lc012 MC012 nc012 oc012{
 recode `v' (1=1) (5=0) (else=.)
 replace insulin = `v' if !missing(`v')
}

foreach v of varlist d824 e824 f1152 g1285 hc033 jc033 kc033 lc033 MC033 nc033 oc033{
 recode `v' (1=1) (5=0) (else=.)
 replace lungoxy = `v' if !missing(`v')
}

*c017 not available for 2012 either
foreach v of varlist hc017 jc017 kc017 lc017 MC017 nc017{
 recode `v' (1=1) (5=0) (else=.)
 replace diabkidney = `v' if !missing(`v')
}

* Code congestive heart failure (CHF)
gen chfe = .
label var chfe "Ever had congestive heart failure (missing for 1993 AHEAD wave)"
local chffatvars v411 w373 d843 e843 f1171 g1304 hc048 jc048 kc048 lc048 MC263 nc263 oc263
foreach v of varlist `chffatvars' {
	recode `v' (0=.) (5=0) (8=.d) (9=.r)
	tab `v', m
	replace chfe = `v' if `v' != .
	tab wave chfe, m
}

* if never got any heart disease, then doesn't have CHF
replace chfe = 0 if hearte==0

* Recode for 2010 and 2011
local chf1011 MC048 nc048 oc048
foreach x of varlist `chf1011' {
	recode `x' (0=.) (5=0) (8=.d) (9=.r)
  replace chfe = 0 if wave > 9 & `x' == 0
} 

* some respondents disputed hearte status in a later wave, recode their CHF status to none
replace chfe=0 if inlist(chfe,1,.d,.r) & hearte==0 & heartf==6
drop `chffatvars'
drop heartf
* make CHF an absorbing state
sort hhidpn wave
replace chfe=1 if chfe[_n-1]==1 & chfe==0 & hhidpn[_n-1]==hhidpn

* Fill in any zeroes for chfe that we can (if future waves are 0, we can assume current is 0)
forvalues wv = 12 (-1) 1 {
	replace chfe = 0 if F.chfe == 0 & wave == `wv' & missing(chfe)
}
* Fill in any zeroes for chfe that we can (if past wave is 1, we can assume current is 1)
forvalues wv = 1/12 {
	replace chfe = 1 if L.chfe == 1 & wave == `wv' & missing(chfe)
}


* Make ALZHEIMERS disease (AD) an absorbing state
sort hhidpn wave
replace alzhe = 1 if alzhe[_n-1]==1 & alzhe==0 & hhidpn[_n-1]==hhidpn

* Make sure Heartae is an absorbing state
replace heartae = 0 if hearte == 0
sort hhidpn wave
replace heartae = 1 if heartae[_n-1]==1 & heartae==0 & hhidpn[_n-1]==hhidpn



* Life satisfaction is missing for proxy respondents
tab wave satisfaction if proxy == 1
replace satisfaction = -2 if proxy == 1 & missing(satisfaction)

* Handle missings for parents' education
replace rameduc = -999 if missing(rameduc)
replace rafeduc = -999 if missing(rafeduc)


keep if died < .
save "$outdata/hrs_analytic_recoded.dta", replace
exit, STATA
