clear

quietly include ../../../fem_env.do

* Import csv dataset
import delimited using $outdata/CT0469_2011census_educ.csv, varnames(1)
*import delimited using ../../../input_data/CT0469_2011census_educ.csv, varnames(1)

* Drop rows where data info is written
drop in 314/332

* Drop unnecessary variables (only need total)
drop v5-l15fulltimestudents

* Replace missing vars with value from observation above (only occurs in first 2 vars)
replace v1 = v1[_n-1] if missing(v1)
replace v2 = v2[_n-1] if missing(v2)

* Rename variables
rename v1 Sex
rename v2 Age
rename v3 Qualifications
rename totalnssec Total

* Only keep data for 30-34 yo's to 45-49 yo's
keep if Age == "Age 30 to 34" || Age == "Age 35 to 39" || Age == "Age 40 to 44" || Age == "Age 45 to 49"

* Drop totals
drop if Qualifications == "Total: Highest level of qualification"
drop if Sex == "Total: Sex"

* Change education categories to fit literature standard, 3 categories:
* Lower - No qualifications
* Intermediate - Quals less than university degree
* Higher - University degree or higher
* This fits better with ISCED classification
replace Qualifications = "Lower" if Qualifications == "No Qualifications"
replace Qualifications = "Intermediate" if Qualifications == "Other qualifications"
replace Qualifications = "Intermediate" if Qualifications == "Apprenticeship"
replace Qualifications = "Intermediate" if Qualifications == "Level 1 qualifications"
replace Qualifications = "Intermediate" if Qualifications == "Level 2 qualifications"
replace Qualifications = "Intermediate" if Qualifications == "Level 3 qualifications"
replace Qualifications = "Higher" if Qualifications == "Level 4 qualifications and above"

replace Total=subinstr(Total,",","",.)
destring Total, replace

* Group by Qualifications and Sex
collapse (sum) Total, by(Age Qualifications Sex)
gsort Age -Sex -Qualifications

* Replace string with binary for male/female
gen male = 1 if Sex == "Males"
replace male = 0 if Sex == "Females"
* Drop Sex var (replaced with male)
drop Sex
*Reorder
order male

* Clean up age cells
replace Age = subinstr(Age, "Age ", "",.)
replace Age = subinstr(Age, " to ", "-",.)

* Rename total
rename Total total

* Expand groups of observations, by cluster of age then sort
expandcl 5, generate(newAge) cluster(Age)
gsort newAge -Qualifications

* Expand ages from bins
replace newAge = newAge + 29

drop Age
rename newAge age

* Get the average of the total per age bin for the midpoint in age
* i.e. 30-34 midpoint == 32
gen totalPerYear = .
replace totalPerYear = total/4 if inlist(age, 32, 37, 42, 47)

* Save whole dataset as tempfile so we can take subsets to interpolate
tempfile all
save `all'

* Male Lower qual
keep if male == 1
keep if Qualifications == "Lower"
ipolate totalPerYear age, gen(perYear) epolate
tempfile maleLower
save `maleLower'

use `all'
* Male Inter 
keep if male == 1
keep if Qualifications == "Intermediate"
ipolate totalPerYear age, gen(perYear) epolate
tempfile maleInter
save `maleInter'

use `all'
* Male Higher
keep if male == 1
keep if Qualifications == "Higher"
ipolate totalPerYear age, gen(perYear) epolate
tempfile maleHigher
save `maleHigher'

use `all'
* Female Lower
keep if male == 0
keep if Qualifications == "Lower"
ipolate totalPerYear age, gen(perYear) epolate
tempfile femaleLower
save `femaleLower'

use `all'
* Female Inter
keep if male == 0
keep if Qualifications == "Intermediate"
ipolate totalPerYear age, gen(perYear) epolate
tempfile femaleInter
save `femaleInter'

use `all'
* Female Higher
keep if male == 0
keep if Qualifications == "Higher"
ipolate totalPerYear age, gen(perYear) epolate
tempfile femaleHigher
save `femaleHigher'

* Clear data from memory so we can append sets together
clear

* Make tempfile for appending all data to
tempfile working
save `working', emptyok

* append all male
append using `maleLower'
append using `maleInter'
append using `maleHigher'

* append all female
append using `femaleLower'
append using `femaleInter'
append using `femaleHigher'

* Scatter to check
*twoway scatter perYear age if Qualifications == "Higher" & male == 1

* Drop unnecessary vars and rename new total var
drop total totalPerYear
rename perYear total

* Generate education code to match coded var in replenishing populations
gen educ = .
replace educ = 1 if Qualifications == "Lower"
replace educ = 2 if Qualifications == "Intermediate"
replace educ = 3 if Qualifications == "Higher"
drop Qualifications

* Generate birthyear var to merge with replenishing pop
gen rbyr = 2012 - age

* Order and sort
order male rbyr age educ total
gsort rbyr male educ

* Recast float education value to byte
recast byte educ

* Tempsave file to append later
tempfile rbyr6382
save `rbyr6382'

* Extend distribution in 1982 through
keep if rbyr == 1982

* Expand by 27 so distribution extended to 2009
* This is the limit of the replenishing populations (at least at present)
expandcl 27, generate(newcl) cluster(age)

* Sort
gsort newcl age male educ

* Add new cluster value to birth year to produce 
replace rbyr = rbyr + newcl

* Drop cluster var
drop newcl

* Append the 1963-1982 distribution
append using `rbyr6382'
gsort rbyr male educ

* Save the education distribution
*save ../../../input_data/education_data.dta, replace
save $outdata/education_data.dta, replace

capture log close
