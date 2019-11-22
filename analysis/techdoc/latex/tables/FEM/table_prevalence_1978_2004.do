clear all
set more off
include ../../../../../fem_env.do

use $outdata/obs80_adj_table.dta

xpose, clear varname
order _varname v1 v2 v3
drop if _varname == "year"
rename _varname vardesc
replace vardesc = "$30\leq$ BMI $<35$ ($\mathrm{kg}/\mathrm{m}^2$)" if vardesc == "wtstate3"
replace vardesc = "$35\leq$ BMI $<40$ ($\mathrm{kg}/\mathrm{m}^2$)" if vardesc == "wtstate4"
replace vardesc = "BMI $>=40$ ($\mathrm{kg}/\mathrm{m}^2$)" if vardesc == "wtstate5"
replace vardesc = "Hypertension" if vardesc == "hibpe"
replace vardesc = "Diabetes" if vardesc == "diabe"
replace vardesc = "Currently smoking" if vardesc == "smoken"

format v1 v2 v3 %6.3f

#d ;
listtex using prevalence_1978_2004.tex, replace rstyle(tabular)
head(
"\begin{tabular}{l rrr}"
"& \multicolumn{3}{c}{Prevalence}\\"
"\hhline{~---}"
"          &      &      & Annual rate of change to   \\"
"Condition & 1978 & 2004 & get 1978 prevalence by 2030\\"
"\hline"
)
foot("\hline\end{tabular}")
;
#d cr

