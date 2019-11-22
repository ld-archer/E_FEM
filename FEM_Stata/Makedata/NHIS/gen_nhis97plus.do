// This file generates the nhis97plus consolidated file from the raw NHIS survey components

set maxvar 10000
clear all
set more off

include ../../../fem_env.do

local healthvars hypev chdev angev miev hrtev strev dibev cbrchyr ephev cnkind* canev
local disabvars plawklim pss*
local riskvars smkev smknow bmi
local demog race* educ* age_p origin* sex
local utilization private medicare medicaid ihs mil* oth*pub oth*gov
  
forvalues yyyy=1997/2010 {
  if `yyyy' == 1997 {
    local yearspec sdpdisb
  }
  if `yyyy' > 1997 {
    local yearspec notcov
  }
  if `yyyy' > 1998 {
    local yearspec *chip `yearspec'
  }
  
  use srvy_yr hhx fmx *px `demog' `disabvars' `utilization' `yearspec' using $nhis_dir/nhis`yyyy'/data/personsx.dta
  if `yyyy' <= 2003 {
    merge 1:1 srvy_yr hhx fmx px using $nhis_dir/nhis`yyyy'/data/samadult.dta, assert(master match) keep(match) nogen keepusing(`healthvars' `riskvars' wtfa_sa)
  }
  else {
    merge 1:1 srvy_yr hhx fmx fpx using $nhis_dir/nhis`yyyy'/data/samadult.dta, assert(master match) keep(match) nogen keepusing(`healthvars' `riskvars' wtfa_sa)
  }

  tempfile nhis`yyyy'
  save `nhis`yyyy''
}

use `nhis1997', clear
forvalues yyyy=1998/2010 {
  append using `nhis`yyyy''
}

replace origin_i = origin if missing(origin_i)

replace race = racer_p if missing(race)
replace race = racerp_i if missing(race)
replace race = racerpi2 if missing(race)

replace military = milcare if missing(military)
replace otherpub = othpub if missing(otherpub)
replace othergov = othgov if missing(othergov)

qui compress
save "$outdata/nhis97plus.dta", replace
