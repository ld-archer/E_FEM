/* This file will explore health gradients for workers at firms that did not offer insurance 

We analyze individual health outcomes and the PCS score:

The SF-12® contains 12 questions in which people are asked about the following topics:

1 Limitations in performing moderate physical activities, such as moving a table.
2 Limitations in climbing several flights of stairs.
3 Extent to which pain interfered with normal work.
4 Whether they accomplished less than they would like at work or other regular activity as a result of their physical health.
5 Whether they were limited in kind of work or other activities as a result of their physical health.
6 How often they felt calm and peaceful.
7 How often they felt downhearted and blue.
8 Whether they accomplished less than they would like at work or other regular activity as a result of emotional problems.
9 Whether they didn’t do work or other activities as carefully as usual as a result of emotional problems.
10 How often they felt that they had a lot of energy.
11 How often physical health or emotional problems interfered with social activities.
12 Overall rating of health (from excellent to poor).

Responses to these questions are combined to form two summary scores. The underlying concept is that overall health is composed 
of a physical and a mental component. The Physical Component Summary (PCS) weights responses to the first five items more heavily.

From: http://meps.ahrq.gov/data_files/publications/mr15/mr15.shtml

*/


quietly include ../fem_env.do

use $outdata/MEPS_cost_est.dta, replace

gen male_black = male*black
gen male_hispan = male*hispan
gen male_hsless = male*hsless

count
keep if age >=25 & age < 65
count

label var held31x "Held employer insurance 31"
label var held42x "Held employer insurance 42"
label var held53x "Held employer insurance 53"
label var offer31x "Employer offer health insurance 31"
label var offer42x "Employer offer health insurance 42"
label var offer53x "Employer offer health insurance 53"


*  -2 values mean that the previous response still holds
* "Question was not asked in round because there was no change in current main job since previous round"
replace held42x = held31x if held42x == -2
replace held53x = held42x if held53x == -2

replace offer42x = offer31x if offer42x == -2
replace offer53x = offer42x if offer53x == -2


foreach var of varlist held31x held42x held53x offer31x offer42x offer53x {
	recode `var' (1=1) (2=0) (-2=-2) (nonmissing=.) (missing=.)
	tab `var'
	tab prvev `var'
}

recode pcs42 (-1 = .) (-9 = .)
sum pcs42 [aw=perwt], detail

* self-reported health
foreach var of varlist rthlth31 rthlth42 rthlth53 {
	recode `var' (5=1) (4=2) (3=3) (2=4) (1=5) (nonmissing=.) (missing=.)
	label define `var' 1 "poor" 2 "fair" 3 "good" 4 "very good" 5 "excellent"
	label values `var' `var'
	tab `var'
}



* Populations of interest: employer does not offer insurance grouped into those who do and those who don't have private ins.
foreach val of numlist 31 42 53 {
	gen samp`val' = .
	replace samp`val' = 0 if prvev == 0 & offer`val'x == 0
	replace samp`val' = 1 if prvev == 1 & offer`val'x == 0
}

tab samp31 
tab samp42 
tab samp53

label var samp42 "private insurance"

bys samp31: sum pcs42 [aw=perwt]
bys samp42: sum pcs42 [aw=perwt]
bys samp53: sum pcs42 [aw=perwt]

* Full population
reg pcs42 age3034 age3539 age4044 age4549 age5054 age5559 age6064 male male_black male_hispan male_hsless black hispan hsless college widowed single [pw=perwt]
* Only those whose employers do not offer insurance with private insurance effect
local rhs age3034 age3539 age4044 age4549 age5054 age5559 age6064 male male_black male_hispan male_hsless black hispan hsless college widowed single samp42
reg pcs42 `rhs' if !missing(samp42) [pw=perwt]


* Particular health outcomes
foreach var of varlist cancre diabe hearte hibpe lunge stroke adl1p {
	bys samp42: sum `var' [aw=perwt]
	probit `var' `rhs' if !missing(samp42) [pw=perwt]
	margins, dydx(samp42)
}

* Self-reported health
tab rthlth42 samp42 [aw=perwt], col
reg rthlth42 `rhs' if !missing(samp42) [pw=perwt]
oprobit rthlth42 `rhs' if !missing(samp42) [pw=perwt]
margins, dydx(samp42) predict(outcome(1))
margins, dydx(samp42) predict(outcome(2))
margins, dydx(samp42) predict(outcome(3))
margins, dydx(samp42) predict(outcome(4))
margins, dydx(samp42) predict(outcome(5))

margins, at(samp42=(0/1)) predict(outcome(1))
margins, at(samp42=(0/1)) predict(outcome(2))
margins, at(samp42=(0/1)) predict(outcome(3))
margins, at(samp42=(0/1)) predict(outcome(4))
margins, at(samp42=(0/1)) predict(outcome(5))



capture log close
