/** Table rates of change in CHF prevalence by decade
*/

use chf_summary.dta

drop if (Source=="FEM - Constant CHF Model" | Source=="FEM - Full CHF Model") & mod(year,10) != 0
drop if Source=="NHANES" & !inlist(year,2000,2010)
drop if Source=="Raw HRS" & !inlist(year,2000,2010)
drop if Source=="FEM Estimation Sample (HRS)" & !inlist(year,1998,2008)

sort Source Age year
by Source Age: gen end_year = year[_n+1] if Source==Source[_n+1] & Age==Age[_n+1]
label var end_year
rename year start_year
gen Years = string(start_year) + "-" + string(end_year)

foreach v in hearte chfe chfe_hearte {
	by Source Age: gen end_`v' = `v'[_n+1] if Source==Source[_n+1] & Age==Age[_n+1]
	rename `v' start_`v'
	
	* absolute change
	gen absch_`v' = end_`v' - start_`v'
	gen abschyr_`v' = absch_`v' / (end_year - start_year - 1)
	
	* relative change
	gen relch_`v' = end_`v' / start_`v' - 1
	gen relchyr_`v' = (end_`v' / start_`v')^(1/(end_year - start_year - 1)) - 1
}

drop if end_year==.
keep Source Age Years start_* end_* absch* relch*
sort Age Source Years
foreach v in hearte chfe chfe_hearte {
	local varorder `varorder' start_`v' end_`v' absch_`v' abschyr_`v' relch_`v' relchyr_`v'
}
order Age Source Years start_year end_year `varorder'
save chf_prevelance_changes.dta, replace







