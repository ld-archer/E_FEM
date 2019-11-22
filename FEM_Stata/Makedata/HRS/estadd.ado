*! version 1.0.3, Ben Jann, 12apr2005

program define estadd, rclass
	version 8.2
	syntax [anything] , Stats(string) [ Prefix(name) ]
	if "`prefix'"!="" local prefix "prefix(`prefix')"

//parse the stats() option
	ParseStats `stats'

//expand estimates names
	est_expand `"`anything'"' , default(.)
	local names `r(names)'

//backup current (unstored) estimates / determine active estimates
	tempname hcurrent
	if "`e(_estimates_name)'"=="" {
		if "`names'"!="." & `"`e(cmd)'"' != "" {
			local holdcurrent holdcurrent
			_est hold `hcurrent', restore estsystem
		}
	}
	else local active "`e(_estimates_name)'"

//loop over estimates names and add the statistics
	nobreak {
		foreach name of local names {
			if "`name'"=="." {
				if "`holdcurrent'"!="" _est unhold `hcurrent'
			}
			else {
				ereturn clear
				qui estimates restore `name', drop
			}
			local s 0
			foreach stat in `stats' {
				local opt: word `++s' of `opts'
				cap _estadd_`stat' , `opt' `prefix'
				if _rc {
					di as error ///
					 "error executing _estadd_`stat'"
					local exit=_rc //need to restore estimates before exiting
				}
				if "`exit'"!="" continue, break
			}
			if "`name'"=="." {
				if "`holdcurrent'"!="" _est hold `hcurrent', restore estsystem
			}
			else estimates store `name', title(`"`e(_estimates_title)'"')
		if "`exit'"!="" continue, break
		}
		if "`holdcurrent'"!="" _est unhold `hcurrent'
		else if "`active'"!="" qui estimates restore `active'
	}
	exit `exit'
end

program define ParseStats
	gettoken stat 0: 0, parse(" (")
	gettoken trash 00: 0, match(par)
	gettoken opt: 0, match(par)
	while "`stat'"!="" {
		local stats: list stats | stat
		if `"`par'"'!="(" {
			gettoken stat 0: 0, parse(" (")
			local opts `"`opts'`""' "'
		}
		else {
			local opts `"`opts'`"`opt'"' "'
			gettoken stat 0: 00, parse(" (")
		}
		gettoken trash 00: 0, match(par)
		gettoken opt: 0, match(par)
	}
	c_local stats `stats' // list of statistics: stat1 stat2 ...
	c_local opts `"`opts'"'   // list of options: `"opts1"' `"opts2"' ...
end

// Note: The following subroutines could also be saved as external
// ado-files, e.g. save the "_estadd_beta" command as
// "_estadd_beta.ado" in the current directory or elswhere in the
// ado path. Use them as a starting point for programming your
// own subroutines.

program define _estadd_beta, eclass
	syntax [ , prefix(name) * ]

//use aweights with -summarize-
	local wtype `e(wtype)'
	if "`wtype'"=="pweight" local wtype aweight

//subpop?
	local subpop "`e(subpop)'"
	if "`subpop'"=="" local subpop 1

//copy coefficients matrix and determine varnames
	tempname results
	mat `results' = e(b)
	local vars: colnames `results'
	local eqs: coleq `results', q
	local depv "`e(depvar)'"

//loop over variables: calculate -beta-
	local j 0
	local lastdepvar
	foreach var of local vars {
		local depvar: word `++j' of `eqs'
		if "`depvar'"=="_" local depvar "`depv'"
		capture confirm numeric variable `depvar'
		if _rc mat `results'[1,`j'] = .z
		else {
			if "`depvar'"!="`lastdepvar'" {
				qui su `depvar' [`wtype'`e(wexp)'] if e(sample) & `subpop'
				local sddep `r(sd)'
			}
			capture confirm numeric variable `var'
			if _rc mat `results'[1,`j'] = .z
			else {
				qui su `var' [`wtype'`e(wexp)'] if e(sample) & `subpop'
				mat `results'[1,`j'] = `results'[1,`j'] * r(sd) / `sddep'
			}
		}
		local lastdepvar "`depvar'"
	}

//return the results
	ereturn matrix `prefix'beta = `results'
end

program define _estadd_mean, eclass
	syntax [ , prefix(name) * ]

//use aweights with -summarize-
	local wtype `e(wtype)'
	if "`wtype'"=="pweight" local wtype aweight

//subpop?
	local subpop "`e(subpop)'"
	if "`subpop'"=="" local subpop 1

//copy coefficients matrix and determine varnames
	tempname results
	mat `results' = e(b)
	local vars: colnames `results'

//loop over variables: calculate -mean-
	local j 0
	foreach var of local vars {
		local ++j
		capture confirm numeric variable `var'
		if _rc mat `results'[1,`j'] = .z
		else {
			su `var' [`wtype'`e(wexp)'] if e(sample) & `subpop', meanonly
			mat `results'[1,`j'] = r(mean)
		}
	}

//return the results
	ereturn matrix `prefix'mean = `results'
end

program define _estadd_sd, eclass
	syntax [ , prefix(name) noBinary * ]

//use aweights with -summarize-
	local wtype `e(wtype)'
	if "`wtype'"=="pweight" local wtype aweight

//subpop?
	local subpop "`e(subpop)'"
	if "`subpop'"=="" local subpop 1

//copy coefficients matrix and determine varnames
	tempname results
	mat `results' = e(b)
	local vars: colnames `results'

//loop over variables: calculate -mean-
	local j 0
	foreach var of local vars {
		local ++j
		capture confirm numeric variable `var'
		if _rc mat `results'[1,`j'] = .z
		else {
			capture assert `var'==0 | `var'==1 if e(sample) & `subpop'
			if _rc | "`binary'"=="" {
				qui su `var' [`wtype'`e(wexp)'] if e(sample) & `subpop'
				mat `results'[1,`j'] = r(sd)
			}
			else mat `results'[1,`j'] = .z
		}
	}

//return the results
	ereturn matrix `prefix'sd = `results'
end
