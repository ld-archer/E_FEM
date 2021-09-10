/*
Cross-validation results using ELSA
*/

*ssc install descsave

clear all
set maxvar 15000
include ../../fem_env.do

local scen: env scen

log using crossvalidation_ELSA_`scen'.log, replace

* Path to files
if "`scen'" == "CV1" {
	*local output "../../output/ELSA_CV1"
	local output "$output_dir/COMPLETE/ELSA_CV1"
}
else if "`scen'" == "minimal" {
	*local output "../../output/ELSA_minimal"
	local output "$output_dir/COMPLETE/ELSA_minimal"
}
*local input "../../input_data"
local input "$outdata"

* For processing simulation output
local iter 10

* For processing ELSA
local minwave 1
local maxwave 9

********************************
* PROCESS ELSA
********************************

*use `input'/H_ELSA_f_2002-2016.dta, clear
*use ../../../input_data/H_ELSA_f_2002-2016.dta, clear
*use ../../output/ELSA_core_base/detailed_output/y2012_rep1.dta, clear
use `input'/H_ELSA_g2.dta, clear

gen hhidpn = idauniq

if "`scen'" == "CV1" {
	* Keep only those used in the simulation (simulation==1)
	merge 1:1 idauniq using `input'/cross_validation/crossvalidation.dta, keepusing(simulation)
	*merge 1:1 hhidpn using ../../output/ELSA_core_base/detailed_output/y2012_rep1.dta/*, keep(match)*/
	tab _merge
	keep if simulation == 1
	drop _merge
}
else if "`scen'" == "minimal" {
	* Keep the same people from minimal run. Use flag var created in generate_stock_pop.do
	merge 1:1 idauniq using `input'/ELSA_stock_min_flag.dta /*, keep(match) nogenerate*/
	*merge 1:1 hhidpn using ../../output/ELSA_core_base/detailed_output/y2012_rep1.dta/*, keep(match)*/
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
	r*asthmae
	r*smoken
	r*smokev
	r*mbmi
	r*cwtresp
	r*drink
	r*psyche
	r*smokef
	r*lnlys
	r*alzhe
	r*demene
	r*lbrf_e
	r*drinkd_e
	r*drinkn_e
	r*drinkwn_e
	h*atotb
	h*itot
	r*ltactx_e
	r*mdactx_e
	r*vgactx_e
	
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
	r*mheight
	r*mweight
;
#d cr

* Calculate an mbmi value for wave 9 using wave 8 height and wave 9 weight then drop height and weight
generate r9mbmi = r9mweight / r8mheight^2
drop r*mheight r*mweight

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
	r@asthmae
	r@smoken
	r@smokev
	r@mbmi
	r@cwtresp
	r@drink
	r@psyche
	r@smokef
	r@lnlys
	r@alzhe
	r@demene
	r@lbrf_e
	r@drinkd_e
	r@drinkn_e
	r@drinkwn_e
	h@atotb
	h@itot
	r@ltactx_e
	r@mdactx_e
	r@vgactx_e
	
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


*** Health conditions
foreach var in cancre diabe hearte hibpe lunge stroke psyche alzhe demene asthmae {
	ren r`var' `var'
}
label var cancre "R ever had cancer"
label var diabe "R ever had diabetes"
label var hearte "R ever had heart disease"
label var hibpe "R ever had hypertension"
label var lunge "R ever had lung disease"
label var stroke "R ever had stroke"
label var psyche "R ever had psychological problems"
label var alzhe "R ever had Alzheimers"
label var demene "R ever had dementia"
label var asthmae "R ever had asthma"

*** Mortality
gen died = riwstat
recode died (0 7 9 = .) (1 4 6 = 0) (5 = 1)
label var died "Whether died or not in this wave"

*** Risk factors
foreach var in mbmi smokev smoken drink smokef lnlys drinkd_e drinkn_e drinkwn_e ltactx_e mdactx_e vgactx_e {
	ren r`var' `var'
}

* rename bmi after name change in ELSA release g.2
rename mbmi bmi

label var bmi "R Body mass index"
label var smoken "R smokes now"
label var smokev "R smoke ever"
label var drink "R drinks alcohol"
label var drinkd_e "# days/week drinking"
label var drinkn_e "# drinks/day"
label var drinkwn_e "# drinks/week"

*** Relationship Status
*foreach var in mstat {
*	ren r`var' `var'
*}

* Generate partnership status vars, then drop mstat
* mstat values: 1 - Married
*               3 - Partnered
*               4 - Separated
*               5 - Divorced
*               7 - Widowed
*               8 - Never Married
*replace mstat = 2 if inlist(mstat, 4,5,8)
*replace mstat = 4 if mstat == 7
*label variable mstat "Marriage Status"
*label define mstat 1 "Married" 2 "Single" 3 "Cohabiting" 4 "Widowed"
*label values mstat mstat

*gen married = mstat == 1
*gen single = mstat == 2
*gen cohab = mstat == 3
*gen widowed = mstat == 4
*label variable married "Married"
*label variable single "Single"
*label variable cohab "Cohabiting"
*label variable widowed "Widowed"

* Generate an exercise status variable to hold exercise info in single var
* Three levels:
*   1 - No exercise
*   2 - Light exercise 1+ times per week
*   3 - Moderate/Vigorous exercise 1+ times per week
* Third try now
gen exstat = .
replace exstat = 1 if (ltactx_e == 4 | ltactx_e == 5) & (mdactx_e == 4 | mdactx_e == 5) & (vgactx_e == 4 | vgactx_e == 5)
replace exstat = 2 if (ltactx_e == 2 | ltactx_e == 3) & (mdactx_e == 4 | mdactx_e == 5) & (vgactx_e == 4 | vgactx_e == 5)
replace exstat = 3 if (mdactx_e == 2 | mdactx_e == 3) | (vgactx_e == 2 | vgactx_e == 3)
label var exstat "Exercise Status"
* Now the dummys
gen exstat1 = 1 if exstat == 1
replace exstat1 = 0 if exstat != 1
gen exstat2 = 1 if exstat == 2
replace exstat2 = 0 if exstat != 2
gen exstat3 = 1 if exstat == 3
replace exstat3 = 0 if exstat != 3

* Smoking intensity variable
*recode smokef (0/0.99=0) (1/9.99=1) (10/19.99=2) (20/max=3), gen(smkint)
*label define smkint 1 "Low" 2 "Medium" 3 "High"
*label values smkint smkint
*label variable smkint "Smoking intensity"
*drop smokef
* Now assign any missing that don't smoke to equal 0
*replace smkint = 0 if smoken == 0

* Second attempt at smoking intensity variable
* Going to do a simple 'heavy smoker' var, for respondents that smoke 10 or more cigarettes/day
gen heavy_smoker = (smokef >= 20) if !missing(smokef)
drop smokef


/*
*** Drinking intensity variable
* This is more complicated than smoking, needs to include drinkwn and drinkd (& drinkn)?
* Going to create a drinkstat variable (and replace the current drinkd_stat because its terrible)
* drinkstat will be defined by an intersection between the drinkd, drinkwn, and potentially drinkn vars
* if ANY of the variables are at the extreme end (will find cut off values for weekly/daily drinking), then person.drinkstat == high
* First find binge drinkers 
gen binge = 1 if male & drinkn > 4 & !missing(drinkn)
replace binge = 1 if !male & drinkn > 3 & !missing(drinkn)
replace binge = 0 if male & drinkn <= 4 & !missing(drinkn)
replace binge = 0 if drinkn <= 3 & !missing(drinkn)
* Now heavy drinkers (>14 units ~=~ 7 drinks)
gen heavy = 1 if drinkwn > 7 & !missing(drinkwn)
replace heavy = 0 if drinkwn <= 7 & !missing(drinkwn)
* Now generate heavy_drinker as either of binge or heavy
gen heavy_drinker = 1 if binge == 1 | heavy == 1 & !missing(binge) | !missing(heavy)
replace heavy_drinker = 0 if binge == 0 & missing(heavy)
replace heavy_drinker = 0 if heavy == 0 & missing(binge)
* Now find frequent drinkers (the decision of 6 or more days was arbitrary)
gen freq_drinker = drinkd > 5 if !missing(drinkd)
replace freq_drinker = 0 if drinkd <= 5 & !missing(drinkd)
* Can't be heavy or frequent drinker in the last week if they didn't drink
replace heavy_drinker = 0 if drink == 0
replace freq_drinker = 0 if drink == 0
* Now drop drink vars after generating indicators
drop drinkn drinkwn drinkd
label variable heavy_drinker "Heavy Drinker (>14 units/week)"
label variable freq_drinker "Frequent Drinker (>5 days/week)"
*/

*** Drinking Intensity (Take 2)
*gen problem_drinker = (drinkwn > 7) if !missing(drinkwn)
*replace problem_drinker = (drinkd > 5) if missing(problem_drinker) | problem_drinker == 0
gen problem_drinker = 1 if (drinkwn > 12) & !missing(drinkwn)
replace problem_drinker = 1 if (drinkn > 7) & !missing(drinkn)
replace problem_drinker = 0 if (drinkwn <= 12) & !missing(drinkwn)
replace problem_drinker = 0 if (drinkn > 7) & !missing(drinkn)
*replace problem_drinker = 1 if (drinkd == 7)
*replace problem_drinker = 0 if (drinkd < 7)
label variable problem_drinker "Problem Drinker (binge/too freq)"

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

*** Economic vars
foreach var in lbrf_e {
	ren r`var' `var'
}
* Rename labour force var to remove the _e at the end (I don't like it)
ren lbrf_e lbrf

* Sort out labour force var and generate dummys
recode lbrf (1/2 4= 1 Employed) ///
            (3    = 2 Unemployed) ///
            (5/7  = 3 Retired) ///
            , copyrest gen(workstat)
*drop lbrf
gen employed = workstat == 1
gen unemployed = workstat == 2
gen retired = workstat == 3

*** Money vars
foreach var in atotb itot {
	ren h`var' `var'
}

* Earnings
gen itotx = itot/1000
replace itotx = min(itotx, 200) if !missing(itotx)
label var itotx "Total Family Income in 1000s, max 200"

* Wealth
gen atotbx = atotb/1000
replace atotbx = min(atotbx, 2000) if !missing(atotbx)
label var atotbx "Total Family Wealth in 1000s (max 2000) if positive, zero otherwise"

* Interview year
gen iwyear = 2000 + 2*wave


gen FEM = 0
gen year = iwyear

tempfile ELSA
save `ELSA'
save ELSA_2002_2018.dta, replace
clear all

********************************
* Process simulation output
* iter = numbers of reps
********************************
forvalues i = 1/`iter' {
	forvalues yr = 2002 (2) 2018 {
		append using "`output'/detailed_output/y`yr'_rep`i'.dta"
	}
}
gen reweight = weight/`iter'
gen FEM = 1
gen rep = mcrep + 1

* Earnings
*gen itotx = itot/1000
*replace itotx = min(itotx, 200) if !missing(itotx)

* Wealth
*gen atotbx = atotb/1000
*replace atotbx = min(atotbx, 2000) if !missing(atotbx)

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
*label var psyche "Psychological problems ever"
label var alzhe "Alzheimers ever"
label var demene "Dementia ever"
label var asthmae "Asthma ever"

label var bmi "BMI"
label var smokev "Smoke ever"
label var smoken "Smoke now"
label var drink "Drinks Alcohol"
*label var smkint "Smoking Intensity"
label var heavy_smoker "Heavy Smoker"
*label var lnly "Loneliness Score"
*label var heavy_drinker "Heavy Drinker"
*label var freq_drinker "Frequent Drinker"
label var problem_drinker "Problem Drinker"
label var exstat1 "Exstat - Low activity"
label var exstat2 "Exstat - Moderate activity"
label var exstat3 "Exstat - High activity"
*label var mstat "Marriage Status"
*label var married "Married"
*label var single "Single"
*label var cohab "Cohabiting"
*label var widowed "Widowed"

label var workstat "Working Status"
label var employed "Employed"
label var unemployed "Unemployed"
label var retired "Retired"

*label var itotx "Total Family Income (thou.)"
*label var atotbx "Total Family Wealth (thou.)"

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

* Removed in core model: psyche lnly itotx atotbx

local binhlth cancre diabe hearte hibpe lunge stroke anyadl anyiadl alzhe demene
local risk smoken smokev bmi drink heavy_smoker problem_drinker exstat1 exstat2 exstat3
local binecon employed unemployed retired
local cntecon
local demog age_yrs male white
local unweighted died

save testing_crossvalidation.dta, replace

* cntecon
foreach tp in binhlth risk binecon demog {
	forvalues wave = `minwave'/`maxwave' {
		file open myfile using "`output'/fem_elsa_ttest_`tp'_`wave'.txt", write replace
		file write myfile "variable" _tab "fem_mean" _tab "fem_n" _tab "fem_sd" _tab "elsa_mean" _tab "elsa_n" _tab "elsa_sd" _tab "p_value" _n
		
		local yr = 2000 + 2*`wave'
		
		foreach var in ``tp'' {
		
			* BMI has no data for odd waves, skip over these in the loop
			if "`var'" == "bmi" & (`wave' == 1 | `wave' == 3 | `wave' == 5 | `wave' == 7) {
				continue
			}
			else if "`var'" == "drinkd" | "`var'" == "lnly" | "`var'" == "problem_drinker" & `wave' == 1 {
				continue
			}
			
			local select
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
* cntecon
foreach tabl in binhlth risk binecon demog unweighted {
	
	foreach wave in 3 4 5 6 8 9 {
		tempfile wave`wave'
		insheet using "`output'/fem_elsa_ttest_`tabl'_`wave'.txt",clear
	
		foreach var in `varlist' {
			ren `var' `var'_wave`wave'
		}
		save `wave`wave''
	}
	
	di "Table is `tabl'"

	use "`wave3'", replace
	merge 1:1 variable using "`wave4'", nogen
	merge 1:1 variable using "`wave5'", nogen
	merge 1:1 variable using "`wave6'", nogen
	merge 1:1 variable using "`wave8'", nogen
	merge 1:1 variable using "`wave9'", nogen
	
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
* cntecon
foreach tabl in binhlth risk binecon demog unweighted {
	
	foreach wave in 1 2 3 4 5 6 7 8 9 {
		tempfile wave`wave'
		insheet using "`output'/fem_elsa_ttest_`tabl'_`wave'.txt",clear
	
		foreach var in `varlist' {
			ren `var' `var'_wave`wave'
		}
		save `wave`wave''
	}

	use "`wave1'", replace
	merge 1:1 variable using "`wave2'", nogen
	merge 1:1 variable using "`wave3'", nogen
	merge 1:1 variable using "`wave4'", nogen
	merge 1:1 variable using "`wave5'", nogen
	merge 1:1 variable using "`wave6'", nogen
	merge 1:1 variable using "`wave7'", nogen
	merge 1:1 variable using "`wave8'", nogen
	merge 1:1 variable using "`wave9'", nogen
	
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
