/* 
Compare FEM baseline population forecasts to Census
*/


clear all
set more off
include ../../../../../fem_env.do


/* 2012+ Census population projections */


global pop_proj_file "2012_Pop_Projection/NP2012_D1.csv"

insheet using $census_dir/$pop_proj_file
keep if origin == 0 & race == 0 & sex == 0
* Two population measures: 51+ and 65+
egen pop_51p = rowtotal(pop_51-pop_100)
egen pop_65p = rowtotal(pop_65-pop_100)
egen pop_85p = rowtotal(pop_85-pop_100)

foreach var in pop_51p pop_65p pop_85p {
	replace `var' = `var'/(10^6)
	rename `var' `var'_census
}

label var pop_51p_census "2012 Census 51+ population projection"
label var pop_65p_census "2012 Census 65+ population projection"
label var pop_85p_census "2012 Census 85+ population projection"

label var year "Year"

keep year pop_51p_census pop_65p_census pop_85p_census

tempfile census
save `census'


/* Process FEM "minimal" results */
capture confirm file "$routput_dir/vMinimal_sq"
if _rc {
  local output $output_dir
}
else {
  local output $routput_dir
}

use `output'/vMinimal_sq/vMinimal_sq_summary.dta, replace

keep year end_pop end_pop65p

rename end_pop FEM_minimal_51p
rename end_pop65p FEM_minimal_65p

label var FEM_minimal_51p "FEM minimal 51+ population projection"
label var FEM_minimal_65p "FEM minimal 65+ population projection"

tempfile minimal
save `minimal'


/* Process FEM "baseline" results */

use `output'/vBaseline_sq/vBaseline_sq_summary.dta, replace

keep year end_pop end_pop65p

rename end_pop FEM_51p
rename end_pop65p FEM_65p

label var FEM_51p "FEM 51+ population projection"
label var FEM_65p "FEM 65+ population projection"

tempfile baseline
save `baseline'


use `minimal'
merge 1:1 year using `baseline'
drop _merge
merge 1:1 year using `census'
drop _merge
* Keep even years
keep if mod(year,2) == 0

keep if year >= 2012 & year <= 2050

order year pop_51p pop_65p FEM_51p FEM_65p FEM_minimal_51p FEM_minimal_65p 

outsheet using population_compare_all.csv, comma replace


keep year pop_51p pop_65p FEM_51p FEM_65p

* Save the file
outsheet using population_compare.csv, comma replace



capture log close
