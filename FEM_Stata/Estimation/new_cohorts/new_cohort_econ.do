
clear
clear mata
set mem 500m
set more off
set seed 52432
*set maxvar 10000
est drop _all
capt log close

log using new_cohort_econ.log, replace

*==========================================================================*
* Estimate New Cohorts - Wealth, DC Wealth, Income
* Jun 23, 2008: For wealth, use generalized inverse hyperbolic sine  transformation
* =========================================================================*



* Assume that this script is being executed in the FEM_Stata/Estimation/new_cohorts directory

* Load environment variables from the root FEM directory, three levels up
* these define important paths, specific to the user
include "../../../fem_env.do"

* Define paths
global workdir  			"$local_path/Estimation/new_cohorts"


global outdir "$local_path/Estimates/new_cohorts"
adopath + "$local_path/hyp_mata"


do "$local_path/Code/put_est.mata"

use "$netdir/age5055_hrs1992r"



replace iearn = . if work == 0
replace iearnx = . if work == 0
replace dcwlth = . if dcwlth == 0
replace dcwlthx = . if dcwlthx == 0
replace hatota = . if hatota == 0
replace hatotax = . if hatotax == 0

quietly{
	foreach i in   iearnx  hatotax{
		noi disp ""
		noi disp ""
		noi disp "`i'"
		ghreg `i' black hispan hsless college male single widowed lunge cancre stroke if `i'!=.
		noi disp "theta: " e(theta)
		noi disp "omega: " e(omega)
		noi disp "ssr: " e(ssr)
		estimates store o_`i'
		matrix tos`i' = (	e(theta), e(omega), e(ssr))
		matrix m`i' = e(b)
		matrix s`i' = e(V)
		matrix t`i' = e(b)
		matrix t2`i' = t`i''
		noi matrix list t2`i'
		predict simu_`i', simu
		gen e_`i' = e(sample) == 1

		capt drop t
		}
}		


keep iearn iearnx hatota hatotax simu_* e_*



do "$local_path/Code/put_est.mata"
    
foreach var in  iearnx  hatotax {
 		capture erase "$outdir//m`var'"
 		capture erase "$outdir//s`var'"
		mata: _putestimates("$outdir//m`var'","$outdir//s`var'" ,"m`var'")
 }
 

use "$netdir/age5055_hrs1992r", clear

replace dcwlth = . if dcwlth == 0
replace dcwlthx = . if dcwlthx == 0



quietly{
	foreach i in   dcwlthx {
		noi disp ""
		noi disp ""
		noi disp "`i'"
		ghreg `i' black hispan hsless college male single widowed lunge cancre stroke if `i'!=.
		noi disp "theta: " e(theta)
		noi disp "omega: " e(omega)
		noi disp "ssr: " e(ssr)
		estimates store o_`i'
		matrix tos`i' = (e(theta), e(omega), e(ssr))
		matrix m`i' = e(b)
		matrix t`i' = e(b)
		matrix t2`i' = t`i''
		noi matrix list t2`i'
		**predict simu_`i', simu
		**gen e_`i' = e(sample) == 1
	}
}		
 

do "$local_path/Code/put_est.mata"

foreach var in  dcwlthx  {
 		capture erase "$outdir//m`var'"
 		capture erase "$outdir//s`var'"
		mata: _putestimates("$outdir//m`var'","$outdir//s`var'" ,"m`var'")
 }
 
	matrix coeffs = (tiearnx \ thatotax \ tdcwlthx) 
	matrix tos = (tosiearnx \ toshatotax \ tosdcwlthx) 
	
	matrix colnames tos = theta omega ssr
	matrix rownames tos = iearnx hatotax dcwlthx
	
	matrix colnames coeffs = black hispan hsless college male single widowed lunge cancre stroke constant
	matrix rownames coeffs = iearnx hatotax dcwlthx
	
	clear
	set obs 3
	gen var = "iearnx" if _n == 1
	replace var = "hatotax" if _n == 2
	replace var = "dcwlthx" if _n == 3
	svmat coeffs, names(col)
	save "$indata/incoming_means_econ", replace
	
	
	clear
	set obs 3
	gen var = "iearnx" if _n == 1
	replace var = "hatotax" if _n == 2
	replace var = "dcwlthx" if _n == 3
	svmat tos, names(col)
	save "$indata/incoming_means_econ_tos", replace

 
clear mata

log close
