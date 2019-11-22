/** \file

produces the pop5152_projection_2080 file

\ 5-13-2014 project through 2080 from 2012 population projections
*/
  
clear
set memory 100m
set more off

include ../../../fem_env.do

global pop_proj pop5152_projection

**Project 2060 - 2150 population of incoming cohort: using linear trend based on 2040-2060**

clear
tempfile temp_fin

forvalues i = 0/1{
	forvalues j = 0/1{
		forvalues k = 0/1{
			clear
			use "$outdata/$pop_proj.dta" if male == `i' & hispan == `j' & black == `k'
			count
			if r(N) > 0 {
				* expand dataset by number of rows needed to hold projections
				set obs `=_N + 45'
				
				sort year
				replace year = year[_n-1]+2 if year ==. & _n > 1
				replace male = `i' 
				replace hispan = `j'
				replace black = `k'
				reg pop year if year >= 2040 & year <= 2060
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
save "$outdata/pop5152_projection_2150.dta", replace
