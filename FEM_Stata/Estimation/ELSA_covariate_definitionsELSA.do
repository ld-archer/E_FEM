

*** DEPENDANT VARIABLES
global bin_hlth cancre diabe hearte hibpe lunge stroke arthre psyche died asthmae parkine drink smoke_start smoke_stop
#d ;
global bin_hlth_names
    "Cancer"
    "Diabetes"
    "Heart Disease"
    "Hypertension"
    "Lung Disease"
    "Stroke"
    "Arthritis"
    "Pyschological Problems"
    "Died"
    "Asthma"
    "Parkinsons Disease"
    "Drinks Alcohol"
    "Started Smoking"
    "Stopped Smoking"
;

#d cr
global bin_econ work hlthlm retemp
#d ;
global bin_econ_names
    "R working for pay"
    "Health Limits Work"
    "Whether retired at time of interview"
;

#d cr
global ols logbmi retage ipubpen atotf itearn smokef
#d ;
global ols_names
    "Log(BMI)"
    "Retirement Age"
    "Public Pension Income (All types)"
    "Net Value of Non-housing Financial Wealth"
    "Individual Employment Earnings (annual, after tax)"
    "Average # cigs/day"
;

#d cr
global order adlstat iadlstat drinkd drinkd_stat vgactx_e mdactx_e ltactx_e smkstat
#d ;
global order_names 
    "ADL status"
    "IADL status"
    "# days per week R drinks alcohol"
    "Days/week drinking status"
    "# days/week doing vigorous exercise"
    "# days/week doing moderate exercise"
    "# days/week doing light exercise"
    "Smoking status"
;
#d cr


*** Set up globals for predictor groups ***

*** Demographics
global dvars male white hsless college
*** Lagged Age splines
global lvars_age l2age65l l2age6574 l2age75p

*** Health variables at t-1
global lvars_hlth l2cancre l2diabe l2hearte l2hibpe l2lunge l2stroke l2adl1 l2adl2 l2adl3p l2iadl1 l2iadl2p
*** Econ vars at t-1
global lvars_econ l2work l2retemp l2itearn l2ipubpen l2atotf

*** BMI variable at t-1
global bmivars l2logbmi

*** For Chronic Conditions and Ordinal Outcomes
global allvars_hlth $dvars $lvars_age $lvars_hlth $bmivars

*** For Economic Outcomes
global allvars_econ $dvars $lvars_age $lvars_hlth $lvars_econ

* Single year of age
local age_var agey

*** Custom groups
* Exercise vars
local lvars_exercise l2ltactx_e l2mdactx_e l2vgactx_e
* Smoking
local lvars_smoke smokev l2smoken l2smokef
* Drinking
local lvars_drink l2drink l2drinkd1 l2drinkd2 l2drinkd3 l2drinkd4


*** Now specify the transition models ***

*** For Mortality
global allvars_died $dvars $lvars_age $lvars_hlth $bmivars $lvars_smoke $lvars_drink


*** Chronic Diseases
global allvars_cancre       $dvars $lvars_age $bmivars $lvars_smoke $lvars_drink
global allvars_diabe        $dvars $lvars_age $bmivars $lvars_smoke $lvars_exercise $lvars_drink l2hibpe l2psyche /*https://www.diabetes.org.uk/Preventing-Type-2-diabetes/Diabetes-risk-factors*/
global allvars_hearte       $dvars $lvars_age $bmivars $lvars_smoke $lvars_exercise $lvars_drink l2hibpe l2diabe /*https://www.bhf.org.uk/informationsupport/risk-factors*/
global allvars_hibpe        $dvars $lvars_age $bmivars $lvars_smoke $lvars_exercise $lvars_drink l2diabe /*https://www.bhf.org.uk/informationsupport/risk-factors/high-blood-pressure*/
global allvars_lunge        $dvars $lvars_age $bmivars $lvars_smoke /*https://www.healthline.com/health/understanding-idiopathic-pulmonary-fibrosis/chronic-lung-diseases-causes-and-risk-factors#1*/
global allvars_stroke       $dvars $lvars_age $bmivars $lvars_smoke $lvars_drink l2hearte l2cancre l2hibpe l2diabe

global allvars_arthre       $dvars $lvars_age $bmivars $lvars_smoke l2hearte l2stroke l2cancre l2hibpe l2diabe l2work
global allvars_psyche       $dvars $lvars_age $bmivars $lvars_smoke $lvars_drink l2hearte l2stroke l2cancre l2hibpe l2diabe l2work
global allvars_asthmae      $dvars $lvars_age $bmivars $lvars_smoke l2lunge
global allvars_parkine      $dvars $lvars_age $bmivars $lvars_smoke $lvars_drink l2diabe l2stroke


*** Smoking 
* Look at Hymovitz et. al (1997) for justification for some of the vars as smoking predictors (Could also add var for self-reported health measures as paper says its important)
global allvars_smoke_start  $dvars $lvars_age $bmivars $lvars_drink $lvars_hlth $lvars_econ l2psyche l2arthre l2asthmae
global allvars_smoke_stop   $dvars $lvars_age $bmivars $lvars_drink $lvars_hlth $lvars_econ l2psyche l2arthre l2asthmae
*global allvars_smoken       $dvars $lvars_age $bmivars $lvars_drink $lvars_hlth l2atotf l2itearn l2psyche l2arthre l2asthmae
*global allvars_smokev       $dvars $lvars_age $bmivars $lvars_drink $lvars_hlth l2atotf l2itearn l2psyche l2arthre l2asthmae
* smokef is xsectional so don't use lags of chronic diseases/choices as right hand variables
global allvars_smokef       $dvars $lvars_age logbmi drink drinkd1 drinkd2 drinkd3 drinkd4 atotf itearn cancre diabe hearte hibpe lunge stroke adl1 adl2 adl3p iadl1 iadl2p psyche arthre asthmae
global allvars_smkstat      $dvars $lvars_age $bmivars $lvars_drink $lvars_hlth $lvars_econ l2psyche l2arthre l2asthmae


*** Drinking
global allvars_drink        $dvars $lvars_age $bmivars $lvars_smoke $lvars_hlth l2psyche l2arthre l2asthmae l2parkine
global allvars_drinkd_stat  $dvars $lvars_age $bmivars $lvars_hlth l2psyche l2arthre l2asthmae l2parkine
global allvars_drinkd       $dvars $lvars_age $bmivars $lvars_hlth l2psyche l2arthre l2asthmae l2parkine
*global allvars_drinkwn      $dvars $lvars_age $bmivars $lvars_hlth l2psyche l2arthre l2asthmae l2parkine l2drinkd1 l2drinkd2 l2drinkd3 l2drinkd4


*** Logbmi & other health
global allvars_logbmi       $dvars $lvars_age $bmivars $lvars_hlth $lvars_drink l2smoken l2psyche l2arthre l2asthmae l2parkine
global allvars_hlthlm       $dvars $lvars_age hearte stroke cancre hibpe diabe lunge logbmi adl1 adl2 adl3p iadl1 iadl2p smokev smoken smokef arthre psyche asthmae parkine drink drinkd1 drinkd2 drinkd3 drinkd4


*** Disabilities
global allvars_anyadl       $dvars $lvars_age $bmivars $lvars_smoke $lvars_drink l2hearte l2cancre l2hibpe l2diabe l2psyche l2arthre
global allvars_anyiadl      $dvars $lvars_age $bmivars $lvars_smoke $lvars_drink l2hearte l2cancre l2hibpe l2diabe l2psyche l2arthre
global allvars_adlstat      $dvars $lvars_age $bmivars $lvars_smoke $lvars_hlth $lvars_drink l2psyche l2arthre l2asthmae l2parkine
global allvars_iadlstat     $dvars $lvars_age $bmivars $lvars_smoke $lvars_hlth $lvars_drink l2psyche l2arthre l2asthmae l2parkine


*** Economic
global allvars_work         $dvars $lvars_age $bmivars $lvars_hlth $lvars_econ l2psyche l2arthre l2parkine
global allvars_retemp       $dvars $lvars_age $bmivars $lvars_hlth $lvars_econ l2psyche l2arthre l2asthmae l2parkine l2hlthlm 
global allvars_retage       $dvars $lvars_age $bmivars $lvars_hlth $lvars_econ $lvars_smoke l2hlthlm l2arthre l2psyche l2asthmae l2parkine
global allvars_ipubpen      $dvars $lvars_age $bmivars $lvars_hlth $lvars_econ $lvars_smoke l2hlthlm l2arthre l2psyche l2asthmae l2parkine
global allvars_atotf        $dvars $lvars_age $bmivars $lvars_hlth $lvars_econ $lvars_smoke l2hlthlm l2arthre l2psyche l2asthmae l2parkine
global allvars_itearn       $dvars $lvars_age $bmivars $lvars_hlth $lvars_econ $lvars_drink $lvars_smoke l2hlthlm l2arthre l2psyche l2asthmae l2parkine


*** Exercise
global allvars_vgactx_e     $dvars $lvars_age $bmivars $lvars_hlth $lvars_smoke l2psyche l2arthre l2asthmae l2parkine
global allvars_mdactx_e     $dvars $lvars_age $bmivars $lvars_hlth $lvars_smoke l2psyche l2arthre l2asthmae l2parkine
global allvars_ltactx_e     $dvars $lvars_age $bmivars $lvars_hlth $lvars_smoke l2psyche l2arthre l2asthmae l2parkine


*** Sample Selection Macros
* Selection criteria for models that only rely on not being dead
foreach v in adlstat iadlstat smkstat work retemp itearn atotf drink vgactx_e mdactx_e ltactx_e smoken smokev {
    local select_`v' !died
}

* Selection criteria for models that only rely on lag value and not being dead
foreach v in cancre diabe hearte hibpe lunge stroke arthre psyche asthmae parkine anyadl anyiadl {
    local select_`v' !l2`v' & !died
}

local select_died !l2died

* Selection criteria for models with specific requirements
local select_smoke_start !died & l2smoken == 0
local select_smoke_stop !died & l2smoken == 1
local select_smokef !died & smoken==1
local select_hlthlm !died & wave > 1
local select_ipubpen !died & work == 0
local select_retage !died & retemp == 1
local select_drinkd !died & drink == 1 & wave > 1
local select_drinkd_stat !died & drink == 1 & wave > 1
*local select_drinkwn !died & drink == 1 & wave > 3 /* Estimate model if not dead, is a drinker and wave 4 or higher */
local select_logbmi !died & (wave==2 | wave==4 | wave==6 | wave==8) /* Only estimate bmi model using waves 2,4,6 as other waves are imputed */
