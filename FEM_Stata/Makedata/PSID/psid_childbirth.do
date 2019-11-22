/* This file will recode the PSID childbirth and adoption history file into a wide file appropriate for our purposes.
 
 Ultimately want:
	1. Number of children born/adopted in 1999, 2001, ...
	2. Time between births/adoptions
	3. 
	
Wish list for covariates in models:	
x Age 
x Race
Duration since last birth
Number of biological children
x Education
Difference in age between husband and wife
If previously married
Employment status
x Earnings (hers and - if married - his)
? If her mother gave birth to her as a teen
? If her mother graduated high school
? If her mother attended college
*/

quietly include common.do

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




capture log close
