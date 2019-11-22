/* Comparison of population projections for FAM compared to Census projections */


clear all
set more off
include ../../fem_env.do

local tbl 10_1


/* Intercensal population estimates for 2009 */
insheet using $census_dir/2000_2010_Intercensal_Estimates/US-EST00INT-ALLDATA.csv
keep if year == 2009

forvalues x = 25 (10) 85 {
	gen pop_`x'p = tot_pop if age >= `x' & age < 999
}

collapse (sum) pop_25p pop_35p pop_45p pop_55p pop_65p pop_75p pop_85p, by(year)
forvalues x = 25 (10) 85 {
	replace pop_`x'p = pop_`x'p/1e6
	rename pop_`x'p pop_`x'p_census
}

tempfile census2009
save `census2009'


/* 2011 Census population estimates - need a good file for this*/
clear
set obs 1
gen year = 2011
gen pop_25p_census = 206592936/(1e6)
gen pop_35p_census = 164802438/(1e6)
gen pop_45p_census = 124174484/(1e6)
gen pop_55p_census = 79456281/(1e6)
gen pop_65p_census = 41394141/(1e6)
gen pop_75p_census = 18912403/(1e6)
gen pop_85p_census = 5737173/(1e6)

tempfile census2011
save `census2011'
clear

/* 2012+ Census population projections */


global pop_proj_file "2012_Pop_Projection/NP2012_D1.csv"

insheet using $census_dir/$pop_proj_file
keep if origin == 0 & race == 0 & sex == 0
* Two population measures: 51+ and 65+
egen pop_25p = rowtotal(pop_25-pop_100)
egen pop_35p = rowtotal(pop_35-pop_100)
egen pop_45p = rowtotal(pop_45-pop_100)
egen pop_55p = rowtotal(pop_55-pop_100)
egen pop_65p = rowtotal(pop_65-pop_100)
egen pop_75p = rowtotal(pop_75-pop_100)
egen pop_85p = rowtotal(pop_85-pop_100)

foreach var in pop_25p pop_35p pop_45p pop_55p pop_65p pop_75p pop_85p {
	replace `var' = `var'/(10^6)
	rename `var' `var'_census
}

label var pop_25p_census "2012 Census 25+ population projection"
label var pop_35p_census "2012 Census 35+ population projection"
label var pop_45p_census "2012 Census 45+ population projection"
label var pop_55p_census "2012 Census 55+ population projection"
label var pop_65p_census "2012 Census 65+ population projection"
label var pop_75p_census "2012 Census 75+ population projection"
label var pop_85p_census "2012 Census 85+ population projection"

label var year "Year"

keep year pop_25p_census pop_35p_census pop_45p_census pop_55p_census pop_65p_census pop_75p_census pop_85p_census

tempfile census
save `census'

* PSID population with no health in transition models
use $output_dir/psid_minimal/psid_minimal_summary, replace
keep year m_endpop_all m_endpop_35p m_endpop_45p m_endpop_55p m_endpop_65p m_endpop_75p m_endpop_85p
foreach var in m_endpop_all m_endpop_35p m_endpop_45p m_endpop_55p m_endpop_65p m_endpop_75p m_endpop_85p {
	rename `var' `var'_minimal
}

label var m_endpop_all_minimal "FAM with no health ending population 25+"
label var m_endpop_35p_minimal "FAM with no health ending population 35+"
label var m_endpop_45p_minimal "FAM with no health ending population 45+"
label var m_endpop_55p_minimal "FAM with no health ending population 55+"
label var m_endpop_65p_minimal "FAM with no health ending population 65+"
label var m_endpop_75p_minimal "FAM with no health ending population 75+"
label var m_endpop_85p_minimal "FAM with no health ending population 85+"


tempfile minimal
save `minimal'


* PSID population with health in transition models
use $output_dir/psid_baseline/psid_baseline_summary, replace
keep year m_endpop_all m_endpop_35p m_endpop_45p m_endpop_55p m_endpop_65p m_endpop_75p m_endpop_85p
foreach var in m_endpop_all m_endpop_35p m_endpop_45p m_endpop_55p m_endpop_65p m_endpop_75p m_endpop_85p {
	rename `var' `var'_baseline
}

label var m_endpop_all_baseline "FAM ending population 25+"
label var m_endpop_35p_baseline "FAM ending population 35+"
label var m_endpop_45p_baseline "FAM ending population 45+"
label var m_endpop_55p_baseline "FAM ending population 55+"
label var m_endpop_65p_baseline "FAM ending population 65+"
label var m_endpop_75p_baseline "FAM ending population 75+"
label var m_endpop_85p_baseline "FAM ending population 85+"

tempfile baseline
save `baseline'

* Append the census files
use `census2009'
append using `census2011'
append using `census'

tempfile censusall
save `censusall'




* Merge the files together
use `censusall', replace
merge 1:1 year using `minimal'
drop _merge 
merge 1:1 year using `baseline'
drop _merge

keep if year >= 2009 & year <= 2050
* Odd years for FAM
keep if mod(year,2) == 1

#d ;
order year 
pop_25p_census pop_35p_census pop_45p_census pop_55p_census pop_65p_census pop_75p_census pop_85p_census
m_endpop_all_minimal m_endpop_35p_minimal m_endpop_45p_minimal m_endpop_55p_minimal m_endpop_65p_minimal m_endpop_75p_minimal m_endpop_85p_minimal
m_endpop_all_baseline m_endpop_35p_baseline m_endpop_45p_baseline m_endpop_55p_baseline m_endpop_65p_baseline m_endpop_75p_baseline m_endpop_85p_baseline
;
#d cr

rename m_endpop_all_minimal m_endpop_25p_minimal
rename m_endpop_all_baseline m_endpop_25p_baseline

outsheet using table`tbl'.csv, comma replace
export excel using techappendix.xlsx, sheetreplace sheet("Table `tbl'") firstrow(varlabels)


* 10 year age group populations
forvalues x = 25 (10) 75 {
	local y = `x' + 9
	local z = `x' + 10
	gen age`x'`y'_census = pop_`x'p_census - pop_`z'p_census 
	gen age`x'`y'_minimal = m_endpop_`x'p_minimal - m_endpop_`z'p_minimal
	gen age`x'`y'_fam = m_endpop_`x'p_baseline - m_endpop_`z'p_baseline
	
	label var age`x'`y'_census "Census `x'-`y'"
	label var age`x'`y'_minimal "FAM minimal `x'-`y'"
	label var age`x'`y'_fam "FAM `x'-`y'"
}

rename pop_85p_census age85p_census
rename m_endpop_85p_minimal age85p_minimal
rename m_endpop_85p_baseline age85p_fam

label var age85p_census "Census 85p"
label var age85p_minimal "FAM minimal 85p"
label var age85p_fam "FAM 85p"

keep year age*

export excel using ageranges.xlsx, sheetreplace sheet("Age Ranges") firstrow(varlabels)

exit, STATA clear



