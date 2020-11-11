clear
set maxvar 10000
log using reshape_long.log, replace

quietly include ../../../fem_env.do

local in_file : env INPUT
local out_file : env OUTPUT
local scr : env SCENARIO

*use ../../../input_data/H_ELSA_f_2002-2016.dta, clear
use $outdata/H_ELSA_f_2002-2016.dta, clear

global firstwave 1
global lastwave 8

local seed 5000
set seed `seed'
local num_imputations 3
local num_knn 5

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
r*clust
r*cwtresp
r*iwindy
r*iwindm
rabyear
radyear
r*agey
ragender
raeduc_e
raeducl
s*educl
ramomeduage
radadeduage
raracem
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
;
#d cr

* Rename h*coupid to a more useful form
forvalues wv = $firstwave/$lastwave {
    rename h`wv'coupid r`wv'hhid
    rename h`wv'atotf r`wv'atotf
}

* Rename drink vars to more readable (and pleasant) form - r*drinkd
* Also rename exercise variables in the near future
forvalues wv = $firstwave/$lastwave {
	if `wv' >= 2 {
		/* drinkd_e not present in wave 1 */
		rename r`wv'drinkd_e r`wv'drinkd
    }
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
      { ;
            forvalues i = $firstwave(1)$lastwave { ;
                cap confirm var r`i'`var';
                if !_rc{;
                    ren r`i'`var' `var'`i';
                };
            };
    } ;
#d cr

* Seperate for renaming spousal vars
forvalues wv = $firstwave/$lastwave {
    rename s`wv'educl educl`wv'
}

* Reshape data from wide to long
#d ;
reshape long iwstat strat cwtresp iwindy iwindm agey walkra dressa batha eata beda 
    toilta mapa phonea moneya medsa shopa mealsa housewka hibpe diabe cancre lunge 
    hearte stroke psyche arthre bmi smokev smoken smokef hhid work hlthlm 
    asthmae parkine itearn ipubpen retemp retage atotf vgactx_e mdactx_e ltactx_e 
    drink drinkd educl
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
label variable educl "Spouse Harmonised Education Level"
label variable ramomeduage "Age mother left education"
label variable radadeduage "Age father left education"


* Use harmonised education var
gen educ = raeducl
label variable educ "Harmonised Education Level"
label define educ 1 "1.Less than Secondary" 2 "2.Upper Secondary and Vocational" 3 "3.Tertiary"
label values educ educ
drop raeducl

* Create separate variables for hsless (less than secondary school) and college (university)
gen hsless = (educ == 1)
gen college = (educ == 3)

* Label males
gen male = (ragender == 1) if !missing(ragender)
label variable male "Male"

* Label white
gen white = (raracem == 1) if !missing(raracem)
label var white "White"

* Find if dead with iwstat var
gen died = (iwstat == 5) if !missing(iwstat)
* Keep only those alive or recently deceased
/* Dropping the 0 (inap.? Unknown code) 6 (previously deceased), 7 (dropped from sample) 
and 9 (non-response, unkown if dead or alive) */
keep if inlist(iwstat,1,4,5)

* FEM uses hhidpn as the person ID
gen hhidpn = idauniq
replace hhid = hhidpn

* generate birth year and age variable for naming conventions
gen rbyr = rabyear
gen age = agey

* Year variable derived from wave (wave 1: 2002-3, wave 2: 2004-5...)
gen year = 2000 + wave*2

* Age is top-coded at 90 in ELSA data. Therefore calculate correct age from birthyear (also calculate if missing age but not birth year)
*replace age = year - rbyr
replace age = (year - rbyr) if missing(age) & !missing(rbyr)
replace age = (year - rbyr) if age >= 90

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

* Handle missing bmi values
bys hhidpn: ipolate bmi wave, gen(bmi_ipolate) epolate
replace bmi = bmi_ipolate if missing(bmi)

** Now add some noise to the BMI interpolation **
* Decision for rnormal boundaries (-2,2) was based on the RMSE of US bmi regression model
gen rand = rnormal(-2, 2) if (wave==1 | wave==3 | wave==5 | wave==7)
replace bmi = bmi + rand if !missing(rand)

* log(bmi)
gen logbmi = log(bmi) if !missing(bmi)

* Generate dummy for obesity
* This is already generated in generate_transition_pop.do. TODO: change gen_trans_pop.do to replace instead of generate
gen obese = (bmi > 30.0) if !missing(bmi)

* Generate a categorical variable for BMI to get summary stats by group
* cut() has to include both the lower and upper limits (which is why both 0 and 100 are included)
egen bmi_cat = cut(bmi), at(0, 18.5, 25, 30, 40)

* Handle weird smoking status (smoke now but not smoke ever, nonsensical)
*count if smokev==0 & smoken==1
replace smokev = 1 if smoken==1 & smokev==0

*Categorical smoking variable
gen smkstat = 1 if smokev == 0 & smoken == 0
replace smkstat = 2 if smokev == 1 & smoken == 0
replace smkstat = 3 if smoken == 1
label define smkstat 1 "Never smoked" 2 "Former smoker" 3 "Current smoker"
label values smkstat smkstat

* Calculate drinkwn from drinkn for waves 2 and 3

*count if missing(drinkd)
* Create categorical drinking variable (for days of week - drinkd) (using adlstat as template)
recode drinkd (0=1) (1/2 = 2) (3/4 = 3) (5/7 = 4), gen(drinkd_stat)
label define drinkd_stat 1 "Teetotal" 2 "Light drinker" 3 "Moderate drinker" 4 "Heavy drinker"
label values drinkd_stat drinkd_stat
*count if missing(drinkd_stat)

* No create some dummy categorical vars from drinkd_stat for estimating other transition models
gen drinkd1 = drinkd_stat==1 if !missing(drinkd_stat)
gen drinkd2 = drinkd_stat==2 if !missing(drinkd_stat)
gen drinkd3 = drinkd_stat==3 if !missing(drinkd_stat)
gen drinkd4 = drinkd_stat==4 if !missing(drinkd_stat)

label variable drinkd1 "Teetotal"
label variable drinkd2 "Light Drinker"
label variable drinkd3 "Moderate Drinker"
label variable drinkd4 "Heavy Drinker"

* Generate an exercise status variable to hold exercise info in single var
* Three levels:
*   1 - No exercise
*   2 - Light exercise 1+ times per week
*   3 - Moderate/Vigorous exercise 1+ times per week
* Third try now
gen exstat = .
replace exstat = 1 if (ltactx_e == 4 | ltactx_e == 5) & (mdactx_e == 4 | mdactx_e == 5) & (vgactx_e == 4 | vgactx_e == 5)
replace exstat = 2 if (ltactx_e == 2 | ltactx_e == 3) & (mdactx_e == 4 | mdactx_e == 5) & (vgactx_e == 4 | vgactx_e == 5)
replace exstat = 3 if (mdactx_e == 2 | mdactx_e == 3) | (vgactx_e == 2 | vgactx_e == 3)

* Now dummy categorical vars for including in transition models
gen exstat1 = 1 if exstat == 1
replace exstat1 = 0 if exstat != 1
gen exstat2 = 1 if exstat == 2
replace exstat2 = 0 if exstat != 2
gen exstat3 = 1 if exstat == 3
replace exstat3 = 0 if exstat != 3

*** Generate lagged variables ***
* xtset tells stata data is panel data (i.e. longitudinal)
xtset hhidpn wave
* Make sure that smokev is an absorbing state
replace smokev = 1 if L.smokev == 1 & smokev == 0
* L.***, L is lag operator; can use L2 for 2 waves prior also
* can use this as xtset tells stata that data is panel data

#d ;
foreach var in
    iwstat
    agey
	age
    hibpe
    diabe
    cancre
    lunge
    hearte
    stroke
    psyche
    arthre
    bmi
    logbmi
    smokev
    smoken
    smokef
    died
    adlcount
    adlstat
    anyadl
    iadlcount
    iadlstat
    anyiadl
    smkstat
    educ
    work
    hlthlm
    asthmae
    parkine
    retemp
    retage
    ipubpen
    atotf
    itearn
    vgactx_e
    mdactx_e
    ltactx_e
    drink
    drinkd
    drinkd_stat
	drinkd1
	drinkd2
	drinkd3
	drinkd4
    exstat
    exstat1
    exstat2
    exstat3
    obese
    {;
        gen l2`var' = L.`var';
    };
;
#d cr

* Generate smoke_start and smoke_stop vars
gen smoke_start = 1 if l2smoken == 0 & smoken == 1
replace smoke_start = 0 if l2smoken == 0 & smoken == 0
gen smoke_stop = 1 if l2smoken == 1 & smoken == 0
replace smoke_stop = 0 if l2smoken == 1 & smoken == 1

*** Imputation Section ***
* Be aware of what this section is doing, particularly for missing cases!
* We want to assess how many people are missing and being assigned mean value on
* lines 289-293

* Generate a missing education variable
generate missing_educ = missing(educ)

* One record missing data for education
*drop if missing(educ)
* Education doesn't vary over time so can safely replace missing lag with current
replace l2educ = educ if missing(l2educ) & !missing(educ)

*save ../../../input_data/ELSA_long.dta, replace
save $outdata/ELSA_long.dta, replace

capture log close
