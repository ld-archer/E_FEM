
clear
cap clear mata
set mem 500m
set more off
set seed 52432
*set maxvar 10000
est drop _all

*==========================================================================*
* Estimate transition
* Apr 8, 2008: add age dummies (lage62e,lage65e) to labor participation and SS claiming
* Cohort effects for weight and hh wealth
* Apr 13, 2008: For wealth, use emprical distribution,dont use log transformation
* Jun 23, 2008: For wealth, use generalized inverse hyperbolic sine  transformation - dummy variables for waves and zero/non-zero
* GET THE THETA/OMEGA/SSR SAVED.
* Sep 6, 2008: This re-estimate mortality by including those alive but not interviewed
* 							remove BMI and smoking (initial and lag) from estimation 
* Sep 21, 2008, change age dummies for ss claiming equation
* Sep 22, 2008, change age dummies for working equation, re-run all estimations
* Keep obesity and overweight variables only in disease and functional status, smoking and weight equations
* Sep 27, correct for mis-specified covariates
* 9/21/2009 - Eliminated explicit PC Stata path references. Use fem_path global instead
* 9/21/2009 - Use exact ages for estimation, age_iwe, the age at the end of the interview
* 9/21/2009 - Changed the iearnx_simu and hatotax_simu filenames to ***_simulated because they are writeprotected by AHG
* 9/21/2009 - Added logdeltaage = log(age_iwe - lage_iwe) as a covariate to account for differences in time between interviews
* 12/15/2009 - Changed rbyr to frbyr as the regressor because frbyr stays at the HRS value while rbyr increases for future incoming cohorts
*  1/13/2010 - Added memrye as a health outcome
*2/26 - expand BMI
* =========================================================================*

/*********************************************************************/
*	SEP UP DIRECTORIES
/*********************************************************************/
global fem_path "/zeno/a/FEM/FEM_1.0"

global workdir "$fem_path/Estimation_2"
global indata  "$fem_path/Input_yh"
global ster    "$fem_path/Estimates/bmi_exp"
global outdata "$fem_path/Input_yh/bmi_exp"
global netdir  "/homer/c/Retire/FEM/rdata"
global outdir "$fem_path/Input_yh/bmi_exp/all"
	
cd "$fem_path/Makedata/HRS"
capt takestring
cd "$fem_path/Estimation_2"
capt estout

global ghregdir "$fem_path/Code"
* adopath ++ "\\zeno\zeno_a\zyuhui\DOL\PC"
adopath ++ "$fem_path/Makedata/HRS"
adopath ++ "$fem_path/Estimation_2"
adopath ++ "$fem_path/Code"

/*********************************************************************/
* USE DATA AND RECODE
/*********************************************************************/

cap log close
log using "$workdir/init_transition_exp_bmi.log", replace
dis "Current time is: " c(current_time) " on " c(current_date)

use "$netdir/hrs17r_transition_bmi_exp.dta", clear
* FOR hacohort = 0 & 1 in wave 2 & 3 no info on SSI claiming
	replace ssiclaim = -2 if inlist(hacohort, 0, 1) & inlist(wave,3,4)

	cd  "$fem_path/Code"

*** CHANGE hatota, earnings VARIABLES
	drop floghatota floghatotax lloghatota lloghatotax llogiearn llogiearnx flogiearn flogiearnx
	set more off
	foreach i in hatota hatotax iearn iearnx{
		egen flog`i' = h(f`i')
		replace flog`i' = flog`i'/100
		egen llog`i' = h(l`i')
		replace llog`i' = llog`i'/100
	}


*** DEPENDENT VARIABLES
	global bin_econ anyhi diclaim ssclaim dbclaim ssiclaim nhmliv work wlth_nonzero
	global bin_hlth died hearte stroke cancre hibpe diabe lunge memrye
	global order wtstate smkstat funcstat

*** GENERATE THE AGE SPLINE VARIABLES
	foreach x in lage6061 lage6263 lage64e lage6566 lage6770 lage65l lage6574 lage75l lage75p lage62e lage63e {
		cap drop `x'
	}
		
	local age_var age_iwe
	
	gen lage6061 = floor(l`age_var') == 58 | floor(l`age_var') == 59 if l`age_var' < .
	gen lage6263 = inrange(floor(l`age_var'),60,61) if l`age_var' < .
	gen lage64e = floor(l`age_var') == 62 if l`age_var' < . 
	gen lage6566 = floor(l`age_var') == 63 | floor(l`age_var') == 64 if l`age_var' < .
	gen lage6770 = inrange(floor(l`age_var'),65,68) if l`age_var' < . 
	
	gen lage65l  = min(63,l`age_var') if l`age_var' < .
	gen lage6574 = min(max(0,l`age_var'-63),73-63) if l`age_var' < .
	gen lage75l = min(l`age_var', 73) if l`age_var' < . 
	gen lage75p = max(0, l`age_var'-73) if l`age_var' < . 
	
	gen lage62e = floor(l`age_var') == 60 if l`age_var' < .
	gen lage63e = floor(l`age_var') == 61 if l`age_var' < .

	mkspline la6 58 la7 73 la7p = l`age_var'

	gen logdeltaage = log(`age_var' - l`age_var')

*** GENERATE WEAVE DUMMIES
	gen w3 = wave == 3
	gen w4 = wave == 4
	gen w5 = wave == 5
	gen w6 = wave == 6
	gen w7 = wave == 7

*** INDEPENDENT VARIABLES

*** Demographics
	global dvars black hispan hsless college male 
*** Initial values
#d;
	global fvars fhearte fstroke fcancre fhibpe fdiabe flunge fsmokev fsmoken fiadl1 fadl12 fadl3 
	fwidowed fsingle fwork flogiearnx fwlth_nonzero floghatotax 
	flogaime flogq fshlt fanydb frdb_na_2 frdb_na_3 frdb_na_4 fanydc flogdcwlthx ;
#d cr
*** values of health variables at t-1
	global lvars_hlth lhearte lstroke lcancre lhibpe ldiabe llunge liadl1 ladl12 ladl3 lsmoken lwidowed 
*** values of econ variables at time t-1
	global lvars_econ lwork llogiearnx lwlth_nonzero lloghatotax ldiclaim lssiclaim lssclaim ldbclaim lnhmliv

*** FOR MORTALITY
	global allvars_died $dvars lage65l lage6574 lage75p $lvars_hlth $fvars fmemrye lmemrye
	
*** FOR CHRONIC CONDITIONS AND ORDINAL OUTCOMES
	global allvars_hlth $dvars lage65l lage6574 lage75p $lvars_hlth lobese_1 lobese_2 lobese_3 loverwt $fvars fobese_1 fobese_2 fobese_3 foverwt logdeltaage

	takestring, oldlist($allvars_hlth) newname("allvars_hearte") extlist("lhearte fhearte lstroke llunge lcancre liadl1 ladl12 ladl3")
	takestring, oldlist($allvars_hlth) newname("allvars_stroke") extlist("lstroke fstroke lstroke llunge liadl1 ladl12 ladl3")
	takestring, oldlist($allvars_hlth) newname("allvars_cancre") extlist("lhearte lstroke lcancre lhibpe ldiabe llunge fcancre liadl1 ladl12 ladl3")
	takestring, oldlist($allvars_hlth) newname("allvars_hibpe")  extlist("lhearte lstroke lcancre lhibpe llunge fhibpe liadl1 ladl12 ladl3")
	takestring, oldlist($allvars_hlth) newname("allvars_diabe")  extlist("lhearte lstroke lcancre lhibpe ldiabe llunge fdiabe liadl1 ladl12 ladl3")
	takestring, oldlist($allvars_hlth) newname("allvars_lunge")  extlist("lhearte lstroke lcancre lhibpe ldiabe llunge flunge liadl1 ladl12 ladl3")
	takestring, oldlist($allvars_hlth) newname("allvars_memrye") extlist("lhearte lstroke lcancre lhibpe ldiabe llunge flunge")

	global allvars_smkstat $allvars_hlth
	global allvars_funcstat $allvars_hlth
	global allvars_wtstate $allvars_hlth frbyr
	
*** FOR ECONOMIC OUTCOMES
  global allvars_econ1 $dvars lage65l lage6574 lage75p $lvars_hlth $lvars_econ $fvars logdeltaage
  global allvars_econ2 $dvars lage6061 lage62e lage63e lage64e lage6566 lage6770 $lvars_hlth $lvars_econ $fvars logdeltaage
  global allvars_econ3 $dvars la6 la7 la7p $lvars_hlth $lvars_econ $fvars w3 w4 w5 w6 w7 frbyr logdeltaage
  global allvars_econ4 $dvars lage65l lage6574 lage75p $lvars_hlth lmemrye $lvars_econ $fvars fmemrye logdeltaage
  
	takestring, oldlist($allvars_econ1) newname("allvars_anyhi")  extlist("lage75p ldbclaim lssiclaim lnhmliv lsmoken")
	takestring, oldlist($allvars_econ1) newname("allvars_diclaim")  extlist("lage75p lssiclaim lssclaim ldbclaim lnhmliv lsmoken")
	takestring, oldlist($allvars_econ1) newname("allvars_dbclaim")  extlist("lage75p fwork fanydb lssiclaim ldbclaim lwork lnhmliv lsmoken")
	takestring, oldlist($allvars_econ1) newname("allvars_ssiclaim")  extlist("lnhmliv lsmoken")
	takestring, oldlist($allvars_econ4) newname("allvars_nhmliv")  extlist("ldiclaim lssiclaim lssclaim ldbclaim lwork llogiearnx lsmoken frdb_na_4")
	takestring, oldlist($allvars_econ1) newname("allvars_iearnx")  extlist("lssiclaim lnhmliv lsmoken lage75p")

	takestring, oldlist($allvars_econ2) newname("allvars_ssclaim")  extlist("lssiclaim lssclaim lnhmliv lsmoken")
	takestring, oldlist($allvars_econ2) newname("allvars_work")  extlist("lssiclaim lnhmliv lsmoken")

	takestring, oldlist($allvars_econ3) newname("allvars_wlth_nonzero")  extlist("lssiclaim lsmoken")
	takestring, oldlist($allvars_econ3) newname("allvars_hatotax")  extlist("lssiclaim lsmoken")


set more off

/*********************************************************************/
* ESTIMATE BINARY OUTCOMES
/*********************************************************************/
	foreach n in $bin_hlth $bin_econ {
		local x = "allvars_`n'"
		probit `n' $`x' if `n'!=-2&`n'!=9
		gen e_`n' = e(sample)
		estimates store b_`n'
		est save "$ster/`n'.ster", replace
		matrix m`n' = e(b) 
	}


/*********************************************************************/
* ESTIMATE ORDERED OUTCOMES
/*********************************************************************/
foreach n in $order {
	local x = "allvars_`n'"
	oprobit `n' $`x' if `n'!=-2&`n'!=9
	gen e_`n' = e(sample)
	estimates store o_`n'
	est save "$ster/`n'.ster", replace
	matrix m`n' = e(b)
}



/*********************************************************************/
*ESTIMATE EARNINGS
/*********************************************************************/

*global allvars_earn lh ls lc lhi ld ll la ldi lss lssc ldb lo lob lsm li lad ladl lw llo fh fs fc fhi fd fl fa fo fob fsm fsmo fi fad fadl fw fwl flo lag lwi bl hi hs co ma fwi fsi flog flogq fsh fan f_2 f_3 f_4 fany flogd lha  
/* 
Sep 22, remove lo lob fo fob 
global allvars_earn lh ls lc lhi ld ll la ldi lss lssc ldb lsm li lad ladl lw llo fh fs fc fhi fd fl fa fsm fsmo fi fad fadl fw fwl flo lag lwi bl hi hs co ma fwi fsi flog flogq fsh fan f_2 f_3 f_4 fany flogd lha  
*/

/* Sep 22, add lwlth_nonzero */
*rename lwlth_nonzero lwo
*global allvars_earn $allvars_earn lwo

/* Sep 23, make lloghatotax, use rename .do*/
*global allvars_iearnx lhearte lstroke lcancre lhibpe ldiabe llunge lanyhi ldiclaim lssiclaim lssclaim ldbclaim   lsmoken liadl1 ladl12 ladl3 lwork llogiearnx fhearte fstroke fcancre fhibpe fdiabe flunge fanyhi   fsmokev fsmoken fiadl1 fadl12 fadl3 fwork fwlth_nonzero floghatotax lage75l lwidowed   black hispan hsless college male fwidowed fsingle flogaime flogq fshlt fanydb frdb_na_2 frdb_na_3 frdb_na_4 fanydc flogdcwlthx lloghatotax  lwlth_nonzero 

preserve
*** Rename the vectors for iearnx and hatotax,as well as rename variables
	do "$workdir/init_transition_rename_iearnx_bmi_exp.do"
	
clear mata
cd "$ghregdir"
egen x = h(2*3)
egen y = h(6)
assert x == y
drop x y

foreach n in iearnx{
	ghreg `n' $allvars_iearnx_r if work == 1

	gen e_`n' = e(sample)
	summ `n' if e(sample) == 1
	global max = r(max)
	global theta = e(theta)
	global omega = e(omega)
	global ssr = e(ssr)
	disp "theta omega ssr max"
	disp $theta " " $omega " " $ssr " " $max
	estimates store i_`n'
	matrix m`n' = e(b)
	matrix v`n' = e(v)
	predict simu_`n', simu
	keep simu_`n' `n' wave e_`n' work
	save "$indata/bmi_exp/`n'_simulated.dta", replace	
	restore
}
gen e_iearnx = e(sample)
matrix colnames miearnx = $allvars_iearnx _cons
matrix colnames viearnx = theta omega ssr $allvars_iearnx _cons







**********************************************
* RE-estimate wealth equation
**********************************************



cd "$workdir"
preserve
do init_transition_rename_hatotax_bmi_exp

clear mata
cd "$ghregdir"


**Estimate on 92-2004**
cd "$ghregdir"
rename hatotax tax
ghreg tax $allvars_hatotax_r if died == 0 & !missing(tax) & tax !=0
rename tax hatotax

summ hatotax  if e(sample) == 1
global max = r(max)
global theta = e(theta)
global omega = e(omega)
global ssr = e(ssr)
disp "theta omega ssr max"
disp $theta " " $omega " " $ssr " " $max
gen e_hatotax = e(sample)
est store w_hatotax
*Change Column Name for mhatota*
matrix mhatotax = e(b)
matrix vhatotax = e(v)
predict simu_hatotax, simu
keep simu_hatotax hatotax wave e_hatotax died
save "$indata/bmi_exp/hatotax_simulated.dta", replace	
matrix colnames mhatotax = $allvars_hatotax _cons
matrix colnames vhatotax = theta omega ssr $allvars_hatotax _cons
restore
gen e_hatotax = e(sample)
cd "$workdir"

**********************************************
* Examine estimation sample
**********************************************
foreach x in $bin $order $censored memrye died_memrye hatotax iearnx{
	* dis "Estimation outcome is: `x'"
	* tab wave e_`x', m
}

cap log close


cd "$fem_path/Input_yh/all"
	#d ;
 	estout b_*
 	 	using "hazards.txt", 
		  cells(b(fmt(%9.4f)) t(fmt(%9.2f)))
              stats(N, fmt( %9.0fc) label("N"))
		  legend label collabel(,none)
              varlabels(_cons "Constant")
              prefoot("")
		  postfoot("")
              varwidth(10)
		  modelwidth(20) 
		  replace notype;
	#d cr

foreach d in $order {
	#d ;
 	estout o_`d'
 	 	using "trans_`d'_yh.txt", 
		  cells(b(fmt(%9.4f)) t(fmt(%9.2f)))
              stats(N, fmt( %9.0fc) label("N"))
		  legend label collabel(,none)
              varlabels(_cons "Constant")
              prefoot("")
		  postfoot("")
              varwidth(10)
		  modelwidth(20) 
		  replace notype;
	#d cr
}
	
	quietly{
		log using "$outdir/hatota_92_04_out.txt", replace
		local _counter = 1
		foreach i in 	$allvars_hatotax{
			local _counter_3 = `_counter'+3
			noi disp "`i'" " " mhatotax[1,`_counter'] " "
			noi disp " " mhatotax[1,`_counter']/sqrt(vhatotax[`_counter_3',`_counter_3'])
			local _counter = `_counter' + 1
		}
		count if e_hatotax == 1
		noi disp "N" " " r(N)
		capt log close
	}

	quietly{
		log using "$outdir/iearnx_out.txt", replace
		local _counter = 1
		foreach i in 	$allvars_iearnx {
			local _counter_3 = `_counter'+3
			noi disp "`i'" " " miearnx[1,`_counter'] " "
			noi disp " " miearnx[1,`_counter']/sqrt(viearnx[`_counter_3',`_counter_3'])
			local _counter = `_counter' + 1
		}
		count if e_iearnx == 1
		noi disp "N" " " r(N)
		capt log close
	}

* OUTPUT ESTIMATION COEFFICIENTS AS MATRICES
do "$workdir/put_est.mata"

foreach var in $bin_hlth $bin_econ $order hatotax iearnx {
* foreach var in $bin_hlth $bin_econ $order {
* foreach var in  hatotax iearnx {
 		capture erase "$outdir//m`var'"
 		capture erase "$outdir//s`var'"
		mata: _putestimates("$outdir//m`var'","$outdir//s`var'" ,"m`var'")
 }
*************************************************

clear mata
log close

#d cr



