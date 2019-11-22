
***=========================================
* SELECT DATA FOR COST ESTIMATION
* Yuhui Zheng, Nov 3nd, 2005
* updated: Dec 12, 2005: add underweight, 
* rename costs variables, add age spline
* change directories
* Oct 22, 2006, add 2003 data, revise interactions of disease and ADLs
* Nov 8,  2006, add variables for doctor visits, hospital stay, hospital days
* Doctor visits identified using survey data; hospital stay uses both survey & claims
* Hospital nights only available from claims data
* March 2007: add lead variables
* Sep 2008: keep detailed ADL variables, recode ADL indicators
* Oct 2008: use year 2003-2005, recode payments for Medicare HMO respondents
* June 2008: Use a crosswalk stored in a stata dataset and read into a matrix for the medical cpi
* June 2008: Add indicator, diclaim, that the person has medicare because of disability
* Sept 2009: Use ageexact + .5 = age instead of the age in the MCBS dataset because we want age as of July 1st, and we want it exact
* July 2014: Use 2000-2010 data
***=========================================

*** MCBS
*** Total medical expenditures: PAMTTOT
*** Out of pocket expenditures: PAMTOOP
*** Age:AGE
*** Mar 26, 2006: annual CPI in 2005 (not just the first 9 months)
*** Marital status

clear
* Clear anything thats already in memory
clear all
cap clear mata
cap clear programs
cap clear ado
discard
est clear
set more off
set mem 500m
capture log close



* Assume that this script is being executed in the FEM_Stata/Makedata/MCBS directory

* Load environment variables from the root FEM directory, three levels up
* these define important paths, specific to the user
include "../../../fem_env.do"

* Define paths
global workdir  			"$local_path/Makedata/MCBS"

adopath + "$local_path/Makedata/MCBS"


**** Store the medical cpi into a matrix cross walk
*use "$indata/medcpi_cxw.dta"
insheet using $fred_dir/CPIMEDSL.csv, clear
gen year = substr(date,5,4)
destring year, replace
ren value medcpi
keep year medcpi
mkmat medcpi, matrix(medcpi) rownames(year)

* Use the file covering 1992-2012
use "$mcbs_dir/mcbs9212.dta", clear

keep if inrange(year,2000,2012)
egen id = group(baseid)

***Adjust costs by CPI
***Costs-Medicaid, Medicare, total
gen totmd_mcbs = .
gen oopmd_mcbs = .
gen mcare = .
gen mcare_pta = .
gen mcare_ptb = .
gen caidmd_mcbs  = .

label var totmd_mcbs "total medical costs"
label var oopmd_mcbs "out of pocket costs"
label var mcare  "total medicare costs"
label var mcare_pta  "medicare pt a costs, if not in ghp"
label var mcare_ptb  "medicare pt b costs, if not in ghp"
label var caidmd_mcbs "total medicaid costs"

***Use Medicare capitation payments for MCO patients
	gen cap_pay = 0
	foreach i in 01 02 03 04 05 06 07 08 09 10 11 12 {
		replace cap_pay = cap_pay + h_plpy`i' if h_plpy`i' < .
	}
	
	sum cap_pay if h_ghpsw == "1" [aw = cweight]
	replace pamtcare = cap_pay if h_ghpsw == "1"
	
*** Replace total
egen newtot  = rowtotal(pamtcaid pamtcare pamtdisc pamthmom pamthmop pamtoop pamtoth pamtprve pamtprvi pamtprvu pamtva)
replace pamttot = newtot if h_ghpsw == "1"
drop newtot


***MEDICAL CPI AJDUSTED COSTS
 sort year
 forvalues i = 1992(1)2012{
	replace totmd_mcbs = pamttot     * medcpi[rownumb(medcpi,"2004"), 1]/medcpi[rownumb(medcpi,"`i'"), 1] if year == `i'
	replace oopmd_mcbs = pamtoop     * medcpi[rownumb(medcpi,"2004"), 1]/medcpi[rownumb(medcpi,"`i'"), 1] if year == `i'
	replace mcare = pamtcare   * medcpi[rownumb(medcpi,"2004"), 1]/medcpi[rownumb(medcpi,"`i'"), 1] if year == `i'
	replace mcare_pta = h_ptarmb  * medcpi[rownumb(medcpi,"2004"), 1]/medcpi[rownumb(medcpi,"`i'"), 1] if year == `i'	 & h_ghpsw == "0"
	replace mcare_ptb = h_ptbrmb  * medcpi[rownumb(medcpi,"2004"), 1]/medcpi[rownumb(medcpi,"`i'"), 1] if year == `i'	 & h_ghpsw == "0"
  replace caidmd_mcbs = pamtcaid * medcpi[rownumb(medcpi,"2004"), 1]/medcpi[rownumb(medcpi,"`i'"), 1] if year == `i'
	}
	
*** Check spending by insurance status
tabstat totmd_mcbs mcare caidmd_mcbs oopmd_mcbs mcare_pta mcare_ptb [w=cweight], by(h_ghpsw)


*** Recode age
replace age = ageexact + .5
label var age "exact age on July 1st"

***MAKE AGE SPLINE

mkspline agesp74 74 agesp84 84 agesp85p = age
label var agesp74 "age spline: aged 65-74"
label var agesp84 "age spline: aged 75-84"
label var agesp85p "age spline: aged 85 and over"

***MAKE AGE DUMMIES

foreach var in age2534 age3544 age4554 age5054 age5559 age5564 age6064 age6569 age7074 age7579 age8084 age6574 age7584 age85 {
       gen `var' = 0*age
       }
       
* More age variables
replace age2534 = 1 if inrange(floor(age), 25, 34)
replace age3544 = 1 if inrange(floor(age), 35, 44)
replace age4554 = 1 if inrange(floor(age), 45, 54)
replace age5564 = 1 if inrange(floor(age), 55, 64)
replace age5054 = 1 if inrange(floor(age), 50, 54)
label var age5054 "Age 50 to 54"
replace age5559 = 1 if inrange(floor(age), 55, 59)
label var age5559 "Age 55 to 59"
replace age6064 = 1 if inrange(floor(age), 60, 64)
label var age6064 "Age 60 to 64"
replace age6569 = 1 if inrange(floor(age), 65, 69)
label var age6569 "Age 65 to 69"
replace age7074 = 1 if inrange(floor(age), 70, 74)
label var age7074 "Age 70 to 74"
replace age7579 = 1 if inrange(floor(age), 75, 79)
label var age7579 "Age 75 to 79"
replace age8084 = 1 if inrange(floor(age), 80, 84)
label var age8084 "Age 80 to 84"
replace age6574 = 1 if inrange(floor(age),65,74)
label var age7584 "Age 65 to 74"
replace age7584 = 1 if inrange(floor(age),75,84)
label var age7584 "Age 75 to 84"
replace age85 = 1 if floor(age) > 84
label var age85 "Age > 84"

tab race
gen regnth = region == 1
gen regmid = region == 2
gen regwst = region == 4
gen regsth = region == 5 | region == 3

***RENAME VARIABLES AS IN FEDERICO'S FILE
ren hispanic hispan
ren cancer cancre
ren diabet diabe
ren hbp hibpe
ren heart hearte
ren lung lunge
ren eversmok smokev
ren smokenow smoken
drop nurshome nrsliv
gen nrshom = type == "F" if type != ""
label var nrshom "Living in nursing home"
ren hsdrop hsless

* Recode marital status
recode spmarsta ( -9 -8 -7 = .) (1 = 1 "1.married") ( 2 = 2 "2.widowed") ( 3 4 5 = 3 "3.single"), gen(rmstat)

capture drop married
cap drop widowed
gen married = rmstat == 1 if rmstat < .
gen widowed = rmstat == 2 if rmstat < .
gen single  = rmstat == 3 if rmstat < .

*local iadlvars prbtele prblhwk prbmeal prbshop prbbils
*recode `iadlvars' (1=1) (2 3=0) (nonmissing=.)
gen  adl_ct2 = bathing + dressing + eating + bedchair + walking + toilet
*egen iadl_ct2 = rowtotal(`iadlvars')
* IADL variables have been replaced with formatted variables similar to what was done with ADLs
gen iadl_ct2 = telephone + meals + lhousework + hhousework + shopping + bills

gen iadl1 = iadl_ct2 == 1 if iadl_ct2 < .
gen iadl2p = iadl_ct2 >= 2 if iadl_ct2 < .
gen adl1 = adl_ct2 == 1 if adl_ct2 < .
gen adl2 = adl_ct2 == 2 if adl_ct2 < .
gen adl3p = adl_ct2 >= 3 if adl_ct2 < .

* If in nursing home, don't count ADLs
foreach v in iadl1 iadl2p adl1 adl2 adl3p {
	replace `v' = 0 if nrshom == 1
}

xtset id year
foreach var in cancre diabe hibpe  hearte lunge stroke alzhmr myocar {
	foreach q in adl1 adl2 adl3p nrshom {
		capture gen `var'_`q' = `var' * `q'
		}
        gen l`var' = l.`var'
        replace l`var' = 0 if !`var'
	}

* ONLY with other heart problems
gen othartonly = hearte == 1 & chd == 0 & myocar == 0 if hearte < .

* Utilization variables; 
gen doctim = sv_drevnts 
gen hsptim = ipaevnts
gen hspnit = hdays

*********************
* Prepare data for hazard analysis
*********************
sort baseid year, stable
foreach var in cancre diabe hearte hibpe lunge stroke ///
	smoken smokev died nrshom {
		gen f`var' = `var'[_n+1] if (year[_n+1]-year == 1) 
		replace f`var' = . if `var' == 1
		label var f`var' "1 yr lead var of `var'"
		gen f2`var' = `var'[_n+2] if (year[_n+2]-year == 2) 
		replace f2`var' = . if `var' == 1		
		label var f2`var' "2-yr lead var of `var'"
}

/* Rename the Medicaid eligibility variable to be more obvious */
  rename mcaid medicaid_elig

/* MCBS income is total income, not earned income as we usually use, so we need to rename it */
  rename income gross

/* Indicator for being disablied eligable for medicare */
gen diclaim = inrange(h_medsta,20,21)

keep baseid cweight year pamttot pamtoop pamtcare pamtip pamthp totmd_mcbs oopmd_mcbs mcare mcare_pta mcare_ptb ///
	amcarehh amcareip amcareiu amcarefa amcarehp amcaredu amcaremp amcareop amcarepm ///
	age educ region male black hispan hsless somecol college collgrad ///
	regnth regmid regwst regsth ///
	cancre diabe hibpe hearte lunge stroke overwt obese smokev alzhmr myocar ///
	cancre_adl1 cancre_adl2 diabe_adl1 diabe_adl2 hearte_adl1 hearte_adl2 hibpe_adl1 hibpe_adl2 lunge_adl1 lunge_adl2 stroke_adl1 stroke_adl2 alzhmr_adl1 alzhmr_adl2 myocar_adl1 myocar_adl2  ///
	cancre_adl3p diabe_adl3p hearte_adl3p hibpe_adl3p lunge_adl3p stroke_adl3p alzhmr_adl3p myocar_adl3p ///
	cancre_nrshom diabe_nrshom hearte_nrshom hibpe_nrshom lunge_nrshom stroke_nrshom alzhmr_nrshom myocar_nrshom ///
	agesp74 agesp84 agesp85p age7584 age85 adl_ct adl_ct2 iadl_ct2 iadl1 iadl2p died adl1 adl2 adl3p underwt nrshom smoken smokev ///
	collgrad othart chd myocar othartonly ///
	married widowed single rmstat d_hmo d_care bmi age5054 age5559 age6064 age6569 age7074 age7579 age8084 age85 ///
	doctim hsptim hspnit h_ghpsw pamtcare caidmd_mcbs ///
	fcancre fdiabe fhearte fhibpe flunge fstroke ///
        lcancre ldiabe lhearte lhibpe llunge lstroke lalzhmr lmyocar ///
	fsmoken fsmokev fdied fnrshom bathing dressing eating bedchair walking toilet ///
	diclaim h_ghpsw ///
        medicaid_elig gross ///
        age2534 age3544 age4554 age5564 ///
  sudstrat sudunit
	
ren cweight weight
ren alzhmr alzhe
ren lalzhmr lalzhe

ren myocar heartae
ren lmyocar lheartae

* Label variables
label var male "Male"
label var black "Black"
label var hispan "Hispanic"

label var hsless "Less than high school"
label var college "Some college and above"
label var somecol "Some college"
label var collgrad "College graduate"

label var smoken "Current smoking"
label var smokev "Ever smoked"

label var obese "Obese(bmi>=30)"
label var overwt "Overweight(25<=bmi<30)"
label var underwt "Underweight(bmi<18.5)"

label var iadl1 "IADL 1-Not in nursing home"
label var iadl2p "IADL 2+-Not in nursing home"
label var adl1 "ADL 1-Not in nursing home "
label var adl1 "ADL 2-Not in nursing home "
label var adl3 "ADL 3+-Not in nursing home"
label var died   "Died"

label var cancre "Cancer"
label var diabe  "Diabetes"
label var hearte "Heart disease"
label var hibpe "Hypertension"
label var lunge "Lung disease"
label var stroke "Stroke"
label var heartae "Heart attack"

label var cancre_adl1 "Cancer * ADL 1"
label var diabe_adl1  "Diabetes * ADL 1"
label var hearte_adl1 "Heart disease * ADL 1"
label var hibpe_adl1  "Hypertension * ADL 1"
label var lunge_adl1  "Lung disease * ADL 1"
label var stroke_adl1  "Stroke * ADL 1"

label var cancre_adl2 "Cancer * ADL 2"
label var diabe_adl2  "Diabetes * ADL 2"
label var hearte_adl2 "Heart disease * ADL 2"
label var hibpe_adl2  "Hypertension * ADL 2"
label var lunge_adl2  "Lung disease * ADL 2"
label var stroke_adl2  "Stroke * ADL 2"

label var cancre_adl3 "Cancer * ADL 3+"
label var diabe_adl3  "Diabetes * ADL 3+"
label var hearte_adl3 "Heart disease * ADL 3+"
label var hibpe_adl3  "Hypertension * ADL 3+"
label var lunge_adl3  "Lung disease * ADL 3+"
label var stroke_adl3  "Stroke * ADL 3+"

label var cancre_nrshom "Cancer * NURSING HOME"
label var diabe_nrshom  "Diabetes * NURSING HOME"
label var hearte_nrshom "Heart disease * NURSING HOME"
label var hibpe_nrshom  "Hypertension * NURSING HOME"
label var lunge_nrshom  "Lung disease * NURSING HOME"
label var stroke_nrshom  "Stroke * NURSING HOME"

label var regnth "Census reg-North"
label var regmid "Census reg-Midwest"
label var regsth "Census reg-South or Other"
label var regwst "Census reg-West"

label var diclaim "Eligable for Medicare due to disablity"

label var gross "Individual Gross Income"

* merge on bootstrap weights
merge m:1 sudstrat sudunit using "$dua_mcbs_dir/mcbs_bootstrap_weights.dta"
drop if _m==2
drop _m

label data "MCBS 2000-2012, for cost estimation and hazard analysis, all ages"
save "$dua_mcbs_dir/mcbs_cost_est.dta", replace

exit, STATA
