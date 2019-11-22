include common.do

***************************************************
*EXTRACT AND RENAME VARIABLES FROM PSID INDIV FILE, SOC SECURITY FILE AND WEALTH FILES
***************************************************


*RUN THE ADO FILE THAT RENAME RAW VARIABLES
run "$wkdir/rename_psidvar.ado"

/**********************************
*Individual file IDs
**********************************/

**Sequence number:which indicates the person's position and status for any given year's list of family members.
#d;
global seqin 
        [68]ER30002 [69]ER30021 [70]ER30044 [71]ER30068 [72]ER30092 [73]ER30118 
           [74]ER30139 [75]ER30161 [76]ER30189 [77]ER30218 [78]ER30247 [79]ER30284 
           [80]ER30314 [81]ER30344 [82]ER30374 [83]ER30400 [84]ER30430 [85]ER30464 
           [86]ER30499 [87]ER30536 [88]ER30571 [89]ER30607 [90]ER30643 [91]ER30690 
           [92]ER30734 [93]ER30807 [94]ER33102 [95]ER33202 [96]ER33302 [97]ER33402 
           [99]ER33502 [01]ER33602 [03]ER33702 [05]ER33802 [07]ER33902 [09]ER34002
           [11]ER34102 [13]ER34202 [15]ER34302;
#d cr

**Family ID in that year
#d;
global famnumin
	[68]ER30001 [69]ER30020 [70]ER30043 [71]ER30067 [72]ER30091 
              [73]ER30117 [74]ER30138 [75]ER30160 [76]ER30188 [77]ER30217 [78]ER30246 
              [79]ER30283 [80]ER30313 [81]ER30343 [82]ER30373 [83]ER30399 [84]ER30429 
              [85]ER30463 [86]ER30498 [87]ER30535 [88]ER30570 [89]ER30606 [90]ER30642 
              [91]ER30689 [92]ER30733 [93]ER30806 [94]ER33101 [95]ER33201 [96]ER33301 
              [97]ER33401 [99]ER33501 [01]ER33601 [03]ER33701 [05]ER33801 [07]ER33901 
              [09]ER34001 [11]ER34101 [13]ER34201 [15]ER34301;
#d cr
**Relationship to head
#d;

global relhdin
	[68]ER30003 [69]ER30022 [70]ER30045 [71]ER30069 [72]ER30093 
             [73]ER30119 [74]ER30140 [75]ER30162 [76]ER30190 [77]ER30219 [78]ER30248 
             [79]ER30285 [80]ER30315 [81]ER30345 [82]ER30375 [83]ER30401 [84]ER30431 
             [85]ER30465 [86]ER30500 [87]ER30537 [88]ER30572 [89]ER30608 [90]ER30644 
             [91]ER30691 [92]ER30735 [93]ER30808 [94]ER33103 [95]ER33203 [96]ER33303 
             [97]ER33403 [99]ER33503 [01]ER33603 [03]ER33703 [05]ER33803 [07]ER33903 
             [09]ER34003 [11]ER34103 [13]ER34203 [15]ER34303;
#d cr

**Age actual age of the individual reported in years on his or her most recent birthday (valid values 1-125)
#d;
global agein [68]ER30004 [69]ER30023 [70]ER30046 [71]ER30070 [72]ER30094 [73]ER30120 [74]ER30141 
		[75]ER30163 [76]ER30191 [77]ER30220 [78]ER30249 [79]ER30286 [80]ER30316 [81]ER30346 
		[82]ER30376 [83]ER30402 [84]ER30432 [85]ER30466 [86]ER30501 [87]ER30538 [88]ER30573 
		[89]ER30609 [90]ER30645 [91]ER30692 [92]ER30736 [93]ER30809 [94]ER33104 [95]ER33204 
		[96]ER33304 [97]ER33404 [99]ER33504 [01]ER33604 [03]ER33704 [05]ER33804 [07]ER33904 [09]ER34004
		[11]ER34104 [13]ER34204 [15]ER34305;
#d cr	

**Health insurance variables

**type of HI last year or year before
/*
1 Employer provided health insurance 
2 Private health insurance purchased directly 
3 Medicare 
4 Medi-Gap/Supplemental 
5 Medicaid/Medical Assistance/[STATE PROGRAM] 
6 Military health care/TRICARE (Active) 
7 CHAMPUS/TRICARE/CHAMP-VA (Dependents, Veterans) 
8 Indian Health Insurance 
9 Other state-sponsored plan (not Medicaid) 
10 Other government program 
97 Other 
98 DK 
99 NA; refused 
0 Inap.: not covered by health care plan; from Latino sample (ER30001=7001-9308); main family nonresponse by 2009 or mover-out nonresponse by 2007 (ER34001=0); moved out before 2007 (ER34002=71-89 and ER34010>0 and ER34010<2007) 
*/

*first mention
global hlins1stin [99]ER33518 [01]ER33618 [03]ER33718 [05]ER33819 [07]ER33919 [09]ER34022 [11]ER34121

*second mention
global hlins2ndin [99]ER33519 [01]ER33619 [03]ER33719 [05]ER33820 [07]ER33920 [09]ER34023 [11]ER34122

*3rd mention
global hlins3rdin [99]ER33520 [01]ER33620 [03]ER33720 [05]ER33821 [07]ER33921 [09]ER34024 [11]ER34123

*4th mention
global hlins4thin [99]ER33521 [01]ER33621 [03]ER33721 [05]ER33822 [07]ER33922 [09]ER34025 [11]ER34124

*months covered by health insurance last year
global hlinsmoin [99]ER33523 [01]ER33623 [03]ER33723 [05]ER33825 [07]ER33925 [09]ER34028 [11]ER34127


/* In 2011+ they also ask about current health insurance.  They seem to have stopped asking about previous in 2013 */

* Any health insurance currently
global curhlinsin [11]ER34128 [13]ER34235 [15]ER34385

* Current health insurnace, first mention
global curhlins1stin [11]ER34129 [13]ER34236 [15]ER34386

* Current health insurnace, second mention
global curhlins2ndin [11]ER34130 [13]ER34237 [15]ER34387

* Current health insurnace, third mention
global curhlins3rdin [11]ER34131 [13]ER34238 [15]ER34388

*Type of Social security income (only available in 2009+)
* For other years get from socsectype file. 
* note that in 2009 there is one variable for socsectype
* but in 2011 there are six, one for each type
* ER34137  G33A WTR SOC SEC TYPE DISABILITY      11
* ER34138  G33A WTR SOC SEC TYPE RETIREMENT      11
* ER34139  G33A WTR SOC SEC TYPE SURVIVOR        11
* ER34140  G33A WTR SOC SEC TYPE DEP OF DISABLED 11
* ER34141  G33A WTR SOC SEC TYPE DEP OF RETIRED  11
* ER34142  G33A WTR SOC SEC TYPE OTHER

global sstypein [09]ER34030 [11]SSTP11 [13]SSTP13 [15]SSTP15
*Amount of social security income (only available in 2009+)
global ssamtin  [09]ER34031 [11]ER34143 [13]ER34250 [15]ER34400

*Employment status for non-head, non-wife
global empstatothin [99]ER33512 [01]ER33612 [03]ER33712 [05]ER33813 [07]ER33913 [09]ER34016 [11]ER34116 [13]ER34216 [15]ER34317

*DEFINE LIST OF VARIABLES TO EXTRACT
#d ;
global allvars seqin famnumin relhdin agein  empstatothin hlins1stin hlins2ndin hlins3rdin hlins4thin  hlinsmoin sstypein ssamtin
	curhlinsin curhlins1stin curhlins2ndin curhlins3rdin ;
#d cr

*----------------------------------------------
* local maxyr 2009
use "$psid_dir/Stata/ind${lastyr}er.dta", clear	

	*UNIQUE ID = famID in 1968*1000+SeqNum in 1968
	ren ER30001 famno68
	ren ER30002 pn68
	gen id = famno68 * 1000 + pn68

* need to combine 2011 soc sec types
gen multss11=(ER34137==1)+(ER34138==1)+(ER34139==1)+(ER34140==1)+(ER34141==1)+(ER34142==1)
gen SSTP11=0 if multss11==0
replace SSTP11=1 if multss11==1 & ER34137==1   
replace SSTP11=2 if multss11==1 & ER34138==1   
replace SSTP11=3 if multss11==1 & ER34139==1   
replace SSTP11=5 if multss11==1 & ER34140==1   
replace SSTP11=6 if multss11==1 & ER34141==1   
replace SSTP11=7 if multss11==1 & ER34142==1   
replace SSTP11=4 if multss11>1
tab SSTP11

* need to combine 2013 soc sec types
gen multss13=(ER34244==1)+(ER34245==1)+(ER34246==1)+(ER34247==1)+(ER34248==1)+(ER34249==1)
gen SSTP13=0 if multss13==0
replace SSTP13=1 if multss13==1 & ER34244==1   
replace SSTP13=2 if multss13==1 & ER34245==1   
replace SSTP13=3 if multss13==1 & ER34246==1   
replace SSTP13=5 if multss13==1 & ER34247==1   
replace SSTP13=6 if multss13==1 & ER34248==1   
replace SSTP13=7 if multss13==1 & ER34249==1   
replace SSTP13=4 if multss13>1
tab SSTP13

* need to combine 2015 soc sec types
gen multss15=(ER34394==1)+(ER34395==1)+(ER34396==1)+(ER34397==1)+(ER34398==1)+(ER34399==1)
gen SSTP15=0 if multss15==0
replace SSTP15=1 if multss15==1 & ER34394==1   
replace SSTP15=2 if multss15==1 & ER34395==1   
replace SSTP15=3 if multss15==1 & ER34396==1   
replace SSTP15=5 if multss15==1 & ER34397==1   
replace SSTP15=6 if multss15==1 & ER34398==1   
replace SSTP15=7 if multss15==1 & ER34399==1   
replace SSTP15=4 if multss15>1
tab SSTP15


set trace off
forvalues i = $firstyr(2)$lastyr {
	foreach x in $allvars {
		rename_psidvar, rawlist("`x'")  yyyy(`i') naming_yr(1)
	}
}

cap drop ER*
cap drop V*

des

*keep those who were ever head or wife during beginning year or ending year
gen hdwfever = 0
forvalues i = $firstyr(2)$lastyr {
	*gen head_`i' = inlist(relhd_`i',1,10) & seq_`i' == 1
	*gen wife_`i' = inlist(relhd_`i',2,20,22) & seq_`i' == 2
	
	gen head_`i' = inlist(relhd_`i',1,10) & inrange(seq_`i',1,50)
	gen wife_`i' = inlist(relhd_`i',2,20,22) & inrange(seq_`i',1,50)
 
	replace hdwfever = 1 if head_`i' == 1 | wife_`i' == 1
}
keep if hdwfever == 1

*Reshape the dataset to long format
#d;
	reshape long seq famnum relhd age  empstatoth hlins1st hlins2nd hlins3rd hlins4th  hlinsmo head wife sstype ssamt curhlins curhlins1st curhlins2nd curhlins3rd
	, i(id famno68 pn68 hdwfever) j(year)  string;
	replace year = substr(year,2,.) ;
	destring year, replace ;
#d cr
des
sum
tab year
saveold "$temp_dir/psid_inder_${firstyr}to${lastyr}.dta", replace


