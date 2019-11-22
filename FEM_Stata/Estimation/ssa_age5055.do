/* 
This program will estimate a joint model for aime and quarters worked.  This will be used in new51simulate.

We will estimate the percentile, not the level.

*/

quietly include ../../fem_env.do

* Path to output
local restrictedvars $local_path/Estimates/restrictedvars

* use restricted data for 2004 50-55 cohort
use $dua_rand_hrs/age5055_hrs2004r.dta

replace fraime = 0 if fraime == 1
replace frq = 0 if frq == 1

* Make datasets describing the AIME and quarters worked distributions - do this by collapsing into 50 "equal"-sized groups (approx 32 per group, min 17)
preserve
egen aime_grp = cut(fraime), group(50)
collapse (mean) fraime [aw=weight], by(aime_grp)
rename fraime aime_dist
gen n = _n
tempfile aime
save `aime'

restore
preserve
egen q_grp = cut(frq), group(50)
collapse (mean) frq [aw=weight], by(q_grp)
rename frq q_dist

gen n = _n

* Output a file of the distributions
merge 1:1 n using `aime', nogen
drop n
save `restrictedvars'/ssa_dist.dta, replace
restore


* Percentile variables for the joint estimation
local cats = 40
local cuts = `cats' - 1

xtile aime_pct = fraime [aw=weight], n(`cats')
xtile q_pct = frq [aw=weight], n(`cats')



foreach var in black hispan hsless college cancre diabe hibpe hearte lunge stroke anyadl anyiadl work age logiearnx loghatotax {
	gen male_`var' = male*`var'
} 


* An ordered list of the models estimated - not used in the estimation, but used in the saving of the parameters
local models 		aime_pct 		q_pct
local dim : word count `models'

* Define the RHS variables

#d ;
local rhs male 
			black hispan
			hsless college
			cancre diabe hibpe hearte lunge stroke
			anyadl anyiadl
			work 
			logiearnx /* loghatotax */ 
			age
			male_black male_hispan
			male_hsless male_college
			male_cancre male_diabe male_hibpe male_hearte male_lunge male_stroke
			male_anyadl male_anyiadl
			male_work
			male_logiearnx /* male_loghatotax */ 
			male_age
;
#d cr

* local rhs male black hispan hsless college

local cov `rhs' _cons

* Estimate the joint model for AIME and quarters worked
cmp setup

#delimit ;

cmp 				(aime_pct = `rhs')	(q_pct = `rhs')

, indicators(
						$cmp_oprobit					$cmp_oprobit 							
)   
tech(dfp) 
nrtolerance(.01)
ghkdraws(10)
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
matsave ssa_vcmatrix, replace path("`restrictedvars'") saving


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
matsave ssa_means, replace path("`restrictedvars'") saving




* Make a matrix storing the cutpoints, shifting them so that the first cut point is 0

mat CP = J(`r_count',`cuts',.)

local a = 1
forvalues x = 1/`r_count' {
		forvalues y = 1/`cuts' {
			capture mat CP[`a',`y'] = _b[cut_`x'_`y':_cons] - _b[cut_`x'_1:_cons]
		}
		local a = `a' + 1
}


forvalues x = 1/`cuts' {
	local cutlist `cutlist' cut_`x'
}

mat colnames CP = `cutlist'
mat rownames CP = `models'

mat ssa_cut_points = CP
matsave ssa_cut_points, replace path("`restrictedvars'") saving



capture log close
