

*** DEPENDANT VARIABLES
global bin_hlth cancre diabe hearte stroke hibpe lunge died drink smoke_start smoke_stop hchole alzhe demene problem_drinker heavy_smoker
global bin_econ
global ols logbmi
global order adlstat iadlstat srh exstat
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
    "Problem Drinker (binge/too frequent)"
    "Heavy Smoker (>10 cigs/day)"
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
    "Exercise status"
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
local lvars_smoke l2smokev l2smoken l2heavy_smoker
* Drinking
local lvars_drink l2drink l2problem_drinker
* Exercise vars
local lvars_exercise l2exstat1 l2exstat2                            /*Control: l2exstat3 - High activity level*/
* Functional Limitations
local lvars_funclimit l2adl1 l2adl2 l2adl3p l2iadl1 l2iadl2p        /*Control: NoADL*/
* Workstat vars
local lvars_workstat l2employed l2unemployed                        /*Control: l2retired - retired*/
* Self Reported Health
local lvars_srh l2srh1 l2srh2 l2srh4 l2srh5
* National Statistics Socio-Economic Classification
local lvars_nssec l2nssec1 l2nssec2 l2nssec3 l2nssec4 l2nssec5 l2nssec6 l2nssec7 l2nssec8



*** Now specify the transition models ***

*** For Mortality
*global allvars_died male $lvars_age l2logbmi_l30 l2logbmi_30p l2cancre l2hearte l2diabe l2stroke l2demene l2alzhe l2smoken `lvars_srh'
global allvars_died male $lvars_age l2cancre l2hearte l2diabe l2lunge l2stroke `lvars_smoke' l2demene

*** Chronic Diseases
*CANCRE
global allvars_cancre       $dvars $lvars_age l2logbmi_l30 l2logbmi_30p l2smokev l2smoken `lvars_srh' `lvars_drink'
* DIABE
global allvars_diabe        $dvars $lvars_age l2logbmi_l30 l2logbmi_30p l2hibpe l2hchole l2problem_drinker `lvars_exercise'
* HEARTE
global allvars_hearte       $dvars $lvars_age l2logbmi_l30 l2logbmi_30p l2smokev l2smoken l2hibpe l2hchole l2diabe l2drink l2problem_drinker `lvars_exercise'
* HIBPE 
global allvars_hibpe        $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_smoke' l2hchole l2problem_drinker `lvars_exercise'
global allvars_lunge        $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_smoke'
global allvars_stroke       $dvars $lvars_age l2logbmi_l30 l2logbmi_30p l2hibpe l2diabe l2hchole l2smoken l2heavy_smoker
global allvars_hchole       $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_smoke' `lvars_exercise'
global allvars_srh          $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_smoke' `lvars_workstat' `lvars_funclimit' l2hearte l2diabe l2lunge l2stroke
global allvars_alzhe        $dvars $lvars_age l2logbmi_l30 l2logbmi_30p l2hibpe l2smoken l2problem_drinker
global allvars_demene       $dvars $lvars_age l2logbmi_l30 l2logbmi_30p l2hibpe l2smoken l2problem_drinker


*** Smoking 
global allvars_smoke_start  $dvars $lvars_age `lvars_workstat'
global allvars_smoke_stop   $dvars $lvars_age `lvars_workstat'
global allvars_heavy_smoker $dvars $lvars_age `lvars_workstat'
*global allvars_smkint       $dvars $lvars_age `lvars_workstat'


*** Drinking
/* https://alcohol.addictionblog.org/alcoholism-causes-and-risk-factors/ */
global allvars_drink        $dvars $lvars_age `lvars_workstat' `lvars_srh'
global allvars_problem_drinker $dvars $lvars_age `lvars_workstat' `lvars_srh'
*global allvars_heavy_drinker $dvars $lvars_age `lvars_workstat'
*global allvars_freq_drinker $dvars $lvars_age `lvars_workstat'


*** Logbmi & other health
global allvars_logbmi       $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_exercise'


*** Disabilities
global allvars_adlstat      $dvars $lvars_age l2logbmi_l30 l2logbmi_30p l2stroke l2demene l2problem_drinker
global allvars_iadlstat     $dvars $lvars_age l2logbmi_l30 l2logbmi_30p l2stroke l2demene l2problem_drinker

*** Workstat
global allvars_workstat     $dvars $lvars_age `lvars_srh'

*** Exercise
global allvars_exstat       $dvars $lvars_age `lvars_funclimit'