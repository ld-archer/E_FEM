/** \file
This program explores the different relationship status variables in the ACS in order to create a definition that is consistent
with what is used for PSID/FAM.
*/


* 2009 ACS 1-year file that will be used for reweighting
use "/sch-data-library/public-data/ACS/Stata/population_2009.dta"
sort serialno 

* we need to drop those in group quarters to be consistent with PSID
drop if rel == "16" | rel == "17"

* Check household sizes
by serialno: gen hhsize = _N
tab hhsize
drop hhsize
foreach r in 00 01 13 {
	gen rel`r' = rel == "`r'"
	by serialno: egen hhrel`r' = total(rel`r') 
	tab hhrel`r'
}

*** Definition 1: use rel variable to derive relationship in household -- this code was borrowed from FEM_Stata/Makedata/ACS/ACS_trends_final.do
* Cohab
gen cohab = (rel == "13")

* Assign married flag to household head and husband/wife
gen married = (rel == "01")
bys serialno: egen married_hh = total(married)
tab married
replace married = 1 if married_hh == 1 & rel == "00"

* Assign cohabitation status to person with rel = 00 if cohabitating
bys serialno: egen cohab_hh = total(cohab)
tab cohab_hh
replace cohab = 1 if cohab_hh == 1 & rel == "00"
	
* Assign single to those who are not married or cohabitating
gen single = (married == 0 & cohab == 0)

gen mstat2 = .
replace mstat2=1 if single==1
replace mstat2=2 if cohab==1
replace mstat2=3 if married==1
label define mstat2_lbl 1 "Single" 2 "Cohab" 3 "Married"
label values mstat2 mstat2_lbl
label var mstat2 "Derived marital status (def. 1)"
	
*** Definition 2: use mar variable
label define mar_lbl 1 "Married" 2 "Widowed" 3 "Divorced" 4 "Separated" 5 "Never married"
destring mar, replace
label values mar mar_lbl
label var mar "ACS Marital status"

*** Definition 3: use msp variable	
label define msp_lbl 1 "Married, sp. present" 2 "Married, sp. absent" 3 "Widowed" 4 "Divorced" 5 "Seperated" 6 "Never married"
destring msp, replace
label values msp msp_lbl
label var msp "ACS Marital status, spouse present/absent"

*** Comparison 1: mar and msp
tab msp mar, m
tab msp mar [fw=pwgtp], m

*** Comparison 2: mar and mstat2
tab mar mstat2, m
tab mar mstat2 [fw=pwgtp], m

*** Comparison 3: msp and mstat2
tab msp mstat2, m	
tab msp mstat2 [fw=pwgtp], m

*** Definition 4: Use self-reported marital status (Definition 2), but use household structure to define cohab and to override where conflicting (Definition 1)
* Married if reported married
gen mstat3 = 3 if mar==1
* Married if reported separated and no partner in HH
replace mstat3 = 3 if mar==4 & mstat2==1
* Single if widowed, divorced, or never married and no partner in HH
replace mstat3 = 1 if inlist(mar,2,3,5) & mstat2==1
* Cohab if widowed, divorced, never married, or separated, and unmarried partner in HH
replace mstat3 = 2 if inlist(mar,2,3,4,5) & mstat2 == 2
label values mstat3 mstat2_lbl
label var mstat3 "Marital status (def. 4)"

di "heads"
tab mar mstat3 if rel=="00", m

di "non-heads"
tab mar mstat3 if rel!="00", m

* check agreement of head status w/in married and cohab HHs
tab mstat3 if rel == "00" & cohab_hh==1, m
tab mstat3 if rel == "00" & married_hh==1, m

*** Comparison 4: mar and mstat3
tab mar mstat3, m

*** Comparison 5: msp and mstat3
tab msp mstat3, m
