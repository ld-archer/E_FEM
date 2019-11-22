/** \file

This is the file that adjusts the population weights to match expectations.

- March 2008, adjust population weight of the initial host dataset(with restricted variables)
- Sep 2008, more detailed estimation of the population by age group
- 9/8/2009 - Using age variable age 
 - Removed calculation of age splines
*/
include common.do

local age_var age_yrs
local datain : env DATAIN
local dataout : env DATAOUT
local bsamp : env BREP
 
tempvar drop _all

			/* Re-generate census population data by redefining age group */
			use "$outdata/population_projection.dta", clear
			keep if year == 2004 & age >= 51
			
			egen agec = cut(age), at(51,55,60,65,70,75,80,85,200)
			tab age agec if age >= 51, m
			gen agegrp = age
			*replace agegrp = agec if age >= 65 | racegrp == 4
			*replace agegrp = agec if age >= 80 | racegrp == 4
			replace agegrp = agec if age >= 75 | racegrp == 4
			
			collapse (sum) pop, by( agegrp racegrp male)
			sort  agegrp racegrp male, stable
			tempfile pop04
			save `pop04', replace

			/* Use Human Mortality Database (HMD) for reweighting dead people by age and sex */
			use "$outdata/death_counts.dta",clear
			keep if inrange(year,2003,2004) & age >=51
			
			egen dagec = cut(age), at(51,55,60,65,70,75,80,85,90,95,200)
			tab age dagec if age >=51
			gen dagegrp = age
			replace dagegrp = dagec if age < 70 | age >= 95
			
			collapse (sum) count, by(dagegrp male)
			sort dagegrp male, stable
			tempfile died0304
			save `died0304', replace			
				
		* Do the weight adjustment for the restricted data

if missing("`bsamp'") {
		 use "`datain'", clear
}
else {
		 use "$outdata/input_rep`bsamp'/all2004.dta", clear
}
		 
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
		bys hhid: egen hhinsamp = total(insamp )
		drop if hhinsamp == 0
                drop hhinsamp

		 * Recode age group
		 /*
		 gen agegrp = 1 if inrange(age,51,64)
		 replace agegrp = 2 if inrange(age, 65, 74)
		 replace agegrp = 3 if age >= 75 
		 */
		 
		 * Race/ethnicity
		 gen racegrp = 1 if hispan == 1 
		 replace racegrp = 2 if hispan == 0 & white == 1 
		 replace racegrp = 3 if hispan == 0 & black == 1
		 replace racegrp = 4 if hispan == 0 & white == 0 & black == 0

		egen agec = cut(`age_var'), at(51,55,60,65,70,75,80,85,200)
		gen agegrp = `age_var'
		*replace agegrp = agec if `age_var' >= 65 | racegrp == 4
		*replace agegrp = agec if `age_var' >= 80 | racegrp == 4
		replace agegrp = agec if `age_var' >= 75 | racegrp == 4
				 
		 * Sum of weights
		 bys agegrp racegrp male: egen sumwt = total(weight) if died == 0
		 sort agegrp racegrp male, stable
		 
		 *Sum of HH weights
		 *HH weight divided by 2 for couples
		 sort hhid hhidpn, stable
		 by hhid: replace wthh = wthh/2 if Nalive == 2
		 sort agegrp racegrp male, stable
		 
     * Merge with 2004 census projection
		 merge m:1 agegrp racegrp male using `pop04'
		 *merge agegrp racegrp male using `pop04'
		 count if _merge == 2
		 *qui count if _merge == 2
		 		 
		 list agegrp racegrp male if _merge==2
		 
		 if r(N) > 0 {
		 	dis "Wrong, there are empty cells"
		 	exit(333)
		 }
		 drop _merge 
			 
                 qui sum weight if died == 0 
                 local oldsumwt = r(sum)

		 * Adjust the weights
		 replace weight = weight * pop / sumwt if `age_var' >= 51 & died == 0 
		 
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
		 bys dagegrp male: egen dsumwt = total(weight) if `age_var' >= 51 & died == 1 & wave == 7
		 sort dagegrp male, stable
		 
     * Merge with 2004 death counts (target = 2,102,067)
		 merge m:1 dagegrp male using `died0304'
		 qui count if _merge == 2
		 
		 if r(N) > 0 {
		 	dis "Wrong, there are empty cells"
		 	exit(333)
		 }
		 drop _merge dagegrp dagec
			 
     qui sum weight if `age_var' >= 51 & died == 1 & wave == 7
     local doldsumwt = r(sum)


		 * Adjust the weights
		 replace weight = weight * count / dsumwt if `age_var' >= 51 & died == 1 & wave == 7 & dsumwt > 0
		 
		 qui sum weight if `age_var' >= 51 & died == 1 & wave == 7
		 local dnewsumwt = r(sum)
		
		 dis "Original death count is: `doldsumwt'"
		 dis "Adjusted death count is: `dnewsumwt'"
	 
		 drop count N Nalive dsumwt hhid_orig hhidpn_orig


     label data "Pop 51+ in 2004, population size adjusted to Census Bureau projection"
if missing("`bsamp'") {	
	save "`dataout'", replace
}
else {
	save "$outdata/input_rep`bsamp'/all2004_pop_adjusted.dta", replace
}
