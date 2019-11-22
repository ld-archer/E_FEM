/** \file Creates a data file of multiple NHANES waves with variables of interest
This program creates an analytic data file that stacks many waves of NHANES.
Relevant variables are derived and named the same as the corresponding HRS 
variables when approppriate. If you want to use a new NHANES outcome, this is the
place to add it.  NOTE: Many variables have only been developed for the waves 
where they are needed and are missing in other waves.

\todo loading the data after 1999 can be done in a for loop instead of individual blocks for each wave
*/

clear
clear mata
set more off

* Assume that this script is being executed in the FEM_Stata/Makedata/NHANES directory

* Load environment variables from the root FEM directory, three levels up
* these define important paths, specific to the user
include "../../../fem_env.do"

/**************************************** NHANES 1 (year = 1972) ****************************************/
/*
NHANES I - 1971 - 1975
Sample: Population groups thought to be at high risk of malnutrition were oversampled (low income, preschool children, youngh women
	the elderly). Weights based on age/sex/race categories to reflect the US civilian noninstitutionalized population 1-74 years of age.
	About 32,000 surveyed, 23,800 given physical exam.
Some variables of interest: age N1BM0144
	race N1BM0103 	gender N1BM0104
	weight N1BM0260 	height  N1BM0266
	sampling weight N1BM0194 N1BM0158 N1BM0164  N1BM0170  N1BM0176  N1BM0182  N1BM0188 
	exam year N1BM0138
	ancestry N1BM0120
	date of birth N1BM0106
** sample weights: "It is suggested ...if the researcher is interested in an exam component of the nutrition screening examination he should use
	the weight and consequently the data from the 65 location subsample."
	The data corresponding to weight and height comes from two of the surveys. The 1-65 location examination survey and the 66-100 location examination survey. 
	The NHANES website recomends to not combine this surveys: it is strongly advised that you do not attempt to combine samples in any analysis of NHANES I data.  
	The 1-65 weights are selected for this analysis.
*/

tempfile tfile_nhanes1
use $nhanes_dir/stata/nhanesi/d_4111.dta, replace
keep seqn N1BM0103 N1BM0104 N1BM0144 N1BM0138  N1BM0106 N1BM0120 N1BM0260 N1BM0266 N1BM0194 N1BM0158 N1BM0164  N1BM0170  N1BM0176  N1BM0182  N1BM0188

* gender recode
gen male = (N1BM0104 == 1)

* race/ethnicity recode
gen hisp = (N1BM0120==7 | N1BM0120==8)
gen black = (N1BM0103 == 2 & hisp == 0)
gen other = (N1BM0103 == 3 & hisp == 0)

* Derive BMI = weight[kg]/(height[m])^2
gen bmi = (N1BM0260/100)/(N1BM0266/1000)^2 if N1BM0260 !=88888 & N1BM0266 != 8888

rename N1BM0144 exam_age
tostring N1BM0138,replace
gen yr = real(substr(N1BM0138,4,2)) if length(N1BM0138)==5
replace yr = real(substr(N1BM0138,5,2)) if length(N1BM0138)==6

rename N1BM0176 exam_wght
keep if exam_wght !=. & exam_wght !=0

gen exam_yr = 1972
gen cohort = "nhanes1972"
gen year = 1972
save `tfile_nhanes1'

/**************************************** NHANES 2 (year = 1978) ****************************************/
/* 
NHANES 2 - 1976-1980

Some variables of interest:  	age - N2BM0190					race - N2BM0056				ancestry - N2BM0060
												gender - N2BM0055				height (cm with 1 decimal place ) - N2BM0418
												weight (kg with 2 decimal places) - N2BM0412
												Sampling weight - N2BM0288		Exam year - N2BM0188
*/
tempfile tfile_nhanes2

/*************************************** NHANES 2 Medical History ***************************************/
use $nhanes_dir/stata/nhanes2/d_5020.dta, replace
keep seqn N2AH0047 N2AH0288 N2AH0426 N2AH0491 N2AH0495 N2AH0499 N2AH0625 N2AH0626 N2AH0698 N2AH0699 N2AH1059 N2AH1060

/* Age */
rename N2AH0047 age_yrs

/* Sample weight */
rename N2AH0288 intw_wght

/* Self-reported health */
gen shlt = N2AH0426
recode shlt (1/3 = 0) (4/5 = 1) (8 = .)

/* Heart condition */
rename N2AH0491 hrtfaile
recode hrtfaile (2=0) (13 14 18 19 = 1) (88 = .)

rename N2AH0495 hrtattke
recode hrtattke (2=0) (88= .)

rename N2AH0499 hrtothe
recode hrtothe (2=0) (13 14 18 19 = 1) (88 = .)

gen nheartc = hrtfaile + hrtattke + hrtothe
gen hearte = nheartc > 0 & !missing(nheartc)
drop nheartc

/* Smoking */
rename N2AH0625 smokev
recode smokev (2=0)
rename N2AH0626 smoken
recode smoken (2=0)
replace smoken=0 if smokev==0

/* Diabetes */
rename N2AH0699 diabe
recode diabe (2=0)
* these people report not having diabetes:
replace diabe = 0 if N2AH0698 == 2

/* Hypertension */
rename N2AH1059 hibpe
recode hibpe (2=0)
* these people say they don't have high blood pressure, but do have hypertension:
replace hibpe=1 if N2AH1060==1

/********************************** NHANES2 Health History Supplement ***********************************/
merge 1:1 seqn using $nhanes_dir/stata/nhanes2/d_5305.dta, nogen keepusing(seqn N2SH0047 N2SH0765 N2SH0282)

/* Sample weight */
rename N2SH0282 exam_wght

/* Functional Status */
rename N2SH0765 fstat_new
recode fstat_new (2=0) (8=.n)

/******************************************** NHANES2 BMI ***********************************************/
merge 1:1 seqn using $nhanes_dir/stata/nhanes2/d_5301.dta, nogen keepusing(seqn N2BM0055 N2BM0056 N2BM0060  N2BM0188 N2BM0190  N2BM0288 N2BM0412 N2BM0418)

* gender recode
gen male = (N2BM0055 == 1)

* race/ethnicity recode
gen hisp = (N2BM0060 >= 1 & N2BM0060 <= 8)
gen black = (N2BM0056 == 2 & hisp == 0)
gen other = (N2BM0056 == 3 & hisp == 0)

* Derive BMI = weight[kg]/(height[m])^2
gen bmi = (N2BM0412/100)/(N2BM0418/1000)^2

* self-reported height: feet (N2AH0682) and inches (N2AH0683), weight: pounds (N2AH0685)
merge 1:1 seqn using $nhanes_dir/stata/nhanes2/d_5020.dta, keepusing(N2AH0288 N2AH0682 N2AH0683 N2AH0685) keep(master matched)
replace N2AH0682 = . if N2AH0682 == 8
replace N2AH0683 = . if N2AH0683 == 88
gen height_inches = 12*N2AH0682 + N2AH0683

replace N2AH0685 = . if N2AH0685 == 888

gen bmi_sr = 703 * N2AH0685 / (height_inches^2)

rename N2BM0190 exam_age
gen exam_yr = 1900+ N2BM0188

gen cohort = "nhanes1976"
gen year=1978
save `tfile_nhanes2', replace

/**************************************** NHANES 3 (year = 1991) ****************************************/
/*  NHANES3 - 1988-1994

Some variables of Interest:  	
age (months at exam) - mxpaxtmr
race - dmaracer
ethnicity - dmaethnr
gender - hssex
bmi - bmpbmi
sampling weight - WTPFEX1 (first wave) WTPFEX2 (second wave)

*/
tempfile tfile_nhanes3

use $nhanes_dir/stata/nhanes3/exam.dta, clear
keep seqn bmpbmi

merge 1:1 seqn using $nhanes_dir/stata/nhanes3/adult.dta, nogen keepusing(mxpaxtmr dmaracer dmaethnr hssex WTPFEX1 WTPFEX2 HAM5S HAM6S) keep(matched)

* recode BMI
rename bmpbmi bmi
replace bmi = . if bmi == 8888

* self-reported height (inches) and weight (pounds).
replace HAM5S = . if inlist(HAM5S,888,999)
replace HAM6S = . if inlist(HAM6S,888,999)

gen bmi_sr = 703 * HAM6S / (HAM5S^2)

* gender recode
gen male = (hssex == 1)

* race/ethnicity recode
gen hisp = (dmaethnr == 1 | dmaethnr == 2)
gen black = (dmaracer == 2 & hisp == 0)
gen other = (dmaracer == 3 & hisp == 0)
 
gen exam_yr=1989 if WTPFEX1 < .
replace exam_yr=1992 if WTPFEX2 < .
gen cohort_88="Phase 1" if WTPFEX1 < .
replace cohort_88="Phase 2" if WTPFEX2 < .

gen exam_age = floor(mxpaxtmr/12)
rename WTPFEX2 exam_wght
replace exam_wght = WTPFEX1 if WTPFEX1 < .

gen year = 1991
gen cohort = "nhanes1988"
save `tfile_nhanes3'

/**************************************** NHANES 1999-2000 (year = 2000) ****************************************/
tempfile tfile_nhanes9900

use  $nhanes_dir/stata/1999-2000/demo.dta, clear
keep seqn riagendr ridageyr ridageex ridreth1 dmdeduc2 ridexprg wtint2yr wtmec2yr sdmvpsu sdmvstra

merge 1:1 seqn using $nhanes_dir/stata/1999-2000/bmx.dta, nogen keepusing(bmxwt bmiwt bmxht bmiht bmxbmi)

* Self-reported height and weight
merge 1:1 seqn using $nhanes_dir/stata/1999-2000/whq.dta, nogen keepusing(WHD010 WHD020)

* Blood pressure
merge 1:1 seqn using $nhanes_dir/stata/1999-2000/bpq.dta, nogen keepusing(BPQ010 BPQ020)

* Heart disease
merge 1:1 seqn using $nhanes_dir/stata/1999-2000/mcq.dta, nogen keepusing(MCQ160B MCQ160C MCQ160D MCQ160E )

* Smoking status
merge 1:1 seqn using $nhanes_dir/stata/1999-2000/smq.dta, nogen keepusing(seqn SMQ020 SMD030 SMQ040)

* Diabetes
merge 1:1 seqn using $nhanes_dir/stata/1999-2000/diq.dta, nogen keepusing(DIQ010)

* HbA1c
merge 1:1 seqn using $nhanes_dir/stata/1999-2000/lab10.dta, nogen keepusing(lbxgh)

* plasma fasting glucose
merge 1:1 seqn using $nhanes_dir/stata/1999-2000/lab10am.dta, nogen keepusing(lbxglu)

gen exam_yr = 1999
gen cohort = "nhanes1999"
gen year=2000
save `tfile_nhanes9900'

/**************************************** NHANES 2001-2002 (year = 2002) ****************************************/
tempfile tfile_nhanes0102

use $nhanes_dir/stata/2001-2002/demo_b.dta, clear
keep seqn riagendr ridageyr ridageex ridreth1 dmdeduc2 ridexprg wtint2yr wtmec2yr sdmvpsu sdmvstra

merge 1:1 seqn using  $nhanes_dir/stata/2001-2002/bmx_b.dta, nogen keepusing(bmxwt bmiwt bmxht bmiht bmxbmi)

* Self-reported height and weight
merge 1:1 seqn using $nhanes_dir/stata/2001-2002/whq_b.dta, nogen keepusing(WHD010 WHD020)

* Blood pressure
merge 1:1 seqn using $nhanes_dir/stata/2001-2002/bpq_b.dta, nogen keepusing(BPQ010 BPQ020)

* Heart disease
merge 1:1 seqn using $nhanes_dir/stata/2001-2002/mcq_b.dta, nogen keepusing(MCQ160B MCQ160C MCQ160D MCQ160E )

* Smoking status
merge 1:1 seqn using $nhanes_dir/stata/2001-2002/smq_b.dta, nogen keepusing(seqn SMQ020 SMD030 SMQ040)

* Diabetes
merge 1:1 seqn using $nhanes_dir/stata/2001-2002/diq_b.dta, nogen keepusing(DIQ010)

* HbA1c
merge 1:1 seqn using $nhanes_dir/stata/2001-2002/l10_b.dta, nogen keepusing(lbxgh)

* plasma fasting glucose
merge 1:1 seqn using $nhanes_dir/stata/2001-2002/l10am_b.dta, nogen keepusing(lbxglu)

gen exam_yr = 2001
gen cohort = "nhanes2001"
gen year=2002
save `tfile_nhanes0102'

/**************************************** NHANES 2003-2004 (year = 2004) ****************************************/
tempfile tfile_nhanes0304

use $nhanes_dir/stata/2003-2004/demo_c.dta, clear
keep seqn riagendr ridageyr ridageex ridreth1 dmdeduc2 ridexprg wtint2yr wtmec2yr sdmvpsu sdmvstra

merge 1:1 seqn using  $nhanes_dir/stata/2003-2004/bmx_c.dta, nogen keepusing(bmxwt bmiwt bmxht bmiht bmxbmi)

* Self-reported height and weight
merge 1:1 seqn using $nhanes_dir/stata/2003-2004/whq_c.dta, nogen keepusing(WHD010 WHD020)

* Blood pressure
merge 1:1 seqn using $nhanes_dir/stata/2003-2004/bpq_c.dta, nogen keepusing(BPQ010 BPQ020)

* Heart disease
merge 1:1 seqn using $nhanes_dir/stata/2003-2004/mcq_c.dta, nogen keepusing(MCQ160B MCQ160C MCQ160D MCQ160E )

* Smoking status
merge 1:1 seqn using $nhanes_dir/stata/2003-2004/smq_c.dta, nogen keepusing(seqn SMQ020 SMD030 SMQ040)

* Diabetes
merge 1:1 seqn using $nhanes_dir/stata/2003-2004/diq_c.dta, nogen keepusing(DIQ010)

* HbA1c
merge 1:1 seqn using $nhanes_dir/stata/2003-2004/l10_c.dta, nogen keepusing(lbxgh)

* plasma fasting glucose
merge 1:1 seqn using $nhanes_dir/stata/2003-2004/l10am_c.dta, nogen keepusing(lbxglu)

gen exam_yr = 2003
gen cohort = "nhanes2003"
gen year=2004
save `tfile_nhanes0304'

/**************************************** NHANES 2005-2006 (year = 2006) ****************************************/
tempfile tfile_nhanes0506

use $nhanes_dir/stata/2005-2006/demo_d.dta, clear
keep seqn riagendr ridageyr ridageex ridreth1 dmdeduc2 ridexprg wtint2yr wtmec2yr sdmvpsu sdmvstra

merge 1:1 seqn using $nhanes_dir/stata/2005-2006/bmx_d.dta, nogen keepusing(bmxwt bmiwt bmxht bmiht bmxbmi)

* NO ridreth2 variable *

* Self-reported height and weight
merge 1:1 seqn using $nhanes_dir/stata/2005-2006/whq_d.dta, nogen keepusing(WHD010 WHD020)

* Blood pressure
merge 1:1 seqn using $nhanes_dir/stata/2005-2006/bpq_d.dta, nogen keepusing(BPQ020)

* Heart disease
merge 1:1 seqn using $nhanes_dir/stata/2005-2006/mcq_d.dta, nogen keepusing(MCQ160B MCQ160C MCQ160D MCQ160E )

* Smoking status
merge 1:1 seqn using $nhanes_dir/stata/2005-2006/smq_d.dta, nogen keepusing(seqn SMQ020 SMD030 SMQ040)

* Diabetes
merge 1:1 seqn using $nhanes_dir/stata/2005-2006/diq_d.dta, nogen keepusing(DIQ010)

* HbA1c
merge 1:1 seqn using $nhanes_dir/stata/2005-2006/ghb_d.dta, nogen keepusing(lbxgh)

* plasma fasting glucose
merge 1:1 seqn using $nhanes_dir/stata/2005-2006/glu_d.dta, nogen keepusing(lbxglu)

* OGTT
merge 1:1 seqn using $nhanes_dir/stata/2005-2006/ogtt_d.dta, nogen keepusing(lbxglt)

gen exam_yr = 2005
gen cohort = "nhanes2005"
gen year=2006
save `tfile_nhanes0506'

/**************************************** NHANES 2007-2008 (year = 2008) ****************************************/
tempfile tfile_nhanes0708

use $nhanes_dir/stata/2007-2008/demo_e.dta, clear
keep seqn riagendr ridageyr ridageex ridreth1 dmdeduc2 ridexprg wtint2yr wtmec2yr sdmvpsu sdmvstra

merge 1:1 seqn using $nhanes_dir/stata/2007-2008/bmx_e.dta, nogen keepusing(bmxwt bmiwt bmxht bmiht bmxbmi)

* Self-reported height and weight
merge 1:1 seqn using $nhanes_dir/stata/2007-2008/whq_e.dta, keepusing(WHD010 WHD020)
drop _merge

* Blood pressure
merge 1:1 seqn using $nhanes_dir/stata/2007-2008/bpq_e.dta, nogen keepusing(BPQ020)

* Heart disease
merge 1:1 seqn using $nhanes_dir/stata/2007-2008/mcq_e.dta, nogen keepusing(MCQ160B MCQ160C MCQ160D MCQ160E )

* Smoking status
merge 1:1 seqn using $nhanes_dir/stata/2007-2008/smq_e.dta, nogen keepusing(seqn SMQ020 SMD030 SMQ040)

* Diabetes
merge 1:1 seqn using $nhanes_dir/stata/2007-2008/diq_e.dta, nogen keepusing(DIQ010)

* HbA1c
merge 1:1 seqn using $nhanes_dir/stata/2007-2008/ghb_e.dta, nogen keepusing(lbxgh)

* plasma fasting glucose
merge 1:1 seqn using $nhanes_dir/stata/2007-2008/glu_e.dta, nogen keepusing(lbxglu)

* OGTT
merge 1:1 seqn using $nhanes_dir/stata/2007-2008/ogtt_e.dta, nogen keepusing(lbxglt)

gen exam_yr = 2007
gen cohort = "nhanes2007"
gen year=2008
save `tfile_nhanes0708'

/************************************ NHANES 2009-2010 (year = 2010) ************************************/
tempfile tfile_nhanes0910
use $nhanes_dir/stata/2009-2010/demo_f.dta, clear
keep seqn riagendr ridageyr ridageex ridreth1 dmdeduc2 ridexprg wtint2yr wtmec2yr sdmvpsu sdmvstra

/******************************* NHANES 2009-2010 - current health status *******************************/
merge 1:1 seqn using $nhanes_dir/stata/2009-2010/hsq_f.dta, nogen keepusing(HSD010)
/* Self-reported health */
gen shlt = HSD010
recode shlt (1/3 = 0) (4/5 = 1) (7 = .r) (9 = .d)

/********************************* NHANES 2009-2010 - medical conditions ********************************/
merge 1:1 seqn using $nhanes_dir/stata/2009-2010/mcq_f.dta, nogen keepusing(MCQ160B MCQ160C MCQ160D MCQ160E )


/****************************** NHANES 2009-2010 - smoking & cigarette use *******************************/
merge 1:1 seqn using $nhanes_dir/stata/2009-2010/smq_f.dta, nogen keepusing(seqn SMQ020 SMD030 SMQ040)

/************************************* NHANES 2009-2010 - diabetes **************************************/
merge 1:1 seqn using $nhanes_dir/stata/2009-2010/diq_f.dta, nogen keepusing(DIQ010)

/************************** NHANES 2009-2010 - blood pressure and cholesterol ***************************/
merge 1:1 seqn using $nhanes_dir/stata/2009-2010/bpq_f.dta, nogen keepusing(BPQ020)

/******************************* NHANES 2009-2010 - physical functioning ********************************/
merge 1:1 seqn using $nhanes_dir/stata/2009-2010/pfq_f.dta, keepusing(PFQ061H PFQ061J PFQ061K PFQ061L)
drop _merge

rename PFQ061H walk
recode walk (1=0) (2/4=1) (5=.n) (7=.r) (9=.d)

rename PFQ061J bed
recode bed (1=0) (2/4=1) (5=.n) (7=.r) (9=.d)

rename PFQ061K eat
recode eat (1=0) (2/4=1) (5=.n) (7=.r) (9=.d)

rename PFQ061L dress
recode dress (1=0) (2/4=1) (5=.n) (7=.r) (9=.d)

gen nfdiff = walk + bed + eat + dress
gen fstat_new = nfdiff > 0 & !missing(nfdiff)
drop nfdiff


/*************************************** NHANES 2009-2010 - BMI *****************************************/
merge 1:1 seqn using $nhanes_dir/stata/2009-2010/bmx_f.dta, nogen keepusing(seqn bmxwt bmiwt bmxht bmiht bmxbmi)

/************************* NHANES 2009-2010 - Self-reported height and wieght ***************************/
merge 1:1 seqn using $nhanes_dir/stata/2009-2010/whq_f.dta, nogen keepusing(WHD010 WHD020)

* HbA1c
merge 1:1 seqn using $nhanes_dir/stata/2009-2010/ghb_f.dta, nogen keepusing(lbxgh)

* plasma fasting glucose
merge 1:1 seqn using $nhanes_dir/stata/2009-2010/glu_f.dta, nogen keepusing(lbxglu)

* OGTT
merge 1:1 seqn using $nhanes_dir/stata/2009-2010/OGTT_F.dta, nogen keepusing(lbxglt)


gen exam_yr = 2009
gen cohort = "nhanes2009"
gen year = 2010
save `tfile_nhanes0910'





/************************************ NHANES 2011-2012 (year = 2012) ************************************/
tempfile tfile_nhanes1112
use $nhanes_dir/stata/2011-2012/demo_g.dta, clear
rename *, lower
keep seqn riagendr ridageyr /*ridageex*/ ridreth1 dmdeduc2 ridexprg wtint2yr wtmec2yr sdmvpsu sdmvstra
gen ridageex = ridageyr * 12


/******************************* NHANES 2011-2012 - current health status *******************************/
merge 1:1 seqn using $nhanes_dir/stata/2011-2012/hsq_g.dta, nogen keepusing(HSD010)
/* Self-reported health */
gen shlt = HSD010
recode shlt (1/3 = 0) (4/5 = 1) (7 = .r) (9 = .d)

/********************************* NHANES 2011-2012 - medical conditions ********************************/
merge 1:1 seqn using $nhanes_dir/stata/2011-2012/mcq_g.dta, nogen keepusing(MCQ160B MCQ160C MCQ160D MCQ160E )


/****************************** NHANES 2011-2012 - smoking & cigarette use *******************************/
merge 1:1 seqn using $nhanes_dir/stata/2011-2012/smq_g.dta, nogen keepusing(seqn SMQ020 SMD030 SMQ040)

/************************************* NHANES 2011-2012 - diabetes **************************************/
merge 1:1 seqn using $nhanes_dir/stata/2011-2012/diq_g.dta, nogen keepusing(DIQ010)

/************************** NHANES 2011-2012 - blood pressure and cholesterol ***************************/
merge 1:1 seqn using $nhanes_dir/stata/2011-2012/bpq_g.dta, nogen keepusing(BPQ020)

/******************************* NHANES 2011-2012 - physical functioning ********************************/
merge 1:1 seqn using $nhanes_dir/stata/2011-2012/pfq_g.dta, keepusing(PFQ061H PFQ061J PFQ061K PFQ061L)
drop _merge

rename PFQ061H walk
recode walk (1=0) (2/4=1) (5=.n) (7=.r) (9=.d)

rename PFQ061J bed
recode bed (1=0) (2/4=1) (5=.n) (7=.r) (9=.d)

rename PFQ061K eat
recode eat (1=0) (2/4=1) (5=.n) (7=.r) (9=.d)

rename PFQ061L dress
recode dress (1=0) (2/4=1) (5=.n) (7=.r) (9=.d)

gen nfdiff = walk + bed + eat + dress
gen fstat_new = nfdiff > 0 & !missing(nfdiff)
drop nfdiff


/*************************************** NHANES 2011-2012 - BMI *****************************************/
merge 1:1 seqn using $nhanes_dir/stata/2011-2012/bmx_g.dta, nogen keepusing(seqn bmxwt bmiwt bmxht bmiht bmxbmi)

/************************* NHANES 2011-2012 - Self-reported height and wieght ***************************/
merge 1:1 seqn using $nhanes_dir/stata/2011-2012/whq_g.dta, nogen keepusing(WHD010 WHD020)

* HbA1c
merge 1:1 seqn using $nhanes_dir/stata/2011-2012/ghb_g.dta, nogen keepusing(lbxgh)

* plasma fasting glucose
merge 1:1 seqn using $nhanes_dir/stata/2011-2012/glu_g.dta, nogen keepusing(lbxglu)

* OGTT
merge 1:1 seqn using $nhanes_dir/stata/2011-2012/ogtt_g.dta, nogen keepusing(lbxglt)


gen exam_yr = 2011
gen cohort = "nhanes2011"
gen year = 2012
save `tfile_nhanes1112'









/************************************ NHANES 2013-2014 (year = 2014) ************************************/
tempfile tfile_nhanes1314
use $nhanes_dir/stata/2013-2014/DEMO_H.dta, clear
rename *, lower
keep seqn riagendr ridageyr /*ridageex*/ ridreth1 dmdeduc2 ridexprg wtint2yr wtmec2yr sdmvpsu sdmvstra
gen ridageex = ridageyr * 12


/******************************* NHANES 2013-2014 - current health status *******************************/
merge 1:1 seqn using $nhanes_dir/stata/2013-2014/HSQ_H.dta, nogen keepusing(HSD010)
/* Self-reported health */
gen shlt = HSD010
recode shlt (1/3 = 0) (4/5 = 1) (7 = .r) (9 = .d)

/********************************* NHANES 2013-2014 - medical conditions ********************************/
merge 1:1 seqn using $nhanes_dir/stata/2013-2014/MCQ_H.dta, nogen keepusing(MCQ160B MCQ160C MCQ160D MCQ160E )


/****************************** NHANES 2013-2014 - smoking & cigarette use *******************************/
merge 1:1 seqn using $nhanes_dir/stata/2013-2014/SMQ_H.dta, nogen keepusing(seqn SMQ020 SMD030 SMQ040)

/************************************* NHANES 2013-2014 - diabetes **************************************/
merge 1:1 seqn using $nhanes_dir/stata/2013-2014/DIQ_H.dta, nogen keepusing(DIQ010)

/************************** NHANES 2013-2014 - blood pressure and cholesterol ***************************/
merge 1:1 seqn using $nhanes_dir/stata/2013-2014/BPQ_H.dta, nogen keepusing(BPQ020)

/******************************* NHANES 2013-2014 - physical functioning ********************************/
merge 1:1 seqn using $nhanes_dir/stata/2013-2014/PFQ_H.dta, keepusing(PFQ061H PFQ061J PFQ061K PFQ061L)
drop _merge

rename PFQ061H walk
recode walk (1=0) (2/4=1) (5=.n) (7=.r) (9=.d)

rename PFQ061J bed
recode bed (1=0) (2/4=1) (5=.n) (7=.r) (9=.d)

rename PFQ061K eat
recode eat (1=0) (2/4=1) (5=.n) (7=.r) (9=.d)

rename PFQ061L dress
recode dress (1=0) (2/4=1) (5=.n) (7=.r) (9=.d)

gen nfdiff = walk + bed + eat + dress
gen fstat_new = nfdiff > 0 & !missing(nfdiff)
drop nfdiff


/*************************************** NHANES 2013-2014 - BMI *****************************************/
merge 1:1 seqn using $nhanes_dir/stata/2013-2014/BMX_H.dta, nogen keepusing(seqn bmxwt bmiwt bmxht bmiht bmxbmi)

/************************* NHANES 2013-2014 - Self-reported height and wieght ***************************/
merge 1:1 seqn using $nhanes_dir/stata/2013-2014/whq_h.dta, nogen keepusing(WHD010 WHD020)

* HbA1c
merge 1:1 seqn using $nhanes_dir/stata/2013-2014/GHB_H.dta, nogen keepusing(lbxgh)

* plasma fasting glucose
merge 1:1 seqn using $nhanes_dir/stata/2013-2014/GLU_H.dta, nogen keepusing(lbxglu)

* OGTT
merge 1:1 seqn using $nhanes_dir/stata/2013-2014/OGTT_H.dta, nogen keepusing(lbxglt)

gen exam_yr = 2013
gen cohort = "nhanes2013"
gen year = 2014
save `tfile_nhanes1314'









/************************************ NHANES 2015-2016 (year = 2016) ************************************/
tempfile tfile_nhanes1516
use $nhanes_dir/stata/2015-2016/demo_i.dta, clear
rename *, lower
keep seqn riagendr ridageyr /*ridageex*/ ridreth1 dmdeduc2 ridexprg wtint2yr wtmec2yr sdmvpsu sdmvstra
gen ridageex = ridageyr * 12


/******************************* NHANES 2015-2016 - current health status *******************************/
merge 1:1 seqn using $nhanes_dir/stata/2015-2016/hsq_i.dta, nogen keepusing(HSD010)
/* Self-reported health */
gen shlt = HSD010
recode shlt (1/3 = 0) (4/5 = 1) (7 = .r) (9 = .d)

/********************************* NHANES 2015-2016 - medical conditions ********************************/
merge 1:1 seqn using $nhanes_dir/stata/2015-2016/mcq_i.dta, nogen keepusing(MCQ160B MCQ160C MCQ160D MCQ160E )


/****************************** NHANES 2015-2016 - smoking & cigarette use *******************************/
merge 1:1 seqn using $nhanes_dir/stata/2015-2016/smq_i.dta, nogen keepusing(seqn SMQ020 SMD030 SMQ040)

/************************************* NHANES 2015-2016 - diabetes **************************************/
merge 1:1 seqn using $nhanes_dir/stata/2015-2016/diq_i.dta, nogen keepusing(DIQ010)

/************************** NHANES 2015-2016 - blood pressure and cholesterol ***************************/
merge 1:1 seqn using $nhanes_dir/stata/2015-2016/bpq_i.dta, nogen keepusing(BPQ020)

/******************************* NHANES 2015-2016 - physical functioning ********************************/
merge 1:1 seqn using $nhanes_dir/stata/2015-2016/pfq_i.dta, keepusing(PFQ061H PFQ061J PFQ061K PFQ061L)
drop _merge

rename PFQ061H walk
recode walk (1=0) (2/4=1) (5=.n) (7=.r) (9=.d)

rename PFQ061J bed
recode bed (1=0) (2/4=1) (5=.n) (7=.r) (9=.d)

rename PFQ061K eat
recode eat (1=0) (2/4=1) (5=.n) (7=.r) (9=.d)

rename PFQ061L dress
recode dress (1=0) (2/4=1) (5=.n) (7=.r) (9=.d)

gen nfdiff = walk + bed + eat + dress
gen fstat_new = nfdiff > 0 & !missing(nfdiff)
drop nfdiff


/*************************************** NHANES 2015-2016 - BMI *****************************************/
merge 1:1 seqn using $nhanes_dir/stata/2015-2016/bmx_i.dta, nogen keepusing(seqn bmxwt bmiwt bmxht bmiht bmxbmi)

/************************* NHANES 2015-2016 - Self-reported height and wieght ***************************/
*** This doesn't seem to be publicly available yet as of 1/22/2018 ??? ***
* merge 1:1 seqn using $nhanes_dir/stata/2015-2016/whq_i.dta, nogen keepusing(WHD010 WHD020)

* HbA1c
merge 1:1 seqn using $nhanes_dir/stata/2015-2016/ghb_i.dta, nogen keepusing(lbxgh)

* plasma fasting glucose
*** This doesn't seem to be publicly available yet as of 1/22/2018 ??? ***
* merge 1:1 seqn using $nhanes_dir/stata/2015-2016/glu_i.dta, nogen keepusing(lbxglu)

* OGTT
*** This doesn't seem to be publicly available yet as of 1/22/2018 ??? ***
* merge 1:1 seqn using $nhanes_dir/stata/2015-2016/ogtt_i.dta, nogen keepusing(lbxglt)

gen exam_yr = 2015
gen cohort = "nhanes2015"
gen year = 2016
save `tfile_nhanes1516'










/**************************** Append NHANES 1999-2016 variables and recode *******************************/
use `tfile_nhanes1516', clear
append using `tfile_nhanes1314' `tfile_nhanes1112' `tfile_nhanes0910' `tfile_nhanes0708' `tfile_nhanes0506' `tfile_nhanes0304' `tfile_nhanes0102' `tfile_nhanes9900'

rename bmxbmi bmi

* Male
gen male = (riagendr == 1)

* Race/ethnicity
gen black = (ridreth1 == 4)
gen hisp =  (ridreth1 == 1 | ridreth1 == 2)
gen other = (ridreth1 == 5)

* Self-reported BMI
replace WHD010 = . if inlist(WHD010,7777,9999)
replace WHD020 = . if inlist(WHD020,7777,9999,77777,99999)

gen bmi_sr = 703 * WHD020 / (WHD010^2)

/* Blood pressure */
rename BPQ020 hibpe
recode hibpe (2=0) (7=.r) (9=.d)
replace hibpe=0 if BPQ010==5

/* Heart condition */
rename MCQ160B hrtfaile
recode hrtfaile (2=0) (7 = .r) (9 = .d)
rename MCQ160C hrtchde
recode hrtchde (2=0) (7 = .r) (9 = .d)
rename MCQ160D hrtange
recode hrtange (2=0) (7 = .r) (9 = .d)
rename MCQ160E hrtattke
recode hrtattke (2=0) (7 = .r) (9 = .d)
gen hearte = .
gen nmisshrt = 0
foreach v in hrtfaile hrtchde hrtange hrtattke {
	replace hearte = 1 if `v'==1
	replace nmisshrt = nmisshrt + missing(`v')
}
replace hearte = 0 if hearte==. & nmisshrt==0
drop nmisshrt
rename hrtfaile chfe


/* Smoking */
rename SMQ020 smokev
recode smokev (2=0) (7 = .r) (9 = .d)
rename SMQ040 smoken
recode smoken (2=1) (3=0) (7=.r) (9=.d)
replace smoken = 0 if smokev==0 | SMD030==0
* smoking categories are mutually exclusive: former smokers and current smokers
replace smokev = 0 if smoken == 1

/* Diabetes - treating borderline as " no" */
rename DIQ010 diabe
recode diabe (2=0) (3=0) (7=.r) (9=.d)

gen exam_age = floor(ridageex/12)
gen age_yrs = ridageyr
rename wtmec2yr exam_wght
rename wtint2yr intw_wght


/*************************** append pre-1999 NHANES and output combined file ****************************/
append using `tfile_nhanes3' `tfile_nhanes2' `tfile_nhanes1'

label var age_yrs "Age at interview/screening date (top-coded)"
label var exam_age "Age at physical exam date (top-coded)"
label var exam_yr "Year of physical exam"
label var exam_wght "Physical examination sample weight"
label var intw_wght "Interview sample weight"
label var cohort "Indication of Survey Wave - need to combine with cohort_88"
label var cohort_88 "Indication of Survey Phase for 1988 Wave"
label var bmi_sr "BMI based on self-reported data"
label var year "Year of survey"
label var hearte "Doctor ever told CHF, CHD, angina, heart attack"
label var hibpe  "Doctor ever told high blood pressure/hypertension"
label var diabe "Doctor ever told diabetes"
label var smokev "Smoke ever?"
label var smoken "Smoke cigarettes now?"
label var shlt "Self-report health fair/poor"
label var fstat_new  "limitation on personal needs activities"
label var walk  "Diff. walking room"
label var bed  "Diff. getting in/out bed"
label var eat  "Diff. fork, knife, drink"
label var dress  "Diff. dressing"


format intw_wght exam_wght %15.0fc
keep seqn bmi male black hisp other exam_age age_yrs cohort exam_age exam_yr exam_wght intw_wght cohort_88 bmi_sr year hibpe diabe smokev smoken hearte chfe lbxgh lbxglu lbxglt dmdeduc2

* smoking categories are mutually exclusive: former smokers and current smokers
replace smokev = 0 if smoken == 1

sort year seqn
label data "NHANES analytic file for waves I, II, III, and 1999-2016"
save $outdata/nhanes.dta, replace





