*! cmp 5.1.0 14 April 2012
*! David Roodman, Center for Global Development, Washington, DC, www.cgdev.org
*! Copyright David Roodman 2007-12. May be distributed free.
cap program drop cmp_d1
program define cmp_d1
	version 10.0

	forvalues l=1/$cmp_num_scores {
		local scargs `scargs' sc`l'
	}
	args todo b lnfi g negH `scargs'
	tokenize `0'
	macro shift 5
	tempname t cuts rc _g
	tempvar theta
	
	local i $cmp_d

	mat `cuts' = J($cmp_d, $cmp_max_cuts+2, .)
	forvalues j=1/$cmp_d {
		if cmp_num_cuts[`j',1] {
			mat `cuts'[`j',1] = minfloat()
			forvalues k=1/`=cmp_num_cuts[`j',1]' {
				mleval `t' = `b', eq(`++i') scalar
				mat `cuts'[`j',`k'+1] = `t' 
			}
		}
	}

	forvalues l=1/$parse_L {
		tempname sig`l' rho`l'
		local sigs `sigs' `sig`l''
		local rhos `rhos' `rho`l''
		forvalues j=1/$cmp_d {
			if cmpLevels[`j',`l'] {
				if  (cmp_fixed_sigs`l'[1,`j']==.) {
					mleval `t' = `b', eq(`++i') scalar
					mat `sig`l'' = nullmat(`sig`l''), exp(`t')
				}
				else {
					mat `sig`l'' = nullmat(`sig`l''), cmp_fixed_sigs`l'[1,`j']
				}
			}
		}
		
		if $cmp_d > 1 {
			if "${cmp_covariance`l'}" == "exchangeable" {
				mleval `t' = `b', eq(`++i') scalar
			}
			forvalues j=1/$cmp_d {
				forvalues k=`=`j'+1'/$cmp_d {
					if cmpLevels[`j',`l'] & cmpLevels[`k',`l'] {
						if cmp_fixed_rhos`l'[`k',`j'] == . {
							if "${cmp_covariance`l'}" != "exchangeable" {
								mleval `t' = `b', eq(`++i') scalar
							}
							mat `rho`l'' = nullmat(`rho`l''), `t'
						}
						else {
							mat `rho`l'' = nullmat(`rho`l''), cmp_fixed_rhos`l'[`k',`j']
						}
					}
				}
			}
		}
	}

	qui forvalues l=1/$cmp_d {
		mleval `theta' = `b', eq(`l')
		replace _cmp_e`l' = cond(inlist(_cmp_ind`l', 1, 2, 7, 8),           ///
							${cmp_y`l'} - `theta',                 ///
					  cond(_cmp_ind`l'==3,                            ///
							`theta' - ${cmp_y`l'},                 ///
					  cond(_cmp_ind`l'==4,                            ///
							cond(${cmp_y`l'}, `theta', -`theta'),  ///
					  cond(_cmp_ind`l'==5,                            ///
							`cuts'[`l', ${cmp_y`l'}+1] - `theta', ///
							-`theta')))) if _cmp_ind`l'
		if $cmp_max_cuts | ${cmp_intreg`l'}  | ${cmp_truncreg`l'} ///
				replace _cmp_f`l' = cond(_cmp_ind`l'==5, `cuts'[`l', ${cmp_y`l'}], ${cmp_y`l'_L}) - `theta' if inlist(_cmp_ind`l', 5, 7, 8)
		if ${cmp_truncreg`l'} replace _cmp_g`l' = ${cmp_y`l'_U} - `theta' if _cmp_ind`l'==8
		drop `theta'
	}

	mata (void) cmp_lnL(`todo', "", "`*'")
	if $parse_L==1 mlsum `lnfi' = _cmp_lnfi
	
	if `todo' {
		tempname _g
		forvalues l=1/$cmp_d {
			mlvecsum `lnfi' `t' = `sc`l'' if _cmp_ind`l', eq(`l')
			mat `_g' = nullmat(`_g'), `t'
		}
		forvalues l=`=$cmp_d+1'/$cmp_num_scores {
			mlsum `t' = `sc`l''
			mat `_g' = `_g', `t'
		}
		mat `g' = `_g'
	}
end
