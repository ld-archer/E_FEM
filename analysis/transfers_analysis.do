clear all
set mem 2500M
set maxvar 10000
set more off

include ../fem_env.do
global discount_rate 0.03
global qaly65 0.792
gen scenario = ""
foreach f in "depratios" {
  ** A script to calculate the life expectancy of a cohort simulation
  global cohort_dir "$local_root/output/`f'/detailed_output"
  
  ** Read in all the data files, dropping records dead for more than one timestep
  cd $cohort_dir
  shell ls *.dta > filelist.txt
  
  file open myfile using filelist.txt, read
  
  file read myfile line
  while r(eof)==0 {
    append using `line'
    drop if ldied
    replace scenario = "`f'" if scenario==""
    file read myfile line
  }
  
  file close myfile
}

cd "$local_root/analysis"

/* ADD COMENTED FIGURE DESCRIPTIONS */

hist qaly if nhmliv==0, bin(50) fraction
su qaly [fw = round(weight)] if qaly==1 & nhmliv==0
su qaly [fw = round(weight)] if nhmliv==0
su qaly [fw = round(weight)] if qaly<1 & nhmliv==0



/*** FIGURE:  Histogram of QoL for different age buckets */

hist qaly if age<55 [fw=round(weight)], name(panela, replace) nodraw fraction bin(25) yscale(range(0 .4))  ytick(0 .1 .2 .3 .4) ylabel(0 .1 .2 .3 .4)  xtick(.4 .5 .6 .7 .8 .9 1) xlabel(.4 .5 .6 .7 .8 .9 1) xtitle("QoL") title("51-54")
hist qaly if age>=55 & age<60 [fw=round(weight)], name(panelb, replace) nodraw fraction bin(25) yscale(range(0 .4)) ytick(0 .1 .2 .3 .4) ylabel(0 .1 .2 .3 .4)  xtick(.4 .5 .6 .7 .8 .9 1) xlabel(.4 .5 .6 .7 .8 .9 1) xtitle("QoL") title ("55-59")
hist qaly if age>=60 & age<65 [fw=round(weight)], name(panelc, replace) nodraw fraction bin(25) yscale(range(0 .4)) ytick(0 .1 .2 .3 .4) ylabel(0 .1 .2 .3 .4)  xtick(.4 .5 .6 .7 .8 .9 1) xlabel(.4 .5 .6 .7 .8 .9 1) xtitle("QoL") title("60-64")
hist qaly if age>=65 & age<70 [fw=round(weight)], name(paneld, replace) nodraw fraction bin(25) yscale(range(0 .4)) ytick(0 .1 .2 .3 .4) ylabel(0 .1 .2 .3 .4)  xtick(.4 .5 .6 .7 .8 .9 1) xlabel(.4 .5 .6 .7 .8 .9 1) xtitle("QoL") title("65-69")
hist qaly if age>=70 & age<75 [fw=round(weight)], name(panele, replace) nodraw fraction bin(25) yscale(range(0 .4)) ytick(0 .1 .2 .3 .4) ylabel(0 .1 .2 .3 .4)  xtick(.4 .5 .6 .7 .8 .9 1) xlabel(.4 .5 .6 .7 .8 .9 1) xtitle("QoL") title("70-74")
hist qaly if age>=75 & age<80 [fw=round(weight)], name(panelf, replace) nodraw fraction bin(25) yscale(range(0 .4)) ytick(0 .1 .2 .3 .4) ylabel(0 .1 .2 .3 .4)  xtick(.4 .5 .6 .7 .8 .9 1) xlabel(.4 .5 .6 .7 .8 .9 1) xtitle("QoL") title("75-79")
hist qaly if age>=80 & age<85 [fw=round(weight)], name(panelg, replace) nodraw fraction bin(25) yscale(range(0 .4)) ytick(0 .1 .2 .3 .4) ylabel(0 .1 .2 .3 .4)  xtick(.4 .5 .6 .7 .8 .9 1) xlabel(.4 .5 .6 .7 .8 .9 1) xtitle("QoL") title("80-84")
hist qaly if age>=85 [fw=round(weight)], name(panelh, replace) nodraw fraction bin(25) yscale(range(0 .4)) ytick(0 .1 .2 .3 .4) ylabel(0 .1 .2 .3 .4) xtick(.4 .5 .6 .7 .8 .9 1) xlabel(.4 .5 .6 .7 .8 .9 1) xtitle("QoL") title("85+")
graph combine panela panelb panelc paneld panele panelf panelg panelh, cols(3) imargin(tiny)

/*
hist qaly if age<55 [fw=round(weight)], name(panela, replace) nodraw fraction width(.04) yscale(range(0 .4))  ytick(0 .1 .2 .3 .4) ylabel(0 .1 .2 .3 .4)  xtick(0 .2 .4 .6 .8 1) xlabel(0 .2 .4 .6 .8 1) xtitle("QoL") title("51-54")
hist qaly if age>=55 & age<60 [fw=round(weight)], name(panelb, replace) nodraw fraction width(.04) yscale(range(0 .4)) ytick(0 .1 .2 .3 .4) ylabel(0 .1 .2 .3 .4)  xtick(0 .2 .4 .6 .8 1) xlabel(0 .2 .4 .6 .8 1) xtitle("QoL") title ("55-59")
hist qaly if age>=60 & age<65 [fw=round(weight)], name(panelc, replace) nodraw fraction width(.04) yscale(range(0 .4)) ytick(0 .1 .2 .3 .4) ylabel(0 .1 .2 .3 .4)  xtick(0 .2 .4 .6 .8 1) xlabel(0 .2 .4 .6 .8 1) xtitle("QoL") title("60-64")
hist qaly if age>=65 & age<70 [fw=round(weight)], name(paneld, replace) nodraw fraction width(.04) yscale(range(0 .4)) ytick(0 .1 .2 .3 .4) ylabel(0 .1 .2 .3 .4)  xtick(0 .2 .4 .6 .8 1) xlabel(0 .2 .4 .6 .8 1) xtitle("QoL") title("65-69")
hist qaly if age>=70 & age<75 [fw=round(weight)], name(panele, replace) nodraw fraction width(.04) yscale(range(0 .4)) ytick(0 .1 .2 .3 .4) ylabel(0 .1 .2 .3 .4)  xtick(0 .2 .4 .6 .8 1) xlabel(0 .2 .4 .6 .8 1) xtitle("QoL") title("70-74")
hist qaly if age>=75 & age<80 [fw=round(weight)], name(panelf, replace) nodraw fraction width(.04) yscale(range(0 .4)) ytick(0 .1 .2 .3 .4) ylabel(0 .1 .2 .3 .4)  xtick(0 .2 .4 .6 .8 1) xlabel(0 .2 .4 .6 .8 1) xtitle("QoL") title("75-79")
hist qaly if age>=80 & age<85 [fw=round(weight)], name(panelg, replace) nodraw fraction width(.04) yscale(range(0 .4)) ytick(0 .1 .2 .3 .4) ylabel(0 .1 .2 .3 .4)  xtick(0 .2 .4 .6 .8 1) xlabel(0 .2 .4 .6 .8 1) xtitle("QoL") title("80-84")
hist qaly if age>=85 [fw=round(weight)], name(panelh, replace) nodraw fraction width(.04) yscale(range(0 .4)) ytick(0 .1 .2 .3 .4) ylabel(0 .1 .2 .3 .4) xtick(0 .2 .4 .6 .8 1) xlabel(0 .2 .4 .6 .8 1) xtitle("QoL") title("85+")
graph combine panela panelb panelc paneld panele panelf panelg panelh, cols(3) imargin(tiny)
*/

/* Create age buckets */

egen agebucket = cut(age), at(50,55,60,65,70,75,80,85,999)

/* QOL BUCKETS FOR LINEAR QOL MODEL */
replace qaly = . if died
egen qolbucket = cut(qaly), at(0,0.55(0.05)0.85,1)

/*** QOL BUCKETS FOR TWO-STAGE QOL MODEL ***/
/*
gen qolbucket = 0
replace qolbucket = 1 if qaly ==1
replace qolbucket = 2 if qaly >= 0.75 & qaly < 1
replace qolbucket = 3 if qaly >= 0.7 & qaly < .75
replace qolbucket = 4 if qaly >= 0.65 & qaly < 0.7
replace qolbucket = 5 if qaly >= 0.60 & qaly < 0.65
replace qolbucket = 6 if qaly >= 0.55 & qaly < 0.6
replace qolbucket = 7 if qaly < 0.55
*/


/*** MEPS DEPENDENCY RATIO CALCULATIONS ***/
/* code to calculate MEPS dependency ratios */
/* local VAR = XX */



/*** FIGURE:  Prevalence of diseases/ADLs for different QoL levels ***/

/*** FIGURE:  Variation in QoL within age groups ***/

/*** FIGURE:  Bar chart of Medicare spending per QoL bucket, per age group, for Medicare eligible population only ***/
replace mcare = . if !medicare_eligibility

/*** FIGURE:  Bar chart of Medicare/Medicaid spending per QoL bucket, per age group, for entire population ***/
gen med_spending = mcare + caidmd

/*** FIGURE:  Bar chart of Medicare/Medicaid/SS/Federal income tax/FICA tax per QoL bucket, per age group, for entire population ***/
gen tax_collected = ftax + hmed + hoasi

/*** FIGURE:  Mean QoL for different age groups, from 2004 to 2050 - one series per age group ***/

tempfile details
keep qaly year weight scenario age cancre diabe hearte hibpe lunge stroke mcare qaly med_spending tax_collected agebucket qolbucket
save `details'

  collapse (mean) cancre diabe hearte hibpe lunge stroke mcare qaly med_spending tax_collected age (count) weight [fw=round(weight)], by(scenario year agebucket qolbucket)
save buckets, replace

/*** FIGURE:  Plot of dependency ratio trajectories for OADR, POADR, Quality of Life DR, from 2004 to 2050
 Need to calculate dependency for QLDR using MEPS ratios above; also first DL needs to calculate QoL
 threshold to use based on new QoL model (that uses all years of MEPS and */

  * read in census projections
clear
insheet using NP2008_D1.csv, comma
keep if hisp==0 & race==0 & sex==0
gen pop1864=0
gen pop1850=0
forvalues a=18/50 {
  replace pop1864 = pop1864 + pop_`a'
  replace pop1850 = pop1850 + pop_`a'
}
forvalues a=51/64 {
  replace pop1864 = pop1864 + pop_`a'
}
tempfile census
save `census'

use ../output/depratios/depratios_summary.dta
merge year using `census', sort

gen oadr = end_pop65p/pop1864

keep year oadr pop1864 pop1850
  save oadr.dta, replace

use `details', clear
merge year using oadr.dta, sort uniqusing

gen qolP = qaly >= $qaly65
gen qolN = qaly < $qaly65

collapse (sum) qolP qolN [fw=round(weight)], by(year scenario)
save fig6, replace

/*** FIGURE:  Lifetime levels of Medicare/Medicaid spending and years of life for 51-53 year olds for different QoL buckets ***/

  sort scenario mcrep hhidpn year
  gen calc_npv = 0
by scenario mcrep hhidpn: replace calc_npv = 1 if entry==2004 & inrange(age[1],51,53)

gen med_npv = med_spending * 1/(1 + $discount_rate)^(year - 2004)
gen mcare_npv = mcare * 1/(1 + $discount_rate)^(year-2004)
gen caidmd_npv = caidmd * 1/(1 + $discount_rate)^(year-2004)

by scenario mcrep hhidpn: egen c_med = total(med_npv) if calc_npv
by scenario mcrep hhidpn: egen c_mcare = total(mcare_npv) if calc_npv
by scenario mcrep hhidpn: egen c_caidmd = total(caidmd_npv) if calc_npv

tabstat c_* [fw=round(weight)] if calc_npv & year==2004, by(qolbucket)

/*** FIGURE:  Lifetime levels of Medicare/Medicaid/SS/Federal income tax/FICA spending and years of life for 51-53 year olds for different QoL buckets ***/

/*** CALCULATION:  # of people who are under QoL threshold (same one as used in dependency ratio calcs), 
not on Medicare or Medicaid or private health insurance - using MEPS data ***/


/* Check total Medicaid costs in 2004 in dataset - to compare to actual */
total mcare caidmd ssben ssiben diben [fw=round(weight)] if ldied==0 & died==0



table agebucket [fw=round(weight)], contents (mean qaly p10 qaly p50 qaly p90 qaly)


gen transfers = mcare + caidmd + ssben + ssiben + diben

keep if ldied==0

table qolbucket agebucket [fw=round(weight)] if medicare_elig==1, contents(mean mcare)

exit

table qolbucket agebucket, contents(mean caidmd)
table qolbucket agebucket, contents(mean ssben)
table qolbucket agebucket, contents(mean ssiben)
table qolbucket agebucket, contents(mean diben)
table qolbucket agebucket, contents (mean transfers)

table qolbucket agebucket if caidmd<0, contents(count caidmd)




/* Create age buckets */

replace agebucket = 0
replace agebucket = 1 if age >=51 & age < 64
replace agebucket = 2 if age >= 65


replace qolbucket = 0
replace qolbucket = 1 if qaly >= 0.80
replace qolbucket = 2 if qaly >= 0.75 & qaly < 0.80
replace qolbucket = 3 if qaly >= 0.70 & qaly < 0.75
replace qolbucket = 4 if qaly >= 0.65 & qaly < 0.7
replace qolbucket = 5 if qaly >= 0.60 & qaly < 0.65
replace qolbucket = 6 if qaly >= 0.55 & qaly < 0.6
replace qolbucket = 7 if qaly < 0.55

table qolbucket agebucket [fw=round(weight)], contents(mean mcare)
table qolbucket agebucket [fw=round(weight)], contents(mean caidmd)
table qolbucket agebucket [fw=round(weight)], contents(mean ssben)
table qolbucket agebucket [fw=round(weight)], contents(mean transfers)

table qolbucket agebucket [fw=round(weight)], contents(sum mcare)
table qolbucket agebucket [fw=round(weight)], contents(sum transfers)
table qolbucket agebucket [fw=round(weight)], contents(count transfers)

/* Create age buckets */

gen agebucket = 0
replace agebucket = 1 if age >=51 & age < 55
replace agebucket = 2 if age >= 55 & age < 60
replace agebucket = 3 if age >=60 & age < 65
replace agebucket = 4 if age >= 65 & age < 70
replace agebucket = 5 if age >= 70 & age < 75
replace agebucket = 6 if age >= 75 & age < 80
replace agebucket = 7 if age >= 80 & age < 85
replace agebucket = 8 if age >= 85

replace qolbucket = 0
replace qolbucket = 1 if qaly >= 0.80
replace qolbucket = 2 if qaly < 0.8

table qolbucket agebucket [fw=round(weight)], contents(mean mcare)
table qolbucket agebucket [fw=round(weight)], contents(mean caidmd)
table qolbucket agebucket [fw=round(weight)], contents(mean ssben)
table qolbucket agebucket [fw=round(weight)], contents(mean transfers)

table qolbucket agebucket [fw=round(weight)], contents(sum mcare)
table qolbucket agebucket [fw=round(weight)], contents(sum transfers)
table qolbucket agebucket [fw=round(weight)], contents(count transfers)

table qolbucket agebucket [fw=round(weight)], contents(count caidmd)


