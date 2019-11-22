*! cmp 5.1.0 14 April 2012
*! David Roodman, Center for Global Development, Washington, DC, www.cgdev.org
*! Copyright David Roodman 2007-12. May be distributed free.
cap program drop cmp_clear
program define cmp_clear
	version 10.0
	forvalues l=1/0$parse_L {
		cap mat drop cmp_fixed_sigs`l'
		cap mat drop cmp_fixed_rhos`l'
	}
	foreach mat in cmp_mprobit_group_inds cmp_roprobit_group_inds cmp_num_cuts cmp_levels cmp_nonbase_cases {
		cap mat drop `mat'
	}
	foreach vars in lnfi y* rev_ind* ind* id* e* f* g* u* {
		cap drop _cmp_`vars'
	}
	cap drop _mp_cmp*
	cap drop _cmp_y*_*
	cap drop _cmp_weight*
	macro drop ml_*
	macro drop parse_*
	foreach global in d truncreg* intreg* y* tot_cuts max_cuts eq* x* mprobit_ind_base roprobit_ind_base num_mprobit_groups num_roprobit_groups ///
			cmp_reverse cmpREDraws rc* id* L* covariance*{
		macro drop cmp_`global'
	}
	foreach var in _ghk_p _ghk_anti _ghk_draws _ghk_type _Sig _subviews _first_call _d _NumCuts _NumScores _interactive _X _num_mprobit_groups ///
			_mprobit_ind_base _mprobit_group_inds _intreg _SimultaneousSampling _dSigdParams {
		cap mata mata drop `var'
	}
	ml clear
end
