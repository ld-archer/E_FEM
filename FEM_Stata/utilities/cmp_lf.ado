*! cmp 5.1.0 14 April 2012
*! David Roodman, Center for Global Development, Washington, DC, www.cgdev.org
*! Copyright David Roodman 2007-12. May be distributed free.
cap program drop cmp_lf
program define cmp_lf
	version 10.0

	args lnf
	macro shift
	tempname t sig cuts rc
	mat `cuts' = J($cmp_d, $cmp_max_cuts+2, .)

	local l $cmp_d
	forvalues j=1/$cmp_d {
		if cmp_num_cuts[`j',1] {
			forvalues k=1/`=cmp_num_cuts[`j',1]' {
				mat `cuts'[`j',`k'+1] = ``++l''[$cmp_n]
			}
		}
	}

	forvalues j=1/$cmp_d {
		if cmp_fixed_sigs1[1,`j']==. {
			mat `sig' = nullmat(`sig'), exp(``++l''[$cmp_n])
		}
		else mat `sig' = nullmat(`sig'), cmp_fixed_sigs1[1,`j']
	}

	if $cmp_d > 1 {
		if "${cmp_covariance1}" == "exchangeable" {
			scalar `t' = ``++l''[$cmp_n]
		}
		tempname atanhrho
		forvalues j=1/$cmp_d {
			forvalues k=`=`j'+1'/$cmp_d {
				if cmp_fixed_rhos1[`k',`j'] == . {
					if "${cmp_covariance`l'}" != "exchangeable" {
						scalar `t' = ``++l''[$cmp_n]
					}
					mat `atanhrho' = nullmat(`atanhrho'), `t'
				}
				else {
					mat `atanhrho' = nullmat(`atanhrho'), cmp_fixed_rhos1[`k',`j']
				}
			}
		}
	}

	local sigs `sig'
	local rhos `atanhrho'

	qui forvalues l=1/$cmp_d {
		replace _cmp_e`l' = cond(inlist(_cmp_ind`l', 1, 2, 7, 8),                 ///
							${ML_y`l'} - ``l'',                 ///
					  cond(_cmp_ind`l'==3,                            ///
							``l'' - ${ML_y`l'},                 ///
					  cond(_cmp_ind`l'==4,                            ///
							cond(${ML_y`l'}, ``l'', -``l''),    ///
					  cond(_cmp_ind`l'==5,                            ///
							`cuts'[`l', ${cmp_y`l'}+1] - ``l'', ///
							-``l'')))) if _cmp_ind`l'
		if $cmp_max_cuts | ${cmp_intreg`l'}  | ${cmp_truncreg`l'} ///
				replace _cmp_f`l' = cond(_cmp_ind`l'==5, `cuts'[`l', ${cmp_y`l'}], ${cmp_y`l'_L}) - ``l'' if inlist(_cmp_ind`l', 5, 7, 8)
		if ${cmp_truncreg`l'} replace _cmp_g`l' = ${cmp_y`l'_U} - ``l'' if _cmp_ind`l'==8
	}
	mata (void) cmp_lnL(0, "`lnf'")
end
