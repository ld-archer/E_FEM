/** \file
Cross-sectional regressions of deprsymp

- Mar 22, 2008
- Apr 8, 2008, add estimation for SSI

\todo When possible, use global variable lists from fem_env.do instead of these custom ones.
*/
include common.do

use "$outdata/age5055_hrs2010.dta", clear

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
  
	local cond inrange(age,50,55)
	local cond hhidpn

* deprsymp
	probit deprsymp $demoglist $dslist $bhvlist $econlist3
	est store e_deprsymp
	matrix minit_deprsymp = e(b)
	
		
	* OUTPUT ESTIMATION COEFFICIENTS AS MATRICES
	    
	#d;
	 foreach var in init_deprsymp {;
	 		capture erase "$outdata//m`var'";
	 		capture erase "$outdata//s`var'";
			mata: _putestimates("$outdata//m`var'","$outdata//s`var'" ,"m`var'");
	 };
	#d cr

* estimation for hearta

	probit hearta $demoglist cancre lunge stroke diabe hibpe $bhvlist $econlist3 if hearte == 1
	est store e_hearta
	matrix minit_hearta = e(b)
	
		
	* OUTPUT ESTIMATION COEFFICIENTS AS MATRICES
	    
	#d;
	 foreach var in init_hearta {;
	 		capture erase "$outdata//m`var'";
	 		capture erase "$outdata//s`var'";
			mata: _putestimates("$outdata//m`var'","$outdata//s`var'" ,"m`var'");
	 };
	#d cr


* estimation for heartae
	probit heartae $demoglist cancre lunge stroke diabe hibpe $bhvlist $econlist3 if hearte == 1
	est store e_heartae
	matrix minit_heartae = e(b)
	
		
	* OUTPUT ESTIMATION COEFFICIENTS AS MATRICES
	    
	#d;
	 foreach var in init_heartae {;
	 		capture erase "$outdata//m`var'";
	 		capture erase "$outdata//s`var'";
			mata: _putestimates("$outdata//m`var'","$outdata//s`var'" ,"m`var'");
	 };
	#d cr


* estimation for painstat
	oprobit painstat $demoglist $dslist $bhvlist $econlist3
	est save "$outdata/new51_painstat.ster", replace

* estimation for adlstat conditional on anyadl
	oprobit adlstat $demoglist $dslist $bhvlist iearnx work if adlstat>1
	est save "$outdata/new51_adlstat.ster", replace
	
* estimation for iadlstat conditional on anyiadl
	ren iadlstat iadlstat_old
	recode iadlstat_old (1=.) (2=0) (3=1) (missing=.), generate(iadlstat)
	probit iadlstat $demoglist $dslist $bhvlist iearnx work if iadlstat < .
	est save "$outdata/new51_iadlstat.ster", replace
	
drop _all
		
exit, STATA
