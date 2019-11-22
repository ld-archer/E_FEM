/*
-Look across all years of the individual file and see if reason for non-response is jail/prison
-Look at 1995 questions regarding being booked for crime or being in jail/prison/reform school
*/

include common.do

*RUN THE ADO FILE THAT RENAME RAW VARIABLES
run "$wkdir/rename_psidvar.ado"

#d;
global nonresponsein [68]ER30018 [69]ER30041 [70]ER30065 [71]ER30089 [72]ER30115 [73]ER30136 [74]ER30158 
		[75]ER30186 [76]ER30215 [77]ER30244 [78]ER30281 [79]ER30311 [80]ER30341 [81]ER30371 
		[82]ER30397 [83]ER30427 [84]ER30461 [85]ER30496 [86]ER30533 [87]ER30568 [88]ER30604 
		[89]ER30640 [90]ER30685 [91]ER30729 [92]ER30802 [93]ER30863 [94]ER33127 [95]ER33283 
		[96]ER33325 [97]ER33437 [99]ER33545 [01]ER33636 [03]ER33739 [05]ER33847 [07]ER33949 
		[09]ER34044 [11]ER34153 [13]ER34267 [15]ER34412; 
#d cr

global allvars nonresponsein

local lastyr $lastyr
use "$psid_dir/Stata/ind`lastyr'er.dta", clear	

*UNIQUE ID = famID in 1968*1000+SeqNum in 1968
ren ER30001 famno68
ren ER30002 pn68
gen id = famno68 * 1000 + pn68

* 1995 questions regarding criminal behavior (only asked of ages 14-49)
* Booked or charged
ren ER33266 booked95
* ever spent time in jail, prison, youth training, or reform school 
ren ER33267 corrections95


forvalues i = 1968/1996 {
	foreach x in $allvars {
		rename_psidvar, rawlist("`x'")  yyyy(`i') naming_yr(1)
	}
}

forvalues i = 1997 (2) $lastyr {
	foreach x in $allvars {
		rename_psidvar, rawlist("`x'")  yyyy(`i') naming_yr(1)
	}
}

cap drop ER*
cap drop V*

*Reshape the dataset to long format
reshape long nonresponse, i(id) j(year) string
replace year = substr(year,2,.) 
destring year, replace 


* Identify individuals who were previously in jail
sort id year
by id (year): egen firstjail = min(cond(nonresponse == 14, year, .))
gen jaile = 0
replace jaile = (year >= firstjail) & !missing(firstjail)


* Based on 1995 questions, recode those who spent time in corrections
recode booked95 (0=.) (1=1) (5=0) (8=.) (9=.)
recode corrections95 (0=.) (1=1) (5=0) (8=.) (9=.)
tab booked95 corrections95
replace corrections95 = 0 if booked95 == 0
tab booked95 corrections95

gen jaile_alt = jaile

tab jaile
tab jaile corrections95
replace jaile_alt = 1 if corrections95 == 1 & year >= 1995
tab jaile_alt
tab jaile_alt corrections95

label var booked95 "Reports being booked or charged with breaking the law in 1995 survey"
label var corrections95 "Reports spending time in jail, prison, youth training or reform school in 1995 survey"
label var jaile "Ever non-response due to being in prison or jail"
label var jaile_alt "Ever non-response due to prison/jail OR reported spending time in jail/prison/youth-training/reform in 1995 survey"

keep id year jaile jaile_alt
rename id hhidpn

save $outdata/prison.dta, replace


capture log close
