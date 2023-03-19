

*** DEPENDANT VARIABLES
global bin_hlth cancre diabe hearte stroke hibpe lunge asthmae died drink smoke_start smoke_stop hchole demene angine hrtatte conhrtfe hrtmre hrtrhme catracte osteoe physact
global bin_econ 
global ols logbmi logatotb logitot orient
global count smokef tr20 verbf
global order adlstat iadlstat srh lnly alcfreq sociso sight hearing
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
    "Dementia"
    "Angina"
    "Heart Attack"
    "Congestive Heart Failure"
    "Heart Murmur"
    "Abnormal Heart Rhythm"
    "Cataracts"
    "Osteoporosis"
    "Physically Active"
;
global bin_econ_names
;
global ols_names
    "Log(BMI)"
    "Total Family Wealth"
    "Total Couple Level Income"
    "Smoking Intensity (# cigs/day)"
    "Total word recall"
    "Verbal fluency score"
    "Date naming (orient)"
;
global count_names
    "Number of cigarettes consumed per day"
    "Total word recall"
    "Verbal fluency score"
;
global order_names 
    "ADL status"
    "IADL status"
    "Self-Reported Health Status"
    "Rounded categorical revised UCLA loneliness score [1-3]"
    "Alcohol consumption frequency [1-8]"
    "Index of Social Isolation [1-6]"
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
*local lvars_exercise l2exstat1 l2exstat2                            /*Control: l2exstat3 - High activity level*/
* Functional Limitations
local lvars_funclimit l2adl1 l2adl2 l2adl3p l2iadl1 l2iadl2p        /*Control: NoADL*/
* Workstat vars
local lvars_workstat l2employed l2inactive                        /*Control: l2retired - retired*/
* Self Reported Health
local lvars_srh l2srh1 l2srh2 l2srh4 l2srh5
* National Statistics Socio-Economic Classification
local lvars_nssec l2nssec1 l2nssec2 l2nssec3 l2nssec4 l2nssec5 l2nssec6 l2nssec7 l2nssec8
* Relationship Status vars
local lvars_mstat l2single l2cohab l2widowed                        /*Control: l2married - married*/
* Loneliness
local lvars_lnly l2lnly1 l2lnly2                                    /* Control: l2lnly1 - Loneliness score: Low*/
* Alcohol consumption frequency
local lvars_alcfreq l2alcfreq1 l2alcfreq2 l2alcfreq3 l2alcfreq5 l2alcfreq6 l2alcfreq7 l2alcfreq8 /* Control: alcfreq4 - Alcohol consumption frequency: once or twice a week*/
* Social Isolation
local lvars_sociso l2sociso1 l2sociso2 l2sociso3 l2sociso4 l2sociso5 /* Control: l2sociso1 - No Social Isolation */



*** Now specify the transition models ***

*** For Mortality
*global allvars_died male $lvars_age l2logbmi_l30 l2logbmi_30p l2cancre l2hearte l2diabe l2stroke l2demene l2alzhe l2smoken
* 16/6/21 - now includes l2hibpe & `lvars_funclimit'
*global allvars_died        $dvars $lvars_age l2cancre l2hearte l2diabe l2lunge l2stroke l2hibpe `lvars_smoke' l2demene `lvars_funclimit'
* FROM covar_defincoreLEGACY
global allvars_died             $dvars $lvars_age l2cancre l2hearte l2diabe l2lunge l2stroke l2demene `lvars_smoke' `lvars_lnly' `lvars_sociso'
*global allvars_died             $dvars $lvars_age `lvars_lnly' `lvars_sociso'
*global allvars_died             $dvars $lvars_age sociso

*** Chronic Diseases
*CANCRE
global allvars_cancre           $dvars $lvars_age l2logbmi_l30 l2logbmi_30p l2smokev `lvars_lnly' `lvars_alcfreq'
* DIABE
*global allvars_diabe        $dvars $lvars_age l2logbmi_l30 l2logbmi_30p
*global allvars_diabe            $dvars $lvars_age l2logbmi_l30 l2logbmi_30p l2hibpe l2hchole l2physact `lvars_lnly' `lvars_sociso' `lvars_alcfreq'
global allvars_diabe            $dvars $lvars_age `lvars_lnly' `lvars_sociso'
* Heart Health
*global allvars_hearte       $dvars $lvars_age l2logbmi_l30 l2logbmi_30p
global allvars_hearte           $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_smoke' l2hibpe l2hchole l2diabe l2physact `lvars_lnly' `lvars_sociso' `lvars_alcfreq'
*global allvars_hearte           $dvars $lvars_age `lvars_lnly' `lvars_sociso'
global allvars_angine           $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_smoke' l2hibpe l2hchole l2diabe l2physact
global allvars_hrtatte          $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_smoke' l2hibpe l2hchole l2diabe l2physact
global allvars_conhrtfe         $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_smoke' l2hibpe l2hchole l2diabe l2physact
global allvars_hrtmre           $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_smoke' l2hibpe l2hchole l2diabe l2physact
global allvars_hrtrhme          $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_smoke' l2hibpe l2hchole l2diabe l2physact
* Alzhe & Demene
global allvars_alzhe            $dvars $lvars_age l2logbmi_l30 l2logbmi_30p l2physact l2hchole l2stroke l2hibpe l2smokev `lvars_lnly' `lvars_sociso' `lvars_alcfreq'
global allvars_demene           $dvars $lvars_age l2logbmi_l30 l2logbmi_30p l2physact l2hchole l2stroke l2hibpe l2smokev `lvars_lnly' `lvars_sociso' `lvars_alcfreq' l2sight l2hearing
*global allvars_alzhe            $dvars $lvars_age `lvars_lnly' `lvars_sociso'
*global allvars_demene           $dvars $lvars_age `lvars_lnly' `lvars_sociso'
* Other
global allvars_hibpe            $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_smoke' l2hchole l2physact `lvars_sociso' `lvars_alcfreq'
*global allvars_hibpe            $dvars $lvars_age `lvars_lnly' `lvars_sociso'
global allvars_lunge            $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_smoke'
global allvars_stroke           $dvars $lvars_age l2logbmi_l30 l2logbmi_30p l2hibpe l2diabe l2hchole l2smoken `lvars_lnly' `lvars_sociso' `lvars_alcfreq'
*global allvars_stroke           $dvars $lvars_age `lvars_lnly' `lvars_sociso'
global allvars_hchole           $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_smoke' l2physact `lvars_lnly' `lvars_sociso' `lvars_alcfreq'
*global allvars_hchole           $dvars $lvars_age `lvars_lnly' `lvars_sociso'
global allvars_srh              $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_smoke' `lvars_workstat' `lvars_funclimit' l2hearte l2diabe l2lunge l2stroke
global allvars_asthmae          $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_smoke'
global allvars_catracte         $dvars $lvars_age l2diabe l2hibpe `lvars_smoke' /* https://cks.nice.org.uk/topics/cataracts/background-information/causes-risk-factors/ */
global allvars_osteoe           $dvars $lvars_age l2logbmi_l30 l2logbmi_30p `lvars_smoke' l2asthmae l2physact   /* arthritis https://www.nhs.uk/conditions/osteoporosis/causes/ */


*** Sight and Hearing
global allvars_sight            $dvars $lvars_age l2catracte l2logbmi_l30 l2logbmi_30p l2hchole l2hibpe `lvars_alcfreq' l2smoken l2smokev
global allvars_hearing          $dvars $lvars_age l2logbmi_l30 l2logbmi_30p l2smoken l2smokev l2hibpe l2diabe l2stroke l2sight

*** Smoking 
global allvars_smoke_start      $dvars $lvars_age l2logbmi_l30 l2logbmi_30p
global allvars_smoke_stop       $dvars $lvars_age l2logbmi_l30 l2logbmi_30p
global allvars_smokef           $dvars $lvars_age l2logbmi_l30 l2logbmi_30p


*** Drinking
/* https://alcohol.addictionblog.org/alcoholism-causes-and-risk-factors/ */
global allvars_drink            $dvars $lvars_age l2logbmi_l30 l2logbmi_30p l2physact `lvars_lnly'
global allvars_alcfreq          $dvars $lvars_age l2logbmi_l30 l2logbmi_30p l2physact `lvars_lnly'


*** Logbmi & other health
global allvars_logbmi           $dvars $lvars_age l2logbmi_l30 l2logbmi_30p l2physact


*** Economic vars (atotb & itot)
global allvars_logatotb            $dvars $lvars_age `lvars_workstat' `lvars_funclimit' `lvars_smoke' l2drink /*`lvars_mstat'*/
global allvars_logitot             $dvars $lvars_age `lvars_workstat' `lvars_funclimit' `lvars_smoke' l2drink /*`lvars_mstat'*/

*** Cognitive Score ***
global allvars_tr20             $dvars $lvars_age l2hearing l2sight `lvars_funclimit' l2cesd l2smoken l2employed l2retired
global allvars_verbf            $dvars $lvars_age l2hearing l2sight `lvars_funclimit' l2cesd l2smoken l2employed l2retired
global allvars_orient           $dvars $lvars_age l2hearing l2sight `lvars_funclimit' l2cesd l2smoken l2employed l2retired


*** Disabilities
* 16/6/21 - Now includes l2alzhe
global allvars_adlstat          $dvars $lvars_age l2logbmi_l30 l2logbmi_30p l2smokev l2stroke l2demene l2osteoe l2catracte `lvars_sociso' `lvars_lnly' l2cesd l2married l2widowed `lvars_alcfreq' l2tr20 l2verbf l2orient
global allvars_iadlstat         $dvars $lvars_age l2logbmi_l30 l2logbmi_30p l2smokev l2stroke l2demene l2osteoe l2catracte `lvars_sociso' `lvars_lnly' l2cesd l2married l2widowed `lvars_alcfreq' l2tr20 l2verbf l2orient
*global allvars_adlstat          $dvars $lvars_age `lvars_lnly' `lvars_sociso' l2physact 
*global allvars_iadlstat         $dvars $lvars_age `lvars_lnly' `lvars_sociso' l2physact

*** Workstat
global allvars_workstat         $dvars $lvars_age `lvars_funclimit'

*** Exercise
*global allvars_exstat           $dvars $lvars_age `lvars_funclimit' l2physact
global allvars_physact          $dvars $lvars_age `lvars_funclimit' `lvars_mstat'

*** Loneliness
* https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4225959/
global allvars_lnly             $dvars $lvars_age `lvars_mstat' `lvars_workstat' l2physact l2anyadl l2anyiadl l2srh5 l2logatotb l2hhres l2socyr l2gcareinhh1w childless l2cesd
*** Social Isolation
global allvars_sociso           $dvars $lvars_age `lvars_mstat' l2physact l2srh5 l2logatotb l2hhres l2gcareinhh1w childless l2cesd l2sight l2hearing l2ahown

*** Marriage Status
global allvars_mstat            $dvars $lvars_age `lvars_workstat' l2logbmi_l30 l2logbmi_30p
 