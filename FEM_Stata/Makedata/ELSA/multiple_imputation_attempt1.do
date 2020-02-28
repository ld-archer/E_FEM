clear
quietly include ../../../fem_env.do

local in_file : env INPUT
local out_file : env OUTPUT
local scr : env SCENARIO

*use ../../../input_data/H_ELSA.dta, clear
use $outdata/H_ELSA.dta, clear

global firstwave 1
global lastwave 7

local seed 5000

/* Variables from Harmonized ELSA:

Section A: Demographics, Identifiers, and Weights::
Person unique ID; CoupleID number; Spouse unique ID;
Interview status (morbidity); Stratification variable; 
Clustering variable; Person-level cross-sectional weight; 
Individual interview year; Individual interview month; Birth year; 
Death year; Age at interview (years); Gender; Education (categ).

Section B: Health::
ADLs. Some difficulty:
Walking across room; Dressing; Bathing/Shower; Eating;
Getting in/out of bed; Using the toilet.

IADLs. Some difficulty:
Using a map; Using a telephone; Managing money; 
Taking Medications; Shopping for groceries;
Preparing a hot meal; Doing work around the house or garden.

Doctor diagnosed health problems. Ever have condition:
High blood pressure; Diabetes; Cancer; Lung Disease;
Heart problems; Stroke; Psychological problems; 
Arthritis, Asthma, Parkinson's disease.

Height, Weight, BMI:
Height in meters; Weight in kilograms; BMI

Health Behaviours:
Smoke ever; Smoke now; How many cigs per day (avg);
Exercise(vigorous, moderate, light); Drinking ever;
# days/week drinks; # drinks/week.

Whether Health Limits Work.

Section E Financial and Housing Wealth::
Net Value of Non-Housing Financial Wealth;

Section F: Income and Consumption::
Individual employment earnings; Public pension income;

*/

* Dropping the longitudinal sample weight
drop r*lwtresp

* Keep these variables from the harmonized ELSA
#d ;
keep idauniq
h*coupid
r*iwstat
r*strat 
raclust
r*cwtresp
r*iwindy
r*iwindm
rabyear
radyear
r*agey
ragender
raeduc_e
raeducl
r*walkra
r*dressa
r*batha
r*eata
r*beda
r*toilta
r*mapa
r*phonea
r*moneya
r*medsa 
r*shopa
r*mealsa
r*housewka
r*hibpe
r*diabe 
r*cancre 
r*lunge
r*hearte
r*stroke 
r*psyche
r*arthre
r*bmi 
r*smokev
r*smoken
r*smokef
r*work
r*hlthlm
r*arthre
r*psyche
r*asthmae
r*parkine
r*retemp
r*retage
r*ipubpen
r*itearn
h*atotf
r*vgactx_e
r*mdactx_e
r*ltactx_e
r*drink
r*drinkd_e
r*drinkwn_e
;
#d cr

* Rename h*coupid to a more useful form
forvalues wv = $firstwave/$lastwave {
    rename h`wv'coupid r`wv'hhid
    rename h`wv'atotf r`wv'atotf
}

* Rename r*drinkd_e to more readable (and pleasant) form - r*drinkd
forvalues wv = $firstwave/$lastwave {
	if `wv' == 1 {
		continue /*drinkd_e has no data for wave 1 so continue*/
	}
	rename r`wv'drinkd_e r`wv'drinkd
}

* Rename variables to make reshape easier and have names consistent with US FEM
* Respondent?
#d ;
foreach var in 
    iwstat
    strat
    cwtresp
    iwindy
    iwindm
    agey
    walkra
    dressa
    batha
    eata
    beda
    toilta
    mapa
    phonea
    moneya
    medsa
    shopa
    mealsa
    housewka
    hibpe
    diabe 
    cancre 
    lunge
    hearte
    stroke 
    psyche
    arthre
    bmi
    smokev
    smoken
    smokef
    hhid
    work
    hlthlm
    asthmae
    parkine
    retemp
    retage
    ipubpen
    itearn
    atotf
    vgactx_e
    mdactx_e
    ltactx_e
    drink
    drinkd
    drinkwn_e
      { ;
            forvalues i = $firstwave(1)$lastwave { ;
                cap confirm var r`i'`var';
                if !_rc{;
                    ren r`i'`var' `var'`i';
                };
            };
    } ;
#d cr

* Reshape data from wide to long
#d ;
reshape long iwstat strat cwtresp iwindy iwindm agey walkra dressa batha eata beda 
    toilta mapa phonea moneya medsa shopa mealsa housewka hibpe diabe cancre lunge 
    hearte stroke psyche arthre bmi smokev smoken smokef hhid work hlthlm
    asthmae parkine itearn ipubpen retemp retage atotf vgactx_e mdactx_e ltactx_e
    drink drinkd drinkwn_e
, i(idauniq) j(wave)
; 

#d cr
label variable iwindy "Interview Year"
label variable iwindm "Interview Month"
label variable agey "Age at Interview (yrs)"
label variable walkra "Difficulty walking across room"
label variable dressa "Difficulty dressing"
label variable batha "Difficulty bathing/showering"
label variable eata "Difficulty eating"
label variable beda "Difficulty getting in/out of bed"
label variable toilta "Difficulty using the toilet"
label variable mapa "Difficulty using a map"
label variable phonea "Difficulty using a telephone"
label variable moneya "Difficulty  managing money"
label variable medsa "Difficulty taking medications"
label variable shopa "Difficulty shopping for groceries"
label variable mealsa "Difficulty preparing a hot meal"
label variable housewka "Difficulty doing housework/gardening"
label variable hibpe "Hypertension ever"
label variable diabe "Diabetes ever"
label variable cancre "Cancer ever"
label variable lunge "Lung disease ever"
label variable hearte "Heart disease ever"
label variable stroke "Stroke ever"
label variable psyche "Pyschological problems ever"
label variable arthre "Arthritis ever"
label variable bmi "BMI"
label variable smokev "Smoke ever"
label variable smoken "Smoke now"
label variable smokef "Average cigs/day"
label variable hhid "Household ID"
label variable work "Working for pay"
label variable hlthlm "Health limits work"
label variable itearn "Individual employment earnings (annual, after tax)"
label variable ipubpen "Public pension income (all types)"
label variable asthmae "Asthma ever"
label variable parkine "Parkinsons disease ever"
label variable retemp "Considers self retired"
label variable retage "Retirement age"
label variable atotf "Net Value of Non-Housing Financial Wealth"
label variable vgactx_e "Number of times done vigorous exercise per week"
label variable mdactx_e "Number of times done moderate exercise per week"
label variable ltactx_e "Number of times done light exercise per week"
label variable drink "Drinks at all"
label variable drinkd "# Days/week has a drink"
label variable drinkwn_e "# drinks/week"

* There are 5,362 records missing massive amounts of data, they are almost useless
* so should be removed. Easy way to do this is to remove those without an
* interview date:
*drop if missing(iwindy)
* Also a single person missing a birthyear, may as well get rid
*drop if missing(rabyear)

*** Recode Variables ***
/*
* Recode the education variable (HRS has 3 tiers of eductation, )
recode raeduc_e (1 = 1) (3/4 = 2) (5 = 3), gen(educ_h)
label variable educ_h "Education Level"
label drop educharm
label define educ_h 1 "1.No Qualifications" 2 "2.Less than University degree" 3 "3.University degree or higher"
label values educ_h educ_h
drop raeduc_e
*/

* Use harmonised education var
gen educ = raeducl
label variable educ "Harmonised Education Level"
label define educ 1 "1.Less than Secondary" 2 "2.Upper Secondary and Vocational" 3 "3.Tertiary"
label values educ educ
drop raeducl

*codebook educ

* Label males
gen male = (ragender == 1) if !missing(ragender)
label variable male "Male"

* Find if dead with iwstat var
gen died = (iwstat == 5) if !missing(iwstat)
* Keep only those alive or recently deceased
count
tab iwstat, m
/* Dropping the 0 (inap.? Unknown code) 6 (previously deceased), 7 (dropped from sample) 
and 9 (non-response, unkown if dead or alive) */
keep if inlist(iwstat,1,4,5)
count

* FEM uses hhidpn as the person ID
gen hhidpn = idauniq
replace hhid = hhidpn

* generate birth year and age variable for naming conventions
gen rbyr = rabyear
gen age = agey

*codebook age agey

* Year variable derived from wave (wave 1: 2002-3, wave 2: 2004-5...)
gen year = 2000 + wave*2

* No birth month in ELSA data (unlike HRS, KLoSA) so cannot calculate exact age
* Therefore keep agey as age variable (in years)

* Label cross-sectional sampling weight var
label variable cwtresp "Cross-Sectional sampling weight"

* ADL/IADL
egen adlcount = rowtotal(walkra dressa batha eata beda toilta)
egen iadlcount = rowtotal(mapa phonea moneya medsa shopa mealsa housewka)
recode adlcount (0=1) (1=2) (2=3) (3/7 = 4), gen(adlstat)
recode adlcount (0=0) (1/6 = 1), gen(anyadl)
recode iadlcount (0=1) (1=2) (2/7=3), gen(iadlstat)
recode iadlcount (0=0) (1/7=1), gen(anyiadl)
label define adlstat 1 "No ADLs" 2 "1 ADL" 3 "2 ADLs" 4 "3 or more ADLs"
label values adlstat adlstat
label define anyadl 0 "No ADLs" 1 "1 or more ADL" 
label values anyadl anyadl
label define iadlstat 1 "No IADLs" 2 "1 IADL" 3 "2 or more IADLs"
label values iadlstat iadlstat
label define anyiadl 0 "No IADLs" 1 "1 or more IADL" 
label values anyiadl anyiadl

gen adl1 = adlstat==2 if !missing(adlstat)
gen adl2 = adlstat==3 if !missing(adlstat)
gen adl3p = adlstat==4 if !missing(adlstat)

gen iadl1 = iadlstat==2 if !missing(iadlstat)
gen iadl2p = iadlstat==3 if !missing(iadlstat) 

* Only 35 records missing information on work and 38 missing for retemp (share 35),
* drop these to use for imputation
*replace retemp = . if missing(retemp)
*drop if missing(work)
*drop if missing(retemp)
* Check
*codebook work retemp

* Also 6 records consistently missing data for chronic diseases, removing missing
* cancre data removes these 6 records (pointless as contain no info on chronic
* diseases)
*drop if missing(cancre)
*drop if missing(hibpe)
*drop if missing(arthre)
*drop if missing(parkine)

* Check
*codebook cancre hibpe diabe lunge hearte stroke psyche asthmae arthre parkine

* Have to replace soft missing values with hard (.) missing
replace bmi = . if missing(bmi)
replace educ = . if missing(educ)
replace drink = . if missing(drink)
replace drinkd = . if missing(drinkd)

* Need to set data as longitudinal:
* xtset tells stata data is panel data (i.e. longitudinal)
xtset hhidpn wave

* Having a go at multiple imputation to replace a lot of the crap below
* Does this need to be after we produce lag variables? I'm not sure and don't really care anymore
* Set the style of the data as full long
mi set flong

* Variables to be imputed
local imputees bmi educ drink

* Regular variables (used in imputation) (cba listing everything)
local regulars ragender rbyr retemp work adlcount iadlcount hibpe diabe cancre lunge hearte stroke psyche asthmae arthre parkine

* Check some summary statistics of imputees and pattern of missing data
misstable summ `imputees'
misstable pattern `imputees'

* Register the variables to be imputed and listed regulars
mi register imputed `imputees'
mi register regular `regulars'

* Describe mi data
mi describe

* Having a go at imputing with PMM instead of regress and multiple logit/ologit 
mi impute chained (pmm, knn(10)) bmi drink educ ///
	= i.ragender rbyr i.retemp i.work i.adlcount i.iadlcount i.hibpe i.diabe i.cancre i.lunge i.hearte i.stroke i.psyche i.asthmae i.arthre i.parkine ///
	, add(5) chaindots rseed(`seed') force
	
*save ../../../input_data/ELSA_imputed1.dta, replace
	
mi extract 5

mi set flong
mi register imputed drinkd
mi register regular bmi educ drink `regulars'

mi impute chained (pmm, knn(10)) drinkd ///
	= i.ragender rbyr bmi i.educ i.work i.adlcount i.iadlcount i.hibpe i.diabe i.cancre i.lunge i.hearte i.stroke i.psyche i.asthmae i.arthre i.parkine ///
	, add(5) chaindots rseed(`seed') force
	
*save ../../../input_data/ELSA_imputed2.dta, replace
	
mi extract 5
	
* THIS TOOK FOREVER! Get a script working on here and then lets switch the data generation to the HPC
* Can easily do the stata part on HPC then scp the data to machine and run the other bit locally
* Bash script would do this? Make call to Makefile and then scp to local machine? Or some other type of transfer?

*save ../../../input_data/ELSA_long_imputed1.dta, replace
save $outdata/ELSA_long_imputed1.dta, replace
