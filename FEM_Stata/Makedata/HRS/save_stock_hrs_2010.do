
/** \file

Construct the simul2004 file, the restricted 2004 cohort file

\date Mar 2008

*/
include common.do

local expand : env EXPAND

  use $dua_rand_hrs/all2010r_pop_adjusted.dta
  
* Specify V-C matrices for different types of outcomes
* For health conditions
  global dep_hlth "cancre deprsymp hearte lunge stroke hibpe diabe memrye died funcstat nhmliv adlstat iadlstat"
* For health behaviors
  global dep_behv "smkstat wtstate"
* For others
  global dep_othr "anyhi diclaim ssiclaim ssclaim dbclaim work logiearnx wlth_nonzero loghatotax" 
  global dep_othr "anyhi diclaim ssiclaim ssclaim dbclaim work iearnx wlth_nonzero hatotax inpatient_ever" 

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

multiply_persons `expand'

gen flogq = ln(frq)

gen entry = 2010

if(floor(c(version))>=14) {
	saveold "$dua_rand_hrs/stock_hrs_2010.dta",replace v(12)
}
else{
	saveold "$dua_rand_hrs/stock_hrs_2010.dta",replace
}

* Saving very simple models of the restricted variables for imputation
local covars hsless college i.agec work male##(widowed single c.flogiearnx)
gen fraime_nonzero = fraime > 1
probit fraime_nonzero `covars'
est save $resmodels/fraime_nonzero2010.ster, replace
regress fraime `covars' if fraime_nonzero
est save $resmodels/fraime2010.ster, replace
reg flogq `covars' [aw=weight]
est save $resmodels/flogq2010.ster, replace
reg rpia `covars' [aw=weight]
est save $resmodels/rpia2010.ster, replace

