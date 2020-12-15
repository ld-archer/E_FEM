

*** DEPENDANT VARIABLES
global bin_hlth cancre diabe hearte hibpe lunge stroke arthre psyche died asthmae parkine drink smoke_start smoke_stop hchole hipe alzhe demene heavy_drinker freq_drinker
global bin_econ hlthlm
global ols logbmi logatotb logitot
global order adlstat iadlstat exstat srh smkint lnly
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
    "Heavy Drinker (>14 units/week)"
    "Frequent Drinker (>5 days/week)"
;
global bin_econ_names
    "Health Limits Work"
;
global ols_names
    "Log(BMI)"
    "Log(Total Family Wealth)"
    "Log(Total Family Income)"
;
global order_names 
    "ADL status"
    "IADL status"
    "Exercise status"
    "Self-Reported Health Status"
    "Smoking Intensity Status"
    "Loneliness Status"
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

foreach v of varlist $bin_hlth $bin_econ $ols $order $unorder {
	global allvars_`v' $dvars $lvars_age
}
