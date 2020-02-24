*local seed 5000
*local num_imputations 10

args seed num_imputations num_knn

save $outdata/H_ELSA_pre_impute.dta, replace

***** Before reshaping, impute data (supposedly better to impute in wide format)
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
					= i.ragender rabyear ///
					, add(`num_imputations') chaindots rseed(`seed') force

* Save full dataset 
save ../../../input_data/ELSA_half_imputed.dta, replace

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
					= bmi2 bmi4 bmi6 bmi8 i.raeducl i.ragender rabyear ///
					, add(`num_imputations') chaindots rseed(`seed') force

* Save again
save ../../../input_data/ELSA_post_impute_full.dta, replace					

* Extract final imputation		
mi extract `num_imputations'

save ../../../input_data/ELSA_post_impute_`num_imputations'.dta, replace
