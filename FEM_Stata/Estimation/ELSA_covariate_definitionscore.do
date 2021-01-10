

*** DEPENDANT VARIABLES
global bin_hlth cancre diabe hearte stroke hibpe lunge died drink smoke_start smoke_stop hchole alzhe demene heavy_drinker freq_drinker
global bin_econ
global ols logbmi logatotb logitot
global order adlstat iadlstat srh smkint
global unorder mstat workstat

* Variable names
#d ;
global bin_hlth_names
    "Cancer"
    "Diabetes"
    "Heart Disease"
    "Stroke"
    "Hypertension"
    "Lung Disease"
    "Died"
    "Drinks Alcohol"
    "Started Smoking"
    "Stopped Smoking"
    "High Cholesterol"
    "Alzheimers"
    "Dementia"
    "Heavy Drinker (>14 units/week)"
    "Frequent Drinker (>5 days/week)"
;
global bin_econ_names
;
global ols_names
    "Log(BMI)"
    "Log(Total Family Wealth)"
    "Log(Total Family Income)"
;
global order_names 
    "ADL status"
    "IADL status"
    "Self-Reported Health Status"
    "Smoking Intensity Status"
    "Loneliness Status"
;
global unorder_names
    "Marriage Status"
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
global lvars_econ

*** Custom groups
* Smoking
local lvars_smoke l2smokev l2smoken l2smkint1 l2smkint2 l2smkint3
* Drinking
local lvars_drink l2drink l2heavy_drinker l2freq_drinker
* Functional Limitations
local lvars_funclimit l2adl1 l2adl2 l2adl3p l2iadl1 l2iadl2p        /*Control: NoADL*/
* Marriage Status vars
local lvars_mstat l2single l2cohab l2widowed                        /*Control: l2married - married*/
* Workstat vars
local lvars_workstat l2employed l2unemployed                        /*Control: l2retired - retired*/
* Finance vars
local lvars_finance l2logatotb l2logitot


*** Now specify the transition models ***

*** For Mortality
global allvars_died male $lvars_age l2cancre l2hearte l2diabe l2stroke l2demene l2alzhe `lvars_srh' `lvars_funclimit' l2logatotb /* :thumbs-up !!! */


*** Chronic Diseases
*CANCRE
global allvars_cancre       $dvars $lvars_age l2logbmi `lvars_smoke' l2freq_drinker l2heavy_drinker `lvars_srh'

* DIABE
global allvars_diabe        $dvars $lvars_age l2hchole l2hibpe l2logatotb /*https://www.diabetes.org.uk/Preventing-Type-2-diabetes/Diabetes-risk-factors https://www.diabetes.co.uk/Diabetes-Risk-factors.html*/

* HEARTE
global allvars_hearte       $dvars $lvars_age l2logbmi l2hibpe l2hchole /*https://www.bhf.org.uk/informationsupport/risk-factors  https://www.nhsggc.org.uk/your-health/health-services/hsd-patient-carers/heart-disease/risk-factors-for-heart-disease/#*/


* HIBPE 
global allvars_hibpe        $dvars $lvars_age l2logbmi l2hchole l2smoken /*https://www.bhf.org.uk/informationsupport/risk-factors/high-blood-pressure https://cks.nice.org.uk/topics/hypertension-not-diabetic/background-information/risk-factors/ */
global allvars_lunge        $dvars $lvars_age l2logbmi l2smkint /*https://www.healthline.com/health/understanding-idiopathic-pulmonary-fibrosis/chronic-lung-diseases-causes-and-risk-factors#1 https://cks.nice.org.uk/topics/chronic-obstructive-pulmonary-disease/background-information/risk-factors/ */
global allvars_stroke       $dvars $lvars_age l2logbmi `lvars_smoke' l2drink l2hearte l2hibpe l2diabe l2hchole /*https://www.stroke.org.uk/what-is-stroke/are-you-at-risk-of-stroke*/
global allvars_hchole       $dvars $lvars_age l2logbmi `lvars_smoke' l2diabe /*https://www.bhf.org.uk/informationsupport/risk-factors/high-cholesterol*/
global allvars_srh          $dvars $lvars_age l2logbmi `lvars_smoke' l2drink l2cancre l2hearte l2diabe
global allvars_alzhe        $dvars $lvars_age l2logbmi l2hchole l2stroke l2diabe /*https://www.alzheimersresearchuk.org/dementia-information/types-of-dementia/alzheimers-disease/risk-factors/ */
global allvars_demene       $dvars $lvars_age l2logbmi l2hchole l2stroke l2diabe `lvars_smoke' `lvars_funclimit' /*https://www.healthline.com/health/dementia-risk-factors#genetic-and-lifestyle-risk-factors*/


*** Smoking 
global allvars_smoke_start  $dvars $lvars_age `lvars_workstat' `lvars_mstat' l2logatotb l2logitot
global allvars_smoke_stop   $dvars $lvars_age `lvars_workstat' `lvars_mstat' l2logatotb l2logitot
global allvars_smkint       $dvars $lvars_age `lvars_workstat' `lvars_mstat' l2logatotb l2logitot


*** Drinking
/* https://alcohol.addictionblog.org/alcoholism-causes-and-risk-factors/ */
global allvars_drink        $dvars $lvars_age l2drink `lvars_workstat' `lvars_mstat' $lvars_hlth
global allvars_heavy_drinker $dvars $lvars_age l2heavy_drinker l2freq_drinker `lvars_workstat' `lvars_mstat' $lvars_hlth `lvars_smoke' `lvars_finance'
global allvars_freq_drinker $dvars $lvars_age l2freq_drinker l2heavy_drinker `lvars_workstat' `lvars_mstat' $lvars_hlth `lvars_smoke' `lvars_finance'


*** Logbmi & other health
global allvars_logbmi       $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_smoke' `lvars_drink' `lvars_funclimit' `lvars_workstat' `lvars_mstat'


*** Disabilities
global allvars_adlstat      $dvars $lvars_age `lvars_smoke' $lvars_hlth `lvars_funclimit' l2drink
global allvars_iadlstat     $dvars $lvars_age `lvars_smoke' $lvars_hlth `lvars_funclimit' l2drink


*** Economic
global allvars_logatotb     $dvars $lvars_age l2logatotb `lvars_workstat' `lvars_mstat' $lvars_hlth  /* Control for workstat vars is retired */
global allvars_logitot      $dvars $lvars_age l2logitot `lvars_workstat' `lvars_mstat' $lvars_hlth

global allvars_workstat     $dvars $lvars_age l2workstat l2stroke `lvars_smoke' `lvars_mstat'

*** Marriage Status
global allvars_mstat        $dvars $lvars_age `lvars_workstat' l2logatotb
