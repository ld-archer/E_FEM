
/** \file

Add random variables to host dataset. The logic here is very similar to save_simul2004_faked, but some special handling is
required for wave 4 as well as for crossvalidation.

\date Mar 2008

*/
include common.do

  use "$outdata/all1998_pop_adjusted.dta",replace
    
* Using parameter estimates from stock_hrs_1998, but now applying them to the unrestricted all1998_pop_adjusted.dta file to restore our sample size when using the unrestricted data.  
est use $resmodels/fraime_nonzero1998.ster
predict Pfraime_nonzero, xb
gen fraime_nonzero = runiform() < Pfraime_nonzero
est use $resmodels/fraime1998.ster
predict fraime if fraime_nonzero
recode fraime (missing=0)
drop fraime_nonzero Pfraime_nonzero

est use $resmodels/flogq1998.ster
local logq_sd = e(rmse)
predict flogq
gen rq = exp(flogq + 0.5 * `logq_sd'^2)
recode rq (missing=0)

est use $resmodels/rpia1998.ster
local pia_sd = e(rmse)
predict rpia
recode rpia (missing=0)

* This is a kludge to deal with individuals who have missing weight and missing bweight.  I think this relates to three nursing home respondents, two of which were dead in 2004.
drop if weight == . & bweight == .

merge m:1 hhidpn using "$outdata/crossvalidation.dta" , keepusing(simulation)
drop if _m == 2
keep if simulation == 1

/* proptax doesn't exist for wave 4 (1998) */
replace proptax = 0
replace proptax_nonzero = 0

gen entry = 1998

if(floor(c(version))>=14) {
	saveold "$outdata/stock_hrs_1998.dta",replace v(12)
}
else{
	saveold "$outdata/stock_hrs_1998.dta",replace
}
