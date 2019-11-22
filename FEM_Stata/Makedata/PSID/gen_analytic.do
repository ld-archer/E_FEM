include common.do

/* Need to assign an hhid to couples.  Using famnum68 is not unique to households.  Use hhdipn on head in a wave instead. */
use "$outdata/psid_merge.dta", clear


#d;
	keep hhidpn famnum* hdwf* relhd* deathyr*
		;
#d cr

drop deathyr
rename hdwfever everhdwf 



* Reshape from wide to long
#d;
local namelist famnum* hdwf* relhd* deathyr*
;
#d cr

foreach var of varlist `namelist' {
	local len = length("`var'")
	local head = substr("`var'",1,`len'-2)
	local tail = substr("`var'",`len'-1,`len')

	if (`tail'<67) local date = 2000+`tail'
	else local date = 1900+`tail'
	rename `var' `head'`date'
}

#d;

local shapelist famnum relhd hdwf deathyr
	;

reshape long `shapelist', i(hhidpn) j(year);
#d cr

* Only want current heads and wives or decedents who were a head or wife in previous year
sort hhidpn year
keep if hdwf == 1 | (deathyr == 1 & everhdwf == 1)
drop if famnum==0
/* 
Assign hhidpn of head to head and wife as hhid_new 
This will create a unique HHID (hhid_new) for all years with the same head
*/
bys year famnum (relhd deathyr): gen hhid_new = hhidpn[1]

tempfile hhid_new
save `hhid_new', replace





* USE PSID AND KEEP SELECTED VARIABLES

use "$outdata/psid_merge.dta", clear

drop educlvl*
/* Five level education variable from Patty - will ultimately get rid of this */
foreach x in 85 86 87 88 89 90 91 92 93 94 95 96 97 99 01 03 05 07 09 11 13 15 {
	rename educ`x' educp`x'
}

/* Five level education variable from Patty - will ultimately get rid of this */
foreach x in 85 86 87 88 89 90 91 92 93 94 95 96 97 99 01 03 05 07 09 11 13 15 {
	rename educ_b`x' educlvl`x'
}

* Get rid of exercise from before 85
forvalues yr = 69/84 {
	cap drop dlylgtexc`yr'
	cap drop dlyhvyexc`yr'
	cap drop dlymuscle`yr'
}

* Get rid of variables from before 97
forvalues yr = 85/96 {
	cap drop dlylgtexc`yr'
	cap drop dlyhvyexc`yr'
	cap drop dlymuscle`yr'
	cap drop educyrs`yr'
	cap drop hsless`yr'
	cap drop college`yr'
	cap drop educ_yrs`yr'
	cap drop educlvl`yr'
	cap drop educloc`yr'
	cap drop edyrs`yr'
	cap drop degree`yr'
	cap drop educ`yr'
	cap drop educ_b`yr'
	cap drop outoflabor`yr'
	
	cap drop educp`yr'
}

#d;
	keep hhidpn hhid hispan white black other hsless* college* male married* widowed* single* age* famnum* pn68 seq* relhd* inyr* diedyr* srh* head* wife* hdwf* shlt*
		rabmonth* rabyear* educyr* weight* 
		smoken* smokev* bmi* underwt* overwt* obese* cancre* diabe* hearte* hibpe* lunge* stroke* adlstat* iadlstat* asthme*
		mstath*
		deathyr* 
		cohab*
		edyrs*
		feduc meduc
		fmaage* mar* div* sep* sgl* wid* nummar* everm* everds* everw* yrlstst* yrmar* 
		childses
		hibp*
		grewup
		proptax*
		births* numbiokids* kidsinfu* yrsnclastkid* siblings*
		ofch relinv
		workweeks* weekworkhr* overtimehr* yrworkhr* 
		outoflabor*
		educp*
		degree*
		educlvl*
		colldegyr somecollyr hsdegyr gedgradyr
		sp_id*
		packyears*
		chldsrh chldmissschool chldmeasles chldmumps  chldcknpox  chldvision  chldparsmk  chldasthma  chlddiab 
		chldresp  chldspeech  chldallergy  chldheart  chldear  chldszre  chldmgrn  chldstomach  chldhibp  chlddepress  
		chlddrug  chldpsych 
		adlhelp*
		fstrok25 fheartattack25 fheart25 fhibp25 fasthma25 flung25 fdiab25 farthritis25 fmemry25 flearndis25 fcancr25 fpsych25 
		fstrok30 fheartattack30 fheart30 fhibp30 fasthma30 flung30 fdiab30 farthritis30 fmemry30 flearndis30 fcancr30 fpsych30 
		limitwrk* sestrat seclust
		respsadness* respnervous* resprestless* resphopeless* respeffort* respworthless* respk6scale* 
		statecode* 
		resp* 
		respondent*
		/*iwmonth* iwday* iwyear**/
    alcohol* alcdrinks* alcfreq* alcbinge*
		satisfaction*
	  dlylgtexc* dlyhvyexc* dlymuscle*
	  conhous* confood* contran* conhealth* contrips* coned* concloth* conothrec* conchild* 
		;
#d cr
desc

rename hdwfever everhdwf
rename deathyr death_yr

rename hibp99 highbp99
rename hibp01 highbp01
rename hibp03 highbp03
rename hibp05 highbp05
rename hibp07 highbp07
rename hibp09 highbp09
rename hibp11 highbp11
rename hibp13 highbp13
rename hibp15 highbp15


* Reshape from wide to long

#d;
local namelist married* widowed* single* age* famnum* seq* relhd* diedyr* srh* head* wife* hdwf* shlt* inyr*
	weight*
	smoken* smokev* bmi* underwt* overwt* obese* cancre* diabe* hearte* hibpe* lunge* stroke* adlstat* iadlstat* asthme*
	mstath*
	deathyr* 
	rabyear* rabmonth*
	cohab*
	edyrs*
	hsless* college*
	fmaage* mar99 mar0* mar11 mar13 mar15 div99 div0* div11 div13 div15 sep99 sep0* sep11 sep13 sep15 sgl99 sgl0* sgl11 sgl13 sgl15 wid99 wid0* wid11 wid13 wid15 nummar* everm* everds* everw* yrlstst* yrmar* 
	highbp*
	proptax*
	births* numbiokids* kidsinfu* yrsnclastkid* siblings*
	workweeks* weekworkhr* overtimehr* yrworkhr* 
	outoflabor*
	educp*
	degree*
	educlvl*
	sp_id*
	packyears*
	adlhelp*
	limitwrk*
	respsadness* respnervous* resprestless* resphopeless* respeffort* respworthless* respk6scale* 
	statecode* 
	respondent*
/*iwmonth* iwday* iwyear**/
	alcohol* alcdrinks* alcfreq* alcbinge*
	satisfaction*
	dlylgtexc* dlyhvyexc* dlymuscle*
	conhous* confood* contran* conhealth* contrips* coned* concloth* conothrec* conchild* 
;
#d cr

foreach var of varlist `namelist' {
	local len = length("`var'")
	local head = substr("`var'",1,`len'-2)
	local tail = substr("`var'",`len'-1,`len')

	if (`tail'<67) local date = 2000+`tail'
	else local date = 1900+`tail'
	rename `var' `head'`date'
}

#d;

local shapelist married widowed single age famnum seq relhd diedyr srh head wife hdwf shlt inyr
	weight
	smoken smokev bmi underwt overwt obese cancre diabe hearte hibpe lunge stroke adlstat iadlstat asthme
	mstath
	aged
	deathyr
	rabyear rabmonth
	cohab
	edyrs
	fmaage mar div sep sgl wid nummar everm everds everw yrlstst yrmar 
	highbp
	proptax
	births birthse numbiokids numbiokidslt18 kidsinfu yrsnclastkid siblings
	workweeks weekworkhr overtimehr yrworkhr 
	outoflabor
	hsless college
	educp
	degree
	educlvl
	sp_id
	packyears
	cancre_miss diabe_miss hearte_miss hibpe_miss lunge_miss stroke_miss
	adlhelp
	limitwrk
	respsadness respnervous resprestless resphopeless respeffort respworthless respk6scale 
	statecode
	respondent
	/*iwmonth iwday iwyear*/
	alcohol alcdrinks alcfreq	alcbinge
	satisfaction
	dlylgtexc dlyhvyexc dlymuscle
	conhous confood contran conhealth contrips coned concloth conothrec conchild 
;

reshape long `shapelist', i(hhidpn) j(year);
#d cr

rename rabyear rbyr
rename rabmonth rbmonth


/* Going with four categories of education:  less than HS/GED, high school/some college/AA, college, graduate+

  value educlvl
  1="1.Lt HS"
  2="2.GED/HS"
  3="3.some college"
  4="4.AA"
  5="5.BA"
  6="6.MA+"
  
  But we'll reassign the GED holders to LT HS based on their degree if no evidence of college
  
   value degree
  0="0.no degree"
  1="1.GED"
  2="2.HS"
  3="3.HS/GED"
  4="4.AA"
  5="5.BA"
  6="6.MA/MS/MBA"
  7="7.Law/MD/PhD"
  
  */

* Code the GED recipients with no college as LTHS equivalent
replace educlvl = 1 if degree == 1 & educlvl == 2
recode educlvl (1=1) (2=2) (3=2) (4=2) (5=3) (6=4) (missing=.)





label var fmaage "Age at first marriage - missing if never married"
label var nummar "Number of marriages including current"
label var mar "Married Ind- from marriage history"
label var div "Divorced Ind- from marriage history"
label var sep "Separated Ind- from marriage history"
label var sgl "Single Ind (includes divorced)- from marriage history"
label var wid "Widow Ind- from marriage history"
label var everm "Ever Married"
label var everds "Ever Divorced"
label var everw "Ever Widow"
label var yrlstst "Years since marriage status last changed"
label var yrmar "Year married"
label var hhidpn "Individual ID"
label var hhid "Household ID"
label var year "Year"
label var hisp "Hispanic"
label var white "Non-hispanic white"
label var black "Non-hispanic black"
label var other "Non-hispanic other"
label var hsless "Educ less than high school"
label var college "Some college or more"
label var male "Male"
label var married "Married- from individual file"
label var widowed "Widowed- from individual file"
label var single "Single- from individual file"
label var age "Age"
label var famnum "Family identification number"
* label var famno68 "Family number 1968"
label var pn68 "Person number, 1968"
label var seq "Sequence"
label var relhd "Relation to head"
label var inyr "Present in year"
label var diedyr "Died since last interview - old variable"
label var srh "Self Reported Health"
label var head "Head"
label var wife "Wife"
label var hdwf "Head or Wife"
label var everhdwf "Ever Head or Wife"
label var shlt "Binary self-reported health 1=fair/poor"
label var smoken "Current smoker"
label var smokev "Ever smoked cigarettes"
label var bmi "Body mass index"
label var underwt "BMI < 18.5"
label var overwt "25 < BMI < 30"
label var obese "BMI > 30"
label var cancre "Doctor ever - cancer"
label var diabe "Doctor ever - diabetes"
label var hearte "Doctor ever - heart disease"
label var hibpe "Doctor ever - hypertension"
label var lunge "Doctor ever - chronic lung disease"
label var stroke "Doctor ever - stroke"
label var adlstat "Count of ADL"
label var iadlstat "Count of IADL"
label var asthme "Doctor ever - asthma"
label var aged "Age in years with monthly categories"
label var weight "Individual cross-sectional weight"
label var mstath "Marital status of head"
label var deathyr "Improved wave of death flag"
label var rbyr "Respondent birth year"
label var rbmonth "Respondent birth month"
label var cohab "Wife is cohabitating"
label var feduc "Father's education"
label var meduc "Mother's education"
label var childses "Economic situation when growing up"
label var highbp "Non-absorbed version of hypertension variable"
label var grewup "Where the respondent grew up"
label var packyears "Packs of cigarettes per year by years smoked"
 
 label var workweeks  "Total Weeks worked in previous year"
 label var weekworkhr "Hours worked per week in previous year"
 label var overtimehr "Total overtime hours in previous year"
 label var yrworkhr   "Total hours worked (includes overtime) in previous year"
 label var siblings 	"Number of siblings"
 
 label var chldsrh "Self-reported health before age 17"
 label var chldmissschool "Miss a month of more of school due to health before age 17"
 label var chldmeasles "Measles before age 17"
 label var chldmumps "Mumps before age 17"
 label var chldcknpox "Chicken pox before age 17"
 label var chldvision "Difficulty seeing even with glasses before age 17"
 label var chldparsmk "Parents smoke before age 17"
 label var chldasthma "Asthma before age 17"
 label var chlddiab "Diabetes before age 17"
 label var chldresp "Respiratory disorder before age 17"
 label var chldspeech "Speech impairment before age 17"
 label var chldallergy "Allergic condition before age 17"
 label var chldheart "Heart trouble before age 17"
 label var chldear "Chronic ear problems before age 17"
 label var chldszre "Epilepsy or seizures before age 17"
 label var chldmgrn "Severe headaches or migraines before age 17"
 label var chldstomach "Stomahc problems before age 17"
 label var chldhibp "High blood pressure before age 17"
 label var chlddepress "Depression before age 17"
 label var chlddrug "Drug or alcohol problems before age 17"
 label var chldpsych "Other emotional or psychological problems before age 17"
 label var adlhelp "Receives help with bathing, dressing, or walking"
 label var limitwrk "Physical or nervous condition that limits the type or amount of work"
 
 label var	alcohol "ever drinks alcohol" 
 label var	alcdrinks "categorical of drinks per day"
 label var	alcfreq "categorical of frequency of drinking"
 label var alcbinge "Days in last year with 5+ (males) or 4+ (females) drinks on one occasion"
 
 label var satisfaction "Life satisfaction (respondent only, 2009 and later)"
 
 label define satisfaction 1 "Completely satisfied" 2 "Very satisfied" 3 "Somewhat satisfied" 4 "Not very satisfied" 5 "Not at all satisfied"
 label values satisfaction satisfaction 
 
 
 
	label var degree "Highest degree"
  label define degree 0 "0.no degree" 1 "1.GED" 2 "2.HS" 3 "3.HS/GED" 4 "4.AA" 5 "5.BA" 6 "6.MA/MS/MBA" 7 "7.Law/MD/PhD"
  label values degree degree
	
	label var educlvl "Four levels of education"
	label define educlvl 1 "1.Lt HS/GED" 2 "2.HS/somecolleg/AA" 3 "3.BA" 4 "4.MA+"
	label values educlvl educlvl
	


label var colldegyr "Year completed highest degree" 
label var somecollyr "Year associated with some college"
label var hsdegyr "Year completed high school"
label var gedgradyr "Year completed GED"

label var sp_id "hhidpn of spouse/partner"

	* Health fvars at age 25 
	label var fstrok25 "Stroke onset by age 25"
	label var fheartattack25 "Heart attack onset by age 25"
	label var fheart25 "Heart disease onset by age 25"
	label var fhibp25 "Hypertension onset by age 25"
	label var fasthma25 "Asthma onset by age 25"
	label var flung25 "Lung disease onset by age 25"
	label var fdiab25 "Diabetes onset by age 25"
	label var farthritis25 "Arthritis onset by age 25"
	label var fmemry25 "Memory loss onset by age 25"
	label var flearndis25 "Learning disorder onset by age 25"
	label var fcancr25 "Cancer onset by age 25"
	label var fpsych25 "Psychiatric problems onset by age 25"
	
	* Health fvars at age 25 - intended for the Abecedarian project 
	label var fstrok30 "Stroke onset by age 30"
	label var fheartattack30 "Heart attack onset by age 30"
	label var fheart30 "Heart disease onset by age 30"
	label var fhibp30 "Hypertension onset by age 30"
	label var fasthma30 "Asthma onset by age 30"
	label var flung30 "Lung disease onset by age 30"
	label var fdiab30 "Diabetes onset by age 30"
	label var farthritis30 "Arthritis onset by age 30"
	label var fmemry30 "Memory loss onset by age 30"
	label var flearndis30 "Learning disorder onset by age 30"
	label var fcancr30 "Cancer onset by age 30"
	label var fpsych30 "Psychiatric problems onset by age 30"
	
	label var dlylgtexc "Daily light exercise (standardized to times per day)"
	label var dlyhvyexc "Daily heavy exercise (standardized to times per day)"
	label var dlymuscle "Daily weight lifting (standardized to times per day)"



/*
label define fthreduclvl 0 "0 Less than high school" 1 "1 high school" 2 "2 Some college, includes associates" 3 "3 Bachelor" 4 "4 Grad school"
label values fthreduclvl fthreduclvl

label define mthreduclvl 0 "0 Less than high school" 1 "1 high school" 2 "2 Some college, includes associates" 3 "3 Bachelor" 4 "4 Grad school"
label values mthreduclvl mthreduclvl
*/
	
label define childses 1 "1 Poor" 2 "2 Average or varied" 3 "3 Well off"
label values childses childses
	
label define chldsrh 5 "5 Excellent" 4 "4 Very good" 3 "3 Good" 2 "2 Fair" 1 "1 Poor"
label values chldsrh chldsrh
	
label define grewup 1 "1 Farm or rural" 2 "2 Town or suburb" 3 "3 City or large city" 4 "4 Other or several different places"
label values grewup grewup

label var proptax "Household property taxes"

label define ofchlvl 0 "Never" 1 "Once a week or more" 2 "Once a month or more" 3 "Less than once a month"
label values ofch ofchlvl 


/* 
The eversep ("Ever seperated from marriage or cohabitation") variable has not been developed.
Using everds ("Ever divorced") as a temporary replacement until the final version is developed.
*/
gen eversep = everds
label var eversep "Ever seperated from marriage or cohabitation"

* Merge on the economic variables
merge 1:1 hhidpn year using "$outdata/psid_econ.dta"
tab _merge
drop if _merge == 2
tab seq relhd if _merge!=3, m
tab seq relhd if _merge!=3 & diabe < . ,m
drop _merge


#d ;
global psid_econ ssiamt adcamt anyunwc unwcamt gxframt anygxfr hatota work retired anyhi hipri himcr himcd himil hioth
iearn hicap ssiclaim anyadc ipena anyipena pxframt anypxfr diclaim oasiclaim anydb anydc db_tenure nage_db eage_db
iearnx logiearnx hatotax loghatotax wlth_nonzero 
vapenamt fdstmpamt welfamt igxfr hicap_nonzero igxfr_nonzero
totalfaminc
;

#d cr 

* Label econ variables
label var hatota "Household wealth"

* Merge on consumption variables from 1999-2013 and earlier
cap drop _merge
merge m:1 famnum year using $outdata/con9913.dta
drop _merge
foreach var in hous food tran health trips ed cloth othrec child {
	replace con`var' = `var' if inrange(year,1999,2013)
} 

egen consumption = rowtotal(conhous confood contran conhealth contrips coned concloth conothrec conchild)
label var consumption "Annual consumption (housing+food+transportation+healthcare+trips+education+clothing+childcare), fully-defined 2005+"

bys year: sum consumption, detail


*==================================*
* Adjust dollar values (in 2009 dollars)
*==================================*
	// CPI adjusted social security income
	global colcpi "1991 1992 1993 1994 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015"
	#d;
	matrix matcpiu = 
	(136.2,
	140.3,
	144.5,
	148.2,
	152.4,
	156.9,
	160.5,
	163,
	166.6,
	172.2,
	177.1,
	179.9,
	184,
	188.9,
	195.3,
	201.6,
	207.3,
	215.303,
	214.537,
	218.056,
	224.939,
	229.594,
	232.957,
	236.736,
	237.017);
	#d cr
	
	matrix colnames matcpiu = $colcpi
	matrix list matcpiu

forvalues i = $firstyr/$lastyr {
	foreach var in ssiamt adcamt hatota iearn hicap ipena pxframt proptax vapenamt fdstmpamt welfamt igxfr hicap totalfaminc consumption ssdiamt ssoasiamt  { 
			replace `var' = matcpiu[1,colnumb(matcpiu,"2009")]*`var'/matcpiu[1,colnumb(matcpiu,"`i'")] if year == `i' 
	}
}

replace iearn = iearn/1000 if !missing(iearn)
replace hatota = hatota/1000 if !missing(hatota)
replace iearnx = min(iearn,200) if iearn < .
replace hatotax = min(hatota,2000) if hatota < .
replace logiearnx = log(iearnx+sqrt(1+iearnx^2))/100
replace loghatotax = log(hatotax+sqrt(1+hatotax^2))/100

gen iearn_real = iearn
label var iearn_real "Earnings in thousands in 2009 dollars.  This will be used in the simulation without inflation adjustment"
gen hicap_real = hicap
label var hicap_real "capital income in 2009 dollars.  This will be used in the simulation without inflation adjustment"

gen proptax_nonzero = proptax != 0 if !missing(proptax)
label var proptax_nonzero "Nonzero property taxes paid"

* Recode adlstat and iadlstat to conform to FEM variables
rename adlstat adlstat_old
rename iadlstat iadlstat_old
recode adlstat_old (0 = 1) (1 = 2) (2 = 3) (nonmissing = 4), gen(adlstat)
recode iadlstat_old (0 = 1) (1 = 2) (nonmissing = 3), gen(iadlstat)
drop adlstat_old iadlstat_old

* Recode smkstat variable
*** Recode smoking status
	gen smkstat = smokev + 1
	replace smkstat = 3 if smoken == 1
	replace smkstat = . if missing(smokev) | missing(smoken)
	label define smklb 1 "1 Never smoked" 2 "2 Ex smoker" 3 "3 Cur smoker", modify
	label values smkstat smklb
	label var smkstat "Smoking status"

* Recode births variable
*** cap births at 2 and no births in CAH if female is over 44
	rename births births_old 
	recode births_old (0 = 1) (1 = 2) (2 3 = 3) (missing = .), gen(births)
	gen paternity = births

	replace births = . if male == 1 
	replace paternity = . if male == 0 

	
	* Gen wtstate variable
	gen wtstate=0*bmi
	replace wtstate = 1 if overwt==0 & obese == 0
	replace wtstate = 2 if overwt == 1
	replace wtstate = 3 if bmi >=30 & bmi < 35
	replace wtstate = 4 if bmi >=35 & bmi < 40
	replace wtstate = 5 if bmi >= 40 & bmi < .
	label var wtstate "BMI status"
	label define wtlb 1 "1 normal or underwt" 2 "2 overweight" 3 "3 obese1" 4 "4 obese2" 5 "5 obese3", modify
	label values wtstate wtlb
	
  gen obese_1 = wtstate == 3 if wtstate < .
	gen obese_2 = wtstate == 4 if wtstate < .
	gen obese_3 = wtstate == 5 if wtstate < .
	
	label var obese_1 "BMI in [30,35)"
	label var obese_2 "BMI in [35,40)"
	label var obese_3 "BMI >= 40"
	
	* Transform BMI	
	gen logbmi = ln(bmi)
	
	label var logbmi "log(BMI)"
	
	* Gen educ level dummy variables
	*** also generate dummy to use as 4 level education variable
	forvalues x = 1/4 {
		gen educ`x' = (educlvl == `x') if !missing(educlvl)
	}
		
	label var educ1 "Less than HS/GED"
	label var educ2 "High school/some college/AA"
	label var educ3 "College"
	label var educ4 "Beyond college"
	
	
	* Clean up dummy variables
	drop hsless
	drop college
	gen hsless = (educlvl == 1)
	* College with this definition is BA or more.
	gen college = inlist(educlvl,3,4)


	label var hsless "Less than HS or GED education"
	label var college "College degree or higher"


	* Gen parents' education dummy variables (educ_1 = less than high school, educ_2 = high school, educ_3 = some college (no bach), educ_4 = bachelors or higher)
	gen fthreduc1 = inlist(feduc,1,2,3) if !missing(feduc)
	gen fthreduc2 = inlist(feduc,4) if !missing(feduc)
	gen fthreduc3 = inlist(feduc,5) if !missing(feduc)
	gen fthreduc4 = inlist(feduc,6) if !missing(feduc)

	gen mthreduc1 = inlist(meduc,1,2,3) if !missing(meduc)
	gen mthreduc2 = inlist(meduc,4) if !missing(meduc)
	gen mthreduc3 = inlist(meduc,5) if !missing(meduc)
	gen mthreduc4 = inlist(meduc,6) if !missing(meduc)

	label var fthreduc1 "R's father less than high school"
	label var fthreduc2 "R's father high school grad"
	label var fthreduc3 "R;s father some college"
	label var fthreduc4 "R's father college graduate"

	label var mthreduc1 "R's mother less than high school"
	label var mthreduc2 "R's mother high school grad"
	label var mthreduc3 "R;s mother some college"
	label var mthreduc4 "R's mother college graduate"	

	tab fthreduc1 feduc
	tab fthreduc2 feduc
	tab fthreduc3 feduc
	tab fthreduc4 feduc
	
	tab mthreduc1 meduc
	tab mthreduc2 meduc
	tab mthreduc3 meduc
	tab mthreduc4 meduc
			
	* Gen dummy variables for childhood SES	
	gen fpoor = (childses == 1)
	gen frich = (childses == 3)
	
	label var fpoor "Poor as a child"
	label var frich "Wealthy as a child"
	
	* Gen dummy variables for childhood self-reported health
	gen poorchldhlth = (chldsrh == 1 | chldsrh == 2)
	label var poorchldhlth "Fair or poor health before age 17"
	
	
	* In labor force, not "out of labor force"
	rename outoflabor inlaborforce
	recode inlaborforce (1=0) (0=1)
	
	label var inlaborforce "Working or unemployed"
	
	* Generate work categorical variable 
	gen workstat = .
	
	* Unemployed or out of labor force - less thatn 200 hours in a year
	replace workstat = 1 if workweeks*weekworkhr <= 200
	* Part-time, part of the year - less than 40 weeks and less than 35 hours per week
	replace workstat = 2 if (workweeks*weekworkhr > 200) & workweeks <= 40 & weekworkhr <= 35  
	* Part-time, all of the year - more than 40 weeks, but less than 35 hours per week
	replace workstat = 3 if (workweeks*weekworkhr > 200) & workweeks > 40 & workweeks < . & weekworkhr <= 35  
	* Full-time, part of the year - more than 35 hours per week, but less than 40 weeks
	replace workstat = 4 if (workweeks*weekworkhr > 200) & workweeks <= 40 & weekworkhr > 35 & weekworkhr < .
	* Full-time, all of the year  - more than 40 weeks and more than 35 hours per week
	replace workstat = 5 if (workweeks*weekworkhr > 200) & workweeks > 40 & workweeks < . & weekworkhr > 35 & weekworkhr < .
		
	label var workstat "Categorical variable of work status"
	label define workstat 1 "Unemployed or out of labor force" 2 "Part-time, part of the year" 3 "Part-time, all year" 4 "Full-time, part of the year" 5 "Full-time, all year"
	label values workstat workstat
	
forvalues i = 1/5 {
	gen workstat`i' = (workstat == `i')
	label var workstat`i' "DEPRECATED - use workcat instead"
}
	
	recode workstat (1 = 1) (2/4 = 2) (5 = 3), gen(workstat_alt)
	label var workstat_alt "Three level work status: unemployed, part-time, full-time"
	label define workstat_alt 1 "Unemployed" 2 "Part-time" 3 "Full-time"
	label values workstat_alt workstat_alt
	
forvalues i = 1/3 {
	gen workstat_alt`i' = (workstat_alt == `i')
	label var workstat_alt`i' "DEPRECATED - use workcat instead"
}

/* More work alternatives,  */
* Out of labor force, unemployed, employed - based on first response (of 3) to "what are you doing now" question
gen laborforcestat = .
replace laborforcestat = 1 if inlist(empstat1st,4,5,6,7,8) 
replace laborforcestat = 2 if inlist(empstat1st,3) 
replace laborforcestat = 3 if inlist(empstat1st,1,2)

label var laborforcestat "Labor force status"
label define laborforcestat 1 "Out of labor force" 2 "Unemployed" 3 "Employed"
label values laborforcestat laborforcestat

* Full-time  (1) or part-time (0)
gen fullparttime = .
replace fullparttime = 1 if workstat_alt == 3
replace fullparttime = 0 if workstat_alt == 2

label var fullparttime "Full-time (1) or part-time (0)"

/* Work category
1 = out of labor force
2 = unemployed
3 = part-time
4 = full-time */
gen workcat = .
replace workcat = 1 if inlist(empstat1st,4,5,6,7,8) 
replace workcat = 2 if inlist(empstat1st,3) 
replace workcat = 3 if inlist(empstat1st,1,2) & workstat_alt == 2
replace workcat = 4 if inlist(empstat1st,1,2) & workstat_alt == 3
label var workcat "Categorical work variable"
label define workcat 1 "Out of labor force" 2 "Unemployed" 3 "Part-time" 4 "Full-time" 
label values workcat workcat
	
tab deathyr year

* Keep only the observations that were interviewed in a year or who died since the last interview
keep if inyr == 1 | deathyr == 1
* Keep only heads and wives

tab deathyr

keep if hdwf == 1 | (deathyr == 1 & everhdwf == 1)

* Replace hhid (based on famnum68) with hhid_new (based on hhidpn of head)
merge 1:1 hhidpn year using `hhid_new', keepusing(hhid_new)
drop _merge

drop hhid
rename hhid_new hhid
label var hhid "household ID based on HHIDPN of head"

* generate some diagnostic variables
gen misshhid = missing(hhid)
gen has_spid = !missing(sp_id)
sort hhidpn year
gen haslag = hhidpn[_n-1]==hhidpn
gen lsp_id = sp_id[_n-1] if haslag

/***** Set up cohab flag for everyone, not just wives *****/
tab relhd cohab, m
tab seq cohab, m
tab seq if deathyr==1, m

* set cohab flag for "wives" who died while cohabiting
replace cohab = 1 if inlist(relhd,22,88) & inrange(seq,80,90)

* If a "wife" is alive and cohabitating, so is the living head 
gen cohab_alive = cohab==1 & !inrange(seq,80,90)
bys hhid year: egen cohab_hh = total(cohab_alive)
replace cohab = 1 if cohab_hh==1 & relhd==10 & !inrange(seq,80,90)
replace cohab = 0 if cohab == .

* if a cohab head dies and then "wife" remarries or finds a new cohab, we need to flag the original head as cohab at death
gen newcohab = relhd==88
bys hhid year: egen newcohab_hh = max(newcohab)
sort hhidpn year
gen qwf2hd = relhd==10 & inlist(relhd[_n-1],22,88) & haslag
bys hhid year: egen qwf2hd_hh = max(qwf2hd)
gen hddied = relhd==10 & inrange(seq,80,90)
bys hhid year: egen hddied_hh = max(hddied)
replace cohab=1 if hddied & newcohab_hh>0 & qwf2hd_hh==1

* relabel cohab variable because it now refers to heads and wives, not just wives
label var cohab "Cohabitating"
tab relhd cohab, m
drop cohab_hh
tab cohab misshhid, m
tab cohab deathyr, m
/**********************************************************/

*****************************************************************************************************
* Generate a new married categorical variable that includes single, cohabitating, and married
* Use marriage history variables except for cohab
bys died: tab cohab sgl, m
bys died: tab cohab mar, m
bys died: tab cohab single, m
bys died: tab cohab married, m
gen mstat_new = .
replace mstat_new = 1 if sgl == 1
replace mstat_new = 1 if wid == 1 /* single if widowed */
replace mstat_new = 2 if cohab == 1 /* cohabitation overrides single and married status */
replace mstat_new = 3 if cohab == 0 & mar == 1
gen ms_source=1 if mstat_new !=.
** use person status source to fill missing values
replace mstat_new = 1 if mstat_new==. & single ==1
replace mstat_new = 1 if mstat_new==. & widow ==1
replace mstat_new = 3 if mstat_new==. & cohab==0 & married==1
replace ms_source=2 if !missing(mstat_new) & missing(ms_source)
label define ms_srclbl 1 "marriage history file" 2 "person status"
label values ms_source ms_srclbl
tab mstat_new ms_source,missing
tab ms_source if missing(hhid), m
tab age if missing(hhid), m
sum age if missing(hhid)
count if age > 45 & missing(hhid)
count if age < 13 & missing(hhid)
count if age >=13 & age <=45 & missing(hhid)

label define statusv 1 "single" 2 "Cohabiting" 3 "Married" 
label value mstat_new statusv
label var mstat_new "Marital Status (single, cohab, married)"

* check for conflicting marital status w/in HH
gen cohab_tmp = mstat_new==2 if !missing(mstat_new)
gen married_tmp = mstat_new==3 if !missing(mstat_new)
bys famnum year: egen cohab_hh2 = max(cohab_tmp) if famnum != 0
bys famnum year: egen married_hh = max(married_tmp) if famnum !=0
tab cohab_hh2 married_hh, m
drop cohab_tmp cohab_hh2 married_tmp married_hh

*****************************************************************************************************

* partnership and partnership type variables
gen partnered = (mstat_new == 2 | mstat_new == 3)
gen partnertype = .
replace partnertype = 0 if mstat_new == 2
replace partnertype = 1 if mstat_new == 3

label var partnered "married or cohabitating"
label var partnertype "0 = cohab, 1 = married"

* Need "died" not "diedyr"
ren deathyr died

/******************** Define partner death ***********************/
* define partner death, include existing widowhood
gen partdied = widowed==1 & mstat_new==1
replace partdied = 0 if missing(widowed)
di "existing widowhood data:"
tab year partdied, m
* number of dead people in HH:
sort hhidpn year
*replace partdied = 1 if year-2 < sdeath_yr & sdeath_yr < year
*replace partdied = 1 if sdied==1
* number of dead people in HH:
bys famnum year: egen hhndied = total(died) if famnum != 0
replace hhndied = died if famnum == 0
* partner died if person is alive, not new to the PSID, and other member of their household died:
bys hhid year: gen hhsize=_N
sort hhidpn year
replace partdied = 1 if died==0 & hhndied > 0 & hhidpn[_n-1] != hhidpn & hhsize==2
drop hhndied
di "partner death (incl. widowhood):"
tab year partdied, m

* define widowhood when partner dies and person is currently or previously married
di "existing widowhood data:"
tab year widowed, m
sort hhidpn year
replace widowed = 1 if hhsize==2 & partdied==1 & (mstat_new==3 | (mstat_new[_n-1]==3 & hhidpn[_n-1]==hhidpn))
di "final widowhood definition:"
tab year widowed, m
* there are a few cases where a widow finds a new partner (marriage or cohab) in the same year their spouse dies so hhsize==3
* we decided not to flag them as widows
tab year hhsize if died, m

* check marital status and widowhood for people with a partner in this wave and previous wave
gen has_sp = !missing(sp_id)
sort hhidpn year
gen lhas_sp = has_sp[_n-1] if hhidpn[_n-1] == hhidpn
tab mstat_new has_sp, m row
bys died: tab mstat_new has_sp, m row
bys died: tab mstat_new lhas_sp, m row
tab mstat_new lhas_sp, m row
tab misshhid has_sp, m row


/******************** Marriage Model Variables ***********************/
/* married tag includes cohab (wife or "wife") */

gen legmar = (married==1 & cohab!=1) if married !=. & cohab !=.
tab legmar cohab,missing
tab married legmar,missing
tab partnertype legmar,missing

sort hhidpn year
by hhidpn (year): gen mvtog = (married==1 & married[_n-1]==0 ) if _n!=1 & inlist(married,0,1) & inlist(married[_n-1],0,1)
by hhidpn (year): replace mvtog = -2 if married==1 & married[_n-1]==1 
replace mvtog = 9 if died==1
gen evermvtog=0
by hhidpn (year): replace evermvtog=max(evermvtog[_n-1],mvtog) if _n!=1
by hhidpn (year): gen getmar = (legmar==1 & legmar[_n-1]==0) if evermvtog==1 | cohab==1
by hhidpn (year): replace getmar = -2 if getmar==1 & getmar[_n-1]==1

drop evermvtog
tab mvtog getmar, missing
tab mvtog married, missing
tab getmar legmar,missing

label var legmar "Legally married"
label var mvtog "Moved together since last interview (cohab or marriage)"
label var getmar "Get married since last interview"

* make partdied and widowed absorbing until next partner is found
sort hhidpn year
replace partdied = 1 if partdied[_n-1]==1 & mstat_new==1 & hhidpn[_n-1]==hhidpn
replace widowed = 1 if widowed[_n-1]==1 & mstat_new==1 & hhidpn[_n-1]==hhidpn
* check that no one is widowed when partdied==0
tab partdied widowed, m

* create absorbing widowev ("widowed ever") variable
sort hhidpn year
gen widowev = widowed
replace widowev = 1 if widowev[_n-1]==1 & hhidpn[_n-1]==hhidpn
* flag widowev when hhsize==3 even though the person is not considered a widow because they remarried
replace widowev = 1 if hhsize==3 & partdied==1 & hhidpn[_n-1]==hhidpn & hhid[_n-1]==hhid

* break up households so partners will not be linked in the simulation
replace hhid = hhidpn

label var partdied "Most recent partner died" 
label var widowed "Widowed: most recent spouse died"
label var widowev "Ever widowed"
drop hhsize 

* drop first-year cohabs
/** \todo some first-year cohabs have lagged values, should they be included? */
drop if relhd == 88


* k6 - create a measure of severe distress; 
gen k6severe=respk6scale>=13
replace k6severe=. if respk6scale==.
label var k6severe "Severe Mental Distress"

rename respk6scale k6score
* This is going to be an ordere probit, which is indexed starting at 1
replace k6score = k6score + 1
label var k6score "Kessler distress score [1-25]"

* Recode number of alcoholic drinks (changed in 2005) */
gen alcintensity = .

* Less than once a month -> 5 times a year
replace alcintensity = 5*alcdrinks/365 if alcfreq == 1 & year >= 2005

* About once a month case -> 12 times a year
replace alcintensity = 12*alcdrinks/365 if alcfreq == 2 & year >= 2005

* Several times a month -> 36 times a year
replace alcintensity = 36*alcdrinks/365 if alcfreq == 3 & year >= 2005

* About once a week -> 52 times a year
replace alcintensity = 52*alcdrinks/365 if alcfreq == 4 & year >= 2005

* Several times a week -> -> 150 times a year
replace alcintensity = 150*alcdrinks/365 if alcfreq == 5 & year >= 2005

* Every day -> 365 times a year
replace alcintensity = 365*alcdrinks/365 if alcfreq == 6 & year >= 2005

* Categories at 0, less than 1, 1-2, 3-4, and 5+
gen alc_cat = .
* non-drinkers post-2005
replace alc_cat = 0 if alcohol == 0 & year >= 2005
replace alc_cat = 0 if alcintensity ==0 & alcohol == 1 & year >= 2005
replace alc_cat = 1 if alcintensity > 0 & alcintensity < 1 & alcohol == 1 & year >= 2005
replace alc_cat = 2 if alcintensity >= 1 & alcintensity < 3 & alcohol == 1 & year >= 2005
replace alc_cat = 3 if alcintensity >= 3 & alcintensity < 5 & alcohol == 1 & year >= 2005
replace alc_cat = 4 if alcintensity >= 5 & alcohol == 1 & year >= 2005

* Before 2005 they asked about average drinks per day
replace alc_cat = alcdrinks if year < 2005


drop alcdrinks alcfreq

label define alc_cat 0 "Never" 1 "Less than one a day" 2 "1-2 a day" 3 "3-4 a day" 4 "5 or more per day"
label values alc_cat alc_cat

label var alc_cat "categorical alcohol consumption variable"

*** Exercise recoding - doing any light or vigorous for now ***
gen anylightex = (dlylgtexc > 0) if !missing(dlylgtexc)
gen anyheavyex = (dlyhvyexc > 0) if !missing(dlyhvyexc)

gen anyexercise = (anylightex == 1) | (anyheavyex == 1) if !missing(anylightex) & !missing(anyheavyex)
replace anyexercise = anylightex if missing(anyheavyex)
replace anyexercise = anyheavyex if missing(anylightex)

label var anylightex "Any light exercise"
label var anyheavyex "Any heavy exercise"
label var anyexercise "Any light or heavy physical activity"





**********************************************************************************
* Merge on the jail/prison-related variables
merge 1:1 hhidpn year using $outdata/prison.dta
keep if _merge == 3
drop _merge


**********************************************************************************
* Merge on the TaxSim data for 1999-2011
merge 1:1 hhidpn year using $indata/psid_taxsim_1999_2011.dta
tab _merge
keep if inlist(_merge,1,3) | year > 2011
drop _merge

bys year famfid: gen size = _N if inyr == 1

* Adjust taxes by number in household
foreach var in fu_fica fu_fiitax fu_eic fu_ctc fu_ctcref fu_ccc fu_fiibc fu_siitax fu_sccc fu_seic fu_siicred {
	gen `var'_ind = `var'/size 
	drop `var'
}     

label var fu_fiitax_ind "Federal income tax liability - famunit divided between head and wife"
label var fu_eic_ind "Earned Income Credit (total federal) - famunit divided between head and wife"
label var fu_ctc_ind "Child Tax Credit - famunit divided between head and wife"
label var fu_ctcref_ind "Additional Child Tax Credit (refundable) - famunit divided between head and wife"
label var fu_ccc_ind "Child and Dependent Care Credit (federal) - famunit divided between head and wife"
label var fu_fiibc_ind "Federal income tax before credits - famunit divided between head and wife"
label var fu_siitax_ind "State income tax liability - famunit divided between head and wife"
label var fu_sccc_ind "State Child Care Credit - famunit divided between head and wife"
label var fu_seic_ind "State EIC - famunit divided between head and wife"
label var fu_siicred_ind "State total credits - famunit divided between head and wife"
label var fu_fica_ind "FICA payroll tax - famunit divided between head and wife"



*** Generate the lagged values ***

* Lists of variables for initial conditions and lagged variables
local zlist2 shlt srh
#d;
local flist widowed married age aged
smoken smokev bmi underwt overwt obese cancre diabe hearte hibpe lunge stroke adlstat iadlstat asthme
smkstat wtstate
single
logbmi
cohab mstat_new
nummar everm everds everw yrlstst yrmar 
births birthse numbiokids numbiokidslt18 kidsinfu yrsnclastkid siblings paternity
workweeks weekworkhr overtimehr yrworkhr 
workstat workstat1 workstat2 workstat3 workstat4 workstat5 
workstat_alt workstat_alt1 workstat_alt2 workstat_alt3 
died
eversep
inlaborforce
partdied widowev
workcat
edyrs
educp
degree
educlvl
inscat
packyears
jaile jaile_alt
respsadness respnervous resprestless resphopeless respeffort respworthless k6score k6severe
statecode 
respondent
/*iwmonth iwday iwyear*/
satisfaction
dlylgtexc dlyhvyexc dlymuscle
anylightex anyheavyex anyexercise
alcbinge
;
#d cr
bys hhidpn year: gen n_pyr = _N
tab n_pyr, m
li hhidpn year if n_pyr > 1
xtset hhidpn year, delta(2)

sort hhidpn year, stable
by hhidpn: gen firstyear = year[1]
by hhidpn: gen lastyear = year[_N]
by hhidpn: gen twave = _N


* Only keep those who are continuous respondents (we probably want to revisit this!)
* drop if twave < (lastyear - firstyear + 2)/2
* drop twave

* Drop individuals only interviewed in a single year since they can't have lagged values.
gen newobservation = (twave == 1)

sort hhidpn year, stable

* Lag conditions loop
foreach v in `zlist2' `flist' $psid_econ year {
	qui gen l2`v' = l.`v'
	local vlb: var label `v'
	label var l2`v' "Lag of `vlb'"
}

	
* Deal with education dummies for those who died, as educlvl is not populated correctly in death wave - these variables are only used in mortality estimation
replace hsless = L.hsless if died == 1
replace college = L.college if died == 1

* Deal with missing values for age and birthyear - assigning missings to July 1 of possible birth year
replace age = . if age == 999
replace rbyr = year - age if rbyr == 9999
replace rbmonth = 7 if rbmonth == 99 

* deal with missing values for DI benefit amount, set to 0 if missing
replace diclaim = 0 if mi(diclaim)
replace ssdiamt = 0 if mi(ssdiamt) & year>=2005 

* Initial conditions loop
foreach v in `zlist2' `flist' $psid_econ rbyr {
	sort hhidpn year, stable
	by hhidpn: gen f`v' = `v'[1]
	local vlb: var label `v'
	label var f`v' "Init Cond of `vlb'"
}

drop /*firstyear*/ lastyear twave


clonevar hhidpn_orig = hhidpn
clonevar hhid_orig = hhid

gen original_psid = (pn68< 170) if !missing(pn68)
label var original_psid "Member or descendent from original 1968 PSID family"

* Save the file to be used for transition estimations
save "$outdata/psid_analytic.dta", replace

capture log close
