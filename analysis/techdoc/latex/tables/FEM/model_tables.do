clear all
set more off
include ../../../../../fem_env.do

set matsize 500

local varsout : env MODELS
local table : env TABLE

* set the width of the leftmost column here
local lwid 1in
* set the width of the model estimates columns here
local mwid 0.6in


log using model_tables_`table'.log, replace

/************ GET VARIABLE LABELS (GIVE PRECEDENCE TO HRS, THEN MCBS, THEN MEPS ************/
tempfile varlabs varlabs_tmp
use $outdata/hrs19_transition
descsave, saving(`varlabs', replace)
use `varlabs', clear
gen labpri=0
save `varlabs', replace

use $dua_mcbs_dir/mcbs_cost_est.dta, clear
descsave, saving(`varlabs_tmp', replace)
use `varlabs_tmp', clear
gen labpri=1
append using `varlabs'
bys name: gen nlab = _N
drop if nlab > 1 & labpri==1
drop nlab
replace labpri=0
save `varlabs', replace

use $dua_mcbs_dir/mcbs_enroll_est.dta, clear
descsave, saving(`varlabs_tmp', replace)
use `varlabs_tmp', clear
gen labpri=1
append using `varlabs'
bys name: gen nlab = _N
drop if nlab > 1 & labpri==1
drop nlab
replace labpri=0
save `varlabs', replace

use $dua_mcbs_dir/mcbs_initenroll_est.dta, clear
descsave, saving(`varlabs_tmp', replace)
use `varlabs_tmp', clear
gen labpri=1
append using `varlabs'
bys name: gen nlab = _N
drop if nlab > 1 & labpri==1
drop nlab
replace labpri=0
save `varlabs', replace

use $dua_mcbs_dir/mcbs_ptd_est.dta, clear
descsave, saving(`varlabs_tmp', replace)
use `varlabs_tmp', clear
gen labpri=1
append using `varlabs'
bys name: gen nlab = _N
drop if nlab > 1 & labpri==1
drop nlab
replace labpri=0
save `varlabs', replace

use $outdata/MEPS_cost_est.dta, clear
descsave, saving(`varlabs_tmp', replace)
use `varlabs_tmp', clear
gen labpri=1
append using `varlabs'
bys name: gen nlab = _N
drop if nlab > 1 & labpri==1


keep name varlab
/*
* escape out underscore for latex compatibility
replace varlab = regexr(varlab,"_","\_")
replace varlab = regexr(varlab,"<=","$<=$")
replace varlab = regexr(varlab," > "," $>$ ")
*/
save `varlabs', replace
/*********************************************/

clear
foreach v of local varsout {
  est use $local_path/Estimates/`v'.ster
  est store `v'
}

esttab `varsout' using `table'.csv, csv replace label noobs nostar b(%12.4f) t(%12.2f)

clear
insheet using `table'.csv, comma
li
preserve
tempfile varlabrow
keep if _n==2
unab varnames : *
di "`varnames'"
foreach v in `varnames' {
	di "merging in a label for `v' : "
	li `v'
	rename `v' name
	merge 1:1 name using `varlabs'
	drop if _merge==2
	*gen `v' = "\parbox[b]{`mwid'}{\hfill " + varlab + "}" if varlab!=""
	gen `v' = varlab if varlab!=""
	replace `v' = name if varlab==""
	keep `varnames'
	save `varlabrow', replace
}
gen order=0
replace v1 = "Covariate"
rename v1 name
save `varlabrow', replace
li
restore

rowrename 2
li
drop in 1
drop if v1=="main"
gen order = _n
rename v1 name
merge m:1 name using `varlabs'
drop if _merge==2
drop _merge
*drop if name=="t statistics in parentheses"
replace name = varlab if varlab != ""
* put variable labels on two rows (estimate + t-stat)
* replace name = "\multirow{2}{*}{\parbox[t]{`lwid'}{" + name + "}}" if name!=""
unab varnames : *
sort order
/*
foreach v in `varnames' {
	if !("`v'" == "name" | "`v'" == "order") {
		di "`v'"
		replace `v' = "\parbox[t]{`mwid'}{" +`v' + "\\" + `v'[_n+1] + "}" if `v' != ""
		*replace `v' = "\parbox[t]{`mwid'}{" +`v' + "\\" + `v'[_n+1] + "}" 
	}
}
drop if name==""
*/

append using `varlabrow'
sort order
keep name v*
drop varlab


* get number of columns required for estimates
local colct: word count `varnames' 
local modct = `colct' - 1
/*
* NOTE: this outputs an incomplete table -- when the output is included in other
* latex code, you will need to add "\end{longtable}" at the end.  This allows 
* you to add a customized caption and label for the table
#d ;
listtex using `table'.tex, replace rstyle(tabular) 
head(
"\begin{longtable}{p{`lwid'}*{`modct'}{r}}"
"\endfirsthead"
"\multicolumn{`colct'}{c}{(continued from previous page)}\endhead"
"\multicolumn{`colct'}{c}{(continued on next page)}\endfoot"
"\endlastfoot"
)
;
#d cr
*/
export excel using FEM_estimates_table.xls, sheetreplace sheet("`table'")

exit, STATA clear
