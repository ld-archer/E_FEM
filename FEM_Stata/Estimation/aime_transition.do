/* The goal with this file is to estimate a how AIME changes from year to year for men and women.

It is based on the idea in UpdateAIME.ado, which was then implemented in C++.  We do not have code that estimates the models.

The specification is based on the following:
	tempvar m e a m2 e2 a2 me am ae a3 m3 e3 ame am2 ae2 a2m a2e m2e e2m cons;
	qui gen `m' = log(`aime') if `touse';
	qui gen `e' = log(`ry_earn') if `touse';
	qui gen `a' = `age' if `touse';
	qui gen `m2' = `m'^2 if `touse';
	qui gen `e2' = `e'^2 if `touse';
	qui gen `a2' = `a'^2 if `touse';
	qui gen `me' = `m'*`e' if `touse';
	qui gen `am' = `a'*`m' if `touse';
	qui gen `ae' = `a'*`e' if `touse';
	qui gen `a3' = `a2'*`a' if `touse';
	qui gen `m3' = `m2'*`m' if `touse';
	qui gen `e3' = `e2'*`e' if `touse';
	qui gen `ame' = `a'*`m'*`e' if `touse';
	qui gen `am2' = `a'*`m2' if `touse';
	qui gen `ae2' = `a'*`e2' if `touse';
	qui gen `a2m' = `a2'*`m' if `touse';
	qui gen `a2e' = `a2'*`e' if `touse';
	qui gen `m2e' = `m2'*`e' if `touse';
	qui gen `e2m' = `e2'*`m' if `touse';
	qui gen `cons' = 1 if `touse';
	
	*/




clear all
set mem 500m
set more off
set seed 52432
*set maxvar 10000
set matsize 5000

est drop _all

include "../../fem_env.do"

* Define paths
local ster    				"$local_path/Estimates"

use "$dua_rand_hrs/aime_transition.dta", clear


gen logaime = log(aime + sqrt(1+aime^2))

gen m = log(laime + sqrt(1+laime^2)) 
gen e = log(iearn + sqrt(1+iearn^2))
gen a = age 
gen m2 = m^2
gen e2 = e^2 
gen a2 = a^2 
gen me = m*e 
gen am = a*m 
gen ae = a*e 
gen a3 = a2*a 
gen m3 = m2*m 
gen e3 = e2*e 
gen ame = a*m*e 
gen am2 = a*m2 
gen ae2 = a*e2 
gen a2m = a2*m 
gen a2e = a2*e 
gen m2e = m2*e 
gen e2m = e2*m 

local rhs m e a m2 e2 a2 me am ae a3 m3 e3 ame am2 ae2 a2m a2e m2e e2m



reg logaime `rhs' if male == 0
predict paime_f if male == 0


reg logaime `rhs' if male == 1
predict paime_m if male == 1

gen paime = paime_f if male == 0
replace paime = paime_m if male == 1

gen diff = logaime - paime




capture log close
