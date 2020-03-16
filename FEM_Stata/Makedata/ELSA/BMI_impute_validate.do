* This script will validate the Multiple Imputation of BMI (and drink and drinkd if necessary?)


* Script needs to:
*	Read in dataset BEFORE imputation
* 	Remove 10% (arbitrary) of KNOWN BMI values
*	Run through MI exactly how we do in mi_attempt6.do
*	Compare imputed values against known - calculate an error metric?
*		Sum of squared error?

quietly include ../../../fem_env.do

log using BMI_impute_validate.log, replace

* Set imputation parameters
local seed 5000
set seed `seed'
local num_imputations 10
local num_knn 5

* Read in pre-imputed data
*use ../../../input_data/H_ELSA_pre_impute.dta, clear
use $outdata/H_ELSA_pre_impute.dta, clear

* Have to replace hard missing values with soft (.) missing
replace bmi2 = . if missing(bmi2)
replace bmi4 = . if missing(bmi4)
replace bmi6 = . if missing(bmi6)
replace bmi8 = . if missing(bmi8)

replace raeducl = . if missing(raeducl)

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
			
* Remove impossible BMI value (BMI == 2.91, weight == 1 kg)
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


*** Now run through MI exactly as we do in MI_attempt6.do ***

* Set format as wide
mi set wide

* Variable to be imputed
local imputees	raeducl /// 
				bmi2 bmi4 bmi6 bmi8 /// 
				drink1 drink2 drink3 drink4 drink5 drink6 drink7 drink8
				

* Register the variables to be imputed and listed regulars
mi register imputed `imputees'

* Check some summary statistics of imputees and pattern of missing data
misstable summ `imputees'
*misstable pattern `imputees'

* Describe mi data
mi describe

local predictors 	i.hlthlm2 i.hlthlm3 i.hlthlm4 i.hlthlm5 i.hlthlm6 i.hlthlm7 i.hlthlm8 ///
					i.walkra1 i.walkra2 i.walkra3 i.walkra4 i.walkra5 i.walkra6 i.walkra7 i.walkra8 ///
					i.dressa1 i.dressa2 i.dressa3 i.dressa4 i.dressa5 i.dressa6 i.dressa7 i.dressa8 ///
					i.batha1 i.batha2 i.batha3 i.batha4 i.batha5 i.batha6 i.batha7 i.batha8 ///
					i.mdactx_e1 i.mdactx_e2 i.mdactx_e3 i.mdactx_e4 i.mdactx_e5 i.mdactx_e6 i.mdactx_e7 i.mdactx_e8 ///
					i.vgactx_e1 i.vgactx_e2 i.vgactx_e3 i.vgactx_e4 i.vgactx_e5 i.vgactx_e6 i.vgactx_e7 i.vgactx_e8 ///
					i.ltactx_e1 i.ltactx_e2 i.ltactx_e3 i.ltactx_e4 i.ltactx_e5 i.ltactx_e6 i.ltactx_e7 i.ltactx_e8 ///
					i.cancre1 i.cancre2 i.cancre3 i.cancre4 i.cancre5 i.cancre6 i.cancre7 i.cancre8 ///
					i.diabe1 i.diabe2 i.diabe3 i.diabe4 i.diabe5 i.diabe6 i.diabe7 i.diabe8 ///
					i.hibpe1 i.hibpe2 i.hibpe3 i.hibpe4 i.hibpe5 i.hibpe6 i.hibpe7 i.hibpe8 ///
					i.lunge1 i.lunge2 i.lunge3 i.lunge4 i.lunge5 i.lunge6 i.lunge7 i.lunge8 ///
					i.stroke1 i.stroke2 i.stroke3 i.stroke4 i.stroke5 i.stroke6 i.stroke7 i.stroke8 ///
					i.smoken1 i.smoken2 i.smoken3 i.smoken4 i.smoken5 i.smoken6 i.smoken7 i.smoken8 ///
					i.psyche1 i.psyche2 i.psyche3 i.psyche4 i.psyche5 i.psyche6 i.psyche7 i.psyche8 ///
					i.arthre1 i.arthre2 i.arthre3 i.arthre4 i.arthre5 i.arthre6 i.arthre7 i.arthre8 
					/*i.work1 i.work2 i.work3 i.work4 i.work5 i.work6 i.work7 i.work8 ///
					itearn1 itearn2 itearn3 itearn4 itearn5 itearn6 itearn7 itearn8 ///
					i.retemp1 i.retemp2 i.retemp3 i.retemp4 i.retemp5 i.retemp6 i.retemp7 i.retemp8 ///
					drinkwn4 drinkwn5 drinkwn6 drinkwn7 drinkwn8*/
					
global allvars_logbmi male hsless college l2age65l l2age6574 l2age75p l2logbmi l2cancre l2diabe l2hearte l2hibpe l2lunge l2stroke l2adl1 l2adl2 l2adl3p l2iadl1 l2iadl2p l2smoken l2psyche l2arthre l2asthmae l2parkine l2drink l2drinkd1 l2drinkd2 l2drinkd3 l2drinkd4

* Have a go!
mi impute chained 	(ologit) raeducl ///
					(pmm, knn(`num_knn')) bmi2 bmi4 bmi6 bmi8 ///
					(logit) drink1 ///
					(logit) drink2 /// 
					(logit) drink3 ///
					(logit) drink4 ///
					(logit) drink5 ///
					(logit) drink6 ///
					(logit) drink7 ///
					(logit) drink8 ///
					= i.ragender rabyear `predictors' ///
					, add(`num_imputations') chaindots rseed(`seed') force

* Save full dataset 
save ../../../input_data/validate/ELSA_half_imp_validate_`num_imputations'.dta, replace

mi extract `num_imputations'

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
					= bmi2 bmi4 bmi6 bmi8 i.raeducl i.ragender rabyear `predictors' ///
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
save $outdata/validate/imputed_with_errors_`num_imputations'.dta, replace

capture log close
