/* Function that calculates the generalized inverse
hyperbolic sin transform of a continuous variable
see 
MacKinnon and Magee (1990): "Transforming the Dependent
Variable in a Regression Model", IER 31:2, pp. 315-339
http://www.jstor.org/stable/2526842

specification eq(39)

egen transformed var = gh(var), 
				   theta(real) omega(real)
where numlist is first theta and then omega, name below
as a and b (from MM)

-----------------------------------------------------*/

program define _ggh
	version 9, missing 

	* parse the arguments
	gettoken type 0 : 0
	gettoken g 0 : 0
	gettoken eqs 0 : 0			/* "=" */
	gettoken paren 0 : 0, parse("(), ")	/* "(" */
	gettoken y 0 : 0, parse("(), ")
	gettoken paren 0 : 0, parse("(), ")	/* "(" */
	* syntax statement and mark sample
	
	syntax [if] [in] [, theta(real 1) omega(real 0)] 
	marksample touse
	tempname a b
	
	quietly {
	scalar `a' = `theta'
	scalar `b' = `omega'
	
	* preliminaru calculations
	tempvar hy hb dy
	tempname dhb
	gen double `dy' = `a'*(`y'+`b') if `touse'
	egen double `hy' = h(`dy') if `touse'
	egen double `hb' = h(`a'*`b') if `touse'
	scalar `dhb' = ((1+(`a'*`b')^2)^(-1/2))  

	* computations
	qui gen double `g' = (`hy'-`hb')/(`a'*`dhb') if `touse'
	}
end


