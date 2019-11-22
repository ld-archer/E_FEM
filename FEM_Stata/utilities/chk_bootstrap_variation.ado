/** 
Check the variation in a variable over possible bootstrap samples
of the data set. This can be used to identify model terms that 
probably do not have enough variation to be estimated in bootstrap 
samples.

This assumes a complex sample design with clusters sampled within strata.  
It also assumes that the bootstrap will resample (n_h - 1) clusters with 
replacement from each stratum, where n_h is the number of clusters in 
stratum h.

input: 
variable, e.g. male
stratum ID variable
cluster ID variable
sample selection indicator variable (which records were included in the estimation? usually `sel' == e(sample))
cutoff value for probability of drawing a bootstrap sample with no 
	variation in the variable of interest

result:
display warning message if the probability of a bootstrap draw with 
constant variable exceeds the cutoff value
*/

cap program drop chk_bootstrap_variation.ado
program define chk_bootstrap_variation
	args var strat clust sel plimit
	di "Checking variation of `var' in sampling units (`strat' `clust') selected by `sel'"
	
	tempfile orig_data
	save `orig_data', replace
	
	keep `strat' `clust' `var' `sel'
			
	* get number of in-sample observations in each cluster
	bys `strat' `clust': egen nobsinclust = total(`sel')
	
	* get number of in-sample values of `var' in each cluster
	bys `strat' `clust' `var' `sel': gen temp1 = `sel'==1 & _n==1
	bys `strat' `clust': egen nvalinclust = total(temp1)
	drop temp1
	
	* get number of clusters in each stratum
	bys `strat' `clust': gen temp2 = _n==1
	bys `strat': egen nclustinstrat = total(temp2)
	drop temp2
		
	* for each stratum: get number of clusters with zero in-sample observations
	bys `strat' `clust': gen temp3 = _n==1 & nobsinclust==0
	bys `strat': egen nemptyclust = total(temp3)
	drop temp3
	
	* for each stratum and value of `var': get number of clusters in the stratum with only that value
	bys `strat' `clust': gen constclust = _n==1 & nvalinclust==1

	collapse (mean) nclustinstrat nemptyclust (sum) nconstclust=constclus, by(`strat' `var')

	* not sure why this is needed, but it is:
	drop if missing(`strat')

	* for each stratum: probability of selecting only empty clusters
	gen clogp_e = (nclustinstrat-1) * (ln(nemptyclust) - ln(nclustinstrat))
	* use this to track zero probabilities because ln(0)=. and collapse ignores missing
	gen p_e0 = nemptyclust == 0

	levelsof(`var') if nconstclust > 0, local(varlevs)
	local p1 = 0.0
	local p2 = 0.0
	local nval = 0

	tempfile tfile1
	save `tfile1', replace

	if "`varlevs'" != "" {
		foreach x in `varlevs' {
			* does `x' appear as a constant value for some clusters in the stratum?
			bys `strat' `var': gen temp4 = _n==1 & `var'==`x' & nconstclust > 0
			bys `strat': egen cvalinstrat = total(temp4)
				
			* if `x' is constant cluster value in the stratum, keep only that record
			* if `x' is not a constant cluster value in the stratum, keep all records in the stratum
			keep if temp4==1 | cvalinstrat==0
			drop temp4
			
			* keep positive cases from the previous step
			* if `x' is not a constant cluster value in the stratum, keep only the first record for that stratum
			bys `strat': keep if cvalinstrat==1 | (cvalinstrat==0 & _n==1)
			* need to update the record if the first record happens to be a constant cluster of a different value
			replace nconstclust = 0 if cvalinstrat==0
			
			* for each stratum: probability of selecting constant cluster with value `x' or empty clusters
			gen clogp_ve = (nclustinstrat-1) * (ln(nconstclust + nemptyclust) - ln(nclustinstrat))
			
			* use this to track zero probabilities because ln(0)=. and collapse ignores missing
			gen p_ve0 = (nconstclust + nemptyclust) == 0
			
			collapse (sum) clogp_ve clogp_e np_ve0=p_ve0 np_e0 = p_e0
			gen p_ve = exp(clogp_ve) 
			replace p_ve = 0 if np_ve0 > 0
			gen p_e = exp(clogp_e)
			replace p_e = 0 if np_e0 > 0
			
			local p1 = `p1' + p_ve[1]
			local p2 = `p2' + p_e[1]
			local nval = `nval' + 1
			use `tfile1', clear
		}
		local pactual = `p1' - ((`nval'-1)/`nval')*`p2'
	}
	* probability of selecting only empty clusters when there are no constant-valued clusters
	else {
		collapse (sum) clogp_e np_e0 = p_e0
		gen p_e = exp(clogp_e)
		replace p_e = 0 if np_e0 > 0
		local pactual = p_e[1]
	}
	
	if(`pactual' > `plimit') {
		di "WARNING: Probability of a bootstrap draw with constant `var' if `sel' is `pactual' (>`plimit')"
	}
	else {
		di "Probability of selecting a bootstrap draw with constant `var' if `sel' is `pactual' (<=`plimit')"
	}

	use `orig_data', clear
	erase `orig_data'
end
