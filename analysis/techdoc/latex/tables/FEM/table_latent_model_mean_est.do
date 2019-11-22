clear all
set more off
include ../../../../../fem_env.do

use $indata/incoming_means.dta, clear
desc
local num = r(N)
mkmat black-constant, mat(omega) rownames(_rowname)
local rowname: rownames omega

xpose, clear varname

ren (_varname v1-v`num') (covariate `rowname')

drop if covariate=="order" | covariate=="var" | covariate=="_rowname"

* format for display in a table
foreach v in `rowname' {
	format `v' %6.2f
}

order covariate, first
li
outsheet * using latent_model_mean_est.csv, comma replace

** merge variable labels onto rows and columns
** \todo put this code into an ado file since it gets used for other tables
* get labels for variables
tempfile varlabs
local fname = "$outdata/hrs$firstwave$lastwave" + "_transition.dta"
use `fname', clear
descsave, list(name varlab) saving(`varlabs', replace)
use `varlabs', clear
keep name varlab
* escape out underscore and create math environment for latex compatibility
replace varlab = regexr(varlab,"_","\_")
replace varlab = regexr(varlab,"<=","$<=$")
replace varlab = regexr(varlab," > "," $>$ ")
save `varlabs', replace

clear
insheet using latent_model_mean_est.csv, comma nonames
gen row_order = _n
li

* replace first column variables names with their labels
desc
li
rename v1 name
merge 1:1 name using `varlabs'
drop if _merge==2
drop _merge
replace name = varlab if varlab!=""
drop varlab
rename name v1

sort row_order
drop row_order

drop if _n==1
desc
li

#d ;
listtex using latent_model_mean_est.tex, replace rstyle(tabular) 
head(
"\begin{tabular}{l*{20}{r}}"
" &  &       &  &            &                                      &        &         & Functional & Functional &          &         &           &               &         &            &         &        &        & Early      & Normal\\"
" &  & Heart &  & Any health & Self-reported                        & Weight & Smoking & status     & status     &          & Nonzero &           & Quarters      & IHT(HH  & IHT(earned & Log(DC  & Any DC & Any DB & retirement & retirement \\"
"Covariate & Hypertension & disease & Diabetes & insurance & health & status & status  & (ADL)      & (IADL)      & Working & wealth  & AIME      & worked        & wealth) & income)    & wealth) & plan   & plan   & age        & age\\"
)
foot("\end{tabular}")
;
#d cr

exit, STATA clear
