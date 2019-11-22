/*
This file can be included in other programs when using the ACS 1-year data.  It defines marital status categories
(single, married, cohab) to match the categories in FAM/PSID.  It was tested on 2009 data.  Other ACS years might 
not have the same 
*/

* backup mar and destring it (this will be undone at end of file)
gen mar_old = mar
destring mar, replace

/*** First, define marital status based on relations between partners ***/
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

/*** Next, use ACS reported marital status (mar), but define cohab/single from relations between partners ***/
* Married if reported married
gen mstat_new = 3 if mar==1
* Married if reported separated and no partner in HH
replace mstat_new = 3 if mar==4 & single==1
* Single if widowed, divorced, or never married and no partner in HH
replace mstat_new = 1 if inlist(mar,2,3,5) & single==1
* Cohab if widowed, divorced, never married, or separated, and unmarried partner in HH
replace mstat_new = 2 if inlist(mar,2,3,4,5) & cohab==1
label define mstat_lbl 1 "Single" 2 "Cohab" 3 "Married"
label values mstat_new mstat_lbl
label var mstat_new "Marital status"

* Widowed if reported widowed and single (marriage/cohab after widowhood is not considered a widow in FAM)
gen widowed = mar==2 & mstat_new==1

* check for missing values
tab mstat_new, m
tab widowed, m

* check status for heads and non-heads
di "heads"
tab mar mstat_new if rel=="00", m
di "non-heads"
tab mar mstat_new if rel!="00", m

* check agreement of head status w/in married and cohab HHs
tab mstat_new if rel == "00" & cohab_hh==1, m
tab mstat_new if rel == "00" & married_hh==1, m

drop mar single married married_hh cohab cohab_hh
rename mar_old mar


