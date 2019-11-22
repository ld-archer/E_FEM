*! cmp 5.2.5 22 August 2012
*! David Roodman, Center for Global Development, Washington, DC, www.cgdev.org
*! Copyright David Roodman 2007-12. May be distributed free.
* Version history at bottom
cap program drop cmp
program define cmp, sortpreserve properties(user_score svyb svyj svyr mi)
	version 10.0
	cap version 11.0
	
	if replay() {
		if "`e(cmd)'" != "cmp" error 301
		if _by() error 190
		Display `0'
		exit 0
	}
	global cmp_out 0
	global cmp_cont 1
	global cmp_left 2
	global cmp_right 3
	global cmp_probit 4
	global cmp_oprobit 5
	global cmp_mprobit 6
	global cmp_int 7
	global cmp_trunc 8
	global cmp_roprobit 9
	
	if `"`0'"' == "setup" {
		di as txt "$" "cmp_out      = " as res 0
		di as txt "$" "cmp_cont     = " as res 1
		di as txt "$" "cmp_left     = " as res 2
		di as txt "$" "cmp_right    = " as res 3
		di as txt "$" "cmp_probit   = " as res 4
		di as txt "$" "cmp_oprobit  = " as res 5
		di as txt "$" "cmp_mprobit  = " as res 6
		di as txt "$" "cmp_int      = " as res 7
		di as txt "$" "cmp_trunc    = " as res 8
		di as txt "$" "cmp_roprobit = " as res 9
		exit 0
	}

	cap ghk2version
	if _rc | "`r(version)'" < "01.41.00" {
		di as err "Error: {cmd:cmp} works with {cmd:ghk2()} version 1.4.1 or later."
		di `"To install or update it, type or click on {stata "ssc install ghk2, replace"}. Then restart Stata."'
		exit 601
	}

	cmp_clear

	syntax anything(equalok id="model" name=model) [pw fw aw iw/] [if] [in], INDicators(string asis) [svy GHKAnti GHKDraws(string) ///
		GHKType(string) QUIetly noLRtest CLuster(varname) Robust vce(string) SCore(string) Level(real `c(level)') predict lnl(string) ///
		CONSTraints(numlist) TECHnique(string) INTERactive noDRop init(namelist min=1 max=1) lf pseudod2 PSampling(numlist min=1 max=2) ///
		STRUCtural REVerse noESTimate REDraws(string) COVariance(string) *] 
	if "`pseudod2'" != "" {
		di as err "The pseudod2 option is no longer supported."
		cmp_clear
		exit 198
	}
	local structural = "`structural'" != ""
	global cmp_reverse = "`reverse'" != ""
	mata _reverse = $cmp_reverse
	local cmdline `0'
	
	if c(stata_version) < 10 & `"`vce'"' != "" {
		di as err "{cmd:cmp} only accepts the {cmd:vce()} option in Stata version 10 or higher."
		exit 198
	}

	if c(stata_version) < 11.1 {
		di as res _n "Note: cmp runs faster in Stata versions 11.2 and later."
		if c(stata_version) >= 11.0 {
			di as res "You should be able to upgrade to 11.2 for free. Type or click on {stata "update executable"}."
		}
	}
	
	_get_eformopts, soptions eformopts(`options')
	local eform `s(eform)'
	local options `s(options)'

	marksample touse
	
	if "`svy'" != "" {
		svymarkout `touse'
		svyopts modopts diopts options, `options' `eform' level(`level')
		local subopt subpop(`s(subpop)')
		local meff `s(meff)'
	}
	else local diopts `eform' level(`level')

	if "`subpop'"=="" local subpop 1
		else markout `touse' `subpop'

	mlopts mlopts, `options'
	local collinear = s(collinear)

	Parse `model' // parse the equations
	local depvar $parse_y
	global cmp_d $parse_d
	global parse_wtypeL `weight'
	global parse_wexpL `exp'

	local 0 `ghkdraws'
	syntax [anything], [type(string) ANTIthetics]
	if `"`ghktype'"' != "" & `"`type'"' != "" & `"`ghktype'"' != `"`type'"' & `"`ghktype'`type'"' != "halton" {
		di as res _n "Warning: {cmd:type(`type')} suboption overriding deprecated {cmd:ghktype(`ghktype')} option."
	}
	if `"`type'"' != "" local ghktype `type'
	local 0, ghkdraws(`anything')
	syntax, [ghkdraws(numlist integer>=1 max=1)]
	if `"`ghktype'"'=="" local ghktype halton
	else if inlist(`"`ghktype'"', "halton", "hammersley", "ghalton", "random") == 0 {
		di as err `"The {cmdab:ghkt:ype()} option must be "halton", "hammersley", "ghalton", or "random". It corresponds to the {cmd:{it:type}} option of {cmd:ghk()}. See help {help mf_ghk}."'
		exit 198
	}
	mata _ghkType="`ghktype'"; _ghkAnti = `="`antithetics'"!="" | "`ghkanti'"!=""'; _ghkDraws=0`ghkdraws'

	if `"`covariance'"' == "" {
		forvalues l=1/$parse_L {
			global cmp_covariance`l' unstructured
		}
	}
	else {
		local covariance: subinstr local covariance "." "unstructured", word all
		if `: word count `covariance'' != $parse_L {
			di as err "The {cmdab:cov:ariance()}, if used, must contain one entry for each of the $parse_L levels in the model."
			cmp_clear
			exit 198
		}
		else {
			tokenize `covariance'
			forvalues l=1/$parse_L {
				local 0, ``l''
				syntax, [UNstructured EXchangeable INDependent]
				global cmp_covariance`l' `unstructured'`exchangeable'`independent'
				if inlist("${cmp_covariance`l'}", "unstructured", "exchangeable", "independent") == 0 {
					di as err `"Each entry in the {cmdab:cov:ariance()} option must be "unstructured", "." (equivalent to "unstructured"), "exchangeable", or "independent"."'
					exit 198
				}
			}
		}
	}
	forvalues l=1/$parse_L {
		local FixedRhoFill`l' = cond("${cmp_covariance`l'}"=="independent", 0, .)
	}

	if "`lf'" != "" & $parse_L > 1 & c(stata_version) <= 11.1 {
		di as err "The lf option is not available for multi-level models in Stata version 11.1 or earlier."
		cmp_clear
		exit 198
	}
	
	local t : subinstr local indicators "(" "", all
	if $cmp_d != `: word count `: subinstr local t ")" "", all'' {
		di as err "The indicators() option must contain $cmp_d variables, one for each equation."
		di as err `"Did you forget to type {stata "cmp setup"}?"'
		exit 198
	}

	local 0 `redraws'
	syntax [anything], [type(string) ANTIthetics STeps(numlist integer min=1 max=1 >0)]
	local 0, redraws(`anything')
	syntax, [redraws(numlist integer>=1)]
	if $parse_L>1 & $parse_L != `: word count `redraws'' + 1 {
		di as err "For multilevel models, the redraws() option must be included, with one entry for each level except the lowest."
		exit 198
	}
	if 0`steps'==0 {
		if $parse_L==1 local steps 1
		else {
			local steps = round(ln(1+`:word `=$parse_L-1' of `redraws'' * (1 + ("`antithetics'"!=""))))
		}
	}
	if `"`type'"'=="" local type halton
	else if inlist(`"`type'"', "halton", "hammersley", "ghalton", "random") == 0 {
		di as err `"The {cmd:redraws()} {cmd:type()} suboption must be "halton", "hammersley", "ghalton", or "random"."'
		exit 198
	}
	else if "`type'"=="hammersley" & "`ghktype'"=="hammersley" {
		di as err "Random effects and GHK sequences shouldn't both be Hammersley since this will assign the same draws to the first dimension of each."
		exit 198
	}
	mata _REType="`type'"; _REAnti = `=1+("`antithetics'"!= "")'

	global cmp_max_cuts 0
	global cmp_tot_cuts 0
	global cmp_num_mprobit_groups 0
	global cmp_num_roprobit_groups 0
	global cmp_mprobit_ind_base 20
	global cmp_roprobit_ind_base 40
	global cmp_intreg 0
	global cmp_truncreg 0
	local asprobit_eq 0
	tempvar _touse n asmprobit_dummy_sum asmprobit_ind
	tempname cmp_nonbase_cases
	qui {
		gen double _cmp_lnfi = .
		gen byte `_touse' = 0
		tokenize `"`indicators'"', parse("() ")
		local parse_eqno 0
		local cmp_eqno 0
		while `"`1'"' != "" {
			if (`"`1'"' == ")" & `asprobit_eq' == 0) | (`"`1'"' == "(" & `asprobit_eq') {
				noi di as err "too many " `1'
				exit 132
			}
			if `"`1'"'==")" {
				if "`mro'" == "m" {
					count if `asmprobit_dummy_sum'!=1 & `touse' & _cmp_ind`first_asprobit_eq'
					if r(N) {
						noi di as err "For multinomial probit groups, exactly one dependent variable must be non-zero for each observation."
						exit 132
					}
					replace _cmp_ind`first_asprobit_eq'=`asmprobit_ind'*(_cmp_ind`first_asprobit_eq'!=0) // store choice info in indicator var for first equation
					replace _cmp_rev_ind`first_asprobit_eq' = _cmp_ind`first_asprobit_eq'
					drop `asmprobit_ind' `asmprobit_dummy_sum'
				}
				mat cmp_`mro'probit_group_inds[${cmp_num_`mro'probit_groups}, 2] = `cmp_eqno'
				mat cmp_nonbase_cases = nullmat(cmp_nonbase_cases) , 0 , J(1, `asprobit_eq'-2, 1)
				local asprobit_eq 0
				local mro
				macro shift
				continue
			}

			local ++parse_eqno
			local ++cmp_eqno
			local num_alts 0

			if `"`1'"'=="(" {
				macro shift
				if `"`1'"' == ")" continue
				local asprobit_eq 1
				local first_asprobit_eq `cmp_eqno'
				if "${parse_x`parse_eqno'}" == "" { // assure nocons for first eq in asprobit group or leave cons in but constrained to 0
					constraint free
					local _constraints `_constraints' `r(free)'
					constraint `r(free)' [${parse_eq`parse_eqno'}]_cons
				}
				else global parse_xc`parse_eqno' nocons			
			}

			gen byte _cmp_ind`cmp_eqno' = `1'
			count if inlist(_cmp_ind`cmp_eqno', 0, 1, 2, 3, 4, 5, 6, 7, 8, 9)==0 & _cmp_ind`cmp_eqno' < . & `touse'
			if r(N) {
				di as err "Indicator for ${parse_y`parse_eqno'} must only evaluate to integers between 0 and 9."
				exit 198
			}

			foreach macro in eq x xc xo xe {
				global cmp_`macro'`cmp_eqno' ${parse_`macro'`parse_eqno'}
			}
			global cmp_y`cmp_eqno' ${parse_y`parse_eqno'}

			count if _cmp_ind`cmp_eqno'==7 & `touse'
			if r(N) { // interval regression
				global cmp_y`cmp_eqno'_L : word 1 of ${cmp_y`cmp_eqno'}
				global cmp_y`cmp_eqno'   : word 2 of ${cmp_y`cmp_eqno'}
				global cmp_intreg 1
				global cmp_intreg`cmp_eqno' 1
				replace _cmp_ind`cmp_eqno' = ${cmp_y`cmp_eqno'}<. if _cmp_ind`cmp_eqno'==7 & ${cmp_y`cmp_eqno'}==${cmp_y`cmp_eqno'_L}
				replace _cmp_ind`cmp_eqno' = 0 if _cmp_ind`cmp_eqno'==7 & ${cmp_y`cmp_eqno'}<${cmp_y`cmp_eqno'_L} & ${cmp_y`cmp_eqno'_L}<.
				markout _cmp_ind`cmp_eqno' ${parse_x`parse_eqno'}
			}
			else {
				markout _cmp_ind`cmp_eqno' ${parse_x`parse_eqno'} ${parse_y`parse_eqno'}
				global cmp_y`cmp_eqno'_L . // just to prevent syntax errors in evaluators
				global cmp_intreg`cmp_eqno' 0
			}

			if `"${parse_tr`parse_eqno'}"' != "" { // truncated regression
				gen double _cmp_y`cmp_eqno'_L = `: word 1 of ${parse_tr`parse_eqno'}'
				gen double _cmp_y`cmp_eqno'_U = `: word 2 of ${parse_tr`parse_eqno'}'
				global cmp_y`cmp_eqno'_L _cmp_y`cmp_eqno'_L
				global cmp_y`cmp_eqno'_U _cmp_y`cmp_eqno'_U
				global cmp_truncreg 1
				global cmp_truncreg`cmp_eqno' 1
				replace _cmp_ind`cmp_eqno' = 0 if _cmp_ind`cmp_eqno'==8 & ///
					((${cmp_y`cmp_eqno'}<=${cmp_y`cmp_eqno'_L} & ${cmp_y`cmp_eqno'_L}<.) | ${cmp_y`cmp_eqno'}>=${cmp_y`cmp_eqno'_U})
			}
			else {
				global cmp_y`cmp_eqno'_U . // just to prevent syntax errors in evaluators
				global cmp_truncreg`cmp_eqno' 0
			}

			global cmp_eq`cmp_eqno' = cond("${parse_eq`parse_eqno'}"=="eq`parse_eqno'", subinstr("${cmp_y`parse_eqno'}", ".", "", .), "${parse_eq`parse_eqno'}")
			if "`: list eqnames & global(cmp_eq`cmp_eqno')'" != "" global cmp_eq`cmp_eqno' `=substr("${cmp_eq`cmp_eqno'}",1,29)'`cmp_eqno'
			local eqnames `eqnames' ${cmp_eq`cmp_eqno'}

			replace `_touse' = `_touse' | _cmp_ind`cmp_eqno'

			count if _cmp_ind`cmp_eqno'==5 & `touse'
			if r(N) { // ordered probit
				tempvar t
				// copy in order to get rid of any non-numeric value labels, which can't be stored in e(cat)
				gen `:type ${cmp_y`cmp_eqno'}' `t' = ${cmp_y`cmp_eqno'} if `touse' & _cmp_ind`cmp_eqno'==5 
				egen int _cmp_y`cmp_eqno' = group(`t') if `t' < ., lname(cmp_y`cmp_eqno'_label)
				drop `t'
				sum _cmp_y`cmp_eqno' if `touse' & _cmp_ind`cmp_eqno'==5, meanonly
				local t = r(max) - 1
				mat cmp_num_cuts = nullmat(cmp_num_cuts) \ `t'
				if $cmp_max_cuts < `t' global cmp_max_cuts = `t'
				global cmp_tot_cuts = $cmp_tot_cuts + `t'
				forvalues j=1/`t' {
					local cutparams `cutparams' /cut_`cmp_eqno'_`j'
				}
				global cmp_y`cmp_eqno' _cmp_y`cmp_eqno'
				local i_oprobit_ys `i_oprobit_ys' i._cmp_y`cmp_eqno'
			}
			else {
				local lrtest `lrtest' ${cmp_xc`cmp_eqno'}
				mat cmp_num_cuts = nullmat(cmp_num_cuts) \ 0
			}
	
			count if _cmp_ind`cmp_eqno'==6 & `touse'
			local N_mprobit `r(N)'
			count if _cmp_ind`cmp_eqno'==9 & `touse'
			local N_roprobit `r(N)'
			if `N_mprobit' | `N_roprobit' { // multinomial or rank-ordered probit
				if (`N_mprobit' & "`mro'" == "ro") | (`N_roprobit' & "`mro'" == "m") {
					di as err "Cannot mix multinomial and rank-ordered indicator values in the same group."
					exit 148
				}
				count if inlist(_cmp_ind`cmp_eqno', 0, 6, 9)==0 & `touse'
				if r(N) | `N_mprobit'&`N_roprobit' {
					noi di as err "Dependent variables modeled as `=cond(`N_mprobit',"multinomial","rank-ordered")' probit may not be modeled differently for other observations in the same equation."
					exit 148
				}
				
				if `asprobit_eq'==1 & "`mro'" == "" { // starting new asprobit group?
					if `N_mprobit' {
						gen byte `asmprobit_dummy_sum' = 0 if `touse'
						gen byte `asmprobit_ind' = $cmp_mprobit_ind_base + `cmp_eqno' - 1 if `touse'
						local mro m
					}
					else local mro ro
					
					global cmp_num_`mro'probit_groups = ${cmp_num_`mro'probit_groups} + 1
					mat cmp_`mro'probit_group_inds = nullmat(cmp_`mro'probit_group_inds) \ (`cmp_eqno', .)
				}
				
				if `asprobit_eq' == 0 { // non-as mprobit?
					if `N_roprobit' {
						noi di as err "Rank-ordered probit indicators must be grouped in parentheses."
						exit 148
					}
					global cmp_num_mprobit_groups = $cmp_num_mprobit_groups + 1

					egen int _cmp_y`cmp_eqno' = group(${cmp_y`cmp_eqno'}) if `touse' & _cmp_ind`cmp_eqno'==6, lname(cmp_y`cmp_eqno'_label)

					sum _cmp_y`cmp_eqno', meanonly
					local num_alts = r(max) - 1
					if `num_alts' == 0 {
						di as err "There is only one outcome in ${cmp_y`cmp_eqno'}."
						exit 148
					}

					mat cmp_mprobit_group_inds = nullmat(cmp_mprobit_group_inds) \ (`cmp_eqno', `cmp_eqno'+`num_alts')
					mat cmp_nonbase_cases = nullmat(cmp_nonbase_cases) , 0 , J(1, `num_alts', 1)

					// indicator for first equation holds choice info
					replace _cmp_ind`cmp_eqno' = $cmp_mprobit_ind_base + _cmp_y`cmp_eqno' + `cmp_eqno' - 1 if `touse' & _cmp_ind`cmp_eqno'==6

					xi, noomit prefix(_mp) i._cmp_y`cmp_eqno'
					forvalues i=`cmp_eqno'/`=`cmp_eqno'+`num_alts'' {
						ren _mp_cmp_y`cmp_eqno'_`=`i'+1-`cmp_eqno'' _mp_cmp_y`i'
						global cmp_y`i' _mp_cmp_y`i'
					}

					LabelMprobitEq `cmp_eqno' `cmp_eqno' `parse_eqno' 1

					forvalues j=`=`cmp_eqno'+1'/`=`cmp_eqno'+`num_alts'' { // Generate all equations associated with this, the user's one mprobit equation
						gen byte _cmp_ind`j' = 6*(_cmp_ind`cmp_eqno'>0) if `touse'
						LabelMprobitEq `j' `cmp_eqno' `parse_eqno' `j'
						foreach macro in x xc xo xe {
							global cmp_`macro'`j' ${cmp_`macro'`cmp_eqno'}
						}
						mat cmp_num_cuts = cmp_num_cuts \ 0
					}
					label drop cmp_y`cmp_eqno'_label

					// first equation in expanded group is placeholder, for consistency with asmprobit--constant-only and constant=0
					constraint free
					local _constraints `_constraints' `r(free)'
					constraint `r(free)' [${cmp_eq`cmp_eqno'}]_cons
					foreach macro in x xc xo xe {
						global cmp_`macro'`cmp_eqno' 
					}
				}
				else {
					if "`mro'" == "m" {
						replace `asmprobit_ind' = `asmprobit_ind' + (${cmp_y`cmp_eqno'}!=0) * `asprobit_eq' if _cmp_ind`cmp_eqno'
						replace `asmprobit_dummy_sum' = `asmprobit_dummy_sum' + (${cmp_y`cmp_eqno'}!=0) if _cmp_ind`cmp_eqno'
						replace _cmp_ind`cmp_eqno' = 0 if _cmp_ind`first_asprobit_eq' == 0  // exclude obs missing for base case
					}
					else {
						count if `touse' & (mod(${cmp_y`cmp_eqno'}, 1) | ${cmp_y`cmp_eqno'}<0 | ${cmp_y`cmp_eqno'}>`=maxbyte()-$cmp_roprobit_ind_base')
						if r(N) {
							noi di as err "Dependent variables modeled as rank-ordered probit must take integer values between 0 and `=maxbyte()-$cmp_roprobit_ind_base'."
							exit 148
						}
						replace _cmp_ind`cmp_eqno' = ${cmp_y`cmp_eqno'} + $cmp_roprobit_ind_base if _cmp_ind`cmp_eqno'
					}
					local ++asprobit_eq
				}
			}
			else {
				if `asprobit_eq' {
					if "`mro'"=="m" noi di as err "Each indicator in an alternative-specific multinomial probit group must evaluate to 6 ($"  "cmp_mprobit) at least once."
					           else noi di as err "Each indicator in "                   "a rank-ordered probit group must evaluate to 9 ($" "cmp_roprobit) at least once."
					exit 148
				}
				mat cmp_nonbase_cases = nullmat(cmp_nonbase_cases) , 1
			}

			forvalues i=`cmp_eqno'/`=`cmp_eqno'+`num_alts'*(`asprobit_eq'==0)' { // do once unless expanding non-as mprobit eq
				// revise indicator variables to combine left-censored tobit and probit/Y=0 and ditto right-censored and probit/Y=1
				// since values passed to optimizer have same derivative w.r.t XB (Y-XB and -XB and XB-Y and XB)
				gen byte _cmp_rev_ind`i' = cond(_cmp_ind`i'==4, 2+(${cmp_y`i'}!=0), _cmp_ind`i') if `touse' 
				gen double _cmp_e`i' = .

				if `i'==1 mat cmp_fixed_rhos$parse_L = 0
				else      mat cmp_fixed_rhos$parse_L = (cmp_fixed_rhos$parse_L, J(`i'-1, 1, .)) \ J(1, `i', `FixedRhoFill$parse_L')

				// create sig param unless mprobit eq 1-2 or (ordered) probit
				count if inlist(_cmp_ind`i', 4, 5) & `touse'
				if r(N) {
					mat cmp_fixed_sigs$parse_L = nullmat(cmp_fixed_sigs$parse_L), 1
					forvalues l=1/`=$parse_L-1' {
						mat cmp_fixed_sigs`l' = nullmat(cmp_fixed_sigs`l'), .
					}
					count if !inlist(_cmp_ind`i', 0, 5) & `touse'
					if r(N) == 0 global cmp_xc`i' nocons
				}
				else if `asprobit_eq'-1==1 | (`num_alts' & `i'==`cmp_eqno') { // 1st eq of m/roprobit. sig=1 for structural, 0 otherwise, all levels
					forvalues l=1/$parse_L {
						mat cmp_fixed_sigs`l' = nullmat(cmp_fixed_sigs`l'), `structural'
					}
				}
				else if `asprobit_eq'-1==2 | (`num_alts' & `i'==`cmp_eqno'+1) { // 2nd eq of m/roprobit. sig=1 for structural, 2 otherwise, bottom level
					mat cmp_fixed_sigs$parse_L = nullmat(cmp_fixed_sigs$parse_L), sqrt(2-`structural')
					forvalues l=1/`=$parse_L-1' {
						mat cmp_fixed_sigs`l' = nullmat(cmp_fixed_sigs`l'), .
					}
				}
				else {
					forvalues l=1/`=$parse_L-1' {
						mat cmp_fixed_sigs`l' = nullmat(cmp_fixed_sigs`l'), .
					}
					if `i'>=`cmp_eqno'+2 & "${parse_iia`parse_eqno'}" != "" { // impose IIA for non-as mprobits
						mat cmp_fixed_sigs$parse_L = nullmat(cmp_fixed_sigs$parse_L), sqrt(2-`structural')
						forvalues j=`=`cmp_eqno'+1'/`=`i'-1' {
							mat cmp_fixed_rhos$parse_L[`i',`j'] = cond(`structural', 0, atanh(0.5))
						}
					}
					else {
						mat cmp_fixed_sigs$parse_L = nullmat(cmp_fixed_sigs$parse_L), .
						local sigparams$parse_L `sigparams$parse_L' /lnsig_`i' 
					}
				}

				global cmp_id`i' ${parse_id`parse_eqno'}
				forvalues l=1/$parse_L {
					global cmp_rc`i'_`l' $parse_rc`usereqno'_`l'
				}	
				
				global cmp_intreg`i' ${cmp_intreg`cmp_eqno'}
				global cmp_truncreg`i' ${cmp_truncreg`cmp_eqno'}
			}

			if `asprobit_eq'==0 local cmp_eqno = `cmp_eqno' + `num_alts'
			macro shift
		}

		replace `touse' = `touse' & `_touse'

		count if `touse'
		if r(N)==0 {
			noi di as err "No observations."
			exit 2000
		}
		markout `touse' _cmp_ind*

		if "`lnl'" != "" gen double `lnl' = .
	}

	if $cmp_tot_cuts | $cmp_intreg | $cmp_truncreg  {
		qui forvalues i=1/`cmp_eqno' {
			gen double _cmp_f`i' = .
			if $cmp_truncreg gen double _cmp_g`i' = .
		}
	}

	global cmp_d = `cmp_eqno'

	xi, prefix(" ") noomit `i_oprobit_ys'

	mat cmpLevels = J($cmp_d, $parse_L, 0)
	forvalues eq = 1/$cmp_d {
		foreach id in ${cmp_id`eq'} {
			local l: list posof "`id'" in global(parse_id)
			mat cmpLevels[`eq', `l'] = cmp_fixed_sigs`l'[1,`eq']>0 | "`id'"=="_n" // for efficiency, don't simulate REs with variance=0
		}
	}
	mata _Eqs=J($parse_L, 1, NULL); for (l=$parse_L; l; l--) _Eqs[l]=&OneInds(st_matrix("cmpLevels")[,l]')
	
	local technique technique(`technique')
	if c(stata_version) >= 10 {
		_vce_parse, optlist(robust jackknife bootstrap oim opg) argoptlist(cluster) pwallowed(robust jackknife bootstrap cluster oim opg) old: `wgtexp', `robust' cluster(`cluster') vce(`vce')
		local vce `r(vceopt)'
		local robust `r(robust)'
		local cluster `r(cluster)'
	}
	else {
		local vce `robust' cluster(`cluster')
		if "`cluster'" != "" {
			di as res "Warning: In defining clusters for computing standard errors, Stata 9 drops observations with missing values in any RHS variables,"
			di as res "even when the missing values only occur in variables that are in equations that are excluded for those observations"
			di as res "(with a 0 value in the relevant {cmd:indicator()} variables). Later versions of Stata do not behave in this way."
		}
	}
	markout `touse' `cluster', strok

	tokenize $parse_id
	forvalues l = 1/`=$parse_L-1' {
		mat cmp_fixed_rhos`l' = J($cmp_d, $cmp_d, `FixedRhoFill`l'')
		local ids `ids' ``l''
		qui egen long _cmp_id`l' = group(`ids') if `touse'
	}

	if $parse_L == 1 { // for 1-level models, ml will handle weights
		if "$parse_wexpL" != "" {
			tempvar wvar
			qui gen double `wvar' = $parse_wexpL if `touse'
			local wgtexp [$parse_wtypeL = `wvar']
			local awgtexp [aw = `wvar']
			markout `touse' `wvar'
		}
	}
	else {
		sort _cmp_id*

		global parse_wtype$parse_L $parse_wtypeL
		global parse_wexp$parse_L $parse_wexpL
		forvalues l = 1/$parse_L {
			local cmp_ids `cmp_ids' _cmp_id`l'
			if "${parse_wtype`l'}" != "" {
				qui gen double _cmp_weight`l' = ${parse_wexp`l'} if `touse'
				markout `touse' _cmp_weight`l'
				replace `touse' = 0 if _cmp_weight`l'<=0

				if "${parse_wtype`l'}" == "fweight" {
					qui count if trunc(_cmp_weight`l') != _cmp_weight`l' & `touse'
					if r(N) {
						di as err "May not use noninteger frequency weights."
						cmp_clear
						error 401
					}
				}
					
				if "${parse_wtype`l'}" == "pweight" & 0`wcluster' == 0 {
					local wcluster 1
					if "`cluster'" != "`:word `l' of $parse_id'" {
						if "`cluster'`robust'" != "" {
							di as res _n "Warning: " as txt "[pweight = ${parse_wexp`l'}]" as res " would usually imply " as txt "vce(cluster `:word `l' of $parse_id')."
							di as res "Implementing " as txt `"`=cond("`cluster'"=="", "robust", "cluster `cluster'")'"' as res " instead."
						}
						else {
							local vce vce(cluster `:word `l' of $parse_id')
							local lrtest pweight
							di as res _n "Note: [pweight = ${parse_wexp`l'}] implies vce(cluster `:word `l' of $parse_id')"
						}
					}
				}

				if `l' < $parse_L {
					tempvar t
					qui by `cmp_ids': egen float `t' = sd(_cmp_weight`l') if `touse'
					qui count if `t' & `t'<. & `touse'
					if r(N) {
						di as error "Weights for level " as res "`:word `l' of $parse_id'" as err " must be constant within groups."
						cmp_clear
						error 101
					}
					drop `t'
				}
			}
		}
	}

	global cmp_lf `lf'
	if "`lf'" != "" & c(stata_version) <= 11.1 {
		qui gen long `n' = _n if `touse'
		sum `n' if `touse', meanonly
		global cmp_n = r(min) // id for a row in sample, used by cmp_lnL() to grab lnsig's, atanhrho's, cuts
		drop `n'
		local method_spec lf cmp_lf
 	}
	else local method_spec = cond("`lf'"!="",  ///
	                             "lf0 cmp_lf1",                      ///
	                             cond(c(stata_version)>11.1, ///
									"lf1 cmp_lf1",       ///
									"d1 cmp_d1"))

	if "`predict'" != "" {
		forvalues l=1/$parse_L {
			mat cmp_fixed_rhos`l' = e(fixed_rhos`l')
			mat cmpSigScoreInds`l' = e(sig_score_inds`l')
		}
		global cmp_num_scores = e(num_scores)
		mata _NumScores = $cmp_num_scores; _first_call = 1
		mata _NumREDraws = 1 \ strtoreal(tokens("`redraws'"))' * _REAnti
		MakedSigdParams
	}

	mata _num_mprobit_groups  = $cmp_num_mprobit_groups;   _mprobit_group_inds=st_matrix("cmp_mprobit_group_inds"); _mprobit_ind_base = $cmp_mprobit_ind_base
	mata _num_roprobit_groups = $cmp_num_roprobit_groups; _roprobit_group_inds=st_matrix("cmp_roprobit_group_inds"); _roprobit_ind_base = $cmp_roprobit_ind_base
	mata _nonbase_cases = st_matrix("cmp_nonbase_cases"); _L = $parse_L
	mata _NumCuts = sum(_vNumCuts=st_matrix("cmp_num_cuts")); _intreg = $cmp_intreg; _truncreg = $cmp_truncreg
	mata _interactive=`="`interactive'"!=""' 

	forvalues i=1/$cmp_d {
		if cmp_nonbase_cases[1,`i'] { 
			forvalues l=1/`=$parse_L-1' {
				if cmpLevels[`i',`l'] { 
					local sigparams`l' `sigparams`l'' /lnsig_`l'_`i'
				}
			}
		}
	}

	forvalues l=$parse_L(-1)1 {
		forvalues i=1/$cmp_d {
			forvalues j=`=`i'+1'/$cmp_d {
				if !cmp_nonbase_cases[1,`i'] | !cmp_nonbase_cases[1,`j'] {
					mat cmp_fixed_rhos`l'[`j',`i'] = 0
				}
				else if cmp_fixed_rhos`l'[`j',`i']==. & "${cmp_covariance`l'}" != "exchangeable" {
					local sigparams`l' `sigparams`l'' /atanhrho`_l'_`i'`j'
				}   
			}
		}
		if "${cmp_covariance`l'}" == "exchangeable" {
			local sigparams`l' `sigparams`l'' /atanhrho`_l'
		}
		
		local _l _`=`l'-1'
	}
	forvalues l=1/$parse_L {
		local sigparams `sigparams' `sigparams`l''
	}
	local auxparams `cutparams' `sigparams'

	if "`predict'" != "" exit  // done reconstructing _cmp_* variables to carry out predict (of scores)

	if "`init'" == "" {
		tempname b bfull
		// Fit individual models before mis-specifed and constant-only ones in case perfect probit predictors shrink some eq samples
		di as res _n "Fitting individual models as starting point for full model fit."
		`quietly' do_InitSearch InitSearch if `touse' `wgtexp', `svy' adjustprobitsample `drop' auxparams(`auxparams')
		mat `bfull' = r(b)
	}
	else InitSearch if `touse' `wgtexp', `svy' adjustprobitsample `drop' auxparams(`auxparams') quietly

	if "`estimate'" != "" {
		NoEstimate `bfull'`init' `wgtexp'
		ereturn display
		cmp_clear
		di as res _n `"Full model not fit. To view the initial coefficient matrix, type or click on {stata "mat list e(b)"}."'
		di as res "You can copy and modify this matrix, then pass it back to {cmd:cmp} with the {cmd:init()} option."
		exit 0
	}

	local initconstraints `r(initconstraints)'
	local auxparams `r(auxparams)'
	global cmp_num_scores = $cmp_d + `: word count `auxparams''
	mata _NumScores = $cmp_num_scores

	tempvar t
	egen `t' = anycount(_cmp_rev_ind*), values(0)
	qui replace `touse' = 0 if `t'==$cmp_d
	
	MakedSigdParams

	forvalues i=1/$cmp_d { // save these for full fit in case they get modified by 1only or meff calls to InitSearch
		local cmp_x`i' ${cmp_x`i'}
		local cmp_xc`i' ${cmp_xc`i'}
	}

	if "`meff'" != "" {
		di as res _n "Fitting misspecified model."
		if "`init'" == "" {
			qui InitSearch if `touse' & (`subpop'), `drop' auxparams(`auxparams')
			mat `b' = r(b)
		}
		Estimate `method_spec' if `touse' & (`subpop'), init(`b'`init') `vce' auxparams(`auxparams') psampling(`psampling') resteps(`steps') ///
			constraints(`constraints' `_constraints' `initconstraints') `mlopts' `technique' `quietly' redraws(`redraws')
		if _rc==0 {
			tempname vsmp
			mat `vsmp' = e(V)
		}
	}

	if "`lrtest'" == "" & `"`constraints'`robust'`cluster'`estimate'"'=="" & "`weight'"!="pweight" & "$parse_x"!="" {
		di as res _n "Fitting constant`=cond($cmp_d>1,"s","")'-only model for LR test of overall model fit."
		qui InitSearch if `touse' `wgtexp', `svy' 1only  auxparams(`auxparams')
		local 1onlyinitconstraints `r(initconstraints)'
		tempname b
		mat `b' = r(b)
		qui Estimate `method_spec' if `touse' `wgtexp', init(`b') constraints(`_constraints' `1onlyinitconstraints') psampling(`psampling') resteps(`steps') ///
		                `svy' `mlopts' `technique' auxparams(`auxparams') 1only `quietly' redraws(`redraws')
		if _rc==0 local lf0opt lf0(`e(rank)' `e(ll)')
	}

	forvalues i=1/$cmp_d {
		global cmp_x`i' `cmp_x`i''
		global cmp_xc`i' `cmp_xc`i''
	}

	foreach param in `auxparams' {
		if substr("`param'", 2, 2) == "ln" {
			local diparmopt `diparmopt' diparm(`=substr("`param'", 2, strlen("`param'")-1)', exp  label("`=substr("`param'", 4, strlen("`param'")-3)'"))
		}
		else if substr("`param'", 2, 5) == "atanh" {
			local diparmopt `diparmopt' diparm(`=substr("`param'", 2, strlen("`param'")-1)', tanh label("`=substr("`param'", 7, strlen("`param'")-6)'"))
		}
	}

	di as res _n "Fitting full model."
	cmp_full_model `method_spec' if `touse' `wgtexp', `vce' score(`score') `lf0opt' modopts(`modopts') mlopts(`mlopts') `technique' ///
		constraints(`_constraints' `initconstraints' `constraints') init(`bfull'`init') `svy' `interactive' psampling(`psampling') ///
		`quietly' auxparams(`auxparams') cmdline(`"`cmdline'"') lnl(`lnl') resteps(`steps') redraws(`redraws') ///
		vsmp(`vsmp') meff(`meff') eqnames(`eqnames') depvar(`depvar') ghkanti(`ghkanti') ghkdraws(`ghkdraws') ghktype(`ghktype') diparmopt(`diparmopt')

	constraint drop `_constraints' `initconstraints' `1onlyinitconstraints'

	if "`e(cmd)'"=="cmp" Display, `diopts'
end

* These lines are in a subroutine to work around Stata parsing bug with "if...quietly {"
cap program drop do_InitSearch
program define do_InitSearch, rclass
	version 10.0
	cap version 11.0
	di as res "Note: For programming reasons, these initial estimates may deviate from your specification."
	di as res "      For exact fits of each equation alone, run cmp separately on each."
	`*' // run InitSearch
	tempname b
	mat `b' = r(b)
	return matrix b = `b'
	return local auxparams `r(auxparams)'
	return local initconstraints `r(initconstraints)'
end

* perform full estimate. Program cmp is not eclass, so it can be called for non-estimating purposes without obliterating current estimates
* cmp_full_model is eclass, so it performs and saves full estimate
cap program drop cmp_full_model
program define cmp_full_model, eclass
	version 10.0
	cap version 11.0
	syntax anything if [pw fw aw iw], [auxparams(string) vsmp(string) meff(string) eqnames(string) depvar(string) ghkanti(string) ///
					ghkdraws(string) ghktype(string) diparmopt(string) cmdline(string) *]

	Estimate `anything' `if' [`weight'`exp'], auxparams(`auxparams') `options'
	
	if _rc==0 {
		mata _interactive = 1 // in case cmp_lf or cmp_lf1 or cmp_d2 reentered post-estimation

		if "`meff'" != "" _svy_mkmeff `vsmp'

		mata cmpSaveSigsAndObs()

		ereturn scalar k_aux = `: word count `auxparams''
		ereturn local wexp "= $parse_wexpL"
		forvalues i=1/$cmp_d {
			qui count if e(sample) & _cmp_rev_ind`i'
			ereturn scalar N`i' = r(N)
		}

		tempname t
		mat `t' = J($cmp_d, $cmp_max_cuts+1, .)
		mat rownames `t' = `eqnames'
		forvalues i=1/$cmp_d {
			if cmp_num_cuts[`i',1] {
				forvalues j=1/`=cmp_num_cuts[`i',1]+1' {
					mat `t'[`i',`j'] = `: label (_cmp_y`i') `j''
				}
			}
		}
		ereturn mat cat = `t'
		mat `t' = cmp_num_cuts
		mat rownames `t' = `eqnames'
		ereturn mat num_cuts = `t'
		
		ereturn scalar num_scores = $cmp_num_scores 
		forvalues l=1/$parse_L {
			ereturn mat fixed_rhos`l' = cmp_fixed_rhos`l'
			cap ereturn mat sig_score_inds`l' = cmpSigScoreInds`l'
		}
		
		foreach macro in diparmopt depvar ghkanti ghkdraws ghktype {
			ereturn local `macro' ``macro''
		}
		ereturn local indicators = `"`indicators'"'
		ereturn local eqnames `eqnames' `auxparams'
		ereturn local predict cmp_p
		ereturn local title Mixed-process `=cond($parse_L>1, "multilevel ", "")' regression
		ereturn local cmdline cmp `cmdline'
		ereturn local cmd cmp
	}
	cmp_clear
	if _rc==1 error 1
end

cap program drop MakedSigdParams
program define MakedSigdParams
	mata _dSigdParams = J($parse_L, 1, NULL)
	forvalues l=1/$parse_L {
		mata d = cols(L = *_Eqs[`l'])
		mata t = d==1? J(0,0,0) : cdr(designmatrix((d*(d-1)/2 \ OneInds(vech(st_matrix("cmp_fixed_rhos`l'")[L,L][|2,.\.,d-1|])':==.)')))'
		mata _dSigdParams[`l'] = &blockdiag(                                                                                        ///
		                             cdr(designmatrix((d \ OneInds(st_matrix("cmp_fixed_sigs`l'")[,L]:==.)')))' ,  ///
		                             "${cmp_covariance`l'}"=="exchangeable" ? rowsum(t) : t)
	}
end

cap program drop Parse
program define Parse
	version 10.0
	cap version 11.0
	local tsfv = cond(c(version)==11, "fv", "ts")
	
	local _cons _cons
	global parse_d 0
	gettoken eq eqs: 0, match(parenflag)
	while `"`eq'"' != "" {
		global parse_d = $parse_d + 1

		tokenize `"`eq'"', parse(" :")
		if "`2'" == ":" {
			confirm name `1'
			global parse_eq$parse_d `1'
			macro shift 2
		}

		local eq `*'
		gettoken 0 eq: eq, parse("=|")
		if "`0'" != "|" { // includes an FE equation?
			`tsfv'unab myy: `0'
			global parse_y $parse_y `myy'
			global parse_y$parse_d `myy'
			
			gettoken 0 eq: eq, parse("=")
			if `"`0'"' != "=" {
				di as err `"Missing "=": (`0')"'
				cmp_clear
				error 198
			}
			
			gettoken 0 eq: eq, parse("|")
			if "`0'" == "|" {
				local 0
				local eq |`eq'
			}
			syntax [varlist(`tsfv' ts default=none)], [noCONStant OFFset(varname) EXPosure(varname) TRUNCpoints(string) iia]

			if "`varlist'" != "" {
				`tsfv'unab varlist: `varlist'
				global parse_x$parse_d `varlist'
				global parse_x $parse_x `varlist'
				global parse_iia$parse_d `iia'
			}
			if "`constant'" != "" {
				global parse_xc$parse_d nocons
				if "${parse_x$parse_d}" == "" {
					di as err `"(`0')"'
					cmp_clear
					error 198
				}
			}
			if "`offset'"!="" | "`exposure'"!="" {
				if "`offset'" != "" & "`exposure'" != "" {
					di as err "Cannot specify both offset() and exposure()."
					cmp_clear
					error 198
				}
				global parse_xo$parse_d `offset'
				global parse_xe$parse_d `exposure'
			}
			if `"`truncpoints'"' != "" {
				tokenize `"`truncpoints'"'
				if `"`3'"' != "" | `"`2'"'=="" {
					di as error `"truncpoints(`"`truncpoints'"') invalid. Must have two arguments. Arguments with spaces must be quoted."'
					cmp_clear
					error 198
				}
				global parse_tr$parse_d `truncpoints'
			}
		}
		else local eq |`eq' // if no FE eq, stick the | back on the beginning
		
		gettoken 0 eq: eq, parse("|")
		while `"`0'"' != "" {
			gettoken 0 eq: eq, parse("|")
			if `"`0'"' != "|" {
				di as err `""|" not allowed in equation specification. Use "||"."'
				cmp_clear
				error 198
			}

			gettoken 0 eq: eq, parse("|")
			tokenize `0'
			local id `1'
			confirm name `id'
			if "`2'" != ":" {
				di as err `"Specify random effects starting with the group identifier variable and a ":"."'
				cmp_clear
				error 198
			}

			global parse_id: list global(parse_id) | id
			global parse_id$parse_d: list global(parse_id$parse_d) | id
			local L: list posof "`id'" in global(parse_id)
			macro shift 2
		
			local 0 `*'
			syntax [varlist(`tsfv' ts default=none)] [fw aw pw iw/], [noCONStant]

			if "${parse_wtype`L'}" == "" & "${parse_wexp`L'}" == ""  {
				global parse_wtype`L' `weight'
				global parse_wexp`L' `exp'
				if "`weight'"=="fweight" global parse_fweight 1
			}
			else if "${parse_wtype`L'}" != "`weight'" | "${parse_wexp`L'}" != `"`exp'"' {
				di as err "Weights more than once for the `id' level specified more than once."
				cmp_clear
				error 198
			}

			if "`constant'" == "" local varlist `varlist' _cons
			global parse_rc${parse_d}_`L': list global(parse_rc${parse_d}_`L') | varlist
			if `:list posof "_cons" in global(parse_rc${parse_d}_`L')' { // keep _cons at end in merging varlists for same id
				global parse_rc${parse_d}_`L' `:list global(parse_rc${parse_d}_`L') - _cons' _cons
			}
			
			gettoken 0 eq: eq, parse("|")
		}
		global parse_id$parse_d ${parse_id$parse_d} _n

		gettoken eq eqs: eqs, match(parenflag)
	}

	global parse_L: word count $parse_id

	if $parse_L > 1 { // draw together partial orderings implied by random effect sequences in each equation
		mata _X = I($parse_L)
		forvalues i=1/$parse_d {
			tokenize ${parse_id`i'}
			forvalues j=1/`=`:word count ${parse_id`i'}'-2' {
				mata _X[`:list posof "``j''" in global(parse_id)',`:list posof "``=`j'+1''" in global(parse_id)'] = 1
			}
		}
		mata _Y = _X; for (i=$parse_L-1; i; i--) _Y = _Y * _X
		mata _p = order(rowsum(_Y:!=0), -1) // permutation to make Y upper triangular
		mata st_local("t", strofreal(all(vech(_Y'[_p,_p]))))
		if `t' {
			mata st_global("parse_id", invtokens(tokens("$parse_id")[_p]))
			mata mata drop _p _X _Y
		}
		else {
			mata mata drop _p _X _Y
			di as err "Cannot determine hierarchical order of levels."
			di as err `"You can add a dummy equation like ""' as res "( || id1: || id2: || id3:)" as err `"" to specify the full ordering."'
			di as err "Don't include this equation in the " as res "indicators()" as err " option."
			exit 110
		}
	}

	local i 0
	forvalues j=1/$parse_d { // expunge dummy eqs
		if "${parse_y`j'}" != "" {
			local ++i

			if `i' != `j' {
				foreach macro in eq y x xo xe xc tr id {
					global parse_`macro'`i' ${parse_`macro'`j'}
					global parse_`macro'`j'
				}


				forvalues l=1/$parse_L {
					global parse_rc`i'_`l' ${parse_rc`j'_`l'}
					global parse_rc`j'_`l'
				}
			}

			if "${parse_eq`i'}" == "" {
				global parse_eq`i' eq`i'
			}
			local eqnames `eqnames' ${parse_eq$`i'}
		}
	}
	global parse_d `i'

	local t : list dups eqnames
	if "`t'" != "" {
		di as err "Multiply defined equations: `t'"
		exit 110
	}
	
	global parse_id $parse_id _n
	global parse_L: word count $parse_id
end
cap program drop NoEstimate
program NoEstimate, eclass
	version 10.0
	ereturn post `0'
	ereturn local title Mixed-process regression--initial fits only
	ereturn local cmdline cmp `cmdline'
	ereturn local cmd cmp
end
cap program drop Estimate
program Estimate, eclass
	version 10.0
	cap version 11.0
	syntax anything(name=method_spec) if/ [fw aw pw iw], [auxparams(string) psampling(string) svy score(string) interactive ///
		modopts(string) mlopts(string) init(string) constraints(string) technique(string) 1only quietly lnl(string) resteps(string) redraws(string) *]

	if "`weight'" != "" local awgtexp [aw`exp']
	
	local mlversion = cond(c(stata_version)>=11 & substr("`method_spec'",1,2)!="d2", "11", "`c(version)'")
	
	if "`interactive'" == "" & "`constraints'" == "" {
		forvalues i=1/$cmp_d {
			if "`1only'"=="" local xvars `xvars' ${cmp_x`i'}
			if "${cmp_xc`i'}"=="" local xvars `xvars' _cons
			foreach macro in y x xo xe {
				if "${cmp_`macro'`i'}" != "" & ("`macro'"!="x" | "`1only'"=="") {
					`=cond(c(version)==11,"fv","ts")'revar ${cmp_`macro'`i'}
					local `macro'_ts `r(varlist)'
				}
				else local `macro'_ts
			}
			local model `model' (${cmp_eq`i'}: `y_ts' = `x_ts', ${cmp_xc`i'} offset(`xo_ts') exposure(`xe_ts'))
		}
	}
	else {
		forvalues i=1/$cmp_d { 
			local model `model' (${cmp_eq`i'}: ${cmp_y`i'} = 
			if "`1only'"=="" local model `model' ${cmp_x`i'}
			local model `model', ${cmp_xc`i'} offset(${cmp_xo`i'}) exposure(${cmp_xe`i'}))
		}
	}
	local model `method_spec' `model' `auxparams'
	
	if "`psampling'" == "" {
		local psampling_cutoff 1
		local psampling_rate 2
		local u 1
	}
	else {
		count if `if'
		local N = r(N)
		tokenize `psampling'
		local psampling_cutoff = cond(`1'>=1, `1'/`N', `1')
		local psampling_rate = cond(0`2', 0`2', 2)
		tempvar u
		gen `u' = uniform() if `if'
	}

	tempname b sample
	while `psampling_cutoff' < `psampling_rate' {
		if "`psampling'" != "" {
			if `psampling_cutoff' < 1 di as res _n "Fitting on approximately " %1.0f `psampling_cutoff'*`N' " observations (approximately " %1.0f `psampling_cutoff'*100 "% of the sample)."
			else di as res _n "Fitting on full sample."
		}

		if `resteps'>1 mata __NumREDraws = J(`=$parse_L-1', 1, 1) :/ (_DrawMultipliers = strtoreal(tokens("`redraws'"))' :^ (1/(`resteps'-1)))

		forvalues restep = 1/`resteps' {
			if `restep' < `resteps' mata __NumREDraws = __NumREDraws:*_DrawMultipliers
			                   else mata __NumREDraws = strtoreal(tokens("`redraws'"))'

			if "`init'" != "" local initopt init(`init', copy)
	
			mata _NumREDraws = 1 \ ceil(__NumREDraws) * _REAnti

			local final = `psampling_cutoff'>=1 & `restep'==`resteps'
			if `final' {
				local this_mlopts `mlopts'
				local this_technique `technique'
			}
			else {
				local this_mlopts nonrtolerance tolerance(0.1)
				local this_technique nr
			}

			mata _first_call=1
			if "`interactive'" == "" {
				preserve
				qui keep if (`if') & (`psampling_cutoff'>=1 | `u'<=.001+`psampling_cutoff')

				local mlcmd `quietly' version `mlversion': ml model `model' `=cond(`final',"[`weight'`exp'],`options' score(`score')", "`awgtexp',")' max ///
				  `svy' constraints(`constraints' `userconstraints') nopreserve missing collinear `this_mlopts' `modopts' technique(`this_technique')
				capture noisily `mlcmd' `initopt' search(off)

				if _rc==1400 {
					di as res "Restarting search with parameters all 0."
					tempname zeroes
					mat `zeroes' = J(1, `=colsof(`init')', 0)
					mata _first_call=1
					capture noisily `mlcmd' init(`zeroes', copy) search(off)
				}
				restore

				if _rc==1 {
					local rc = _rc
					cmp_clear
					error `rc'
				}
				if _rc continue

				if "`auxparams'" != "" {
					mat `b' = e(b)
					mat `b' = `b'[1,`=1+`:word count `xvars'''...]
					local bcolnames `xvars' `:colnames `b''
				}
				else local bcolnames `xvars'
				mat `b' = e(b)
				mat colnames `b' = `bcolnames'
				gen byte `sample' = `if'
				ereturn repost b = `b', rename esample(`sample')
				cap _ms_op_info e(b)
				if _rc==0 & r(fvops) ereturn repost, buildfvinfo
				cap local _a // reset _rc to 0
			}
			else {
				local mlmodelcmd version `mlversion': ml model `model' `=cond(`final',"[`weight'`exp'] if `if',`options'","`awgtexp' if (`if') & `u'<=.001+`psampling_cutoff', ")' ///
				  `svy' constraints(`constraints' `userconstraints') `modopts' collinear technique(`this_technique') nopreserve missing
				local mlmaxcmd `quietly' version `mlversion': ml max, search(off)` noclear nooutput `this_mlopts' `=cond(`psampling_cutoff'>=1, "score(`score')", "")'
				`mlmodelcmd' `initopt'
				`mlmaxcmd'
				if _rc==1400 {
					di as res "Restarting search with initial parameters all 0."
					tempname zeroes
					mat `zeroes' = J(1, `=colsof(`init')', 0)
					mata _first_call=1
					`mlmodelcmd' init(`zeroes', copy)
					capture noisiliy `mlmaxcmd'
				}
				else if _rc==1 {
					cmp_clear
					error 1
				}
				if _rc continue
			}
			if `restep'+1 < `resteps' {
				if "`quietly'"=="" noi version `mlversion': ml di
				mat `init' = e(b)
			}
		}

		local psampling_cutoff = `psampling_cutoff' * `psampling_rate'
		if `psampling_cutoff' < `psampling_rate' {
			noi version `mlversion': ml di
			mat `init' = e(b)
		}
	}
	
	if _rc {
		local rc = _rc
		cmp_clear
		error `rc'
	}
	if "`lnl'" != "" {
		quietly version `mlversion': ml model `model' [`weight'`exp'] if `if', `options' `svy' nopreserve missing collinear `modopts'
		tempname b
		mat `b' = e(b)
		cmp_lf1 0 `b' `lnl'
		ml clear
	}

	if "`interactive'" == "" {
		if e(p)==. & "`1only'"=="" & e(chi2type)=="Wald" & e(df_m) {  // estimation with multicollinear fvrevar'd factor var dummies messes up Wald test
			qui test
			ereturn scalar p = r(p)
			ereturn scalar chi2 = r(chi2)
		}
	}

	if "`interactive'" != "" ereturn repost, esample(`if')
	
	ereturn local model `model'
end

cap program drop LabelMprobitEq
program LabelMprobitEq
	version 10.0
	// try to name the eq after the outcome's label
	global cmp_eq`1' : label cmp_y`2'_label `4'
	cap confirm names ${cmp_eq`1'}
	if _rc | `: word count ${cmp_eq`1'}' > 1 global cmp_eq`1' _outcome_`3'_`4'
end

// Given current ml model, estimate starting points equation by equation
// Also, return reduced lists of RHS vars reflecting rmcoll and perfect-prediction eliminations in probit case
// as well as constraints on rho's needed for equations with non-overlapping samples
cap program drop InitSearch
program InitSearch, rclass
	version 10.0
	cap version 11.0
	syntax [aw fw iw pw] if/, [auxparams(string) adjustprobitsample nodrop svy 1only quietly]
	tempname beta sig betavec cutvec sigvec atanhrho V t t2 mat_cons
	tempvar y id choice
	local _cons _cons
	mat `mat_cons' = 0
	mat colnames `mat_cons' = "_cons"
	if "`svy'"!="" local svy svy:
	if "`weight'" != "" & "`svy'"=="" {
		local iwgtexp [iweight `exp']
		local awgtexp [aweight `exp']
		local pwgtexp [aweight `exp']
	}

	forvalues i=1/$cmp_d {
		local xvars
		tempvar e`i' ebar`i'

		qui {
			count if `if' & _cmp_ind`i'==5
			if r(N) local regtype 5
			else {
				count if `if' & (_cmp_ind`i' > $cmp_mprobit_ind_base & _cmp_ind`i' < $cmp_roprobit_ind_base) | inlist(_cmp_ind`i', 4, 6)
				if r(N) local regtype 4
				else {
					count if `if' & (_cmp_ind`i' == 7)
					if r(N) local regtype 7
					else {
						count if `if' & (_cmp_ind`i' == 8)
						if r(N) local regtype 8
						else {
							count if `if' & (_cmp_ind`i' == 9)
							if r(N) local regtype 9
							else {
								count if `if' & (_cmp_ind`i' == 2 | _cmp_ind`i' == 3)
								local regtype = cond(r(N), 2, 1)
							}
						}
					}
				}
			}
		}

		if "`1only'"=="" {
			if "`drop'" == "" {
				`=cond(`regtype'==1, "_rmdcoll ${cmp_y`i'}", "_rmcoll")' ${cmp_x`i'} if `if' & _cmp_ind`i', ${cmp_xc`i'} `=cond(c(version)==11, "expand", "")'
				foreach var in `r(varlist)' {
					if substr("`var'", 1, 2) != "o." local xvars `xvars' `var'
				}
			}
			else local xvars ${cmp_x`i'}
		}
		
		local dropped (force first iteration)
		while "`dropped'"!= "" {
			local keep
			cap drop `e`i''
			if `regtype'==5 {
				`quietly' `svy' oprobit ${cmp_y`i'} `xvars' `iwgtexp' if `if' & _cmp_ind`i', offset(${cmp_xo`i'})
				mat `beta' = e(b)
				mat `V' = e(V)
				mat `sig' = 0
				local pos1 = colsof(`beta') - e(k_aux) + 1
				mat `cutvec' = nullmat(`cutvec'), `beta'[1, `pos1'...]
				if e(k_eq) == e(k_cat) {
					matrix `beta' = `beta'[1,"${cmp_y`i'}:"]
					matrix `V' = `V'["${cmp_y`i'}:","${cmp_y`i'}:"]
					global cmp_xc`i' nocons
				}
				else {
					mat `beta' = `mat_cons' // put a 0 on end for "constant"
					constraint free
					local initconstraints `initconstraints' `r(free)'
					constraint `r(free)' [${cmp_eq`i'}]_cons
					global cmp_xc`i'
				}
				qui if $cmp_d > 1 | $parse_L > 1 {
					_predict `e`i'' if e(sample)
					recode `e`i'' (. = 0) if e(sample) // can be all missing if there are no regressors
					replace `e`i'' = ${cmp_y`i'} - `e`i''
				}
			}
			else if `regtype'==4 {
				cap confirm variable _mp_cmp_y`i' // check for cmp-made dummies for non-as mprobit
				`quietly' `svy' probit `=cond(_rc, "${cmp_y`i'}", "_mp_cmp_y`i'")' `xvars' `iwgtexp' ///
					if `if' & (inlist(_cmp_ind`i',4,6) | (_cmp_ind`i' > $cmp_mprobit_ind_base & _cmp_ind`i' < $cmp_roprobit_ind_base)), ${cmp_xc`i'} offset(${cmp_xo`i'})
				if "`adjustprobitsample'" != "" qui replace _cmp_rev_ind`i' = 0 if e(sample)==0
				mat `beta' = e(b)
				mat `V' = e(V)
				mat `sig' = 0
				qui if $cmp_d > 1 | $parse_L > 1 {
					predict `e`i'' if e(sample)
					replace `e`i'' = (`e(depvar)'!=0) - `e`i''
				}
				mat `t' = e(rules)
				local perfect : colnames(`beta')
				local perfect : list xvars - perfect
				foreach var in `perfect' {
					mat `t2' = `t'["`var'",1]
					if `t2'[1,1]==1 {
						di as res _n "Warning: `var' perfectly predicts success or failure in ${cmp_y`i'}."
						if "`drop'" == "" di as res "It will be dropped from the full model."
						di as res "Perfectly predicted observations will be dropped from the estimation sample for this equation."
					}
					else if "`drop'" != "" {  // keep collinear regressors?
						local keep `keep' `var'
					}
				}
			}
			else if `regtype'==2 {
				cap `svy' tobit ${cmp_y`i'} `xvars' `pwgtexp' if `if' & inlist(_cmp_ind`i', 1, 2, 3), ${cmp_xc`i'} ll ul
				if _rc & _rc != 430 { // crash on error other than failure to converge
					error _rc
					exit _rc
				}
				if "`quietly'" =="" tobit
				mat `beta' = e(b)
				mat `sig' = ln([sigma]_cons)
				mat `beta' = `beta'[1, "model:"]
				mat `V' = e(V)
				mat `V' = `V'["model:", "model:"]
				qui if $cmp_d > 1 | $parse_L > 1 {
					predict `e`i'' if e(sample) & (${cmp_y`i'}>`e(llopt)' | `e(llopt)'==.) & ${cmp_y`i'}<`e(ulopt)'
					replace `e`i'' = ${cmp_y`i'} - `e`i''
				}
			}
			else if `regtype'==7 {
				cap `svy' intreg ${cmp_y`i'_L} ${cmp_y`i'} `xvars' `iwgtexp' if `if' & inlist(_cmp_ind`i', 1, 7), ${cmp_xc`i'} offset(${cmp_xo`i'})
				if _rc & _rc != 430 { // crash on error other than failure to converge
					error _rc
					exit _rc
				}
				if "`quietly'"=="" intreg
				mat `beta' = e(b)
				mat `sig' = [lnsigma]_cons
				mat `beta' = `beta'[1, "model:"]
				mat `V' = e(V)
				mat `V' = `V'["model:", "model:"]
				qui if $cmp_d > 1 | $parse_L > 1 {
					predict `e`i'' if e(sample)
					replace `e`i'' = cond(${cmp_y`i'}<., cond(${cmp_y`i'_L}<., (${cmp_y`i'}+${cmp_y`i'_L})/2, ${cmp_y`i'}), ///
					                                     cond(${cmp_y`i'_L}<., ${cmp_y`i'_L}, 0)) - `e`i''
				}
			}
			else if `regtype'==8 {
				sum ${cmp_y`i'_L} if `if' & _cmp_ind`i'==8, meanonly
				local ll = cond(r(min)<., "ll(`r(min)')", "")
				sum ${cmp_y`i'_U} if `if' & _cmp_ind`i'==8, meanonly
				local ul = cond(r(max)<., "ul(`r(max)')", "")
				cap `svy' truncreg ${cmp_y`i'} `xvars' `iwgtexp' if `if' & _cmp_ind`i'==8, `ll' `ul' ${cmp_xc`i'} offset(${cmp_xo`i'})
				if _rc & _rc != 430 { // crash on error other than failure to converge
					error _rc
					exit _rc
				}
				if "`quietly'"=="" & _rc!=430 truncreg
				mat `beta' = e(b)
				mat `sig' = cond(_rc==430, 1, ln([sigma]_cons))
				mat `beta' = `beta'[1, "eq1:"]
				mat `V' = e(V)
				mat `V' = `V'["eq1:", "eq1:"]
				qui if $cmp_d  >1 | $parse_L > 1 {
					predict `e`i'' if e(sample)
					replace `e`i'' = ${cmp_y`i'} - `e`i''
				}
			}
			else { // uncensored or roprobit var
				`quietly' `svy' regress ${cmp_y`i'} `xvars' `iwgtexp' if `if' & (_cmp_ind`i'==1 |  _cmp_ind`i'>=$cmp_roprobit_ind_base), ${cmp_xc`i'}
				mat `beta' = e(b)
				if $cmp_reverse & `regtype'==9 mat `beta' = -`beta'
				mat `sig' = ln(e(rmse))
				mat `V' = e(V)
				if $cmp_d > 1 | $parse_L > 1 qui predict `e`i'' if e(sample), resid
			}

			local k = colsof(`beta')
			local dropped
			if (colsof(`beta')) {
				local xvars : colnames `beta'
				local xvars : list xvars - `_cons'
				if diag0cnt(`V') & diag0cnt(`V') < rowsof(`V') { // unless all the coefs had se=0, drop those that did from this equation
					if "`drop'" == "" {
						forvalues j=1/`=`k' - ("${cmp_xc`i'}"=="")' {
							if `V'[`j',`j'] == 0 & strpos("`: word `j' of `xvars''", "b.") == 0 { // skip base vars of factor variables
								if `"`dropped'"' == "" {
									di as res _n "Warning: Covariance matrix for single-equation estimate of ${cmp_y`i'} equation is not of full rank."
									di as res "Parameters with singular variance will be excluded from full model."
									di as res "Re-running single-equation estimate without them."
								}
								local dropped `dropped' `: word `j' of `xvars''
							}
						}
						local xvars : list xvars - dropped
						if "${cmp_xc`i'}"=="" & `V'[`k',`k']==0 {
							local dropped `dropped' _cons
							global cmp_xc`i' noconstant
						}
					}
					else di as res "Parameters with singular variance will be retained in full model."
				}
			}
			else local xvars
		}

		if "`keep'" != "" {   // add back collinear regressors if nodrop specified
			if "${cmp_xc`i'}"=="" mat `beta' = `=cond(`k'>1,"`beta'[1, 1..`=`k'-1'],", "")'  J(1, `:word count `keep'', 0), `beta'[1,`k']
			else                  mat `beta' = `beta', J(1, `:word count `keep'', 0)
		}

		mat coleq `beta' = ${cmp_eq`i'}
		mat `betavec' = nullmat(`betavec'), `beta'
		if cmp_fixed_sigs$parse_L[1,`i']==. {
			mat colnames `sig' = lnsig_`i':_cons
			mat `sigvec' = nullmat(`sigvec'), `sig'
		}

		if e(converged) == 0 {
			di as res _n "Single-equation estimate for ${cmp_y`i'} equation did not converge."
			di "This may indicate convergence problems for the full model too."
		}
		CheckCondition `xvars'

		if e(df_m) | `regtype'!=5 {
			if "${cmp_xc`i'}"=="" & `V'[`=colsof(`V')', `=colsof(`V')']==0 & e(converged) global cmp_xc`i' noconstant
		}
		global cmp_x`i' `xvars' `keep'
	}

	mat `betavec' = `betavec', nullmat(`cutvec')

	tempname Rho rho _sigvec sig t
	forvalues l=1/$parse_L {
		cap mat drop `_sigvec'
		cap mat drop `atanhrho'
		mat `Rho' = I($cmp_d)
		if `l' < $parse_L {
			local cmp_ids `cmp_ids' _cmp_id`l'
			local l_ `l'_
			local level_l "level `l' "
		}
		else {
			local l_
			local level_l
			local _sigvec `sigvec'
		}

		quietly forvalues i=1/$cmp_d {
			if cmp_nonbase_cases[1,`i'] & cmpLevels[`i', `l'] {
				if `l' < $parse_L {
					tempname ebar`i'
					by `cmp_ids': egen `ebar`i'' = mean(`e`i'')
					sum `ebar`i'' `awgtexp'
					mat `sig' = cond(r(sd), ln(r(sd)), 0)
					mat colnames `sig' = lnsig_`l_'`i':_cons
					mat `_sigvec' = nullmat(`_sigvec'), `sig'
					replace `e`i'' = `e`i'' - `ebar`i''
				}
				else local ebar`i' `e`i''
			}
		}

		forvalues i=1/$cmp_d {
			if cmp_nonbase_cases[1,`i'] {
				forvalues j=`=`i'+1'/$cmp_d {
					if cmpLevels[`j',`l'] & cmp_fixed_rhos`l'[`j',`i']==. {
						cap corr `ebar`i'' `ebar`j''
						if abs(r(rho))==1 {
							di as err "Residuals from initial fits for `level_l'equations `i' and `j' are exactly correlated."
							exit 3002
						} 
						if r(N) | "`drop'" != "" {
							if r(N)==0 {
								di as res _n "Samples for `level_l'equations `i' and `j' do not overlap."
								di as res "atanhrho_`l_'`i'`j' kept in the model because of {cmd:nodrop} option."
								di as res "It cannot be identified, so it must be constrained."
								mat `rho' = 0
							}
							else mat `rho' = cond(r(rho)==., 0, atanh(r(rho)))
							mat colnames `rho' = atanhrho_`l_'`i'`j':_cons
							if "${cmp_covariance`l'}" != "exchangeable" mat `atanhrho' = nullmat(`atanhrho'), `rho'
							mat `Rho'[`i',`j'] = tanh(`rho'[1,1])
							mat `Rho'[`j',`i'] = tanh(`rho'[1,1])
						}
						else {
							mat cmp_fixed_rhos`l'[`j',`i'] = 0
							local t /atanhrho_`l_'`i'`j'
							local auxparams: list auxparams - t
							di as res _n "Samples for `level_l'equations `i' and `j' do not overlap. Removing rho_`l_'`i'`j' from the model."
						}
					}
				}
			}
		}
		if "${cmp_covariance`l'}" == "exchangeable" mat `atanhrho' = nullmat(`atanhrho'), 0
		
		cap mat `Rho' = cholesky(`Rho')
		if _rc {
			forvalues j=1/`=colsof(`atanhrho') {
				mat `atanhrho'[1,`j'] = 0 // If initial guess not pos-def, zero out rhos while preserving column labels in case noESTimate will post this
			}
		}
		mat `betavec' = `betavec', nullmat(`_sigvec'), nullmat(`atanhrho')
	}
	return matrix b = `betavec'
	return local auxparams `auxparams'
	return local initconstraints `initconstraints'
end
cap program drop Display
program Display
	version 10.0
	cap version 11.0
	syntax [, Level(real `c(level)') *]
	svyopts noopts diopts, `options'
	mlopts noopts, `noopts' // trigger error if extra options
	local meff meff meft
	local diopts: list diopts - meff
	if `:word count `e(diparmopt)''/3+`:word count `diopts''<=48+20*(c(version)>10) ml display, level(`level') `diopts' showeq `e(diparmopt)'
	                                                                           else ml display, level(`level') `diopts' showeq
end
cap program drop CheckCondition
program define CheckCondition
	version 10.0
	cap version 11.0
	if "`1'" != "" {
		syntax varlist(ts `=cond(c(version)==11,"fv","")') [aw iw]
		tempname XX c
		tempvar sample
		qui gen byte `sample' = e(sample)
		`=cond(c(version)==11,"fv","ts")'revar `varlist'
		local varlist `r(varlist)'
		qui mat accum `XX' = `varlist' [`weight'`exp'] if e(sample), nocons
		forvalues i=1/`=colsof(`XX')' {
			if `XX'[`i',`i'] local xvars `xvars' `:word `i' of `varlist''
		}
		if "`xvars'" != "" {
			qui mat accum `XX' = `xvars' [`weight'`exp'] if e(sample), nocons
			mata _X = .
			mata st_view(_X, ., tokens("`xvars'"), "`sample'")
			mata _X = sqrt(quadcolsum(_X:*_X))
			mata st_numscalar("`c'", cond(st_matrix("`XX'") :/ quadcross(_X,_X)))
			if `c' > 20 { // threshhold from Greene (2000, p. 40)
				di _n as res "Warning: regressor matrix for " as txt "`e(depvar)'" as res " equation appears ill-conditioned. (Condition number = " `c' ".)"
				di "This might prevent convergence. If it does, and if you have not done so already, you may need to remove nearly"
				di "collinear regressors to achieve convergence. Or you may need to add a {opt nrtol:erance(#)} or {opt nonrtol:erance} option to the command line."
				di "See {help cmp##tips:cmp tips} for more information. "
			}
			mata mata drop _X
		}
	}
end

* Version history
* 5.2.5 Prevented crash when two eqs have same name, by suffixing with eq number
*       Fixed bug in constants-only InitSearch when dropping rhos for non-overlapping eqs
* 5.2.4 Dropped e(diparmopt) from call to ml display if that exceeds maximum # of options for syntax command
* 5.2.3 Fixed bug causing crash in mixed censored-uncensored models.
*       Used ereturn, repost to establish correct esample() before using buildfvinfo option. Prevented revar'ing when constraints used.
* 5.2.2 Assured intreg residuals in InitSearch are never missing even if bounds are
* 5.2.1 Changed _rmdcoll to _rmcoll exept for regtype==1
* 5.2.0 Added lnl option to predict
* 5.1.2 Prevented crash when adjustprobit sample restricts sample on only eq that applies to obs, thus restricting sample
*       Prevented crash when model with oprobit has some obs with no oprobit (or otherwise censored) eqs for some obs
* 5.1.1 Prevented crash when diparm tries to display rho version of a dropped atanhrho
* 5.1.0 Added covariance() option
* 5.0.0 Added random effects, iia suboption. Dropped pseudod2.
* 4.0.4 Minor changes in handling of rho's for non-overlapping eqs in constant-only model
* 4.0.3 Added check after _rmdcoll to remove "o." vars in varlist--artifact of factor variable support
* 4.0.2 Tweaked InitSearch tobit code introduced in 3.5.2 for factor var compatibility. No "version 10:" now.
* 4.0.1 Code refinements
* 4.0.0 Added rank-ordered probit support.
* 3.9.3 In InitSearch, eliminated subscripting matrices with "#1" in Stata-provided code fragment for compatibility with Stata <11.
* 3.9.2 Suppressed call to test introduced in 3.9.1 if LR test used 
* 3.9.1 Fixed bugs in handling factor variables with help of Stata Corp. 
*       For intreg, made InitSearch include samples where indicator==1, not just 7
* 3.9.0 Added factor variable support. Thanks to Tamas Bartus for inspiration.
*       Use pseudod2 in Stata version 11.1 or earlier. Code to check version is version dependent! date() takes "dmy" in some versions, "DMY" in others
* 3.8.6 Fixed typo in 3.8.5. Suppressed "equation #1 assumed" in predict if there is only 1 equation
* 3.8.5 Use pseudod2 if Stata born before 11 feb 2010
* 3.8.4 Fixed bug so pseudod2 will call ml to be run under version 9.2 so that cluster() is accepted
*       Fixed bug introduced in 3.6.8--code for vecmultinormal() call for truncregs not properly updated
* 3.8.3 Fixed bug in InitSearch preventing dropping of last regressor from an eq if no SE in preliminary regression and nocons
*       Fixed bug in line determinining version to use for ml. (local a=c(version) can return 9.199999999)
* 3.8.2 Added lnl() option to save observation-level log likelihood. Fixed 3.8.0 bug.
* 3.8.1 Use arguments instead of Stata locals to pass to cmp_lnL() variable names for scores and likelihood
*       Changed required ghk2() version to 1.3.1 because of bug fix in latter
* 3.8.0 Incorporated use of lf1 method by default in Stata 11 and later
* 3.7.0 Fixed minor bugs in InitSearch in handling case of no RHS vars
*       Fixed bug restricting whole-system sample to those of non-as mprobit eqs
* 3.6.9 Got rid of i loop in vecbinormal() for speed
* 3.6.8 Made vecmultinormal() return value and scores of log instead of level. Tightened functions that call it.
* 3.6.7 In cmp_d2, changed constant in h formula from 1e-4 to 1e-5.
*       Introduced normal2() to calculate normal(U)-normal(L) more precisely.
* 3.6.6 Added check in Parse for missing "="
* 3.6.5 Fixed 3.6.4 bug: predict didn't handle SigScoreInds properly when it was empty
* 3.6.4 Fixed bug: code for dropping rhos of non-overlapping eqs broken by 3.5.0.
*       Fixed bug: changed `0' to `"`0'"' in call to cmp_full_model in case command line contains quotes
*       Fixed bug: lack of SE for _cons in InitSearch probit fit didn't cause its coef to be dropped from initial fit vector
* 3.6.3 Added check to cmp_d2 for lnf = 0 after cmp_lnL call
* 3.6.2 Reworked `quietly' 3.5.5 work-around. Put bracketed code in do_InitSearch
* 3.6.1 Fixed bug in 3.6.0
* 3.6.0 Added noestimate option, copying gllamm. Thanks to Stas Kolenikov for suggestion.
* 3.5.6 Made mi-friendly
* 3.5.5 Inserted line break in "`quietly' {" to avoid Stata syntactic pecadillo.
*       If inital guess for Sigma is not positive definite, InitSearch makes it diagonal
* 3.5.4 Allowed reals for level()
* 3.5.3 Added warning about initial single-equation fits deviating from specification.
* 3.5.2 For weighted regressions, InitSearch now uses iweights throughout, except for -tobit- in Stata 9.2, where it must use aweights.
*       This improves starting point. -tobit- does aweights differently from -ml-. (see [R] intreg)
* 3.5.1 Added "did you forget to type cmp setup?"
* 3.5.0 Reorganized to leave no variables behind. Now works with -est (re)store- and -suest-. Dropped cleanup/clear subcommand.
* 3.4.6 Removed bug causing attempt to store potentially non-numeric value labels in e(cat) for oprobit eq
* 3.4.5 Added warning that with GHK changing observation order changes results.
* 3.4.4 Added nopreserve to ml model command in interactive mode
* 3.4.3 Added e(cmdline)
* 3.4.2 Added clear as synonym for cleanup
* 3.4.1 Tightened vecbinormal(), neg_half_E_Dinvsym_E(), and dPhi_dpE_dSig(). Took over model parsing and changed truncreg syntax
* 3.4.0 Added truncreg equation type
* 3.3.3 Run InitSearch even when init() specified in order to consistently perform and report various specification checks. Thanks to Misha Bontch-Osmolovski.
* 3.3.2 Made it use distinct GHK draws for each block of identically censored observations, via new ghk2() s argument
* 3.3.1 Added warning about Stata 9 cluster() behavior with missing values in regressors. Thanks to Misha Bontch-Osmolovski.
* 3.3.0 Added ghk2version check
* 3.2.9 Switched from invsym() to cholinv(). Fixed bug in cmp_p affecting predicted probability after ordered probit for second-highest outcome
* 3.2.8 Added -missing- option to ml model call in interactive model to prevent sample shrinkage
* 3.2.7 Fixed loss of sample marker caused by preserve/restore in Estimate
* 3.2.6 Fixed bug causing crash with use of init()
* 3.2.5 Fixed robust/cluster handling incompatibility between Estimate and Stata 9
* 3.2.4 Changed =r(varlist) to `r(varlist)' after tsrevar so it doesn't treat macros as strings
* 3.2.3 Fixed bugs affecting mprobit score and Hessian computations. mprobit converges much better. Fixed misc bugs.
* 3.2.2 Used tsrevar and preserve/keep/restore to cut down data set for speed in non-interactive mode. Created Estimate subroutine.
*       For non-overlapping samples removed rho_ij from model rather than keeping and constraining to 0, for speed.
* 3.2.1 Added e() and ystar() options to cmp_p
* 3.2.0 Added interval regression type. Replaced minfloat() and maxfloat() for cuts with "."
* 3.1.1 Fixed bug preventing use of user-supplied equation names. Added "_cons" after ":" in _b[] in cmp_p
* 3.1.0 Added psuedo-d2 evaluator as default
* 3.0.3 Fixed call to _ghk2_2d() had dE and dF swapped
* 3.0.2 Made sure empty score matrix still created for cuts in obs with no oprobit eq
* 3.0.1 Fixed bug in determining which cut #s are relevant for which obs when set of oprobit eqs varies
* 3.0.0 Added multinomial probit support. Added lf evaluator. Switched to ghk2(). Added progressive sampling.
* 2.1.0 Fixed bug causing constants-only model to be unweighted
* 2.0.9 Replaced call to symeigenvalues() with one to cholesky() for surprisingly large speed gain.
* 2.0.8 Tightened Mata code. Put missing qui in InitSearch.
* 2.0.7 Fixed bugs in Mata code for ordered probit. Wasn't working if # of o-probit eq varied by obs.
* 2.0.6 Fixed small bug in cmp_p
* 2.0.5 Fixed 2.0.4 bug affecting whether constant included in an ordered probit equation
* 2.0.4 Fixed 2.0.2 bug. Estimation restricted to union of samples for each eq. Was the intersection before 2.0.2. Was set by if/in only in 2.0.2.
* 2.0.3 When using dep var as eq name, remove "." from ts ops
* 2.0.2 Changed response to missing obs. If indicator>0 and obs missing, no longer set touse=0 for all eq--just set indicator=0.
* 2.0.1 Changed e(indicators) to contents of indicators() option. (e(k_dv) holds # of indicators.)
*       Fixed bug in dPhi_dpE_dSig() for ordered-probit case.
* 2.0.0 Added ordered probit and beefed up predict.
* 1.4.1 Added real generation of residuals after probit in InitSearch, so 1.3.1 code doesn't think probit samples overlap no others
* 1.4.0 Added init() option for manual control of initial values
* 1.3.1 Added rho constraints to handle equations with non-overlapping subsamples
* 1.3.0 Added plot feature. Added _rmdcoll check to InitSearch.
* 1.2.8 Fixed typo ("`drop'"") introduced in 1.2.7
* 1.2.7 Turned ghkanti option from an integer to a present/absent macro. Added nodrop option.
* 1.2.6 Changed e(indicators) from macro to scalar
* 1.2.5 Added return macros e(Ni) with equation-specific sample sizes. Prevented errors if cmp cleanup run unnecessarily.
*       Fixed bugs in handling of ts ops.
*       Prevented it from dropping all regressors if an initial 1-equation tobit fails to converge.
* 1.2.4 In interactive mode, moved mlopts from ml model to ml max command, where they belong.
*       Adjusted 1.2.3 fix: iweights for probit and aweight for tobit and regress.
*       Added warning for ill-conditioned regressor matrix.
* 1.2.3 Use aweights instead of pweights, if requested, in InitSearch since Stata 9.2 tobit doesn't accept pweights, and for speed
* 1.2.2 Fixed bug in InitSearch causing it to drop observations with missing even when the missings are in variables/equationsare marked as out
* 1.2.1 Changed "version 9.2" to "cap version 10" in cmp_ll so callersversion() returns right value.
* 1.2.0 Made it work in Stata 9.2
* 1.1.2 Added noclear to ml command line in interactive mode
* 1.1.1 Prevented repeated display of ghk notification in interactive mode
* 1.1.0 Added interactive option
* 1.0.2 Fixed predict statement after bicensored tobit in InitSearch
* 1.0.1 Minor changes
