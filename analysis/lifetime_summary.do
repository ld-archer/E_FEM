***=======================================================*	 
* FEM scenario combination - lifetime
* Sep 25, 2008
***=======================================================*	 

capt log close
clear
cap clear mata
set more off
set mem 500m
set linesize 255


* Assume that this script is being executed in the analysis directory

* Load environment variables from the root FEM directory, one level up
* these define important paths, specific to the user
include "../fem_env.do"


global out_path "$local_root/output/JHE"

***=============================*	 
global outdata "$local_root/output/JHE"

global scnr_base "status_quo smk_iom smk_ext whiter intermed_obese extreme_obese higrowth lowgrowth cure_diabe cure_cancre cure_hibpe workup_mild workdown_mild workup_ext workdown_ext" 
global yrs 2030 2050 

global scnr status_quo2004
foreach s in $scnr_base {
	foreach y in $yrs {
			global scnr $scnr `s'`y'
	}
}

* Year to discount back to
local base_year = 2004

* Pop discount rate
local disrate1 = 0

* $ discount rate
local disrate2 = 0.03
set trace off

local i = 0
foreach x in $scnr {
	local i = `i' + 1
}
matrix matr = J(`i',17,.)
matrix rownames matr = $scnr
matrix colnames matr = ID LE HEALTH_LE QALY GOVREV GOVEXP LFSPEND ssben ssiben diben caremd caidmd  ftax stax ctax hoasi hmed

*********************************
* Adjustment factors
*********************************
local sorder = 1
foreach scr in $scnr {
	
	matrix matr[rownumb(matr,"`scr'"), colnumb(matr,"ID")] = `sorder'
	local sorder = `sorder' + 1
	
	drop _all
	use "$outdata/`scr'/summary.dta"
	

	sort year
	merge year using "$local_root/analysis/cpi_adjust.dta", nokeep
	assert _m == 3
	drop _m
	
	foreach j in ry_earn fed_tax state_tax county_tax ss_tax med_tax ss_ben di_ben ssi_ben ttl_mcare ttl_caidmd ttl_totmd{
		replace `j' = `j'*adjust
	}
	
	foreach v in ss_tax med_tax ss_ben ssi_ben di_ben fed_tax state_tax county_tax ttl_mcare ttl_totmd bs_treat_new {
		replace `v' = 0 if `v' == .
	}
	
	rename ss_tax ttl_hoasi
	rename med_tax ttl_hmed
	rename ss_ben ttl_ssben
	rename ssi_ben ttl_ssiben
	rename di_ben ttl_diben
	
	rename fed_tax ttl_ftax
	rename state_tax ttl_stax
	rename county_tax ttl_ctax
	rename ttl_mcare ttl_caremd
	
	rename end_pop pop
	rename qaly_sum qaly
replace qaly = qaly/10^6
	**NEED TO PUT IN ADJUSTMENT FACTORS
	
	gen govexp = ttl_ssben + ttl_ssiben + ttl_diben + ttl_caremd + ttl_caidmd
	gen govrev = ttl_ftax + ttl_stax + ttl_ctax + ttl_hoasi + ttl_hmed
	
	keep year pop pop_healthy govrev govexp ttl_totmd ttl_ssben ttl_ssiben ttl_diben ttl_caremd ttl_caidmd  ttl_ftax ttl_stax ttl_ctax ttl_hoasi ttl_hmed bs_treat_new qaly
	
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
	foreach x in pop pop_healthy  qaly {
		gen `x'_old = `x'
		local k1 = _n+1
		local k2 = _n-1
		xtset id year
		sort id year

		replace `x' = (f.`x' + l.`x')/2 if _n > 1 & _n < _N & mod(year,2) != 0
		replace `x' = `x' * ((1/(1+`disrate1'))^(year-`base_year'))
	}
	drop if year > `max_yr'
	foreach x in govrev govexp ttl_totmd ttl_ssben ttl_ssiben ttl_diben ttl_caremd ttl_caidmd  ttl_ftax ttl_stax ttl_ctax ttl_hoasi ttl_hmed {
		gen `x'_old = `x'
		local k1 = _n+1
		local k2 = _n-1
		xtset id year
		sort id year

		replace `x' = (f.`x' + l.`x')/2 if _n > 1 & _n < _N & mod(year,2) != 0
		replace `x' = `x' * ((1/(1+`disrate2'))^(year-`base_year'))
	}
	
	replace ttl_totmd = bs_treat_new * 20 + ttl_totmd
	
	drop *old
	
	* LE, disable-free LE, lifetime ME
	
	qui sum pop if year == `myr'
	local init_pop = r(mean)
	qui sum pop
	local ttlyr = r(sum)
	matrix matr[rownumb(matr,"`scr'"), colnumb(matr,"LE")] = `ttlyr'/`init_pop'

	qui sum pop_healthy if year == `myr'
	local init_pop_hlth = r(mean)
	qui sum pop_healthy
	local ttlyr = r(sum)
	* matrix matr[rownumb(matr,"`scr'"), colnumb(matr,"HEALTH_LE")] = `ttlyr'/`init_pop_hlth'	
	matrix matr[rownumb(matr,"`scr'"), colnumb(matr,"HEALTH_LE")] = `ttlyr'/`init_pop'	

	qui sum qaly
	local ttlyr = r(sum)
	matrix matr[rownumb(matr,"`scr'"), colnumb(matr,"QALY")] = `ttlyr'/`init_pop'



	qui sum ttl_totmd 
	local ttlmd = r(sum)
	matrix matr[rownumb(matr,"`scr'"), colnumb(matr,"LFSPEND")] = int(`ttlmd'*1000/`init_pop'	)

	qui sum govrev
	local ttl = r(sum)
	matrix matr[rownumb(matr,"`scr'"), colnumb(matr,"GOVREV")] =int( `ttl'*1000/`init_pop')

	qui sum govexp
	local ttl = r(sum)
	matrix matr[rownumb(matr,"`scr'"), colnumb(matr,"GOVEXP")] = int(`ttl'*1000/`init_pop')			
	
	foreach i in ssben ssiben diben caremd caidmd  ftax stax ctax hoasi hmed{
		qui sum ttl_`i'
		local ttl = r(sum)
		matrix matr[rownumb(matr,"`scr'"), colnumb(matr,"`i'")] = int(`ttl'*1000/`init_pop')			
	}
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
	#d;
	outsheet scenario LE HEALTH_LE GOVREV GOVEXP LFSPEND ssben ssiben 
	diben caremd caidmd  ftax stax ctax hoasi hmed 
	using "$local_root/analysis/lftime_summary.csv", replace comma nol;
	#d cr

capt log close

	
