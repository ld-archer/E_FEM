
* Clear anything thats already in memory
clear all
cap clear mata
cap clear programs
cap clear ado
discard
est clear

* Setup some environmental settings
set more off
set mem 500m

* Define Directories
global prepath "C:\projects\FEM\FEM_DOL"
global workdir "$prepath/Code"
global indata "$prepath/Input_yh"
global indata2 "$prepath/Indata_yh"
*global netindata "/homer/c/Retire/ahg/rdata2"
global netindata "$prepath/Indata_yh"
global ster "$prepath/Estimates"
global est_out_dir "C:\Projects\FEM\FEM_JAVA\Estimates"



* Setup variables
qui do $workdir/setup_variables.do

global simutype 3

do save_eststore_txt.ado

if $simutype == 1 {
	* Import estimates from
	global estdir "$indata/partial"
}
else if $simutype ==2 | $simutype == 3 {
	* Import estimates from
	global estdir "$indata/all"
}

noi di "Loading Estimates from [$estdir]"
set trace off
* IMPORT ESTIMATES 
do put_est.mata
#d; 
	foreach var in 
	 $depvars $medvars hatotax iearnx eq5d isret_wd admin_ssi {;
		mata: _getestimates("$estdir/m`var'","$estdir/s`var'", "coef_`var'");
 	};    	 
#d cr

set trace off

	global probit anyhi diclaim ssclaim dbclaim ssiclaim nhmliv work wlth_nonzero died hearte stroke cancre hibpe diabe lunge 
	global oprobit wtstate smkstat funcstat
/*
foreach v in $probit {
	matrix x = coef_`v''
	log using "$est_out_dir/`v'.est", text replace
	di "`v'"
	di "probit"
	di "`v'"
	matrix list x
	log close
	matrix drop x
}
	
foreach v in $oprobit {
	matrix x = coef_`v''
	log using "$est_out_dir/`v'.est", text replace
	di "`v'"
	di "oprobit"
	di "`v'"
	matrix list x
	log close
	matrix drop x
}
*/
             * work wlth_nonzero iearnx hatotax 
noi di "Loading estimates from [$ster]"
	* Loads all estimates
	local all_ests :dir "$ster" files "*.ster"
	
	foreach est in `all_ests' {
		noi di "Loading estimate: `est'"
		est use "$ster/`est'"
		local est_name = substr("`est'",1,length("`est'")-5)
		est store `est_name'
		local cmd = e(cmd)
		local depvar = e(depvar)
		save_eststore_txt `est_name'  using "$est_out_dir/`est_name'.est" , model_name(`depvar') model_type(`cmd') predicted_var(`depvar')
	}



