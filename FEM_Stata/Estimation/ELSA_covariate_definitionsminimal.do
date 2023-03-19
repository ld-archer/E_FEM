

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


*** DEMOGRAPHICS
global dvars male /*white hsless college*/
*** Lagged Age splines
global lvars_age l2age65l l2age6574 l2age75p


*** Now specify the transition models ***

foreach v of varlist $bin_hlth $bin_econ $ols $count $order $unorder {
	global allvars_`v' $dvars $lvars_age
}
