

*** DEPENDANT VARIABLES
global bin_hlth cancre diabe hearte hibpe lunge stroke arthre psyche died asthmae parkine drink smoke_start smoke_stop
global bin_econ work hlthlm retemp
global ols logbmi retage ipubpen atotf itearn smokef
global order adlstat iadlstat drinkd drinkd_stat vgactx_e mdactx_e ltactx_e smkstat

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
;
global bin_econ_names
    "R working for pay"
    "Health Limits Work"
    "Whether retired at time of interview"
;
global ols_names
    "Log(BMI)"
    "Retirement Age"
    "Public Pension Income (All types)"
    "Net Value of Non-housing Financial Wealth"
    "Individual Employment Earnings (annual, after tax)"
    "Average # cigs/day"
;
global order_names 
    "ADL status"
    "IADL status"
    "# days per week R drinks alcohol"
    "Days/week drinking status"
    "# days/week doing vigorous exercise"
    "# days/week doing moderate exercise"
    "# days/week doing light exercise"
    "Smoking status"
;
#d cr


*** DEMOGRAPHICS
global dvars male white hsless college
*** Lagged Age splines
global lvars_age l2age65l l2age6574 l2age75p


*** Now specify the transition models ***

foreach v of varlist $bin_hlth $bin_econ $ols $order {
	global allvars_`v' $dvars $lvars_age
}
