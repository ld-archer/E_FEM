***************************************************************
* Prepare data for estimating Medicare Part D costs and Cross Sectional Enrollment
* 2/1/2009 - File Created
* Both models are done cross sectionally
***************************************************************

local defmod : env suffix
log using "./MedicarePartD`defmod'.log", replace

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
  di as error "The MedicarePartD script now requires a suffix input"
  exit 197
}

use "$mcbs_dir/mcbs9212", clear
keep if year >= 2007

* Only use years after 2006, because Part D was unavailable before then
gen flag51 = year >= 2006 & age>=51

* Prepare some data
cap drop mcare_ptd_enroll


* Get the total capitation rate
cap drop mcare_ptd
gen mcare_ptd = 0
forvalues m = 1/9 {
	replace mcare_ptd = mcare_ptd + h_pdpy0`m'
}
forvalues m = 10/12 {
	replace mcare_ptd = mcare_ptd + h_pdpy`m'
}

* Enrolled in medicare if non missing capitation payments
gen mcare_ptd_enroll =  !missing(mcare_ptd)

* Diagnostics
qui { 
		sum mcare_ptd [aw=cweight]
	local mcare_ptd_percap = r(mean)
	qui sum cweight if mcare_ptd_enroll
	local mcare_ptd_enroll = r(sum)/10^6
	qui sum cweight
	local mcare_enroll = r(sum)/10^6
	local pct_mcare_ptd_enroll = `mcare_ptd_enroll' * 100 / `mcare_enroll'
	local mcare_ptd_ttl = `mcare_ptd_enroll'*`mcare_ptd_percap'/10^3
	noi di "Medicare Part D Stats in 2006 (MCBS):"
	noi di "     Per Capita Cost       : $"%-9.2f `mcare_ptd_percap' 
	noi di " Total Pt D Enrollment (M) : " %-9.1f `mcare_ptd_enroll' 
	noi di "      Total Enrollment (M) : " %-9.1f `mcare_enroll' 
	noi di "   Percent Pt D Enrollment : " %-9.1f `pct_mcare_ptd_enroll' 
	noi di "      Total Cost (B)       : $"%-9.1f `mcare_ptd_ttl' 
	noi di ""

	sum mcare_ptd [aw=cweight] if flag51
	local mcare_ptd_percap = r(mean)
	qui sum cweight if mcare_ptd_enroll & flag51
	local mcare_ptd_enroll = r(sum)/10^6
	qui sum cweight if flag51
	local mcare_enroll = r(sum)/10^6
	local pct_mcare_ptd_enroll = `mcare_ptd_enroll' * 100 / `mcare_enroll'
	local mcare_ptd_ttl = `mcare_ptd_enroll'*`mcare_ptd_percap'/10^3
	noi di "Medicare Part D Stats in 2006 (MCBS Aged 51+):"
	noi di "     Per Capita Cost       : $"%-9.2f `mcare_ptd_percap' 
	noi di " Total Pt D Enrollment (M) : " %-9.1f `mcare_ptd_enroll' 
	noi di "      Total Enrollment (M) : " %-9.1f `mcare_enroll' 
	noi di "   Percent Pt D Enrollment : " %-9.1f `pct_mcare_ptd_enroll' 
	noi di "      Total Cost (B)       : $"%-9.1f `mcare_ptd_ttl' 
	noi di ""
	
	noi di "CMS TR Medicare Part D Stats in 2006"
	noi di "     Per Capita Cost       : $1690"
	noi di " Total Pt D Enrollment (M) :  27.9"
	noi di "      Total Enrollment (M) :  43.2"
	noi di "   Percent Pt D Enrollment :  64.6"
	noi di "      Total Cost (B)       : $47.1"
	noi di "Source: http://www.cms.hhs.gov/reportstrustfunds/downloads/tr2007.pdf"
	noi di ""
}
* pause
keep if flag51

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
local depvars age male male_black male_hispan male_hsless black hispan hsless college widowed married iearnx work cancre diabe hibpe stroke hearte lunge iadl1 iadl2p adl1 adl2 adl3p smokev smoken diclaim

* Eliminate records with missing independent variables. Hotdeck instead later?
gen anymiss = 0
qui {
foreach x in `depvars' {
	dis "`x'"
	count if missing(`x')
	replace anymiss = 1 if missing(`x')
}
}
qui count if anymiss
di "Removing " r(N) " records with missing independent variables"
drop if anymiss


* Age splines
gen age75l = min(age, 75) 
gen age75p = max(0.0, age-75) 

label var mcare_ptd_enroll "Pt D enrollment"
label var mcare_ptd "Pt D capitated payment"

** save the estimation data for diagnostics and for extracting variable labels
save $dua_mcbs_dir/mcbs_ptd_est.dta, replace

*** get the covariate definitions for defmod
include mcared_mcbs_covariate_defs`defmod'.do	

probit mcare_ptd_enroll $mcare_ptd_enroll_covar [pw=cweight]
ch_est_title "Part D enrollment coefficients"
mfx2, nose stub(mcare_ptd_enroll)
est save "$ster/mcare_ptd_enroll.ster", replace
est restore mcare_ptd_enroll_mfx
ch_est_title "Part D enrollment marginal effects"
est store mcare_ptd_enroll_mfx


reg  mcare_ptd $mcare_ptd_covar [pw=cweight] if mcare_ptd_enroll
ch_est_title "Part D capitated payment coefficients"
mfx2, nose stub(mcare_ptd_cost)
est save "$ster/mcare_ptd.ster", replace
est restore mcare_ptd_cost_mfx
ch_est_title "Part D capitated payment marginal effects"
est store mcare_ptd_cost_mfx

*** put estimates into regression tables
xml_tab mcare_ptd*, save($ster/mcare_ptd.xls) replace pvalue stats(N r2_a)

* also write estimates as a sheet in the file to be distributed with tech appendix
* xml_tab mcare_ptd*, save($ster/FEM_estimates_table.xml) sheet(mcare_ptd) append pvalue stats(N r2_a)

