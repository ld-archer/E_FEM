/* Compare FEM forecasts of population to CA DOF */


quietly include ../fem_env.do

insheet using $ca_dof_dir/P3_Complete.csv

keep if agerc >= 51

* Collapse to year level
collapse (sum) perwt, by(year)
rename perwt ca_dof
replace ca_dof = ca_dof/1e6

tempfile ca_dof
save `ca_dof'

*** Typical FEM results ***
use ../output/ca_fem_stock/ca_fem_stock_summary.dta

merge 1:1 year using `ca_dof'

gen diff = m_endpop_all - ca_dof

list year m_endpop_all ca_dof diff



clear
*** Minimal results ***
use ../output/ca_fem_stock_minimal/ca_fem_stock_minimal_summary.dta

merge 1:1 year using `ca_dof'
gen diff = m_endpop_all - ca_dof

list year m_endpop_all ca_dof diff





capture log close
