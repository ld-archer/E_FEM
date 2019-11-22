/* Program to develop assignment of SSA variables for 2010 stock population */

include common.do
local bsamp : env BREP
if missing("`bsamp'") {
  local outdir $outdata
}
else {
  local outdir $outdata/input_rep`bsamp'
}

/* Get distributions of AIME and quarters worked */
use $resmodels/ssa_dist_50p.dta, replace
* Move from the 50 categories to tenths of percentiles
expand 20
sort q_grp
gen id = (_n-1)/10
* Set values to be used for imputation at middle of each group
replace q_dist = . if mod(id+1,2)>0
replace aime_dist = . if mod(id+1,2)>0
* Set lowest values
replace q_dist = 0 if id == 0
replace aime_dist = 0 if id == 0
* In case we need a 100th
expand 2 if _n == _N
replace id = 100 if _n == _N
	
ipolate q_dist id, gen(q_imp) epolate
ipolate aime_dist id, gen(aime_imp) epolate

gen aime_pct = id
gen q_pct = id
replace aime_dist = aime_imp
replace q_dist = q_imp
* quarters should be integers
replace q_dist = round(q_dist)
	
keep aime_pct aime_dist q_pct q_dist
tempfile ssa
save `ssa'

*** Separately for retired and not retired ***

foreach status in ret notret {

	************************************************
	* Create matrices for SSA-related joint models *
	************************************************
	drop _all
	use "$resmodels/`status'/ssa_vcmatrix.dta"

	drop _rowname

	mkmat *, mat(ssa_omega)
	local d = colsof(ssa_omega)
	forvalues i = 1/`d'{
		local k = `i'+1
		forvalues j = `k'/`d'{
			matrix ssa_omega[`i',`j'] = ssa_omega[`j',`i']
		}
	}
	local ssa_colname: colnames ssa_omega
	noi dis "`ssa_colname'"
	matrix rownames ssa_omega = `ssa_colname'
	local num = rowsof(ssa_omega)

	matrix list ssa_omega
  
	* Different V-C matrices with each of the outcome as the first row

	foreach x in `ssa_colname' {
		takestring, oldlist("`ssa_colname'") newname("addlist") extlist("`x'")
		global ssavlist `x' $addlist
		matrix ssavc_`x' = J(`num',`num',.)
		matrix colnames ssavc_`x' = $ssavlist
		matrix rownames ssavc_`x' = $ssavlist
		foreach y in $ssavlist {
			foreach z in $ssavlist {
				matrix ssavc_`x'[rownumb(ssavc_`x',"`y'"), colnumb(ssavc_`x', "`z'")] =  ssa_omega[rownumb(ssa_omega,"`y'"), colnumb(ssa_omega,"`z'")]
			}
		}
	}
	
	* Cholesky decomposition
	matrix L_ssaomega = cholesky(ssa_omega)
	foreach x in `ssa_colname'{
		matrix L_ssa`x' = cholesky(ssavc_`x')
	}

	* Models for aime and quarters worked
	drop _all
	use "$resmodels/`status'/ssa_means.dta"
	gen order = _n
	drop _rowname

	sort order, stable
	drop order
	mkmat *, mat(ssa_meanest)
	matrix rownames ssa_meanest = `ssa_colname'
	mat list ssa_meanest


	* Read in the file with the cut points for the SSA ordered probit models, make a matrix for later use 
	drop _all
	use "$resmodels/`status'/ssa_cut_points.dta"
	mkmat cut_*, mat(ssa_cutpoints) rownames(_rowname)

	mat list ssa_cutpoints
	local ssa_cuts = colsof(ssa_cutpoints)

	forvalues x = 1/`ssa_cuts' {
		foreach y in aime_pct q_pct {
			scalar `y'_cut`x' = ssa_cutpoints[rownumb(ssa_cutpoints,"`y'"),colnumb(ssa_cutpoints,"cut_`x'")]
			di `y'_cut`x'
		}
	}



	* New approach for aime and quarters worked - estimated a model on the 2004 50-55 year olds

        use `outdir'/all2010_pop_adjusted.dta, replace
        
	
	if "`status'" == "ret" {
		keep if isret > 0
	}
	else if "`status'" == "notret" {
		keep if isret == 0
	}
	
	count

	
	drawnorm d_aime_pct d_q_pct, cov(ssa_omega) seed(987562)	

	sum d_aime_pct
	sum d_q_pct

	cap gen __cons = 1

	* Interactions in model
	foreach var in black hispan hsless college work {
		gen male_`var' = male*`var'
	} 


	egen agecat = cut(age), at(0,50,55,60,65,70,75,80,85,200)
	
	* Nope - these people are spouses in the simulation, so we need SSA parameters for them.
	* drop if age < 50
	
	forvalues age = 50 (5) 85 {
		gen age`age' = (agecat == `age')	
	}
	
	gen isretx = isret/1000

	* Predicted prevalence
	local j = 1
	foreach x in `ssa_colname' {
		matrix betamat = ssa_meanest[`j',1...]
		cap drop `x'_xb
	
		matrix score `x'_xb = betamat
		local j = `j' + 1
		matrix mat_`x' = betamat
	
		mat list mat_`x'
		di "mean of `x' is:"
		sum `x'_xb
	}

 	drop __cons

	* Ordered outcomes
	local ssa_cats = `ssa_cuts' + 1

	foreach x in aime_pct q_pct {
		forvalues j = 1/`ssa_cats'{
			if `j' < `ssa_cats'{
				gen p`x'`j' = normal(`x'_cut`j' - `x'_xb)
			}
			else if `j' == `ssa_cats'{
				gen p`x'`j' = 1
			}
		}
	}		

	* Ordered outcomes
	foreach x in aime_pct q_pct {
		cap drop `x'
		gen `x' = .
		forvalues i = `ssa_cats'(-1)1 {
			replace `x' = `i' if normal(d_`x') <= p`x'`i'
			drop p`x'`i'
		}
	}	
		
	
	**********************************************
	* Incoming cohort model predicts categorical AIME and quarters worked in categories
	* Convert these categories into continuous values, then assign to values
	* Get 50-55 2004 distribution and use this to convert categorical to continous (we have 1000 points in our distribution)
	**********************************************
	gen ssa_draw1 = runiform()
	gen ssa_draw2 = runiform()

	local adj = 100/`ssa_cats'
	
	replace aime_pct = round(`adj'*aime_pct - `adj'*ssa_draw1,0.1)
	replace q_pct = round(`adj'*q_pct - `adj'*ssa_draw2,0.1)

	* Fill in the AIME values
	merge m:1 aime_pct using `ssa', keepusing(aime_dist) keep(matched) nogen
	* Fill in the quarters worked values
	merge m:1 q_pct using `ssa', keepusing(q_dist) keep(matched) nogen

	rename aime_dist raime_test
	rename q_dist rq_test		
		
	gen raime = raime_test
	gen rq = rq_test
	gen fraime = raime
	gen frq = rq
	
	sum rq, detail
	sum raime, detail
	
	save `outdir'/test_assign_`status'.dta, replace
	
	* Assign the individuals with no quarters worked using the probit estimates
	est use "$resmodels/`status'/anyrq.ster"
	matrix anyrq = e(b)
	matrix score panyrq_xb = anyrq
	gen d_anyrq = invnorm(runiform())
	gen anyrq = (panyrq_xb > d_anyrq)
	replace rq = 0 if anyrq == 0
	replace frq = rq
	replace raime = 0 if rq == 0
	replace fraime = raime 
	
	drop aime_pct raime_test q_pct rq_test

	* We are missing some of the values in the AIME and quarters worked merge
	drop if missing(hhidpn)

	keep hhidpn wave raime rq fraime frq
	
	foreach var in raime rq fraime frq {
		rename `var' `var'_`status'
	}
	
	save `outdir'/imputed_ssa_`status'.dta, replace

}

























capture log close
