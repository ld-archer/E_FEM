/*

For any models not assigned in the joint estimation (currently only educlvl, partnered, partnertype, wtstate, smkstat, hibpe, and work)
you can estimate additional models that can then be assigned in new25_simulate_development.do after the joint models are assigned.

At present, we'll add iearn and hatota

*/

quietly include common.do
local ster "$local_path/Estimates/incoming_separate_psid"
cap ssc install matsave

* Use 2009 PSID 25-30 year olds
use $outdata/age2530_psid2009.dta


* We only assign 4 levels of wtstate (normal, overweight, obese1, obese2) - so collapse the highest category into the second highest
cap drop overwt
gen overwt = (wtstate == 2)
gen obese1 = (wtstate == 3)
gen obese2p = (wtstate == 4 | wtstate == 5)
gen age2526 = (age >= 25 & age < 27)
gen male_black = male*black
gen male_hispan = male*hispan
forvalues x = 1/4 {
	gen male_educ`x' = male*educ`x'
}
cap drop single
cap drop cohab
gen single = mstat_new == 1
gen cohab = mstat_new == 2

gen male_single = male*single
gen male_cohab = male*cohab

* Core predictors for models - fixed demographic variables 
local rhs1 black hispan male mthreduc1 mthreduc3 mthreduc4 fthreduc1 fthreduc3 fthreduc4 fpoor frich age2526
* Removing parent's education
local rhs1 black hispan male fpoor frich poorchldhlth age2526

* Additional predictors - things we will have already assigned in new25_simulate_development.do --- need to add married/cohab variables
local rhs2 educ1 educ3 educ4 overwt obese1 obese2p hibpe inlaborforce single cohab
local rhs2_alt overwt obese1 obese2p hibpe single cohab
* educ1 educ2 educ3 educ4 educ6 
* Interactions
local rhs3 male_black male_hispan male_educ1 male_educ3 male_educ4 male_single male_cohab

*** Wealth ***
gen hatota_cat = .
replace hatota_cat = 1 if hatota < 0
replace hatota_cat = 2 if hatota == 0
replace hatota_cat = 3 if hatota > 0 & hatota < .

* Predict if wealth is negative, zero, or positive
oprobit hatota_cat `rhs1' `rhs2' `rhs3'
est save "`ster'/hatota_cat.ster", replace

* Work on log(hatotax), not hatota
gen lnhatota = ln(hatotax) if hatota > 0 & hatota < .
gen neglnhatota = -ln(-hatotax) if hatota < 0

* Estimate negative wealth value
reg neglnhatota `rhs1' `rhs2' `rhs3' if hatota < 0
est save "`ster'/lnhatotax_neg.ster", replace

* Estimate positive wealth value
reg lnhatota `rhs1' `rhs2' `rhs3' if hatota > 0 & hatota < .
est save "`ster'/lnhatotax_pos.ster", replace



*** Earnings ***
gen iearn_cat = (iearn > 0 & iearn < .)

* Work on log of earnings, not earnings
gen lniearn = ln(iearnx) if iearn > 0 & iearn < .

* Predict if earnings are positive
probit iearn_cat `rhs1' `rhs2' `rhs3'
est save "`ster'/iearn_cat.ster", replace

* IHS for positive values

foreach n in iearnx {
  
  ghreg `n' `rhs1' `rhs2' `rhs3' if `n' > 0

  gen e_`n' = e(sample)
  summ `n' if e_`n' == 1
  global max = r(max)
  global theta = e(theta)
  global omega = e(omega)
  global ssr = e(ssr)
  disp "theta omega ssr max"
  disp $theta " " $omega " " $ssr " " $max
  
  mat `n'_TOS = [e(theta),e(omega),e(ssr)]
  mat colnames `n'_TOS = theta omega ssr
  mat rowname `n'_TOS = iearnx
  matsave `n'_TOS, replace path("$outdata") saving
  
  estimates store i_`n'
  predict simu_`n', simu
 * keep simu_`n' `n' wave e_`n' work
  save "$outdata/`n'_simulated.dta", replace	
  
  est save "`ster'/`n'.ster", replace
  
}


* Labor force status of those not unemployed
gen laborcat = .
replace laborcat = 1 if workcat == 2
replace laborcat = 2 if workcat == 3
replace laborcat = 3 if workcat == 4

* Unemployed, part-time, or full-time if in labor force
foreach n in laborcat {
	mprobit `n' male black hispan male_black male_hispan poorchldhlth if inlaborforce
	est save "`ster'/`n'.ster", replace
}

* Health insurance categorical variable (none, public only, any private)
foreach n in inscat {
	mprobit `n' male black hispan male_black male_hispan poorchldhlth
	est save "`ster'/`n'.ster", replace
}



save $outdata/age2530_explore.dta, replace


capture log close
