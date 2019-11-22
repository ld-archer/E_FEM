
clear
cap clear mata
set more off
set seed 52432
set maxvar 10000
est drop _all

include "../../fem_env.do"
global ster    				"$local_path/Estimates/HRS"

cap install xml_tab

cap log close
log using "qaly_estimations.log", replace
dis "Current time is: " c(current_time) " on " c(current_date)


use $outdata/hrs_analytic_recoded, clear

* Sample selection
keep if wave >= 4

/* Calculate the age bucket-specific mean srh values */
egen agecat_weight = total(wtresp) if nhmliv==0, by(agecat)
egen agecat_srh = total(srh * wtresp) if nhmliv==0, by(agecat)
gen mean_srh_hrs_agecat = agecat_srh/agecat_weight if nhmliv==0 & !missing(agecat) & !missing(srh)
drop agecat_*
  
/* Merge in the MEPS-specific srh values */
merge agecat using "$outdata/meps_mean_srh_agecat.dta", sort uniqusing keep(mean_srh_meps_agecat) nokeep
drop _merge

/* Calculate the ratios of srh per age category */
gen srh_ratio = mean_srh_hrs_agecat / mean_srh_meps_agecat

keep agecat srh_ratio
collapse (first) srh_ratio, by(agecat)

save $outdata/srh_ratio, replace

use $outdata/MEPS_EQ5D, clear
keep if age>= 51
merge agecat using $outdata/srh_ratio, sort uniqusing keep(srh_ratio) nokeep
drop _merge

keep if eq5d>=0 & eq5d<=1 & eq5d ~= .

/* Plot original weighted histogram of EQ5D values and calculate statistics */
hist eq5d [fw = round(perwt)], bin(50)
su eq5d [fw = round(perwt)] if eq5d==1
su eq5d [fw = round(perwt)]

hist eq5d if age<55 [fw=round(perwt)], name(panela, replace) nodraw fraction bin(25) yscale(range(0 .4))  ytick(0 .1 .2 .3 .4) ylabel(0 .1 .2 .3 .4)  xtick(0 .2 .4 .6 .8 1) xlabel(0 .2 .4 .6 .8 1) xtitle("QoL") title("51-54")
hist eq5d if age>=55 & age<60 [fw=round(perwt)], name(panelb, replace) nodraw fraction bin(25) yscale(range(0 .4)) ytick(0 .1 .2 .3 .4) ylabel(0 .1 .2 .3 .4)  xtick(0 .2 .4 .6 .8 1) xlabel(0 .2 .4 .6 .8 1) xtitle("QoL") title ("55-59")
hist eq5d if age>=60 & age<65 [fw=round(perwt)], name(panelc, replace) nodraw fraction bin(25) yscale(range(0 .4)) ytick(0 .1 .2 .3 .4) ylabel(0 .1 .2 .3 .4)  xtick(0 .2 .4 .6 .8 1) xlabel(0 .2 .4 .6 .8 1) xtitle("QoL") title("60-64")
hist eq5d if age>=65 & age<70 [fw=round(perwt)], name(paneld, replace) nodraw fraction bin(25) yscale(range(0 .4)) ytick(0 .1 .2 .3 .4) ylabel(0 .1 .2 .3 .4)  xtick(0 .2 .4 .6 .8 1) xlabel(0 .2 .4 .6 .8 1) xtitle("QoL") title("65-69")
hist eq5d if age>=70 & age<75 [fw=round(perwt)], name(panele, replace) nodraw fraction bin(25) yscale(range(0 .4)) ytick(0 .1 .2 .3 .4) ylabel(0 .1 .2 .3 .4)  xtick(0 .2 .4 .6 .8 1) xlabel(0 .2 .4 .6 .8 1) xtitle("QoL") title("70-74")
hist eq5d if age>=75 & age<80 [fw=round(perwt)], name(panelf, replace) nodraw fraction bin(25) yscale(range(0 .4)) ytick(0 .1 .2 .3 .4) ylabel(0 .1 .2 .3 .4)  xtick(0 .2 .4 .6 .8 1) xlabel(0 .2 .4 .6 .8 1) xtitle("QoL") title("75-79")
hist eq5d if age>=80 & age<85 [fw=round(perwt)], name(panelg, replace) nodraw fraction bin(25) yscale(range(0 .4)) ytick(0 .1 .2 .3 .4) ylabel(0 .1 .2 .3 .4)  xtick(0 .2 .4 .6 .8 1) xlabel(0 .2 .4 .6 .8 1) xtitle("QoL") title("80-84")
hist eq5d if age>=85 [fw=round(perwt)], name(panelh, replace) nodraw fraction bin(25) yscale(range(0 .4)) ytick(0 .1 .2 .3 .4) ylabel(0 .1 .2 .3 .4) xtick(0 .2 .4 .6 .8 1) xlabel(0 .2 .4 .6 .8 1) xtitle("QoL") title("85+")
graph combine panela panelb panelc paneld panele panelf panelg panelh, cols(3) imargin(tiny)


gen agebucket = 0
replace agebucket = 1 if age >=51 & age < 55
replace agebucket = 2 if age >= 55 & age < 60
replace agebucket = 3 if age >=60 & age < 65
replace agebucket = 4 if age >= 65 & age < 70
replace agebucket = 5 if age >= 70 & age < 75
replace agebucket = 6 if age >= 75 & age < 80
replace agebucket = 7 if age >= 80 & age < 85
replace agebucket = 8 if age >= 85

* EQ5D from 2004 algorithm
table agebucket [fw=round(perwt)], contents (mean eq5d p10 eq5d p50 eq5d p90 eq5d)
* EQ5D from 2010 algorithm
table agebucket [fw=round(perwt)], contents (mean eq5d_median p10 eq5d_median p50 eq5d_median p90 eq5d_median)

gen srh_hrs = srh * srh_ratio
replace srh_hrs = 5 if srh_hrs > 5
replace srh_hrs = 1 if srh_hrs < 1


/* Create the interaction term between srh_hrs and age>=75 */
gen srh_hrs_75p = srh_hrs
replace srh_hrs_75p = 0 if age<75

/* Rename the MEPS variables to HRS conventions */
gen widowed = marry==2
gen single = inlist(marry, 3, 4, 5, 6)

/* Merge in the health variables */
  merge dupersid yr using "$outdata/MEPS_cost_est.dta", uniqmaster keep(cancre diabe hibpe hearte lunge stroke hearta) sort nokeep
drop _merge


/* Create self-reported mental health variables just to test its effect on predictive power */
gen srmh = mnhlth53
gen srmh2 = 0
replace srmh2 = 1 if srmh==2
gen srmh3 = 0
replace srmh3 = 1 if srmh==3
gen srmh4 = 0
replace srmh4 = 1 if srmh==4
gen srmh5 = 0
replace srmh5 = 1 if srmh==5

/* Create new cognitive limitations variable */
gen memrye = 0
replace memrye = 1 if coglim53 == 1

/* Create overweight variable */
gen overwt = 0
replace overwt = 1 if bmindx53 >= 25.0 & bmindx53 < 30

/* Create obesity variable */
gen obese = 0
replace obese = 1 if bmindx53 >= 30

/* Create smoking variable */
gen smoken = 0
replace smoken = 1 if adsmok42 == 1

/* Create eq5d=1 indicator variable */
gen eq5d1 = 0
replace eq5d1 = 1 if eq5d == 1


/* Generate summary statistics on regressors */
tab srh2 if srh2 ~= . [fw=round(perwt)]
tab srh3 if srh3 ~= . [fw=round(perwt)]
tab srh4 if srh4 ~= . [fw=round(perwt)]
tab srh5 if srh5 ~= . [fw=round(perwt)]
tab adlhelp if adlhelp ~= . [fw=round(perwt)]
tab iadlhelp if iadlhelp ~= . [fw=round(perwt)]
tab cancre if cancre ~= . [fw=round(perwt)]
tab diabe if diabe ~= . [fw=round(perwt)]
tab hibpe if hibpe ~= . [fw=round(perwt)]
tab hearte if hearte ~= . [fw=round(perwt)]
tab lunge if lunge ~= . [fw=round(perwt)]
tab stroke if stroke ~= . [fw=round(perwt)]
tab single if single ~= . [fw=round(perwt)]
tab widowed if widowed ~= . [fw=round(perwt)]
tab memrye if memrye ~= . [fw=round(perwt)]
tab overwt if overwt ~= . [fw=round(perwt)]
tab obese if obese ~= . [fw=round(perwt)]
tab smoken if smoken ~= . [fw=round(perwt)]

/* Drop cases with missing values for any single regressor */
keep if srh == 1 | srh == 2 | srh == 3 | srh == 4 | srh == 5
keep if eq5d>=0 & eq5d<=1 & eq5d ~= .
keep if coglim53 ~= -8 & coglim53 ~= -1
keep if bmindx53 ~= -9 & bmindx53 ~= -1
keep if adsmok42 ~= -9 & adsmok42 ~= -1
keep if adlhelp ~= .
keep if iadlhelp ~= .


* Explore interactions
gen cancre_diabe    = cancre*diabe 
gen cancre_hibpe    = cancre*hibpe 
gen cancre_hearte   = cancre*hearte
gen cancre_lunge    = cancre*lunge 
gen cancre_stroke   = cancre*stroke
gen diabe_hibpe     = diabe*hibpe  
gen diabe_hearte    = diabe*hearte 
gen diabe_lunge     = diabe*lunge  
gen diabe_stroke    = diabe*stroke 
gen hibpe_hearte    = hibpe*hearte 
gen hibpe_lunge     = hibpe*lunge  
gen hibpe_stroke    = hibpe*stroke 
gen hearte_lunge    = hearte*lunge 
gen hearte_stroke   = hearte*stroke
gen lunge_stroke    = lunge*stroke 

gen adlhelp_iadlhelp = adlhelp*iadlhelp

gen adlhelp_cancre   = adlhelp*cancre  
gen adlhelp_diabe    = adlhelp*diabe   
gen adlhelp_hearte   = adlhelp*hearte  
gen adlhelp_hibpe    = adlhelp*hibpe   
gen adlhelp_lunge    = adlhelp*lunge   
gen adlhelp_stroke   = adlhelp*stroke  
gen iadlhelp_cancre  = iadlhelp*cancre 
gen iadlhelp_diabe   = iadlhelp*diabe  
gen iadlhelp_hearte  = iadlhelp*hearte 
gen iadlhelp_hibpe   = iadlhelp*hibpe  
gen iadlhelp_lunge   = iadlhelp*lunge  
gen iadlhelp_stroke  = iadlhelp*stroke 

gen hearta_stroke    = hearta*stroke
gen hearta_diabe     = hearta*diabe


local rhs srh2_l75 srh3_l75 srh4_l75 srh5_l75 srh_hrs_75p adlhelp iadlhelp cancre diabe hibpe hearte lunge stroke /*memrye*/ hearta obese smoken single widowed

#d ;
local rhs2
cancre_diabe       
cancre_hibpe       
cancre_hearte      
cancre_lunge       
cancre_stroke      
diabe_hibpe        
diabe_hearte       
diabe_lunge        
diabe_stroke       
hibpe_hearte       
hibpe_lunge        
hibpe_stroke       
hearte_lunge       
hearte_stroke      
lunge_stroke
adlhelp_iadlhelp
adlhelp_cancre 
adlhelp_diabe  
adlhelp_hearte 
adlhelp_hibpe  
adlhelp_lunge  
adlhelp_stroke 
iadlhelp_cancre
iadlhelp_diabe 
iadlhelp_hearte
iadlhelp_hibpe 
iadlhelp_lunge 
iadlhelp_stroke
hearta_stroke
hearta_diabe
;       
#d cr

/* EQ5D MEPS REGRESSION */
/* Using hybrid approach:  Indicator variables for age<75, and the adjusted single variable for age>=75 */
regress eq5d `rhs'  [pw=perwt]
est store eq5d
* Model with interactions
regress eq5d `rhs' `rhs2' [pw=perwt]
est store eq5d2

* Regress 2010 EQ5D algorithm outcome
regress eq5d_median `rhs' [pw=perwt]
est store eq5d_median
* Regress 2010 EQ5D algorithm outcome with interactions
regress eq5d_median `rhs' `rhs2' [pw=perwt]
est store eq5d_median2


/******* BEGIN USE OF HRS DATA *********/
use "$outdata/hrs_analytic_recoded.dta", clear

* Sample selection
keep if wave >= 4

forvalues i=1/5 {
  gen srh`i' = srh==`i'
}

forvalues i=2/5 {
  gen srh`i'_l75 = srh`i' * (age < 75)
}
gen srh_hrs_75p = srh * (age >= 75)

gen iadl1 = iadlstat==2 if !missing(iadlstat)
gen iadl2p = iadlstat==3 if !missing(iadlstat)

gen adl1 = adlstat==2 if !missing(adlstat)
gen adl2 = adlstat==3 if !missing(adlstat)
gen adl3p = adlstat==4 if !missing(adlstat)



/* Generate summary statistics on regressors */
tab srh2 if srh2 ~= . & nhmliv == 0  [fw=round(wtresp)]
tab srh3 if srh3 ~= . [aw=round(wtresp)]
tab srh4 if srh4 ~= .  [aw=round(wtresp)]
tab srh5 if srh5 ~= .  [aw=round(wtresp)]
tab adlhelp if adlhelp ~= . & nhmliv == 0  [aw=round(wtresp)]
tab iadlhelp if iadlhelp ~= .  [aw=round(wtresp)]
tab cancre if cancre ~= .  [aw=round(wtresp)]
tab hearta if hearta ~= .  [aw=round(wtresp)]
tab diabe if diabe ~= .  [aw=round(wtresp)]
tab hibpe if hibpe ~= .  [aw=round(wtresp)]
tab hearte if hearte ~= .  [aw=round(wtresp)]
tab lunge if lunge ~= .  [aw=round(wtresp)]
tab stroke if stroke ~= .  [aw=round(wtresp)]
tab single if single ~= .  [aw=round(wtresp)]
tab widowed if widowed ~= .  [aw=round(wtresp)]
tab memrye if memrye ~= .  [aw=round(wtresp)]
tab obese if obese ~= .  [aw=round(wtresp)]
tab smoken if smoken ~= .  [aw=round(wtresp)]

* Explore interactions
gen cancre_diabe    = cancre*diabe 
gen cancre_hibpe    = cancre*hibpe 
gen cancre_hearte   = cancre*hearte
gen cancre_lunge    = cancre*lunge 
gen cancre_stroke   = cancre*stroke
gen diabe_hibpe     = diabe*hibpe  
gen diabe_hearte    = diabe*hearte 
gen diabe_lunge     = diabe*lunge  
gen diabe_stroke    = diabe*stroke 
gen hibpe_hearte    = hibpe*hearte 
gen hibpe_lunge     = hibpe*lunge  
gen hibpe_stroke    = hibpe*stroke 
gen hearte_lunge    = hearte*lunge 
gen hearte_stroke   = hearte*stroke
gen lunge_stroke    = lunge*stroke 

gen adlhelp_iadlhelp = adlhelp*iadlhelp

gen adlhelp_cancre   = adlhelp*cancre  
gen adlhelp_diabe    = adlhelp*diabe   
gen adlhelp_hearte   = adlhelp*hearte  
gen adlhelp_hibpe    = adlhelp*hibpe   
gen adlhelp_lunge    = adlhelp*lunge   
gen adlhelp_stroke   = adlhelp*stroke  
gen iadlhelp_cancre  = iadlhelp*cancre 
gen iadlhelp_diabe   = iadlhelp*diabe  
gen iadlhelp_hearte  = iadlhelp*hearte 
gen iadlhelp_hibpe   = iadlhelp*hibpe  
gen iadlhelp_lunge   = iadlhelp*lunge  
gen iadlhelp_stroke  = iadlhelp*stroke 

gen hearta_stroke    = hearta*stroke
gen hearta_diabe     = hearta*diabe 

est restore eq5d
predict qaly

local rhs iadl1 iadl2p adl1 adl2 adl3p cancre diabe hearte hibpe lunge stroke hearta smoken obese single widowed

* Main qaly model estimation
regress qaly `rhs' [aw=wtresp]
eststo qaly
est save "$ster/qaly.ster", replace

* Model with interactions
est restore eq5d2
predict qaly2

* Exploring 2010 eq5d scoring algorith 
est restore eq5d_median
predict qaly_2010
regress qaly_2010 `rhs' [aw=wtresp]
eststo qaly_2010
* est save "$ster/qaly.ster", replace

* Model with interactions
est restore eq5d_median2
predict qaly_2010_2


gen agebucket = 0
replace agebucket = 1 if age >=51 & age < 55
replace agebucket = 2 if age >= 55 & age < 60
replace agebucket = 3 if age >=60 & age < 65
replace agebucket = 4 if age >= 65 & age < 70
replace agebucket = 5 if age >= 70 & age < 75
replace agebucket = 6 if age >= 75 & age < 80
replace agebucket = 7 if age >= 80 & age < 85
replace agebucket = 8 if age >= 85


* See how we did in predicting the HRS
* Initial specification
table agebucket [fw=round(wtresp)], contents (mean qaly p10 qaly p50 qaly p90 qaly)
table agebucket [fw=round(wtresp)], contents (p1 qaly p5 qaly)
* Disease interactions
table agebucket [fw=round(wtresp)], contents (mean qaly2 p10 qaly2 p50 qaly2 p90 qaly2)
table agebucket [fw=round(wtresp)], contents (p1 qaly2 p5 qaly2)

* 2010 algorithm
table agebucket [fw=round(wtresp)], contents (mean qaly_2010 p10 qaly_2010 p50 qaly_2010 p90 qaly_2010)
table agebucket [fw=round(wtresp)], contents (p1 qaly_2010 p5 qaly_2010)

* 2010 algorithm, disease interactions
table agebucket [fw=round(wtresp)], contents (mean qaly_2010_2 p10 qaly_2010_2 p50 qaly_2010_2 p90 qaly_2010_2)
table agebucket [fw=round(wtresp)], contents (p1 qaly_2010_2 p5 qaly_2010_2)

sum qaly [aw=wtresp], detail
sum qaly2 [aw=wtresp], detail
sum qaly_2010 [aw=wtresp], detail
sum qaly_2010_2 [aw=wtresp], detail

xml_tab qaly, save($ster/qaly.xls) replace pvalue

drop _all

set obs 2
gen iadl1   = 0
gen iadl2p  = _n-1
gen adl1    = 0
gen adl2    = 0
gen adl3p   = _n-1
gen cancre  = _n-1
gen diabe   = _n-1
gen hearte  = _n-1
gen hibpe   = _n-1
gen lunge   = _n-1
gen stroke  = _n-1
gen hearta  = _n-1
gen smoken  = _n-1
gen obese   = _n-1
gen single  = _n-1
gen widowed = _n-1


est restore qaly
predict p_qaly

est restore qaly_2010
predict p_qaly_2010

list


