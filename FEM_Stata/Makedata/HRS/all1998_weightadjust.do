/** \file

This is the file that adjusts the population weights to match expectations.

- March 2008, adjust population weight of the initial host dataset(with restricted variables)
- Sep 2008, more detailed estimation of the population by age group
- 9/8/2009 - Using age variable age 
 - Removed calculation of age splines
- 11/13/2012 - Use 1998 census population

*/

include common.do

local age_var "age_yrs"
local datain : env DATAIN
local dataout : env DATAOUT

tempvar drop _all


			/* Re-generate census population data by redefining age group */
			use "$outdata/population_projection_1998.dta", clear
			gen pop1000 = pop*1000
			drop pop
			ren pop1000 pop
			gen agenumeric = real(substr(age,1,3))
			replace agenumeric = real(substr(age,1,2)) if missing(agenumeric)
			keep if year == 1998 & agenumeric >= 51
			
			egen agec = cut(agenumeric), at(51,55,60,65,70,75,80,85,200)
			drop if missing(agec)
			drop if inlist(age, "55 to 59 years","60 to 64 years","65 years and over","85 years and over")
			tab agenumeric agec if agenumeric >= 51, m
			gen agegrp = agenumeric
			replace agegrp = agec if agenumeric >= 65 | racegrp == 4
			
			
			collapse (sum) pop, by(agegrp racegrp male)
			sort  agegrp racegrp male, stable
			tempfile pop98
			save `pop98', replace

			/* Use Human Mortality Database (HMD) for reweighting dead people by age and sex */
			use "$outdata/death_counts.dta",clear
			keep if inrange(year,1997,1998) & age >=51
			
			egen dagec = cut(age), at(51,55,60,65,70,75,80,85,90,95,200)
			tab age dagec if age >=51
			gen dagegrp = age
			replace dagegrp = dagec if age < 70 | age >= 95
			
			collapse (sum) count, by(dagegrp male)
			sort dagegrp male, stable
			tempfile died9798
			save `died9798', replace
		
		* Do the weight adjustment for the restricted data
		
		 use "`datain'", clear
		 
***************************************
* Spouses not interviewed, drop them and scale up the weights for other households
* First find which HH have an insamp person requiring a spouse
* Then remove the HH where that spouse is needed and not present
***************************************

		gen needs_live_sp = insamp & married & alive
		gen needs_sp =  insamp & married
		
		 * Count number of alive persons per HH
		bys hhid: egen Nalive = total(alive)
		
		* Re-count number of persons per household
		bys hhid: gen N = _N
		
		sum weight if (Nalive == 1 & needs_live_sp) | (N == 1 & needs_sp)
		local p1 = r(sum)
		sum weight if (Nalive == 2 & needs_live_sp) | (N == 2 & needs_sp)
		local p2 = r(sum)

		replace weight = weight * (`p1' + `p2')/`p2' if (Nalive == 2 & needs_live_sp) | (N == 2 & needs_sp)
		
		drop if (Nalive == 1 & needs_live_sp) | (N == 1 & needs_sp)
                drop needs_live_sp needs_sp
		 
		 * no sampling weights for younger than 51
		 replace weight = 0 if `age_var' < 51

		* Remove anyone in a HH with no insamp persons
		drop hhinsamp
		bys hhid: egen hhinsamp = total(insamp )
		drop if hhinsamp == 0
                drop hhinsamp

		 * Race/ethnicity
		 gen racegrp = 1 if hispan == 1 
		 replace racegrp = 2 if hispan == 0 & white == 1 
		 replace racegrp = 3 if hispan == 0 & black == 1
		 replace racegrp = 4 if hispan == 0 & white == 0 & black == 0

		egen agec = cut(`age_var'), at(51,55,60,65,70,75,80,85,200)
		gen agegrp = `age_var'
		replace agegrp = agec if `age_var' >= 65 | racegrp == 4
					 
		 * Sum of weights
		 bys agegrp racegrp male: egen sumwt = total(weight) if died == 0
		 sort agegrp racegrp male, stable
		 
		 *Sum of HH weights
		 *HH weight divided by 2 for couples
		 sort hhid hhidpn, stable
		 by hhid: replace wthh = wthh/2 if Nalive == 2
		 sort agegrp racegrp male, stable
		 
     * Merge with 1998 census projection
		 merge m:1 agegrp racegrp male using `pop98'
		 qui count if _merge == 2
		 
		 if r(N) > 0 {
		 	dis "Wrong, there are empty cells"
		 	exit(333)
		 }
		 drop _merge 
			 
                 qui sum weight if died == 0 & wave == 4
                 local oldsumwt = r(sum)

		 * Adjust the weights
		 replace weight = weight * pop / sumwt if `age_var' >= 51 & died == 0 & wave == 4
		 
		 * Adjust household weights too
		 qui sum weight
		 local newsumwt = r(sum)
		
		 dis "Original population size is: `oldsumwt'"
		 dis "Adjusted population size is: `newsumwt'"
		 
		 
		 * Average weight change per HH
		 bys hhid: egen oldwt = total(weight) 
		 bys hhid: egen newwt = total(weight)
		 replace wthh = wthh * newwt/oldwt
		 
		 
     		 drop oldwt newwt pop 
     		 label var wthh "Household weight"

			/*
		 * Recode HH ID and Person ID
			sort hhid hhidpn, stable
			by hhid: gen id = 1 if _n == 1
			replace id = sum(id)
			drop hhid
			gen hhid = id
			
			* Person ID
			sort hhid hhidpn, stable
		  	replace hhidpn = _n 
			*/

		egen dagec = cut(`age_var'), at(51,55,60,65,70,75,80,85,90,95,200)
		gen dagegrp = `age_var'
		replace dagegrp = dagec if `age_var' < 70 | `age_var' >= 95
					 
		 * Sum of weights
		 bys dagegrp male: egen dsumwt = total(weight) if `age_var' >= 51 & died == 1 & wave == 4
		 sort dagegrp male, stable
		 
     * Merge with 1998 death counts (target = 2,337,256)
		 merge m:1 dagegrp male using `died9798'
		 qui count if _merge == 2
		 
		 if r(N) > 0 {
		 	dis "Wrong, there are empty cells"
		 	exit(333)
		 }
		 drop _merge dagegrp dagec
			 
     qui sum weight if `age_var' >= 51 & died == 1 & wave == 4
     local doldsumwt = r(sum)

		 * Adjust the weights
		 replace weight = weight * count / dsumwt if `age_var' >= 51 & died == 1 & wave == 4 & dsumwt > 0
		 
		 qui sum weight if `age_var' >= 51 & died == 1 & wave == 4
		 local dnewsumwt = r(sum)
		
		 dis "Original death count is: `doldsumwt'"
		 dis "Adjusted death count is: `dnewsumwt'"
		 
		 drop count N Nalive dsumwt

     label data "Pop 51+ in 1998, population size adjusted to Census Bureau projection"
	save "`dataout'", replace

*exit, STATA

