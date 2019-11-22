/* 
This program will estimate a joint model for aime and quarters worked.  This will be used in save_simul2010_faked.do
We will estimate the percentile, not the level.
We will do the estimation for those already receiving SS benefits (using the benefit amount as a predictor) and a those not in two separate estimations


*/

quietly include ../../fem_env.do
cmp setup

* Path to output
local restrictedvars $local_path/Estimates/restrictedvars

* use restricted data for 2004 population
use $dua_rand_hrs/all2004r.dta

replace fraime = 0 if fraime == 1
replace frq = 0 if frq == 1

keep if year == 2004

* Create any needed variables
gen anyadl = (adlstat > 1) if !missing(adlstat)
gen anyiadl = (iadlstat > 1) if !missing(iadlstat)

gen anyrq = (frq > 0) if !missing(frq)

egen agecat = cut(age), at(0,50,55,60,65,70,75,80,85,200)
drop if age < 50
forvalues age = 50 (5) 85 {
	gen age`age' = (agecat == `age')
}

gen isretx = isret/1000

* Make datasets describing the AIME and quarters worked distributions - do this by collapsing into 50 "equal"-sized groups 
preserve
egen aime_grp = cut(fraime), group(51)
collapse (mean) fraime [aw=weight], by(aime_grp)
rename fraime aime_dist
gen n = _n
tempfile aime
save `aime'

restore
preserve
* Need to have 50 groups and rq doesn't behave well ...
egen q_grp = cut(frq), group(51)
collapse (mean) frq [aw=weight], by(q_grp)
rename frq q_dist

gen n = _n

* Output a file of the distributions
merge 1:1 n using `aime', nogen
drop n
save `restrictedvars'/ssa_dist_50p.dta, replace
restore


* Percentile variables for the joint estimation
local cats = 40
local cuts = `cats' - 1

xtile aime_pct = fraime [aw=weight], n(`cats')
xtile q_pct = frq [aw=weight], n(`cats')

#d ;
local ints black hispan hsless college cancre diabe hibpe hearte lunge stroke anyadl anyiadl work age logiearnx loghatotax
	age50 age55 age60 age65 age70 age75 age80 age85	
	fcanc50 fdiabe50 fheart50 fhibp50 flung50 fstrok50
	jyears isretx
	;
#d cr

foreach var of local ints {	
	gen male_`var' = male*`var'
} 

* An ordered list of the models estimated - not used in the estimation, but used in the saving of the parameters
local models 		aime_pct 	q_pct
local dim : word count `models'

foreach cat in ret notret {

	if "`cat'" == "ret" {
		* Define the RHS variables
		#d ;
		local rhs male 
			black hispan
			hsless college
			cancre diabe hibpe hearte lunge stroke
			age55 age60 age65 age70 age75 age80 age85
			fcanc50 fdiabe50 fheart50 fhibp50 flung50 fstrok50
			jyears isretx
			male_black male_hispan
			male_hsless male_college
			;
		#d cr

		local cov `rhs' _cons
		local select "isret > 0 & anyrq == 1"
	} /* End "ret" loop */
		
	if "`cat'" == "notret" {
		* Define the RHS variables
		#d ;
		local rhs male 
			black hispan
			hsless college
			cancre diabe hibpe hearte lunge stroke
			work 
			age55 age60 age65 age70 age75 age80 age85
			fcanc50 fdiabe50 fheart50 fhibp50 flung50 fstrok50
			jyears iearnx
			male_black male_hispan
			male_hsless male_college
			male_work
			;
		#d cr

		local cov `rhs' _cons
		local select "isret == 0 & anyrq == 1"
	} /* End "notret" loop */
	
	
	/* Estimate a probit for anyrq, which will also limit the joint estimation */
	probit anyrq male black hispan hsless college jyears male_black male_hispan male_hsless male_college age55 age60 age65 age70 age75 age80 age85
	est save "`restrictedvars'/`cat'/anyrq.ster", replace
	
	
	
	* Estimate the joint model for AIME and quarters worked for those with positive retirement benefits
	

	#delimit ;

	cmp 				(aime_pct = `rhs')	(q_pct = `rhs')
	if `select'
	, indicators(
							$cmp_oprobit				$cmp_oprobit 							
	)   
	tech(dfp) 
	nrtolerance(.01)
	ghkdraws(100)
	;
 
	#delimit cr


	**************************************************************************************************** 
	* Format and save the output
	*******************************************************************************************************

	* Build the Variance-Covariance matrix
	mat VC = J(`dim',`dim',.)
	* label the rows and colums
	mat rownames VC = `models'
	mat colnames VC = `models'

	* Populate the variance terms - All are 1 except for continuous models.
	forvalues x = 1/`dim' {
		capture: mat VC[`x',`x'] = (exp(_b[lnsig_`x':_cons]))^2
		if _rc > 0 { 
			mat VC[`x',`x'] = 1
		}
	}

	* Populate the covariance terms
	local oneless = `dim' - 1
	forvalues x = 1/`oneless' {
			local a = `x' + 1
			forvalues y = `a'/`dim' {
				mat VC[`y',`x'] = tanh(_b[atanhrho_`x'`y':_cons])*sqrt(VC[`x',`x']*VC[`y',`y']) 
		}
	}

	mat list VC

	* Save the VC matrix
	mat ssa_vcmatrix = VC
	matsave ssa_vcmatrix, replace path("`restrictedvars'/`cat'") saving


	* Store the beta coefficients from the models 

	local r_count : word count `models'
	local c_count : word count `cov'

	di "`r_count'"
	di "`c_count'"

	mat IM = J(`r_count',`c_count',.)

	local a = 1

	foreach x in `models' {
		local b = 1
		foreach y in `cov' {
			capture:  mat IM[`a',`b'] = _b[`x':`y']
			* This is to deal with no constant in the ordered probit estimations
			if _rc != 0 {
					mat IM[`a',`b'] = 0
				}
			local b = `b' + 1
			}
		local a = `a' + 1
	}		


	* Set the constant to the first cut point for the ordered probit models
	forvalues x = 1/`r_count' {
		mat IM[`x',`c_count'] = -_b[cut_`x'_1:_cons]
	}

	mat rownames IM = `models' 
	mat colnames IM = `cov'

	mat list IM

	mat ssa_means = IM
	matsave ssa_means, replace path("`restrictedvars'/`cat'") saving

	* Make a matrix storing the cutpoints, shifting them so that the first cut point is 0

	mat CP = J(`r_count',`cuts',.)

	local a = 1
	forvalues x = 1/`r_count' {
			forvalues y = 1/`cuts' {
				capture mat CP[`a',`y'] = _b[cut_`x'_`y':_cons] - _b[cut_`x'_1:_cons]
			}
			local a = `a' + 1
	}
	
	* Need to initialize this ...
	local cutlist 

	forvalues x = 1/`cuts' {
		local cutlist `cutlist' cut_`x'
	}

	mat colnames CP = `cutlist'
	mat rownames CP = `models'

	mat ssa_cut_points = CP
	matsave ssa_cut_points, replace path("`restrictedvars'/`cat'") saving

}


capture log close
