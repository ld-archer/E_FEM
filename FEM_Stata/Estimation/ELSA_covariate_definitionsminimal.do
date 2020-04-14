

*** DEPENDANT VARIABLES
global bin_hlth cancre diabe hearte hibpe lunge stroke arthre psyche died asthmae parkine drink smoke_start smoke_stop smoken smokev
global bin_econ work hlthlm retemp
global ols logbmi retage ipubpen atotf itearn smokef
global order adlstat iadlstat drinkd drinkd_stat vgactx_e mdactx_e ltactx_e smkstat


*** DEMOGRAPHICS
global dvars male white hsless college


*** Values of health variables at t-1
global lvars_hlth l2hearte l2stroke l2cancre l2hibpe l2diabe l2lunge l2iadl1 l2iadl2p l2adl1 l2adl2 l2adl3p l2smoken
*** Values of econ variables at t-1
global lvars_econ l2work l2hlthlm l2retemp

*** BMI variables
global bmivars l2logbmi

*** FOR MORTALITY
global allvars_died $dvars l2age65l l2age6574 l2age75p $lvars_hlth

*** FOR CHRONIC	CONDITIONS AND ORDINAL OUTCOMES
global allvars_hlth $dvars l2age65l l2age6574 l2age75p $lvars_hlth $bmivars
*** FOR ECONOMIC OUTCOMES
global allvars_econ $dvars l2age65l l2age6574 l2age75p $lvars_hlth $lvars_econ


local age_var age


** Sample selection macros
foreach v in $bin_econ $order drink smoken smokev {
	local select_`v' !died
}

drink smoken smokev

foreach v in cancre diabe hearte hibpe lunge stroke arthre psyche asthmae parkine anyadl anyiadl {
	local select_`v' !l2`v' & !died
}

/*
drink smoke_start smoke_stop smoken smokev
work hlthlm retemp
logbmi retage ipubpen atotf itearn smokef
adlstat iadlstat drinkd drinkd_stat vgactx_e mdactx_e ltactx_e smkstat
*/

local select_died !l2died
local select_

* Selection criteria for models with specific requirements
local select_smoke_start !died & l2smoken == 0
local select_smoke_stop !died & l2smoken == 1
local select_smokef !died & smoken==1
local select_hlthlm !died & wave > 1
local select_ipubpen !died & work == 0
local select_retage !died & retemp == 1
local select_drinkd !died & drink == 1 & wave > 1
local select_drinkd_stat !died & drink == 1 & wave > 1
local select_logbmi !died & (wave==2 | wave==4 | wave==6 | wave==8) /* Only estimate bmi model using waves 2,4,6 as other waves are imputed */











































