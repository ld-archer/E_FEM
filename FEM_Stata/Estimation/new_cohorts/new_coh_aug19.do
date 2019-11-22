
clear
clear mata
set mem 500m
set more off
set seed 52432
*set maxvar 10000
est drop _all
capt log close

log using new_coh_aug19.log, replace

*==========================================================================*
* Estimate New Cohorts - Wealth, DC Wealth, Income
* Jun 23, 2008: For wealth, use generalized inverse hyperbolic sine  transformation
* =========================================================================*

global workdir "\\zeno\zeno_a\FEM\FEM_1.0\Estimation_2\new_cohorts"
global indata  "\\homer\homer_c\Retire\FEM\rdata\age5055_hrs1992r.dta"
global outdata "\\zeno\zeno_a\FEM\FEM_1.0\Input_yh"
global outdir "\\zeno\zeno_a\FEM\FEM_1.0\Input_yh\all\new_cohort"
* global netdir  "\\homer\homer_c\Retire\ahg\rdata2"

cd "\\zeno\zeno_a\FEM\FEM_1.0\Makedata\HRS"
capt takestring
cd "\\zeno\zeno_a\FEM\FEM_1.0\Estimation_2"
capt estout

global ghregdir "\\zeno\zeno_a\FEM\FEM_1.0\Code"
adopath ++ "\\zeno\zeno_a\zyuhui\DOL\PC"
adopath ++ "\\zeno\zeno_a\DOL\Makedata\HRS"
adopath ++ "\\zeno\zeno_a\DOL\Estimation_2"
adopath ++ "\\zeno\zeno_a\FEM\FEM_1.0\Code"

cd $ghregdir

use $indata



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

save "\\homer\homer_c\Retire\ahg\rdata3\simu_2jul08.dta", replace

do "$workdir\put_est.mata"
    
foreach var in  iearnx  hatotax {
 		capture erase "$outdir//m`var'"
 		capture erase "$outdir//s`var'"
		mata: _putestimates("$outdir//m`var'","$outdir//s`var'" ,"m`var'")
 }
 
global ghregdir "\\zeno\zeno_a\FEM\FEM_1.0\Code"
cd $ghregdir

use $indata, clear

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
		matrix m`i' = e(b)
		matrix t`i' = e(b)
		matrix t2`i' = t`i''
		noi matrix list t2`i'
		**predict simu_`i', simu
		**gen e_`i' = e(sample) == 1
	}
}		
 
cd "$workdir"

do "$workdir\put_est.mata"

foreach var in  dcwlthx  {
 		capture erase "$outdir//m`var'"
 		capture erase "$outdir//s`var'"
		mata: _putestimates("$outdir//m`var'","$outdir//s`var'" ,"m`var'")
 }
clear mata

log close
