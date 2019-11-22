/* 
Crossvalidation results for FAM (1999-2013)
*/



clear all
quietly include ../../../../../fem_env.do

local output "$output_dir/psid_crossvalidation"

local iter 10
local minyr 1999
local maxyr 2013

set more off


********************************
* Process PSID
********************************
use $outdata/psid_analytic.dta, replace

* Keep only those considered for the crossvalidation (present in 1999)
merge m:1 hhidpn using $outdata/psid_crossvalidation.dta
keep if _merge == 3
keep if simulation == 1

gen rep = .
gen FAM = 0
gen age_yrs = floor(age)

* fill in indicator variables
gen anyadl = inlist(adlstat,2,3,4)
gen anyiadl = inlist(iadlstat,2,3)


* kludge
gen nhmliv = 0

tempfile psid
save `psid'

clear all


********************************
* Process simulation output
********************************
forvalues i = 1/`iter' {
	forvalues yr = `minyr' (2) `maxyr' {
		append using "`output'/detailed_output/y`yr'_rep`i'.dta"
	}
}
gen reweight = weight/`iter' 
gen FAM = 1
gen rep = mcrep + 1

* smoking is not coded correctly ...
replace smoken = (smkstat == 3)
replace smokev = (smkstat == 2 | smkstat == 3)


*******************************
* Analytic file
*******************************
append using `psid'

/* Shorter variable labels */
label var died "Died"
label var nhmliv "Lives in nursing home"

label var adl1 "1 ADL"
label var adl2 "2 ADLs"
label var adl3p "3+ ADLs"

label var anyadl "Any ADLs"

label var iadl1 "1 IADL"
label var iadl2p "2+ IADLs"

label var anyiadl "Any IADLs"

label var cancre "Cancer"
label var diabe "Diabetes"
label var hearte "Heart Disease" 
label var hibpe "Hypertension"
label var lunge "Lung Disease"
label var stroke "Stroke"

label var bmi "BMI"
label var smoken "Current smoker"
label var smokev "Ever smoked"

label var diclaim "Claiming SSDI"
label var oasiclaim "Claiming OASI"
label var ssiclaim "Claiming SSI"
label var work "Working for pay"

label var hatotax "Household wealth (thou.)"
label var hicap "Capital income (thou.)"
label var iearnx "Earnings (thou.)"

label var age_yrs "Age on July 1st"
label var black "Black"
label var hispan "Hispanic"
label var male "Male"

* get variable labels for later merging
preserve
tempfile varlabs
descsave, list(name varlab) saving(`varlabs', replace)
* save varlabs, replace
use `varlabs', clear
rename name variable
* escape out underscore and create math environment for latex compatibility
replace varlab = regexr(varlab,"_","\_")
replace varlab = regexr(varlab,"<=","$<=$")
replace varlab = regexr(varlab," > "," $>$ ")
* replace varlab = regexr(varlab,"\$","\\$")
save `varlabs', replace
restore

save psid_crossvalidation_data.dta, replace

local binhlth cancre diabe hearte hibpe lunge stroke anyadl anyiadl
local risk smoken smokev bmi 
local binecon work diclaim ssiclaim oasiclaim
local cntecon iearnx hatotax hicap
local demog age_yrs male black hispan
* Not sumarizing nursing home population
local unweighted died

foreach tp in binhlth risk binecon cntecon demog {
	forvalues wave = `minyr' (2) `maxyr' {
		file open myfile using "`output'/fam_psid_ttest_`tp'_`wave'.txt", write replace
		file write myfile "variable" _tab "fam_mean" _tab "fam_n" _tab "fam_sd" _tab "psid_mean" _tab "psid_n" _tab "psid_sd" _tab "p_value" _n

		local yr = year

		foreach var in ``tp'' {
		
			local select
			if "`var'" == "oasiclaim" {
				* local select & age_yrs >= 62 & age_yrs <= 70
			} 
			if "`var'" == "work" {
				* local select & age_yrs <= 80
			} 
			if "`var'" == "diclaim" {
				* local select & age_yrs <= 65
			} 
			if "`var'" == "iearnx" {
				* local select & age_yrs <= 80
			}
		
			di "var is `var' and select is `select'"
		
			qui sum `var' if FAM==1 & died == 0 & nhmliv == 0 & year == `wave' `select' [aw=reweight] 
			local N1 = r(N)
			local av1 = r(mean)
			local sd1 = r(sd)
			qui sum `var' if FAM==0 & died == 0 & nhmliv == 0 & year == `wave' `select' [aw=weight] 
			local N2 = r(N)
			local av2 = r(mean)
			local sd2 = r(sd)
			ttesti `N1' `av1' `sd1' `N2' `av2' `sd2', unequal
	 		file write myfile %15s "`var'" _tab %15.5f (`av1') _tab %15.0f (`N1') _tab %15.5f (`sd1') _tab %15.5f (`av2') _tab %15.0f (`N2')	_tab %15.5f (`sd2') _tab %15.5f (r(p)) _n
		}
		file close myfile
	}
}

foreach tp in unweighted {
	forvalues wave = `minyr' (2) `maxyr' {
		file open myfile using "`output'/fam_psid_ttest_`tp'_`wave'.txt", write replace
		file write myfile "variable" _tab "fam_mean" _tab "fam_n" _tab "fam_sd" _tab "psid_mean" _tab "psid_n" _tab "psid_sd" _tab "p_value" _n

		local yr = year 

		foreach var in ``tp'' {
			qui sum `var' if FAM==1 & year == `wave'
			local N1 = r(N)
			local av1 = r(mean)
			local sd1 = r(sd)
			qui sum `var' if FAM==0 & year == `wave'
			local N2 = r(N)
			local av2 = r(mean)
			local sd2 = r(sd)
			ttesti `N1' `av1' `sd1' `N2' `av2' `sd2', unequal
	 		file write myfile %15s "`var'" _tab %15.5f (`av1') _tab %15.0f (`N1') _tab %15.5f (`sd1') _tab %15.5f (`av2') _tab %15.0f (`N2')	_tab %15.5f (`sd2') _tab %15.5f (r(p)) _n
		}
		file close myfile
	}
}


	local varlist "fam_mean fam_n fam_sd psid_mean psid_n psid_sd p_value"


* Produce tables
foreach tabl in binhlth risk binecon cntecon demog unweighted {
	
	foreach wave in 2001 2007 2013 {
		tempfile year`wave'
		insheet using "`output'/fam_psid_ttest_`tabl'_`wave'.txt",clear
	
		foreach var in `varlist' {
			ren `var' `var'_year`wave'
		}
		save `year`wave''
	}

	use "`year2001'", replace
	merge 1:1 variable using "`year2007'", nogen
	merge 1:1 variable using "`year2013'", nogen
	
	* Add variable labels
	merge 1:1 variable using `varlabs'
	drop if _merge==2
	drop _merge
	replace variable = varlab if varlab != ""
	keep variable fam_mean* psid_mean* p_value*
	
	keep variable fam_mean* psid_mean* p_value*
	replace variable = "ageyrs" if variable == "age_yrs"
	outsheet using table12_1_`tabl'.csv, comma replace
}





/* Make the latex tables */
foreach tabl in binhlth risk binecon cntecon demog unweighted {
	clear
	insheet using table12_1_`tabl'.csv, comma
	
	if inlist("`tabl'","unweighted","binhlth","risk","binecon","demog") {
		format fam_mean* psid_mean* p_value* %12.3f
	}
	else if inlist("`tabl'","cntecon")  {
		format fam_mean* psid_mean* p_value* %7.0g
	}
	#d ;
	listtab using crossval_`tabl'.tex, replace rstyle(tabular) 
	head(
	"\begin{tabular}{|p{1.2in}|*{3}{r}|*{3}{r}|*{3}{r}|}"
	" \multicolumn{1}{c}{} & \multicolumn{3}{c}{2001} & \multicolumn{3}{c}{2007} & \multicolumn{3}{c}{2013} \\"
	"\hhline{~---------}"
	" \multicolumn{1}{c|}{} & FAM & PSID & & FAM & PSID & & FAM & PSID & \\"
	" \multicolumn{1}{l|}{Outcome} & mean & mean & \textit{p} & mean & mean & \textit{p} & mean & mean & \textit{p} \\"
	"\hline"
	)
	foot("\hline""\end{tabular}")
	;
	#d cr

}






capture log close






















