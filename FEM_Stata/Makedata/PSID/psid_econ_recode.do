include common.do

/*
*Merge PSID indiv file with family file, (wealth file before 2009), selected and renamed variables only
*/


forvalues yr = $firstyr(2)$lastyr {
	append using "$temp_dir/psid_econ_merged`yr'.dta"
}

*Keep only those interviewed as head or wife in that year, or those who died after last interview
 	keep if (inrange(seq,1,50) & (head == 1 | wife == 1))
	
*HRS-equivalent variables
*Individual ID
	ren id hhidpn

*---------------------------------------------------
*EMPLOYMENT STATUS
/*
empstat1st:
Count  %  Value/Range  Text  
5,810 66.86 1 Working now 
58 .67 2 Only temporarily laid off, sick leave or maternity leave 
867 9.98 3 Looking for work, unemployed 
1,128 12.98 4 Retired 
419 4.82 5 Permanently disabled; temporarily disabled 
212 2.44 6 Keeping house 
158 1.82 7 Student 
35 .40 8 Other; "workfare"; in prison or jail 
3 .03 99 DK; NA 
NOTE in some years there are codes like 9, 22,32,35.  
PSID says these are "wild codes".
Also in some years there is a 98 code for DK
*/
/*** may want to set work missing if it is missing, i.e., empstat>8 and wkfrmoney not 1,5. */
	gen work = 0
	gen retired = 0

	foreach x in empstat1st empstat2nd empstat3rd {
		replace work = 1 if inlist(`x',1) 
		replace retired = 1 if inlist(`x',4)		
	}
*IF WORKING FOR MONEY, ALSO COUNT
	replace work = 1 if wkfrmoney == 1

  tab work, missing
  tab retired, missing
*Missing values
* wkfrmoney is missing for all of 2003
  gen xemp=(empstat1st==0 | empstat1st>8) & (empstat2nd==0 | empstat2nd>8) & (empstat3rd==0 | empstat3rd>8)

  tab xemp wkfrmoney if work==0, m
  replace work = . if work==0 & xemp==1 & inlist(wkfrmoney,.,0, 8, 9)
  replace retired = . if retired==0 & xemp==1
  
  tab work xemp, missing

  tab xemp wkfrmoney, missing
  tab retired xemp, missing
  drop xemp
	
	label var work "Working now"
	label var retired "Retired"

*---------------------------------------------------
*HEALTH INSURANCE LAST YEAR
/*
hlins1st: 
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
0 Inap.: not covered by health care plan; from Latino sample (ER30001=7001-9308); 
main family nonresponse by 2009 or mover-out nonresponse by 2007 (ER34001=0); 
moved out before 2007 (ER34002=71-89 and ER34010>0 and ER34010<2007) 
*/

*Any coverage
gen anyhi = 0 
replace anyhi = 1 if inrange(hlinsmo,1,12)
replace anyhi = . if inlist(hlinsmo,98,99) 
label var anyhi "any health insurance LCY"

gen anyhi_12mo = 0
replace anyhi_12mo = 1 if hlinsmo == 12
replace anyhi_12mo = . if inlist(hlinsmo,98,99)
label var anyhi_12mo "12 months of any health insurance LCY"


gen hipri = 0
gen himcr = 0
gen himcd = 0
gen himil = 0
gen hioth = 0

foreach x in hlins1st hlins2nd hlins3rd hlins4th {
	replace hipri = 1 if inlist(`x',1,2) & anyhi == 1
	replace himcr = 1 if inlist(`x',3,4) & anyhi == 1
	replace himcd = 1 if inlist(`x',5) & anyhi == 1
	replace himil = 1 if inlist(`x',6,7) & anyhi == 1
	replace hioth = 1 if inlist(`x',8,9,10,97) & anyhi == 1
}

foreach y in hipri himcr himcd himil hioth {
	foreach x in hlins1st hlins2nd hlins3rd hlins4th {
		replace `y' = . if `y' == 0 & inlist(`x',98,99)
	}
}


/* In 2011 they asked about both past and current health insurance.  Staring in 2013 they only report current insurance.  This will compare
those measures */

*Any coverage
gen curanyhi = 0 
replace curanyhi = 1 if curhlins == 1


gen curhipri = 0
gen curhimcr = 0
gen curhimcd = 0
gen curhimil = 0
gen curhioth = 0

* only three mentions for current health insurance
foreach x in curhlins1st curhlins2nd curhlins3rd {
	replace curhipri = 1 if inlist(`x',1,2) & curanyhi == 1
	replace curhimcr = 1 if inlist(`x',3,4) & curanyhi == 1
	replace curhimcd = 1 if inlist(`x',5) & curanyhi == 1
	replace curhimil = 1 if inlist(`x',6,7) & curanyhi == 1
	replace curhioth = 1 if inlist(`x',8,9,10,97) & curanyhi == 1
}

foreach y in curhipri curhimcr curhimcd curhimil curhioth {
	foreach x in curhlins1st curhlins2nd curhlins3rd {
		replace `y' = . if `y' == 0 & inlist(`x',98,99)
	}
}

label var hipri "private health insurance LCY"
label var himcr "Medicare/supplemental health insurance LCY"
label var himcd "Medicaid health insurance LCY"
label var himil "VA/CHAMPUS/TRICARE health insurance LCY"
label var hioth "other health insurance LCY"

label var curhipri "private health insurance currently"
label var curhimcr "Medicare/supplemental health insurance currently"
label var curhimcd "Medicaid health insurance currently"
label var curhimil "VA/CHAMPUS/TRICARE health insurance currently"
label var curhioth "other health insurance currently"

* Check how things compare for 2011 when both LCY and current were asked
tab hipri curhipri if year == 2011
tab himcr curhimcr if year == 2011
tab himcd curhimcd if year == 2011
tab himil curhimil if year == 2011
tab hioth curhioth if year == 2011

* It lines up pretty well, so we'll use current in place of LCY where we have to
foreach var in anyhi hipri himcr himcd himil hioth {
	replace `var' = cur`var' if inrange(year,2013,$lastyr)
}



/* Categorical variable for health insurance category.
Private
Medicare
Medicaid
Military
Other
Private & Medicare
Medicare & Medicaid
Other Multiple
*/

egen hisrc = rowtotal(hipri himcr himcd himil hioth)
tab hisrc, m

gen hlthinscat = .
* Uninsured
replace hlthinscat = 0 if anyhi == 0
* Single source of insurance
replace hlthinscat = 1 if hipri == 1 & hisrc == 1
replace hlthinscat = 2 if himcr == 1 & hisrc == 1
replace hlthinscat = 3 if himcd == 1 & hisrc == 1
replace hlthinscat = 4 if himil == 1 & hisrc == 1
replace hlthinscat = 5 if hioth == 1 & hisrc == 1
* Two sources of insurance - just looking at private/medicare and medicare/medicaid for now
replace hlthinscat = 6 if hipri == 1 & himcr == 1 & hisrc == 2
replace hlthinscat = 7 if himcr == 1 & himcd == 1 & hisrc == 2
replace hlthinscat = 8 if missing(hlthinscat) & hisrc >= 2 & !missing(hisrc)

label define hlthinscat 0 "Uninsured" 1 "Private HI only" 2 "Medicare only" 3 "Medicaid Only" 4 "Military HI only" 5 "Other HI only" 6 "Private HI and Medicare" 7 "Medicare and Medicaid" 8 "All other 2+"
label values hlthinscat hlthinscat
label var hlthinscat "Health Insurance source(s)"

gen inscat = .
replace inscat = 1 if anyhi == 0
replace inscat = 2 if hipri == 0 & anyhi == 1
replace inscat = 3 if hipri == 1 & anyhi == 1
label define inscat 1 "Uninsured" 2 "Public Ins only" 3 "Any Private Ins"
label values inscat inscat
label var inscat "Broad insurance categories: uninsured, public only, any private" 

/*
*Type of coverage
gen hiesi = 0
gen hiself = 0
gen himcare = 0
gen himgap = 0
gen himcaid = 0
gen hiothgov = 0

foreach x in hlins1st hlins2nd hlins3rd hlins4th {
	replace hiesi = 1 if inlist(`x',1)  & anyhi == 1
	replace hiself = 1 if inlist(`x',2) & anyhi == 1
	replace himcare = 1 if inlist(`x',3) & anyhi == 1
	replace himgap = 1 if inlist(`x',4) & anyhi == 1
	replace himcaid = 1	if inlist(`x',5) & anyhi == 1
	replace hiothgov = 1 if inrange(`x',6,10) & anyhi == 1
}

foreach x in hiesi hiself himcare himgap himcaid hiothgov {
	foreach x in hlins1st hlins2nd hlins3rd hlins4th {
		replace `x' = . if `x' == 0 & anyhi == 1 & inlist(`h',98,99)
	}
}

label var hiesi "Employer provided health insurance LCY"
label var hiself "Private health insurance purchased LCY"
label var himcare "Medicare LCY"
label var himgap "Medigap LCY"
label var himcaid "Medicaid LCY"
label var hioth "Other government health ins LCY"
*/

*---------------------------------------------------
*INCOME RELATED

*individual labor earnings (LCY = last calender year), including labor portion of business income
*market gardening was previously left as farm income out but is now left in head's labor income to match wife
	*gen iearn = max(0,earninggen-gardincgen) + laborbzgen if head == 1
	*replace iearn = earninggen + laborbzgen if wife == 1
	gen iearn = earninggen + laborbzgen
	label var iearn "earnings LCY"
	
	
	* Cap earnings and transform
	gen iearnx = min(iearn,200000)/1000
	gen logiearnx = ln(iearnx+sqrt(1+iearnx^2))/100
	label var iearnx "Earnings in 1000s capped at 200K"
	label var logiearnx "IHS of iearnx divided by 100"
	
*head(H)+wife(W) capital income = H+W taxable income -H+W labor earnings
	tempvar t
	bys famfid year: egen `t' = total(iearn)
	gen hicap = htaxincgen - `t' 
	label var hicap "H+W capital income LCY"
	gen hicap_nonzero = (hicap != 0) if hicap<.
	label var hicap_nonzero "capital income LCY not equal to zero"
	drop `t'
	
*SSI
	gen ssiclaim = ssigen > 0 if ssigen < .
	label var ssiclaim "any SSI LCY"
	ren ssigen ssiamt
	label var ssiamt "SSI amount LCY"
	
*ADC/TANF
	gen anyadc = adcgen > 0 if adcgen < . 
	label var anyadc "any ADC/TANF LCY"
	ren adcgen adcamt
	label var adcamt "ADC/TANF amount LCY"

*UNEMP+WORK COMP
	egen iunwc = rsum(unempgen wkcmpgen)
	label var iunwc "unemp comp+workers' comp amount LCY"
	
	gen unempamt = unempgen
	gen anyunemp = unempamt > 0 if !missing(unempamt)
	label var unempamt "unemployment benefit amount LCY"
	label var anyunemp "any unemployment benefit LCY"

*(Other)GOV TRANSER-VA benefits, food stamps, welfare other than SSI
*food stamps reported at the household level, split evenly if both husband and wife in the household
	bys famfid year: egen hsize = total(head==1|wife==1)
	tempvar t
	gen `t' = hfdstmpgen/hsize
	drop hsize
	
	ren vapengen vapenamt
	gen fdstmpamt = `t'
	ren welfgen welfamt
	
	gen anyfdstmp = fdstmpamt > 0 if !missing(fdstmpamt)
	label var anyfdstmp "any foodstamps LCY" 
	
  egen igxfr = rsum(vapenamt fdstmpamt welfamt adcamt)
	drop `t'
	label var vapenamt "VA benefits amount LCY"
	label var fdstmpamt "Foodstamps amount LCY"
	label var welfamt "Welfare amount LCY"
	label var igxfr "other gov transfers (VA benefits, foodstamps, welfare, ADC/TANF) amount LCY"
	gen igxfr_nonzero = (igxfr != 0) if igxfr<.
	label var igxfr_nonzero "other gov transfers LCY not equal to zero"
	
*Non-SS and non-VA Pension income

	egen ipena = rsum(othpengen annuigen retunkgen) if head == 1
	replace ipena = othretgen if wife == 1
	label var ipena "pension/annuity/IRA amount LCY"
	gen anyipena = ipena > 0 if ipena < . 
	label var anyipena "any pension/annuity/IRA LCY"
	
*Other private transfers
	egen pxframt = rsum(alimgen chdspgen hlprelgen hlpfrdgen othtrgen)
	label var pxframt "misc.private transfer amount LCY"
	gen anypxfr = pxframt > 0 if pxframt < .
	label var anypxfr "any misc.private transfer LCY"
	
*Other income - alimony, lump sum payments from insurance or inheritance

*---------------------------------------------------

* Cap hatota to 2 million, transform
	gen hatotax = min(hatota,2000000)/1000
	gen loghatotax = ln(hatotax+sqrt(1+hatotax^2))/100
	label var hatotax "Wealth in 1000s capped at 2 million"
	label var loghatotax "IHS of hatotax divided by 100"

	gen wlth_nonzero = hatota != 0 if hatota < .
	label var wlth_nonzero "Wealth not equal to zero"

*---------------------------------------------------
*Social security related
gen diclaim = socsectype == 1 if !inlist(socsectype,8,9)
*gen anyssoth = inrange(socsectype,3,7) if !inlist(socsectype,8,9)
gen oasiclaim = inrange(socsectype,2,7) if !inlist(socsectype,8,9)

* social security income variable at individual level, available since 2005 
gen ssdiamt = ssincgen if year >= 2005 & diclaim == 1
gen ssoasiamt = ssincgen if year >= 2005 & oasiclaim == 1
replace ssdiamt = 0 if diclaim == 0 & year >= 2005
replace ssoasiamt = 0 if oasiclaim == 0 & year >= 2005

label var diclaim "any socical security disability income LCY"

*label var anyssoth "any social security survivor or dep income LCY"
label var oasiclaim "any social security OASI income LCY"
label var ssdiamt "social security disability income LCY"
label var ssoasiamt "social security income LCY"

*---------------------------------------------------
*Pension related variables for current job

*Any DB pension for current job
gen anydb = anypen == 1 & inlist(pentp,1,3) if inlist(anypen,1,5)
*Any DC pension for current job
gen anydc = anypen == 1 & inlist(pentp,3,5) if inlist(anypen,1,5)
*Tenure for DB pension
gen db_tenure = cjten if inrange(cjten,1,65) & anydb == 1

*Full retirement age for DB pension for current job
*If based on age only
gen nage_db = nra1age if nrafml == 1 & inrange(nra1age,31,100) & anydb == 1
*If based on years of service only
replace nage_db = max(31,int(age) + (nra1yr - cjten)) if nrafml == 2 & inrange(nra1yr,1,50) & inrange(cjten,1,65) & anydb == 1
*If based on both years of service and age, choose the maximum
replace nage_db = max(nra2age, max(31,int(age) + (nra2yr - cjten)) ) if nrafml == 3  ///
		& inrange(nra2age,31,100) & anydb == 1 ///
		& inrange(nra2yr,1,50) & inrange(cjten,1,65)
		
* Early retirement age for DB pension for current job, if any
gen eage_db = era1age if erafml == 1 & inrange(era1age,31,100) & anydb == 1
*If based on years of service only
replace eage_db = max(31,int(age) + (era1yr - cjten)) if erafml == 2 & inrange(era1yr,1,50) & inrange(cjten,1,65) & anydb == 1
*If based on both years of service and age, choose the maximum
replace eage_db = max(era2age, max(31,int(age) + (era2yr - cjten)) ) if erafml == 3  ///
		& inrange(era2age,31,100) & anydb == 1 ///
		& inrange(era2yr,1,50) & inrange(cjten,1,65)

*Coordinate normal/early retirement age for DB pension
replace eage_db = nage_db if (eage_db > nage_db | missing(nage_db)) & !missing(nage_db)

label var anydb "Any DB pension for current job"
label var anydc "Any DC pension for current job"
label var db_tenure "Tenure for current job with DB pension"
label var nage_db "Normal retire age for DB current job"
label var eage_db "Early retire age for DB current job"


*VARIABLES TO KEEP
/****
#d;
keep hhidpn year 
iearn hicap ssiclaim ssiamt anyadc anyunwc unwcamt gxframt anygxfr ipena anyipena pxframt anypxfr
work retired 
hipri himcr himcd himil hioth anyhi
hatota diclaim 
anydb anydc db_tenure nage_db eage_db
iearnx logiearnx hatotax loghatotax
vapenamt fdstmpamt welfamt adcamt igxfr anyfdstmp unempamt anyunemp
;
#d cr
****/

save "$outdata/psid_econ.dta", replace
sum



