cap program drop annualize_psidvar
program define annualize_psidvar

syntax [varlist] [if] [in], econitem(string) annualvar(name) topvalue(real)
	
	marksample touse, novarlist	
	
	*tab `touse'

	*dis "`econitem'"
	*dis `topvalue'
	/*
	*"econitem": a string indicating the type of variable
	*"annualvar": annualized variable to generate
	*"topvalue": top coding for amount reported
	*`anyvar': whether any
	*`amtvar': amount reported
	*`pervar': unit of amount reported
	*`janvar': indicator of any amount in January
	*/
	
	tempvar anyvar amtvar pervar 
	gen `anyvar' = `econitem'any if `touse'
	gen `amtvar' = `econitem'amt if `touse'
	gen `pervar' = `econitem'per if `touse'

	*Monthly indicators from feb to dec
	
	foreach mth in jan feb mar apr may jun jul aug sep oct nov dec {
		tempvar `mth'var
		gen ``mth'var' = `econitem'`mth'
	}
	
	*UNIT OF AMOUNT REPORTED
	/*
	G60a. How much did she receive from Supplemental Security Income in 1998?--TIME UNIT
	3 Week 
	4 Two weeks 
	5 Month 
	6 Year 
	7 Other 
	8 DK 
	9 NA; refused 
	0 Inap.: no wife/"wife" in FU; did not receive any income in 1998; no income from SSI in 1998 
	*/

	*Define imputation sample based on positive (DK,RF) for amount received
	tempvar impsamp
	gen `impsamp' = `amtvar' > 0 & `amtvar' < . if `touse'
	
	*months covered
	tempvar mthcovered 
	gen `mthcovered' = 0 if `impsamp' & `touse'
	foreach mth in jan feb mar apr may jun jul aug sep oct nov dec {
		replace `mthcovered' = `mthcovered' + 1 if ``mth'var' == 1
	}	
	#d;
	gen `annualvar' =  `amtvar' * (`pervar' == 3) * (52/12) * `mthcovered' + 
		`amtvar' * (`pervar' == 4) * (26/12) * `mthcovered' + 
		`amtvar' * (`pervar' == 5) * `mthcovered' + 
		`amtvar' * (`pervar' == 6) 
		if `amtvar' > 0 & `amtvar' < `topvalue' & inlist(`pervar',3,4,5,6) & `touse';
	#d cr
	
	*PSID chose 6 mths coverage for imputation if reported units are weekly, bioweekly, or monthly and months are zero
	#d;
	replace `annualvar' =  `amtvar' * (`pervar' == 3) * 26 + 
		`amtvar' * (`pervar' == 4) * 13 + 
		`amtvar' * (`pervar' == 5) *6
		if `amtvar' > 0 & `amtvar' < `topvalue' & inlist(`pervar',3,4,5) & `touse' & `mthcovered' == 0;
	#d cr	
	
	*median of valid values 
	
	qui sum `annualvar' if  `touse' , det
	replace `annualvar' = r(p50) if `impsamp' & missing(`annualvar') & `touse'
	replace `annualvar' = 0 if `amtvar' == 0 & `touse'
	replace `annualvar' = 0 if `pervar' == 0 & `touse'
	*replace `annualvar' = . if inlist(`anyvar',8,9) & `touse'

	*any annual values, considering DK,RF for the original "any" variable
	*gen `newany' = `annualvar' > 0 if !inlist(`anyvar',8,9) & `touse'
	
	*optional: months covered
	*cap drop `econitem'mths
	*gen `econitem'mths = `mthcovered'
	
end
