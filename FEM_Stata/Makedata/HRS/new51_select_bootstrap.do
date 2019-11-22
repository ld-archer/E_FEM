/** \file
Prepare data for incoming cohort.

- 9/08/2009 - Use age in middle of year for age

\todo Move the fixed, othervar, and keepvar lists to fem_env.do

*/
include common.do

// The expansion factor controls how many copies of each record to make, which is handy
// when doing analyses on small sub populations
local expand : env EXPAND

use "$outdata/hrs_selected`bsamp'.dta", clear

***************************************
*Keep only wave 10 data
***************************************
	keep if (iwstat == 1 & wave == 10)
	* Keep only Households with at least one individual aged 51 and over, treat partners as spouses	
	* Any household members 51/52
	bys hhid: egen insamp = total(inrange(age_yrs,51,52) & ((weight > 0 & weight < .)))
	
	sum insamp
	if r(max)>2 {
		dis "Wrong, at most 2 individuals per HH"
	}
	
	keep if insamp == 1 | insamp == 2 
	drop insamp
	replace weight = 0 if !inrange(age_yrs,51,52)

	* No one claims SS
	cap drop ssclaim
	gen ssclaim = 0
	
	* No one claims DB
	cap drop dbclaim
	gen dbclaim = 0

	* First year claiming SS benefits
	cap drop rssclyr
	gen rssclyr = 2100
				
	* First year claiming DB benefits
	cap drop rdbclyr
	gen rdbclyr = 2100 
					
	global fixed black hispan male black hispan hsless college single widowed rbyr lunge cancre stroke fkids bornus
	global othervar age_yrs age white married ssclaim dbclaim rssclyr rdbclyr died iwstat iadlstat adlstat proptax proptax_nonzero tcamt
	global bryvar catholic jewish reloth relnone suburb exurb gkcarehrs volhours kid_byravg kid_mnage nkid_liv10mi helphoursyr helphoursyr_sp helphoursyr_nonsp parhelphours
	global keepvar hhid hhidpn hacohort weight wthh $fixed $othervar $bryvar
	
	keep $keepvar 
	
	foreach v of varlist $keepvar {
			drop if missing(`v')
	}

* Drop those married but without spouses
	bys hhid: gen N = _N
	sum weight if N == 1 & married
	local p1 = r(sum)
	sum weight if N == 2 & married
	local p2 = r(sum)
	
	replace weight = weight * (`p1' + `p2')/`p2' if N == 2 & married
	replace wthh = wthh * (`p1' + `p2')/`p2' if N == 2 & married
	
	drop if N == 1 & married
			
	* Adjust population weight
	gen year = 2010
	sort year male hispan black, stable
	merge year male hispan black using "$indata/pop5152_projection_2080.dta"
	tab _merge
	keep if _merge == 3
  
	sort male hispan black, stable
	by male hispan black: egen twt = total(weight)
	replace weight = weight * pop/twt
	replace wthh = wthh/2
	replace wthh = wthh * pop/twt

	* Recode HH ID and Person ID
	sort hhid hhidpn, stable
	by hhid: gen id = 1 if _n == 1
	replace id = sum(id)
	drop hhid
	gen hhid = id
	drop id
	
	* Person ID
	sort hhid hhidpn, stable

*multiply_persons `expand'

	sum weight
	dis r(sum)

	dis "Population size for aged 51/52 in year 2010 is: `r(sum)'"
	sum wthh
	dis r(sum)
	
	save "$outdata/incoming_base`bsamp'.dta", replace	
	
*exit, STATA
