
/** \file

Add random variables to host dataset.

\date Mar 2008
**4/2015 Change host data to 2010

*/
include common.do
local expand : env EXPAND
local bsamp : env BREP

* Using parameter estimates from simul2004, but now applying them to the unrestricted all2004_pop_adjusted.dta file to restore our sample size when using the unrestricted data.
if missing("`bsamp'") {
  local outdir $outdata
}
else {
  local outdir $outdata/input_rep`bsamp'
}

use `outdir'/all2010_pop_adjusted.dta, clear

* Merge on the jointly imputed values
merge 1:1 hhidpn wave using `outdir'/imputed_ssa_ret.dta 
drop _merge
merge 1:1 hhidpn wave using `outdir'/imputed_ssa_notret.dta 
drop _merge

foreach var in raime rq fraime frq {
	egen `var' = rowmax(`var'_ret `var'_notret)
}


* Assume alzhe = 0, cogstate is normal, and selfmem are good if missing in earlier wave

replace alzhe = 0 if alzhe == .
replace l2alzhe = 0 if l2alzhe == .

replace cogstate = 3 if cogstate == .
replace l2cogstate = 3 if l2cogstate == .

replace selfmem = 1 if selfmem == .
replace l2selfmem = 1 if l2selfmem == .


* This is a kludge to deal with individuals who have missing weight and missing bweight.  I think this relates to three nursing home respondents, two of which were dead in 2004.
drop if weight == . & bweight == .

multiply_persons `expand'

gen entry = 2010

if(floor(c(version))>=14) {
  saveold "`outdir'/stock_hrs_2010.dta", replace v(12)
}
else {	
  saveold "`outdir'/stock_hrs_2010.dta", replace
}

