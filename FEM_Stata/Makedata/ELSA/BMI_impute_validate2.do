quietly include ../../../fem_env.do

log using BMI_impute_validate2.log, replace

* Set imputation parameters
local seed 5000
set seed `seed'
local num_imputations 5
local num_knn 5

* Read in pre-imputed data
*use ../../../input_data/H_ELSA_pre_impute.dta, clear
use $outdata/H_ELSA_pre_impute.dta, clear

* Have to replace hard missing values with soft (.) missing
replace raeducl = . if missing(raeducl)

replace bmi2 = . if missing(bmi2)
replace bmi4 = . if missing(bmi4)
replace bmi6 = . if missing(bmi6)
replace bmi8 = . if missing(bmi8)

replace drink1 = . if missing(drink1)
replace drink2 = . if missing(drink2)
replace drink3 = . if missing(drink3)
replace drink4 = . if missing(drink4)
replace drink5 = . if missing(drink5)
replace drink6 = . if missing(drink6)
replace drink7 = . if missing(drink7)
replace drink8 = . if missing(drink8)

replace drinkd2 = . if missing(drinkd2)
replace drinkd3 = . if missing(drinkd3)
replace drinkd4 = . if missing(drinkd4)
replace drinkd5 = . if missing(drinkd5)
replace drinkd6 = . if missing(drinkd6)
replace drinkd7 = . if missing(drinkd7)
replace drinkd8 = . if missing(drinkd8)

* Check if all missing values replaced
codebook bmi2 bmi4 bmi6 bmi8 raeducl drink1 drink2 drink3 drink4 drink5 drink6 drink7 drink8 ///
			drinkd2 drinkd3 drinkd4 drinkd5 drinkd6 drinkd7 drinkd8
			
* Remove impossible BMI values (anything below 10)
drop if bmi8 < 10
			
* Copy BMI to new var, remove 10% of known values
generate bmi2_known = bmi2
generate bmi4_known = bmi4
generate bmi6_known = bmi6 
generate bmi8_known = bmi8

* Generate a random number if record has full BMI information (all 4 waves)
gen rand_bmi = runiform()

* Remove 10% of full records and generate a 'removed' tag
gen bmi_removed = 1 if rand_bmi < 0.1
replace bmi_removed = 0 if missing(bmi_removed)
replace bmi2 = . if bmi_removed==1
replace bmi4 = . if bmi_removed==1
replace bmi6 = . if bmi_removed==1
replace bmi8 = . if bmi_removed==1

* Check
codebook bmi_removed bmi2 bmi2_k bmi4 bmi4_k bmi6 bmi6_k bmi8 bmi8_k


* For loop to collect all the predictors for each wave in 1 go
forvalues x = 1/8 {
	local wave`x'predictors i.walkra`x' i dress`x' i.batha`x' i.mdactx_e`x' i.vgactx_e`x' i.ltactx_e`x' i.work`x' i.cancre`x' i.diabe`x' i.hearte`x' i.hibpe`x' i.stroke`x'
}


************* RUN THE IMPUTATION *************

* Set format as wide
mi set wide

* Register the education variable to be imputed first
mi register imputed raeducl

* Describe mi data
mi describe
					
mi impute ologit raeducl = i.ragender rabyear `wave1pred' `wave2pred' ///
								`wave3pred' `wave4pred' `wave5pred' ///
								`wave6pred' `wave7pred' `wave8pred' ///
								, add(`num_imputations') chaindots rseed(`seed') force

mi extract `num_imputations', clear

*** NOW WAVE 1 PREDICTIONS ***
mi set wide

local imputees_wave1 drink1 

mi register imputed `imputees_wave1'

mi impute logit drink1 = i.ragender rabyear raeducl `wave1pred' ///
								, add(`num_imputations') chaindots rseed(`seed') force
									
mi extract `num_imputations', clear

*** WAVE 2 PREDICTIONS ***

mi set wide

local imputees_wave2 drink2 bmi2 

mi register imputed `imputees_wave2'

mi impute chained 	(pmm, knn(`num_knn')) bmi2 ///
					(logit) drink2 ///
								= i.ragender rabyear raeducl `wave2pred' i.hlthlm2 ///
								, add(`num_imputations') chaindots rseed(`seed') force
									
mi extract `num_imputations', clear

*** WAVE 3 PREDICTIONS ***

mi set wide

local imputees_wave3 drink3 

mi register imputed `imputees_wave3'

mi impute logit drink3 = i.ragender rabyear raeducl `wave3pred' i.hlthlm3 ///
								, add(`num_imputations') chaindots rseed(`seed') force
									
mi extract `num_imputations', clear

*** WAVE 4 PREDICTIONS ***

mi set wide

local imputees_wave4 drink4 bmi4 

mi register imputed `imputees_wave4'

mi impute chained 	(pmm, knn(`num_knn')) bmi4 ///
					(logit) drink4 ///
								= i.ragender rabyear raeducl `wave4pred' i.hlthlm4 ///
								, add(`num_imputations') chaindots rseed(`seed') force
									
mi extract `num_imputations', clear

*** WAVE 5 PREDICTIONS ***

mi set wide

local imputees_wave5 drink5 

mi register imputed `imputees_wave5'

mi impute logit drink5 = i.ragender rabyear raeducl `wave5pred' i.hlthlm5 ///
								, add(`num_imputations') chaindots rseed(`seed') force
									
mi extract `num_imputations', clear

*** WAVE 6 PREDICTIONS ***

mi set wide

local imputees_wave6 drink6 bmi6 

mi register imputed `imputees_wave6'

mi impute chained 	(pmm, knn(`num_knn')) bmi6 ///
					(logit) drink6 ///
								= i.ragender rabyear raeducl `wave6pred' i.hlthlm6 ///
								, add(`num_imputations') chaindots rseed(`seed') force
									
mi extract `num_imputations', clear

*** WAVE 7 PREDICTIONS ***

mi set wide

local imputees_wave7 drink7 

mi register imputed `imputees_wave7'

mi impute logit drink7 = i.ragender rabyear raeducl `wave7pred' i.hlthlm7 ///
								, add(`num_imputations') chaindots rseed(`seed') force
									
mi extract `num_imputations', clear

*** WAVE 8 PREDICTIONS ***

mi set wide

local imputees_wave8 drink8 bmi8 

mi register imputed `imputees_wave8'

mi impute chained 	(pmm, knn(`num_knn')) bmi8 ///
					(logit) drink8 ///
								= i.ragender rabyear raeducl `wave8pred' i.hlthlm8 ///
								, add(`num_imputations') chaindots rseed(`seed') force

mi extract `num_imputations', clear

* Save full dataset 
save ../../../input_data/validate/educ_drink_bmi_`num_imputations'.dta, replace

* Have to impute drinkd separately to drink as drinkd is perfect predictor of drink
* Stata's augment option is not good enough to handle this problem

mi set wide

local imputees2 drinkd2 drinkd3 drinkd4 drinkd5 drinkd6 drinkd7 drinkd8

mi register imputed `imputees2'

mi impute chained 	(ologit) drinkd2 ///
					(ologit) drinkd3 ///
					(ologit) drinkd4 ///
					(ologit) drinkd5 ///
					(ologit) drinkd6 ///
					(ologit) drinkd7 ///
					(ologit) drinkd8 ///
					= bmi2 bmi4 bmi6 bmi8 i.raeducl i.ragender rabyear ///
					`wave1pred' `wave2pred' `wave3pred' `wave4pred' ///
					`wave5pred' `wave6pred' `wave7pred' `wave8pred' ///
					if drink2 | drinkd3 | drink4 | drink5 | drink6 | drink7 | drink8 ///
					, add(`num_imputations') chaindots rseed(`seed') force

* Save again
save ../../../input_data/validate/ELSA_full_imp_validate_`num_imputations'.dta, replace					

* Extract final imputation		
mi extract `num_imputations'

*** FINISHED IMPUTATION ***

** Now compare imputed values in bmi* column to known in bmi*_k
* Calculate absolute error
gen bmi2_e = abs(bmi2 - bmi2_known)
gen bmi4_e = abs(bmi4 - bmi4_known)
gen bmi6_e = abs(bmi6 - bmi6_known)
gen bmi8_e = abs(bmi8 - bmi8_known)

* Generate squared error
gen bmi2_e2 = bmi2_e^2
gen bmi4_e2 = bmi4_e^2
gen bmi6_e2 = bmi6_e^2
gen bmi8_e2 = bmi8_e^2

* Summarize known, imputed and errors
summ bmi2_known bmi4_known bmi6_known bmi8_known
summ bmi2 bmi4 bmi6 bmi8
summ bmi2_e bmi4_e bmi6_e bmi8_e
summ bmi2_e2 bmi4_e2 bmi6_e2 bmi8_e2

order idauniq bmi2_known bmi2 bmi2_e bmi4_known bmi4 bmi4_e bmi6_known bmi6 bmi6_e bmi8_known bmi8 bmi8_e

* Save dataset for playing around with later
*save ../../../input_data/validate/imputed_with_errors_`num_imputations'.dta, replace
save $outdata/validate/imputed_with_errors_attempt2_`num_imputations'.dta, replace

capture log close
