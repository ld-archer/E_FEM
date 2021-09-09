clear
set maxvar 15000
log using reshape_long.log, replace

quietly include ../../../fem_env.do

local in_file : env INPUT
local out_file : env OUTPUT
local scr : env SCENARIO

*use ../../../input_data/H_ELSA_f_2002-2016.dta, clear
*use $outdata/H_ELSA_f_2002-2016.dta, clear
use $outdata/H_ELSA_g2.dta, clear

global firstwave 1
global lastwave 9

local seed 5000
set seed `seed'
local num_imputations 3
local num_knn 5

/* Variables from Harmonized ELSA:

Section A: Demographics, Identifiers, and Weights::
Person unique ID; CoupleID number; Spouse unique ID;
Interview status (morbidity); Person-level cross-sectional weight; 
Individual interview year; Individual interview month; Birth year; 
Death year; Age at interview (years); Gender; Education (categ);
Spouse's Harmonized Education (categ); Mother and Father age left
education; Marriage status; High Cholesterol; Hip Fracture;
self-reported health.

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
* REMOVED: r*strat, r*clust, raeduc_e
#d ;
keep idauniq
h*coupid
r*iwstat
r*cwtresp
r*iwindy
r*iwindm
rabyear
radyear
r*agey
ragender
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
r*asthmae
r*parkine
r*vgactx_e
r*mdactx_e
r*ltactx_e
r*drink
r*drinkd_e
r*drinkn_e
r*drinkwn_e
r*mstat
r*hchole
r*hipe
r*shlt
h*atotb
h*itot
r*smokef
r*lnlys
r*alzhe
r*demene
h*itot
r*lbrf_e
;
#d cr

* Rename household vars to a more useful form
forvalues wv = $firstwave/$lastwave {
    rename h`wv'coupid r`wv'hhid
    rename h`wv'atotb r`wv'atotb
    rename h`wv'itot r`wv'itot
}

* Rename drink vars to more readable (and pleasant) form - r*drinkd
* Also rename exercise variables in the near future
forvalues wv = $firstwave/$lastwave {
	if `wv' > 1 {
		/* drinkd_e not present in wave 1 */
		rename r`wv'drinkd_e r`wv'drinkd
    }
    if inlist(`wv', 2, 3) {
        /* drinkn_e only present in waves 2 & 3*/
        rename r`wv'drinkn_e r`wv'drinkn
    }
    if `wv' > 3 {
        /* drinkwn_e only present in waves 4+*/
        rename r`wv'drinkwn_e r`wv'drinkwn
    }
    /*Remove '_e' from labour force status var (don't know why they link inlcuding these)*/
    rename r`wv'lbrf_e r`wv'lbrf
}

* Rename variables to make reshape easier and have names consistent with US FEM
* Respondent?
* REMOVED: strat,
#d ;
foreach var in 
    iwstat
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
    hhid
    asthmae
    parkine
    vgactx_e
    mdactx_e
    ltactx_e
    drink
    drinkd
    drinkn
    drinkwn
    mstat
    hchole
    hipe
    shlt
    atotb
    itot
    smokef
    lnlys
    alzhe
    demene
    itot
    lbrf
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

*** Impute missing wave 1 for minimal ***
* Any variable missing wave 1 causes trouble for the minimal population, as it is derived from people in wave 1
* Therefore, for only these specific variables we will impute by copying the wave 2 values onto wave 1
* This will not affect transitions, as the transition population excludes wave 1
local wav1missvars hchole lnlys drinkd
foreach var in `wav1missvars' {
    gen `var'1 = .
    replace `var'1 = `var'2 if missing(`var'1) & !missing(`var'2)
}

* Reshape data from wide to long
* REMOVED: strat
#d ;
reshape long iwstat cwtresp iwindy iwindm agey walkra dressa batha eata beda 
    toilta mapa phonea moneya medsa shopa mealsa housewka hibpe diabe cancre lunge 
    hearte stroke psyche arthre bmi smokev smoken hhid
    asthmae parkine itearn ipubpen atotf vgactx_e mdactx_e ltactx_e 
    drink drinkd drinkn drinkwn educl mstat hchole hipe shlt atotb itot smokef lnlys alzhe demene
    lbrf
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
label variable asthmae "Asthma ever"
label variable parkine "Parkinsons disease ever"
label variable vgactx_e "Number of times done vigorous exercise per week"
label variable mdactx_e "Number of times done moderate exercise per week"
label variable ltactx_e "Number of times done light exercise per week"
label variable drink "Drinks at all"
label variable drinkd "# Days/week has a drink"
label variable drinkn "# Drinks/day on heaviest drinking day of last week"
label variable drinkwn "# Drinks in last week"
label variable educl "Spouse Harmonised Education Level"
label variable ramomeduage "Age mother left education"
label variable radadeduage "Age father left education"
label variable mstat "Marriage Status"
label variable hchole "High Cholesterol Ever"
label variable hipe "Hip Fracture Ever"
label variable shlt "Self Reported Health Status"
label variable alzhe "Alzheimers Ever"
label variable demene "Dementia Ever"
label variable itot "Total Family Income"
label variable atotb "Total Family Wealth"
label variable lbrf "Labour Force Status"
*label variable nssec "National Statistics Socio-Economic Classification"


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
drop ragender

* Label white
gen white = (raracem == 1) if !missing(raracem)
label var white "White"
drop raracem

* Find if dead with iwstat var
gen died = (iwstat == 5) if !missing(iwstat)
* Keep only those alive or recently deceased
/* Dropping the 0 (inap.? Unknown code) 6 (previously deceased), 7 (dropped from sample) 
and 9 (non-response, unkown if dead or alive) */
keep if inlist(iwstat,1,4,5)

* Generate partnership status vars, then drop mstat
* mstat values: 1 - Married
*               3 - Partnered
*               4 - Separated
*               5 - Divorced
*               7 - Widowed
*               8 - Never Married
replace mstat = 2 if inlist(mstat, 4,5,8)
replace mstat = 4 if mstat == 7
label define mstat 1 "Married" 2 "Single" 3 "Cohabiting" 4 "Widowed"
label values mstat mstat

gen married = mstat == 1
gen single = mstat == 2
gen cohab = mstat == 3
gen widowed = mstat == 4
label variable married "Married"
label variable single "Single"
label variable cohab "Cohabiting"
label variable widowed "Widowed"


* FEM uses hhidpn as the person ID, so can drop idauniq
gen hhidpn = idauniq
replace hhid = hhidpn

* generate birth year and age variable for naming conventions
gen rbyr = rabyear
gen age = agey
drop agey

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

*** ADL/IADL
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

* Now drop vars if no longer needed
drop adlcount iadlcount
drop walkra dressa batha eata beda toilta
drop mapa phonea moneya medsa shopa mealsa housewka


*** Self Reported Health
* Rename as 'stat' var
rename shlt srh
label define srh 1 "Excellent" 2 "Very Good" 3 "Good" 4 "Fair" 5 "Poor"
label values srh srh

* Create dummys for transition models
gen srh1 = srh == 1 if !missing(srh)
gen srh2 = srh == 2 if !missing(srh)
gen srh3 = srh == 3 if !missing(srh)
gen srh4 = srh == 4 if !missing(srh)
gen srh5 = srh == 5 if !missing(srh)
* Replace missing with 0
replace srh1 = 0 if srh != 1 & !missing(srh)
replace srh2 = 0 if srh != 2 & !missing(srh)
replace srh3 = 0 if srh != 3 & !missing(srh)
replace srh4 = 0 if srh != 4 & !missing(srh)
replace srh5 = 0 if srh != 5 & !missing(srh)
* Label
label variable srh1 "Self Reported Health Status: Excellent"
label variable srh2 "Self Reported Health Status: Very Good"
label variable srh3 "Self Reported Health Status: Good"
label variable srh4 "Self Reported Health Status: Fair"
label variable srh5 "Self Reported Health Status: Poor"

*** Loneliness
* loneliness is brought into our model as a summary score for 4 questions relating to loneliness
* To use this score (which is ordinal, containing non-integers), we are going to round the values and keep them as 3 categories: low, medium and high
* Potentially in the future, we could just keep the high loneliness? Try full var first
gen lnly = round(lnlys, 1)
label variable lnly "Loneliness Score, Low to High [1, 3]"
* Now generate some dummys
gen lnly1 = lnly == 1
gen lnly2 = lnly == 2
gen lnly3 = lnly == 3
* Labels
label variable lnly1 "Loneliness level: low"
label variable lnly2 "Loneliness level: medium"
label variable lnly3 "Loneliness level: high"
* Drop original
drop lnlys

save $outdata/before_bmi_impute.dta, replace

* Handle missing bmi values
bys hhidpn: ipolate bmi wave, gen(bmi_ipolate) epolate
replace bmi = bmi_ipolate if missing(bmi)
drop bmi_ipolate

*** Now add some noise to the BMI interpolation ***
* Decision for rnormal boundaries (-2,2) was based on the RMSE of US bmi regression model
*gen rand = rnormal(0, 1.8) if (wave==1 | wave==3 | wave==5 | wave==7)
*replace bmi = bmi + rand if !missing(rand)
*drop rand

* The interpolation step for BMI produces a couple of completely impossible values. Removing anything under 14, as 14 is the lowest I've seen in ELSA that didn't look like a typo
* Let kludge.do handle it with hotdeck
replace bmi = . if bmi < 14

* Introduce perturbation in logbmi, maybe not symetrical when added to bmi
* Maybe don't perturb at all, see what happens

* log(bmi)
gen logbmi = log(bmi) if !missing(bmi)

*** Now add noise
* Take the exponential of rnormal distribution, then add this
*gen rand = exp(rnormal(0, 0.08)) if (wave==1 | wave==3 | wave==5 | wave==7)
*gen rand = exp(rnormal(-2, 2)) if (wave==1 | wave==3 | wave==5 | wave==7)
*gen rand = exp(rnormal(0, 0.5)) if (wave==1 | wave==3 | wave==5 | wave==7)
*replace logbmi = logbmi + rand if !missing(rand)
*drop rand

* 
gen rand = rnormal(0, 0.05)
replace logbmi = logbmi + rand if !missing(rand)

* Generate dummy for obesity
* This is already generated in generate_transition_pop.do. TODO: change gen_trans_pop.do to replace instead of generate
gen obese = (logbmi > log(30.0)) if !missing(bmi)

* Generate a categorical variable for BMI to get summary stats by group
* cut() has to include both the lower and upper limits (which is why both 0 and 100 are included)
gen bmi2 = exp(logbmi)
egen bmi_cat = cut(bmi2), at(0 25 30 200)

* Handle weird smoking status (smoke now but not smoke ever, nonsensical)
*count if smokev==0 & smoken==1
replace smokev = 1 if smoken==1 & smokev==0

*Categorical smoking variable
gen smkstat = 1 if smokev == 0 & smoken == 0
replace smkstat = 2 if smokev == 1 & smoken == 0
replace smkstat = 3 if smoken == 1
label define smkstat 1 "Never smoked" 2 "Former smoker" 3 "Current smoker"
label values smkstat smkstat

* Second attempt at smoking intensity variable
* Going to do a simple 'heavy smoker' var, for respondents that smoke 10 or more cigarettes/day
gen heavy_smoker = (smokef >= 20) if !missing(smokef)
drop smokef


*** Drinking Intensity (Take 2)
*gen problem_drinker = (drinkwn > 7) if !missing(drinkwn)
*replace problem_drinker = (drinkd > 5) if missing(problem_drinker) | problem_drinker == 0
* Problem drinker == more than 7 drinks/week OR more than 4 drinks/day OR more than 5 days drinking/week
*gen problem_drinker = 1 if (drinkwn > 7) | (drinkn > 4)
gen problem_drinker = 1 if (drinkwn > 12) & !missing(drinkwn)
replace problem_drinker = 1 if (drinkn > 7) & !missing(drinkn)
replace problem_drinker = 0 if (drinkwn <= 12) & !missing(drinkwn)
replace problem_drinker = 0 if (drinkn > 7) & !missing(drinkn)
*replace problem_drinker = 1 if (drinkd == 7)
*replace problem_drinker = 0 if (drinkd < 7)


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

* Drop the exercise vars now
drop ltactx_e mdactx_e vgactx_e
*** Income and Wealth
* These vars need to be converted to logs
gen logitot = log(itot) if !missing(itot)
gen logatotb = log(atotb) if !missing(atotb)
* Now drop non-logged vars
drop atotb itot

*** Labour Force Status
* Recoding the lbrf var to three categories
* 1 - Working (includes self-employed and partly retired)
* 2 - Unemployed
* 3 - Retired (including disabled and caring for home/family)
recode lbrf (1/2 4= 1 Employed) ///
            (3    = 2 Unemployed) ///
            (5/7  = 3 Retired) ///
            , copyrest gen(workstat)
*drop lbrf
gen employed = workstat == 1
gen unemployed = workstat == 2
gen retired = workstat == 3


*** National Statistics Socio-Economic Classification
* Generate dummys
*gen nssec1 = (nssec == 1)
*gen nssec2 = (nssec == 2)
*gen nssec3 = (nssec == 3)
*gen nssec4 = (nssec == 4)
*gen nssec5 = (nssec == 5)
*gen nssec6 = (nssec == 6)
*gen nssec7 = (nssec == 7)
*gen nssec8 = (nssec == 8)

*** Generate alcohol in last week var for validation
gen drink_7d = 1 if (drinkwn > 0) & !missing(drinkwn)
replace drink_7d = 1 if (drinkn > 0) & !missing(drinkn)
replace drink_7d = 1 if (drinkd > 0) & !missing(drinkd)

replace drink_7d = 0 if (drink == 0) & !missing(drink)
replace drink_7d = 0 if (drinkwn == 0) & (drinkn == 0) & (drinkd == 0) & !missing(drinkwn) & !missing(drinkn) & !missing(drinkd)

* Now drop drinking vars we don't use
drop drinkd drinkwn drinkn

*Label vars generated in this script (not read directly from ELSA)
label variable heavy_smoker "Heavy smoker (20+ cigs/day)"


*** Generate lagged variables ***
* xtset tells stata data is panel data (i.e. longitudinal)
xtset hhidpn wave
* Make sure that smokev is an absorbing state
replace smokev = 1 if L.smokev == 1 & smokev == 0
* L.***, L is lag operator; can use L2 for 2 waves prior also
* can use this as xtset tells stata that data is panel data

* REMOVED: adlcount, iadlcount, agey, bmi, smkint, smkint1, smkint2, smkint3
#d ;
foreach var in
    iwstat
	age
    hibpe
    diabe
    cancre
    lunge
    hearte
    stroke
    psyche
    arthre
    logbmi
    smokev
    smoken
    died
    adlstat
    anyadl
    iadlstat
    anyiadl
    smkstat
    asthmae
    parkine
    drink
    exstat
    exstat1
    exstat2
    exstat3
    obese
    mstat
    married
    single
    widowed
    cohab
    hchole
    hipe
    srh
    srh1
    srh2
    srh3
    srh4
    srh5
    heavy_smoker
    lnly
    lnly1
    lnly2
    lnly3
    alzhe
    demene
    logitot
    logatotb
    workstat
    employed
    unemployed
    retired
    problem_drinker
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
* Now replace all special missing codes with simple missing (.) This is because the imputation model will only impute records with simple missing
replace educ = . if missing(educ)

*** Drop Vars That Are Not Necessary ***
drop r*scwtresp
drop r*fagey

*save ../../../input_data/ELSA_long.dta, replace
save $outdata/ELSA_long.dta, replace

capture log close
