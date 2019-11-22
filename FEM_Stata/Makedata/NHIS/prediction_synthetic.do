
*** Build a synthetic cohort 
*** Apr 2007
*** Feb 2015 Update the mortality data to year 2009
*** This method only works for diseases (absorbing states)

capture clear
capture set mem 400m
set more off
set seed 1234567

* Get the mortality data 

local fstyr = 1997		// First year of historical data
local lstyr = 2009		// Last year of historical data
local fstage = 25		// Lowest age
local lstage = 52		// Highest age
local fstsimuyr = 2010		// First year for simulated data
local lstsimuyr = 2030		// Last year for simulated data

* Results not sensitive to the rate of improvement
global improve_past = 0.01	
global improve_future = 0.008

* Relative risk for mortality
foreach v in pcancre phearte pstroke {
	local rr`v' = 2
}

foreach v in pdiabe phibpe plunge {
	local rr`v' = 1.5
}

	*************************************************
	*** Retrieve historical age-specific mortality rate given specified age range and year range
	*************************************************
	
local yrrange = `lstyr' - `fstyr' + 1
set obs  `yrrange'
gen year = `fstyr' + _n -1 

local agerange = `lstage' - `fstage' + 1
expand `agerange'
sort year, stable
by year: gen age = `fstage' + _n -1  
tempfile tmp
sort year age, stable
save `tmp', replace

/* This is the cohort death rate file 1x1 from the following URL:
http://www.mortality.org/cgi-bin/hmd/country.php?cntr=USA&level=1
*/
  infile using $indata/hmd.dct, clear using($hmd_dir/cMx_1x1.txt)



ren year birthyear
gen year = birthyear + age
drop birthyear male female
sort year age, stable

merge year age using `tmp'
tab _merge
drop if _merge == 1

local mrateimprove  = $improve_past
sort age year, stable

*** Impute mortality rate if not available for the youngest cohorts
	sort age year, stable
	by age: replace total = total[_n-1] * ( 1 - `mrateimprove') if total == . 

keep year age total
ren total mrate

*** If mortality rate is zero
*** replace mrate = 0

sort year age, stable
tempfile tmp
save `tmp', replace

*** Take the predicted prevalence by year and by year, link with mortality rates
use "$outdata/pred.dta", clear
keep if inrange(age, `fstage', `lstage')
merge year age using `tmp', sort
qui count if _merge != 3
if r(N)>0 {
	dis "non-matched for mortality rate, wrong"
	exit(333)
}

*** Get the prevalence next year using synthetic cohort approach
foreach v in $poutcome { 
	sort year age, stable
	gen f1`v' = `v'[_n + `agerange' + 1] if year[_n + `agerange' + 1] - year == 1
}


* Assume that the net increase rate of prevalance rate keep stable, assume zero recover rate

foreach v in $poutcome {
        cap drop dmrate
        gen dmrate = mrate/(`v' + (1-`v')/`rr`v'')
	gen inc`v' = (f1`v' * ( 1 - mrate) - `v' * ( 1 - dmrate)) /((1 - `v')*( 1 - dmrate/`rr`v''))
}
/*
* Age specific incidence rates, use the year 2004 rates
foreach v in $poutcome {
	xi: reg inc`v' i.age year 
	gen year_old = year
	replace year = 2004
	drop inc`v'
	predict inc`v' if e(sample)
	replace year = year_old
	drop year_old
}
*/

  tempfile incidence
preserve
	collapse inc* if inrange(year, 1997,2009), by(age)
	save `incidence'
restore 

* Gender-age specific prevalances and mortality rates in year 2009 (the year before first simulation year)

collapse $poutcome mrate if inrange(year, 2009,2011), by(age)
merge age using `incidence', sort

	***************************************
	*** Predict prevalence in future years 
	***************************************
	
keep if inrange(age, `fstage',`lstage')

local mrateimprove  = $improve_future

*** For each outcome measure
*** Mortality
sort age, stable
	mkmat age mrate, mat(mort)
	matrix A = J(rowsof(mort), `lstsimuyr' - `fstsimuyr' + 1, .)

foreach v in $poutcome { 
	sort age, stable
	mkmat age `v' , mat(`v')
	matrix `v' = `v', A
	mkmat age inc`v' , mat(minc`v')

}

matrix result = J(1, `lstsimuyr' - `fstsimuyr' + 3, . )


global mortimprove = 0.008

set trace off

* local colname 
foreach v in $poutcome {

*		local colname `colname' `v'
		dis "outcome is `v' "
		set trace off
		* Matrix for prevalence of aged 51 and 52 (take the average of aged 51 and 52)
		matrix a5152 = J(1, colsof(`v'), . )
		matrix a5152[1,1] = 51
		matrix a5152[1,2] = (`v'[rowsof(`v'),2] + `v'[rowsof(`v') - 1 ,2])/2
		
		local begcol = 3
		forvalues yy = `fstsimuyr'/`lstsimuyr' { 
			local begrow = `yy' - (`fstsimuyr' - 1) + 1
			local endrow = `lstage' - `fstage' + 1
			forvalues a =  `begrow' / `endrow' {
				local rr   = `rr`v''		
					/* Relative risk of death compared to without condition */

				local pt_1 = `v'[`a' - 1,`begcol' -1] 
					/* Prevlance of age -1 in t-1 */

				local dt_1 = mort[`a' - 1, colnumb(mort,"mrate")] * ( 1 - `mrateimprove')^(`yy'- (`fstsimuyr' - 1) - 1)
					/* Mortality rate for total at time t-1 */

				local mt_1 = `dt_1'/(`pt_1' + (1-`pt_1')/`rr')
					/* Mortality rate for with disease at age-1 and time-1 */

				local it_1 = minc`v'[`a' - 1, colnumb(minc`v',"inc`v'")]
					/* Age-specific incidence rate */
					
				matrix `v'[`a',`begcol'] =  `pt_1' * ( 1 - `mt_1')/ (1 - `dt_1') + (1-`pt_1')*`it_1'*( 1 - `mt_1'/`rr')/(1 - `dt_1')
					/* Age-specific prevalence */
			}
			
			matrix a5152[1,`begcol'] = (`v'[rowsof(`v'),`begcol'] + `v'[rowsof(`v') - 1 ,`begcol'])/2
			local begcol = `begcol' + 1
		}
		matrix result = result \ a5152

}

* Remove the first column (not useful)

matrix result = result[2...,2...]
matrix list result
matrix result = result'
matrix colnames result = $poutcome
matrix list result

drop _all
svmat result, names(col)
gen year = _n + 2009

save  $outdata/pred5152.dta, replace

