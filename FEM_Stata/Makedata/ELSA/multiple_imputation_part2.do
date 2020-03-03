* Need to extract only the final imputation from the dataset
* Then check the distributions to see if they are similar to original

clear

quietly include ../../../fem_env.do

use ../../../input_data/ELSA_long_imputed1.dta, clear
use $outdata/ELSA_long_imputed1.dta, clear


* log(bmi)
gen logbmi = log(bmi) if !missing(bmi)

* Handle weird smoking status (smoke now but not smoke ever, nonsensical)
count if smokev==0 & smoken==1
replace smokev = 1 if smoken==1 & smokev==0

*Categorical smoking variable
gen smkstat = 1 if smokev == 0 & smoken == 0
replace smkstat = 2 if smokev == 1 & smoken == 0
replace smkstat = 3 if smoken == 1
label define smkstat 1 "Never smoked" 2 "Former smoker" 3 "Current smoker"
label values smkstat smkstat

* Create categorical drinking variable (for days of week - drinkd) (using adlstat as template)
recode drinkd (0=1) (1/2 = 2) (3/4 = 3) (5/7 = 4), gen(drinkd_stat)
label define drinkd_stat 1 "Teetotal" 2 "Light drinker" 3 "Moderate drinker" 4 "Heavy drinker"
label values drinkd_stat drinkd_stat

gen drinkd1 = drinkd_stat==1 if !missing(drinkd_stat)
gen drinkd2 = drinkd_stat==2 if !missing(drinkd_stat)
gen drinkd3 = drinkd_stat==3 if !missing(drinkd_stat)
gen drinkd4 = drinkd_stat==4 if !missing(drinkd_stat)

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
    drinkwn_e
    {;
        gen l2`var' = L.`var';
    };
;
#d cr

* Handle l2age problems
gen l2age = l2agey

*** Imputation Section ***
* Be aware of what this section is doing, particularly for missing cases!
* We want to assess how many people are missing and being assigned mean value on
* lines 289-293

* Set lag to current if missing for logbmi (~20,000 missing - investigate this)
replace l2logbmi = logbmi if missing(l2logbmi) & !missing(logbmi)

* Create any_adl and any_iadl
gen any_adl = 1 if adlcount > 0
replace any_adl = 0 if adlcount == 0
gen any_iadl = 1 if iadlcount > 0
replace any_iadl = 0 if iadlcount == 0

* Handle missing smkstat data
replace smkstat = l2smkstat if missing(smkstat)
replace l2smkstat = smkstat if missing(l2smkstat)

gen smoke_start = 1 if l2smoken == 0 & smoken == 1
replace smoke_start = 0 if l2smoken == 0 & smoken == 0
gen smoke_stop = 1 if l2smoken == 1 & smoken == 0
replace smoke_stop = 0 if l2smoken == 1 & smoken == 1


* For education, can safely replace missing lag with current as does not change
replace l2educ = educ if missing(l2educ)
* Create separate variables for hsless (less than secondary school) and college (university)
gen hsless = (educ == 1)
gen college = (educ == 3)

* Now impute lag of educ and drink vars
replace l2educ = educ if missing(l2educ) & !missing(educ)
replace l2drinkd = drinkd if missing(l2drinkd) & !missing(drinkd)

* Handle missing drinkd_stat data
replace drinkd_stat = l2drinkd_stat if missing(drinkd_stat)
replace l2drinkd_stat = drinkd_stat if missing(l2drinkd_stat)

* Now handle missing drinkd# data
replace drinkd1 = drinkd_stat==1 if missing(drinkd1)
replace drinkd2 = drinkd_stat==2 if missing(drinkd2)
replace drinkd3 = drinkd_stat==3 if missing(drinkd3)
replace drinkd4 = drinkd_stat==4 if missing(drinkd4)

*save ../../../input_data/ELSA_long.dta, replace
save $outdata/ELSA_long.dta, replace

capture log close
