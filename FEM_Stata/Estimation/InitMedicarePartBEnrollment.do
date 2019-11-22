***************************************************************
* Prepare data for estimating medicare part B enrollment among the initial population
* 10/6/2009 - File Created
***************************************************************

local defmod : env suffix

clear all
set more off
est clear
set memory 500m

* Assume that this script is being executed in the FEM_Stata/Estimation directory

* Load environment variables from the root FEM directory, two levels up
* these define important paths, specific to the user
include "../../fem_env.do"

local bsamp : env BREP

* Bootstrapping is not currently supported
assert missing("`bsamp'")

* Define Aux Directories
if missing("`bsamp'") {
	log using "./InitMedicarePartBEnrollment`defmod'.log", replace
	if !missing("`defmod'"){
		global ster "$local_path/Estimates/`defmod'"
	}
	else {
          di as error "The InitMedicarePartBEnrollment script now requires a suffix input"
          exit 197
	}
}
else {
	log using "./bootstrap_logs/InitMedicarePartBEnrollment`bsamp'_`defmod'.log", replace
	if !missing("`defmod'"){
		global ster "$local_path/Estimates/`defmod'/models_rep`bsamp'"
	}
	else {
          di as error "The InitMedicarePartBEnrollment script now requires a suffix input"
          exit 197
	}
}


use "$mcbs_dir/mcbs9212", clear


* Only use years 1999+, because job status is only available in 1999+
keep if inrange(year,2007,2012) & age>=51

* Prepare some data
cap drop mcare_ptb_enroll 

/* Flag persons that have part b */
gen mcare_ptb_enroll = inlist(d_care, 2, 3)

/* Fix the age to be July 1st */
replace age = ageexact + .5
label variable age "Exact age on July 1st"

* Rename some variables to their names in the FEM
ren hispanic hispan
ren cancer cancre
ren diabet diabe
ren hbp hibpe
ren heart hearte
ren lung lunge
ren eversmok smokev
ren smokenow smoken
ren hsdrop hsless

* Recode marital status
recode spmarsta ( -9 -8 -7 = .) (1 = 1 "1.married") ( 2 = 2 "2.widowed") ( 3 4 5 = 3 "3.single"), gen(rmstat)

capture drop married
cap drop widowed
gen married = rmstat == 1 if rmstat < .
gen widowed = rmstat == 2 if rmstat < .
gen single  = rmstat == 3 if rmstat < .

* Prepare functional status
capture drop funcstat

gen  adl_ct2 = bathing + dressing + eating + bedchair + walking + toilet
*gen iadl_ct2 = prbtele + prblhwk + prbmeal + prbshop + prbbils
* IADL variables have been replaced with formatted variables similar to what was done with ADLs
gen iadl_ct2 = telephone + meals + lhousework + hhousework + shopping + bills

gen iadl1 = iadl_ct2 == 1 if iadl_ct2 < .
gen iadl2p = iadl_ct2 >= 2 if iadl_ct2 < .
gen adl1 = adl_ct2 == 1 if adl_ct2 < .
gen adl2 = adl_ct2 == 2 if adl_ct2 < .
gen adl3p = adl_ct2 >= 3 if adl_ct2 < .

/* Indicator for being disablied eligable for medicare */
gen diclaim = inrange(h_medsta,20,21)

/* Recode work from job status */
recode jobstat (1=1) (2=0) (nonmiss = .), gen(work)
label variable work "Working"

/* rename the income variable */
gen iearnx = min(income/1000, 200)

/* Generate some disparity interactions */
  gen male_black = male*black
gen male_hispan = male*hispan
gen male_hsless = male*hsless

* Possible dependent variables
local depvars male male_black male_hispan male_hsless black hispan hsless college widowed iearnx work cancre diabe hibpe stroke iadl1 iadl2p adl1 adl2 adl3p obese smokev diclaim overwt smoken

* Eliminate records with missing dependent variables. Hotdeck instead later?
gen anymiss = 0
foreach x in `depvars' {
	dis "`x'"
	count if missing(`x')
	replace anymiss = 1 if missing(`x')
}
drop if anymiss

* Trim the dataset
keep year baseid `depvars' mcare_ptb_enroll cweight age hearte lunge

* Define possible interactions
gen diabe_hearte = diabe*hearte
gen diabe_hibpe = diabe*hibpe
gen diabe_obese = diabe*obese
gen diclaim_adl3p = diclaim*adl3p
gen hearte_diclaim = hearte*diclaim
gen hearte_smokev = hearte*smokev
gen hibpe_hearte = hibpe*hearte
gen hibpe_obese = hibpe*obese
gen hibpe_stroke = hibpe*stroke
gen lunge_diclaim = lunge*diclaim
gen work_adl3p = work*adl3p
gen work_diclaim = work*diclaim
gen work_hearte = work*hearte
gen work_iadl1 = work*iadl1

* Age splines
mkspline age65l 65 age6575 75 age75p = age

*** get the covariate definitions for defmod
include init_mcareb_mcbs_covariate_defs`defmod'.do	

** save the estimation data for diagnostics and for extracting variable labels
if missing("`bsamp'") {
	save $dua_mcbs_dir/mcbs_initenroll_est.dta, replace
}

di "Part B Take up Model"
probit mcare_ptb_enroll $cov_mcare_ptb_enroll    [pw=cweight] 
ch_est_title "Part B initial takeup coefficients"
mfx2, nose stub(mcareb_init)
est save "$ster/mcareb_takeup_init.ster", replace
est restore mcareb_init_mfx
ch_est_title "Pt B initial takeup marginal effects"
est store mcareb_init_mfx


*** put estimates into regression tables
xml_tab mcareb*, save($ster/mcareb_init.xls) replace pvalue stats(N r2_a)

* also write estimates as a sheet in the file to be distributed with tech appendix
* xml_tab mcareb*, save($ster/FEM_estimates_table.xml) sheet(mcareb_initenroll) append pvalue stats(N r2_a)

shell touch $ster/mcareb_init.txt
