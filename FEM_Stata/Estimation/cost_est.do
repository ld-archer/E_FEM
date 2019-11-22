
*===================================*
* Estimate costs models using MEPS (<65) and MCBS (>=65)
* Mar 2008
* Sep 2008, use weights in cost estimations
* Sep 9, 2008, impute missing values for regressors first
*===================================*

clear
set more off
set mem 400m

global workdir "/zeno/a/DOL/Estimation_2"
global indata  "/zeno/a/DOL/Input_yh"
global outdata "/zeno/a/DOL/Input_yh"
global outdata2 "/zeno/a/DOL/Indata_yh"
global netdir  "/homer/c/Retire/yuhui/rdata2"

adopath + "/zeno/a/DOL/PC"
adopath + "/zeno/a/DOL/Makedata/HRS"
adopath + "/zeno/a/DOL/Estimation_2"

capture log close
log using "$workdir//cost_est.log", replace

*** Vector of medical CPI
*CPI adjusted social security income
global colcpi "1991 1992 1993 1994 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005"

#d;
matrix medcpiu = 
( 177.02,190.06, 201.4, 211.03, 220.45,228.27, 234.59, 242.13,250.56, 260.75,
272.77, 285.63, 297.05, 310.13,323.23); 
#d cr

matrix colnames medcpiu = $colcpi
	
*** Define all covariates used in cost models
	global cov1 "male black hispan hsless college widowed single"
	global cov2 "cancre diabe hibpe hearte lunge stroke overwt obese smokev smoken"
	global cov2 "cancre diabe hibpe hearte lunge stroke"

	global cr age75l $cov1 $cov2  
	global cm age75l age75p $cov1 $cov2 nhmliv
	
	/*****************************************************************/
	/* IMPUTATION */
	/*****************************************************************/
	
	tempfile meps_imp mcbs_imp
	
	*===================================*
	* MEPS
	*===================================*
	drop _all

	use "$outdata/MEPS_cost_est.dta"
	keep if inrange(yr, 2002,2004)
	gen age75l = min(age, 75) if age < . 
	gen age75p = max(0, age-75) if age < . 	
	
	foreach item in exp slf mcr mcd prv va ofd wcp opr opu osr{
		cap drop meps`item'
		gen meps`item' = tot`item'
		label var meps`item' "tot`item' in 2004 dollars"
		 forvalues frsyr = 2002/2004 {
			replace meps`item' = meps`item' ///
			* medcpiu[1,colnumb(medcpiu,"2004")]/( medcpiu[1,colnumb(medcpiu,"`frsyr'")]) if yr == `frsyr'
		 }
	}
	
	  gen rcaid = mepsmcd
	  gen rcare = mepsmcr
	  gen rtot  = mepsexp
	  gen roop  = mepsslf
	  	
	*** Unweighted
	/* Sep 2008: keep weights */
	* replace perwt = 1
	
	keep if inrange(age,51,64) 
	* Hotdeck missing values 	
	gen anymiss = 0
	foreach x in $cov1 $cov2 age75l {
		dis "`x'"
		count if missing(`x')
		replace anymiss = 1 if missing(`x')
		* drop if missing(`x') 
	}
	
	hotdeck $cov1 $cov2 age75l using imp, by(male) keep(yr dupersid) store
	drop $cov1 $cov2 age75l 
	merge yr dupersid using imp1, sort
	tab _merge
	
	* Check missing values again
	
	gen anymiss2 = 0
	foreach x in $cov1 $cov2 age75l {
		dis "`x'"
		count if missing(`x')
		replace anymiss2 = 1 if missing(`x')
		* drop if missing(`x') 
	}
	qui sum if anymiss2 == 1
	if r(N) > 0 {
		dis "Wrong, still missing values"
		exit(333)
	}
	erase imp1.dta
	drop anymiss*
	save `meps_imp', replace
	
	*===================================*
	* MCBS
	*===================================*
	drop _all
	use "$outdata/mcbs_cost_est.dta"
	
	ren nrshom nhmliv
	keep if inrange(yr,2002,2004) & age >= 65
	
  cap drop mcaid
  ren totcaid mcaid
  
	gen age75l = min(age, 75) if age < . 
	gen age75p = max(0, age-75) if age < .   
	 
 	*** If in nursing home, no ADL limitation variables
 	foreach v in iadl1 adl12 adl3 {
 		replace `v' = 0 if nhmliv == 1 
 	}
 	
	/* Sep 2008: keep weights */
	* replace weight = 1	

	* Hotdeck missing values 	
	gen anymiss = 0
	foreach x in $cov1 $cov2 age75l age75p nhmliv {
		dis "`x'"
		count if missing(`x')
		replace anymiss = 1 if missing(`x')
		* drop if missing(`x') 
	}
	
	hotdeck $cov1 $cov2 age75l age75p nhmliv using imp, by(male) keep(yr baseid) store
	drop $cov1 $cov2 age75l age75p nhmliv
	merge yr baseid using imp1, sort
	tab _merge
	
	* Check missing values again
	
	gen anymiss2 = 0
	foreach x in $cov1 $cov2 age75l age75p nhmliv {
		dis "`x'"
		count if missing(`x')
		replace anymiss2 = 1 if missing(`x')
		* drop if missing(`x') 
	}
	qui sum if anymiss2 == 1
	if r(N) > 0 {
		dis "Wrong, still missing values"
		exit(333)
	}
	erase imp1.dta
	drop anymiss*
	save `mcbs_imp', replace	

	/*****************************************************************/
	/* ESTIMATION	 		*/
	/*****************************************************************/

	*===================================*
	* MEPS
	*===================================*
	drop _all
	use `meps_imp'			
	foreach v in doctim hsptim hspnit {
		poisson `v' $cr [pw = perwt]
		est store er`v'
		matrix mr`v' = e(b)
	}	
	
	foreach v in rtot rcaid rcare roop {
		reg `v' $cr [pw = perwt]
		est store e`v'
		matrix m`v' = e(b)
	}	

	*===================================*
	* MCBS
	*===================================*	
	drop _all
	use `mcbs_imp'

	foreach v in doctim hsptim hspnit {
		poisson `v' $cm [pw = weight]
		est store em`v'
		matrix mm`v' = e(b)
	}

	foreach v in mtot mcare mcaid moop {
		reg `v' $cm [pw = weight]
		est store e`v'
		matrix m`v' = e(b)
	}	

log close

*** put estimates into matrices by MATA subroutine
*** In current version we don't want to include obesity and smoking variables as covarites
do "$workdir/put_est.mata"

#d;
foreach var in rtot roop rcaid rcare rdoctim rhsptim rhspnit  
mtot moop mcaid mcare mhsptim mhspnit mdoctim {;
 		capture erase "$outdata/all/m`var'";
 		capture erase "$outdata/all/s`var'";
		mata: _putestimates("$outdata/all/m`var'","$outdata/all/s`var'" ,"m`var'");
};
#d cr

#d;
foreach var in rtot roop rcaid rcare rdoctim rhsptim rhspnit  
mtot moop mcaid mcare mhsptim mhspnit mdoctim {;
 		capture erase "$outdata/partial/m`var'";
 		capture erase "$outdata/partial/s`var'";
		mata: _putestimates("$outdata/partial/m`var'","$outdata/partial/s`var'" ,"m`var'");
};
#d cr

***

*** put estimates into regression tables
	#d;
	estout ertot emtot eroop emoop ercare emcare ercaid emcaid 
 	using "$workdir//cost_est.txt", 
		  cells(b(star fmt(%9.0f)) se(par fmt(%9.0f)))
              stats(r2_a N, fmt(%9.2g %9.0fc) label("Adjusted R2" "N"))
		  starlevels(* 0.10 ** 0.05 *** 0.01)
		  legend label collabel(,none)
              varlabels(_cons "Constant")
              prefoot("")
		  postfoot("")
              varwidth(10)
		  modelwidth(20) 
		  replace;
	#d cr
 ***  
  	#d;
	estout erdoctim emdoctim erhsptim emhsptim erhspnit emhspnit 
 	using "$workdir//utilization_est.txt", 
		  cells(b(star fmt(%9.4f)) se(par fmt(%9.4f)))
              stats(r2_a N, fmt(%9.2g %9.0fc) label("Adjusted R2" "N"))
		  starlevels(* 0.10 ** 0.05 *** 0.01)
		  legend label collabel(,none)
              varlabels(_cons "Constant")
              prefoot("")
		  postfoot("")
              varwidth(10)
		  modelwidth(20)
		  replace;
	#d cr
 ***          

	
