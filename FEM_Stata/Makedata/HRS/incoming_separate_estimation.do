/** \file
Cross-sectional regressions of tenure for job with a DB and claiming DI

- Mar 22, 2008
- Apr 8, 2008, add estimation for SSI

\todo When possible, use global variable lists from fem_env.do instead of these custom ones.
*/
include common.do

* use "$dua_rand_hrs/all2004r.dta"
use "$dua_rand_hrs/age5055_hrs1992r.dta", clear

* Generate dummies for categorical 
global ordered wtstate smkstat rdb_ea_c rdb_na_c
* For categorical outcomes
global wtstate_cat overwt obese_1 obese_2 obese_3
global smkstat_cat smokev smoken 
global rdb_ea_c_cat rdb_ea_2 rdb_ea_3
global rdb_na_c_cat rdb_na_2 rdb_na_3 rdb_na_4

/* Dummies for ordered outcomes */	
foreach x of varlist $ordered {
	if "`x'" == "rdb_na_c" {
		local num_cut = 4
	}
	else if "`x'" == "wtstate" {
		local num_cut = 5
	}
	else{
		local num_cut = 3
	}		 				
	forvalues j = 2/`num_cut'{
		local ovar = "`x'_cat"
		local v = word("$`ovar'", `j'-1)
		cap drop `v'
		gen `v' = `x' == `j'
	}
}				
		  				
	global demoglist hispan black male hsless college single widowed 
	global dslist  cancre lunge stroke hearte diabe hibpe shlt
	global bhvlist overwt obese_1 obese_2 obese_3 smokev smoken
	global econlist raime rq loghatotax wlth_nonzero rdb_na_2 rdb_na_3 rdb_na_4
	global econlist2 raime rq loghatotax wlth_nonzero
  global econlist3 dcwlthx iearnx work anydc anydb 
  
	* Generate log of the tenure, divide by 10
	gen logtenure = log(db_tenure)/10

	local cond inrange(age,50,55)
	local cond hhidpn

* Wealth
	reg hatota $demoglist $dslist $bhvlist $econlist3
	est store e_hatota
	matrix minit_hatota = e(b)
	
* DB tenure
	reg logtenure $demoglist $econlist if anydb == 1 & `cond'
	est store e_logtenure
	matrix minit_logtenure = e(b)
	
	probit diclaim $demoglist $dslist $econlist2 if `cond'
	est store e_diclaim
	matrix minit_diclaim = e(b)	

	probit ssiclaim $demoglist $dslist $econlist2 if `cond'
	est store e_ssiclaim
	matrix minit_ssiclaim = e(b)	
		
	* OUTPUT ESTIMATION COEFFICIENTS AS MATRICES
	    
	#d;
	 foreach var in init_logtenure init_diclaim init_ssiclaim init_hatota {;
	 		capture erase "$resmodels//m`var'";
	 		capture erase "$resmodels//s`var'";
			mata: _putestimates("$resmodels//m`var'","$resmodels//s`var'" ,"m`var'");
	 };
	#d cr

* Draw from the wealth distribution of the 2004 new incoming cohorts
* The restricted data were not available for 2010 new incoming cohorts yet, therefore we keep 2004 cohort here
drop _all
use "$outdata/age5055_hrs2004.dta"

/* Dummies for ordered outcomes */	
foreach x of varlist $ordered {
	if "`x'" == "rdb_na_c" {
		local num_cut = 4
	}
	else if "`x'" == "wtstate" {
		local num_cut = 5
	}
	else{
		local num_cut = 3
	}		 				
	forvalues j = 2/`num_cut'{
		local ovar = "`x'_cat"
		local v = word("$`ovar'", `j'-1)
		cap drop `v'
		gen `v' = `x' == `j'
	}
}			
est restore e_hatota
predict phatota
gen resid = hatota - phatota

drop if missing(hatota)
gen wlth_id = _n
	
		keep resid wlth_id
		ren resid wlth_resid
		sort wlth_id, stable
		save "$outdata/new51_wlth2004.dta", replace
		
exit, STATA
