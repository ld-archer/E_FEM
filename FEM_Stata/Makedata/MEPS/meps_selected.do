clear
set more off
set mem 800m
set seed 2344234
set trace off

include "../../../fem_env.do"

**** Store the medical cpi into a matrix cross walk
*use "$indata/medcpi_cxw.dta"
insheet using $fred_dir/CPIMEDSL.csv, clear
gen year = substr(date,5,4)
destring year, replace
ren value medcpi
keep year medcpi
mkmat medcpi, matrix(medcpi) rownames(year)
matlist medcpi

*** Vector of medical CPI
*CPI adjusted social security income
*global colcpi "1991 1992 1993 1994 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005"

*#d;
*matrix medcpiu = 
*( 177.02,190.06, 201.4, 211.03, 220.45,228.27, 234.59, 242.13,250.56, 260.75,
*272.77, 285.63, 297.05, 310.13,323.23); 
*#d cr

*matrix colnames medcpiu = $colcpi

*******************************************
* Selected cost and disease variables from MEPS
*******************************************
drop _all
local frsyr = 2000
foreach v in 00 01 02 03 04 05 06 07 08 09 10 11 12 {
	drop _all
	fdause "$meps_dir/csd`frsyr'.ssp"
	if `frsyr' == 1996 {
		ren inscope1 inscop31
		ren inscope2 inscop42
	}
	
	if `frsyr' < 1999{
		ren wtdper`v' perwt`v'f
		ren educyr`v' educyear
	}

	if inrange(`frsyr',2005,2012) {
		ren educyr educyear
	}
	
	if `frsyr' == 2013 {
		ren eduyrdg educyear
		/* They started coding years and degrees.  
		1 LESS THAN/EQUAL TO 8TH GRADE 
		2 9-12TH GRADE, NO HIGH SCHOOL DIPLOMA 
		3 GED OR EQUIVALENT 
		4 HIGH SCHOOL DIPLOMA 
		5 SOME COLLEGE, NO DEGREE 
		6 ASSOC DEG: OCCUPATIONAL,TECH,VOCATIONAL 
		7 ASSOCIATE DEGREE: ACADEMIC PROGRAM 
		8 BACHELOR'S DEGREE (BA,AB,BS,BBA) 
		9 MASTER'S, PROFESSIONAL, DOCTORAL DEGREE 
		10 CHILD UNDER 5 YEARS OLD 
		*/
		* code to approximate years of education (GED is less than HS).  Will be recoded in the next step.
		recode educyear (1=8) (2=11) (3=11) (4=12) (5=13) (6=14) (7=14) (8=16) (9=17) (10=0)
	}
	
	
	if `frsyr' == 2000 {
		gen bmindx53 = (weight53 * 0.4545)/(hghtft53*0.3048+hghtin53*0.0254)^2
		replace bmindx53 = . if weight53 <0 |hghtft53 < 0 | hghtin53  < 0 
	}
	
	if `frsyr' >= 2007 {
		ren diabdx diabdx53
		ren hibpdx hibpdx53
		ren chddx chddx53 
		ren angidx angidx53 
		ren midx midx53 
		ren ohrtdx ohrtdx53 
		ren strkdx strkdx53 
		ren emphdx emphdx53 
		ren asthdx asthdx53
	}
	
	* K6 only available 2004 & onwards; 
	if `frsyr' >= 2004 {
		ren k6sum42 k6score
		replace k6score = . if k6score<0
		label var k6score "K6 Score"
		gen k6severe = k6score>=13 & k6score<.
		replace k6severe=. if k6score==.
		label var k6severe "Severe Mental Distress"
	}
	
	/* Asthma variables (age of diagnosis is only for 2008 and later)
	
	2000-2002
	asthdx53
	asatak53
	asamed53
	asster53
	
	2003-2006
	asthdx53
	asstil53
	asatak53
	asprev53
	asdaly53
	
	2007
	asthdx
	asstil31
	asstil53
	asatak31
	asatak53
	asprev53
	asdaly53
	
	2008-2010
	asthdx - asthma diagnosis
	asthaged - age of diagnosis
	asstil31 - still have round 3/1
	asstil53 - still have round 5/3
	asatak31 - attack in last 12 months round 3/1
	asatak53 - attack in last 12 months round 5/3
	asthep31 - when was last episode round 3/1
	asthep53 - when was last episode round 5/3
	
	Additional follow-up questions regarding asthma medication used for quick relief (ASACUT53),
	preventive medicine (ASPREV53), and peak flow meters (ASPKFL53) were asked. These
	questions were asked if the person reported having been diagnosed with asthma (ASTHDX = 1).
	ASACUT53 asked whether the person had used the kind of prescription inhaler that you breathe
	in through your mouth that gives quick relief from asthma symptoms. ASPREV53 asked whether
	the person had ever taken the preventive kind of asthma medicine used every day to protect the
	lungs and prevent attacks, including both oral medicine and inhalers. ASPKFL53 indicates
	whether the person with asthma had a peak flow meter at home.
	Persons who said “Yes” to ASACUT53 were asked whether they had used more than three
	canisters of this type of inhaler in the past 3 months (ASMRCN53). Persons who said “Yes” to
	ASPREV53 were asked whether they now took this kind of medication daily or almost daily
	(ASDALY53). Persons who said “Yes” to ASPKFL53 were asked if they ever used the peak
	flow meter (ASEVFL53). Those persons who said “Yes” to ASEVFL53 were asked when they
	last used the peak flow meter (ASWNFL53). 
	
  ***	For now, we're only keeping asthdx and astaged ***
	
	*/
	
	if `frsyr' < 2008 {
		* No age of diagnosis before 2008
		gen asthaged = .
	}
	
	label var asthaged "age of asthma diagnosis (2008 and later)"
	
	
	* Race variables changed in 2012.  racev1x is coded comparable to racex
	if `frsyr' >= 2012 {
		rename racev1x racex
	}
	
	
	* Only keep those with positive weights and in scope
	* keep if perwt`v'f > 0 & perwt`v'f < . & insc1231 == 1
	keep if perwt`v'f > 0 & perwt`v'f < .
	
	* Rename variables
	ren inscop`v' inscopend
	ren age`v'x age
	ren perwt`v'f perwt
	gen male = sex == 1 if sex < .
	ren famwt`v'f famwt 
	ren famsze`v' famsze
  ren mcaid`v'x medicaid_elig
  ren ttlp`v'x gross
  ren wagep`v'x iearn
  gen iearnx = min(iearn, 2e6)
  gen logiearnx = ln(iearnx + sqrt(1 + iearnx^2))/100
  
  * Health insurance coverage variables
  ren inscov`v' inscov
  label var inscov "health insurance coverage indicator"
  label define inscov 1 "Any Private" 2 "Public Only" 3 "Uninsured" 

    
  foreach tp in prvev triev mcrev mcdev opaev opbev {
  	ren `tp'`v' `tp'
  	recode `tp' (1=1) (2=0)
  }

  label var prvev "ever have private insurance"
  label var triev "ever have tricare"
  label var mcrev "ever have medicare"
  label var mcdev "ever have medicaid"
  label var opaev "ever have other public a ins"
  label var opbev "ever have other public b ins"
  
  egen hisrc = rowtotal(prvev triev mcrev mcdev opaev opbev)
	tab hisrc, m

	gen hlthinscat = .
	* Single source of insurance
	replace hlthinscat = 0 if inscov == 3
	replace hlthinscat = 1 if prvev == 1 & hisrc == 1
	replace hlthinscat = 2 if mcrev == 1 & hisrc == 1
	replace hlthinscat = 3 if mcdev == 1 & hisrc == 1
	replace hlthinscat = 4 if triev == 1 & hisrc == 1
	replace hlthinscat = 5 if opaev == 1 & hisrc == 1
	replace hlthinscat = 5 if opbev == 1 & hisrc == 1
	
	
	* Two sources of insurance - just looking at private/medicare and medicare/medicaid for now
	replace hlthinscat = 6 if prvev == 1 & mcrev == 1 & hisrc == 2
	replace hlthinscat = 7 if mcrev == 1 & mcdev == 1 & hisrc == 2
	replace hlthinscat = 8 if missing(hlthinscat) & hisrc >= 2 & !missing(hisrc)

	label define hlthinscat 0 "Uninsured" 1 "Private HI only" 2 "Medicare only" 3 "Medicaid Only" 4 "Military HI only" 5 "Other HI only" 6 "Private HI and Medicare" 7 "Medicare and Medicaid" 8 "All other 2+"
	label values hlthinscat hlthinscat
	label var hlthinscat "Health Insurance source(s)"
  
  gen anyhi = (inscov == 1 | inscov == 2)
	label var anyhi "Any health insurance coverage"
	
	gen inscat = .
	replace inscat = 1 if anyhi == 0
	replace inscat = 2 if prvev == 0 & anyhi == 1
	replace inscat = 3 if prvev == 1 & anyhi == 1
	label define inscat 1 "Uninsured" 2 "Public Ins only" 3 "Any Private Ins"
	label values inscat inscat
	label var inscat "Broad insurance categories: uninsured, public only, any private" 
	
	forvalues x = 1/3 {
		gen inscat`x' = (inscat == `x') if !missing(inscat)
	}


*** Expenditures adjusted by Medical CPI based on interview year	
	foreach item in exp slf mcr mcd prv va ofd wcp opr opu osr{
		ren tot`item'`v' tot`item'
		gen meps`item' = tot`item'
		*labe var meps`item' "tot`item' in 2005 dollars"
		label var meps`item' "tot`item' in 2004 dollars"
		*replace meps`item' = meps`item' ///
		* medcpiu[1,colnumb(medcpiu,"2005")]/( medcpiu[1,colnumb(medcpiu,"`frsyr'")])
		replace meps`item' = meps`item' * medcpi[rownumb(medcpi,"2004"), 1]/( medcpi[rownumb(medcpi,"`frsyr'"),1])
	}
	gen yr = `frsyr'
	gen year = `frsyr'

*** Utilization variables ; 
	foreach item in obtotv ipdis ipngtd {  
		ren `item'`v' `item' 
	}
	
	ren obtotv doctim 
	ren ipdis  hsptim
	ren ipngtd hspnit
	
	#d;
	
	* pre 2004, keep everything except for k6 (bc doesn't exist); 
		if `frsyr'<2004 {;
	keep duid dupersid yr male educyear age racex hispanx marry53x
	tot* meps* doctim hsptim hspnit perwt 
	duid famidyr famrfpyr famszeyr famwt
	iadlhp53 adlhlp53 diabdx53 hibpdx53 chddx53 angidx53 midx53 ohrtdx53 strkdx53 emphdx53 asthdx53 bmindx53 adsmok42
	region53 panel*
          medicaid_elig logiearnx gross
  prvev triev mcrev mcdev opaev opbev hlthinscat inscov anyhi      inscat* 
  held* offer* pcs42 rthlth* asthaged year;
};


	* after 2004, keep k6 vars and everything else; 
	if `frsyr' >= 2004 {;
			keep duid dupersid yr male educyear age racex hispanx marry53x
	tot* meps* doctim hsptim hspnit perwt 
	duid famidyr famrfpyr famszeyr famwt
	iadlhp53 adlhlp53 diabdx53 hibpdx53 chddx53 angidx53 midx53 ohrtdx53 strkdx53 emphdx53 asthdx53 bmindx53 adsmok42
	region53 panel*
          medicaid_elig logiearnx gross
  prvev triev mcrev mcdev opaev opbev hlthinscat inscov anyhi inscat* 
  held* offer* pcs42 rthlth* asthaged year
  k6* varstr varpsu;
	};
	

          
	#d cr
	save "$outdata/m`frsyr'.dta", replace
	local frsyr = `frsyr' + 1 
}

* Combine mutiple years of cost data

drop _all
*use "$outdata/m2004.dta"
*erase "$outdata/m2004.dta"
use "$outdata/m2012.dta"
erase "$outdata/m2012.dta"
forvalues i = 2011(-1)2000{
	append using "$outdata/m`i'.dta"
	erase "$outdata/m`i'.dta"
}

/* Recode Medicaid Eligible to be boolean rather than 1 or 2 */
  recode medicaid_elig (1=1) (2=0) (nonmissing=.) (missing=.)

*******************************************
* Selected self-reported conditions from conditions file
*******************************************
#d;
	sort dupersid yr, stable ; 
	tempfile old ; 
	save `old', replace ; 

forval i=2000/2012 { ; 

	fdause "$meps_dir/condition`i'.ssp", clear ; 
	keep dupersid cccodex ;

	* Destring cccodex ; 
	destring cccodex, gen(ncccodex)  ; 
	gen cancrecr = 1 if inrange(ncccodex, 11, 21) | inrange(ncccodex, 24,45) ; 
	gen heartecr = 1 if inrange(ncccodex, 96,97) | inrange(ncccodex, 100,108) ; 
	* gen lungecr  = 1 if inrange(ncccodex, 127,127) | inrange(ncccodex, 129,134) ; 
	gen lungecr  = 1 if inlist(ncccodex, 127,129,130,131,132) ; 	
	gen diabecr  = 1 if inlist(ncccodex, 49,50) ;
	gen hibpecr  = 1 if inlist(ncccodex, 98,99) ; 
	gen strokecr = 1 if inlist(ncccodex, 109,110,112,113) ; 
	gen heartacr = 1 if inlist(ncccodex, 100);
	
	* One observation per person ; 
	sort dupersid, stable; 
	foreach v in diabe hibpe stroke hearte lunge cancre hearta { ; 
		by dupersid: gen cum = sum(`v'cr == 1) ; 
		by dupersid: replace `v' = cum[_N] >= 1 ; 
		drop cum ; 
		ren `v'cr `v'cr`i' ; 
	} ; 
	by dupersid: keep if _n == 1 ; 
	
	gen yr = `i' ; 
	sort dupersid yr, stable; 
	tempfile tmp ; 
	save `tmp', replace ; 
	
	use `old' , clear ; 
	merge dupersid yr using `tmp' ; 
	tab _merge ; 
	qui count if _merge == 2 ; 
	if r(N) > 0 { ; 
		dis "NO matched file in CSD: " r(N); 
	}; 
	drop if _merge == 2 ; 
	drop _merge; 

	sort dupersid yr, stable ; 
	save `old', replace ; 
} ; 

	foreach v in diabe hibpe stroke hearte lunge cancre hearta { ; 
		gen `v'cr = `v'cr2000 if yr == 2000 ;
		forval y=2001/2012 { ;  
			replace `v'cr = `v'cr`y' if yr == `y' ; 
		} ; 
		replace `v'cr = 0 if `v'cr!= 1 ; 
		drop `v'cr20*;
	} ; 
	
	label var diabecr "Diabetes CCC code 049/050" ; 
	label var hibpecr "hypertension CCC code 098/099" ; 
	label var strokecr "Stroke CCC code 109/110/112/113" ; 
	label var lungecr "Lung disease CCC code 127/129-134" ; 
	label var heartecr "Heart disease CCC code 96/97/100 to 108" ; 
	label var cancrecr "Cancer (except skin) CCC code 11-21/24-45" ; 
	label var heartacr "MI CCC code 100" ; 
	
	#d cr ;
		
	******************************  
	* Recode variables 	        
	******************************  
	
	* Recode health conditions in MEPS
	gen hearte = 0 
	label var hearte "CHD/ANGINA/MI/OTHER heart problems"
	foreach v in chd angi mi ohrt { 
		replace hearte = 1 if `v'dx53 == 1
	}
	foreach v in chd angi mi ohrt { 
		replace hearte = . if `v'dx53 < 0 & hearte == 0
	}
	
	gen diabe = diabdx53 == 1 if inlist(diabdx53,1,2)
	label var diabe "Ever diagnosed with diabetes"
	gen hibpe = hibpdx53 == 1 if inlist(hibpdx53,1,2)
	label var hibpe "Ever diagnosed with high blood pressure"
	gen stroke = strkdx53 == 1 if inlist(strkdx53,1,2)
	label var stroke "Ever diagnosed with stroke"
	gen lunge   = emphdx53 == 1 if inlist(emphdx53,1,2)
	label var lunge "Ever diagnosed with emphysema"
	gen heartae = midx53 == 1 if inlist(midx53,1,2)
	label var heartae "Ever diagnosed with MI"
	
	gen adl1p = adlhlp53 == 1 if inlist(adlhlp53,1,2)
	label var adl1p "One or more ADLs"

	gen iadl1 = iadlhp53 == 1 if inlist(iadlhp53,1,2)
	replace iadl1 = 0 if adl1p == 1 
	label var iadl1 "IADL only"
		
	************
	* Recode demographic variables 
	************
	gen age2529 = inrange(floor(age), 25, 29)
	gen age3034 = inrange(floor(age), 30, 34)
	gen age3539 = inrange(floor(age), 35, 39)
	gen age4044 = inrange(floor(age), 40, 44)
	gen age4549 = inrange(floor(age), 45, 49)
	gen age5054 = inrange(floor(age), 50, 54)
  gen age5559 = inrange(floor(age), 55, 59)
  gen age6064 = inrange(floor(age), 60, 64)
	gen age6569 = inrange(floor(age), 65, 69)
	
	
	
	ren hispanx hispan
	replace hispan = 0 if hispan == 2
	gen black = racex == 2 & hispan == 0 if inrange(racex,1,6)
	label var black "R is non-hispanic black"
	
	*** Note: in year 2000 and 2001, coding of racex is 1 to 5, and black is 4
	replace black = racex == 4 & hispan == 0 if inrange(racex,1,5) & inlist(yr,2000,2001)
	
	#d;
	recode educyear (0/11 = 1 "1 less than HS") (12 = 2 "2 HS grad")
	(13/15 = 3 "3 Some college") (16/17 = 4 "4 College grad") (nonmissing = .),gen(educ) ; 
	label var educ "Education recoded";
	#d cr
	
	gen hsless = educ == 1 if educyear < . 
	label var hsless "Less than HS"
	gen somecol = educ == 3 if educyear < . 
	label var somecol "Some college"
	gen collgrad = educ == 4 if educyear < . 
	label var collgrad "College grad"
	gen college = somecol | collgrad
	label var college "At least some college"

	gen regnth = region53 == 1 if region53>0 & region53<.
	label var regnth "Census region: Northeast"
	
	gen regmid = region53 == 2 if region53>0 & region53<. 
	label var regmid "Census region: Midwest"
	
	gen regwst = region53 == 4 if region53>0 & region53<. 
	label var regwst "Census region: West"
	
	gen widowed = inlist(marry53,2,8) if marry53>0&marry53<.&marry53!=6
	label var widowed "Marital status:widowed"
	
	gen single = inlist(marry53,3,4,5,9,10) if marry53>0&marry53<.&marry53!=6
	label var single "Marital status: single"
	
	************
	* Recode smoking and obesity 
	************
	* ren eversmok smokev
	* ren smokenow smoken
	
	gen bmi = bmindx53 if bmindx53>0&bmindx53<50
	label var bmi "BMI if 0-50"
	*** obesity
	gen obese = 0*bmi
	replace obese = 1 if bmi >=30 & bmi < .
	label var obese "whether obese (bmi>=30)"
	
	*** overweight
	gen overwt = 0*bmi
	replace overwt = 1 if bmi >= 25 & bmi < 30
	label var overwt "whether over weight (25<=bmi<30)"
	
	*** normal weight
	gen normalwt = 0*bmi
	replace normalwt = 1 if bmi >= 18.5 & bmi < 25
	label var normalwt "whether normal weight (20<=bmi<25)"
	
	*** underweight
	generate underwt = 0*bmi
	replace underwt = 1 if bmi < 18.5 & bmi > 0
	label var underwt "whether under-weight (bmi< 20)"
	
	*** exclusive weight status
	gen wtstate = 0*bmi
	replace wtstate = 1 if underwt  == 1
	replace wtstate = 2 if normalwt == 1
	replace wtstate = 3 if overwt == 1
	replace wtstate = 4 if obese == 1
	label var wtstate "bmi status"
	
/*	THIS SECTION NOT USED. KEPT FOR NOW FOR MINIMAL CHANGES
	************
	* Merge with NHIS file 
	************		
	
	sort yr dupersid, stable
	merge yr dupersid using "$nhisdir\link_meps_nhis.dta", uniqusing
	tab _merge
	drop if _merge == 2
	ren _merge mergeMEPSNHIS

	label define mergelb 1 "1 MEPS only" 2 "2 NHIS only" 3 "3 MEPS and NHIS" 
	label values mergeMEPSNHIS mergelb 

	ren nh_smokev smokev
	recode adsmok42 (1 = 1) (2 = 0) (nonmissing = .), gen(smoken)
		
	************
	* Save the file 
	************	
	
	label data "MEPS2000-2004, six conditions recoded,linked to NHIS" 
	save "$meps_dir\MEPS0004_selected_NHIS.dta", replace 
*/

*	keep if age >= 51 
	
	* Replace the lung disease variable using ICD codes ; 
	replace lunge = lungecr 
	ren cancrecr cancre 
	ren heartacr hearta

	* merge on bootstrap weights
	merge m:1 varstr varpsu using "$outdata/meps_bootstrap_weights.dta"
	drop if _m==2
	drop _m

	cap drop nh_*
	label data "MEPS2000-2012 for cost estimation in 2004 USD"

	compress
	save "$outdata/MEPS_cost_est.dta", replace 
	
	
	
	
exit, STATA
