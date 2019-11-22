clear all
set more off
include ../../../../../fem_env.do

use $outdata/psid_incoming_means.dta, clear
mkmat black-constant, mat(omega) rownames(_rowname)
local rowname: rownames omega

xpose, clear varname
ren (_varname v1-v8) (covariate `rowname')

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
local fname = "$outdata/psid_transition.dta"
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

* Labeling a stray variable
replace name = "Age 25 or 26" if varlab=="" & name == "age2526"
replace name = "Constant" if varlab=="" & name == "constant"

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
"\begin{tabular}{l*{9}{r}}"
"          &           &           &             &        &         &              &          & Number of  \\"
"          & Education &           & Partnership & Weight & Smoking &              & In labor & biological \\"
"Covariate & level     & Partnered & type        & status & status  & Hypertension & force    & children   \\"
)
foot("\end{tabular}")
;
#d cr

exit, STATA clear
