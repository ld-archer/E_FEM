

*** DEPENDANT VARIABLES
global bin_hlth cancre diabe hearte hibpe lunge stroke arthre psyche died asthmae parkine drink smoke_start smoke_stop
global bin_econ work hlthlm retemp
global ols logbmi retage ipubpen atotf itearn
global order adlstat iadlstat drinkd drinkd_stat exstat /*vgactx_e mdactx_e ltactx_e smkstat*/

* Variable names
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
global bin_econ_names
    "R working for pay"
    "Health Limits Work"
    "Whether retired at time of interview"
;
global ols_names
    "Log(BMI)"
    "Retirement Age"
    "Public Pension Income (All types)"
    "Net Value of Non-housing Financial Wealth"
    "Individual Employment Earnings (annual, after tax)"
    "Number cigs/day"
;
global order_names 
    "ADL status"
    "IADL status"
    "# days per week R drinks alcohol"
    "Days/week drinking status"
    "Exercise status"
;
#d cr


*** Set up globals for predictor groups ***

*** Demographics
global dvars male white hsless college /*missing_educ NEED TO ADD THIS IN AT SOME POINT SOON*/
*** Lagged Age splines
global lvars_age l2age65l l2age6574 l2age75p


* For age and gender interactions
global lvars_age_sex male_l2age65l male_l2age6574 male_l2age75p

*** Health variables at t-1
global lvars_hlth l2cancre l2diabe l2hearte l2hibpe l2lunge l2stroke l2adl1 l2adl2 l2adl3p l2iadl1 l2iadl2p
*** Econ vars at t-1
global lvars_econ l2work l2retemp l2itearn l2ipubpen l2atotf

*** Custom groups
* Exercise vars
local lvars_exercise l2exstat1 l2exstat2 /*l2exstat3*/
* Smoking
local lvars_smoke l2smokev l2smoken
* Drinking
local lvars_drink l2drink l2drinkd2 l2drinkd3 l2drinkd4


*** Now specify the transition models ***

*** For Mortality
*global allvars_died $dvars $lvars_age $lvars_hlth /*$lvars_econ `lvars_exercise'*/ l2logbmi `lvars_drink'  l2smoken l2smokev
global allvars_died $dvars $lvars_age `lvars_smoke' l2cancre l2diabe l2hibpe l2hearte l2lunge l2stroke l2adl1 l2adl2 l2adl3p /*l2logbmi*/
*global allvars_died male $lvars_age 


*** Chronic Diseases
global allvars_cancre       $dvars $lvars_age l2smoken l2logbmi l2drink
global allvars_diabe        $dvars $lvars_age l2logbmi `lvars_smoke' `lvars_exercise' `lvars_drink' l2hibpe l2psyche /*https://www.diabetes.org.uk/Preventing-Type-2-diabetes/Diabetes-risk-factors*/
global allvars_hearte       $dvars $lvars_age l2logbmi `lvars_smoke' `lvars_exercise' `lvars_drink' l2hibpe l2diabe /*https://www.bhf.org.uk/informationsupport/risk-factors*/
global allvars_hibpe        $dvars $lvars_age l2logbmi `lvars_smoke' `lvars_exercise' `lvars_drink' l2diabe /*https://www.bhf.org.uk/informationsupport/risk-factors/high-blood-pressure*/
global allvars_lunge        $dvars $lvars_age l2logbmi `lvars_smoke' /*https://www.healthline.com/health/understanding-idiopathic-pulmonary-fibrosis/chronic-lung-diseases-causes-and-risk-factors#1*/
global allvars_stroke       $dvars $lvars_age l2logbmi `lvars_smoke' `lvars_drink' l2hearte l2cancre l2hibpe l2diabe

global allvars_arthre       $dvars $lvars_age l2logbmi `lvars_smoke' l2hearte l2stroke l2hibpe l2diabe l2work
global allvars_psyche       $dvars $lvars_age l2logbmi `lvars_smoke' l2hearte l2stroke l2cancre l2hibpe l2diabe l2work
global allvars_asthmae      $dvars $lvars_age l2logbmi `lvars_smoke' `lvars_drink' l2lunge
global allvars_parkine      $dvars $lvars_age l2logbmi `lvars_smoke' `lvars_drink' l2diabe l2stroke


*** Smoking 
* Look at Hymovitz et. al (1997) for justification for some of the vars as smoking predictors (Could also add var for self-reported health measures as paper says its important)
global allvars_smoke_start  $dvars $lvars_age l2work l2retemp l2adl1 l2adl2 l2adl3p l2iadl1 l2iadl2p
global allvars_smoke_stop   $dvars $lvars_age l2work l2retemp l2adl1 l2adl2 l2adl3p l2iadl1 l2iadl2p
* smokef is xsectional so don't use lags of chronic diseases/choices as right hand variables
global allvars_smokef       $dvars $lvars_age logbmi drink drinkd2 drinkd3 drinkd4 atotf itearn adl1 adl2 adl3p iadl1 iadl2p psyche



*** Drinking
global allvars_drink        $dvars $lvars_age l2logbmi `lvars_smoke' l2psyche
global allvars_drinkd_stat  $dvars $lvars_age l2logbmi $lvars_hlth l2psyche l2arthre l2asthmae l2parkine
global allvars_drinkd       $dvars $lvars_age l2logbmi $lvars_hlth l2psyche l2arthre l2asthmae l2parkine


*** Logbmi & other health
global allvars_logbmi       $dvars $lvars_age l2logbmi l2smokev l2smoken `lvars_exercise'
global allvars_hlthlm       $dvars $lvars_age hearte stroke cancre hibpe diabe lunge logbmi adl1 adl2 adl3p iadl1 iadl2p smokev smoken smokef arthre psyche asthmae parkine drink drinkd1 drinkd2 drinkd3 drinkd4


*** Disabilities
global allvars_anyadl       $dvars $lvars_age l2logbmi `lvars_smoke' `lvars_drink' l2hearte l2cancre l2hibpe l2diabe l2psyche l2arthre
global allvars_anyiadl      $dvars $lvars_age l2logbmi `lvars_smoke' `lvars_drink' l2hearte l2cancre l2hibpe l2diabe l2psyche l2arthre
global allvars_adlstat      $dvars $lvars_age l2logbmi `lvars_smoke' $lvars_hlth `lvars_drink' l2psyche l2arthre l2asthmae l2parkine
global allvars_iadlstat     $dvars $lvars_age l2logbmi `lvars_smoke' $lvars_hlth `lvars_drink' l2psyche l2arthre l2asthmae l2parkine


*** Economic
global allvars_work         $dvars $lvars_age l2logbmi $lvars_hlth $lvars_econ `lvars_exercise' l2psyche l2arthre l2parkine
global allvars_retemp       $dvars $lvars_age l2logbmi $lvars_hlth $lvars_econ l2psyche l2arthre l2asthmae l2parkine l2hlthlm 
global allvars_retage       $dvars $lvars_age l2logbmi $lvars_hlth $lvars_econ `lvars_smoke' l2hlthlm l2arthre l2psyche l2asthmae l2parkine
global allvars_ipubpen      $dvars $lvars_age l2logbmi $lvars_hlth $lvars_econ `lvars_smoke' l2hlthlm l2arthre l2psyche l2asthmae l2parkine
global allvars_atotf        $dvars $lvars_age l2logbmi $lvars_hlth $lvars_econ `lvars_smoke' l2hlthlm l2arthre l2psyche l2asthmae l2parkine
global allvars_itearn       $dvars $lvars_age l2logbmi $lvars_hlth $lvars_econ `lvars_drink' `lvars_smoke' l2hlthlm l2arthre l2psyche l2asthmae l2parkine


*** Exercise
global allvars_exstat       $dvars $lvars_age l2logbmi l2psyche l2arthre l2asthmae /*$lvars_hlth `lvars_smoke'*/
