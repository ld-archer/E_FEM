/* Process the California Department of Finance population projections for use in reweighting the stock and replenishing populations
*/

quietly include ../../../fem_env.do

local table_dir ../../../FEM_CPP_settings/ca_fem/tables

insheet using $ca_dof_dir/P3_Complete.csv


/* 1        sex
                        1       Female
                        2       Male
2        race7
                        1       White, Non-Hispanic
                        2       Black, Non-Hispanic
                        3       American Indian or Alaska Native, Non-Hispanic
                        4       Asian, Non-Hispanic
                        5       Native Hawaiian or Pacific Islander, Non-Hispanic
                        6       Multiracial (two or more of above races), Non-Hispanic
                        7       Hispanic (any race)
                        
*/


* Race/ethnicity: 1 = hispan, 2 = white, 3 = black, 4 = other
gen racegrp = .
replace racegrp = 1 if inlist(race7,7)
replace racegrp = 2 if inlist(race7,1)
replace racegrp = 3 if inlist(race7,2)
replace racegrp = 4 if inlist(race7,3,4,5,6)

gen male = .
replace male = 1 if sex == 2
replace male = 0 if sex == 1

* Collapse to year/sex/race/age level
collapse (sum) perwt, by(year male racegrp agerc)

label var perwt "Population"
label var year "Year"
label var male "Male"
label var racegrp "Race Hisp/Wh/Bl/oth"
label var agerc "Age"

* to match what we use in HRS
rename perwt pop
rename agerc age

save $outdata/ca_dof.dta, replace


clear all


*** Process the migration data - note that this is at the county-year level ***

import excel using $ca_dof_dir/P_Components_interim.xlsx, cellrange(A4:H2962) firstrow

rename County county
rename Date start_date
rename Population start_pop
rename Births births
rename Deaths deaths
rename Netmigrants net_migration
rename G end_date
rename H end_pop   

collapse (sum) net_migration, by(end_date)
gen year = substr(end_date,5,4)
drop end_date

order year net_migration

* Assuming that the vast majority (95%) of migration is people 50 and under.  This is an educated guess at best!!! 
replace net_migration = round(0.05*net_migration)

save $outdata/ca_migration.dta, replace

sort year 
local j = _N

file open myfile using `table_dir'/immigration.txt, write text replace
#delimit ; 
file write myfile 
"|Source: CA Department of Finance net migration forecasts" _n
"year" _n;
forval i=1/`j' {;
	file write myfile
	(year[`i']) _tab (net_migration[`i']) _n;
};
#delimit cr
file close myfile	

capture log close
