/* This file will recode the PSID childbirth and adoption history file into a wide file with adoption dates.
 
 Ultimately want:
	1. Number of children adopted in 1999, 2001, ...
	2. Time between adoptions
	
 Approach:  Adoption date is not recorded.  We can get move-in date from the PSID Individual file.

*/
	

quietly include common.do

/* First, find move-in date for individuals on Individual file */

* Move-in variables 
global movedinin [68]ER30006 [69]ER30025 [70]ER30048 [71]ER30072 [72]ER30096 [73]ER30122 [74]ER30143 [75]ER30165 [76]ER30193 [77]ER30222 [78]ER30251 [79]ER30288 [80]ER30318 [81]ER30348 [82]ER30378 [83]ER30406 [84]ER30436 [85]ER30470 [86]ER30505 [87]ER30542 [88]ER30577 [89]ER30613 [90]ER30649 [91]ER30696 [92]ER30740 [93]ER30813 [94]ER33108 [95]ER33208 [96]ER33308 [97]ER33408 [99]ER33508 [01]ER33608 [03]ER33708 [05]ER33808 [07]ER33908 [09]ER34008
global movedmonthin [68]ER30007 [69]ER30026 [70]ER30049 [71]ER30073 [72]ER30097 [73]ER30123 [74]ER30144 [75]ER30166 [76]ER30194 [77]ER30223 [78]ER30252 [79]ER30289 [80]ER30319 [81]ER30349 [82]ER30379 [83]ER30407 [84]ER30437 [85]ER30471 [86]ER30506 [87]ER30543 [88]ER30578 [89]ER30614 [90]ER30650 [91]ER30697 [92]ER30741 [93]ER30814 [94]ER33109 [95]ER33209 [96]ER33309 [97]ER33409 [99]ER33509 [01]ER33609 [03]ER33709 [05]ER33809 [07]ER33909 [09]ER34009
global movedyearin [68]ER30008 [69]ER30027 [70]ER30050 [71]ER30074 [72]ER30098 [73]ER30124 [74]ER30145 [75]ER30167 [76]ER30195 [77]ER30224 [78]ER30253 [79]ER30290 [80]ER30320 [81]ER30350 [82]ER30380 [83]ER30408 [84]ER30438 [85]ER30472 [86]ER30507 [87]ER30544 [88]ER30579 [89]ER30615 [90]ER30651 [91]ER30698 [92]ER30742 [93]ER30815 [94]ER33110 [95]ER33210 [96]ER33310 [97]ER33410 [99]ER33510 [01]ER33610 [03]ER33710 [05]ER33810 [07]ER33910 [09]ER34010

use "$psid_dir/Stata/ind2009er.dta", clear	

*UNIQUE ID = famID in 1968*1000+SeqNum in 1968
	ren ER30001 famno68
	ren ER30002 pn68
	gen child_id = famno68 * 1000 + pn68

global allvars movedinin movedmonthin movedyearin

set trace off
forvalues i = 1985/1997  {
	foreach x in $allvars {
		rename_psidvar, rawlist("`x'")  yyyy(`i') naming_yr(1)
	}
}

forvalues i = 1999 (2) 2009  {
	foreach x in $allvars {
		rename_psidvar, rawlist("`x'")  yyyy(`i') naming_yr(1)
	}
}

cap drop ER*
cap drop V*

/* Moved in variable: 1 = moved in between previous and current interview, 
											2 = Moved in by previous interview (listing error), 
											5 = moved out between previous and current, 
											6 = moved out and into institution
											7 = living in previous but died by current, 
											8 = disappeared
											0 = Innapropriate
*/
										
* Reshape to long
reshape long movedin_ movedmonth_ movedyear_, i(child_id) j(year)				

save $outdata/indiv_temp.dta, replace

									
keep if (movedin_ == 1 | movedin_ == 2)

gen missingmonth = (movedmonth_ == 0 | movedmonth_ == 99) 
gen missingyear = (movedyear_ == 0 | movedyear_ == 9999)

* Populate missing values for month (randomly distributed) and to the previous year
replace movedmonth_ = floor(12*uniform()+1) if (movedmonth_ == 0 | movedmonth_ == 99) 
* Assign to either year or year-1 if missing and before 1997
replace movedyear_ = year - floor(2*uniform()) if (movedyear_ == 0 | movedyear_ == 9999) & year <=1997
* Assign to either year, year-1, or year-2 if missing and between 1997 and 2009
replace movedyear_ = year - floor(3*uniform()) if (movedyear_ == 0 | movedyear_ == 9999) & (year > 1997 & year <=2009)
									
* Identify first move in - require observation is of a move-in and the first date reported									
sort child_id movedyear_ movedmonth_, stable
bys child_id: keep if _n == 1

										
* Assign the first move-in 


tempfile indfile
save $outdata/temp_indiv.dta, replace
save `indfile', replace


/* Now use Childbirth and Adoption File */

use "$psid_dir/Stata/cah85_09.dta", clear

/* On this file
CAH1 - record type (1 = childbirth, 2= adoption)
CAH4-CAH7 sex of parent, parent birth month, parent birth year, marital status of mother when individual born
CAH8 - birth order of child
CAH9 & CAH10 - famnum68 and pn68 of child
CAH11 sex of child
CAH12 & CAH13 - birth month and birth year of child
CAH14 birth weight
CAH15 state of birth
CAH16-CAH18 - child location and month/year moved out or died
CAH19 hispanicity of child
CAH20-CAH22 Race of child, 1st, 2nd, 3rd mention
CAH23-CAH25 Ethnic group (primary, secondary 1st and 2nd mention)
CAH26 year most recently reported number of kids
CAH27 year most recently reported this child
CAH28 Number of natural or adopted children
CAH29 Relationship to adoptive parent
CAH30 Number of birth/adoption records
CAH31 Release number
*/

*UNIQUE ID = famID in 1968*1000+SeqNum in 1968
rename CAH2 famno68
rename CAH3 pn68
gen hhidpn = famno68 * 1000 + pn68


* Keep only the adoption records
keep if CAH1 == 2
gen child_id = 1000*CAH9 + CAH10

* Keep only the adoption records for actual children (a child_id of 0 reflects a person does not report adopting a child)
drop if child_id == 0

* Drop the identifiers that are 9999999 - not sure what we can do about these cases.
drop if child_id == 9999999



* Merge with the Individual file by child_id to find when the child moved in to the household - children can be adopted by two parents, hence the m:1 merge
merge m:1 child_id using `indfile', keep(master match)


drop _merge											
											

save $outdata/psid_adoption.dta, replace


capture log close
