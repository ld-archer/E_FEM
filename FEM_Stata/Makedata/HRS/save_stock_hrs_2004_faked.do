
/** \file

Add random variables to host dataset.

\date Mar 2008

*/
include common.do
local expand : env EXPAND
local bsamp : env BREP

* Using parameter estimates from stock_hrs_2004, but now applying them to the unrestricted all2004_pop_adjusted.dta file to restore our sample size when using the unrestricted data.
if missing("`bsamp'") {	
	use "$outdata/all2004_pop_adjusted.dta",replace
}
else {
	use "$outdata/input_rep`bsamp'/all2004_pop_adjusted.dta", clear
}

est use $resmodels/fraime_nonzero2004.ster
predict Pfraime_nonzero, xb
gen fraime_nonzero = runiform() < Pfraime_nonzero
est use $resmodels/fraime2004.ster
predict fraime if fraime_nonzero
recode fraime (missing=0)
drop fraime_nonzero Pfraime_nonzero

est use $resmodels/flogq2004.ster
local q_sd = e(rmse)
predict flogq
gen rq = exp(flogq + 0.5 * `q_sd'^2)
recode rq (missing=0)

est use $resmodels/rpia2004.ster
local pia_sd = e(rmse)
predict rpia
recode rpia (missing=0)

* This is a kludge to deal with individuals who have missing weight and missing bweight.  I think this relates to three nursing home respondents, two of which were dead in 2004.
drop if weight == . & bweight == .

* Assume alzhe = 0, cogstate is normal, and selfmem are good if missing in earlier wave

replace alzhe = 0 if alzhe == .
replace l2alzhe = 0 if l2alzhe == .

replace cogstate = 3 if cogstate == .
replace l2cogstate = 3 if l2cogstate == .

replace selfmem = 1 if selfmem == .
replace l2selfmem = 1 if l2selfmem == .

multiply_persons `expand'

gen entry = 2004

* Lipids were only asked after 2006
replace lipidrx = 0 if missing(lipidrx)
replace l2lipidrx = 0 if missing(l2lipidrx)
replace rxchol = 0 if missing(rxchol)
replace l2rxchol = 0 if missing(l2rxchol)

if missing("`bsamp'") {	
	if(floor(c(version))>=14) {
		saveold "$outdata/stock_hrs_2004.dta", replace v(12)
	}
	else {	
		saveold "$outdata/stock_hrs_2004.dta", replace
	}
}
else {
	if(floor(c(version))>=14) {
		saveold "$outdata/input_rep`bsamp'/stock_hrs_2004.dta", replace v(12)
	}
	else{
		saveold "$outdata/input_rep`bsamp'/stock_hrs_2004.dta", replace
	}
}
