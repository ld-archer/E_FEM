/* Social Security Supplementary Income for United States -
Based on regressions by Shawn

Bryan 12/2013:  UpdateAIME_v2.ado is a copy of the file previously used in the simulation.  Now, it is
used in the data generation process (in aime_gen_all.do) to update AIME values for individuals
after the wave in which they gave permission to access their SS records.   

To do:  Update these hardcoded models with models we estimate.
---------------------------------------------------- */

program define UpdateAIME_v2,	
	syntax varlist [if], gen(namelist)
	marksample touse
	tokenize `varlist'
	#delimit;
	tempvar aime ry_earn age sex yr;
	
	///1. Assign Data to Variables -------------------
	
	qui gen `aime'     = `1'  if `touse';	
	qui gen `ry_earn'	 = `2'  if `touse';
	qui gen `age'	 = `3'  if `touse';	
	qui gen `sex'	 = `4'  if `touse';	
	qui gen `yr'       = `5'  if `touse';	

	tempvar cpiyr cpi92;
	qui egen `cpiyr' = cpi(`yr') if `touse';
	qui egen `cpi92' = cpi(1992) if `touse';
	qui replace `cpiyr' = `cpi92'/`cpiyr' if `touse';

	qui replace `aime' = `aime'*`cpiyr' if `touse';
	qui replace `ry_earn' = `ry_earn'*`cpiyr' if `touse';

	/// 2.A Loading Parameters -------------------
	tempname pars_m pars_f;
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
	 	
	matrix input `pars_f' = (
		-0.6428344,
		0.956511,
		-0.0148539,
		0.0404891,
		0.0095312,
		0.0102989,
		-0.0008079,
		-0.0139591,
		0.0032182,
		-0.0016385,
		5.02E-06,
		-0.0070748,
		0.0039112,
		0.0000205,
		-0.0003838,
		0.0001103,
		0.000011,
		-5.75E-06,
		0.0190655,
		-0.0155299);
	matrix colnames `pars_f' = `cons' `m' `e' `a' `m2' `e2' `a2' `me' `am' 
				`ae' `a3' `m3' `e3' `ame' `am2' `ae2' `a2m' `a2e' `m2e' `e2m'; 
	

	matrix input `pars_m' = (
		1.736857,
		0.6951943,
		0.00041,
		-0.0685375,
		0.0407903,
		0.0191816,
		0.0007148,
		-0.0479509,
		0.0101093,
		0.0000246,
		-5.85E-06,
		-0.006154,
		0.0019137,
		-0.0004902,
		-0.000729,
		0.0002401,
		0.0000348,
		-8.00E-06,
		0.0158903,
		-0.0099898);
	matrix colnames `pars_m' = `cons' `m' `e' `a' `m2' `e2' `a2' `me' `am' 
				`ae' `a3' `m3' `e3' `ame' `am2' `ae2' `a2m' `a2e' `m2e' `e2m'; 

		
	/// Generating Prediction
	tempvar faime diff;
	qui gen `faime' = `aime' if `touse';
	qui matrix score `faime' = `pars_f' if `sex'==0&`touse', replace;
	qui matrix score `faime' = `pars_m' if `sex'==1&`touse', replace;	

	qui gen `diff' = max(min(`faime' - `m',0.25),0) if `touse'&`faime'!=.;
	qui replace `faime' = `m' + `diff' if `touse';
	qui replace `faime' = exp(`faime') if `touse';

	qui replace `faime' = `aime' if `touse'&`ry_earn'==0;

	qui replace `faime' = `faime'/`cpiyr' if `touse';
	
	tokenize `gen';
	qui gen `1' = `faime' if `touse';
end;
