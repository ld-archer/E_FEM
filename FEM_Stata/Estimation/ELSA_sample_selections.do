*** Sample Selection Macros

* Selection criteria for models that only rely on not being dead
* These are all PREVALENCE models - estimate for anyone who has not died
foreach v in adlstat iadlstat work retemp atotf drink exstat atotb /*smkstat vgactx_e mdactx_e ltactx_e*/ {
    local select_`v' !died 
}

* Selection criteria for models that only rely on lag value and not being dead
* These are all INCIDENCE models - estimate for people who have not previously got the disease and also not dead
foreach v in cancre diabe hearte hibpe lunge stroke arthre psyche asthmae parkine {
    local select_`v' !l2`v' & !died 
}

local select_died !l2died & wave > 1 & wave <= 6 

* Selection criteria for models with specific requirements
local select_smoke_start !died & l2smoken == 0  /*INCIDENCE*/
local select_smoke_stop !died & l2smoken == 1  /*INCIDENCE*/
local select_srh !died & wave != 3
*local select_smokef !died & smoken==1
local select_hlthlm !died & wave > 1 & retemp == 0  /*PREVALENCE*/
local select_ipubpen !died & retemp == 1 
local select_retage !died /*INCIDENCE*/
local select_drinkd !died & drink == 1 & wave > 1
local select_drinkd_stat !died & drink == 1 & wave > 1
*local select_drinkwn !died & drink == 1 & wave > 3 /* Estimate model if not dead, is a drinker and wave 4 or higher */
local select_logbmi !died & (wave==2 | wave==4 | wave==6 | wave==8) /* Only estimate bmi model using waves 2,4,6 as other waves are imputed */
local select_hchole !died & l2hchole == 0 & wave > 1 /*INCIDENCE*/
local select_hipe !died & l2hipe == 0 & age > 59 /*INCIDENCE  Hip Fracture question only asked if respondent is aged 60+ */
local select_itearn !died & work == 1 & retemp == 0 /*PREVALENCE  Only estimate individual earnings if r in work and not retired */

* FOR CROSS VALIDATION 2 - Restrict all models to waves 1-4
if "`defmod'" == "CV2" {
    local CV2 & wave < 5
}
* varlist holds all that we estimate transition models for
local varlist adlstat iadlstat work retemp atotf drink exstat cancre diabe hearte hibpe lunge stroke arthre psyche asthmae parkine died smoke_start smoke_stop hlthlm ipubpen retage drinkd drinkd_stat logbmi hchole hipe itearn

foreach v in `varlist' {
    local select_`v' `select_`v'' `CV2'
}
