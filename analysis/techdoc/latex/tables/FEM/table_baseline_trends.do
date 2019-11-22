clear all
set more off
include ../../../../../fem_env.do

use $outdata/trend_all_status_quo.dta

keep if inlist(year, 2004, 2010, 2020, 2030, 2040, 2050)

sort year

local outvars phibpe phearte pdiabe pwtstate5 psmkstat3 panydb panydc

format `outvars' %9.2f

local outvars year `outvars'

#d ;
listtex `outvars' using baseline_trends.tex, replace rstyle(tabular) 
head(
"\begin{tabular}{|l|rrr|rr|rr|}"
"\multicolumn{1}{c}{} & \multicolumn{7}{c}{Ratio of future prevalence to 2004 prevalence for 51-52 year olds}\\"
"\hhline{~-------}"
"\multicolumn{1}{c|}{}&\multicolumn{3}{c|}{Binary outcomes} & \multicolumn{2}{c|}{Ordered outcomes (highest category)} & \multicolumn{2}{c|}{Censored discrete outcomes}\\"
"\hline"
" & & & & BMI Status & Smoking Status  & & \\"
"Year & Hypertension & Heart Disease & Diabetes & (BMI$\ge$40) & (smoking now) & Any DB Plan & Any DC Plan\\"
"\hline"
)
foot("\hline""\end{tabular}")
;
#d cr
exit, STATA clear
