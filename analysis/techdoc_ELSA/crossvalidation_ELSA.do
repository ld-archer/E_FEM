/*
Cross-validation results using ELSA
*/

*ssc install descsave

clear all
set maxvar 10000
include ../../fem_env.do

local scen: env scen

log using crossvalidation_ELSA_`scen'.log, replace

* Path to files
if "`scen'" == "CV1" {
	local output "../../output/ELSA_CV1"
	*local output "$output_dir/ELSA_CV1"
}
else if "`scen'" == "minimal" {
	local output "../../output/ELSA_minimal"
	*local output "$output_dir/output/ELSA_minimal"
}
*local input "../../input_data"
local input "$outdata"

* For processing simulation output
local iter 10

* For processing ELSA
local minwave 1
local maxwave 8

********************************
* PROCESS ELSA
********************************

use `input'/H_ELSA_f_2002-2016.dta, clear
*use ../../../input_data/H_ELSA_f_2002-2016.dta, clear

if "`scen'" == "CV1" {
	* Keep only those used in the simulation (simulation==1)
	merge 1:1 idauniq using `input'/cross_validation/crossvalidation.dta, keepusing(simulation)
	tab _merge
	keep if simulation == 1
	drop _merge
}
else if "`scen'" == "minimal" {
	* Keep the same people from minimal run. Use flag var created in generate_stock_pop.do
	merge 1:1 idauniq using `input'/ELSA_stock_min_flag.dta /*, keep(match) nogenerate*/
	tab _merge
	keep if _merge == 3
	drop _merge
}

#d ;
keep 
	idauniq
	raracem
	ragender
	rabyear
	
	r*iwstat
	r*agey
	r*cancre
	r*diabe
	r*hearte
	r*hibpe
	r*lunge
	r*stroke
	r*smoken
	r*smokev
	r*work
	r*bmi
	r*itearn
	r*cwtresp
	h*atotf
	r*ipubpen
	r*drink
	r*psyche
	r*smokef
	r*lnlys
	
	r*walkra
	r*dressa
	r*batha
	r*eata
	r*beda
	r*toilta
	r*mapa
	r*phonea
	r*moneya
	r*medsa 
	r*shopa
	r*mealsa
	r*housewka
;
#d cr

* Reshape this data to long
#d ;
local shapelist
	r@iwstat
	r@agey
	r@cancre
	r@diabe
	r@hearte
	r@hibpe
	r@lunge
	r@stroke
	r@smoken
	r@smokev
	r@work
	r@bmi
	r@itearn
	r@cwtresp
	h@atotf
	r@ipubpen
	r@drink
	r@psyche
	r@smokef
	r@lnlys
	
	r@walkra
	r@dressa
	r@batha
	r@eata
	r@beda
	r@toilta
	r@mapa
	r@phonea
	r@moneya
	r@medsa 
	r@shopa
	r@mealsa
	r@housewka
;
#d cr

reshape long `shapelist', i(idauniq) j(wave)

keep if wave >= `minwave'
keep if rabyear <= 1951 /* Keep only those aged 50 or over */

* FEM uses hhidpn as the person ID
gen hhidpn = idauniq
replace hhid = hhidpn

* Recode variables
* Fixed variables
gen white = raracem == 1
label var white "White"

* Label males
gen male = (ragender == 1) if !missing(ragender)
label variable male "Male"

* ADL/IADL
egen adlcount = rowtotal(rwalkra rdressa rbatha reata rbeda rtoilta)
egen iadlcount = rowtotal(rmapa rphonea rmoneya rmedsa rshopa rmealsa rhousewka)
recode adlcount (0=1) (1=2) (2=3) (3/7 = 4), gen(adlstat)
recode adlcount (0=0) (1/6 = 1), gen(anyadl)
recode iadlcount (0=1) (1=2) (2/7=3), gen(iadlstat)
recode iadlcount (0=0) (1/7=1), gen(anyiadl)
label define adlstat 1 "No ADLs" 2 "1 ADL" 3 "2 ADLs" 4 "3 or more ADLs"
label values adlstat adlstat
label define anyadl 0 "No ADLs" 1 "1 or more ADL" 
label values anyadl anyadl
label var anyadl "Any ADL limitations"
label define iadlstat 1 "No IADLs" 2 "1 IADL" 3 "2 or more IADLs"
label values iadlstat iadlstat
label define anyiadl 0 "No IADLs" 1 "1 or more IADL" 
label values anyiadl anyiadl
label var anyiadl "Any IADL limitations"

gen adl1 = adlstat==2 if !missing(adlstat)
gen adl2 = adlstat==3 if !missing(adlstat)
gen adl3p = adlstat==4 if !missing(adlstat)
label var adl1 "One ADL limitation"
label var adl2 "Two ADL limitations"
label var adl3p "Three or more ADL limitations"

gen iadl1 = iadlstat==2 if !missing(iadlstat)
gen iadl2p = iadlstat==3 if !missing(iadlstat)
label var iadl1 "One IADL limitation"
label var iadl2p "Two or more IADL limitations"


* Health conditions
foreach var in cancre diabe hearte hibpe lunge stroke psyche {
	ren r`var' `var'
}
label var cancre "R ever had cancer"
label var diabe "R ever had diabetes"
label var hearte "R ever had heart disease"
label var hibpe "R ever had hypertension"
label var lunge "R ever had lung disease"
label var stroke "R ever had stroke"
label var psyche "R ever had psychological problems"

* Mortality
gen died = riwstat
recode died (0 7 9 = .) (1 4 6 = 0) (5 = 1)
label var died "Whether died or not in this wave"

* Risk factors
foreach var in bmi smokev smoken drink smokef lnlys {
	ren r`var' `var'
}
label var bmi "R Body mass index"
label var smoken "R smokes now"
label var smokev "R smoke ever"
label var drink "R drinks alcohol"

* Smoking intensity variable
recode smokef (0/0.99=0) (1/9.99=1) (10/19.99=2) (20/max=3), gen(smkint)
label define smkint 1 "Low" 2 "Medium" 3 "High"
label values smkint smkint
label variable smkint "Smoking intensity"
drop smokef
* Now assign any missing that don't smoke to equal 0
replace smkint = 0 if smoken == 0

/*
* Smoking intensity variable
recode smokef (0=1) (1/9=2) (10/19=3) (20/max=4), gen(smkint)
label define smkint 1 "Non-smoker" 2 "Low" 3 "Medium" 4 "High"
label values smkint smkint
label variable smkint "Smoking intensity"
drop smokef
*/

*** Loneliness
* loneliness is brought into our model as a summary score for 4 questions relating to loneliness
* To use this score (which is ordinal, containing non-integers), we are going to round the values and keep them as 3 categories: low, medium and high
* Potentially in the future, we could just keep the high loneliness? Try full var first
gen lnly = round(lnlys, 1)
label variable lnly "Loneliness level [1, 3]"
* Now generate some dummys
*gen lnly1 = lnly == 1
*gen lnly2 = lnly == 2
*gen lnly3 = lnly == 3
* Labels
*label variable lnly1 "Loneliness level: low"
*label variable lnly2 "Loneliness level: medium"
*label variable lnly3 "Loneliness level: high"
* Drop original
drop lnlys

* Sampling weight
ren rcwtresp weight
label var weight "R cross-sectional weight"

codebook weight

* Interview Status
ren riwstat iwstat

* Age years
ren ragey age
gen age_yrs = age

* Economic vars
foreach var in work itearn {
	ren r`var' `var'
}

* Work status
label var work "R working for pay"

* Earnings
replace itearn = 0 if work == 0
gen itearnx = itearn/1000
replace itearnx = min(itearn, 200) if !missing(itearn)
label var itearnx "Individual earnings in 1000s, max 200"

* Non-housing Wealth
gen atotfx = hatotf/1000
replace atotfx = min(hatotf, 2000) if !missing(hatotf)
label var atotfx "HH wealth in 1000s (max 2000) if positive, zero otherwise"

* Couple level Capital Income

* Interview year
gen iwyear = 2000 + 2*wave


gen FEM = 0
gen year = iwyear

tempfile ELSA
save `ELSA'
save ELSA_2002_2016.dta, replace
clear all

********************************
* Process simulation output
* iter = numbers of reps
********************************
forvalues i = 1/`iter' {
	forvalues yr = 2002 (2) 2016 {
		append using "`output'/detailed_output/y`yr'_rep`i'.dta"
	}
}
gen reweight = weight/`iter'
gen FEM = 1
gen rep = mcrep + 1

*replace hicap = hicap/1000

append using `ELSA'

bys FEM: sum diabe [aw=weight] if year == 2002
bys FEM: sum diabe [aw=weight] if year == 2012


/* Shorter Variable Labels */
label var died "Died"

label var adl1 "1 ADL"
label var adl2 "2 ADLs"
label var adl3p "3+ ADLs"

label var anyadl "Any ADLs"

label var iadl1 "1 IADL"
label var iadl2p "2+ IADLs"

label var anyiadl "Any IADLs"

label var hibpe "Hypertension ever"
label var diabe "Diabetes ever"
label var cancre "Cancer ever"
label var lunge "Lung disease ever"
label var hearte "Heart disease ever"
label var stroke "Stroke ever"
label var psyche "Psychological problems ever"

label var bmi "BMI"
label var smokev "Smoke ever"
label var smoken "Smoke now"
label var drink "Drinks Alcohol"
label var smkint "Smoking Intensity"
label var lnly "Loneliness Score, Low to High [1, 3]"

label var work "Working for pay"

label var itearnx "Earnings (thou.)"
label var atotfx "Household wealth (thou.)"

label var age_yrs "Age at interview"
label var male "Male"
label var white "White"



* Get variable labels for later merging
preserve
tempfile varlabs
descsave, list(name varlab) saving(`varlabs', replace)
*save varlabs, replace
use `varlabs', clear
rename name variable
*recast str18 variable
save `varlabs', replace
save varlabs.dta, replace
restore

*save test_pre_loop.dta, replace

local binhlth cancre diabe hearte hibpe lunge stroke anyadl anyiadl psyche
local risk smoken smokev bmi drink smkint lnly
local binecon work
*local cntecon /*itearnx atotfx*/
local demog age_yrs male white
local unweighted died

foreach tp in binhlth risk binecon cntecon demog {
	forvalues wave = `minwave'/`maxwave' {
		file open myfile using "`output'/fem_elsa_ttest_`tp'_`wave'.txt", write replace
		file write myfile "variable" _tab "fem_mean" _tab "fem_n" _tab "fem_sd" _tab "elsa_mean" _tab "elsa_n" _tab "elsa_sd" _tab "p_value" _n
		
		local yr = 2000 + 2*`wave'
		
		foreach var in ``tp'' {
		
			* BMI has no data for odd waves, skip over these in the loop
			if "`var'" == "bmi" & (`wave' == 1 | `wave' == 3 | `wave' == 5 | `wave' == 7) {
				continue
			}
			else if "`var'" == "drinkd" & `wave' == 1 {
				continue
			}
			
			local select
			if "`var'" == "work" {
				local select & age_yrs <= 80
			}
			if "`var'" == "itearnx" {
				local select & age_yrs <= 80
			}
			
			di "var is `var' and select is `select' and wave is `wave'"
			
			qui sum `var' if FEM == 1 & died == 0 & year == `yr' `select' [aw=reweight]
			local N1 = r(N)
			local av1 = r(mean)
			local sd1 = r(sd)
			
			di "N, mean, and sd:"
			di `N1'
			di `av1'
			di `sd1'
			
			qui sum `var' if FEM == 0 & died == 0 & year == `yr' `select' [aw=weight] 
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
	forvalues wave = `minwave'/`maxwave' {
		file open myfile using "`output'/fem_elsa_ttest_`tp'_`wave'.txt", write replace
		file write myfile "variable" _tab "fem_mean" _tab "fem_n" _tab "fem_sd" _tab "elsa_mean" _tab "elsa_n" _tab "elsa_sd" _tab "p_value" _n

		local yr = 2000 + 2*`wave' 

		foreach var in ``tp'' {
			qui sum `var' if FEM == 1 & year == `yr'  
			local N1 = r(N)
			local av1 = r(mean)
			local sd1 = r(sd)
			qui sum `var' if FEM == 0 & year == `yr'
			local N2 = r(N)
			local av2 = r(mean)
			local sd2 = r(sd)
			ttesti `N1' `av1' `sd1' `N2' `av2' `sd2', unequal
	 		file write myfile %15s "`var'" _tab %15.5f (`av1') _tab %15.0f (`N1') _tab %15.5f (`sd1') _tab %15.5f (`av2') _tab %15.0f (`N2')	_tab %15.5f (`sd2') _tab %15.5f (r(p)) _n
		}
		file close myfile
	}
}


local varlist "fem_mean fem_n fem_sd elsa_mean elsa_n elsa_sd p_value"

* Produce tables
foreach tabl in binhlth risk binecon /*cntecon*/ demog unweighted {
	
	foreach wave in 3 5 8 {
		tempfile wave`wave'
		insheet using "`output'/fem_elsa_ttest_`tabl'_`wave'.txt",clear
	
		foreach var in `varlist' {
			ren `var' `var'_wave`wave'
		}
		save `wave`wave''
	}
	
	di "Table is `tabl'"

	use "`wave3'", replace
	merge 1:1 variable using "`wave5'", nogen
	merge 1:1 variable using "`wave8'", nogen
	
	recast str10 variable
	
	///*
	* Add variable labels
	merge 1:1 variable using `varlabs'
	tab _merge
	drop if _merge==2
	drop _merge
	replace variable = varlab if varlab != ""
	keep variable fem_mean* elsa_mean* p_value*
		
	keep variable fem_mean* elsa_mean* p_value*
	outsheet using "`output'/T-tests/`scen'_`tabl'.csv", comma replace
	//*/
}

///*
* Produce tables of all years
foreach tabl in binhlth risk binecon /*cntecon*/ demog unweighted {
	
	foreach wave in 1 2 3 4 5 6 7 8 {
		tempfile wave`wave'
		insheet using "`output'/fem_elsa_ttest_`tabl'_`wave'.txt",clear
	
		foreach var in `varlist' {
			ren `var' `var'_wave`wave'
		}
		save `wave`wave''
	}

	use "`wave3'", replace
	merge 1:1 variable using "`wave4'", nogen
	merge 1:1 variable using "`wave5'", nogen
	merge 1:1 variable using "`wave6'", nogen
	merge 1:1 variable using "`wave7'", nogen
	merge 1:1 variable using "`wave8'", nogen
	
	* Add variable labels
	merge 1:1 variable using `varlabs'
	drop if _merge==2
	drop _merge
	replace variable = varlab if varlab != ""
	keep variable fem_mean* elsa_mean* p_value*
		
	keep variable fem_mean* elsa_mean* p_value*
	outsheet using "`output'/T-tests/`scen'_all_waves_`tabl'.csv", comma replace
}

capture log close
