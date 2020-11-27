

*** DEPENDANT VARIABLES
global bin_hlth cancre diabe hearte hibpe lunge stroke arthre psyche died asthmae parkine drink smoke_start smoke_stop hchole hipe
global bin_econ work hlthlm retemp
global ols logbmi retage ipubpen atotf itearn atotb
global order adlstat iadlstat drinkd drinkd_stat exstat srh /*vgactx_e mdactx_e ltactx_e smkstat*/

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
    "High Cholesterol"
    "Hip Fracture"
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
    "Total Family Wealth"
;
global order_names 
    "ADL status"
    "IADL status"
    "# days per week R drinks alcohol"
    "Days/week drinking status"
    "Exercise status"
    "Self-Reported Health Status"
;
#d cr


*** Set up globals for predictor groups ***

*** Demographics
global dvars male white hsless college
*** Lagged Age splines
global lvars_age l2age65l l2age6574 l2age75p


* For age and gender interactions
global lvars_age_sex male_l2age65l male_l2age6574 male_l2age75p

*** Health variables at t-1
global lvars_hlth l2cancre l2diabe l2hearte l2hibpe l2lunge l2stroke
*** Econ vars at t-1
global lvars_econ l2work l2retemp l2itearn l2ipubpen l2atotf

*** Custom groups
* Exercise vars
local lvars_exercise l2exstat1 l2exstat2 /*l2exstat3*/
* Smoking
local lvars_smoke l2smokev l2smoken
* Drinking
local lvars_drink l2drink
* Functional Limitations
local lvars_funclimit l2adl1 l2adl2 l2adl3p l2iadl1 l2iadl2p
* Self Reported Health Status
local lvars_srh l2srh1 l2srh2 l2srh4 l2srh5


*** Now specify the transition models ***

*** For Mortality
*global allvars_died male $lvars_age l2srh3 l2srh4 l2srh5 l2cancre l2hearte l2atotb l2adl2 l2adl3p l2iadl2p
*global allvars_died male $lvars_age l2srh3 l2srh4 l2srh5 l2cancre l2hearte l2iadl2p
*global allvars_died male $lvars_age l2srh4 l2srh5 l2cancre l2hearte l2iadl2p
*global allvars_died male $lvars_age l2srh5 l2hearte
global allvars_died male $lvars_age 


*** Chronic Diseases
*CANCRE
*global allvars_cancre       $dvars $lvars_age l2smoken l2logbmi l2drink
global allvars_cancre       $dvars $lvars_age l2smoken

* DIABE
*global allvars_diabe        $dvars $lvars_age l2logbmi `lvars_smoke' `lvars_exercise' l2hibpe l2hchole /*https://www.diabetes.org.uk/Preventing-Type-2-diabetes/Diabetes-risk-factors https://www.diabetes.co.uk/Diabetes-Risk-factors.html*/
global allvars_diabe        $dvars $lvars_age l2hchole l2hibpe

* HEARTE
*global allvars_hearte       $dvars $lvars_age l2logbmi `lvars_smoke' `lvars_exercise' l2drink l2hibpe l2diabe l2psyche l2hchole /*https://www.bhf.org.uk/informationsupport/risk-factors  https://www.nhsggc.org.uk/your-health/health-services/hsd-patient-carers/heart-disease/risk-factors-for-heart-disease/#*/
*global allvars_hearte       $dvars $lvars_age l2logbmi l2smoken l2hibpe l2hchole
*global allvars_hearte       $dvars $lvars_age l2logbmi l2smoken l2hibpe
global allvars_hearte       $dvars $lvars_age l2logbmi l2hibpe


global allvars_hibpe        $dvars $lvars_age l2logbmi `lvars_smoke' `lvars_exercise' l2drink l2psyche l2hchole /*https://www.bhf.org.uk/informationsupport/risk-factors/high-blood-pressure https://cks.nice.org.uk/topics/hypertension-not-diabetic/background-information/risk-factors/ */
global allvars_lunge        $dvars $lvars_age l2logbmi `lvars_smoke' l2asthmae /*https://www.healthline.com/health/understanding-idiopathic-pulmonary-fibrosis/chronic-lung-diseases-causes-and-risk-factors#1 https://cks.nice.org.uk/topics/chronic-obstructive-pulmonary-disease/background-information/risk-factors/ */
global allvars_stroke       $dvars $lvars_age l2logbmi `lvars_smoke' l2drink l2hearte l2hibpe l2diabe l2hchole /*https://www.stroke.org.uk/what-is-stroke/are-you-at-risk-of-stroke*/

global allvars_arthre       $dvars $lvars_age l2logbmi `lvars_smoke' `lvars_exercise' /*https://www.verywellhealth.com/arthritis-causes-and-risk-factors-2549243*/
global allvars_psyche       $dvars $lvars_age `lvars_smoke' l2drink l2ipubpen l2itearn l2atotf l2work l2cancre l2diabe l2stroke l2hibpe /*https://www.healthyplace.com/other-info/mental-illness-overview/what-causes-mental-illness-genetics-environment-risk-factors*/
global allvars_asthmae      $dvars $lvars_age l2logbmi `lvars_smoke' l2atotb /* https://cks.nice.org.uk/topics/asthma/background-information/risk-factors/ */
global allvars_parkine      $dvars $lvars_age l2logbmi `lvars_smoke' l2drink /*https://parkinsonsdisease.net/basics/risk-factors-causes/ */
global allvars_hchole       $dvars $lvars_age l2logbmi `lvars_exercise' `lvars_smoke' l2diabe /*https://www.bhf.org.uk/informationsupport/risk-factors/high-cholesterol*/
global allvars_hipe         $dvars $lvars_age l2logbmi `lvars_exercise' `lvars_smoke' l2drink l2arthre /*https://www.nursingtimes.net/clinical-archive/orthopaedics/hip-fracture-1-identifying-and-managing-risk-factors-10-12-2018/ */
global allvars_srh          $dvars $lvars_age l2logbmi `lvars_smoke' `lvars_exercise' l2drink l2cancre l2hearte l2diabe l2stroke 


*** Smoking 
global allvars_smoke_start  $dvars $lvars_age l2work l2retemp l2smokev l2psyche l2itearn l2atotf l2ipubpen l2atotb
global allvars_smoke_stop   $dvars $lvars_age l2work l2retemp l2psyche l2itearn l2atotf l2ipubpen l2atotb


*** Drinking
global allvars_drink        $dvars $lvars_age l2logbmi l2psyche l2work l2atotb /* https://alcohol.addictionblog.org/alcoholism-causes-and-risk-factors/ */
global allvars_drinkd_stat  $dvars $lvars_age l2logbmi l2psyche l2work
global allvars_drinkd       $dvars $lvars_age l2logbmi l2psyche l2work


*** Logbmi & other health
*global allvars_logbmi       $dvars $lvars_age l2logbmi l2married l2atotf l2smokev l2smoken `lvars_exercise' l2atotb
global allvars_logbmi       $dvars $lvars_age l2smokev l2smoken l2adl2 l2adl3p
global allvars_hlthlm       $dvars $lvars_age hearte stroke cancre diabe lunge logbmi adl1 adl2 adl3p iadl1 iadl2p smoken smokev drink drinkd1 drinkd3 drinkd4


*** Disabilities
global allvars_adlstat      $dvars $lvars_age l2logbmi `lvars_smoke' $lvars_hlth `lvars_funclimit' l2drink l2psyche l2arthre l2asthmae
global allvars_iadlstat     $dvars $lvars_age l2logbmi `lvars_smoke' $lvars_hlth `lvars_funclimit' l2drink l2psyche l2arthre l2asthmae


*** Economic
global allvars_work         $dvars $lvars_age l2work l2psyche l2cancre l2diabe l2hearte l2stroke l2atotb
*global allvars_itearn       $dvars $lvars_age l2logbmi $lvars_econ l2drink `lvars_smoke' hlthlm l2arthre l2psyche l2asthmae
global allvars_itearn       $dvars $lvars_age l2atotb l2itearn
global allvars_atotf        $dvars $lvars_age l2atotb l2itearn l2work l2retemp
global allvars_atotb        $dvars $lvars_age l2atotf l2itearn l2work l2retemp
global allvars_retemp       $dvars $lvars_age l2psyche l2cancre l2diabe l2hearte l2stroke l2atotb /* https://www.theamericancollege.edu/news-center/6-factors-affecting-actual-retirement-age*/
global allvars_ipubpen      $dvars $lvars_age l2atotf l2atotb /* retage (when fixed and functional)*/
global allvars_retage       $dvars $lvars_age l2logbmi $lvars_hlth $lvars_econ `lvars_smoke' hlthlm l2arthre l2psyche l2asthmae /*REMOVING THIS MODEL SOON*/


*** Exercise
global allvars_exstat       $dvars $lvars_age `lvars_funclimit' l2logbmi l2arthre l2asthmae
