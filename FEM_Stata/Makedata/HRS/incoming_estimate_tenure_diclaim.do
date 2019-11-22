/** \file
Cross-sectional regressions of tenure for job with a DB and claiming DI

- Mar 22, 2008
- Apr 8, 2008, add estimation for SSI

\todo Use global varlists from fem_env.do when possible
*/
clear
clear mata
set more off
set mem 400m


* use "$dua_rand_hrs/all2004r.dta"
use "$dua_rand_hrs/age5055_hrs1992r.dta"

* Generate dummies for categorical 
global ordered wtstate smkstat funcstat rdb_ea_c rdb_na_c
* For categorical outcomes
global wtstate_cat overwt obese
global smkstat_cat smokev smoken 
global funcstat_cat iadl1 adl1p
global rdb_ea_c_cat rdb_ea_2 rdb_ea_3
global rdb_na_c_cat rdb_na_2 rdb_na_3 rdb_na_4
		  			
/* Dummies for ordered outcomes */	
foreach x of varlist $ordered {
	if "`x'" == "rdb_na_c" {
		local num_cut = 4
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
	global bhvlist overwt obese smokev smoken
	global econlist logaime logq loghatotax wlth_nonzero rdb_na_2 rdb_na_3 rdb_na_4
	global econlist2 logaime logq loghatotax wlth_nonzero
		
	* Generate log of the tenure, divide by 10
	gen logtenure = log(db_tenure)/10

	local cond inrange(age,50,55)
	local cond hhidpn

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
	do "$workdir/put_est.mata"
	    
	#d;
	 foreach var in init_logtenure init_diclaim init_ssiclaim{;
	 		capture erase "$outdata//m`var'";
	 		capture erase "$outdata//s`var'";
			mata: _putestimates("$outdata//m`var'","$outdata//s`var'" ,"m`var'");
	 };
	#d cr
	


	
	
	 
	
	

