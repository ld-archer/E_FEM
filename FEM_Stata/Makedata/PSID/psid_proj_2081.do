/** \file

produces the pop2526_projection_2081 file

*/
  

include common.do

**Project 2061 - 2081 population of incoming 25-26 year old cohort: using linear trend based on 2029-2059**


clear
use "$outdata/pop2526_projection.dta"
*How many time intervals to project into the future, i.e. if we want to project 2061-2081 population, then we have 11 two-year intervals to project
*IntervalsToProject = (The final year to project to - the last year for which there's available projection from the census) / 2
summarize year
local FinalYearToProject = 2081
local FinalYearCensusProjection = r(max)
local IntervalsToProject=(`FinalYearToProject'-`FinalYearCensusProjection')/2

clear
tempfile temp_fin

forvalues i = 0/1{
	forvalues j = 0/1{
		forvalues k = 0/1{
			clear
			use "$outdata/pop2526_projection.dta" if male == `i' & hispan == `j' & black == `k'
			count
			local ObsExisting = r(N)
			if r(N) > 0 {
				*This ExpandedObs reflects number of observations from 2009-2049 (ObsExisting) and then new observations from 2051-2081 (IntervalsToProject)
				local ExpandedObs = `IntervalsToProject' + `ObsExisting'
				set obs `ExpandedObs'
				sort year
				replace year = year[_n-1]+2 if year ==. & _n > 1
				replace male = `i' 
				replace hispan = `j'
				replace black = `k'
				reg pop year if year >= 2029 & year <= `FinalYearCensusProjection'
				predict pop_pred
				replace pop = pop_pred if pop == .
				drop pop_pred
				if `i' == 0 & `j' == 0 & `k' == 0{
					save `temp_fin', replace
				}
				else{
					append using `temp_fin'
					save `temp_fin', replace
				}
			}
		}
	}
}

clear
use `temp_fin'
bysort year  male  hispan  black: assert _n == 1
save "$outdata/pop2526_projection_2081.dta", replace

capture log close