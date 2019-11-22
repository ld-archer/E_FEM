/** \file

INCLUDE DEMENTIA/ALZHEIMER'S DISEASE INFORMATION INTO FEM
USING ADAMS STUDY DATA - WAVE A AND ADAMS STUDY TRACKER FILE

\deprecated This is probably being replaced by the AD project.

\bug This file will not run as-is
*/

* Note: activate this do file from within Stata
clear
clear mata
set more off
set mem 800m
set seed 5243212
set maxvar 10000
cap log close

* Define paths
global hrs_dir "/homer/e/RANDHRS/VerG" 
global hrsfat "/homer/e/HRSFATF/Stata/8SE"
global fem_path "/zeno/a/FEM/FEM_1.0"

global workdir  "$fem_path/Makedata"
global indata   "$fem_path/Input_yh"
global outdata  "$fem_path/Input_yh"
global outdata2 "$fem_path/Indata_yh"
global netdir    "/homer/c/Retire/FEM/rdata"
global ster "$fem_path/Estimates/alzhmr"


log using "$workdir/HRS/alzheimers.log", replace
***********
** INCLUDE DEMENTIA DIAGNOSES/SUMMARY SCORES FROM WAVE A
***********

cd "$workdir/adams1a/adams1ada"
infile using "$workdir/adams1a/ADAMS1AD_R_Jan122010.dct", clear

foreach x of varlist * {
	ren `x' `=lower("`x'")'
}

gen hhidpn = hhid + pn
destring hhidpn, replace
sort hhidpn
save "$indata\ADAMS1AD_R.dta", replace

***********
** EXTRACT SAMPLING WEIGHT FOR WAVE A AND WAVE OF INTERVIEW FROM ADAMS TRACKER FILE
***********

cd "$workdir/adams1trk/adams1trkda"
infile using "$workdir/adams1trk/ADAMS1TRK_R_Jan122010.dct", clear

foreach x of varlist * {
	ren `x' `=lower("`x'")'
}

gen hhidpn = hhid + pn
destring hhidpn, replace
sort hhidpn
save "$indata\ADAMS1TRK_R.dta", replace

***********
** GENERATE ADAM DATASET INCLUDING ID, WAVE OF INTERVIEW, AND DEMENTIA SUMMARY SCORE
***********
use "$indata\ADAMS1AD_R.dta", clear
sort hhidpn
merge hhidpn using "$indata\ADAMS1TRK_R.dta"
tab _merge
keep if _merge == 3
drop _merge
keep hhidpn *samp* wavesel adfdx1-adfdx3

*Recode AD based on final primary/secondary/tertiary diagnosis
/*
* adfdx1
         .................................................................................
           122           1.  Probable AD
           107           2.  Possible AD
            22           3.  Probable Vascular Dementia
            26           4.  Possible Vascular Dementia
             2           5.  Parkinson's
                         6.  Huntington's
                         7.  Progressive Supranuclear Palsy
             1           8.  Normal pressure hydrocephalus
            23          10.  Dementia of undetermined etiology
                        11.  Pick's disease
             1          13.  Frontal lobe dementia
             2          14.  Severe head trauma (with residual)
             1          15.  Alcoholic dementia
                        16.  ALS with dementia
                        17.  Hypoperfusion dementia
             1          18.  Probable Lewy Body dementia
                        19.  Post encephalitic dementia
            94          20.  Mild-ambiguous
            20          21.  Cognitive impairment secondary to vascular disease
             4          22.  Mild Cognitive Impairment
             8          23.  Depression
             2          24.  Psychiatric Disorder
             8          25.  Mental Retardation
             3          26.  Alcohol Abuse (past)
             3          27.  Alcohol Abuse (current)
            34          28.  Stroke
            10          29.  Other Neurological conditions
            55          30.  Other Medical conditions
           307          31.  Normal/Non-case
                        32.  Possible Lewy Body dementia
                        33.  CIND, non-specified
*/
gen alzhmr = adfdx1 == 1 | adfdx2 == 1 | adfdx3 == 1 if adfdx1 <= 33 & adfdx1 >= 1
gen wave = 5 if wavesel == 1
replace wave = 6 if wavesel == 2
keep hhidpn wave alzhmr aasampwt_f 
ren aasampwt_f adamswt
sort hhidpn
save adams_temp,replace
pause Adams Created
***********
** TICS SCORE - FOR THOSE AGED 65 AND OLDER
** SEE PAGE 17 OF 
**"Documentation of Cognitive Functioning Measures in the Health and Retirement Study"
** HRS Documentation Report DR-006, March, 2005
** USE RAND HRS FAT DATA ON HOMER/E
***********

/*
* TICS SCORE COUNT
1995 Core D1340 
1996 Core E1340 
1998 Core F1677 
2000 Core G1852 
2002 Core HD170 
2002 Exit N/A 
2004 Core JD170 
2004 Exit N/A 
2006 Core KD170 
2006 Exit N/A 
2008 Core LD170 
*/
/*
* USE DATA FROM 1998-2006
* List of files 
global filelist h98f2b h00f1c h02f2b h04f1a h06f2a

* List of TICS score count variables for corresponding files
global vlist f1677 g1852 hd170 jd170 kd170

clear
set obs 1
gen nonsense = 1
save tics_temp,replace

local i = 1
local j = 4
foreach f in $filelist {
	local x = word("$vlist", `i')
	local i = `i' + 1
	use hhidpn `x' using "$hrsfat//`f'.dta", clear
	ren `x' tics
	
	gen wave = `j'
	local j = `j' + 1
	keep hhidpn wave tics
	append using tics_temp
	save tics_temp,replace
}
drop if nonsense == 1
drop nonsense
erase tics_temp.dta

sort hhidpn wave
label data "TICS Score Count 1998-2006"
save "$indata/tics.dta", replace
*/

***********
** MERGE TICS SCORE WITH TRANSITION ESTIMATION SAMPLE
***********

* use "$netdir/hrs17r_transition.dta", clear
use "$indata/hrs17_transition.dta", clear
/*
sort hhidpn wave
merge hhidpn wave using "$indata/tics.dta"

tab wave _merge
* There will be unmatched cases from tics data since this is only those merged with AIME
drop if _merge == 2
* Most of the under 65 only has two questions for TICS, and only in wave 6, ignore under 65
tab tics if age < 65 & _merge == 3 , m
tab tics if age >= 65 & _merge == 3, m
ren _merge merge_tics
*/
* Merge with ADAMs study

sort hhidpn wave
merge hhidpn wave using adams_temp.dta, sort
erase adams_temp.dta
pause merged with adams
tab _merge if age >= 71 & inlist(wave,5,6)

/*
** Seems those proxy respondents had missing tics
tab tics alzhmr if _merge == 3 [aw = adamswt], m r
tab tics alzhmr if _merge == 3, m r

gen low_tics = tics < 8 | missing(tics)
tab low_tics alzhmr if _merge == 3 [aw = adamswt], m r
tab low_tics alzhmr if _merge == 3, m r
*/
replace memrye = 1 if memrye  == -2
tab memrye alzhmr if _merge == 3 [aw = weight], m r

gen agesq = age^2
foreach x in diabe hearte stroke lunge cancre hibpe {
	replace `x' = 1 if `x' == -2
}

pause here

probit alzhmr memrye age agesq hsless college black hispan diabe hearte stroke lunge cancre hibpe iadl adl12 adl3 if _merge == 3 & age >= 65 [pw = weight]
est save "$ster/alzhmr.ster", replace



cap log close






