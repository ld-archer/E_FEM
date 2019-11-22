/*  
Cross-validation results using RAND HRS Version N (through 2012)
*/

ssc install ttab

clear all
include ../../fem_env.do

* Path to files
local randhrsn /nfs/sch-data-library/public-data/HRS/Unrestricted/RAND-HRS/rndhrs_n.dta
local randhrsk /nfs/sch-data-library/public-data/HRS/Unrestricted/RAND-HRS/rndhrs_k.dta
local incwlth_n /nfs/sch-data-library/public-data/HRS/Unrestricted/Stata/incwlth_n.dta
local input "$outdata"
local output "$routput_dir/vCrossvalidation"
local restricted "$dua_rand_hrs"


* For processing simulation output
local iter 50

* For processing RAND HRS
local minwave 4
local maxwave 11

* Need a list of individuals who gave permission to use SSA records 
use `restricted'/simul1998.dta, clear
keep hhidpn
tempfile sslist
save `sslist'

*********************************
* Process RAND HRS
*********************************
use `randhrsn', clear

* Merge on income/wealth vars
merge 1:1 hhidpn using `incwlth_n', keepusing(r*isemp r*ioss r*iosdi h*iossi r*iss r*isdi r*issi)
drop _merge

forvalues x = 3/11 {
	rename r`x'isemp r`x'semp
}

* Keep only those used in the simulation (transition = 0)
merge 1:1 hhidpn using "$outdata/crossvalidation.dta" , keepusing(transition)
drop if _merge == 2
keep if transition == 0
drop _merge

* Keep only those who on the simul1998 file
count
merge 1:1 hhidpn using `sslist', keep(matched)
count

#d ;
keep
	hhidpn
	rahispan
	raracem
	ragender
	hacohort
	rabyear
	
	r*adla
	r*higov r*covr r*covs r*hiothp	
	r*cancre
	r*iwstat
	r*diabe
	r*dstat
	r*agey_e
	r*hearte
	r*hibpe
	r*iadla
	r*lunge
	r*nhmliv
	r*smoken
	r*smokev
	r*stroke
	r*work
	r*lbrf
	r*bmi
	r*iearn
	r*semp
	r*wtresp
	h*icap
	h*atota
	r*ioss
	r*iosdi
	h*iossi
	
	r*iss r*isdi r*issi r*peninc r*jcpen
	
	;
#d cr

* Reshape the data to long
#d ;
local shapelist
	r@adla
	r@higov r@covr r@covs r@hiothp	
	r@cancre
	r@iwstat
	r@diabe
	r@dstat
	r@agey_e
	r@hearte
	r@hibpe
	r@iadla
	r@lunge
	r@nhmliv
	r@smoken
	r@smokev
	r@stroke
	r@work
	r@lbrf
	r@bmi
	r@iearn
	r@semp
	r@wtresp
	h@icap
	h@atota
	r@ioss
	r@iosdi
	h@iossi
	
	r@iss r@isdi r@issi r@peninc r@jcpen
;
#d cr

reshape long `shapelist', i(hhidpn) j(wave)

keep if wave >= `minwave'
keep if rabyear <= 1947

* Recode variables
* Fixed variables
gen hispan = rahispan
label var hispan "Hispanic"

gen black = 0*raracem
replace black = 1 if raracem == 2 & hispan == 0
label var black "Non-hispanic black"

gen male = 0*ragender
replace male = 1 if ragender == 1
label var male "Male"

* Any ADL
recode radla (0=1) (1=2) (2=3) (nonmissing=4) (missing=.), gen(adlstat)
gen anyadl = inlist(adlstat,2,3,4) & !missing(adlstat)
label var anyadl "Any ADL limitations"

* Any IADL
recode riadla (0=1) (1=2) (nonmissing=3) (missing=.), gen(iadlstat)
gen anyiadl = inlist(iadlstat,2,3) & !missing(iadlstat)
label var anyiadl "Any IADL limitations"

  ** ADL (three categories)//

	gen adl1 = adlstat==2 if !missing(adlstat)
	gen adl2 = adlstat==3 if !missing(adlstat)
	gen adl3p = adlstat==4 if !missing(adlstat)
	label var adl1 "One ADL limitation"
	label var adl2 "Two ADL limitations"
	label var adl3p "Three or more ADL limitations"
	
  **IADL (three categories) //

	gen iadl1 = iadlstat==2 if !missing(iadlstat)
	gen iadl2p = iadlstat==3 if !missing(iadlstat)
	label var iadl1 "One IADL limitation"
	label var iadl2p "Two or more IADL limitations"


* Health Conditions
foreach var in cancre diabe hearte hibpe lunge stroke {
	ren r`var' `var'
}
label var cancre "R ever had cancer"
label var diabe "R ever had diabetes"
label var hearte "R ever had heart disease"
label var hibpe "R ever had hypertension"
label var lunge "R ever had lung disease"
label var stroke "R ever had stroke"

* Mortality
gen died = riwstat
recode died (0 6 9 = .) (1 4 = 0) (2 3 5 = 1) 
label var died "whether died or not in this wave"

* Risk factors
foreach var in bmi smokev smoken {
	ren r`var' `var'
} 
label var bmi "R Body mass index"
label var smoken "R smokes now"
label var smokev "R smoke ever"

* Sampling weight
ren rwtresp weight
label var weight "R person level weight"

* Nursing home
ren rnhmliv nhmliv
label var nhmliv "R live in nursing home at interview"


ren rdstat dstat
ren riwstat iwstat

* Supplemental Security Income
* gen ssiclaim = inlist(dstat,2,12,22,200) if dstat <= 200 & iwstat == 1
* replace ssiclaim = 0 if inlist(hacohort,0,1) & inlist(wave,2,3) & iwstat == 1 
* label var ssiclaim "Claiming SSI"

gen ssiclaim = (hiossi == 1) if !missing(hiossi)
label var ssiclaim "Claiming SSI"
label var rissi "SSI income"

* Social Security Income
gen ssclaim = (rioss == 1) if !missing(rioss)
label var ssclaim "Receiving SS retirement or survivors"

* Make SS Claim absorbing
sort hhidpn wave
xtset hhidpn wave
bys wave: tab ssclaim
sort hhidpn wave
replace ssclaim = 1 if l.ssclaim == 1
bys wave: tab ssclaim

label var riss "SS Income"

* Health insurance
gen anyhi =0
foreach v in rhigov rcovr rcovs rhiothp {
	replace anyhi = 1 if inlist(`v',1,.e,.c,.t)
}
foreach v in rhigov rcovr rcovs rhiothp {
	replace anyhi = . if !inlist(`v',0,1,.e,.c,.t) & anyhi == 0
}
label var anyhi "Any health insurance coverage (gov/emp/other)"


* Age years
ren ragey_e agey_e
gen age_yrs = agey_e

* Disability
* gen diclaim	= inlist(dstat,20,21,22,200) if dstat <=200 & iwstat == 1
* replace diclaim = 0 if inlist(hacohort,0,1,2) & iwstat == 1 | agey_e > 66
* replace diclaim = 0 if agey_e >= 65 & iwstat == 1
* label var diclaim "Claiming SSDI"

gen diclaim = (riosdi == 1) if !missing(riosdi)
label var diclaim "Receiving SSDI"

label var risdi "DI Income"

* Work staus
gen work = rwork
replace work = 0 if !inlist(rwork,0,1) & inlist(rlbrf,5,6,7)
label var work "R working for pay"

* Earnings
ren riearn iearn
replace iearn = rsemp if work == 1 & iearn == 0 & rsemp > 0 & rsemp < .
replace iearn = 0 if work == 0
gen iearnx = iearn/1000
replace iearnx = min(iearnx,200) if !missing(iearn)
label var iearnx "Individual earnings in 1000s-max 200"

* DB pension claim

gen dbclaim = (rpeninc == 1) if !missing(rpeninc) 
label var dbclaim "Receiving DB pension"

* Any DB entitlement for current job 

gen anydb = .
replace anydb = (rjcpen == 1) if !missing(rjcpen)

    * Consistency of DB pension and job status
	
      replace anydb = 0 if (work!= 1 | iearn == 0) & iwstat == 1
      replace dbclaim = 0 if anydb == 0 & dbclaim != .

* Wealth
gen hatotax = hatota/1000 
replace hatotax = min(hatotax, 2000) if !missing(hatota)
label var hatotax "HH wlth in 1000s if positive-max 2000 zero otherwise"

* Capital income
replace hicap = hicap/1000
label var hicap "Capital income in 1000s"

* Put financial variables into $2004
gen iwyear = 1990 + 2*wave

// CPI adjusted social security income
global colcpi "1991 1992 1993 1994 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012"

#d;
matrix matcpiu = 
(136.17,140.31,144.48,148.23,152.38,156.86,160.53,
163.01,166.58,172.19,177.07,179.84,183.96,188.89,195.27,
201.6, 207.3, 215.303, 214.537, 218.056, 224.939, 229.60);
#d cr
	
matrix colnames matcpiu = $colcpi
matrix list matcpiu
	
#d ;
forvalues i = 1991/2012{; 
	foreach var in iearnx	hatotax hicap riss risdi rissi{; 
		replace `var' = matcpiu[1,colnumb(matcpiu,"2004")] ///
		*`var'/matcpiu[1,colnumb(matcpiu,"`i'")] if iwyear == `i'; 
	};
};
#d cr

gen FEM = 0
gen year = iwyear

* Only keep individuals in the appropriate cohorts - no EBB or later (not required for 2010 FEM)
* keep if inlist(hacohort,0,1,2,3,4)

tempfile hrs
save `hrs'
save hrs_1992_2012.dta, replace
clear all

********************************
* Process simulation output
* iter = 50 numbers of reps
********************************
forvalues i = 1/`iter' {
	forvalues yr = 1998 (2) 2012 {
		append using "`output'/detailed_output/y`yr'_rep`i'.dta"
	}
}
gen reweight = weight/`iter' 
gen FEM = 1
gen rep = mcrep + 1

replace hicap = hicap/1000


append using `hrs'

bys FEM: sum diabe [aw=weight] if year == 1998
bys FEM: sum diabe [aw=weight] if year == 2012

**ttest diabe if year == 2012 [aw=weight], by(FEM) unequal
 
**ttab diabe [aw=weight] if year == 2012, by(FEM)


local binhlth cancre diabe hearte hibpe lunge stroke anyadl anyiadl adl1 adl2 adl3p iadl1 iadl2p
local risk smoken smokev bmi 
local binecon work diclaim ssiclaim ssclaim dbclaim
local cntecon iearnx hatotax hicap
local demog age_yrs male black hispan
local unweighted nhmliv died

foreach tp in binhlth risk binecon cntecon demog {
	forvalues wave = `minwave'/`maxwave' {
		file open myfile using "`output'/fem_hrs_ttest_`tp'_`wave'.txt", write replace
		file write myfile "variable" _tab "fem_mean" _tab "fem_n" _tab "fem_sd" _tab "hrs_mean" _tab "hrs_n" _tab "hrs_sd" _tab "p_value" _n

		local yr = 1990 + 2*`wave' 

		foreach var in ``tp'' {
		
			local select
			if "`var'" == "ssclaim" {
				local select & age_yrs >= 62 & age_yrs <= 70
			} 
			if "`var'" == "work" {
				local select & age_yrs <= 80
			} 
			if "`var'" == "diclaim" {
				local select & age_yrs <= 65
			} 
			if "`var'" == "iearnx" {
				local select & age_yrs <= 80
			}
		
			di "var is `var' and select is `select'"
		
			qui sum `var' if FEM==1 & died == 0 & nhmliv == 0 & year == `yr' `select' [aw=reweight] 
			local N1 = r(N)
			local av1 = r(mean)
			local sd1 = r(sd)
			qui sum `var' if FEM==0 & died == 0 & nhmliv == 0 & year == `yr' `select' [aw=weight] 
			local N2 = r(N)
			local av2 = r(mean)
			local sd2 = r(sd)
			ttesti `N1' `av1' `sd1' `N2' `av2' `sd2', unequal
	 		file write myfile %15s "`var'" _tab %15.5f (`av1') _tab %15f (`N1') _tab %15.5f (`sd1') _tab %15.5f (`av2') _tab %15f (`N2')	_tab %15.5f (`sd2') _tab %15.5f (r(p)) _n
		}
		file close myfile
	}
}

foreach tp in unweighted {
	forvalues wave = `minwave'/`maxwave' {
		file open myfile using "`output'/fem_hrs_ttest_`tp'_`wave'.txt", write replace
		file write myfile "variable" _tab "fem_mean" _tab "fem_n" _tab "fem_sd" _tab "hrs_mean" _tab "hrs_n" _tab "hrs_sd" _tab "p_value" _n

		local yr = 1990 + 2*`wave' 

		foreach var in ``tp'' {
			qui sum `var' if FEM==1 & year == `yr'  
			local N1 = r(N)
			local av1 = r(mean)
			local sd1 = r(sd)
			qui sum `var' if FEM==0 & year == `yr'
			local N2 = r(N)
			local av2 = r(mean)
			local sd2 = r(sd)
			ttesti `N1' `av1' `sd1' `N2' `av2' `sd2', unequal
	 		file write myfile %15s "`var'" _tab %15.5f (`av1') _tab %15f (`N1') _tab %15.5f (`sd1') _tab %15.5f (`av2') _tab %15f (`N2')	_tab %15.5f (`sd2') _tab %15.5f (r(p)) _n
		}
		file close myfile
	}
}


	local varlist "fem_mean fem_n fem_sd hrs_mean hrs_n hrs_sd p_value"


* Produce tables
foreach tabl in binhlth risk binecon cntecon demog unweighted {
	
	foreach wave in 4 5 7 9 11 {
		tempfile wave`wave'
		insheet using "`output'/fem_hrs_ttest_`tabl'_`wave'.txt",clear
	
		foreach var in `varlist' {
			ren `var' `var'_wave`wave'
		}
		save `wave`wave''
	}

	use "`wave4'", replace
	merge 1:1 variable using "`wave5'", nogen
	merge 1:1 variable using "`wave7'", nogen
	merge 1:1 variable using "`wave9'", nogen
	merge 1:1 variable using "`wave11'", nogen
	
	keep variable fem_mean* hrs_mean* p_value*
	outsheet using table34_`tabl'.csv, comma replace
}



capture log close
