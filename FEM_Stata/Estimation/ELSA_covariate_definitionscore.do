

*** DEPENDANT VARIABLES
global bin_hlth cancre diabe hearte stroke hibpe lunge asthmae died drink smoke_start smoke_stop hchole alzhe demene problem_drinker heavy_smoker
global bin_econ
global ols logbmi atotb itot
global order adlstat iadlstat srh exstat
global unorder workstat mstat

* Variable names
#d ;
global bin_hlth_names
    "Cancer"
    "Diabetes"
    "Heart Disease"
    "Stroke"
    "Hypertension"
    "Lung Disease"
    "Asthma"
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
    "Total Family Wealth"
    "Total Couple Level Income"
;
global order_names 
    "ADL status"
    "IADL status"
    "Self-Reported Health Status"
    "Exercise status"
;
global unorder_names
    "Work Status"
    "Marriage Status"
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
* Relationship Status vars
local lvars_mstat l2single l2cohab l2widowed                        /*Control: l2married - married*/



*** Now specify the transition models ***

*** For Mortality
*global allvars_died male $lvars_age l2logbmi_l30 l2logbmi_30p l2cancre l2hearte l2diabe l2stroke l2demene l2alzhe l2smoken
* 16/6/21 - now includes l2hibpe & `lvars_funclimit'
*global allvars_died        $dvars $lvars_age l2cancre l2hearte l2diabe l2lunge l2stroke l2hibpe `lvars_smoke' l2demene `lvars_funclimit'
* FROM covar_defincoreLEGACY
global allvars_died         male $lvars_age l2cancre l2hearte l2diabe l2lunge l2stroke l2demene `lvars_smoke'

*** Chronic Diseases
*CANCRE
global allvars_cancre       $dvars $lvars_age l2logbmi_l30 l2logbmi_30p l2smokev l2heavy_smoker l2problem_drinker
* DIABE
global allvars_diabe        $dvars $lvars_age l2logbmi_l30 l2logbmi_30p l2hibpe l2hchole l2problem_drinker `lvars_exercise'
* HEARTE
global allvars_hearte       $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_smoke' l2hibpe l2hchole l2diabe l2problem_drinker `lvars_exercise'

* HIBPE (16/6/21 Now includes l2diabe)
global allvars_hibpe        $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_smoke' l2hchole l2problem_drinker `lvars_exercise'
global allvars_lunge        $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_smoke'
global allvars_stroke       $dvars $lvars_age l2logbmi_l30 l2logbmi_30p l2hibpe l2diabe l2hchole l2smoken l2heavy_smoker l2problem_drinker
global allvars_hchole       $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_smoke' `lvars_exercise'
global allvars_srh          $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_smoke' `lvars_workstat' `lvars_funclimit' l2hearte l2diabe l2lunge l2stroke
global allvars_asthmae      $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_smoke'

* Alzhe & Demene (16/6/21 now includes l2stroke)
global allvars_alzhe        $dvars $lvars_age l2logbmi_l30 l2logbmi_30p l2stroke l2hibpe l2smoken
global allvars_demene       $dvars $lvars_age l2logbmi_l30 l2logbmi_30p l2stroke l2hibpe l2smoken


*** Smoking 
global allvars_smoke_start  $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_workstat'
global allvars_smoke_stop   $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_workstat'
global allvars_heavy_smoker $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_workstat'
*global allvars_smkint       $dvars $lvars_age `lvars_workstat'


*** Drinking
/* https://alcohol.addictionblog.org/alcoholism-causes-and-risk-factors/ */
global allvars_drink        $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_workstat' `lvars_exercise' 
global allvars_problem_drinker $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_workstat' `lvars_exercise'
*global allvars_heavy_drinker $dvars $lvars_age `lvars_workstat'
*global allvars_freq_drinker $dvars $lvars_age `lvars_workstat'


*** Logbmi & other health
global allvars_logbmi       $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_exercise'


*** Economic vars (atotb & itot)
global allvars_atotb     $dvars $lvars_age `lvars_workstat' `lvars_funclimit' `lvars_smoke' `lvars_drink' `lvars_mstat'
global allvars_itot      $dvars $lvars_age `lvars_workstat' `lvars_funclimit' `lvars_smoke' `lvars_drink' `lvars_mstat'


*** Disabilities
* 16/6/21 - Now includes l2alzhe
global allvars_adlstat      $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_smoke' l2stroke l2demene l2alzhe
global allvars_iadlstat     $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_smoke' l2stroke l2demene l2alzhe

*** Workstat
global allvars_workstat     $dvars $lvars_age `lvars_funclimit'

*** Exercise
global allvars_exstat       $dvars $lvars_age `lvars_funclimit' `lvars_exercise'

*** Marriage Status
global allvars_mstat        $dvars $lvars_age `lvars_workstat' l2logbmi_l30 l2logbmi_30p l2problem_drinker l2heavy_smoker
 