

*** DEPENDANT VARIABLES
global bin_hlth cancre diabe hearte hibpe lunge stroke arthre psyche died asthmae parkine drink smoke_start smoke_stop hchole hipe alzhe demene
global bin_econ hlthlm
global ols logbmi ipubpen atotf itearn atotb
global order adlstat iadlstat drinkd drinkd_stat exstat srh smkint mstat lnly workstat

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
    "Alzheimers"
    "Dementia"
;
global bin_econ_names
    "Health Limits Work"
;
global ols_names
    "Log(BMI)"
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
    "Smoking Intensity Status"
    "Loneliness Status"
    "Work Status"
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
global lvars_econ l2employed l2unemployed l2itearn l2ipubpen l2atotf

*** Custom groups
* Exercise vars
local lvars_exercise l2exstat1 l2exstat2                            /*Control: l2exstat3 - High activity level*/
* Smoking
local lvars_smoke l2smokev l2smoken l2smkint1 l2smkint2 l2smkint3
* Drinking
local lvars_drink l2drink
* Functional Limitations
local lvars_funclimit l2adl1 l2adl2 l2adl3p l2iadl1 l2iadl2p        /*Control: NoADL*/
* Self Reported Health Status
local lvars_srh l2srh1 l2srh2 l2srh4 l2srh5                         /*Control: l2srh3 - Good*/
* Loneliness score
local lvars_lnly lnly2 lnly3                                        /*Control: l2lnly1 - loneliness == low*/
* Marriage Status vars
local lvars_mstat l2single l2cohab l2widowed                        /*Control: l2married - married*/
* Workstat vars
local lvars_workstat l2employed l2unemployed                        /*Control: l2retired - retired*/


*** Now specify the transition models ***

*** For Mortality
*global allvars_died male $lvars_age l2srh3 l2srh4 l2srh5 l2cancre l2hearte l2atotb l2adl2 l2adl3p l2iadl2p
*global allvars_died male $lvars_age l2srh3 l2srh4 l2srh5 l2cancre l2hearte l2iadl2p
*global allvars_died male $lvars_age l2srh4 l2srh5 l2cancre l2hearte l2iadl2p
*global allvars_died male $lvars_age l2srh5 l2hearte
* 11-27_16:47:29: global allvars_died male $lvars_age 
global allvars_died male $lvars_age l2cancre l2hearte l2diabe


*** Chronic Diseases
*CANCRE
*global allvars_cancre       $dvars $lvars_age l2smoken l2logbmi l2drink
* debug/11-27_10:49:41
* 11-27_11:01:51: global allvars_cancre       $dvars $lvars_age l2smoken
* 11-27_11:15:22: global allvars_cancre       $dvars $lvars_age l2smokev
* 11-27_11:54:01: global allvars_cancre       $dvars $lvars_age l2logbmi
* 11-27_12:21:26: global allvars_cancre       $dvars $lvars_age l2logbmi l2drink
* 11-27_13:49:05: global allvars_cancre       $dvars $lvars_age l2logbmi l2hchole
* 11-27_16:12:16: global allvars_cancre       $dvars $lvars_age l2logbmi l2smoken l2drink l2married
* 11-27_16:47:29: global allvars_cancre       $dvars $lvars_age l2logbmi l2smoken l2drink l2married l2exstat1 l2exstat2
global allvars_cancre       $dvars $lvars_age l2logbmi l2exstat1

* DIABE
*global allvars_diabe        $dvars $lvars_age l2logbmi `lvars_smoke' `lvars_exercise' l2hibpe l2hchole /*https://www.diabetes.org.uk/Preventing-Type-2-diabetes/Diabetes-risk-factors https://www.diabetes.co.uk/Diabetes-Risk-factors.html*/
* debug/11-27_10:49:41
* 11-27_11:01:51: global allvars_diabe        $dvars $lvars_age l2logbmi l2hchole l2hibpe l2smoken
* 11-27_11:15:22: global allvars_diabe        $dvars $lvars_age l2hchole l2hibpe l2smoken
* 11-27_11:54:01: global allvars_diabe        $dvars $lvars_age l2hchole l2hibpe l2smoken l2exstat1 l2exstat2
* 11-27_12:21:26: global allvars_diabe        $dvars $lvars_age l2hchole l2hibpe l2exstat1 l2exstat2
* 11-27_13:49:05: global allvars_diabe        $dvars $lvars_age l2hchole l2hibpe l2exstat1 l2exstat2 l2drink
* 11-27_16:12:16: global allvars_diabe        $dvars $lvars_age l2hchole l2hibpe l2exstat1 l2exstat2 l2drink
* 11-27_16:47:29: global allvars_diabe        $dvars $lvars_age l2hchole l2hibpe l2exstat1 l2exstat2
global allvars_diabe        $dvars $lvars_age l2hchole l2hibpe l2exstat1 l2exstat2 l2atotb

* HEARTE
*global allvars_hearte       $dvars $lvars_age l2logbmi `lvars_smoke' `lvars_exercise' l2drink l2hibpe l2diabe l2psyche l2hchole /*https://www.bhf.org.uk/informationsupport/risk-factors  https://www.nhsggc.org.uk/your-health/health-services/hsd-patient-carers/heart-disease/risk-factors-for-heart-disease/#*/
* debug/11-27_10:49:41
* 11-27_11:01:51: global allvars_hearte       $dvars $lvars_age l2logbmi l2smoken l2hibpe
* 11-27_11:15:22: global allvars_hearte       $dvars $lvars_age l2logbmi l2hibpe l2hchole
* 11-27_11:54:01: global allvars_hearte       $dvars $lvars_age l2logbmi l2smoken l2hibpe l2hchole
* 11-27_12:21:26: global allvars_hearte       $dvars $lvars_age l2logbmi l2hibpe l2hchole l2drink
* 11-27_13:49:05: global allvars_hearte       $dvars $lvars_age l2logbmi l2hibpe l2hchole l2diabe
* 11-27_16:12:16: global allvars_hearte       $dvars $lvars_age l2logbmi l2hibpe l2hchole l2diabe l2exstat1 l2exstat2
* 11-27_16:47:29: global allvars_hearte       $dvars $lvars_age l2logbmi l2hibpe l2hchole l2exstat1 l2exstat2 l2smoken
global allvars_hearte       $dvars $lvars_age l2logbmi l2hibpe l2hchole l2exstat1 l2exstat2


* HIBPE 
* 11-27_11:54:01: global allvars_hibpe        $dvars $lvars_age l2logbmi `lvars_smoke' `lvars_exercise' l2drink l2psyche l2hchole /*https://www.bhf.org.uk/informationsupport/risk-factors/high-blood-pressure https://cks.nice.org.uk/topics/hypertension-not-diabetic/background-information/risk-factors/ */
* 11-27_12:21:26: global allvars_hibpe        $dvars $lvars_age
* 11-27_13:49:05: global allvars_hibpe        $dvars $lvars_age l2logbmi
* 11-27_16:12:16: global allvars_hibpe        $dvars $lvars_age l2logbmi l2hchole
* 11-27_16:47:29: global allvars_hibpe        $dvars $lvars_age l2logbmi l2hchole l2smoken l2drink
global allvars_hibpe        $dvars $lvars_age l2logbmi l2hchole l2smoken l2exstat1 l2exstat2

global allvars_lunge        $dvars $lvars_age l2logbmi l2smkint l2asthmae /*https://www.healthline.com/health/understanding-idiopathic-pulmonary-fibrosis/chronic-lung-diseases-causes-and-risk-factors#1 https://cks.nice.org.uk/topics/chronic-obstructive-pulmonary-disease/background-information/risk-factors/ */
global allvars_stroke       $dvars $lvars_age l2logbmi `lvars_smoke' l2drink l2hearte l2hibpe l2diabe l2hchole /*https://www.stroke.org.uk/what-is-stroke/are-you-at-risk-of-stroke*/

global allvars_arthre       $dvars $lvars_age l2logbmi `lvars_smoke' `lvars_exercise' /*https://www.verywellhealth.com/arthritis-causes-and-risk-factors-2549243*/

* PSYCHE
*global allvars_psyche       $dvars $lvars_age `lvars_smoke' l2drink l2ipubpen l2itearn l2atotf l2employed l2unemployed l2cancre l2diabe l2stroke l2hibpe /*https://www.healthyplace.com/other-info/mental-illness-overview/what-causes-mental-illness-genetics-environment-risk-factors*/
global allvars_psyche       $dvars $lvars_age 


global allvars_asthmae      $dvars $lvars_age l2logbmi `lvars_smoke' l2atotb /* https://cks.nice.org.uk/topics/asthma/background-information/risk-factors/ */
global allvars_parkine      $dvars $lvars_age l2logbmi `lvars_smoke' l2drink /*https://parkinsonsdisease.net/basics/risk-factors-causes/ */
global allvars_hchole       $dvars $lvars_age l2logbmi `lvars_exercise' `lvars_smoke' l2diabe /*https://www.bhf.org.uk/informationsupport/risk-factors/high-cholesterol*/
global allvars_hipe         $dvars $lvars_age l2logbmi `lvars_exercise' `lvars_smoke' l2drink l2arthre /*https://www.nursingtimes.net/clinical-archive/orthopaedics/hip-fracture-1-identifying-and-managing-risk-factors-10-12-2018/ */
global allvars_srh          $dvars $lvars_age l2logbmi `lvars_smoke' `lvars_exercise' l2drink l2cancre l2hearte l2diabe l2stroke
global allvars_alzhe        $dvars $lvars_age 
global allvars_demene       $dvars $lvars_age


*** Smoking 
*global allvars_smoke_start  $dvars $lvars_age l2employed l2unemployed l2smokev l2psyche l2itearn l2atotf l2ipubpen l2atotb
* 11-27_16:12:16: global allvars_smoke_start  $dvars $lvars_age
*global allvars_smoke_start  $dvars $lvars_age l2smokev l2employed l2unemployed 
*global allvars_smoke_start  $dvars $lvars_age l2employed l2unemployed l2psyche l2single l2married l2widowed
global allvars_smoke_start  $dvars $lvars_age `lvars_lnly' `lvars_workstat' `lvars_mstat'
*global allvars_smoke_stop   $dvars $lvars_age l2employed l2unemployed l2psyche l2itearn l2atotf l2ipubpen l2atotb
* 11-27_16:12:16: global allvars_smoke_stop   $dvars $lvars_age
*global allvars_smoke_stop   $dvars $lvars_age l2employed l2unemployed
*global allvars_smoke_stop   $dvars $lvars_age l2employed l2unemployed l2psyche l2single l2married l2widowed
global allvars_smoke_stop   $dvars $lvars_age `lvars_lnly' `lvars_workstat' `lvars_mstat'
*l2single l2married l2cohab l2atotb l2ipubpen
global allvars_smkint       $dvars $lvars_age `lvars_lnly' `lvars_workstat' `lvars_mstat'


*** Drinking
*global allvars_drink        $dvars $lvars_age l2logbmi l2psyche l2employed l2unemployed l2atotb /* https://alcohol.addictionblog.org/alcoholism-causes-and-risk-factors/ */
* 11-27_16:12:16: global allvars_drink        $dvars $lvars_age
global allvars_drink        $dvars $lvars_age l2employed l2unemployed l2logbmi
global allvars_drinkd_stat  $dvars $lvars_age
global allvars_drinkd       $dvars $lvars_age


*** Logbmi & other health
*global allvars_logbmi       $dvars $lvars_age l2logbmi l2married l2atotf l2smokev l2smoken `lvars_exercise' l2atotb
* Previous Good: global allvars_logbmi       $dvars $lvars_age l2smokev l2smoken l2adl2 l2adl3p
global allvars_logbmi       $dvars $lvars_age l2logbmi
global allvars_hlthlm       $dvars $lvars_age hearte stroke cancre diabe lunge logbmi adl1 adl2 adl3p iadl1 iadl2p smoken smokev drink drinkd1 drinkd3 drinkd4


*** Disabilities
global allvars_adlstat      $dvars $lvars_age l2logbmi `lvars_smoke' $lvars_hlth `lvars_funclimit' l2drink l2psyche l2arthre l2asthmae
global allvars_iadlstat     $dvars $lvars_age l2logbmi `lvars_smoke' $lvars_hlth `lvars_funclimit' l2drink l2psyche l2arthre l2asthmae


*** Economic
*global allvars_itearn       $dvars $lvars_age l2logbmi $lvars_econ l2drink `lvars_smoke' hlthlm l2arthre l2psyche l2asthmae
global allvars_itearn       $dvars $lvars_age l2atotb l2itearn
global allvars_atotf        $dvars $lvars_age l2atotb l2itearn l2employed l2unemployed /* Control for workstat vars is retired */
global allvars_atotb        $dvars $lvars_age l2atotf l2itearn l2employed l2unemployed /* Control for workstat vars is retired */
global allvars_ipubpen      $dvars $lvars_age l2atotf l2atotb

global allvars_workstat     $dvars $lvars_age l2workstat l2psyche l2stroke `lvars_smoke' l2married l2single

*** Exercise
global allvars_exstat       $dvars $lvars_age `lvars_funclimit' l2logbmi l2arthre l2asthmae

*** Marriage Status
global allvars_mstat        $dvars $lvars_age l2employed l2unemployed l2psyche l2atotb l2logbmi

*** Social
global allvars_lnly         $dvars $lvars_age l2widowed `lvars_funclimit' 
