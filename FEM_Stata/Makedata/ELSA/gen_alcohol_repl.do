* gen_alcohol_repl.do

* This script just generates the replenishing population to be used in the init minimum unit price of alcohol intervention

** ALCOHOL INTERVENTION **
replace alcbase = alcbase * 0.985 if moderate == 1 & !missing(alcbase) & !missing(moderate)
replace alcbase = alcbase * 0.961 if increasingRisk == 1 & !missing(alcbase) & !missing(increasingRisk)
replace alcbase = alcbase * 0.944 if highRisk == 1 & !missing(alcbase) & !missing(highRisk)

* Now do accounting
* Moderate drinker
replace alcstat = 1 if drink == 1 & alcbase >= 0 & alcbase <= 14 & male == 0 & !missing(alcbase) & !missing(drink)
replace alcstat = 1 if drink == 1 & alcbase >= 0 & alcbase <= 21 & male == 1 & !missing(alcbase) & !missing(drink)
* Increasing-risk
replace alcstat = 2 if drink == 1 & alcbase >= 15 & alcbase <= 35 & male == 0 & !missing(alcbase) & !missing(drink)
replace alcstat = 2 if drink == 1 & alcbase >= 22 & alcbase <= 50 & male == 1 & !missing(alcbase) & !missing(drink)
* High-risk
replace alcstat = 3 if drink == 1 & alcbase > 35 & male == 0 & !missing(alcbase) & !missing(drink)
replace alcstat = 3 if drink == 1 & alcbase > 50 & male == 1 & !missing(alcbase) & !missing(drink)
* alcstat4 accounting
replace alcstat4 = 2 if alcstat == 1 & !missing(alcstat)
replace alcstat4 = 3 if alcstat == 2 & !missing(alcstat)
replace alcstat4 = 4 if alcstat == 3 & !missing(alcstat)
* Dummys
replace moderate = 0 if alcstat4 != 2 & !missing(alcstat4)
replace increasingRisk = 0 if alcstat4 != 3 & !missing(alcstat4)
replace highRisk = 0 if alcstat4 != 4 & !missing(alcstat4)

saveold $outdata/ELSA_repl_alcohol.dta, replace v(12)

