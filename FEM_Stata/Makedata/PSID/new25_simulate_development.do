/* This file is for developing how new25 year olds are simulated.  
		Trying to impose trends on future cohorts.
		
		* BUG - need to make sure lage is correctly defined 

*/


quietly include common.do

local ster "$local_path/Estimates/incoming_separate_psid"

* Environmental variable for creating different scenarios (default, notrend, etc.)
local scr : env SCENARIO

local outfile $outdata/new25s_`scr'.dta

* Take the year as an argument
local fy : env FYEAR
local ly : env LYEAR


global indirect_adjust = 0

	* Try to trend smoking and weight
	global ordered1 educlvl
	global ordered2 wtstate smkstat numbiokids
	global ordered $ordered1 $ordered2
	
	* Removing work to try alternate specification
	global bin hibpe partnered partnertype inlaborforce

* For categorical outcomes 
	global educlvl_cat educ2 educ3 educ4  
	global wtstate_cat overwt obese_1 obese_2 obese_3
	global smkstat_cat smokev smoken 
	global numbiokids_cat numbiokids2 numbiokids3 numbiokids4 numbiokids5
*	global workstat_alt_cat workstat_alt2 workstat_alt3
*	global funcstat_cat iadl1 adl1p
*	global rdb_ea_c_cat rdb_ea_2 rdb_ea_3
*	global rdb_na_c_cat rdb_na_2 rdb_na_3 rdb_na_4
*	global baselist $bin $cont $wtstate_cat $smkstat_cat $funcstat_cat $rdb_ea_c_cat $rdb_na_c_cat

	global means09 hibpe $wtstate_cat $smkstat_cat $educlvl_cat partnered partnertype inlaborforce $numbiokids_cat

* Need to have mean values from original sample
use "$outdata/psid_all2009_pop_adjusted_2526", clear

* Move obese_3 to obese_2
* replace obese_2 = 1 if obese_3 == 1

* Generate summary variables for number of kids (variable numbering starts at 1).  Recode 5+ kids with to group with 4
gen numbiokids2 = (numbiokids == 1)
gen numbiokids3 = (numbiokids == 2)
gen numbiokids4 = (numbiokids == 3)
gen numbiokids5 = (numbiokids >= 4)

if "`scr'" == "hs_wtstate" {
	* This scenario will set the BMI distribution for everyone to be that of those who finished high school
	qui sum overwt if educlvl == 2 [aw=weight]
	local overwt_hs = r(mean)
	qui sum obese_1 if educlvl == 2 [aw=weight]
	local obese_1_hs = r(mean)
	qui sum obese_2 if educlvl == 2 [aw=weight]
	local obese_2_hs = r(mean)
	qui sum obese_3 if educlvl == 2 [aw=weight]
	local obese_3_hs = r(mean)
}


keep $means09 weight
collapse $means09 [aw = weight]
		
* For the incoming cohort simulation, we want proportion of EX SMOKERS, not EVER SMOKER
replace smokev = smokev - smoken

list educ2 educ3 educ4

if "`scr'" == "finish_hs" {
	replace educ2 = 1 - (educ3 + educ4)
	list educ2 educ3 educ4
}

gen educ1 = 1 - (educ2 + educ3 + educ4)
qui sum educ1
local hsless = r(mean)
drop educ1

if "`scr'" == "more_coll" {
	* Decrease high school by amount we will increase college -> amount is the same as the size of hsless population
	replace educ2 = educ2 - `hsless'
	replace educ3 = `hsless' + educ3
	list educ2 educ3 educ4

}

if "`scr'" == "no_obese" {
	* We will only have wtstate = 1 (normal) and 2 (overwt)
	* Scale up wtstates 1 and 2
	replace overwt = overwt/(1-obese_1-obese_2-obese_3)
	replace obese_1 = 0
	replace obese_2 = 0
	replace obese_3 = 0
}

if "`scr'" == "hs_wtstate" {
	* This scenario will set the BMI distribution for everyone to be that of those who finished high school
	replace overwt = `overwt_hs'
	replace obese_1 = `obese_1_hs'
	replace obese_2 = `obese_2_hs'
	replace obese_3 = `obese_3_hs'
}

* Just for testing
* replace numbiokids2 = .2
* replace numbiokids3 = .2
* replace numbiokids4 = .2
* replace numbiokids5 = .2
		
mkmat $means09, mat(means09)
matrix colnames means09 = phibpe pwtstate2 pwtstate3 pwtstate4 pwtstate5 psmkstat2 psmkstat3 peduclvl2 peduclvl3 peduclvl4 ppartnered ppartnertype pinlaborforce pnumbiokids2 pnumbiokids3 pnumbiokids4 pnumbiokids5
matrix rownames means09 = yr2009

matlist means09

save $outdata/psid_starting_means_`scr'.dta, replace



	**********************************************
	* Incoming cohort model predicts categorical BMI
	* Get centiles from 25-30 2009 data and use this to convert categorical to continous
	* Creates a dataset `bmi_centiles' in long format with the following variables:
	* 	centile - 0 to 100 indicating the centile
	*		wtstate - the weight category for the centile, 1 to 5
	* 	bmi			- the bmi for that centile and weight state category
	* The dataset is sorted by centile wtstate
	**********************************************
	
	use "$outdata/age2530_psid2009.dta", clear
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
	matlist bmi_centiles
	clear
	svmat bmi_centiles, names(col)
	reshape long bmi, i(centile) j(wtstate)
	
	* Make sure each bmi value is unique
	bys wtstate bmi (centile): gen counter = _n
	replace bmi = bmi + counter*.00001 if counter >1
	drop counter
	sort centile wtstate
	
	tempfile bmi_centiles
	save `bmi_centiles', replace
	* Just to see what we are doing
	save $outdata/bmi_centiles.dta, replace


* Import population trends, make a matrix
use $outdata/pop2526_projection_2081.dta, clear

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
matlist poptrend



* Bring in the health/demographic trends, make a matrix 
use $outdata/psid_trend_default.dta, replace
rename pworking pwork

* Place holder until we develop trends
gen pinlaborforce = 1
gen pworkstat_alt2 = 1
gen pworkstat_alt3 = 1

keep year pwtstate2 pwtstate3 pwtstate4 pwtstate5 psmkstat2 psmkstat3 peduc2 peduc3 peduc4 psingle pcohab pmarried phibpe ppartnered ppartnertype pinlaborforce pworkstat_alt2 pworkstat_alt3 pkids1 pkids2 pkids3 pkids4 pkids5

rename pkids1 pnumbiokids1
rename pkids2 pnumbiokids2
rename pkids3 pnumbiokids3
rename pkids4 pnumbiokids4
rename pkids5 pnumbiokids5


if "`scr'" == "notrend"{
	* Shut down the  trends in everything
	foreach x in pwtstate2 pwtstate3 pwtstate4 pwtstate5 psmkstat2 psmkstat3 peduc2 peduc3 peduc4 psingle pcohab pmarried phibpe ppartnered ppartnertype pinlaborforce pworkstat_alt2 pworkstat_alt3 pnumbiokids1 pnumbiokids2 pnumbiokids3 pnumbiokids4 pnumbiokids5 {
	replace `x' = 1
	}
}

if "`scr'" == "finish_hs"{
	* Shut down the  trends in education
	foreach x in peduc2 peduc3 peduc4 {
	replace `x' = 1
	}
}

if "`scr'" == "more_coll"{
	* Shut down the  trends in education
	foreach x in peduc2 peduc3 peduc4 {
	replace `x' = 1
	}
}

sum peduc2 peduc3 peduc4


forvalues i = 2/4 {
	rename peduc`i' peduclvl`i'
}

* Turn off education trends
/*
forvalues i = 2/4 {
	replace peduclvl`i' = 1
}
*/

qui sum year
local begyr = r(min)
local maxyr = r(max)

* keep odd years
keep if mod(year,2) > 0

mkmat * , mat(hlthtrend)
 
* Row names
global rowname ""
forvalues i = `begyr' (2) `maxyr'{
		global rowname $rowname yr`i'
} 

matrix rownames hlthtrend = $rowname
matlist hlthtrend	
save $outdata/hlthtrend.dta, replace



* Bring in the VC-matrix ("Omega")
drop _all
use "$outdata/psid_incoming_vcmatrix.dta"
drop _rowname

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

matlist omega
	
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


* Bring in the models ("mean estimation matrix")
drop _all
use "$outdata/psid_incoming_means.dta"
* gen order = _n
drop _rowname
	
mkmat *, mat(meanest)
matrix rownames meanest = `colname'
mat list meanest


* A list for random draws
global drawlist ""
foreach x in `colname' {
  global drawlist $drawlist d_`x'
}

* Bring in the cut points for ordered probit models
drop _all
 	
* Read in the file with the cut points for the ordered probit models, make a matrix for later use 
use "$outdata/psid_incoming_cut_points.dta"
mkmat cut_1 cut_2 cut_3 cut_4 cut_5, mat(cutpoints) rownames(_rowname)
matlist cutpoints 


* Bring in the parameters (theta, omega, ssr) for assigning earnings 
	drop _all	
 	use "$outdata/iearnx_TOS.dta"
 	
	drop _rowname
 	
 	mkmat *, mat(iearnx_params)
	matlist iearnx_params



* Use the reweighted 2009 data
use "$outdata/psid_all2009_pop_adjusted_2526", replace

* This deals with variables that are not yet cleaned or are missing in PSID
do kludge.do

forvalues x = 1/4 {
	replace educ`x' = 0 if missing(educ`x')
}

count



gen subgrp = 2^2 * male + 2^1 * hispan + black

* Simulate the new 25-26 year olds.

gen weight_psid_09 = weight

* Person ID
sort hhid hhidpn, stable
gen hhidpn_cnt = _n 

gen double hhid_hold = hhid
gen double hhidpn_hold = hhidpn

foreach v of varlist hhid_hold hhidpn_hold {
    qui sum `v'
    local max = r(max)
    local max = round(log10(`max')) + 2
    format %`max'.0g `v'
  }

* Actual respondent birth year
gen rbyr_actual = rbyr


* Set cutoffs for ordered outcomes
	scalar educlvl_cut1 =     cutpoints[rownumb(cutpoints,"educlvl"),colnumb(cutpoints,"cut_1")]	
	scalar educlvl_cut2 =     cutpoints[rownumb(cutpoints,"educlvl"),colnumb(cutpoints,"cut_2")]	
	scalar educlvl_cut3 =     cutpoints[rownumb(cutpoints,"educlvl"),colnumb(cutpoints,"cut_3")]	
*	scalar educlvl_cut4 =     cutpoints[rownumb(cutpoints,"educlvl"),colnumb(cutpoints,"cut_4")]	
*	scalar educlvl_cut5 =     cutpoints[rownumb(cutpoints,"educlvl"),colnumb(cutpoints,"cut_5")]

	scalar wtstate_cut1 =     cutpoints[rownumb(cutpoints,"wtstate"),colnumb(cutpoints,"cut_1")]	        
	scalar wtstate_cut2 =     cutpoints[rownumb(cutpoints,"wtstate"),colnumb(cutpoints,"cut_2")]		
	scalar wtstate_cut3 =     cutpoints[rownumb(cutpoints,"wtstate"),colnumb(cutpoints,"cut_3")]	        
	scalar wtstate_cut4 =     cutpoints[rownumb(cutpoints,"wtstate"),colnumb(cutpoints,"cut_4")]		

	scalar smkstat_cut1 =     cutpoints[rownumb(cutpoints,"smkstat"),colnumb(cutpoints,"cut_1")]	        
	scalar smkstat_cut2 =     cutpoints[rownumb(cutpoints,"smkstat"),colnumb(cutpoints,"cut_2")]
	
	scalar numbiokids_cut1 =     cutpoints[rownumb(cutpoints,"numbiokids"),colnumb(cutpoints,"cut_1")]	        
	scalar numbiokids_cut2 =     cutpoints[rownumb(cutpoints,"numbiokids"),colnumb(cutpoints,"cut_2")]		
	scalar numbiokids_cut3 =     cutpoints[rownumb(cutpoints,"numbiokids"),colnumb(cutpoints,"cut_3")]	        
	scalar numbiokids_cut4 =     cutpoints[rownumb(cutpoints,"numbiokids"),colnumb(cutpoints,"cut_4")]		
	
*	scalar workstat_alt_cut1 = cutpoints[rownumb(cutpoints,"workstat_alt"),colnumb(cutpoints,"cut_1")]	       
*	scalar workstat_alt_cut2 = cutpoints[rownumb(cutpoints,"workstat_alt"),colnumb(cutpoints,"cut_2")]	       
	
	gen constant = 1
	gen age2526 = 1
	gen male_black = male*black
	gen male_hispan = male*hispan
	
cap rm `outfile'	
	
preserve
forvalues yy = `fy'(2)`ly' {
	restore, preserve
	di "**** Projection year is `yy' ****"
	
/* Generate random draws */ 	
	 cap drop $drawlist
	 drawnorm $drawlist, cov(omega) seed(8675309)	
	 noisily sum d_*


	* Drop variables we will assign
	drop logbmi bmi hatotax iearnx 
	
	
	
	* Return weight to 2009 value since weighting is used in the cut point adjustment
	sum weight
	replace weight = weight_psid_09
	sum weight


	* Predicted prevalence
	local j = 1
	foreach x in `colname' {
		matrix betamat = meanest[`j',1...]
		cap drop `x'_xb
		
		matrix score `x'_xb = betamat
		local j = `j' + 1
		matrix mat_`x' = betamat
		di "Initial assignment - used in education in `yy'"
		mat list mat_`x'
		sum `x'_xb
	}

	 


	/* Determine the deviations */
	foreach x in $ordered1 $ordered2  {
			new_deviation, vname("`x'") vtype("o") cyr(`yy') data("psid")
			sum `x'_delta
	}
	foreach x in $bin {
			new_deviation, vname("`x'") vtype("b") cyr(`yy') data("psid")
	}
	foreach x in $cont $iht {
			new_deviation, vname("`x'") vtype("c") cyr(`yy') data("psid")			 		
	}
	
	
	/* Assign education first, as this is used in assigning other conditions */
		if $indirect_adjust == 0 { 					
		foreach x in $ordered1 {
			cap drop inc`x'
			qui gen inc`x' = 0
			foreach y in $bin $ordered {
					qui replace inc`x' = inc`x' + L_`y'[rownumb(L_`y',"`x'"), colnumb(L_`y', "`y'")] * `y'_delta
			}
			cap drop `x'_xb_new
			qui gen `x'_xb_new = `x'_xb + inc`x'
			sum inc`x'
			sum `x'_xb_new
		}
	}
	
	foreach v in educlvl {
		local ncuts = wordcount("$`v'_cat")
		local ncats = `ncuts'+1
		
		local p1 = 1
		forvalues probs = 2/`ncats' {
			local x   p`v'`probs'
			local p`probs' = hlthtrend[rownumb(hlthtrend,"yr`yy'"), colnumb(hlthtrend, "p`v'`probs'")]*means09[rownumb(means09, "yr2009"), colnumb(means09, "`x'")]
			local p1 = `p1' - `p`probs''
		}
		di "`v' in `yy'"
		di "p1 = `p1'"
		di "p2 = `p2'"
		di "p3 = `p3'"
		di "p4 = `p4'"
		
		if "`scr'" == "finish_hs" {
				local p1 = 0
		}			
		
		di "p1 = `p1'"
		di "p2 = `p2'"
		di "p3 = `p3'"
		di "p4 = `p4'"
						
		assert `p1' >= 0
		assert `p1' <= 1
		
		* Adjust the cuts
	 	forvalues c = 1/`ncuts' {
			local c_prev = `c' - 1
			if `c' == 1 {
		    calc_cut_point `v'_xb_new,  prob(`p1') prev_cut(-9999)
			}
			else {
			  local prev_cut = `v'_cut`c_prev'
			  calc_cut_point `v'_xb_new,  prob(`p`c'') prev_cut(`prev_cut')
			}
			matrix x = e(b)
			scalar `v'_cut`c' = x[1,1]
			
			noi di "Cut `v'_cut`c' = " `v'_cut`c'
		}
		forvalues c = 1/`ncats' {
			di "`v'_`c' = `p`c''"
		}
		sum `v'_xb_new
	}
	
	
	foreach x in $ordered1{
		if "`x'" == "rdb_na_c"{
			local numcut = 4
		}
		else if "`x'" == "educlvl" {
			local numcut = 4
		}
		else if "`x'" == "wtstate"{
			local numcut = 5
		}
		else if "`x'" == "numbiokids"{
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
		di "`x' `j' ="
		sum p`x'*
		}
	}	
	* Ordered outcomes
	foreach x in $ordered1 {
		cap drop `x'
		gen `x' = .
		if "`x'" == "rdb_na_c" {
			local num_cut = 4
			}
		else if "`x'" == "educlvl" {
			local num_cut = 4
		}
		else if "`x'" == "wtstate"{
			local num_cut = 5
		}
		else if "`x'" == "numbiokids"{
			local num_cut = 5
		}
		else{
			local num_cut = 3
			}
		forvalues i = `num_cut'(-1)1 {
			replace `x' = `i' if normal(d_`x') <= p`x'`i'
			drop p`x'`i'
			}
		di "assigning ordered based on draw"
		noi tab `x'
	}	
		/* Dummies for ordered outcomes */	
	foreach x in $ordered1 {
		if "`x'" == "rdb_na_c" {
			local num_cut = 4
		}
		else if "`x'" == "educlvl" {
			local num_cut = 4
		}
		else if "`x'" == "wtstate"{
			local num_cut = 5
		}
		else if "`x'" == "numbiokids"{
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
			noi sum `v'
		}
	}
	
	tab educlvl, m

	
	tab educlvl, m
	
	forvalues x = 1/4 {
		cap drop educ`x'
		gen educ`x' = (educlvl == `x')
	}
	sum educ1-educ4
	
	* Recalculate predicted prevalence with new education variables
	local j = 1
	foreach x in `colname' {
		matrix betamat = meanest[`j',1...]
		cap drop `x'_xb
		
		matrix score `x'_xb = betamat
		local j = `j' + 1
		matrix mat_`x' = betamat
		di "Second assignment - used for all other binary and ordered in `yy'"
		mat list mat_`x'
		sum `x'_xb
	}
	
	/*
	if "`scr'" == "hs_wtstate" {
		keep if educlvl == 1
	}
	*/
	
	if $indirect_adjust == 0 { 					
		foreach x in $bin $ordered2 {
			cap drop inc`x'
			qui gen inc`x' = 0
			foreach y in $bin $ordered {
					qui replace inc`x' = inc`x' + L_`y'[rownumb(L_`y',"`x'"), colnumb(L_`y', "`y'")] * `y'_delta
			}
			cap drop `x'_xb_new
			qui gen `x'_xb_new = `x'_xb + inc`x'
			sum inc`x'
			sum `x'_xb_new
		}
		foreach x in $cont $iht{
			cap drop inc`x'
			qui gen inc`x' = 0
			qui replace inc`x' = inc`x' + L_`x'[rownumb(L_`x',"`x'"), colnumb(L_`x', "`x'")] * `x'_delta
			cap drop `x'_xb_new
			qui gen `x'_xb_new = `x'_xb + inc`x'
		}							

	}
	
	/* Predicted probabilities */ 			

	* Determine the probabilities
	* Binary outcomes
	foreach x in $bin{
		cap drop p`x'
		gen p`x' = normal(-`x'_xb_new)
	}
	
		/* Determine the status */ 	 
	* Binary outcomes	
	foreach x in $bin {
		cap drop `x'
		gen `x' = normal(d_`x') >= p`x'
		drop p`x'
	}						

	**** For Weight and Smoking, we get new values by adjusting the cutoffs to match desired probabilities 

	foreach v in $ordered2 {
		
		if `v' == wtstate {
			local censor_var
		} 
		else if `v' == smkstat {
			local censor_var
		} 
		else if `v' == workstat_alt {
			local censor_var 
		}
		else if `v' == numbiokids {
			local censor_var
		}
		
		local ncuts = wordcount("$`v'_cat")
		local ncats = `ncuts'+1
		
		local p1 = 1
		forvalues probs = 2/`ncats' {
			local x   p`v'`probs'
			local p`probs' = hlthtrend[rownumb(hlthtrend,"yr`yy'"), colnumb(hlthtrend, "p`v'`probs'")]*means09[rownumb(means09, "yr2009"), colnumb(means09, "`x'")]
			local p1 = `p1' - `p`probs''
		}
		di "`v' in `yy'"
		di "p1 = `p1'"
		di "p2 = `p2'"
		assert `p1' >= 0
		assert `p1' <= 1
		
		* Adjust the cuts
		 forvalues c = 1/`ncuts' {
				local c_prev = `c' - 1
				if `c' == 1 {
			    calc_cut_point `v'_xb_new `censor_var',  prob(`p1') prev_cut(-9999)
				}
				else {
				  local prev_cut = `v'_cut`c_prev'
				  calc_cut_point `v'_xb_new `censor_var',  prob(`p`c'') prev_cut(`prev_cut')
				}
				matrix x = e(b)
				scalar `v'_cut`c' = x[1,1]
			
				noi di "Cut `v'_cut`c' = " `v'_cut`c'
			}
		forvalues c = 1/`ncats' {
			di "`v'_`c' = `p`c''"
		}
	}
	
	* Ordered outcomes
	foreach x in $ordered2{
		if "`x'" == "rdb_na_c"{
			local numcut = 4
		}
		else if "`x'" == "educlvl" {
			local numcut = 4
		}
		else if "`x'" == "wtstate"{
			local numcut = 5
		}
		else if "`x'" == "numbiokids"{
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
		di "`x' `j' ="
		sum p`x'*
		}
	}	


	/* Determine the status */ 	
	* Ordered outcomes
	foreach x in $ordered2 {
		cap drop `x'
		gen `x' = .
		if "`x'" == "rdb_na_c" {
			local num_cut = 4
			}
		else if "`x'" == "educlvl" {
			local num_cut = 4
		}
		else if "`x'" == "wtstate"{
			local num_cut = 5
		}
		else if "`x'" == "numbiokids"{
			local num_cut = 5
		}
		else{
			local num_cut = 3
			}
		forvalues i = `num_cut'(-1)1 {
			replace `x' = `i' if normal(d_`x') <= p`x'`i'
			* for testing purposes
			* gen p`x'`i'test = p`x'`i'
			drop p`x'`i'
			}
		di "assigning ordered based on draw"
		noi tab `x'
	}	

	* Continuous
	foreach x in $cont {
		cap drop `x'
		* Removing draw term for the $cont variables:   
		gen `x' = `x'_xb_new + d_`x'
	}

	
	/* Dummies for ordered outcomes */	
	foreach x in $ordered2 {
		if "`x'" == "rdb_na_c" {
			local num_cut = 4
		}
		else if "`x'" == "educlvl" {
			local num_cut = 4
		}
		else if "`x'" == "wtstate"{
			local num_cut = 5
		}
		else if "`x'" == "numbiokids"{
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
			noi sum `v'
		}
	}
	
	tab wtstate, m
	tab educlvl, m
	tab smkstat, m
	tab numbiokids, m
*	tab workstat_alt, m
	
	tab inlaborforce, m
	
	cap drop hsless
	cap drop college
	gen hsless = (educlvl == 1)
	gen college = (educlvl >= 3)
	
	forvalues x = 1/4 {
		gen male_educ`x' = male*educ`x'
	}
	
	 /* Make sure single/cohab/married is logical */
	 replace mstat_new = 1 if (partnered == 0)
	 replace mstat_new = 2 if (partnertype == 0 & partnered == 1)
	 replace mstat_new = 3 if (partnertype == 1 & partnered == 1)
	 
	 cap drop single
	 cap drop cohab
	 cap drop married
	 gen single = mstat_new == 1
	 gen cohab = mstat_new == 2
	 gen married = mstat_new == 3
	 
	 cap drop male_single
	 cap drop male_cohab
	 cap drop male_married
	 gen male_single = male*single
	 gen male_cohab = male*cohab
	 gen male_married = male*married
	 
	 /* Current smokers are ever smokers */
	 replace smokev = 1 if smoken == 1
	 
	 /* Clean up numbiokids - assigned at n+1 levels */
	 replace numbiokids = numbiokids - 1
	 * Set lag to current
	 replace l2numbiokids = numbiokids
	 
	 
	 /* Make sure workstat_alt is consistent with censoring variable*/
*	 replace workstat_alt = 0 if inlaborforce == 0
*	 replace workstat_alt1 = (workstat_alt == 1)
*	 replace workstat_alt2 = (workstat_alt == 2)
*	 replace workstat_alt3 = (workstat_alt == 3)
*	 label define workstat_alt 0 "out of labor force" 1 "unemployed" 2 "part-time" 3 "full-time"
*	 label values workstat_alt workstat_alt 
	
	* BMI variables used in wealth and earnings assignment
	cap drop overwt 
	cap drop obese1 
	cap drop obese2p
	gen overwt = (wtstate == 2)
	gen obese1 = (wtstate == 3)
	gen obese2p = (wtstate == 4 | wtstate == 5)
	
	***** Populate earnings and wealth using models from incoming_separate_estimation.do  *****
	
	* need some additional draws - uncorrelated for now
	set seed 90210
	local drawlist2 d_hatota_cat d_iearn_cat d_labor_cat d_inscat
	foreach var of local drawlist2 {
		gen `var' = runiform()
	}
	
	local drawlist3 d_hatota_neg d_hatota_pos d_iearn_pos
	foreach var of local drawlist3 {
		drawnorm `var' 
	}
		
	*** Wealth ***
	* Predict category (negative wealth, zero wealth, positive wealth)
	est use "`ster'/hatota_cat.ster"
	predict p_hatota_cat1 p_hatota_cat2 p_hatota_cat3
	
	* Assign the category based on a random draw
	gen hatota_cat = .
	replace hatota_cat = 1 if d_hatota_cat < p_hatota_cat1  
	replace hatota_cat = 2 if d_hatota_cat >= p_hatota_cat1 & d_hatota_cat < p_hatota_cat1 + p_hatota_cat2 
	replace hatota_cat = 3 if d_hatota_cat >= p_hatota_cat1 + p_hatota_cat2
	
	tab hatota_cat
	
	* Predict negative wealth for indivduals in that category 
	est use "`ster'/lnhatotax_neg.ster"
	predict lnhatota_neg if hatota_cat == 1
	replace lnhatota_neg = lnhatota_neg + d_hatota_neg*e(rmse)

	* Predict positive wealth for individuals in that category 		
	est use "`ster'/lnhatotax_pos.ster"
	predict lnhatota_pos if hatota_cat == 3
	replace lnhatota_pos = lnhatota_pos + d_hatota_pos*e(rmse)
	
	* Populate the variable
	gen hatotax = .
	replace hatotax = -exp(-lnhatota_neg) if hatota_cat == 1
	replace hatotax = 0 if hatota_cat == 2
	replace hatotax = exp(lnhatota_pos) if hatota_cat == 3
	* Cap hatotax at $2M
	replace hatotax = min(2000,hatotax) if !missing(hatotax)
	
	replace hatota = hatotax
	
	*** Earnings ***
	est use "`ster'/iearn_cat.ster"
	predict p_iearn_cat 
	sum p_iearn_cat

	* Asssign the category based on a random draw
	gen iearn_cat = .
	replace iearn_cat = 1 if d_iearn_cat > p_iearn_cat 
	replace iearn_cat = 2 if d_iearn_cat <= p_iearn_cat   
	
	tab iearn_cat
	
	* IHT
	
	**Instead of taking logs, take log(y+sqrt(y^2+1)) - gh(y,1,0)
	cap drop iearnx_xb_new
	est use "`ster'/iearnx.ster"
	predict iearnx_xb_new
	
	* Draw term scaled by sqrt(ssr) of ghreg estimation) 
	cap drop _ahg_temp
	gen _ahg_temp = iearnx_xb_new + d_iearn_pos*sqrt(iearnx_params[1,colnumb(iearnx_params, "ssr")])
		
	cap drop iearnx_ihs
	local th = iearnx_params[1,colnumb(iearnx_params, "theta")]
	local om = iearnx_params[1,colnumb(iearnx_params, "omega")]
	egen _iearnx = invgh(_ahg_temp), theta(`th') omega(`om')
	replace _iearnx = 0 if _iearnx < 0 | _iearnx == .
	replace _iearnx = 0 if iearn_cat == 1
		
	replace _iearnx = min(_iearnx,200) if !missing(_iearnx)
	rename _iearnx iearnx
	replace iearn = iearnx
	

	
	* Unemployed, working part-time, working full-time if inlaborforce == 1
	est use "`ster'/laborcat.ster"
	predict p_labor_cat1 p_labor_cat2 p_labor_cat3
	* Assign the category based on a random draw
	gen labor_cat = .
	replace labor_cat = 1 if d_labor_cat < p_labor_cat1  
	replace labor_cat = 2 if d_labor_cat >= p_labor_cat1 & d_labor_cat < p_labor_cat1 + p_labor_cat2 
	replace labor_cat = 3 if d_labor_cat >= p_labor_cat1 + p_labor_cat2
	
	drop workcat
	gen workcat = .
	replace workcat = 1 if !(inlaborforce)
	replace workcat = 2 if inlaborforce & labor_cat == 1
	replace workcat = 3 if inlaborforce & labor_cat == 2
	replace workcat = 4 if inlaborforce & labor_cat == 3
		
		
	* Health insurance categorical variable (none, public only, any private)
	est use "`ster'/inscat.ster"
	predict p_inscat1 p_inscat2 p_inscat3
	* Assign the category based on the random draw	
	drop inscat
	gen inscat = .
	replace inscat = 1 if d_inscat < p_inscat1  
	replace inscat = 2 if d_inscat >= p_inscat1 & d_inscat < p_inscat1 + p_inscat2 
	replace inscat = 3 if d_inscat >= p_inscat1 + p_inscat2
		
	drop hatota_cat lnhatota_neg lnhatota_pos
	drop iearn_cat 
	drop `drawlist2' `drawlist3'
	drop p_hatota_cat1 p_hatota_cat2 p_hatota_cat3
	drop p_iearn_cat 	
	drop p_inscat1 p_inscat2 p_inscat3
		
		
	* Need to reweight individuals
	
	/* Adjust the population weight to reflect population size and structual change */
	levelsof subgrp, local(subgrplv)
	
	di "`subgrplv'"
	
	dis "********** current year is: `yy' *************"
	gen weight`yy' = .
	foreach l of local subgrplv {
	  local popratio = poptrend[rownumb(poptrend, "yr`yy'"), colnumb(poptrend,"pop`l'")]/poptrend[rownumb(poptrend, "yr2009"), colnumb(poptrend,"pop`l'")]
		replace weight`yy' = weight_psid_09 * `popratio' if subgrp == `l'
		di "`popratio'"
	}
	 
	* gen weight_`yy'_09 = weight	 
	tabstat weight, stat(sum)
	drop weight
	ren weight`yy' weight
	
	di "`yy'"
	tabstat weight, stat(sum)
	
	
	replace year = `yy'
	
	replace rbyr = rbyr_actual + `yy' - 2009
	
	codebook hhid_hold
	
  tostring hhidpn_hold, gen(hhidpnstr) usedisplayformat
  drop hhid hhidpn
  gen str hhidpn = "-`yy'" + hhidpnstr
  destring hhidpn, replace
	drop hhidpnstr 
	* Set hhid to be hhidpn
	gen double hhid = hhidpn
	
	* Assign hhidpn of head as hhid to both head and wife/"wife"
*	bys year hhid (relhd): gen long hhid_new = hhidpn[1]
*	drop hhid
*	rename hhid_new hhid
	
	
	* Drop iteration-specific variables
	*	drop d_* *_xb*  *_delta inc* constant
	drop  *_xb*  *_delta inc* 
	
	#d ;	
	*** POPULATE INITIAL VALUES AND LAGS WITH CURRENT VALUES ***
	* REMOVING: dcwlthx rdb_ea_c rdb_na_c rssclyr era nra
	* Initial condition only; 
	global zlist2 single shlt smokev anydb rdb_na_2 
		rdb_na_3 rdb_na_4 rdb_ea_2 rdb_ea_3 anydc db_tenure logdcwlthx ;	
	
	* Time-varying covariants and outcomes; 
	* REMOVING: iwstat memrye funcstat age_yrs age_1231 volhours gkcarehrs helphoursyr helphoursyr_sp helphoursyr_nonsp parhelphours ;
	global plist widowed married hearte stroke cancre hibpe diabe lunge anyhi diclaim ssiclaim oasiclaim dbclaim 
	nhmliv wlth_nonzero overwt obese_1 obese_2 obese_3 smoken iadlstat adlstat work retired 
	loghatotax logiearnx hatota hatotax iearnx smkstat wtstate iearnuc 
	age 
	inlaborforce 
	workcat
	educlvl
	mstat_new
	;

	#d cr		
		
	di "What the heck is going on here???"		
	di "plist is $plist"
		
		
	* 	global flist $plist; 


	foreach v of global plist {
		*	di "`v'"
		cap drop l2`v' f`v'
		gen l2`v' = `v'
		gen f`v' = `v'
		local vlb: var label `v'
		label var l2`v' "Lag of `vlb'"
		label var f`v' "Init. of `vlb'"
	}
	
	foreach v of global zlist2 {
		*	di "`v'"
		cap drop f`v'
		gen f`v' = `v'
		local vlb: var label `v'
		label var f`v' "Init.of `vlb'"
	}
	
	
	
	
	
	* Turn the categorical BMI into logbmi using centiles from 2009 data
	* These centiles were created earlier and are stored in the temp dataset `bmi_centiles'
	
	* Do a random draw from 0 - 100 for each person
	gen centile = round(uniform()*100)
	sum centile

	sort centile wtstate
	
	* Merge with the centile dataset for the new BMI values
	merge centile wtstate using `bmi_centiles', _merge(bmi_merge)

	* Resort everything by HHIDPN.
	sort hhidpn
	
	keep if bmi_merge == 3
	
	drop centile bmi_merge
	
	* Generate logbmi
	gen logbmi = log(bmi)
	sum logbmi
	
	di "Year is `yy'"
	tab wtstate
	
	*	desc
	
	gen scr = "`scr'"
	
	gen entry = `yy'
	
	/* Script to get rid of variables that are "present in data, but not in simulation"*/
	quietly include drop_vars.do
	
	* Save new25 files.
	compress
	create_or_append `outfile'  
	* save "$outdata/new25_`yy'_`scr'.dta", replace

}	

	


capture log close