/** \file

- March 2008, adjust population weight of the initial host dataset(with restricted variables)
- Sep 2008, more detailed estimation of the population by age group

\todo Figure out if this file is still required.

\deprecated This seems to have been replaced by all2004_weightadjust.do

*/

		/* Re-generate census population data by redefining age group */
		use "$indata/population_projection.dta", clear
		keep if year == 2004 & age >= 51
		
		egen agec = cut(age), at(51,55,60,65,70,75,80,85,200)
		tab age agec if age >= 51, m
		gen agegrp = age
		replace agegrp = agec if age >= 80 | racegrp == 4
		
		collapse (sum) pop, by( agegrp racegrp male)
		sort  agegrp racegrp male, stable
		tempfile pop04
		save `pop04', replace

		use "$dua_rand_hrs/all2004r.dta", clear

		* Remove those married but with only one observation
		 cap drop N
		 bys hhid: gen N = _N
		 tab married N
		 drop if married == 1 & N == 1
		 drop N
		 
		 * no sampling weights for younger than 51
		 replace weight = 0 if age75l < 51
		 
		 * Recode age group
		 /*
		 gen agegrp = 1 if inrange(age75l,51,64)
		 replace agegrp = 2 if inrange(age75l, 65, 74)
		 replace agegrp = 3 if age75l == 75 
		 */

		 * Race/ethnicity
		 gen racegrp = 1 if hispan == 1 
		 replace racegrp = 2 if hispan == 0 & white == 1 
		 replace racegrp = 3 if hispan == 0 & black == 1
		 replace racegrp = 4 if hispan == 0 & white == 0 & black == 0
		 
			egen agec = cut(age), at(51,55,60,65,70,75,80,85,200)
			gen agegrp = age
			replace agegrp = agec if age >= 80 | racegrp == 4
				 
		 * Sum of weights
		 bys agegrp racegrp male: egen sumwt = total(weight)
		 sort agegrp racegrp male, stable
		 
		 *Sum of HH weights
		 *HH weight divided by 2 for couples
		 sort hhid hhidpn, stable
		 by hhid: replace wthh = wthh/2 if _N == 2
		 sort agegrp racegrp male, stable
		 
     * Merge with 2004 census projection
     * Those younger than age 51 will not be matched
		 * merge agegrp racegrp male using "$outdata/pop2004_51p.dta"
		 merge agegrp racegrp male using `pop04'
		 qui count if _merge == 2
		 
		 if r(N) > 0 {
		 	dis "Wrong, there are empty cells"
		 	exit(333)
		 }
		 drop _merge 
		 * Adjust the weights
		 replace weight = weight * pop / sumwt
		 
		 * Adjust household weights too
		 qui sum weight
		 local newsumwt = r(sum)
		 qui sum weight
		 local oldsumwt = r(sum)
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
			
	   drop agegrp
     label data "Pop 51+ in 2004, population size adjusted to Census Bureau projection"
		 save "$dua_rand_hrs/all2004r_pop_adjusted", replace

		 
		 





