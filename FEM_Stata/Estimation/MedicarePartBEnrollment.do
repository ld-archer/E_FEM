***************************************************************
* Prepare data for estimating medicare part B enrollment
* 10/1/2009 - File Created
* 10/5/2009 - Models finalized and code changed to be compatible with ZENO file structure
***************************************************************

local defmod : env suffix
log using "./MedicarePartBEnrollment`defmod'.log", replace

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
if !missing("`defmod'"){
	global ster "$local_path/Estimates/`defmod'"
}
else {
  di as error "The MedicarePartBEnrollment script now requires a suffix input"
  exit 197
}

use "$mcbs_dir/mcbs9212", clear


* Only use years 1999+, because job status is only available in 1999+
keep if inrange(year,2007,2012) & age>=51

* Prepare some data
cap drop est_flag ptb_flag mon_death


* The month the person died. 
gen mon_death = month(dod)

gen est_flag = 0
gen ptb_flag = .

* Estimation dataset includes new enrollees
replace est_flag = 1 if newenrol == 1

* Estimation dataset also includes persons that could have enrolled in medicare part B,
forvalues i = 1/11 {
	* Use the d_care1-11 variables to see if the persons didn't have medicare part B in a month
	* but don't consider months after the person died
	replace est_flag = 1 if inlist(d_care`i', 0, 1) & `i' <= mon_death
	
	* Flag the person as obtaining part B if the person got part B in the next month.
	local j = `i' + 1
	replace ptb_flag = 1 if inlist(d_care`j', 2, 3) & est_flag == 1
}

* Persons that could have gotten part B but didnt
replace ptb_flag = 0 if missing(ptb_flag) & est_flag == 1

* Only keep the records that are flagged as being for estimation
keep if est_flag == 1

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
keep year baseid `depvars' ptb_flag cweight age newenrol hearte lunge

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
gen age75l = min(age, 75) 
gen age75p = max(0.0, age-75) 

gen mcare_ptb_enroll = ptb_flag

*** get the covariate definitions for defmod
include mcareb_mcbs_covariate_defs`defmod'.do	

** save the estimation data for diagnostics and for extracting variable labels
save $dua_mcbs_dir/mcbs_enroll_est.dta, replace

* New enrollee Part B Take up Model
di "New enrollee Part B Take up Model"
probit mcare_ptb_enroll $mcareb_newenroll_covar [pw=cweight] if newenrol == 1
ch_est_title "New enrollee Part B Take up coefficients"
mfx2, nose stub(mcareb_newenroll)
est save "$ster/mcareb_takeup_newenroll.ster", replace
est restore mcareb_newenroll_mfx
ch_est_title "New enrollee Part B Take up marginal effects"
est store mcareb_newenroll_mfx

di "Current enrollee Part B Take up Model"
probit mcare_ptb_enroll $mcareb_curenroll_covar [pw=cweight] if newenrol == 0
ch_est_title "Current enrollee Part B Take up coefficients"
mfx2, nose stub(mcareb_curenroll)
est save "$ster/mcareb_takeup_curenroll.ster", replace
est restore mcareb_curenroll_mfx
ch_est_title "Current enrollee Part B Take up marginal effects"
est store mcareb_curenroll_mfx

** Copy for Medicare Part A
gen mcare_pta_enroll = mcare_ptb_enroll
di "New enrollee Part A Take up Model"
probit mcare_pta_enroll $mcarea_newenroll_covar [pw=cweight] if newenrol == 1
ch_est_title "New enrollee Part A Take up coefficients"
mfx2, nose stub(mcarea_newenroll)
est save "$ster/mcarea_takeup_newenroll.ster", replace
est restore mcarea_newenroll_mfx
ch_est_title "New enrollee Part A Take up marginal effects"
est store mcarea_newenroll_mfx

di "Current enrollee Part A Take up Model"
probit mcare_pta_enroll $mcarea_curenroll_covar [pw=cweight] if newenrol == 0
ch_est_title "Current enrollee Part A Take up coefficients"
mfx2, nose stub(mcarea_curenroll)
est save "$ster/mcarea_takeup_curenroll.ster", replace
est restore mcarea_curenroll_mfx
ch_est_title "Current enrollee Part A Take up marginal effects"
est store mcarea_curenroll_mfx

*** put estimates into regression tables
xml_tab mcare*, save($ster/mcare_takeup.xls) replace pvalue stats(N r2_a)

* also write estimates as a sheet in the file to be distributed with tech appendix
* xml_tab mcare*, save($ster/FEM_estimates_table.xml) append sheet(mcare_takeup) pvalue stats(N r2_a)
