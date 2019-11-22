clear all
set more off
include ../../../../../fem_env.do

local datain : env DATAIN
use `datain'

* get variable labels for later merging
preserve
tempfile varlabs
descsave, list(name varlab) saving(`varlabs', replace)
use `varlabs', clear
rename name variable
* escape out underscore and create math environment for latex compatibility
replace varlab = regexr(varlab,"_","\_")
replace varlab = regexr(varlab,"<=","$<=$")
replace varlab = regexr(varlab," > "," $>$ ")
keep variable varlab
save `varlabs', replace
restore

tab nra, gen(fnra)

local varsout age black hispan hsless college male smokev fraime frq fanydb fnra3 fnra4 fnra5 anydc logdcwlthx

** Handle the restricted variables. For now, explicitly create as missing to point out that this is
** unrestricted data.
foreach v in any frq fraime {
  capture confirm variable `v'
  if _rc {
    ** Variable does not exist
    gen `v' = .
  }
}

logout, save(table8) dta replace: summ `varsout'

* the logout saves variable labels as the first observation
use table8, clear
rowrename 1
drop if _n==1
drop v2

* merge in variable lables instead of using variable names
rename v1 variable
gen order = _n
merge 1:1 variable using `varlabs'
drop if _merge==2
drop _merge
replace variable = varlab if varlab != ""
sort order
drop varlab order

#d ;
listtex using controlvar_descs.tex, replace rstyle(tabular) 
head(
"\begin{tabular}{lrrrr}"
" & \multicolumn{4}{c}{Unweighted Statistics} \\"
"\hhline{~----}"
" &  & Standard &  &  \\"
"Control variable & Mean & deviation & Minimum & Maximum\\"
"\hline"
)
foot("\end{tabular}")
;
#d cr

*export excel using techappendix.xls, sheetreplace sheet("Table 8") firstrow(varlabels)

exit, STATA clear
