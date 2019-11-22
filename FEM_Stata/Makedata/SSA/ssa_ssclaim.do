/* Process the December retirement tables downloaded from SSA for 2005-2014, then made into useful files

URLs were of the form: https://www.ssa.gov/oact/progdata/benefits/ra_age201412.html

*/


quietly include common.do

local minyr 2005
local maxyr 2014


forvalues yr = `minyr'/`maxyr' {	
	import delimited using $indata/ra_age`yr'12.csv, varnames(1) clear
	
	* Recode age variables for consistency
	drop if age == "Total"
	replace age = "99" if age == "99 & over"
	
	destring age, replace

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

label var enrollees "Retired worker beneficiaries as of December"
label var enrollees_m "Male etired worker beneficiaries as of December"
label var enrollees_f "Female retired worker beneficiaries as of December"

label var avg_benefit "Average retirement benefit (nominal)"
label var avg_benefit_m "Male average retirement benefit (nominal)"
label var avg_benefit_f "Female average retirement benefit (nominal)"	

save $outdata/ssa_ssclaim.dta, replace



capture log close
