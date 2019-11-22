/** \file
Generate alternative BMI measure for initial conditions – to use in transition models.
Steps: 1 - Bring in data with all waves for all individuals selected (from hrs_analytic_recoded.dta)
	2 - Compute BMI deciles for individuals with no BMI measure at age 50-55 in two steps 
		* looking at same wave, 5 years age range, gender and race
		* if not enough individuals, look at same wave, 9 years age range and gender
	3 - Add average BMI for each decile and cohort (birth cohort/gender/race) generated using NHANES survey
	4 - Define intial values of BMI for individuals with observed BMI at age 55 or earlier and estimated values

*/

include common.do

* seed for hotdecking
local seed 45418

******************************************************************************************************************
**** 1 - Identify individuals used to estimate transition models
******************************************************************************************************************
**** Bring in data with all waves for all individuals. Processed file with selected original and derived variables

use hhidpn r*wtresp r*bmi r*iwstat rabyear rabmonth rahispan ragender raracem using "$rand_hrs", clear

**************************************************************************
**** rename variables as done in hrs_select.do - if later the recoding done in "hrs_select.do" is move to the "recode.do" file this
**** portion of the program can be dropped

generate male = 0*ragender
replace  male = 1 if ragender == 1
drop ragender
rename rahispan hispan

generate black = 0*raracem
replace black = 1 if raracem == 2 & hispan == 0
label var black "Non-hispanic black"

gen white = 0*raracem
replace white = 1 if black==0 & hispan==0 & white ==0 /* Recode to include others under white variable - drop at the end of the program*/
drop raracem

reshape long r@wtresp r@bmi r@iwstat, i(hhidpn) j(wave)
rename r* *
ren wtresp weight

* Year of birth
gen rbyr = abyear

* Year
gen year = (wave - 1) * 2 + 1992
gen age_yrs = int((wave-1)*2 + 1992 - abyear + (7-abmonth)/12)
drop abyear
label var age_yrs "Age in years at July 1st"

**************************************************************************

  gen race = 1 if black==0 & hispan==0
replace race = 2 if black == 1
replace race = 3 if hispan==1
label var race "1=white/other 2=black 3=hispanic"


drop if iwstat != 1 | bmi >=./* Drop non-responses (bmi missing) */
sum bmi
tempfile sample
preserve
keep hhidpn
duplicates drop
sort hhidpn
sav "`sample'"
restore

tempfile hrs_sel

sort hhidpn wave
by hhidpn (wave): gen first_wave=wave[1]

gen fow_age = age_yrs
label var fow_age "Age at first observed interview"

sort wave male race
sum age,detail
gen older55 = age >55

tab wave older55 if first_wave==wave,missing
sum older55 if first_wave==wave

save `hrs_sel'


***********************************************************************************************************************
**** 2. Compute BMI deciles for individuals with no BMI measure at age 50-55
***********************************************************************************************************************

sort wave male race fow_age
keep if wave==first_wave

keep wave male race fow_age
duplicates drop
gen grp = _n
local grpN = _N

local loopcnt = 0

forvalues i=1/`grpN'{
	preserve
	keep if grp == `i'
	dis "Round: `i'"
	list	
	merge 1:m wave male race using `hrs_sel', keepusing(hhidpn wave first_wave older55 male race white black hispan bmi weight rbyr age_yrs)
	keep if _merge==3
	drop _merge
	keep if age_yrs >= fow_age-2 & age_yrs <= fow_age+2
	gen fow_bmi = bmi if age_yrs == fow_age & wave==first_wave
	count if weight>0
	local numb = r(N)
	gen grcnt=`numb'
	if `numb' < 20 {
		display "Not enough observations"
		keep if age_yrs == fow_age & wave==first_wave
		keep hhidpn male race white black hispan rbyr fow_age fow_bmi bmi older55 wave grcnt
		if `i'==1 save "$outdata/HRS_bmi_deciles.dta", replace
		else {
			append using "$outdata/HRS_bmi_deciles.dta"
			save "$outdata/HRS_bmi_deciles.dta",replace
		}
		restore
		continue
	}
	_pctile bmi [w=weight],nquantiles(10)
	gen bmi_dec= cond(bmi<=r(r1),1,cond(bmi<=r(r2),2,cond(bmi<=r(r3),3,cond(bmi<=r(r4),4,cond(bmi<=r(r5),5,cond(bmi<=r(r6),6,cond(bmi<=r(r7),7,cond(bmi<=r(r8),8,cond(bmi<=r(r9),9,10)))))))))
	keep if age_yrs == fow_age & wave==first_wave
	keep hhidpn male race white black hispan rbyr bmi_dec fow_age fow_bmi bmi older55 wave grcnt 
	if `i'==1 save "$outdata/HRS_bmi_deciles.dta", replace
	else {
		append using "$outdata/HRS_bmi_deciles.dta"
		save "$outdata/HRS_bmi_deciles.dta",replace
	}
	display "Deciles Estimated"
	restore
}

** compute deciles using only age and gender, and make age group larger (9 yrs)
sort wave male
keep wave male fow_age
duplicates drop
gen grp = _n
local grpN = _N
tempfile bmidec_gender

local loopcnt = 0

forvalues i=1/`grpN'{	
	preserve
	keep if grp == `i'
	dis "Round: `i'"
	list	
	merge 1:m wave male using `hrs_sel', keepusing(hhidpn wave first_wave male bmi weight age_yrs)
	keep if _merge==3
	drop _merge
	keep if age_yrs >= fow_age-4 & age_yrs <= fow_age+4
	count if weight>0
	local numb = r(N)
	if `numb' < 20 {
		display "Not enough observations"
		restore
		continue
	}
	local loopcnt=`loopcnt'+1
	count
	_pctile bmi [w=weight],nquantiles(10)
	gen bmi_dec_gender= cond(bmi<=r(r1),1,cond(bmi<=r(r2),2,cond(bmi<=r(r3),3,cond(bmi<=r(r4),4,cond(bmi<=r(r5),5,cond(bmi<=r(r6),6,cond(bmi<=r(r7),7,cond(bmi<=r(r8),8,cond(bmi<=r(r9),9,10)))))))))
	keep if age_yrs == fow_age & wave==first_wave
	gen fow_bmi = bmi
	keep hhidpn bmi_dec_gender
	if `loopcnt'==1 save `bmidec_gender', replace
	else {
		append using `bmidec_gender'
		save `bmidec_gender',replace
	}
	display "Deciles Estimated"
	restore
}

use `bmidec_gender',clear
sort hhidpn
save `bmidec_gender',replace

use "$outdata/HRS_bmi_deciles.dta",clear
sort hhidpn
merge 1:1 hhidpn using `bmidec_gender'
drop _merge
save "$outdata/HRS_bmi_deciles.dta", replace

**********************************************************************************************************************
**** 3 - Add average BMI for each decile and cohort (birth cohort/gender/race) generated using NHANES survey
**********************************************************************************************************************

merge 1:1 hhidpn using "`sample'"
drop _merge

gen cohort =  "nhanes1972" if rbyr <= 1922
replace cohort = "nhanes1976" if rbyr > 1922 & rbyr <= 1930
replace cohort = "nhanes1988" if rbyr > 1930 & rbyr <= 1938
gen cohort_88 = "Phase 1" if rbyr > 1930 & rbyr <= 1938
replace cohort = "nhanes1988" if rbyr > 1938 & rbyr <= 1944
replace cohort_88 = "Phase 2" if rbyr > 1938 & rbyr <= 1944
replace cohort = "nhanes1999" if rbyr > 1944 & rbyr <= 1946
replace cohort = "nhanes2001" if rbyr > 1946 & rbyr <= 1948
replace cohort = "nhanes2003" if rbyr > 1948 & rbyr <= 1950
replace cohort = "nhanes2005" if rbyr > 1950 & rbyr <= 1952
replace cohort = "nhanes2007" if rbyr > 1952 & rbyr <= 1954
replace cohort = "nhanes2009" if rbyr > 1954 

sort cohort cohort_88 male black hispan white bmi_dec

preserve
tempfile genrace
use "$outdata/NHANES_bmi_cohort_qtls.dta",clear
drop if black==. & hispan==. & white==.
sort cohort cohort_88 male black hispan white bmi_dec 
save `genrace'
restore

merge m:1 cohort cohort_88 male black hispan white bmi_dec using `genrace'
drop if _merge ==2
drop _merge

gen fbmi50 = bmi if older55!=1
replace fbmi50 = bmi_avg if older55==1
gen fbmi50_imp=1 if older55==1 & fbmi50 !=.
replace fbmi50_imp=0 if older55!=1
label var fbmi50_imp "Indicator of estimated initial bmi variable fbmi50"

gen bmidiff = bmi-bmi_avg
sum bmidiff if fow_age<=55 & fow_age>=50 & older55!=1 ,detail
local srcorr=r(mean) /* Correction to estimated BMI from NHANES based on measured BMI vs self reported BMI from HRS */

keep hhidpn fbmi50_imp rbyr male race fow_bmi fow_age fbmi50 cohort cohort_88 wave bmi_dec bmi_dec_gender
label var fow_bmi "First Observed Wave BMI"
label var rbyr "Respondent birth year"

**************** Use distribution by gender only to fill missing fbmi50
preserve
tempfile gender
use "$outdata/NHANES_bmi_cohort_qtls.dta",clear
keep if black==. & hispan==. & white==.
keep  cohort cohort_88 male bmi_dec bmi_avg
rename bmi_dec bmi_dec_gender
sort cohort cohort_88 male bmi_dec_gender
save `gender'
restore

sort cohort cohort_88 male bmi_dec_gender
merge m:1 cohort cohort_88 male bmi_dec_gender using `gender'
drop if _merge ==2

replace fbmi50_imp=1 if fbmi50==. & bmi_avg !=.
replace fbmi50 = bmi_avg if fbmi50==.

replace fbmi50=fbmi50+`srcorr' if fbmi50_imp==1

drop bmi_avg _merge

tab fow_age fbmi50_imp,missing
tab race fbmi50_imp,missing
tab male fbmi50_imp,missing
tab wave fbmi50_imp,missing

sort hhidpn male race rbyr 

********** There are still missing values - use hotdeck method
gen fbmi50_imphd = fbmi50==.
replace fbmi50_imp=1 if fbmi50_imphd==1 & fbmi50==.
sort male cohort cohort_88
replace cohort_88="n/a" if cohort_88==""
hotdeck fbmi50, by(male cohort cohort_88) keep(hhidpn) store seed(`seed')
drop fbmi50
merge 1:1 hhidpn using imp1.dta
drop _merge
rm imp1.dta

label var fbmi50 "BMI level at age 50 (1/0)-imputed"
label var fbmi50_imphd "Flag of BMI level at age 50 imputed w/hotdeck method by gender and cohort" 

bys fbmi50_imphd:sum fbmi50 

save "$outdata/BMI_initial_values.dta", replace

**********************************************************************************************************
desc


