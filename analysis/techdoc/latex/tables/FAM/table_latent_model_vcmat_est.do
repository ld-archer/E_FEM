clear all
set more off
include ../../../../../fem_env.do

tempfile varlabs
insheet using initcond_labels.csv, comma names
rename name _rowname
li
save `varlabs'

use $outdata/psid_incoming_vcmatrix, clear
li
gen row_order = _n
merge 1:1 _rowname using `varlabs'
drop if _merge==2
drop _merge
replace _rowname=varlab if varlab!=""

replace _rowname = "Education level" if varlab=="" & _rowname == "educlvl"
replace _rowname = "Partnered" if varlab=="" & _rowname == "partnered"
replace _rowname = "Partnership type" if varlab=="" & _rowname == "partnertype"
replace _rowname = "Weight status" if varlab=="" & _rowname == "wtstate"
replace _rowname = "Smoking status" if varlab=="" & _rowname == "smkstat"
replace _rowname = "Hypertension" if varlab=="" & _rowname == "hibpe"
replace _rowname = "In labor force" if varlab=="" & _rowname == "inlaborforce"
replace _rowname = "Number of biological children" if varlab=="" & _rowname == "numbiokids"

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
"\begin{tabular}{l*{9}{r}}"
" &           &           &             &        &         &              &          & Number of  \\"
" & Education &           & Partnership & Weight & Smoking &              & In labor & biological \\"
" & level     & Partnered & type        & status & status  & Hypertension & force    & children   \\"
)
foot("\end{tabular}")
;
#d cr

*outsheet using latent_model_vcmat_est.csv, comma replace
*export excel using techappendix.xls, sheetreplace sheet("Table 18") firstrow(varlabels)

exit, STATA clear
