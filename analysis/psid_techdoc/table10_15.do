/* Comparing insurance coverage rates and insurance types between PSID (2011 question about 2010) and MEPS for 2010
*/

clear all
set more off
include ../../fem_env.do

*** PSID ***

local tbl 10_15

tempfile psid meps

use $outdata/psid_analytic.dta, replace
keep if age >= 25 & age < .
keep if year == 2011
gen ageLT65 = age < 65

tab hlthinscat, gen(hi_cat)
tab inscat, gen(inscat)
foreach v of var * {
        local l`v' : variable label `v'
            if `"`l`v''"' == "" {
            local l`v' "`v'"
        }
}
collapse hi_cat1-hi_cat9 inscat1-inscat3 [aw=weight], by(ageLT65)
foreach v of var * {
        label var `v' "`l`v''"
}
gen source = 1 if ageLT65
replace source = 3 if !ageLT65
save `psid'

*** MEPS *** 
use $outdata/MEPS_cost_est.dta, replace
keep if age >= 25 & age < .
keep if yr == 2010
gen ageLT65 = age < 65

tab hlthinscat, gen(hi_cat)
forvalues x = 1/3 {
	cap drop inscat`x'
}
tab inscat, gen(inscat)
foreach v of var * {
        local l`v' : variable label `v'
            if `"`l`v''"' == "" {
            local l`v' "`v'"
        }
}
collapse hi_cat1-hi_cat9 inscat1-inscat3 [aw=perwt], by(ageLT65)
foreach v of var * {
        label var `v' "`l`v''"
}
gen source = 2 if ageLT65
replace source = 4 if !ageLT65
save `meps'

append using `psid'

sort source
drop ageLT65

label define source_lbl 1 "PSID (25-64)" 2 "MEPS (25-64)" 3 "PSID (65+)" 4 "MEPS (65+)" 

label values source source_lbl
label var source "Source (ages)"

order source, first

outsheet using table`tbl'.csv, comma replace
export excel using techappendix.xlsx, sheetreplace sheet("Table `tbl'") firstrow(varlabels)



capture log close




