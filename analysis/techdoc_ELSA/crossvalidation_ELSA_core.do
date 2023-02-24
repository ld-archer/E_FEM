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
use `input'/H_ELSA_g2_wv_specific.dta, clear

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

	r*iwindy
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
	h*atotb
	h*itot
	h*coupid
	r*ltactx_e
	r*mdactx_e
	r*vgactx_e
	r*jphysl
	
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
	c*cpindex
	r*GOR
	r*angine
	r*hrtatte
	r*conhrtfe
	r*hrtmre
	r*hrtrhme
	r*catracte
	r*osteoe
	r*lnlys3
	r*scako
	r*kcntm
	r*rcntm
	r*fcntm
	r*socyr
	r*mstat
;
#d cr

* Calculate an mbmi value for wave 9 using wave 8 height and wave 9 weight then drop height and weight
generate r9mbmi = r9mweight / r8mheight^2
drop r*mheight r*mweight

* Reshape this data to long
#d ;
local shapelist
	r@iwindy
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
	h@atotb
	h@itot
	h@coupid
	r@ltactx_e
	r@mdactx_e
	r@vgactx_e
	r@jphysl
	
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
	r@GOR
	r@angine
	r@hrtatte
	r@conhrtfe
	r@hrtmre
	r@hrtrhme
	r@catracte
	r@osteoe
	r@lnlys3
	r@scako
	r@kcntm
	r@rcntm
	r@fcntm
	r@socyr
	r@mstat
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
foreach var in cancre diabe hearte hibpe lunge stroke psyche alzhe demene asthmae angine hrtatte conhrtfe hrtmre hrtrhme catracte osteoe {
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
label var angine "R ever had Angina"
label var hrtatte "R ever had Heart Attack"
label var conhrtfe "R ever had Congenital Heart Failure"
label var hrtmre "R ever had Heart Murmur"
label var hrtrhme "R ever had Abnormal Heart Rhythm"
label var catracte "R ever had Cataracts"
label var osteoe "R ever had Osteoporosis"

*** Mortality
gen died = riwstat
recode died (0 7 9 = .) (1 4 6 = 0) (5 = 1)
label var died "Whether died or not in this wave"

*** Risk factors
foreach var in mbmi smokev smoken drink smokef lnlys lnlys3 ltactx_e mdactx_e vgactx_e scako kcntm rcntm fcntm socyr mstat jphysl{
	ren r`var' `var'
}

* rename bmi after name change in ELSA release g.2
rename mbmi bmi

label var bmi "R Body mass index"
label var smoken "R smokes now"
label var smokev "R smoke ever"
label var smokef "R number cigarettes / day"
label var drink "R drinks alcohol"
label var lnlys "R average of 4 level loneliness summary score"
label var lnlys3 "R average of 3 level loneliness summary score"
label var scako "Alcohol consumption frequency, [1-8]"
label var mstat "Marriage / Partnership status"
label var jphysl "Job physical activity level"


****** EXERCISE ******

** 23/02/23 Changing this variable to a binary variable defined in:
* Shankar et al. (2011) - https://psycnet.apa.org/record/2011-08649-001

* Active - Moderate or vigorous physical activity more than once per week OR if employed, occupation is any of standing, physical work, or heavy manual work
* Not Active - Moderate or vigorous physical activity only once a week or less AND if employed, occupation is reported as primarily sedentary

gen physact = .
* First check activity level then job
* (Moderate &| Vigorous) &| (Occupation physical activity level)
replace physact = 1 if (mdactx_e == 2 | vgactx_e == 2) | (inlist(jphysl, 2, 3, 4)) 
replace physact = 0 if (mdactx_e != 2 & vgactx_e != 2) & (jphysl == 1)
replace physact = 1 if inlist(jphysl, 2, 3, 4) & !missing(jphysl)
replace physact = 0 if jphysl == 1

/* * Generate an exercise status variable to hold exercise info in single var
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
replace exstat3 = 0 if exstat != 3 */

* Second attempt at smoking intensity variable
* Going to do a simple 'heavy smoker' var, for respondents that smoke 10 or more cigarettes/day
*gen heavy_smoker = (smokef >= 20) if !missing(smokef)
*drop smokef

****** MARRIAGE/PARTNERSHIP STATUS ******

* Generate partnership status vars, then drop mstat
* mstat values: 1 - Married
*               3 - Partnered
*               4 - Separated
*               5 - Divorced
*               7 - Widowed
*               8 - Never Married
replace mstat = 2 if inlist(mstat, 4,5,8)
replace mstat = 4 if mstat == 7
label define mstat 1 "Married" 2 "Single" 3 "Cohabiting" 4 "Widowed"
label values mstat mstat

gen married = mstat == 1
gen single = mstat == 2
gen cohab = mstat == 3
gen widowed = mstat == 4
label variable married "Married"
label variable single "Single"
label variable cohab "Cohabiting"
label variable widowed "Widowed"

****** LONELINESS ******

* loneliness is brought into our model as a summary score for 4 questions relating to loneliness
* To use this score (which is ordinal, containing non-integers), we are going to round the values and keep them as 3 categories: low, medium and high
* Potentially in the future, we could just keep the high loneliness? Try full var first
gen lnly = round(lnlys3, 1)
label variable lnly "Loneliness level [1, 3]"
* Now generate some dummys
gen lnly1 = lnly == 1
gen lnly2 = lnly == 2
gen lnly3 = lnly == 3
* Labels
label variable lnly1 "Loneliness level: low"
label variable lnly2 "Loneliness level: medium"
label variable lnly3 "Loneliness level: high"
* Drop original
*drop lnlys3

****** INDEX OF SOCIAL ISOLATION ******

* Generate an index of social isolation as in this study by Shankar et al. (2011) - https://pubmed.ncbi.nlm.nih.gov/21534675/
* Index ranges from 1-6, with a score of +1 for the following 5 things
* - Not married/cohabiting with a partner
* - Had less than monthly contact (including face-to-face, telephone, or written/email contact) with (+1 each):
*     - children 
*     - other immediate family 
*     - friends
* - Did not participate in any organisations, religious groups, or committees that meet at least once a year
* 1-6 chosen instead of 0-5 because FEM doesn't like 0 values in ordinal variables for some reason
gen sociso = 1
replace sociso = sociso + 1 if married == 1 | cohab == 1 & !missing(mstat) /*Married or cohabiting*/
replace sociso = sociso + 1 if kcntm == 0 & !missing(kcntm) /*Kids contact less than monthly*/
replace sociso = sociso + 1 if rcntm == 0 & !missing(rcntm) /*Relatives contact less than monthly*/
replace sociso = sociso + 1 if fcntm == 0 & !missing(fcntm) /*friends contact less than monthly*/
replace sociso = sociso + 1 if socyr == 0 & !missing(socyr) /*not member of religious group, committee, or other organisation*/
* drop elements of index
drop kcntm rcntm fcntm socyr
* Dummy vars
gen sociso1 = (sociso == 1) & !missing(sociso)
gen sociso2 = (sociso == 2) & !missing(sociso)
gen sociso3 = (sociso == 3) & !missing(sociso)
gen sociso4 = (sociso == 4) & !missing(sociso)
gen sociso5 = (sociso == 5) & !missing(sociso)
gen sociso6 = (sociso == 6) & !missing(sociso)

****** ALCOHOL ******
** Moving from the previous consumptiong based alcohol vars in the FEM (alcbase/alcstat) to a frequency based version (scako)
* First rename to something more useful (like alcfreq)
ren scako alcfreq
* Now define labels for each of the levels
label define alcfreq 1 "Almost every day" 2 "five or six days a week" 3 "three or four days a week" 4 "once or twice a week" 5 "once or twice a month" 6 "once every couple of months" 7 "once or twice a year" 8 "not at all in the last 12 months"
label values alcfreq alcfreq
* handle missings
replace alcfreq = . if alcfreq < 0
* Create dummys for prediction and label
gen alcfreq1 = alcfreq == 1
gen alcfreq2 = alcfreq == 2
gen alcfreq3 = alcfreq == 3
gen alcfreq4 = alcfreq == 4
gen alcfreq5 = alcfreq == 5
gen alcfreq6 = alcfreq == 6
gen alcfreq7 = alcfreq == 7
gen alcfreq8 = alcfreq == 8
label variable alcfreq1 "Alcohol consumption: Almost every day"
label variable alcfreq2 "Alcohol consumption: five or six days a week"
label variable alcfreq3 "Alcohol consumption: three or four days a week"
label variable alcfreq4 "Alcohol consumption: once or twice a week"
label variable alcfreq5 "Alcohol consumption: once or twice a month"
label variable alcfreq6 "Alcohol consumption: once every couple of months"
label variable alcfreq7 "Alcohol consumption: once or twice a year"
label variable alcfreq8 "Alcohol consumption: not at all in the last 12 months"

* Sampling weight
ren rcwtresp weight
label var weight "R cross-sectional weight"

*codebook weight

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
recode lbrf (1/2   = 1 "Employed") ///
            (3 6/7 = 2 "Inactive") ///
            (4/5   = 3 "Retired") ///
            , copyrest gen(workstat)
drop lbrf
gen employed = workstat == 1
gen inactive = workstat == 2
gen retired = workstat == 3

*** Money vars
foreach var in atotb itot {
	ren h`var' `var'
}

*** Income and Wealth
** Replace top-coded values of itot with 900000 (see p599 harmonised codebook)
replace itot = 900000 if itot == .t

* rename iwindy for inflation adjustment
ren riwindy iwindy
ren hcoupid coupid
** Rebase cpindex var from 2010 to 2012 (start year of simulation)
* Formula for this: updatedValue = oldValue / newBaseBalue(2012) * 100
* Example of this given here: https://mba-lectures.com/statistics/descriptive-statistics/508/shifting-of-base-year.html
forvalues n = 2001/2019 {
    gen newc`n'cpindex = (c`n'cpindex / c2012cpindex) * 100 // generate new index with 2012 base year
    drop c`n'cpindex // drop original cpindex
    ren newc`n'cpindex c`n'cpindex // rename new base to match old varnames
}

** Now modify all financial vars for inflation using the rebased CPI
* Adjusted value = (oldValue / cpindex) * 100
* https://timeseriesreasoning.com/contents/inflation-adjustment/
* Problem here with negative values, need to do this with absolute values then flip the sign back
* First take absolute values
gen newatotb = abs(atotb)
gen newitot = abs(itot)
* Generate flag if financial values are negative
gen negatotb = 1 if atotb < 0
gen negitot = 1 if itot < 0
* Loop through values so we only change values from specific years
forvalues n = 2001/2019 {
    replace newatotb = (newatotb / c`n'cpindex ) * 100 if iwindy == `n' // Generate updated atotb values based on interview year
    replace newitot = (newitot / c`n'cpindex ) * 100 if iwindy == `n' // Same for itot
}
* Do some hacky thing to turn the value negative if the flag == 1
replace newatotb = newatotb - (newatotb * 2) if negatotb == 1
replace newitot = newitot - (newitot * 2) if newitot == 1

* Finally replace the original financial vars and drop the intermediate things plus the CPI
replace atotb = newatotb
replace itot = newitot
drop newatotb newitot negatotb negitot
forvalues n = 2001/2019 {
    drop c`n'cpindex
}

** Now adjust couple level (benefit unit level) data into individual values
* To do this, multiply those in a couple by sqrt(2)
bysort coupid wave: gen atotb_adjusted = atotb / sqrt(2) if _N == 2
bysort coupid wave: gen itot_adjusted = itot / sqrt(2) if _N == 2

* Now replace original value with values adjusted for benefit unit level
replace atotb = atotb_adjusted if !missing(atotb_adjusted)
replace itot = itot_adjusted if !missing(itot_adjusted)

* Now replace original value with values adjusted for benefit unit level
replace atotb = atotb_adjusted if !missing(atotb_adjusted)
replace itot = itot_adjusted if !missing(itot_adjusted)

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
gen itotx = itot/1000
replace itotx = min(itotx, 200) if !missing(itotx)

* Wealth
gen atotbx = atotb/1000
replace atotbx = min(atotbx, 2000) if !missing(atotbx)

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
label var angine "Angina ever"
label var hrtatte "Heart Attack ever"
label var conhrtfe "Congenital Heart Failure ever"
label var hrtmre "Heart Murmur ever"
label var hrtrhme "Abnormal Heart Rhythm ever"
label var catracte "Cataracts ever"
label var osteoe "Osteoporosis ever"

label var bmi "BMI"
label var smokev "Smoke ever"
label var smoken "Smoke now"
label var smokef "No. cigarettes / day"
label var drink "Drinks Alcohol"
label var alcfreq "Frequency of Alcohol Consumption [1-8]"
label variable alcfreq1 "Alcohol consumption: Almost every day"
label variable alcfreq2 "Alcohol consumption: five or six days a week"
label variable alcfreq3 "Alcohol consumption: three or four days a week"
label variable alcfreq4 "Alcohol consumption: once or twice a week"
label variable alcfreq5 "Alcohol consumption: once or twice a month"
label variable alcfreq6 "Alcohol consumption: once every couple of months"
label variable alcfreq7 "Alcohol consumption: once or twice a year"
label variable alcfreq8 "Alcohol consumption: not at all in the last 12 months"
*label var exstat1 "Exstat - Low activity"
*label var exstat2 "Exstat - Moderate activity"
*label var exstat3 "Exstat - High activity"
label var physact "Physically active"
label var lnly "Loneliness Score [1,3]"
label var lnly1 "Loneliness Score: Low"
label var lnly2 "Loneliness Score: Medium"
label var lnly3 "Loneliness Score: High"
label var sociso "Social Isolation"
label var sociso1 "Social Isolation == 1"
label var sociso2 "Social Isolation == 2"
label var sociso3 "Social Isolation == 3"
label var sociso4 "Social Isolation == 4"
label var sociso5 "Social Isolation == 5"
label var sociso6 "Social Isolation == 6"

label var workstat "Working Status"
label var employed "Employed"
label var inactive "Inactive"
label var retired "Retired"

label var itotx "Total Family Income (thou.)"
label var atotbx "Total Family Wealth (thou.)"

label var age_yrs "Age at interview"
label var male "Male"
label var white "White"


* Replace smokef to missing for people who don't smoke
replace smokef = . if smoken == 0 & !missing(smoken)

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

local binhlth cancre diabe hearte hibpe lunge stroke anyadl anyiadl alzhe demene catracte
local risk smoken smokev smokef bmi drink lnly /*lnly1 lnly2 lnly3*/ alcfreq /*alcfreq1 alcfreq2 alcfreq3 alcfreq4 alcfreq5 alcfreq6 alcfreq7 alcfreq8*/ sociso /*sociso1 sociso2 sociso3 sociso4 sociso5 sociso6*/ physact
local binecon employed inactive retired
local cntecon itotx atotbx
local demog age_yrs male white
local unweighted died

save testing_crossvalidation.dta, replace

foreach tp in binhlth risk binecon cntecon demog {
	forvalues wave = `minwave'/`maxwave' {
		file open myfile using "`output'/fem_elsa_ttest_`tp'_`wave'.txt", write replace
		file write myfile "variable" _tab "fem_mean" _tab "fem_n" _tab "fem_sd" _tab "elsa_mean" _tab "elsa_n" _tab "elsa_sd" _tab "p_value" _n
		
		local yr = 2000 + 2*`wave'
		
		foreach var in ``tp'' {
		
			* BMI has no data for odd waves (except wave 9), skip over these in the loop
			if "`var'" == "bmi" & (`wave' == 1 | `wave' == 3 | `wave' == 5 | `wave' == 7) {
				continue
			}
			else if ("`var'" == "lnly" | "`var'" == "lnly1" | "`var'" == "lnly2" | "`var'" == "lnly3") & `wave' == 1 {
				continue
			}
			else if ("`var'" == "alcfreq" | "`var'" == "alcfreq1" | "`var'" == "alcfreq2" | "`var'" == "alcfreq3" | "`var'" == "alcfreq4" | "`var'" == "alcfreq5" | "`var'" == "alcfreq6" | "`var'" == "alcfreq7" | "`var'" == "alcfreq8") & `wave' == 1 {
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
foreach tabl in binhlth risk binecon cntecon demog unweighted {
	
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
foreach tabl in binhlth risk binecon cntecon demog unweighted {
	
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
