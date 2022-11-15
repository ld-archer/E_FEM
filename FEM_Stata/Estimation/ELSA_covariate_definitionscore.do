

*** DEPENDANT VARIABLES
global bin_hlth cancre diabe hearte stroke hibpe lunge asthmae died drink smoke_start smoke_stop hchole alzhe demene angine hrtatte conhrtfe hrtmre hrtrhme catracte osteoe
global bin_econ
global ols logbmi atotb itot smokef
global order adlstat iadlstat srh exstat lnly alcfreq
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
    "Angina"
    "Heart Attack"
    "Congestive Heart Failure"
    "Heart Murmur"
    "Abnormal Heart Rhythm"
    "Cataracts"
    "Osteoporosis"
;
global bin_econ_names
;
global ols_names
    "Log(BMI)"
    "Total Family Wealth"
    "Total Couple Level Income"
    "Smoking Intensity (# cigs/day)"
;
global count_names
    "Number of pints of beer consumed in week before survey"
    "Number of glasses of wine consumed in week before survey"
    "Number of measures of spirits consumed in week before survey"
    "Number of cigarettes consumed per day"
;
global order_names 
    "ADL status"
    "IADL status"
    "Self-Reported Health Status"
    "Exercise status"
    "Rounded categorical revised UCLA loneliness score [1-3]"
    "Alcohol consumption frequency [1-8]"
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
local lvars_smoke l2smokev l2smoken l2smokef
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
* Loneliness
local lvars_lnly l2lnly2 l2lnly3                                    /* Control: l2lnly1 - Loneliness score: Low*/
* Alcohol consumption frequency
local lvars_alcfreq alcfreq1 alcfreq2 alcfreq3 alcfreq5 alcfreq6 alcfreq7 alcfreq8 /* Control: alcfreq4 - Alcohol consumption frequency: once or twice a week*/



*** Now specify the transition models ***

*** For Mortality
*global allvars_died male $lvars_age l2logbmi_l30 l2logbmi_30p l2cancre l2hearte l2diabe l2stroke l2demene l2alzhe l2smoken
* 16/6/21 - now includes l2hibpe & `lvars_funclimit'
*global allvars_died        $dvars $lvars_age l2cancre l2hearte l2diabe l2lunge l2stroke l2hibpe `lvars_smoke' l2demene `lvars_funclimit'
* FROM covar_defincoreLEGACY
global allvars_died         $dvars $lvars_age l2cancre l2hearte l2diabe l2lunge l2stroke l2demene `lvars_smoke' `lvars_lnly'

*** Chronic Diseases
*CANCRE
global allvars_cancre       $dvars $lvars_age l2logbmi_l30 l2logbmi_30p l2smokev 
* DIABE
*global allvars_diabe        $dvars $lvars_age l2logbmi_l30 l2logbmi_30p
global allvars_diabe        $dvars $lvars_age l2logbmi_l30 l2logbmi_30p l2hibpe l2hchole `lvars_exercise' `lvars_lnly'
* Heart Health
*global allvars_hearte       $dvars $lvars_age l2logbmi_l30 l2logbmi_30p
global allvars_hearte       $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_smoke' l2hibpe l2hchole l2diabe `lvars_exercise' `lvars_lnly'
global allvars_angine       $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_smoke' l2hibpe l2hchole l2diabe `lvars_exercise'
global allvars_hrtatte      $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_smoke' l2hibpe l2hchole l2diabe `lvars_exercise'
global allvars_conhrtfe     $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_smoke' l2hibpe l2hchole l2diabe `lvars_exercise'
global allvars_hrtmre       $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_smoke' l2hibpe l2hchole l2diabe `lvars_exercise'
global allvars_hrtrhme      $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_smoke' l2hibpe l2hchole l2diabe `lvars_exercise'
* Alzhe & Demene
global allvars_alzhe        $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_exercise' l2hchole l2stroke l2hibpe l2smokev `lvars_lnly'
global allvars_demene       $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_exercise' l2hchole l2stroke l2hibpe l2smokev `lvars_lnly'
* Other
global allvars_hibpe        $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_smoke' l2hchole `lvars_exercise'
global allvars_lunge        $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_smoke'
global allvars_stroke       $dvars $lvars_age l2logbmi_l30 l2logbmi_30p l2hibpe l2diabe l2hchole l2smoken `lvars_lnly'
global allvars_hchole       $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_smoke' `lvars_exercise' `lvars_lnly'
global allvars_srh          $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_smoke' `lvars_workstat' `lvars_funclimit' l2hearte l2diabe l2lunge l2stroke
global allvars_asthmae      $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_smoke'
global allvars_catracte     $dvars $lvars_age l2diabe l2hibpe `lvars_smoke' /* https://cks.nice.org.uk/topics/cataracts/background-information/causes-risk-factors/ */
global allvars_osteoe       $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_smoke' l2asthmae `lvars_exercise'   /* arthritis https://www.nhs.uk/conditions/osteoporosis/causes/ */


*** Smoking 
global allvars_smoke_start  $dvars $lvars_age l2logbmi_l30 l2logbmi_30p
global allvars_smoke_stop   $dvars $lvars_age l2logbmi_l30 l2logbmi_30p
global allvars_smokef       $dvars $lvars_age l2logbmi_l30 l2logbmi_30p


*** Drinking
/* https://alcohol.addictionblog.org/alcoholism-causes-and-risk-factors/ */
global allvars_drink        $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_exercise'
global allvars_alcfreq      $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_exercise'


*** Logbmi & other health
global allvars_logbmi           $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_exercise'


*** Economic vars (atotb & itot)
global allvars_atotb            $dvars $lvars_age `lvars_workstat' `lvars_funclimit' `lvars_smoke' l2drink `lvars_mstat'
global allvars_itot             $dvars $lvars_age `lvars_workstat' `lvars_funclimit' `lvars_smoke' l2drink `lvars_mstat'


*** Disabilities
* 16/6/21 - Now includes l2alzhe
global allvars_adlstat          $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_smoke' l2stroke l2demene l2alzhe l2osteoe l2catracte `lvars_lnly' 
global allvars_iadlstat         $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_smoke' l2stroke l2demene l2alzhe l2osteoe l2catracte `lvars_lnly'

*** Workstat
global allvars_workstat         $dvars $lvars_age `lvars_funclimit'

*** Exercise
global allvars_exstat           $dvars $lvars_age `lvars_funclimit' `lvars_exercise'

*** Loneliness
global allvars_lnly             $dvars $lvars_age atotb `lvars_mstat' `lvars_workstat'

*** Marriage Status
global allvars_mstat            $dvars $lvars_age `lvars_workstat' l2logbmi_l30 l2logbmi_30p
 