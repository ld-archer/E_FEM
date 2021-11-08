

*** DEPENDANT VARIABLES
global bin_hlth cancre diabe hearte hibpe lunge stroke arthre psyche died asthmae parkine drink smoke_start smoke_stop hchole hipe alzhe demene problem_drinker heavy_smoker
global bin_econ
global ols logbmi atotb itot alcbase
global order adlstat iadlstat exstat srh alcstat
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
    "Problem Drinker (binge/too frequent)"
    "Heavy Smoker (>10 cigs/day)"
;
global bin_econ_names
;
global ols_names
    "Log(BMI)"
    "Total Family Wealth"
    "Total Couple Level Income"
    "Total alcohol consumption in past week (units)"
;
global order_names 
    "ADL status"
    "IADL status"
    "Exercise status"
    "Self-Reported Health Status"
    "Alcohol Consumption Status"
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
