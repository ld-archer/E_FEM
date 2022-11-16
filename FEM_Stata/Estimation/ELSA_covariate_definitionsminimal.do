

*** DEPENDANT VARIABLES
global bin_hlth cancre diabe hearte hibpe lunge stroke arthre psyche died asthmae parkine drink smoke_start smoke_stop hchole hipe alzhe demene angine hrtatte conhrtfe hrtmre hrtrhme catracte osteoe
global bin_econ
global ols logbmi atotb itot smokef
global order adlstat iadlstat exstat srh lnly alcfreq sociso
global unorder mstat workstat

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
    "Exercise status"
    "Self-Reported Health Status"
    "Rounded categorical revised UCLA loneliness score [1-3]"
    "Alcohol consumption frequency [1-8]"
;
global unorder_names
    "Marriage Status"
    "Work Status"
;
#d cr


*** DEMOGRAPHICS
global dvars male /*white hsless college*/
*** Lagged Age splines
global lvars_age l2age65l l2age6574 l2age75p


*** Now specify the transition models ***

foreach v of varlist $bin_hlth $bin_econ $ols $count $order $unorder {
	global allvars_`v' $dvars $lvars_age
}
