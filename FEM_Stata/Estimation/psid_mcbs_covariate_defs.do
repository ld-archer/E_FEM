// Define the covariates used in the cost models, which are the dependent variables and interaction terms
global cov_mcbs `agevars' male male_black male_hispan male_hsless black hispan hsless college widowed single cancre_nlcancre diabe_nldiabe hibpe_nlhibpe hearte_nlhearte lunge_nllunge stroke_nlstroke cancre_lcancre diabe_ldiabe hearte_lhearte hibpe_lhibpe lunge_llunge stroke_lstroke nhmliv adl3p diclaim died
* using ages 65-69 as reference in died interactions, too
global cov_interactions diabe_hearte diabe_hibpe hibpe_hearte hibpe_stroke diclaim_died diclaim_nhmliv died_nhmliv died_cancre died_diabe died_hibpe died_hearte died_lunge died_stroke died_age2534 died_age3544 died_age4554 died_age5564 died_age7074 died_age7579 died_age8084 died_age85 


// By default, the list of covariates for each cost measure is the same as the default
foreach v in totmd_mcbs mcare mcare_pta mcare_ptb caidmd_mcbs oopmd_mcbs {
	global cov_`v' $cov_mcbs
}

* replacing gross with logiearnx 
* Nope - removing logiearnx - the measure is too different from MCBS to HRS.  We need to either develop the Medicaid eligibility model in the HRS or develop hitot in the HRS, which is closer to gross.
global cov_medicaid_elig = "male black hispan hsless male_black male_hispan male_hsless college widowed single cancre nhmliv adl3p"

