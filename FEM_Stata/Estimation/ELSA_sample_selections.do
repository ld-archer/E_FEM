*** Sample Selection Macros

* Selection criteria for models that only rely on not being dead
* These are all PREVALENCE models - estimate for anyone who has not died
foreach v in adlstat iadlstat drink mstat workstat logatotb logitot sociso physact tr20 orient {
    local select_`v' !died 
}

* Selection criteria for models that only rely on lag value and not being dead
* These are all INCIDENCE models - estimate for people who have not previously got the var and also not dead
foreach v in cancre diabe hearte hibpe lunge stroke arthre psyche asthmae parkine demene angine hrtatte conhrtfe hrtmre hrtrhme catracte osteoe {
    local select_`v' !l2`v' & !died 
}

local select_died !l2died & wave > 1 & wave <= 6 

* Selection criteria for models with specific requirements
local select_smoke_start !died & l2smoken == 0  /*INCIDENCE*/
local select_smoke_stop !died & l2smoken == 1  /*INCIDENCE*/
local select_srh !died & wave != 3
local select_smokef !died & smoken == 1
local select_logbmi !died & (wave==2 | wave==4 | wave==6 | wave==8 | wave==9) /* Only estimate bmi model using waves 2,4,6,8,9 as other waves are imputed */
local select_hchole !died & l2hchole == 0 & wave > 1 /*INCIDENCE*/
local select_hipe !died & l2hipe == 0 & age > 59 /*INCIDENCE  Hip Fracture question only asked if respondent is aged 60+ */
local select_lnly !died & wave > 1 /* Loneliness questions only asked from wave 2 onwards */
*local select_lnlys3 !died & wave > 1 /* Loneliness questions only asked from wave 2 onwards */
local select_alcfreq !died & drink == 1 /* Only calculate alcfreq if drink == 1*/
local select_verbf !died & wave != 6 /* not available in wave 6*/

* FOR CROSS VALIDATION 2 - Restrict all models to waves 1-4
if "`defmod'" == "CV2" {
    local CV2 & wave < 5
}
* varlist holds all that we estimate transition models for
local varlist adlstat iadlstat drink exstat cancre diabe ///
                hearte hibpe lunge stroke arthre psyche asthmae parkine died ///
                smoke_start smoke_stop alcfreq ///
                logbmi hchole hipe mstat lnly demene ///
                workstat logatotb logitot smokef ///
                angine hrtatte tr20 verbf orient ///
                conhrtfe hrtmre hrtrhme catracte osteoe lnly sociso physact

foreach v in `varlist' {
    local select_`v' `select_`v'' `CV2'
}
