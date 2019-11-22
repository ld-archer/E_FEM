clear all
set more off

include "../../fem_env.do"
global ster "$local_path/Estimates/PSID"

adopath ++ "$local_path/Estimation"
adopath ++ "$local_path/hyp_mata"
adopath ++ "$local_path/utilities"
adopath ++ "$local_path/Makedata/HRS"

use "$outdata/psid_transition.dta", clear

cmp setup

*** set up binned variables ***

*** "25 35 45 55 65 75 85" ***
global agecuts = "25 35 45 55" 
gen agebin = 0
foreach cut in $agecuts {
	replace agebin = agebin + 1 if age >= `cut' & !missing(age)
}
gen age25l = age
replace age25l = 1 if age < 25  & !missing(age)
replace age25l = 0 if age >= 25  & !missing(age)

gen age2535 = age
replace age2535 = 0 if (age < 25 | age >= 35) & !missing(age)
replace age2535 = 1 if (age >= 25 & age < 35) & !missing(age)

gen age3545 = age
replace age3545 = 0 if (age < 35 | age >= 45) & !missing(age)
replace age3545 = 1 if (age >= 35 & age < 45) & !missing(age)

gen age4555 = age
replace age4555 = 0 if (age < 45 | age >= 55) & !missing(age)
replace age4555 = 1 if (age >= 45 & age < 55) & !missing(age)

gen age55p = age
replace age55p = 0 if age < 55 & !missing(age)
replace age55p = 1 if age >= 55 & !missing(age)

gen age5565 = age
replace age5565 = 0 if (age < 55 | age >= 65) & !missing(age)
replace age5565 = 1 if (age >= 55 & age < 65) & !missing(age)

gen age6575 = age
replace age6575 = 0 if (age < 65 | age >= 75) & !missing(age)
replace age6575 = 1 if (age >= 65 & age < 75) & !missing(age)

gen age7585 = age
replace age7585 = 0 if (age < 75 | age >= 85) & !missing(age)
replace age7585 = 1 if (age >= 75 & age < 85) & !missing(age)

gen age85p = age
replace age85p = 0 if age < 85 & !missing(age)
replace age85p = 1 if age >= 85 & !missing(age)

*li age age25l age2535 age3545 age4555 age5565 age6575 age7585 age85p


gen educbin = educlvl
replace educbin = 2 if educlvl > 1 & !missing(educlvl)
gen lths = educlvl
replace lths = 1 if educlvl < 1 & !missing(educlvl)
replace lths = 0 if educlvl >= 1 & !missing(educlvl)

gen hs = educlvl
replace hs = 1 if educlvl == 1 & !missing(educlvl)
replace hs = 0 if (educlvl < 1 | educlvl > 1) & !missing(educlvl)

gen gths = educlvl
replace gths = 1 if educlvl > 1 & !missing(educlvl)
replace gths = 0 if educlvl < 1 & !missing(educlvl)

global clist = "mstat_new lmstat_new agebin age25l age2535 age3545 age4555 age5565 age55p age6575 age7585 age85p educbin lths hs gths white"

keep hhid year male $clist

*** only keep households with two people ***
sort hhid year
by hhid year: gen hhsize = _N
keep if hhsize == 2
tempfile temp_all
save temp_all, replace

**************************** MARRIAGE *******************************

drop if mstat_new != 3

tempfile temp_spouses
save temp_spouses, replace

drop if male == 1
drop male

foreach v in $clist {
	rename `v' wif_`v'
}

sort hhid year
tempfile temp_wife
save temp_wife, replace

use temp_spouses

drop if male == 0
drop male

foreach v in $clist {
	rename `v' hus_`v'
}

sort hhid year
merge hhid year using temp_wife
tab _merge, miss

* drop if neither husband nor wife are newly wed
drop if hus_lmstat_new == 3 & wif_lmstat_new == 3


* estimate for husbands
* equations: 
* wif_white = hus_white + hus_agebin + hus_educbin
* wif_agebin = hus_white + hus_agebin + hus_educbin
* wif_educbin = hus_white + hus_agebin + hus_educbin
global hus_rhs = "hus_white hus_age25l hus_age3545 hus_age4555 hus_age55p hus_lths hus_hs"
*#delimit ;
cmp (wif_white = $hus_rhs) (wif_agebin = $hus_rhs) (wif_educbin = $hus_rhs)  , indicators( $cmp_probit $cmp_oprobit $cmp_oprobit )  tech(dfp)   nrtolerance(.0001)  ghkdraws(90)      
*cmp (wif_white = hus_white) (wif_agebin = hus_agebin) (wif_educbin = hus_educbin)  , indicators( $cmp_probit $cmp_oprobit $cmp_oprobit )  tech(dfp)   nrtolerance(.0001)  ghkdraws(90)      
*;
*#delimit cr


* An ordered list of the models estimated - not used in the estimation, but used in the saving of the parameters
#delimit ;
local models wif_white wif_agebin wif_educbin
;
#delimit cr
local dim : word count `models'

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
mat psid_wife_selection_vcmatrix = VC
matsave psid_wife_selection_vcmatrix, replace path("$outdata") saving

* Store models
* Store the beta coefficients from the models

* Note: ordered probit models are estimated without a constant.  The cut points can be transformed by the 
* value of cut point 1 to be comparable to the model that included a constant.

local cov $hus_rhs _cons

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
foreach x in 2 3 {
	mat IM[`x',`c_count'] = -_b[cut_`x'_1:_cons]
}

mat rownames IM = `models' 
mat colnames IM = $hus_rhs constant

mat list IM

* Rename and save
mat psid_wife_selection_means = IM
matsave psid_wife_selection_means, replace path("$outdata") saving


* Store cutpoints
* Make a matrix storing the cutpoints, shifting them so that the first cut point is 0

mat CP = J(2,4,.)

local a = 1
foreach x in 2 3 {
		forvalues y = 1/4 {
			capture mat CP[`a',`y'] = _b[cut_`x'_`y':_cons] - _b[cut_`x'_1:_cons]
		}
		local a = `a' + 1
}


mat colnames CP = cut_1 cut_2 cut_3 cut_4
mat rownames CP = wif_agebin wif_educbin 
                        
matlist CP
                        
mat psid_wife_selection_cutpts = CP
matsave psid_wife_selection_cutpts, replace path("$outdata") saving


* estimate for wives
* equations: 
* hus_white = wif_white + wif_agebin + wif_educbin
* hus_agebin = wif_white + wif_agebin + wif_educbin
* hus_educbin = wif_white + wif_agebin+ wif_educbin
global wif_rhs = "wif_white wif_age25l wif_age3545 wif_age4555 wif_age55p wif_lths wif_hs"
cmp (hus_white = $wif_rhs) (hus_agebin = $wif_rhs) (hus_educbin = $wif_rhs), indicators( $cmp_probit $cmp_oprobit $cmp_oprobit )  tech(dfp)   nrtolerance(.0001)  ghkdraws(90)  
*cmp (hus_white = wif_white) (hus_agebin = wif_agebin) (hus_educbin = wif_educbin), indicators( $cmp_probit $cmp_oprobit $cmp_oprobit )  tech(dfp)   nrtolerance(.0001)  ghkdraws(90)  

* ouput model probabilities as tables

* An ordered list of the models estimated - not used in the estimation, but used in the saving of the parameters
#delimit ;
local models hus_white hus_agebin hus_educbin
;
#delimit cr
local dim : word count `models'

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
mat psid_husband_selection_vcmatrix = VC
matsave psid_husband_selection_vcmatrix, replace path("$outdata") saving

* Store models
* Store the beta coefficients from the models

* Note: ordered probit models are estimated without a constant.  The cut points can be transformed by the 
* value of cut point 1 to be comparable to the model that included a constant.

local cov $wif_rhs _cons

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
foreach x in 2 3 {
	mat IM[`x',`c_count'] = -_b[cut_`x'_1:_cons]
}

mat rownames IM = `models' 
mat colnames IM = $wif_rhs constant

mat list IM

* Rename and save
mat psid_husband_selection_means = IM
matsave psid_husband_selection_means, replace path("$outdata") saving


* Store cutpoints
* Make a matrix storing the cutpoints, shifting them so that the first cut point is 0

mat CP = J(2,4,.)

local a = 1
foreach x in 2 3 {
		forvalues y = 1/4 {
			capture mat CP[`a',`y'] = _b[cut_`x'_`y':_cons] - _b[cut_`x'_1:_cons]
		}
		local a = `a' + 1
}


mat colnames CP = cut_1 cut_2 cut_3 cut_4
mat rownames CP = hus_agebin hus_educbin 
                        
matlist CP
                        
mat psid_husband_selection_cutpts = CP
matsave psid_husband_selection_cutpts, replace path("$outdata") saving




************************** COHABITATION *****************************

use temp_all, clear

drop if mstat_new != 2

tempfile temp_cohabs
save temp_cohabs, replace

drop if male == 1
drop male

foreach v in $clist {
	rename `v' fem_`v'
}

sort hhid year
tempfile temp_female
save temp_female, replace

use temp_cohabs

drop if male == 0
drop male

foreach v in $clist {
	rename `v' male_`v'
}

sort hhid year
merge hhid year using temp_female
tab _merge, miss

* drop if neither partner is newly cohabitating
drop if male_lmstat_new == 2 & fem_lmstat_new == 2

* estimate for males
* equations: 
* fem_white = male_white + male_agebin + male_educbin
* fem_agebin = male_white + male_agebin + male_educbin
* fem_educbin = male_white + male_agebin + male_educbin
global male_rhs = "male_white male_age25l male_age3545 male_age4555 male_age55p male_lths male_hs"
*#delimit ;
cmp (fem_white = $male_rhs) (fem_agebin = $male_rhs) (fem_educbin = $male_rhs)  , indicators( $cmp_probit $cmp_oprobit $cmp_oprobit )  tech(dfp)   nrtolerance(.0001)  ghkdraws(90)      
*;
*#delimit cr

* An ordered list of the models estimated - not used in the estimation, but used in the saving of the parameters
#delimit ;
local models fem_white fem_agebin fem_educbin
;
#delimit cr
local dim : word count `models'

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
mat psid_cohabfem_selection_vcmatrix = VC
matsave psid_cohabfem_selection_vcmatrix, replace path("$outdata") saving

* Store models
* Store the beta coefficients from the models

* Note: ordered probit models are estimated without a constant.  The cut points can be transformed by the 
* value of cut point 1 to be comparable to the model that included a constant.

local cov $male_rhs _cons

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
foreach x in 2 3 {
	mat IM[`x',`c_count'] = -_b[cut_`x'_1:_cons]
}

mat rownames IM = `models' 
mat colnames IM = $male_rhs constant

mat list IM

* Rename and save
mat psid_cohabfem_selection_means = IM
matsave psid_cohabfem_selection_means, replace path("$outdata") saving


* Store cutpoints
* Make a matrix storing the cutpoints, shifting them so that the first cut point is 0

mat CP = J(2,4,.)

local a = 1
foreach x in 2 3 {
		forvalues y = 1/4 {
			capture mat CP[`a',`y'] = _b[cut_`x'_`y':_cons] - _b[cut_`x'_1:_cons]
		}
		local a = `a' + 1
}


mat colnames CP = cut_1 cut_2 cut_3 cut_4
mat rownames CP = fem_agebin fem_educbin 
                        
matlist CP
                        
mat psid_cohabfem_selection_cutpts = CP
matsave psid_cohabfem_selection_cutpts, replace path("$outdata") saving


* estimate for females
* equations: 
* male_white = fem_white + fem_agebin + fem_educbin
* male_agebin = fem_white + fem_agebin + fem_educbin
* male_educbin = fem_white + fem_agebin+ fem_educbin
global fem_rhs = "fem_white fem_age25l fem_age3545 fem_age4555 fem_age55p fem_lths fem_hs"
cmp (male_white = $fem_rhs) (male_agebin = $fem_rhs) (male_educbin = $fem_rhs), indicators( $cmp_probit $cmp_oprobit $cmp_oprobit )  tech(dfp)   nrtolerance(.0001)  ghkdraws(90)  


* An ordered list of the models estimated - not used in the estimation, but used in the saving of the parameters
#delimit ;
local models male_white male_agebin male_educbin
;
#delimit cr
local dim : word count `models'

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
mat psid_cohabmal_selection_vcmatrix = VC
matsave psid_cohabmal_selection_vcmatrix, replace path("$outdata") saving

* Store models
* Store the beta coefficients from the models

* Note: ordered probit models are estimated without a constant.  The cut points can be transformed by the 
* value of cut point 1 to be comparable to the model that included a constant.

local cov $fem_rhs _cons

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
foreach x in 2 3 {
	mat IM[`x',`c_count'] = -_b[cut_`x'_1:_cons]
}

mat rownames IM = `models' 
mat colnames IM = $fem_rhs constant

mat list IM

* Rename and save
mat psid_cohabmal_selection_means = IM
matsave psid_cohabmal_selection_means, replace path("$outdata") saving


* Store cutpoints
* Make a matrix storing the cutpoints, shifting them so that the first cut point is 0

mat CP = J(2,4,.)

local a = 1
foreach x in 2 3 {
		forvalues y = 1/4 {
			capture mat CP[`a',`y'] = _b[cut_`x'_`y':_cons] - _b[cut_`x'_1:_cons]
		}
		local a = `a' + 1
}


mat colnames CP = cut_1 cut_2 cut_3 cut_4
mat rownames CP = male_agebin male_educbin 
                        
matlist CP
                        
mat psid_cohabmal_selection_cutpts = CP
matsave psid_cohabmal_selection_cutpts, replace path("$outdata") saving