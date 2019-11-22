include common.do 

***************************************************
*RECODE VARIABLES FROM PSID FAMILY YEARLY FILES
***************************************************




*RUN THE ADO FILE THAT ANNULIZES AND IMPUTES ECONOMIC OUTCOME VARIABLES
*Algorithm confirmed to work very well by using 2005-2009 data
run "$wkdir/annualize_psidvar.ado"

* local begyr = 1999
* local endyr = 2009

forvalues yr = $firstyr(2)$lastyr {
	use "$temp_dir/psid_fam`yr'er_select", clear

	if `yr' == 2001 {
	* recode extreme va amt to be a yearly rather than monthly value
		replace hdvapenper = 6 if hdvapenamt == 35400
	}
	
	*ANNUALIZED VARIABLES PROVIDED SINCE YEAR 2005, except for food stamps
	if `yr' >= 2005 {
		*ANNUALIZED VARIABLES PROVIDED SINCE YEAR 2005, except for food stamps
		foreach p in hd  {
			foreach x in fdstmp {
				set trace off
				cap confirm var `p'`x'gen
				if _rc !=0  {
					qui annualize_psidvar, econitem("`p'`x'") annualvar("`p'`x'gen") topvalue(999997)
				}
			}
		}		
		
	}
	
	*Before 2005,non-labor income components need to be annulized
	else {
		
		*TYPE OF INCOME VARIABLES THAT NEED TO BE ANNULIZED - head pension variables should be treated differently as their top coding is higher
		*type of income
		*for head
		global hdlist_short ssi adc chdsp welf fdstmp unemp wkcmp alim   hlprel hlpfrd othtr
		*for wife
		global wflist_short ssi adc chdsp welf        unemp wkcmp othret hlprel hlpfrd othtr
	
		foreach p in hd wf {
			local lshort `p'list_short
			foreach x in $`lshort' {
				set trace off
				qui annualize_psidvar, econitem("`p'`x'") annualvar("`p'`x'gen") topvalue(999997)
			}
		}
		
		*HEAD pension variables - VA - turned out topcoding still 999997
		*correction(1/28/2014): topcoding is 99997 through 2003
		*vapen  othpen annui retunk 
		gen hdvapenany = 0
		forvalues i = 1/3 {
			cap confirm var hdvapen`i'any
			if _rc==0 {
				replace hdvapenany = 1 if inrange(hdvapen`i'any,1,4)
			}
		}
		forvalues i = 1/3 {
			cap confirm var hdvapen`i'any
			if _rc==0 {		
				replace hdvapenany = . if hdvapenany == 0 & inrange(hdvapen`i'any,8,9)
			}
		}
		foreach p in hd  {
			foreach x in vapen {

				qui annualize_psidvar , econitem("`p'`x'") annualvar("`p'`x'gen") topvalue(99997)
		
			}
		}
		
		*HEAD pension variables - Other retirement pension - turned out topcoding still 999997
		foreach p in hd  {
			foreach x in othpen annui retunk {
				cap drop `p'`x'any
				qui gen `p'`x'any = `p'othretany
				qui annualize_psidvar, econitem("`p'`x'") annualvar("`p'`x'gen")  topvalue(999997)
			}
		}
		
	}

	*DROP VARIABLES FOR INCOME COMPONENTS
	*for head
	global hdlist_short ssi adc chdsp welf fdstmp unemp wkcmp vapen alim othret othpen annui retunk hlprel hlpfrd othtr
	*for wife
	global wflist_short ssi adc chdsp welf        unemp wkcmp      othret                    hlprel hlpfrd othtr
	
	foreach p in hd wf {
		local lshort `p'list_short

		foreach x in $`lshort' {
			
			if "`p'" == "hd" & "`x'" == "othret" {
				foreach s in any {
					cap drop `p'`x'`s'
				}
			} 
			else if "`x'" != "vapen"  {
				foreach s in any amt per jan feb mar apr may jun jul aug sep oct nov dec {
					cap drop `p'`x'`s'
				}
			}
			else if "`x'" == "vapen" {
				foreach s in 1any 2any 3any amt per jan feb mar apr may jun jul aug sep oct nov dec  {
					cap drop `p'`x'`s'
				}		
			}
	
		}
	}	

	sum
		
	save "$temp_dir/psid_fam`yr'er_select_rcd", replace
}
