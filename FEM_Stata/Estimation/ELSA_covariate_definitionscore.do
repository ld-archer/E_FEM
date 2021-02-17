

*** DEPENDANT VARIABLES
global bin_hlth cancre diabe hearte stroke hibpe lunge died drink smoke_start smoke_stop hchole alzhe demene heavy_drinker freq_drinker
global bin_econ
global ols logbmi
global order adlstat iadlstat srh smkint
global unorder workstat

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
;
global order_names 
    "ADL status"
    "IADL status"
    "Self-Reported Health Status"
    "Smoking Intensity Status"
;
global unorder_names
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
* Workstat vars
local lvars_workstat l2employed l2unemployed                        /*Control: l2retired - retired*/
* Self Reported Health
local lvars_srh l2srh1 l2srh2 l2srh4 l2srh5


*** Now specify the transition models ***

*** For Mortality
global allvars_died male $lvars_age l2cancre l2hearte l2diabe l2stroke l2demene l2alzhe `lvars_srh' `lvars_funclimit'  /* :thumbs-up !!! */


*** Chronic Diseases
*CANCRE
global allvars_cancre       $dvars $lvars_age l2logbmi `lvars_smoke' `lvars_srh'
* DIABE
global allvars_diabe        $dvars $lvars_age l2logbmi l2freq_drinker l2hibpe l2hchole
* HEARTE
global allvars_hearte       $dvars $lvars_age l2logbmi l2hibpe l2hchole l2smoken
* HIBPE 
global allvars_hibpe        $dvars $lvars_age l2logbmi l2hchole l2smoken
global allvars_lunge        $dvars $lvars_age `lvars_smoke'
global allvars_stroke       $dvars $lvars_age l2logbmi
global allvars_hchole       $dvars $lvars_age l2logbmi
global allvars_srh          $dvars $lvars_age 
global allvars_alzhe        $dvars $lvars_age 
global allvars_demene       $dvars $lvars_age 


*** Smoking 
global allvars_smoke_start  $dvars $lvars_age 
global allvars_smoke_stop   $dvars $lvars_age 
global allvars_smkint       $dvars $lvars_age 


*** Drinking
/* https://alcohol.addictionblog.org/alcoholism-causes-and-risk-factors/ */
global allvars_drink        $dvars $lvars_age 
global allvars_heavy_drinker $dvars $lvars_age 
global allvars_freq_drinker $dvars $lvars_age 


*** Logbmi & other health
global allvars_logbmi       $dvars $lvars_age l2logbmi_l30 l2logbmi_30p 


*** Disabilities
global allvars_adlstat      $dvars $lvars_age l2logbmi
global allvars_iadlstat     $dvars $lvars_age l2logbmi

** Workstat
global allvars_workstat     $dvars $lvars_age 
