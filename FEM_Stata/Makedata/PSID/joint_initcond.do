/* Current goal:
Simultaneously estimate initial condition models for new 25-26 year olds using 25-30 year olds from 2011.


Education: Four levels educlvl ordered (less than high school, high school/GED/some college/associates, college, grad school)
Marital status: mstat_new non-ordered (single, cohabitating, married)
Weight: wtstate ordered (noral/underwt, overweight, obese1, obese2, obese3)
Smoking: smkstat ordered (never smoked, ex-smoker, current smoker)
hypertension: hibpe binary
Work: work binary


Kids: not doing yet

*/

quietly include common.do
di "$outdata"


which cmp

* Use 2005-2009 PSID 25-26 year olds
* use $outdata/age2526_psid0509.dta

* Use 2005-2011 PSID 25-30 year olds
use $outdata/age2530_psid0515.dta


* Use 2009 25-26 year olds only
* use $outdata/psid_all2009_pop_adjusted_2526

* Set seed for repeatable results
 set seed 8675309

 tab mstat_new, m
 tab educlvl, m


* Clean up missing education - need to do this in SAS
replace educlvl = 2 if educlvl == .
forvalues x = 1/4 {
	cap drop educ`x'
	gen educ`x' = (educlvl == `x') if !missing(educlvl) 
}
* replace inlaborforce = 0 if missing(inlaborforce)

* replace laborforcestat = 3 if laborforcestat == .
* replace fullparttime = 1 if fullparttime == .

* Only model four weight categories: normal, overweight, obese1, and obese2.  This is because we will only assign those four in new25simulate.
* replace wtstate = 4 if wtstate == 5

* Generate dummy variables for exploring endogenous/recursive issues
gen mstat_1 = (mstat_new == 1)
gen mstat_2 = (mstat_new == 2)
gen mstat_3 = (mstat_new == 3)

* Dummy for being age 25 or 26
gen age2526 = (age >= 25 & age < 27)

* Recode number of kids (0, 1, 2, 3, 4+)
replace numbiokids = numbiokids + 1
replace numbiokids = 5 if inlist(numbiokids,6,7,8)


foreach var in partnered partnertype wtstate smkstat hibpe inlaborforce {
	tab `var' educlvl , col
}



 * An ordered list of the models estimated - not used in the estimation, but used in the saving of the parameters
#delimit ;
local models 	educlvl partnered partnertype wtstate smkstat hibpe inlaborforce numbiokids  	
;
#delimit cr
local dim : word count `models'
 
 
* Right-hand side variables for all models - excluding flunge fcancre fstroke for now (very rare
local educ_cov black hispan male mthreduc1 mthreduc3 mthreduc4 fthreduc1 fthreduc3 fthreduc4 fpoor frich poorchldhlth age2526
local rhs black hispan male educ1 educ3 educ4 mthreduc1 mthreduc3 mthreduc4 fthreduc1 fthreduc3 fthreduc4 fpoor frich poorchldhlth age2526

local rhs_lim black hispan male educ1 educ3 educ4 age2526

gen cens = (laborforcestat == 3)
 
 
* Summarize variables we will predict 
tab educlvl
tab partnered
tab partnertyp if partnered
tab wtstate
tab smkstat
tab hibpe
tab inlaborforce
 
 cmp setup
 
 * Constraints 
 * partnership masks cohab/married
	constraint 1 [atanhrho_23]_cons = 0
 #delimit ;

cmp 				 		(educlvl = `educ_cov')  	(partnered = `rhs') 	(partnertype = `rhs') 
								(wtstate = `rhs_lim') 		(smkstat = `rhs_lim') 		(hibpe = `rhs_lim') 
								(inlaborforce = `rhs')		 (numbiokids = `rhs')
					
, indicators(
								$cmp_oprobit  					$cmp_probit 							partnered*$cmp_probit
								$cmp_oprobit						$cmp_oprobit							$cmp_probit
								$cmp_probit							$cmp_oprobit
						)
	constraint(1)
	tech(dfp) 
 	nrtolerance(.01)
 	ghkdraws(20) 
;
 
#delimit cr



capture log close


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

matlist VC

* Save the VC matrix
mat psid_incoming_vcmatrix = VC
matsave psid_incoming_vcmatrix, replace path("$outdata") saving



* Store models
* Store the beta coefficients from the models (equivalent to old incoming_means.dta)

* Note: ordered probit models are estimated without a constant.  The cut points can be transformed by the 
* value of cut point 1 to be comparable to the model that included a constant.

local cov black hispan male educ1 educ3 educ4 mthreduc1 mthreduc3 mthreduc4 fthreduc1 fthreduc3 fthreduc4 fpoor frich poorchldhlth age2526 _cons

local r_count : word count `models'
local c_count : word count `cov'

mat IM = J(`r_count',`c_count',.)

local a = 1

foreach x in `models' {
	local b = 1
	foreach y in `cov' {
		capture:  mat IM[`a',`b'] = _b[`x':`y']
		* This is to deal with no constant in the ordered probit estimations (and possibly for other missing covariates, like educ_* in the education model)
		if _rc != 0 {
				mat IM[`a',`b'] = 0
			}
		local b = `b' + 1
		}
	local a = `a' + 1
}		

mat list IM


* Set the constant to the first cut point for the ordered probit models
foreach x in 1 4 5 8 {
	mat IM[`x',`c_count'] = -_b[cut_`x'_1:_cons]
}

mat rownames IM = `models' 
mat colnames IM = `rhs' constant

mat list IM

* Rename and save
mat psid_incoming_means = IM
matsave psid_incoming_means, replace path("$outdata") saving




* Store cutpoints
* Make a matrix storing the cutpoints, shifting them so that the first cut point is 0

mat CP = J(4,5,.)

local a = 1
foreach x in 1 4 5 8 {
		forvalues y = 1/5 {
			capture mat CP[`a',`y'] = _b[cut_`x'_`y':_cons] - _b[cut_`x'_1:_cons]
		}
		local a = `a' + 1
}


mat colnames CP = cut_1 cut_2 cut_3 cut_4 cut_5
mat rownames CP = educlvl wtstate smkstat numbiokids
                        
matlist CP
                        
mat psid_incoming_cut_points = CP
matsave psid_incoming_cut_points, replace path("$outdata") saving






capture log close
