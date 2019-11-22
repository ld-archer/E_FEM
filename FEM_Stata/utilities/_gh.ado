/* Function that calculates the inverse
hyperbolic sin transform of a continuous variable

specification

egen transformed var = h(var)
				  
-----------------------------------------------------*/

program define _gh
	version 9, missing

	* parse the arguments
	gettoken type 0 : 0
	gettoken g 0 : 0
	gettoken eqs 0 : 0			/* "=" */
	gettoken paren 0 : 0, parse("(), ")	/* "(" */
	gettoken y 0 : 0, parse("(), ")
	gettoken paren 0 : 0, parse("(), ")	/* "(" */
	
	* syntax statement and mark sample
	syntax [if] [in]
	marksample touse
	
	* computations
	qui gen `g' = log(`y'+sqrt((`y')^2+1)) if `touse'
end


