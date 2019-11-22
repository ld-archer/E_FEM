/* Table of trends for replinishing cohorts */


clear all
set more off
include ../../../../../fem_env.do

use $outdata/psid_trend_default.dta, replace

keep if year <= 2035
keep year pwtstate2 pwtstate3 pwtstate4 pwtstate5 pstudent pworking peduc1 peduc2 peduc3 peduc4 pkids1 pkids2 pkids3 pkids4 pkids5 psingle pcohab pmarried ppartnered ppartnertype phibpe psmkstat1 psmkstat2 psmkstat3


label var year "Year"
label var pwtstate2 "Overweight"
label var pwtstate3 "Obese 1"
label var pwtstate4 "Obese 2"
label var pwtstate5 "Obese 3"
label var peduc1 "Less than HS"
label var peduc2 "HS Graduate"
label var peduc3 "College Graduate"
label var peduc4 "Graduate School"
label var pkids1 "No children"
label var pkids2 "One child"
label var pkids3 "Two children"
label var pkids4 "Three children"
label var pkids5 "Four or more children"

label var ppartnered "Partnered" 
label var ppartnertype "Married if partnered"

label var phibpe "Hypertension"
label var psmkstat1 "Never smoked"
label var psmkstat2 "Former smoker"
label var psmkstat3 "Current smoker"


local hlth_vars phibpe pwtstate2 pwtstate3 pwtstate4 pwtstate5 psmkstat1 psmkstat2 psmkstat3
local educ_vars peduc1 peduc2 peduc3 peduc4 
local soc_vars pkids1 pkids2 pkids3 pkids4 pkids5 ppartnered ppartnertype


format `hlth_vars' `educ_vars' `soc_vars' %10.2f

preserve
keep year `hlth_vars'


#d ;
listtab using new_cohort_trends_health.tex, replace rstyle(tabular) 
head(
"\begin{tabular}{ccccccccc}"
"Year & Hypertension & Overweight & Obese 1 & Obese 2 & Obese 3 & Never Smoked & Former Smoker & Current Smoker \\"
"\hline"
)
foot("\hline""\end{tabular}")
;
#d cr


restore
preserve
keep year `educ_vars'

#d ;
listtab using new_cohort_trends_educ.tex, replace rstyle(tabular) 
head(
"\begin{tabular}{ccccc}"
"Year & Less than HS & HS Grad & College Grad & Graduate School \\"
"\hline"
)
foot("\hline""\end{tabular}")
;
#d cr



restore
keep year `soc_vars'

#d ;
listtab using new_cohort_trends_social.tex, replace rstyle(tabular) 
head(
"\begin{tabular}{cccccccc}"
"Year & No Children & One Child & Two Children & Three Chidren & Four or More Children & Partnered & Married \\"
"\hline"
)
foot("\hline""\end{tabular}")
;
#d cr




capture log close

