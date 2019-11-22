
/** \file
Generate future incoming cohorts (51/52yr olds) based on census population projection and projected trends.


- Use the 2004 as the base
- Apr 1st, convert AIME into 2004 dollars
- Apr 8th, modify mean of wlth_nonzero; mean and variance of loghatotax,simulation of the two
- Apr 12nd, don't allow any feedback
- Wealth distribution - use empirical distribution
- Apr 15th, don't change the smoking trend
- 9/8/2009 - Added new age variables, removed age splines from here
- Simulate status_quo cohorts out to 2080.
- 5/13/2014 - Use 2012 population projections.

\todo convert the all the hard-coded lists of variables in to globals or locals as appropriate.

\todo Resurrect the European SHARE weights, in case we ever want to compare against the European population again.

\todo create a mapping between trends and scenarios to automate the generation of multiple scenarios with different trends

*/
include common.do	

///!\bug Putting random junk in the scenario doesn't cause any errors or even any warnings
local scr : env SCENARIO
* Take bootstrap sample as an argument
local bsamp : env BREP

* Trend file to use for incoming cohorts. Named base_data/trend_all_`trend_name'.dta
local trend_name : env TREND

if `bsamp'==0 {
	local outfile $outdata/new51s_`scr'.dta
}
else {
	local outfile $outdata/input_rep`bsamp'/new51s_`scr'.dta
}	

* Take the year as an argument
local fy : env FYEAR
local ly : env LYEAR

* File to use for population projections
global pop_proj pop5152_projection_2150

* Not adjust economic outcomes to indirect changes
	global indirect_adjust = -1
	
* Don't allow for any feedback
*	global indirect_adjust = -1

* Type of outcome
	global bin hibpe hearte diabe anyhi shlt work wlth_nonzero anydb anydc anyadl anyiadl
	global cont 
	global iht iearnx hatotax dcwlthx 
	global ordered wtstate smkstat rdb_ea_c rdb_na_c
	* For categorical outcomes
	global wtstate_cat overwt obese_1 obese_2 obese_3          
	global smkstat_cat smokev smoken 
	global funcstat_cat iadl1 adl1p
	global rdb_ea_c_cat rdb_ea_2 rdb_ea_3
	global rdb_na_c_cat rdb_na_2 rdb_na_3 rdb_na_4
	global baselist $bin $cont $wtstate_cat $smkstat_cat $funcstat_cat $rdb_ea_c_cat $rdb_na_c_cat
	
	

/*
* Old way of simulating wealth
 **********************************************
 * Dimension of wealth data for imputation
 **********************************************
 	drop _all
	use "$outdata/new51_wlth2004.dta"
	global wlth_impn = _N
	drop _all
*/

**********************************************
* Modify variance of loghatotax
* No, draw hatota from empirical distribution
* No, use Inverse hyperbolic sine transform
**********************************************
			
	* set seed 43241
	clear
	global scenario = "`scr'"  	
	dis "Scenario is: " "$scenario"
  	**********************************************
 	* Import population trends
 	**********************************************
	use "$outdata/$pop_proj.dta", clear

	qui sum year
	local begyr = r(min)
	local maxyr = r(max)

	sort year male hispan black, stable
	gen subgrp = 2^2 * male + 2^1 * hispan + black
	drop male hispan black
	reshape wide pop, i(year) j(subgrp)
	mkmat year pop*, mat(poptrend)
	
	* Row names
	global rowname ""
	forvalues i = `begyr'(2)`maxyr'{
		global rowname $rowname yr`i'
	}
	
	matrix rownames poptrend = $rowname
	
	
	******* Figure out adjustment factors for wealth - To do: calculate this if the user has restricted data access
	
	local res: env RES
	
	if `res'==1 {
*		use "$dua_rand_hrs/age5055_hrs1992r.dta"
		use "$outdata/age5055_hrs1992.dta"
		
  	sum hatotax [aw=weight]
		local mean_hatota92 = r(mean)
  }
  else {
		local mean_hatota92 = 272.3572
  }	
	
	use "$outdata/age5055_hrs2010.dta"
	
	sum hatotax [aw=weight]
	local mean_hatota04 = r(mean)
	local wealth_adj = `mean_hatota04'/`mean_hatota92'
	
	di `wealth_adj'

  ******************
	* The incoming cohort model is estimated from the 1992 cohort. So the means estimates will be for 1992, not 2010. 
	* Therefore need to adjust trends to account for the shift from 1992 to 2010.
	******************
	global trend9210 hibpe hearte diabe anyhi work $wtstate_cat $smkstat_cat anyadl anyiadl 
	
	* Get the 1992 means
	use "$outdata/age5055_hrs1992.dta", clear

	* Create indicator variables for weight status
	gen overwt  = wtstate == 2 if wtstate < .
	gen obese_1 = wtstate == 3 if wtstate < .
	gen obese_2 = wtstate == 4 if wtstate < .
	gen obese_3 = wtstate == 5 if wtstate < .
	
	* Create indicator variables for smoking status
	gen smokev = smkstat == 3 | smkstat == 2 if smkstat < .
	gen smoken = smkstat == 3 if smkstat < .
	
	keep $trend9210 weight
	collapse $trend9210 [pw = weight]
	* collapse $trend9210 
	
	gen year = 1992
	sort year, stable
	tempfile tmp
	save `tmp'


	if `bsamp'==0 {
		use "$outdata/age5055_hrs2010.dta", clear
	}
	else {
		use "$outdata/input_rep`bsamp'/age5055_hrs2010.dta", clear
	}

	* Create indicator variables for weight status
	gen overwt  = wtstate == 2 if wtstate < .
	gen obese_1 = wtstate == 3 if wtstate < .
	gen obese_2 = wtstate == 4 if wtstate < .
	gen obese_3 = wtstate == 5 if wtstate < .
	
	* Create indicator variables for smoking status
	gen smokev = smkstat == 3 | smkstat == 2 if smkstat < .
	gen smoken = smkstat == 3 if smkstat < .
	
	keep $trend9210 weight
	collapse $trend9210 [aw = weight]
	* collapse $trend9210
	
	gen year = 2010
	sort year, stable
	append using `tmp'
	sort year, stable
	
	* For the incoming cohort simulation, we want proportion of EX SMOKERS, not EVER SMOKER
	replace smokev = smokev - smoken
	
	
	mkmat $trend9210, mat(trend9210)
	matrix colnames trend9210 = phibpe phearte pdiabe panyhi pwork pwtstate2 pwtstate3 pwtstate4 pwtstate5 psmkstat2 psmkstat3 panyadl panyiadl
	matrix rownames trend9210 = yr1992 yr2010
	
matlist trend9210
	**********************************************
	* Incoming cohort model predicts categorical BMI
	* Get centiles from 50-55 2010 data and use this to convert categorical to continous
	* Creates a dataset `bmi_centiles' in long format with the following variables:
	* 	centile - 0 to 100 indicating the centile
	*		wtstate - the weight category for the centile, 1 to 5
	* 	bmi			- the bmi for that centile and weight state category
	* The dataset is sorted by centile wtstate
	**********************************************
	
	if `bsamp'==0 {
		use "$outdata/age5055_hrs2010.dta", clear
	}
	else {
		use "$outdata/input_rep`bsamp'/age5055_hrs2010.dta", clear
	}
	gen bmi = exp(logbmi)

	local nwtstate_cats = wordcount("$wtstate_cat")+1
	matrix bmi_centiles = J(101, `nwtstate_cats'+1, .)
	
	quietly{
		forvalues i = 1/`nwtstate_cats'{
			forvalues j = 0/100{
				centile bmi if wtstate == `i', centile(`j')
				matrix bmi_centiles[`j'+1, `i'+1] = r(c_1)
				matrix bmi_centiles[`j'+1, 1] = `j'
			}
		}
	}
	local colnames centile
	forvalues i = 1/`nwtstate_cats'{
		local colnames `colnames' bmi`i'
	}
	matrix colnames bmi_centiles = `colnames'
	clear
	svmat bmi_centiles, names(col)
	reshape long bmi, i(centile) j(wtstate)
	tempfile bmi_centiles
	save `bmi_centiles', replace


	* Process the SSA summary files and reconstruct the distributions by interpolation
	use $resmodels/ssa_dist.dta, replace
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
		
 	*******************************************
 	* Import health trends - DON'T BRING IN HEALTH TRENDS.**
 	**********************************************	

 	drop _all
 	use "$outdata/trend_all_`trend_name'"

 	keep year phibpe phearte pdiabe panyhi pwtstate2 pwtstate3 pwtstate4 pwtstate5 psmkstat2 psmkstat3 panyadl panyiadl pwork pwlth_nonzero plogiearnx ploghatotax panydc panydb  
 	
	if "`scr'" == "obese_r"{
		* Shut down the  trends in obesity, diabetes, and hypertension
		 foreach x in phibpe pdiabe pwtstate2 pwtstate3 {
		*	foreach x in phibpe pdiabe{
			replace `x' = 1
		}
	}
	else if "`scr'" == "obs80"{
		* Return to the 1976-1980 NHANES level 
   	merge m:1 year using $outdata/obs80_adjustments.dta, nogen update replace keepusing(pdiabe phibpe pwtstate3 pwtstate4 pwtstate5)
    
    * keep pwtstate2 constant
    replace pwtstate2 = 1 if year < = 2030
 
    foreach x in pdiabe pwtstate2 pwtstate3 pwtstate4 pwtstate5 phibpe {
    	qui sum `x' if year == 2030
      replace `x' = r(mean) if year > 2030
    }

	}

	else if "`scr'" == "obs_flat"{
		
		**keep obesity flat.**
		
		replace pwtstate2 = 1
		replace pwtstate3 = 1
		replace pwtstate4 = 1
		replace pwtstate5 = 1
		
		replace pdiabe = 1
		replace phibpe = 1
	}
	
	else if "`scr'" == "smk80"{
		* Return to the 1976-1980 NHANES level
         replace psmkstat3 = (1 + 0.016) ^ (year - 2010) if year <= 2030
         qui sum psmkstat3 if year == 2030
         replace psmkstat3 = r(mean) if year > 2030
	}

	else if "`scr'" == "smk_flat"{
		**Keep smoking at 2010 level
		replace psmkstat2 = 1
		replace psmkstat3 = 1
	}
	
	else if "`scr'" == "notrend"{
		* Shut down the  trends in everything
		 foreach x in phibpe phearte pdiabe panyhi pwtstate2 pwtstate3 psmkstat2 psmkstat3 panyadl panyiadl pwork pwlth_nonzero plogiearnx ploghatotax panydc panydb {
			replace `x' = 1
		}
	}
 
	* Generate other trends

  	foreach x in shlt aime q rdb_na_2  rdb_na_3 rdb_na_4 rdb_ea_2 rdb_ea_3 hatotax iearnx dcwlthx {
 		qui gen p`x' = 1
 	}

	* Rename variables 
	forvalues i = 2/3{
		ren prdb_ea_`i' prdb_ea_c`i'
	}
	forvalues i = 2/4{
		ren prdb_na_`i' prdb_na_c`i'
	}
			
	******************
	* Adjust for the the trend between 1992 to 2010 (estimtion sample for initial cohort is from year 1992)
	******************
	local tlist : colnames trend9210
	foreach x in `tlist' {
		local ratio =trend9210[rownumb(trend9210, "yr2010"), colnumb(trend9210, "`x'")]/ trend9210[rownumb(trend9210, "yr1992"), colnumb(trend9210, "`x'")]
		sum `x'
		replace `x' = `x' * `ratio'
		sum `x'
		
	}

		
	* Keep only even years
	keep if mod(year,2) == 0

	qui sum year
	local begyr = r(min)
	local maxyr = r(max)
 	 mkmat * , mat(hlthtrend)
 
 	* Row names
	global rowname ""
	forvalues i = `begyr'(2)`maxyr'{
		global rowname $rowname yr`i'
	} 
	
	matrix rownames hlthtrend = $rowname
	matlist hlthtrend
	
 	**********************************************
 	* Interventions on the trends
 	**********************************************	
	* Multiple trends shut down
	* if "$scenario" == "multi_r" | "$scenario" == "shareprev" {
	if "$scenario" == "multi_r" {
		local exclvar1 smkstat
		local exclvar2 wtstate
		local trow = rowsof(hlthtrend)
		local tcol = colsof(hlthtrend)
		local cyear = colnumb(hlthtrend,"year")
	
		local ckeep2 = colnumb(hlthtrend,"p`exclvar1'2")
		local ckeep3 = colnumb(hlthtrend,"p`exclvar1'3")		
		local ckeep4 = colnumb(hlthtrend,"p`exclvar2'2")
		local ckeep5 = colnumb(hlthtrend,"p`exclvar2'3")		
		local ckeep6 = colnumb(hlthtrend,"phibpe")
		* local ckeep7 = colnumb(hlthtrend,"phearte")		
		* local ckeep8 = colnumb(hlthtrend,"pdiabe")		
		local ckeep7 = colnumb(hlthtrend,"pdiabe")	
						
		forvalues i = 1/`trow' {
			forvalues k = 4/7{
				matrix hlthtrend[`i',`ckeep`k''] = 1
			}
		}
	}

	
	

	 **********************************************
	 * Import V-C matrix
	 **********************************************	
 	drop _all	
 	use "$indata/incoming_vcmatrix.dta"
 	
 	
 	rename fhibpe hibpe
 	rename fhearte hearte
 	rename fdiabe diabe
 	rename fanyhi anyhi
 	rename fshlt shlt
 	rename fwtstate wtstate
 	rename fsmkstat smkstat
 	rename fanyadl anyadl
 	rename fanyiadl anyiadl
	rename fwork work
	rename fwlth_nonzero wlth_nonzero
*	rename fraime aime
*	rename frq q
	rename fanydc anydc
	rename fanydb anydb
	rename frdb_ea_c rdb_ea_c
	rename frdb_na_c rdb_na_c
	drop _rowname
 	
 	/*
 	foreach i in $iht{
 		rename log`i' `i' 
 	}
 	*/
 	
 	mkmat *, mat(omega)
	local d = colsof(omega)
	forvalues i = 1/`d'{
		local k = `i'+1
		forvalues j = `k'/`d'{
			matrix omega[`i',`j'] = omega[`j',`i']
		}
	}
	local colname: colnames omega
	noi dis "`colname'"
	matrix rownames omega = `colname'
	local num = rowsof(omega)
	
	* Get the variance of earnings, hatota, and dcwlth
	drop _all
	use "$indata/incoming_means_econ_tos.dta"
	mkmat theta omega ssr, matrix(iht_tos) rownames(_rowname)
	drop _all

/* * This happens when the matrix is created.
 	matrix omega[rownumb(omega,"iearnx"), colnumb(omega,"iearnx")] = iht_tos[rownumb(iht_tos,"iearnx"), colnumb(iht_tos,"ssr")]
	matrix omega[rownumb(omega,"hatotax"), colnumb(omega,"hatotax")] = iht_tos[rownumb(iht_tos,"hatotax"), colnumb(iht_tos,"ssr")]
	matrix omega[rownumb(omega,"dcwlthx"), colnumb(omega,"dcwlthx")] = iht_tos[rownumb(iht_tos,"dcwlthx"), colnumb(iht_tos,"ssr")]
		
	*********
	* Covariance should be adjusted too
	  forvalues i = 1/`num' {
	  	forvalues j = 1/`num'{
	  		if `i' != `j' {
	  			matrix omega[`i', `j'] = tanh( omega[`i', `j']) * sqrt(omega[`i', `i'] * omega[`j', `j'])
	  		}
	  	}
	  }

	*/
	
	
	  matrix list omega
	  
	* Different V-C matrices with each of the outcome as the first row

	foreach x in `colname' {
		takestring_old, oldlist("`colname'") newname("addlist") extlist("`x'")
		global vlist `x' $addlist
		matrix vc_`x' = J(`num',`num',.)
		matrix colnames vc_`x' = $vlist
		matrix rownames vc_`x' = $vlist
		foreach y in $vlist {
			foreach z in $vlist {
				matrix vc_`x'[rownumb(vc_`x',"`y'"), colnumb(vc_`x', "`z'")] =  omega[rownumb(omega,"`y'"), colnumb(omega,"`z'")]
			}
		}
	}
	
	
	
	* Cholesky decomposition
	matrix L_omega = cholesky(omega)
	foreach x in `colname'{
		matrix L_`x' = cholesky(vc_`x')
	}

  **********************************************
 	* Import mean-estimation matrix
 	**********************************************	
 	drop _all
 	use "$indata/incoming_means.dta"
 	gen order = _n
 	drop _rowname
	
	* append using "$indata/incoming_means_econ.dta"
	/* 
	foreach v in $iht {
		replace order = rownumb(omega,"`v'") if var == "`v'"
	}
	drop var
	*/
	
	sort order, stable
	if "`scr'" == "fem_work"{
		replace constant = constant + male if inlist(order,9,11,14)
		replace male = 0 if inlist(order,9,11,14)
	}
	
 	drop order
 	mkmat *, mat(meanest)
 	matrix rownames meanest = `colname'
 	mat list meanest
	
	************************************************
	* Create matrices for SSA-related joint models *
	************************************************
	drop _all
	use "$resmodels/ssa_vcmatrix.dta"
	
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
		takestring_old, oldlist("`ssa_colname'") newname("addlist") extlist("`x'")
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
 	use "$resmodels/ssa_means.dta"
 	gen order = _n
 	drop _rowname
	
	sort order, stable
 	drop order
 	mkmat *, mat(ssa_meanest)
 	matrix rownames ssa_meanest = `ssa_colname'
 	mat list ssa_meanest
 	
 	
 	* Read in the file with the cut points for the SSA ordered probit models, make a matrix for later use 
 	drop _all
 	use "$resmodels/ssa_cut_points.dta"
 	mkmat cut_*, mat(ssa_cutpoints) rownames(_rowname)
 	
	mat list ssa_cutpoints
	local ssa_cuts = colsof(ssa_cutpoints)
	
	forvalues x = 1/`ssa_cuts' {
		foreach y in aime_pct q_pct {
			scalar `y'_cut`x' = ssa_cutpoints[rownumb(ssa_cutpoints,"`y'"),colnumb(ssa_cutpoints,"cut_`x'")]
			di `y'_cut`x'
		}
	}

	
	
		
	**********************************************
	* Import Estimation for DI claim and DB tenure
	* Apr 8 2008, add ssiclaim
	**********************************************	
	* IMPORT ESTIMATES 
		foreach var in init_diclaim init_logtenure init_ssiclaim init_hatota {
			mata: _getestimates("$resmodels/m`var'","$resmodels/s`var'", "coef_`var'")
	 	}    	 

	**********************************************
	* Import Estimation for deprsymp hearta heartae stroks
	**********************************************	
	* IMPORT ESTIMATES 
		foreach var in init_deprsymp init_hearta init_heartae {
			mata: _getestimates("$outdata/m`var'","$outdata/s`var'", "coef_`var'")
	 	}  
			 	
	**********************************************
 	* Import the incoming cohort, baseline prevalence and predicted prevalence
 	* Baseline prevalence might be inaccurate
 	**********************************************	

  	* A list for random draws
  	global drawlist ""
  	foreach x in `colname' {
  	global drawlist $drawlist d_`x'
  	}

 	drop _all
 	
 	* Read in the file with the cut points for the ordered probit models, make a matrix for later use 
 	use "$indata/incoming_cut_points.dta"
 	mkmat cut_1 cut_2 cut_3 cut_4, mat(cutpoints) rownames(_rowname)
 	
 	
 	
 	
	use "$outdata/incoming_base.dta"
	
	
	* if missing("`bsamp'") & "`scr'" != "bootstrap" {
	*	use "$outdata/incoming_base.dta", clear
	*}
	*else {
	*	use "$outdata/input_rep`bsamp'/incoming_base.dta", clear
	*}
	
	sort male hispan black, stable
	gen subgrp = 2^2 * male + 2^1 * hispan + black
	  
	* Set cutoffs for ordered outcomes
	scalar wtstate_cut1 =     cutpoints[rownumb(cutpoints,"fwtstate"),colnumb(cutpoints,"cut_1")]	        
	scalar wtstate_cut2 =     cutpoints[rownumb(cutpoints,"fwtstate"),colnumb(cutpoints,"cut_2")]		
	scalar wtstate_cut3 =     cutpoints[rownumb(cutpoints,"fwtstate"),colnumb(cutpoints,"cut_3")]	
	scalar wtstate_cut4 =     cutpoints[rownumb(cutpoints,"fwtstate"),colnumb(cutpoints,"cut_4")]	
	scalar smkstat_cut1 =     cutpoints[rownumb(cutpoints,"fsmkstat"),colnumb(cutpoints,"cut_1")]	        
	scalar smkstat_cut2 =     cutpoints[rownumb(cutpoints,"fsmkstat"),colnumb(cutpoints,"cut_2")]
	scalar rdb_ea_c_cut1	=   cutpoints[rownumb(cutpoints,"frdb_ea_c"),colnumb(cutpoints,"cut_1")]		        
	scalar rdb_ea_c_cut2	=   cutpoints[rownumb(cutpoints,"frdb_ea_c"),colnumb(cutpoints,"cut_2")]	
	scalar rdb_na_c_cut1	=   cutpoints[rownumb(cutpoints,"frdb_na_c"),colnumb(cutpoints,"cut_1")]	        
	scalar rdb_na_c_cut2	=   cutpoints[rownumb(cutpoints,"frdb_na_c"),colnumb(cutpoints,"cut_2")]
	scalar rdb_na_c_cut3	=   cutpoints[rownumb(cutpoints,"frdb_na_c"),colnumb(cutpoints,"cut_3")]	
	
	gen constant = 1
	
	* Predicted prevalence
	local j = 1
	foreach x in `colname' {
		matrix betamat = meanest[`j',1...]
		cap drop `x'_xb
		
		matrix score `x'_xb = betamat
		local j = `j' + 1
		matrix mat_`x' = betamat
		
		mat list mat_`x'
		sum `x'_xb
		
		
	}

   drop constant

	**********************************************
	* Form new linear combinations
	* A vector of incremental changes in linear combination
	**********************************************	
		
	**********************************************
	* Simulate future years' data
	**********************************************	

	matrix share_us = (0.474 ,0.474,0.474,0.474, 0.72, 1.28, 0.31, 0.40, 0.44, 0.46, 0.62, 0.49)
	matrix colnames share_us = poverwt pobese_1 pobese_2 pobese_3 psmokev psmoken phearte pdiabe pstroke plunge pcancre phibpe

cap rm `outfile'
preserve
forvalues yy=`fy'(2)`ly' {
restore, preserve
	  dis "***** Projection year is `yy' ***** "

	  /* Generate random draws */ 	
	  cap drop $drawlist
	  drawnorm $drawlist, cov(omega) seed(987562)	
	  
	  noisily sum d_*
	  
	  set seed 432422
	  if "$scenario" == "shareprev" {
	  	
	  	*SHARE prevalence
		  foreach c in stroke lunge cancre {
			qui sum `c'
			cap drop p`c'
			qui gen p`c' = 1 - r(mean)
			
		  }
		foreach c in pstroke plunge pcancre {
			local cnum = colnumb(share_us, "`c'")
			qui sum `c'
			local oldm = 1 - r(mean)
			local newm = share_us[1,`cnum']
			replace `c' = 1 - (1 - `c') * `newm'
		}			  
		  foreach c in stroke lunge cancre {
			cap drop draw
			qui gen draw = uniform()
			replace `c' = draw >= p`c'
			drop draw
		}
		
	  }
	  else if "$scenario" != "shareprev" {
	  
	  	  * Make sure RN sequence the same
		  foreach c in stroke lunge cancre {
			cap drop draw
			qui gen draw = uniform()
			drop draw
		}
		  	
	  }
		  
	/* Determine the deviations */
	foreach x in $bin {
			new_deviation, vname("`x'") vtype("b") cyr(`yy') data("hrs")
		}
		
	sum hearte_delta	
		
	foreach x in $ordered {
			new_deviation, vname("`x'") vtype("o") cyr(`yy') data("hrs")
	}				
	foreach x in $cont $iht {
			new_deviation, vname("`x'") vtype("c") cyr(`yy') data("hrs")
		}
			
	/* new latent variables */ 	
	* If adjust each outcome to all changes
	if $indirect_adjust == 0 { 					
		foreach x in $bin $ordered {
			cap drop inc`x'
			qui gen inc`x' = 0
			foreach y in $bin $ordered {
					qui replace inc`x' = inc`x' + L_`y'[rownumb(L_`y',"`x'"), colnumb(L_`y', "`y'")] * `y'_delta
			di "inc`x' `y'_delta"
			sum inc`x'
			sum `y'_delta
			}
			cap drop `x'_xb_new
			qui gen `x'_xb_new = `x'_xb + inc`x'
			sum `x'_xb_new 
			sum `x'_xb 
			sum inc`x'
		}
		foreach x in $cont $iht{
			cap drop inc`x'
			qui gen inc`x' = 0
			qui replace inc`x' = inc`x' + L_`x'[rownumb(L_`x',"`x'"), colnumb(L_`x', "`x'")] * `x'_delta
			cap drop `x'_xb_new
			qui gen `x'_xb_new = `x'_xb + inc`x'
		}							

	}
	
	* Allow for all feedbacks
	else if $indirect_adjust == 1 {
		foreach x in $bin $ordered $cont $iht{
			cap drop inc`x'
			qui gen inc`x' = 0
			foreach y in $bin $ordered $cont $iht {
					qui replace inc`x' = inc`x' + L_`y'[rownumb(L_`y',"`x'"), colnumb(L_`y', "`y'")] * `y'_delta
			}
			cap drop `x'_xb_new
			qui gen `x'_xb_new = `x'_xb + inc`x'
		}												
	}
		
	* Don't allow for any feedback
	else if $indirect_adjust == -1 {
		foreach x in $bin $ordered $cont $iht {
			cap drop inc`x'
			qui gen inc`x' = 0
			foreach y in `x' {
			qui replace inc`x' = inc`x' + `y'_delta
			}
			* Bryan's addition for diagnotic purposes
			* sum *_delta
			
			cap drop `x'_xb_new
			qui gen `x'_xb_new = `x'_xb + inc`x'
		  sum `x'_xb_new 
			sum `x'_xb 
			sum inc`x'
		}												
	}							
		
	/* Predicted probabilities */ 			

	* Determine the probabilities
	* Binary outcomes
	foreach x in $bin{
		cap drop p`x'
		gen p`x' = normal(-`x'_xb_new)
	}
	sum phearte


	**** For Weight and Smoking, we get new values by adjusting the cutoffs to match desired probabilities 

	foreach v in wtstate smkstat {
		local ncuts = wordcount("$`v'_cat")
		local ncats = `ncuts'+1
		/*
		summ `v'_xb_new
		local xb_mean = r(mean)
		*/
		* The hlthtrend matrix is the trend from 1992. So multiply by the proportion in 1992 to get proprotion in year yy
		local p1 = 1
		forvalues probs = 2/`ncats' {
			local x   p`v'`probs'
			local p`probs' = hlthtrend[rownumb(hlthtrend,"yr`yy'"), colnumb(hlthtrend, "p`v'`probs'")]*trend9210[rownumb(trend9210, "yr1992"), colnumb(trend9210, "`x'")]
			local p1 = `p1' - `p`probs''
		}
		assert `p1' >= 0
		assert `p1' <= 1
		
		* Adjust the cuts
		 forvalues c = 1/`ncuts' {
			local c_prev = `c' - 1
			if `c' == 1 {
					dis "`v'"
					dis "`p1'"
			    calc_cut_point `v'_xb_new,  prob(`p1') prev_cut(-9999)
			}
			else {
				  local prev_cut = `v'_cut`c_prev'
				  dis "`v'"
				  dis "`prev_cut'"
				  dis "`p`c''"
				  calc_cut_point `v'_xb_new,  prob(`p`c'') prev_cut(`prev_cut')
			}
			matrix x = e(b)
			scalar `v'_cut`c' = x[1,1]
			
			* noi di "Cut `v'_cut`c' = " `v'_cut`c'
		}
/*
		* Adjust the cuts
		forvalues c = 1/`ncuts' {
			local c_next = `c' + 1
			local c_prev = `c' - 1
			if `c' == 1 {
					scalar `v'_cut`c' = invnorm(`p1')+`xb_mean'
			} 
			else if `c' == `ncuts' {
					scalar wtstate_cut`c' = invnorm(1-`p`c_next'')+`xb_mean'
			}
			else {
						scalar wtstate_cut`c' = invnorm(`p`c''+normal(`v'_cut`c_prev'-`xb_mean'))+`xb_mean'
			}
		}
		*/
		
		forvalues c = 1/`ncats' {
			di "`v'_`c' = `p`c''"
		}
	}	

	
	* Ordered outcomes
	foreach x in $ordered{
		if "`x'" == "rdb_na_c" {
			local numcut = 4
		}
		else if "`x'" == "wtstate"{
			local numcut = 5
		}
		else{
			local numcut = 3
		}
			
		forvalues j = 1/`numcut'{
			if `j' < `numcut'{
				gen p`x'`j' = normal(`x'_cut`j' - `x'_xb_new)
			}
			else if `j' == `numcut'{
				gen p`x'`j' = 1
			}
		}
	}		
	


	/* Predicted probabilities for shareprev scenario*/
	if "$scenario" == "shareprev"  {
	
		local clist: colnames share_us
		foreach c in pdiabe phibpe phearte {
			local cnum = colnumb(share_us, "`c'")
			qui sum `c'
			local oldm = 1 - r(mean)
			local newm = share_us[1,`cnum']
			replace `c' = 1 - (1 - `c') * `newm'
		}
			
		* Ordinal outcomes
		gen poverwt = pwtstate2 - pwtstate1
		gen pobese_1 = pwtstate3 - pwtstate2
		gen pobese_2 = pwtstate4 - pwtstate3
		gen pobese_3 = pwtstate5 - pwtstate4
		
		gen psmokev = psmkstat2 - psmkstat1
		gen psmoken = psmkstat3 - psmkstat2

		foreach c in poverwt pobese_1 pobese_2 pobese_3 psmoken psmokev {
			local cnum = colnumb(share_us, "`c'")
			qui sum `c'
			local oldm = r(mean)
			local newm = share_us[1,`cnum']	 						
			replace `c' = `c' * `newm'
		}
		
		replace pwtstate4 = pwtstate5 - pobese_3
		replace pwtstate3 = pwtstate4 - pobese_2
		replace pwtstate2 = pwtstate3 - pobese_1
		replace pwtstate1 = pwtstate2 - poverwt
		
		replace psmkstat2 = psmkstat3 - psmoken
		replace psmkstat1 = psmkstat2 - psmokev
	} 			

	/* Determine the status */ 	 
	* Binary outcomes	
	foreach x in $bin {
		cap drop `x'
		gen `x' = normal(d_`x') >= p`x'
		* For diagnostics
		sum `x'
		sum d_`x'
		sum `x'
		
		drop p`x'
		
	}					

	* Ordered outcomes
	foreach x in $ordered {
		cap drop `x'
		gen `x' = .
		if "`x'" == "rdb_na_c" {
			local num_cut = 4
			}
		else if "`x'" == "wtstate"{
			local num_cut = 5
		}
		else{
			local num_cut = 3
			}
		forvalues i = `num_cut'(-1)1 {
			replace `x' = `i' if normal(d_`x') <= p`x'`i'
			drop p`x'`i'
			}
		}	

	* Continuous
	foreach x in $cont {
		cap drop `x'
		* Removing draw term for the $cont variables:   
		gen `x' = `x'_xb_new + d_`x'
		* Added by Bryan for testing
		noisily sum `x' `x'_xb_new d_`x'
	}
	
	* Added by Bryan for testing
	noisily sum $cont
	

	**THETA and OMEGA for iearnx, hatotax, and dcwlthx
		
	foreach v in $iht {
		local `v'_omega = iht_tos[rownumb(iht_tos,"`v'"), colnumb(iht_tos,"omega")]
		local `v'_theta = iht_tos[rownumb(iht_tos,"`v'"), colnumb(iht_tos,"theta")]
	}


	* IHT
	
	**Instead of taking logs, take log(y+sqrt(y^2+1)) - gh(y,1,0)
	
	gen _ahg_temp = iearnx_xb_new + d_iearnx
	drop iearnx logiearnx iearnuc logiearnuc
	egen _iearnx = invgh(_ahg_temp), theta(`iearnx_theta') omega(`iearnx_omega')
	replace _iearnx = 0 if _iearnx < 0 | _iearnx == .
	/* Bryan's edits trying to incorporate iearnuc and logiearnuc */
	gen iearnuc = _iearnx if !missing(_iearnx)
	egen logiearnuc = h(iearnuc)
	replace logiearnuc = logiearnuc/100
	tabstat iearnuc, stat(mean, median, min, max)
	tabstat logiearnuc, stat(mean, median, min, max)
	
	replace _iearnx = min(_iearnx,200) if !missing(_iearnx)
	egen logiearnx = h(_iearnx)
	replace logiearnx = logiearnx/100
	rename _iearnx iearnx
	
	**Force iearnx to be >=0.**
	

	
	drop _ahg_temp
	gen _ahg_temp = hatotax_xb_new + d_hatotax
	drop hatotax hatota loghatotax loghatota
	egen _hatotax = invgh(_ahg_temp) , theta(`hatotax_theta') omega(`hatotax_omega')
	replace _hatotax = 0 if wlth_nonzero != 1
	**Adjust for growth from 1992 - 2010.
	replace _hatotax = _hatotax * `wealth_adj'
	gen hatota = _hatotax
	replace _hatotax = min(_hatotax,2000) if _hatotax!=.
	egen loghatotax = h(_hatotax)
	replace loghatotax = loghatotax/100
	rename _hatotax hatotax


	drop _ahg_temp
	gen _ahg_temp = dcwlthx_xb_new + d_dcwlthx
	drop dcwlthx logdcwlthx
	egen _dcwlthx = invgh(_ahg_temp), theta(`dcwlthx_theta') omega(`dcwlthx_omega')
	replace _dcwlthx = 0 if _dcwlthx < 0 | _dcwlthx == .
	egen logdcwlthx = h(_dcwlthx)
	replace logdcwlthx = logdcwlthx/100
	rename _dcwlthx dcwlthx
	drop _ahg_temp
		
		
		
	* New approach for aime and quarters worked - estimated a model on the 2004 50-55 year olds
	drawnorm d_aime_pct d_q_pct, cov(ssa_omega) seed(987562)	
	
	sum d_aime_pct
	sum d_q_pct
	
	cap gen __cons = 1
	
	foreach var in black hispan hsless college cancre diabe hibpe hearte lunge stroke anyadl anyiadl work age logiearnx loghatotax {
		gen male_`var' = male*`var'
	} 
	
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
	merge m:1 aime_pct using `ssa', keepusing(aime_dist) nogen
	* Fill in the quarters worked values
	merge m:1 q_pct using `ssa', keepusing(q_dist) nogen
	
	rename aime_dist raime_test
	rename q_dist rq_test		
			
	gen raime = raime_test
	gen rq = rq_test
	gen fraime = raime
	gen frq = rq
	
	drop aime_pct raime_test q_pct rq_test
	
			
	* Calculate rpia for each respondent
	* Calculate PIA for each respondent
	gen rl = 1 if died == 0
	* No death year, since alive
	gen rdthyr = 2100 if died == 0
	* Calculate PIA
	SsPIA_v2 raime rq rbyr rl rdthyr, gen(rpia)
	drop rl rdthyr	
			
				
		
		
	/*
	foreach x in $iht {
		cap drop `x'
		egen `x' = log(invgh(`x'_xb_new + d_`x',theta, omega))
	}
	*/

	* Binary and censored
	replace anydb = 0 if work != 1
	replace anydc = 0 if work != 1
		
	* Ordered and censored
	replace rdb_ea_c = 0 if anydb != 1
	replace rdb_na_c = 0 if anydb != 1
		
	* Continuous and truncated
	replace logiearnx = 0 if work != 1
	replace logdcwlthx = 0 if anydc != 1
	replace loghatotax = 0 if wlth_nonzero != 1
	replace iearnx = 0 if work != 1
	replace dcwlthx = 0 if anydc != 1
	replace hatotax = 0 if wlth_nonzero != 1
	* Bryan's edits to incorporate iearnuc and logiearnuc
	replace logiearnuc = 0 if work != 1
	replace iearnuc = 0 if work != 1
		
	* Fix inconsistencies in early versus normal retirement age (the former cannot be larger than the latter)
	replace rdb_ea_c = 2 if rdb_na_c == 1 & rdb_ea_c == 3

	/* Dummies for ordered outcomes */	
	foreach x in $ordered {
		if "`x'" == "rdb_na_c" {
			local num_cut = 4
		}
		else if "`x'" == "wtstate"{
			local num_cut = 5
		}
		else{
			local num_cut = 3
		}
		forvalues j = 2/`num_cut'{
			local ovar = "`x'_cat"
			local v = word("$`ovar'", `j'-1)
			cap drop `v'
			gen `v' = `x' == `j'
		}
	}				
			
	/* Adjust the population weight to reflect population size and structual change */
	levelsof subgrp, local(subgrplv)
	dis "********** current year is: `yy' *************"
	gen weight`yy' = .
	foreach l of local subgrplv {
	  local popratio = poptrend[rownumb(poptrend, "yr`yy'"), colnumb(poptrend,"pop`l'")]/poptrend[rownumb(poptrend, "yr2010"), colnumb(poptrend,"pop`l'")]
		replace weight`yy' = weight * `popratio' if subgrp == `l'
		}
	* Old HH total person level weight
	bys hhid: egen oldhhwt = total(weight)
		
	* New HH total person level weight
	bys hhid: egen newhhwt = total(weight`yy')
		
	* Adjust HH weight
	 gen wthh`yy' = wthh * newhhwt/oldhhwt

sum hearte
sum hearte [aw=weight]		 
			 
	drop weight wthh oldhhwt newhhwt
	ren weight`yy' weight
	ren wthh`yy' wthh

sum hearte
sum hearte [aw=weight]	
			
	*smokev includes smoken
	replace smokev = 1 if smoken == 1


	* Resort everything by HHIDPN. This fixes problems with the previous bys hhid that was unstable sorting
	sort hhidpn

	label var iearnx "Individual earnings in 1000s-max 200"
	label var hatotax "HH wlth in 1000s if positive,zero otherwise"
	label var dcwlthx "Individual DC wlth wv1-5 only in 1000s(=dcwlth)"
	label var logiearnx "(Log of earnings in 1000s)/100 if working,zero otherwise"
	label var logdcwlthx "(Log of DC wlth in 1000s)/100 if any DC,zero otherwise"
	label var loghatotax "(Log of hh wlth in 1000s if positive)/100,zero otherwise"										
	label var iearnuc "Individual earnings in 1000s - uncapped"
	label var logiearnuc "IHT of earnings in 1000s/100 if working, zero otherwise"
	
	**PUT IN GROWTH FACTOR TO GET FROM 1992-2004.**
		
	***************************************
	* Predict tenure for those with DB
	* Regression-based
	***************************************	
  	matrix score logtenure = coef_init_logtenure
        drop db_tenure
	gen db_tenure = 10 * exp(logtenure) if anydb == 1		
	* Maximum tenure
	replace db_tenure = min(age_yrs - 15, db_tenure)	if anydb == 1
	replace db_tenure = -2 if anydb != 1	
	drop logtenure

	***************************************
	* Predict DI claim
	* Regression-based
	***************************************	
	matrix score diclaim_xb = coef_init_diclaim
        drop diclaim
	gen x_diclaim = invnorm(uniform()) 
	gen diclaim = x_diclaim + diclaim_xb >= 0
	drop x_diclaim diclaim_xb

	***************************************
	* Predict SSI claim
	* Regression-based
	***************************************	
	matrix score ssiclaim_xb = coef_init_ssiclaim
        drop ssiclaim
	gen x_ssiclaim = invnorm(uniform()) 
	gen ssiclaim = x_ssiclaim + ssiclaim_xb >= 0
	drop x_ssiclaim ssiclaim_xb
		
	***************************************
	* Predict deprsymp
	* Regression-based
	***************************************	
	matrix score deprsymp_xb = coef_init_deprsymp
	drop deprsymp
	gen x_deprsymp = invnorm(uniform())
	gen deprsymp = x_deprsymp + deprsymp_xb >=0
	drop x_deprsymp deprsymp_xb

	***************************************
	* Predict painstat
	* Regression-based
	***************************************	
	est use $outdata/new51_painstat.ster
	predict painstat_xb, xb
	gen x_painstat = invnorm(uniform())
	gen painstat = 1 if x_painstat + painstat_xb <= _b[/cut1]
	replace painstat = 2 if x_painstat + painstat_xb > _b[/cut1] & x_painstat + painstat_xb <= _b[/cut2]
	replace painstat = 3 if x_painstat + painstat_xb > _b[/cut2] & x_painstat + painstat_xb <= _b[/cut3]
	replace painstat = 4 if x_painstat + painstat_xb > _b[/cut3]
	drop x_painstat painstat_xb
	est clear

	***************************************
	* Predict adlstat conditional on anyadl
	* Regression-based
	***************************************
        drop adlstat
	est use $outdata/new51_adlstat.ster
	predict adlstat_xb, xb
	gen x_adlstat = invnorm(uniform())
	gen adlstat = 1 if !anyadl 
	replace adlstat =	2 if x_adlstat + adlstat_xb <= _b[/cut1] & anyadl
	replace adlstat = 3 if x_adlstat + adlstat_xb > _b[/cut1] & x_adlstat + adlstat_xb <= _b[/cut2] & anyadl
	replace adlstat = 4 if x_adlstat + adlstat_xb > _b[/cut2] & anyadl
	drop x_adlstat adlstat_xb anyadl
	est clear

	***************************************
	* Predict iadlstat conditional on anyiadl
	* Regression-based
	***************************************
        drop iadlstat
	est use $outdata/new51_iadlstat.ster
	predict iadlstat_xb, xb
	gen x_iadlstat = invnorm(uniform())
	gen iadlstat = 1 if !anyiadl
	replace iadlstat = 2 if x_iadlstat + iadlstat_xb < 0 & anyiadl
	replace iadlstat = 3 if x_iadlstat + iadlstat_xb >= 0 & anyiadl
	drop x_iadlstat iadlstat_xb anyiadl
	est clear
			
	***************************************
	* Predict hearta
	* Regression-based
	***************************************	
	matrix score hearta_xb = coef_init_hearta
	drop hearta
	gen x_hearta = invnorm(uniform())
	gen hearta = x_hearta + hearta_xb >=0
	drop x_hearta hearta_xb
	replace hearta = 0 if hearte == 0
	
	***************************************
	* Predict heartae
	* Regression-based
	***************************************	
	matrix score heartae_xb = coef_init_heartae
	drop heartae
	gen x_heartae = invnorm(uniform())
	gen heartae = x_heartae + heartae_xb >=0
	drop x_heartae heartae_xb
	replace heartae = 0 if hearte == 0
	replace heartae = 1 if hearta == 1
	
	*** Impute early and normal DB retirement age
        drop era nra
	recode rdb_ea_c (1 = 50) (2 = 55) (3 = 60) , gen(era)
	recode rdb_na_c (1 = 55) (2 = 60) (3 = 62) (4 = 65) , gen(nra)
        drop rdb_ea_* rdb_na_*
		
* Turn the categorical BMI into logbmi using centiles from 2004 data
* These centiles were created earlier and are stored in the temp dataset `bmi_centiles'
	
* Do a random draw from 0 - 100 for each person
gen centile = round(uniform()*100)

sort centile wtstate

* Merge with the centile dataset
merge n:1 centile wtstate using `bmi_centiles', keep(match) nogen

* Resort everything by HHIDPN.
sort hhidpn

* Generate logbmi
drop logbmi
gen logbmi = log(bmi)

* Remove helper vars
drop centile obese_* overwt wtstate bmi

foreach v in $timevariant cogstate selfmem {
	gen l2`v' = `v'
	local vlb: var label `v'
	label var l2`v' "Two-year lag of `vlb'"
	}
	
foreach v in $flist {
	gen f`v' = `v'
	local vlb: var label `v'
	label var f`v' "Init.of `vlb'"
	}
	gen period = 1
	cap drop year			
	gen year = `yy'
	
	drop d_* *_xb*  *_delta inc*

	* Sep 9, 2008
	
	**Change hatota, earnings variables.**
	drop l2loghatota l2loghatotax l2logiearnx l2logiearnuc
	
	* removed iearn from the following loop
	foreach i in hatota hatotax iearnx iearnuc{
          egen l2log`i' = h(l2`i')
          replace l2log`i' = l2log`i'/100
	}

        foreach i in iearnx iearnuc {
          drop flog`i'
          egen flog`i' = h(`i')
          replace flog`i' = flog`i'/100
        }

	* Create fvars at age 50
	foreach v in diabe smoken logbmi heart strok hibp lung canc {
          drop f`v'50
		if "`v'" == "canc" {
			gen f`v'50 = `v're
			local vlb: var label `v're
			label var f`v'50 "Init. of `vlb' at age 50"
		}		
		else if "`v'" == "heart" | "`v'" == "strok" | "`v'" == "hibp" | "`v'" == "lung" {
			gen f`v'50 = `v'e
			local vlb: var label `v'e
			label var f`v'50 "Init. of `vlb' at age 50"
		}
		else {
			gen f`v'50 = `v'
			local vlb: var label `v'
			label var f`v'50 "Init. of `vlb' at age 50"
		}
	} 


	recast long hhid
	recast long hhidpn
desc hhid*
       tostring hhid, gen(hhidstr) 
       tostring hhidpn, gen(hhidpnstr) usedisplayformat
        
        drop hhid hhidpn
        gen hhid = "-`yy'" + hhidstr
        gen hhidpn = "-`yy'" + hhidpnstr
        destring hhid hhidpn, replace
	drop hhidpnstr hhidstr

	replace rbyr = rbyr + year - 2010
	* Increment mean birth year of children 
	*replace kid_byravg = kid_byravg + year - 2010

	* make sure chf agrees with hearte
	replace chfe=0 if hearte==0
	replace l2chfe=0 if l2hearte==0

	if "`scr'" == "whiter"{
	
		capt drop draw
		qui gen draw = uniform()
		summ weight if hispan == 1
		
		local blah = (1- ((2030 - min(`yy',2030))/(2030-2010)))*r(sum)
		
		gsort -hispan draw
		gen sumw = sum(weight)
		
		replace hispan = 0 if  sumw <= `blah'
		replace white = 1 if sumw <= `blah'
		drop sumw
		
	
		summ weight if black == 1
		local blah = (1- ((2030 - min(`yy',2030))/(2030-2010)))*r(sum)
		gsort -black draw
		gen sumw = sum(weight)
		
		replace black = 0 if  sumw <= `blah'
		replace white = 1 if sumw <= `blah'
		drop sumw
		capt drop draw

		if `yy'>=2030{
			replace hispan = 0
			replace black = 0
			replace white = 1
		}
	}

if "`scr'" == "hsless_removed" {
drop if hsless==1
}
if "`scr'" == "hsless_ged" {
replace hsless=0 if hsless==1
}


gen entry = `yy'
drop subgrp

compress
create_or_append `outfile'		

}

exit, STATA clear
