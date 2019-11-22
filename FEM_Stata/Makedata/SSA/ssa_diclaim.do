/* Process the December disability tables downloaded from SSA for 2005-2014, then made into useful files

URLs were of the form: https://www.ssa.gov/OACT/ProgData/benefits/da_age201412.html

*/

quietly include common.do

local minyr 2005
local maxyr 2014


forvalues yr = `minyr'/`maxyr' {	
	import delimited using $indata/SSA_DI_`yr'_12.csv, varnames(1) clear
	
	* Recode age variables for consistency
	drop if age == "Total"
	replace age = "20" if age == "20 & under"
	replace age = "65" if age == "65 & over"
	replace age = "66" if age == "66 & over"
	
	destring age, replace
	
	* age 65 should include all 65 and older
	egen num6566 = total(number) if inlist(age,65,66)
	egen num6566_m = total(number_male) if inlist(age,65,66)
	egen num6566_f = total(number_female) if inlist(age,65,66)	
	
	replace number = num6566 if age == 65
	replace number_male = num6566_m if age == 65
	replace number_female = num6566_f if age == 65
	drop if age == 66
	drop num6566*
	
	gen year = `yr'
	tempfile `yr'
	save ``yr''
}

clear

forvalues yr = `minyr'/`maxyr' {	
	append using ``yr''
}

rename number enrollees
rename averageamount avg_benefit
rename number_male enrollees_m
rename averageamount_male avg_benefit_m
rename number_female enrollees_f
rename averageamount_female avg_benefit_f

label var enrollees "Enrollment as of December"
label var enrollees_m "Male enrollment as of December"
label var enrollees_f "Female enrollment as of December"

label var avg_benefit "Average DI benefit (nominal)"
label var avg_benefit_m "Male average DI benefit (nominal)"
label var avg_benefit_f "Female average DI benefit (nominal)"	

save $outdata/ssa_diclaim.dta, replace



capture log close
