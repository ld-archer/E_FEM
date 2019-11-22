/** \file
Estimation of 2-parameter inverse hyperbolic sin models
 based on MacKinnon and Magee (1990)
see 
MacKinnon and Magee (1990): "Transforming the Dependent
Variable in a Regression Model", IER 31:2, pp. 315-339
http://www.jstor.org/stable/2526842

estimation in two-steps, concentrated likelihood first
and then retrieve concentrated parameters. Following
equation (41),(42) and discussion on page 325-326.


\author Pierre-Carl Michaud
\date April 2008

*/
program ghreg
	version 9.1
	Estimate `0'
end



program Estimate, eclass sortpreserve
	syntax varlist [if] [in] [,					///
			vce(passthru)					///
			CLuster(varname)				      ///
			i(varname)						///
			noCONStant						///
			Level(cilevel)	]	
	// Check Syntax
	gettoken lhs rhs: varlist
	if ("`cluster'" != "") {
		local clopt cluster(`cluster')	
	}
	

	// Mark Sample for estimation
	marksample touse	
	// Obtain Estimation Results

	tempvar _cons
	gen `_cons' = 1

*	Removing the equal sign in this local so we can avoid renaming our variables
* local vars = "`lhs' `rhs' `_cons'"
	local vars "`lhs' `rhs' `_cons'"
	
	di as txt _n "Maximizing concentrated likelihood: "	
	mata: initial = opti("`vars'","`touse'")


	di as txt _n "Retrieving concentrated parameters: "	
	local theta = r(theta)
	local omega = r(omega)
	tempvar g
	
	qui egen double `g' = gh(`lhs') if `touse', theta(`theta') omega(`omega')
	qui reg `g' `rhs' if `touse'						

	tempname reg_b nm	
	matrix define nmval = (.1, .1, .1)
	matrix define `reg_b' = e(b)
	local num = colsof(`reg_b')
	forvalues i = 1/`num'{
		matrix define nmval = (nmval,.1)
	}
	
	local sig = e(rmse)^2
	matrix define initial = (`theta', `omega', `sig', `reg_b')
		

	mata: opti_unc("`vars'","initial","`touse'","nmval")

	local theta = e(theta)
	local omega = e(omega)
	tempvar h

	ereturn local predict "ghreg_p"
	ereturn local cmd "ghreg"
	ereturn local depvar "`lhs'"

	mata: mata clear
	
end


