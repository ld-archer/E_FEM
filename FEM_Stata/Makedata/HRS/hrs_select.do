/** \file
 Prepare simulation dataset in 1992, for validation purposes

- Jan 2008
- Mar 2008, add memrye as the state
- Mar 11, 2008, include spouses, population size weighting
- Select economic variables
- drop those with missing values (or hotdeck??)
- Wealth: wlth_nonzero is non-zero
- Wealth, iearnx, and dcwlth are transformed using gh
 - Sep 6, 2008: drop missing values for those alive but not interviewed, first impute demographics
 - Sep 13, 2008: keep the self-reported SS income isret
 - 9/08/2009 - Removed references to age dummies
  - Added references to other age variables

*/
include common.do

use "$outdata/hrs_analytic_recoded.dta", clear

count

* rename weight
ren wtcrnh weight

***************************************
* Recode variables
***************************************
/*---------- Censored continuous variables --------------*/
foreach v of varlist iearn hatota dcwlth{
	gen `v'x = `v'/1000
}

foreach v of varlist iearn hatota dcwlth{
	replace `v' = `v'/1000
}

*** Truncate  /* Check distribution of rinc_oth ipena spinc */
replace iearnx = min(iearnx,200) if !missing(iearn)
* replace hatotax = max(-25, hatotax) if !missing(hatota)
**replace hatotax = 0 if hatota <= 0
replace hatotax = min(hatotax, 2000) if !missing(hatota) & hatota < . 

gen iearnuc = iearn
label var iearnuc "Uncapped earnings in 1000s"

label var iearn "Individual earnings in 1000s"
label var hatota "HH wlth in 1000s"
label var dcwlth "Individual DC wlth wv1-5 only in 1000s"

label var iearnx "Individual earnings in 1000s-max 200"
label var hatotax "HH wlth in 1000s if positive-max 2000 zero otherwise"
label var dcwlthx "Individual DC wlth wv1-5 only in 1000s(=dcwlth)"

*** Indicators for log transformation
gen wlth_nonzero = hatota != 0 if hatota < . 
label var wlth_nonzero "Non-pension wlth(hatota) not zero"

*gen wlth_nonzero = hatota > 0 if hatota < . 
*label var wlth_nonzero "Positive non-pension wealth(hatota)"

gen hicap_nonzero = hicap != 0 if hicap < .
label variable hicap_nonzero "Household Capital Income is not zero"

gen igxfr_nonzero = igxfr !=0 if !missing(igxfr)
label variable igxfr_nonzero "Other Government Transfers is not zero"

gen proptax_nonzero = proptax != 0 if !missing(proptax)
label var proptax_nonzero "Property Taxes are not zero"

*** Log transform BMI
gen logbmi = log(bmi) if bmi < .
label var logbmi "Log(BMI)"

*** IHT transformation
egen logiearnx = h(iearnx) if work == 1
replace logiearnx = logiearnx/100
replace logiearnx = 0 if work == 0
label var logiearnx "(IHT of earnings in 1000s)/100 if working zero otherwise"

* For uncapped income
egen logiearn = h(iearn) if work == 1
replace logiearn = logiearn/100
replace logiearn = 0 if work == 0
label var logiearn "(IHT of earnings in 1000s)/100 if working,zero otherwise"

* For uncapped (and stable) income
egen logiearnuc = h(iearnuc) if work == 1
replace logiearnuc = logiearnuc/100
replace logiearnuc = 0 if work == 0
label var logiearnuc "(IHT of earnings in 1000s)/100 if working,zero otherwise"

replace dcwlthx = 0 if anydc == 0
egen logdcwlthx = h(dcwlthx) if dcwlthx > 0 & dcwlthx < . 
replace logdcwlthx = logdcwlthx/100
replace logdcwlthx = 0 if dcwlthx == 0
label var logdcwlthx "(IHT of DC wlth in 1000s)/100 if any DC zero otherwise"
egen loghatotax = h(hatotax) if wlth_nonzero == 1
replace loghatotax = loghatotax/100
replace loghatotax = 0 if wlth_nonzero == 0
label var loghatotax "(IHT of hh wlth in 1000s if positive)/100 zero otherwise"

/* ----------Recode other variables ------------------*/

gen retired = work==0 if work < .
label var retired "Retired or not"

*Refined Obesity*
replace wtstate = 1 if bmi < 25
replace wtstate = 2 if bmi >=25 & bmi < 30
replace wtstate = 3 if bmi >= 30 & bmi < 35
replace wtstate = 4 if bmi >=35 & bmi < 40
replace wtstate = 5 if bmi >= 40 & bmi !=.
replace wtstate = . if bmi == .

label drop wtlb
label def wtlb 1 "BMI < 25" 2 "BMI >= 25 & BMI < 30" 3 "BMI >=30 & BMI < 35" 4 "BMI >=35 & BMI < 40" 5 "BMI >= 40"
label values wtstate wtlb

* Year of birth
gen rbyr = rabyear

* Assume memory-related diseases in wave 1 or 3 is zero
replace memrye = 0 if inrange(wave,1,3) & iwstat == 1

* Assume depression symptoms in wave 1 are zero
*replace deprsymp = 0 if wave == 1 & iwstat == 1
*replace cesdstat = 0 if wave == 1 & iwstat == 1

* SSclaim-all with SS benefit if older than 70
* replace ssclaim = 1 if age > 70 & iwstat == 1

* No nursing home population in wave 1-2
replace nhmliv = 0 if( wave == 1 | wave == 2) & iwstat == 1

count

********************************************************************************
*** Add BMI initial values (value at age 50-55 or earlier)
sort hhidpn
merge m:1 hhidpn using "$outdata/BMI_initial_values.dta", keepusing(hhidpn fbmi50 fbmi50_imp)
drop if _merge==2
drop _merge

** check on things 
count

gen flogbmi50 = log(fbmi50) if fbmi50 < .
drop fbmi50 fbmi50_imp

label var flogbmi50 "Log(BMI age 50)"


*********************************************************************************
* Recode rxchol missing cases to avoid dropping
*********************************************************************************
replace rxchol = -333 if rxchol != 0 & rxchol != 1


********************************************************************************
* Drop variables with invalid missing
***************************************

/* Sep 6, impute demographics for those alive but not interviewed */
foreach x of varlist $demog {
	sort hhidpn wave, stable
	by hhidpn: replace `x' = `x'[1] if iwstat == 4
}

foreach v of varlist $identifiers $demog $vcmatrix $timevariant {
		qui count if missing(`v') == 1 & died == 0 & iwstat == 1
		dis "Number missing for `v' is: " r(N)
}

tab hacohort

count

foreach v of varlist $identifiers $demog $vcmatrix $timevariant {
		drop if missing(`v') == 1 & died == 0 & iwstat == 1
		dis "`v'"
		count
}

count

tab hacohort

***************************************
* Special recoding: no question on memrye before wave 4
***************************************
replace memrye = . if wave < 4

***************************************
* Special recoding: no question on cesd variables for wave 1
***************************************
replace cesdstat = . if cesdstat == -2
replace deprsymp = . if deprsymp == -2

***************************************
* Special recoding: no question on alzhe variables before wave 10
***************************************
replace alzhe = . if alzhe==-2  

***************************************
* Special recoding: satisfaction not asked for proxy respondents
***************************************
replace satisfaction = . if satisfaction==-2  

***************************************
* Special recoding: lipidrx not asked for before wave 8
***************************************

replace lipidrx = . if lipidrx == -333

***************************************
* Special recoding: rxchol missing for earlier years
***************************************
*********************************************************************************
replace rxchol = . if rxchol == -333


***************************************
* Keep selected variables
***************************************
  keep $identifiers $demog $vcmatrix $timevariant $outcomeonly isret ssretbegyear iwbeg ssretflag clmwv proptax proptax_nonzero

******************************************
* Merge with TICS data
******************************************
merge 1:1 hhidpn wave using "$outdata/tics.dta", keepusing(cogstate selfmem)
tab cogstate wave, row
tab _merge
keep if _merge == 1 | _merge == 3
drop _merge

***************************************
* Save the data
***************************************
* Year
gen year = (wave - 1) * 2 + 1992

count

clonevar hhid_orig = hhid
clonevar hhidpn_orig = hhidpn


save "$outdata/hrs_selected.dta", replace

exit, STATA
