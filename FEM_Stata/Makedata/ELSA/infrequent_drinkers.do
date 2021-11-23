/*
infrequent drinkers

This script will try to impute information on the level of alcohol consumption for infrequent drinkers (and frequent ones that are missing data)

*/

*** Start with the wv_specific harmonised ELSA file (should already be using)
*use $outdata/H_ELSA_g2_wv_specific.dta, replace
use input_data/H_ELSA_g2_wv_specific.dta, replace

* Calculate annual and monthly consumption alongside weekly
*gen alcbase_annual = alcbase * 52
*gen alcbase_monthly = alcbase * 4

local firstwave 1
local lastwave 9

*gen r4alcbase_annual = r4alcbase * 52

preserve
drop if inlist(r4scako, 1, 2, 3, 4, 5, 6, 7)
tempfile scako_missing
save `scako_missing'
restore

keep if inlist(r4scako, 1, 2, 3, 4, 5, 6, 7)

/*forvalues wv = 4/`lastwave' {
    * Generate annual and monthly consumption
    gen r`wv'alcbase_annual = r`wv'alcbase * 52
    gen r`wv'alcbase_monthly = r`wv'alcbase * 4

    * Make a dummy var so we can check between the new and original
    gen r`wv'newAlcbase_a = r`wv'alcbase_annual

    * Drop all 0 values to be imputed
    replace r`wv'newAlcbase_a = . if r`wv'newAlcbase_a == 0
    * hotdeck within scako groups (done with the by(scako) command) then load that data in 
    hotdeck r`wv'newAlcbase_a using hotdeck_data/r`wv'newAlcbase_a_imp, by(r`wv'scako) store seed(`seed') keep(_all) impute(1)
    use hotdeck_data/r`wv'newAlcbase_a_imp.dta, replace

    * Finally calculate the new weekly consumption 
    gen r`wv'newAlcbase = r`wv'newAlcbase_a / 52
}*/

* Generate annual and monthly consumption
gen r4alcbase_annual = r4alcbase * 52
gen r4alcbase_monthly = r4alcbase * 4

* Make a dummy var so we can check between the new and original
gen r4newAlcbase_a = r4alcbase_annual

* Drop all 0 values to be imputed
replace r4newAlcbase_a = . if r4newAlcbase_a == 0
bys scako: summ r4newAlcbase_a

* hotdeck within scako groups (done with the by(scako) command) then load that data in 
hotdeck r4newAlcbase_a using hotdeck_data/r4newAlcbase_a_imp, by(r4scako) store seed(`seed') keep(_all) impute(1)
use hotdeck_data/r4newAlcbase_a_imp.dta, replace

* Finally calculate the new weekly consumption 
gen r4newAlcbase = r4newAlcbase_a / 52

append using `scako_missing'

* Now loop over possible values of scako and impute within group
*forvalues level = 1/7 {
*    replace 
*}

*save $outdata/H_ELSA_g2_infrequent_drinkers.dta, replace
*save $outdata/H_ELSA_g2_wv_specific, replace
