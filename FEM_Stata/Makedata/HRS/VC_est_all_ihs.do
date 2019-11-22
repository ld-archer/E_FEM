/*
The goal in this file is to estimate the inverse hyperbolic sine models using ghreg.  Then, we will use the residuals terms from those 
models in the cmp procedure.  After the CMP estimation, the models from ghreg will replace the residual models used in cmp.  

This will produce files for use in new51simulate: 
	incoming_vcmatrix.dta - the variance-covariance matrix
	incoming_means.dta - the beta coefficients for the models
	incoming_means_econ_tos.dta - the parameters for the inverse hyperbolic sine models
	incoming_cut_points.dta - the cut points for the ordered probit models

9/28/15 - removed AIME and quarters worked.  These are estimated in a separate joint estimation.

*/


quietly include common.do

* Install the cmp mata routine
quietly do "$local_path/utilities/cmp.mata"

* Include this since we need ghreg
adopath + "$local_path/hyp_mata"
adopath ++ "$local_path/utilities"

* use restricted data for 1992 50-55 cohort - (We no longer need this restricted data restriction ...)
* use $dua_rand_hrs/age5055_hrs1992r.dta
use $outdata/age5055_hrs1992.dta

* Set seed for repeatable results
 set seed 8675309


* Right-hand side variables for all models
local rhs black hispan hsless college male fsingle fwidowed flunge fcancre fstroke
* Shorter specification removing stroke for use in some models since it is so rare in the 5055 population
local rhs2 black hispan hsless college male fsingle fwidowed flunge fcancre

* Estimate the IHS models using ghreg

local ihs_var "hatotax iearnx dcwlthx"
local restrict "fwlth_nonzero work anydc"
local n : word count `ihs_var'


* An ordered list of the models estimated - not used in the estimation, but used in the saving of the parameters
#delimit ;
local models 		fhibpe 				fhearte 	fdiabe 		fanyhi 			fshlt 
								fwtstate 			fsmkstat 	fanyadl		fanyiadl		fwork
 								fwlth_nonzero 										hatotax 		iearnx
 								dcwlthx 			fanydc 		fanydb 		frdb_ea_c 	frdb_na_c
								;
#delimit cr
local dim : word count `models'

* matrix for storing theta, omega, and SSR parameters
mat TOS = J(`n',3,.)

forvalues i = 1/`n' {
		local a : word `i' of `ihs_var'
		local b : word `i' of `restrict'	
		ghreg `a' black hispan hsless college male single widowed lunge cancre if `b' == 1
		
		* Store the estimates for theta, omega, and ssr for later in new51_simulate
		mat TOS[`i',1] = e(theta)
		mat TOS[`i',2] = e(omega)
		mat TOS[`i',3] = e(ssr)
		
		* Store the models so we can replace the cmp estimated models
		mat ghreg_`a' = e(b)
		mat rownames ghreg_`a' = `a' 
		mat list ghreg_`a'
		
		* Store  the SSR for later use
		local ssr_`a' = e(ssr)
		di "SSR = " `ssr_`a''
		
		* These are the predicted values g = xB (no error)
		predict p1_`a'
		sum p1_`a'
		
		* These are the simulated values g = xB + error (including a draw from a uniform distribution)
		predict p2_`a', simu
		sum p2_`a'

		* Store the parameters
		tempvar theta 
		tempvar omega
		gen `theta' = e(theta)
		gen `omega' = e(omega)
		di "Theta = " `theta' 
		di "Omega = " `omega'
		 
		* Variables/parameters for the transformation 
		gen term_`a' = `theta'*(`a'+`omega')
		tempvar term2
		gen `term2' = `theta'*`omega'
		
		* Generate the transformed outcome
		gen g_`a' = (ln(term_`a'+(1+(term_`a')^2)^0.5) - ln(`term2'+(1+(`term2')^2)^0.5)) / (`theta'*((1+(`term2')^2)^(-1/2)))
		sum g_`a'
		
		* Summarize the predicted value
		sum p1_`a'
		
		* Calculate the residuals
		gen res_`a' = g_`a' - p1_`a'
		sum res_`a'
		
		* This is a parameter used in the simulated prediction, needs to be dropped for subsequent estimations
		drop t
		
}

mat rownames TOS = `ihs_var'
mat colnames TOS = theta omega ssr
mat incoming_means_econ_tos = TOS		
matsave incoming_means_econ_tos, replace path("$indata") saving


* The approach for the ghreg models is to use the calculated residuals as the outcomes of a very simple OLS estimation:  
* 		res_hatotax = error 
* 		res_iearnx = error 
* 		res_dcwlthx = error 


* This is for the res_hatotax, res_iearnx, and res_dcwlthx cmp estimation where we only fit the error term.
gen c = 0

***************************************************************************************************************
/*
* CMP  -  
		options include:
		- tech = search algorithm (here, using dfp), 
		- nrtolerance = tolerance of steps (default is 10^-5, larger values give faster convergence (useful for testing))
		- ghkdraws = since this is a Monte Carlo simulation, we specify # of draws.  Ideally, ~100, smaller values run faster (useful for testing)
*/
*****************************************************************************************************************
cmp setup
which cmp

* Constraints
* work and earnings
constraint 1 [atanhrho_1013]_cons = 0
* work and anydc 
constraint 2 [atanhrho_1015]_cons = 0
* work and anydb
constraint 3 [atanhrho_1016]_cons = 0
* non-zero wealth and wealth
constraint 4 [atanhrho_1112]_cons = 0
* anydb and early db
constraint 5 [atanhrho_1617]_cons = 0
* anydb and normal db
constraint 6 [atanhrho_1618]_cons = 0
* fanydc and flogdcwlthx
constraint 7 [atanhrho_1415]_cons = 0
* work and flogdcwlthx?
constraint 8 [atanhrho_1014]_cons = 0
* work and frdb_ea_c?
constraint 9 [atanhrho_1017]_cons = 0
* work and frdb_na_c?
constraint 10 [atanhrho_1018]_cons = 0

* Additional constraints on the variance terms for ihs models
                                            

#delimit ;

cmp 				(fhibpe = `rhs2') 				(fhearte = `rhs2') 		(fdiabe = `rhs2') 			(fanyhi = `rhs2') 			(fshlt = `rhs2') 
 						(fwtstate = `rhs2') 			(fsmkstat = `rhs2') 	(fanyadl = `rhs2') 			(fanyiadl = `rhs2')			(fwork = `rhs2')
			 			(fwlth_nonzero = `rhs2')	  																						(res_hatotax = c) 			(res_iearnx = c)
						(res_dcwlthx = c)					(fanydc = `rhs2')			(fanydb = `rhs2') 			(frdb_ea_c = `rhs2') 		(frdb_na_c = `rhs2')
, indicators(
						$cmp_probit 				$cmp_probit 				$cmp_probit 						$cmp_probit 						$cmp_probit 
 					 	$cmp_oprobit 				$cmp_oprobit 				$cmp_probit 						$cmp_probit							$cmp_probit
 						$cmp_probit 																										fwlth_nonzero*$cmp_cont fwork*$cmp_cont
 						fanydc*$cmp_cont		fwork*$cmp_probit 	fwork*$cmp_probit 			fanydb*$cmp_oprobit 		fanydb*$cmp_oprobit
 						)   
 	 constraint(1/10) 
 	 tech(dfp) 
 	 nrtolerance(.01)
 	 ghkdraws(5)
 	 
;
 
#delimit cr



**************************************************************************************************** 
* Format and save the output
*******************************************************************************************************

* Build the Variance-Covariance matrix
mat VC = J(`dim',`dim',.)
* label the rows and colums
mat rownames VC = `models'
mat colnames VC = `models'

* Populate the variance terms - All are 1 except for continuous models.
forvalues x = 1/`dim' {
	capture: mat VC[`x',`x'] = (exp(_b[lnsig_`x':_cons]))^2
	if _rc > 0 { 
		mat VC[`x',`x'] = 1
	}
}

* Replace the variance terms for the ghreg estimations with the SSR terms
forvalues i = 1/`n' {
	local a : word `i' of `ihs_var'
	local r = rownumb(matrix(VC),"`a'")
	mat VC[`r',`r'] = `ssr_`a''
}

* Populate the covariance terms
local oneless = `dim' - 1
forvalues x = 1/`oneless' {
		local a = `x' + 1
		forvalues y = `a'/`dim' {
			mat VC[`y',`x'] = tanh(_b[atanhrho_`x'`y':_cons])*sqrt(VC[`x',`x']*VC[`y',`y']) 
	}
}


* Save the VC matrix
mat incoming_vcmatrix = VC
matsave incoming_vcmatrix, replace path("$indata") saving


* Store the beta coefficients from the models (equivalent to old incoming_means.dta)

* Note: ordered probit models are estimated without a constant.  The cut points can be transformed by the 
* value of cut point 1 to be comparable to the model that included a constant.

local cov black hispan hsless college male fsingle fwidowed flunge fcancre _cons

local r_count : word count `models'
local c_count : word count `cov'

mat IM = J(`r_count',`c_count',.)

local a = 1

foreach x in `models' {
	local b = 1
	foreach y in `cov' {
		capture:  mat IM[`a',`b'] = _b[`x':`y']
		* This is to deal with no constant in the ordered probit estimations
		if _rc != 0 {
				mat IM[`a',`b'] = 0
			}
		local b = `b' + 1
		}
	local a = `a' + 1
}		

mat list IM

* Set the constant to the first cut point for the ordered probit models
foreach x in 6 7 17 18 {
	mat IM[`x',10] = -_b[cut_`x'_1:_cons]
}

mat list IM

mat rownames IM = `models' 
mat colnames IM = black hispan hsless college male single widowed lunge cancre constant 

* Replace the residual models with the ghreg models

forvalues i = 1/`n' {
	local a : word `i' of `ihs_var'
	local r = rownumb(matrix(IM),"`a'")
	forvalues y = 1/10 {
			mat IM[`r',`y'] = ghreg_`a'[1,`y']
	}
}


mat incoming_means = IM
matsave incoming_means, replace path("$indata") saving



* Make a matrix storing the cutpoints, shifting them so that the first cut point is 0

mat CP = J(4,4,.)

local a = 1
foreach x in 6 7 17 18 {
		forvalues y = 1/4 {
			capture mat CP[`a',`y'] = _b[cut_`x'_`y':_cons] - _b[cut_`x'_1:_cons]
		}
		local a = `a' + 1
}


mat colnames CP = cut_1 cut_2 cut_3 cut_4					
mat rownames CP = fwtstate fsmkstat frdb_ea_c frdb_na_c

mat incoming_cut_points = CP
matsave incoming_cut_points, replace path("$indata") saving



* Save the files in Stata 11 format
use $indata/incoming_vcmatrix.dta
saveold $indata/incoming_vcmatrix.dta, replace

use $indata/incoming_means.dta
saveold $indata//incoming_means, replace

use $indata/incoming_means_econ_tos.dta
saveold $indata//incoming_means_econ_tos.dta, replace

use $indata/incoming_cut_points.dta
saveold $indata/incoming_cut_points.dta, replace
   

capture log close


