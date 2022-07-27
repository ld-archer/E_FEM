/*
This script will backcast respondents to generate a value for the falcbase50 variable. This variable is supposed to represent a respondents alcohol consumption levels
immediately before they turn 50/51 and enter the survey. Lots of people join the survey after the age of 50/51, and so only a small proportion of people actually 
have consumption data for this age. 

Author: Luke Archer
Email:  l.archer@leeds.ac.uk
Date: 13/07/20
 */

 

*** STEPS:
* Organise into 5 year birth cohorts (maybe try 10 year if 5 year not working)
* Take percentiles of consumption level
* Assume that x percentile at age y would correspond with the same x percentile at age 50
* Include this newly constructed variable in transition models and evaluate if the impact is what we would expect

* Assuming that we are starting with ELSA_long.dta after creation of the falcbase50 var


** Get just the first wave that a person enters the survey
bys hhidpn: keep if _n == 1


** 5 year birth cohorts
*egen birth_cohort = cut(age), at(50,55,60,65,70,75,80,85,90,95,100,105,110)
egen birth_cohort = cut(rabyear), at(1897,1902,1907,1912,1917,1922,1927,1932,1937,1942,1947,1952)


** percentiles
/* * code for calculating percentiles within groups came from the following post:
* https://www.stata.com/support/faqs/statistics/percentile-ranks-and-plotting-positions/
by birth_cohort, sort: egen n = count(alcbase) if alcbase > 0
by birth_cohort: egen i = rank(alcbase) if alcbase > 0, track 
gen pcrank = (i - 1) / (n - 1)
* this returns a rank from 0-1, so for percentiles just multiple by 100
replace pcrank = pcrank * 100
* All alcbase == 0 values should also be the 0th percentile rank
replace pcrank = 0 if alcbase == 0
* round the pcrank to nearest integer
gen newPCrank = round(pcrank) */

** percentiles second go
xtile2 alcpct = alcbase , nq(100) by(male birth_cohort)

/*
** Assume people don't change percentile over life
* Then we can assign the same value for 80 year old in 50th percentile as a 50 year old in 50th percentile
forvalues x = 1/100 {
    *summarise to get the mean of alcbase for each percentile in the 50-55 year age group
    sum alcbase if newPCrank == `x' & birth_cohort == 50
    local alcb = r(mean)

    * Assign the 50-55 year age group mean for all ages within a percentile
    replace falcbase50 = `alcb' if newPCrank == `x'
}

* if pcrank == 0 then alcbase == 0, and falcbase50 should also == 0
replace falcbase50 = 0 if pcrank == 0


** Handle the abstainers separately
* This has come together from trial and error
* If the response in the first wave is alcbase == 0 (no alcohol in week before first survey) and drink == 0 (not drank in previous 12 months) then fdrink50 == 0
* Might need to consider those who are diagnosed with a chronic disease as a separate group as these people often change their consumption habits
replace fdrink50 = 0 if falcbase50 == 0 & drink == 0 & !missing(falcbase50) & !missing(drink)
replace fdrink50 = 1 if falcbase50 > 0 | drink > 0 & !missing(falcbase50) & !missing(drink)


* Keep some vars for merge with ELSA_long.dta
keep idauniq falcbase50 fdrink50 pcrank
