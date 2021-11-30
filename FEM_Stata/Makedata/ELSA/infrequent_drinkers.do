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

bys r4scako: sum r4alcbase

hist r4alcbase

merge 1:1 idauniq using input_data/alcbase_imputed.dta, update

hist r4alcbase

bys r4scako: sum r4alcbase

*save $outdata/H_ELSA_g2_infrequent_drinkers.dta, replace
*save $outdata/H_ELSA_g2_wv_specific, replace
