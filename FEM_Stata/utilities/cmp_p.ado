*! cmp 5.2.0 22 April 2012
*! David Roodman, Center for Global Development, droodman@cgdev.org
cap program drop cmp_p
program define cmp_p
	version 10.0
	
	syntax anything [if] [in], [EQuation(string) Outcome(string) NOOFFset pr REsiduals lnl SCores Ystar(string) e(string) *]
	local c 0
	foreach stat in pr residuals scores ystar e lnl {
		if `"``stat''"' != "" {
			if `++c'>1 {
				di as err "Only one statistic allowed per {cmd:predict} call."
				exit 198
			}
		}
	}

	local options `options' `scores'
	marksample touse, novarlist
	
	if "`scores'"=="" {
		tempname b
		mat `b' = e(b)
		mat `b' = `b'[1,1..`=e(k)-e(k_aux)']
	}
	else qui replace `touse' = `touse' & e(sample)

	if `"`outcome'"'!="" local pr pr
	_score_spec `anything', equation(`equation') b(`b')
	if "`s(eqspec)'"=="#1" & `"`equation'`lnl'"'=="" & e(k_dv)>1 di as txt "(equation #1 assumed)"

	local vartype : word 1 of `s(typlist)'
	local varlist `s(varlist)'

	if "`lnl'" != "" {
		_stubstar2names `anything', nvars(1)
		local vartype `s(typlist)'
		local varname `s(varlist)'
		quietly {
			gen `vartype' `varname' = .
			`e(cmdline)' predict // run cmp front end to reconstruct necessary _cmp_* variables
			ml model `e(model)' if e(sample) & `touse'
			if "`e(user)'" == "cmp_lf" {
				tempvar t
				_stubstar2names `t'*, nvars(`e(k_eq)')
				tokenize `s(varlist)'
				forvalues i=1/`e(k_eq)' {
					qui ml_p double ``i'' if e(sample) & `touse', eq(#`i')
				}
				cmp_lf `varname' `*'
			}
			else {
				tempname b
				mat `b' = e(b)
				if "`e(user)'" == "cmp_lf1" {
					cmp_lf1 0 `b' `varname'
				}
				else {
					tempname t
					cmp_d1 0 `b' `t'
					replace `varname' = _cmp_lnfi if e(sample) & `touse'
				}
			}
			ml clear
			cmp_clear
		}
		exit
	}
	

	if `"`options'`pr'`residuals'`ystar'`e'"' == "" di as txt "(option xb assumed; fitted values)"

	tempname num_cuts cat
	mat `cat' = e(cat)
	mat `num_cuts' = e(num_cuts)
	tokenize `varlist'
	for`=cond("`s(eqspec)'"=="", "values eqno=1/`e(k_`=cond("`scores'"=="", "dv", "eq")')'", "each eqno in `=subinstr("`s(eqspec)'","#","",.)'")' {
		local depvar : word `eqno' of `e(depvar)'
		if `"`residuals'`pr'`ystar'`e'"' == "" {
			quietly `e(cmdline)' predict // run cmp front end to reconstruct necessary _cmp_* variables
			quietly ml_p `vartype' `1' if `touse', `options' equation(#`eqno') `offset'
			cmp_clear
		}
		else {
			tempvar xb
			quietly ml_p double `xb' if `touse', `options' equation(#`eqno') `offset'
		
			if "`residuals'" != "" {
				gen `vartype' `1' = `depvar' - `xb' if `touse'
				label var `1' Residuals
			}
			else if `"`ystar'`e'"' != "" {
				local ll : word 1 of `ystar'`e'
				local ul : word 2 of `ystar'`e'
				cap confirm var `ll'
				local lmissing = _rc==0 & `ll'>=.
				cap confirm var `ul'
				local umissing = _rc==0 & `ul'>=.
				local title = cond(`lmissing' & `umissing', "", "|`=cond(`lmissing', "", "`ll'<")'`depvar'`=cond(`umissing', "", "<`ul'")'")
				cap local sig = exp([lnsig_`eqno']_cons)
				if _rc local sig 1
				tempvar L U phiL phiU PhiL PhiU
				qui {
					gen double `L' = (`ll'-`xb')/`sig' if `touse'
					gen double `U' = (`ul'-`xb')/`sig' if `touse'
					gen double `phiL' = cond(`ll'==., 0, normalden(`L')) if `touse'
					gen double `phiU' = cond(`ul'==., 0, normalden(`U')) if `touse'
					gen double `PhiL' = cond(`ll'==., 0, normal   (`L')) if `touse'
					gen double `PhiU' = cond(`ul'==., 1, normal   (`U')) if `touse'
				}
				if `"`e'"' != "" {
					gen `vartype' `1' = `xb' - `sig' * (`phiU'-`phiL')/(`PhiU'-`PhiL') if `touse'
					label var `1' "E(`depvar'`title')"
				}
				else {
					gen `vartype' `1' = (`PhiU'-`PhiL')*`xb'-`sig'*(`phiU'-`phiL')+cond(`ll'==.,0,`PhiL'*`ll')+cond(`ul'==.,0,(1-`PhiU')*`ul') if `touse'
					label var `1' "E(`depvar'*`title')"
				}
			}
			else if "`pr'" != "" {
				local num_cats = `num_cuts'[`eqno',1] + 1
				if `num_cats' > 1 {
					if `"`outcome'"' == "" {
						_stubstar2names `1'_*, nvars(`num_cats') outcome
						forvalues outno=1/`num_cats' {
							gen `vartype' `1'_`outno' = `=cond(`outno'<=`num_cuts'[`eqno',1], "normal([cut_`eqno'_`outno']_cons - `xb')", "1")' ///
												    - `=cond(`outno'>1, "normal([cut_`eqno'_`=`outno'-1']_cons - `xb')", "0")'
							label var `1'_`outno' "Pr(`depvar'=`=`cat'[`eqno', `outno']')"
						}
					}
					else {
						if substr(`"`outcome'"', 1, 1) == "#" {
							local outcome = substr(`"`outcome'"', 2, .)
							if `outcome' > `num_cats' {
								di as err `"There is no outcome #`outcome'. There are only `num_cats' outcomes for equation #`eqno'."'
								exit 111
							}
						}
						else {
							local i 1
							while `i' <= `num_cats' & `cat'[`eqno', `i']!=`outcome' {
								local ++i
							}
							if `i' > `num_cats' {
								di as error `"Outcome `outcome' not found in equation `eqno'. outcome() must either be a value of `depvar' or #1, #2, ..."'
								exit 111
							}
							local outcome `i'
						}
						gen `vartype' `1' = `=cond(`outcome'<=`num_cuts'[`eqno',1], "normal([cut_`eqno'_`outcome']_cons - `xb')", "1")' ///
											- `=cond(`outcome'>1, "normal([cut_`eqno'_`=`outcome'-1']_cons - `xb')", "0")'
						label var `1' "Pr(`depvar'=`=`cat'[`eqno', `outcome']')"
					}
				}
				else if `"`outcome'"' == "" {
					gen `vartype' `1' = normal(`xb')
					label var `1' "Pr(`depvar')"
				}
				else {
					di as err "Equation #`eqno' is not ordered probit. outcome() is not allowed."
					exit 197
				}
			}
		}
		macro shift
	}
end
