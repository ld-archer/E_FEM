/** \file
Add random variables to host dataset
\date Mar 2008

\todo Figure out what this does and if we want to do it again.

\deprecated This file no longer seems to be in use
*/
  
* Specify V-C matrices for different types of outcomes
* For health conditions
  global dep_hlth "cancre hearte lunge stroke hibpe diabe memrye died funcstat nhmliv"
* For health behaviors
  global dep_behv "smkstat wtstate"
* For others
  global dep_othr "anyhi diclaim ssiclaim ssclaim dbclaim work logiearnx wlth_nonzero loghatotax" 
  global dep_othr "anyhi diclaim ssiclaim ssclaim dbclaim work iearnx wlth_nonzero hatotax" 

* Variance of continuous outcomes
 * scalar v_logiearnx = 0.0092169^2
 * scalar v_loghatotax = 0.0125488^2

  scalar v_iearnx = 1
  scalar v_hatotax = 1
    
* Mean adjustment of the wealth  
*  scalar a_loghatotax = 0.0004252
* A list of random variables
  global x_dep_hlth ""
  global x_dep_behv ""
  global x_dep_othr ""
  
  foreach dtype in hlth behv othr{
  		global x_dep_`dtype' ""
  		local vlist = "dep_`dtype'"
  		local xlist = "x_dep_`dtype'"
  		foreach x in $`vlist' {
  			global x_dep_`dtype' $`xlist' x_`x'
  		}
  		dis "$`xlist'"
  }
  
* Generate correlation matrices
* For health conditions
  local pho = 0.0
  local n = wordcount("$dep_hlth")
	matrix define cov_hlth = J(`n',`n',`pho')+ (1-`pho')*I(`n')
* For health behaviors
  local pho = 0.0
  local n = wordcount("$dep_behv")
	matrix define cov_behv = J(`n',`n',`pho')+ (1-`pho')*I(`n')	
* For others
  local pho = 0.0
  local n = wordcount("$dep_othr")
	matrix define cov_othr = J(`n',`n',`pho')+ (1-`pho')*I(`n')	
	set trace off

* Adjust the variance of continuous outcomes
  matrix colnames cov_othr = $dep_othr
  matrix rownames cov_othr = $dep_othr

/*
foreach x in logiearnx loghatotax {
	matrix cov_othr[rownumb(cov_othr,"`x'"), colnumb(cov_othr,"`x'")] = v_`x'
}
*/

* Random variables for the host dataset (aged 51 and over): generate 10 datasets and 10 fake ones
local repn = $repnum
forvalues rep = 1/`repn'{
	drop _all
  use "$dua_rand_hrs/host92_initial.dta"
  local begyr = 1992
  local endyr = 2004
  local step  = 2
  forvalues y = `begyr'(`step')`endyr' {
	  foreach dtype in hlth behv othr{
	  		local xlist = "x_dep_`dtype'"
				drawnorm $`xlist', cov(cov_`dtype')
				foreach xvar in $`xlist'{
					ren `xvar' `xvar'`y'
				}
	  }
  }
  save "$dua_rand_hrs/simul1992_r`rep'.dta",replace

}  







  
  
	
