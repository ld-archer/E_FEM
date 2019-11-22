
* List of conditions that have been turned off
local offcond change cancre diabe hearte hibpe stroke lunge

* Simulation start year
local simstartyr 2010
local simendyr 2090

foreach cond in `offcond' {
	* stack years of detailed output for disease scenario
	clear
	forvalues i = `simstartyr'(2)`simendyr' {
		append using "../../output/no_`cond'/detailed_output/y`i'_rep1.dta"
	}
	
	* for no change scenario
	if("`cond'" == "change") {
		gen lchange=0
		gen change=0 
	}
	
	*format %15.0g hhidpn
	
	* save initial weight
	bys hhidpn year: gen initwt = weight[1]
	
	* keeping years of disease incidence or death
	keep if (l`cond'==0 & `cond'==1) | died==1

	* for people who didn't have disease before death wave, create record for 'incident' year
	expand 2 if died==1 & l`cond'==0, generate(inc_dummy)
	replace died=0 if inc_dummy==1
	* for people who never got the disease, set incident year to the year they were 51-52 (first year of the simulation)
	replace year=`simstartyr' if inc_dummy==1 & `cond'==0
	
	* compute time between incidence and death, then collapse to single observation
	sort hhidpn year died
	gen inc_year = year[_n-1] if died==1
	drop if died==0
	di "Incidence count by year"
	tab inc_year `cond' [fw=round(initwt)], m
	* assume death happens in the middle of a time step on average, so subtract one year
	gen survtime = year - inc_year - 1
	replace survtime = 0 if survtime == -1
	sum survtime [fw=round(initwt)]

	di "make sure everyone is dead"
	tab died, m
	
	label var inc_year "disease incidence year"
	label var initwt "baseline weight"
	label var survtime "survival time after incidence"
	
	 format hhidpn %20.0g
	
	* save file for survival analysis of disease
	keep hhidpn `cond' survtime initwt inc_year
	save "no_`cond'_survival.dta", replace
}
