***=======================================================*	 
* FEM scenario combination - lifetime
* Sep 25, 2008
***=======================================================*	 

capt log close
* log using logs/lftime_summary.log, replace
clear
cap clear mata
set more off
set mem 500m
set linesize 255
pause on 



***=============================*	 
global outdata "T:\vaynman\FEM\current\output\JHE\cohort_analysis"

global scnr_base  "bar_surg100 bar_surg100_smk_ext bar_surg100_smk_iom bar_surg50 bar_surg50_smk_ext bar_surg50_smk_iom"
global scnr_base  "$scnr_base combo100 combo100_smk_ext combo100_smk_iom combo50 combo50_smk_ext combo50_smk_iom pill pill_smk_ext"
global scnr_base  "$scnr_base pill_smk_iom smk_ext smk_iom status_quo"

global cohort_yrs 2010 2030
global grps obese obese2p obese3p

global scnr

foreach s in $scnr_base {
	foreach y in $cohort_yrs {
		global scnr "$scnr `s'_cohort`y'"
		foreach g in $grps {
			global scnr "$scnr `s'_cohort`y'_`g'"	
		}
	}
}

local disrate1 = 0
local disrate2 = 0.03
set trace off

local i = 0
foreach x in $scnr {
	local i = `i' + 1
}
matrix matr = J(`i',8,.)
* matrix rownames matr = $scnr
matrix colnames matr = ID INIT_POP LE HEALTH_LE LFSPEND QALY BARSURG PILL

*********************************
* Adjustment factors
*********************************
local sorder = 1
foreach scr in $scnr {
	
	matrix matr[`sorder', colnumb(matr,"ID")] = `sorder'
	
	drop _all
	use "$outdata\\`scr'\summary.dta"

	rename end_pop pop
	rename qaly_sum qaly

	
	keep year pop pop_healthy ttl_totmd qaly bs_treat_new wlp_new
	replace qaly = qaly/10^6
	
	* Include odds years
	qui sum year
	local myr = r(min)
	local max_yr = r(max)
	sort year, stable
	expand 2
	sort year, stable
	gen year_old = year
	replace year = `myr' + _n-1
	gen id = 1
	foreach x in pop pop_healthy qaly  {
		gen `x'_old = `x'
		local k1 = _n+1
		local k2 = _n-1
		xtset id year
		sort id year

		replace `x' = (f.`x' + l.`x')/2 if _n > 1 & _n < _N & mod(year,2) != 0
		replace `x' = `x' * ((1/(1+`disrate1'))^(year-`myr'))
	}
	drop if year > `max_yr'

	foreach x in bs_treat_new wlp_new {
		replace `x' = 0 if  mod(year,2) != 0

	}

	foreach x in ttl_totmd {
		gen `x'_old = `x'
		local k1 = _n+1
		local k2 = _n-1
		xtset id year
		sort id year

		replace `x' = (f.`x' + l.`x')/2 if _n > 1 & _n < _N & mod(year,2) != 0
		replace `x' = `x' * ((1/(1+`disrate2'))^(year-`myr'))
	}

	replace ttl_totmd = bs_treat_new * 20 + ttl_totmd

	drop *old

	* LE, disable-free LE, lifetime ME
	
	qui sum pop if year == `myr'
	local init_pop = r(mean)
	matrix matr[`sorder', colnumb(matr,"INIT_POP")] = `init_pop'
	

	qui sum pop
	local ttlyr = r(sum)
	matrix matr[`sorder', colnumb(matr,"LE")] = `ttlyr'/`init_pop'


	qui sum qaly
	local ttlyr = r(sum)
	matrix matr[`sorder', colnumb(matr,"QALY")] = `ttlyr'/`init_pop'


	qui sum pop_healthy if year == `myr'
	local init_pop_hlth = r(mean)
	qui sum pop_healthy
	local ttlyr = r(sum)
	* matrix matr[rownumb(matr,"`scr'"), colnumb(matr,"HEALTH_LE")] = `ttlyr'/`init_pop_hlth'	
	matrix matr[`sorder', colnumb(matr,"HEALTH_LE")] = `ttlyr'/`init_pop'	



	qui sum ttl_totmd 
	local ttlmd = r(sum)
	matrix matr[`sorder', colnumb(matr,"LFSPEND")] = int(`ttlmd'*1000/`init_pop'	)

	qui sum bs_treat_new
	local ttl_bs_treated= r(sum)
	matrix matr[`sorder', colnumb(matr,"BARSURG")] = `ttl_bs_treated'

	qui sum wlp_new
	local ttl_wlp_new = r(sum)
	matrix matr[`sorder', colnumb(matr,"PILL")] = `ttl_wlp_new'
	
	local sorder = `sorder' + 1


}

matrix list matr
drop _all
svmat matr, names(col)
sort ID, stable
gen n = _n
local sorder = 1
gen scenario = ""
foreach scr in $scnr {
		replace scenario = "`scr'" if `sorder' == n
		local sorder = `sorder' + 1
	}
drop ID n
