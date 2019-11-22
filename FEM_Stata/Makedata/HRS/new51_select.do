/** \file
Prepare data for incoming cohort.

- 9/08/2009 - Use age in middle of year for age
- 5/13/2014 - Use 2012 population projections.

*/
include common.do

// The expansion factor controls how many copies of each record to make, which is handy
// when doing analyses on small sub populations
local expand : env EXPAND
local datain : env DATAIN
local dataout : env DATAOUT
local bsamp : env BREP

if missing("`bsamp'") {
	use "`datain'", clear
}
else {
	use "$outdata/input_rep`bsamp'/hrs_selected.dta", clear
}

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
					

	global keepvar hhid_orig hhidpn_orig $demog $identifiers $timevariant $vcmatrix cogstate selfmem
	
	keep $keepvar proptax proptax_nonzero
	
* Drop those married but without spouses
	bys hhid: gen N = _N
	count
	sum weight if N == 1 & married
	local p1 = r(sum)
	sum weight if N == 2 & married
	local p2 = r(sum)
	
	replace weight = weight * (`p1' + `p2')/`p2' if N == 2 & married
	replace wthh = wthh * (`p1' + `p2')/`p2' if N == 2 & married
	
	drop if N == 1 & married
        drop N

	* Adjust population weight
	gen year = 2010
	sort year male hispan black, stable
	merge year male hispan black using "$outdata/pop5152_projection_2150.dta"
	tab _merge
	keep if _merge == 3
        drop _merge

	sort male hispan black, stable
	by male hispan black: egen twt = total(weight)
	replace weight = weight * pop/twt
	replace wthh = wthh/2
	replace wthh = wthh * pop/twt
        drop twt pop

	* Recode HH ID and Person ID
	sort hhid hhidpn, stable
	by hhid: gen id = 1 if _n == 1
	replace id = sum(id)
	drop hhid
	gen hhid = id
	drop id
	
	* Person ID
	sort hhid hhidpn, stable

multiply_persons `expand'

	sum weight
	dis r(sum)

	dis "Population size for aged 51/52 in year 2010 is: `r(sum)'"
	sum wthh
	dis r(sum)

if missing("`bsamp'") {	
	save "`dataout'", replace
}
else {
	save "$outdata/input_rep`bsamp'/incoming_base.dta", replace
}

exit, STATA
