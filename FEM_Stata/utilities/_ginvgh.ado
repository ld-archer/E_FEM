/* Function that calculates the inverse of the 
generalized inverse
hyperbolic sin transform of a continuous variable
see 
MacKinnon and Magee (1990): "Transforming the Dependent
Variable in a Regression Model", IER 31:2, pp. 315-339
http://www.jstor.org/stable/2526842

specification

egen transformed var = invgh(var), 
				   theta(real) omega(real)
where numlist is first theta and then omega (from MM)
name below as a and b.

-----------------------------------------------------*/

program define _ginvgh
	version 9, missing 
	
	* parse the arguments
	gettoken type 0 : 0
	gettoken y 0 : 0
	gettoken eqs 0 : 0			/* "=" */
	gettoken paren 0 : 0, parse("(), ")	/* "(" */
	gettoken g 0 : 0, parse("(), ")
	gettoken paren 0 : 0, parse("(), ")	/* "(" */
	
	* syntax statement and mark sample
	syntax [if] [in] [, theta(real 1) omega(real 0)] 
	
	marksample touse	
	tempname a b
	quietly {
	scalar `a' = `theta'
	scalar `b' = `omega'
	
	* preliminaru calculations
	tempvar sinh hb dy x
	tempname dhb	
	egen `hb' = h(`a'*`b') if `touse'
	scalar `dhb' = (1+(`a'*`b')^2)^(-1/2)  
	gen double `x' =  `a'*`dhb'*`g'+`hb' if `touse'
	gen double `sinh' = 0.5*(exp(`x')-exp(-`x')) if `touse'
		
	* computations
	qui gen double `y' = (`sinh'-`a'*`b')/`a' if `touse'
	}
end


