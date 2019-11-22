clear all
set more off
include ../../../../../fem_env.do

foreach var in nwi interest_rate cola cpi sga medgrowth {
	tempfile `var'
	infile using ../shared/`var'.dct, clear
	save "``var''"
}

use "`medgrowth'", clear
foreach var in nwi interest_rate cola cpi sga {
merge 1:1 year using "``var''", nogenerate
}

order year nwi interest_rate cola cpi sga medgrowth
drop if missing(year)
drop if year < 2004 | year > 2050
sort year

*save time_series_by_year.dta, replace

#d ;
listtex using time_series_by_year.tex, replace rstyle(tabular) 
head(
"\begin{tabular}{l*{6}{r}}"
"               &            &                    &         &               &                  & Y-o-Y excess       \\"
"               & National   & Real interest      &         & Consumer      & Substantial      & real growth in     \\"
" Calendar year & Wage Index & rate on wealth     & COLA    & Price Index   & Gainful Activity & medical costs      \\"
\hline
)
foot("\hline\end{tabular}")
;
#d cr

exit, STATA clear
