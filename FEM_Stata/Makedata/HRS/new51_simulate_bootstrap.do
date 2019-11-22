
/** \file bootstrap_new51_samples.do
Create bootstrap samples of the new51 files that will be used in simulation

\section hist Limited Version History
- 02/03/2014 - Created

\todo 

*/

include common.do


* Define paths
* Take bootstrap sample as an argument
local bsamp : env BREP

* Take the year as an argument
local scr : env SCENARIO

local outfile $outdata/input_rep`bsamp'/new51s_`scr'.dta

* Take the year as an argument
local fy : env FYEAR
local ly : env LYEAR

* File to use for population projections
global pop_proj pop5152_projection_2150

  **********************************************
 	* Import population trends
 	**********************************************
	use "$outdata/$pop_proj.dta", clear

	qui sum year
	local begyr = r(min)
	local maxyr = r(max)

	sort year male hispan black, stable
	gen subgrp = 2^2 * male + 2^1 * hispan + black
	drop male hispan black
	reshape wide pop, i(year) j(subgrp)
	gen total = pop0+pop1+pop2+pop4+pop5+pop6
	mkmat year pop* total, mat(poptrend)
	
	* Row names
	global rowname ""
	forvalues i = `begyr'(2)`maxyr'{
		global rowname $rowname yr`i'
	}
	
	matrix rownames poptrend = $rowname

/*********************************************************************/
* SAMPLE WITH REPLACEMENT: n-1 method (McCarthy and Snowden, 1985) via (Shao, 2003)
/*********************************************************************/

	use $outdata/input_rep`bsamp'/bootstrap_sample.dta, clear
	tab bsample
	local max=r(r)

	forval i = 1/`max' {	
		if "`scr'" == "bstrend" {
			use $outdata/new51s_status_quo.dta, clear 
		}
		else if "`scr'" == "input_bstrend" {
			use $outdata/input_rep`bsamp'/new51s_input.dta, clear 
		}
	if `i' == 1 {
	sum weight
	dis r(sum)
	}
		gen bsample=`i'
		* merge strata hhid (non wave specific) back onto data as hhidb
		merge m:1 hhidpn_orig using $outdata/hhidb.dta
		drop if _m==2
		drop _merge
		* keep data for transition sample specific to bootstrap sample based on hhidb 
		merge m:1 hhidb bsample using $outdata/input_rep`bsamp'/bootstrap_sample.dta
		keep if _merge==3
		drop _merge
		
		if floor(c(version))>=14 {
			saveold $outdata/input_rep`bsamp'/new51s_`scr'`i'.dta, replace v(12)
		}
		else{
			saveold $outdata/input_rep`bsamp'/new51s_`scr'`i'.dta, replace
		}
		
		}
	
	* stack when hhidb was selected more than once in sample
	use $outdata/input_rep`bsamp'/new51s_`scr'1.dta
		forval i = 2/`max' {
			append using $outdata/input_rep`bsamp'/new51s_`scr'`i'.dta, nolabel
			}

	** replace hhidpn **			
	* Recode HH ID and Person ID

	* Person ID
	ren hhid hhid_old
	ren hhidpn hhidpn_old

	egen hhid = group(hhid_old bsample)
	egen hhidpn = group(hhidpn_old bsample)
	replace hhid = 10^5 + hhid
	replace hhidpn = 10^5 + hhidpn
  tostring hhid, gen(hhidstr) usedisplayformat
  tostring hhidpn, gen(hhidpnstr) 
  drop hhid hhidpn
  tostring year, gen(yearstr) 
	gen hhid = "-" + yearstr + hhidstr
  gen hhidpn = "-" + yearstr + hhidpnstr
  destring hhid hhidpn, replace
  gen subgrp = 2^2 * male + 2^1 * hispan + black

forvalues yy=`fy'(2)`ly' {

	sum weight if year == `yy'
	dis r(sum)

	dis "Population size for aged 51/52 in year `yy' is: `r(sum)'"

	** reweight to population **
	/* Adjust the population weight to reflect population size and structual change */
	levelsof subgrp, local(subgrplv)
	dis "********** current year is: `yy' *************"
	gen weight`yy' = .
	foreach l of local subgrplv {
		sum weight if subgrp == `l' & year == `yy'
		local new51pop = r(sum)
	  local poptotal = poptrend[rownumb(poptrend, "yr`yy'"), colnumb(poptrend,"pop`l'")]
	  dis "new51pop for `yy' and subgroup `l' is `new51pop'"
	  dis "poptotal for `yy' and subgroup `l' is `poptotal'"
		replace weight`yy' = weight * `poptotal' / `new51pop' if subgrp == `l' & year == `yy'
		}
        
	* Old HH total person level weight
	bys hhid: egen oldhhwt = total(weight) if year == `yy'
		
	* New HH total person level weight
	bys hhid: egen newhhwt = total(weight`yy') if year == `yy'
		
	* Adjust HH weight
	 gen wthh`yy' = wthh * newhhwt/oldhhwt if year == `yy'
		 
			 
	replace weight = weight`yy' if year == `yy'
	replace wthh = wthh`yy' if year == `yy'
	drop newhhwt oldhhwt weight`yy' wthh`yy'
        
	sum weight if year == `yy'
	dis r(sum)

	dis "Population size for aged 51/52 in year `yy' is: `r(sum)'"
	
	local yrtotal = poptrend[rownumb(poptrend, "yr`yy'"), colnumb(poptrend,"total")]
	dis "Census population size for aged 51/52 in year `yy' is: `yrtotal'"
	
	sum wthh
	dis r(sum)
	
}
				
	if floor(c(version))>=14 {
			saveold $outdata/input_rep`bsamp'/new51s_`scr'.dta, replace v(12)
		}
		else{
			saveold $outdata/input_rep`bsamp'/new51s_`scr'.dta, replace
		}


	forval i = 1/`max' {	
		rm $outdata/input_rep`bsamp'/new51s_`scr'`i'.dta
	}	
