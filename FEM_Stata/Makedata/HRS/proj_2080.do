/** \file

produces the trend_all_2080 file

\deprecated The output from this file no logner seems to be required.
*/
  
capt log close
log using proj_2080.log, replace

set more off

global fem_path "/zeno/a/FEM/FEM_1.0"
global outdata  "$fem_path/Input_yh"
global pop_proj pop5152_projection

**Project 2050 - 2080 population of incoming cohort: using linear trend based on 2030-2050**

clear
tempfile temp_fin

forvalues i = 0/1{
	forvalues j = 0/1{
		forvalues k = 0/1{
			clear
			use "$outdata/$pop_proj.dta" if male == `i' & hispan == `j' & black == `k'
			count
			if r(N) > 0 {
				set obs 39
				sort year
				replace year = year[_n-1]+2 if year ==. & _n > 1
				replace male = `i' 
				replace hispan = `j'
				replace black = `k'
				reg pop year if year >= 2030 & year <= 2050
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
save "$outdata/pop5152_projection_2080.dta", replace

clear
use "$outdata/trend_all.dta"
**extend 2050 to 2080**
set obs 77
sort year
replace year = year[_n-1]+1 if _n > 1 & year ==.

foreach i in  pcancre pdiabe phearte phibpe plunge pstroke pwtstate2 pwtstate3 psmkstat2 psmkstat3 pfuncstat2 pfuncstat3 pwork panydb panydc plogiearnx ploghatotax pwlth_nonzero plogdcwlthx phispan pblack ppop pmale phsless pcollege psingle pwidowed panyhi{
	replace `i' = `i'[_n-1] if `i' ==. & year > 2050
}
save "$outdata/trend_all_2080.dta", replace

log close


				
