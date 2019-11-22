clear all
set more off
include ../../../../../fem_env.do

foreach var in nra drc {
	tempfile `var'
	infile using ../shared/`var'.dct, clear
	save "``var''"
}

use "`nra'", clear
foreach var in drc {
merge 1:1 yob using "``var''", nogenerate
}

order yob nra drc
drop if missing(yob)
drop if yob > 1960
sort yob

*save time_series_by_yob.dta, replace

#d ;
listtex using time_series_by_yob.tex, replace rstyle(tabular) 
head(
"\begin{tabular}{l*{2}{r}}"
"            &                &                    \\"
"            & Normal         & Delayed            \\"
" Birth year & Retirement Age & Retirement Credit  \\"
\hline
)
foot("\hline\end{tabular}")
;
#d cr

exit, STATA clear

