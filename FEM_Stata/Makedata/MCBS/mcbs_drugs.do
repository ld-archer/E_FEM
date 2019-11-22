/* 
Generate annual drug cost measures for the MCBS population from the ric_pme files
- files are at baseid-drug level

Issues:
- MCBS "ghost" records do not have imputed drug expenditures, so we need to be identify them to be able to impute them later. 

*/

quietly include ../../../fem_env.do

**** Store the medical cpi into a matrix 
insheet using $fred_dir/CPIMEDSL.csv, clear
gen year = substr(date,5,4)
destring year, replace
ren value medcpi
keep year medcpi
mkmat medcpi, matrix(medcpi) rownames(year)

clear

local begyr 2000
local endyr 2012

* Process the ghost files
forvalues year = `begyr'/`endyr' {
	
	use $mcbs_dir/ghost`year'.dta, replace		
	
	* Keep only the ghost records
	keep if substr(ghostid,1,1) == "G"
	gen ghost = 1
	
	tempfile gh`year'
	save `gh`year''
}

forvalues year = `begyr'/`endyr' {
	use $mcbs_dir/ricpme_c`year'.dta, replace
	gen baseid_gst = baseid
	merge m:1 baseid_gst using `gh`year''
	replace baseid = baseid_gst if ghost
	drop baseid_gst

	
	* counter for number of fills	
	gen fills = 1 
	replace ghost = 0 if missing(ghost)
	
	* outcomes of interest
	local outcomes amttot amtcare amtcaid amthmop amthmom amtva amtprve amtprvi amtprvu amtoop amtoth 
	collapse (sum) `outcomes' fills (max) ghost, by(baseid)
	
	* Put everything in the same $
	foreach var of local outcomes {
		replace `var' = `var' * medcpi[rownumb(medcpi,"`endyr'"), 1]/( medcpi[rownumb(medcpi,"`year'"),1])
	}
	
	* Make the collapsed values for the ghosts missing so we don't accidentally use them later.
	replace fills = . if ghost
	foreach var of local outcomes {
		replace `var' = . if ghost
	}
	
	
	gen year = `year'
	
	tempfile `year'
	save ``year''
				
}

clear

forvalues year = `begyr'/`endyr' {
	append using ``year''
}



* Label variables
label var amttot "Rx Expenditures - Total"
label var amtcare "Rx Expenditures - Medicare"
label var amtcaid "Rx Expenditures - Medicaid"
label var amthmop "Rx Expenditures - HMO"
label var amthmom "Rx Expenditures - Medicare HMO"
label var amtva "Rx Expenditures - VA"
label var amtprve "Rx Expenditures - Employer Sponsored Ins"
label var amtprvi "Rx Expenditures - Individual Purchased Ins"
label var amtprvu "Rx Expenditures - Unknown"
label var amtoop "Rx Expenditures - Out of Pocket"
label var amtoth "Rx Expenditures - Other"
label var fills "Rx fills"
label var year "year"
label var ghost "Person was a ghost, so no drug utilization information"

compress

label data "MCBS `begyr'-`endyr' drug data" 
save $dua_mcbs_dir/mcbs_drugs.dta, replace


capture log close
