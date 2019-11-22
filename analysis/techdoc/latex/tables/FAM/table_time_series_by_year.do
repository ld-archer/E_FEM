clear all
set more off
include ../../../../../fem_env.do

foreach var in interest_rate medgrowth {
	tempfile `var'
	infile using ../shared/`var'.dct, clear
	save "``var''"
}

use "`medgrowth'", clear
foreach var in interest_rate {
	merge 1:1 year using "``var''", nogenerate
}

order year interest_rate medgrowth
drop if missing(year)
drop if year < 2009 | year > 2050
sort year

*save time_series_by_year.dta, replace

#d ;
listtex using time_series_by_year.tex, replace rstyle(tabular) 
head(
"\begin{tabular}{l*{6}{r}}"
"               &                    & Y-o-Y excess       \\"
"               & Real interest      & real growth in     \\"
" Calendar year & rate on wealth     & medical costs      \\"
\hline
)
foot("\hline\end{tabular}")
;
#d cr

exit, STATA clear
