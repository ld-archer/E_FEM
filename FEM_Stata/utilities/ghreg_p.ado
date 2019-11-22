/* Likelihood evaluator for maximum likelihood estimator 
 of 2-parameter hyperbolic sin transformation - post estimation
 (concentrated likelihood)
 
see 
MacKinnon and Magee (1990): "Transforming the Dependent
Variable in a Regression Model", IER 31:2, pp. 315-339
http://www.jstor.org/stable/2526842

see equation (42) for concentrated likelihood
					    
----------------------------------------------------- */

program define ghreg_p
	version 9.1
	local myopts "unc simu"
	_pred_se "`myopts'" `0'
	if `s(done)' { 
		exit 
	}
	local vtyp `s(typ)'
	local varn `s(varn)'
	local 0 `"`s(rest)'"'
	syntax [if] [in] [, `myopts' noOFFset]

	local type = "`unc'`simu'"

	if "`type'" == ""{
		di in gr "(option pr assumed)"
		tempvar t
		qui _predict double `t' `if' `in', `offset'
		gen `vtyp' `varn' = `t' `if' `in'
		label var `varn' "Predicted Value of G"
	}

	marksample touse

	if "`type'" == "unc"{
		tempvar t t2
		qui _predict double `t' if `touse', `offset'
		qui replace `t' = `t' + e(rmse)*invnormal(uniform())
		

		local theta = e(theta)
		local omega = e(omega)
	
		tempvar r
		gen `r' = `theta'*`t'*(1+`theta'^2*`omega'^2)^(-1/2)+log(`theta'*`omega'+(`theta'^2*`omega'^2+1)^(1/2))

		tempvar y
		gen `y' = -1*`omega' + (1/`theta')*exp(`theta'^2*e(ssr)/(2*(1+`theta'^2*`omega'^2)))*((exp(`r')-exp(-1*`r'))/2)
		gen `vtyp' `varn' = `y' if `touse'
		label var `varn' "Uncensored Predicted Value of Y"
	}		

	if "`type'" == "simu"{
		tempvar t t2
		qui _predict double `t' if `touse', `offset'
		qui replace `t' = `t' + sqrt(e(ssr))*invnormal(uniform())
		gen t = `t'
		local theta = e(theta)
		local omega = e(omega)

		tempvar y
		egen `y' = invgh(`t'), theta(`theta') omega(`omega')
		gen `vtyp' `varn' = `y' if `touse'
		label var `varn' "Simulated Value of Y"
	}

end
