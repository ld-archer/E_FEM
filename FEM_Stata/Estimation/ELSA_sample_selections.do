*** Sample Selection Macros
* Selection criteria for models that only rely on not being dead
foreach v in adlstat iadlstat work retemp itearn atotf drink vgactx_e mdactx_e ltactx_e exstat /*smkstat*/ {
    local select_`v' !died
}

* Selection criteria for models that only rely on lag value and not being dead
foreach v in cancre diabe hearte hibpe lunge stroke arthre psyche asthmae parkine anyadl anyiadl {
    local select_`v' !l2`v' & !died
}

local select_died !l2died & wave > 1 & wave < 6

* Selection criteria for models with specific requirements
local select_smoke_start !died & l2smoken == 0
local select_smoke_stop !died & l2smoken == 1
local select_smokef !died & smoken==1
local select_hlthlm !died & wave > 1
local select_ipubpen !died & work == 0
local select_retage !died & retemp == 1
local select_drinkd !died & drink == 1 & wave > 1
local select_drinkd_stat !died & drink == 1 & wave > 1
*local select_drinkwn !died & drink == 1 & wave > 3 /* Estimate model if not dead, is a drinker and wave 4 or higher */
local select_logbmi !died & (wave==2 | wave==4 | wave==6 | wave==8) /* Only estimate bmi model using waves 2,4,6 as other waves are imputed */
