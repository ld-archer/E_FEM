clear all
clear matrix
include "../../../fem_env.do"
set more off

use $outdata/nhis97plus_selected.dta, replace

*the weight to be used for the estimation is [pweight=wtfa_sa]


*creating a categorical smoking variable based on smoken and smokev

gen smkcat=.
replace smkcat=1 if smoken==0 & smokev==0
replace smkcat=2 if smoken==0 & smokev==1
replace smkcat=3 if smoken==1 & smokev==1

label define smkcat 1 "never smoked" 2 "ever smoked 100 cigarettes" 3 "smoking now"
label values smkcat smkcat

tab smkcat, gen(smkcat)
label variable smkcat1 "never smoked"
label variable smkcat2 "has ever smoked"
label variable smkcat3 "smoking now"

/*For FEM, ignore this part?? */
*for consistency with ACS estimates, the time variable starts
*as 0 in the first year (in this case, 1997)
gen yr=year-1997

save $outdata/nhis_smk_scenarios.dta, replace

*/
***
***TRENDS FOR AGES 21-30***
*Change age to 46-56 for FEM
***
*/
drop _all
use $outdata/nhis_smk_scenarios.dta, replace
keep if age>=46 & age<=56

*ordered probit estimation for smoking category
oprobit smkcat yr [pweight=wtfa_sa] //1997-2010, ages 46-56
est store msmk4656

keep smkcat1-smkcat3 wtfa_sa year 
collapse (mean) smkcat1-smkcat3 [pweight=wtfa_sa], by(year)

rename smkcat1 smkcat1_4656
rename smkcat2 smkcat2_4656
rename smkcat3 smkcat3_4656

local obs = 2050-1997+1
set obs `obs'
replace year = 1996 + _n
gen yr=year-1997


mkmat year, mat(trends)

*projecting trends for smoking
est restore msmk4656
forvalues cnt = 1/3 {
	predict psmkcat`cnt'_4656, outcome(`cnt')
}

mkmat smkcat1_4656-smkcat3_4656 psmkcat1_4656-psmkcat3_4656, mat(t_4656)
matrix trends = trends, t_4656

drop _all
svmat trends, names(col)


save $outdata/nhis_smk_trends.dta, replace

keep year psmkcat1_4656-psmkcat3_4656

replace psmkcat1_4656=. if year>2050
replace psmkcat2_4656=. if year>2050
replace psmkcat3_4656=. if year>2050


*for all years after 2050 replace with values for 2050

foreach v in psmkcat1_4656 {
		sort year,stable
		qui sum `v' if year == 2050
		local r0 = r(mean)
		replace `v' = `r0' if year > 2050

}

foreach v in psmkcat2_4656 {
		sort year,stable
		qui sum `v' if year == 2050
		local r0 = r(mean)
		replace `v' = `r0' if year > 2050

}

foreach v in psmkcat3_4656 {
		sort year,stable
		qui sum `v' if year == 2050
		local r0 = r(mean)
		replace `v' = `r0' if year > 2050

}

keep if year>=2010

save $outdata/nhis_smk_projections.dta, replace
