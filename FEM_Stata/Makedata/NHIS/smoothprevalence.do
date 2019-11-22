
 /*========================================*
 *Smooth Disease and overweight rates and obese rates
 *=======================================*/
clear
set more off
set seed 1234567


local agelow = 18
use "$outdata/nhis97plus_selected.dta"
keep if age >= `agelow' & inrange(year, $firstyear, $lastyear)

* Normalize weights by year
egen twt = total(wtfa_sa), by(year)
replace wtfa_sa = wtfa_sa / twt
drop twt

 /* Macro of estimating smooth function for each health conditions */
 
  capture program drop dsmooth
	program define dsmooth
      
      		`1' `2' lap* ylap* $ses [pweight=wtfa_sa]
		predict p`2' if `2' < .

end

/* Set age and year cutoffs and smooth parameters */		   

scalar smooth = 5 
scalar a1  = 35
scalar a2  = 45
scalar a3  = 55
scalar a4  = 65
scalar a5  = 75

scalar smooth2 = 0.5
scalar y1 = 1998
scalar y2 = 2000
scalar y3 = 2002
scalar y4 = 2004
scalar y5 = 2006
scalar y6 = 2008
scalar y7 = 2010


gen py0 = 1
gen py1 = normprob((year-y1)/smooth2)
gen py2 = normprob((year-y2)/smooth2)
gen py3 = normprob((year-y3)/smooth2)
gen py4 = normprob((year-y4)/smooth2)
gen py5 = normprob((year-y5)/smooth2)
gen py6 = normprob((year-y6)/smooth2)
gen py7 = 0 

gen p0 =1
gen p1 =normprob((age-a1)/smooth)
gen p2 =normprob((age-a2)/smooth)
gen p3 =normprob((age-a3)/smooth)
gen p4 =normprob((age-a4)/smooth)
gen p5 =normprob((age-a5)/smooth)
gen p6 = 0

gen ylap0 = py0-py1
gen ylap1 = py1-py2
gen ylap2 = py2-py3
gen ylap3 = py3-py4
gen ylap4 = py4-py5
gen ylap5 = py5-py6
gen ylap6 = py6-py7


gen lap0 = p0-p1
gen lap1 = p1-p2
gen lap2 = p2-p3
gen lap3 = p3-p4
gen lap4 = p4-p5
gen lap5 = p5-p6

/*
* Check the smoothness
egen agegrp = cut(age), at(25,35,45,55,65,75,200)
tabstat lap*, by(agegrp) stats(mean min max sd)
tabstat ylap*, by(year)  stats(mean min max sd)
*/

/* Smooth prevalence rates by calling the macro "dsmooth"  */

foreach v in $outcome {
	dsmooth logit `v'
}

* Collapse data 
keep if inrange(age, 25,52)
* gen sex = male + 1

collapse $poutcome [aw = wtfa_sa], by(year age)
label drop _all

keep if inrange(age,25,53)
sort year age, stable

* this is a temporary fix since the HMD data in the next step only has through 2009
keep if year < 2010

save "$outdata/pred.dta", replace

exit



