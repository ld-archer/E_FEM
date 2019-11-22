/* This program will generate historic trends in:
	hypertension
	elevated cholesterol
	HBA1C 
	
	using NHANES 2, NHANES 3, and NHANES (1999-2000, 2001-2002, 2003-2004, 2005-2006, 2007-2008, 2009-2010).
	

*** Blood Pressure ***
Normal blood pressure. Your blood pressure is normal if it's below 120/80 mm Hg. However, some doctors recommend 115/75 mm Hg as a better goal. Once blood pressure rises above 115/75 mm Hg, the risk of cardiovascular disease begins to increase.
Prehypertension. Prehypertension is a systolic pressure ranging from 120 to 139 mm Hg or a diastolic pressure ranging from 80 to 89 mm Hg. Prehypertension tends to get worse over time.
Stage 1 hypertension. Stage 1 hypertension is a systolic pressure ranging from 140 to 159 mm Hg or a diastolic pressure ranging from 90 to 99 mm Hg.
Stage 2 hypertension. More severe hypertension, stage 2 hypertension is a systolic pressure of 160 mm Hg or higher or a diastolic pressure of 100 mm Hg or higher.
	
*** HbA1C ***
Diabetes - 6.5 or greater 
Prediabetes - 5.7 to 6.4
Normal - About 5.0

*** Fasting Plasma Glucose (mg/dL)
Diabetes - 126 or above 
Prediabetes - 100 to 125
Normal - 99 or below

*** Oral Glucose Tolerance Test (mg/dL)
Diabetes - 200 or above 
Prediabetes - 140 to 199
Normal - 139 or below
		
*** Total Cholesterol *** 
Less than 200 mg/dL -	Desirable
200–239 mg/dL	- Borderline high
240 mg/dL and higher - High

*** LDL Cholesterol ***
Less than 100 mg/dL -	Optimal
100–129 mg/dL -	Near optimal/above optimal
130–159 mg/dL -	Borderline high
160–189 mg/dL -	High
190 mg/dL and higher -	Very high

*** HDL Cholesterol ***
Less than 40 mg/dL -	A major risk factor for heart disease
40–59 mg/dL -	The higher, the better
60 mg/dL and higher -	Considered protective against heart disease
	
*/
	
clear
clear mata
set more off
set seed 5243212
set maxvar 10000

* Assume that this script is being executed in the FEM_Stata/Makedata/NHANES directory

* Load environment variables from the root FEM directory, three levels up
* these define important paths, specific to the user
quietly include "../../../fem_env.do" 



/* NHANES 2 1976-1980 

Variables of interest:

From Physician's Exam (d_5302) file:
N2PE0411 - systolic blood pressure (seated, at beginning of exam)
N2PE0414 - diastolic blood pressure (seated, at beginning of exam)

From Hematology and Biochemistry (d_5411) file:
N2LB0421 - Serum cholesterol 
N2LB0434  - HDL cholesterol 
N2LB0438 - Strata for variance computation

N2LB0294 GLUCOSE TOLERANCE TEST FINAL EXAMINED WEIGHT
N2LB0466 FASTING PLASMA GLUCOSE
N2LB0469 ONE-HOUR PLASMA GLUCOSE
N2LB0472 TWO-HOUR PLASMA GLUCOSE
N2LB0516 glucose (0 = negative, 1 = light+, 2 = medium++, 3 = dark+++, 4 = very dark ++++, 5 = trace, 8 = blank but applicable, 9 = not applicable)
*/





/* NHANES 3
From examination file (exam)
PEPMNK1R - overall average k1, systolic
PEPMNK5R - overall average k5, diastolic
WTPFEX1 - sampling weight first wave
WTPFEX2 - sampling weight second wave

age (months at exam) - mxpaxtmr

From laboratory file (lab)

ghp - glycated hemoglobin (HbA1c)
tcp   Serum cholesterol (mg/dL)    [PREFERRED MEASURE]
tcpsi Serum cholesterol:  SI (mmol/L)    
lcp   Serum LDL cholesterol (mg/dL)      
lcpsi Serum LDL cholesterol:  SI (mmol/L)
hdp   Serum HDL cholesterol (mg/dL)      
hdpsi Serum HDL cholesterol:  SI (mmol/L)
chp   Serum cholesterol (mg/dL)          
chpsi Serum cholesterol:  SI (mmol/L)    
*/

tempfile nhanes3
use $nhanes_dir/stata/nhanes3/exam.dta, replace
keep seqn bmpbmi PEPMNK1R PEPMNK5R WTPFEX1 WTPFEX2 mxpaxtmr

rename PEPMNK1R systolic 
rename PEPMNK5R diastolic

save `nhanes3', replace

use $nhanes_dir/stata/nhanes3/adult.dta, replace
keep seqn HAE2 HAD1 HAE7

* doctor ever told hypertension
gen hibpe = .
replace hibpe = 1 if HAE2 == 1
replace hibpe = 0 if HAE2 == 2

* doctor ever told diabetes
gen diabe = .
replace diabe = 1 if HAD1 == 1
replace diabe = 0 if HAD1 == 2

* doctor ever told cholesterol high
gen chole = .
replace chole = 1 if HAE7 == 1
replace chole = 0 if HAE7 == 2

merge 1:1 seqn using `nhanes3'
drop _merge
save `nhanes3', replace

use $nhanes_dir/stata/nhanes3/lab.dta, replace
keep seqn ghp tcp tcpsi lcp lcpsi hdp hdpsi chp chpsi

rename tcp serum_chol
rename hdp hdl_chol
rename ghp hba1c

merge 1:1 seqn using `nhanes3'
gen str cohort = "nhanes3"

* normalize weights as if two samples
qui sum WTPFEX1
gen weight_norm = WTPFEX1/r(sum) if WTPFEX1 < .
qui sum WTPFEX2
replace weight_norm = WTPFEX2/r(sum) if WTPFEX2 < .

* Derive diagnoses
gen meas_hibp = .
replace meas_hibp = 1 if (systolic >= 140 & systolic < 888 & diastolic > = 90 & diastolic < 888)
replace meas_hibp = 0 if (systolic < 140 | diastolic < 90)
gen hypertension = .
replace hypertension = 1 if (hibpe == 1 | meas_hibp == 1)
replace hypertension = 1 if (hibpe == 1 & missing(meas_hibp))
replace hypertension = 1 if (missing(hibpe) & meas_hibp == 1)
replace hypertension = 0 if (hibpe == 0 & meas_hibp == 0)
replace hypertension = 0 if (hibpe == 0 & missing(meas_hibp))
replace hypertension = 0 if (missing(hibpe) & meas_hibp == 0)

gen meas_diab = .
replace meas_diab = 1 if hba1c >= 6.5 & hba1c < 8888
replace meas_diab = 0 if hba1c < 6.5
gen diabetes = .
replace diabetes = 1 if (diabe == 1 | meas_diab == 1)
replace diabetes = 1 if (diabe == 1 & missing(meas_diab))
replace diabetes = 1 if (missing(diabe) & meas_diab == 1)
replace diabetes = 0 if (diabe == 0 & meas_diab == 0)
replace diabetes = 0 if (diabe == 0 & missing(meas_diab))
replace diabetes = 0 if (missing(diabe) & meas_diab == 0)

gen meas_chol = .
replace meas_chol = 1 if serum_chol >= 240 & serum_chol < 888
replace meas_chol = 0 if serum_chol < 240
gen cholesterol = .
replace cholesterol = 1 if (chole == 1 | meas_chol == 1)
replace cholesterol = 1 if (chole == 1 & missing(meas_chol))
replace cholesterol = 1 if (missing(chole) & meas_chol == 1)
replace cholesterol = 0 if (chole == 0 & meas_chol == 0)
replace cholesterol = 0 if (chole == 0 & missing(meas_chol))
replace cholesterol = 0 if (missing(chole) & meas_chol == 0)

gen age = mxpaxtmr/12 if mxpaxtmr < .

* Set year at midpoint of exam
gen year = 1989.5 if WTPFEX1 < .
replace year = 1992.5 if WTPFEX2 < .


keep age hypertension diabetes cholesterol year cohort weight_norm hibpe chole diabe meas_hibp meas_chol meas_diab

save `nhanes3', replace






/* NHANES 1999-2010 

BPXSY1 through BPXSY4 - systolic - bpx
BPXDI1 through BPXDI4 - diastolic - bpx

lbxtc - Total cholesterol - lab13
lbxgh - glycohemoglogin (HbA1c) - lab10

*/
tempfile nhanes99
use $nhanes_dir/stata/1999-2000/demo.dta 
keep seqn riagendr ridageyr ridageex ridreth1 dmdeduc2 ridexprg wtint2yr wtmec2yr sdmvpsu sdmvstra


merge 1:1 seqn using $nhanes_dir/stata/1999-2000/bpx 
drop _merge
egen systolic = rowmean(BPXSY1 BPXSY2 BPXSY3 BPXSY4)
egen diastolic = rowmean(BPXDI1 BPXDI2 BPXDI3 BPXDI4)

merge 1:1 seqn using $nhanes_dir/stata/1999-2000/lab13 
drop _merge 
rename lbxtc serum_chol

merge 1:1 seqn using $nhanes_dir/stata/1999-2000/lab10
drop _merge
rename lbxgh hba1c

* Hypertension/cholesterol questionnaire
merge 1:1 seqn using $nhanes_dir/stata/1999-2000/bpq
drop _merge 
gen hibpe = .
replace hibpe = 1 if BPQ020 == 1
replace hibpe = 0 if BPQ020 == 2

gen chole = .
replace chole = 1 if BPQ080 == 1
replace chole = 0 if BPQ080 == 2

* Diabetes questionnaire
merge 1:1 seqn using $nhanes_dir/stata/1999-2000/diq
drop _merge
gen diabe = .
replace diabe = 1 if DIQ010 == 1
* 2 == no, 3 = borderline
replace diabe = 0 if (DIQ010 == 2 | DIQ010 == 3)



qui sum wtmec2yr
gen weight_norm = wtmec2yr/r(sum)
gen cohort = "nhanes99"

* Derive diagnoses
gen meas_hibp = .
replace meas_hibp = 1 if (systolic >= 140 & diastolic >= 90 & systolic < . & diastolic < .)
replace meas_hibp = 0 if (systolic < 140 | diastolic < 90)
gen hypertension = .
replace hypertension = 1 if (hibpe == 1 | meas_hibp == 1)
replace hypertension = 0 if (hibpe == 0 & meas_hibp == 0)
replace hypertension = 0 if (hibpe == 0 & missing(meas_hibp))
replace hypertension = 0 if (missing(hibpe) & meas_hibp == 0)

gen meas_diab = .
replace meas_diab = 1 if hba1c >= 6.5 & hba1c < .
replace meas_diab = 0 if hba1c < 6.5
gen diabetes = .
replace diabetes = 1 if (diabe == 1 | meas_diab == 1)
replace diabetes = 0 if (diabe == 0 & meas_diab == 0)
replace diabetes = 0 if (diabe == 0 & missing(meas_diab))
replace diabetes = 0 if (missing(diabe) & meas_diab == 0)

gen meas_chol = .
replace meas_chol = 1 if serum_chol >= 240 & serum_chol < .
replace meas_chol = 0 if serum_chol < 240
gen cholesterol = .
replace cholesterol = 1 if (chole == 1 | meas_chol == 1)
replace cholesterol = 0 if (chole == 0 & meas_chol == 0)
replace cholesterol = 0 if (chole == 0 & missing(meas_chol))
replace cholesterol = 0 if (missing(chole) & meas_chol == 0)

gen year = 1999.5
gen age = ridageex/12 if ridageex < .


keep age hypertension diabetes cholesterol year cohort weight_norm hibpe chole diabe meas_hibp meas_chol meas_diab

save `nhanes99', replace


/* NHANES 2001-2002
BPXSY1 through BPXSY4 - systolic - bpx_b
BPXDI1 through BPXDI4 - diastolic - bpx_b

lbxtc - total cholesterol - l13_b
lbxgh - glycohemoglobin (HbA1c) - l10_b

*/
tempfile nhanes01
use $nhanes_dir/stata/2001-2002/demo_b.dta, replace

merge 1:1 seqn using $nhanes_dir/stata/2001-2002/bpx_b
drop _merge
egen systolic = rowmean(BPXSY1 BPXSY2 BPXSY3 BPXSY4)
egen diastolic = rowmean(BPXDI1 BPXDI2 BPXDI3 BPXDI4)

merge 1:1 seqn using $nhanes_dir/stata/2001-2002/l13_b
drop _merge
rename lbxtc serum_chol

merge 1:1 seqn using $nhanes_dir/stata/2001-2002/l10_b
drop _merge
rename lbxgh hba1c

qui sum wtmec2yr
gen weight_norm = wtmec2yr/r(sum)
gen cohort = "nhanes01"

* Hypertension/cholesterol questionnaire
merge 1:1 seqn using $nhanes_dir/stata/2001-2002/bpq_b
drop _merge 
gen hibpe = .
replace hibpe = 1 if BPQ020 == 1
replace hibpe = 0 if BPQ020 == 2

gen chole = .
replace chole = 1 if BPQ080 == 1
replace chole = 0 if BPQ080 == 2

* Diabetes questionnaire
merge 1:1 seqn using $nhanes_dir/stata/2001-2002/diq_b
drop _merge
gen diabe = .
replace diabe = 1 if DIQ010 == 1
* 2 == no, 3 = borderline
replace diabe = 0 if (DIQ010 == 2 | DIQ010 == 3)

* Derive diagnoses
gen meas_hibp = .
replace meas_hibp = 1 if (systolic >= 140 & diastolic >= 90 & systolic < . & diastolic < .)
replace meas_hibp = 0 if (systolic < 140 | diastolic < 90)
gen hypertension = .
replace hypertension = 1 if (hibpe == 1 | meas_hibp == 1)
replace hypertension = 0 if (hibpe == 0 & meas_hibp == 0)
replace hypertension = 0 if (hibpe == 0 & missing(meas_hibp))
replace hypertension = 0 if (missing(hibpe) & meas_hibp == 0)

gen meas_diab = .
replace meas_diab = 1 if hba1c >= 6.5 & hba1c < .
replace meas_diab = 0 if hba1c < 6.5
gen diabetes = .
replace diabetes = 1 if (diabe == 1 | meas_diab == 1)
replace diabetes = 0 if (diabe == 0 & meas_diab == 0)
replace diabetes = 0 if (diabe == 0 & missing(meas_diab))
replace diabetes = 0 if (missing(diabe) & meas_diab == 0)

gen meas_chol = .
replace meas_chol = 1 if serum_chol >= 240 & serum_chol < .
replace meas_chol = 0 if serum_chol < 240
gen cholesterol = .
replace cholesterol = 1 if (chole == 1 | meas_chol == 1)
replace cholesterol = 0 if (chole == 0 & meas_chol == 0)
replace cholesterol = 0 if (chole == 0 & missing(meas_chol))
replace cholesterol = 0 if (missing(chole) & meas_chol == 0)

gen year = 2001.5
gen age = ridageex/12 if ridageex < .


keep age hypertension diabetes cholesterol year cohort weight_norm hibpe chole diabe meas_hibp meas_chol meas_diab

save `nhanes01', replace


/* NHANES 2003-2004
BPXSY1 through BPXSY4 - systolic - bpx_c
BPXDI1 through BPXDI4 - diastolic - bpx_c

lbxtc - total cholesterol - l13_c
lbxgh - glycohemoglobin (HbA1c) - l10_c

*/
tempfile nhanes03
use $nhanes_dir/stata/2003-2004/demo_c.dta, replace

merge 1:1 seqn using $nhanes_dir/stata/2003-2004/bpx_c
drop _merge
egen systolic = rowmean(BPXSY1 BPXSY2 BPXSY3 BPXSY4)
egen diastolic = rowmean(BPXDI1 BPXDI2 BPXDI3 BPXDI4)

merge 1:1 seqn using $nhanes_dir/stata/2003-2004/l13_c
drop _merge
rename lbxtc serum_chol

merge 1:1 seqn using $nhanes_dir/stata/2003-2004/l10_c
drop _merge
rename lbxgh hba1c

qui sum wtmec2yr
gen weight_norm = wtmec2yr/r(sum)
gen cohort = "nhanes03"

* Hypertension/cholesterol questionnaire
merge 1:1 seqn using $nhanes_dir/stata/2003-2004/bpq_c
drop _merge 
gen hibpe = .
replace hibpe = 1 if BPQ020 == 1
replace hibpe = 0 if BPQ020 == 2

gen chole = .
replace chole = 1 if BPQ080 == 1
replace chole = 0 if BPQ080 == 2

* Diabetes questionnaire
merge 1:1 seqn using $nhanes_dir/stata/2003-2004/diq_c
drop _merge
gen diabe = .
replace diabe = 1 if DIQ010 == 1
* 2 == no, 3 = borderline
replace diabe = 0 if (DIQ010 == 2 | DIQ010 == 3)


* Derive diagnoses
gen meas_hibp = .
replace meas_hibp = 1 if (systolic >= 140 & diastolic >= 90 & systolic < . & diastolic < .)
replace meas_hibp = 0 if (systolic < 140 | diastolic < 90)
gen hypertension = .
replace hypertension = 1 if (hibpe == 1 | meas_hibp == 1)
replace hypertension = 0 if (hibpe == 0 & meas_hibp == 0)
replace hypertension = 0 if (hibpe == 0 & missing(meas_hibp))
replace hypertension = 0 if (missing(hibpe) & meas_hibp == 0)

gen meas_diab = .
replace meas_diab = 1 if hba1c >= 6.5 & hba1c < .
replace meas_diab = 0 if hba1c < 6.5
gen diabetes = .
replace diabetes = 1 if (diabe == 1 | meas_diab == 1)
replace diabetes = 0 if (diabe == 0 & meas_diab == 0)
replace diabetes = 0 if (diabe == 0 & missing(meas_diab))
replace diabetes = 0 if (missing(diabe) & meas_diab == 0)

gen meas_chol = .
replace meas_chol = 1 if serum_chol >= 240 & serum_chol < .
replace meas_chol = 0 if serum_chol < 240
gen cholesterol = .
replace cholesterol = 1 if (chole == 1 | meas_chol == 1)
replace cholesterol = 0 if (chole == 0 & meas_chol == 0)
replace cholesterol = 0 if (chole == 0 & missing(meas_chol))
replace cholesterol = 0 if (missing(chole) & meas_chol == 0)

gen year = 2003.5
gen age = ridageex/12 if ridageex < .

keep age hypertension diabetes cholesterol year cohort weight_norm hibpe chole diabe meas_hibp meas_chol meas_diab

save `nhanes03', replace


/* NHANES 2005-2006
BPXSY1 through BPXSY4 - systolic - bpx_d
BPXDI1 through BPXDI4 - diastolic - bpx_d

lbxtc - total cholesterol - tchol_d
lbxgh - glycohemoglobin (HbA1c) - ghb_d

*/

tempfile nhanes05
use $nhanes_dir/stata/2005-2006/demo_d.dta, replace

merge 1:1 seqn using $nhanes_dir/stata/2005-2006/bpx_d
drop _merge
egen systolic = rowmean(BPXSY1 BPXSY2 BPXSY3 BPXSY4)
egen diastolic = rowmean(BPXDI1 BPXDI2 BPXDI3 BPXDI4)

merge 1:1 seqn using $nhanes_dir/stata/2005-2006/tchol_d
drop _merge
rename lbxtc serum_chol

merge 1:1 seqn using $nhanes_dir/stata/2005-2006/ghb_d
drop _merge
rename lbxgh hba1c

qui sum wtmec2yr
gen weight_norm = wtmec2yr/r(sum)
gen cohort = "nhanes05"

* Hypertension/cholesterol questionnaire
merge 1:1 seqn using $nhanes_dir/stata/2005-2006/bpq_d
drop _merge 
gen hibpe = .
replace hibpe = 1 if BPQ020 == 1
replace hibpe = 0 if BPQ020 == 2

gen chole = .
replace chole = 1 if BPQ080 == 1
replace chole = 0 if BPQ080 == 2

* Diabetes questionnaire
merge 1:1 seqn using $nhanes_dir/stata/2005-2006/diq_d
drop _merge
gen diabe = .
replace diabe = 1 if DIQ010 == 1
* 2 == no, 3 = borderline
replace diabe = 0 if (DIQ010 == 2 | DIQ010 == 3)

* Derive diagnoses
gen meas_hibp = .
replace meas_hibp = 1 if (systolic >= 140 & diastolic >= 90 & systolic < . & diastolic < .)
replace meas_hibp = 0 if (systolic < 140 | diastolic < 90)
gen hypertension = .
replace hypertension = 1 if (hibpe == 1 | meas_hibp == 1)
replace hypertension = 0 if (hibpe == 0 & meas_hibp == 0)
replace hypertension = 0 if (hibpe == 0 & missing(meas_hibp))
replace hypertension = 0 if (missing(hibpe) & meas_hibp == 0)

gen meas_diab = .
replace meas_diab = 1 if hba1c >= 6.5 & hba1c < .
replace meas_diab = 0 if hba1c < 6.5
gen diabetes = .
replace diabetes = 1 if (diabe == 1 | meas_diab == 1)
replace diabetes = 0 if (diabe == 0 & meas_diab == 0)
replace diabetes = 0 if (diabe == 0 & missing(meas_diab))
replace diabetes = 0 if (missing(diabe) & meas_diab == 0)

gen meas_chol = .
replace meas_chol = 1 if serum_chol >= 240 & serum_chol < .
replace meas_chol = 0 if serum_chol < 240
gen cholesterol = .
replace cholesterol = 1 if (chole == 1 | meas_chol == 1)
replace cholesterol = 0 if (chole == 0 & meas_chol == 0)
replace cholesterol = 0 if (chole == 0 & missing(meas_chol))
replace cholesterol = 0 if (missing(chole) & meas_chol == 0)

gen year = 2005.5
gen age = ridageex/12 if ridageex < .

keep age hypertension diabetes cholesterol year cohort weight_norm hibpe chole diabe meas_hibp meas_chol meas_diab

save `nhanes05', replace


/* NHANES 2007-2008
BPXSY1 through BPXSY4 - systolic - bpx_e
BPXDI1 through BPXDI4 - diastolic - bpx_e

lbxtc - total cholesterol - TCHOL_E
lbxgh - glycohemoglobin (HbA1c) - GHB_E

*/
tempfile nhanes07
use $nhanes_dir/stata/2007-2008/demo_e.dta, replace

merge 1:1 seqn using $nhanes_dir/stata/2007-2008/bpx_e
drop _merge
egen systolic = rowmean(BPXSY1 BPXSY2 BPXSY3 BPXSY4)
egen diastolic = rowmean(BPXDI1 BPXDI2 BPXDI3 BPXDI4)

merge 1:1 seqn using $nhanes_dir/stata/2007-2008/TCHOL_E
drop _merge
rename lbxtc serum_chol

merge 1:1 seqn using $nhanes_dir/stata/2007-2008/GHB_E
drop _merge
rename lbxgh hba1c

qui sum wtmec2yr
gen weight_norm = wtmec2yr/r(sum)
gen cohort = "nhanes07"

* Hypertension/cholesterol questionnaire
merge 1:1 seqn using $nhanes_dir/stata/2007-2008/bpq_e
drop _merge 
gen hibpe = .
replace hibpe = 1 if BPQ020 == 1
replace hibpe = 0 if BPQ020 == 2

gen chole = .
replace chole = 1 if BPQ080 == 1
replace chole = 0 if BPQ080 == 2

* Diabetes questionnaire
merge 1:1 seqn using $nhanes_dir/stata/2007-2008/diq_e
drop _merge
gen diabe = .
replace diabe = 1 if DIQ010 == 1
* 2 == no, 3 = borderline
replace diabe = 0 if (DIQ010 == 2 | DIQ010 == 3)

* Derive diagnoses
gen meas_hibp = .
replace meas_hibp = 1 if (systolic >= 140 & diastolic >= 90 & systolic < . & diastolic < .)
replace meas_hibp = 0 if (systolic < 140 | diastolic < 90)
gen hypertension = .
replace hypertension = 1 if (hibpe == 1 | meas_hibp == 1)
replace hypertension = 0 if (hibpe == 0 & meas_hibp == 0)
replace hypertension = 0 if (hibpe == 0 & missing(meas_hibp))
replace hypertension = 0 if (missing(hibpe) & meas_hibp == 0)

gen meas_diab = .
replace meas_diab = 1 if hba1c >= 6.5 & hba1c < .
replace meas_diab = 0 if hba1c < 6.5
gen diabetes = .
replace diabetes = 1 if (diabe == 1 | meas_diab == 1)
replace diabetes = 0 if (diabe == 0 & meas_diab == 0)
replace diabetes = 0 if (diabe == 0 & missing(meas_diab))
replace diabetes = 0 if (missing(diabe) & meas_diab == 0)

gen meas_chol = .
replace meas_chol = 1 if serum_chol >= 240 & serum_chol < .
replace meas_chol = 0 if serum_chol < 240
gen cholesterol = .
replace cholesterol = 1 if (chole == 1 | meas_chol == 1)
replace cholesterol = 0 if (chole == 0 & meas_chol == 0)
replace cholesterol = 0 if (chole == 0 & missing(meas_chol))
replace cholesterol = 0 if (missing(chole) & meas_chol == 0)

gen year = 2007.5
gen age = ridageex/12 if ridageex < .

keep age hypertension diabetes cholesterol year cohort weight_norm hibpe chole diabe meas_hibp meas_chol meas_diab

save `nhanes07', replace

/* NHANES 2009-2010
BPXSY1 through BPXSY4 - systolic - BPX_F
BPXDI1 through BPXDI4 - diastolic - BPX_F

lbxtc - total cholesterol - TCHOL_F
lbxgh - glycohemoglobin (HbA1c) - GHB_F

*/
tempfile nhanes09
use $nhanes_dir/stata/2009-2010/demo_f.dta, replace

merge 1:1 seqn using $nhanes_dir/stata/2009-2010/BPX_F
drop _merge
egen systolic = rowmean(BPXSY1 BPXSY2 BPXSY3 BPXSY4)
egen diastolic = rowmean(BPXDI1 BPXDI2 BPXDI3 BPXDI4)

merge 1:1 seqn using $nhanes_dir/stata/2009-2010/TCHOL_F
drop _merge
rename lbxtc serum_chol

merge 1:1 seqn using $nhanes_dir/stata/2009-2010/GHB_F
drop _merge
rename lbxgh hba1c

qui sum wtmec2yr
gen weight_norm = wtmec2yr/r(sum)
gen cohort = "nhanes09"

* Hypertension/cholesterol questionnaire
merge 1:1 seqn using $nhanes_dir/stata/2009-2010/bpq_f
drop _merge 
gen hibpe = .
replace hibpe = 1 if BPQ020 == 1
replace hibpe = 0 if BPQ020 == 2

gen chole = .
replace chole = 1 if BPQ080 == 1
replace chole = 0 if BPQ080 == 2

* Diabetes questionnaire
merge 1:1 seqn using $nhanes_dir/stata/2009-2010/diq_f
drop _merge
gen diabe = .
replace diabe = 1 if DIQ010 == 1
* 2 == no, 3 = borderline
replace diabe = 0 if (DIQ010 == 2 | DIQ010 == 3)

* Derive diagnoses
gen meas_hibp = .
replace meas_hibp = 1 if (systolic >= 140 & diastolic >= 90 & systolic < . & diastolic < .)
replace meas_hibp = 0 if (systolic < 140 | diastolic < 90)
gen hypertension = .
replace hypertension = 1 if (hibpe == 1 | meas_hibp == 1)
replace hypertension = 0 if (hibpe == 0 & meas_hibp == 0)
replace hypertension = 0 if (hibpe == 0 & missing(meas_hibp))
replace hypertension = 0 if (missing(hibpe) & meas_hibp == 0)

gen meas_diab = .
replace meas_diab = 1 if hba1c >= 6.5 & hba1c < .
replace meas_diab = 0 if hba1c < 6.5
gen diabetes = .
replace diabetes = 1 if (diabe == 1 | meas_diab == 1)
replace diabetes = 0 if (diabe == 0 & meas_diab == 0)
replace diabetes = 0 if (diabe == 0 & missing(meas_diab))
replace diabetes = 0 if (missing(diabe) & meas_diab == 0)

gen meas_chol = .
replace meas_chol = 1 if serum_chol >= 240 & serum_chol < .
replace meas_chol = 0 if serum_chol < 240
gen cholesterol = .
replace cholesterol = 1 if (chole == 1 | meas_chol == 1)
replace cholesterol = 0 if (chole == 0 & meas_chol == 0)
replace cholesterol = 0 if (chole == 0 & missing(meas_chol))
replace cholesterol = 0 if (missing(chole) & meas_chol == 0)

gen year = 2009.5
gen age = ridageex/12 if ridageex < .

keep age hypertension diabetes cholesterol year cohort weight_norm hibpe chole diabe meas_hibp meas_chol meas_diab

save `nhanes09', replace



use `nhanes3', replace
append using `nhanes99'
append using `nhanes01'
append using `nhanes03'
append using `nhanes05'
append using `nhanes07'
append using `nhanes09'

* Estimate the projection models

logit diabetes year [pw = weight_norm]
logit hypertension year [pw = weight_norm]
logit cholesterol year [pw = weight_norm]


* diabetes
logit diabetes year [pw = weight_norm]
logit diabetes year if age >= 24 & age < 28
logit diabetes year [pw = weight_norm] if age >= 24 & age < 28
est store mdiabetes

* hypertension
logit hypertension year [pw = weight_norm] if age >= 24 & age < 28
est store mhypertension

* high cholesterol
logit cholesterol year [pw = weight_norm] if age >= 24 & age < 28
est store mcholesterol

egen agecat = cut(age), at(20,30,40,50,60,70) label


save nhanes_historic.dta, replace

collapse (mean) diabetes hypertension cholesterol diabe hibpe chole meas_diab meas_hibp meas_chol [aw=weight_norm], by(year agecat)

save nhanes_historic_means.dta, replace

capture log close









*********************************************************************************************************************************************************














/*
tempfile nhanes2
* Physician's Exam - nhanes2
use $nhanes_dir/stata/nhanes2/d_5302.dta, replace
keep seqn N2PE0190 N2PE0056 N2PE0060 N2PE0055 N2PE0418 N2PE0288 N2PE0188 N2PE0411 N2PE0414 N2PE0288

* Normalize the weights
qui sum N2PE0288
gen weight_norm = N2PE0288/r(sum)

* gender recode
gen male = (N2PE0055 == 1)

* race/ethnicity recode
gen hisp = (N2PE0060 >= 1 & N2PE0060 <= 8)
gen black = (N2PE0056 == 2 & hisp == 0)
gen other = (N2PE0056 == 3 & hisp == 0)

* Age in years, up to 75.
rename N2PE0190 age

* BP variables
rename N2PE0411 systolic
rename N2PE0414 diastolic

save `nhanes2', replace

* Lab (hematology and biochemistry)
use $nhanes_dir/stata/nhanes2/d_5411.dta, replace
keep seqn N2LB0421 N2LB0434 N2LB0438 N2LB0294 N2LB0466 N2LB0469 N2LB0472 N2LB0516
rename N2LB0421 serum_chol
rename N2LB0434 hdl_chol
rename N2LB0466 fasting_glucose

merge 1:1 seqn using `nhanes2'

gen since75 = N2PE0188 - 75
gen cohort = "nhanes2"

* Derive diagnoses
gen hypertension = 0
replace hypertension = 1 if (systolic >= 140 & systolic < 800) & (diastolic >= 90 & diastolic < 800)
replace hypertension = . if missing(systolic) | missing(diastolic)

gen diabetes = 0
replace diabetes = (fasting_glucose >= 126 & fasting_glucose <= 400)
replace 

save `nhanes2', replace
*/
