clear
set maxvar 15000
log using reshape_long.log, replace

quietly include ../../../fem_env.do

local in_file : env INPUT
local out_file : env OUTPUT
local scr : env SCENARIO


*use ../../../input_data/H_ELSA_f_2002-2016.dta, clear
*use $outdata/H_ELSA_f_2002-2016.dta, clear
use $outdata/H_ELSA_g2_wv_specific.dta, clear

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

/*
Variables from Wave Specific ELSA files:

Risk Behaviours:

Demographics:
- GOR: Government Office Region (one of 8? possible regions in UK)

*/

* Dropping the longitudinal sample weight
drop r*lwtresp

* Keep these variables from the harmonized ELSA
* REMOVED: r*strat, r*clust, raeduc_e
#d ;
keep idauniq
h*coupid
r*iwstat
inw*
inw*sc
inw*n
inw3lh
r*cwtresp
r*strat
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
r*mbmi 
r*smokev
r*smoken
r*asthmae
r*parkine
r*vgactx_e
r*mdactx_e
r*ltactx_e
r*drink
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
r*mheight
r*mweight
c*cpindex
r*GOR
r*angine
r*hrtatte
r*conhrtfe
r*hrtmre
r*hrtrhme
r*catracte
r*osteoe
r*complac
r*leftout
r*isolate
r*lnlys3
r*scako
r*kcntm
r*rcntm
r*fcntm
r*socyr
r*jphysl
h*hhres
r*gcareinhh1w
r*child
r*cesd
r*sight
r*hearing
h*ahown
r*tr20
r*verbf
r*orient
;
#d cr

* Rename household vars to a more useful form
forvalues wv = $firstwave/$lastwave {
    *rename h`wv'coupid r`wv'hhid // No longer want to drop the coupid var, just use it to generate hhid
    generate r`wv'hhid = h`wv'coupid
    rename h`wv'coupid r`wv'coupid // Still rename to r`var' for the rename and reshape below (r is removed anyway)

    rename h`wv'atotb r`wv'atotb
    rename h`wv'itot r`wv'itot

    rename h`wv'hhres r`wv'hhres
    rename h`wv'ahown r`wv'ahown
}

* Also rename exercise variables in the near future
forvalues wv = $firstwave/$lastwave {
    /*Remove '_e' from labour force status var (don't know why they link inlcuding these)*/
    rename r`wv'lbrf_e r`wv'lbrf
}

* Rename variables to make reshape easier and have names consistent with US FEM
* Respondent?
#d ;
foreach var in 
    iwstat
    cwtresp
    strat
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
    mbmi
    smokev
    smoken
    hhid
    asthmae
    parkine
    vgactx_e
    mdactx_e
    ltactx_e
    drink
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
    mheight
    mweight
    coupid
    GOR
    angine
    hrtatte
    conhrtfe
    hrtmre
    hrtrhme
    catracte
    osteoe
    complac
    leftout
    isolate
    lnlys3
    scako
    kcntm
    rcntm
    fcntm
    socyr
    jphysl
    hhres
    socyr
    gcareinhh1w
    child
    cesd
    sight
    hearing
    ahown
    tr20
    verbf
    orient
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

* Separate again for renaming response indicator vars
forvalues wv = $firstwave/$lastwave {
    rename inw`wv'sc insc`wv'

    * Nurse visit only happened on waves 2,4,6,8 (technically 9 too but no in this var)
    if inlist(`wv', 2, 4, 6, 8) {
        rename inw`wv'n inn`wv'
    }
    
}

* Calculate an mbmi value for wave 9 using wave 8 height and wave 9 weight then drop height and weight
generate mbmi9 = mweight9 / mheight8^2
drop mheight* mweight*

*** Impute missing wave 1 for minimal ***
* Any variable missing wave 1 causes trouble for the minimal population, as it is derived from people in wave 1
* Therefore, for only these specific variables we will impute by copying the wave 2 values onto wave 1
* This will not affect transitions, as the transition population excludes wave 1
local wav1missvars hchole lnlys complac leftout isolate lnlys3 scako
foreach var in `wav1missvars' {
    gen `var'1 = .
    replace `var'1 = `var'2 if missing(`var'1) & !missing(`var'2)
}

* Reshape data from wide to long
#d ;
reshape long iwstat cwtresp strat iwindy iwindm agey walkra dressa batha eata beda 
    toilta mapa phonea moneya medsa shopa mealsa housewka hibpe diabe cancre lunge 
    hearte stroke psyche arthre mbmi smokev smoken hhid inw insc inn
    asthmae parkine itearn ipubpen atotf vgactx_e mdactx_e ltactx_e 
    drink educl mstat hchole hipe shlt atotb itot smokef lnlys alzhe demene
    lbrf coupid GOR angine hrtatte conhrtfe hrtmre hrtrhme catracte osteoe
    complac leftout isolate lnlys3 scako kcntm rcntm fcntm socyr jphysl hhres 
    gcareinhh1w child cesd sight hearing ahown tr20 verbf orient
, i(idauniq) j(wave)
;
#d cr

* Changed bmi to mbmi in Harmonized ELSA G.2 release, rename back
rename mbmi bmi


label variable strat "ELSA Stratification Variable"
label variable iwindy "Interview Year"
label variable iwindm "Interview Month"
label variable inw "Response indicator"
label variable insc "Response Indicator: Self-completion"
label variable inn "Response Indicator: Nurse sample"
label variable inw3lh "Response Indicator: W3 Life History"
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
label variable GOR "Government Office Region"
label variable angine "Angina ever"
label variable hrtatte "Heart Attack ever"
label variable conhrtfe "Congestive Heart Failure ever"
label variable hrtmre "Heart Murmur ever"
label variable hrtrhme "Abnormal Heart Rhythm"
label variable catracte "Cataracts ever"
label variable osteoe "Osteoporosis ever"
label variable complac "How often feels lack of companionship"
label variable leftout "How often feels left out"
label variable isolate "How often feels isolated from others"
label variable lnlys3 "Mean revised UCLA loneliness score, continuous"
label variable scako "Frequency of Alcohol consumption in past 12 months"
label variable kcntm "Monthly or more contact with children"
label variable rcntm "Monthly or more contact with relatives"
label variable fcntm "Monthly or more contact with friends"
label variable socyr "Whether participates in social activities (org, religious group, committee)"
label variable jphysl "Level of physical effort required in current job"
label variable hhres "Number of people in household"
label variable socyr "Whether participates in social activities"
label variable gcareinhh1w "Cared for someone in household in past week"
label variable child "Number of children"
label variable cesd "Center for Epidemiologic Studies Depression Scale (CESD)"
label variable sight "Self-rated eyesight"
label variable hearing "Self-rated hearing"
label variable ahown "Whether owns home"
label variable tr20 "Word recall summary score"
label variable verbf "Verbal fluency score"
label variable orient "Cognition Orient (summary date naming)"


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
* loneliness is brought into our model as a summary score for 3 questions relating to loneliness
* To use this score (which is ordinal, containing non-integers), we are going to round the values and keep them as 3 categories: low, medium and high
* Potentially in the future, we could just keep the high loneliness? Try full var first
gen lnly = round(lnlys3, 1)
label variable lnly "Loneliness Score, Low to High [1, 3]"
* Now generate some dummys
gen lnly1 = lnly == 1
gen lnly2 = lnly == 2
gen lnly3 = lnly == 3
* Labels
label variable lnly1 "Loneliness level: low"
label variable lnly2 "Loneliness level: medium"
label variable lnly3 "Loneliness level: high"
* Drop 3 level summary score
*drop lnlys3


****** ALCOHOL ******
** Moving from the previous consumptiong based alcohol vars in the FEM (alcbase/alcstat) to a frequency based version (scako)
* First rename to something more useful (like alcfreq)
ren scako alcfreq
* Now define labels for each of the levels
label define alcfreq 1 "Almost every day" 2 "five or six days a week" 3 "three or four days a week" 4 "once or twice a week" 5 "once or twice a month" 6 "once every couple of months" 7 "once or twice a year" 8 "not at all in the last 12 months"
label values alcfreq alcfreq
* handle missings
replace alcfreq = . if alcfreq < 0
* TODO: Move these dummy definitions to generate_transition_pop.do
* Create dummys for prediction and label
gen alcfreq1 = alcfreq == 1
gen alcfreq2 = alcfreq == 2
gen alcfreq3 = alcfreq == 3
gen alcfreq4 = alcfreq == 4
gen alcfreq5 = alcfreq == 5
gen alcfreq6 = alcfreq == 6
gen alcfreq7 = alcfreq == 7
gen alcfreq8 = alcfreq == 8
label variable alcfreq1 "Alcohol consumption: Almost every day"
label variable alcfreq2 "Alcohol consumption: five or six days a week"
label variable alcfreq3 "Alcohol consumption: three or four days a week"
label variable alcfreq4 "Alcohol consumption: once or twice a week"
label variable alcfreq5 "Alcohol consumption: once or twice a month"
label variable alcfreq6 "Alcohol consumption: once every couple of months"
label variable alcfreq7 "Alcohol consumption: once or twice a year"
label variable alcfreq8 "Alcohol consumption: not at all in the last 12 months"


****** BMI & OBESITY ******
* Handle missing bmi values
bys hhidpn: ipolate bmi wave, gen(bmi_ipolate) epolate
replace bmi = bmi_ipolate if missing(bmi)
drop bmi_ipolate

* The interpolation step for BMI produces a couple of completely impossible values. Removing anything under 14, as 14 is the lowest I've seen in ELSA that didn't look like a typo
* Let kludge.do handle it with hotdeck
replace bmi = . if bmi < 14

* log(bmi)
gen logbmi = log(bmi) if !missing(bmi)

* 
gen rand = rnormal(0, 0.05)
replace logbmi = logbmi + rand if !missing(rand)

* Generate dummy for obesity
* This is already generated in generate_transition_pop.do. TODO: change gen_trans_pop.do to replace instead of generate
gen overwt = (logbmi >= log(25.0)) & (logbmi > log(30)) & !missing(logbmi)
gen obese1 = (logbmi >= log(30.0)) & (logbmi < 35) if !missing(bmi)
gen obese2 = (logbmi >= log(35.0)) & (logbmi < 40) if !missing(bmi)
gen obese3 = (logbmi >= log(40.0)) if !missing(bmi)

* Generate a categorical variable for BMI to get summary stats by group
* cut() has to include both the lower and upper limits (which is why both 0 and 100 are included)
gen bmi2 = exp(logbmi)
egen bmi_cat = cut(bmi2), at(0 25 30 200)

****** SMOKING ******

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
*gen heavy_smoker = (smokef >= 20) if !missing(smokef)

****** EXERCISE ******

** 23/02/23 Changing this variable to a binary variable defined in:
* Shankar et al. (2011) - https://psycnet.apa.org/record/2011-08649-001

* Active - Moderate or vigorous physical activity more than once per week OR if employed, occupation is any of standing, physical work, or heavy manual work
* Not Active - Moderate or vigorous physical activity only once a week or less AND if employed, occupation is reported as primarily sedentary

gen physact = .
* First check activity level then job
* (Moderate &| Vigorous) &| (Occupation physical activity level)
replace physact = 1 if (mdactx_e == 2 | vgactx_e == 2) | (inlist(jphysl, 2, 3, 4)) 
replace physact = 0 if (mdactx_e != 2 & vgactx_e != 2) & (jphysl == 1)
replace physact = 1 if inlist(jphysl, 2, 3, 4) & !missing(jphysl)
replace physact = 0 if jphysl == 1

* Generate an exercise status variable to hold exercise info in single var
* Three levels:
*   1 - No exercise
*   2 - Light exercise 1+ times per week
*   3 - Moderate/Vigorous exercise 1+ times per week
* Third try now
*gen exstat = .
*replace exstat = 1 if (ltactx_e == 4 | ltactx_e == 5) & (mdactx_e == 4 | mdactx_e == 5) & (vgactx_e == 4 | vgactx_e == 5)
*replace exstat = 2 if (ltactx_e == 2 | ltactx_e == 3) & (mdactx_e == 4 | mdactx_e == 5) & (vgactx_e == 4 | vgactx_e == 5)
*replace exstat = 3 if (mdactx_e == 2 | mdactx_e == 3) | (vgactx_e == 2 | vgactx_e == 3)

* Now dummy categorical vars for including in transition models
*gen exstat1 = 1 if exstat == 1
*replace exstat1 = 0 if exstat != 1
*gen exstat2 = 1 if exstat == 2
*replace exstat2 = 0 if exstat != 2
*gen exstat3 = 1 if exstat == 3
*replace exstat3 = 0 if exstat != 3

* Drop the exercise vars now
*drop ltactx_e mdactx_e vgactx_e

****** INCOME AND WEALTH ******

** Replace top-coded values of itot with 900000 (see p599 harmonised codebook)
replace itot = 900000 if itot == .t

** Rebase cpindex var from 2010 to 2012 (start year of simulation)
* Formula for this: updatedValue = oldValue / newBaseBalue(2012) * 100
* Example of this given here: https://mba-lectures.com/statistics/descriptive-statistics/508/shifting-of-base-year.html
forvalues n = 2001/2019 {
    gen newc`n'cpindex = (c`n'cpindex / c2012cpindex) * 100 // generate new index with 2012 base year
    drop c`n'cpindex // drop original cpindex
    ren newc`n'cpindex c`n'cpindex // rename new base to match old varnames
}

** Now modify all financial vars for inflation using the rebased CPI
* Adjusted value = (oldValue / cpindex) * 100
* https://timeseriesreasoning.com/contents/inflation-adjustment/
* Problem here with negative values, need to do this with absolute values then flip the sign back
* First take absolute values
gen newatotb = abs(atotb)
gen newitot = abs(itot)
* Generate flag if financial values are negative
gen negatotb = 1 if atotb < 0
gen negitot = 1 if itot < 0
* Loop through values so we only change values from specific years
forvalues n = 2001/2019 {
    replace newatotb = (newatotb / c`n'cpindex ) * 100 if iwindy == `n' // Generate updated atotb values based on interview year
    replace newitot = (newitot / c`n'cpindex ) * 100 if iwindy == `n' // Same for itot
}
* Do some hacky thing to turn the value negative if the flag == 1
replace newatotb = newatotb - (newatotb * 2) if negatotb == 1
replace newitot = newitot - (newitot * 2) if newitot == 1

* Finally replace the original financial vars and drop the intermediate things plus the CPI
replace atotb = newatotb
replace itot = newitot
drop newatotb newitot negatotb negitot
forvalues n = 2001/2019 {
    drop c`n'cpindex
}

** Now adjust couple level (benefit unit level) data into individual values
* To do this, multiply those in a couple by sqrt(2)
bysort coupid wave: gen atotb_adjusted = atotb / sqrt(2) if _N == 2
bysort coupid wave: gen itot_adjusted = itot / sqrt(2) if _N == 2

* Now replace original value with values adjusted for benefit unit level
replace atotb = atotb_adjusted if !missing(atotb_adjusted)
replace itot = itot_adjusted if !missing(itot_adjusted)
* Finally drop the adjusted vars
drop atotb_adjusted itot_adjusted

* Lets create log versions of these variables too
gen logatotb = log(atotb)
gen logitot = log(itot)

* FINAL finally, calculate wealth quintiles for prediction of other things (incorporate sampling weight cwtresp)
xtile wealth_quintile = atotb[aw=cwtresp], n(5)

****** LABOUR FORCE STATUS ******

* Recoding the lbrf var to three categories
* 1 - Working (includes self-employed and partly retired)
* 2 - Inactive
* 3 - Retired (including disabled and caring for home/family)
recode lbrf (1/2   = 1 "Employed") ///
            (3 6/7 = 2 "Inactive") ///
            (4/5   = 3 "Retired") ///
            , copyrest gen(workstat)
drop lbrf
gen employed = workstat == 1
gen inactive = workstat == 2
gen retired = workstat == 3

****** INDEX OF SOCIAL ISOLATION ******

* Generate an index of social isolation as in this study by Shankar et al. (2011) - https://pubmed.ncbi.nlm.nih.gov/21534675/
* Index ranges from 1-6, with a score of +1 for the following 5 things
* - Not married/cohabiting with a partner
* - Had less than monthly contact (including face-to-face, telephone, or written/email contact) with (+1 each):
*     - children 
*     - other immediate family 
*     - friends
* - Did not participate in any organisations, religious groups, or committees that meet at least once a year
* 1-6 chosen instead of 0-5 because FEM doesn't like 0 values in ordinal variables for some reason
gen sociso = 1
replace sociso = sociso + 1 if married != 1 & cohab != 1 & !missing(mstat) /*Not Married or cohabiting*/
replace sociso = sociso + 1 if kcntm == 0 & !missing(kcntm) /*Kids contact less than monthly*/
replace sociso = sociso + 1 if rcntm == 0 & !missing(rcntm) /*Relatives contact less than monthly*/
replace sociso = sociso + 1 if fcntm == 0 & !missing(fcntm) /*friends contact less than monthly*/
replace sociso = sociso + 1 if socyr == 0 & !missing(socyr) /*not member of religious group, committee, or other organisation*/
replace sociso = . if missing(mstat) & missing(kcntm) & missing(rcntm) & missing(fcntm) & missing(socyr)
* Now count number of missing to understand data a bit better
gen sociso_mflag = 0
replace sociso_mflag = sociso_mflag + 1 if missing(mstat)
replace sociso_mflag = sociso_mflag + 1 if missing(kcntm)
replace sociso_mflag = sociso_mflag + 1 if missing(rcntm)
replace sociso_mflag = sociso_mflag + 1 if missing(fcntm)
replace sociso_mflag = sociso_mflag + 1 if missing(socyr)

* drop elements of index
*drop kcntm rcntm fcntm socyr
* Dummy vars
gen sociso1 = (sociso == 1) & !missing(sociso)
gen sociso2 = (sociso == 2) & !missing(sociso)
gen sociso3 = (sociso == 3) & !missing(sociso)
gen sociso4 = (sociso == 4) & !missing(sociso)
gen sociso5 = (sociso == 5) & !missing(sociso)
gen sociso6 = (sociso == 6) & !missing(sociso)

****** CHILDLESS ******

gen childless = child > 0


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
    smokef
    died
    adlstat
    anyadl
    iadlstat
    anyiadl
    smkstat
    asthmae
    parkine
    drink
    physact
    overwt
    obese1
    obese2
    obese3
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
    lnly
    lnly1
    lnly2
    lnly3
    lnlys3
    complac
    leftout
    isolate
    alzhe
    demene
    itot
    atotb
    logatotb
    logitot
    workstat
    employed
    inactive
    retired
    GOR
    angine
    hrtatte
    conhrtfe
    hrtmre
    hrtrhme
    catracte
    osteoe
    alcfreq
    alcfreq1
    alcfreq2
    alcfreq3
    alcfreq4
    alcfreq5
    alcfreq6
    alcfreq7
    alcfreq8
    sociso
    sociso1
    sociso2
    sociso3
    sociso4
    sociso5
    sociso6
    hhres
    socyr
    gcareinhh1w
    wealth_quintile
    cesd
    sight
    hearing
    ahown
    tr20
    verbf
    orient
    {;
        gen l2`var' = L.`var';
    };
;
#d cr

*TODO: Remove the dummy vars from this list (alcfreq, sociso, lnly) & define them in the transition population instead (generate_transition_pop.do)

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

replace lnly = . if missing(lnly)
replace sociso = . if missing(sociso)

*** Drop Vars That Are Not Necessary ***
drop r*scwtresp
drop r*fagey


*** DROP VARS CURRENTLY NOT IN USE ***
* These variables are not in use at the minute, and all they do is pollute the std::out and logs so I'm going to remove them for now
*drop r*idauniq
*drop r*GOR
*drop r*inw
*drop r*insc
*drop r*inw3lh
*drop r*strat
*drop r*radyear
*drop r*lbrf
*drop r*complac
*drop r*leftout
*drop r*isolate

*save ../../../input_data/ELSA_long.dta, replace
save $outdata/ELSA_long.dta, replace

capture log close
