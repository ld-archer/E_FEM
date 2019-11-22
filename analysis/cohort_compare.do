clear all
include ../fem_env.do
set more off

infile using nwi.dict

tempfile nwi
save `nwi'
clear

local scenarios "example_stock ante_stock"
gen scenario = ""
foreach v of local scenarios {
  append using ../output/`v'/`v'_summary
  replace scenario = "_`v'" if missing(scenario)
}

sort year
merge m:1 year using `nwi', keep(master match) keepusing(nwi) nogen
bys scenario (year): gen nwi_delta = nwi/nwi[1]
by scenario (year): gen p_iearnx_nwi = p_iearnx_all[1] * nwi_delta
label var p_iearnx_nwi "iearnx 2004 inflated by NWI only"

local hlth_n n_cancre_all n_diabe_all n_hearte_all n_hibpe_all n_lunge_all n_stroke_all
local hlth_p p_cancre_all p_diabe_all p_hearte_all p_hibpe_all p_lunge_all p_stroke_all
local pop m_endpop_all m_startpop_all pop_medicare
local income p_iearnx_all p_iearnx_nwi
local participation p_ssclaim_all p_ssiclaim_all p_work_all p_diclaim_all p_anyhi_all p_dbclaim_all
local wealth p_hatota_all

foreach v of varlist `hlth_n' {
  replace `v' = `v'/1e6
}

twoway connected `hlth_n' year, by(scenario) xtitle("Year") ytitle("Prevalence (M)") title("Health Conditions") name(hlth_n) legend(cols(1))
graph export hlth_n.eps, replace

twoway connected `hlth_p' year, by(scenario) xtitle("Year") ytitle("Prevalence (%)") title("Health Conditions") name(hlth_p) legend(cols(1))
graph export hlth_p.eps, replace

twoway connected `participation' year, by(scenario) xtitle("Year") ytitle("Participation Rate") title("Program Participation") name(participation) legend(cols(1))
graph export participation.eps, replace

twoway connected `pop' year, by(scenario) xtitle("Year") ytitle("Millions of People") title("Population") name(pop) legend(cols(1))
graph export pop.eps, replace

twoway connected `income' year, by(scenario) xtitle("Year") ytitle("Thousands of Dollars") title("Income Outcomes") name(income) legend(cols(1))
graph export income.eps, replace

twoway connected `wealth' year, by(scenario) xtitle("Year") ytitle("Thousands of Dollars") title("Wealth Outcomes") name(wealth) legend(cols(1))
graph export wealth.eps, replace

keep `hlth' `pop' `income' year scenario
reshape wide `hlth' `pop' `income', i(year) j(scenario) string
outsheet using cohort_compare.csv, comma replace
