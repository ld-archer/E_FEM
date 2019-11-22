clear all
set more off
include ../../../../../fem_env.do

foreach var in nra {
	tempfile `var'
	infile using ../shared/`var'.dct, clear
	save "``var''"
}


use "`nra'", clear

* refer to the FEM tech doc to see how this loop is used for additional variables
*foreach var in drc {
*merge 1:1 yob using "``var''", nogenerate
*}

order yob nra 
drop if missing(yob)
drop if  yob < 1940 | yob > 1985
sort yob

*save time_series_by_yob.dta, replace

#d ;
listtex using time_series_by_yob.tex, replace rstyle(tabular) 
head(
"\begin{tabular}{l*{1}{r}}"
"            &                \\"
"            & Normal         \\"
" Birth year & Retirement Age \\"
\hline
)
foot("\hline\end{tabular}")
;
#d cr

exit, STATA clear

