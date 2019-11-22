clear all
set mem 1000M
set maxvar 10000

include "../fem_env.do"

use ../output/ACA/detailed_output/y2006_rep1.dta

// A few indicators
gen ageGT65 = age >= 65
gen ageLT17 = age < 17
sort hhid
by hhid: egen hhsize = total(!ldied)
// Creating the taxsim variables
gen state = 23 // Michigan, for now
label var state "State for taxes, 0 is no state tax"

gen mstat = 1
replace mstat = 2 if married
label var mstat "Filing Status"
label define filestatus 1 Single 2 Joint 3 "Head of Household"
label values mstat filestatus

gen depx = 0
label var depx "Number of Dependents"

by hhid: egen agex = total(ageGT65)
label var agex "Number of 65+ taxpayers"

sort hhid ry_earn
by hhid: gen pwages = ry_earn[_N]
by hhid: gen swages = ry_earn[_N-1] if _N > 1
label var pwages "Primary taxpayer wages"
label var swages "Secondary taxpayer wages"

gen dividends = 0
label var dividends "Dividend Income"

gen otherprop = 0
label var otherprop "Interest and other property income. Random stuff"

gen pensions = dbpen
label var pensions "Taxable Pension Income"

gen gssi = ssben + ssiben
label var gssi "Gross social security benefits"

gen transfers = 0
label var transfers "Non-taxable transfer income"

gen rentpaid = 0
label var rentpaid "Total rent paid"

gen proptax = 0
label var proptax "Total property taxes paid"

gen otheritem = 0
label var otheritem "Other taxes paid, excluding state income tax"

gen childcare = 0
label var childcare "Child care expenses"

gen ui = 0
label var ui "Unemployment benefits"

by hhid: egen depchild = total(ageLT17)
label var depchild "Number of dependent children under 17"

gen mortgage = 0
label var mortgage "Mortage interest, charitable donations, and other non-AMT related deductions"

gen stcg = 0
label var stcg "Short term capital gains"

gen ltcg = hicap
label var ltcg "Long term capital gains"

taxsim9, replace full
