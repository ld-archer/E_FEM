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

replace drinkwn4 = . if missing(drinkwn4)
replace drinkwn5 = . if missing(drinkwn5)
replace drinkwn6 = . if missing(drinkwn6)
replace drinkwn7 = . if missing(drinkwn7)
replace drinkwn8 = . if missing(drinkwn8)

* Generate a few flags for imputed variables
forvalues wv = 2 (2) 8 {
	generate bmi_imputed`wv' = 1 if missing(bmi`wv')
}
forvalues wv = 1/8 {
	gen drink_imputed`wv' = 1 if missing(drink`wv')
}
forvalues wv = 2/8 {
	gen drinkd_imputed`wv' = 1 if missing(drinkd`wv')
}
forvalues wv = 4/8 {
	gen drinkwn_imputed`wv' = 1 if missing(drinkwn`wv')
}

* Check if all missing values replaced
codebook 	raeducl ///
			bmi2 bmi4 bmi6 bmi8 ///
			drink1 drink2 drink3 drink4 drink5 drink6 drink7 drink8 ///
			drinkd2 drinkd3 drinkd4 drinkd5 drinkd6 drinkd7 drinkd8 ///
			drinkwn4 drinkwn5 drinkwn6 drinkwn7 drinkwn8
			

local right_hand_vars 	i.ragender rabyear ///
						i.work1 i.work2 i.work3 i.work4 i.work5 i.work6 i.work7 i.work8 ///
						itearn1 itearn2 itearn3 itearn4 itearn5 itearn6 itearn7 itearn8 ///
						i.retemp1 i.retemp2 i.retemp3 i.retemp4 i.retemp5 i.retemp6 i.retemp7 i.retemp8 ///
						retage1 retage2 retage3 retage4 retage5 retage6 retage7 retage8 ///
						ipubpen1 ipubpen2 ipubpen3 ipubpen4 ipubpen5 ipubpen6 ipubpen7 ipubpen8 ///
						atotf1 atotf2 atotf3 atotf4 atotf5 atotf6 atotf7 atotf8 ///
						i.vgactx_e1 i.vgactx_e2 i.vgactx_e3 i.vgactx_e4 i.vgactx_e5 i.vgactx_e6 i.vgactx_e7 i.vgactx_e8 ///
						i.mdactx_e1 i.mdactx_e2 i.mdactx_e3 i.mdactx_e4 i.mdactx_e5 i.mdactx_e6 i.mdactx_e7 i.mdactx_e8 ///
						i.ltactx_e1 i.ltactx_e2 i.ltactx_e3 i.ltactx_e4 i.ltactx_e5 i.ltactx_e6 i.ltactx_e7 i.ltactx_e8

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
					(logit) drink1 drink2 drink3 drink4 drink5 drink6 drink7 drink8 ///
					= `right_hand_vars' ///
					, add(`num_imputations') chaindots rseed(`seed') force

/*
					(logit) drink2 ///
					(logit) drink3 ///
					(logit) drink4 ///
					(logit) drink5 ///
					(logit) drink6 ///
					(logit) drink7 ///
					(logit) drink8 ///
*/
					
mi extract `num_imputations', clear

* Have to impute drinkd separately to drink as drinkd is perfect predictor of drink
* Stata's augment option is not good enough to handle this problem

mi set wide

local imputees2 drinkd2 drinkd3 drinkd4 drinkd5 drinkd6 drinkd7 drinkd8

mi register imputed `imputees2'

mi impute chained 	(ologit) drinkd2 drinkd3 drinkd4 drinkd5 drinkd6 drinkd7 drinkd8 ///
					= bmi2 bmi4 bmi6 bmi8 i.raeducl `right_hand_vars' ///
					, add(`num_imputations') chaindots rseed(`seed') force
					
/*
					(ologit) drinkd3 ///
					(ologit) drinkd4 ///
					(ologit) drinkd5 ///
					(ologit) drinkd6 ///
					(ologit) drinkd7 ///
					(ologit) drinkd8 ///
*/

* Extract final imputation
mi extract `num_imputations', clear

* Now impute drinkwn separately again

mi set wide

local imputees3 drinkwn4 drinkwn5 drinkwn6 drinkwn7 drinkwn8

mi register imputed `imputees3'

mi impute chained	(pmm, knn(`num_knn')) `imputees3' ///
					= i.raeducl bmi2 bmi4 bmi6 bmi8 `right_hand_vars' `imputees2' ///
					, add(`num_imputations') chaindots rseed(`seed') force

* Extract final imputation
mi extract `num_imputations', clear

save ../../../input_data/ELSA_post_impute_`num_imputations'.dta, replace
