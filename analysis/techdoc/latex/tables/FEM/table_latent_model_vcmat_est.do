clear all
set more off
include ../../../../../fem_env.do

tempfile varlabs
insheet using initcond_labels.csv, comma names
rename name _rowname
li
save `varlabs'

use $indata/incoming_vcmatrix, clear
li
gen row_order = _n
merge 1:1 _rowname using `varlabs'
drop if _merge==2
drop _merge
replace _rowname=varlab if varlab!=""
drop varlab
sort row_order
drop row_order
li

* format for display in a table
unab varnames : *
foreach v in `varnames' {
	if("`v'" != "_rowname") {
		format `v' %6.3f
	}
}

#d ;
listtex using latent_model_vcmat_est.tex, replace rstyle(tabular) 
head(
"\begin{tabular}{l*{20}{r}}"
" &              &         &          &            &                &        &         & Functional & Functional &         &         &      &           &         &            &         &        &        & Early      & Normal\\"
" &              & Heart   &          & Any health & Self-reported  & Weight & Smoking & status     & status     &         & Nonzero &      & Quarters  & IHT(HH  & IHT(earned & Log(DC  & Any DC & Any DB & retirement & retirement \\"
" & Hypertension & disease & Diabetes & insurance  & health         & status & status  & (ADL)      & (IADL)     & Working & wealth  & AIME & worked    & wealth) & income)    & wealth) & plan   & plan   & age        & age\\"
)
foot("\end{tabular}")
;
#d cr

*outsheet using latent_model_vcmat_est.csv, comma replace
*export excel using techappendix.xls, sheetreplace sheet("Table 18") firstrow(varlabels)

exit, STATA clear
