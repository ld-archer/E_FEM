use ELSA_core_cohort_append.dta, replace

bys hhidpn (year): keep if _n == _N

replace hhidpn = mod(-hhidpn, 1000000000)

summarize [aw=weight]

count if bmi < 25 & weight > 0

count if bmi >= 25 & bmi < 30  & weight > 0

count if bmi >= 30  & weight > 0

summ diabe [aw=weight]
summ cancre [aw = weight]
summ hearte [aw = weight]

* THIS IS THE IMPORTANT LINE THAT WE NEED FOR FIGURE 2!!!!!!
* It breaks down the disease stats by education and summarizes for each education level.
bys educ: summ diabe [aw=weight]
bys educ: summ cancre [aw=weight]
bys educ: summ hearte [aw=weight]
