clear all
set more off
set maxvar 10000

**************************************************
*Title: H_ELSA_EOL_long
*Summary: converts data from the ELSA to create the Harmonized ELSA EOL
*Version: Version A.2 (2004-2013)
*Authors: Jenny Wilkens, Drystan Phillips, Jennifer Ailshire, & Jinkook Lee
*Date Published: July 2021
**************************************************

***define folder locations***
local stataraw "/home/luke/Documents/E_FEM_clean/ELSA/UKDA_5050_stata_EOL_data"
local output "/home/luke/Documents/E_FEM_clean/E_FEM/input_data/"

***define raw files***
global index "`stataraw'/index_file_wave_0-wave_5_v2.dta"
global wave_2_xt "`stataraw'/elsa_eol_w2_archive_v1.dta"
global wave_3_xt "`stataraw'/elsa_eol_w3_archive_v1.dta"
global wave_4_xt "`stataraw'/elsa_eol_w4_archive_v1.dta"
global wave_6_xt "`stataraw'/elsa_endoflife_w6archive.dta"
global h_elsa "`stataraw'/H_ELSA_g2.dta"

***define programs***
*create special missing codes

***missing_w0
***this is a program that creates special missing codes for wave 1 variables
***
*** the program is called as follows
***		missing_w1 varlist, result(result)
***			where:
***				varlist - list of variables which should influence missing codes
***				result 	- name of variable, must be generated before program
***				[if] and [in] allow limitation of the program to a subsample using an if or in statement, both are optional
capture program drop missing_w0
program define missing_w0
syntax varlist [if] [in], result(varname)

marksample touse, novarlist // process if and in statements

quietly {
	foreach v of varlist `varlist' {
		replace `result' = .m if `v' == -1 & !inlist(`result',.d,.r) & (`touse') // this is the lowest category
		}
	foreach v of varlist `varlist' {
		replace `result' = .d if `v' == -8 & `result'!=.r & (`touse')
		}
	foreach v of varlist `varlist' {
		replace `result' = .r if `v' == -9 & (`touse')
		}
	}
end

***missing_w1
***this is a program that creates special missing codes for wave 1 variables
***
*** the program is called as follows
***		missing_w1 varlist, result(result)
***			where:
***				varlist - list of variables which should influence missing codes
***				result 	- name of variable, must be generated before program
***				[if] and [in] allow limitation of the program to a subsample using an if or in statement, both are optional
capture program drop missing_w1
program define missing_w1
syntax varlist [if] [in], result(varname)

marksample touse, novarlist // process if and in statements

quietly {
	foreach v of varlist `varlist' {
		replace `result' = .m if `v' == -1 & !inlist(`result',.d,.r)  & (`touse') // this is the lowest category
		}
	foreach v of varlist `varlist' {
		replace `result' = .d if `v' == -8 & `result'!=.r & (`touse')
		}
	foreach v of varlist `varlist' {
		replace `result' = .r if `v' == -9 & (`touse')
		}
	}
end

***missing_w2
***this is a program that creates special missing codes for wave 2 variables
***
*** the program is called as follows
***		missing_w2 varlist, result(result)
***			where:
***				varlist - list of variables which should influence missing codes
***				result 	- name of variable, must be generated before program
***				[if] and [in] allow limitation of the program to a subsample using an if or in statement, both are optional
capture program drop missing_w2
program define missing_w2
syntax varlist [if] [in], result(varname)

marksample touse, novarlist // process if and in statements

quietly {
	foreach v of varlist `varlist' {
		replace `result' = .m if (`v' == -1 | `v'==.m) & !inlist(`result',.d,.r)  & (`touse') // this is the lowest category
		}
	foreach v of varlist `varlist' {
		replace `result' = .d if (`v' == -8 | `v' == 96 | `v'==.d) & `result'!=.r & (`touse')
		}
	foreach v of varlist `varlist' {
		replace `result' = .r if (`v' == -9 | `v'==.r) & (`touse')
		}
	}
end

***missing_w3
***this is a program that creates special missing codes for wave 3 variables
***
*** the program is called as follows
***		missing_w3 varlist, result(result)
***			where:
***				varlist - list of variables which should influence missing codes
***				result 	- name of variable, must be generated before program
***				[if] and [in] allow limitation of the program to a subsample using an if or in statement, both are optional
capture program drop missing_w3
program define missing_w3
syntax varlist [if] [in], result(varname)

marksample touse, novarlist // process if and in statements

quietly {
	foreach v of varlist `varlist' {
		replace `result' = .m if (`v' == -1 | `v' == -2 | `v'==.m) & !inlist(`result',.d,.r)  & (`touse') // this is the lowest category
		}
	foreach v of varlist `varlist' {
		replace `result' = .d if (`v' == -8 | `v'==.d) & `result'!=.r & (`touse')
		}
	foreach v of varlist `varlist' {
		replace `result' = .r if (`v' == -9 | `v'==.r) & (`touse')
		}
	}
end

***missing_w4
***this is a program that creates special missing codes for wave 4 variables
***
*** the program is called as follows
***		missing_w4 varlist, result(result)
***			where:
***				varlist - list of variables which should influence missing codes
***				result 	- name of variable, must be generated before program
***				[if] and [in] allow limitation of the program to a subsample using an if or in statement, both are optional
capture program drop missing_w4
program define missing_w4
syntax varlist [if] [in], result(varname)

marksample touse, novarlist // process if and in statements

quietly {
	foreach v of varlist `varlist' {
		replace `result' = .m if (`v' == -1 | `v' == -2 | `v'==.m) & !inlist(`result',.d,.r)  & (`touse') // this is the lowest category
		}
	foreach v of varlist `varlist' {
		replace `result' = .d if (`v' == -8 | `v'==.d) & `result'!=.r & (`touse')
		}
	foreach v of varlist `varlist' {
		replace `result' = .r if (`v' == -9 | `v'==.r) & (`touse')
		}
	}
end

***missing_w5
***this is a program that creates special missing codes for wave 5 variables
***
*** the program is called as follows
***		missing_w5 varlist, result(result)
***			where:
***				varlist - list of variables which should influence missing codes
***				result 	- name of variable, must be generated before program
***				[if] and [in] allow limitation of the program to a subsample using an if or in statement, both are optional
capture program drop missing_w5
program define missing_w5
syntax varlist [if] [in], result(varname)

marksample touse, novarlist // process if and in statements

quietly {
	foreach v of varlist `varlist' {
		replace `result' = .m if (`v' == -1 | `v' == -2 | `v'==.m) & !inlist(`result',.d,.r)  & (`touse') // this is the lowest category
		}
	foreach v of varlist `varlist' {
		replace `result' = .d if (`v' == -8 | `v'==.d) & `result'!=.r & (`touse')
		}
	foreach v of varlist `varlist' {
		replace `result' = .r if (`v' == -9 | `v'==.r) & (`touse')
		}
	}
end

***missing_w6
***this is a program that creates special missing codes for wave 6 variables
***
*** the program is called as follows
***		missing_w6 varlist, result(result)
***			where:
***				varlist - list of variables which should influence missing codes
***				result 	- name of variable, must be generated before program
***				[if] and [in] allow limitation of the program to a subsample using an if or in statement, both are optional
capture program drop missing_w6
program define missing_w6
syntax varlist [if] [in], result(varname)

marksample touse, novarlist // process if and in statements

quietly {
	foreach v of varlist `varlist' {
		replace `result' = .m if (`v' == -1 | `v' == -2 | `v'==.m) & !inlist(`result',.d,.r)  & (`touse') // this is the lowest category
		}
	foreach v of varlist `varlist' {
		replace `result' = .d if (`v' == -8 | `v'==.d) & `result'!=.r & (`touse')
		}
	foreach v of varlist `varlist' {
		replace `result' = .r if (`v' == -9 | `v'==.r) & (`touse')
		}
	}
end

***missing_w7
***this is a program that creates special missing codes for wave 7 variables
***
*** the program is called as follows
***		missing_w7 varlist, result(result)
***			where:
***				varlist - list of variables which should influence missing codes
***				result 	- name of variable, must be generated before program
***				[if] and [in] allow limitation of the program to a subsample using an if or in statement, both are optional
capture program drop missing_w7
program define missing_w7
syntax varlist [if] [in], result(varname)

marksample touse, novarlist // process if and in statements

quietly {
	foreach v of varlist `varlist' {
		replace `result' = .m if (`v' == -1 | `v' == -2 | `v'==.m) & !inlist(`result',.d,.r)  & (`touse') // this is the lowest category
		}
	foreach v of varlist `varlist' {
		replace `result' = .d if (`v' == -8 | `v'==.d) & `result'!=.r & (`touse')
		}
	foreach v of varlist `varlist' {
		replace `result' = .r if (`v' == -9 | `v'==.r) & (`touse')
		}
	}
end

***missing_H
***this is a program that creates special missing codes for RAND Harmonized variables
***
*** the program is called as follows
***		missing_H varlist, result(result)
***			where:
***				varlist - list of variables which should influence missing codes
***				result 	- name of harmonized variable, must be generated before program
***				[if] and [in] allow limitation of the program to a subsample using an if or in statement, both are optional
capture program drop missing_H
program define missing_H
syntax varlist [if] [in], result(varname)

marksample touse, novarlist // process if and in statements

quietly {
	foreach v of varlist `varlist' {
		replace `result' = .m if `v' == .m & !inlist(`result',.d,.r)  & (`touse') // this is the lowest category
	}
	foreach v of varlist `varlist' {
		replace `result' = .d if `v' == .d & `result'!=.r & (`touse')
	}
	foreach v of varlist `varlist' {
		replace `result' = .r if `v' == .r & (`touse')
	}
}
end


*impute missing values
capture program drop elsa_eol_impute
program define elsa_eol_impute, sort
syntax varname [if] [in], [entry_var(varname) min_var(varname) max_var(varname) list extralistvars(varlist)]
    marksample touse, novarlist 
    
    qui gen `varlist'_i = .
    qui gen `varlist'_i_f = .
    qui gen `varlist'_i_neighbor = .
    
   *specify independent imputation groups
    local sepby
    
    *specify covariates    
    local indepvars ragender radagecat_i inw?xt

    *set min and max options
    if "`min_var'" != "" {
        local minopt min(`min_var') 
    }
    
    if  "`max_var'" != "" {
        local maxopt max(`max_var') 
    }
    
    local opteratoropt min_operator(>) max_operator(<)

    tempvar group
    if "`sepby'" != "" {
        qui egen `group' = group(`sepby'), label
    }
    else {
        qui gen `group' = 1
    }     
    
    qui sum `group'
    forvalues g = 1 / `r(max)' {
            
        if "`sepby'" != "" {
            local groupname : label (`group') `g'
            di as result "**Imputing for: `groupname'"
        }
    
        if "`entry_var'" != "" {
            elsa_entry_check `varlist', entryvar(`entry_var') `extralistvars' `minopt' `maxopt'
            
            di as result "*Assigning reported values when there is ownership"
            replace `varlist'_i = `varlist' if `touse' & `group' == `g' & `entry_var' == 1 & !mi(`varlist') & mi(`varlist'_i) 
            qui replace `varlist'_i_f = 1 if `touse' & `group' == `g' & `entry_var' == 1 & !mi(`varlist') & mi(`varlist'_i_f)
            di
            
            di as result "*Assigning 0 values when there is no ownership"
            replace `varlist'_i = 0 if `touse' & `group' == `g' & `entry_var' == 0 & mi(`varlist'_i) 
            qui replace `varlist'_i_f = 6 if `touse' & `group' == `g' & `entry_var' == 0 & mi(`varlist'_i_f)
            di
            
            qui count if `touse' & `group' == `g' & !mi(`varlist'_i)
            if `r(N)' >= 2 {
                *Estimate model
                local indepvarspec
            	foreach var of varlist `indepvars' {
            	    qui distinct `var'
            	    if `r(ndistinct)' > 2 {
            	        local indepvarspec `indepvarspec' i.`var'
            	    }
            	    else {
            	        local indepvarspec `indepvarspec' `var'
            	    }
            	}
                
                tempvar asinh prediction
                qui gen `asinh' = asinh(`varlist'_i) if `touse' & `group' == `g'
                qui regress `asinh' `indepvarspec' if `touse' & `group' == `g'
                qui predict `prediction' if `touse' & `group' == `g', xb
                
                di as result "*Imputing when ownership is known"
                *di `"imputation_mixed `varlist' if `touse' & `group' == `g' & `entry_var' == 1, harmonized(`varlist'_i) closeness(`prediction') id(idauniq) `maxopt' `opteratoropt' `minopt' exclude_flags(-1,2,3,5,6,7) `list' extralistvars(`indepvars' `extralistvars' `entry_var')"'
                imputation_mixed `varlist' if `touse' & `group' == `g' & `entry_var' == 1, harmonized(`varlist'_i) closeness(`prediction') id(idauniq) ///
                                    sort(idauniq) `maxopt' `opteratoropt' `minopt' exclude_flags(-1,2,3,5,6,7) `list' extralistvars(`indepvars' `extralistvars' `entry_var')
                
                di as result "*Imputing when ownership is unknown"
                *di `"imputation_mixed `varlist' if `touse' & `group' == `g' & mi(`entry_var'), harmonized(`varlist'_i) closeness(`prediction') id(idauniq) exclude_flags(-1,2,3,5,7) `list' extralistvars(`indepvars' `extralistvars') dknow"'
                imputation_mixed `varlist' if `touse' & `group' == `g', harmonized(`varlist'_i) closeness(`prediction') id(idauniq) ///
                                    sort(idauniq) exclude_flags(-1,2,3,5,7) `list' extralistvars(`indepvars' `extralistvars' `entry_var') dknow
            }
            else {
                di as error "The following observations with ownership need imputation but there is not more than one observations without missing values"
                list idauniq `entry_var' `varlist' `min_var' `max_var' if `touse' & `group' == `g' & mi(`varlist'_i), noobs
                qui replace `varlist'_i_f = -1 if `touse' & `group' == `g' & mi(`varlist'_i) & mi(`varlist'_i_f)
                di
            }                 
        }
        else {
             di as result "*Assigning reported values"
            replace `varlist'_i = `varlist' if `touse' & `group' == `g' & !mi(`varlist') & mi(`varlist'_i) 
            qui replace `varlist'_i_f = 1 if `touse' & `group' == `g' & !mi(`varlist') & mi(`varlist'_i_f)
            
            qui count if `touse' & `group' == `g' & !mi(`varlist'_i)
            if `r(N)' >= 2 {
                *Estimate model
                local indepvarspec
            	foreach var of varlist `indepvars' {
            	    qui distinct `var'
            	    if `r(ndistinct)' > 2 {
            	        local indepvarspec `indepvarspec' i.`var'
            	    }
            	    else {
            	        local indepvarspec `indepvarspec' `var'
            	    }
            	}
                
                tempvar asinh prediction
                qui gen `asinh' = asinh(`varlist'_i) if `touse' & `group' == `g'
                qui regress `asinh' `indepvarspec' if `touse' & `group' == `g'
                qui predict `prediction' if `touse' & `group' == `g', xb
                
                di as result "*Imputing"
                imputation_mixed `varlist' if `touse' & `group' == `g', harmonized(`varlist'_i) closeness(`prediction') id(idauniq) /// 
                                   sort(idauniq) `maxopt' `minopt' `opteratoropt' exclude_flags(-1,2,3,5,7) `list' extralistvars(`indepvars' `extralistvars')
            }
            else {
                di as error "The following observations with ownership need imputation but there is not more than one observations without missing values"
                list idauniq `varlist' `min_var' `max_var' if `touse' & `group' == `g' & mi(`varlist'_i), noobs
                qui replace `varlist'_i_f = -1 if `touse' & `group' == `g' & mi(`varlist'_i) & mi(`varlist'_i_f)
                di
            }                   
        }
    }
    local anymiss
    local or
    foreach var of varlist `indepvars' {
        local anymiss `anymiss' `or' mi(`var')
        local or |
    }
    qui replace `varlist'_i_f = -2 if `touse' & mi(`varlist'_i) & mi(`varlist'_i_f) & (`anymiss')
    
    imputation_summary_table `varlist'_i if `touse', `maxopt' `minopt' `opteratoropt'
    di
    
end
     capture program drop imputation_mixed
program define imputation_mixed, sort
syntax varname [if] [in], harmonized(varname) closeness(varname) id(varname) [min(varname) max(varname) min_operator(string) max_operator(string) ///
                          exclude_flags(string) outlier(passthru) noSeed list extralistvars(varlist) sort(varname) randsort dknow ]
	marksample touse, novarlist 
	
	if "`exclude_flags'" != "" {
	    local exclude_opt exclude_flags(`exclude_flags')
	    local exclude_cond & !inlist(`harmonized'_f,`exclude_flags')
	}
	else {
	    local exclude_opt
	    local exclude_cond
	}
	if "`extralistvars'" == "" {
	    local extralistvarsopt
	}
	else {
	    local extralistvarsopt extralistvars(`extralistvars')
	}	
	
	capture drop cell
    qui count if `touse' `exclude_cond' & mi(`harmonized')
    if `r(N)' > 0 {
        
        if "`seed'" == "" {
    	     set seed 123456789
        }
        	
        if "`sort'" != "" {
    	    local sort_option sort(`sort')
    	}
    	else if "`randsort'" == "randsort" {
    	    tempvar rand_sort
    	    qui gen `rand_sort' =  runiform()
    	    local sort_option sort(`rand_sort')
    	}
            
        if "`min'" != "" | "`max'" != "" {
        	qui egen cell = group(`min' `max') if `touse' `exclude_cond' & mi(`harmonized'), missing
            
        	sum cell, meanonly
        	forvalues i = 1/`r(max)' {
        	    if "`min'" != "" {
            		su `min' if cell == `i', meanonly
            		local bracket_min = r(mean)
            	}
            	else {
            	    local bracket_min = .
            	}
            	if "`max'" != "" {
            		su `max' if cell == `i', meanonly    
            		local bracket_max = r(mean)
            	}
            	else {
            	    local bracket_max = .
            	}
        		di as result "Reported min=`bracket_min' max=`bracket_max'"
        		
        		if "`bracket_min'" != "." {
        			if "`bracket_max'" != "." { // *max and min given
        			    if `bracket_min' == `bracket_max' {
        			        qui count if cell == `i' & `touse'
                            di as result "Number of observations with this about value:`r(N)'"
            			    replace `harmonized' = `min' if cell == `i' & `touse'
        				    qui replace `harmonized'_f = 2 if cell == `i' & `touse'
        				}
        				else {
        				    impute_mixed `harmonized' if `touse', closeness(`closeness') min(`bracket_min') min_operator(`min_operator') max(`bracket_max') max_operator(`max_operator') ///
        					imput_flag(`harmonized'_f) neighbor_flag(`harmonized'_neighbor) flag_value(2) cell(`i') `exclude_opt' `outlier' `list' `extralistvarsopt' `sort_option' id(`id')
        				}
        			}
        			else { // * only min given
        			    impute_mixed `harmonized' if `touse', closeness(`closeness') min(`bracket_min') min_operator(`min_operator') ///
    						imput_flag(`harmonized'_f) neighbor_flag(`harmonized'_neighbor) flag_value(3) cell(`i') `exclude_opt' `outlier' `list' `extralistvarsopt' `sort_option' id(`id')
        			}
        		}
        		else {
        			if "`bracket_max'" != "." { // * only max given
    					impute_mixed `harmonized' if `touse', closeness(`closeness') max(`bracket_max') max_operator(`max_operator') ///
    						imput_flag(`harmonized'_f) neighbor_flag(`harmonized'_neighbor) flag_value(2) cell(`i') `exclude_opt' `outlier' `list' `extralistvarsopt' `sort_option' id(`id')
        			}
        			else { // * neither max or min given
        			    if "`dknow'" == "" {
            				impute_mixed `harmonized' if `touse', closeness(`closeness') ///
            					imput_flag(`harmonized'_f) neighbor_flag(`harmonized'_neighbor) flag_value(5) cell(`i') `exclude_opt' `outlier' `list' `extralistvarsopt' `sort_option' id(`id')
            				}
            				else {
            				  impute_mixed `harmonized' if `touse', closeness(`closeness') ///
            					imput_flag(`harmonized'_f) neighbor_flag(`harmonized'_neighbor) flag_value(7) cell(`i') `exclude_opt' `outlier' `list' `extralistvarsopt' `sort_option' id(`id')  
            				}
        			}
        		}
        		
        		if "`list'" != "" {
        		    di as result "Imputed cases:"
            		list `id' `extralistvars' `closeness' `varlist' `min' `max' `harmonized' `harmonized'_f `harmonized'_neighbor if cell == `i' & `touse' & !mi(`harmonized'), noobs
            	}
            	di
        	}
            drop cell 
        }
        else {
            qui gen cell = 1 if  `touse' `exclude_cond' & mi(`harmonized')
            if "`dknow'" == "" {
                impute_mixed `harmonized' if `touse', closeness(`closeness') ///
        						   imput_flag(`harmonized'_f) neighbor_flag(`harmonized'_neighbor) flag_value(5) cell(1) `exclude_opt' `outlier' `list' `extralistvarsopt' `sort_option' id(`id')
        	}
        	else {
        	    impute_mixed `harmonized' if `touse', closeness(`closeness') ///
        						   imput_flag(`harmonized'_f) neighbor_flag(`harmonized'_neighbor) flag_value(7) cell(1) `exclude_opt' `outlier' `list' `extralistvarsopt' `sort_option' id(`id')
        	}
    	    if "`list'" != "" {
    	        di as result "Imputed cases:"
        		list `id' `extralistvars' `closeness' `varlist' `harmonized' `harmonized'_f `harmonized'_neighbor if cell == 1 & `touse' & !mi(`harmonized'), noobs
        	}
        	di
            drop cell
        }
        
        qui count if mi(`harmonized') & `touse' `exclude_cond'
    	if r(N) > 0 {
    		di as error "Imputed values were not assinged in the following `r(N)' cases:"
    		list `id' `varlist' `min' `max' `extralistvars' `harmonized' `harmonized'_f if ///
    				mi(`varlist') & mi(`harmonized') &  `touse' `exclude_cond', noobs
    		di		
    	}
    }
    else {
        di as text "no observations have missing values"
        di
    }
	
	
    
end

    capture program drop impute_mixed
program define impute_mixed, sort
syntax varname [if] [in],  closeness(varname) imput_flag(varname) neighbor_flag(varname) flag_value(integer) cell(integer) id(varname) ///
        [min(real 9999.999) max(real 9999.999) min_operator(string) max_operator(string) exclude_flags(string) outlier(real 100) list extralistvars(varlist) sort(varname)]

	marksample touse, novarlist
	
	capture drop hot
	capture drop `varlist'_i
	capture drop lower_n_value
	capture drop lower_n_closeness
	capture drop lower_n_id
	capture drop upper_n_value
	capture drop upper_n_closeness
	capture drop upper_n_id
	
	if `outlier' != 100 {
        _pctile `varlist', p(`outlier')
        local outlier_restric & `varlist' <= `r(r1)'
    }
	
	if `min' != 9999.999 {
	    *di as result "use min=`min'"
	    if `max' != 9999.999 {
	        *di as result "use max=`max'"
	        local hotcondition cell == `cell' | (`varlist' `min_operator' `min' & `varlist' `max_operator' `max' `outlier_restric')
	    }
	    else {
	        local hotcondition cell == `cell' | (`varlist' `min_operator' `min' & !mi(`varlist') `outlier_restric')
	    }
	}
	else {
	    if `max' != 9999.999 {
	        *di as result "use max=`max'"
	        local hotcondition cell == `cell' | (`varlist' `max_operator' `max' & !mi(`varlist') `outlier_restric')
	    }
	    else {
	        local hotcondition cell == `cell' | (!mi(`varlist') `outlier_restric')
	    }
	}
	
	if "`exclude_flags'" != "" {
	    local exclude_cond & !inlist(`imput_flag',`exclude_flags')
	}
	else {
	    local exclude_cond
	}
	
	qui gen hot = 1 if `touse' & (`hotcondition') `exclude_cond'
	
	qui count if hot == 1 & !mi(`varlist')
	local num_not_miss = r(N) 
	qui count if hot == 1 & mi(`varlist')
	local num_miss = r(N)
	di as res  "Number of observations without missing values:" `num_not_miss'
	di as res  "Number of observations with    missing values:" `num_miss' 
	if `num_miss' == 0 {
	    list `id' `extralistvars' `varlist' hot if cell == `cell'
	}
	
	if `num_miss' > 0 {
	    	if `num_not_miss' < 2 {
    		if `min' != 9999.999 {
        	    if `max' != 9999.999 {
        	        qui gen double `varlist'_i = .
        	        di as error "The following observations need imputation but there is not more than one observation with a value between the minimum and the maximum:"
        	        list `id' if hot == 1 & mi(`varlist'), noobs
        	        qui replace `imput_flag' = -1 if hot == 1 & mi(`varlist')
        	    }
        	    else {
        	        qui gen double `varlist'_i = .
        	        di as error "The following observations need imputation but there is not more than one observation with a value above the minimum:"
        	        list `id' if hot == 1 & mi(`varlist'), noobs
        	        qui replace `imput_flag' = -1 if hot == 1 & mi(`varlist')
        	    }
        	}
        	else {
        	    if `max' != 9999.999 {
        	        qui gen double `varlist'_i = .
        	        di as error "The following observations need imputation but there is not more than one observation below their maximum:"
        	        list `id' if hot == 1 & mi(`varlist'), noobs
        	        qui replace `imput_flag' = -1 if hot == 1 & mi(`varlist')
        	        di
        	    }
        	    else {
        	        qui gen double `varlist'_i = .
        	        di as error "The following observations need imputation but there is not more than one observation with a non-missing value:"
        	        list `id' if hot == 1 & mi(`varlist'), noobs
        	        qui replace `imput_flag' = -1 if hot == 1 & mi(`varlist')
        	        di
        	    }
        	}
        	qui replace `imput_flag' = `flag_value' if mi(`varlist') & !mi(`varlist'_i) 
    		drop `varlist'_i
    	}
	    else if `num_not_miss' < 50 {
	        di as text "There are fewer than 50 observations with reported values, covariates will not be used for this group."
	        sort hot `sort'
    		
    		qui gen lower_n_value = .
    		qui gen lower_n_id = .
    		
    		qui gen upper_n_value = .
    		qui gen upper_n_id = .
    		
    		local idformat : format `id'
    		format `idformat' lower_n_id upper_n_id `neighbor_flag'
    		
    		tempvar obs
    		gen `obs' = _n
    		qui sum `obs' if hot == 1 & !mi(`varlist')
    		local first = `r(min)'
    		local last = `r(max)'
   	
    		qui count if hot == 1
    		forvalues n = 1 / `r(N)' {
        		qui replace lower_n_value = `varlist'[_n-`n'] if !mi(`varlist'[_n-`n']) & hot[_n-`n'] == 1 & mi(lower_n_value) & hot == 1 & mi(`varlist')
        		qui replace lower_n_id = `id'[_n-`n'] if !mi(`varlist'[_n-`n']) & hot[_n-`n'] == 1 & mi(lower_n_id) & hot == 1 & mi(`varlist')
        		
        		qui replace upper_n_value = `varlist'[_n+`n'] if !mi(`varlist'[_n+`n']) & hot[_n+`n'] == 1 & mi(upper_n_value) & hot == 1 & mi(`varlist')
        		qui replace upper_n_id = `id'[_n+`n'] if !mi(`varlist'[_n+`n']) & hot[_n+`n'] == 1 & mi(upper_n_id) & hot == 1 & mi(`varlist')
        		
        		qui count if mi(lower_n_value) & hot == 1 & mi(`varlist') & _n > `first'
        		if r(N) == 0 {
        		    qui count if mi(upper_n_value) & hot == 1 & mi(`varlist') & _n < `last'
        		    if r(N) == 0 {
        		        continue, break
        		    }
        		}
        	}
    		
    		qui gen `varlist'_i = .
    		tempvar rand
    		qui gen `rand' =  floor((2)*runiform()) if hot == 1
    		qui replace `varlist'_i = lower_n_value if `rand' == 0 & !mi(lower_n_value) & !mi(upper_n_value) & mi(`varlist')
    		qui replace `varlist'_i = upper_n_value if `rand' == 1 & !mi(lower_n_value) & !mi(upper_n_value) & mi(`varlist')
    		qui replace `varlist'_i = lower_n_value if !mi(lower_n_value) & mi(upper_n_value) & mi(`varlist')
    		qui replace `varlist'_i = upper_n_value if mi(lower_n_value) & !mi(upper_n_value) & mi(`varlist')
    		
    		qui replace `neighbor_flag' = lower_n_id if `rand' == 0 & !mi(lower_n_value) & !mi(upper_n_value) & mi(`varlist')
    		qui replace `neighbor_flag' = upper_n_id if `rand' == 1 & !mi(lower_n_value) & !mi(upper_n_value) & mi(`varlist')
    		qui replace `neighbor_flag' = lower_n_id if !mi(lower_n_value) & mi(upper_n_value) & mi(`varlist')
    		qui replace `neighbor_flag' = upper_n_id if mi(lower_n_value) & !mi(upper_n_value) & mi(`varlist')
    		
    		qui replace `imput_flag' = `flag_value' if mi(`varlist') & !mi(`varlist'_i)
    		
    		if "`list'" == "list" {
    		    tempvar print
    		    qui egen `print' = seq() if hot == 1
    		    qui sum `print' if cell == `cell'
    		    if `r(N)' > 1 {
        		    local low_print_low = r(min) - 3
        		    local high_print_low = r(min) + 3 
        		    local low_print_high = r(max) - 3
        		    local high_print_high = r(max) + 3 
        		    di as result "Example Assignments:"
        		    list `id' `extralistvars' `varlist' lower_n_id lower_n_value upper_n_id upper_n_value if `print' >= `low_print_low' & `print' <= `high_print_low' , noobs sep(7)
                    list `id' `extralistvars' `varlist' lower_n_id lower_n_value upper_n_id upper_n_value if `print' >= `low_print_high' & `print' <= `high_print_high' , noobs sep(7)
                }
                else {
                    local low_print_low = r(min) - 3
        		    local high_print_low = r(min) + 3 
        		    di as result "Assignment:"
        		    list `id' `extralistvars' `varlist' lower_n_id lower_n_value upper_n_id upper_n_value if `print' >= `low_print_low' & `print' <= `high_print_low' , noobs sep(7)
                }
    		}
    		
    		replace `varlist' = `varlist'_i if mi(`varlist') & !mi(`varlist'_i)
    		
    		drop `varlist'_i
    		drop lower_n_value
        	drop lower_n_id
        	drop upper_n_value
        	drop upper_n_id
	    }
	    else {
    		sort hot `closeness' `sort'
    		
    		qui gen lower_n_value = .
    		qui gen lower_n_closeness = .
    		qui gen lower_n_id = .
    		
    		qui gen upper_n_value = .
    		qui gen upper_n_closeness = .
    		qui gen upper_n_id = .
    		
    		local idformat : format `id'
    		format `idformat' lower_n_id upper_n_id `neighbor_flag'
    		
    		tempvar obs
    		gen `obs' = _n
    		qui sum `obs' if hot == 1 & !mi(`closeness') & !mi(`varlist')
    		local first = `r(min)'
    		local last = `r(max)'
   	
    		qui count if hot == 1 & !mi(`closeness')
    		forvalues n = 1 / `r(N)' {
        		qui replace lower_n_value = `varlist'[_n-`n'] if !mi(`varlist'[_n-`n']) & hot[_n-`n'] == 1 & mi(lower_n_value) & hot == 1 & !mi(`closeness') & mi(`varlist')
        		qui replace lower_n_closeness = abs(`closeness'- `closeness'[_n-`n']) if !mi(`varlist'[_n-`n']) & hot[_n-`n'] == 1 & mi(lower_n_closeness) & hot == 1 & !mi(`closeness') & mi(`varlist')
        		qui replace lower_n_id = `id'[_n-`n'] if !mi(`varlist'[_n-`n']) & hot[_n-`n'] == 1 & mi(lower_n_id) & hot == 1 & !mi(`closeness') & mi(`varlist')
        		
        		qui replace upper_n_value = `varlist'[_n+`n'] if !mi(`varlist'[_n+`n']) & hot[_n+`n'] == 1 & mi(upper_n_value) & hot == 1 & !mi(`closeness') & mi(`varlist')
        		qui replace upper_n_closeness = abs(`closeness' - `closeness'[_n+`n']) if !mi(`varlist'[_n+`n']) & hot[_n+`n'] == 1 & mi(upper_n_closeness) & hot == 1 & !mi(`closeness') & mi(`varlist')
        		qui replace upper_n_id = `id'[_n+`n'] if !mi(`varlist'[_n+`n']) & hot[_n+`n'] == 1 & mi(upper_n_id) & hot == 1 & !mi(`closeness') & mi(`varlist')
        		
*        		if `n' > 4 {
*        		    di "first:`first'"
*        		    di "last:`last'"
*        		    list `id' `closeness' `varlist' lower_n_id lower_n_value upper_n_id upper_n_value if hot==1
*        		    di
*        		}
        		
        		qui count if mi(lower_n_value) & hot == 1 & !mi(`closeness') & mi(`varlist') & _n > `first' 
        		if r(N) == 0 {
        		    qui count if mi(upper_n_value) & hot == 1 & !mi(`closeness') & mi(`varlist') & _n < `last' 
        		    if r(N) == 0 {
        		        continue, break
        		    }
        		}
        	}
    		
    		qui gen `varlist'_i = .
    		tempvar rand
    		qui gen `rand' =  floor((2)*runiform()) if hot == 1
    		qui replace `varlist'_i = lower_n_value if lower_n_closeness < upper_n_closeness & !mi(lower_n_closeness) & !mi(upper_n_closeness) & mi(`varlist')
    		qui replace `varlist'_i = upper_n_value if upper_n_closeness < lower_n_closeness & !mi(lower_n_closeness) & !mi(upper_n_closeness) & mi(`varlist')
    		qui replace `varlist'_i = lower_n_value if lower_n_closeness == upper_n_closeness & `rand' == 0 & !mi(lower_n_closeness) & !mi(upper_n_closeness) & mi(`varlist')
    		qui replace `varlist'_i = upper_n_value if upper_n_closeness == lower_n_closeness & `rand' == 1 & !mi(lower_n_closeness) & !mi(upper_n_closeness) & mi(`varlist')
    		qui replace `varlist'_i = lower_n_value if !mi(lower_n_closeness) & mi(upper_n_closeness) & mi(`varlist')
    		qui replace `varlist'_i = upper_n_value if mi(lower_n_closeness) & !mi(upper_n_closeness) & mi(`varlist')
    		
    		qui replace `neighbor_flag' = lower_n_id if lower_n_closeness < upper_n_closeness & !mi(lower_n_closeness) & !mi(upper_n_closeness) & mi(`varlist')
    		qui replace `neighbor_flag' = upper_n_id if upper_n_closeness < lower_n_closeness & !mi(lower_n_closeness) & !mi(upper_n_closeness) & mi(`varlist')
    		qui replace `neighbor_flag' = lower_n_id if lower_n_closeness == upper_n_closeness & `rand' == 0 & !mi(lower_n_closeness) & !mi(upper_n_closeness) & mi(`varlist')
    		qui replace `neighbor_flag' = upper_n_id if upper_n_closeness == lower_n_closeness & `rand' == 1 & !mi(lower_n_closeness) & !mi(upper_n_closeness) & mi(`varlist')
    		qui replace `neighbor_flag' = lower_n_id if !mi(lower_n_closeness) & mi(upper_n_closeness) & mi(`varlist')
    		qui replace `neighbor_flag' = upper_n_id if mi(lower_n_closeness) & !mi(upper_n_closeness) & mi(`varlist')	
    		
    		qui replace `imput_flag' = `flag_value' if mi(`varlist') & !mi(`varlist'_i)
    		
    		if "`list'" == "list" {
    		    tempvar print
    		    qui egen `print' = seq() if hot == 1
    		    qui sum `print' if cell == `cell'
    		    if `r(N)' > 1 {
        		    local low_print_low = r(min) - 3
        		    local high_print_low = r(min) + 3 
        		    local low_print_high = r(max) - 3
        		    local high_print_high = r(max) + 3 
        		    di as result "Example Assignments:"
        		    list `id' `extralistvars' `closeness' `varlist' lower_n_id lower_n_value lower_n_closeness upper_n_id upper_n_value upper_n_closeness if `print' >= `low_print_low' & `print' <= `high_print_low' , noobs sep(7)
                    list `id' `extralistvars' `closeness' `varlist' lower_n_id lower_n_value lower_n_closeness upper_n_id upper_n_value upper_n_closeness if `print' >= `low_print_high' & `print' <= `high_print_high' , noobs sep(7)
                }
                else {
                    local low_print_low = r(min) - 3
        		    local high_print_low = r(min) + 3 
        		    di as result "Assignment:"
        		    list `id' `extralistvars' `closeness' `varlist' lower_n_id lower_n_value lower_n_closeness upper_n_id upper_n_value upper_n_closeness if `print' >= `low_print_low' & `print' <= `high_print_low' , noobs sep(7)
                }
    		}
    		
    		replace `varlist' = `varlist'_i if mi(`varlist') & !mi(`varlist'_i)
    		
    		drop `varlist'_i
    		drop lower_n_value
        	drop lower_n_closeness
        	drop lower_n_id
        	drop upper_n_value
        	drop upper_n_closeness
        	drop upper_n_id
        }
	}
	else {
		di as res  "No missing values for respondents in this cell"
	}
	drop hot
end
capture program drop elsa_entry_check
program define elsa_entry_check
syntax varname [if] [in], entryvar(varname) [extralistvars(varlist) min(varname) max(varname)]
    marksample touse, novarlist 
    if "`min'" != "" {
        local minnotmiss | !mi(`min')
    }
    if "`max'" != "" {
        local maxnotmiss | !mi(`max')
    }
    
    qui count if `entryvar' == 0 & (!mi(`varlist') `minnotmiss' `maxnotmiss') & `touse'
    if  `r(N)' > 0 {
        di
        di as error "Warning: `r(N)' respondents were assigned no ownership for `varlist' but have values"
        list `extralistvars' `entryvar' `varlist' `min' `max' if `entryvar' == 0 & (!mi(`varlist') `minnotmiss' `maxnotmiss') & `touse', noobs
        di
    }
    qui count if mi(`entryvar') & !mi(`varlist') & `touse'
    if  `r(N)' > 0 {
        di
        di as error "Warning: `r(N)' respondents were not assigned an ownership value for `varlist' but have values"
        list `extralistvars' `entryvar' `varlist' `min' `max' if  mi(`entryvar') & (!mi(`varlist')  `minnotmiss' `maxnotmiss') & `touse', noobs
        di
    }
    
end
    capture program drop imputation_summary_table
program define imputation_summary_table
syntax varname [if] [in], [min(varname) max(varname)  min_operator(string) max_operator(string)]
    marksample touse, novarlist 
    
    capture matrix drop B
    capture matrix drop C
    qui count if `varlist'_f == 1 & `touse'
    if `r(N)' > 0 {
        marg_distributions `varlist' if `varlist'_f == 1 & `touse', flag(`varlist'_f)
        matrix B = r(horizontal)
    }
    qui count if `varlist'_f == 6 & `touse'
    if `r(N)' > 0 {
        marg_distributions `varlist' if `varlist'_f == 6 & `touse', flag(`varlist'_f)
        matrix C = r(horizontal)
        local ownership yes 
    }
    else {
        local ownership no
    }
    marg_distributions `varlist' if inlist(`varlist'_f,1,6) & `touse', flag(`varlist'_f)
    matrix D = r(horizontal)
    
    
    capture confirm matrix B
    if !_rc {
        capture confirm matrix C
        if !_rc {
            matrix A = B[1...,8..8],B[1...,1..7] \ C[1...,8..8],C[1...,1..7] \ D[1...,8..8],D[1...,1..7]
            matrix rownames A = "CONTINUOUS" "NO OWNERSHIP" "All reported"
            matlist A, nodotz cspec(& %20s | %10.0fc & %10.1f & %10.1f & %10.2f & %10.1f & %12.1f & %12.1f & %10.1f &) rspec( & - & - - ) title("Reported Values")
        }
        else {
            matrix A = B[1...,8..8],B[1...,1..6]
            matrix rownames A = "CONTINUOUS"
            matlist A, nodotz cspec(& %20s | %10.0fc & %10.1f & %10.1f & %10.2f & %10.1f & %12.1f & %12.1f &) rspec( & - - ) title("Reported Values")
        }
    }
    else {
        capture confirm matrix C
        if !_rc {
            matrix A = C[1...,8..8],C[1...,1..7]
            matrix rownames A = "NO OWNERSHIP"
            matlist A, nodotz cspec(& %20s | %10.0fc & %10.1f & %10.1f & %10.2f & %10.1f & %12.1f & %12.1f & %10.1f &) rspec( & - - ) title("Reported Values")
        }
    }

    capture matrix drop B
    local rspec -
    qui count if `touse' & inlist(`varlist'_f,2,3)
    if `r(N)' > 0 {
        if "`min'" != "" | "`max'" != "" {
            tempvar cell
            qui count if `touse' & `varlist'_f == 2
            if `r(N)' > 0 {
                qui egen `cell' = group(`min' `max') if `touse' & `varlist'_f == 2, missing
                matrix B = [.z,.z,.z,.z,.z,.z,.z,.z]
                matrix rowname B = "CLOSED BRACKETS"
                local rspec `rspec' -
                su `cell', meanonly
            	forvalues i = 1 / `r(max)' {
            		su `min' if `cell' == `i', meanonly
            		local bracket_min = r(mean)
            		su `max' if `cell' == `i', meanonly    
            		local bracket_max = r(mean)
                    if "`bracket_max'" != "." {
            			if "`bracket_min'" == "." {
                            marg_distributions `varlist' if `cell' == `i' & `touse', flag(`varlist'_f)
                            matrix C = r(horizontal)
                            matrix rownames C = "Imputed values"
                            matrix roweq C = "0-`bracket_max'"
                            matrix B = B \ C
                            qui count if `varlist'_f == 1 & `varlist' `max_operator' `bracket_max' & `touse'
                            if `r(N)' > 0 {
                                marg_distributions `varlist' if `varlist'_f == 1 & `varlist' `max_operator' `bracket_max' & `touse', flag(`varlist'_f)
                                matrix C = r(horizontal)
                            }
                            else {
                                matrix C = [.,.,.,.,.,.,.,0]
                            }
                            matrix rownames C = "Donor values"
                            matrix roweq C = "0-`bracket_max'"
                            matrix B = B \ C
                            local rspec `rspec' & &
                        }
                    }
                }
                su `cell', meanonly
                forvalues i = 1 / `r(max)' {
            		su `min' if `cell' == `i', meanonly
            		local bracket_min = r(mean)
            		su `max' if `cell' == `i', meanonly    
            		local bracket_max = r(mean)
                    if "`bracket_max'" != "." {
            			if "`bracket_min'" != "." {
                            marg_distributions `varlist' if `cell' == `i' & `touse', flag(`varlist'_f)
                            matrix C = r(horizontal)
                            matrix rownames C = "Imputed values"
                            matrix roweq C = "`bracket_min'-`bracket_max'"
                            matrix B = B \ C
                            qui count if `varlist'_f == 1 & `varlist' `min_operator' `bracket_min' & `varlist' `max_operator' `bracket_max' & `touse'
                            if `r(N)' > 0 {
                                marg_distributions `varlist' if `varlist'_f == 1 & `varlist' `min_operator' `bracket_min' & `varlist' `max_operator' `bracket_max' & `touse', flag(`varlist'_f)
                                matrix C = r(horizontal)
                            }
                            else {
                                matrix C = [.,.,.,.,.,.,.,0]
                            }
                            matrix rownames C = "Donor values"
                            matrix roweq C = "`bracket_min'-`bracket_max'"
                            matrix B = B \ C
                            local rspec `rspec' & &
                        }
                    }
                }
            }
            qui count if `touse' & `varlist'_f == 3
            if `r(N)' > 0 {
                tempvar cell
                qui egen `cell' = group(`min' `max') if `touse' & `varlist'_f == 3, missing
                matrix C = [.z,.z,.z,.z,.z,.z,.z,.z]
                matrix rowname C = "OPEN BRACKETS"
                local rspec `rspec' -
                capture confirm matrix B
                if !_rc {
                    matrix B = B\C
                }
                else {
                    matrix B = C
                }
                su `cell', meanonly
            	forvalues i = 1/`r(max)' {
            		su `min' if `cell' == `i', meanonly
            		local bracket_min = r(mean)
                    marg_distributions `varlist' if `cell' == `i' & `touse', flag(`varlist'_f)
                    matrix C = r(horizontal)
                    matrix rownames C = "Imputed values"
                    matrix roweq C = "`bracket_min'+"
                    matrix B = B \ C
                    qui count if `varlist'_f == 1 & `varlist' `min_operator' `bracket_min' & `touse'
                    if `r(N)' > 0 {
                        marg_distributions `varlist' if `varlist'_f == 1 & `varlist' `min_operator' `bracket_min' & `touse', flag(`varlist'_f)
                        matrix C = r(horizontal)
                    }
                    else {
                        matrix C = [.,.,.,.,.,.,.,0]
                    }
                    matrix rownames C = "Donor values"
                    matrix roweq C = "`bracket_min'+"
                    matrix B = B \ C
                    local rspec `rspec' & &
                }
            }
        }
    }
    
    qui count if `varlist'_f == 5 & `touse'
    if `r(N)' > 0 {
        matrix C = [.z,.z,.z,.z,.z,.z,.z,.z]
        matrix rowname C = "NO BRACKET/VALUE"
        local rspec `rspec' -
        capture confirm matrix B
        if !_rc {
            matrix B = B\C
        }
        else {
            matrix B = C
        }
        marg_distributions `varlist' if `varlist'_f == 5 & `touse', flag(`varlist'_f)
        matrix C = r(horizontal)
        matrix rownames C = "Imputed values"
        matrix B = B \ C
        marg_distributions `varlist' if `varlist'_f == 1 & `touse', flag(`varlist'_f)
        matrix C = r(horizontal)
        matrix rownames C = "Donor values"
        matrix B = B \ C
        local rspec `rspec' & &
    }
    qui count if `varlist'_f == 7 & `touse'
    if `r(N)' > 0 {
        matrix C = [.z,.z,.z,.z,.z,.z,.z,.z]
        matrix rowname C = "DK"
        local rspec `rspec' -
        capture confirm matrix B
        if !_rc {
            matrix B = B\C
        }
        else {
            matrix B = C
        }
        marg_distributions `varlist' if `varlist'_f == 7 & `touse', flag(`varlist'_f)
        matrix C = r(horizontal)
        matrix rownames C = "Imputed values"
        matrix B = B \ C
        marg_distributions `varlist' if inlist(`varlist'_f,1,6) & `touse', flag(`varlist'_f)
        matrix C = r(horizontal)
        matrix rownames C = "Donor values"
        matrix B = B \ C
        local rspec `rspec' & &
    }
    
    capture confirm matrix B
    if !_rc {
        if "`ownership'" == "yes" {
            matrix A = B[1...,8..8],B[1...,1..7]
            matrix colnames A = n mean sd skewness median min max ownership
            matlist A, nodotz cspec(& %20s | %10.0fc & %10.1f & %10.1f & %10.2f & %10.1f & %12.1f & %12.1f & %10.1f &) rspec( `rspec' - ) title("Imputed Values")
        }
        else {
            matrix A = B[1...,8..8],B[1...,1..6]
            matrix colnames A = n mean sd skewness median min max
            matlist A, nodotz cspec(& %20s | %10.0fc & %10.1f & %10.1f & %10.2f & %10.1f & %12.1f & %12.1f &) rspec( `rspec' - ) title("Imputed Values")
        }
    }
end
    capture program drop marg_distributions
program define marg_distributions, rclass
syntax varname [if] [in], flag(varname)
    marksample touse, novarlist
    
    qui sum `varlist' if `touse',d
    matrix A_ = [`r(mean)' \ `r(sd)' \ `r(skewness)' \ `r(p50)' \ `r(min)' \ `r(max)' ]
    
    qui count if `touse' & (`flag' == 6 | (inlist(`flag',7,9) & `varlist' == 0))
    local num `r(N)'
    qui count if `touse' & !mi(`varlist')
    local den `r(N)'
    local per = ((`den'-`num')/`den')*100
    matrix A_ = A_ \ [`per']
    matrix A_ = A_ \ [`den']
    
    matrix colnames A_ = "`varlist'" 
    matrix rownames A_ = mean sd skewness median min max ownership n
    *matrix list A_, noheader
    
    matrix B_ = A_'
    *matlist B_, nodotz noheader cspec(& %15s | %10.2fc & %10.2fc & %10.4f & %10.0f & %10.2f &) rspec( & - & )
    return matrix vertical = A_
    return matrix horizontal = B_
    
end
capture program drop combine_imp_flag
program define combine_imp_flag
syntax varlist [if] [in], result(varname)

marksample touse, novarlist // process if and in statements

quietly {
	foreach v of varlist `varlist' {
		replace `result' = 6 if `v' == 6  & (`touse') // this is the lowest category
		}
	foreach v of varlist `varlist' {
		replace `result' = 1 if `v' == 1 & (`touse')
		}
	foreach v of varlist `varlist' {
		replace `result' = 2 if `v' == 2 & (`touse')
		}
	foreach v of varlist `varlist' {
		replace `result' = 3 if `v' == 3 & (`touse')
		}
	foreach v of varlist `varlist' {
		replace `result' = 5 if `v' == 5 & (`touse')
		}
	foreach v of varlist `varlist' {
		replace `result' = 7 if `v' == 7 & (`touse')
		}
    foreach v of varlist `varlist' {
		replace `result' = -1 if `v' == -1 & (`touse')
		}
	foreach v of varlist `varlist' {
		replace `result' = -2 if `v' == -2 & (`touse')
		}
	}
end


***drop repeat interviews in eol wave 4***
*idauniq 105273 in eol wave 2
*idauniq 106139,108381,108829 in eol wave 3
*idauniq 114235,150336 not in any core wave
tempfile w4_xt
use "$wave_4_xt"
drop if inlist(idauniq,105273,106139,108381,108829,114235,150336)
save "`w4_xt'"
global w4_xt `w4_xt'
clear

********************************************************************************************************************

****load full set of ELSA respodents***
use idauniq idauniqc pn pnc ragender inw1 inw2 inw3 inw4 inw5 inw6 inw7 inw8 inw9 c????cpindex using "$h_elsa"
gen in_helsa = 1
drop if inw1!=1 & inw2!=1 & inw3!=1 & inw4!=1 & inw5!=1 & inw6!=1 & inw7!=1 & inw8!=1 & inw9!=1

********************************************************************************************************************



***wave status: response indicator***
label define inwxt ///
   0 "0.nonresp" ///
   1 "1.resp,deceased"
   
***who interviewed***
label define relate ///
	1 "1.spouse" ///
	2 "2.child" ///
	3 "3.other relative" ///
	4 "4.other non-relative" 
	
***same proxy***
label define proxy ///
	1 "1.same proxy" ///
	2 "2.different proxy" ///
	3 "3.unknown" ///
	.p ".p:no previous proxy"
	
***season***
label define season ///
	1 "1.Winter (Dec to Feb)" ///
	2 "2.Spring (March to May)" ///
	3 "3.Summer (June to Aug)" ///
	4 "4.Autumn (Sept to Nov)"
	
***age flag***
label define ageflag ///
	0 "0.calculated age used" ///
	1 "1.month & year used" ///
	2 "2.only year used" 
	
***death location***
label define locate ///
	1 "1.private home" ///
	2 "2.hospital" ///
	3 "3.nursing home" ///
	4 "4.hospice" ///
	5 "5.other" 
	
***specific death location***
label define locatespec ///
	1 "1.own home" ///
	2 "2.another person's home" ///
	3 "3.hospital" ///
	4 "4.nursing home" ///
	5 "5.residential home" ///
	6 "6.mixed nursing/residential home" ///
	7 "7.sheltered housing" ///
	8 "8.non-specified care home" ///
	9 "9.hospice" ///
	10 "10.ambulance/en route" ///
	11 "11.other"
	
***death expected***
label define expect ///
	1 "1.expected" ///
	2 "2.unexpected" ///
	3 "3.other" 
	
***death cause harmonized***
label define grpcaus ///
	1 "1.cancer" /// 
	2 "2.cardiovascular" ///
	3 "3.other" ///
	.i ".i:irrelevant response"
	
***death cause original***
label define causes ///
	1 "1.cancer" ///
	2 "2.cardiovascular disease" ///
	3 "3.respiratory disease" ///
	4 "4.other" ///
	.i ".i:irrelevant response" 
	
***death duration***
label define duration ///
	1 "1.died suddenly" ///
	2 "2.less than 1 day" ///
	3 "3.less than 1 week" ///
	4 "4.less than 1 month" ///
	5 "5.less than 1 year" ///
	6 "6.1 year or more" 
	
***yes or no***
label define yesno ///
	0 "0.no" ///
	1 "1.yes" ///
	.n ".n:not applicable" ///
	.w ".w:no will" ///
	.t ".t:not distributed yet" ///
	.q ".q:not asked this wave" ///
	.i ".i:no eol instructions" ///
	.x ".x:not applicable"
	
***where living***
label define living ///
	0 "0.no" ///
	1 "1.yes, nursing home" ///
	2 "2.yes, hospice" 
	
***duration***
label define duration2 ///
	1 "1.less than 1 day" ///
	2 "2.less than 1 week" ///
	3 "3.less than 1 month" ///
	4 "4.less than 1 year" ///
	5 "5.1 year or more" ///
	.x ".x:not applicable" 
	
***date flag***
label define dateflag ///
	1 "1.season & year used" ///
	2 "2.only year used"
	
 

*set wave number
local wv=2
local pre_wv=1

****merge with wave 2 h_elsa data***
local demogxt_w2_helsa rabyear s`wv'byear r1iwindy 
merge 1:1 idauniq using "$h_elsa", keepusing(`demogxt_w2_helsa') nogen

local demogxt_w2_exit IntDatYY IntDatMM EiRRel EiDateY DVEiDateS EiRAGE EiPlac EiExPt EiSudd ///
											DVEiCaus EiLongW2 SurvSp EiHomeSt EiLOthB EiPlcL EiLive1 EiLive2 ///
											EiLive3 EiLive4 EiLive5 EiLive6 EiLive7 EiLive91 EiLive95 EiLive96 ///
											EiLHospB EiLHpceB EiLNursB EiLResB EiLMixB EiLShelB EiLExtB1 
merge 1:1 idauniq using "$wave_2_xt", keepusing(`demogxt_w2_exit') nogen





***In exit interview***
*wave 2 respondent in exit interview
gen inw`wv'xt = .
replace inw`wv'xt = 0 if IntDatYY==.
replace inw`wv'xt = 1 if !mi(IntDatYY)
label variable inw`wv'xt "inw`wv'xt: r in w`wv' eol interview"
label value inw`wv'xt inwxt

drop if idauniq==115040 //not in any core wave


***Last completed core interview***
*wave 2 respondent last completed core interview
gen ralstcore = .
replace ralstcore = 1 if inw1==1 & inw`wv'xt==1
label variable ralstcore "ralstcore: r last completed core interview wave"

***last completed core interview year***
*wave 2 respondent last completed core interview year
gen ralstcorey = .
replace ralstcorey = r1iwindy if inrange(r1iwindy,2002,2003) & inw`wv'xt==1
label variable ralstcorey "ralstcorey: r last completed core interview year"


***Interview Month***
*wave 2 respondent exit interview month
gen raxtiwm = .
missing_w2 IntDatMM if inw`wv'xt==1, result(raxtiwm)
replace raxtiwm = IntDatMM if inrange(IntDatMM,1,12)
label variable raxtiwm "raxtiwm: r eol interview month"


***Interview year***
*wave 2 respondent exit interview year
gen raxtiwy = .
missing_w2 IntDatYY if inw`wv'xt==1, result(raxtiwy)
replace raxtiwy = IntDatYY if inlist(IntDatYY,2004,2005)
label variable raxtiwy "raxtiwy: r eol interview year"


***How interviewee knew respondent***
*wave 2 respondent how interviewee knew respondent
gen raxprxy = .
replace raxprxy = 1 if inlist(EiRRel,1,2)
replace raxprxy = 2 if inrange(EiRRel,3,6)
replace raxprxy = 3 if inrange(EiRRel,13,21)
replace raxprxy = 4 if EiRRel==22
label variable raxprxy "raxprxy: proxy relationship to r: eol ivw"
label values raxprxy relate


***Death year***
*wave 2 respondent death year
gen raxyear = .
missing_w2 EiDateY if inw`wv'xt==1, result(raxyear)
replace raxyear = EiDateY if inrange(EiDateY,2002,2005)
label variable raxyear "raxyear: r death year in eol ivw"


***Death season***
*wave 2 respondent death season
gen raxseason = .
missing_w2 DVEiDateS if inw`wv'xt==1, result(raxseason)
replace raxseason = DVEiDateS if inrange(DVEiDateS,1,4)
label variable raxseason "raxseason: r death season in eol ivw"
label values raxseason season


***Age at death***
*wave 2 respondent age at death
gen deathage = .
replace deathage = raxyear - rabyear if !mi(raxyear) & !mi(rabyear)

gen radage = .
missing_w2 EiRAGE if inw`wv'xt==1, result(radage)
replace radage = EiRAGE if inrange(EiRAGE,30,130)
replace radage = deathage if mi(radage) & !mi(deathage)
label variable radage "radage: r age at death"

drop deathage

***Age at death flag***
*wave 2 respondent age at death flag
gen radagef = .
replace radagef = .m if inlist(radage,.d,.r,.m) & inw`wv'xt==1
replace radagef = 0 if inrange(EiRAGE,30,130)
replace radagef = 2 if !inrange(EiRAGE,30,130) & !mi(raxyear) & !mi(rabyear) & inw`wv'xt==1
label variable radagef "radagef: r flag age at death"
label values radagef ageflag


***Time from death to interview, months***
*wave 2 respondent time from death to interview,months
gen dmonth = .
replace dmonth = 1 if raxseason==1
replace dmonth = 4 if raxseason==2
replace dmonth = 7 if raxseason==3
replace dmonth = 10 if raxseason==4

gen radtoivwm = .
missing_w2 raxseason raxyear raxtiwm raxtiwy if inw`wv'xt==1, result(radtoivwm)
replace radtoivwm = (raxtiwy - raxyear) * 12 if !mi(raxtiwy) & !mi(raxyear)
replace radtoivwm = (raxtiwm - dmonth) + radtoivwm if !mi(radtoivwm) & !mi(raxtiwm) & !mi(dmonth)
replace radtoivwm = .i if inrange(radtoivwm,-10,-1)
label variable radtoivwm "radtoivwm: r time between death and eol ivw, months"

drop dmonth


***Time from death to interview, years***
*wave 2 respondent time from death to interview, years
gen radtoivwy = .
missing_w2 radtoivwm if inw`wv'xt==1, result(radtoivwy)
replace radtoivwy = .m if radtoivwy==. & inw`wv'xt==1
replace radtoivwy = floor(radtoivwm/12) if !mi(radtoivwm)
replace radtoivwy = .i if inrange(radtoivwy,-10,-1)
label variable radtoivwy "radtoivwy: r time between death and eol ivw, years"

***time from death to interview flag***
*wave 2 respondent time from death to interview flag
gen radtoivwf = .
replace radtoivwf = .m if inlist(radtoivwy,.m,.d,.r,.i) & inw`wv'xt==1
replace radtoivwf = 1 if (inrange(raxseason,1,4) & inrange(raxtiwm,1,12)) & !mi(radtoivwy) & inw`wv'xt==1
replace radtoivwf = 2 if (!inrange(raxseason,1,4) | !inrange(raxtiwm,1,12)) & !mi(radtoivwy) & inw`wv'xt==1
label variable radtoivwf "radtoivwf: r flag time between death and eol ivw"
label values radtoivwf dateflag


***Death location***
*wave 2 respondent death location
gen radloc = .
missing_w2 EiPlac if inw`wv'xt==1, result(radloc)
replace radloc = 1 if inlist(EiPlac,1,3)
replace radloc = 2 if EiPlac==4
replace radloc = 3 if inlist(EiPlac,2,6,7,8)
replace radloc = 4 if EiPlac==5
replace radloc = 5 if inlist(EiPlac,9,95)
label variable radloc "radloc: r death location"
label values radloc locate

***Specific death location***
*wave 2 respondent specific death location
gen radloc_e = .
missing_w2 EiPlac if inw`wv'xt==1, result(radloc_e)
replace radloc_e = 1 if EiPlac==1
replace radloc_e = 2 if EiPlac==3
replace radloc_e = 3 if EiPlac==4
replace radloc_e = 4 if EiPlac==6
replace radloc_e = 5 if EiPlac==7
replace radloc_e = 6 if EiPlac==8
replace radloc_e = 7 if EiPlac==2
replace radloc_e = 9 if EiPlac==5
replace radloc_e = 10 if EiPlac==9
replace radloc_e = 11 if EiPlac==95
label variable radloc_e "radloc_e: r specific death location"
label values radloc_e locatespec


***Whether death was expected***
*wave 2 respondent whether death expected
gen radexpec = .
missing_w2 EiLongW2 EiExPt EiSudd if inw`wv'xt==1, result(radexpec)
replace radexpec = 1 if EiExPt==1 | EiSudd==2
replace radexpec = 2 if EiExPt==2 | EiSudd==1
replace radexpec = 3 if EiExPt==95 | EiSudd==3
label variable radexpec "radexpec: r death expected"
label values radexpec expect


***Grouped Disease that caused death***
*wave 2 respondent grouped disease that caused death
gen ragcod = .
missing_w2 DVEiCaus if inw`wv'xt==1, result(ragcod)
replace ragcod = .i if DVEiCaus==96
replace ragcod = 1 if DVEiCaus==1
replace ragcod = 2 if DVEiCaus==2
replace ragcod = 3 if inlist(DVEiCaus,3,4)
label variable ragcod "ragcod: grouped disease that caused r's death"
label values ragcod grpcaus


***disease that caused death***
*wave 2 respondent disease that caused death
gen racod_e = .
missing_w2 DVEiCaus if inw`wv'xt==1, result(racod_e)
replace racod_e = .i if DVEiCaus==96
replace racod_e = DVEiCaus if inrange(DVEiCaus,1,4)
label variable racod_e "racod_e: disease that caused r's death"
label values racod_e causes


***Duration of final illness***
*wave 2 respondent duration final illness
gen raddur = .
missing_w2 EiLongW2 if inw`wv'xt==1, result(raddur)
replace raddur = 1 if EiLongW2==1
replace raddur = 2 if EiLongW2==3
replace raddur = 3 if EiLongW2==4
replace raddur = 4 if EiLongW2==5
replace raddur = 5 if inlist(EiLongW2,6,7)
replace raddur = 6 if EiLongW2==8
label variable raddur "raddur: r duration final illness/death"
label values raddur duration


***Whether married or partnered at death***
*wave 2 respondent whether married or partnered at death
gen radmarrp = .
missing_w2 EiRRel SurvSp if inw`wv'xt==1, result(radmarrp)
replace radmarrp = 0 if SurvSp==2
replace radmarrp = 1 if SurvSp==1 | inlist(EiRRel,1,2)
label variable radmarrp "radmarrp: r married/partnered at death"
label values radmarrp yesno


***Whether lived in nursing home prior to death***
gen place = .
gen max = 0

gen place1 = 7 if EiPlac==1 | EiLive1==1 //home=1
gen place2 = EiLOthB if EiLive3==1 //other person's home=2
replace place2 = EiPlcL if EiPlac==3
gen place3 = EiLHospB if EiLive4==1 //hospital=3
replace place3 = EiPlcL if EiPlac==4
gen place4 = EiLExtB1 if EiLive95==1 //other=4
replace place4 = EiPlcL if EiPlac==95
gen place5 = EiLNursB if EiLive6==1 //nursing home=5
replace place5 = EiPlcL if EiPlac==6
gen place6 = EiLResB if EiLive91==1 //residential home=6
replace place6 = EiPlcL if EiPlac==7
gen place7 = EiLMixB if EiLive7==1 //mixed nursing/residential=7
replace place7 = EiPlcL if EiPlac==8
gen place8 = EiLShelB if EiLive2==1 //sheltered housing=8
replace place8 = EiPlcL if EiPlac==2
gen place9 = EiLHpceB if EiLive5==1 //hospice=9
replace place9 = EiPlcL if EiPlac==5

recode place1-place9 (8=.d)

forval p = 1/9 {
	replace place = `p' if place`p'>=max & place`p'<.
	replace max = place`p' if place`p'>=max & place`p'<.
}

*wave 2 respondent whether lived in nursing home prior to death
gen radlivnh = .
missing_w2 EiPlcL EiLOthB EiLHospB EiLHpceB EiLNursB EiLResB EiLMixB ///
			EiLShelB EiLExtB1 if inw`wv'xt==1, result(radlivnh)
replace radlivnh = 0 if inrange(place,1,4)
replace radlivnh = 1 if inrange(place,5,8)
replace radlivnh = 2 if place==9
label variable radlivnh "radlivnh: r whether lived in nursing home prior to death"
label values radlivnh living


***Whether respondent moved into someone's house for help***
*wave 2 respondent whether moved into someone's house for help
gen ramvhlp = .
missing_w2 EiPlcL EiLOthB if inw`wv'xt==1, result(ramvhlp)
replace ramvhlp = 0 if place2==. & inw`wv'xt==1
replace ramvhlp = 1 if inrange(place2,1,7)
label variable ramvhlp "ramvhlp: r moved into someone's house for help"
label values ramvhlp yesno


***How long lived in other person's home***
*wave 2 respondent how long lived in other person's home
gen ralvhlpd = .
missing_w2 ramvhlp if inw`wv'xt==1, result(ralvhlpd)
replace ralvhlpd = .x if ramvhlp==0
replace ralvhlpd = 1 if place2==1
replace ralvhlpd = 2 if place2==2
replace ralvhlpd = 3 if place2==3
replace ralvhlpd = 4 if inlist(place2,4,5,6)
replace ralvhlpd = 5 if place2==7
label variable ralvhlpd "ralvhlpd: duration r lived in other person's home"
label values ralvhlpd duration2

drop place1 place2 place3 place4 place5 place6 place7 place8 place9 place max



***drop ELSA wave 2 core file raw variables***
drop `demogxt_w2_exit'


****drop h_elsa variables***
drop `demogxt_w2_helsa'


******************************************************************************************


*set wave number
local wv=3
local pre_wv=2

****merge with wave 3 h_elsa data***
local demogxt_w3_helsa rabyear s`wv'byear r1iwindy r2iwindy 
merge 1:1 idauniq using "$h_elsa", keepusing(`demogxt_w3_helsa') nogen

local demogxt_w3_exit IntDatYY IntDatMM EiRRel EiDateY EiDateS EiRAGE EiPlac EiExPt EiSudd ///
											DVEiCaus EiLong SurvSp EiHomeSt EiLOthB EiPlcL EiLHospB EiLHpceB EiLNursB ///
											EiLResB EiLMixB EiLive1 EiLive2 EiLive3 EiLive4 EiLive5 EiLive6 EiLive7 EiLive8 ///
											EiLive91 EiLive95 EiLive96 EiLShelB EiLExtB1 EiLExtB2 EiLExtB3
merge 1:1 idauniq using "$wave_3_xt", keepusing(`demogxt_w3_exit') nogen





***In exit interview***
*wave 3 respondent in exit interview
gen inw`wv'xt = .
replace inw`wv'xt = 0 if IntDatYY==.
replace inw`wv'xt = 1 if !mi(IntDatYY)
label variable inw`wv'xt "inw`wv'xt: r in w`wv' eol interview"
label value inw`wv'xt inwxt

drop if idauniq==101432 //not in any core wave


***Last completed core interview***
*wave 3 respondent last completed core interview
replace ralstcore = 2 if inw2==1 & inw`wv'xt==1
replace ralstcore = 1 if inw2==0 & inw1==1 & inw`wv'xt==1

***last completed core interview year***
*wave 3 respondent last completed core interview year
forvalues w = 1/2 {
replace ralstcorey = r`w'iwindy if inrange(r`w'iwindy,2002,2005) & inw`wv'xt==1
}


***Interview Month***
*wave 3 respondent exit interview month
missing_w3 IntDatMM if inw`wv'xt==1, result(raxtiwm)
replace raxtiwm = IntDatMM if inrange(IntDatMM,1,12)


***Interview year***
*wave 3 respondent exit interview year
missing_w3 IntDatYY if inw`wv'xt==1, result(raxtiwy)
replace raxtiwy = IntDatYY if inlist(IntDatYY,2006,2007)


***How interviewee knew respondent***
*wave 3 respondent how interviewee knew respondent
replace raxprxy = 1 if inlist(EiRRel,1,2)
replace raxprxy = 2 if inrange(EiRRel,3,7)
replace raxprxy = 3 if inrange(EiRRel,8,21)
replace raxprxy = 4 if EiRRel==22


***Death year***
*wave 3 respondent death year
missing_w3 EiDateY if inw`wv'xt==1, result(raxyear)
replace raxyear = EiDateY if inrange(EiDateY,2002,2007)


***Death season***
*wave 3 respondent death season
missing_w3 EiDateS if inw`wv'xt==1, result(raxseason)
replace raxseason = EiDateS if inrange(EiDateS,1,4)


***Age at death***
*wave 3 respondent age at death
gen deathage = .
replace deathage = raxyear - rabyear if !mi(raxyear) & !mi(rabyear)

missing_w3 EiRAGE if inw`wv'xt==1, result(radage)
replace radage = EiRAGE if inrange(EiRAGE,30,130)
replace radage = deathage if mi(radage) & !mi(deathage)

drop deathage

***Age at death flag***
*wave 3 respondent age at death flag
replace radagef = .m if inlist(radage,.d,.r,.m) & inw`wv'xt==1
replace radagef = 0 if inrange(EiRAGE,30,130)
replace radagef = 2 if !inrange(EiRAGE,30,130) & !mi(raxyear) & !mi(rabyear) & inw`wv'xt==1


***Time from death to interview, months***
*wave 3 respondent time from death to interview,months
gen dmonth = .
replace dmonth = 1 if raxseason==1
replace dmonth = 4 if raxseason==2
replace dmonth = 7 if raxseason==3
replace dmonth = 10 if raxseason==4

missing_w3 raxseason raxyear raxtiwm raxtiwy if inw`wv'xt==1, result(radtoivwm)
replace radtoivwm = (raxtiwy - raxyear) * 12 if !mi(raxtiwy) & !mi(raxyear)
replace radtoivwm = (raxtiwm - dmonth) + radtoivwm if !mi(radtoivwm) & !mi(raxtiwm) & !mi(dmonth)
replace radtoivwm = .i if inrange(radtoivwm,-10,-1)

drop dmonth


***Time from death to interview, years***
*wave 3 respondent time from death to interview, years
missing_w3 radtoivwm if inw`wv'xt==1, result(radtoivwy)
replace radtoivwy = .m if radtoivwy==. & inw`wv'xt==1
replace radtoivwy = floor(radtoivwm/12) if !mi(radtoivwm)
replace radtoivwy = .i if inrange(radtoivwy,-10,-1)

***time from death to interview flag***
*wave 3 respondent time from death to interview flag
replace radtoivwf = .m if inlist(radtoivwy,.m,.d,.r,.i) & inw`wv'xt==1
replace radtoivwf = 1 if (inrange(raxseason,1,4) & inrange(raxtiwm,1,12)) & !mi(radtoivwy) & inw`wv'xt==1
replace radtoivwf = 2 if (!inrange(raxseason,1,4) | !inrange(raxtiwm,1,12)) & !mi(radtoivwy) & inw`wv'xt==1


***Death location***
*wave 3 respondent death location
missing_w3 EiPlac if inw`wv'xt==1, result(radloc)
replace radloc = 1 if inlist(EiPlac,1,3)
replace radloc = 2 if EiPlac==4
replace radloc = 3 if inlist(EiPlac,2,6,7,8,91)
replace radloc = 4 if EiPlac==5
replace radloc = 5 if inlist(EiPlac,9,95)

***Specific death location***
*wave 3 respondent specific death location
missing_w3 EiPlac if inw`wv'xt==1, result(radloc_e)
replace radloc_e = 1 if EiPlac==1
replace radloc_e = 2 if EiPlac==3
replace radloc_e = 3 if EiPlac==4
replace radloc_e = 4 if EiPlac==6
replace radloc_e = 5 if EiPlac==7
replace radloc_e = 6 if EiPlac==8
replace radloc_e = 7 if EiPlac==2
replace radloc_e = 8 if EiPlac==91
replace radloc_e = 9 if EiPlac==5
replace radloc_e = 10 if EiPlac==9
replace radloc_e = 11 if EiPlac==95


***Whether death was expected***
*wave 3 respondent whether death expected
missing_w3 EiLong EiExPt EiSudd if inw`wv'xt==1, result(radexpec)
replace radexpec = 1 if EiExPt==1 | EiSudd==2
replace radexpec = 2 if EiExPt==2 | EiSudd==1
replace radexpec = 3 if EiExPt==95 | EiSudd==3


***Grouped Disease that caused death***
*wave 3 respondent grouped disease that caused death
missing_w3 DVEiCaus if inw`wv'xt==1, result(ragcod)
replace ragcod = .i if DVEiCaus==96
replace ragcod = 1 if DVEiCaus==1
replace ragcod = 2 if DVEiCaus==2
replace ragcod = 3 if inlist(DVEiCaus,3,4)


***disease that caused death***
*wave 3 respondent disease that caused death
missing_w3 DVEiCaus if inw`wv'xt==1, result(racod_e)
replace racod_e = .i if DVEiCaus==96
replace racod_e = DVEiCaus if inrange(DVEiCaus,1,4)


***Duration of final illness***
*wave 3 respondent duration final illness
missing_w3 EiLong if inw`wv'xt==1, result(raddur)
replace raddur = .d if EiLong==8
replace raddur = 1 if EiLong==1
replace raddur = 2 if EiLong==2
replace raddur = 3 if EiLong==3
replace raddur = 4 if EiLong==4
replace raddur = 5 if inlist(EiLong,5,6)
replace raddur = 6 if EiLong==7


***Whether married or partnered at death***
*wave 3 respondent whether married or partnered at death
missing_w3 EiRRel SurvSp if inw`wv'xt==1, result(radmarrp)
replace radmarrp = 0 if SurvSp==2
replace radmarrp = 1 if SurvSp==1 | inlist(EiRRel,1,2)


***Where living prior to death***
gen place = .
gen max = 0
egen eilextb = rowmax(EiLExtB1 EiLExtB2 EiLExtB3)

gen place1 = 6 if EiPlac==1 | EiLive1==1 //home=1
gen place2 = EiLOthB if EiLive3==1 //other person's home=2
replace place2 = EiPlcL if EiPlac==3
gen place3 = EiLHospB if EiLive4==1 //hospital=3
replace place3 = EiPlcL if EiPlac==4
gen place4 = eilextb if EiLive95==1 //other=4
replace place4 = EiPlcL if EiPlac==95
gen place5 = EiLNursB if EiLive6==1 //nursing home=5
replace place5 = EiPlcL if EiPlac==6
gen place6 = EiLResB if EiLive7==1 //residential home=6
replace place6 = EiPlcL if EiPlac==7
gen place7 = EiLMixB if EiLive8==1 //mixed nursing/residential=7
replace place7 = EiPlcL if EiPlac==8
gen place8 = EiLShelB if EiLive2==1 //sheltered housing=8
replace place8 = EiPlcL if EiPlac==2
gen place9 = EiLHpceB if EiLive5==1 //hospice=9
replace place9 = EiPlcL if EiPlac==5

recode place1-place9 (7=.d)

forval p = 1/9 {
	replace place = `p' if place`p'>=max & place`p'<.
	replace max = place`p' if place`p'>=max & place`p'<.
}

*wave 3 respondent whether lived in nursing home prior to death
missing_w2 EiPlcL EiLOthB EiLHospB EiLHpceB EiLNursB EiLResB EiLMixB ///
			EiLShelB EiLExtB1 if inw`wv'xt==1, result(radlivnh)
replace radlivnh = 0 if inrange(place,1,4)
replace radlivnh = 1 if inrange(place,5,8)
replace radlivnh = 2 if place==9


***Whether respondent moved into someone's house for help***
*wave 3 respondent whether moved into someone's house for help
missing_w3 EiPlcL EiLOthB if inw`wv'xt==1, result(ramvhlp)
replace ramvhlp = 0 if place2==. & inw`wv'xt==1
replace ramvhlp = 1 if inrange(place2,1,7)


***How long lived in other person's home***
*wave 3 respondent how long lived in other person's home
missing_w3 ramvhlp if inw`wv'xt==1, result(ralvhlpd)
replace ralvhlpd = .x if ramvhlp==0
replace ralvhlpd = 2 if place2==1
replace ralvhlpd = 3 if place2==2
replace ralvhlpd = 4 if inrange(place2,3,5)
replace ralvhlpd = 5 if place2==6

drop place1 place2 place3 place4 place5 place6 place7 place8 place9 place max eilextb


***drop ELSA wave 3 core file raw variables***
drop `demogxt_w3_exit'


****drop h_elsa variables***
drop `demogxt_w3_helsa'


******************************************************************************************


*set wave number
local wv=4
local pre_wv=3

****merge with wave 4 h_elsa data***
local demogxt_w4_helsa rabyear s`wv'byear r1iwindy r2iwindy r3iwindy 
merge 1:1 idauniq using "$h_elsa", keepusing(`demogxt_w4_helsa') nogen

local demogxt_w4_exit IntDatYY IntDatMM EiRRel EiDateY DVEiDateS EiRAGE EiPlac EiExPt EiSudd ///
											DVEiCaus EiLong SurvSp EiHomeSt EiLOthB EiPlcL EiLHospB EiLHpceB EiLNursB ///
											EiLResB EiLMixB EiLive1 EiLive2 EiLive3 EiLive4 EiLive5 EiLive6 EiLive7 EiLive8 ///
											EiLive91 EiLive95 EiLive96 EiLShelB EiLExtB1
merge 1:1 idauniq using "$w4_xt", keepusing(`demogxt_w4_exit') nogen





***In exit interview***
*wave 4 respondent in exit interview
gen inw`wv'xt = .
replace inw`wv'xt = 0 if IntDatYY==.
replace inw`wv'xt = 1 if !mi(IntDatYY)
label variable inw`wv'xt "inw`wv'xt: r in w`wv' eol interview"
label value inw`wv'xt inwxt


***Last completed core interview***
*wave 4 respondent last completed core interview
replace ralstcore = 3 if inw3==1 & inw`wv'xt==1
replace ralstcore = 2 if inw3==0 & inw2==1 & inw`wv'xt==1
replace ralstcore = 1 if inw3==0 & inw2==0 & inw1==1 & inw`wv'xt==1

***last completed core interview year***
*wave 4 respondent last completed core interview year
forvalues w = 1/3 {
replace ralstcorey = r`w'iwindy if inrange(r`w'iwindy,2002,2007) & inw`wv'xt==1
}

***Interview Month***
*wave 4 respondent exit interview month
missing_w4 IntDatMM if inw`wv'xt==1, result(raxtiwm)
replace raxtiwm = IntDatMM if inrange(IntDatMM,1,12)


***Interview year***
*wave 4 respondent exit interview year
missing_w4 IntDatYY if inw`wv'xt==1, result(raxtiwy)
replace raxtiwy = IntDatYY if inlist(IntDatYY,2008,2009)


***How interviewee knew respondent***
*wave 4 respondent how interviewee knew respondent
replace raxprxy = 1 if inlist(EiRRel,1,2)
replace raxprxy = 2 if inrange(EiRRel,3,7)
replace raxprxy = 3 if inrange(EiRRel,8,21)
replace raxprxy = 4 if EiRRel==22


***Death year***
*wave 4 respondent death year
missing_w4 EiDateY if inw`wv'xt==1, result(raxyear)
replace raxyear = EiDateY if inrange(EiDateY,2004,2009)


***Death season***
*wave 4 respondent death season
missing_w4 DVEiDateS if inw`wv'xt==1, result(raxseason)
replace raxseason = DVEiDateS if inrange(DVEiDateS,1,4)


***Age at death***
*wave 4 respondent age at death
gen deathage = .
replace deathage = raxyear - rabyear if !mi(raxyear) & !mi(rabyear)

missing_w4 EiRAGE if inw`wv'xt==1, result(radage)
replace radage = EiRAGE if inrange(EiRAGE,30,130)
replace radage = deathage if mi(radage) & !mi(deathage)

drop deathage

***Age at death flag***
*wave 4 respondent age at death flag
replace radagef = .m if inlist(radage,.d,.r,.m) & inw`wv'xt==1
replace radagef = 0 if inrange(EiRAGE,30,130)
replace radagef = 2 if !inrange(EiRAGE,30,130) & !mi(raxyear) & !mi(rabyear) & inw`wv'xt==1


***Time from death to interview, months***
*wave 4 respondent time from death to interview,months
gen dmonth = .
replace dmonth = 1 if raxseason==1
replace dmonth = 4 if raxseason==2
replace dmonth = 7 if raxseason==3
replace dmonth = 10 if raxseason==4

missing_w4 raxseason raxyear raxtiwm raxtiwy if inw`wv'xt==1, result(radtoivwm)
replace radtoivwm = (raxtiwy - raxyear) * 12 if !mi(raxtiwy) & !mi(raxyear)
replace radtoivwm = (raxtiwm - dmonth) + radtoivwm if !mi(radtoivwm) & !mi(raxtiwm) & !mi(dmonth)
replace radtoivwm = .i if inrange(radtoivwm,-10,-1)

drop dmonth


***Time from death to interview, years***
*wave 4 respondent time from death to interview, years
missing_w4 radtoivwm if inw`wv'xt==1, result(radtoivwy)
replace radtoivwy = .m if radtoivwy==. & inw`wv'xt==1
replace radtoivwy = floor(radtoivwm/12) if !mi(radtoivwm)
replace radtoivwy = .i if inrange(radtoivwy,-10,-1) | radtoivwm==.i

***time from death to interview flag***
*wave 4 respondent time from death to interview flag
replace radtoivwf = .m if inlist(radtoivwy,.m,.d,.r,.i) & inw`wv'xt==1
replace radtoivwf = 1 if (inrange(raxseason,1,4) & inrange(raxtiwm,1,12)) & !mi(radtoivwy) & inw`wv'xt==1
replace radtoivwf = 2 if (!inrange(raxseason,1,4) | !inrange(raxtiwm,1,12)) & !mi(radtoivwy) & inw`wv'xt==1


***Death location***
*wave 4 respondent death location
missing_w4 EiPlac if inw`wv'xt==1, result(radloc)
replace radloc = 1 if inlist(EiPlac,1,3)
replace radloc = 2 if EiPlac==4
replace radloc = 3 if inlist(EiPlac,2,6,7,8,91)
replace radloc = 4 if EiPlac==5
replace radloc = 5 if inlist(EiPlac,9,95)

***Specific death location***
*wave 4 respondent specific death location
missing_w4 EiPlac if inw`wv'xt==1, result(radloc_e)
replace radloc_e = 1 if EiPlac==1
replace radloc_e = 2 if EiPlac==3
replace radloc_e = 3 if EiPlac==4
replace radloc_e = 4 if EiPlac==6
replace radloc_e = 5 if EiPlac==7
replace radloc_e = 6 if EiPlac==8
replace radloc_e = 7 if EiPlac==2
replace radloc_e = 8 if EiPlac==91
replace radloc_e = 9 if EiPlac==5
replace radloc_e = 10 if EiPlac==9
replace radloc_e = 11 if EiPlac==95


***Whether death was expected***
*wave 4 respondent whether death expected
missing_w4 EiLong EiExPt EiSudd if inw`wv'xt==1, result(radexpec)
replace radexpec = 1 if EiExPt==1 | EiSudd==2
replace radexpec = 2 if EiExPt==2 | EiSudd==1
replace radexpec = 3 if EiExPt==95 | EiSudd==3


***Grouped Disease that caused death***
*wave 4 respondent grouped disease that caused death
missing_w4 DVEiCaus if inw`wv'xt==1, result(ragcod)
replace ragcod = .i if DVEiCaus==96
replace ragcod = 1 if DVEiCaus==1
replace ragcod = 2 if DVEiCaus==2
replace ragcod = 3 if inlist(DVEiCaus,3,4)


***disease that caused death***
*wave 4 respondent disease that caused death
missing_w4 DVEiCaus if inw`wv'xt==1, result(racod_e)
replace racod_e = .i if DVEiCaus==96
replace racod_e = DVEiCaus if inrange(DVEiCaus,1,4)


***Duration of final illness***
*wave 4 respondent duration final illness
missing_w4 EiLong if inw`wv'xt==1, result(raddur)
replace raddur = .d if EiLong==8
replace raddur = 1 if EiLong==1
replace raddur = 2 if EiLong==2
replace raddur = 3 if EiLong==3
replace raddur = 4 if EiLong==4
replace raddur = 5 if inlist(EiLong,5,6)
replace raddur = 6 if EiLong==7


***Whether married or partnered at death***
*wave 4 respondent whether married or partnered at death
missing_w4 EiRRel SurvSp if inw`wv'xt==1, result(radmarrp)
replace radmarrp = 0 if SurvSp==2
replace radmarrp = 1 if SurvSp==1 | inlist(EiRRel,1,2)


***Where living prior to death***
gen place = .
gen max = 0

gen place1 = 6 if EiPlac==1 | EiLive1==1 //home=1
gen place2 = EiLOthB if EiLive3==1 //other person's home=2
replace place2 = EiPlcL if EiPlac==3
gen place3 = EiLHospB if EiLive4==1 //hospital=3
replace place3 = EiPlcL if EiPlac==4
gen place4 = EiLExtB1 if EiLive95==1 //other=4
replace place4 = EiPlcL if EiPlac==95
gen place5 = EiLNursB if EiLive6==1 //nursing home=5
replace place5 = EiPlcL if EiPlac==6
gen place6 = EiLResB if EiLive7==1 //residential home=6
replace place6 = EiPlcL if EiPlac==7
gen place7 = EiLMixB if EiLive8==1 //mixed nursing/residential=7
replace place7 = EiPlcL if EiPlac==8
gen place8 = EiLShelB if EiLive2==1 //sheltered housing=8
replace place8 = EiPlcL if EiPlac==2
gen place9 = EiLHpceB if EiLive5==1 //hospice=9
replace place9 = EiPlcL if EiPlac==5

recode place1-place9 (7=.d)

forval p = 1/9 {
	replace place = `p' if place`p'>=max & place`p'<.
	replace max = place`p' if place`p'>=max & place`p'<.
}

*wave 4 respondent whether lived in nursing home prior to death
missing_w2 EiPlcL EiLOthB EiLHospB EiLHpceB EiLNursB EiLResB EiLMixB ///
			EiLShelB EiLExtB1 if inw`wv'xt==1, result(radlivnh)
replace radlivnh = 0 if inrange(place,1,4)
replace radlivnh = 1 if inrange(place,5,8)
replace radlivnh = 2 if place==9


***Whether respondent moved into someone's house for help***
*wave 4 respondent whether moved into someone's house for help
missing_w4 EiPlcL EiHomeSt if inw`wv'xt==1, result(ramvhlp)
replace ramvhlp = 0 if place2==. & inw`wv'xt==1
replace ramvhlp = 1 if inrange(place2,1,7)


***How long lived in other person's home***
*wave 4 respondent how long lived in other person's home
missing_w4 ramvhlp if inw`wv'xt==1, result(ralvhlpd)
replace ralvhlpd = .x if ramvhlp==0
replace ralvhlpd = 2 if place2==1
replace ralvhlpd = 3 if place2==2
replace ralvhlpd = 4 if inrange(place2,3,4)

drop place1 place2 place3 place4 place5 place6 place7 place8 place9 place max


***drop ELSA wave 4 core file raw variables***
drop `demogxt_w4_exit'


****drop h_elsa variables***
drop `demogxt_w4_helsa'


******************************************************************************************


*set wave number
local wv=6
local pre_wv=5

****merge with wave 6 h_elsa data***
local demogxt_w6_helsa rabyear s`wv'byear r1iwindy r2iwindy r3iwindy r4iwindy r5iwindy 
merge 1:1 idauniq using "$h_elsa", keepusing(`demogxt_w6_helsa') nogen

local demogxt_w6_exit IntDatYY IntDatMM EiRRel EiDateY DVEiDateS EiRAGE EiPlac EiExPt EiSudd ///
											DVEiCaus EiLong SurvSp EiHomeSt EiLOthB EiPlcL EiLHospB EiLHpceB EiLNursB ///
											EiLResB EiLMixB EiLive1 EiLive2 EiLive3 EiLive4 EiLive5 EiLive6 EiLive7 EiLive8 ///
											EiLive91 EiLive95 EiLive96 EiLShelB EiLExtB1 EiLExtB2 
merge 1:1 idauniq using "$wave_6_xt", keepusing(`demogxt_w6_exit') nogen





***In exit interview***
*wave 6 respondent in exit interview
gen inw`wv'xt = .
replace inw`wv'xt = 0 if IntDatYY==.
replace inw`wv'xt = 1 if !mi(IntDatYY)
label variable inw`wv'xt "inw`wv'xt: r in w`wv' eol interview"
label value inw`wv'xt inwxt


***Last completed core interview***
*wave 6 respondent last completed core interview
replace ralstcore = 5 if inw5==1 & inw`wv'xt==1
replace ralstcore = 4 if inw5==0 & inw4==1 & inw`wv'xt==1
replace ralstcore = 3 if inw5==0 & inw4==0 & inw3==1 & inw`wv'xt==1
replace ralstcore = 2 if inw5==0 & inw4==0 & inw3==0 & inw2==1 & inw`wv'xt==1
replace ralstcore = 1 if inw5==0 & inw4==0 & inw3==0 & inw2==0 & inw1==1 & inw`wv'xt==1

***last completed core interview year***
*wave 6 respondent last completed core interview year
forvalues w = 1/5 {
replace ralstcorey = r`w'iwindy if inrange(r`w'iwindy,2002,2011) & inw`wv'xt==1
}


***Interview Month***
*wave 6 respondent exit interview month
missing_w6 IntDatMM if inw`wv'xt==1, result(raxtiwm)
replace raxtiwm = IntDatMM if inrange(IntDatMM,1,12)


***Interview year***
*wave 6 respondent exit interview year
missing_w6 IntDatYY if inw`wv'xt==1, result(raxtiwy)
replace raxtiwy = IntDatYY if inlist(IntDatYY,2012,2013)


***How interviewee knew respondent***
*wave 6 respondent how interviewee knew respondent
replace raxprxy = 1 if inlist(EiRRel,1,2)
replace raxprxy = 2 if inrange(EiRRel,3,7)
replace raxprxy = 3 if inrange(EiRRel,8,21)
replace raxprxy = 4 if EiRRel==22


***Death year***
*wave 6 respondent death year
missing_w6 EiDateY if inw`wv'xt==1, result(raxyear)
replace raxyear = .i if EiDateY==2000
replace raxyear = EiDateY if inrange(EiDateY,2002,2012)


***Death season***
*wave 6 respondent death season
missing_w6 DVEiDateS if inw`wv'xt==1, result(raxseason)
replace raxseason = DVEiDateS if inrange(DVEiDateS,1,4)


***Age at death***
*wave 6 respondent age at death
gen deathage = .
replace deathage = raxyear - rabyear if !mi(raxyear) & !mi(rabyear)

missing_w6 EiRAGE if inw`wv'xt==1, result(radage)
replace radage = EiRAGE if inrange(EiRAGE,30,130)
replace radage = deathage if mi(radage) & !mi(deathage)

drop deathage

***Age at death flag***
*wave 6 respondent age at death flag
replace radagef = .m if inlist(radage,.d,.r,.m) & inw`wv'xt==1
replace radagef = 0 if inrange(EiRAGE,30,130)
replace radagef = 2 if !inrange(EiRAGE,30,130) & !mi(raxyear) & !mi(rabyear) & inw`wv'xt==1


***Time from death to interview, months***
*wave 6 respondent time from death to interview,months
gen dmonth = .
replace dmonth = 1 if raxseason==1
replace dmonth = 4 if raxseason==2
replace dmonth = 7 if raxseason==3
replace dmonth = 10 if raxseason==4

missing_w6 raxseason raxyear raxtiwm raxtiwy if inw`wv'xt==1, result(radtoivwm)
replace radtoivwm = .d if raxyear==.d
replace radtoivwm = (raxtiwy - raxyear) * 12 if !mi(raxtiwy) & !mi(raxyear)
replace radtoivwm = (raxtiwm - dmonth) + radtoivwm if !mi(radtoivwm) & !mi(raxtiwm) & !mi(dmonth)
replace radtoivwm = .i if inrange(radtoivwm,-10,-1) | (raxyear==.i & inw`wv'xt==1)

drop dmonth


***Time from death to interview, years***
*wave 6 respondent time from death to interview, years
missing_w6 radtoivwm if inw`wv'xt==1, result(radtoivwy)
replace radtoivwy = .m if radtoivwy==. & inw`wv'xt==1
replace radtoivwy = floor(radtoivwm/12) if !mi(radtoivwm)
replace radtoivwy = .i if inrange(radtoivwy,-10,-1) | radtoivwm==.i

***time from death to interview flag***
*wave 6 respondent time from death to interview flag
replace radtoivwf = .m if inlist(radtoivwy,.m,.d,.r,.i) & inw`wv'xt==1
replace radtoivwf = 1 if (inrange(raxseason,1,4) & inrange(raxtiwm,1,12)) & !mi(radtoivwy) & inw`wv'xt==1
replace radtoivwf = 2 if (!inrange(raxseason,1,4) | !inrange(raxtiwm,1,12)) & !mi(radtoivwy) & inw`wv'xt==1


***Death location***
*wave 6 respondent death location
missing_w6 EiPlac if inw`wv'xt==1, result(radloc)
replace radloc = 1 if inlist(EiPlac,1,3)
replace radloc = 2 if EiPlac==4
replace radloc = 3 if inlist(EiPlac,2,6,7,8)
replace radloc = 4 if EiPlac==5
replace radloc = 5 if inlist(EiPlac,9,95)

***Specific death location***
*wave 6 respondent specific death location
missing_w6 EiPlac if inw`wv'xt==1, result(radloc_e)
replace radloc_e = 1 if EiPlac==1
replace radloc_e = 2 if EiPlac==3
replace radloc_e = 3 if EiPlac==4
replace radloc_e = 4 if EiPlac==6
replace radloc_e = 5 if EiPlac==7
replace radloc_e = 6 if EiPlac==8
replace radloc_e = 7 if EiPlac==2
replace radloc_e = 8 if EiPlac==10
replace radloc_e = 9 if EiPlac==5
replace radloc_e = 10 if EiPlac==9
replace radloc_e = 11 if EiPlac==95


***Whether death was expected***
*wave 6 respondent whether death expected
missing_w6 EiLong EiExPt EiSudd if inw`wv'xt==1, result(radexpec)
replace radexpec = 1 if EiExPt==1 | EiSudd==2
replace radexpec = 2 if EiExPt==2 | EiSudd==1
replace radexpec = 3 if EiExPt==95 | EiSudd==3


***Grouped Disease that caused death***
*wave 6 respondent grouped disease that caused death
missing_w6 DVEiCaus if inw`wv'xt==1, result(ragcod)
replace ragcod = .i if DVEiCaus==96
replace ragcod = 1 if DVEiCaus==1
replace ragcod = 2 if DVEiCaus==2
replace ragcod = 3 if inlist(DVEiCaus,3,4)


***disease that caused death***
*wave 6 respondent disease that caused death
missing_w6 DVEiCaus if inw`wv'xt==1, result(racod_e)
replace racod_e = .i if DVEiCaus==96
replace racod_e = DVEiCaus if inrange(DVEiCaus,1,4)


***Duration of final illness***
*wave 6 respondent duration final illness
missing_w6 EiLong if inw`wv'xt==1, result(raddur)
replace raddur = .d if EiLong==8
replace raddur = 1 if EiLong==1
replace raddur = 2 if EiLong==2
replace raddur = 3 if EiLong==3
replace raddur = 4 if EiLong==4
replace raddur = 5 if inlist(EiLong,5,6)
replace raddur = 6 if EiLong==7


***Whether married or partnered at death***
*wave 6 respondent whether married or partnered at death
missing_w6 EiRRel SurvSp if inw`wv'xt==1, result(radmarrp)
replace radmarrp = 0 if SurvSp==2
replace radmarrp = 1 if SurvSp==1 | inlist(EiRRel,1,2)


***Where living prior to death***
gen place = .
gen max = 0
egen eilextb = rowmax(EiLExtB1 EiLExtB2)

gen place1 = 6 if EiPlac==1 | EiLive1==1 //home=1
gen place2 = EiLOthB if EiLive3==1 //other person's home=2
replace place2 = EiPlcL if EiPlac==3
gen place3 = EiLHospB if EiLive4==1 //hospital=3
replace place3 = EiPlcL if EiPlac==4
gen place4 = eilextb if EiLive95==1 //other=4
replace place4 = EiPlcL if EiPlac==95
gen place5 = EiLNursB if EiLive6==1 //nursing home=5
replace place5 = EiPlcL if EiPlac==6
gen place6 = EiLResB if EiLive7==1 //residential home=6
replace place6 = EiPlcL if EiPlac==7
gen place7 = EiLMixB if EiLive8==1 //mixed nursing/residential=7
replace place7 = EiPlcL if EiPlac==8
gen place8 = EiLShelB if EiLive2==1 //sheltered housing=8
replace place8 = EiPlcL if EiPlac==2
gen place9 = EiLHpceB if EiLive5==1 //hospice=9
replace place9 = EiPlcL if EiPlac==5

recode place1-place9 (7=.d)

forval p = 1/9 {
	replace place = `p' if place`p'>=max & place`p'<.
	replace max = place`p' if place`p'>=max & place`p'<.
}

*wave 6 respondent whether lived in nursing home prior to death
missing_w2 EiPlcL EiLOthB EiLHospB EiLHpceB EiLNursB EiLResB EiLMixB ///
			EiLShelB EiLExtB1 if inw`wv'xt==1, result(radlivnh)
replace radlivnh = 0 if inrange(place,1,4)
replace radlivnh = 1 if inrange(place,5,8)
replace radlivnh = 2 if place==9


***Whether respondent moved into someone's house for help***
*wave 6 respondent whether moved into someone's house for help
missing_w6 EiPlcL EiLOthB if inw`wv'xt==1, result(ramvhlp)
replace ramvhlp = 0 if place2==. & inw`wv'xt==1
replace ramvhlp = 1 if inrange(place2,1,7)


***How long lived in other person's home***
*wave 6 respondent how long lived in other person's home
missing_w6 ramvhlp if inw`wv'xt==1, result(ralvhlpd)
replace ralvhlpd = .x if ramvhlp==0
replace ralvhlpd = 2 if place2==1
replace ralvhlpd = 3 if place2==2
replace ralvhlpd = 4 if inrange(place2,3,5)

drop place1 place2 place3 place4 place5 place6 place7 place8 place9 place max eilextb 



***drop ELSA wave 6 core file raw variables***
drop `demogxt_w6_exit'


****drop h_elsa variables***
drop `demogxt_w6_helsa'


******************************************************************************************






***In any exit interview***
*respondent in exit interview
gen inxt = .
replace inxt = 1 if inw2xt==1 | inw3xt==1 | inw4xt==1 | inw6xt==1
label variable inxt "inxt: r in eol interview"
label value inxt inwxt


***End of Life Interview Wave***
gen raxt = .
foreach w of numlist 2 3 4 6 {
	replace raxt = `w' if inw`w'xt==1
}
label variable raxt "raxt: r eol interview wave"





******************************************************************************************




*gender
tab ragender if in_helsa == 1, m

*age catagories
sum radage, d

egen radagecat_i  = cut(radage), at(20,70,80,90,199) icode
tab radagecat_i,m



******************************************************************************************


***yes or no doctor diagnosed***
label define yesnodr ///
	0 "0.no" ///
	1 "1.yes"
	
	

*set wave number
local wv=2
local pre_wv=1

****merge with wave 2 h_elsa data***
local healthxt_w2_helsa r1diabe r1cancre r1lunge r1hearte r1hrtatte r1stroke r1hibpe r1alzhe r1demene  
merge 1:1 idauniq using "$h_elsa", keepusing(`healthxt_w2_helsa') nogen

****merge with wave 2 exit data***
local healthxt_w2_exit EiCaHa EiCaSt EiCaCa EiDiaA2 EiDiaA3 EiDiaA4 EiDiaA5 EiDiaA6 EiDiaA7 EiDiaA8 ///
											 EiDiaA95 EiDiaA96 EiDiaB1 EiDiaB5 EiDiaB8 EiDiaB9 EiDiaB96  
merge 1:1 idauniq using "$wave_2_xt", keepusing(`healthxt_w2_exit') nogen




***ever had cancer last ivw***
*respondent wave 2 ever had cancer last ivw
gen ralcancre = .
replace ralcancre = r1cancre if ralstcore==1
label variable ralcancre "ralcancre: r ever had cancer as of last ivw"
label values ralcancre yesnodr

***ever had lung disease last ivw***
*respondent wave 2 ever had lung disease last ivw
gen rallunge = .
replace rallunge = r1lunge if ralstcore==1
label variable rallunge "rallunge: r ever had lung disease as of last ivw"
label values rallunge yesnodr

***ever had heart problems last ivw***
*respondent wave 2 ever had heart problems last ivw
gen ralhearte = .
replace ralhearte = r1hearte if ralstcore==1
label variable ralhearte "ralhearte: r ever had heart problems as of last ivw"
label values ralhearte yesnodr

***ever had heart attack last ivw***
*respondent wave 2 ever had heart attack last ivw
gen ralhrtatte = .
replace ralhrtatte = r1hrtatte if ralstcore==1
label variable ralhrtatte "ralhrtatte: r ever had heart attack as of last ivw"
label values ralhrtatte yesnodr

***ever had stroke last ivw***
*respondent wave 2 ever had stroke last ivw
gen ralstroke = .
replace ralstroke = r1stroke if ralstcore==1
label variable ralstroke "ralstroke: r ever had stroke as of last ivw"
label values ralstroke yesnodr

***ever had diabetes last ivw***
*respondent wave 2 ever had diabetes last ivw
gen raldiabe = .
replace raldiabe = r1diabe if ralstcore==1
label variable raldiabe "raldiabe: r ever had diabetes as of last ivw"
label values raldiabe yesnodr

***ever had high bp last ivw***
*respondent wave 2 ever had high bp last ivw
gen ralhibpe = .
replace ralhibpe = r1hibpe if ralstcore==1
label variable ralhibpe "ralhibpe: r ever had high blood pressure as of last ivw"
label values ralhibpe yesnodr

***ever had memory problems last ivw***
*respondent wave 2 ever had memory problems last ivw
gen ralmemrye = .
missing_w2 r1alzhe r1demene if inw`wv'xt==1, result(ralmemrye)
replace ralmemrye = 0 if (r1alzhe==0 | r1demene==0) & ralstcore==1
replace ralmemrye = 1 if (r1alzhe==1 | r1demene==1) & ralstcore==1
label variable ralmemrye "ralmemrye: r ever had memory-related disease as of last ivw"
label values ralmemrye yesnodr


***ever had cancer***
*respondent wave 2 ever had cancer
gen raxcancre = .
missing_w2 EiDiaB5 EiDiaB96 if inw`wv'xt==1, result(raxcancre)
replace raxcancre = 0 if EiDiaB5==0 | EiDiaB96==1
replace raxcancre = 1 if EiDiaB5==1 | ralcancre==1
label variable raxcancre "raxcancre: r ever had cancer in lifetime"
label values raxcancre yesnodr

***cancer since last ivw***
*respondent wave 2 cancer since last ivw
gen raxcancr = .
missing_w2 raxcancre ralcancre if inw`wv'xt==1, result(raxcancr)
replace raxcancr = 0 if (raxcancre==0 | (raxcancre==1 & ralcancre==1)) & inw`wv'xt==1
replace raxcancr = 1 if (raxcancre==1 & ralcancre==0) & inw`wv'xt==1
label variable raxcancr "raxcancr: r new report of cancer since last ivw"
label values raxcancr yesnodr

***ever had lung disease***
*respondent wave 2 ever had lung disease
gen raxlunge = .
missing_w2 EiDiaB1 EiDiaB96 if inw`wv'xt==1, result(raxlunge)
replace raxlunge = 0 if EiDiaB1==0 | EiDiaB96==1
replace raxlunge = 1 if EiDiaB1==1 | rallunge==1
label variable raxlunge "raxlunge: r ever had lung disease in lifetime"
label values raxlunge yesnodr

***lung disease since last ivw***
*respondent wave 2 lung disease since last ivw
gen raxlung = .
missing_w2 raxlunge rallunge if inw`wv'xt==1, result(raxlung)
replace raxlung = 0 if (raxlunge==0 | (raxlunge==1 & rallunge==1)) & inw`wv'xt==1
replace raxlung = 1 if (raxlunge==1 & rallunge==0) & inw`wv'xt==1
label variable raxlung "raxlung: r new report of lung disease since last ivw"
label values raxlung yesnodr

***ever had heart problems***
*respondent wave 2 ever had heart problems
gen raxhearte = .
missing_w2 EiDiaA2 EiDiaA3 EiDiaA4 EiDiaA5 EiDiaA6 EiDiaA95 EiDiaA96 if inw`wv'xt==1, result(raxhearte)
replace raxhearte = 0 if EiDiaA2==0 | EiDiaA3==0 | EiDiaA4==0 | EiDiaA5==0 | EiDiaA6==0 | EiDiaA95==0 | EiDiaB96==1
replace raxhearte = 1 if EiDiaA2==1 | EiDiaA3==1 | EiDiaA4==1 | EiDiaA5==1 | EiDiaA6==1 | EiDiaA95==1 | ralhearte==1
label variable raxhearte "raxhearte: r ever had heart problems in lifetime"
label values raxhearte yesnodr

***heart problems since last ivw***
*respondent wave 2 heart problems since last ivw
gen raxheart = .
missing_w2 raxhearte ralhearte if inw`wv'xt==1, result(raxheart)
replace raxheart = 0 if (raxhearte==0 | (raxhearte==1 & ralhearte==1)) & inw`wv'xt==1
replace raxheart = 1 if (raxhearte==1 & ralhearte==0) & inw`wv'xt==1
label variable raxheart "raxheart: r new report of heart problems since last ivw"
label values raxheart yesnodr

***ever had heart attack***
*respondent wave 2 ever had heart attack
gen raxhrtatte = .
missing_w2 EiDiaA3 EiDiaA96 if inw`wv'xt==1, result(raxhrtatte)
replace raxhrtatte = 0 if EiDiaA3==0 | EiDiaA96==1
replace raxhrtatte = 1 if EiDiaA3==1 | ralhrtatte==1
label variable raxhrtatte "raxhrtatte: r ever had heart attack in lifetime"
label values raxhrtatte yesnodr

***heart attack since last ivw***
*respondent wave 2 heart attack since last ivw
gen raxhrtatt = .
missing_w2 raxhrtatte ralhrtatte if inw`wv'xt==1, result(raxhrtatt)
replace raxhrtatt = 0 if (raxhrtatte==0 | (raxhrtatte==1 & ralhrtatte==1)) & inw`wv'xt==1
replace raxhrtatt = 1 if (raxhrtatte==1 & ralhrtatte==0) & inw`wv'xt==1
label variable raxhrtatt "raxhrtatt: r new report of heart attack since last ivw"
label values raxhrtatt yesnodr

***ever had stroke***
*respondent wave 2 ever had stroke
gen raxstroke = .
missing_w2 EiDiaA8 EiDiaA96 if inw`wv'xt==1, result(raxstroke)
replace raxstroke = 0 if EiDiaA8==0 | EiDiaA96==1
replace raxstroke = 1 if EiDiaA8==1 | ralstroke==1
label variable raxstroke "raxstroke: r ever had stroke in lifetime"
label values raxstroke yesnodr

***stroke since last ivw***
*respondent wave 2 stroke since last ivw
gen raxstrok = .
missing_w2 raxstroke ralstroke if inw`wv'xt==1, result(raxstrok)
replace raxstrok = 0 if (raxstroke==0 | (raxstroke==1 & ralstroke==1)) & inw`wv'xt==1
replace raxstrok = 1 if (raxstroke==1 & ralstroke==0) & inw`wv'xt==1
label variable raxstrok "raxstrok: r new report of stroke since last ivw"
label values raxstrok yesnodr

***ever had diabetes***
*respondent wave 2 ever had diabetes
gen raxdiabe = .
missing_w2 EiDiaA7 EiDiaA96 if inw`wv'xt==1, result(raxdiabe)
replace raxdiabe = 0 if EiDiaA7==0 | EiDiaA96==1
replace raxdiabe = 1 if EiDiaA7==1 | raldiabe==1
label variable raxdiabe "raxdiabe: r ever had diabetes in lifetime"
label values raxdiabe yesnodr

***diabetes since last ivw***
*respondent wave 2 diabetes since last ivw
gen raxdiab = .
missing_w2 raxdiabe raldiabe if inw`wv'xt==1, result(raxdiab)
replace raxdiab = 0 if (raxdiabe==0 | (raxdiabe==1 & raldiabe==1)) & inw`wv'xt==1
replace raxdiab = 1 if (raxdiabe==1 & raldiabe==0) & inw`wv'xt==1
label variable raxdiab "raxdiab: r new report of diabetes since last ivw"
label values raxdiab yesnodr

***ever had memory-related disease***
*respondent wave 2 ever had memory-related disease
gen raxmemrye = .
missing_w2 EiDiaB8 EiDiaB9 EiDiaB96 if inw`wv'xt==1, result(raxmemrye)
replace raxmemrye = 0 if EiDiaB8==0 | EiDiaB9==0 | EiDiaB96==1
replace raxmemrye = 1 if EiDiaB8==1 | EiDiaB9==1 | ralmemrye==1
label variable raxmemrye "raxmemrye: r ever had memory-related disease in lifetime"
label values raxmemrye yesnodr

***memory-related disease since last ivw***
*respondent wave 2 memory-related disease since last ivw
gen raxmemry = .
missing_w2 raxmemrye ralmemrye if inw`wv'xt==1, result(raxmemry)
replace raxmemry = 0 if (raxmemrye==0 | (raxmemrye==1 & ralmemrye==1)) & inw`wv'xt==1
replace raxmemry = 1 if (raxmemrye==1 & ralmemrye==0) & inw`wv'xt==1
label variable raxmemry "raxmemry: r new report of memory-related disease since last ivw"
label values raxmemry yesnodr





***drop ELSA wave 2 exit file raw variables***
drop `healthxt_w2_exit'

****drop h_elsa variables***
drop `healthxt_w2_helsa'


******************************************************************************************


*set wave number
local wv=3
local pre_wv=2

****merge with wave 3 h_elsa data***
local healthxt_w3_helsa r1diabe r2diabe r1cancre r2cancre r1lunge r2lunge r1hearte r2hearte /// 
											  r1hrtatte r2hrtatte r1stroke r2stroke r1hibpe r2hibpe ///
											  r1alzhe r2alzhe r1demene r2demene 
merge 1:1 idauniq using "$h_elsa", keepusing(`healthxt_w3_helsa') nogen

****merge with wave 3 exit data***
local healthxt_w3_exit EiCaHa EiCaSt EiCaCa EiDiaA2 EiDiaA3 EiDiaA4 EiDiaA5 EiDiaA6 EiDiaA7 EiDiaA8 ///
											 EiDiaA95 EiDiaA96 EiDiaB1 EiDiaB5 EiDiaB8 EiDiaB9 EiDiaB96  
merge 1:1 idauniq using "$wave_3_xt", keepusing(`healthxt_w3_exit') nogen




***ever had cancer last ivw***
*respondent wave 3 ever had cancer last ivw
forvalues v = 1/2 {
	replace ralcancre = r`v'cancre if ralstcore==`v'
}

***ever had lung disease last ivw***
*respondent wave 3 ever had lung disease last ivw
forvalues v = 1/2 {
	replace rallunge = r`v'lunge if ralstcore==`v'
}

***ever had heart problems last ivw***
*respondent wave 3 ever had heart problems last ivw
forvalues v = 1/2 {
	replace ralhearte = r`v'hearte if ralstcore==`v'
}

***ever had heart attack last ivw***
*respondent wave 3 ever had heart attack last ivw
forvalues v = 1/2 {
	replace ralhrtatte = r`v'hrtatte if ralstcore==`v'
}

***ever had stroke last ivw***
*respondent wave 3 ever had stroke last ivw
forvalues v = 1/2 {
	replace ralstroke = r`v'stroke if ralstcore==`v'
}

***ever had diabetes last ivw***
*respondent wave 3 ever had diabetes last ivw
forvalues v = 1/2 {
	replace raldiabe = r`v'diabe if ralstcore==`v'
}

***ever had high bp last ivw***
*respondent wave 3 ever had high bp last ivw
forvalues v = 1/2 {
	replace ralhibpe = r`v'hibpe if ralstcore==`v'
}

***ever had memory problems last ivw***
*respondent wave 3 ever had memory problems last ivw
forvalues v = 1/2 {
	missing_w3 r`v'alzhe r`v'demene if ralstcore==`v', result(ralmemrye)
	replace ralmemrye = 0 if (r`v'alzhe==0 | r`v'demene==0) & ralstcore==`v'
	replace ralmemrye = 1 if (r`v'alzhe==1 | r`v'demene==1) & ralstcore==`v'
}


***ever had cancer***
*respondent wave 3 ever had cancer
missing_w3 EiDiaB5 EiDiaB96 if inw`wv'xt==1, result(raxcancre)
replace raxcancre = 0 if EiDiaB5==0 | EiDiaB96==1
replace raxcancre = 1 if EiDiaB5==1 | ralcancre==1

***cancer since last ivw***
*respondent wave 3 cancer since last ivw
missing_w3 raxcancre ralcancre if inw`wv'xt==1, result(raxcancr)
replace raxcancr = 0 if (raxcancre==0 | (raxcancre==1 & ralcancre==1)) & inw`wv'xt==1
replace raxcancr = 1 if (raxcancre==1 & ralcancre==0) & inw`wv'xt==1

***ever had lung disease***
*respondent wave 3 ever had lung disease
missing_w3 EiDiaB1 EiDiaB96 if inw`wv'xt==1, result(raxlunge)
replace raxlunge = 0 if EiDiaB1==0 | EiDiaB96==1
replace raxlunge = 1 if EiDiaB1==1 | rallunge==1

***lung disease since last ivw***
*respondent wave 3 lung disease since last ivw
missing_w3 raxlunge rallunge if inw`wv'xt==1, result(raxlung)
replace raxlung = 0 if (raxlunge==0 | (raxlunge==1 & rallunge==1)) & inw`wv'xt==1
replace raxlung = 1 if (raxlunge==1 & rallunge==0) & inw`wv'xt==1

***ever had heart problems***
*respondent wave 3 ever had heart problems
missing_w3 EiDiaA2 EiDiaA3 EiDiaA4 EiDiaA5 EiDiaA6 EiDiaA95 EiDiaA96 if inw`wv'xt==1, result(raxhearte)
replace raxhearte = 0 if EiDiaA2==0 | EiDiaA3==0 | EiDiaA4==0 | EiDiaA5==0 | EiDiaA6==0 | EiDiaA95==0 | EiDiaB96==1
replace raxhearte = 1 if EiDiaA2==1 | EiDiaA3==1 | EiDiaA4==1 | EiDiaA5==1 | EiDiaA6==1 | EiDiaA95==1 | ralhearte==1

***heart problems since last ivw***
*respondent wave 3 heart problems since last ivw
missing_w3 raxhearte ralhearte if inw`wv'xt==1, result(raxheart)
replace raxheart = 0 if (raxhearte==0 | (raxhearte==1 & ralhearte==1)) & inw`wv'xt==1
replace raxheart = 1 if (raxhearte==1 & ralhearte==0) & inw`wv'xt==1

***ever had heart attack***
*respondent wave 3 ever had heart attack
missing_w3 EiDiaA3 EiDiaA96 if inw`wv'xt==1, result(raxhrtatte)
replace raxhrtatte = 0 if EiDiaA3==0 | EiDiaA96==1
replace raxhrtatte = 1 if EiDiaA3==1 | ralhrtatte==1

***heart attack since last ivw***
*respondent wave 3 heart attack since last ivw
missing_w3 raxhrtatte ralhrtatte if inw`wv'xt==1, result(raxhrtatt)
replace raxhrtatt = 0 if (raxhrtatte==0 | (raxhrtatte==1 & ralhrtatte==1)) & inw`wv'xt==1
replace raxhrtatt = 1 if (raxhrtatte==1 & ralhrtatte==0) & inw`wv'xt==1

***ever had stroke***
*respondent wave 3 ever had stroke
missing_w3 EiDiaA8 EiDiaA96 if inw`wv'xt==1, result(raxstroke)
replace raxstroke = 0 if EiDiaA8==0 | EiDiaA96==1
replace raxstroke = 1 if EiDiaA8==1 | ralstroke==1

***stroke since last ivw***
*respondent wave 3 stroke since last ivw
missing_w3 raxstroke ralstroke if inw`wv'xt==1, result(raxstrok)
replace raxstrok = 0 if (raxstroke==0 | (raxstroke==1 & ralstroke==1)) & inw`wv'xt==1
replace raxstrok = 1 if (raxstroke==1 & ralstroke==0) & inw`wv'xt==1

***ever had diabetes***
*respondent wave 3 ever had diabetes
missing_w3 EiDiaA7 EiDiaA96 if inw`wv'xt==1, result(raxdiabe)
replace raxdiabe = 0 if EiDiaA7==0 | EiDiaA96==1
replace raxdiabe = 1 if EiDiaA7==1 | raldiabe==1

***diabetes since last ivw***
*respondent wave 3 diabetes since last ivw
missing_w3 raxdiabe raldiabe if inw`wv'xt==1, result(raxdiab)
replace raxdiab = 0 if (raxdiabe==0 | (raxdiabe==1 & raldiabe==1)) & inw`wv'xt==1
replace raxdiab = 1 if (raxdiabe==1 & raldiabe==0) & inw`wv'xt==1

***ever had memory-related disease***
*respondent wave 3 ever had memory-related disease
missing_w3 EiDiaB8 EiDiaB9 EiDiaB96 if inw`wv'xt==1, result(raxmemrye)
replace raxmemrye = 0 if EiDiaB8==0 | EiDiaB9==0 | EiDiaB96==1
replace raxmemrye = 1 if EiDiaB8==1 | EiDiaB9==1 | ralmemrye==1

***memory-related disease since last ivw***
*respondent wave 3 memory-related disease since last ivw
missing_w3 raxmemrye ralmemrye if inw`wv'xt==1, result(raxmemry)
replace raxmemry = 0 if (raxmemrye==0 | (raxmemrye==1 & ralmemrye==1)) & inw`wv'xt==1
replace raxmemry = 1 if (raxmemrye==1 & ralmemrye==0) & inw`wv'xt==1





***drop ELSA wave 3 exit file raw variables***
drop `healthxt_w3_exit'

****drop h_elsa variables***
drop `healthxt_w3_helsa'


******************************************************************************************


*set wave number
local wv=4
local pre_wv=3

****merge with wave 4 h_elsa data***
local healthxt_w4_helsa r1diabe r2diabe r3diabe r1cancre r2cancre r3cancre r1lunge r2lunge r3lunge ///
												r1hearte r2hearte r3hearte r1hrtatte r2hrtatte r3hrtatte r1stroke r2stroke r3stroke ///
												r1hibpe r2hibpe r3hibpe r1alzhe r2alzhe r3alzhe r1demene r2demene r3demene 
merge 1:1 idauniq using "$h_elsa", keepusing(`healthxt_w4_helsa') nogen

****merge with wave 4 exit data***
local healthxt_w4_exit EiCaHa EiCaSt EiCaCa EiDiaA2 EiDiaA3 EiDiaA4 EiDiaA5 EiDiaA6 EiDiaA7 EiDiaA8 ///
											 EiDiaA95 EiDiaA96 EiDiaB1 EiDiaB5 EiDiaB8 EiDiaB9 EiDiaB10 EiDiaB96  
merge 1:1 idauniq using "$w4_xt", keepusing(`healthxt_w4_exit') nogen




***ever had cancer last ivw***
*respondent wave 4 ever had cancer last ivw
forvalues v = 1/3 {
	replace ralcancre = r`v'cancre if ralstcore==`v'
}

***ever had lung disease last ivw***
*respondent wave 4 ever had lung disease last ivw
forvalues v = 1/3 {
	replace rallunge = r`v'lunge if ralstcore==`v'
}

***ever had heart problems last ivw***
*respondent wave 4 ever had heart problems last ivw
forvalues v = 1/3 {
	replace ralhearte = r`v'hearte if ralstcore==`v'
}

***ever had heart attack last ivw***
*respondent wave 4 ever had heart attack last ivw
forvalues v = 1/3 {
	replace ralhrtatte = r`v'hrtatte if ralstcore==`v'
}

***ever had stroke last ivw***
*respondent wave 4 ever had stroke last ivw
forvalues v = 1/3 {
	replace ralstroke = r`v'stroke if ralstcore==`v'
}

***ever had diabetes last ivw***
*respondent wave 4 ever had diabetes last ivw
forvalues v = 1/3 {
	replace raldiabe = r`v'diabe if ralstcore==`v'
}

***ever had high bp last ivw***
*respondent wave 4 ever had high bp last ivw
forvalues v = 1/3 {
	replace ralhibpe = r`v'hibpe if ralstcore==`v'
}

***ever had memory problems last ivw***
*respondent wave 4 ever had memory problems last ivw
forvalues v = 1/3 {
	missing_w4 r`v'alzhe r`v'demene if ralstcore==`v', result(ralmemrye)
	replace ralmemrye = 0 if (r`v'alzhe==0 | r`v'demene==0) & ralstcore==`v'
	replace ralmemrye = 1 if (r`v'alzhe==1 | r`v'demene==1) & ralstcore==`v'
}


***ever had cancer***
*respondent wave 4 ever had cancer
missing_w4 EiDiaB5 EiDiaB10 EiDiaB96 if inw`wv'xt==1, result(raxcancre)
replace raxcancre = 0 if EiDiaB5==0 | EiDiaB10==0 | EiDiaB96==1
replace raxcancre = 1 if EiDiaB5==1 | EiDiaB10==1 | ralcancre==1

***cancer since last ivw***
*respondent wave 4 cancer since last ivw
missing_w4 raxcancre ralcancre if inw`wv'xt==1, result(raxcancr)
replace raxcancr = 0 if (raxcancre==0 | (raxcancre==1 & ralcancre==1)) & inw`wv'xt==1
replace raxcancr = 1 if (raxcancre==1 & ralcancre==0) & inw`wv'xt==1

***ever had lung disease***
*respondent wave 4 ever had lung disease
missing_w4 EiDiaB1 EiDiaB96 if inw`wv'xt==1, result(raxlunge)
replace raxlunge = 0 if EiDiaB1==0 | EiDiaB96==1
replace raxlunge = 1 if EiDiaB1==1 | rallunge==1

***lung disease since last ivw***
*respondent wave 4 lung disease since last ivw
missing_w4 raxlunge rallunge if inw`wv'xt==1, result(raxlung)
replace raxlung = 0 if (raxlunge==0 | (raxlunge==1 & rallunge==1)) & inw`wv'xt==1
replace raxlung = 1 if (raxlunge==1 & rallunge==0) & inw`wv'xt==1

***ever had heart problems***
*respondent wave 4 ever had heart problems
missing_w4 EiDiaA2 EiDiaA3 EiDiaA4 EiDiaA5 EiDiaA6 EiDiaA95 EiDiaA96 if inw`wv'xt==1, result(raxhearte)
replace raxhearte = 0 if EiDiaA2==0 | EiDiaA3==0 | EiDiaA4==0 | EiDiaA5==0 | EiDiaA6==0 | EiDiaA95==0 | EiDiaB96==1
replace raxhearte = 1 if EiDiaA2==1 | EiDiaA3==1 | EiDiaA4==1 | EiDiaA5==1 | EiDiaA6==1 | EiDiaA95==1 | ralhearte==1

***heart problems since last ivw***
*respondent wave 4 heart problems since last ivw
missing_w4 raxhearte ralhearte if inw`wv'xt==1, result(raxheart)
replace raxheart = 0 if (raxhearte==0 | (raxhearte==1 & ralhearte==1)) & inw`wv'xt==1
replace raxheart = 1 if (raxhearte==1 & ralhearte==0) & inw`wv'xt==1

***ever had heart attack***
*respondent wave 4 ever had heart attack
missing_w4 EiDiaA3 EiDiaA96 if inw`wv'xt==1, result(raxhrtatte)
replace raxhrtatte = 0 if EiDiaA3==0 | EiDiaA96==1
replace raxhrtatte = 1 if EiDiaA3==1 | ralhrtatte==1

***heart attack since last ivw***
*respondent wave 4 heart attack since last ivw
missing_w4 raxhrtatte ralhrtatte if inw`wv'xt==1, result(raxhrtatt)
replace raxhrtatt = 0 if (raxhrtatte==0 | (raxhrtatte==1 & ralhrtatte==1)) & inw`wv'xt==1
replace raxhrtatt = 1 if (raxhrtatte==1 & ralhrtatte==0) & inw`wv'xt==1

***ever had stroke***
*respondent wave 4 ever had stroke
missing_w4 EiDiaA8 EiDiaA96 if inw`wv'xt==1, result(raxstroke)
replace raxstroke = 0 if EiDiaA8==0 | EiDiaA96==1
replace raxstroke = 1 if EiDiaA8==1 | ralstroke==1

***stroke since last ivw***
*respondent wave 4 stroke since last ivw
missing_w4 raxstroke ralstroke if inw`wv'xt==1, result(raxstrok)
replace raxstrok = 0 if (raxstroke==0 | (raxstroke==1 & ralstroke==1)) & inw`wv'xt==1
replace raxstrok = 1 if (raxstroke==1 & ralstroke==0) & inw`wv'xt==1

***ever had diabetes***
*respondent wave 4 ever had diabetes
missing_w4 EiDiaA7 EiDiaA96 if inw`wv'xt==1, result(raxdiabe)
replace raxdiabe = 0 if EiDiaA7==0 | EiDiaA96==1
replace raxdiabe = 1 if EiDiaA7==1 | raldiabe==1

***diabetes since last ivw***
*respondent wave 4 diabetes since last ivw
missing_w4 raxdiabe raldiabe if inw`wv'xt==1, result(raxdiab)
replace raxdiab = 0 if (raxdiabe==0 | (raxdiabe==1 & raldiabe==1)) & inw`wv'xt==1
replace raxdiab = 1 if (raxdiabe==1 & raldiabe==0) & inw`wv'xt==1

***ever had memory-related disease***
*respondent wave 4 ever had memory-related disease
missing_w4 EiDiaB8 EiDiaB9 EiDiaB96 if inw`wv'xt==1, result(raxmemrye)
replace raxmemrye = 0 if EiDiaB8==0 | EiDiaB9==0 | EiDiaB96==1
replace raxmemrye = 1 if EiDiaB8==1 | EiDiaB9==1 | ralmemrye==1

***memory-related disease since last ivw***
*respondent wave 4 memory-related disease since last ivw
missing_w4 raxmemrye ralmemrye if inw`wv'xt==1, result(raxmemry)
replace raxmemry = 0 if (raxmemrye==0 | (raxmemrye==1 & ralmemrye==1)) & inw`wv'xt==1
replace raxmemry = 1 if (raxmemrye==1 & ralmemrye==0) & inw`wv'xt==1





***drop ELSA wave 4 exit file raw variables***
drop `healthxt_w4_exit'

****drop h_elsa variables***
drop `healthxt_w4_helsa'


******************************************************************************************


*set wave number
local wv=6
local pre_wv=5

****merge with wave 6 h_elsa data***
local healthxt_w6_helsa r1diabe r2diabe r3diabe r4diabe r5diabe ///
												r1cancre r2cancre r3cancre r4cancre r5cancre ///
												r1lunge r2lunge r3lunge r4lunge r5lunge ///
												r1hearte r2hearte r3hearte r4hearte r5hearte ///
												r1hrtatte r2hrtatte r3hrtatte r4hrtatte r5hrtatte /// 
											  r1stroke r2stroke r3stroke r4stroke r5stroke ///
											  r1hibpe r2hibpe r3hibpe r4hibpe r5hibpe ///
											  r1alzhe r2alzhe r3alzhe r4alzhe r5alzhe ///
											  r1demene r2demene r3demene r4demene r5demene 
merge 1:1 idauniq using "$h_elsa", keepusing(`healthxt_w6_helsa') nogen

****merge with wave 6 exit data***
local healthxt_w6_exit EiCaHa EiCaSt EiCaCa EiDiaA2 EiDiaA3 EiDiaA4 EiDiaA5 EiDiaA6 EiDiaA7 EiDiaA8 ///
											 EiDiaA95 EiDiaA96 EiDiaB1 EiDiaB5 EiDiaB8 EiDiaB9 EiDiaB10 EiDiaB96  
merge 1:1 idauniq using "$wave_6_xt", keepusing(`healthxt_w6_exit') nogen




***ever had cancer last ivw***
*respondent wave 6 ever had cancer last ivw
forvalues v = 1/5 {
	replace ralcancre = r`v'cancre if ralstcore==`v'
}

***ever had lung disease last ivw***
*respondent wave 6 ever had lung disease last ivw
forvalues v = 1/5 {
	replace rallunge = r`v'lunge if ralstcore==`v'
}

***ever had heart problems last ivw***
*respondent wave 6 ever had heart problems last ivw
forvalues v = 1/5 {
	replace ralhearte = r`v'hearte if ralstcore==`v'
}

***ever had heart attack last ivw***
*respondent wave 6 ever had heart attack last ivw
forvalues v = 1/5 {
	replace ralhrtatte = r`v'hrtatte if ralstcore==`v'
}

***ever had stroke last ivw***
*respondent wave 6 ever had stroke last ivw
forvalues v = 1/5 {
	replace ralstroke = r`v'stroke if ralstcore==`v'
}

***ever had diabetes last ivw***
*respondent wave 6 ever had diabetes last ivw
forvalues v = 1/5 {
	replace raldiabe = r`v'diabe if ralstcore==`v'
}

***ever had high bp last ivw***
*respondent wave 6 ever had high bp last ivw
forvalues v = 1/5 {
	replace ralhibpe = r`v'hibpe if ralstcore==`v'
}

***ever had memory problems last ivw***
*respondent wave 6 ever had memory problems last ivw
forvalues v = 1/5 {
	missing_w6 r`v'alzhe r`v'demene if ralstcore==`v', result(ralmemrye)
	replace ralmemrye = 0 if (r`v'alzhe==0 | r`v'demene==0) & ralstcore==`v'
	replace ralmemrye = 1 if (r`v'alzhe==1 | r`v'demene==1) & ralstcore==`v'
}


***ever had cancer***
*respondent wave 6 ever had cancer
missing_w6 EiDiaB5 EiDiaB10 EiDiaB96 if inw`wv'xt==1, result(raxcancre)
replace raxcancre = 0 if EiDiaB5==0 | EiDiaB10==0 | EiDiaB96==1
replace raxcancre = 1 if EiDiaB5==1 | EiDiaB10==1 | ralcancre==1

***cancer since last ivw***
*respondent wave 6 cancer since last ivw
missing_w6 raxcancre ralcancre if inw`wv'xt==1, result(raxcancr)
replace raxcancr = 0 if (raxcancre==0 | (raxcancre==1 & ralcancre==1)) & inw`wv'xt==1
replace raxcancr = 1 if (raxcancre==1 & ralcancre==0) & inw`wv'xt==1

***ever had lung disease***
*respondent wave 6 ever had lung disease
missing_w6 EiDiaB1 EiDiaB96 if inw`wv'xt==1, result(raxlunge)
replace raxlunge = 0 if EiDiaB1==0 | EiDiaB96==1
replace raxlunge = 1 if EiDiaB1==1 | rallunge==1

***lung disease since last ivw***
*respondent wave 6 lung disease since last ivw
missing_w6 raxlunge rallunge if inw`wv'xt==1, result(raxlung)
replace raxlung = 0 if (raxlunge==0 | (raxlunge==1 & rallunge==1)) & inw`wv'xt==1
replace raxlung = 1 if (raxlunge==1 & rallunge==0) & inw`wv'xt==1

***ever had heart problems***
*respondent wave 6 ever had heart problems
missing_w6 EiDiaA2 EiDiaA3 EiDiaA4 EiDiaA5 EiDiaA6 EiDiaA95 EiDiaA96 if inw`wv'xt==1, result(raxhearte)
replace raxhearte = 0 if EiDiaA2==0 | EiDiaA3==0 | EiDiaA4==0 | EiDiaA5==0 | EiDiaA6==0 | EiDiaA95==0 | EiDiaB96==1
replace raxhearte = 1 if EiDiaA2==1 | EiDiaA3==1 | EiDiaA4==1 | EiDiaA5==1 | EiDiaA6==1 | EiDiaA95==1 | ralhearte==1

***heart problems since last ivw***
*respondent wave 6 heart problems since last ivw
missing_w6 raxhearte ralhearte if inw`wv'xt==1, result(raxheart)
replace raxheart = 0 if (raxhearte==0 | (raxhearte==1 & ralhearte==1)) & inw`wv'xt==1
replace raxheart = 1 if (raxhearte==1 & ralhearte==0) & inw`wv'xt==1

***ever had heart attack***
*respondent wave 6 ever had heart attack
missing_w6 EiDiaA3 EiDiaA96 if inw`wv'xt==1, result(raxhrtatte)
replace raxhrtatte = 0 if EiDiaA3==0 | EiDiaA96==1
replace raxhrtatte = 1 if EiDiaA3==1 | ralhrtatte==1

***heart attack since last ivw***
*respondent wave 6 heart attack since last ivw
missing_w6 raxhrtatte ralhrtatte if inw`wv'xt==1, result(raxhrtatt)
replace raxhrtatt = 0 if (raxhrtatte==0 | (raxhrtatte==1 & ralhrtatte==1)) & inw`wv'xt==1
replace raxhrtatt = 1 if (raxhrtatte==1 & ralhrtatte==0) & inw`wv'xt==1

***ever had stroke***
*respondent wave 6 ever had stroke
missing_w6 EiDiaA8 EiDiaA96 if inw`wv'xt==1, result(raxstroke)
replace raxstroke = 0 if EiDiaA8==0 | EiDiaA96==1
replace raxstroke = 1 if EiDiaA8==1 | ralstroke==1

***stroke since last ivw***
*respondent wave 6 stroke since last ivw
missing_w6 raxstroke ralstroke if inw`wv'xt==1, result(raxstrok)
replace raxstrok = 0 if (raxstroke==0 | (raxstroke==1 & ralstroke==1)) & inw`wv'xt==1
replace raxstrok = 1 if (raxstroke==1 & ralstroke==0) & inw`wv'xt==1

***ever had diabetes***
*respondent wave 6 ever had diabetes
missing_w6 EiDiaA7 EiDiaA96 if inw`wv'xt==1, result(raxdiabe)
replace raxdiabe = 0 if EiDiaA7==0 | EiDiaA96==1
replace raxdiabe = 1 if EiDiaA7==1 | raldiabe==1

***diabetes since last ivw***
*respondent wave 6 diabetes since last ivw
missing_w6 raxdiabe raldiabe if inw`wv'xt==1, result(raxdiab)
replace raxdiab = 0 if (raxdiabe==0 | (raxdiabe==1 & raldiabe==1)) & inw`wv'xt==1
replace raxdiab = 1 if (raxdiabe==1 & raldiabe==0) & inw`wv'xt==1

***ever had memory-related disease***
*respondent wave 6 ever had memory-related disease
missing_w6 EiDiaB8 EiDiaB9 EiDiaB96 if inw`wv'xt==1, result(raxmemrye)
replace raxmemrye = 0 if EiDiaB8==0 | EiDiaB9==0 | EiDiaB96==1
replace raxmemrye = 1 if EiDiaB8==1 | EiDiaB9==1 | ralmemrye==1

***memory-related disease since last ivw***
*respondent wave 6 memory-related disease since last ivw
missing_w6 raxmemrye ralmemrye if inw`wv'xt==1, result(raxmemry)
replace raxmemry = 0 if (raxmemrye==0 | (raxmemrye==1 & ralmemrye==1)) & inw`wv'xt==1
replace raxmemry = 1 if (raxmemrye==1 & ralmemrye==0) & inw`wv'xt==1





***drop ELSA wave 6 exit file raw variables***
drop `healthxt_w6_exit'

****drop h_elsa variables***
drop `healthxt_w6_helsa'


******************************************************************************************




label define stays ///
	0 "0.0 nights" ///
	1 "1.less than 1 week" ///
	2 "2.1 week to lt 1 month" ///
	3 "3.1 month to lt 3 months" ///
	4 "4.3 months to lt 6 months" ///
	5 "5.6 months to lt 1 year" ///
	6 "6.1 year or more" ///
	.x ".x:not applicable" ///
	.c ".c:continuous since entry" ///
	.q ".q:not asked this wave"
	
label define whocost ///
	1 "1.child" /// 
	2 "2.relative" ///
	3 "3.other" ///
	4 "4.child and relative" ///
	5 "5.child and other" ///
	.x ".x:not applicable" ///
	.h ".h:no help"
	
label define oopflag ///
	-1 "-1.not imputed, missing neighbors" ///
  -2 "-2.not imputed, missing covariates" ///
	1 "1.continuous value" ///
	2 "2.closed bracket" ///
	3 "3.open bracket" ///
	5 "5.no bracket info" ///
	6 "6.no expense" ///
	7 "7.dk had expense"
	
 

*set wave number
local wv=2
local pre_wv=1

local insxt_w2_exit EiPlac EiLive4 EiPlcN EiLHospA EiLHospB EiPlcL EiLive6 ///
										EiLNursA EiLNursB EiLive5 EiLHpceA EiLHpceB EiFAl EiFAu EiExpS ///
										EiPHI EiFHlp EiFWho1 EiFWho2 EiFWho95 EiFWho96 EiTol ///
										EiHPay1 EiHPay2 EiHPay3 EiHPay95 EiHPay96 EiLive2 EiLive7 EiLive91 ///
										EiLShelA EiLShelB EiLMixA EiLMixB EiLResA EiLResB 
merge 1:1 idauniq using "$wave_2_xt", keepusing(`insxt_w2_exit') nogen




***whether overnight hospital stays***
*wave 2 respondent whether overnight hospital stays
gen raxhosp = .
missing_w2 EiPlac EiLive4 if inw`wv'xt==1, result(raxhosp)
replace raxhosp = 0 if inrange(EiPlac,1,3) | inrange(EiPlac,5,96) | EiLive4==0
replace raxhosp = 1 if EiPlac==4 | EiLive4==1
label variable raxhosp "raxhosp: r any hospital stay prev 2 yrs"
label values raxhosp yesno


***number overnight hospital stays***
*wave 2 respondent number overnight hospital stays
gen raxhsptim = .
missing_w2 raxhosp EiPlcN EiLHospA if inw`wv'xt==1, result(raxhsptim)
replace raxhsptim = 0 if raxhosp==0 & inw`wv'xt==1
replace raxhsptim = EiPlcN if inrange(EiPlcN,1,90) & EiPlac==4
replace raxhsptim = EiLHospA if inrange(EiLHospA,1,90) & EiLive4==1
label variable raxhsptim "raxhsptim: r # hospital stays prev 2 yrs"


***number nights in hospital grouped***
*wave 2 respondent number nights in hospital grouped
gen raxhspnitd = .
missing_w2 raxhosp EiPlcL EiLHospB if inw`wv'xt==1, result(raxhspnitd)
replace raxhspnitd = .d if EiPlcL==8 | EiLHospB==8
replace raxhspnitd = 0 if raxhosp==0 & inw`wv'xt==1
replace raxhspnitd = 1 if (inlist(EiPlcL,1,2) & EiPlac==4) | (inlist(EiLHospB,1,2) & EiLive4==1)
replace raxhspnitd = 2 if (EiPlcL==3 & EiPlac==4) | (EiLHospB==3 & EiLive4==1)
replace raxhspnitd = 3 if (EiPlcL==4 & EiPlac==4) | (EiLHospB==4 & EiLive4==1)
replace raxhspnitd = 4 if (EiPlcL==5 & EiPlac==4) | (EiLHospB==5 & EiLive4==1)
replace raxhspnitd = 5 if (EiPlcL==6 & EiPlac==4) | (EiLHospB==6 & EiLive4==1)
replace raxhspnitd = 6 if (EiPlcL==7 & EiPlac==4) | (EiLHospB==7 & EiLive4==1)
label variable raxhspnitd "raxhspnitd: r total duration hospital stays prev 2 yrs"
label values raxhspnitd stays


***whether nursing home stays***
*wave 2 respondent whether nursing home stays
gen raxnrshom = .
missing_w2 EiLive6 EiLive91 EiLive7 EiLive2 EiPlac if inw`wv'xt==1, result(raxnrshom)
replace raxnrshom = 0 if inlist(EiPlac,1,3,4,5) | inrange(EiPlac,9,96) | ///
													EiLive6==0 | EiLive91==0 | EiLive7==0 | EiLive2==0
replace raxnrshom = 1 if inlist(EiPlac,2,6,7,8) | EiLive6==1 | EiLive91==1 | EiLive7==1 | EiLive2==1
label variable raxnrshom "raxnrshom: r any nursing home stay prev 2 yrs"
label values raxnrshom yesno


***number nursing home stays***
*wave 2 respondent number nursing home stays
gen nhms = 0 if inw`wv'xt==1
replace nhms = EiLNursA if EiLive6==1 & inrange(EiLNursA,1,95)
replace nhms = EiPlcN if EiPlac==6 & inrange(EiPlcN,1,95)
gen rhms = 0 if inw`wv'xt==1
replace rhms = EiLResA if EiLive91==1 & inrange(EiLResA,1,95)
replace rhms = EiPlcN if EiPlac==7 & inrange(EiPlcN,1,95)
gen mixs = 0 if inw`wv'xt==1
replace mixs = EiLMixA if EiLive7==1 & inrange(EiLMixA,1,95)
replace mixs = EiPlcN if EiPlac==8 & inrange(EiPlcN,1,95)
gen shls = 0 if inw`wv'xt==1
replace shls = EiLShelA if EiLive2==1 & inrange(EiLShelA,1,95)
replace shls = EiPlcN if EiPlac==2 & inrange(EiPlcN,1,95)
gen sums = nhms + rhms + mixs + shls

gen raxnrstim = .
missing_w2 raxnrshom EiPlcN EiLNursA EiLResA EiLMixA EiLShelA if inw`wv'xt==1, result(raxnrstim)
replace raxnrstim = 0 if raxnrshom==0 & inw`wv'xt==1
replace raxnrstim = sums if !inlist(sums,0,.)
label variable raxnrstim "raxnrstim: r # nursing home stays prev 2 yrs"

drop nhms rhms mixs shls sums


***number nights in nursing home grouped***
*wave 2 respondent number nights in nursing home grouped
gen nhmn = 0 if inw`wv'xt==1
replace nhmn = EiLNursB if EiLive6==1 & inrange(EiLNursB,1,7)
replace nhmn = EiPlcL if EiPlac==6 & inrange(EiPlcL,1,7)
gen rhmn = 0 if inw`wv'xt==1
replace rhmn = EiLResB if EiLive91==1 & inrange(EiLResB,1,7)
replace rhmn = EiPlcL if EiPlac==7 & inrange(EiPlcL,1,7)
gen mixn = 0 if inw`wv'xt==1
replace mixn = EiLMixB if EiLive7==1 & inrange(EiLMixB,1,7)
replace mixn = EiPlcL if EiPlac==8 & inrange(EiPlcL,1,7)
gen shln = 0 if inw`wv'xt==1
replace shln = EiLShelB if EiLive2==1 & inrange(EiLShelB,1,7)
replace shln = EiPlcL if EiPlac==2 & inrange(EiPlcL,1,7)

gen raxnrsnitd_e = .
missing_w2 raxnrshom EiPlcL EiLNursB EiLResB EiLMixB EiLShelB if inw`wv'xt==1, result(raxnrsnitd_e)
replace raxnrsnitd_e = .d if EiPlcL==8 | EiLNursB==8 | EiLResB==8 | EiLMixB==8 | EiLShelB==8
replace raxnrsnitd_e = 0 if raxnrshom==0 & inw`wv'xt==1
replace raxnrsnitd_e = 1 if inlist(nhmn,1,2) | inlist(rhmn,1,2) | inlist(mixn,1,2) | inlist(shln,1,2)
replace raxnrsnitd_e = 2 if nhmn==3 | rhmn==3 | mixn==3 | shln==3
replace raxnrsnitd_e = 3 if nhmn==4 | rhmn==4 | mixn==4 | shln==4
replace raxnrsnitd_e = 4 if nhmn==5 | rhmn==5 | mixn==5 | shln==5
replace raxnrsnitd_e = 5 if nhmn==6 | rhmn==6 | mixn==6 | shln==6
replace raxnrsnitd_e = 6 if nhmn==7 | rhmn==7 | mixn==7 | shln==7
label variable raxnrsnitd_e "raxnrsnitd_e: r longest duration nursing home stay prev 2 yrs"
label values raxnrsnitd_e stays

drop nhmn rhmn mixn shln


***whether overnight hospice stays***
*wave 2 respondent whether overnight hospice stays
gen raxhospice = .
missing_w2 EiPlac EiLive5 if inw`wv'xt==1, result(raxhospice)
replace raxhospice = 0 if inrange(EiPlac,1,4) | inrange(EiPlac,6,96) | EiLive5==0
replace raxhospice = 1 if EiPlac==5 | EiLive5==1
label variable raxhospice "raxhospice: r any hospice stay prev 2 yrs"
label values raxhospice yesno


***number overnight hospice stays***
*wave 2 number overnight hospice stays
gen raxhpctim = .
missing_w2 raxhospice EiPlcN EiLHpceA if inw`wv'xt==1, result(raxhpctim)
replace raxhpctim = 0 if raxhospice==0 & inw`wv'xt==1
replace raxhpctim = EiPlcN if inrange(EiPlcN,1,90) & EiPlac==5
replace raxhpctim = EiLHpceA if inrange(EiLHpceA,1,90) & EiLive5==1
label variable raxhpctim "raxhpctim: r # hospice stays prev 2 yrs"


***number nights in hospice grouped***
*wave 2 respondent number nights in hospice grouped 
gen raxhpcnitd = .
missing_w2 raxhospice EiPlcL EiLHpceB if inw`wv'xt==1, result(raxhpcnitd)
replace raxhpcnitd = .d if EiPlcL==8 | EiLHpceB==8
replace raxhpcnitd = 0 if raxhospice==0 & inw`wv'xt==1
replace raxhpcnitd = 1 if (inlist(EiPlcL,1,2) & EiPlac==5) | (inlist(EiLHpceB,1,2) & EiLive5==1)
replace raxhpcnitd = 2 if (EiPlcL==3 & EiPlac==5) | (EiLHpceB==3 & EiLive5==1)
replace raxhpcnitd = 3 if (EiPlcL==4 & EiPlac==5) | (EiLHpceB==4 & EiLive5==1)
replace raxhpcnitd = 4 if (EiPlcL==5 & EiPlac==5) | (EiLHpceB==5 & EiLive5==1)
replace raxhpcnitd = 5 if (EiPlcL==6 & EiPlac==5) | (EiLHpceB==6 & EiLive5==1)
replace raxhpcnitd = 6 if (EiPlcL==7 & EiPlac==5) | (EiLHpceB==7 & EiLive5==1)
label variable raxhpcnitd "raxhpcnitd: r total duration hospice stays prev 2 yrs"
label values raxhpcnitd stays


***hospital, hospice, or nursing home stays***
*wave 2 respondent hospital, hospice, or nursing home stays
gen raxhhnh = .
missing_w2 raxhosp raxnrshom raxhospice if inw`wv'xt==1, result(raxhhnh)
replace raxhhnh = 0 if (raxhosp==0 | raxnrshom==0 | raxhospice==0) & inw`wv'xt==1
replace raxhhnh = 1 if (raxhosp==1 | raxnrshom==1 | raxhospice==1) & inw`wv'xt==1
label variable raxhhnh "raxhhnh: r any hospital, hospice, or nursing home stays prev 2 yrs"
label values raxhhnh yesno

***number hospital, hospice, or nursing home stays***
*wave 2 respondent number hospital, hospice, or nursing home stays
egen timesm = rowmiss(raxhsptim raxnrstim raxhpctim) if inw`wv'xt==1
egen times = rowtotal(raxhsptim raxnrstim raxhpctim) if inrange(timesm,0,2),m

gen raxhhntim = .
missing_w2 raxhsptim raxnrstim raxhpctim if inw`wv'xt==1, result(raxhhntim)
replace raxhhntim = times if inrange(times,0,160) & inw`wv'xt==1
replace raxhhntim = .m if (raxhsptim==.m | raxnrstim==.m | raxhpctim==.m) & timesm==3 & inw`wv'xt==1
replace raxhhntim = .d if (raxhsptim==.d | raxnrstim==.d | raxhpctim==.d) & timesm==3 & inw`wv'xt==1
replace raxhhntim = .r if (raxhsptim==.r | raxnrstim==.r | raxhpctim==.r) & timesm==3 & inw`wv'xt==1
label variable raxhhntim "raxhhntim: r # hospital, hospice, or nursing home stays prev 2 yrs"

*wave 2 respondent missings
gen raxhhntimm = .
replace raxhhntimm = timesm if inrange(timesm,0,3) & inw`wv'xt==1
label variable raxhhntimm "raxhhntimm: r # missing hospital, hospice, or nursing home stays"

drop times timesm


****total oop major medical costs***
**wave 2 respondent total oop major medical costs
*gen eifal = EiFAl if inrange(EiFAl,0,100000)
*gen eifau = EiFAu if inrange(EiFAu,0,100000)
*
*gen eifao = .
*replace eifao = 0 if EiExpS==2 | inlist(EiPHI,1,4)
*replace eifao = 1 if EiExpS==1 & inlist(EiPHI,2,3)
*
*gen EiFA_ = .
**no values for EiFA
*
*gen raxoopmd = .
*label variable raxoopmd "raxoopmd: r oop cost: total major medical expenses"
*
*gen raxoopmdf = .
*label variable raxoopmdf "raxoopmdf: r oop cost flag: total major medical expenses"
*label values raxoopmdf oopflag


***whether anyone helped pay oop costs***
*wave 2 respondent whether anyone helped pay oop costs
gen raxoophelp = .
missing_w2 EiExpS EiPHI EiFHlp if inw`wv'xt==1, result(raxoophelp)
replace raxoophelp = .d if EiExpS==3 | EiFHlp==3
replace raxoophelp = .x if EiExpS==2 | (EiExpS==1 & inlist(EiPHI,1,4))
replace raxoophelp = 0 if EiFHlp==2
replace raxoophelp = 1 if EiFHlp==1
label variable raxoophelp "raxoophelp: r whether anyone helped pay oop costs"
label values raxoophelp yesno


***who helped pay oop costs***
*wave 2 respondent who helped pay oop costs
gen raxoopwho = .
missing_w2 raxoophelp EiFWho1 EiFWho2 EiFWho95 EiFWho96 if inw`wv'xt==1, result(raxoopwho)
replace raxoopwho = .d if EiFWho96==1
replace raxoopwho = .x if raxoophelp==.x & inw`wv'xt==1
replace raxoopwho = .h if raxoophelp==0 & inw`wv'xt==1
replace raxoopwho = 1 if EiFWho1==1
replace raxoopwho = 2 if EiFWho2==1
replace raxoopwho = 3 if EiFWho95==1
label variable raxoopwho "raxoopwho: r who helped pay oop costs"
label values raxoopwho whocost


***how financed medical expenses***
*wave 2 respondent paid med expenses with savings
gen raxoopsave = .
missing_w2 EiExpS EiPHI EiHPay1 EiHPay96 if inw`wv'xt==1, result(raxoopsave)
replace raxoopsave = .d if EiExpS==3 | EiHPay96==1
replace raxoopsave = .x if EiExpS==2 | (EiExpS==1 & inlist(EiPHI,1,4))
replace raxoopsave = 0 if EiHPay1==0
replace raxoopsave = 1 if EiHPay1==1
label variable raxoopsave "raxoopsave: r used savings to finance med expenses"
label values raxoopsave yesno


*wave 2 respondent paid med expenses with loan
gen raxooploan = .
missing_w2 EiExpS EiPHI EiHPay2 EiHPay96 if inw`wv'xt==1, result(raxooploan)
replace raxooploan = .d if EiExpS==3 | EiHPay96==1
replace raxooploan = .x if EiExpS==2 | (EiExpS==1 & inlist(EiPHI,1,4))
replace raxooploan = 0 if EiHPay2==0
replace raxooploan = 1 if EiHPay2==1
label variable raxooploan "raxooploan: r used loan to finance med expenses"
label values raxooploan yesno


*wave 2 respondent med expenses not yet paid
gen raxoopnyet = .
missing_w2 EiExpS EiPHI EiHPay3 EiHPay96 if inw`wv'xt==1, result(raxoopnyet)
replace raxoopnyet = .d if EiExpS==3 | EiHPay96==1
replace raxoopnyet = .x if EiExpS==2 | (EiExpS==1 & inlist(EiPHI,1,4))
replace raxoopnyet = 0 if EiHPay3==0
replace raxoopnyet = 1 if EiHPay3==1
label variable raxoopnyet "raxoopnyet: r not yet paid med expenses"
label values raxoopnyet yesno


*wave 2 respondent med expenses paid other way
gen raxoopothr = .
missing_w2 EiExpS EiPHI EiHPay95 EiHPay96 if inw`wv'xt==1, result(raxoopothr)
replace raxoopothr = .d if EiExpS==3 | EiHPay96==1
replace raxoopothr = .x if EiExpS==2 | (EiExpS==1 & inlist(EiPHI,1,4))
replace raxoopothr = 0 if EiHPay95==0
replace raxoopothr = 1 if EiHPay95==1
label variable raxoopothr "raxoopothr: r used other way to finance med expenses"
label values raxoopothr yesno




***drop ELSA wave 2 core file raw variables***
drop `insxt_w2_exit'



******************************************************************************************


*set wave number
local wv=3
local pre_wv=2

local insxt_w3_exit EiPlac EiLive4 EiPlcN EiLHospA EiLHospB EiPlcL EiLive6 ///
										EiLNursA EiLNursB EiLive5 EiLHpceA EiLHpceB EiFAl EiFAu EiExpS ///
										EiPHI EiFHlp EiFWho1 EiFWho2 EiFWho95 EiFWho96 EiTol ///
										EiHPay1 EiHPay2 EiHPay3 EiHPay95 EiHPay96 EiLive2 EiLive7 EiLive8 ///
										EiLShelA EiLShelB EiLMixA EiLMixB EiLResA EiLResB 
merge 1:1 idauniq using "$wave_3_xt", keepusing(`insxt_w3_exit') nogen




***whether overnight hospital stays***
*wave 3 respondent whether overnight hospital stays
missing_w3 EiPlac EiLive4 if inw`wv'xt==1, result(raxhosp)
replace raxhosp = 0 if inrange(EiPlac,1,3) | inrange(EiPlac,5,96) | EiLive4==0
replace raxhosp = 1 if EiPlac==4 | EiLive4==1


***number overnight hospital stays***
*wave 3 respondent number overnight hospital stays
missing_w3 raxhosp EiPlcN EiLHospA if inw`wv'xt==1, result(raxhsptim)
replace raxhsptim = 0 if raxhosp==0 & inw`wv'xt==1
replace raxhsptim = EiPlcN if inrange(EiPlcN,1,90) & EiPlac==4
replace raxhsptim = EiLHospA if inrange(EiLHospA,1,90) & EiLive4==1


***number nights in hospital grouped***
*wave 3 respondent number nights in hospital grouped
missing_w3 raxhosp EiPlcL EiLHospB if inw`wv'xt==1, result(raxhspnitd)
replace raxhspnitd = .d if EiPlcL==7 | EiLHospB==7
replace raxhspnitd = 0 if raxhosp==0 & inw`wv'xt==1
replace raxhspnitd = 1 if (EiPlcL==1 & EiPlac==4) | (EiLHospB==1 & EiLive4==1)
replace raxhspnitd = 2 if (EiPlcL==2 & EiPlac==4) | (EiLHospB==2 & EiLive4==1)
replace raxhspnitd = 3 if (EiPlcL==3 & EiPlac==4) | (EiLHospB==3 & EiLive4==1)
replace raxhspnitd = 4 if (EiPlcL==4 & EiPlac==4) | (EiLHospB==4 & EiLive4==1)
replace raxhspnitd = 5 if (EiPlcL==5 & EiPlac==4) | (EiLHospB==5 & EiLive4==1)
replace raxhspnitd = 6 if (EiPlcL==6 & EiPlac==4) | (EiLHospB==6 & EiLive4==1)


***whether nursing home stays***
*wave 3 respondent whether nursing home stays
missing_w3 EiLive6 EiPlac if inw`wv'xt==1, result(raxnrshom)
replace raxnrshom = 0 if inlist(EiPlac,1,3,4,5) | inrange(EiPlac,9,96) | ///
													EiLive6==0 | EiLive7==0 | EiLive8==0 | EiLive2==0
replace raxnrshom = 1 if inlist(EiPlac,2,6,7,8) | EiLive6==1 | EiLive7==1 | EiLive8==1 | EiLive2==1


***number nursing home stays***
*wave 3 respondent number nursing home stays
gen nhms = 0 if inw`wv'xt==1
replace nhms = EiLNursA if EiLive6==1 & inrange(EiLNursA,1,95)
replace nhms = EiPlcN if EiPlac==6 & inrange(EiPlcN,1,95)
gen rhms = 0 if inw`wv'xt==1
replace rhms = EiLResA if EiLive7==1 & inrange(EiLResA,1,95)
replace rhms = EiPlcN if EiPlac==7 & inrange(EiPlcN,1,95)
gen mixs = 0 if inw`wv'xt==1
replace mixs = EiLMixA if EiLive8==1 & inrange(EiLMixA,1,95)
replace mixs = EiPlcN if EiPlac==8 & inrange(EiPlcN,1,95)
gen shls = 0 if inw`wv'xt==1
replace shls = EiLShelA if EiLive2==1 & inrange(EiLShelA,1,95)
replace shls = EiPlcN if EiPlac==2 & inrange(EiPlcN,1,95)
gen sums = nhms + rhms + mixs + shls

missing_w3 raxnrshom EiPlcN EiLNursA EiLResA EiLMixA EiLShelA if inw`wv'xt==1, result(raxnrstim)
replace raxnrstim = 0 if raxnrshom==0 & inw`wv'xt==1
replace raxnrstim = sums if !inlist(sums,0,.)

drop nhms rhms mixs shls sums


***number nights in nursing home grouped***
*wave 3 respondent number nights in nursing home grouped
gen nhmn = 0 if inw`wv'xt==1
replace nhmn = EiLNursB if EiLive6==1 & inrange(EiLNursB,1,6)
replace nhmn = EiPlcL if EiPlac==6 & inrange(EiPlcL,1,6)
gen rhmn = 0 if inw`wv'xt==1
replace rhmn = EiLResB if EiLive7==1 & inrange(EiLResB,1,6)
replace rhmn = EiPlcL if EiPlac==7 & inrange(EiPlcL,1,6)
gen mixn = 0 if inw`wv'xt==1
replace mixn = EiLMixB if EiLive8==1 & inrange(EiLMixB,1,6)
replace mixn = EiPlcL if EiPlac==8 & inrange(EiPlcL,1,6)
gen shln = 0 if inw`wv'xt==1
replace shln = EiLShelB if EiLive2==1 & inrange(EiLShelB,1,6)
replace shln = EiPlcL if EiPlac==2 & inrange(EiPlcL,1,6)

missing_w3 raxnrshom EiPlcL EiLNursB EiLResB EiLMixB EiLShelB if inw`wv'xt==1, result(raxnrsnitd_e)
replace raxnrsnitd_e = .d if EiPlcL==7 | EiLNursB==7 | EiLResB==7 | EiLMixB==7 | EiLShelB==7
replace raxnrsnitd_e = 0 if raxnrshom==0 & inw`wv'xt==1
replace raxnrsnitd_e = 1 if nhmn==1 | rhmn==1 | mixn==1 | shln==1
replace raxnrsnitd_e = 2 if nhmn==2 | rhmn==2 | mixn==2 | shln==2
replace raxnrsnitd_e = 3 if nhmn==3 | rhmn==3 | mixn==3 | shln==3
replace raxnrsnitd_e = 4 if nhmn==4 | rhmn==4 | mixn==4 | shln==4
replace raxnrsnitd_e = 5 if nhmn==5 | rhmn==5 | mixn==5 | shln==5
replace raxnrsnitd_e = 6 if nhmn==6 | rhmn==6 | mixn==6 | shln==6

drop nhmn rhmn mixn shln


***whether overnight hospice stays***
*wave 3 respondent whether overnight hospice stays
missing_w3 EiPlac EiLive5 if inw`wv'xt==1, result(raxhospice)
replace raxhospice = 0 if inrange(EiPlac,1,4) | inrange(EiPlac,6,96) | EiLive5==0
replace raxhospice = 1 if EiPlac==5 | EiLive5==1


***number overnight hospice stays***
*wave 3 number overnight hospice stays
missing_w3 raxhospice EiPlcN EiLHpceA if inw`wv'xt==1, result(raxhpctim)
replace raxhpctim = 0 if raxhospice==0 & inw`wv'xt==1
replace raxhpctim = EiPlcN if inrange(EiPlcN,1,90) & EiPlac==5
replace raxhpctim = EiLHpceA if inrange(EiLHpceA,1,90) & EiLive5==1


***number nights in hospice grouped***
*wave 3 respondent number nights in hospice grouped 
missing_w3 raxhospice EiPlcL EiLHpceB if inw`wv'xt==1, result(raxhpcnitd)
replace raxhpcnitd = .d if EiPlcL==7 | EiLHpceB==7
replace raxhpcnitd = 0 if raxhospice==0 & inw`wv'xt==1
replace raxhpcnitd = 1 if (EiPlcL==1 & EiPlac==5) | (EiLHpceB==1 & EiLive5==1)
replace raxhpcnitd = 2 if (EiPlcL==2 & EiPlac==5) | (EiLHpceB==2 & EiLive5==1)
replace raxhpcnitd = 3 if (EiPlcL==3 & EiPlac==5) | (EiLHpceB==3 & EiLive5==1)
replace raxhpcnitd = 4 if (EiPlcL==4 & EiPlac==5) | (EiLHpceB==4 & EiLive5==1)
replace raxhpcnitd = 5 if (EiPlcL==5 & EiPlac==5) | (EiLHpceB==5 & EiLive5==1)
replace raxhpcnitd = 6 if (EiPlcL==6 & EiPlac==5) | (EiLHpceB==6 & EiLive5==1)


***hospital, hospice, or nursing home stays***
*wave 3 respondent hospital, hospice, or nursing home stays
missing_w3 raxhosp raxnrshom raxhospice if inw`wv'xt==1, result(raxhhnh)
replace raxhhnh = 0 if (raxhosp==0 | raxnrshom==0 | raxhospice==0) & inw`wv'xt==1
replace raxhhnh = 1 if (raxhosp==1 | raxnrshom==1 | raxhospice==1) & inw`wv'xt==1

***number hospital, hospice, or nursing home stays***
*wave 3 respondent number hospital, hospice, or nursing home stays
egen timesm = rowmiss(raxhsptim raxnrstim raxhpctim) if inw`wv'xt==1
egen times = rowtotal(raxhsptim raxnrstim raxhpctim) if inrange(timesm,0,2),m

missing_w3 raxhsptim raxnrstim raxhpctim if inw`wv'xt==1, result(raxhhntim)
replace raxhhntim = times if inrange(times,0,160) & inw`wv'xt==1
replace raxhhntim = .m if (raxhsptim==.m | raxnrstim==.m | raxhpctim==.m) & timesm==3 & inw`wv'xt==1
replace raxhhntim = .d if (raxhsptim==.d | raxnrstim==.d | raxhpctim==.d) & timesm==3 & inw`wv'xt==1
replace raxhhntim = .r if (raxhsptim==.r | raxnrstim==.r | raxhpctim==.r) & timesm==3 & inw`wv'xt==1

*wave 3 respondent missings
replace raxhhntimm = timesm if inrange(timesm,0,3) & inw`wv'xt==1

drop times timesm


****total oop major medical costs***
**wave 3 respondent total oop major medical costs
*replace eifal = EiFAl if inrange(EiFAl,0,100000)
*replace eifau = EiFAu if inrange(EiFAu,0,100000)
*
*replace eifao = 0 if EiExpS==2 | inlist(EiPHI,1,4)
*replace eifao = 1 if EiExpS==1 & inlist(EiPHI,2,3)
*
**no values for EiFA_


***whether anyone helped pay oop costs***
*wave 3 respondent whether anyone helped pay oop costs
missing_w3 EiExpS EiPHI EiFHlp if inw`wv'xt==1, result(raxoophelp)
replace raxoophelp = .d if EiExpS==3 | EiPHI==5 | EiFHlp==3
replace raxoophelp = .x if EiExpS==2 | (EiExpS==1 & inlist(EiPHI,1,4))
replace raxoophelp = 0 if EiFHlp==2
replace raxoophelp = 1 if EiFHlp==1


***who helped pay oop costs***
*wave 3 respondent who helped pay oop costs
missing_w3 raxoophelp EiFWho1 EiFWho2 EiFWho95 EiFWho96 if inw`wv'xt==1, result(raxoopwho)
replace raxoopwho = .d if EiFWho96==1
replace raxoopwho = .x if raxoophelp==.x & inw`wv'xt==1
replace raxoopwho = .h if raxoophelp==0 & inw`wv'xt==1
replace raxoopwho = 1 if EiFWho1==1
replace raxoopwho = 2 if EiFWho2==1
replace raxoopwho = 3 if EiFWho95==1


***how financed medical expenses***
*wave 3 respondent paid med expenses with savings
missing_w3 EiExpS EiPHI EiHPay1 EiHPay96 if inw`wv'xt==1, result(raxoopsave)
replace raxoopsave = .d if EiExpS==3 | EiPHI==5 | EiHPay96==1
replace raxoopsave = .x if EiExpS==2 | (EiExpS==1 & inlist(EiPHI,1,4))
replace raxoopsave = 0 if EiHPay1==0
replace raxoopsave = 1 if EiHPay1==1


*wave 3 respondent paid med expenses with loan
missing_w3 EiExpS EiPHI EiHPay2 EiHPay96 if inw`wv'xt==1, result(raxooploan)
replace raxooploan = .d if EiExpS==3 | EiPHI==5 | EiHPay96==1
replace raxooploan = .x if EiExpS==2 | (EiExpS==1 & inlist(EiPHI,1,4))
replace raxooploan = 0 if EiHPay2==0
replace raxooploan = 1 if EiHPay2==1


*wave 3 respondent med expenses not yet paid
missing_w3 EiExpS EiPHI EiHPay3 EiHPay96 if inw`wv'xt==1, result(raxoopnyet)
replace raxoopnyet = .d if EiExpS==3 | EiPHI==5 | EiHPay96==1
replace raxoopnyet = .x if EiExpS==2 | (EiExpS==1 & inlist(EiPHI,1,4))
replace raxoopnyet = 0 if EiHPay3==0
replace raxoopnyet = 1 if EiHPay3==1


*wave 3 respondent med expenses paid other way
missing_w3 EiExpS EiPHI EiHPay95 EiHPay96 if inw`wv'xt==1, result(raxoopothr)
replace raxoopothr = .d if EiExpS==3 | EiPHI==5 | EiHPay96==1
replace raxoopothr = .x if EiExpS==2 | (EiExpS==1 & inlist(EiPHI,1,4))
replace raxoopothr = 0 if EiHPay95==0
replace raxoopothr = 1 if EiHPay95==1



***drop ELSA wave 3 core file raw variables***
drop `insxt_w3_exit'



******************************************************************************************


*set wave number
local wv=4
local pre_wv=3

local insxt_w4_exit EiPlac EiLive4 EiPlcN EiLHospA EiLHospB EiPlcL EiLive6 ///
										EiLNursA EiLNursB EiLive5 EiLHpceA EiLHpceB EiFAl EiFAu EiExpS ///
										EiPHI EiFHlp EiFWho1 EiFWho2 EiFWho95 EiFWho96 EiTol ///
										EiHPay1 EiHPay2 EiHPay3 EiHPay95 EiHPay96 EiLive2 EiLive7 EiLive8 ///
										EiLShelA EiLShelB EiLMixA EiLMixB EiLResA EiLResB 
merge 1:1 idauniq using "$w4_xt", keepusing(`insxt_w4_exit') nogen




***whether overnight hospital stays***
*wave 4 respondent whether overnight hospital stays
missing_w4 EiPlac EiLive4 if inw`wv'xt==1, result(raxhosp)
replace raxhosp = 0 if inrange(EiPlac,1,3) | inrange(EiPlac,5,96) | EiLive4==0
replace raxhosp = 1 if EiPlac==4 | EiLive4==1


***number overnight hospital stays***
*wave 4 respondent number overnight hospital stays
missing_w4 raxhosp EiPlcN EiLHospA if inw`wv'xt==1, result(raxhsptim)
replace raxhsptim = 0 if raxhosp==0 & inw`wv'xt==1
replace raxhsptim = EiPlcN if inrange(EiPlcN,1,90) & EiPlac==4
replace raxhsptim = EiLHospA if inrange(EiLHospA,1,90) & EiLive4==1


***number nights in hospital grouped***
*wave 4 respondent number nights in hospital grouped
missing_w4 raxhosp EiPlcL EiLHospB if inw`wv'xt==1, result(raxhspnitd)
replace raxhspnitd = .d if EiPlcL==7 | EiLHospB==7
replace raxhspnitd = 0 if raxhosp==0 & inw`wv'xt==1
replace raxhspnitd = 1 if (EiPlcL==1 & EiPlac==4) | (EiLHospB==1 & EiLive4==1)
replace raxhspnitd = 2 if (EiPlcL==2 & EiPlac==4) | (EiLHospB==2 & EiLive4==1)
replace raxhspnitd = 3 if (EiPlcL==3 & EiPlac==4) | (EiLHospB==3 & EiLive4==1)
replace raxhspnitd = 4 if (EiPlcL==4 & EiPlac==4) | (EiLHospB==4 & EiLive4==1)
replace raxhspnitd = 5 if (EiPlcL==5 & EiPlac==4) | (EiLHospB==5 & EiLive4==1)
replace raxhspnitd = 6 if (EiPlcL==6 & EiPlac==4) | (EiLHospB==6 & EiLive4==1)


***whether nursing home stays***
*wave 4 respondent whether nursing home stays
missing_w4 EiLive6 EiPlac if inw`wv'xt==1, result(raxnrshom)
replace raxnrshom = 0 if inlist(EiPlac,1,3,4,5) | inrange(EiPlac,9,96) | ///
													EiLive6==0 | EiLive7==0 | EiLive8==0 | EiLive2==0
replace raxnrshom = 1 if inlist(EiPlac,2,6,7,8) | EiLive6==1 | EiLive7==1 | EiLive8==1 | EiLive2==1


***number nursing home stays***
*wave 4 respondent number nursing home stays
gen nhms = 0 if inw`wv'xt==1
replace nhms = EiLNursA if EiLive6==1 & inrange(EiLNursA,1,95)
replace nhms = EiPlcN if EiPlac==6 & inrange(EiPlcN,1,95)
gen rhms = 0 if inw`wv'xt==1
replace rhms = EiLResA if EiLive7==1 & inrange(EiLResA,1,95)
replace rhms = EiPlcN if EiPlac==7 & inrange(EiPlcN,1,95)
gen mixs = 0 if inw`wv'xt==1
replace mixs = EiLMixA if EiLive8==1 & inrange(EiLMixA,1,95)
replace mixs = EiPlcN if EiPlac==8 & inrange(EiPlcN,1,95)
gen shls = 0 if inw`wv'xt==1
replace shls = EiLShelA if EiLive2==1 & inrange(EiLShelA,1,95)
replace shls = EiPlcN if EiPlac==2 & inrange(EiPlcN,1,95)
gen sums = nhms + rhms + mixs + shls

missing_w4 raxnrshom EiPlcN EiLNursA EiLResA EiLMixA EiLShelA if inw`wv'xt==1, result(raxnrstim)
replace raxnrstim = 0 if raxnrshom==0 & inw`wv'xt==1
replace raxnrstim = sums if !inlist(sums,.,0)

drop nhms rhms mixs shls sums


***number nights in nursing home grouped***
*wave 4 respondent number nights in nursing home grouped
gen nhmn = 0 if inw`wv'xt==1
replace nhmn = EiLNursB if EiLive6==1 & inrange(EiLNursB,1,6)
replace nhmn = EiPlcL if EiPlac==6 & inrange(EiPlcL,1,6)
gen rhmn = 0 if inw`wv'xt==1
replace rhmn = EiLResB if EiLive7==1 & inrange(EiLResB,1,6)
replace rhmn = EiPlcL if EiPlac==7 & inrange(EiPlcL,1,6)
gen mixn = 0 if inw`wv'xt==1
replace mixn = EiLMixB if EiLive8==1 & inrange(EiLMixB,1,6)
replace mixn = EiPlcL if EiPlac==8 & inrange(EiPlcL,1,6)
gen shln = 0 if inw`wv'xt==1
replace shln = EiLShelB if EiLive2==1 & inrange(EiLShelB,1,6)
replace shln = EiPlcL if EiPlac==2 & inrange(EiPlcL,1,6)

missing_w4 raxnrshom EiPlcL EiLNursB EiLResB EiLMixB EiLShelB if inw`wv'xt==1, result(raxnrsnitd_e)
replace raxnrsnitd_e = .d if EiPlcL==7 | EiLNursB==7 | EiLResB==7 | EiLMixB==7 | EiLShelB==7
replace raxnrsnitd_e = 0 if raxnrshom==0 & inw`wv'xt==1
replace raxnrsnitd_e = 1 if nhmn==1 | rhmn==1 | mixn==1 | shln==1
replace raxnrsnitd_e = 2 if nhmn==2 | rhmn==2 | mixn==2 | shln==2
replace raxnrsnitd_e = 3 if nhmn==3 | rhmn==3 | mixn==3 | shln==3
replace raxnrsnitd_e = 4 if nhmn==4 | rhmn==4 | mixn==4 | shln==4
replace raxnrsnitd_e = 5 if nhmn==5 | rhmn==5 | mixn==5 | shln==5
replace raxnrsnitd_e = 6 if nhmn==6 | rhmn==6 | mixn==6 | shln==6

drop nhmn rhmn mixn shln


***whether overnight hospice stays***
*wave 4 respondent whether overnight hospice stays
missing_w4 EiPlac EiLive5 if inw`wv'xt==1, result(raxhospice)
replace raxhospice = 0 if inrange(EiPlac,1,4) | inrange(EiPlac,6,96) | EiLive5==0
replace raxhospice = 1 if EiPlac==5 | EiLive5==1


***number overnight hospice stays***
*wave 4 number overnight hospice stays
missing_w4 raxhospice EiPlcN EiLHpceA if inw`wv'xt==1, result(raxhpctim)
replace raxhpctim = 0 if raxhospice==0 & inw`wv'xt==1
replace raxhpctim = EiPlcN if inrange(EiPlcN,1,90) & EiPlac==5
replace raxhpctim = EiLHpceA if inrange(EiLHpceA,1,90) & EiLive5==1


***number nights in hospice grouped***
*wave 4 respondent number nights in hospice grouped 
missing_w4 raxhospice EiPlcL EiLHpceB if inw`wv'xt==1, result(raxhpcnitd)
replace raxhpcnitd = .d if EiPlcL==7 | EiLHpceB==7
replace raxhpcnitd = 0 if raxhospice==0 & inw`wv'xt==1
replace raxhpcnitd = 1 if (EiPlcL==1 & EiPlac==5) | (EiLHpceB==1 & EiLive5==1)
replace raxhpcnitd = 2 if (EiPlcL==2 & EiPlac==5) | (EiLHpceB==2 & EiLive5==1)
replace raxhpcnitd = 3 if (EiPlcL==3 & EiPlac==5) | (EiLHpceB==3 & EiLive5==1)
replace raxhpcnitd = 4 if (EiPlcL==4 & EiPlac==5) | (EiLHpceB==4 & EiLive5==1)
replace raxhpcnitd = 5 if (EiPlcL==5 & EiPlac==5) | (EiLHpceB==5 & EiLive5==1)
replace raxhpcnitd = 6 if (EiPlcL==6 & EiPlac==5) | (EiLHpceB==6 & EiLive5==1)


***hospital, hospice, or nursing home stays***
*wave 4 respondent hospital, hospice, or nursing home stays
missing_w4 raxhosp raxnrshom raxhospice if inw`wv'xt==1, result(raxhhnh)
replace raxhhnh = 0 if (raxhosp==0 | raxnrshom==0 | raxhospice==0) & inw`wv'xt==1
replace raxhhnh = 1 if (raxhosp==1 | raxnrshom==1 | raxhospice==1) & inw`wv'xt==1

***number hospital, hospice, or nursing home stays***
*wave 4 respondent number hospital, hospice, or nursing home stays
egen timesm = rowmiss(raxhsptim raxnrstim raxhpctim) if inw`wv'xt==1
egen times = rowtotal(raxhsptim raxnrstim raxhpctim) if inrange(timesm,0,2),m

missing_w4 raxhsptim raxnrstim raxhpctim if inw`wv'xt==1, result(raxhhntim)
replace raxhhntim = times if inrange(times,0,160) & inw`wv'xt==1
replace raxhhntim = .m if (raxhsptim==.m | raxnrstim==.m | raxhpctim==.m) & timesm==3 & inw`wv'xt==1
replace raxhhntim = .d if (raxhsptim==.d | raxnrstim==.d | raxhpctim==.d) & timesm==3 & inw`wv'xt==1
replace raxhhntim = .r if (raxhsptim==.r | raxnrstim==.r | raxhpctim==.r) & timesm==3 & inw`wv'xt==1

*wave 4 respondent missings
replace raxhhntimm = timesm if inrange(timesm,0,3) & inw`wv'xt==1

drop times timesm


****total oop major medical costs***
**wave 4 respondent total oop major medical costs
*replace eifal = EiFAl if inrange(EiFAl,0,100000)
*replace eifau = EiFAu if inrange(EiFAu,0,100000)
*
*replace eifao = 0 if EiExpS==2 | inlist(EiPHI,1,4)
*replace eifao = 1 if EiExpS==1 & inlist(EiPHI,2,3)
*
**no values for EiFA


***whether anyone helped pay oop costs***
*wave 4 respondent whether anyone helped pay oop costs
missing_w4 EiExpS EiPHI EiFHlp if inw`wv'xt==1, result(raxoophelp)
replace raxoophelp = .d if EiExpS==3 | EiPHI==5 | EiFHlp==3
replace raxoophelp = .x if EiExpS==2 | (EiExpS==1 & inlist(EiPHI,1,4))
replace raxoophelp = 0 if EiFHlp==2
replace raxoophelp = 1 if EiFHlp==1


***who helped pay oop costs***
*wave 4 respondent who helped pay oop costs
missing_w4 raxoophelp EiFWho1 EiFWho2 EiFWho95 EiFWho96 if inw`wv'xt==1, result(raxoopwho)
replace raxoopwho = .d if EiFWho96==1
replace raxoopwho = .x if raxoophelp==.x & inw`wv'xt==1
replace raxoopwho = .h if raxoophelp==0 & inw`wv'xt==1
replace raxoopwho = 1 if EiFWho1==1
replace raxoopwho = 2 if EiFWho2==1
replace raxoopwho = 3 if EiFWho95==1


***how financed medical expenses***
*wave 4 respondent paid med expenses with savings
missing_w4 EiExpS EiPHI EiHPay1 EiHPay96 if inw`wv'xt==1, result(raxoopsave)
replace raxoopsave = .d if EiExpS==3 | EiPHI==5 | EiHPay96==1
replace raxoopsave = .x if EiExpS==2 | (EiExpS==1 & inlist(EiPHI,1,4))
replace raxoopsave = 0 if EiHPay1==0
replace raxoopsave = 1 if EiHPay1==1


*wave 4 respondent paid med expenses with loan
missing_w4 EiExpS EiPHI EiHPay2 EiHPay96 if inw`wv'xt==1, result(raxooploan)
replace raxooploan = .d if EiExpS==3 | EiPHI==5 | EiHPay96==1
replace raxooploan = .x if EiExpS==2 | (EiExpS==1 & inlist(EiPHI,1,4))
replace raxooploan = 0 if EiHPay2==0
replace raxooploan = 1 if EiHPay2==1


*wave 4 respondent med expenses not yet paid
missing_w4 EiExpS EiPHI EiHPay3 EiHPay96 if inw`wv'xt==1, result(raxoopnyet)
replace raxoopnyet = .d if EiExpS==3 | EiPHI==5 | EiHPay96==1
replace raxoopnyet = .x if EiExpS==2 | (EiExpS==1 & inlist(EiPHI,1,4))
replace raxoopnyet = 0 if EiHPay3==0
replace raxoopnyet = 1 if EiHPay3==1


*wave 4 respondent med expenses paid other way
missing_w4 EiExpS EiPHI EiHPay95 EiHPay96 if inw`wv'xt==1, result(raxoopothr)
replace raxoopothr = .d if EiExpS==3 | EiPHI==5 | EiHPay96==1
replace raxoopothr = .x if EiExpS==2 | (EiExpS==1 & inlist(EiPHI,1,4))
replace raxoopothr = 0 if EiHPay95==0
replace raxoopothr = 1 if EiHPay95==1



***drop ELSA wave 4 core file raw variables***
drop `insxt_w4_exit'



******************************************************************************************


*set wave number
local wv=6
local pre_wv=4

local insxt_w6_exit EiPlac EiLive4 EiPlcN EiLHospA EiLHospB EiPlcL EiLive6 ///
										EiLNursA EiLNursB EiLive5 EiLHpceA EiLHpceB EiFAl EiFAu EiExpS ///
										EiPHI EiFHlp EiFWho1 EiFWho2 EiFWho95 EiFWho96 EiTol ///
										EiHPay1 EiHPay2 EiHPay3 EiHPay95 EiHPay96 EiLive2 EiLive7 EiLive8 ///
										EiLShelA EiLShelB EiLMixA EiLMixB EiLResA EiLResB EiHPayz4 
merge 1:1 idauniq using "$wave_6_xt", keepusing(`insxt_w6_exit') nogen




***whether overnight hospital stays***
*wave 6 respondent whether overnight hospital stays
missing_w6 EiPlac EiLive4 if inw`wv'xt==1, result(raxhosp)
replace raxhosp = 0 if inrange(EiPlac,1,3) | inrange(EiPlac,5,96) | EiLive4==0
replace raxhosp = 1 if EiPlac==4 | EiLive4==1


***number overnight hospital stays***
*wave 6 respondent number overnight hospital stays
missing_w6 raxhosp EiPlcN EiLHospA if inw`wv'xt==1, result(raxhsptim)
replace raxhsptim = 0 if raxhosp==0 & inw`wv'xt==1
replace raxhsptim = EiPlcN if inrange(EiPlcN,1,90) & EiPlac==4
replace raxhsptim = EiLHospA if inrange(EiLHospA,1,90) & EiLive4==1


***number nights in hospital grouped***
*wave 6 respondent number nights in hospital grouped
missing_w6 raxhosp EiPlcL EiLHospB if inw`wv'xt==1, result(raxhspnitd)
replace raxhspnitd = .d if EiPlcL==7 | EiLHospB==7
replace raxhspnitd = 0 if raxhosp==0 & inw`wv'xt==1
replace raxhspnitd = 1 if (EiPlcL==1 & EiPlac==4) | (EiLHospB==1 & EiLive4==1)
replace raxhspnitd = 2 if (EiPlcL==2 & EiPlac==4) | (EiLHospB==2 & EiLive4==1)
replace raxhspnitd = 3 if (EiPlcL==3 & EiPlac==4) | (EiLHospB==3 & EiLive4==1)
replace raxhspnitd = 4 if (EiPlcL==4 & EiPlac==4) | (EiLHospB==4 & EiLive4==1)
replace raxhspnitd = 5 if (EiPlcL==5 & EiPlac==4) | (EiLHospB==5 & EiLive4==1)
replace raxhspnitd = 6 if (EiPlcL==6 & EiPlac==4) | (EiLHospB==6 & EiLive4==1)


***whether nursing home stays***
*wave 6 respondent whether nursing home stays
missing_w6 EiLive6 EiPlac if inw`wv'xt==1, result(raxnrshom)
replace raxnrshom = 0 if inlist(EiPlac,1,3,4,5) | inrange(EiPlac,9,96) | ///
													EiLive6==0 | EiLive7==0 | EiLive8==0 | EiLive2==0
replace raxnrshom = 1 if inlist(EiPlac,2,6,7,8) | EiLive6==1 | EiLive7==1 | EiLive8==1 | EiLive2==1


***number nursing home stays***
*wave 6 respondent number nursing home stays
gen nhms = 0 if inw`wv'xt==1
replace nhms = EiLNursA if EiLive6==1 & inrange(EiLNursA,1,95)
replace nhms = EiPlcN if EiPlac==6 & inrange(EiPlcN,1,95)
gen rhms = 0 if inw`wv'xt==1
replace rhms = EiLResA if EiLive7==1 & inrange(EiLResA,1,95)
replace rhms = EiPlcN if EiPlac==7 & inrange(EiPlcN,1,95)
gen mixs = 0 if inw`wv'xt==1
replace mixs = EiLMixA if EiLive8==1 & inrange(EiLMixA,1,95)
replace mixs = EiPlcN if EiPlac==8 & inrange(EiPlcN,1,95)
gen shls = 0 if inw`wv'xt==1
replace shls = EiLShelA if EiLive2==1 & inrange(EiLShelA,1,95)
replace shls = EiPlcN if EiPlac==2 & inrange(EiPlcN,1,95)
gen sums = nhms + rhms + mixs + shls

missing_w6 raxnrshom EiPlcN EiLNursA EiLResA EiLMixA EiLShelA if inw`wv'xt==1, result(raxnrstim)
replace raxnrstim = 0 if raxnrshom==0 & inw`wv'xt==1
replace raxnrstim = sums if !inlist(sums,0,.)

drop nhms rhms mixs shls sums


***number nights in nursing home grouped***
*wave 6 respondent number nights in nursing home grouped
gen nhmn = 0 if inw`wv'xt==1
replace nhmn = EiLNursB if EiLive6==1 & inrange(EiLNursB,1,6)
replace nhmn = EiPlcL if EiPlac==6 & inrange(EiPlcL,1,6)
gen rhmn = 0 if inw`wv'xt==1
replace rhmn = EiLResB if EiLive7==1 & inrange(EiLResB,1,6)
replace rhmn = EiPlcL if EiPlac==7 & inrange(EiPlcL,1,6)
gen mixn = 0 if inw`wv'xt==1
replace mixn = EiLMixB if EiLive8==1 & inrange(EiLMixB,1,6)
replace mixn = EiPlcL if EiPlac==8 & inrange(EiPlcL,1,6)
gen shln = 0 if inw`wv'xt==1
replace shln = EiLShelB if EiLive2==1 & inrange(EiLShelB,1,6)
replace shln = EiPlcL if EiPlac==2 & inrange(EiPlcL,1,6)

missing_w6 raxnrshom EiPlcL EiLNursB EiLResB EiLMixB EiLShelB if inw`wv'xt==1, result(raxnrsnitd_e)
replace raxnrsnitd_e = .d if EiPlcL==7 | EiLNursB==7 | EiLResB==7 | EiLMixB==7 | EiLShelB==7
replace raxnrsnitd_e = 0 if raxnrshom==0 & inw`wv'xt==1
replace raxnrsnitd_e = 1 if nhmn==1 | rhmn==1 | mixn==1 | shln==1
replace raxnrsnitd_e = 2 if nhmn==2 | rhmn==2 | mixn==2 | shln==2
replace raxnrsnitd_e = 3 if nhmn==3 | rhmn==3 | mixn==3 | shln==3
replace raxnrsnitd_e = 4 if nhmn==4 | rhmn==4 | mixn==4 | shln==4
replace raxnrsnitd_e = 5 if nhmn==5 | rhmn==5 | mixn==5 | shln==5
replace raxnrsnitd_e = 6 if nhmn==6 | rhmn==6 | mixn==6 | shln==6

drop nhmn rhmn mixn shln


***whether overnight hospice stays***
*wave 6 respondent whether overnight hospice stays
missing_w6 EiPlac EiLive5 if inw`wv'xt==1, result(raxhospice)
replace raxhospice = 0 if inrange(EiPlac,1,4) | inrange(EiPlac,6,96) | EiLive5==0
replace raxhospice = 1 if EiPlac==5 | EiLive5==1


***number overnight hospice stays***
*wave 6 number overnight hospice stays
missing_w6 raxhospice EiPlcN EiLHpceA if inw`wv'xt==1, result(raxhpctim)
replace raxhpctim = 0 if raxhospice==0 & inw`wv'xt==1
replace raxhpctim = EiPlcN if inrange(EiPlcN,1,90) & EiPlac==5
replace raxhpctim = EiLHpceA if inrange(EiLHpceA,1,90) & EiLive5==1


***number nights in hospice grouped***
*wave 6 respondent number nights in hospice grouped 
missing_w6 raxhospice EiPlcL EiLHpceB if inw`wv'xt==1, result(raxhpcnitd)
replace raxhpcnitd = .d if EiPlcL==7 | EiLHpceB==7
replace raxhpcnitd = 0 if raxhospice==0 & inw`wv'xt==1
replace raxhpcnitd = 1 if (EiPlcL==1 & EiPlac==5) | (EiLHpceB==1 & EiLive5==1)
replace raxhpcnitd = 2 if (EiPlcL==2 & EiPlac==5) | (EiLHpceB==2 & EiLive5==1)
replace raxhpcnitd = 3 if (EiPlcL==3 & EiPlac==5) | (EiLHpceB==3 & EiLive5==1)
replace raxhpcnitd = 4 if (EiPlcL==4 & EiPlac==5) | (EiLHpceB==4 & EiLive5==1)
replace raxhpcnitd = 5 if (EiPlcL==5 & EiPlac==5) | (EiLHpceB==5 & EiLive5==1)
replace raxhpcnitd = 6 if (EiPlcL==6 & EiPlac==5) | (EiLHpceB==6 & EiLive5==1)


***hospital, hospice, or nursing home stays***
*wave 6 respondent hospital, hospice, or nursing home stays
missing_w6 raxhosp raxnrshom raxhospice if inw`wv'xt==1, result(raxhhnh)
replace raxhhnh = 0 if (raxhosp==0 | raxnrshom==0 | raxhospice==0) & inw`wv'xt==1
replace raxhhnh = 1 if (raxhosp==1 | raxnrshom==1 | raxhospice==1) & inw`wv'xt==1

***number hospital, hospice, or nursing home stays***
*wave 6 respondent number hospital, hospice, or nursing home stays
egen timesm = rowmiss(raxhsptim raxnrstim raxhpctim) if inw`wv'xt==1
egen times = rowtotal(raxhsptim raxnrstim raxhpctim) if inrange(timesm,0,2),m

missing_w6 raxhsptim raxnrstim raxhpctim if inw`wv'xt==1, result(raxhhntim)
replace raxhhntim = times if inrange(times,0,160) & inw`wv'xt==1
replace raxhhntim = .m if (raxhsptim==.m | raxnrstim==.m | raxhpctim==.m) & timesm==3 & inw`wv'xt==1
replace raxhhntim = .d if (raxhsptim==.d | raxnrstim==.d | raxhpctim==.d) & timesm==3 & inw`wv'xt==1
replace raxhhntim = .r if (raxhsptim==.r | raxnrstim==.r | raxhpctim==.r) & timesm==3 & inw`wv'xt==1

*wave 6 respondent missings
replace raxhhntimm = timesm if inrange(timesm,0,3) & inw`wv'xt==1

drop times timesm


****total oop major medical costs***
**wave 6 respondent total oop major medical costs
*replace eifal = EiFAl if inrange(EiFAl,0,100000)
*replace eifau = EiFAu if inrange(EiFAu,0,100000)
*
*replace eifao = 0 if EiExpS==2 | inlist(EiPHI,1,4)
*replace eifao = 1 if EiExpS==1 & inlist(EiPHI,2,3)
*
**no values for EiFA


***whether anyone helped pay oop costs***
*wave 6 respondent whether anyone helped pay oop costs
missing_w6 EiExpS EiPHI EiFHlp if inw`wv'xt==1, result(raxoophelp)
replace raxoophelp = .d if EiExpS==3 | EiPHI==5 | EiFHlp==3
replace raxoophelp = .x if EiExpS==2 | (EiExpS==1 & inlist(EiPHI,1,4))
replace raxoophelp = 0 if EiFHlp==2
replace raxoophelp = 1 if EiFHlp==1


***who helped pay oop costs***
*wave 6 respondent who helped pay oop costs
missing_w6 raxoophelp EiFWho1 EiFWho2 EiFWho95 EiFWho96 if inw`wv'xt==1, result(raxoopwho)
replace raxoopwho = .d if EiFWho96==1
replace raxoopwho = .x if raxoophelp==.x & inw`wv'xt==1
replace raxoopwho = .h if raxoophelp==0 & inw`wv'xt==1
replace raxoopwho = 1 if EiFWho1==1
replace raxoopwho = 2 if EiFWho2==1
replace raxoopwho = 3 if EiFWho95==1
replace raxoopwho = 5 if EiFWho1==1 & EiFWho95==1


***how financed medical expenses***
*wave 6 respondent paid med expenses with savings
missing_w6 EiExpS EiPHI EiHPay1 EiHPay96 if inw`wv'xt==1, result(raxoopsave)
replace raxoopsave = .d if EiExpS==3 | EiPHI==5 | EiHPay96==1
replace raxoopsave = .x if EiExpS==2 | (EiExpS==1 & inlist(EiPHI,1,4))
replace raxoopsave = 0 if EiHPay1==0
replace raxoopsave = 1 if EiHPay1==1


*wave 6 respondent paid med expenses with loan
missing_w6 EiExpS EiPHI EiHPay2 EiHPay96 if inw`wv'xt==1, result(raxooploan)
replace raxooploan = .d if EiExpS==3 | EiPHI==5 | EiHPay96==1
replace raxooploan = .x if EiExpS==2 | (EiExpS==1 & inlist(EiPHI,1,4))
replace raxooploan = 0 if EiHPay2==0
replace raxooploan = 1 if EiHPay2==1


*wave 6 respondent med expenses not yet paid
missing_w6 EiExpS EiPHI EiHPay3 EiHPay96 if inw`wv'xt==1, result(raxoopnyet)
replace raxoopnyet = .d if EiExpS==3 | EiPHI==5 | EiHPay96==1
replace raxoopnyet = .x if EiExpS==2 | (EiExpS==1 & inlist(EiPHI,1,4))
replace raxoopnyet = 0 if EiHPay3==0
replace raxoopnyet = 1 if EiHPay3==1


*wave 6 respondent med expenses paid other way
missing_w6 EiExpS EiPHI EiHPay95 EiHPayz4 EiHPay96 if inw`wv'xt==1, result(raxoopothr)
replace raxoopothr = .d if EiExpS==3 | EiPHI==5 | EiHPay96==1
replace raxoopothr = .x if EiExpS==2 | (EiExpS==1 & inlist(EiPHI,1,4))
replace raxoopothr = 0 if EiHPay95==0 | EiHPayz4==0
replace raxoopothr = 1 if EiHPay95==1 | EiHPayz4==1



***drop ELSA wave 6 core file raw variables***
drop `insxt_w6_exit'



******************************************************************************************



label define difficulty ///
	1 "1.no difficulty" ///
	2 "2.slight difficulty" ///
	3 "3.great difficulty" ///
	.n ".n:not applicable"
	
label define cogfreq ///
	1 "1.never" ///
	2 "2.occasionally" ///
	3 "3.frequently"
	
label define yesnocog ///
	0 "0.no" ///
	1 "1.yes" ///
	.x ".x:no memory problems" ///
	.e ".e:skip pattern error"
	
label define timingcog ///
	1 "1.gradually" ///
	2 "2.suddenly" ///
	.x ".x:no memory problems"
	
 

*set wave number
local wv=2
local pre_wv=1


****merge with wave 2 end of life data***
local cogxt_w2_exit EiCogA EiCogB EiCogC EiCogD EiCogE EiCogF EiCogG EiCogH EiCogI EiCogJ ///
										EiCogK EiCogL EiCogM EiCogN EiCogO EiCogQ EiCogR 
merge 1:1 idauniq using "$wave_2_xt", keepusing(`cogxt_w2_exit') nogen




***Difficulty Remembering Things About Family***
*wave 2 respondent diff remembering things about family
gen radfamf = .
missing_w2 EiCogA if inw`wv'xt==1, result(radfamf)
replace radfamf = .d if EiCogA==4
replace radfamf = EiCogA if inrange(EiCogA,1,3)
label variable radfamf "radfamf: r diff remembering things about family/friends"
label values radfamf difficulty

***Difficulty Remembering Recent Events***
*wave 2 respondent diff remembering recent events
gen radevnt = .
missing_w2 EiCogB if inw`wv'xt==1, result(radevnt)
replace radevnt = .d if EiCogB==4
replace radevnt = EiCogB if inrange(EiCogB,1,3)
label variable radevnt "radevnt: r diff remembering recent events"
label values radevnt difficulty

***Difficulty Recalling Conversations***
*wave 2 respondent diff recalling conversations
gen radconv = .
missing_w2 EiCogC if inw`wv'xt==1, result(radconv)
replace radconv = .d if EiCogC==4
replace radconv = EiCogC if inrange(EiCogC,1,3)
label variable radconv "radconv: r diff recalling conversations days later"
label values radconv difficulty

***Difficulty Remembering Address and Telephone Number***
*wave 2 respondent diff remembering address and telephone number
gen radaddr = .
missing_w2 EiCogD if inw`wv'xt==1, result(radaddr)
replace radaddr = .d if EiCogD==4
replace radaddr = EiCogD if inrange(EiCogD,1,3)
label variable radaddr "radaddr: r diff remembering address/phone number"
label values radaddr difficulty

***Difficulty Remembering Date***
*wave 2 respondent diff remembering date
gen raddymon = .
missing_w2 EiCogE if inw`wv'xt==1, result(raddymon)
replace raddymon = .d if EiCogE==4
replace raddymon = EiCogE if inrange(EiCogE,1,3)
label variable raddymon "raddymon: r diff remembering day and month"
label values raddymon difficulty

***Difficulty Remembering Where Things Usually Kept***
*wave 2 respondent diff remembering where things usually kept
gen radkept = .
missing_w2 EiCogF if inw`wv'xt==1, result(radkept)
replace radkept = .d if EiCogF==4
replace radkept = EiCogF if inrange(EiCogF,1,3)
label variable radkept "radkept: r diff remembering where things usually kept"
label values radkept difficulty

***Difficulty Following a Story***
*wave 2 respondent diff following a story
gen radstry = .
missing_w2 EiCogG if inw`wv'xt==1, result(radstry)
replace radstry = .d if EiCogG==4
replace radstry = EiCogG if inrange(EiCogG,1,3)
label variable radstry "radstry: r diff following a story"
label values radstry difficulty

***Difficulty Making Everyday Decisions***
*wave 2 respondent diff making everyday decisions
gen raddcsn = .
missing_w2 EiCogH if inw`wv'xt==1, result(raddcsn)
replace raddcsn = .d if EiCogH==4
replace raddcsn = EiCogH if inrange(EiCogH,1,3)
label variable raddcsn "raddcsn: r diff making everyday decisions"
label values raddcsn difficulty

***Difficulty Handling Financial Matters***
*wave 2 respondent diff handling financial matters
gen radfinl = .
missing_w2 EiCogI if inw`wv'xt==1, result(radfinl)
replace radfinl = .d if EiCogI==4
replace radfinl = EiCogI if inrange(EiCogI,1,3)
label variable radfinl "radfinl: r diff handling financial matters"
label values radfinl difficulty

***Difficulty Interpreting Surroundings***
*wave 2 respondent diff interpreting surroundings
gen radsurr = .
missing_w2 EiCogK if inw`wv'xt==1, result(radsurr)
replace radsurr = .d if EiCogK==4
replace radsurr = EiCogK if inrange(EiCogK,1,3)
label variable radsurr "radsurr: r diff interpreting surroundings"
label values radsurr difficulty

***Difficulty Finding Way Around Home***
*wave 2 respondent diff finding way around home
gen radhome = .
missing_w2 EiCogL if inw`wv'xt==1, result(radhome)
replace radhome = .d if EiCogL==5
replace radhome = .n if EiCogL==4
replace radhome = EiCogL if inrange(EiCogL,1,3)
label variable radhome "radhome: r diff finding way around home"
label values radhome difficulty

***Frequency Repeated Questions***
*wave 2 respondent frequency repeated questions
gen rafqust = .
missing_w2 EiCogJ if inw`wv'xt==1, result(rafqust)
replace rafqust = .d if EiCogJ==4
replace rafqust = EiCogJ if inrange(EiCogJ,1,3)
label variable rafqust "rafqust: r freq repeated questions"
label values rafqust cogfreq

***Difficulty Finding the Right Word***
*wave 2 respondent diff finding the right word
gen radrwrd = .
missing_w2 EiCogM if inw`wv'xt==1, result(radrwrd)
replace radrwrd = .d if EiCogM==4
replace radrwrd = EiCogM if inrange(EiCogM,1,3)
label variable radrwrd "radrwrd: r freq diff finding the right word"
label values radrwrd cogfreq

***Ever Repeat Same Word***
*wave 2 respondent ever repeat same word
gen raerpwd = .
missing_w2 EiCogN if inw`wv'xt==1, result(raerpwd)
replace raerpwd = .d if EiCogN==3
replace raerpwd = 0 if EiCogN==1
replace raerpwd = 1 if EiCogN==2
label variable raerpwd "raerpwd: r ever repeat same word"
label values raerpwd yesnocog

***Thinking Ever Muddled***
*wave 2 respondent thinking ever muddled
gen raemudl = .
missing_w2 EiCogO if inw`wv'xt==1, result(raemudl)
replace raemudl = .d if EiCogO==3
replace raemudl = 0 if EiCogO==1
replace raemudl = 1 if EiCogO==2
label variable raemudl "raemudl: r ever have muddled thinking"
label values raemudl yesnocog

***Changes Developed Gradually or Suddenly***
*wave 2 respondent changes developed gradually or suddenly
gen ramprobgs = .
missing_w2 EiCogJ EiCogK EiCogL EiCogM EiCogN EiCogO EiCogQ if inw`wv'xt==1, result(ramprobgs)
replace ramprobgs = .x if EiCogJ==1 & EiCogK==1 & EiCogL==1 & EiCogM==1 & EiCogN==1 & EiCogO==1
replace ramprobgs = .d if EiCogQ==3 | EiCogJ==4 | EiCogK==4 | EiCogL==5 | EiCogM==4 | EiCogN==3 | EiCogO==3
replace ramprobgs = EiCogQ if inrange(EiCogQ,1,2)
label variable ramprobgs "ramprobgs: r's memory problems gradual or sudden"
label values ramprobgs timingcog

***Whether Marked Fluctuations in Attention***
*wave 2 respondent whether marked fluctuations in attention
gen raflxatt = .
missing_w2 EiCogR if inw`wv'xt==1, result(raflxatt)
replace raflxatt = .d if EiCogR==3
replace raflxatt = 0 if EiCogR==1
replace raflxatt = 1 if EiCogR==2
label variable raflxatt "raflxatt: r had marked fluctuations in attention"
label values raflxatt yesnocog



***drop ELSA wave 2 eol file raw variables***
drop `cogxt_w2_exit'



******************************************************************************************


*set wave number
local wv=3
local pre_wv=2


****merge with wave 3 end of life data***
local cogxt_w3_exit EiCogA EiCogB EiCogC EiCogD EiCogE EiCogF EiCogG EiCogH EiCogI EiCogJ ///
										EiCogK EiCogL EiCogM EiCogN EiCogO EiCogQ EiCogR 
merge 1:1 idauniq using "$wave_3_xt", keepusing(`cogxt_w3_exit') nogen




***Difficulty Remembering Things About Family***
*wave 3 respondent diff remembering things about family
missing_w3 EiCogA if inw`wv'xt==1, result(radfamf)
replace radfamf = .d if EiCogA==4
replace radfamf = EiCogA if inrange(EiCogA,1,3)

***Difficulty Remembering Recent Events***
*wave 3 respondent diff remembering recent events
missing_w3 EiCogB if inw`wv'xt==1, result(radevnt)
replace radevnt = .d if EiCogB==4
replace radevnt = EiCogB if inrange(EiCogB,1,3)

***Difficulty Recalling Conversations***
*wave 3 respondent diff recalling conversations
missing_w3 EiCogC if inw`wv'xt==1, result(radconv)
replace radconv = .d if EiCogC==4
replace radconv = EiCogC if inrange(EiCogC,1,3)

***Difficulty Remembering Address and Telephone Number***
*wave 3 respondent diff remembering address and telephone number
missing_w3 EiCogD if inw`wv'xt==1, result(radaddr)
replace radaddr = .d if EiCogD==4
replace radaddr = EiCogD if inrange(EiCogD,1,3)

***Difficulty Remembering Date***
*wave 3 respondent diff remembering date
missing_w3 EiCogE if inw`wv'xt==1, result(raddymon)
replace raddymon = .d if EiCogE==4
replace raddymon = EiCogE if inrange(EiCogE,1,3)

***Difficulty Remembering Where Things Usually Kept***
*wave 3 respondent diff remembering where things usually kept
missing_w3 EiCogF if inw`wv'xt==1, result(radkept)
replace radkept = .d if EiCogF==4
replace radkept = EiCogF if inrange(EiCogF,1,3)

***Difficulty Following a Story***
*wave 3 respondent diff following a story
missing_w3 EiCogG if inw`wv'xt==1, result(radstry)
replace radstry = .d if EiCogG==4
replace radstry = EiCogG if inrange(EiCogG,1,3)

***Difficulty Making Everyday Decisions***
*wave 3 respondent diff making everyday decisions
missing_w3 EiCogH if inw`wv'xt==1, result(raddcsn)
replace raddcsn = .d if EiCogH==4
replace raddcsn = EiCogH if inrange(EiCogH,1,3)

***Difficulty Handling Financial Matters***
*wave 3 respondent diff handling financial matters
missing_w3 EiCogI if inw`wv'xt==1, result(radfinl)
replace radfinl = .d if EiCogI==4
replace radfinl = EiCogI if inrange(EiCogI,1,3)

***Difficulty Interpreting Surroundings***
*wave 3 respondent diff interpreting surroundings
missing_w3 EiCogK if inw`wv'xt==1, result(radsurr)
replace radsurr = .d if EiCogK==4
replace radsurr = EiCogK if inrange(EiCogK,1,3)

***Difficulty Finding Way Around Home***
*wave 3 respondent diff finding way around home
missing_w3 EiCogL if inw`wv'xt==1, result(radhome)
replace radhome = .d if EiCogL==5
replace radhome = .n if EiCogL==4
replace radhome = EiCogL if inrange(EiCogL,1,3)

***Frequency Repeated Questions***
*wave 3 respondent frequency repeated questions
missing_w3 EiCogJ if inw`wv'xt==1, result(rafqust)
replace rafqust = .d if EiCogJ==4
replace rafqust = EiCogJ if inrange(EiCogJ,1,3)

***Difficulty Finding the Right Word***
*wave 3 respondent diff finding the right word
missing_w3 EiCogM if inw`wv'xt==1, result(radrwrd)
replace radrwrd = .d if EiCogM==4
replace radrwrd = EiCogM if inrange(EiCogM,1,3)

***Ever Repeat Same Word***
*wave 3 respondent ever repeat same word
missing_w3 EiCogN if inw`wv'xt==1, result(raerpwd)
replace raerpwd = .d if EiCogN==3
replace raerpwd = 0 if EiCogN==1
replace raerpwd = 1 if EiCogN==2

***Thinking Ever Muddled***
*wave 3 respondent thinking ever muddled
missing_w3 EiCogO if inw`wv'xt==1, result(raemudl)
replace raemudl = .d if EiCogO==3
replace raemudl = 0 if EiCogO==1
replace raemudl = 1 if EiCogO==2

***Changes Developed Gradually or Suddenly***
*wave 3 respondent changes developed gradually or suddenly
missing_w3 EiCogJ EiCogK EiCogL EiCogM EiCogN EiCogO EiCogQ if inw`wv'xt==1, result(ramprobgs)
replace ramprobgs = .x if EiCogJ==1 & EiCogK==1 & EiCogL==1 & EiCogM==1 & EiCogN==1 & EiCogO==1
replace ramprobgs = .d if EiCogQ==3 | EiCogJ==4 | EiCogK==4 | EiCogL==5 | EiCogM==4 | EiCogN==3 | EiCogO==3
replace ramprobgs = EiCogQ if inrange(EiCogQ,1,2)

***Whether Marked Fluctuations in Attention***
*wave 3 respondent whether marked fluctuations in attention
missing_w3 EiCogR if inw`wv'xt==1, result(raflxatt)
replace raflxatt = .d if EiCogR==3
replace raflxatt = 0 if EiCogR==1
replace raflxatt = 1 if EiCogR==2



***drop ELSA wave 3 eol file raw variables***
drop `cogxt_w3_exit'



******************************************************************************************


*set wave number
local wv=4
local pre_wv=3

****merge with wave 4 end of life data***
local cogxt_w4_exit EiCogA EiCogB EiCogC EiCogD EiCogE EiCogF EiCogG EiCogH EiCogI EiCogJ ///
										EiCogK EiCogL EiCogM EiCogN EiCogO EiCogQ EiCogR 
merge 1:1 idauniq using "$w4_xt", keepusing(`cogxt_w4_exit') nogen




***Difficulty Remembering Things About Family***
*wave 4 respondent diff remembering things about family
missing_w4 EiCogA if inw`wv'xt==1, result(radfamf)
replace radfamf = .d if EiCogA==4
replace radfamf = EiCogA if inrange(EiCogA,1,3)

***Difficulty Remembering Recent Events***
*wave 4 respondent diff remembering recent events
missing_w4 EiCogB if inw`wv'xt==1, result(radevnt)
replace radevnt = .d if EiCogB==4
replace radevnt = EiCogB if inrange(EiCogB,1,3)

***Difficulty Recalling Conversations***
*wave 4 respondent diff recalling conversations
missing_w4 EiCogC if inw`wv'xt==1, result(radconv)
replace radconv = .d if EiCogC==4
replace radconv = EiCogC if inrange(EiCogC,1,3)

***Difficulty Remembering Address and Telephone Number***
*wave 4 respondent diff remembering address and telephone number
missing_w4 EiCogD if inw`wv'xt==1, result(radaddr)
replace radaddr = .d if EiCogD==4
replace radaddr = EiCogD if inrange(EiCogD,1,3)

***Difficulty Remembering Date***
*wave 4 respondent diff remembering date
missing_w4 EiCogE if inw`wv'xt==1, result(raddymon)
replace raddymon = .d if EiCogE==4
replace raddymon = EiCogE if inrange(EiCogE,1,3)

***Difficulty Remembering Where Things Usually Kept***
*wave 4 respondent diff remembering where things usually kept
missing_w4 EiCogF if inw`wv'xt==1, result(radkept)
replace radkept = .d if EiCogF==4
replace radkept = EiCogF if inrange(EiCogF,1,3)

***Difficulty Following a Story***
*wave 4 respondent diff following a story
missing_w4 EiCogG if inw`wv'xt==1, result(radstry)
replace radstry = .d if EiCogG==4
replace radstry = EiCogG if inrange(EiCogG,1,3)

***Difficulty Making Everyday Decisions***
*wave 4 respondent diff making everyday decisions
missing_w4 EiCogH if inw`wv'xt==1, result(raddcsn)
replace raddcsn = .d if EiCogH==4
replace raddcsn = EiCogH if inrange(EiCogH,1,3)

***Difficulty Handling Financial Matters***
*wave 4 respondent diff handling financial matters
missing_w4 EiCogI if inw`wv'xt==1, result(radfinl)
replace radfinl = .d if EiCogI==4
replace radfinl = EiCogI if inrange(EiCogI,1,3)

***Difficulty Interpreting Surroundings***
*wave 4 respondent diff interpreting surroundings
missing_w4 EiCogK if inw`wv'xt==1, result(radsurr)
replace radsurr = .d if EiCogK==4
replace radsurr = EiCogK if inrange(EiCogK,1,3)

***Difficulty Finding Way Around Home***
*wave 4 respondent diff finding way around home
missing_w4 EiCogL if inw`wv'xt==1, result(radhome)
replace radhome = .d if EiCogL==5
replace radhome = .n if EiCogL==4
replace radhome = EiCogL if inrange(EiCogL,1,3)

***Frequency Repeated Questions***
*wave 4 respondent frequency repeated questions
missing_w4 EiCogJ if inw`wv'xt==1, result(rafqust)
replace rafqust = .d if EiCogJ==4
replace rafqust = EiCogJ if inrange(EiCogJ,1,3)

***Difficulty Finding the Right Word***
*wave 4 respondent diff finding the right word
missing_w4 EiCogM if inw`wv'xt==1, result(radrwrd)
replace radrwrd = .d if EiCogM==4
replace radrwrd = EiCogM if inrange(EiCogM,1,3)

***Ever Repeat Same Word***(YES/NO SWITCHED)
*wave 4 respondent ever repeat same word
missing_w4 EiCogN if inw`wv'xt==1, result(raerpwd)
replace raerpwd = .d if EiCogN==3
replace raerpwd = 0 if EiCogN==2
replace raerpwd = 1 if EiCogN==1

***Thinking Ever Muddled***(YES/NO SWITCHED)
*wave 4 respondent thinking ever muddled
missing_w4 EiCogO if inw`wv'xt==1, result(raemudl)
replace raemudl = .d if EiCogO==3
replace raemudl = 0 if EiCogO==2
replace raemudl = 1 if EiCogO==1

***Changes Developed Gradually or Suddenly***
*wave 4 respondent changes developed gradually or suddenly
missing_w4 EiCogJ EiCogK EiCogL EiCogM EiCogN EiCogO EiCogQ if inw`wv'xt==1, result(ramprobgs)
replace ramprobgs = .x if EiCogJ==1 & EiCogK==1 & EiCogL==1 & EiCogM==1 & EiCogN==2 & EiCogO==2
replace ramprobgs = .d if EiCogQ==3 | EiCogJ==4 | EiCogK==4 | EiCogL==5 | EiCogM==4 | EiCogN==3 | EiCogO==3
replace ramprobgs = EiCogQ if inrange(EiCogQ,1,2)

***Whether Marked Fluctuations in Attention***(YES/NO SWITCHED)
*wave 4 respondent whether marked fluctuations in attention
missing_w4 EiCogR if inw`wv'xt==1, result(raflxatt)
replace raflxatt = .d if EiCogR==3
replace raflxatt = 0 if EiCogR==2
replace raflxatt = 1 if EiCogR==1



***drop ELSA wave 4 eol file raw variables***
drop `cogxt_w4_exit'



******************************************************************************************


*set wave number
local wv=6
local pre_wv=5

****merge with wave 6 end of life data***
local cogxt_w6_exit EiCogA EiCogB EiCogC EiCogD EiCogE EiCogF EiCogG EiCogH EiCogI EiCogJ ///
										EiCogK EiCogL EiCogM EiCogN EiCogO EiCogQ EiCogR 
merge 1:1 idauniq using "$wave_6_xt", keepusing(`cogxt_w6_exit') nogen




***Difficulty Remembering Things About Family***
*wave 6 respondent diff remembering things about family
missing_w6 EiCogA if inw`wv'xt==1, result(radfamf)
replace radfamf = .d if EiCogA==4
replace radfamf = EiCogA if inrange(EiCogA,1,3)

***Difficulty Remembering Recent Events***
*wave 6 respondent diff remembering recent events
missing_w6 EiCogB if inw`wv'xt==1, result(radevnt)
replace radevnt = .d if EiCogB==4
replace radevnt = EiCogB if inrange(EiCogB,1,3)

***Difficulty Recalling Conversations***
*wave 6 respondent diff recalling conversations
missing_w6 EiCogC if inw`wv'xt==1, result(radconv)
replace radconv = .d if EiCogC==4
replace radconv = EiCogC if inrange(EiCogC,1,3)

***Difficulty Remembering Address and Telephone Number***
*wave 6 respondent diff remembering address and telephone number
missing_w6 EiCogD if inw`wv'xt==1, result(radaddr)
replace radaddr = .d if EiCogD==4
replace radaddr = EiCogD if inrange(EiCogD,1,3)

***Difficulty Remembering Date***
*wave 6 respondent diff remembering date
missing_w6 EiCogE if inw`wv'xt==1, result(raddymon)
replace raddymon = .d if EiCogE==4
replace raddymon = EiCogE if inrange(EiCogE,1,3)

***Difficulty Remembering Where Things Usually Kept***
*wave 6 respondent diff remembering where things usually kept
missing_w6 EiCogF if inw`wv'xt==1, result(radkept)
replace radkept = .d if EiCogF==4
replace radkept = EiCogF if inrange(EiCogF,1,3)

***Difficulty Following a Story***
*wave 6 respondent diff following a story
missing_w6 EiCogG if inw`wv'xt==1, result(radstry)
replace radstry = .d if EiCogG==4
replace radstry = EiCogG if inrange(EiCogG,1,3)

***Difficulty Making Everyday Decisions***
*wave 6 respondent diff making everyday decisions
missing_w6 EiCogH if inw`wv'xt==1, result(raddcsn)
replace raddcsn = .d if EiCogH==4
replace raddcsn = EiCogH if inrange(EiCogH,1,3)

***Difficulty Handling Financial Matters***
*wave 6 respondent diff handling financial matters
missing_w6 EiCogI if inw`wv'xt==1, result(radfinl)
replace radfinl = .d if EiCogI==4
replace radfinl = EiCogI if inrange(EiCogI,1,3)

***Difficulty Interpreting Surroundings***
*wave 6 respondent diff interpreting surroundings
missing_w6 EiCogK if inw`wv'xt==1, result(radsurr)
replace radsurr = .d if EiCogK==4
replace radsurr = EiCogK if inrange(EiCogK,1,3)

***Difficulty Finding Way Around Home***
*wave 6 respondent diff finding way around home
missing_w6 EiCogL if inw`wv'xt==1, result(radhome)
replace radhome = .d if EiCogL==5
replace radhome = .n if EiCogL==4
replace radhome = EiCogL if inrange(EiCogL,1,3)

***Frequency Repeated Questions***
*wave 6 respondent frequency repeated questions
missing_w6 EiCogJ if inw`wv'xt==1, result(rafqust)
replace rafqust = .d if EiCogJ==4
replace rafqust = EiCogJ if inrange(EiCogJ,1,3)

***Difficulty Finding the Right Word***
*wave 6 respondent diff finding the right word
missing_w6 EiCogM if inw`wv'xt==1, result(radrwrd)
replace radrwrd = .d if EiCogM==4
replace radrwrd = EiCogM if inrange(EiCogM,1,3)

***Ever Repeat Same Word***(YES/NO SWITCHED)
*wave 6 respondent ever repeat same word
missing_w6 EiCogN if inw`wv'xt==1, result(raerpwd)
replace raerpwd = .d if EiCogN==3
replace raerpwd = 0 if EiCogN==2
replace raerpwd = 1 if EiCogN==1

***Thinking Ever Muddled***(YES/NO SWITCHED)
*wave 6 respondent thinking ever muddled
missing_w6 EiCogO if inw`wv'xt==1, result(raemudl)
replace raemudl = .d if EiCogO==3
replace raemudl = 0 if EiCogO==2
replace raemudl = 1 if EiCogO==1

***Changes Developed Gradually or Suddenly***
*wave 6 respondent changes developed gradually or suddenly
missing_w6 EiCogJ EiCogK EiCogL EiCogM EiCogN EiCogO EiCogQ if inw`wv'xt==1, result(ramprobgs)
replace ramprobgs = .x if EiCogJ==1 & EiCogK==1 & EiCogL==1 & EiCogM==1 & EiCogN==2 & EiCogO==2
replace ramprobgs = .d if EiCogQ==3 | EiCogJ==4 | EiCogK==4 | EiCogL==5 | EiCogM==4 | EiCogN==3 | EiCogO==3
replace ramprobgs = EiCogQ if inrange(EiCogQ,1,2)

***Whether Marked Fluctuations in Attention***(YES/NO SWITCHED)
*wave 6 respondent whether marked fluctuations in attention
missing_w6 EiCogR if inw`wv'xt==1, result(raflxatt)
replace raflxatt = .d if EiCogR==3
replace raflxatt = 0 if EiCogR==2
replace raflxatt = 1 if EiCogR==1



***drop ELSA wave 6 eol file raw variables***
drop `cogxt_w6_exit'



******************************************************************************************




label define yesnohome ///
	0 "0.no" ///
	1 "1.yes" ///
	.t ".t:not distributed yet" ///
	.q ".q:not asked this wave" ///
	.x ".x:didn't own home"
	
label define homedis ///
	1 "1.spouse lives there" ///
	2 "2.other person lives there" ///
	3 "3.currently empty" ///
	4 "4.currently being let out" ///
	5 "5.currently on the market" ///
	6 "6.already been sold" ///
	7 "7.other" ///
	.t ".t:not distributed yet" ///
	.x ".x:didn't own home" ///
	.q ".q:not asked this wave"
	
label define assetflag ///
	-1 "-1.not imputed, missing neighbors" ///
  -2 "-2.not imputed, missing covariates" ///
  -3 "-3.not imputed, estate not distributed" ///
	1 "1.continuous value" ///
	2 "2.closed bracket" ///
	3 "3.open bracket" ///
	5 "5.no bracket info" ///
	6 "6.no asset" ///
	7 "7.ownership unknown" ///
	.q ".q:not asked this wave"
	
 

*set wave number
local wv=2
local pre_wv=1

local assetxt_w2_exit EiPenM EiPenN EiPen1 EiPen2 EiPen3 EiPen4 EiPen5 EiPen6 EiPen7 EiPen8 EiPen9 EiPen10 ///
											EiPen11 EiPen12 EiPen13 EiPen14 EiPen15 EiPenxla EiPerwl1 EiPerwu1 EiPerml1 EiPermu1 EiPerml3 EiPermu3 
merge 1:1 idauniq using "$wave_2_xt", keepusing(`assetxt_w2_exit') nogen



***owned home at death***
*wave 2 respondent owned home at death
gen raxahown = .
replace raxahown = .q if inw`wv'xt==1
label variable raxahown "raxahown: r owned home at death"
label values raxahown yesnohome

***disposition of home***
*wave 2 respondent disposition of home
gen raxhomedis_e = .
replace raxhomedis_e = .q if inw`wv'xt==1
label variable raxhomedis_e "raxhomedis_e: disposition of r's home"
label values raxhomedis_e homedis

***value home***
*wave 2 respondent value home
gen raxahous = .
label variable raxahous "raxahous: asset: value r's home"

*wave 2 respondent flag value home
gen raxafhous = .
label variable raxafhous "raxafhous: asset flag: value r's home"
label values raxafhous assetflag

***value of mortgage***
*wave 2 respondent value mortgage
gen raxamort = .
label variable raxamort "raxamort: asset: value r's home mortgage"

*wave 2 respondent flag value mortgage
gen raxafmort = .
label variable raxafmort "raxafmort: asset flag: value r's home mortgage"
label values raxafmort assetflag

***net value home***
*wave 2 respondent net value home
gen raxatoth = .
label variable raxatoth "raxatoth: asset: net value of r's home"

*wave 2 respondent flag net value home
gen raxaftoth  = .
label variable raxaftoth "raxaftoth: asset flag: net value of r's home"
label values raxaftoth assetflag

***net value other real estate***
*wave 2 respondent net value other real estate
gen raxarles = .
label variable raxarles "raxarles: asset: net value other real estate"

*wave 2 respondent flag net value other real estate
gen raxafrles = .
label variable raxafrles "raxafrles: asset flag: net value other real estate"
label values raxafrles assetflag

***net value business***
*wave 2 respondent net value business
gen raxabsns = .
label variable raxabsns "raxabsns: asset: net value of business"

*wave 2 respondent flag net value business
gen raxafbsns = .
label variable raxafbsns "raxafbsns: asset flag: net value of business"
label values raxafbsns assetflag

***net value of non-housing financial wealth***
*wave 2 respondent net value non-housing financial wealth
gen raxatotf_e = . 
label variable raxatotf_e "raxatotf_e: asset: r's non-housing financial wealth"

*wave 2 respondent flag net value non-housing financial wealth
gen raxaftotf_e = . 
label variable raxaftotf_e "raxaftotf_e: asset flag: r's non-housing financial wealth"
label values raxaftotf_e assetflag

***total assets***
*wave 2 respondent total assets***
gen raxatotb = .
label variable raxatotb "raxatotb: asset: r's total assets"

*wave 2 respondent flag total assets***
gen raxaftotb = .
label variable raxaftotb "raxaftotb: asset flag: r's total assets"
label values raxaftotb assetflag

***total non-housing assets***
*wave 2 respondent total non-housing assets***
gen raxatotn = .
label variable raxatotn "raxatotn: asset: r's total non-housing assets"

*wave 2 respondent flag total non-housing assets***
gen raxaftotn = .
label variable raxaftotn "raxaftotn: asset flag: r's total non-housing assets"
label values raxaftotn assetflag

***lump sum pension benefits***
*wave 2 respondent lump sum pension benefits
gen raxapenls = .
label variable raxapenls "raxapenls: asset: r's pension benefits - lump sum"

*wave 2 respondent flag lump sum pension benefits
gen raxafpenls = .
label variable raxafpenls "raxafpenls: asset flag: r's pension benefits - lump sum"
label values raxafpenls assetflag

**pension 1
*received lump sum amt - no variable for amount, no values for min/max 
*expected lump sum amt - 1 value for amount, no values for min/max
gen penll1 = .
gen penlu1 = .

gen penlo1 = .
replace penlo1 = 0 if EiPenM==2 | (EiPenM==1 & inrange(EiPenN,1,3) & (EiPen2==0 | EiPen4==0))
replace penlo1 = 1 if EiPenM==1 & inrange(EiPenN,1,3) & (EiPen2==1 | EiPen4==1)

gen penl1 = EiPenxla if inrange(EiPenxla,0,50000)

**pension 2 - no values
gen penll2 = .
gen penlu2 = .
gen penlo2 = .
replace penlo2 = 0 if EiPenM==2 | (EiPenM==1 & EiPenN==1) | (EiPenM==1 & inlist(EiPenN,2,3) & (EiPen7==0 | EiPen9==0))
replace penlo2 = 1 if EiPenM==1 & inlist(EiPenN,2,3) & (EiPen7==1 | EiPen9==1)
gen penl2 = .

**pension 3 - no values
gen penll3 = .
gen penlu3 = .
gen penlo3 = .
replace penlo3 = 0 if EiPenM==2 | (EiPenM==1 & inlist(EiPenN,1,2)) | (EiPenM==1 & EiPenN==3 & (EiPen12==0 | EiPen14==0))
replace penlo3 = 1 if EiPenM==1 & EiPenN==3 & (EiPen12==1 | EiPen14==1)
gen penl3 = .


***regular payment pension benefits***
*wave 2 respondent regular payment pension benefits
gen raxapenpy = .
label variable raxapenpy "raxapenpy: asset: r's pension benefits - payment per year"

*wave 2 respondent flag regular payment pension benefits
gen raxafpenpy = .
label variable raxafpenpy "raxafpenpy: asset flag: r's pension benefits - payment per year"
label values raxafpenpy assetflag


**pension 1
*received payment amt - no variable for amount
	*1 value biweekly min/max for pension 1
	*3 values & 1 dk monthly min/max for pension 1
	*no values for other amount/min/max for pension 1
*expected payment amt - 1 dk for amount, 1 dk for min/max
gen penpl1 = EiPerwl1*26 if inrange(EiPerwl1,0,2000) //biweekly
replace penpl1 = EiPerml1*12 if inrange(EiPerml1,0,2000) //monthly
gen penpu1 = EiPerwu1*26 if inrange(EiPerwu1,0,2000) //biweekly
replace penpu1 = EiPermu1*12 if inrange(EiPermu1,0,2000) //monthly

gen penpo1 = .
replace penpo1 = 0 if EiPenM==2 | (EiPenM==1 & inrange(EiPenN,1,3) & (EiPen1==0 | EiPen3==0))
replace penpo1 = 1 if EiPenM==1 & inrange(EiPenN,1,3) & (EiPen1==1 | EiPen3==1)

gen penp1 = .

**pension 2 - no values
gen penpl2 = .
gen penpu2 = .

gen penpo2 = .
replace penpo2 = 0 if EiPenM==2 | (EiPenM==1 & EiPenN==1) | (EiPenM==1 & inlist(EiPenN,2,3) & (EiPen6==0 | EiPen8==0))
replace penpo2 = 1 if EiPenM==1 & inlist(EiPenN,2,3) & (EiPen6==1 | EiPen8==1)

gen penp2 = .

**pension 3
*received payment - 1 dk value for monthly min/max for pension 3
gen penpl3 = EiPerml3*12 if inrange(EiPerml3,0,2000)
gen penpu3 = EiPermu3*12 if inrange(EiPermu3,0,2000)

gen penpo3 = .
replace penpo3 = 0 if EiPenM==2 | (EiPenM==1 & inlist(EiPenN,1,2)) | (EiPenM==1 & EiPenN==3 & (EiPen11==0 | EiPen13==0))
replace penpo3 = 1 if EiPenM==1 & EiPenN==3 & (EiPen11==1 | EiPen13==1)

gen penp3 = .



***drop ELSA wave 2 core file raw variables***
drop `assetxt_w2_exit'


******************************************************************************************


*set wave number
local wv=3
local pre_wv=2

local assetxt_w3_exit EiRRel EiAsCk EiHome EiSp EiSpOwn EiSpLive EiSpInH EiHoLiv EiHoLv EiHoSld EioHSld SurvSp ///
											EiJoint EioIn EioHLiv EioHLv EiWillA EiWillB EiProb ///
											DVEiHoa DVEioHa EiHoMg EioHMg EiHoMgI EioHMgI EiHoMga EiHobl EiHobu EioHbl EioHbu EiPrp DVEiHoa2 ///
											EiHoMg2 EioHMg2 EiHoMgI2 EioHMgI2 EIphy EIphya EiOthres EiOthSps EiOthPrt EiAmt?? EiAmt??? EiAmProb EiWillPr ///
											EiOthAs? EiHol EiHou EioHl EioHu EiHobol1 EiHobou1 EiHool1 EiHoou1 EIphl Eiphu EiHoMga2 ///
											EiPenM EiPenN EiPen1 EiPen2 EiPen3 EiPen4 EiPen5 EiPen6 EiPen7 EiPen8 EiPen9 EiPen10 ///
											EiPen11 EiPen12 EiPen13 EiPen14 EiPen15 EiPerml1 EiPermu1 EiPerml2 EiPermu2 ///
											EiPerll1 EiPerll2 EiPerll3 EiPerlu1 EiPerlu2 EiPerlu3 EiPenxpa EiPexpl1 EiPexpu1
merge 1:1 idauniq using "$wave_3_xt", keepusing(`assetxt_w3_exit') nogen



gen notdist = .
replace notdist = 1 if EiAsCk==2

***owned home at death***
*wave 3 respondent owned home at death
missing_w3 EiAsCk EiHome if inw`wv'xt==1, result(raxahown)
replace raxahown = .t if EiAsCk==2 & EiHome==-1
replace raxahown = 0 if EiHome==2
replace raxahown = 1 if EiHome==1

***disposition of home***
*wave 3 respondent disposition of home
missing_w3 EiAsCk EiHome EiSpLive EiHoLiv EiHoLv EioHLiv EioHLv EiHoSld EioHSld /// 
						if inw`wv'xt==1, result(raxhomedis_e)
replace raxhomedis_e = .t if EiAsCk==2 & EiHome==-1
replace raxhomedis_e = .x if EiHome==2
replace raxhomedis_e = 1 if EiSpLive==1
replace raxhomedis_e = 2 if EiHoLiv==1 | EiHoLv==1 | EioHLiv==1 | EioHLv==1
replace raxhomedis_e = 3 if EiHoSld==1 | EioHSld==1
replace raxhomedis_e = 4 if EiHoSld==2 | EioHSld==2
replace raxhomedis_e = 5 if EiHoSld==3 | EioHSld==3
replace raxhomedis_e = 6 if EiHoSld==4 | EioHSld==4
replace raxhomedis_e = 7 if EiHoSld==95 | EioHSld==95


***value home***
*wave 3 respondent value home
*w/ spouse
gen eihol = EiHol if inrange(EiHol,1,1000000)
gen eihou = EiHou if inrange(EiHou,1,1000000)

gen houseao = .
replace houseao = 0 if EiHome==2 | EiAsCk==2 | inrange(EiRRel,3,22) | SurvSp==2
replace houseao = 1 if EiHome==1 & (inlist(EiRRel,1,2) | SurvSp==1)

gen housea = .
replace housea = 70000 if DVEiHoa==1 //1-140,000
replace housea = 170000 if DVEiHoa==2 //140,000.01-200,000
replace housea = 250000 if DVEiHoa==3 //200,000.01-300,000
replace housea = 625000 if DVEiHoa==4 //300,000.01-950,000

*no spouse
gen eiohl = EioHl if inrange(EioHl,1,1000000)
gen eiohu = EioHu if inrange(EioHu,1,1000000)

gen housebo = .
replace housebo = 0 if EiHome==2 | EiAsCk==2 | inlist(EiRRel,1,2) | SurvSp==1
replace housebo = 1 if EiHome==1 & (inrange(EiRRel,3,22) & SurvSp==2)

gen houseb = .
replace houseb = 40000 if DVEioHa==1 //1-80,000
replace houseb = 115000 if DVEioHa==2 //80,000.01-150,000
replace houseb = 175000 if DVEioHa==3 //150,000.01-200,000
replace houseb = 412500 if DVEioHa==4 //200,000.01-625,000


***value mortgage***
*wave 3 respondent value mortgage
*w/ spouse
gen eihobl = EiHobl if inrange(EiHobl,1,1000000)
gen eihobu = EiHobu if inrange(EiHobu,1,1000000)

gen mortao = .
replace mortao = 0 if EiHome==2 | EiAsCk==2 | inrange(EiRRel,3,22) | SurvSp==2 | EiHoMg==2 | EiHoMgI==1 
replace mortao = 1 if EiHome==1 & (inlist(EiRRel,1,2) | SurvSp==1) & EiHoMg==1 & inlist(EiHoMgI,2,3)

gen morta = EiHoMga if inrange(EiHoMga,1,50000)

*no spouse - no existing EioHMga, 1 dk bracket (EioHbl, EioHbu)
gen eiohbl = EioHbl if inrange(EioHbl,1,1000000)
gen eiohbu = EioHbu if inrange(EioHbu,1,1000000)

gen mortbo = .
replace mortbo = 0 if EiHome==2 | EiAsCk==2 | inrange(EiRRel,1,2) | SurvSp==1 | EioHMg==2 | EioHMgI==1
replace mortbo = 1 if EiHome==1 & (inrange(EiRRel,3,22) & SurvSp==2) & EioHMg==1 & inlist(EioHMgI,2,3)

gen mortb = .


***net value home***
*wave 3 respondent net value home


***net value other real estate***
*wave 3 respondent net value other real estate
*value with spouse
gen eihool1 = EiHool1 if inrange(EiHool1,1,1000000)
gen eihoou1 = EiHoou1 if inrange(EiHoou1,1,1000000)

gen otherreao = .
replace otherreao = 0 if EiPrp==2 | EiAsCk==2 | inrange(EiRRel,3,22) | SurvSp==2
replace otherreao = 1 if EiPrp==1 & (inlist(EiRRel,1,2) | SurvSp==1)

gen otherrea = 125000 if DVEiHoa2==1 //1-250,000

*value with no spouse
*no EioHa2, EioHol2, EioHou2 in dataset
gen eiohol2 = .
gen eiohou2 = .

gen otherrebo = .
replace otherrebo = 0 if EiPrp==2 | EiAsCk==2 | inlist(EiRRel,1,2) | SurvSp==1
replace otherrebo = 1 if EiPrp==1 & inrange(EiRRel,3,22) & SurvSp==2

gen otherreb = .

*mortgage with spouse
*EiHoMga2 has 1 dk value, rest n/a
gen eihobol1 = EiHobol1 if inrange(EiHobol1,1,1000000)
gen eihobou1 = EiHobou1 if inrange(EiHobou1,1,1000000)

gen othermoao = .
replace othermoao = 0 if EiPrp==2 | EiHoMg2==2 | EiHoMgI2==1 | EiAsCk==2 | inrange(EiRRel,3,22) | SurvSp==2
replace othermoao = 1 if EiPrp==1 & EiHoMg2==1 & inlist(EiHoMgI2,2,3) & (inlist(EiRRel,1,2) | SurvSp==1)

gen othermoa = .

*mortgage with no spouse
*EioHMga2 all n/a, no EioHbol2, EioHbou2
gen eiohbol2 = .
gen eiohbou2 = .

gen othermobo = .
replace othermobo = 0 if EiPrp==2 | EioHMg2==2 | EioHMgI2==1 | EiAsCk==2 | inlist(EiRRel,1,2) | SurvSp==1
replace othermobo = 1 if EiPrp==1 & EioHMg2==1 & inlist(EioHMgI2,2,3) & inrange(EiRRel,3,22) & SurvSp==2

gen othermob = .


***net value business***
*wave 3 respondent net value business
*3 bracket values - EIphl eiphu
gen eiphl = EIphl if inrange(EIphl,1,100000)
gen eiphu = Eiphu if inrange(Eiphu,1,100000)

gen buso = .
replace buso = 0 if EIphy==2 | EiAsCk==2
replace buso = 1 if EIphy==1

gen bus = EIphya if inrange(EIphya,0,500000)


***net value of non-housing financial wealth***
*wave 3 respondent net value non-housing financial wealth
*other - EiAmProb is empty but need to include if populated later
*anyone inherited rest of assets
gen anyone = . 
missing_w3 EiAsCk EiOthAs1 EiOthAs2 EiOthAs3 EiOthAs4 EiOthAs5 EiOthAs6 EiOthAs7 EiOthAs8 EiOthAs9 if inw`wv'xt==1, result(anyone)
replace anyone = .t if EiAsCk==2 & EiOthAs1==-1
replace anyone = 0 if EiOthAs1==0 & EiOthAs2==0 & EiOthAs3==0 & EiOthAs4==0 & EiOthAs5==0 & ///
											EiOthAs6==0 & EiOthAs7==0 & EiOthAs8==0 & EiOthAs9==0
replace anyone = 1 if EiOthAs1==1 | EiOthAs2==1 | EiOthAs3==1 | EiOthAs4==1 | EiOthAs5==1 | ///
											EiOthAs6==1 | EiOthAs7==1 | EiOthAs8==1 | EiOthAs9==1

*amount proxy inherited
gen prmin = .
gen prmax = .

gen pro = .
replace pro = 0 if EiOthAs1==0 | EiAsCk==2
replace pro = 1 if EiOthAs1==1

gen prv = EiOthres if inrange(EiOthres,0,500000)

*amount spouse inherited if not proxy
gen spmin = .
gen spmax = .

gen spo = .
replace spo = 0 if inlist(EiRRel,1,2) | SurvSp==2 | EiOthAs2==0 | (EiOthAs1==0 & EiRRel==1) | EiAsCk==2
replace spo = 1 if EiOthAs2==1

gen spv = EiOthSps if inrange(EiOthSps,0,100000)

*amount partner inherited if not proxy (1 value and 1 dk)
gen ptmin = .
gen ptmax = .

gen pto = .
replace pto = 0 if inlist(EiRRel,1,2) | SurvSp==2 | EiOthAs3==0 | (EiOthAs1==0 & EiRRel==2) | EiAsCk==2
replace pto = 1 if EiOthAs3==1

gen ptv = EiOthPrt if inrange(EiOthPrt,0,100000)

*amount non-proxy/spouse/partner inherited
forvalues x = 1 / 9 {
	gen eiamts`x' = .
	missing_w3 EiAsCk anyone EiAmt0`x' if inw`wv'xt==1, result(eiamts`x')
	replace eiamts`x' = .t if EiAsCk==2
	replace eiamts`x' = 0 if inlist(anyone,0,1)
	replace eiamts`x' = EiAmt0`x' if inrange(EiAmt0`x',0,100000)
}
forvalues z = 10/800 {
	gen eiamt`z' = .
	missing_w3 EiAsCk anyone EiAmt`z' if inw`wv'xt==1, result(eiamt`z')
	replace eiamt`z' = .t if EiAsCk==2
	replace eiamt`z' = 0 if anyone==0 | EiOthAs1==1 | EiOthAs2==1 | EiOthAs3==1
	replace eiamt`z' = EiAmt`z' if inrange(EiAmt`z',0,100000)
}
egen sumamt = rowtotal(eiamt*) if inw`wv'xt==1

gen summin = .
gen summax = .

gen sumo = .
replace sumo = 0 if inlist(anyone,0,.t)
replace sumo = 1 if anyone==1


*total value assets if will still needs to go through probate
gen willmin = .
gen willmax = .

gen willo = .
replace willo = 0 if EiWillA==2 | EiProb==2 | EiWillB==1
replace willo = 1 if EiWillA==1 & EiProb==1 & EiWillB==2

gen willamt = EiWillPr if inrange(EiWillPr,0,1000000)

drop anyone eiamt*


***lump sum pension benefits***
*wave 3 respondent lump sum pension benefits

**pension 1
*expected lump sum
	*no values for amount, min/max for pension 1, 2, 3
*lump sum
	*2 dk min/max for pension 1, 1 min/max pension 2, 1 min/max pension 3
*replace penll1 = .
*replace penlu1 = .

replace penlo1 = 0 if EiPenM==2 | (EiPenM==1 & inrange(EiPenN,1,3) & (EiPen2==0 | EiPen4==0))
replace penlo1 = 1 if EiPenM==1 & inrange(EiPenN,1,3) & (EiPen2==1 | EiPen4==1)

*replace penl1 = .

**pension 2 
replace penll2 = EiPerll2 if inrange(EiPerll2,0,50000)
replace penlu2 = EiPerlu2 if inrange(EiPerlu2,0,50000)

replace penlo2 = 0 if EiPenM==2 | (EiPenM==1 & EiPenN==1) | (EiPenM==1 & inlist(EiPenN,2,3) & (EiPen7==0 | EiPen9==0))
replace penlo2 = 1 if EiPenM==1 & inlist(EiPenN,2,3) & (EiPen7==1 | EiPen9==1)

*replace penl2 = .

**pension 3 
replace penll3 = EiPerll3 if inrange(EiPerll3,0,50000)
replace penlu3 = EiPerlu3 if inrange(EiPerlu3,0,50000)

replace penlo3 = 0 if EiPenM==2 | (EiPenM==1 & inlist(EiPenN,1,2)) | (EiPenM==1 & EiPenN==3 & (EiPen12==0 | EiPen14==0))
replace penlo3 = 1 if EiPenM==1 & EiPenN==3 & (EiPen12==1 | EiPen14==1)

*replace penl3 = .


***regular payment pension benefits***
*wave 3 respondent regular payment pension benefits

**pension 1
*expected payments
	*2 values amount & 2 dk, 2 values min/max pension 1
	*no values pension 2 and 3
*reg payment
	*no biweekly min/max for pension 1,2,3
	*1 dk min w value max for monthly pension 1, 1 min/max for pension 2, none for pension 3 
	*no other min/max for pension 1,2,3
replace penpl1 = EiPexpl1*12 if inrange(EiPexpl1,0,500) //monthly
replace penpl1 = EiPerml1*12 if inrange(EiPerml1,0,500) //monthly
replace penpu1 = EiPexpu1*12 if inrange(EiPexpu1,0,500) //monthly
replace penpu1 = EiPermu1*12 if inrange(EiPermu1,0,500) //monthly

replace penpo1 = 0 if EiPenM==2 | (EiPenM==1 & inrange(EiPenN,1,3) & (EiPen1==0 | EiPen3==0))
replace penpo1 = 1 if EiPenM==1 & inrange(EiPenN,1,3) & (EiPen1==1 | EiPen3==1)

replace penp1 = EiPenxpa*12 if inrange(EiPenxpa,1,350)

**pension 2 
replace penpl2 = EiPerml2*12 if inrange(EiPerml2,0,500) //monthly
replace penpu2 = EiPermu2*12 if inrange(EiPermu2,0,500) //monthly

replace penpo2 = 0 if EiPenM==2 | (EiPenM==1 & EiPenN==1) | (EiPenM==1 & inlist(EiPenN,2,3) & (EiPen6==0 | EiPen8==0))
replace penpo2 = 1 if EiPenM==1 & inlist(EiPenN,2,3) & (EiPen6==1 | EiPen8==1)

*replace penp2 = .

**pension 3 - no values
*replace penpl3 = .
*replace penpu3 = .

replace penpo3 = 0 if EiPenM==2 | (EiPenM==1 & inlist(EiPenN,1,2)) | (EiPenM==1 & EiPenN==3 & (EiPen11==0 | EiPen13==0))
replace penpo3 = 1 if EiPenM==1 & EiPenN==3 & (EiPen11==1 | EiPen13==1)

*replace penp3 = .



***drop ELSA wave 3 core file raw variables***
drop `assetxt_w3_exit'



******************************************************************************************


*set wave number
local wv=4
local pre_wv=3

local assetxt_w4_exit EiRRel EiAsCk EiHome EiSp EiSpOwn EiSpLive EiSpInH EiHoLiv EiHoLv EiHoSld EioHSld SurvSp ///
											EiJoint EioIn EioHLiv EioHLv EiWillA EiWillB EiProb ///
											DVEiHoa DVEioHa EiHoMg EioHMg EiHoMgI EioHMgI EiHoMga EiHobl EiHobu EioHbl EioHbu EiPrp DVEiHoa2 ///
											EiHoMg2 EioHMg2 EiHoMgI2 EioHMgI2 EiHoMga2 EioHMga2 EIphy EIphya DVEiOthres DVEiOthSps EiOthPrt EiAmt?? EiAmt??? EiAmProb EiWillPr ///
											EiOthAs? EiHol EiHou EioHl EioHu EiHobol1 EiHobou1 EiHool1 EiHoou1 EIphl Eiphu  ///
											EiPenM EiPenN EiPen1 EiPen2 EiPen3 EiPen4 EiPen5 EiPen6 EiPen7 EiPen8 EiPen9 EiPen10 ///
											EiPen11 EiPen12 EiPen13 EiPen14 EiPen15 EiPenxpa EiPerml1 EiPermu1 EiPerll1 EiPerlu1 
merge 1:1 idauniq using "$w4_xt", keepusing(`assetxt_w4_exit') nogen



replace notdist = 1 if EiAsCk==2

***owned home at death***
*wave 4 respondent owned home at death
missing_w4 EiAsCk EiHome if inw`wv'xt==1, result(raxahown)
replace raxahown = .t if EiAsCk==2 & EiHome==-1
replace raxahown = 0 if EiHome==2
replace raxahown = 1 if EiHome==1

***disposition of home***
*wave 4 respondent disposition of home
missing_w4 EiAsCk EiHome EiSpLive EiHoLiv EiHoLv EioHLiv EioHLv EiHoSld EioHSld /// 
						if inw`wv'xt==1, result(raxhomedis_e)
replace raxhomedis_e = .t if EiAsCk==2 & EiHome==-1
replace raxhomedis_e = .x if EiHome==2
replace raxhomedis_e = 1 if EiSpLive==1
replace raxhomedis_e = 2 if EiHoLiv==1 | EiHoLv==1 | EioHLiv==1 | EioHLv==1
replace raxhomedis_e = 3 if EiHoSld==1 | EioHSld==1
replace raxhomedis_e = 4 if EiHoSld==2 | EioHSld==2
replace raxhomedis_e = 5 if EiHoSld==3 | EioHSld==3
replace raxhomedis_e = 6 if EiHoSld==4 | EioHSld==4
replace raxhomedis_e = 7 if EiHoSld==95 | EioHSld==95


***value home***
*wave 4 respondent value home
*w/ spouse
replace eihol = EiHol if inrange(EiHol,1,1000000)
replace eihou = EiHou if inrange(EiHou,1,1000000)

replace houseao = 0 if EiHome==2 | EiAsCk==2 | inrange(EiRRel,3,22) | SurvSp==2
replace houseao = 1 if EiHome==1 & (inlist(EiRRel,1,2) | SurvSp==1)

replace housea = 70000 if DVEiHoa==1 //1-140,000
replace housea = 170000 if DVEiHoa==2 //140,000.01-200,000
replace housea = 250000 if DVEiHoa==3 //200,000.01-300,000
replace housea = 625000 if DVEiHoa==4 //300,000.01-950,000
replace housea = 1500000 if DVEiHoa==1500000

*no spouse
replace eiohl = EioHl if inrange(EioHl,1,1000000)
replace eiohu = EioHu if inrange(EioHu,1,1000000)

replace housebo = 0 if EiHome==2 | EiAsCk==2 | inlist(EiRRel,1,2) | SurvSp==1
replace housebo = 1 if EiHome==1 & (inrange(EiRRel,3,22) & SurvSp==2)

replace houseb = 40000 if DVEioHa==1 //1-80,000
replace houseb = 115000 if DVEioHa==2 //80,000.01-150,000
replace houseb = 175000 if DVEioHa==3 //150,000.01-200,000
replace houseb = 412500 if DVEioHa==4 //200,000.01-625,000
replace houseb = 1500000 if DVEioHa==1500000


***value mortgage***
*wave 4 respondent value mortgage
*w/ spouse
replace eihobl = EiHobl if inrange(EiHobl,1,1000000)
replace eihobu = EiHobu if inrange(EiHobu,1,1000000)

replace mortao = 0 if EiHome==2 | EiAsCk==2 | inrange(EiRRel,3,22) | SurvSp==2 | EiHoMg==2 | EiHoMgI==1 
replace mortao = 1 if EiHome==1 & (inlist(EiRRel,1,2) | SurvSp==1) & EiHoMg==1 & inlist(EiHoMgI,2,3)

replace morta = EiHoMga if inrange(EiHoMga,1,500000)

*no spouse - no existing EioHMga, EioHbl and EioHbu are unpopulated
replace eiohbl = EioHbl if inrange(EioHbl,1,1000000)
replace eiohbu = EioHbu if inrange(EioHbu,1,1000000)

replace mortbo = 0 if EiHome==2 | EiAsCk==2 | inrange(EiRRel,1,2) | SurvSp==1 | EioHMg==2 | EioHMgI==1
replace mortbo = 1 if EiHome==1 & (inrange(EiRRel,3,22) & SurvSp==2) & EioHMg==1 & inlist(EioHMgI,2,3)

*not replacing mortb b/c no values


***net value home***
*wave 4 respondent net value home


***net value other real estate***
*wave 4 respondent net value other real estate
*value with spouse
replace eihool1 = EiHool1 if inrange(EiHool1,1,1000000)
replace eihoou1 = EiHoou1 if inrange(EiHoou1,1,1000000)

replace otherreao = 0 if EiPrp==2 | EiAsCk==2 | inrange(EiRRel,3,22) | SurvSp==2
replace otherreao = 1 if EiPrp==1 & (inlist(EiRRel,1,2) | SurvSp==1)

replace otherrea = 125000 if DVEiHoa2==1 //1-250,000
replace otherrea = 500000 if DVEiHoa2==500000

*value with no spouse
*no EioHa2, EioHol2, EioHou2 in dataset - so not replacing eiohol2, eiohou2, otherreb
replace otherrebo = 0 if EiPrp==2 | EiAsCk==2 | inlist(EiRRel,1,2) | SurvSp==1
replace otherrebo = 1 if EiPrp==1 & inrange(EiRRel,3,22) & SurvSp==2

*mortgage with spouse
*EiHoMga2 has 2 values, EiHobol1 and EiHobou1 are unpopulated
replace eihobol1 = EiHobol1 if inrange(EiHobol1,1,1000000)
replace eihobou1 = EiHobou1 if inrange(EiHobou1,1,1000000)

replace othermoao = 0 if EiPrp==2 | EiHoMg2==2 | EiHoMgI2==1 | EiAsCk==2 | inrange(EiRRel,3,22) | SurvSp==2
replace othermoao = 1 if EiPrp==1 & EiHoMg2==1 & inlist(EiHoMgI2,2,3) & (inlist(EiRRel,1,2) | SurvSp==1)

replace othermoa = EiHoMga2 if inrange(EiHoMga2,1,200000)

*mortgage with no spouse
*no eiohbol2, eiohbou2 in dataset - so not replacing 
*EioHMga2 has 1 value
replace othermobo = 0 if EiPrp==2 | EioHMg2==2 | EioHMgI2==1 | EiAsCk==2 | inrange(EiRRel,1,2) | SurvSp==1
replace othermobo = 1 if EiPrp==1 & EioHMg2==1 & inlist(EioHMgI2,2,3) & (inrange(EiRRel,3,22) & SurvSp==2)

replace othermob = EioHMga2 if inrange(EioHMga2,1,200000)


***net value business***
*wave 4 respondent net value business
replace eiphl = EIphl if inrange(EIphl,1,1000000)
replace eiphu = Eiphu if inrange(Eiphu,1,1000000)

replace buso = 0 if EIphy==2 | EiAsCk==2
replace buso = 1 if EIphy==1

replace bus = EIphya if inrange(EIphya,0,1500000)
*two 0 values, one 2 value, one 12500000 value, 2 dk
 

***net value of non-housing financial wealth***
*wave 4 respondent net value non-housing financial wealth
*other - EiAmProb is empty but need to include if populated later
*anyone inherited rest of assets
gen anyone = . 
missing_w3 EiAsCk EiOthAs1 EiOthAs2 EiOthAs3 EiOthAs4 EiOthAs5 EiOthAs6 EiOthAs7 EiOthAs8 EiOthAs9 if inw`wv'xt==1, result(anyone)
replace anyone = .t if EiAsCk==2 & EiOthAs1==-1
replace anyone = 0 if EiOthAs1==0 & EiOthAs2==0 & EiOthAs3==0 & EiOthAs4==0 & EiOthAs5==0 & ///
											EiOthAs6==0 & EiOthAs7==0 & EiOthAs8==0 & EiOthAs9==0
replace anyone = 1 if EiOthAs1==1 | EiOthAs2==1 | EiOthAs3==1 | EiOthAs4==1 | EiOthAs5==1 | ///
											EiOthAs6==1 | EiOthAs7==1 | EiOthAs8==1 | EiOthAs9==1

*amount proxy inherited
replace pro = 0 if EiOthAs1==0 | EiAsCk==2
replace pro = 1 if EiOthAs1==1

replace prv = 0 if DVEiOthres==0
replace prv = 3000 if DVEiOthres==1 //1-6,000
replace prv = 11000 if DVEiOthres==2 //6,000.01-16,000
replace prv = 35500 if DVEiOthres==3 //16,000.01-55,000
replace prv = 62500 if DVEiOthres==4 //55,000.01-70,000

*amount spouse inherited if not proxy
replace spo = 0 if inlist(EiRRel,1,2) | SurvSp==2 | EiOthAs2==0 | (EiOthAs1==0 & EiRRel==1) | EiAsCk==2
replace spo = 1 if EiOthAs2==1

replace spv = 0 if DVEiOthSps==0
replace spv = 1500 if DVEiOthSps==1 //1-3,000
replace spv = 14000 if DVEiOthSps==2 //3,000.01-25,000

*amount partner inherited if not proxy (no values, 1 dk)
replace pto = 0 if inlist(EiRRel,1,2) | SurvSp==2 | EiOthAs3==0 | (EiOthAs1==0 & EiRRel==2) | EiAsCk==2
replace pto = 1 if EiOthAs3==1

replace ptv = EiOthPrt if inrange(EiOthPrt,0,100000)

*amount non-proxy/spouse/partner inherited
forvalues x = 1 / 9 {
	gen eiamts`x' = .
	missing_w3 EiAsCk anyone EiAmt0`x' if inw`wv'xt==1, result(eiamts`x')
	replace eiamts`x' = .t if EiAsCk==2
	replace eiamts`x' = 0 if inlist(anyone,0,1)
	replace eiamts`x' = EiAmt0`x' if inrange(EiAmt0`x',0,100000)
}
forvalues z = 10/800 {
	gen eiamt`z' = .
	missing_w3 EiAsCk anyone EiAmt`z' if inw`wv'xt==1, result(eiamt`z')
	replace eiamt`z' = .t if EiAsCk==2
	replace eiamt`z' = 0 if anyone==0 | EiOthAs1==1 | EiOthAs2==1 | EiOthAs3==1
	replace eiamt`z' = EiAmt`z' if inrange(EiAmt`z',0,100000)
}
egen sumamt2 = rowtotal(eiamt*) if inw`wv'xt==1
replace sumamt = sumamt2

replace sumo = 0 if inlist(anyone,0,.t)
replace sumo = 1 if anyone==1

*total value assets if will still needs to go through probate
replace willo = 0 if EiWillA==2 | EiProb==2 | EiWillB==1
replace willo = 1 if EiWillA==1 & EiProb==1 & EiWillB==2

replace willamt = EiWillPr if inrange(EiWillPr,0,1000000)

drop anyone sumamt2 eiamt* 

	
***lump sum pension benefits***
*wave 4 respondent lump sum pension benefits

**pension 1
*expected lump sum
	*no values/min/max for pension 1,2,3
*lump sum
	*3 min/max incl dk for pension 1
	*no min/max for pension 2,3
replace penll1 = EiPerll1 if inrange(EiPerll1,0,110000)
replace penlu1 = EiPerlu1 if inrange(EiPerlu1,0,50000)

replace penlo1 = 0 if EiPenM==2 | (EiPenM==1 & inrange(EiPenN,1,3) & (EiPen2==0 | EiPen4==0))
replace penlo1 = 1 if EiPenM==1 & inrange(EiPenN,1,3) & (EiPen2==1 | EiPen4==1)

*replace penl1 = .

**pension 2 - no values
*replace penll2 = .
*replace penlu2 = .

replace penlo2 = 0 if EiPenM==2 | (EiPenM==1 & EiPenN==1) | (EiPenM==1 & inlist(EiPenN,2,3) & (EiPen7==0 | EiPen9==0))
replace penlo2 = 1 if EiPenM==1 & inlist(EiPenN,2,3) & (EiPen7==1 | EiPen9==1)

*replace penl2 = .

**pension 3 - no values
*replace penll3 = .
*replace penlu3 = .

replace penlo3 = 0 if EiPenM==2 | (EiPenM==1 & inlist(EiPenN,1,2)) | (EiPenM==1 & EiPenN==3 & (EiPen12==0 | EiPen14==0))
replace penlo3 = 1 if EiPenM==1 & EiPenN==3 & (EiPen12==1 | EiPen14==1)

*replace penl3 = .


***regular payment pension benefits***
*wave 4 respondent regular payment pension benefits

**pension 1
*expected payment
	*1 value & 1 dk amt, 1 dk min/max for pension 1
	*no values pension 2 and 3
*regular payment
	*no min/max for weekly pension 1,2,3
	*6 min/max incl dk for monthly pension 1
	*no min/max monthly pension 2,3
	*no min/max for other pension 1,2,3
replace penpl1 = EiPerml1*12 if inrange(EiPerml1,0,500) //monthly
replace penpu1 = EiPermu1*12 if inrange(EiPermu1,0,500) //monthly

replace penpo1 = 0 if EiPenM==2 | (EiPenM==1 & inrange(EiPenN,1,3) & (EiPen1==0 | EiPen3==0))
replace penpo1 = 1 if EiPenM==1 & inrange(EiPenN,1,3) & (EiPen1==1 | EiPen3==1)

replace penp1 = EiPenxpa*12 if inrange(EiPenxpa,1,400)

**pension 2 - no values
*replace penpl2 = .
*replace penpu2 = .

replace penpo2 = 0 if EiPenM==2 | (EiPenM==1 & EiPenN==1) | (EiPenM==1 & inlist(EiPenN,2,3) & (EiPen6==0 | EiPen8==0))
replace penpo2 = 1 if EiPenM==1 & inlist(EiPenN,2,3) & (EiPen6==1 | EiPen8==1)

*replace penp2 = .

**pension 3 - no values
*replace penpl3 = .
*replace penpu3 = .

replace penpo3 = 0 if EiPenM==2 | (EiPenM==1 & inlist(EiPenN,1,2)) | (EiPenM==1 & EiPenN==3 & (EiPen11==0 | EiPen13==0))
replace penpo3 = 1 if EiPenM==1 & EiPenN==3 & (EiPen11==1 | EiPen13==1)

*replace penp3 = .



***drop ELSA wave 4 core file raw variables***
drop `assetxt_w4_exit'



******************************************************************************************


*set wave number
local wv=6
local pre_wv=5

local assetxt_w6_exit EiRRel EiAsCk EiBen EiHome EiSp EiSpOwn EiSpLive EiSpInH EiHoLiv EiHoLv EiHoSld EioHSld SurvSp ///
											EiJoint EioIn EioHLiv EioHLv EiWillA EiWillB EiProb ///
											DVEiHoa DVEioHa EiHoMg EioHMg EiHoMgI EioHMgI EiHoMga EiHobl EiHobu EioHMga EioHbl EioHbu EiPrp DVEiHoa2 ///
											EiHoMg2 EioHMg2 EiHoMgI2 EioHMgI2 EIphy EIphya DVEiOthres DVEiOthSps EiOthPrt EiAmt?? EiAmt??? ///
											EiOthAs? EiHol EiHou EioHl EioHu EiHobol1 EiHobou1 EiHool1 EiHoou1 EIphl Eiphu EiHoMga2 ///
											EiPenM EiPenN EiPen1 EiPen2 EiPen3 EiPen4 EiPen5 EiPen6 EiPen7 EiPen8 EiPen9 EiPen10 ///
											EiPen11 EiPen12 EiPen13 EiPen14 EiPen15 EiPerll1 EiPerlu1 EiPenxp4 EiPenpA EiPenpA2 EiPenpA3 ///
											EiPenPd EiPenPd2 EiPenPd3 EiPerml1 EiPermu1 
merge 1:1 idauniq using "$wave_6_xt", keepusing(`assetxt_w6_exit') nogen




replace notdist = 1 if EiAsCk==2

***owned home at death***
*wave 6 respondent owned home at death
missing_w6 EiAsCk EiHome if inw`wv'xt==1, result(raxahown)
replace raxahown = .t if EiAsCk==2 & EiHome==-1
replace raxahown = 0 if EiHome==2
replace raxahown = 1 if EiHome==1

***disposition of home***
*wave 6 respondent disposition of home
missing_w6 EiAsCk EiHome EiSpLive EiHoLiv EiHoLv EioHLiv EioHLv EiHoSld EioHSld /// 
						if inw`wv'xt==1, result(raxhomedis_e)
replace raxhomedis_e = .t if EiAsCk==2 & EiHome==-1
replace raxhomedis_e = .x if EiHome==2
replace raxhomedis_e = 1 if EiSpLive==1
replace raxhomedis_e = 2 if EiHoLiv==1 | EiHoLv==1 | EioHLiv==1 | EioHLv==1
replace raxhomedis_e = 3 if EiHoSld==1 | EioHSld==1
replace raxhomedis_e = 4 if EiHoSld==2 | EioHSld==2
replace raxhomedis_e = 5 if EiHoSld==3 | EioHSld==3
replace raxhomedis_e = 6 if EiHoSld==4 | EioHSld==4
replace raxhomedis_e = 7 if EiHoSld==95 | EioHSld==95


***value home***
*wave 6 respondent value home
*w/ spouse
replace eihol = EiHol if inrange(EiHol,1,1000000)
replace eihou = EiHou if inrange(EiHou,1,1000000)

replace houseao = 0 if EiHome==2 | EiAsCk==2 | inrange(EiRRel,3,22) | SurvSp==2
replace houseao = 1 if EiHome==1 & (inlist(EiRRel,1,2) | SurvSp==1)

replace housea = 80000 if DVEiHoa==1 //20,000-140,000
replace housea = 170000 if DVEiHoa==2 //140,000.01-200,000
replace housea = 250000 if DVEiHoa==3 //200,000.01-300,000
replace housea = 625000 if DVEiHoa==4 //300,000.01-950,000

*no spouse
replace eiohl = EioHl if inrange(EioHl,1,1000000)
replace eiohu = EioHu if inrange(EioHu,1,1000000)

replace housebo = 0 if EiHome==2 | EiAsCk==2 | inlist(EiRRel,1,2) | SurvSp==1
replace housebo = 1 if EiHome==1 & (inrange(EiRRel,3,22) & SurvSp==2)

replace houseb = 46500 if DVEioHa==1 //13,000-80,000
replace houseb = 115000 if DVEioHa==2 //80,000.01-150,000
replace houseb = 175000 if DVEioHa==3 //150,000.01-200,000
replace houseb = 412500 if DVEioHa==4 //200,000.01-625,000


***value mortgage***
*wave 6 respondent value mortgage
*w/ spouse
replace eihobl = EiHobl if inrange(EiHobl,1,1000000)
replace eihobu = EiHobu if inrange(EiHobu,1,1000000)

replace mortao = 0 if EiHome==2 | EiAsCk==2 | inrange(EiRRel,3,22) | SurvSp==2 | EiHoMg==2 | EiHoMgI==1 
replace mortao = 1 if EiHome==1 & (inlist(EiRRel,1,2) | SurvSp==1) & EiHoMg==1 & inlist(EiHoMgI,2,3)

replace morta = EiHoMga if inrange(EiHoMga,1,500000)

*no spouse - EioHbl and EioHbu are unpopulated
replace eiohbl = EioHbl if inrange(EioHbl,1,1000000)
replace eiohbu = EioHbu if inrange(EioHbu,1,1000000)

replace mortbo = 0 if EiHome==2 | EiAsCk==2 | inrange(EiRRel,1,2) | SurvSp==1 | EioHMg==2 | EioHMgI==1
replace mortbo = 1 if EiHome==1 & (inrange(EiRRel,3,22) & SurvSp==2) & EioHMg==1 & inlist(EioHMgI,2,3)

replace mortb = EioHMga if inrange(EioHMga,0,100000)


***net value home***
*wave 6 respondent net value home


***net value other real estate***
*wave 6 respondent net value other real estate
*value with spouse
replace eihool1 = EiHool1 if inrange(EiHool1,1,1000000)
replace eihoou1 = EiHoou1 if inrange(EiHoou1,1,1000000)

replace otherreao = 0 if EiPrp==2 | EiAsCk==2 | inrange(EiRRel,3,22) | SurvSp==2
replace otherreao = 1 if EiPrp==1 & (inlist(EiRRel,1,2) | SurvSp==1)

replace otherrea = 174000 if DVEiHoa2==1 //98,000-250,000

*value with no spouse
*EioHa2 and brackets not in dataset - so not replacing eiohol2, eiohou2, otherreb
replace otherrebo = 0 if EiPrp==2 | EiAsCk==2 | inlist(EiRRel,1,2) | SurvSp==1
replace otherrebo = 1 if EiPrp==1 & inrange(EiRRel,3,22) & SurvSp==2

*mortgage with spouse - EiHoMga2 is all n/a
replace eihobol1 = EiHobol1 if inrange(EiHobol1,1,1000000)
replace eihobou1 = EiHobou1 if inrange(EiHobou1,1,1000000)

replace othermoao = 0 if EiPrp==2 | EiHoMg2==2 | EiHoMgI2==1 | EiAsCk==2 | inrange(EiRRel,3,22) | SurvSp==2
replace othermoao = 1 if EiPrp==1 & EiHoMg2==1 & inlist(EiHoMgI2,2,3) & (inlist(EiRRel,1,2) | SurvSp==1)

*mortgage with no spouse
*EioHMga2 all n/a, no EioHbol2, EioHbou2
replace othermobo = 0 if EiPrp==2 | EioHMg2==2 | EioHMgI2==1 | EiAsCk==2 | inlist(EiRRel,1,2) | SurvSp==1
replace othermobo = 1 if EiPrp==1 & EioHMg2==1 & inlist(EioHMgI2,2,3) & inrange(EiRRel,3,22) & SurvSp==2


***net value business***
*wave 6 respondent net value business
replace eiphl = EIphl if inrange(EIphl,1,1000000)
replace eiphu = Eiphu if inrange(Eiphu,1,1000000)

replace buso = 0 if EIphy==2 | EiAsCk==2
replace buso = 1 if EIphy==1

replace bus = EIphya if inrange(EIphya,0,1500000)
*one value, one bracket value, one dk bracket


***net value of non-housing financial wealth***
*wave 6 respondent net value non-housing financial wealth
*other - no EiAmProb
*anyone inherited rest of assets
gen anyone = . 
missing_w3 EiOthAs1 EiOthAs2 EiOthAs3 EiOthAs4 EiOthAs5 EiOthAs6 EiOthAs7 EiOthAs8 EiOthAs9 if inw`wv'xt==1, result(anyone)
replace anyone = .t if (EiAsCk==2 & EiOthAs1==-1) | EiBen==4
replace anyone = 0 if EiOthAs1==0 & EiOthAs2==0 & EiOthAs3==0 & EiOthAs4==0 & EiOthAs5==0 & ///
											EiOthAs6==0 & EiOthAs7==0 & EiOthAs8==0 & EiOthAs9==0
replace anyone = 1 if EiOthAs1==1 | EiOthAs2==1 | EiOthAs3==1 | EiOthAs4==1 | EiOthAs5==1 | ///
											EiOthAs6==1 | EiOthAs7==1 | EiOthAs8==1 | EiOthAs9==1

*amount proxy inherited
replace pro = 0 if EiOthAs1==0 | EiAsCk==2
replace pro = 1 if EiOthAs1==1

replace prv = 0 if DVEiOthres==0
replace prv = 3000 if DVEiOthres==1 //0-6,000
replace prv = 11000 if DVEiOthres==2 //6,000.01-16,000
replace prv = 35500 if DVEiOthres==3 //16,000.01-55,000
replace prv = 62500 if DVEiOthres==4 //55,000.01-70,000

*amount spouse inherited if not proxy
replace spo = 0 if inlist(EiRRel,1,2) | SurvSp==2 | EiOthAs2==0 | (EiOthAs1==0 & EiRRel==1) | EiAsCk==2
replace spo = 1 if EiOthAs2==1

replace spv = 0 if DVEiOthSps==0
replace spv = 1500 if DVEiOthSps==1 //0-3,000
replace spv = 14000 if DVEiOthSps==2 //3,000.01-25,000

*amount partner inherited if not proxy (no values)
replace pto = 0 if inlist(EiRRel,1,2) | SurvSp==2 | EiOthAs3==0 | (EiOthAs1==0 & EiRRel==2) | EiAsCk==2
replace pto = 1 if EiOthAs3==1

replace ptv = EiOthPrt if inrange(EiOthPrt,0,100000)

*amount non-proxy/spouse/partner inherited
forvalues x = 1 / 9 {
	gen eiamts`x' = .
	missing_w3 EiAsCk anyone EiAmt0`x' if inw`wv'xt==1, result(eiamts`x')
	replace eiamts`x' = .t if EiAsCk==2
	replace eiamts`x' = 0 if inlist(anyone,0,1)
	replace eiamts`x' = EiAmt0`x' if inrange(EiAmt0`x',0,100000)
}
forvalues z = 10/800 {
	gen eiamt`z' = .
	missing_w3 EiAsCk anyone EiAmt`z' if inw`wv'xt==1, result(eiamt`z')
	replace eiamt`z' = .t if EiAsCk==2
	replace eiamt`z' = 0 if anyone==0 | EiOthAs1==1 | EiOthAs2==1 | EiOthAs3==1
	replace eiamt`z' = EiAmt`z' if inrange(EiAmt`z',0,100000)
}
egen sumamt2 = rowtotal(eiamt*) if inw`wv'xt==1
replace sumamt = sumamt2

replace sumo = 0 if inlist(anyone,0,.t)
replace sumo = 1 if anyone==1

*no EiWillPr in dataset

drop anyone sumamt2 eiamt* 

	
***lump sum pension benefits***
*wave 6 respondent lump sum pension benefits

**pension 1
*expected lump sum
	*no amt/min/max pension 1 or 3,4
	*1 dk val pension 2 w dk min/max pension 2
*lump sum
	*2 min/max pension 1
	*no min/max pension 2,3,4
replace penll1 = EiPerll1 if inrange(EiPerll1,0,100000)
replace penlu1 = EiPerlu1 if inrange(EiPerlu1,0,100000)

replace penlo1 = 0 if EiPenM==2 | (EiPenM==1 & inrange(EiPenN,1,4) & (EiPen2==0 | EiPen4==0))
replace penlo1 = 1 if EiPenM==1 & inrange(EiPenN,1,4) & (EiPen2==1 | EiPen4==1)

*replace penl1 = .

**pension 2 - no values
*replace penll2 = .
*replace penlu2 = .

replace penlo2 = 0 if EiPenM==2 | (EiPenM==1 & EiPenN==1) | (EiPenM==1 & inrange(EiPenN,2,4) & (EiPen7==0 | EiPen9==0))
replace penlo2 = 1 if EiPenM==1 & inrange(EiPenN,2,4) & (EiPen7==1 | EiPen9==1)

*replace penl2 = .

**pension 3 - no values
*replace penll3 = .
*replace penlu3 = .

replace penlo3 = 0 if EiPenM==2 | (EiPenM==1 & inlist(EiPenN,1,2)) | (EiPenM==1 & inlist(EiPenN,3,4) & (EiPen12==0 | EiPen14==0))
replace penlo3 = 1 if EiPenM==1 & inlist(EiPenN,3,4) & (EiPen12==1 | EiPen14==1)

*replace penl3 = .


***regular payment pension benefits***
*wave 6 respondent regular payment pension benefits

**pension 1
*expected payment
	*no amt var pension 1, no val min/max
	*2 values amt pension 2, no val min/max
	*no amt/min/max pension 3,4
*regular payment
	*amt & period (EiPenpA, EiPenPd, EiPenpA2, EiPenpA3, EiPenPd2, EiPenPd3) - no val 4
	*1 dk min/max weekly pension 1 and 2
	*no min/max weekly pension 3,4
	*11 min/max w dk monthly pension 1
	*no min/max monthly pension 2,3,4
	*no min/max other pension 1,2,3,4
replace penpl1 = EiPerml1*12 if inrange(EiPerml1,0,1000) //monthly
replace penpu1 = EiPermu1*12 if inrange(EiPermu1,0,1000) //monthly

replace penpo1 = 0 if EiPenM==2 | (EiPenM==1 & inrange(EiPenN,1,4) & (EiPen1==0 | EiPen3==0))
replace penpo1 = 1 if EiPenM==1 & inrange(EiPenN,1,4) & (EiPen1==1 | EiPen3==1)

replace penp1 = EiPenpA*52 if inrange(EiPenpA,1,4000) & EiPenPd==1 //1 week
replace penp1 = EiPenpA*13 if inrange(EiPenpA,1,4000) & EiPenPd==4 //4 weeks
replace penp1 = EiPenpA*12 if inrange(EiPenpA,1,4000) & EiPenPd==5 //calendar month

**pension 2 
*replace penpl2 = .
*replace penpu2 = .

replace penpo2 = 0 if EiPenM==2 | (EiPenM==1 & EiPenN==1) | (EiPenM==1 & inrange(EiPenN,2,4) & (EiPen6==0 | EiPen8==0))
replace penpo2 = 1 if EiPenM==1 & inrange(EiPenN,2,4) & (EiPen6==1 | EiPen8==1)

replace penp2 = EiPenpA2*52 if inrange(EiPenpA2,1,2000) & EiPenPd2==1 //1 week
replace penp2 = EiPenpA2*13 if inrange(EiPenpA2,1,2000) & EiPenPd2==4 //4 weeks
replace penp2 = EiPenpA2*12 if inrange(EiPenpA2,1,2000) & EiPenPd2==5 //calendar month
replace penp2 = EiPenpA2    if inrange(EiPenpA2,1,2000) & EiPenPd2==52 //1 year

**pension 3
*replace penpl3 = .
*replace penpu3 = .

replace penpo3 = 0 if EiPenM==2 | (EiPenM==1 & inlist(EiPenN,1,2)) | (EiPenM==1 & inlist(EiPenN,3,4) & (EiPen11==0 | EiPen13==0))
replace penpo3 = 1 if EiPenM==1 & inlist(EiPenN,3,4) & (EiPen11==1 | EiPen13==1)

replace penp3 = EiPenpA3*12 if inrange(EiPenpA3,1,500) & EiPenPd3==5 //calendar month



***drop ELSA wave 6 core file raw variables***
drop `assetxt_w6_exit'



******************************************************************************************




***value home***
*adjust for cpi*
forvalues y = 2002/2012 {
	replace eihol = ((eihol*100)/c`y'cpindex) if raxyear==`y' & inrange(eihol,0,10000000)
	replace eihou = ((eihou*100)/c`y'cpindex) if raxyear==`y' & inrange(eihou,0,10000000)
	replace housea = ((housea*100)/c`y'cpindex) if raxyear==`y' & inrange(housea,0,10000000)
	replace eiohl = ((eiohl*100)/c`y'cpindex) if raxyear==`y' & inrange(eiohl,0,10000000)
	replace eiohu = ((eiohu*100)/c`y'cpindex) if raxyear==`y' & inrange(eiohu,0,10000000)
	replace houseb = ((houseb*100)/c`y'cpindex) if raxyear==`y' & inrange(houseb,0,10000000)
}
*impute missing values*
elsa_eol_impute housea if inxt == 1, min_var(eihol) max_var(eihou) entry_var(houseao)
elsa_eol_impute houseb if inxt == 1, min_var(eiohl) max_var(eiohu) entry_var(housebo)
*assign to variables*
replace raxahous = (housea_i + houseb_i) if !mi(housea_i) & !mi(houseb_i) & inxt==1
replace raxahous = .t if notdist==1
replace raxahous = .q if inw2xt==1
replace raxahous = .m if raxahous==. & inxt==1
combine_imp_flag housea_i_f houseb_i_f, result(raxafhous)
replace raxafhous = -3 if notdist==1
replace raxafhous = .q if inw2xt==1

drop eihol eihou eiohl eiohu
drop houseao housea housea_i housea_i_f housea_i_neighbor 
drop housebo houseb houseb_i houseb_i_f houseb_i_neighbor


***value mortgage***
*adjust for cpi*
forvalues y = 2002/2012 {
	replace eihobl = ((eihobl*100)/c`y'cpindex) if raxyear==`y' & inrange(eihobl,0,10000000)
	replace eihobu = ((eihobu*100)/c`y'cpindex) if raxyear==`y' & inrange(eihobu,0,10000000)
	replace morta = ((morta*100)/c`y'cpindex) if raxyear==`y' & inrange(morta,0,10000000)
	replace eiohbl = ((eiohbl*100)/c`y'cpindex) if raxyear==`y' & inrange(eiohbl,0,10000000)
	replace eiohbu = ((eiohbu*100)/c`y'cpindex) if raxyear==`y' & inrange(eiohbu,0,10000000)
	replace mortb = ((mortb*100)/c`y'cpindex) if raxyear==`y' & inrange(mortb,0,10000000)
}
*impute missing values*
elsa_eol_impute morta if inxt == 1, min_var(eihobl) max_var(eihobu) entry_var(mortao)
elsa_eol_impute mortb if inxt == 1, min_var(eiohbl) max_var(eiohbu) entry_var(mortbo)
*assign to variables
replace raxamort = (morta_i + mortb_i) if !mi(morta_i) & !mi(mortb_i) & inxt==1
replace raxamort = .t if notdist==1
replace raxamort = .q if inw2xt==1
replace raxamort = .m if raxamort==. & inxt==1
combine_imp_flag morta_i_f mortb_i_f, result(raxafmort)
replace raxafmort = -3 if notdist==1
replace raxafmort = .q if inw2xt==1

drop eihobl eihobu eiohbl eiohbu 
drop mortao morta morta_i morta_i_f morta_i_neighbor
drop mortbo mortb mortb_i mortb_i_f mortb_i_neighbor


***net value home***
*assign to variables*
replace raxatoth = (raxahous - raxamort) if !mi(raxahous) & !mi(raxamort) & inxt==1
replace raxatoth = .t if notdist==1
replace raxatoth = .q if inw2xt==1
replace raxatoth = .m if raxatoth==. & inxt==1
combine_imp_flag raxafhous raxafmort, result(raxaftoth)
replace raxaftoth = -3 if notdist==1
replace raxaftoth = .q if inw2xt==1


***net value other real estate***
*adjust for cpi*
forvalues y = 2002/2012 {
	replace eihool1 = ((eihool1*100)/c`y'cpindex) if raxyear==`y' & inrange(eihool1,0,10000000)
	replace eihoou1 = ((eihoou1*100)/c`y'cpindex) if raxyear==`y' & inrange(eihoou1,0,10000000)
	replace otherrea = ((otherrea*100)/c`y'cpindex) if raxyear==`y' & inrange(otherrea,0,10000000)
	replace eiohol2 = ((eiohol2*100)/c`y'cpindex) if raxyear==`y' & inrange(eiohol2,0,10000000)
	replace eiohou2 = ((eiohou2*100)/c`y'cpindex) if raxyear==`y' & inrange(eiohou2,0,10000000)
	replace otherreb = ((otherreb*100)/c`y'cpindex) if raxyear==`y' & inrange(otherreb,0,10000000)
	replace eihobol1 = ((eihobol1*100)/c`y'cpindex) if raxyear==`y' & inrange(eihobol1,0,10000000)
	replace eihobou1 = ((eihobou1*100)/c`y'cpindex) if raxyear==`y' & inrange(eihobou1,0,10000000)
	replace othermoa = ((othermoa*100)/c`y'cpindex) if raxyear==`y' & inrange(othermoa,0,10000000)
	replace eiohbol2 = ((eiohbol2*100)/c`y'cpindex) if raxyear==`y' & inrange(eiohbol2,0,10000000)
	replace eiohbou2 = ((eiohbou2*100)/c`y'cpindex) if raxyear==`y' & inrange(eiohbou2,0,10000000)
	replace othermob = ((othermob*100)/c`y'cpindex) if raxyear==`y' & inrange(othermob,0,10000000)
}
*impute missing values*
elsa_eol_impute otherrea if inxt == 1, min_var(eihool1) max_var(eihoou1) entry_var(otherreao)
elsa_eol_impute otherreb if inxt == 1, min_var(eiohol2) max_var(eiohou2) entry_var(otherrebo)
elsa_eol_impute othermoa if inxt == 1, min_var(eihobol1) max_var(eihobou1) entry_var(othermoao)
elsa_eol_impute othermob if inxt == 1, min_var(eiohbol2) max_var(eiohbou2) entry_var(othermobo)
gen otherre_i = (otherrea_i + otherreb_i) if !mi(otherrea_i) & !mi(otherreb_i) & inxt==1
gen othermo_i = (othermoa_i + othermob_i) if !mi(othermoa_i) & !mi(othermob_i) & inxt==1
*assign to variables*
replace raxarles = (otherre_i - othermo_i) if !mi(otherre_i) & !mi(othermo_i) & inxt==1
replace raxarles = .t if notdist==1
replace raxarles = .q if inw2xt==1
replace raxarles = .m if raxarles==. & inxt==1
combine_imp_flag otherrea_i_f otherreb_i_f othermoa_i_f othermob_i_f, result(raxafrles)
replace raxafrles = -3 if notdist==1
replace raxafrles = .q if inw2xt==1

drop eihool1 eihoou1 eiohol2 eiohou2 eihobol1 eihobou1 eiohbol2 eiohbou2 
drop otherreao otherrea otherrea_i otherrea_i_f otherrea_i_neighbor
drop otherrebo otherreb otherreb_i otherreb_i_f otherreb_i_neighbor
drop othermoao othermoa othermoa_i othermoa_i_f othermoa_i_neighbor
drop othermobo othermob othermob_i othermob_i_f othermob_i_neighbor
drop otherre_i othermo_i


***net value business***
*adjust for cpi*
forvalues y = 2002/2012 {
	replace eiphl = ((eiphl*100)/c`y'cpindex) if raxyear==`y' & inrange(eiphl,0,10000000)
	replace eiphu = ((eiphu*100)/c`y'cpindex) if raxyear==`y' & inrange(eiphu,0,10000000)
	replace bus = ((bus*100)/c`y'cpindex) if raxyear==`y' & inrange(bus,0,10000000)
}
*impute missing values*
elsa_eol_impute bus if inxt == 1, min_var(eiphl) max_var(eiphu) entry_var(buso)
*assign to variables*
replace raxabsns = bus_i if !mi(bus_i) & inxt==1
replace raxabsns = .t if notdist==1
replace raxabsns = .q if inw2xt==1
replace raxabsns = .m if raxabsns==. & inxt==1
replace raxafbsns = bus_i_f if !mi(bus_i_f) & inxt==1
replace raxafbsns = -3 if notdist==1
replace raxafbsns = .q if inw2xt==1

drop eiphl eiphu 
drop buso bus bus_i bus_i_f bus_i_neighbor


***net value non-housing financial wealth***
*adjust for cpi*
forvalues y = 2002/2012 {
	replace prmin = ((prmin*100)/c`y'cpindex) if raxyear==`y' & inrange(prmin,0,10000000)
	replace prmax = ((prmax*100)/c`y'cpindex) if raxyear==`y' & inrange(prmax,0,10000000)
	replace prv = ((prv*100)/c`y'cpindex) if raxyear==`y' & inrange(prv,0,10000000)
	replace spmin = ((spmin*100)/c`y'cpindex) if raxyear==`y' & inrange(spmin,0,10000000)
	replace spmax = ((spmax*100)/c`y'cpindex) if raxyear==`y' & inrange(spmax,0,10000000)
	replace spv = ((spv*100)/c`y'cpindex) if raxyear==`y' & inrange(spv,0,10000000)
	replace ptmin = ((ptmin*100)/c`y'cpindex) if raxyear==`y' & inrange(ptmin,0,10000000)
	replace ptmax = ((ptmax*100)/c`y'cpindex) if raxyear==`y' & inrange(ptmax,0,10000000)
	replace ptv = ((ptv*100)/c`y'cpindex) if raxyear==`y' & inrange(ptv,0,10000000)
	replace summin = ((summin*100)/c`y'cpindex) if raxyear==`y' & inrange(summin,0,10000000)
	replace summax = ((summax*100)/c`y'cpindex) if raxyear==`y' & inrange(summax,0,10000000)
	replace sumamt = ((sumamt*100)/c`y'cpindex) if raxyear==`y' & inrange(sumamt,0,10000000)
	replace willmin = ((willmin*100)/c`y'cpindex) if raxyear==`y' & inrange(willmin,0,10000000)
	replace willmax = ((willmax*100)/c`y'cpindex) if raxyear==`y' & inrange(willmax,0,10000000)
	replace willamt = ((willamt*100)/c`y'cpindex) if raxyear==`y' & inrange(willamt,0,1000000)
}
*impute missing values*
elsa_eol_impute prv if inxt == 1, min_var(prmin) max_var(prmax) entry_var(pro)
elsa_eol_impute spv if inxt == 1, min_var(spmin) max_var(spmax) entry_var(spo)
elsa_eol_impute ptv if inxt == 1,  min_var(ptmin) max_var(ptmax) entry_var(pto)
elsa_eol_impute sumamt if inxt == 1, min_var(summin) max_var(summax) entry_var(sumo)
elsa_eol_impute willamt if inxt == 1, min_var(willmin) max_var(willmax) entry_var(willo)
*assign to variables*
replace raxatotf_e = (prv_i + spv_i + ptv_i + sumamt_i) if !mi(prv_i) & !mi(spv_i) & !mi(ptv_i) & !mi(sumamt_i) & inxt==1
replace raxatotf_e = .t if notdist==1
replace raxatotf_e = .q if inw2xt==1
replace raxatotf_e = .m if raxatotf==. & inxt==1
combine_imp_flag prv_i_f spv_i_f ptv_i_f sumamt_i_f, result(raxaftotf_e)
replace raxaftotf_e = -3 if notdist==1
replace raxaftotf_e = .q if inw2xt==1

drop prmin prmax spmin spmax ptmin ptmax summin summax 
drop pro prv prv_i prv_i_f prv_i_neighbor
drop spo spv spv_i spv_i_f spv_i_neighbor
drop pto ptv ptv_i ptv_i_f ptv_i_neighbor
drop sumo sumamt sumamt_i sumamt_i_f sumamt_i_neighbor

***total assets***
replace raxatotb = (raxatoth + raxarles + raxabsns + raxatotf) if !mi(raxatoth) & !mi(raxarles) & !mi(raxabsns) & !mi(raxatotf) & inxt==1
replace raxatotb = .t if notdist==1
replace raxatotb = .q if inw2xt==1
replace raxatotb = willamt_i if inrange(willamt_i,1,1000000) & inlist(raxatotb,0,.)
replace raxatotb = .m if raxatotb==. & inxt==1
combine_imp_flag raxaftoth raxafbsns raxaftotf, result(raxaftotb) 
replace raxaftotb = -3 if notdist==1
replace raxaftotb = willamt_i_f if inrange(willamt_i,1,1000000)
replace raxaftotb = .q if inw2xt==1

***total non-housing assets***
replace raxatotn = (raxabsns + raxatotf) if !mi(raxabsns) & !mi(raxatotf) & inxt==1
replace raxatotn = .t if notdist==1
replace raxatotn = .q if inw2xt==1
replace raxatotn = .m if raxatotn==. & inxt==1
combine_imp_flag raxafbsns raxaftotf, result(raxaftotn)
replace raxaftotn = -3 if notdist==1
replace raxaftotn = .q if inw2xt==1

drop notdist willmin willmax willo willamt willamt_i willamt_i_f willamt_i_neighbor

***lump sum pension benefits***
forvalues y = 2002/2012 {
	replace penll1 = ((penll1*100)/c`y'cpindex) if raxyear==`y' & inrange(penll1,0,110000)
	replace penlu1 = ((penlu1*100)/c`y'cpindex) if raxyear==`y' & inrange(penlu1,0,110000)
	replace penl1 = ((penl1*100)/c`y'cpindex) if raxyear==`y' & inrange(penl1,0,25000)
	replace penll2 = ((penll2*100)/c`y'cpindex) if raxyear==`y' & inrange(penll2,0,110000)
	replace penlu2 = ((penlu2*100)/c`y'cpindex) if raxyear==`y' & inrange(penlu2,0,110000)
	replace penl2 = ((penl2*100)/c`y'cpindex) if raxyear==`y' & inrange(penl2,0,25000)
	replace penll3 = ((penll3*100)/c`y'cpindex) if raxyear==`y' & inrange(penll3,0,110000)
	replace penlu3 = ((penlu3*100)/c`y'cpindex) if raxyear==`y' & inrange(penlu3,0,110000)
	replace penl3 = ((penl3*100)/c`y'cpindex) if raxyear==`y' & inrange(penl3,0,25000)
}
*impute missing values*
elsa_eol_impute penl1 if inxt == 1, min_var(penll1) max_var(penlu1) entry_var(penlo1)
elsa_eol_impute penl2 if inxt == 1, min_var(penll2) max_var(penlu2) entry_var(penlo2)
elsa_eol_impute penl3 if inxt == 1, min_var(penll3) max_var(penlu3) entry_var(penlo3)
*assign to variables*
replace raxapenls = penl1_i + penl2_i + penl3_i if !mi(penl1_i) & !mi(penl2_i) & !mi(penl3_i) & inxt==1
replace raxapenls = .m if raxapenls==. & inxt==1
combine_imp_flag penl1_i_f penl2_i_f penl3_i_f, result(raxafpenls)

drop penll1 penlu1 penll2 penlu2 penll3 penlu3 
drop penlo1 penl1 penl1_i penl1_i_f penl1_i_neighbor ///
		 penlo2 penl2 penl2_i penl2_i_f penl2_i_neighbor ///
		 penlo3 penl3 penl3_i penl3_i_f penl3_i_neighbor 

***regular payment pension benefits***
***lump sum pension benefits***
forvalues y = 2002/2012 {
	replace penpl1 = ((penpl1*100)/c`y'cpindex) if raxyear==`y' & inrange(penpl1,0,110000)
	replace penpu1 = ((penpu1*100)/c`y'cpindex) if raxyear==`y' & inrange(penpu1,0,110000)
	replace penp1 = ((penp1*100)/c`y'cpindex) if raxyear==`y' & inrange(penp1,0,25000)
	replace penpl2 = ((penpl2*100)/c`y'cpindex) if raxyear==`y' & inrange(penpl2,0,110000)
	replace penpu2 = ((penpu2*100)/c`y'cpindex) if raxyear==`y' & inrange(penpu2,0,110000)
	replace penp2 = ((penp2*100)/c`y'cpindex) if raxyear==`y' & inrange(penp2,0,25000)
	replace penpl3 = ((penpl3*100)/c`y'cpindex) if raxyear==`y' & inrange(penpl3,0,110000)
	replace penpu3 = ((penpu3*100)/c`y'cpindex) if raxyear==`y' & inrange(penpu3,0,110000)
	replace penp3 = ((penp3*100)/c`y'cpindex) if raxyear==`y' & inrange(penp3,0,25000)
}
*impute missing values*
elsa_eol_impute penp1 if inxt == 1, min_var(penpl1) max_var(penpu1) entry_var(penpo1)
elsa_eol_impute penp2 if inxt == 1, min_var(penpl2) max_var(penpu2) entry_var(penpo2)
elsa_eol_impute penp3 if inxt == 1, min_var(penpl3) max_var(penpu3) entry_var(penpo3)
*assign to variables*
replace raxapenpy = penp1_i + penp2_i + penp3_i if !mi(penp1_i) & !mi(penp2_i) & !mi(penp3_i) & inxt==1
replace raxapenpy = .m if raxapenpy==. & inxt==1
combine_imp_flag penp1_i_f penp2_i_f penp3_i_f, result(raxafpenpy)

drop penpl1 penpu1 penpl2 penpu2 penpl3 penpu3 
drop penpo1 penp1 penp1_i penp1_i_f penp1_i_neighbor ///
		 penpo2 penp2 penp2_i penp2_i_f penp2_i_neighbor ///
		 penpo3 penp3 penp3_i penp3_i_f penp3_i_neighbor
		 
		 


******************************************************************************************



***yes or no***
label define yesnofam ///
	0 "0.no" ///
	1 "1.yes"  
	



	
	

*set wave number
local wv=2
local pre_wv=1


****merge with wave 2 harmonized elsa data***
local familyxt_w2_helsa r1child
merge 1:1 idauniq using "$h_elsa", keepusing(`familyxt_w2_helsa') nogen


***Number of Children***
*wave 2 respondent
gen raxchild_e = .
missing_w2 r1child if inw`wv'xt==1, result(raxchild_e)
replace raxchild_e = r1child if ralstcore==1 & inw`wv'xt==1
label variable raxchild_e "raxchild_e: r number of living children prev wave"




****drop harmonized elsa variables***
drop `familyxt_w2_helsa'


******************************************************************************************


*set wave number
local wv=3
local pre_wv=2


****merge with wave 3 harmonized elsa data***
local familyxt_w3_helsa r1child r2child 
merge 1:1 idauniq using "$h_elsa", keepusing(`familyxt_w3_helsa') nogen


***Number of Children***
*wave 3 respondent
forvalues w = 1/2 {
	missing_w3 r`w'child if ralstcore==`w' & inw`wv'xt==1, result(raxchild_e)
	replace raxchild_e = r`w'child if ralstcore==`w' & inw`wv'xt==1
}




****drop harmonized elsa variables***
drop `familyxt_w3_helsa'


******************************************************************************************


*set wave number
local wv=4
local pre_wv=3


****merge with wave 4 harmonized elsa data***
local familyxt_w4_helsa r1child r2child r3child  
merge 1:1 idauniq using "$h_elsa", keepusing(`familyxt_w4_helsa') nogen


***Number of Children***
*wave 4 respondent
forvalues w = 1/3 {
	missing_w4 r`w'child if ralstcore==`w' & inw`wv'xt==1, result(raxchild_e)
	replace raxchild_e = r`w'child if ralstcore==`w' & inw`wv'xt==1
}




****drop harmonized elsa variables***
drop `familyxt_w4_helsa'


******************************************************************************************


*set wave number
local wv=6
local pre_wv=5


****merge with wave 6 harmonized elsa data***
local familyxt_w6_helsa r1child r2child r3child r4child r5child
merge 1:1 idauniq using "$h_elsa", keepusing(`familyxt_w6_helsa') nogen


***Number of Children***
*wave 6 respondent
forvalues w = 1/5 {
	missing_w6 r`w'child if ralstcore==`w' & inw`wv'xt==1, result(raxchild_e)
	replace raxchild_e = r`w'child if ralstcore==`w' & inw`wv'xt==1
}




****drop harmonized elsa variables***
drop `familyxt_w6_helsa'


******************************************************************************************




label define yesnowork ///
	0 "0.no" ///
	1 "1.yes" 
	
label define months ///
	1 "1.january" ///
	2 "2.february" ///
	3 "3.march" ///
	4 "4.april" ///
	5 "5.may" ///
	6 "6.june" ///
	7 "7.july" ///
	8 "8.august" ///
	9 "9.september" ///
	10 "10.october" ///
	11 "11.november" ///
	12 "12.december" ///
	13 "13.winter (dec to feb)" ///
	14 "14.spring (march to may)" ///
	15 "15.summer (june to aug)" ///
	16 "16.autumn (sept to nov)" ///
	17 "17.winter (end of year)" ///
	.f ".f:doing unpaid work for family" ///
	.h ".h:missing hse value" ///
	.j ".j:entering/training for job" ///
	.n ".n:never worked" ///
	.p ".p:proxy" ///
	.t ".t:temporarily out of work" ///
	.y ".y:ended on or before 1990, month not asked" ///
	.w ".w:currently working" 
	

	
 

*set wave number
local wv=2
local pre_wv=1

***merge with wave 2 exit data***
local employxt_w2_exit EiWorkA EiWhnTM EiWhnTY EiStop EiWhen EiWhenY
merge 1:1 idauniq using "$wave_2_xt", keepusing(`employxt_w2_exit') nogen

***merge with h_elsa vars***
local employxt_w2_helsa r1jlastm r1jlasty
merge 1:1 idauniq using "$h_elsa", keepusing(`employxt_w2_helsa') nogen





***working up until time of death***
*wave 2 respondent working up until time of death
gen raxwork = .
missing_w2 EiWorkA EiStop if inw`wv'xt==1, result(raxwork)
replace raxwork = 0 if inlist(EiWorkA,3,4) | (inlist(EiWorkA,1,2) & EiStop==1)
replace raxwork = 1 if inlist(EiWorkA,1,2) & EiStop==2
replace raxwork = 1 if EiWorkA==3 & EiWhnTY==raxyear & inrange(EiWhnTY,2002,2005) & ///
											 ((inlist(EiWhnTM,12,1,2) & raxseason==1) | (inlist(EiWhnTM,3,4,5) & raxseason==2) | ///
											 (inlist(EiWhnTM,6,7,8) & raxseason==3) | (inlist(EiWhnTM,9,10,11) & raxseason==4))
label variable raxwork "raxwork: r working up until time of death"
label values raxwork yesnowork

***month last worked***
*wave 2 respondent month last worked
gen raxjlastm_e = .
missing_w2 EiWorkA EiStop EiWhen EiWhnTM r1jlastm if inw`wv'xt==1, result(raxjlastm_e)
replace raxjlastm_e = r1jlastm if ralstcore==1 & EiWorkA==4
replace raxjlastm_e = EiWhnTM if inrange(EiWhnTM,1,12) & EiWorkA==3
replace raxjlastm_e = EiWhen if inrange(EiWhen,1,12) & inlist(EiWorkA,1,2) & EiStop==1
replace raxjlastm_e = 13 if raxseason==1 & inlist(EiWorkA,1,2) & EiStop==2
replace raxjlastm_e = 14 if raxseason==2 & inlist(EiWorkA,1,2) & EiStop==2
replace raxjlastm_e = 15 if raxseason==3 & inlist(EiWorkA,1,2) & EiStop==2
replace raxjlastm_e = 16 if raxseason==4 & inlist(EiWorkA,1,2) & EiStop==2
replace raxjlastm_e = .m if raxjlastm_e==.w & inw`wv'xt==1
label variable raxjlastm_e "raxjlastm_e: r month last worked"
label values raxjlastm_e months

***year last worked***
*wave 2 respondent year last worked
gen raxjlasty = .
missing_w2 EiWorkA EiStop EiWhenY EiWhnTY r1jlasty if inw`wv'xt==1, result(raxjlasty)
replace raxjlasty = r1jlasty if ralstcore==1 & EiWorkA==4
replace raxjlasty = EiWhnTY if inrange(EiWhnTY,2002,2005) & EiWorkA==3
replace raxjlasty = EiWhenY if inrange(EiWhenY,2002,2005) & inlist(EiWorkA,1,2) & EiStop==1
replace raxjlasty = raxyear if inrange(raxyear,2002,2005) & inlist(EiWorkA,1,2) & EiStop==2
replace raxjlasty = .m if raxjlasty==.w & inw`wv'xt==1
label variable raxjlasty "raxjlasty: r year last worked"




***drop ELSA wave 2 core file raw variables***
drop `employxt_w2_exit'

***drop H_ELSA variables***
drop `employxt_w2_helsa'



******************************************************************************************


*set wave number
local wv=3
local pre_wv=2

***merge with wave 3 exit data***
local employxt_w3_exit EiWorkA EiWhnTM EiWhnTY EiStop EiWhen EiWhenY 
merge 1:1 idauniq using "$wave_3_xt", keepusing(`employxt_w3_exit') nogen

***merge with h_elsa vars***
local employxt_w3_helsa r1jlastm r2jlastm r1jlasty r2jlasty 
merge 1:1 idauniq using "$h_elsa", keepusing(`employxt_w3_helsa') nogen




***working up until time of death***
*wave 3 respondent working up until time of death
missing_w3 EiWorkA EiStop if inw`wv'xt==1, result(raxwork)
replace raxwork = 0 if inlist(EiWorkA,3,4) | (inlist(EiWorkA,1,2) & EiStop==1)
replace raxwork = 1 if inlist(EiWorkA,1,2) & EiStop==2
replace raxwork = 1 if EiWorkA==3 & EiWhnTY==raxyear & inrange(EiWhnTY,2002,2007) & ///
											 ((inlist(EiWhnTM,12,1,2) & raxseason==1) | (inlist(EiWhnTM,3,4,5) & raxseason==2) | ///
											 (inlist(EiWhnTM,6,7,8) & raxseason==3) | (inlist(EiWhnTM,9,10,11) & raxseason==4))

***month last worked***
*wave 3 respondent month last worked
missing_w3 EiWorkA EiStop EiWhen EiWhnTM r1jlastm if inw`wv'xt==1, result(raxjlastm_e)
forvalues v = 1/2 {
	replace raxjlastm_e = r`v'jlastm if ralstcore==`v' & EiWorkA==4
}
replace raxjlastm_e = EiWhnTM if inrange(EiWhnTM,1,12) & EiWorkA==3
replace raxjlastm_e = EiWhen if inrange(EiWhen,1,12) & inlist(EiWorkA,1,2) & EiStop==1
replace raxjlastm_e = 13 if raxseason==1 & inlist(EiWorkA,1,2) & EiStop==2
replace raxjlastm_e = 14 if raxseason==2 & inlist(EiWorkA,1,2) & EiStop==2
replace raxjlastm_e = 15 if raxseason==3 & inlist(EiWorkA,1,2) & EiStop==2
replace raxjlastm_e = 16 if raxseason==4 & inlist(EiWorkA,1,2) & EiStop==2
replace raxjlastm_e = .m if raxjlastm_e==.w & inw`wv'xt==1

***year last worked***
*wave 3 respondent year last worked
missing_w3 EiWorkA EiStop EiWhenY EiWhnTY r1jlasty if inw`wv'xt==1, result(raxjlasty)
forvalues v = 1/2 {
	replace raxjlasty = r`v'jlasty if ralstcore==`v' & EiWorkA==4
}
replace raxjlasty = EiWhnTY if inrange(EiWhnTY,2002,2007) & EiWorkA==3
replace raxjlasty = EiWhenY if inrange(EiWhenY,1940,2007) & inlist(EiWorkA,1,2) & EiStop==1
replace raxjlasty = raxyear if inrange(raxyear,2002,2007) & inlist(EiWorkA,1,2) & EiStop==2
replace raxjlasty = .m if raxjlasty==.w & inw`wv'xt==1




***drop ELSA wave 3 core file raw variables***
drop `employxt_w3_exit'

***drop H_ELSA variables***
drop `employxt_w3_helsa'


******************************************************************************************


*set wave number
local wv=4
local pre_wv=3

***merge with wave 4 exit data***
local employxt_w4_exit EiWorkA EiWhnTM EiWhnTY EiStop EiWhen EiWhenY
merge 1:1 idauniq using "$w4_xt", keepusing(`employxt_w4_exit') nogen

***merge with h_elsa vars***
local employxt_w4_helsa r1jlastm r2jlastm r3jlastm r1jlasty r2jlasty r3jlasty 
merge 1:1 idauniq using "$h_elsa", keepusing(`employxt_w4_helsa') nogen




***working up until time of death***
*wave 4 respondent working up until time of death
missing_w4 EiWorkA EiStop if inw`wv'xt==1, result(raxwork)
replace raxwork = 0 if inlist(EiWorkA,3,4) | (inlist(EiWorkA,1,2) & EiStop==1)
replace raxwork = 1 if inlist(EiWorkA,1,2) & EiStop==2
replace raxwork = 1 if EiWorkA==3 & EiWhnTY==raxyear & inrange(EiWhnTY,2002,2009) & ///
											 ((inlist(EiWhnTM,12,1,2) & raxseason==1) | (inlist(EiWhnTM,3,4,5) & raxseason==2) | ///
											 (inlist(EiWhnTM,6,7,8) & raxseason==3) | (inlist(EiWhnTM,9,10,11) & raxseason==4))

***month last worked***
*wave 4 respondent month last worked
missing_w4 EiWorkA EiStop EiWhen EiWhnTM r1jlastm if inw`wv'xt==1, result(raxjlastm_e)
forvalues v = 1/3 {
	replace raxjlastm_e = r`v'jlastm if ralstcore==`v' & EiWorkA==4
}
replace raxjlastm_e = EiWhnTM if inrange(EiWhnTM,1,12) & EiWorkA==3
replace raxjlastm_e = EiWhen if inrange(EiWhen,1,12) & inlist(EiWorkA,1,2) & EiStop==1
replace raxjlastm_e = 13 if raxseason==1 & inlist(EiWorkA,1,2) & EiStop==2
replace raxjlastm_e = 14 if raxseason==2 & inlist(EiWorkA,1,2) & EiStop==2
replace raxjlastm_e = 15 if raxseason==3 & inlist(EiWorkA,1,2) & EiStop==2
replace raxjlastm_e = 16 if raxseason==4 & inlist(EiWorkA,1,2) & EiStop==2
replace raxjlastm_e = .m if raxjlastm_e==.w & inw`wv'xt==1

***year last worked***
*wave 4 respondent year last worked
missing_w4 EiWorkA EiStop EiWhenY EiWhnTY r1jlasty if inw`wv'xt==1, result(raxjlasty)
forvalues v = 1/3 {
	replace raxjlasty = r`v'jlasty if ralstcore==`v' & EiWorkA==4
}
replace raxjlasty = EiWhnTY if inrange(EiWhnTY,2002,2009) & EiWorkA==3
replace raxjlasty = EiWhenY if inrange(EiWhenY,2002,2009) & inlist(EiWorkA,1,2) & EiStop==1
replace raxjlasty = raxyear if inrange(raxyear,2002,2009) & inlist(EiWorkA,1,2) & EiStop==2
replace raxjlasty = .m if raxjlasty==.w & inw`wv'xt==1




***drop ELSA wave 4 core file raw variables***
drop `employxt_w4_exit'

***drop H_ELSA variables***
drop `employxt_w4_helsa'


******************************************************************************************


*set wave number
local wv=6
local pre_wv=5

***merge with wave 6 exit data***
local employxt_w6_exit EiWorkA EiWhnTM EiWhnTY EiStop EiWhen EiWhenY
merge 1:1 idauniq using "$wave_6_xt", keepusing(`employxt_w6_exit') nogen

***merge with h_elsa vars***
local employxt_w6_helsa r1jlastm r2jlastm r3jlastm r4jlastm r5jlastm ///
												r1jlasty r2jlasty r3jlasty r4jlasty r5jlasty 
merge 1:1 idauniq using "$h_elsa", keepusing(`employxt_w6_helsa') nogen




***working up until time of death***
*wave 3 respondent working up until time of death
missing_w6 EiWorkA EiStop if inw`wv'xt==1, result(raxwork)
replace raxwork = 0 if inlist(EiWorkA,3,4) | (inlist(EiWorkA,1,2) & EiStop==1)
replace raxwork = 1 if inlist(EiWorkA,1,2) & EiStop==2
replace raxwork = 1 if EiWorkA==3 & EiWhnTY==raxyear & inrange(EiWhnTY,2002,2012) & ///
											 ((inlist(EiWhnTM,12,1,2) & raxseason==1) | (inlist(EiWhnTM,3,4,5) & raxseason==2) | ///
											 (inlist(EiWhnTM,6,7,8) & raxseason==3) | (inlist(EiWhnTM,9,10,11) & raxseason==4))

***month last worked***
*wave 3 respondent month last worked
missing_w6 EiWorkA EiStop EiWhen EiWhnTM r1jlastm if inw`wv'xt==1, result(raxjlastm_e)
forvalues v = 1/5 {
	replace raxjlastm_e = r`v'jlastm if ralstcore==`v' & EiWorkA==4
}
replace raxjlastm_e = EiWhnTM if inrange(EiWhnTM,1,12) & EiWorkA==3
replace raxjlastm_e = EiWhen if inrange(EiWhen,1,12) & inlist(EiWorkA,1,2) & EiStop==1
replace raxjlastm_e = 13 if raxseason==1 & inlist(EiWorkA,1,2) & EiStop==2
replace raxjlastm_e = 14 if raxseason==2 & inlist(EiWorkA,1,2) & EiStop==2
replace raxjlastm_e = 15 if raxseason==3 & inlist(EiWorkA,1,2) & EiStop==2
replace raxjlastm_e = 16 if raxseason==4 & inlist(EiWorkA,1,2) & EiStop==2
replace raxjlastm_e = .m if raxjlastm_e==.w & inw`wv'xt==1

***year last worked***
*wave 3 respondent year last worked
missing_w6 EiWorkA EiStop EiWhenY EiWhnTY r1jlasty if inw`wv'xt==1, result(raxjlasty)
forvalues v = 1/5 {
	replace raxjlasty = r`v'jlasty if ralstcore==`v' & EiWorkA==4
}
replace raxjlasty = EiWhnTY if inrange(EiWhnTY,2002,2012) & EiWorkA==3
replace raxjlasty = EiWhenY if inrange(EiWhenY,2002,2012) & inlist(EiWorkA,1,2) & EiStop==1
replace raxjlasty = raxyear if inrange(raxyear,2000,2012) & inlist(EiWorkA,1,2) & EiStop==2
replace raxjlasty = .m if raxjlasty==.w & inw`wv'xt==1




***drop ELSA wave 6 core file raw variables***
drop `employxt_w6_exit'

***drop H_ELSA variables***
drop `employxt_w6_helsa'


******************************************************************************************




label define yesnohlp ///
	0 "0.no" ///
	1 "1.yes" ///
	.h ".h:no help received"
	
	

	
 

*set wave number
local wv=2
local pre_wv=1

local funxt_w2_exit EiRRel EiADLA EiADLB EiADLC EiADLD EiADLE EiADLF EiADLG EiADLH EiADLI EiADLJ ///
										EiADLA2W2 EiADLA2a EiADLA2b EiADLA2c EiADLB2W2 EiADLB2a EiADLB2b EiADLB2c ///
										EiADLC2W2 EiADLC2a EiADLC2b EiADLC2c EiADLD2W2 EiADLD2a EiADLD2b EiADLD2c ///
										EiADLE2W2 EiADLE2a EiADLE2b EiADLE2c EiADLF2W2 EiADLF2a EiADLF2b EiADLF2c ///
										EiADLG2W2 EiADLG2a EiADLG2b EiADLG2c EiADLH2W2 EiADLH2a EiADLH2b EiADLH2c ///
										EiADLI2W2 EiADLI2a EiADLI2b EiADLI2c EiADLJ2W2 EiADLJ2a EiADLJ2b EiADLJ2c ///
										EiWHlp1S EiWHlp2S EiWHlp3S EiWHlp4S EiWHlp5S EiWHlp6S EiWHlp7S EiWHlp8S ///
										EiWHlp9S EiWHlp10S EiWHlp11S EiWHlp12S EiWHlp13S EiWHlp14S EiWHlp15S EiWHlp16S EiWHlp17S 
merge 1:1 idauniq using "$wave_2_xt", keepusing(`funxt_w2_exit') nogen




***someone helped dress***
*wave 2 respondent someone helped dress
gen raxdresshlp = .
missing_w2 EiADLA if inw`wv'xt==1, result(raxdresshlp)
replace raxdresshlp = .d if EiADLA==3
replace raxdresshlp = 0 if EiADLA==2
replace raxdresshlp = 1 if EiADLA==1
label variable raxdresshlp "raxdresshlp: someone helped r dress final 3 months"
label values raxdresshlp yesnohlp

***age needed help dressing***
*wave 2 respondent age needed help dressing
gen dressyrs = .
replace dressyrs = (EiADLA2a*12) + EiADLA2b if inrange(EiADLA2a,0,100) & inrange(EiADLA2b,0,12) & EiADLA2W2==1
replace dressyrs = (dressyrs/12) if !mi(dressyrs)

gen raxdressage = .
missing_w2 raxdresshlp EiADLA2W2 EiADLA2a EiADLA2b EiADLA2c if inw`wv'xt==1, result(raxdressage)
replace raxdressage = .d if EiADLA2W2==3
replace raxdressage = .h if raxdresshlp==0 & inw`wv'xt==1
replace raxdressage = floor(radage - dressyrs) if !mi(radage) & !mi(dressyrs) & EiADLA2W2==1
replace raxdressage = EiADLA2c if inrange(EiADLA2c,1,100) & EiADLA2W2==2
replace raxdressage = .i if ((raxdressage > radage) | (raxdressage < 0)) & !mi(raxdressage) & !mi(radage)
label variable raxdressage "raxdressage: age r began to need help dressing"

***help dressing began final year***
*wave 2 respondent help dressing began final year
gen raxdressb1y = .
missing_w2 raxdresshlp EiADLA2W2 EiADLA2a EiADLA2b EiADLA2c if inw`wv'xt==1, result(raxdressb1y)
replace raxdressb1y = .d if EiADLA2W2==3
replace raxdressb1y = 0 if raxdresshlp==0 & inw`wv'xt==1
replace raxdressb1y = 0 if (inrange(dressyrs,1.01,100) & EiADLA2W2==1) | ///
													 (((radage - EiADLA2c) > 1) & !mi(radage) & inrange(EiADLA2c,1,100) & EiADLA2W2==2)
replace raxdressb1y = 1 if (inrange(dressyrs,0,1) & EiADLA2W2==1) | ///
													 ((((radage - EiADLA2c)==0) | ((radage - EiADLA2c)==1)) & !mi(radage) & ///
													 inrange(EiADLA2c,1,100) & EiADLA2W2==2)
label variable raxdressb1y "raxdressb1y: r began needing help with dressing final year"
label values raxdressb1y yesnohlp

drop dressyrs


***someone helped walk***
*wave 2 respondent someone helped walk
gen raxwalkhlp = .
missing_w2 EiADLB if inw`wv'xt==1, result(raxwalkhlp)
replace raxwalkhlp = .d if EiADLB==3
replace raxwalkhlp = 0 if EiADLB==2
replace raxwalkhlp = 1 if EiADLB==1
label variable raxwalkhlp "raxwalkhlp: someone helped r walk across a room final 3 months"
label values raxwalkhlp yesnohlp

***age needed help walking***
*wave 2 respondent age needed help walking
gen walkyrs = .
replace walkyrs = (EiADLB2a*12) + EiADLB2b if inrange(EiADLB2a,0,100) & inrange(EiADLB2b,0,12) & EiADLB2W2==1
replace walkyrs = (walkyrs/12) if !mi(walkyrs)

gen raxwalkage = .
missing_w2 raxwalkhlp EiADLB2W2 EiADLB2a EiADLB2b EiADLB2c if inw`wv'xt==1, result(raxwalkage)
replace raxwalkage = .d if EiADLB2W2==3
replace raxwalkage = .h if raxwalkhlp==0 & inw`wv'xt==1
replace raxwalkage = floor(radage - walkyrs) if !mi(radage) & !mi(walkyrs) & EiADLB2W2==1
replace raxwalkage = EiADLB2c if inrange(EiADLB2c,1,100) & EiADLB2W2==2
replace raxwalkage = .i if ((raxwalkage > radage) | (raxwalkage < 0)) & !mi(raxwalkage) & !mi(radage)
label variable raxwalkage "raxwalkage: age r began to need help walking across a room"

***help walking began final year***
*wave 2 respondent help walking began final year
gen raxwalkb1y = .
missing_w2 raxwalkhlp EiADLB2W2 EiADLB2a EiADLB2b EiADLB2c if inw`wv'xt==1, result(raxwalkb1y)
replace raxwalkb1y = .d if EiADLB2W2==3
replace raxwalkb1y = 0 if raxwalkhlp==0 & inw`wv'xt==1
replace raxwalkb1y = 0 if (inrange(walkyrs,1.01,100) & EiADLB2W2==1) | ///
													 (((radage - EiADLB2c) > 1) & !mi(radage) & inrange(EiADLB2c,1,100) & EiADLB2W2==2)
replace raxwalkb1y = 1 if (inrange(walkyrs,0,1) & EiADLB2W2==1) | ///
													 ((((radage - EiADLB2c)==0) | ((radage - EiADLB2c)==1)) & !mi(radage) & ///
													 inrange(EiADLB2c,1,100) & EiADLB2W2==2)
label variable raxwalkb1y "raxwalkb1y: r began needing help with walking across room final year"
label values raxwalkb1y yesnohlp

drop walkyrs


***someone helped bathe***
*wave 2 respondent someone helped bathe
gen raxbathehlp = .
missing_w2 EiADLC if inw`wv'xt==1, result(raxbathehlp)
replace raxbathehlp = .d if EiADLC==3
replace raxbathehlp = 0 if EiADLC==2
replace raxbathehlp = 1 if EiADLC==1
label variable raxbathehlp "raxbathehlp: someone helped r bathe final 3 months"
label values raxbathehlp yesnohlp

***age needed help bathing***
*wave 2 respondent age needed help bathing
gen batheyrs = .
replace batheyrs = (EiADLC2a*12) + EiADLC2b if inrange(EiADLC2a,0,100) & inrange(EiADLC2b,0,12) & EiADLC2W2==1
replace batheyrs = (batheyrs/12) if !mi(batheyrs)

gen raxbatheage = .
missing_w2 raxbathehlp EiADLC2W2 EiADLC2a EiADLC2b EiADLC2c if inw`wv'xt==1, result(raxbatheage)
replace raxbatheage = .d if EiADLC2W2==3
replace raxbatheage = .h if raxbathehlp==0 & inw`wv'xt==1
replace raxbatheage = floor(radage - batheyrs) if !mi(radage) & !mi(batheyrs) & EiADLC2W2==1
replace raxbatheage = EiADLC2c if inrange(EiADLC2c,1,100) & EiADLC2W2==2
replace raxbatheage = .i if ((raxbatheage > radage) | (raxbatheage < 0)) & !mi(raxbatheage) & !mi(radage)
label variable raxbatheage "raxbatheage: age r began to need help bathing"

***help bathing began final year***
*wave 2 respondent help bathing began final year
gen raxbatheb1y = .
missing_w2 raxbathehlp EiADLC2W2 EiADLC2a EiADLC2b EiADLC2c if inw`wv'xt==1, result(raxbatheb1y)
replace raxbatheb1y = .d if EiADLC2W2==3
replace raxbatheb1y = 0 if raxbathehlp==0 & inw`wv'xt==1
replace raxbatheb1y = 0 if (inrange(batheyrs,1.01,100) & EiADLC2W2==1) | ///
													 (((radage - EiADLC2c) > 1) & !mi(radage) & inrange(EiADLC2c,1,100) & EiADLC2W2==2)
replace raxbatheb1y = 1 if (inrange(batheyrs,0,1) & EiADLC2W2==1) | ///
													 ((((radage - EiADLC2c)==0) | ((radage - EiADLC2c)==1)) & !mi(radage) & ///
													 inrange(EiADLC2c,1,100) & EiADLC2W2==2)
label variable raxbatheb1y "raxbatheb1y: r began needing help with bathing final year"
label values raxbatheb1y yesnohlp

drop batheyrs


***someone helped eat***
*wave 2 respondent someone helped eat
gen raxeathlp = .
missing_w2 EiADLD if inw`wv'xt==1, result(raxeathlp)
replace raxeathlp = .d if EiADLD==3
replace raxeathlp = 0 if EiADLD==2
replace raxeathlp = 1 if EiADLD==1
label variable raxeathlp "raxeathlp: someone helped r eat final 3 months"
label values raxeathlp yesnohlp

***age needed help eating***
*wave 2 respondent age needed help eating
gen eatyrs = .
replace eatyrs = (EiADLD2a*12) + EiADLD2b if inrange(EiADLD2a,0,100) & inrange(EiADLD2b,0,12) & EiADLD2W2==1
replace eatyrs = (eatyrs/12) if !mi(eatyrs)

gen raxeatage = .
missing_w2 raxeathlp EiADLD2W2 EiADLD2a EiADLD2b EiADLD2c if inw`wv'xt==1, result(raxeatage)
replace raxeatage = .d if EiADLD2W2==3
replace raxeatage = .h if raxeathlp==0 & inw`wv'xt==1
replace raxeatage = floor(radage - eatyrs) if !mi(radage) & !mi(eatyrs) & EiADLD2W2==1
replace raxeatage = EiADLD2c if inrange(EiADLD2c,1,100) & EiADLD2W2==2
replace raxeatage = .i if ((raxeatage > radage) | (raxeatage < 0)) & !mi(raxeatage) & !mi(radage)
label variable raxeatage "raxeatage: age r began to need help eating"

***help eating began final year***
*wave 2 respondent help eating began final year
gen raxeatb1y = .
missing_w2 raxeathlp EiADLD2W2 EiADLD2a EiADLD2b EiADLD2c if inw`wv'xt==1, result(raxeatb1y)
replace raxeatb1y = .d if EiADLD2W2==3
replace raxeatb1y = 0 if raxeathlp==0 & inw`wv'xt==1
replace raxeatb1y = 0 if (inrange(eatyrs,1.01,100) & EiADLD2W2==1) | ///
													 (((radage - EiADLD2c) > 1) & !mi(radage) & inrange(EiADLD2c,1,100) & EiADLD2W2==2)
replace raxeatb1y = 1 if (inrange(eatyrs,0,1) & EiADLD2W2==1) | ///
													 ((((radage - EiADLD2c)==0) | ((radage - EiADLD2c)==1)) & !mi(radage) & ///
													 inrange(EiADLD2c,1,100) & EiADLD2W2==2)
label variable raxeatb1y "raxeatb1y: r began needing help with eating final year"
label values raxeatb1y yesnohlp

drop eatyrs


***someone helped bed***
*wave 2 respondent someone helped bed
gen raxbedhlp = .
missing_w2 EiADLE if inw`wv'xt==1, result(raxbedhlp)
replace raxbedhlp = .d if EiADLE==3
replace raxbedhlp = 0 if EiADLE==2
replace raxbedhlp = 1 if EiADLE==1
label variable raxbedhlp "raxbedhlp: someone helped r get in and out of bed final 3 months"
label values raxbedhlp yesnohlp

***age needed help w/ bed***
*wave 2 respondent age needed help w/ bed
gen bedyrs = .
replace bedyrs = (EiADLE2a*12) + EiADLE2b if inrange(EiADLE2a,0,100) & inrange(EiADLE2b,0,12) & EiADLE2W2==1
replace bedyrs = (bedyrs/12) if !mi(bedyrs)

gen raxbedage = .
missing_w2 raxbedhlp EiADLE2W2 EiADLE2a EiADLE2b EiADLE2c if inw`wv'xt==1, result(raxbedage)
replace raxbedage = .d if EiADLE2W2==3
replace raxbedage = .h if raxbedhlp==0 & inw`wv'xt==1
replace raxbedage = floor(radage - bedyrs) if !mi(radage) & !mi(bedyrs) & EiADLE2W2==1
replace raxbedage = EiADLE2c if inrange(EiADLE2c,1,100) & EiADLE2W2==2
replace raxbedage = .i if ((raxbedage > radage) | (raxbedage < 0)) & !mi(raxbedage) & !mi(radage)
label variable raxbedage "raxbedage: age r began to need help getting in/out of bed"

***help w/ bed began final year***
*wave 2 respondent help w/ bed began final year
gen raxbedb1y = .
missing_w2 raxbedhlp EiADLE2W2 EiADLE2a EiADLE2b EiADLE2c if inw`wv'xt==1, result(raxbedb1y)
replace raxbedb1y = .d if EiADLE2W2==3
replace raxbedb1y = 0 if raxbedhlp==0 & inw`wv'xt==1
replace raxbedb1y = 0 if (inrange(bedyrs,1.01,100) & EiADLE2W2==1) | ///
													 (((radage - EiADLE2c) > 1) & !mi(radage) & inrange(EiADLE2c,1,100) & EiADLE2W2==2)
replace raxbedb1y = 1 if (inrange(bedyrs,0,1) & EiADLE2W2==1) | ///
													 ((((radage - EiADLE2c)==0) | ((radage - EiADLE2c)==1)) & !mi(radage) & ///
													 inrange(EiADLE2c,1,100) & EiADLE2W2==2)
label variable raxbedb1y "raxbedb1y: r began needing help with getting in/out bed final year"
label values raxbedb1y yesnohlp

drop bedyrs


***someone helped toilet***
*wave 2 respondent someone helped toilet
gen raxtoilethlp = .
missing_w2 EiADLF if inw`wv'xt==1, result(raxtoilethlp)
replace raxtoilethlp = .d if EiADLF==3
replace raxtoilethlp = 0 if EiADLF==2
replace raxtoilethlp = 1 if EiADLF==1
label variable raxtoilethlp "raxtoilethlp: someone helped r use the toilet final 3 months"
label values raxtoilethlp yesnohlp

***age needed help w/ toilet***
*wave 2 respondent age needed help w/ toilet
gen toiletyrs = .
replace toiletyrs = (EiADLF2a*12) + EiADLF2b if inrange(EiADLF2a,0,100) & inrange(EiADLF2b,0,12) & EiADLF2W2==1
replace toiletyrs = (toiletyrs/12) if !mi(toiletyrs)

gen raxtoiletage = .
missing_w2 raxtoilethlp EiADLF2W2 EiADLF2a EiADLF2b EiADLF2c if inw`wv'xt==1, result(raxtoiletage)
replace raxtoiletage = .d if EiADLF2W2==3
replace raxtoiletage = .h if raxtoilethlp==0 & inw`wv'xt==1
replace raxtoiletage = floor(radage - toiletyrs) if !mi(radage) & !mi(toiletyrs) & EiADLF2W2==1
replace raxtoiletage = EiADLF2c if inrange(EiADLF2c,1,100) & EiADLF2W2==2
replace raxtoiletage = .i if ((raxtoiletage > radage) | (raxtoiletage < 0)) & !mi(raxtoiletage) & !mi(radage)
label variable raxtoiletage "raxtoiletage: age r began to need help using the toilet"

***help w/ toilet began final year***
*wave 2 respondent help w/ toilet began final year
gen raxtoiletb1y = .
missing_w2 raxtoilethlp EiADLF2W2 EiADLF2a EiADLF2b EiADLF2c if inw`wv'xt==1, result(raxtoiletb1y)
replace raxtoiletb1y = .d if EiADLF2W2==3
replace raxtoiletb1y = 0 if raxtoilethlp==0 & inw`wv'xt==1
replace raxtoiletb1y = 0 if (inrange(toiletyrs,1.01,100) & EiADLF2W2==1) | ///
													 (((radage - EiADLF2c) > 1) & !mi(radage) & inrange(EiADLF2c,1,100) & EiADLF2W2==2)
replace raxtoiletb1y = 1 if (inrange(toiletyrs,0,1) & EiADLF2W2==1) | ///
													 ((((radage - EiADLF2c)==0) | ((radage - EiADLF2c)==1)) & !mi(radage) & ///
													 inrange(EiADLF2c,1,100) & EiADLF2W2==2)
label variable raxtoiletb1y "raxtoiletb1y: r began needing help with toileting final year"
label values raxtoiletb1y yesnohlp

drop toiletyrs


***someone helped any adl***
*wave 2 respondent someone helped any adl
gen raxracany = .
missing_w2 raxdresshlp raxwalkhlp raxbathehlp raxeathlp raxbedhlp raxtoilethlp if inw`wv'xt==1, result(raxracany)
replace raxracany = 0 if (raxdresshlp==0 | raxwalkhlp==0 | raxbathehlp==0 | raxeathlp==0 | ///
												raxbedhlp==0 | raxtoilethlp==0) & inw`wv'xt==1
replace raxracany = 1 if (raxdresshlp==1 | raxwalkhlp==1 | raxbathehlp==1 | raxeathlp==1 | ///
												raxbedhlp==1 | raxtoilethlp==1) & inw`wv'xt==1
label variable raxracany "raxracany: r received any care for adls final 3 months"
label values raxracany yesnohlp

***help w/ any adl began final year***
*wave 2 respondent help w/ any adl began final year
gen raxracareb = .
missing_w2 raxdressb1y raxwalkb1y raxbatheb1y raxeatb1y raxbedb1y raxtoiletb1y if inw`wv'xt==1, result(raxracareb)
replace raxracareb = 0 if raxracany==0 & inw`wv'xt==1
replace raxracareb = 0 if (raxdressb1y==0 | raxwalkb1y==0 | raxbatheb1y==0 | raxeatb1y==0 | ///
													 raxbedb1y==0 | raxtoiletb1y==0) & inw`wv'xt==1
replace raxracareb = 1 if (raxdressb1y==1 | raxwalkb1y==1 | raxbatheb1y==1 | raxeatb1y==1 | ///
													 raxbedb1y==1 | raxtoiletb1y==1) & inw`wv'xt==1
label variable raxracareb "raxracareb: r began needing help with any adl final year"
label values raxracareb yesnohlp


***someone helped hot meals***
*wave 2 respondent someone helped hot meals
gen raxmealhlp = .
missing_w2 EiADLG if inw`wv'xt==1, result(raxmealhlp)
replace raxmealhlp = .d if EiADLG==3
replace raxmealhlp = 0 if EiADLG==2
replace raxmealhlp = 1 if EiADLG==1
label variable raxmealhlp "raxmealhlp: someone helped r with hot meals final 3 months"
label values raxmealhlp yesnohlp

***age needed help hot meals***
*wave 2 respondent age needed help hot meals
gen mealyrs = .
replace mealyrs = (EiADLG2a*12) + EiADLG2b if inrange(EiADLG2a,0,100) & inrange(EiADLG2b,0,12) & EiADLG2W2==1
replace mealyrs = (mealyrs/12) if !mi(mealyrs)

gen raxmealage = .
missing_w2 raxmealhlp EiADLG2W2 EiADLG2a EiADLG2b EiADLG2c if inw`wv'xt==1, result(raxmealage)
replace raxmealage = .d if EiADLG2W2==3
replace raxmealage = .h if raxmealhlp==0 & inw`wv'xt==1
replace raxmealage = floor(radage - mealyrs) if !mi(radage) & !mi(mealyrs) & EiADLG2W2==1
replace raxmealage = EiADLG2c if inrange(EiADLG2c,1,100) & EiADLG2W2==2
replace raxmealage = .i if ((raxmealage > radage) | (raxmealage < 0)) & !mi(raxmealage) & !mi(radage)
label variable raxmealage "raxmealage: age r began to need help with hot meals"

***help w/ hot meals began final year***
gen raxmealb1y = .
missing_w2 raxmealhlp EiADLG2W2 EiADLG2a EiADLG2b EiADLG2c if inw`wv'xt==1, result(raxmealb1y)
replace raxmealb1y = .d if EiADLG2W2==3
replace raxmealb1y = 0 if raxmealhlp==0 & inw`wv'xt==1
replace raxmealb1y = 0 if (inrange(mealyrs,1.01,100) & EiADLG2W2==1) | ///
													 (((radage - EiADLG2c) > 1) & !mi(radage) & inrange(EiADLG2c,1,100) & EiADLG2W2==2)
replace raxmealb1y = 1 if (inrange(mealyrs,0,1) & EiADLG2W2==1) | ///
													 ((((radage - EiADLG2c)==0) | ((radage - EiADLG2c)==1)) & !mi(radage) & ///
													 inrange(EiADLG2c,1,100) & EiADLG2W2==2)
label variable raxmealb1y "raxmealb1y: r began needing help with hot meals final year"
label values raxmealb1y yesnohlp

drop mealyrs


***someone helped grocery shopping***
*wave 2 respondent someone helped grocery shopping
gen raxshophlp = .
missing_w2 EiADLH if inw`wv'xt==1, result(raxshophlp)
replace raxshophlp = .d if EiADLH==3
replace raxshophlp = 0 if EiADLH==2
replace raxshophlp = 1 if EiADLH==1
label variable raxshophlp "raxshophlp: someone helped r with grocery shopping final 3 months"
label values raxshophlp yesnohlp

***age needed help grocery shopping***
*wave 2 respondent age needed help grocery shopping
gen shopyrs = .
replace shopyrs = (EiADLH2a*12) + EiADLH2b if inrange(EiADLH2a,0,100) & inrange(EiADLH2b,0,12) & EiADLH2W2==1
replace shopyrs = (shopyrs/12) if !mi(shopyrs)

gen raxshopage = .
missing_w2 raxshophlp EiADLH2W2 EiADLH2a EiADLH2b EiADLH2c if inw`wv'xt==1, result(raxshopage)
replace raxshopage = .d if EiADLH2W2==3
replace raxshopage = .h if raxshophlp==0 & inw`wv'xt==1
replace raxshopage = floor(radage - shopyrs) if !mi(radage) & !mi(shopyrs) & EiADLH2W2==1
replace raxshopage = EiADLH2c if inrange(EiADLH2c,1,100) & EiADLH2W2==2
replace raxshopage = .i if ((raxshopage > radage) | (raxshopage < 0)) & !mi(raxshopage) & !mi(radage)
label variable raxshopage "raxshopage: age r began to need help grocery shopping"

***help w/ grocery shopping began final year***
*wave 2 respondent help w/ grocery shopping began final year
gen raxshopb1y = .
missing_w2 raxshophlp EiADLH2W2 EiADLH2a EiADLH2b EiADLH2c if inw`wv'xt==1, result(raxshopb1y)
replace raxshopb1y = .d if EiADLH2W2==3
replace raxshopb1y = 0 if raxshophlp==0 & inw`wv'xt==1
replace raxshopb1y = 0 if (inrange(shopyrs,1.01,100) & EiADLH2W2==1) | ///
													 (((radage - EiADLH2c) > 1) & !mi(radage) & inrange(EiADLH2c,1,100) & EiADLH2W2==2)
replace raxshopb1y = 1 if (inrange(shopyrs,0,1) & EiADLH2W2==1) | ///
													 ((((radage - EiADLH2c)==0) | ((radage - EiADLH2c)==1)) & !mi(radage) & ///
													 inrange(EiADLH2c,1,100) & EiADLH2W2==2)
label variable raxshopb1y "raxshopb1y: r began needing help with grocery shopping final year"
label values raxshopb1y yesnohlp

drop shopyrs


***someone helped phone***
*wave 2 respondent someone helped phone
gen raxphonehlp = .
missing_w2 EiADLI if inw`wv'xt==1, result(raxphonehlp)
replace raxphonehlp = .d if EiADLI==3
replace raxphonehlp = 0 if EiADLI==2
replace raxphonehlp = 1 if EiADLI==1
label variable raxphonehlp "raxphonehlp: someone helped r with using the phone final 3 months"
label values raxphonehlp yesnohlp

***age needed help phone***
*wave 2 respondent age needed help phone
gen phoneyrs = .
replace phoneyrs = (EiADLI2a*12) + EiADLI2b if inrange(EiADLI2a,0,100) & inrange(EiADLI2b,0,12) & EiADLI2W2==1
replace phoneyrs = (phoneyrs/12) if !mi(phoneyrs)

gen raxphoneage = .
missing_w2 raxphonehlp EiADLI2W2 EiADLI2a EiADLI2b EiADLI2c if inw`wv'xt==1, result(raxphoneage)
replace raxphoneage = .d if EiADLI2W2==3
replace raxphoneage = .h if raxphonehlp==0 & inw`wv'xt==1
replace raxphoneage = floor(radage - phoneyrs) if !mi(radage) & !mi(phoneyrs) & EiADLI2W2==1
replace raxphoneage = EiADLI2c if inrange(EiADLI2c,1,100) & EiADLI2W2==2
replace raxphoneage = .i if ((raxphoneage > radage) | (raxphoneage < 0)) & !mi(raxphoneage) & !mi(radage)
label variable raxphoneage "raxphoneage: age r began to need help using the phone"

***help w/ phone began final year***
*wave 2 respondent help w/ phone began final year
gen raxphoneb1y = .
missing_w2 raxphonehlp EiADLI2W2 EiADLI2a EiADLI2b EiADLI2c if inw`wv'xt==1, result(raxphoneb1y)
replace raxphoneb1y = .d if EiADLI2W2==3
replace raxphoneb1y = 0 if raxphonehlp==0 & inw`wv'xt==1
replace raxphoneb1y = 0 if (inrange(phoneyrs,1.01,100) & EiADLI2W2==1) | ///
													 (((radage - EiADLI2c) > 1) & !mi(radage) & inrange(EiADLI2c,1,100) & EiADLI2W2==2)
replace raxphoneb1y = 1 if (inrange(phoneyrs,0,1) & EiADLI2W2==1) | ///
													 ((((radage - EiADLI2c)==0) | ((radage - EiADLI2c)==1)) & !mi(radage) & ///
													 inrange(EiADLI2c,1,100) & EiADLI2W2==2)
label variable raxphoneb1y "raxphoneb1y: r began needing help with using the phone final year"
label values raxphoneb1y yesnohlp

drop phoneyrs


***someone helped meds***
*wave 2 respondent someone helped meds
gen raxmedhlp = .
missing_w2 EiADLJ if inw`wv'xt==1, result(raxmedhlp)
replace raxmedhlp = .d if EiADLJ==3
replace raxmedhlp = 0 if EiADLJ==2
replace raxmedhlp = 1 if EiADLJ==1
label variable raxmedhlp "raxmedhlp: someone helped r with medications final 3 months"
label values raxmedhlp yesnohlp

***age needed help meds***
*wave 2 respondent age needed help meds
gen medyrs = .
replace medyrs = (EiADLJ2a*12) + EiADLJ2b if inrange(EiADLJ2a,0,100) & inrange(EiADLJ2b,0,12) & EiADLJ2W2==1
replace medyrs = (medyrs/12) if !mi(medyrs)

gen raxmedage = .
missing_w2 raxmedhlp EiADLJ2W2 EiADLJ2a EiADLJ2b EiADLJ2c if inw`wv'xt==1, result(raxmedage)
replace raxmedage = .d if EiADLJ2W2==3
replace raxmedage = .h if raxmedhlp==0 & inw`wv'xt==1
replace raxmedage = floor(radage - medyrs) if !mi(radage) & !mi(medyrs) & EiADLJ2W2==1
replace raxmedage = EiADLJ2c if inrange(EiADLJ2c,1,100) & EiADLJ2W2==2
replace raxmedage = .i if ((raxmedage > radage) | (raxmedage < 0)) & !mi(raxmedage) & !mi(radage)
label variable raxmedage "raxmedage: age r began to need help with medications"

***help w/ meds began final year***
*wave 2 respondent help w/ meds began final year
gen raxmedb1y = .
missing_w2 raxmedhlp EiADLJ2W2 EiADLJ2a EiADLJ2b EiADLJ2c if inw`wv'xt==1, result(raxmedb1y)
replace raxmedb1y = .d if EiADLJ2W2==3
replace raxmedb1y = 0 if raxmedhlp==0 & inw`wv'xt==1
replace raxmedb1y = 0 if (inrange(medyrs,1.01,100) & EiADLJ2W2==1) | ///
													 (((radage - EiADLJ2c) > 1) & !mi(radage) & inrange(EiADLJ2c,1,100) & EiADLJ2W2==2)
replace raxmedb1y = 1 if (inrange(medyrs,0,1) & EiADLJ2W2==1) | ///
													 ((((radage - EiADLJ2c)==0) | ((radage - EiADLJ2c)==1)) & !mi(radage) & ///
													 inrange(EiADLJ2c,1,100) & EiADLJ2W2==2)
label variable raxmedb1y "raxmedb1y: r began needing help with medications final year"
label values raxmedb1y yesnohlp

drop medyrs


***someone helped any iadl***
*wave 2 respondent someone helped any iadl
gen raxricany = .
missing_w2 raxmealhlp raxshophlp raxphonehlp raxmedhlp if inw`wv'xt==1, result(raxricany)
replace raxricany = 0 if (raxmealhlp==0 | raxshophlp==0 | raxphonehlp==0 | raxmedhlp==0) & inw`wv'xt==1
replace raxricany = 1 if (raxmealhlp==1 | raxshophlp==1 | raxphonehlp==1 | raxmedhlp==1) & inw`wv'xt==1
label variable raxricany "raxricany: r received any care for iadls final 3 months"
label values raxricany yesnohlp

***help w/ any iadl began final year***
*wave 2 respondent help w/ any iadl began final year
gen raxricareb = .
missing_w2 raxmealb1y raxshopb1y raxphoneb1y raxmedb1y if inw`wv'xt==1, result(raxricareb)
replace raxricareb = 0 if raxricany==0 & inw`wv'xt==1
replace raxricareb = 0 if (raxmealb1y==0 | raxshopb1y==0 | raxphoneb1y==0 | raxmedb1y==0) & inw`wv'xt==1
replace raxricareb = 1 if (raxmealb1y==1 | raxshopb1y==1 | raxphoneb1y==1 | raxmedb1y==1) & inw`wv'xt==1
label variable raxricareb "raxricareb: r began needing help with any iadl final year"
label values raxricareb yesnohlp


***someone helped adl or iadl***
*wave 2 respondent someone helped adl or iadl
gen raxrcany = .
missing_w2 raxracany raxricany if inw`wv'xt==1, result(raxrcany)
replace raxrcany = 0 if (raxracany==0 | raxricany==0) & inw`wv'xt==1
replace raxrcany = 1 if (raxracany==1 | raxricany==1) & inw`wv'xt==1
label variable raxrcany "raxrcany: r received any care for adls/iadls final 3 months"
label values raxrcany yesnohlp

***help w/ any adl or iadl began final year***
*wave 2 respondent help w/ any adl or iadl began final year
gen raxrcareb = .
missing_w2 raxracareb raxricareb if inw`wv'xt==1, result(raxrcareb)
replace raxrcareb = 0 if raxrcany==0 & inw`wv'xt==1
replace raxrcareb = 0 if (raxracareb==0 | raxricareb==0) & inw`wv'xt==1
replace raxrcareb = 1 if (raxracareb==1 | raxricareb==1) & inw`wv'xt==1
label variable raxrcareb "raxrcareb: r began needing help with any adl/iadl final year"
label values raxrcareb yesnohlp


***spouse helped r adl/iadl***
*wave 2 respondent spouse helped r adl/iadl
gen raxrscare = .
missing_w2 EiRRel EiWHlp1S EiWHlp2S if inw`wv'xt==1, result(raxrscare)
replace raxrscare = .h if raxrcany==0 & inw`wv'xt==1
replace raxrscare = 0 if EiWHlp2S==0 | ///
												 EiWHlp1S==0 | (EiWHlp1S==1 & inrange(EiRRel,3,22))
replace raxrscare = 1 if EiWHlp2S==1 | (EiWHlp1S==1 & inlist(EiRRel,1,2))
label variable raxrscare "raxrscare: r received informal care from spouse for adls/iadls final 3 months"
label values raxrscare yesnohlp

***child helped r adl/iadl***
*wave 2 respondent child helped r adl/iadl
gen raxrccare = .
missing_w2 EiRRel EiWHlp1S EiWHlp4S EiWHlp5S EiWHlp6S EiWHlp7S EiWHlp10S EiWHlp11S if inw`wv'xt==1, result(raxrccare)
replace raxrccare = .h if raxrcany==0 & inw`wv'xt==1
replace raxrccare = 0 if EiWHlp4S==0 | EiWHlp5S==0 | EiWHlp6S==0 | EiWHlp7S==0 | EiWHlp10S==0 | EiWHlp11S==0 | ///
												 EiWHlp1S==0 | (EiWHlp1S==1 & (inrange(EiRRel,8,18) | inlist(EiRRel,1,2,19,20,21,22)))
replace raxrccare = 1 if EiWHlp4S==1 | EiWHlp5S==1 | EiWHlp6S==1 | EiWHlp7S==1 | EiWHlp10S==1 | EiWHlp11S==1 | ///
												 (EiWHlp1S==1 & inlist(EiRRel,3,4,5,6,7,19))
label variable raxrccare "raxrccare: r received informal care from children/grandchildren for adls/iadls final 3 months"
label values raxrccare yesnohlp

***relative helped r adl/iadl***
*wave 2 respondent relative helped r adl/iadl
gen raxrrcare = .
missing_w2 EiRRel EiWHlp1S EiWHlp3S EiWHlp8S EiWHlp9S if inw`wv'xt==1, result(raxrrcare)
replace raxrrcare = .h if raxrcany==0 & inw`wv'xt==1
replace raxrrcare = 0 if EiWHlp3S==0 | EiWHlp8S==0 | EiWHlp9S==0 | ///
												EiWHlp1S==0 | (EiWHlp1S==1 & (inrange(EiRRel,1,7) | inlist(EiRRel,19,22)))
replace raxrrcare = 1 if EiWHlp3S==1 | EiWHlp8S==1 | EiWHlp9S==1 | ///
												(EiWHlp1S==1 & (inrange(EiRRel,8,18) | inlist(EiRRel,20,21)))
label variable raxrrcare "raxrrcare: r received informal care from relatives for adls/iadls final 3 months"
label values raxrrcare yesnohlp

***other helped r adl/iadl***
*wave 2 respondent other helped r adl/iadl
gen raxrfcare = .
missing_w2 EiRRel EiWHlp1S EiWHlp16S EiWHlp17S if inw`wv'xt==1, result(raxrfcare)
replace raxrfcare = .h if raxrcany==0 & inw`wv'xt==1
replace raxrfcare = 0 if EiWHlp16S==0 | EiWHlp17S==0 | ///
												EiWHlp1S==0 | (EiWHlp1S==1 & inrange(EiRRel,1,21))
replace raxrfcare = 1 if EiWHlp16S==1 | EiWHlp17S==1 | ///
												(EiWHlp1S==1 & EiRRel==22)
label variable raxrfcare "raxrfcare: r received informal care from non-relatives for adls/iadls final 3 months"
label values raxrfcare yesnohlp

***received any informal care***
*wave 2 respondent received any informal care
gen raxrcaany = .
missing_w2 raxrscare raxrccare raxrrcare raxrfcare if inw`wv'xt==1, result(raxrcaany)
replace raxrcaany = 0 if raxrcany==0 & inw`wv'xt==1
replace raxrcaany = 0 if (raxrscare==0 | raxrccare==0 | raxrrcare==0 | raxrfcare==0) & inw`wv'xt==1
replace raxrcaany = 1 if (raxrscare==1 | raxrccare==1 | raxrrcare==1 | raxrfcare==1) & inw`wv'xt==1
label variable raxrcaany "raxrcaany: r received informal care for adls/iadls final 3 months"
label values raxrcaany yesnohlp 

***paid pro helped r adl/iadl***
*wave 2 respondent paid pro helped r adl/iadl
gen raxrpfcare = .
missing_w2 EiWHlp14S if inw`wv'xt==1, result(raxrpfcare)
replace raxrpfcare = .h if raxrcany==0 & inw`wv'xt==1
replace raxrpfcare = 0 if EiWHlp14S==0 
replace raxrpfcare = 1 if EiWHlp14S==1 
label variable raxrpfcare "raxrpfcare: r received formal care from paid caregiver for adls/iadls final 3 months"
label values raxrpfcare yesnohlp

***unpaid pro helped r adl/iadl***
*wave 2 respondent unpaid pro helped r adl/iadl
gen raxrufcare = .
missing_w2 EiWHlp13S EiWHlp15S if inw`wv'xt==1, result(raxrufcare)
replace raxrufcare = .h if raxrcany==0 & inw`wv'xt==1
replace raxrufcare = 0 if EiWHlp13S==0 | EiWHlp15S==0
replace raxrufcare = 1 if EiWHlp13S==1 | EiWHlp15S==1
label variable raxrufcare "raxrufcare: r received formal care from unpaid caregiver for adls/iadls final 3 months"
label values raxrufcare yesnohlp

***received any formal care***
*wave 2 respondent received any formal care
gen raxrfaany = .
missing_w2 raxrpfcare raxrufcare if inw`wv'xt==1, result(raxrfaany)
replace raxrfaany = 0 if raxrcany==0 & inw`wv'xt==1
replace raxrfaany = 0 if (raxrpfcare==0 | raxrufcare==0) & inw`wv'xt==1
replace raxrfaany = 1 if (raxrpfcare==1 | raxrufcare==1) & inw`wv'xt==1
label variable raxrfaany "raxrfaany: r received formal care for adls/iadls final 3 months"
label values raxrfaany yesnohlp



***drop ELSA wave 2 core file raw variables***
drop `funxt_w2_exit'



******************************************************************************************


*set wave number
local wv=3
local pre_wv=2

local funxt_w3_exit EiRRel EiADLA EiADLB EiADLC EiADLD EiADLE EiADLF EiADLG EiADLH EiADLI EiADLJ ///
										EiADLA2 EiADLA2M EiADLA2Y EiADLB2 EiADLB2M EiADLB2Y ///
										EiADLC2 EiADLC2M EiADLC2Y EiADLD2 EiADLD2M EiADLD2Y ///
										EiADLE2 EiADLE2M EiADLE2Y EiADLF2 EiADLF2M EiADLF2Y ///
										EiADLG2 EiADLG2M EiADLG2Y EiADLH2 EiADLH2M EiADLH2Y ///
										EiADLI2 EiADLI2M EiADLI2Y EiADLJ2 EiADLJ2M EiADLJ2Y ///
										EiWHlp1S EiWHlp2S EiWHlp3S EiWHlp4S EiWHlp5S EiWHlp6S EiWHlp7S EiWHlp8S ///
										EiWHlp9S EiWHlp10S EiWHlp11S EiWHlp12S EiWHlp13S EiWHlp14S EiWHlp15S EiWHlp16S EiWHlp17S  
merge 1:1 idauniq using "$wave_3_xt", keepusing(`funxt_w3_exit') nogen




***someone helped dress***
*wave 3 respondent someone helped dress
missing_w3 EiADLA if inw`wv'xt==1, result(raxdresshlp)
replace raxdresshlp = .d if EiADLA==3
replace raxdresshlp = 0 if EiADLA==2
replace raxdresshlp = 1 if EiADLA==1

***age needed help dressing***
*wave 3 respondent age needed help dressing
gen dressyrs = .
replace dressyrs = (EiADLA2M/12) if inlist(EiADLA2,2,3) & inrange(EiADLA2M,1,24)

missing_w3 raxdresshlp EiADLA2 EiADLA2M EiADLA2Y if inw`wv'xt==1, result(raxdressage)
replace raxdressage = .d if EiADLA2==96
replace raxdressage = .h if raxdresshlp==0 & inw`wv'xt==1
replace raxdressage = radage if EiADLA2==1
replace raxdressage = floor(radage - dressyrs) if !mi(radage) & !mi(dressyrs) & inlist(EiADLA2,2,3)
replace raxdressage = radage - EiADLA2Y if inrange(EiADLA2Y,1,100) & EiADLA2==4
replace raxdressage = .i if ((raxdressage > radage) | (raxdressage < 0)) & !mi(raxdressage) & !mi(radage)

***help dressing began final year***
*wave 3 respondent help dressing began final year
missing_w3 raxdresshlp EiADLA2 if inw`wv'xt==1, result(raxdressb1y)
replace raxdressb1y = .d if EiADLA2==96
replace raxdressb1y = 0 if raxdresshlp==0 & inw`wv'xt==1
replace raxdressb1y = 0 if inlist(EiADLA2,3,4)
replace raxdressb1y = 1 if inlist(EiADLA2,1,2)

drop dressyrs


***someone helped walk***
*wave 3 respondent someone helped walk
missing_w3 EiADLB if inw`wv'xt==1, result(raxwalkhlp)
replace raxwalkhlp = .d if EiADLB==3
replace raxwalkhlp = 0 if EiADLB==2
replace raxwalkhlp = 1 if EiADLB==1

***age needed help walking***
*wave 3 respondent age needed help walking
gen walkyrs = .
replace walkyrs = (EiADLB2M/12) if inlist(EiADLB2,2,3) & inrange(EiADLB2M,1,24)

missing_w3 raxwalkhlp EiADLB2 EiADLB2M EiADLB2Y if inw`wv'xt==1, result(raxwalkage)
replace raxwalkage = .d if EiADLB2==96
replace raxwalkage = .h if raxwalkhlp==0 & inw`wv'xt==1
replace raxwalkage = radage if EiADLB2==1
replace raxwalkage = floor(radage - walkyrs) if !mi(radage) & !mi(walkyrs) & inlist(EiADLB2,2,3)
replace raxwalkage = radage - EiADLB2Y if inrange(EiADLB2Y,1,100) & EiADLB2==4
replace raxwalkage = .i if ((raxwalkage > radage) | (raxwalkage < 0)) & !mi(raxwalkage) & !mi(radage)

***help walking began final year***
*wave 3 respondent help walking began final year
missing_w3 raxwalkhlp EiADLB2 if inw`wv'xt==1, result(raxwalkb1y)
replace raxwalkb1y = .d if EiADLB2==96
replace raxwalkb1y = 0 if raxwalkhlp==0 & inw`wv'xt==1
replace raxwalkb1y = 0 if inlist(EiADLB2,3,4)
replace raxwalkb1y = 1 if inlist(EiADLB2,1,2)

drop walkyrs


***someone helped bathe***
*wave 3 respondent someone helped bathe
missing_w3 EiADLC if inw`wv'xt==1, result(raxbathehlp)
replace raxbathehlp = .d if EiADLC==3
replace raxbathehlp = 0 if EiADLC==2
replace raxbathehlp = 1 if EiADLC==1

***age needed help bathing***
*wave 3 respondent age needed help bathing
gen batheyrs = .
replace batheyrs = (EiADLC2M/12) if inlist(EiADLC2,2,3) & inrange(EiADLC2M,1,24)

missing_w3 raxbathehlp EiADLC2 EiADLC2M EiADLC2Y if inw`wv'xt==1, result(raxbatheage)
replace raxbatheage = .d if EiADLC2==96
replace raxbatheage = .h if raxbathehlp==0 & inw`wv'xt==1
replace raxbatheage = radage if EiADLC2==1
replace raxbatheage = floor(radage - batheyrs) if !mi(radage) & !mi(batheyrs) & inlist(EiADLC2,2,3)
replace raxbatheage = radage - EiADLC2Y if inrange(EiADLC2Y,1,100) & EiADLC2==4
replace raxbatheage = .i if ((raxbatheage > radage) | (raxbatheage < 0)) & !mi(raxbatheage) & !mi(radage)

***help bathing began final year***
*wave 3 respondent help bathing began final year
missing_w3 raxbathehlp EiADLC2 if inw`wv'xt==1, result(raxbatheb1y)
replace raxbatheb1y = .d if EiADLC2==96
replace raxbatheb1y = 0 if raxbathehlp==0 & inw`wv'xt==1
replace raxbatheb1y = 0 if inlist(EiADLC2,3,4)
replace raxbatheb1y = 1 if inlist(EiADLC2,1,2)

drop batheyrs


***someone helped eat***
*wave 3 respondent someone helped eat
missing_w3 EiADLD if inw`wv'xt==1, result(raxeathlp)
replace raxeathlp = .d if EiADLD==3
replace raxeathlp = 0 if EiADLD==2
replace raxeathlp = 1 if EiADLD==1

***age needed help eating***
*wave 3 respondent age needed help eating
gen eatyrs = .
replace eatyrs = (EiADLD2M/12) if inlist(EiADLD2,2,3) & inrange(EiADLD2M,1,24)

missing_w3 raxeathlp EiADLD2 EiADLD2M EiADLD2Y if inw`wv'xt==1, result(raxeatage)
replace raxeatage = .d if EiADLD2==96
replace raxeatage = .h if raxeathlp==0 & inw`wv'xt==1
replace raxeatage = radage if EiADLD2==1
replace raxeatage = floor(radage - eatyrs) if !mi(radage) & !mi(eatyrs) & inlist(EiADLD2,2,3)
replace raxeatage = radage - EiADLD2Y if inrange(EiADLD2Y,1,100) & EiADLD2==4
replace raxeatage = .i if ((raxeatage > radage) | (raxeatage < 0)) & !mi(raxeatage) & !mi(radage)

***help eating began final year***
*wave 3 respondent help eating began final year
missing_w3 raxeathlp EiADLD2 if inw`wv'xt==1, result(raxeatb1y)
replace raxeatb1y = .d if EiADLD2==96
replace raxeatb1y = 0 if raxeathlp==0 & inw`wv'xt==1
replace raxeatb1y = 0 if inlist(EiADLD2,3,4)
replace raxeatb1y = 1 if inlist(EiADLD2,1,2)

drop eatyrs


***someone helped bed***
*wave 3 respondent someone helped bed
missing_w3 EiADLE if inw`wv'xt==1, result(raxbedhlp)
replace raxbedhlp = .d if EiADLE==3
replace raxbedhlp = 0 if EiADLE==2
replace raxbedhlp = 1 if EiADLE==1

***age needed help w/ bed***
*wave 3 respondent age needed help w/ bed
gen bedyrs = .
replace bedyrs = (EiADLE2M/12) if inlist(EiADLE2,2,3) & inrange(EiADLE2M,1,24)

missing_w3 raxbedhlp EiADLE2 EiADLE2M EiADLE2Y if inw`wv'xt==1, result(raxbedage)
replace raxbedage = .d if EiADLE2==96
replace raxbedage = .h if raxbedhlp==0 & inw`wv'xt==1
replace raxbedage = radage if EiADLE2==1
replace raxbedage = floor(radage - bedyrs) if !mi(radage) & !mi(bedyrs) & inlist(EiADLE2,2,3)
replace raxbedage = radage - EiADLE2Y if inrange(EiADLE2Y,1,100) & EiADLE2==4
replace raxbedage = .i if ((raxbedage > radage) | (raxbedage < 0)) & !mi(raxbedage) & !mi(radage)

***help w/ bed began final year***
*wave 3 respondent help w/ bed began final year
missing_w3 raxbedhlp EiADLE2 if inw`wv'xt==1, result(raxbedb1y)
replace raxbedb1y = .d if EiADLE2==96
replace raxbedb1y = 0 if raxbedhlp==0 & inw`wv'xt==1
replace raxbedb1y = 0 if inlist(EiADLE2,3,4)
replace raxbedb1y = 1 if inlist(EiADLE2,1,2)

drop bedyrs


***someone helped toilet***
*wave 3 respondent someone helped toilet
missing_w3 EiADLF if inw`wv'xt==1, result(raxtoilethlp)
replace raxtoilethlp = .d if EiADLF==3
replace raxtoilethlp = 0 if EiADLF==2
replace raxtoilethlp = 1 if EiADLF==1

***age needed help w/ toilet***
*wave 3 respondent age needed help w/ toilet
gen toiletyrs = .
replace toiletyrs = (EiADLF2M/12) if inlist(EiADLF2,2,3) & inrange(EiADLF2M,1,24)

missing_w3 raxtoilethlp EiADLF2 EiADLF2M EiADLF2Y if inw`wv'xt==1, result(raxtoiletage)
replace raxtoiletage = .d if EiADLF2==96
replace raxtoiletage = .h if raxtoilethlp==0 & inw`wv'xt==1
replace raxtoiletage = radage if EiADLF2==1
replace raxtoiletage = floor(radage - toiletyrs) if !mi(radage) & !mi(toiletyrs) & inlist(EiADLF2,2,3)
replace raxtoiletage = radage - EiADLF2Y if inrange(EiADLF2Y,1,100) & EiADLF2==4
replace raxtoiletage = .i if ((raxtoiletage > radage) | (raxtoiletage < 0)) & !mi(raxtoiletage) & !mi(radage)

***help w/ toilet began final year***
*wave 3 respondent help w/ toilet began final year
missing_w3 raxtoilethlp EiADLF2 if inw`wv'xt==1, result(raxtoiletb1y)
replace raxtoiletb1y = .d if EiADLF2==96
replace raxtoiletb1y = 0 if raxtoilethlp==0 & inw`wv'xt==1
replace raxtoiletb1y = 0 if inlist(EiADLF2,3,4)
replace raxtoiletb1y = 1 if inlist(EiADLF2,1,2)

drop toiletyrs


***someone helped any adl***
*wave 3 respondent someone helped any adl
missing_w3 raxdresshlp raxwalkhlp raxbathehlp raxeathlp raxbedhlp raxtoilethlp if inw`wv'xt==1, result(raxracany)
replace raxracany = 0 if (raxdresshlp==0 | raxwalkhlp==0 | raxbathehlp==0 | raxeathlp==0 | ///
												raxbedhlp==0 | raxtoilethlp==0) & inw`wv'xt==1
replace raxracany = 1 if (raxdresshlp==1 | raxwalkhlp==1 | raxbathehlp==1 | raxeathlp==1 | ///
												raxbedhlp==1 | raxtoilethlp==1) & inw`wv'xt==1

***help w/ any adl began final year***
*wave 3 respondent help w/ any adl began final year
missing_w3 raxdressb1y raxwalkb1y raxbatheb1y raxeatb1y raxbedb1y raxtoiletb1y if inw`wv'xt==1, result(raxracareb)
replace raxracareb = 0 if raxracany==0 & inw`wv'xt==1
replace raxracareb = 0 if (raxdressb1y==0 | raxwalkb1y==0 | raxbatheb1y==0 | raxeatb1y==0 | ///
													 raxbedb1y==0 | raxtoiletb1y==0) & inw`wv'xt==1
replace raxracareb = 1 if (raxdressb1y==1 | raxwalkb1y==1 | raxbatheb1y==1 | raxeatb1y==1 | ///
													 raxbedb1y==1 | raxtoiletb1y==1) & inw`wv'xt==1


***someone helped hot meals***
*wave 3 respondent someone helped hot meals
missing_w3 EiADLG if inw`wv'xt==1, result(raxmealhlp)
replace raxmealhlp = .d if EiADLG==3
replace raxmealhlp = 0 if EiADLG==2
replace raxmealhlp = 1 if EiADLG==1

***age needed help hot meals***
*wave 3 respondent age needed help hot meals
gen mealyrs = .
replace mealyrs = (EiADLG2M/12) if inlist(EiADLG2,2,3) & inrange(EiADLG2M,1,24)

missing_w3 raxmealhlp EiADLG2 EiADLG2M EiADLG2Y if inw`wv'xt==1, result(raxmealage)
replace raxmealage = .d if EiADLG2==96
replace raxmealage = .h if raxmealhlp==0 & inw`wv'xt==1
replace raxmealage = radage if EiADLG2==1
replace raxmealage = floor(radage - mealyrs) if !mi(radage) & !mi(mealyrs) & inlist(EiADLG2,2,3)
replace raxmealage = radage - EiADLG2Y if inrange(EiADLG2Y,1,100) & EiADLG2==4
replace raxmealage = .i if ((raxmealage > radage) | (raxmealage < 0)) & !mi(raxmealage) & !mi(radage)

***help w/ hot meals began final year***
missing_w3 raxmealhlp EiADLG2 if inw`wv'xt==1, result(raxmealb1y)
replace raxmealb1y = .d if EiADLG2==96
replace raxmealb1y = 0 if raxmealhlp==0 & inw`wv'xt==1
replace raxmealb1y = 0 if inlist(EiADLG2,3,4)
replace raxmealb1y = 1 if inlist(EiADLG2,1,2)

drop mealyrs


***someone helped grocery shopping***
*wave 3 respondent someone helped grocery shopping
missing_w3 EiADLH if inw`wv'xt==1, result(raxshophlp)
replace raxshophlp = .d if EiADLH==3
replace raxshophlp = 0 if EiADLH==2
replace raxshophlp = 1 if EiADLH==1

***age needed help grocery shopping***
*wave 3 respondent age needed help grocery shopping
gen shopyrs = .
replace shopyrs = (EiADLH2M/12) if inlist(EiADLH2,2,3) & inrange(EiADLH2M,1,24)

missing_w3 raxshophlp EiADLH2 EiADLH2M EiADLH2Y if inw`wv'xt==1, result(raxshopage)
replace raxshopage = .d if EiADLH2==96
replace raxshopage = .h if raxshophlp==0 & inw`wv'xt==1
replace raxshopage = radage if EiADLH2==1
replace raxshopage = floor(radage - shopyrs) if !mi(radage) & !mi(shopyrs) & inlist(EiADLH2,2,3)
replace raxshopage = radage - EiADLH2Y if inrange(EiADLH2Y,1,100) & EiADLH2==4
replace raxshopage = .i if ((raxshopage > radage) | (raxshopage < 0)) & !mi(raxshopage) & !mi(radage)

***help w/ grocery shopping began final year***
*wave 3 respondent help w/ grocery shopping began final year
missing_w3 raxshophlp EiADLH2 if inw`wv'xt==1, result(raxshopb1y)
replace raxshopb1y = .d if EiADLH2==96
replace raxshopb1y = 0 if raxshophlp==0 & inw`wv'xt==1
replace raxshopb1y = 0 if inlist(EiADLH2,3,4)
replace raxshopb1y = 1 if inlist(EiADLH2,1,2)

drop shopyrs


***someone helped phone***
*wave 3 respondent someone helped phone
missing_w3 EiADLI if inw`wv'xt==1, result(raxphonehlp)
replace raxphonehlp = .d if EiADLI==3
replace raxphonehlp = 0 if EiADLI==2
replace raxphonehlp = 1 if EiADLI==1

***age needed help phone***
*wave 3 respondent age needed help phone
gen phoneyrs = .
replace phoneyrs = (EiADLI2M/12) if inlist(EiADLI2,2,3) & inrange(EiADLI2M,1,24)

missing_w3 raxphonehlp EiADLI2 EiADLI2M EiADLI2Y if inw`wv'xt==1, result(raxphoneage)
replace raxphoneage = .d if EiADLI2==96
replace raxphoneage = .h if raxphonehlp==0 & inw`wv'xt==1
replace raxphoneage = radage if EiADLI2==1
replace raxphoneage = floor(radage - phoneyrs) if !mi(radage) & !mi(phoneyrs) & inlist(EiADLI2,2,3)
replace raxphoneage = radage - EiADLI2Y if inrange(EiADLI2Y,1,100) & EiADLI2==4
replace raxphoneage = .i if ((raxphoneage > radage) | (raxphoneage < 0)) & !mi(raxphoneage) & !mi(radage)

***help w/ phone began final year***
*wave 3 respondent help w/ phone began final year
missing_w3 raxphonehlp EiADLI2 if inw`wv'xt==1, result(raxphoneb1y)
replace raxphoneb1y = .d if EiADLI2==96
replace raxphoneb1y = 0 if raxphonehlp==0 & inw`wv'xt==1
replace raxphoneb1y = 0 if inlist(EiADLI2,3,4)
replace raxphoneb1y = 1 if inlist(EiADLI2,1,2)

drop phoneyrs


***someone helped meds***
*wave 3 respondent someone helped meds
missing_w3 EiADLJ if inw`wv'xt==1, result(raxmedhlp)
replace raxmedhlp = .d if EiADLJ==3
replace raxmedhlp = 0 if EiADLJ==2
replace raxmedhlp = 1 if EiADLJ==1

***age needed help meds***
*wave 3 respondent age needed help meds
gen medyrs = .
replace medyrs = (EiADLJ2M/12) if inlist(EiADLJ2,2,3) & inrange(EiADLJ2M,1,24)

missing_w3 raxmedhlp EiADLJ2 EiADLJ2M EiADLJ2Y if inw`wv'xt==1, result(raxmedage)
replace raxmedage = .d if EiADLJ2==96
replace raxmedage = .h if raxmedhlp==0 & inw`wv'xt==1
replace raxmedage = radage if EiADLJ2==1
replace raxmedage = floor(radage - medyrs) if !mi(radage) & !mi(medyrs) & inlist(EiADLJ2,2,3)
replace raxmedage = radage - EiADLJ2Y if inrange(EiADLJ2Y,1,100) & EiADLJ2==4
replace raxmedage = .i if ((raxmedage > radage) | (raxmedage < 0)) & !mi(raxmedage) & !mi(radage)

***help w/ meds began final year***
*wave 3 respondent help w/ meds began final year
missing_w3 raxmedhlp EiADLJ2 if inw`wv'xt==1, result(raxmedb1y)
replace raxmedb1y = .d if EiADLJ2==96
replace raxmedb1y = 0 if raxmedhlp==0 & inw`wv'xt==1
replace raxmedb1y = 0 if inlist(EiADLJ2,3,4)
replace raxmedb1y = 1 if inlist(EiADLJ2,1,2)

drop medyrs


***someone helped any iadl***
*wave 3 respondent someone helped any iadl
missing_w3 raxmealhlp raxshophlp raxphonehlp raxmedhlp if inw`wv'xt==1, result(raxricany)
replace raxricany = 0 if (raxmealhlp==0 | raxshophlp==0 | raxphonehlp==0 | raxmedhlp==0) & inw`wv'xt==1
replace raxricany = 1 if (raxmealhlp==1 | raxshophlp==1 | raxphonehlp==1 | raxmedhlp==1) & inw`wv'xt==1

***help w/ any iadl began final year***
*wave 3 respondent help w/ any iadl began final year
missing_w3 raxmealb1y raxshopb1y raxphoneb1y raxmedb1y if inw`wv'xt==1, result(raxricareb)
replace raxricareb = 0 if raxricany==0 & inw`wv'xt==1
replace raxricareb = 0 if (raxmealb1y==0 | raxshopb1y==0 | raxphoneb1y==0 | raxmedb1y==0) & inw`wv'xt==1
replace raxricareb = 1 if (raxmealb1y==1 | raxshopb1y==1 | raxphoneb1y==1 | raxmedb1y==1) & inw`wv'xt==1


***someone helped adl or iadl***
*wave 3 respondent someone helped adl or iadl
missing_w3 raxracany raxricany if inw`wv'xt==1, result(raxrcany)
replace raxrcany = 0 if (raxracany==0 | raxricany==0) & inw`wv'xt==1
replace raxrcany = 1 if (raxracany==1 | raxricany==1) & inw`wv'xt==1

***help w/ any adl or iadl began final year***
*wave 3 respondent help w/ any adl or iadl began final year
missing_w3 raxracareb raxricareb if inw`wv'xt==1, result(raxrcareb)
replace raxrcareb = 0 if raxrcany==0 & inw`wv'xt==1
replace raxrcareb = 0 if (raxracareb==0 | raxricareb==0) & inw`wv'xt==1
replace raxrcareb = 1 if (raxracareb==1 | raxricareb==1) & inw`wv'xt==1


***spouse helped r adl/iadl***
*wave 3 respondent spouse helped r adl/iadl
missing_w3 EiRRel EiWHlp1S EiWHlp2S if inw`wv'xt==1, result(raxrscare)
replace raxrscare = .h if raxrcany==0 & inw`wv'xt==1
replace raxrscare = 0 if EiWHlp2S==0 | ///
												EiWHlp1S==0 | (EiWHlp1S==1 & inrange(EiRRel,3,22))
replace raxrscare = 1 if EiWHlp2S==1 | (EiWHlp1S==1 & inlist(EiRRel,1,2))

***child helped r adl/iadl***
*wave 3 respondent child helped r adl/iadl
missing_w3 EiRRel EiWHlp1S EiWHlp4S EiWHlp5S EiWHlp6S EiWHlp7S EiWHlp10S EiWHlp11S if inw`wv'xt==1, result(raxrccare)
replace raxrccare = .h if raxrcany==0 & inw`wv'xt==1
replace raxrccare = 0 if EiWHlp4S==0 | EiWHlp5S==0 | EiWHlp6S==0 | EiWHlp7S==0 | EiWHlp10S==0 | EiWHlp11S==0 | ///
												 EiWHlp1S==0 | (EiWHlp1S==1 & (inrange(EiRRel,8,18) | inlist(EiRRel,1,2,19,20,21,22)))
replace raxrccare = 1 if EiWHlp4S==1 | EiWHlp5S==1 | EiWHlp6S==1 | EiWHlp7S==1 | EiWHlp10S==1 | EiWHlp11S==1 | ///
												 (EiWHlp1S==1 & inlist(EiRRel,3,4,5,6,7,19))

***relative helped r adl/iadl***
*wave 3 respondent relative helped r adl/iadl
missing_w3 EiRRel EiWHlp1S EiWHlp3S EiWHlp8S EiWHlp9S if inw`wv'xt==1, result(raxrrcare)
replace raxrrcare = .h if raxrcany==0 & inw`wv'xt==1
replace raxrrcare = 0 if EiWHlp3S==0 | EiWHlp8S==0 | EiWHlp9S==0 | ///
												EiWHlp1S==0 | (EiWHlp1S==1 & (inrange(EiRRel,1,7) | inlist(EiRRel,19,22)))
replace raxrrcare = 1 if EiWHlp3S==1 | EiWHlp8S==1 | EiWHlp9S==1 | ///
												(EiWHlp1S==1 & (inrange(EiRRel,8,18) | inlist(EiRRel,20,21)))

***other helped r adl/iadl***
*wave 3 respondent other helped r adl/iadl
missing_w3 EiRRel EiWHlp1S EiWHlp16S EiWHlp17S if inw`wv'xt==1, result(raxrfcare)
replace raxrfcare = .h if raxrcany==0 & inw`wv'xt==1
replace raxrfcare = 0 if EiWHlp16S==0 | EiWHlp17S==0 | ///
												EiWHlp1S==0 | (EiWHlp1S==1 & inrange(EiRRel,1,21))
replace raxrfcare = 1 if EiWHlp16S==1 | EiWHlp17S==1 | ///
												(EiWHlp1S==1 & EiRRel==22)

***received any informal care***
*wave 3 respondent received any informal care
missing_w3 raxrscare raxrccare raxrrcare raxrfcare if inw`wv'xt==1, result(raxrcaany)
replace raxrcaany = 0 if raxrcany==0 & inw`wv'xt==1
replace raxrcaany = 0 if (raxrscare==0 | raxrccare==0 | raxrrcare==0 | raxrfcare==0) & inw`wv'xt==1
replace raxrcaany = 1 if (raxrscare==1 | raxrccare==1 | raxrrcare==1 | raxrfcare==1) & inw`wv'xt==1

***pro helped r adl/iadl***
*wave 3 respondent pro helped r adl/iadl
missing_w3 EiWHlp14S if inw`wv'xt==1, result(raxrpfcare)
replace raxrpfcare = .h if raxrcany==0 & inw`wv'xt==1
replace raxrpfcare = 0 if EiWHlp14S==0 
replace raxrpfcare = 1 if EiWHlp14S==1 

***unpaid pro helped r adl/iadl***
*wave 3 respondent unpaid pro helped r adl/iadl
missing_w3 EiWHlp13S EiWHlp15S if inw`wv'xt==1, result(raxrufcare)
replace raxrufcare = .h if raxrcany==0 & inw`wv'xt==1
replace raxrufcare = 0 if EiWHlp13S==0 | EiWHlp15S==0
replace raxrufcare = 1 if EiWHlp13S==1 | EiWHlp15S==1

***received any formal care***
*wave 3 respondent received any formal care
missing_w3 raxrpfcare raxrufcare if inw`wv'xt==1, result(raxrfaany)
replace raxrfaany = 0 if raxrcany==0 & inw`wv'xt==1
replace raxrfaany = 0 if (raxrpfcare==0 | raxrufcare==0) & inw`wv'xt==1
replace raxrfaany = 1 if (raxrpfcare==1 | raxrufcare==1) & inw`wv'xt==1




***drop ELSA wave 3 core file raw variables***
drop `funxt_w3_exit'



******************************************************************************************


*set wave number
local wv=4
local pre_wv=3

local funxt_w4_exit EiADLA EiADLB EiADLC EiADLD EiADLE EiADLF EiADLG EiADLH EiADLI EiADLJ ///
										EiADLA2 EiADLA2M EiADLA2Y EiADLB2 EiADLB2M EiADLB2Y ///
										EiADLC2 EiADLC2M EiADLC2Y EiADLD2 EiADLD2M EiADLD2Y ///
										EiADLE2 EiADLE2M EiADLE2Y EiADLF2 EiADLF2M EiADLF2Y ///
										EiADLG2 EiADLG2M EiADLG2Y EiADLH2 EiADLH2M EiADLH2Y ///
										EiADLI2 EiADLI2M EiADLI2Y EiADLJ2 EiADLJ2M EiADLJ2Y ///
										EiWHlp1 EiWHlp2 EiWHlp3 EiWHlp4 EiWHlp5 EiWHlp6 EiWHlp7 EiWHlp8 ///
										EiWHlp9 EiWHlp10 EiWHlp11 EiWHlp95  
merge 1:1 idauniq using "$w4_xt", keepusing(`funxt_w4_exit') nogen




***someone helped dress***
*wave 4 respondent someone helped dress
missing_w4 EiADLA if inw`wv'xt==1, result(raxdresshlp)
replace raxdresshlp = .d if EiADLA==3
replace raxdresshlp = 0 if EiADLA==2
replace raxdresshlp = 1 if EiADLA==1

***age needed help dressing***
*wave 4 respondent age needed help dressing
gen dressyrs = .
replace dressyrs = (EiADLA2M/12) if inlist(EiADLA2,2,3) & inrange(EiADLA2M,1,24)

missing_w4 raxdresshlp EiADLA2 EiADLA2M EiADLA2Y if inw`wv'xt==1, result(raxdressage)
replace raxdressage = .d if EiADLA2==96
replace raxdressage = .h if raxdresshlp==0 & inw`wv'xt==1
replace raxdressage = radage if EiADLA2==1
replace raxdressage = floor(radage - dressyrs) if !mi(radage) & !mi(dressyrs) & inlist(EiADLA2,2,3)
replace raxdressage = radage - EiADLA2Y if inrange(EiADLA2Y,1,100) & EiADLA2==4
replace raxdressage = .i if ((raxdressage > radage) | (raxdressage < 0)) & !mi(raxdressage) & !mi(radage)

***help dressing began final year***
*wave 4 respondent help dressing began final year
missing_w4 raxdresshlp EiADLA2 if inw`wv'xt==1, result(raxdressb1y)
replace raxdressb1y = .d if EiADLA2==96
replace raxdressb1y = 0 if raxdresshlp==0 & inw`wv'xt==1
replace raxdressb1y = 0 if inlist(EiADLA2,3,4)
replace raxdressb1y = 1 if inlist(EiADLA2,1,2)

drop dressyrs


***someone helped walk***
*wave 4 respondent someone helped walk
missing_w4 EiADLB if inw`wv'xt==1, result(raxwalkhlp)
replace raxwalkhlp = .d if EiADLB==3
replace raxwalkhlp = 0 if EiADLB==2
replace raxwalkhlp = 1 if EiADLB==1

***age needed help walking***
*wave 4 respondent age needed help walking
gen walkyrs = .
replace walkyrs = (EiADLB2M/12) if inlist(EiADLB2,2,3) & inrange(EiADLB2M,1,24)

missing_w4 raxwalkhlp EiADLB2 EiADLB2M EiADLB2Y if inw`wv'xt==1, result(raxwalkage)
replace raxwalkage = .d if EiADLB2==96
replace raxwalkage = .h if raxwalkhlp==0 & inw`wv'xt==1
replace raxwalkage = radage if EiADLB2==1
replace raxwalkage = floor(radage - walkyrs) if !mi(radage) & !mi(walkyrs) & inlist(EiADLB2,2,3)
replace raxwalkage = radage - EiADLB2Y if inrange(EiADLB2Y,1,100) & EiADLB2==4
replace raxwalkage = .i if ((raxwalkage > radage) | (raxwalkage < 0)) & !mi(raxwalkage) & !mi(radage)

***help walking began final year***
*wave 4 respondent help walking began final year
missing_w4 raxwalkhlp EiADLB2 if inw`wv'xt==1, result(raxwalkb1y)
replace raxwalkb1y = .d if EiADLB2==96
replace raxwalkb1y = 0 if raxwalkhlp==0 & inw`wv'xt==1
replace raxwalkb1y = 0 if inlist(EiADLB2,3,4)
replace raxwalkb1y = 1 if inlist(EiADLB2,1,2)

drop walkyrs


***someone helped bathe***
*wave 4 respondent someone helped bathe
missing_w4 EiADLC if inw`wv'xt==1, result(raxbathehlp)
replace raxbathehlp = .d if EiADLC==3
replace raxbathehlp = 0 if EiADLC==2
replace raxbathehlp = 1 if EiADLC==1

***age needed help bathing***
*wave 4 respondent age needed help bathing
gen batheyrs = .
replace batheyrs = (EiADLC2M/12) if inlist(EiADLC2,2,3) & inrange(EiADLC2M,1,24)

missing_w4 raxbathehlp EiADLC2 EiADLC2M EiADLC2Y if inw`wv'xt==1, result(raxbatheage)
replace raxbatheage = .d if EiADLC2==96
replace raxbatheage = .h if raxbathehlp==0 & inw`wv'xt==1
replace raxbatheage = radage if EiADLC2==1
replace raxbatheage = floor(radage - batheyrs) if !mi(radage) & !mi(batheyrs) & inlist(EiADLC2,2,3)
replace raxbatheage = radage - EiADLC2Y if inrange(EiADLC2Y,1,100) & EiADLC2==4
replace raxbatheage = .i if ((raxbatheage > radage) | (raxbatheage < 0)) & !mi(raxbatheage) & !mi(radage)

***help bathing began final year***
*wave 4 respondent help bathing began final year
missing_w4 raxbathehlp EiADLC2 if inw`wv'xt==1, result(raxbatheb1y)
replace raxbatheb1y = .d if EiADLC2==96
replace raxbatheb1y = 0 if raxbathehlp==0 & inw`wv'xt==1
replace raxbatheb1y = 0 if inlist(EiADLC2,3,4)
replace raxbatheb1y = 1 if inlist(EiADLC2,1,2)

drop batheyrs


***someone helped eat***
*wave 4 respondent someone helped eat
missing_w4 EiADLD if inw`wv'xt==1, result(raxeathlp)
replace raxeathlp = .d if EiADLD==3
replace raxeathlp = 0 if EiADLD==2
replace raxeathlp = 1 if EiADLD==1

***age needed help eating***
*wave 4 respondent age needed help eating
gen eatyrs = .
replace eatyrs = (EiADLD2M/12) if inlist(EiADLD2,2,3) & inrange(EiADLD2M,1,24)

missing_w4 raxeathlp EiADLD2 EiADLD2M EiADLD2Y if inw`wv'xt==1, result(raxeatage)
replace raxeatage = .d if EiADLD2==96
replace raxeatage = .h if raxeathlp==0 & inw`wv'xt==1
replace raxeatage = radage if EiADLD2==1
replace raxeatage = floor(radage - eatyrs) if !mi(radage) & !mi(eatyrs) & inlist(EiADLD2,2,3)
replace raxeatage = radage - EiADLD2Y if inrange(EiADLD2Y,1,100) & EiADLD2==4
replace raxeatage = .i if ((raxeatage > radage) | (raxeatage < 0)) & !mi(raxeatage) & !mi(radage)

***help eating began final year***
*wave 4 respondent help eating began final year
missing_w4 raxeathlp EiADLD2 if inw`wv'xt==1, result(raxeatb1y)
replace raxeatb1y = .d if EiADLD2==96
replace raxeatb1y = 0 if raxeathlp==0 & inw`wv'xt==1
replace raxeatb1y = 0 if inlist(EiADLD2,3,4)
replace raxeatb1y = 1 if inlist(EiADLD2,1,2)

drop eatyrs


***someone helped bed***
*wave 4 respondent someone helped bed
missing_w4 EiADLE if inw`wv'xt==1, result(raxbedhlp)
replace raxbedhlp = .d if EiADLE==3
replace raxbedhlp = 0 if EiADLE==2
replace raxbedhlp = 1 if EiADLE==1

***age needed help w/ bed***
*wave 4 respondent age needed help w/ bed
gen bedyrs = .
replace bedyrs = (EiADLE2M/12) if inlist(EiADLE2,2,3) & inrange(EiADLE2M,1,24)

missing_w4 raxbedhlp EiADLE2 EiADLE2M EiADLE2Y if inw`wv'xt==1, result(raxbedage)
replace raxbedage = .d if EiADLE2==96
replace raxbedage = .h if raxbedhlp==0 & inw`wv'xt==1
replace raxbedage = radage if EiADLE2==1
replace raxbedage = floor(radage - bedyrs) if !mi(radage) & !mi(bedyrs) & inlist(EiADLE2,2,3)
replace raxbedage = radage - EiADLE2Y if inrange(EiADLE2Y,1,100) & EiADLE2==4
replace raxbedage = .i if ((raxbedage > radage) | (raxbedage < 0)) & !mi(raxbedage) & !mi(radage)

***help w/ bed began final year***
*wave 4 respondent help w/ bed began final year
missing_w4 raxbedhlp EiADLE2 if inw`wv'xt==1, result(raxbedb1y)
replace raxbedb1y = .d if EiADLE2==96
replace raxbedb1y = 0 if raxbedhlp==0 & inw`wv'xt==1
replace raxbedb1y = 0 if inlist(EiADLE2,3,4)
replace raxbedb1y = 1 if inlist(EiADLE2,1,2)

drop bedyrs


***someone helped toilet***
*wave 4 respondent someone helped toilet
missing_w4 EiADLF if inw`wv'xt==1, result(raxtoilethlp)
replace raxtoilethlp = .d if EiADLF==3
replace raxtoilethlp = 0 if EiADLF==2
replace raxtoilethlp = 1 if EiADLF==1

***age needed help w/ toilet***
*wave 4 respondent age needed help w/ toilet
gen toiletyrs = .
replace toiletyrs = (EiADLF2M/12) if inlist(EiADLF2,2,3) & inrange(EiADLF2M,1,24)

missing_w4 raxtoilethlp EiADLF2 EiADLF2M EiADLF2Y if inw`wv'xt==1, result(raxtoiletage)
replace raxtoiletage = .d if EiADLF2==96
replace raxtoiletage = .h if raxtoilethlp==0 & inw`wv'xt==1
replace raxtoiletage = radage if EiADLF2==1
replace raxtoiletage = floor(radage - toiletyrs) if !mi(radage) & !mi(toiletyrs) & inlist(EiADLF2,2,3)
replace raxtoiletage = radage - EiADLF2Y if inrange(EiADLF2Y,1,100) & EiADLF2==4
replace raxtoiletage = .i if ((raxtoiletage > radage) | (raxtoiletage < 0)) & !mi(raxtoiletage) & !mi(radage)

***help w/ toilet began final year***
*wave 4 respondent help w/ toilet began final year
missing_w4 raxtoilethlp EiADLF2 if inw`wv'xt==1, result(raxtoiletb1y)
replace raxtoiletb1y = .d if EiADLF2==96
replace raxtoiletb1y = 0 if raxtoilethlp==0 & inw`wv'xt==1
replace raxtoiletb1y = 0 if inlist(EiADLF2,3,4)
replace raxtoiletb1y = 1 if inlist(EiADLF2,1,2)

drop toiletyrs


***someone helped any adl***
*wave 4 respondent someone helped any adl
missing_w4 raxdresshlp raxwalkhlp raxbathehlp raxeathlp raxbedhlp raxtoilethlp if inw`wv'xt==1, result(raxracany)
replace raxracany = 0 if (raxdresshlp==0 | raxwalkhlp==0 | raxbathehlp==0 | raxeathlp==0 | ///
												raxbedhlp==0 | raxtoilethlp==0) & inw`wv'xt==1
replace raxracany = 1 if (raxdresshlp==1 | raxwalkhlp==1 | raxbathehlp==1 | raxeathlp==1 | ///
												raxbedhlp==1 | raxtoilethlp==1) & inw`wv'xt==1

***help w/ any adl began final year***
*wave 4 respondent help w/ any adl began final year
missing_w4 raxdressb1y raxwalkb1y raxbatheb1y raxeatb1y raxbedb1y raxtoiletb1y if inw`wv'xt==1, result(raxracareb)
replace raxracareb = 0 if raxracany==0 & inw`wv'xt==1
replace raxracareb = 0 if (raxdressb1y==0 | raxwalkb1y==0 | raxbatheb1y==0 | raxeatb1y==0 | ///
													 raxbedb1y==0 | raxtoiletb1y==0) & inw`wv'xt==1
replace raxracareb = 1 if (raxdressb1y==1 | raxwalkb1y==1 | raxbatheb1y==1 | raxeatb1y==1 | ///
													 raxbedb1y==1 | raxtoiletb1y==1) & inw`wv'xt==1


***someone helped hot meals***
*wave 4 respondent someone helped hot meals
missing_w4 EiADLG if inw`wv'xt==1, result(raxmealhlp)
replace raxmealhlp = .d if EiADLG==3
replace raxmealhlp = 0 if EiADLG==2
replace raxmealhlp = 1 if EiADLG==1

***age needed help hot meals***
*wave 4 respondent age needed help hot meals
gen mealyrs = .
replace mealyrs = (EiADLG2M/12) if inlist(EiADLG2,2,3) & inrange(EiADLG2M,1,24)

missing_w4 raxmealhlp EiADLG2 EiADLG2M EiADLG2Y if inw`wv'xt==1, result(raxmealage)
replace raxmealage = .d if EiADLG2==96
replace raxmealage = .h if raxmealhlp==0 & inw`wv'xt==1
replace raxmealage = radage if EiADLG2==1
replace raxmealage = floor(radage - mealyrs) if !mi(radage) & !mi(mealyrs) & inlist(EiADLG2,2,3)
replace raxmealage = radage - EiADLG2Y if inrange(EiADLG2Y,1,100) & EiADLG2==4
replace raxmealage = .i if ((raxmealage > radage) | (raxmealage < 0)) & !mi(raxmealage) & !mi(radage)

***help w/ hot meals began final year***
missing_w4 raxmealhlp EiADLG2 if inw`wv'xt==1, result(raxmealb1y)
replace raxmealb1y = .d if EiADLG2==96
replace raxmealb1y = 0 if raxmealhlp==0 & inw`wv'xt==1
replace raxmealb1y = 0 if inlist(EiADLG2,3,4)
replace raxmealb1y = 1 if inlist(EiADLG2,1,2)

drop mealyrs


***someone helped grocery shopping***
*wave 4 respondent someone helped grocery shopping
missing_w4 EiADLH if inw`wv'xt==1, result(raxshophlp)
replace raxshophlp = .d if EiADLH==3
replace raxshophlp = 0 if EiADLH==2
replace raxshophlp = 1 if EiADLH==1

***age needed help grocery shopping***
*wave 4 respondent age needed help grocery shopping
gen shopyrs = .
replace shopyrs = (EiADLH2M/12) if inlist(EiADLH2,2,3) & inrange(EiADLH2M,1,24)

missing_w4 raxshophlp EiADLH2 EiADLH2M EiADLH2Y if inw`wv'xt==1, result(raxshopage)
replace raxshopage = .d if EiADLH2==96
replace raxshopage = .h if raxshophlp==0 & inw`wv'xt==1
replace raxshopage = radage if EiADLH2==1
replace raxshopage = floor(radage - shopyrs) if !mi(radage) & !mi(shopyrs) & inlist(EiADLH2,2,3)
replace raxshopage = radage - EiADLH2Y if inrange(EiADLH2Y,1,100) & EiADLH2==4
replace raxshopage = .i if ((raxshopage > radage) | (raxshopage < 0)) & !mi(raxshopage) & !mi(radage)

***help w/ grocery shopping began final year***
*wave 4 respondent help w/ grocery shopping began final year
missing_w4 raxshophlp EiADLH2 if inw`wv'xt==1, result(raxshopb1y)
replace raxshopb1y = .d if EiADLH2==96
replace raxshopb1y = 0 if raxshophlp==0 & inw`wv'xt==1
replace raxshopb1y = 0 if inlist(EiADLH2,3,4)
replace raxshopb1y = 1 if inlist(EiADLH2,1,2)

drop shopyrs


***someone helped phone***
*wave 4 respondent someone helped phone
missing_w4 EiADLI if inw`wv'xt==1, result(raxphonehlp)
replace raxphonehlp = .d if EiADLI==3
replace raxphonehlp = 0 if EiADLI==2
replace raxphonehlp = 1 if EiADLI==1

***age needed help phone***
*wave 4 respondent age needed help phone
gen phoneyrs = .
replace phoneyrs = (EiADLI2M/12) if inlist(EiADLI2,2,3) & inrange(EiADLI2M,1,24)

missing_w4 raxphonehlp EiADLI2 EiADLI2M EiADLI2Y if inw`wv'xt==1, result(raxphoneage)
replace raxphoneage = .d if EiADLI2==96
replace raxphoneage = .h if raxphonehlp==0 & inw`wv'xt==1
replace raxphoneage = radage if EiADLI2==1
replace raxphoneage = floor(radage - phoneyrs) if !mi(radage) & !mi(phoneyrs) & inlist(EiADLI2,2,3)
replace raxphoneage = radage - EiADLI2Y if inrange(EiADLI2Y,1,100) & EiADLI2==4
replace raxphoneage = .i if ((raxphoneage > radage) | (raxphoneage < 0)) & !mi(raxphoneage) & !mi(radage)

***help w/ phone began final year***
*wave 4 respondent help w/ phone began final year
missing_w4 raxphonehlp EiADLI2 if inw`wv'xt==1, result(raxphoneb1y)
replace raxphoneb1y = .d if EiADLI2==96
replace raxphoneb1y = 0 if raxphonehlp==0 & inw`wv'xt==1
replace raxphoneb1y = 0 if inlist(EiADLI2,3,4)
replace raxphoneb1y = 1 if inlist(EiADLI2,1,2)

drop phoneyrs


***someone helped meds***
*wave 4 respondent someone helped meds
missing_w4 EiADLJ if inw`wv'xt==1, result(raxmedhlp)
replace raxmedhlp = .d if EiADLJ==3
replace raxmedhlp = 0 if EiADLJ==2
replace raxmedhlp = 1 if EiADLJ==1

***age needed help meds***
*wave 4 respondent age needed help meds
gen medyrs = .
replace medyrs = (EiADLJ2M/12) if inlist(EiADLJ2,2,3) & inrange(EiADLJ2M,1,24)

missing_w4 raxmedhlp EiADLJ2 EiADLJ2M EiADLJ2Y if inw`wv'xt==1, result(raxmedage)
replace raxmedage = .d if EiADLJ2==96
replace raxmedage = .h if raxmedhlp==0 & inw`wv'xt==1
replace raxmedage = radage if EiADLJ2==1
replace raxmedage = floor(radage - medyrs) if !mi(radage) & !mi(medyrs) & inlist(EiADLJ2,2,3)
replace raxmedage = radage - EiADLJ2Y if inrange(EiADLJ2Y,1,100) & EiADLJ2==4
replace raxmedage = .i if ((raxmedage > radage) | (raxmedage < 0)) & !mi(raxmedage) & !mi(radage)

***help w/ meds began final year***
*wave 4 respondent help w/ meds began final year
missing_w4 raxmedhlp EiADLJ2 if inw`wv'xt==1, result(raxmedb1y)
replace raxmedb1y = .d if EiADLJ2==96
replace raxmedb1y = 0 if raxmedhlp==0 & inw`wv'xt==1
replace raxmedb1y = 0 if inlist(EiADLJ2,3,4)
replace raxmedb1y = 1 if inlist(EiADLJ2,1,2)

drop medyrs


***someone helped any iadl***
*wave 4 respondent someone helped any iadl
missing_w4 raxmealhlp raxshophlp raxphonehlp raxmedhlp if inw`wv'xt==1, result(raxricany)
replace raxricany = 0 if (raxmealhlp==0 | raxshophlp==0 | raxphonehlp==0 | raxmedhlp==0) & inw`wv'xt==1
replace raxricany = 1 if (raxmealhlp==1 | raxshophlp==1 | raxphonehlp==1 | raxmedhlp==1) & inw`wv'xt==1

***help w/ any iadl began final year***
*wave 4 respondent help w/ any iadl began final year
missing_w4 raxmealb1y raxshopb1y raxphoneb1y raxmedb1y if inw`wv'xt==1, result(raxricareb)
replace raxricareb = 0 if raxricany==0 & inw`wv'xt==1
replace raxricareb = 0 if (raxmealb1y==0 | raxshopb1y==0 | raxphoneb1y==0 | raxmedb1y==0) & inw`wv'xt==1
replace raxricareb = 1 if (raxmealb1y==1 | raxshopb1y==1 | raxphoneb1y==1 | raxmedb1y==1) & inw`wv'xt==1


***someone helped adl or iadl***
*wave 4 respondent someone helped adl or iadl
missing_w4 raxracany raxricany if inw`wv'xt==1, result(raxrcany)
replace raxrcany = 0 if (raxracany==0 | raxricany==0) & inw`wv'xt==1
replace raxrcany = 1 if (raxracany==1 | raxricany==1) & inw`wv'xt==1

***help w/ any adl or iadl began final year***
*wave 4 respondent help w/ any adl or iadl began final year
missing_w4 raxracareb raxricareb if inw`wv'xt==1, result(raxrcareb)
replace raxrcareb = 0 if raxrcany==0 & inw`wv'xt==1
replace raxrcareb = 0 if (raxracareb==0 | raxricareb==0) & inw`wv'xt==1
replace raxrcareb = 1 if (raxracareb==1 | raxricareb==1) & inw`wv'xt==1


***spouse helped r adl/iadl***
*wave 4 respondent spouse helped r adl/iadl
missing_w4 EiWHlp1 if inw`wv'xt==1, result(raxrscare)
replace raxrscare = .h if raxrcany==0 & inw`wv'xt==1
replace raxrscare = 0 if EiWHlp1==0 
replace raxrscare = 1 if EiWHlp1==1 

***child helped r adl/iadl***
*wave 4 respondent child helped r adl/iadl
missing_w4 EiWHlp2 EiWHlp3 if inw`wv'xt==1, result(raxrccare)
replace raxrccare = .h if raxrcany==0 & inw`wv'xt==1
replace raxrccare = 0 if EiWHlp2==0 | EiWHlp3==0 
replace raxrccare = 1 if EiWHlp2==1 | EiWHlp3==1 

***relative helped r adl/iadl***
*wave 4 respondent relative helped r adl/iadl
missing_w4 EiWHlp4 EiWHlp5 EiWHlp6 if inw`wv'xt==1, result(raxrrcare)
replace raxrrcare = .h if raxrcany==0 & inw`wv'xt==1
replace raxrrcare = 0 if EiWHlp4==0 | EiWHlp5==0 | EiWHlp6==0 
replace raxrrcare = 1 if EiWHlp4==1 | EiWHlp5==1 | EiWHlp6==1 

***other helped r adl/iadl***
*wave 4 respondent other helped r adl/iadl
missing_w4 EiWHlp11 EiWHlp95 if inw`wv'xt==1, result(raxrfcare)
replace raxrfcare = .h if raxrcany==0 & inw`wv'xt==1
replace raxrfcare = 0 if EiWHlp11==0 | EiWHlp95==0 
replace raxrfcare = 1 if EiWHlp11==1 | EiWHlp95==1 

***received any informal care***
*wave 4 respondent received any informal care
missing_w4 raxrscare raxrccare raxrrcare raxrfcare if inw`wv'xt==1, result(raxrcaany)
replace raxrcaany = 0 if raxrcany==0 & inw`wv'xt==1
replace raxrcaany = 0 if (raxrscare==0 | raxrccare==0 | raxrrcare==0 | raxrfcare==0) & inw`wv'xt==1
replace raxrcaany = 1 if (raxrscare==1 | raxrccare==1 | raxrrcare==1 | raxrfcare==1) & inw`wv'xt==1

***pro helped r adl/iadl***
*wave 4 respondent pro helped r adl/iadl
missing_w4 EiWHlp7 EiWHlp10 if inw`wv'xt==1, result(raxrpfcare)
replace raxrpfcare = .h if raxrcany==0 & inw`wv'xt==1
replace raxrpfcare = 0 if EiWHlp7==0 | EiWHlp10==0
replace raxrpfcare = 1 if EiWHlp7==1 | EiWHlp10==1

***unpaid pro helped r adl/iadl***
*wave 4 respondent unpaid pro helped r adl/iadl
missing_w4 EiWHlp8 EiWHlp9 if inw`wv'xt==1, result(raxrufcare)
replace raxrufcare = .h if raxrcany==0 & inw`wv'xt==1
replace raxrufcare = 0 if EiWHlp8==0 | EiWHlp9==0 
replace raxrufcare = 1 if EiWHlp8==1 | EiWHlp9==1 

***received any formal care***
*wave 4 respondent received any formal care
missing_w4 raxrpfcare raxrufcare if inw`wv'xt==1, result(raxrfaany)
replace raxrfaany = 0 if raxrcany==0 & inw`wv'xt==1
replace raxrfaany = 0 if (raxrpfcare==0 | raxrufcare==0) & inw`wv'xt==1
replace raxrfaany = 1 if (raxrpfcare==1 | raxrufcare==1) & inw`wv'xt==1




***drop ELSA wave 4 core file raw variables***
drop `funxt_w4_exit'



******************************************************************************************


*set wave number
local wv=6
local pre_wv=5

local funxt_w6_exit EiADLA EiADLB EiADLC EiADLD EiADLE EiADLF EiADLG EiADLH EiADLI EiADLJ ///
										EiADLA2 EiADLA2M EiADLA2Y EiADLB2 EiADLB2M EiADLB2Y ///
										EiADLC2 EiADLC2M EiADLC2Y EiADLD2 EiADLD2M EiADLD2Y ///
										EiADLE2 EiADLE2M EiADLE2Y EiADLF2 EiADLF2M EiADLF2Y ///
										EiADLG2 EiADLG2M EiADLG2Y EiADLH2 EiADLH2M EiADLH2Y ///
										EiADLI2 EiADLI2M EiADLI2Y EiADLJ2 EiADLJ2M EiADLJ2Y ///
										EiWHlp1 EiWHlp2 EiWHlp3 EiWHlp4 EiWHlp5 EiWHlp6 EiWHlp7 EiWHlp8 ///
										EiWHlp9 EiWHlp10 EiWHlp11 EiWHlp95 ///
										EIWHLPF1 EIWHLPF2 EIWHLPF3 EIWHLPF4 EIWHLPF5 EIWHLPF6 EIWHLPF7 EIWHLPF8 EIWHLPF9 
merge 1:1 idauniq using "$wave_6_xt", keepusing(`funxt_w6_exit') nogen




***someone helped dress***
*wave 6 respondent someone helped dress
missing_w6 EiADLA if inw`wv'xt==1, result(raxdresshlp)
replace raxdresshlp = .d if EiADLA==3
replace raxdresshlp = 0 if EiADLA==2
replace raxdresshlp = 1 if EiADLA==1

***age needed help dressing***
*wave 6 respondent age needed help dressing
gen dressyrs = .
replace dressyrs = (EiADLA2M/12) if inlist(EiADLA2,2,3) & inrange(EiADLA2M,1,24)

missing_w6 raxdresshlp EiADLA2 EiADLA2M EiADLA2Y if inw`wv'xt==1, result(raxdressage)
replace raxdressage = .d if EiADLA2==96
replace raxdressage = .h if raxdresshlp==0 & inw`wv'xt==1
replace raxdressage = radage if EiADLA2==1
replace raxdressage = floor(radage - dressyrs) if !mi(radage) & !mi(dressyrs) & inlist(EiADLA2,2,3)
replace raxdressage = radage - EiADLA2Y if inrange(EiADLA2Y,1,100) & EiADLA2==4
replace raxdressage = .i if ((raxdressage > radage) | (raxdressage < 0)) & !mi(raxdressage) & !mi(radage)

***help dressing began final year***
*wave 6 respondent help dressing began final year
missing_w6 raxdresshlp EiADLA2 if inw`wv'xt==1, result(raxdressb1y)
replace raxdressb1y = .d if EiADLA2==96
replace raxdressb1y = 0 if raxdresshlp==0 & inw`wv'xt==1
replace raxdressb1y = 0 if inlist(EiADLA2,3,4)
replace raxdressb1y = 1 if inlist(EiADLA2,1,2)

drop dressyrs


***someone helped walk***
*wave 6 respondent someone helped walk
missing_w6 EiADLB if inw`wv'xt==1, result(raxwalkhlp)
replace raxwalkhlp = .d if EiADLB==3
replace raxwalkhlp = 0 if EiADLB==2
replace raxwalkhlp = 1 if EiADLB==1

***age needed help walking***
*wave 6 respondent age needed help walking
gen walkyrs = .
replace walkyrs = (EiADLB2M/12) if inlist(EiADLB2,2,3) & inrange(EiADLB2M,1,24)

missing_w6 raxwalkhlp EiADLB2 EiADLB2M EiADLB2Y if inw`wv'xt==1, result(raxwalkage)
replace raxwalkage = .d if EiADLB2==96
replace raxwalkage = .h if raxwalkhlp==0 & inw`wv'xt==1
replace raxwalkage = radage if EiADLB2==1
replace raxwalkage = floor(radage - walkyrs) if !mi(radage) & !mi(walkyrs) & inlist(EiADLB2,2,3)
replace raxwalkage = radage - EiADLB2Y if inrange(EiADLB2Y,1,100) & EiADLB2==4
replace raxwalkage = .i if ((raxwalkage > radage) | (raxwalkage < 0)) & !mi(raxwalkage) & !mi(radage)

***help walking began final year***
*wave 6 respondent help walking began final year
missing_w6 raxwalkhlp EiADLB2 if inw`wv'xt==1, result(raxwalkb1y)
replace raxwalkb1y = .d if EiADLB2==96
replace raxwalkb1y = 0 if raxwalkhlp==0 & inw`wv'xt==1
replace raxwalkb1y = 0 if inlist(EiADLB2,3,4)
replace raxwalkb1y = 1 if inlist(EiADLB2,1,2)

drop walkyrs


***someone helped bathe***
*wave 6 respondent someone helped bathe
missing_w6 EiADLC if inw`wv'xt==1, result(raxbathehlp)
replace raxbathehlp = .d if EiADLC==3
replace raxbathehlp = 0 if EiADLC==2
replace raxbathehlp = 1 if EiADLC==1

***age needed help bathing***
*wave 6 respondent age needed help bathing
gen batheyrs = .
replace batheyrs = (EiADLC2M/12) if inlist(EiADLC2,2,3) & inrange(EiADLC2M,1,24)

missing_w6 raxbathehlp EiADLC2 EiADLC2M EiADLC2Y if inw`wv'xt==1, result(raxbatheage)
replace raxbatheage = .d if EiADLC2==96
replace raxbatheage = .h if raxbathehlp==0 & inw`wv'xt==1
replace raxbatheage = radage if EiADLC2==1
replace raxbatheage = floor(radage - batheyrs) if !mi(radage) & !mi(batheyrs) & inlist(EiADLC2,2,3)
replace raxbatheage = radage - EiADLC2Y if inrange(EiADLC2Y,1,100) & EiADLC2==4
replace raxbatheage = .i if ((raxbatheage > radage) | (raxbatheage < 0)) & !mi(raxbatheage) & !mi(radage)

***help bathing began final year***
*wave 6 respondent help bathing began final year
missing_w6 raxbathehlp EiADLC2 if inw`wv'xt==1, result(raxbatheb1y)
replace raxbatheb1y = .d if EiADLC2==96
replace raxbatheb1y = 0 if raxbathehlp==0 & inw`wv'xt==1
replace raxbatheb1y = 0 if inlist(EiADLC2,3,4)
replace raxbatheb1y = 1 if inlist(EiADLC2,1,2)

drop batheyrs


***someone helped eat***
*wave 6 respondent someone helped eat
missing_w6 EiADLD if inw`wv'xt==1, result(raxeathlp)
replace raxeathlp = .d if EiADLD==3
replace raxeathlp = 0 if EiADLD==2
replace raxeathlp = 1 if EiADLD==1

***age needed help eating***
*wave 6 respondent age needed help eating
gen eatyrs = .
replace eatyrs = (EiADLD2M/12) if inlist(EiADLD2,2,3) & inrange(EiADLD2M,1,24)

missing_w6 raxeathlp EiADLD2 EiADLD2M EiADLD2Y if inw`wv'xt==1, result(raxeatage)
replace raxeatage = .d if EiADLD2==96
replace raxeatage = .h if raxeathlp==0 & inw`wv'xt==1
replace raxeatage = radage if EiADLD2==1
replace raxeatage = floor(radage - eatyrs) if !mi(radage) & !mi(eatyrs) & inlist(EiADLD2,2,3)
replace raxeatage = radage - EiADLD2Y if inrange(EiADLD2Y,1,100) & EiADLD2==4
replace raxeatage = .i if ((raxeatage > radage) | (raxeatage < 0)) & !mi(raxeatage) & !mi(radage)

***help eating began final year***
*wave 6 respondent help eating began final year
missing_w6 raxeathlp EiADLD2 if inw`wv'xt==1, result(raxeatb1y)
replace raxeatb1y = .d if EiADLD2==96
replace raxeatb1y = 0 if raxeathlp==0 & inw`wv'xt==1
replace raxeatb1y = 0 if inlist(EiADLD2,3,4)
replace raxeatb1y = 1 if inlist(EiADLD2,1,2)

drop eatyrs


***someone helped bed***
*wave 6 respondent someone helped bed
missing_w6 EiADLE if inw`wv'xt==1, result(raxbedhlp)
replace raxbedhlp = .d if EiADLE==3
replace raxbedhlp = 0 if EiADLE==2
replace raxbedhlp = 1 if EiADLE==1

***age needed help w/ bed***
*wave 6 respondent age needed help w/ bed
gen bedyrs = .
replace bedyrs = (EiADLE2M/12) if inlist(EiADLE2,2,3) & inrange(EiADLE2M,1,24)

missing_w6 raxbedhlp EiADLE2 EiADLE2M EiADLE2Y if inw`wv'xt==1, result(raxbedage)
replace raxbedage = .d if EiADLE2==96
replace raxbedage = .h if raxbedhlp==0 & inw`wv'xt==1
replace raxbedage = radage if EiADLE2==1
replace raxbedage = floor(radage - bedyrs) if !mi(radage) & !mi(bedyrs) & inlist(EiADLE2,2,3)
replace raxbedage = radage - EiADLE2Y if inrange(EiADLE2Y,1,100) & EiADLE2==4
replace raxbedage = .i if ((raxbedage > radage) | (raxbedage < 0)) & !mi(raxbedage) & !mi(radage)

***help w/ bed began final year***
*wave 6 respondent help w/ bed began final year
missing_w6 raxbedhlp EiADLE2 if inw`wv'xt==1, result(raxbedb1y)
replace raxbedb1y = .d if EiADLE2==96
replace raxbedb1y = 0 if raxbedhlp==0 & inw`wv'xt==1
replace raxbedb1y = 0 if inlist(EiADLE2,3,4)
replace raxbedb1y = 1 if inlist(EiADLE2,1,2)

drop bedyrs


***someone helped toilet***
*wave 6 respondent someone helped toilet
missing_w6 EiADLF if inw`wv'xt==1, result(raxtoilethlp)
replace raxtoilethlp = .d if EiADLF==3
replace raxtoilethlp = 0 if EiADLF==2
replace raxtoilethlp = 1 if EiADLF==1

***age needed help w/ toilet***
*wave 6 respondent age needed help w/ toilet
gen toiletyrs = .
replace toiletyrs = (EiADLF2M/12) if inlist(EiADLF2,2,3) & inrange(EiADLF2M,1,24)

missing_w6 raxtoilethlp EiADLF2 EiADLF2M EiADLF2Y if inw`wv'xt==1, result(raxtoiletage)
replace raxtoiletage = .d if EiADLF2==96
replace raxtoiletage = .h if raxtoilethlp==0 & inw`wv'xt==1
replace raxtoiletage = radage if EiADLF2==1
replace raxtoiletage = floor(radage - toiletyrs) if !mi(radage) & !mi(toiletyrs) & inlist(EiADLF2,2,3)
replace raxtoiletage = radage - EiADLF2Y if inrange(EiADLF2Y,1,100) & EiADLF2==4
replace raxtoiletage = .i if ((raxtoiletage > radage) | (raxtoiletage < 0)) & !mi(raxtoiletage) & !mi(radage)

***help w/ toilet began final year***
*wave 6 respondent help w/ toilet began final year
missing_w6 raxtoilethlp EiADLF2 if inw`wv'xt==1, result(raxtoiletb1y)
replace raxtoiletb1y = .d if EiADLF2==96
replace raxtoiletb1y = 0 if raxtoilethlp==0 & inw`wv'xt==1
replace raxtoiletb1y = 0 if inlist(EiADLF2,3,4)
replace raxtoiletb1y = 1 if inlist(EiADLF2,1,2)

drop toiletyrs


***someone helped any adl***
*wave 6 respondent someone helped any adl
missing_w6 raxdresshlp raxwalkhlp raxbathehlp raxeathlp raxbedhlp raxtoilethlp if inw`wv'xt==1, result(raxracany)
replace raxracany = 0 if (raxdresshlp==0 | raxwalkhlp==0 | raxbathehlp==0 | raxeathlp==0 | ///
												raxbedhlp==0 | raxtoilethlp==0) & inw`wv'xt==1
replace raxracany = 1 if (raxdresshlp==1 | raxwalkhlp==1 | raxbathehlp==1 | raxeathlp==1 | ///
												raxbedhlp==1 | raxtoilethlp==1) & inw`wv'xt==1

***help w/ any adl began final year***
*wave 6 respondent help w/ any adl began final year
missing_w6 raxdressb1y raxwalkb1y raxbatheb1y raxeatb1y raxbedb1y raxtoiletb1y if inw`wv'xt==1, result(raxracareb)
replace raxracareb = 0 if raxracany==0 & inw`wv'xt==1
replace raxracareb = 0 if (raxdressb1y==0 | raxwalkb1y==0 | raxbatheb1y==0 | raxeatb1y==0 | ///
													 raxbedb1y==0 | raxtoiletb1y==0) & inw`wv'xt==1
replace raxracareb = 1 if (raxdressb1y==1 | raxwalkb1y==1 | raxbatheb1y==1 | raxeatb1y==1 | ///
													 raxbedb1y==1 | raxtoiletb1y==1) & inw`wv'xt==1


***someone helped hot meals***
*wave 6 respondent someone helped hot meals
missing_w6 EiADLG if inw`wv'xt==1, result(raxmealhlp)
replace raxmealhlp = .d if EiADLG==3
replace raxmealhlp = 0 if EiADLG==2
replace raxmealhlp = 1 if EiADLG==1

***age needed help hot meals***
*wave 6 respondent age needed help hot meals
gen mealyrs = .
replace mealyrs = (EiADLG2M/12) if inlist(EiADLG2,2,3) & inrange(EiADLG2M,1,24)

missing_w6 raxmealhlp EiADLG2 EiADLG2M EiADLG2Y if inw`wv'xt==1, result(raxmealage)
replace raxmealage = .d if EiADLG2==96
replace raxmealage = .h if raxmealhlp==0 & inw`wv'xt==1
replace raxmealage = radage if EiADLG2==1
replace raxmealage = floor(radage - mealyrs) if !mi(radage) & !mi(mealyrs) & inlist(EiADLG2,2,3)
replace raxmealage = radage - EiADLG2Y if inrange(EiADLG2Y,1,100) & EiADLG2==4
replace raxmealage = .i if ((raxmealage > radage) | (raxmealage < 0)) & !mi(raxmealage) & !mi(radage)

***help w/ hot meals began final year***
missing_w6 raxmealhlp EiADLG2 if inw`wv'xt==1, result(raxmealb1y)
replace raxmealb1y = .d if EiADLG2==96
replace raxmealb1y = 0 if raxmealhlp==0 & inw`wv'xt==1
replace raxmealb1y = 0 if inlist(EiADLG2,3,4)
replace raxmealb1y = 1 if inlist(EiADLG2,1,2)

drop mealyrs


***someone helped grocery shopping***
*wave 6 respondent someone helped grocery shopping
missing_w6 EiADLH if inw`wv'xt==1, result(raxshophlp)
replace raxshophlp = .d if EiADLH==3
replace raxshophlp = 0 if EiADLH==2
replace raxshophlp = 1 if EiADLH==1

***age needed help grocery shopping***
*wave 6 respondent age needed help grocery shopping
gen shopyrs = .
replace shopyrs = (EiADLH2M/12) if inlist(EiADLH2,2,3) & inrange(EiADLH2M,1,24)

missing_w6 raxshophlp EiADLH2 EiADLH2M EiADLH2Y if inw`wv'xt==1, result(raxshopage)
replace raxshopage = .d if EiADLH2==96
replace raxshopage = .h if raxshophlp==0 & inw`wv'xt==1
replace raxshopage = radage if EiADLH2==1
replace raxshopage = floor(radage - shopyrs) if !mi(radage) & !mi(shopyrs) & inlist(EiADLH2,2,3)
replace raxshopage = radage - EiADLH2Y if inrange(EiADLH2Y,1,100) & EiADLH2==4
replace raxshopage = .i if ((raxshopage > radage) | (raxshopage < 0)) & !mi(raxshopage) & !mi(radage)

***help w/ grocery shopping began final year***
*wave 6 respondent help w/ grocery shopping began final year
missing_w6 raxshophlp EiADLH2 if inw`wv'xt==1, result(raxshopb1y)
replace raxshopb1y = .d if EiADLH2==96
replace raxshopb1y = 0 if raxshophlp==0 & inw`wv'xt==1
replace raxshopb1y = 0 if inlist(EiADLH2,3,4)
replace raxshopb1y = 1 if inlist(EiADLH2,1,2)

drop shopyrs


***someone helped phone***
*wave 6 respondent someone helped phone
missing_w6 EiADLI if inw`wv'xt==1, result(raxphonehlp)
replace raxphonehlp = .d if EiADLI==3
replace raxphonehlp = 0 if EiADLI==2
replace raxphonehlp = 1 if EiADLI==1

***age needed help phone***
*wave 6 respondent age needed help phone
gen phoneyrs = .
replace phoneyrs = (EiADLI2M/12) if inlist(EiADLI2,2,3) & inrange(EiADLI2M,1,24)

missing_w6 raxphonehlp EiADLI2 EiADLI2M EiADLI2Y if inw`wv'xt==1, result(raxphoneage)
replace raxphoneage = .d if EiADLI2==96
replace raxphoneage = .h if raxphonehlp==0 & inw`wv'xt==1
replace raxphoneage = radage if EiADLI2==1
replace raxphoneage = floor(radage - phoneyrs) if !mi(radage) & !mi(phoneyrs) & inlist(EiADLI2,2,3)
replace raxphoneage = radage - EiADLI2Y if inrange(EiADLI2Y,1,100) & EiADLI2==4
replace raxphoneage = .i if ((raxphoneage > radage) | (raxphoneage < 0)) & !mi(raxphoneage) & !mi(radage)

***help w/ phone began final year***
*wave 6 respondent help w/ phone began final year
missing_w6 raxphonehlp EiADLI2 if inw`wv'xt==1, result(raxphoneb1y)
replace raxphoneb1y = .d if EiADLI2==96
replace raxphoneb1y = 0 if raxphonehlp==0 & inw`wv'xt==1
replace raxphoneb1y = 0 if inlist(EiADLI2,3,4)
replace raxphoneb1y = 1 if inlist(EiADLI2,1,2)

drop phoneyrs


***someone helped meds***
*wave 6 respondent someone helped meds
missing_w6 EiADLJ if inw`wv'xt==1, result(raxmedhlp)
replace raxmedhlp = .d if EiADLJ==3
replace raxmedhlp = 0 if EiADLJ==2
replace raxmedhlp = 1 if EiADLJ==1

***age needed help meds***
*wave 6 respondent age needed help meds
gen medyrs = .
replace medyrs = (EiADLJ2M/12) if inlist(EiADLJ2,2,3) & inrange(EiADLJ2M,1,24)

missing_w6 raxmedhlp EiADLJ2 EiADLJ2M EiADLJ2Y if inw`wv'xt==1, result(raxmedage)
replace raxmedage = .d if EiADLJ2==96
replace raxmedage = .h if raxmedhlp==0 & inw`wv'xt==1
replace raxmedage = radage if EiADLJ2==1
replace raxmedage = floor(radage - medyrs) if !mi(radage) & !mi(medyrs) & inlist(EiADLJ2,2,3)
replace raxmedage = radage - EiADLJ2Y if inrange(EiADLJ2Y,1,100) & EiADLJ2==4
replace raxmedage = .i if ((raxmedage > radage) | (raxmedage < 0)) & !mi(raxmedage) & !mi(radage)

***help w/ meds began final year***
*wave 6 respondent help w/ meds began final year
missing_w6 raxmedhlp EiADLJ2 if inw`wv'xt==1, result(raxmedb1y)
replace raxmedb1y = .d if EiADLJ2==96
replace raxmedb1y = 0 if raxmedhlp==0 & inw`wv'xt==1
replace raxmedb1y = 0 if inlist(EiADLJ2,3,4)
replace raxmedb1y = 1 if inlist(EiADLJ2,1,2)

drop medyrs


***someone helped any iadl***
*wave 6 respondent someone helped any iadl
missing_w6 raxmealhlp raxshophlp raxphonehlp raxmedhlp if inw`wv'xt==1, result(raxricany)
replace raxricany = 0 if (raxmealhlp==0 | raxshophlp==0 | raxphonehlp==0 | raxmedhlp==0) & inw`wv'xt==1
replace raxricany = 1 if (raxmealhlp==1 | raxshophlp==1 | raxphonehlp==1 | raxmedhlp==1) & inw`wv'xt==1

***help w/ any iadl began final year***
*wave 6 respondent help w/ any iadl began final year
missing_w6 raxmealb1y raxshopb1y raxphoneb1y raxmedb1y if inw`wv'xt==1, result(raxricareb)
replace raxricareb = 0 if raxricany==0 & inw`wv'xt==1
replace raxricareb = 0 if (raxmealb1y==0 | raxshopb1y==0 | raxphoneb1y==0 | raxmedb1y==0) & inw`wv'xt==1
replace raxricareb = 1 if (raxmealb1y==1 | raxshopb1y==1 | raxphoneb1y==1 | raxmedb1y==1) & inw`wv'xt==1


***someone helped adl or iadl***
*wave 6 respondent someone helped adl or iadl
missing_w6 raxracany raxricany if inw`wv'xt==1, result(raxrcany)
replace raxrcany = 0 if (raxracany==0 | raxricany==0) & inw`wv'xt==1
replace raxrcany = 1 if (raxracany==1 | raxricany==1) & inw`wv'xt==1

***help w/ any adl or iadl began final year***
*wave 6 respondent help w/ any adl or iadl began final year
missing_w6 raxracareb raxricareb if inw`wv'xt==1, result(raxrcareb)
replace raxrcareb = 0 if raxrcany==0 & inw`wv'xt==1
replace raxrcareb = 0 if (raxracareb==0 | raxricareb==0) & inw`wv'xt==1
replace raxrcareb = 1 if (raxracareb==1 | raxricareb==1) & inw`wv'xt==1


***spouse helped r adl/iadl***
*wave 6 respondent spouse helped r adl/iadl
missing_w6 EiWHlp1 if inw`wv'xt==1, result(raxrscare)
replace raxrscare = .h if raxrcany==0 & inw`wv'xt==1
replace raxrscare = 0 if EiWHlp1==0 
replace raxrscare = 1 if EiWHlp1==1 

***child helped r adl/iadl***
*wave 6 respondent child helped r adl/iadl
missing_w6 EiWHlp2 EiWHlp3 if inw`wv'xt==1, result(raxrccare)
replace raxrccare = .h if raxrcany==0 & inw`wv'xt==1
replace raxrccare = 0 if EiWHlp2==0 | EiWHlp3==0 
replace raxrccare = 1 if EiWHlp2==1 | EiWHlp3==1 

***relative helped r adl/iadl***
*wave 6 respondent relative helped r adl/iadl
missing_w6 EiWHlp4 EiWHlp5 EiWHlp6 if inw`wv'xt==1, result(raxrrcare)
replace raxrrcare = .h if raxrcany==0 & inw`wv'xt==1
replace raxrrcare = 0 if EiWHlp4==0 | EiWHlp5==0 | EiWHlp6==0 
replace raxrrcare = 1 if EiWHlp4==1 | EiWHlp5==1 | EiWHlp6==1 

***other helped r adl/iadl***
*wave 6 respondent other helped r adl/iadl
missing_w6 EiWHlp11 EiWHlp95 if inw`wv'xt==1, result(raxrfcare)
replace raxrfcare = .h if raxrcany==0 & inw`wv'xt==1
replace raxrfcare = 0 if EiWHlp11==0 | EiWHlp95==0 
replace raxrfcare = 1 if EiWHlp11==1 | EiWHlp95==1 

***received any informal care***
*wave 6 respondent received any informal care
missing_w6 raxrscare raxrccare raxrrcare raxrfcare if inw`wv'xt==1, result(raxrcaany)
replace raxrcaany = 0 if raxrcany==0 & inw`wv'xt==1
replace raxrcaany = 0 if (raxrscare==0 | raxrccare==0 | raxrrcare==0 | raxrfcare==0) & inw`wv'xt==1
replace raxrcaany = 1 if (raxrscare==1 | raxrccare==1 | raxrrcare==1 | raxrfcare==1) & inw`wv'xt==1

***pro helped r adl/iadl***
*wave 6 respondent pro helped r adl/iadl
missing_w6 EiWHlp7 EiWHlp10 EIWHLPF1 EIWHLPF5 EIWHLPF7 if inw`wv'xt==1, result(raxrpfcare)
replace raxrpfcare = .h if raxrcany==0 & inw`wv'xt==1
replace raxrpfcare = 0 if EiWHlp7==0 | EiWHlp10==0 | ///
													EIWHLPF1==0 | EIWHLPF5==0 | EIWHLPF7==0
replace raxrpfcare = 1 if EiWHlp7==1 | EiWHlp10==1 | ///
													EIWHLPF1==1 | EIWHLPF5==1 | EIWHLPF7==1

***unpaid pro helped r adl/iadl***
*wave 6 respondent unpaid pro helped r adl/iadl
missing_w6 EiWHlp8 EiWHlp9 EIWHLPF2 EIWHLPF3 EIWHLPF4 EIWHLPF6 EIWHLPF8 if inw`wv'xt==1, result(raxrufcare)
replace raxrufcare = .h if raxrcany==0 & inw`wv'xt==1
replace raxrufcare = 0 if EiWHlp8==0 | EiWHlp9==0 | ///
													EIWHLPF2==0 | EIWHLPF3==0 | EIWHLPF4==0 | EIWHLPF6==0 | EIWHLPF8==0 
replace raxrufcare = 1 if EiWHlp8==1 | EiWHlp9==1 | ///
													EIWHLPF2==1 | EIWHLPF3==1 | EIWHLPF4==1 | EIWHLPF6==1 | EIWHLPF8==1

***received any formal care***
*wave 6 respondent received any formal care
missing_w6 raxrpfcare raxrufcare if inw`wv'xt==1, result(raxrfaany)
replace raxrfaany = 0 if raxrcany==0 & inw`wv'xt==1
replace raxrfaany = 0 if (raxrpfcare==0 | raxrufcare==0) & inw`wv'xt==1
replace raxrfaany = 1 if (raxrpfcare==1 | raxrufcare==1) & inw`wv'xt==1



***drop ELSA wave 6 core file raw variables***
drop `funxt_w6_exit'



******************************************************************************************



***yes or no***
label define yesnoe ///
	0 "0.no" ///
	1 "1.yes" ///
	.n ".n:not applicable" ///
	.w ".w:no will" ///
	.t ".t:not distributed yet" ///
	.q ".q:not asked this wave" ///
	.x ".x:did not own home"
	
***probate***
label define probate ///
	1 "1.probate not needed" ///
	2 "2.not yet been thru probate" ///
	3 "3.probate completed" ///
	.t ".t:not distributed yet" ///
	.w ".w:no will" 
	
***durable power of attorney***
label define dpoa ///
   0 "0.deceased respondent" ///
   1 "1.spouse" ///
   2 "2.child/grandchild" ///
   3 "3.other relative" ///
   4 "4.friend" ///
   5 "5.non-relative proxy" ///
   6 "6.doctor" ///
   7 "7.minister" ///
   8 "8.attorney" ///
   9 "9.social worker" ///
   10 "10.other" ///
   11 "11.spouse & child/grandchild" ///
   12 "12.child/grandchild & relative" ///
   .n ".n:not applicable" ///
   .p ".p:post exit ivw" ///
   .q ".q:not asked this wave"
   
***beneficiary***
label define beneficiary ///
	1 "1.spouse" ///
	2 "2.child" ///
	3 "3.grandchild" ///
	4 "4.other relative" ///
	5 "5.other non-relative" ///
	.n ".n:not applicable" ///
	.p ".p:post exit ivw" ///
	.q ".q:not asked this wave"
	
label define yesnopension ///
	0 "0.no" ///
	1 "1.yes" ///
	.n ".n:no pension" ///
	.w ".w:no will" ///
	.o ".o:other" ///
	.q ".q:not asked this wave" 
	
label define yesnolvwill ///
	0 "0.no" ///
	1 "1.yes" ///
	.n ".n:no living will" ///
	.q ".q:not asked this wave" 
	
label define yesnodpoa ///
	0 "0.no" ///
	1 "1.yes" ///
	.n ".n:no durable power of attorney" ///
	.q ".q:not asked this wave" 
	
label define yesnolfins ///
	0 "0.no" ///
	1 "1.yes" ///
	.n ".n:no life insurance" ///
	.q ".q:not asked this wave" ///
	.t ".t:not distributed yet" 

label define eolflag ///
	-1 "-1.not imputed, missing neighbors" ///
  -2 "-2.not imputed, missing covariates" ///
  -3 "-3.not imputed, estate not distributed" ///
	1 "1.continuous value" ///
	2 "2.closed bracket" ///
	3 "3.open bracket" ///
	5 "5.no bracket info" ///
	7 "7.dk whether has expense" ///
	.q ".q:not asked this wave" ///
	.x ".x:no insurance"
 
label define eolflagval ///
	-1 "-1.not imputed, missing neighbors" ///
  -2 "-2.not imputed, missing covariates" ///
  -3 "-3.not imputed, estate not distributed" ///
	1 "1.continuous value" ///
	2 "2.closed bracket" ///
	3 "3.open bracket" ///
	5 "5.no bracket info" ///
	6 "6.no settlement" ///
	7 "7.dk whether settlement" ///
	.t ".t:not distributed yet" ///
	.q ".q:not asked this wave"
	
	

*set wave number
local wv=2
local pre_wv=1

***merge with wave 2 exit data***
local eolxt_w2_exit EiRRel EiWillA EiProb EiWillB Eidcsta EiDcstb Eifuins ///
										EiPenWho EiPenWh2 EiPenWh3 EiKin EiBen EiPenM EiPen5 EiPen10 EiPen15 ///
										EiPen95 EiPen96 EiPen97 EiPen98 EiPen99 EiPen100
merge 1:1 idauniq using "$wave_2_xt", keepusing(`eolxt_w2_exit') nogen



***whether had a witnessed will***
*wave 2 respondent whether had a witnessed will
gen rawitwill = .
missing_w2 EiWillA if inw`wv'xt==1, result(rawitwill) 
replace rawitwill = .d if EiWillA==3
replace rawitwill = 0 if EiWillA==2
replace rawitwill = 1 if EiWillA==1
label variable rawitwill "rawitwill: r had a will"
label values rawitwill yesnoe


***whether will has been through probate***
*wave 2 respondent whether will has been through probate
gen raprobate = .
missing_w2 EiWillB EiProb rawitwill if inw`wv'xt==1, result(raprobate)
replace raprobate = .d if EiProb==3
replace raprobate = .w if rawitwill==0 & inw`wv'xt==1
replace raprobate = 1 if EiProb==2 
replace raprobate = 2 if EiProb==1 & EiWillB==2
replace raprobate = 3 if EiProb==1 & EiWillB==1
label variable raprobate "raprobate: probate status of r's will"
label values raprobate probate

***whether proxy was beneficiary of will***
*wave 2 respondent proxy was beneficiary
gen rawillp = .
missing_w2 EiBen rawitwill if inw`wv'xt==1, result(rawillp)
replace rawillp = .w if rawitwill==0 & inw`wv'xt==1
replace rawillp = 0 if EiBen==2 //proxy will beneficiary
replace rawillp = 1 if EiBen==1 //proxy will beneficiary
label variable rawillp "rawillp: proxy is beneficiary of r's will"
label values rawillp yesnoe


***whether spouse was beneficiary of estate***
*wave 2 respondent spouse was beneficiary
gen rabnfcrsp = .
replace rabnfcrsp = .q if inw`wv'xt==1
label variable rabnfcrsp "rabnfcrsp: spouse was beneficiary of r's estate"
label values rabnfcrsp yesnoe
			
***whether child/grandchild was beneficary of estate***
*wave 2 respondent child/grandchild was beneficiary
gen rabnfcrcg = .
replace rabnfcrcg = .q if inw`wv'xt==1
label variable rabnfcrcg "rabnfcrcg: child/grandchild was beneficiary of r's estate"
label values rabnfcrcg yesnoe

***whether relative was beneficiary of estate***
*wave 2 respondent relative was beneficiary
gen rabnfcrrl = .
replace rabnfcrrl = .q if inw`wv'xt==1
label variable rabnfcrrl "rabnfcrrl: relative was beneficiary of r's estate"
label values rabnfcrrl yesnoe

***whether other person was beneficiary of estate***
*wave 2 respondent other person was beneficiary
gen rabnfcrot = .
replace rabnfcrot = .q if inw`wv'xt==1
label variable rabnfcrot "rabnfcrot: other person was beneficiary of r's estate"
label values rabnfcrot yesnoe


***spouse inherited home***
*wave 2 respondent spouse inherited home
gen rahomesp = .
replace rahomesp = .q if inw`wv'xt==1
label variable rahomesp "rahomesp: spouse owned or inherited r's home"
label values rahomesp yesnoe

***child/grandchild inherited home***
*wave 2 respondent child/grandchild inherited home
gen rahomech = .
replace rahomech = .q if inw`wv'xt==1
label variable rahomech "rahomech: child/grandchild owned or inherited r's home"
label values rahomech yesnoe

***relative inherited home***
*wave 2 respondent relative inherited home
gen rahomerl = .
replace rahomerl = .q if inw`wv'xt==1
label variable rahomerl "rahomerl: relative owned or inherited r's home"
label values rahomerl yesnoe

***other inherited home***
*wave 2 respondent other inherited home
gen rahomeot = .
replace rahomeot = .q if inw`wv'xt==1
label variable rahomeot "rahomeot: other person owned or inherited r's home"
label values rahomeot yesnoe


***whether spouse was beneficiary of pension***
*wave 2 respondent spouse was beneficiary
gen rapensp = .
missing_w2 EiRRel EiPenWho EiPenWh2 EiPenWh3 if inw`wv'xt==1, result(rapensp)
replace rapensp = .d if EiPenM==3 | EiPen96==1 | EiPen98==1 | EiPen100==1
replace rapensp = .n if EiPenM==2 | EiPen5==1 | EiPen10==1 | EiPen15==1
replace rapensp = .o if EiPen95==1 | EiPen97==1 | EiPen99==1
replace rapensp = 0 if EiPenWho==1 | EiPenWh2==1 | EiPenWh3==1 | ///
												inrange(EiPenWho,4,23) | inrange(EiPenWh2,4,23) | inrange(EiPenWh3,4,23) 
replace rapensp = 1 if inlist(EiPenWho,2,3) | inlist(EiPenWh2,2,3) | inlist(EiPenWh3,2,3) | ///
												((EiPenWho==1 | EiPenWh2==1 | EiPenWh3==1) & inlist(EiRRel,1,2)) 
label variable rapensp "rapensp: r's spouse beneficiary of pension"
label values rapensp yesnopension

***whether child/grandchild was beneficary of pension***
*wave 2 respondent child/grandchild was beneficiary
gen rapencg = .
missing_w2 EiRRel EiPenWho EiPenWh2 EiPenWh3 if inw`wv'xt==1, result(rapencg)
replace rapencg = .d if EiPenM==3 | EiPen96==1 | EiPen98==1 | EiPen100==1
replace rapencg = .n if EiPenM==2 | EiPen5==1 | EiPen10==1 | EiPen15==1
replace rapencg = .o if EiPen95==1 | EiPen97==1 | EiPen99==1
replace rapencg = 0 if inlist(EiPenWho,1,2,3,21,22,23) | inlist(EiPenWh2,1,2,3,21,22,23) | inlist(EiPenWh3,1,2,3,21,22,23) | ///
												inrange(EiPenWho,9,19) | inrange(EiPenWh2,9,19) | inrange(EiPenWh3,9,19) 
replace rapencg = 1 if inlist(EiPenWho,4,5,6,7,8,20) | inlist(EiPenWh2,4,5,6,7,8,20) | inlist(EiPenWh3,4,5,6,7,8,20) | ///
												((EiPenWho==1 | EiPenWh2==1 | EiPenWh3==1) & inlist(EiRRel,3,4,5,6,7,19)) 
label variable rapencg "rapencg: r's child/grandchild beneficiary of pension"
label values rapencg yesnopension

***whether relative was beneficiary of pension***
*wave 2 respondent relative was beneficiary
gen rapenrl = .
missing_w2 EiRRel EiPenWho EiPenWh2 EiPenWh3 if inw`wv'xt==1, result(rapenrl)
replace rapenrl = .d if EiPenM==3 | EiPen96==1 | EiPen98==1 | EiPen100==1
replace rapenrl = .n if EiPenM==2 | EiPen5==1 | EiPen10==1 | EiPen15==1
replace rapenrl = .o if EiPen95==1 | EiPen97==1 | EiPen99==1
replace rapenrl = 0 if inrange(EiPenWho,1,8) | inrange(EiPenWh2,1,8) | inrange(EiPenWh3,1,8) | ///
												inlist(EiPenWho,20,23) | inlist(EiPenWh2,20,23) | inlist(EiPenWh3,20,23) 
replace rapenrl = 1 if inrange(EiPenWho,9,19) | inrange(EiPenWh2,9,19) | inrange(EiPenWh3,9,19) | ///
												inlist(EiPenWho,21,22) | inlist(EiPenWh2,21,22) | inlist(EiPenWh3,21,22) | ///
												((EiPenWho==1 | EiPenWh2==1 | EiPenWh3==1) & (inrange(EiRRel,8,18) | inlist(EiRRel,20,21))) 
label variable rapenrl "rapenrl: r's relative beneficiary of pension"
label values rapenrl yesnopension

***whether other person was beneficiary of pension***
*wave 2 respondent other person was beneficiary
gen rapenot = .
missing_w2 EiRRel EiPenWho EiPenWh2 EiPenWh3 if inw`wv'xt==1, result(rapenot)
replace rapenot = .d if EiPenM==3 | EiPen96==1 | EiPen98==1 | EiPen100==1
replace rapenot = .n if EiPenM==2 | EiPen5==1 | EiPen10==1 | EiPen15==1
replace rapenot = .o if EiPen95==1 | EiPen97==1 | EiPen99==1
replace rapenot = 0 if inrange(EiPenWho,1,22) | inrange(EiPenWh2,1,22) | inrange(EiPenWh3,1,22) 
replace rapenot = 1 if EiPenWho==23 | EiPenWh2==23 | EiPenWh3==23 | ///
												((EiPenWho==1 | EiPenWh2==1 | EiPenWh3==1) & EiRRel==22) 
label variable rapenot "rapenot: r other person beneficiary of pension"
label values rapenot yesnopension


***death expenses***
*wave 2 respondent death expenses
*paid on own
gen selfmin = .
gen selfmax = .

gen selfo = .
replace selfo = 0 if EiDcstb==2
replace selfo = 1 if inlist(EiDcstb,1,3)

gen self = Eidcsta if inrange(Eidcsta,0,10000)

*paid by ins
gen insmin = .
gen insmax = .

gen inso = .
replace inso = 0 if EiDcstb==3
replace inso = 1 if inlist(EiDcstb,1,2)

gen ins = Eifuins if inrange(Eifuins,0,10000)

gen radexpense = .
label variable radexpense "radexpense: r death expense: total"

*wave 2 respondent death expenses flag
gen radexpensef = .
label variable radexpensef "radexpensef: r death expense flag: total"
label values radexpensef eolflag


***any costs covered by insurance (excl. life)***
*wave 2 respondent any costs covered by insurance
gen rainscovr = .
missing_w2 EiDcstb radexpense if inw`wv'xt==1, result(rainscovr)
replace rainscovr = 0 if EiDcstb==3
replace rainscovr = 1 if inlist(EiDcstb,1,2)
label variable rainscovr "rainscovr: r death expenses covered by insurance"
label values rainscovr yesnoe


***amount insurance paid out***
*wave 2 respondent amount insurance paid out
gen rainspaid = .
label variable rainspaid "rainspaid: r death expense: insurance paid out"

*wave 2 respondent amount insurance paid out flag
gen rainspaidf = .
label variable rainspaidf "rainspaidf: r death expense flag: insurance paid out"
label values rainspaidf eolflag


***has living will***
*wave 2 respondent has living will
gen ralvwill = .
replace ralvwill = .q if inw`wv'xt==1
label variable ralvwill "ralvwill: r whether had living will"
label values ralvwill yesnolvwill


***desire to limit care in certain situations***
*wave 2 respondent desire to limit care in certain situations
gen ralmtcare = .
replace ralmtcare = .q if inw`wv'xt==1
label variable ralmtcare "ralmtcare: r had desire to limit care"
label values ralmtcare yesnolvwill


***whether had a durable power of attorney for healthcare***
*wave 2 respondent whether had a durable power of attorney for healthcare
gen radpoafh = .
replace radpoafh = .q if inw`wv'xt==1
label variable radpoafh "radpoafh: r durable power of attorney for healthcare"
label values radpoafh yesnodpoa


***Whether spouse was dpoafh***
*wave 2 respondent spouse was dpoafh
gen radpoasp = .
replace radpoasp = .q if inw`wv'xt==1
label variable radpoasp "radpoasp: r spouse was durable power of attorney"
label values radpoasp yesnodpoa


***Whether child was dpoafh***
*wave 2 respondent child was dpoafh
gen radpoach = .
replace radpoach = .q if inw`wv'xt==1
label variable radpoach "radpoach: r child/grandchild was durable power of attorney"
label values radpoach yesnodpoa


***Whether relative was dpoafh***
*wave 2 respondent relative was dpoafh
gen radpoarl = .
replace radpoarl = .q if inw`wv'xt==1
label variable radpoarl "radpoarl: r relative was durable power of attorney"
label values radpoarl yesnodpoa


***Whether friend was dpoafh***
*wave 2 respondent friend was dpoafh
gen radpoafr = .
replace radpoafr = .q if inw`wv'xt==1
label variable radpoafr "radpoafr: r friend was durable power of attorney"
label values radpoafr yesnodpoa


***Whether non-relative was dpoafh***
*wave 2 respondent non-relative was dpoafh
gen radpoanr = .
replace radpoanr = .q if inw`wv'xt==1
label variable radpoanr "radpoanr: r non-relative proxy was durable power of attorney"
label values radpoanr yesnodpoa


***Whether doctor was dpoafh***
*wave 2 respondent doctor was dpoafh
gen radpoadr = .
replace radpoadr = .q if inw`wv'xt==1
label variable radpoadr "radpoadr: r doctor was durable power of attorney"
label values radpoadr yesnodpoa


***Whether religious advisor was dpoafh***
*wave 2 respondent religious advisor was dpoafh
gen radpoara = .
replace radpoara = .q if inw`wv'xt==1
label variable radpoara "radpoara: r religious advisor was durable power of attorney"
label values radpoara yesnodpoa


***Whether legal professional was dpoafh***
*wave 2 respondent legal professional was dpoafh
gen radpoalp = .
replace radpoalp = .q if inw`wv'xt==1
label variable radpoalp "radpoalp: r legal professional was durable power of attorney"
label values radpoalp yesnodpoa


***Whether social worker was dpoafh***
*wave 2 respondent social worker was dpoafh
gen radpoasw = .
replace radpoasw = .q if inw`wv'xt==1
label variable radpoasw "radpoasw: r social worker was durable power of attorney"
label values radpoasw yesnodpoa


***Whether other was dpoafh***
*wave 2 respondent other was dpoafh
gen radpoaot = .
replace radpoaot = .q if inw`wv'xt==1
label variable radpoaot "radpoaot: r other person was durable power of attorney"
label values radpoaot yesnodpoa


***whether non-family member was dpoafh***
*wave 2 respondent non-family member was dpoafh
gen radpoanf = .
replace radpoanf = .q if inw`wv'xt==1
label variable radpoanf "radpoanf: r non-family member was durable power of attorney"
label values radpoanf yesnodpoa


***any life insurance policies***
*wave 2 respondent any life insurance policies
gen raxlifeins = .
replace raxlifeins = .q if inw`wv'xt==1
label variable raxlifeins "raxlifeins: r any life insurance settlement"
label values raxlifeins yesnolfins


***whether spouse is beneficiary of life insurance policies***
*wave 2 respondent spouse is beneficiary of life insurance policies
gen ralfinssp = .
replace ralfinssp = .q if inw`wv'xt==1
label variable ralfinssp "ralfinssp: r spouse beneficiary of life ins"
label values ralfinssp yesnolfins


***whether child is beneficiary of life insurance policies***
*wave 2 respondent child is beneficiary of life insurance policies
gen ralfinsch = .
replace ralfinsch = .q if inw`wv'xt==1
label variable ralfinsch "ralfinsch: r child beneficiary of life ins"
label values ralfinsch yesnolfins


***whether grandchild is beneficiary of life insurance policies***
*wave 2 respondent grandchild is beneficiary of life insurance policies
gen ralfinsgk = .
replace ralfinsgk = .q if inw`wv'xt==1
label variable ralfinsgk "ralfinsgk: r grandchild beneficiary of life ins"
label values ralfinsgk yesnolfins


***whether relative is beneficiary of life insurance policies***
*wave 2 respondent relative is beneficiary of life insurance policies
gen ralfinsrl = .
replace ralfinsrl = .q if inw`wv'xt==1
label variable ralfinsrl "ralfinsrl: r relative beneficiary of life ins"
label values ralfinsrl yesnolfins


***whether other non-relative is beneficiary of life insurance policies***
*wave 2 respondent other non-relative is beneficiary of life insurance policies
gen ralfinsot = .
replace ralfinsot = .q if inw`wv'xt==1
label variable ralfinsot "ralfinsot: r other non-relative beneficiary of life ins"
label values ralfinsot yesnolfins


***value of life insurance policies***
*wave 2 respondent value of life insurance policies
gen ralfinsv = .
label variable ralfinsv "ralfinsv: r life insurance: total payout"

*wave 2 respondent value of life insurance policies flag
gen ralfinsvf = .
label variable ralfinsvf "ralfinsvf: r life insurance flag: total payout"
label values ralfinsvf eolflagval



***drop H_ELSA wave 2 core file raw variables***
drop `eolxt_w2_exit'



******************************************************************************************


*set wave number
local wv=3
local pre_wv=2

***merge with wave 3 exit data***
local eolxt_w3_exit EiWillA EiProb EiWillB Eidcsta EiDcstb DVEifuins EiAsCk EiLI EiLIWh1 EiLIWh2 EiLIWh3 ///
										EiLIWh4 EiLIWh5 EiLIWh6 EiLIWh7 EiLIWh8 EiLIWh9 EiLIWh10 EiLIWh11 EiLIWh12 EiLIWh13 EiLIWh14 ///
										EiLIWh15 EiLIWh16 EiLIWh17 EiLIWh18 EiLIWh19 EiLIWh20 EiLIWh21 EiLIWh22 EiLIWh23 ///
										EiRRel DVEiLIa EiPenWho EiPenWh2 EiPenWh3 EiKin EiBen EiSp EiSp2 EioIn EioIn2 EiSpInH EiSpInH2 EiHome ///
										EiHowH1 EiHowH2 EiHowH3 EiHowH4 EiHowH5 EiHowH6 EiHowH7 EiHowH8 EiHowH9 EiHowH10 EiHowH11 EiHowH12 EiHowH13 ///
										EiHowH14 EiHowH15 EiHowH16 EiHowH17 EiHowH18 EiHowH19 EiHowH20 EiHowH21 EiHowH22 EiHowH23 EiHowH36 EiHowH37 ///
										EiHowH39 EiHowH40 EiHowH41 EiHowH42 EiHowH43 EiHowH44 EiHowH45 EiHowH46 EiHowH47 EiHowH48 EiHowH49 ///
										EiHowH51 EiHowH52 EiHowH53 EiHowH54 EiHowH55 EiHowH56 EiHowH50 EiHowH57 EiHowH58 EiHowH59 EiHowH60 EiHowH61 ///
										EiOthO1 EiOthO2 EiOthO3 EiOthO4 EiOthO5 EiOthO6 EiOthO7 EiOthO8 EiOthO9 EiOthO10 EiOthO11 EiOthO12 EiOthO13 ///
										EiOthO14 EiOthO15 EiOthO16 EiOthO17 EiOthO18 EiOthO19 EiOthO20 EiOthO21 EiOthO22 EiOthO23 ///
										EiOthO24 EiOthO25 EiOthO26 EiOthO27 EiOthO28 EiOthO29 EiOthO30 EiOthO31 EiOthO32 EiOthO33 EiOthO34 EiOthO35 ///
										EiOthO36 EiOthO37 EiOthO38 EiOthO39 EiOthO40 EiOthO41 EiOthO42 EiOthO43 EiOthO44 EiOthO45 EiOthO46 ///
										EioInW1 EioInW2 EioInW3 EioInW4 EioInW5 EioInW6 EioInW7 EioInW8 EioInW9 EioInW10 EioInW11 EioInW12 EioInW13 ///
										EioInW14 EioInW15 EioInW16 EioInW17 EioInW18 EioInW19 EioInW20 EioInW21 EioInW22 EioInW23 EioInW24 EioInW25 ///
										EioInW26 EioInW27 EioInW28 EioInW29 EioInW30 EioInW31 EioInW32 EioInW33 EioInW34 EioInW35 EioInW36 EioInW37 ///
										EioInW38 EioInW39 EioInW40 EioInW41 EioInW42 EioInW43 EioInW44 EioInW45 EioInW46 ///
										EioHwH1 EioHwH2 EioHwH3 EioHwH4 EioHwH5 EioHwH6 EioHwH7 EioHwH8 EioHwH9 EioHwH10 EioHwH11 EioHwH12 EioHwH13 ///
										EioHwH14 EioHwH15 EioHwH16 EioHwH17 EioHwH18 EioHwH19 EioHwH20 EioHwH21 EioHwH22 EioHwH23 ///
										EioHwH24 EioHwH25 EioHwH26 EioHwH27 EioHwH28 EioHwH29 EioHwH30 EioHwH31 EioHwH32 EioHwH33 EioHwH34 EioHwH35 ///
										EioHwH36 EioHwH37 EioHwH38 EioHwH39 EioHwH40 EioHwH41 EioHwH42 EioHwH43 EioHwH44 EioHwH45 EioHwH46 ///
										EIPhyWh1 EIPhyWh2 EIPhyWh3 EIPhyWh4 EIPhyWh5 EIPhyWh6 EIPhyWh7 EIPhyWh8 EIPhyWh9 EIPhyW10 EIPhyW11 EIPhyW12 ///
										EIPhyW13 EIPhyW14 EIPhyW15 EIPhyW16 EIPhyW17 EIPhyW18 EIPhyW19 EIPhyW20 EIPhyW21 EIPhyW22 EIPhyW23 ///
										EiOthAs1 EiOthAs2 EiOthAs3 EiOthAs4 EiOthAs5 EiOthAs6 EiOthAs7 EiOthAs8 EiOthAs9 EiOthA10 EiOthA11 EiOthA12 ///
										EiOthA13 EiOthA14 EiOthA15 EiOthA16 EiOthA17 EiOthA18 EiOthA19 EiOthA20 EiOthA21 EiOthA22 EiOthA23 EiOthA24 ///
										EiPenM EiPen5 EiPen10 EiPen15 EiPen95 EiPen96 EiPen97 EiPen98 EiPen99 EiPen100 ///
										EiHowH1 EiHowH2 EiHowH3 EiHowH4 EiHowH5 EiHowH6 EiHowH7 EiHowH8 EiHowH9 EiHowH10 EiHowH11 EiHowH12 EiHowH13 ///
										EiHowH14 EiHowH15 EiHowH16 EiHowH17 EiHowH18 EiHowH19 EiHowH20 EiHowH21 EiHowH22 EiHowH23 EiHowH36 EiHowH37 ///
										EiOthO1 EiOthO2 EiOthO3 EiOthO4 EiOthO5 EiOthO6 EiOthO7 EiOthO8 EiOthO9 EiOthO10 EiOthO11 EiOthO12 ///
										EiOthO13 EiOthO14 EiOthO15 EiOthO16 EiOthO17 EiOthO18 EiOthO19 EiOthO20 EiOthO21 EiOthO22 EiOthO23 /// 
										EioHwH1 EioHwH2 EioHwH3 EioHwH4 EioHwH5 EioHwH6 EioHwH7 EioHwH8 EioHwH9 EioHwH10 EioHwH11 EioHwH12 ///
										EioHwH13 EioHwH14 EioHwH15 EioHwH16 EioHwH17 EioHwH18 EioHwH19 EioHwH20 EioHwH21 EioHwH22 EioHwH23 ///
										EioInW1 EioInW2 EioInW3 EioInW4 EioInW5 EioInW6 EioInW7 EioInW8 EioInW9 EioInW10 EioInW11 EioInW12 ///
										EioInW13 EioInW14 EioInW15 EioInW16 EioInW17 EioInW18 EioInW19 EioInW20 EioInW21 EioInW22 EioInW23 
merge 1:1 idauniq using "$wave_3_xt", keepusing(`eolxt_w3_exit') nogen




gen notdist = .
replace notdist = 1 if EiAsCk==2

***whether had a witnessed will***
*wave 3 respondent whether had a witnessed will
missing_w3 EiWillA EiAsCk if inw`wv'xt==1, result(rawitwill)
replace rawitwill = .d if EiWillA==3
replace rawitwill = .t if EiAsCk==2 & EiWillA==-1
replace rawitwill = 0 if EiWillA==2
replace rawitwill = 1 if EiWillA==1


***whether will has been through probate***
*wave 3 respondent whether will has been through probate
missing_w3 EiWillB EiProb rawitwill if inw`wv'xt==1, result(raprobate)
replace raprobate = .d if EiProb==3
replace raprobate = .t if EiAsCk==2 & EiWillA==-1
replace raprobate = .w if rawitwill==0 & inw`wv'xt==1
replace raprobate = 1 if EiProb==2 
replace raprobate = 2 if EiProb==1 & EiWillB==2
replace raprobate = 3 if EiProb==1 & EiWillB==1

***whether proxy was beneficiary of will***
*wave 3 respondent proxy was beneficiary
missing_w3 EiBen rawitwill if inw`wv'xt==1, result(rawillp)
replace rawillp = .t if EiAsCk==2
replace rawillp = .w if rawitwill==0 & inw`wv'xt==1
replace rawillp = 0 if EiBen==2 //proxy will beneficiary
replace rawillp = 1 if EiBen==1 //proxy will beneficiary


***whether spouse was beneficiary of estate***
*wave 3 respondent spouse was beneficiary
missing_w3 EiRRel EiAsCk EiOthA24 EiOthAs1 EiOthAs2 EiOthAs3 if inw`wv'xt==1, result(rabnfcrsp)
replace rabnfcrsp = .t if EiAsCk==2
replace rabnfcrsp = 0 if EiSp==2 //house: w sp, spouse
replace rabnfcrsp = 0 if EiHowH2==0 | EiHowH3==0 | EiHowH1==0 | (EiHowH1==1 & inrange(EiRRel,3,22)) //house: w sp, other
replace rabnfcrsp = 0 if EioHwH2==0 | EioHwH3==0 | EioHwH1==0 | (EioHwH1==1 & inrange(EiRRel,3,22)) //house: sole, other
replace rabnfcrsp = 0 if EioIn==2 | (EioIn==1 & ((EiOthO2==0 | EiOthO3==0 | EiOthO1==0) | (EiOthO1==1 & inrange(EiRRel,3,22)))) //house: joint, owners
replace rabnfcrsp = 0 if EioInW2==0 | EioInW3==0 | EioInW1==0 | (EioInW1==1 & inrange(EiRRel,3,22)) //house: joint, other
replace rabnfcrsp = 0 if EiSp2==2 //other prop: w sp, spouse
replace rabnfcrsp = 0 if EiHowH40==0 | EiHowH41==0 | EiHowH39==0 | (EiHowH39==1 & inrange(EiRRel,3,22)) //other prop: w sp, other
replace rabnfcrsp = 0 if EioHwH25==0 | EioHwH26==0 | EioHwH24==0 | (EioHwH24==1 & inrange(EiRRel,3,22)) //other prop: sole, other
replace rabnfcrsp = 0 if EioIn2==2 | (EioIn2==1 & ((EiOthO25==0 | EiOthO26==0 | EiOthO24==0) | (EiOthO24==1 & inrange(EiRRel,3,22)))) //other prop: joint, owners
replace rabnfcrsp = 0 if EioInW25==0 | EioInW26==0 | EioInW24==0 | (EioInW24==1 & inrange(EiRRel,3,22)) //other prop: joint, other 
replace rabnfcrsp = 0 if EIPhyWh2==0 | EIPhyWh3==0 | EIPhyWh1==0 | (EIPhyWh1==1 & inrange(EiRRel,3,22)) //business
replace rabnfcrsp = 0 if EiOthA24==1 | EiOthAs2==0 | EiOthAs3==0 | EiOthAs1==0 | (EiOthAs1==1 & inrange(EiRRel,3,22)) //other assets
replace rabnfcrsp = 1 if EiSp==1 //house: w sp, spouse
replace rabnfcrsp = 1 if EiHowH2==1 | EiHowH3==1 | (EiHowH1==1 & inlist(EiRRel,1,2)) //house: w sp, other
replace rabnfcrsp = 1 if EioHwH2==1 | EioHwH3==1 | (EioHwH1==1 & inlist(EiRRel,1,2)) //house: sole, other
replace rabnfcrsp = 1 if EioIn==1 & ((EiOthO2==1 | EiOthO3==1) | (EiOthO1==1 & inlist(EiRRel,1,2))) //house: joint, owners
replace rabnfcrsp = 1 if EioInW2==1 | EioInW3==1 | (EioInW1==1 & inlist(EiRRel,1,2)) //house: joint, other
replace rabnfcrsp = 1 if EiSp2==1 //other prop: w sp, spouse
replace rabnfcrsp = 1 if EiHowH40==1 | EiHowH41==1 | (EiHowH39==1 & inlist(EiRRel,1,2)) //other prop: w sp, other
replace rabnfcrsp = 1 if EioHwH25==1 | EioHwH26==1 | (EioHwH24==1 & inlist(EiRRel,1,2)) //other prop: sole, other
replace rabnfcrsp = 1 if EioIn2==1 & ((EiOthO25==1 | EiOthO26==1) | (EiOthO24==1 & inlist(EiRRel,1,2))) //other prop: joint, owners
replace rabnfcrsp = 1 if EioInW25==1 | EioInW26==1 | (EioInW24==1 & inlist(EiRRel,1,2)) //other prop: joint, other
replace rabnfcrsp = 1 if EIPhyWh2==1 | EIPhyWh3==1 | (EIPhyWh1==1 & inlist(EiRRel,1,2)) //business
replace rabnfcrsp = 1 if EiOthAs2==1 | EiOthAs3==1 | (EiOthAs1==1 & inlist(EiRRel,1,2)) //other assets

***whether child/grandchild was beneficary of estate***
*wave 3 respondent child/grandchild was beneficiary
missing_w3 EiRRel EiAsCk EiOthA24 EiOthAs1 EiOthAs2 EiOthAs3 if inw`wv'xt==1, result(rabnfcrcg)
replace rabnfcrcg = .t if EiAsCk==2
replace rabnfcrcg = 0 if EiSp==1 & EiSpInH==1 //house: w sp, spouse
replace rabnfcrcg = 0 if EiHowH4==0 | EiHowH5==0 | EiHowH6==0 | EiHowH7==0 | EiHowH8==0 | EiHowH20==0 | ///
												EiHowH1==0 | (EiHowH1==1 & (inlist(EiRRel,1,2,20,21,22) | inrange(EiRRel,8,18))) //house: w sp, other
replace rabnfcrcg = 0 if EioHwH4==0 | EioHwH5==0 | EioHwH6==0 | EioHwH7==0 | EioHwH8==0 | EioHwH20==0 | ///
												EioHwH1==0 | (EioHwH1==1 & (inlist(EiRRel,1,2,20,21,22) | inrange(EiRRel,8,18))) //house: sole, other
replace rabnfcrcg = 0 if EioIn==2 | (EioIn==1 & ((EiOthO4==0 | EiOthO5==0 | EiOthO6==0 | EiOthO7==0 | EiOthO8==0 | EiOthO20==0 | EiOthO1==0) | ///
												(EiOthO1==1 & (inlist(EiRRel,1,2,20,21,22) | inrange(EiRRel,8,18))))) //house: joint, owners
replace rabnfcrcg = 0 if EioInW4==0 | EioInW5==0 | EioInW6==0 | EioInW7==0 | EioInW8==0 | EioInW20==0 | ///
												EioInW1==0 | (EioInW1==1 & (inlist(EiRRel,1,2,20,21,22) | inrange(EiRRel,8,18))) //house: joint, other
replace rabnfcrcg = 0 if EiSp2==1 & EiSpInH2==1 //other prop: w sp, spouse
replace rabnfcrcg = 0 if EiHowH42==0 | EiHowH43==0 | EiHowH44==0 | EiHowH45==0 | EiHowH46==0 | EiHowH58==0 | ///
												EiHowH39==0 | (EiHowH39==1 & (inlist(EiRRel,1,2,20,21,22) | inrange(EiRRel,8,18))) //other prop: w sp, other
replace rabnfcrcg = 0 if EioHwH27==0 | EioHwH28==0 | EioHwH29==0 | EioHwH30==0 | EioHwH31==0 | EioHwH43==0 | ///
												EioHwH24==0 | (EioHwH24==1 & (inlist(EiRRel,1,2,20,21,22) | inrange(EiRRel,8,18))) //other prop: sole, other
replace rabnfcrcg = 0 if EioIn2==2 | (EioIn2==1 & ((EiOthO27==0 | EiOthO28==0 | EiOthO29==0 | EiOthO30==0 | EiOthO31==0 | EiOthO43==0 | EiOthO24==0) | ///
												(EiOthO24==1 & (inlist(EiRRel,1,2,20,21,22) | inrange(EiRRel,8,18))))) //other prop: joint, owners
replace rabnfcrcg = 0 if EioInW27==0 | EioInW28==0 | EioInW29==0 | EioInW30==0 | EioInW31==0 | EioInW43==0 | ///
												EioInW24==0 | (EioInW24==1 & (inlist(EiRRel,1,2,20,21,22) | inrange(EiRRel,8,18))) //other prop: joint, other
replace rabnfcrcg = 0 if EIPhyWh4==0 | EIPhyWh5==0 | EIPhyWh6==0 | EIPhyWh7==0 | EIPhyWh8==0 | EIPhyW20==0 | ///
												EIPhyWh1==0 | (EIPhyWh1==1 & (inlist(EiRRel,1,2,20,21,22) | inrange(EiRRel,8,18))) //business
replace rabnfcrcg = 0 if EiOthA24==1 | EiOthAs4==0 | EiOthAs5==0 | EiOthAs6==0 | EiOthAs7==0 | EiOthAs8==0 | EiOthA20==0 | ///
												EiOthAs1==0 | (EiOthAs1==1 & (inlist(EiRRel,1,2,20,21,22) | inrange(EiRRel,8,18))) //other assets 
replace rabnfcrcg = 1 if EiHowH4==1 | EiHowH5==1 | EiHowH6==1 | EiHowH7==1 | EiHowH8==1 | EiHowH20==1 | ///
												EiHowH1==0 | (EiHowH1==1 & inlist(EiRRel,3,4,5,6,7,19)) //house: w sp, other
replace rabnfcrcg = 1 if EioHwH4==1 | EioHwH5==1 | EioHwH6==1 | EioHwH7==1 | EioHwH8==1 | EioHwH20==1 | ///
												EioHwH1==0 | (EioHwH1==1 & inlist(EiRRel,3,4,5,6,7,19)) //house: sole, other
replace rabnfcrcg = 1 if EioIn==1 & ((EiOthO4==1 | EiOthO5==1 | EiOthO6==1 | EiOthO7==1 | EiOthO8==1 | EiOthO20==1) | ///
												(EiOthO1==1 & inlist(EiRRel,3,4,5,6,7,19))) //house: joint, owners
replace rabnfcrcg = 1 if EioInW4==1 | EioInW5==1 | EioInW6==1 | EioInW7==1 | EioInW8==1 | EioInW20==1 | ///
												EioInW1==0 | (EioInW1==1 & inlist(EiRRel,3,4,5,6,7,19)) //house: joint, other						
replace rabnfcrcg = 1 if EiHowH42==1 | EiHowH43==1 | EiHowH44==1 | EiHowH45==1 | EiHowH46==1 | EiHowH58==1 | ///
												EiHowH39==0 | (EiHowH39==1 & inlist(EiRRel,3,4,5,6,7,19)) //other prop: w sp, other
replace rabnfcrcg = 1 if EioHwH27==1 | EioHwH28==1 | EioHwH29==1 | EioHwH30==1 | EioHwH31==1 | EioHwH43==1 | ///
												EioHwH24==0 | (EioHwH24==1 & inlist(EiRRel,3,4,5,6,7,19)) //other prop: sole, other
replace rabnfcrcg = 1 if EioIn2==1 & ((EiOthO27==1 | EiOthO28==1 | EiOthO29==1 | EiOthO30==1 | EiOthO31==1 | EiOthO43==1) | ///
												(EiOthO24==1 & inlist(EiRRel,3,4,5,6,7,19))) //other prop: joint, owners
replace rabnfcrcg = 1 if EioInW27==1 | EioInW28==1 | EioInW29==1 | EioInW30==1 | EioInW31==1 | EioInW43==1 | ///
												EioInW24==0 | (EioInW24==1 & inlist(EiRRel,3,4,5,6,7,19)) //other prop: joint, other					
replace rabnfcrcg = 1 if EIPhyWh4==1 | EIPhyWh5==1 | EIPhyWh6==1 | EIPhyWh7==1 | EIPhyWh8==1 | EIPhyW20==1 | ///
												(EIPhyWh1==1 & inlist(EiRRel,3,4,5,6,7,19)) //business
replace rabnfcrcg = 1 if EiOthAs4==1 | EiOthAs5==1 | EiOthAs6==1 | EiOthAs7==1 | EiOthAs8==1 | EiOthA20==1 | ///
												(EiOthAs1==1 & inlist(EiRRel,3,4,5,6,7,19)) //other assets

***whether relative was beneficiary of estate***
*wave 3 respondent relative was beneficiary
missing_w3 EiRRel EiAsCk EiOthA24 EiOthAs1 EiOthAs2 EiOthAs3 if inw`wv'xt==1, result(rabnfcrrl)
replace rabnfcrrl = .t if EiAsCk==2
replace rabnfcrrl = 0 if EiSp==1 & EiSpInH==1 //house: only sp inherited
replace rabnfcrrl = 0 if EiHowH9==0 | EiHowH10==0 | EiHowH11==0 | EiHowH12==0 | EiHowH13==0 | EiHowH14==0 | ///
												EiHowH15==0 | EiHowH16==0 | EiHowH17==0 | EiHowH18==0 | EiHowH19==0 | EiHowH21==0 | EiHowH22==0 | ///
												EiHowH1==0 | (EiHowH1==1 & (inrange(EiRRel,1,7) | inlist(EiRRel,19,22))) //house: w sp, other
replace rabnfcrrl = 0 if EioHwH9==0 | EioHwH10==0 | EioHwH11==0 | EioHwH12==0 | EioHwH13==0 | EioHwH14==0 | ///
												EioHwH15==0 | EioHwH16==0 | EioHwH17==0 | EioHwH18==0 | EioHwH19==0 | EioHwH21==0 | EioHwH22==0 | ///
												EioHwH1==0 | (EioHwH1==1 & (inrange(EiRRel,1,7) | inlist(EiRRel,19,22))) //house: sole, other
replace rabnfcrrl = 0 if EioIn==2 | (EioIn==1 & ((EiOthO9==0 | EiOthO10==0 | EiOthO11==0 | EiOthO12==0 | EiOthO13==0 | EiOthO14==0 | ///
												EiOthO15==0 | EiOthO16==0 | EiOthO17==0 | EiOthO18==0 | EiOthO19==0 | EiOthO21==0 | EiOthO22==0 | EiOthO1==0) | ///
												(EiOthO1==1 & (inrange(EiRRel,1,7) | inlist(EiRRel,19,22))))) //house: joint, owners
replace rabnfcrrl = 0 if EioInW9==0 | EioInW10==0 | EioInW11==0 | EioInW12==0 | EioInW13==0 | EioInW14==0 | ///
												EioInW15==0 | EioInW16==0 | EioInW17==0 | EioInW18==0 | EioInW19==0 | EioInW21==0 | EioInW22==0 | ///
												EioInW1==0 | (EioInW1==1 & (inrange(EiRRel,1,7) | inlist(EiRRel,19,22))) //house: joint, other		
replace rabnfcrrl = 0 if EiSp2==1 & EiSpInH2==1 //other prop: only sp inherited
replace rabnfcrrl = 0 if EiHowH47==0 | EiHowH48==0 | EiHowH49==0 | EiHowH50==0 | EiHowH51==0 | EiHowH52==0 | ///
												EiHowH53==0 | EiHowH54==0 | EiHowH55==0 | EiHowH56==0 | EiHowH57==0 | EiHowH59==0 | EiHowH60==0 | ///
												EiHowH39==0 | (EiHowH39==1 & (inrange(EiRRel,1,7) | inlist(EiRRel,19,22))) //other prop: w sp, other
replace rabnfcrrl = 0 if EioHwH32==0 | EioHwH33==0 | EioHwH34==0 | EioHwH35==0 | EioHwH36==0 | EioHwH37==0 | ///
												EioHwH38==0 | EioHwH39==0 | EioHwH40==0 | EioHwH41==0 | EioHwH42==0 | EioHwH44==0 | EioHwH45==0 | ///
												EioHwH24==0 | (EioHwH24==1 & (inrange(EiRRel,1,7) | inlist(EiRRel,19,22))) //other prop: sole, other
replace rabnfcrrl = 0 if EioIn2==2 | (EioIn2==1 & ((EiOthO32==0 | EiOthO33==0 | EiOthO34==0 | EiOthO35==0 | EiOthO36==0 | EiOthO37==0 | ///
												EiOthO38==0 | EiOthO39==0 | EiOthO40==0 | EiOthO41==0 | EiOthO42==0 | EiOthO44==0 | EiOthO45==0 | EiOthO24==0) | ///
												(EiOthO24==1 & (inrange(EiRRel,1,7) | inlist(EiRRel,19,22))))) //other prop: joint, owners
replace rabnfcrrl = 0 if EioInW32==0 | EioInW33==0 | EioInW34==0 | EioInW35==0 | EioInW36==0 | EioInW37==0 | ///
												EioInW38==0 | EioInW39==0 | EioInW40==0 | EioInW41==0 | EioInW42==0 | EioInW44==0 | EioInW45==0 | ///
												EioInW24==0 | (EioInW24==1 & (inrange(EiRRel,1,7) | inlist(EiRRel,19,22))) //other prop: joint, other	
replace rabnfcrrl = 0 if EIPhyWh9==0 | EIPhyW10==0 | EIPhyW11==0 | EIPhyW12==0 | EIPhyW13==0 | EIPhyW14==0 | ///
												EIPhyW15==0 | EIPhyW16==0 | EIPhyW17==0 | EIPhyW18==0 | EIPhyW19==0 | EIPhyW21==0 | EIPhyW22==0 | ///
												EIPhyWh1==0 | (EIPhyWh1==1 & (inrange(EiRRel,1,7) | inlist(EiRRel,19,22))) //business
replace rabnfcrrl = 0 if EiOthA24==1 | EiOthAs9==0 | EiOthA10==0 | EiOthA11==0 | EiOthA12==0 | EiOthA13==0 | EiOthA14==0 | ///
												EiOthA15==0 | EiOthA16==0 | EiOthA17==0 | EiOthA18==0 | EiOthA19==0 | EiOthA21==0 | EiOthA22==0 | ///
												EiOthAs1==0 | (EiOthAs1==1 & (inrange(EiRRel,1,7) | inlist(EiRRel,19,22))) //other assets 
replace rabnfcrrl = 1 if EiHowH9==1 | EiHowH10==1 | EiHowH11==1 | EiHowH12==1 | EiHowH13==1 | EiHowH14==1 | ///
												EiHowH15==1 | EiHowH16==1 | EiHowH17==1 | EiHowH18==1 | EiHowH19==1 | EiHowH21==1 | EiHowH22==1 | ///
												(EiHowH1==1 & (inrange(EiRRel,8,18) | inlist(EiRRel,20,21))) //house: w sp, other
replace rabnfcrrl = 1 if EioHwH9==1 | EioHwH10==1 | EioHwH11==1 | EioHwH12==1 | EioHwH13==1 | EioHwH14==1 | ///
												EioHwH15==1 | EioHwH16==1 | EioHwH17==1 | EioHwH18==1 | EioHwH19==1 | EioHwH21==1 | EioHwH22==1 | ///
												(EioHwH1==1 & (inrange(EiRRel,8,18) | inlist(EiRRel,20,21))) //house: sole, other
replace rabnfcrrl = 1 if EioIn==1 & ((EiOthO9==1 | EiOthO10==1 | EiOthO11==1 | EiOthO12==1 | EiOthO13==1 | EiOthO14==1 | ///
												EiOthO15==1 | EiOthO16==1 | EiOthO17==1 | EiOthO18==1 | EiOthO19==1 | EiOthO21==1 | EiOthO22==1) | ///
												(EiOthO1==1 & (inrange(EiRRel,8,18) | inlist(EiRRel,20,21)))) //house: joint, owners
replace rabnfcrrl = 1 if EioInW9==1 | EioInW10==1 | EioInW11==1 | EioInW12==1 | EioInW13==1 | EioInW14==1 | ///
												EioInW15==1 | EioInW16==1 | EioInW17==1 | EioInW18==1 | EioInW19==1 | EioInW21==1 | EioInW22==1 | ///
												(EioInW1==1 & (inrange(EiRRel,8,18) | inlist(EiRRel,20,21))) //house: joint, other
replace rabnfcrrl = 1 if EiHowH47==1 | EiHowH48==1 | EiHowH49==1 | EiHowH50==1 | EiHowH51==1 | EiHowH52==1 | ///
												EiHowH53==1 | EiHowH54==1 | EiHowH55==1 | EiHowH56==1 | EiHowH57==1 | EiHowH59==1 | EiHowH60==1 | ///
												(EiHowH39==1 & (inrange(EiRRel,8,18) | inlist(EiRRel,20,21))) //other prop: w sp, other
replace rabnfcrrl = 1 if EioHwH32==1 | EioHwH33==1 | EioHwH34==1 | EioHwH35==1 | EioHwH36==1 | EioHwH37==1 | ///
												EioHwH38==1 | EioHwH39==1 | EioHwH40==1 | EioHwH41==1 | EioHwH42==1 | EioHwH44==1 | EioHwH45==1 | ///
												(EioHwH24==1 & (inrange(EiRRel,8,18) | inlist(EiRRel,20,21))) //other prop: sole, other
replace rabnfcrrl = 1 if EioIn2==1 & ((EiOthO32==1 | EiOthO33==1 | EiOthO34==1 | EiOthO35==1 | EiOthO36==1 | EiOthO37==1 | ///
												EiOthO38==1 | EiOthO39==1 | EiOthO40==1 | EiOthO41==1 | EiOthO42==1 | EiOthO44==1 | EiOthO45==1) | ///
												(EiOthO24==1 & (inrange(EiRRel,8,18) | inlist(EiRRel,20,21)))) //other prop: joint, owners
replace rabnfcrrl = 1 if EioInW32==1 | EioInW33==1 | EioInW34==1 | EioInW35==1 | EioInW36==1 | EioInW37==1 | ///
												EioInW38==1 | EioInW39==1 | EioInW40==1 | EioInW41==1 | EioInW42==1 | EioInW44==1 | EioInW45==1 | ///
												(EioInW24==1 & (inrange(EiRRel,8,18) | inlist(EiRRel,20,21))) //other prop: joint, other
replace rabnfcrrl = 1 if EIPhyWh9==1 | EIPhyW10==1 | EIPhyW11==1 | EIPhyW12==1 | EIPhyW13==1 | EIPhyW14==1 | ///
												EIPhyW15==1 | EIPhyW16==1 | EIPhyW17==1 | EIPhyW18==1 | EIPhyW19==1 | EIPhyW21==1 | EIPhyW22==1 | ///
												(EIPhyWh1==1 & (inrange(EiRRel,8,18) | inlist(EiRRel,20,21))) //business
replace rabnfcrrl = 1 if EiOthAs9==1 | EiOthA10==1 | EiOthA11==1 | EiOthA12==1 | EiOthA13==1 | EiOthA14==1 | ///
												EiOthA15==1 | EiOthA16==1 | EiOthA17==1 | EiOthA18==1 | EiOthA19==1 | EiOthA21==1 | EiOthA22==1 | ///
												(EiOthAs1==1 & (inrange(EiRRel,8,18) | inlist(EiRRel,20,21))) //other assets 

***whether other person was beneficiary of estate***
*wave 3 respondent other person was beneficiary
missing_w3 EiRRel EiAsCk EiOthA24 EiOthAs1 EiOthAs2 EiOthAs3 if inw`wv'xt==1, result(rabnfcrot)
replace rabnfcrot = .t if EiAsCk==2
replace rabnfcrot = 0 if EiSp==1 & EiSpInH==1 //house: only sp inherited
replace rabnfcrot = 0 if EiHowH23==0 | EiHowH36==0 | EiHowH37==0 | EiHowH1==0 | (EiHowH1==1 & inrange(EiRRel,1,21)) //house: w sp, other
replace rabnfcrot = 0 if EioHwH23==0 | EioHwH1==0 | (EioHwH1==1 & inrange(EiRRel,1,21)) //house: sole, other
replace rabnfcrot = 0 if EioIn==2 | (EioIn==1 & ((EiOthO23==0 | EiOthO1==0) | (EiOthO1==0 & inrange(EiRRel,1,21)))) //house: joint, owners
replace rabnfcrot = 0 if EioInW23==0 | EioInW1==0 | (EioInW1==1 & inrange(EiRRel,1,21)) //house: joint, other
replace rabnfcrot = 0 if EiSp2==1 & EiSpInH2==1 //other prop: only sp inherited
replace rabnfcrot = 0 if EiHowH61==0 | EiHowH39==0 | (EiHowH39==1 & inrange(EiRRel,1,21)) //other prop: w sp, other
replace rabnfcrot = 0 if EioHwH46==0 | EioHwH24==0 | (EioHwH24==1 & inrange(EiRRel,1,21)) //other prop: sole, other
replace rabnfcrot = 0 if EioIn2==2 | (EioIn2==1 & ((EiOthO46==0 | EiOthO24==0) | (EiOthO24==0 & inrange(EiRRel,1,21)))) //other prop: joint, owners
replace rabnfcrot = 0 if EioInW46==0 | EioInW24==0 | (EioInW24==1 & inrange(EiRRel,1,21)) //other prop: joint, other
replace rabnfcrot = 0 if EIPhyW23==0 | EIPhyWh1==0 | (EIPhyWh1==1 & inrange(EiRRel,1,21)) //business
replace rabnfcrot = 0 if EiOthA24==1 | EiOthA23==0 | EiOthAs1==0 | (EiOthAs1==1 & inrange(EiRRel,1,21)) //other assets
replace rabnfcrot = 1 if EiHowH23==1 | EiHowH36==1 | EiHowH37==1 | (EiHowH1==1 & EiRRel==22) //house: w sp, other
replace rabnfcrot = 1 if EioHwH23==1 | (EioHwH1==1 & EiRRel==22) //house: sole, other
replace rabnfcrot = 1 if EioIn==1 & (EiOthO23==1 | (EiOthO1==1 & EiRRel==22)) //house: joint, owners
replace rabnfcrot = 1 if EioInW23==1 | (EioInW1==1 & EiRRel==22) //house: joint, other
replace rabnfcrot = 1 if EiHowH61==1 | (EiHowH39==1 & EiRRel==22) //other prop: w sp, other
replace rabnfcrot = 1 if EioHwH46==1 | (EioHwH24==1 & EiRRel==22) //other prop: sole, other
replace rabnfcrot = 1 if EioIn2==1 & (EiOthO46==1 | (EiOthO24==1 & EiRRel==22)) //other prop: joint, owners
replace rabnfcrot = 1 if EioInW46==1 | (EioInW24==1 & EiRRel==22) //other prop: joint, other
replace rabnfcrot = 1 if EIPhyW23==1 | (EIPhyWh1==1 & EiRRel==22) //business
replace rabnfcrot = 1 if EiOthA23==1 | (EiOthAs1==1 & EiRRel==22) //other assets


***spouse inherited home***
*wave 3 respondent spouse inherited home
missing_w3 EiAsCk EiHome EiSp EiRRel EiHowH1 EioIn EiOthO1 EioInW1 EioHwH1 if inw`wv'xt==1, result(rahomesp)
replace rahomesp = .t if EiAsCk==2 & EiHome==-1
replace rahomesp = .x if EiHome==2
replace rahomesp = 0 if EiSp==2 //w sp, spouse 
replace rahomesp = 0 if EiHowH2==0 | EiHowH3==0 | EiHowH1==0 | (EiHowH1==1 & inrange(EiRRel,3,22)) //w sp, other
replace rahomesp = 0 if EioIn==2 | (EioIn==1 & ((EiOthO2==0 | EiOthO3==0 | EiOthO1==0) | (EiOthO1==1 & inrange(EiRRel,3,22)))) //joint, owners
replace rahomesp = 0 if EioInW2==0 | EioInW3==0 | EioInW1==0 | (EioInW1==1 & inrange(EiRRel,3,22)) //joint, other
replace rahomesp = 0 if EioHwH2==0 | EioHwH3==0 | EioHwH1==0 | (EioHwH1==1 & inrange(EiRRel,3,22)) //sole, other
replace rahomesp = 1 if EiSp==1 //w sp, spouse
replace rahomesp = 1 if EiHowH2==1 | EiHowH3==1 | (EiHowH1==1 & inlist(EiRRel,1,2)) //w sp, other
replace rahomesp = 1 if EioIn==1 & ((EiOthO2==1 | EiOthO3==1) | (EiOthO1==1 & inlist(EiRRel,1,2))) //joint, owners
replace rahomesp = 1 if EioInW2==1 | EioInW3==1 | (EioInW1==1 & inlist(EiRRel,1,2)) //joint, other
replace rahomesp = 1 if EioHwH2==1 | EioHwH3==1 | (EioHwH1==1 & inlist(EiRRel,1,2)) //sole, other

***child/grandchild inherited home***
*wave 3 respondent child/grandchild inherited home
missing_w3 EiAsCk EiHome EiRRel EiHowH1 EioIn EiOthO1 EioInW1 EioHwH1 EiSp EiSpInH if inw`wv'xt==1, result(rahomech)
replace rahomech = .t if EiAsCk==2 & EiHome==-1
replace rahomech = .x if EiHome==2
replace rahomech = 0 if EiSp==1 & EiSpInH==1 //only sp inherited
replace rahomech = 0 if EiHowH4==0 | EiHowH5==0 | EiHowH6==0 | EiHowH7==0 | EiHowH8==0 | EiHowH20==0 | ///
												EiHowH1==0 | (EiHowH1==1 & (inlist(EiRRel,1,2,20,21,22) | inrange(EiRRel,8,18))) //w sp, toher
replace rahomech = 0 if EioIn==2 | (EioIn==1 & ((EiOthO4==0 | EiOthO5==0 | EiOthO6==0 | EiOthO7==0 | EiOthO8==0 | EiOthO20==0 | EiOthO1==0) | ///
												(EiOthO1==1 & (inlist(EiRRel,1,2,20,21,22) | inrange(EiRRel,8,18))))) //joint, owners
replace rahomech = 0 if EioInW4==0 | EioInW5==0 | EioInW6==0 | EioInW7==0 | EioInW8==0 | EioInW20==0 | ///
												EioInW1==0 | (EioInW1==1 & (inlist(EiRRel,1,2,20,21,22) | inrange(EiRRel,8,18))) //joint, other
replace rahomech = 0 if EioHwH4==0 | EioHwH5==0 | EioHwH6==0 | EioHwH7==0 | EioHwH8==0 | EioHwH20==0 | ///
												EioHwH1==0 | (EioHwH1==1 & (inlist(EiRRel,1,2,20,21,22) | inrange(EiRRel,8,18))) //sole, other
replace rahomech = 1 if EiHowH4==1 | EiHowH5==1 | EiHowH6==1 | EiHowH7==1 | EiHowH8==1 | EiHowH20==1 | ///
												EiHowH1==0 | (EiHowH1==1 & inlist(EiRRel,3,4,5,6,7,19)) //w sp, other
replace rahomech = 1 if EioIn==1 & ((EiOthO4==1 | EiOthO5==1 | EiOthO6==1 | EiOthO7==1 | EiOthO8==1 | EiOthO20==1) | ///
												(EiOthO1==1 & inlist(EiRRel,3,4,5,6,7,19))) //joint, owners
replace rahomech = 1 if EioInW4==1 | EioInW5==1 | EioInW6==1 | EioInW7==1 | EioInW8==1 | EioInW20==1 | ///
												EioInW1==0 | (EioInW1==1 & inlist(EiRRel,3,4,5,6,7,19)) //joint, other 
replace rahomech = 1 if EioHwH4==1 | EioHwH5==1 | EioHwH6==1 | EioHwH7==1 | EioHwH8==1 | EioHwH20==1 | ///
												EioHwH1==0 | (EioHwH1==1 & inlist(EiRRel,3,4,5,6,7,19)) //sole, other

***relative inherited home***
*wave 3 respondent relative inherited home
missing_w3 EiAsCk EiHome EiRRel EiHowH1 EioIn EiOthO1 EioInW1 EioHwH1 EiSp EiSpInH if inw`wv'xt==1, result(rahomerl)
replace rahomerl = .t if EiAsCk==2 & EiHome==-1
replace rahomerl = .x if EiHome==2
replace rahomerl = 0 if EiSp==1 & EiSpInH==1 //only sp inherited
replace rahomerl = 0 if EiHowH9==0 | EiHowH10==0 | EiHowH11==0 | EiHowH12==0 | EiHowH13==0 | EiHowH14==0 | ///
												EiHowH15==0 | EiHowH16==0 | EiHowH17==0 | EiHowH18==0 | EiHowH19==0 | EiHowH21==0 | EiHowH22==0 | ///
												EiHowH1==0 | (EiHowH1==1 & (inrange(EiRRel,1,7) | inlist(EiRRel,19,22))) //w sp, other
replace rahomerl = 0 if EioIn==2 | (EioIn==1 & ((EiOthO9==0 | EiOthO10==0 | EiOthO11==0 | EiOthO12==0 | EiOthO13==0 | EiOthO14==0 | ///
												EiOthO15==0 | EiOthO16==0 | EiOthO17==0 | EiOthO18==0 | EiOthO19==0 | EiOthO21==0 | EiOthO22==0 | EiOthO1==0) | ///
												(EiOthO1==1 & (inrange(EiRRel,1,7) | inlist(EiRRel,19,22))))) //joint, owners
replace rahomerl = 0 if EioInW9==0 | EioInW10==0 | EioInW11==0 | EioInW12==0 | EioInW13==0 | EioInW14==0 | ///
												EioInW15==0 | EioInW16==0 | EioInW17==0 | EioInW18==0 | EioInW19==0 | EioInW21==0 | EioInW22==0 | ///
												EioInW1==0 | (EioInW1==1 & (inrange(EiRRel,1,7) | inlist(EiRRel,19,22))) //joint, other 
replace rahomerl = 0 if EioHwH9==0 | EioHwH10==0 | EioHwH11==0 | EioHwH12==0 | EioHwH13==0 | EioHwH14==0 | ///
												EioHwH15==0 | EioHwH16==0 | EioHwH17==0 | EioHwH18==0 | EioHwH19==0 | EioHwH21==0 | EioHwH22==0 | ///
												EioHwH1==0 | (EioHwH1==1 & (inrange(EiRRel,1,7) | inlist(EiRRel,19,22))) //sole, other
replace rahomerl = 1 if EiHowH9==1 | EiHowH10==1 | EiHowH11==1 | EiHowH12==1 | EiHowH13==1 | EiHowH14==1 | ///
												EiHowH15==1 | EiHowH16==1 | EiHowH17==1 | EiHowH18==1 | EiHowH19==1 | EiHowH21==1 | EiHowH22==1 | ///
												(EiHowH1==1 & (inrange(EiRRel,8,18) | inlist(EiRRel,20,21))) //w sp, other
replace rahomerl = 1 if EioIn==1 & ((EiOthO9==1 | EiOthO10==1 | EiOthO11==1 | EiOthO12==1 | EiOthO13==1 | EiOthO14==1 | ///
												EiOthO15==1 | EiOthO16==1 | EiOthO17==1 | EiOthO18==1 | EiOthO19==1 | EiOthO21==1 | EiOthO22==1) | ///
												(EiOthO1==1 & (inrange(EiRRel,8,18) | inlist(EiRRel,20,21)))) //joint, owners
replace rahomerl = 1 if EioInW9==1 | EioInW10==1 | EioInW11==1 | EioInW12==1 | EioInW13==1 | EioInW14==1 | ///
												EioInW15==1 | EioInW16==1 | EioInW17==1 | EioInW18==1 | EioInW19==1 | EioInW21==1 | EioInW22==1 | ///
												(EioInW1==1 & (inrange(EiRRel,8,18) | inlist(EiRRel,20,21))) //joint, other
replace rahomerl = 1 if EioHwH9==1 | EioHwH10==1 | EioHwH11==1 | EioHwH12==1 | EioHwH13==1 | EioHwH14==1 | ///
												EioHwH15==1 | EioHwH16==1 | EioHwH17==1 | EioHwH18==1 | EioHwH19==1 | EioHwH21==1 | EioHwH22==1 | ///
												(EioHwH1==1 & (inrange(EiRRel,8,18) | inlist(EiRRel,20,21))) //sole, other

***other inherited home***
*wave 3 respondent other inherited home
missing_w3 EiAsCk EiHome EiRRel EiHowH1 EioIn EiOthO1 EioInW1 EioHwH1 EiSp EiSpInH if inw`wv'xt==1, result(rahomeot)
replace rahomeot = .t if EiAsCk==2 & EiHome==-1
replace rahomeot = .x if EiHome==2
replace rahomeot = 0 if EiSp==1 & EiSpInH==1 //only sp inherited
replace rahomeot = 0 if EiHowH23==0 | EiHowH36==0 | EiHowH37==0 | EiHowH1==0 | (EiHowH1==1 & inrange(EiRRel,1,21)) //w sp, other
replace rahomeot = 0 if EioIn==2 | (EioIn==1 & ((EiOthO23==0 | EiOthO1==0) | (EiOthO1==0 & inrange(EiRRel,1,21)))) //joint, owners
replace rahomeot = 0 if EioInW23==0 | EioInW1==0 | (EioInW1==1 & inrange(EiRRel,1,21)) //joint, other
replace rahomeot = 0 if EioHwH23==0 | EioHwH1==0 | (EioHwH1==1 & inrange(EiRRel,1,21)) //sole, other
replace rahomeot = 1 if EiHowH23==1 | EiHowH36==1 | EiHowH37==1 | (EiHowH1==1 & EiRRel==22) //w sp, other 
replace rahomeot = 1 if EioIn==1 & (EiOthO23==1 | (EiOthO1==1 & EiRRel==22)) //joint, owners
replace rahomeot = 1 if EioInW23==1 | (EioInW1==1 & EiRRel==22) //joint, other
replace rahomeot = 1 if EioHwH23==1 | (EioHwH1==1 & EiRRel==22) //sole, other


***whether spouse was beneficiary of pension***
*wave 3 respondent spouse was beneficiary
missing_w3 EiRRel EiPenWho EiPenWh2 EiPenWh3 if inw`wv'xt==1, result(rapensp)
replace rapensp = .d if EiPenM==3 | EiPen96==1 | EiPen98==1 | EiPen100==1
replace rapensp = .n if EiPenM==2 | EiPen5==1 | EiPen10==1 | EiPen15==1
replace rapensp = .o if EiPen95==1 | EiPen97==1 | EiPen99==1
replace rapensp = 0 if EiPenWho==1 | EiPenWh2==1 | EiPenWh3==1 | ///
												inrange(EiPenWho,4,23) | inrange(EiPenWh2,4,23) | inrange(EiPenWh3,4,23) 
replace rapensp = 1 if inlist(EiPenWho,2,3) | inlist(EiPenWh2,2,3) | inlist(EiPenWh3,2,3) | ///
												((EiPenWho==1 | EiPenWh2==1 | EiPenWh3==1) & inlist(EiRRel,1,2))  

***whether child/grandchild was beneficary of pension***
*wave 3 respondent child/grandchild was beneficiary
missing_w3 EiRRel EiPenWho EiPenWh2 EiPenWh3 if inw`wv'xt==1, result(rapencg)
replace rapencg = .d if EiPenM==3 | EiPen96==1 | EiPen98==1 | EiPen100==1
replace rapencg = .n if EiPenM==2 | EiPen5==1 | EiPen10==1 | EiPen15==1
replace rapencg = .o if EiPen95==1 | EiPen97==1 | EiPen99==1
replace rapencg = 0 if inlist(EiPenWho,1,2,3,21,22,23) | inlist(EiPenWh2,1,2,3,21,22,23) | inlist(EiPenWh3,1,2,3,21,22,23) | ///
												inrange(EiPenWho,9,19) | inrange(EiPenWh2,9,19) | inrange(EiPenWh3,9,19) 
replace rapencg = 1 if inlist(EiPenWho,4,5,6,7,8,20) | inlist(EiPenWh2,4,5,6,7,8,20) | inlist(EiPenWh3,4,5,6,7,8,20) | ///
												((EiPenWho==1 | EiPenWh2==1 | EiPenWh3==1) & inlist(EiRRel,3,4,5,6,7,19)) 
												
***whether relative was beneficiary of pension***
*wave 3 respondent relative was beneficiary
missing_w3 EiRRel EiPenWho EiPenWh2 EiPenWh3 if inw`wv'xt==1, result(rapenrl)
replace rapenrl = .d if EiPenM==3 | EiPen96==1 | EiPen98==1 | EiPen100==1
replace rapenrl = .n if EiPenM==2 | EiPen5==1 | EiPen10==1 | EiPen15==1
replace rapenrl = .o if EiPen95==1 | EiPen97==1 | EiPen99==1
replace rapenrl = 0 if inrange(EiPenWho,1,8) | inrange(EiPenWh2,1,8) | inrange(EiPenWh3,1,8) | ///
												inlist(EiPenWho,20,23) | inlist(EiPenWh2,20,23) | inlist(EiPenWh3,20,23) 
replace rapenrl = 1 if inrange(EiPenWho,9,19) | inrange(EiPenWh2,9,19) | inrange(EiPenWh3,9,19) | ///
												inlist(EiPenWho,21,22) | inlist(EiPenWh2,21,22) | inlist(EiPenWh3,21,22) | ///
												((EiPenWho==1 | EiPenWh2==1 | EiPenWh3==1) & (inrange(EiRRel,8,18) | inlist(EiRRel,20,21))) 

***whether other person was beneficiary of pension***
*wave 3 respondent other person was beneficiary
missing_w3 EiRRel EiPenWho EiPenWh2 EiPenWh3 if inw`wv'xt==1, result(rapenot)
replace rapenot = .d if EiPenM==3 | EiPen96==1 | EiPen98==1 | EiPen100==1
replace rapenot = .n if EiPenM==2 | EiPen5==1 | EiPen10==1 | EiPen15==1
replace rapenot = .o if EiPen95==1 | EiPen97==1 | EiPen99==1
replace rapenot = 0 if inrange(EiPenWho,1,22) | inrange(EiPenWh2,1,22) | inrange(EiPenWh3,1,22) 
replace rapenot = 1 if EiPenWho==23 | EiPenWh2==23 | EiPenWh3==23 | ///
												((EiPenWho==1 | EiPenWh2==1 | EiPenWh3==1) & EiRRel==22) 


***death expenses***
gen insurance = .
replace insurance = 0 if DVEifuins==0
replace insurance = 600 if DVEifuins==1
replace insurance = 1700 if DVEifuins==2
replace insurance = 3100 if DVEifuins==3
replace insurance = 12000 if DVEifuins==4

*paid on own
replace selfo = 0 if EiDcstb==2
replace selfo = 1 if inlist(EiDcstb,1,3)

replace self = Eidcsta if inrange(Eidcsta,0,10000)

*paid by ins
replace inso = 0 if EiDcstb==3
replace inso = 1 if inlist(EiDcstb,1,2)

replace ins = insurance if inrange(insurance,0,20000)


***any costs covered by insurance (excl. life)***
*wave 3 respondent any costs covered by insurance
missing_w3 EiDcstb radexpense if inw`wv'xt==1, result(rainscovr)
replace rainscovr = 0 if EiDcstb==3
replace rainscovr = 1 if inlist(EiDcstb,1,2)


***amount insurance paid out***
drop insurance


***has living will***
*wave 3 respondent has living will
replace ralvwill = .q if inw`wv'xt==1


***desire to limit care in certain situations***
*wave 3 respondent desire to limit care in certain situations
replace ralmtcare = .q if inw`wv'xt==1


***whether had a durable power of attorney for healthcare***
*wave 3 respondent whether had a durable power of attorney for healthcare
replace radpoafh = .q if inw`wv'xt==1


***Whether spouse was dpoafh***
*wave 3 respondent spouse was dpoafh
replace radpoasp = .q if inw`wv'xt==1


***Whether child was dpoafh***
*wave 3 respondent child was dpoafh
replace radpoach = .q if inw`wv'xt==1


***Whether relative was dpoafh***
*wave 3 respondent relative was dpoafh
replace radpoarl = .q if inw`wv'xt==1


***Whether friend was dpoafh***
*wave 3 respondent friend was dpoafh
replace radpoafr = .q if inw`wv'xt==1


***Whether non-relative was dpoafh***
*wave 3 respondent non-relative was dpoafh
replace radpoanr = .q if inw`wv'xt==1


***Whether doctor was dpoafh***
*wave 3 respondent doctor was dpoafh
replace radpoadr = .q if inw`wv'xt==1


***Whether religious advisor was dpoafh***
*wave 3 respondent religious advisor was dpoafh
replace radpoara = .q if inw`wv'xt==1


***Whether legal professional was dpoafh***
*wave 3 respondent legal professional was dpoafh
replace radpoalp = .q if inw`wv'xt==1


***Whether social worker was dpoafh***
*wave 3 respondent social worker was dpoafh
replace radpoasw = .q if inw`wv'xt==1


***Whether other was dpoafh***
*wave 3 respondent other was dpoafh
replace radpoaot = .q if inw`wv'xt==1

***whether non-family member was dpoafh***
*wave 3 respondent non-family member was dpoafh
replace radpoanf = .q if inw`wv'xt==1


***any life insurance policies***
*wave 3 respondent any life insurance policies
missing_w3 EiAsCk EiLI if inw`wv'xt==1, result(raxlifeins)
replace raxlifeins = .t if EiAsCk==2 & EiLI==-1
replace raxlifeins = 0 if EiLI==2
replace raxlifeins = 1 if EiLI==1


***whether spouse is beneficiary of life insurance policies***
*wave 3 respondent spouse is beneficiary of life insurance policies
missing_w3 EiAsCk EiLI EiRRel EiLIWh1 EiLIWh2 EiLIWh3 if inw`wv'xt==1, result(ralfinssp)
replace ralfinssp = .t if EiAsCk==2 & EiLI==-1
replace ralfinssp = .n if raxlifeins==0 & inw`wv'xt==1
replace ralfinssp = 0 if EiLIWh1==0 | (EiLIWh1==1 & !inlist(EiRRel,1,2)) | EiLIWh2==0 | EiLIWh3==0
replace ralfinssp = 1 if (EiLIWh1==1 & inlist(EiRRel,1,2)) | EiLIWh2==1 | EiLIWh3==1


***whether child is beneficiary of life insurance policies***
*wave 3 respondent child is beneficiary of life insurance policies
missing_w3 EiAsCk EiLI EiRRel EiLIWh1 EiLIWh4 EiLIWh5 EiLIWh6 EiLIWh7 EiLIWh8 if inw`wv'xt==1, result(ralfinsch)
replace ralfinsch = .t if EiAsCk==2 & EiLI==-1
replace ralfinsch = .n if raxlifeins==0 & inw`wv'xt==1
replace ralfinsch = 0 if EiLIWh1==0 | (EiLIWh1==1 & !inrange(EiRRel,3,7)) | ///
													EiLIWh4==0 | EiLIWh5==0 | EiLIWh6==0 | EiLIWh7==0 | EiLIWh8==0
replace ralfinsch = 1 if (EiLIWh1==1 & inlist(EiRRel,1,2)) | ///
													EiLIWh4==1 | EiLIWh5==1 | EiLIWh6==1 | EiLIWh7==1 | EiLIWh8==1


***whether grandchild is beneficiary of life insurance policies***
*wave 3 respondent grandchild is beneficiary of life insurance policies
missing_w3 EiAsCk EiLI EiRRel EiLIWh1 EiLIWh20 if inw`wv'xt==1, result(ralfinsgk)
replace ralfinsgk = .t if EiAsCk==2 & EiLI==-1
replace ralfinsgk = .n if raxlifeins==0 & inw`wv'xt==1
replace ralfinsgk = 0 if EiLIWh1==0 | (EiLIWh1==1 & EiRRel!=19) | EiLIWh20==0 
replace ralfinsgk = 1 if (EiLIWh1==1 & EiRRel==19) | EiLIWh20==1 


***whether relative is beneficiary of life insurance policies***
*wave 3 respondent relative is beneficiary of life insurance policies
missing_w3 EiAsCk EiLI EiRRel EiLIWh1 EiLIWh9 EiLIWh10 EiLIWh11 EiLIWh12 EiLIWh13 ///
			EiLIWh14 EiLIWh15 EiLIWh16 EiLIWh17 EiLIWh18 EiLIWh19 EiLIWh21 EiLIWh22 if inw`wv'xt==1, result(ralfinsrl)
replace ralfinsrl = .t if EiAsCk==2 & EiLI==-1
replace ralfinsrl = .n if raxlifeins==0 & inw`wv'xt==1
replace ralfinsrl = 0 if EiLIWh1==0 | (EiLIWh1==1 & (!inrange(EiRRel,8,18) | EiRRel!=21)) | ///
													EiLIWh9==0 | EiLIWh10==0 | EiLIWh11==0 | EiLIWh12==0 | EiLIWh13==0 | ///
													EiLIWh14==0 | EiLIWh15==0 | EiLIWh16==0 | EiLIWh17==0 | EiLIWh18==0 | ///
													EiLIWh19==0 | EiLIWh21==0 | EiLIWh22==0
replace ralfinsrl = 1 if (EiLIWh1==1 & (inrange(EiRRel,8,18) | EiRRel==21)) | ///
													EiLIWh9==1 | EiLIWh10==1 | EiLIWh11==1 | EiLIWh12==1 | EiLIWh13==1 | ///
													EiLIWh14==1 | EiLIWh15==1 | EiLIWh16==1 | EiLIWh17==1 | EiLIWh18==1 | ///
													EiLIWh19==1 | EiLIWh21==1 | EiLIWh22==1


***whether other non-relative is beneficiary of life insurance policies***
*wave 3 respondent other non-relative is beneficiary of life insurance policies
missing_w3 EiAsCk EiLI EiRRel EiLIWh1 EiLIWh23 if inw`wv'xt==1, result(ralfinsot)
replace ralfinsot = .t if EiAsCk==2 & EiLI==-1
replace ralfinsot = .n if raxlifeins==0 & inw`wv'xt==1
replace ralfinsot = 0 if EiLIWh1==0 | (EiLIWh1==1 & EiRRel!=22) | EiLIWh23==0 
replace ralfinsot = 1 if (EiLIWh1==1 & EiRRel==22) | EiLIWh23==1 


***value of life insurance policies***
*wave 3 respondent value of life insurance policies
*values are supplied in ranges - midpoint of range is assigned
gen value = .
replace value = 0 if raxlifeins==0 & inw`wv'xt==1
replace value = 900 if DVEiLIa==1 //1-1800
replace value = 2900 if DVEiLIa==2 //1800.01-4000
replace value = 12000 if DVEiLIa==3 //4000.01-20000
replace value = 110000 if DVEiLIa==4 //20000.01-200000

gen lifemin = .
gen lifemax = .

gen lifeo = .
replace lifeo = 0 if inlist(raxlifeins,0,.t) & inw`wv'xt==1
replace lifeo = 1 if raxlifeins==1 & inw`wv'xt==1

gen life = value if inrange(value,0,200000)

drop value




***drop H_ELSA wave 3 core file raw variables***
drop `eolxt_w3_exit'


******************************************************************************************


*set wave number
local wv=4
local pre_wv=3

***merge with wave 4 exit data***
local eolxt_w4_exit EiWillA EiProb EiWillB DVEidcsta EiDcstb DVEifuins EiAsCk EiLI EiLIWh1 EiLIWh2 EiLIWh3 ///
										EiLIWh4 EiLIWh5 EiLIWh6 EiLIWh7 EiLIWh8 EiLIWh9 EiLIWh10 EiLIWh11 EiLIWh12 EiLIWh13 EiLIWh14 ///
										EiLIWh15 EiLIWh16 EiLIWh17 EiLIWh18 EiLIWh19 EiLIWh20 EiLIWh21 EiLIWh22 EiLIWh23 ///
										EiRRel DVEiLIa EiPenWho EiPenWh2 EiPenWh3 EiKin EiBen EiSp EiSp2 EioIn EioIn2 EiSpInH EiSpInH2 EiHome ///
										EiHowH1 EiHowH2 EiHowH3 EiHowH4 EiHowH5 EiHowH6 EiHowH7 EiHowH8 EiHowH9 EiHowH10 EiHowH11 EiHowH12 EiHowH13 ///
										EiHowH14 EiHowH15 EiHowH16 EiHowH17 EiHowH18 EiHowH19 EiHowH20 EiHowH21 EiHowH22 EiHowH23 EiHowH36 EiHowH37 ///
										EiHowH39 EiHowH40 EiHowH41 EiHowH42 EiHowH43 EiHowH44 EiHowH45 EiHowH46 EiHowH47 EiHowH48 EiHowH49 EiHowH50 ///
										EiHowH51 EiHowH52 EiHowH53 EiHowH54 EiHowH55 EiHowH56 EiHowH57 EiHowH58 EiHowH59 EiHowH60 EiHowH61 ///
										EiOthO1 EiOthO2 EiOthO3 EiOthO4 EiOthO5 EiOthO6 EiOthO7 EiOthO8 EiOthO9 EiOthO10 EiOthO11 EiOthO12 EiOthO13 ///
										EiOthO14 EiOthO15 EiOthO16 EiOthO17 EiOthO18 EiOthO19 EiOthO20 EiOthO21 EiOthO22 EiOthO23 ///
										EiOthO24 EiOthO25 EiOthO26 EiOthO27 EiOthO28 EiOthO29 EiOthO30 EiOthO31 EiOthO32 EiOthO33 EiOthO34 EiOthO35 ///
										EiOthO36 EiOthO37 EiOthO38 EiOthO39 EiOthO40 EiOthO41 EiOthO42 EiOthO43 EiOthO44 EiOthO45 EiOthO46 ///
										EioInW1 EioInW2 EioInW3 EioInW4 EioInW5 EioInW6 EioInW7 EioInW8 EioInW9 EioInW10 EioInW11 EioInW12 EioInW13 ///
										EioInW14 EioInW15 EioInW16 EioInW17 EioInW18 EioInW19 EioInW20 EioInW21 EioInW22 EioInW23 ///
										EioInW24 EioInW25 EioInW26 EioInW27 EioInW28 EioInW29 EioInW30 EioInW31 EioInW32 EioInW33 EioInW34 EioInW35 ///
										EioInW36 EioInW37 EioInW38 EioInW39 EioInW40 EioInW41 EioInW42 EioInW43 EioInW44 EioInW45 EioInW46 ///
										EioHwH1 EioHwH2 EioHwH3 EioHwH4 EioHwH5 EioHwH6 EioHwH7 EioHwH8 EioHwH9 EioHwH10 EioHwH11 EioHwH12 EioHwH13 ///
										EioHwH14 EioHwH15 EioHwH16 EioHwH17 EioHwH18 EioHwH19 EioHwH20 EioHwH21 EioHwH22 EioHwH23 ///
										EioHwH24 EioHwH25 EioHwH26 EioHwH27 EioHwH28 EioHwH29 EioHwH30 EioHwH31 EioHwH32 EioHwH33 EioHwH34 EioHwH35 ///
										EioHwH36 EioHwH37 EioHwH38 EioHwH39 EioHwH40 EioHwH41 EioHwH42 EioHwH43 EioHwH44 EioHwH45 EioHwH46 ///
										EIPhyWh1 EIPhyWh2 EIPhyWh3 EIPhyWh4 EIPhyWh5 EIPhyWh6 EIPhyWh7 EIPhyWh8 EIPhyWh9 EIPhyW10 EIPhyW11 EIPhyW12 ///
										EIPhyW13 EIPhyW14 EIPhyW15 EIPhyW16 EIPhyW17 EIPhyW18 EIPhyW19 EIPhyW20 EIPhyW21 EIPhyW22 EIPhyW23 ///
										EiOthAs1 EiOthAs2 EiOthAs3 EiOthAs4 EiOthAs5 EiOthAs6 EiOthAs7 EiOthAs8 EiOthAs9 EiOthA10 EiOthA11 EiOthA12 ///
										EiOthA13 EiOthA14 EiOthA15 EiOthA16 EiOthA17 EiOthA18 EiOthA19 EiOthA20 EiOthA21 EiOthA22 EiOthA23 EiOthA24 ///
										EiPenM EiPen5 EiPen10 EiPen15 EiPen95 EiPen96 EiPen97 EiPen98 EiPen99 EiPen100 ///
										EiHowH1 EiHowH2 EiHowH3 EiHowH4 EiHowH5 EiHowH6 EiHowH7 EiHowH8 EiHowH9 EiHowH10 EiHowH11 EiHowH12 EiHowH13 ///
										EiHowH14 EiHowH15 EiHowH16 EiHowH17 EiHowH18 EiHowH19 EiHowH20 EiHowH21 EiHowH22 EiHowH23 EiHowH36 EiHowH37 ///
										EiOthO1 EiOthO2 EiOthO3 EiOthO4 EiOthO5 EiOthO6 EiOthO7 EiOthO8 EiOthO9 EiOthO10 EiOthO11 EiOthO12 ///
										EiOthO13 EiOthO14 EiOthO15 EiOthO16 EiOthO17 EiOthO18 EiOthO19 EiOthO20 EiOthO21 EiOthO22 EiOthO23 /// 
										EioHwH1 EioHwH2 EioHwH3 EioHwH4 EioHwH5 EioHwH6 EioHwH7 EioHwH8 EioHwH9 EioHwH10 EioHwH11 EioHwH12 ///
										EioHwH13 EioHwH14 EioHwH15 EioHwH16 EioHwH17 EioHwH18 EioHwH19 EioHwH20 EioHwH21 EioHwH22 EioHwH23 ///
										EioInW1 EioInW2 EioInW3 EioInW4 EioInW5 EioInW6 EioInW7 EioInW8 EioInW9 EioInW10 EioInW11 EioInW12 ///
										EioInW13 EioInW14 EioInW15 EioInW16 EioInW17 EioInW18 EioInW19 EioInW20 EioInW21 EioInW22 EioInW23 
merge 1:1 idauniq using "$w4_xt", keepusing(`eolxt_w4_exit') nogen

drop if idauniq==105273



replace notdist = 1 if EiAsCk==2

***whether had a witnessed will***
*wave 4 respondent whether had a witnessed will
missing_w4 EiWillA EiAsCk if inw`wv'xt==1, result(rawitwill)
replace rawitwill = .d if EiWillA==3
replace rawitwill = .t if EiAsCk==2 & EiWillA==-1
replace rawitwill = 0 if EiWillA==2
replace rawitwill = 1 if EiWillA==1


***whether will has been through probate***
*wave 4 respondent whether will has been through probate
missing_w4 EiWillB EiProb rawitwill if inw`wv'xt==1, result(raprobate)
replace raprobate = .d if EiProb==3
replace raprobate = .t if EiAsCk==2 & EiWillA==-1
replace raprobate = .w if rawitwill==0 & inw`wv'xt==1
replace raprobate = 1 if EiProb==2 
replace raprobate = 2 if EiProb==1 & EiWillB==2
replace raprobate = 3 if EiProb==1 & EiWillB==1

***whether proxy was beneficiary of will***
*wave 4 respondent proxy was beneficiary
missing_w4 EiBen rawitwill if inw`wv'xt==1, result(rawillp)
replace rawillp = .t if EiAsCk==2
replace rawillp = .w if rawitwill==0 & inw`wv'xt==1
replace rawillp = 0 if EiBen==2 //proxy will beneficiary
replace rawillp = 1 if EiBen==1 //proxy will beneficiary


***whether spouse was beneficiary of estate***
*wave 4 respondent spouse was beneficiary
missing_w4 EiRRel EiAsCk EiOthA24 EiOthAs1 EiOthAs2 EiOthAs3 if inw`wv'xt==1, result(rabnfcrsp)
replace rabnfcrsp = .t if EiAsCk==2
replace rabnfcrsp = 0 if EiSp==2 //house: w sp, spouse 
replace rabnfcrsp = 0 if EiHowH2==0 | EiHowH3==0 | EiHowH1==0 | (EiHowH1==1 & inrange(EiRRel,3,22)) //house: w sp, other
replace rabnfcrsp = 0 if EioHwH2==0 | EioHwH3==0 | EioHwH1==0 | (EioHwH1==1 & inrange(EiRRel,3,22)) //house: sole, other
replace rabnfcrsp = 0 if EioIn==2 | (EioIn==1 & ((EiOthO2==0 | EiOthO3==0 | EiOthO1==0) | (EiOthO1==1 & inrange(EiRRel,3,22)))) //house: joint, owners
replace rabnfcrsp = 0 if EioInW2==0 | EioInW3==0 | EioInW1==0 | (EioInW1==1 & inrange(EiRRel,3,22)) //house: joint, other
replace rabnfcrsp = 0 if EiSp2==2 //other prop: w sp, spouse
replace rabnfcrsp = 0 if EiHowH40==0 | EiHowH41==0 | EiHowH39==0 | (EiHowH39==1 & inrange(EiRRel,3,22)) //other prop: w sp, other
replace rabnfcrsp = 0 if EioHwH25==0 | EioHwH26==0 | EioHwH24==0 | (EioHwH24==1 & inrange(EiRRel,3,22)) //other prop: sole, other
replace rabnfcrsp = 0 if EioIn2==2 | (EioIn2==1 & ((EiOthO25==0 | EiOthO26==0 | EiOthO24==0) | (EiOthO24==1 & inrange(EiRRel,3,22)))) //other prop: joint, owners
replace rabnfcrsp = 0 if EioInW25==0 | EioInW26==0 | EioInW24==0 | (EioInW24==1 & inrange(EiRRel,3,22)) //other prop: joint, other
replace rabnfcrsp = 0 if EIPhyWh2==0 | EIPhyWh3==0 | EIPhyWh1==0 | (EIPhyWh1==1 & inrange(EiRRel,3,22)) //business
replace rabnfcrsp = 0 if EiOthA24==1 | EiOthAs2==0 | EiOthAs3==0 | EiOthAs1==0 | (EiOthAs1==1 & inrange(EiRRel,3,22)) //other assets
replace rabnfcrsp = 1 if EiSp==1 //house: w sp, spouse
replace rabnfcrsp = 1 if EiHowH2==1 | EiHowH3==1 | (EiHowH1==1 & inlist(EiRRel,1,2)) //house: w sp, other
replace rabnfcrsp = 1 if EioHwH2==1 | EioHwH3==1 | (EioHwH1==1 & inlist(EiRRel,1,2)) //house: sole, other
replace rabnfcrsp = 1 if EioIn==1 & ((EiOthO2==1 | EiOthO3==1) | (EiOthO1==1 & inlist(EiRRel,1,2))) //house: joint, owners
replace rabnfcrsp = 1 if EioInW2==1 | EioInW3==1 | (EioInW1==1 & inlist(EiRRel,1,2)) //house: joint, other
replace rabnfcrsp = 1 if EiSp2==1 //other prop: w sp, spouse
replace rabnfcrsp = 1 if EiHowH40==1 | EiHowH41==1 | (EiHowH39==1 & inlist(EiRRel,1,2)) //other prop: w sp, other
replace rabnfcrsp = 1 if EioHwH25==1 | EioHwH26==1 | (EioHwH24==1 & inlist(EiRRel,1,2)) //other prop: sole, other
replace rabnfcrsp = 1 if EioIn2==1 & ((EiOthO25==1 | EiOthO26==1) | (EiOthO24==1 & inlist(EiRRel,1,2))) //other prop: joint, owners
replace rabnfcrsp = 1 if EioInW25==1 | EioInW26==1 | (EioInW24==1 & inlist(EiRRel,1,2)) //other prop: joint, other
replace rabnfcrsp = 1 if EIPhyWh2==1 | EIPhyWh3==1 | (EIPhyWh1==1 & inlist(EiRRel,1,2)) //business
replace rabnfcrsp = 1 if EiOthAs2==1 | EiOthAs3==1 | (EiOthAs1==1 & inlist(EiRRel,1,2)) //other assets

***whether child/grandchild was beneficary of estate***
*wave 4 respondent child/grandchild was beneficiary
missing_w4 EiRRel EiAsCk EiOthA24 EiOthAs1 EiOthAs2 EiOthAs3 if inw`wv'xt==1, result(rabnfcrcg)
replace rabnfcrcg = .t if EiAsCk==2
replace rabnfcrcg = 0 if EiSp==1 & EiSpInH==1 //house: only sp inherited
replace rabnfcrcg = 0 if EiHowH4==0 | EiHowH5==0 | EiHowH6==0 | EiHowH7==0 | EiHowH8==0 | EiHowH20==0 | ///
												EiHowH1==0 | (EiHowH1==1 & (inlist(EiRRel,1,2,20,21,22) | inrange(EiRRel,8,18))) //house: w sp, other
replace rabnfcrcg = 0 if EioHwH4==0 | EioHwH5==0 | EioHwH6==0 | EioHwH7==0 | EioHwH8==0 | EioHwH20==0 | ///
												EioHwH1==0 | (EioHwH1==1 & (inlist(EiRRel,1,2,20,21,22) | inrange(EiRRel,8,18))) //house: sole, other
replace rabnfcrcg = 0 if EioIn==2 | (EioIn==1 & ((EiOthO4==0 | EiOthO5==0 | EiOthO6==0 | EiOthO7==0 | EiOthO8==0 | EiOthO20==0 | EiOthO1==0) | ///
												(EiOthO1==1 & (inlist(EiRRel,1,2,20,21,22) | inrange(EiRRel,8,18))))) //house: joint, owners
replace rabnfcrcg = 0 if EioInW4==0 | EioInW5==0 | EioInW6==0 | EioInW7==0 | EioInW8==0 | EioInW20==0 | ///
												EioInW1==0 | (EioInW1==1 & (inlist(EiRRel,1,2,20,21,22) | inrange(EiRRel,8,18))) //house: joint, other
replace rabnfcrcg = 0 if EiSp2==1 & EiSpInH2==1 //other prop: only sp inherited
replace rabnfcrcg = 0 if EiHowH42==0 | EiHowH43==0 | EiHowH44==0 | EiHowH45==0 | EiHowH46==0 | EiHowH58==0 | ///
												EiHowH39==0 | (EiHowH39==1 & (inlist(EiRRel,1,2,20,21,22) | inrange(EiRRel,8,18))) //other prop: w sp, other
replace rabnfcrcg = 0 if EioHwH27==0 | EioHwH28==0 | EioHwH29==0 | EioHwH30==0 | EioHwH31==0 | EioHwH43==0 | ///
												EioHwH24==0 | (EioHwH24==1 & (inlist(EiRRel,1,2,20,21,22) | inrange(EiRRel,8,18))) //other prop: sole, other
replace rabnfcrcg = 0 if EioIn2==2 | (EioIn2==1 & ((EiOthO27==0 | EiOthO28==0 | EiOthO29==0 | EiOthO30==0 | EiOthO31==0 | EiOthO43==0 | EiOthO24==0) | ///
												(EiOthO24==1 & (inlist(EiRRel,1,2,20,21,22) | inrange(EiRRel,8,18))))) //other prop: joint, owners
replace rabnfcrcg = 0 if EioInW27==0 | EioInW28==0 | EioInW29==0 | EioInW30==0 | EioInW31==0 | EioInW43==0 | ///
												EioInW24==0 | (EioInW24==1 & (inlist(EiRRel,1,2,20,21,22) | inrange(EiRRel,8,18))) //other prop: joint, other
replace rabnfcrcg = 0 if EIPhyWh4==0 | EIPhyWh5==0 | EIPhyWh6==0 | EIPhyWh7==0 | EIPhyWh8==0 | EIPhyW20==0 | ///
												EIPhyWh1==0 | (EIPhyWh1==1 & (inlist(EiRRel,1,2,20,21,22) | inrange(EiRRel,8,18))) //business
replace rabnfcrcg = 0 if EiOthA24==1 | EiOthAs4==0 | EiOthAs5==0 | EiOthAs6==0 | EiOthAs7==0 | EiOthAs8==0 | EiOthA20==0 | ///
												EiOthAs1==0 | (EiOthAs1==1 & (inlist(EiRRel,1,2,20,21,22) | inrange(EiRRel,8,18))) //other assets 
replace rabnfcrcg = 1 if EiHowH4==1 | EiHowH5==1 | EiHowH6==1 | EiHowH7==1 | EiHowH8==1 | EiHowH20==1 | ///
												EiHowH1==0 | (EiHowH1==1 & inlist(EiRRel,3,4,5,6,7,19)) //house: w sp, other
replace rabnfcrcg = 1 if EioHwH4==1 | EioHwH5==1 | EioHwH6==1 | EioHwH7==1 | EioHwH8==1 | EioHwH20==1 | ///
												EioHwH1==0 | (EioHwH1==1 & inlist(EiRRel,3,4,5,6,7,19)) //house: sole, other
replace rabnfcrcg = 1 if EioIn==1 & ((EiOthO4==1 | EiOthO5==1 | EiOthO6==1 | EiOthO7==1 | EiOthO8==1 | EiOthO20==1) | ///
												(EiOthO1==1 & inlist(EiRRel,3,4,5,6,7,19))) //house: joint, owners
replace rabnfcrcg = 1 if EioInW4==1 | EioInW5==1 | EioInW6==1 | EioInW7==1 | EioInW8==1 | EioInW20==1 | ///
												EioInW1==0 | (EioInW1==1 & inlist(EiRRel,3,4,5,6,7,19)) //house: joint, other						
replace rabnfcrcg = 1 if EiHowH42==1 | EiHowH43==1 | EiHowH44==1 | EiHowH45==1 | EiHowH46==1 | EiHowH58==1 | ///
												EiHowH39==0 | (EiHowH39==1 & inlist(EiRRel,3,4,5,6,7,19)) //other prop: w sp, other
replace rabnfcrcg = 1 if EioHwH27==1 | EioHwH28==1 | EioHwH29==1 | EioHwH30==1 | EioHwH31==1 | EioHwH43==1 | ///
												EioHwH24==0 | (EioHwH24==1 & inlist(EiRRel,3,4,5,6,7,19)) //other prop: sole, other
replace rabnfcrcg = 1 if EioIn2==1 & ((EiOthO27==1 | EiOthO28==1 | EiOthO29==1 | EiOthO30==1 | EiOthO31==1 | EiOthO43==1) | ///
												(EiOthO24==1 & inlist(EiRRel,3,4,5,6,7,19))) //other prop: joint, owners
replace rabnfcrcg = 1 if EioInW27==1 | EioInW28==1 | EioInW29==1 | EioInW30==1 | EioInW31==1 | EioInW43==1 | ///
												EioInW24==0 | (EioInW24==1 & inlist(EiRRel,3,4,5,6,7,19)) //other prop: joint, other					
replace rabnfcrcg = 1 if EIPhyWh4==1 | EIPhyWh5==1 | EIPhyWh6==1 | EIPhyWh7==1 | EIPhyWh8==1 | EIPhyW20==1 | ///
												(EIPhyWh1==1 & inlist(EiRRel,3,4,5,6,7,19)) //business
replace rabnfcrcg = 1 if EiOthAs4==1 | EiOthAs5==1 | EiOthAs6==1 | EiOthAs7==1 | EiOthAs8==1 | EiOthA20==1 | ///
												(EiOthAs1==1 & inlist(EiRRel,3,4,5,6,7,19)) //other assets

***whether relative was beneficiary of estate***
*wave 4 respondent relative was beneficiary
missing_w4 EiRRel EiAsCk EiOthA24 EiOthAs1 EiOthAs2 EiOthAs3 if inw`wv'xt==1, result(rabnfcrrl)
replace rabnfcrrl = .t if EiAsCk==2
replace rabnfcrrl = 0 if EiSp==1 & EiSpInH==1 //house: only sp inherited
replace rabnfcrrl = 0 if EiHowH9==0 | EiHowH10==0 | EiHowH11==0 | EiHowH12==0 | EiHowH13==0 | EiHowH14==0 | ///
												EiHowH15==0 | EiHowH16==0 | EiHowH17==0 | EiHowH18==0 | EiHowH19==0 | EiHowH21==0 | EiHowH22==0 | ///
												EiHowH1==0 | (EiHowH1==1 & (inrange(EiRRel,1,7) | inlist(EiRRel,19,22))) //house: w sp, other
replace rabnfcrrl = 0 if EioHwH9==0 | EioHwH10==0 | EioHwH11==0 | EioHwH12==0 | EioHwH13==0 | EioHwH14==0 | ///
												EioHwH15==0 | EioHwH16==0 | EioHwH17==0 | EioHwH18==0 | EioHwH19==0 | EioHwH21==0 | EioHwH22==0 | ///
												EioHwH1==0 | (EioHwH1==1 & (inrange(EiRRel,1,7) | inlist(EiRRel,19,22))) //house: sole, other
replace rabnfcrrl = 0 if EioIn==2 | (EioIn==1 & ((EiOthO9==0 | EiOthO10==0 | EiOthO11==0 | EiOthO12==0 | EiOthO13==0 | EiOthO14==0 | ///
												EiOthO15==0 | EiOthO16==0 | EiOthO17==0 | EiOthO18==0 | EiOthO19==0 | EiOthO21==0 | EiOthO22==0 | EiOthO1==0) | ///
												(EiOthO1==1 & (inrange(EiRRel,1,7) | inlist(EiRRel,19,22))))) //house: joint, owners
replace rabnfcrrl = 0 if EioInW9==0 | EioInW10==0 | EioInW11==0 | EioInW12==0 | EioInW13==0 | EioInW14==0 | ///
												EioInW15==0 | EioInW16==0 | EioInW17==0 | EioInW18==0 | EioInW19==0 | EioInW21==0 | EioInW22==0 | ///
												EioInW1==0 | (EioInW1==1 & (inrange(EiRRel,1,7) | inlist(EiRRel,19,22))) //house: joint, other		
replace rabnfcrrl = 0 if EiSp2==1 & EiSpInH2==1 //other prop: only sp inherited
replace rabnfcrrl = 0 if EiHowH47==0 | EiHowH48==0 | EiHowH49==0 | EiHowH50==0 | EiHowH51==0 | EiHowH52==0 | ///
												EiHowH53==0 | EiHowH54==0 | EiHowH55==0 | EiHowH56==0 | EiHowH57==0 | EiHowH59==0 | EiHowH60==0 | ///
												EiHowH39==0 | (EiHowH39==1 & (inrange(EiRRel,1,7) | inlist(EiRRel,19,22))) //other prop: w sp, other
replace rabnfcrrl = 0 if EioHwH32==0 | EioHwH33==0 | EioHwH34==0 | EioHwH35==0 | EioHwH36==0 | EioHwH37==0 | ///
												EioHwH38==0 | EioHwH39==0 | EioHwH40==0 | EioHwH41==0 | EioHwH42==0 | EioHwH44==0 | EioHwH45==0 | ///
												EioHwH24==0 | (EioHwH24==1 & (inrange(EiRRel,1,7) | inlist(EiRRel,19,22))) //other prop: sole, other
replace rabnfcrrl = 0 if EioIn2==2 | (EioIn2==1 & ((EiOthO32==0 | EiOthO33==0 | EiOthO34==0 | EiOthO35==0 | EiOthO36==0 | EiOthO37==0 | ///
												EiOthO38==0 | EiOthO39==0 | EiOthO40==0 | EiOthO41==0 | EiOthO42==0 | EiOthO44==0 | EiOthO45==0 | EiOthO24==0) | ///
												(EiOthO24==1 & (inrange(EiRRel,1,7) | inlist(EiRRel,19,22))))) //other prop: joint, owners
replace rabnfcrrl = 0 if EioInW32==0 | EioInW33==0 | EioInW34==0 | EioInW35==0 | EioInW36==0 | EioInW37==0 | ///
												EioInW38==0 | EioInW39==0 | EioInW40==0 | EioInW41==0 | EioInW42==0 | EioInW44==0 | EioInW45==0 | ///
												EioInW24==0 | (EioInW24==1 & (inrange(EiRRel,1,7) | inlist(EiRRel,19,22))) //other prop: joint, other	
replace rabnfcrrl = 0 if EIPhyWh9==0 | EIPhyW10==0 | EIPhyW11==0 | EIPhyW12==0 | EIPhyW13==0 | EIPhyW14==0 | ///
												EIPhyW15==0 | EIPhyW16==0 | EIPhyW17==0 | EIPhyW18==0 | EIPhyW19==0 | EIPhyW21==0 | EIPhyW22==0 | ///
												EIPhyWh1==0 | (EIPhyWh1==1 & (inrange(EiRRel,1,7) | inlist(EiRRel,19,22))) //business
replace rabnfcrrl = 0 if EiOthA24==1 | EiOthAs9==0 | EiOthA10==0 | EiOthA11==0 | EiOthA12==0 | EiOthA13==0 | EiOthA14==0 | ///
												EiOthA15==0 | EiOthA16==0 | EiOthA17==0 | EiOthA18==0 | EiOthA19==0 | EiOthA21==0 | EiOthA22==0 | ///
												EiOthAs1==0 | (EiOthAs1==1 & (inrange(EiRRel,1,7) | inlist(EiRRel,19,22))) //other assets 
replace rabnfcrrl = 1 if EiHowH9==1 | EiHowH10==1 | EiHowH11==1 | EiHowH12==1 | EiHowH13==1 | EiHowH14==1 | ///
												EiHowH15==1 | EiHowH16==1 | EiHowH17==1 | EiHowH18==1 | EiHowH19==1 | EiHowH21==1 | EiHowH22==1 | ///
												(EiHowH1==1 & (inrange(EiRRel,8,18) | inlist(EiRRel,20,21))) //house: w sp, other
replace rabnfcrrl = 1 if EioHwH9==1 | EioHwH10==1 | EioHwH11==1 | EioHwH12==1 | EioHwH13==1 | EioHwH14==1 | ///
												EioHwH15==1 | EioHwH16==1 | EioHwH17==1 | EioHwH18==1 | EioHwH19==1 | EioHwH21==1 | EioHwH22==1 | ///
												(EioHwH1==1 & (inrange(EiRRel,8,18) | inlist(EiRRel,20,21))) //house: sole, other
replace rabnfcrrl = 1 if EioIn==1 & ((EiOthO9==1 | EiOthO10==1 | EiOthO11==1 | EiOthO12==1 | EiOthO13==1 | EiOthO14==1 | ///
												EiOthO15==1 | EiOthO16==1 | EiOthO17==1 | EiOthO18==1 | EiOthO19==1 | EiOthO21==1 | EiOthO22==1) | ///
												(EiOthO1==1 & (inrange(EiRRel,8,18) | inlist(EiRRel,20,21)))) //house: joint, owners
replace rabnfcrrl = 1 if EioInW9==1 | EioInW10==1 | EioInW11==1 | EioInW12==1 | EioInW13==1 | EioInW14==1 | ///
												EioInW15==1 | EioInW16==1 | EioInW17==1 | EioInW18==1 | EioInW19==1 | EioInW21==1 | EioInW22==1 | ///
												(EioInW1==1 & (inrange(EiRRel,8,18) | inlist(EiRRel,20,21))) //house: joint, other
replace rabnfcrrl = 1 if EiHowH47==1 | EiHowH48==1 | EiHowH49==1 | EiHowH50==1 | EiHowH51==1 | EiHowH52==1 | ///
												EiHowH53==1 | EiHowH54==1 | EiHowH55==1 | EiHowH56==1 | EiHowH57==1 | EiHowH59==1 | EiHowH60==1 | ///
												(EiHowH39==1 & (inrange(EiRRel,8,18) | inlist(EiRRel,20,21))) //other prop: w sp, other
replace rabnfcrrl = 1 if EioHwH32==1 | EioHwH33==1 | EioHwH34==1 | EioHwH35==1 | EioHwH36==1 | EioHwH37==1 | ///
												EioHwH38==1 | EioHwH39==1 | EioHwH40==1 | EioHwH41==1 | EioHwH42==1 | EioHwH44==1 | EioHwH45==1 | ///
												(EioHwH24==1 & (inrange(EiRRel,8,18) | inlist(EiRRel,20,21))) //other prop: sole, other
replace rabnfcrrl = 1 if EioIn2==1 & ((EiOthO32==1 | EiOthO33==1 | EiOthO34==1 | EiOthO35==1 | EiOthO36==1 | EiOthO37==1 | ///
												EiOthO38==1 | EiOthO39==1 | EiOthO40==1 | EiOthO41==1 | EiOthO42==1 | EiOthO44==1 | EiOthO45==1) | ///
												(EiOthO24==1 & (inrange(EiRRel,8,18) | inlist(EiRRel,20,21)))) //other prop: joint, owners
replace rabnfcrrl = 1 if EioInW32==1 | EioInW33==1 | EioInW34==1 | EioInW35==1 | EioInW36==1 | EioInW37==1 | ///
												EioInW38==1 | EioInW39==1 | EioInW40==1 | EioInW41==1 | EioInW42==1 | EioInW44==1 | EioInW45==1 | ///
												(EioInW24==1 & (inrange(EiRRel,8,18) | inlist(EiRRel,20,21))) //other prop: joint, other
replace rabnfcrrl = 1 if EIPhyWh9==1 | EIPhyW10==1 | EIPhyW11==1 | EIPhyW12==1 | EIPhyW13==1 | EIPhyW14==1 | ///
												EIPhyW15==1 | EIPhyW16==1 | EIPhyW17==1 | EIPhyW18==1 | EIPhyW19==1 | EIPhyW21==1 | EIPhyW22==1 | ///
												(EIPhyWh1==1 & (inrange(EiRRel,8,18) | inlist(EiRRel,20,21))) //business
replace rabnfcrrl = 1 if EiOthAs9==1 | EiOthA10==1 | EiOthA11==1 | EiOthA12==1 | EiOthA13==1 | EiOthA14==1 | ///
												EiOthA15==1 | EiOthA16==1 | EiOthA17==1 | EiOthA18==1 | EiOthA19==1 | EiOthA21==1 | EiOthA22==1 | ///
												(EiOthAs1==1 & (inrange(EiRRel,8,18) | inlist(EiRRel,20,21))) //other assets 

***whether other person was beneficiary of estate***
*wave 4 respondent other person was beneficiary
missing_w4 EiRRel EiAsCk EiOthA24 EiOthAs1 EiOthAs2 EiOthAs3 if inw`wv'xt==1, result(rabnfcrot)
replace rabnfcrot = .t if EiAsCk==2
replace rabnfcrot = 0 if EiSp==1 & EiSpInH==1 //house: only sp inherited
replace rabnfcrot = 0 if EiHowH23==0 | EiHowH36==0 | EiHowH37==0 | EiHowH1==0 | (EiHowH1==1 & inrange(EiRRel,1,21)) //house: w sp, other
replace rabnfcrot = 0 if EioHwH23==0 | EioHwH1==0 | (EioHwH1==1 & inrange(EiRRel,1,21)) //house: sole, other
replace rabnfcrot = 0 if EioIn==2 | (EioIn==1 & ((EiOthO23==0 | EiOthO1==0) | (EiOthO1==0 & inrange(EiRRel,1,21)))) //house: joint, owners
replace rabnfcrot = 0 if EioInW23==0 | EioInW1==0 | (EioInW1==1 & inrange(EiRRel,1,21)) //house: joint, other
replace rabnfcrot = 0 if EiSp2==1 & EiSpInH2==1 //other prop: only sp inherited
replace rabnfcrot = 0 if EiHowH61==0 | EiHowH39==0 | (EiHowH39==1 & inrange(EiRRel,1,21)) //other prop: w sp, other
replace rabnfcrot = 0 if EioHwH46==0 | EioHwH24==0 | (EioHwH24==1 & inrange(EiRRel,1,21)) //other prop: sole, other
replace rabnfcrot = 0 if EioIn2==2 | (EioIn2==1 & ((EiOthO46==0 | EiOthO24==0) | (EiOthO24==0 & inrange(EiRRel,1,21)))) //other prop: joint, owners
replace rabnfcrot = 0 if EioInW46==0 | EioInW24==0 | (EioInW24==1 & inrange(EiRRel,1,21)) //other prop: joint, other
replace rabnfcrot = 0 if EIPhyW23==0 | EIPhyWh1==0 | (EIPhyWh1==1 & inrange(EiRRel,1,21)) //business
replace rabnfcrot = 0 if EiOthA24==1 | EiOthA23==0 | EiOthAs1==0 | (EiOthAs1==1 & inrange(EiRRel,1,21)) //other assets
replace rabnfcrot = 1 if EiHowH23==1 | EiHowH36==1 | EiHowH37==1 | (EiHowH1==1 & EiRRel==22) //house: w sp, other
replace rabnfcrot = 1 if EioHwH23==1 | (EioHwH1==1 & EiRRel==22) //house: sole, other
replace rabnfcrot = 1 if EioIn==1 & (EiOthO23==1 | (EiOthO1==1 & EiRRel==22)) //house: joint, owners
replace rabnfcrot = 1 if EioInW23==1 | (EioInW1==1 & EiRRel==22) //house: joint, other
replace rabnfcrot = 1 if EiHowH61==1 | (EiHowH39==1 & EiRRel==22) //other prop: w sp, other
replace rabnfcrot = 1 if EioHwH46==1 | (EioHwH24==1 & EiRRel==22) //other prop: sole, other
replace rabnfcrot = 1 if EioIn2==1 & (EiOthO46==1 | (EiOthO24==1 & EiRRel==22)) //other prop: joint, owners
replace rabnfcrot = 1 if EioInW46==1 | (EioInW24==1 & EiRRel==22) //other prop: joint, other
replace rabnfcrot = 1 if EIPhyW23==1 | (EIPhyWh1==1 & EiRRel==22) //business
replace rabnfcrot = 1 if EiOthA23==1 | (EiOthAs1==1 & EiRRel==22) //other assets


***spouse inherited home***
*wave 4 respondent spouse inherited home
missing_w4 EiAsCk EiHome EiSp EiRRel EiHowH1 EioIn EiOthO1 EioInW1 EioHwH1 if inw`wv'xt==1, result(rahomesp)
replace rahomesp = .t if EiAsCk==2 & EiHome==-1
replace rahomesp = .x if EiHome==2
replace rahomesp = 0 if EiSp==2 //w sp, spouse 
replace rahomesp = 0 if EiHowH2==0 | EiHowH3==0 | EiHowH1==0 | (EiHowH1==1 & inrange(EiRRel,3,22)) //w sp, other
replace rahomesp = 0 if EioIn==2 | (EioIn==1 & ((EiOthO2==0 | EiOthO3==0 | EiOthO1==0) | (EiOthO1==1 & inrange(EiRRel,3,22)))) //joint, owners
replace rahomesp = 0 if EioInW2==0 | EioInW3==0 | EioInW1==0 | (EioInW1==1 & inrange(EiRRel,3,22)) //joint, other
replace rahomesp = 0 if EioHwH2==0 | EioHwH3==0 | EioHwH1==0 | (EioHwH1==1 & inrange(EiRRel,3,22)) //sole, other
replace rahomesp = 1 if EiSp==1 //w sp, spouse
replace rahomesp = 1 if EiHowH2==1 | EiHowH3==1 | (EiHowH1==1 & inlist(EiRRel,1,2)) //w sp, other
replace rahomesp = 1 if EioIn==1 & ((EiOthO2==1 | EiOthO3==1) | (EiOthO1==1 & inlist(EiRRel,1,2))) //joint, owners
replace rahomesp = 1 if EioInW2==1 | EioInW3==1 | (EioInW1==1 & inlist(EiRRel,1,2)) //joint, other
replace rahomesp = 1 if EioHwH2==1 | EioHwH3==1 | (EioHwH1==1 & inlist(EiRRel,1,2)) //sole, other

***child/grandchild inherited home***
*wave 4 respondent child/grandchild inherited home
missing_w4 EiAsCk EiHome EiRRel EiHowH1 EioIn EiOthO1 EioInW1 EioHwH1 EiSp EiSpInH if inw`wv'xt==1, result(rahomech)
replace rahomech = .t if EiAsCk==2 & EiHome==-1
replace rahomech = .x if EiHome==2
replace rahomech = 0 if EiSp==1 & EiSpInH==1 //only sp inherited
replace rahomech = 0 if EiHowH4==0 | EiHowH5==0 | EiHowH6==0 | EiHowH7==0 | EiHowH8==0 | EiHowH20==0 | ///
												EiHowH1==0 | (EiHowH1==1 & (inlist(EiRRel,1,2,20,21,22) | inrange(EiRRel,8,18))) //w sp, toher
replace rahomech = 0 if EioIn==2 | (EioIn==1 & ((EiOthO4==0 | EiOthO5==0 | EiOthO6==0 | EiOthO7==0 | EiOthO8==0 | EiOthO20==0 | EiOthO1==0) | ///
												(EiOthO1==1 & (inlist(EiRRel,1,2,20,21,22) | inrange(EiRRel,8,18))))) //joint, owners
replace rahomech = 0 if EioInW4==0 | EioInW5==0 | EioInW6==0 | EioInW7==0 | EioInW8==0 | EioInW20==0 | ///
												EioInW1==0 | (EioInW1==1 & (inlist(EiRRel,1,2,20,21,22) | inrange(EiRRel,8,18))) //joint, other
replace rahomech = 0 if EioHwH4==0 | EioHwH5==0 | EioHwH6==0 | EioHwH7==0 | EioHwH8==0 | EioHwH20==0 | ///
												EioHwH1==0 | (EioHwH1==1 & (inlist(EiRRel,1,2,20,21,22) | inrange(EiRRel,8,18))) //sole, other
replace rahomech = 1 if EiHowH4==1 | EiHowH5==1 | EiHowH6==1 | EiHowH7==1 | EiHowH8==1 | EiHowH20==1 | ///
												EiHowH1==0 | (EiHowH1==1 & inlist(EiRRel,3,4,5,6,7,19)) //w sp, other
replace rahomech = 1 if EioIn==1 & ((EiOthO4==1 | EiOthO5==1 | EiOthO6==1 | EiOthO7==1 | EiOthO8==1 | EiOthO20==1) | ///
												(EiOthO1==1 & inlist(EiRRel,3,4,5,6,7,19))) //joint, owners
replace rahomech = 1 if EioInW4==1 | EioInW5==1 | EioInW6==1 | EioInW7==1 | EioInW8==1 | EioInW20==1 | ///
												EioInW1==0 | (EioInW1==1 & inlist(EiRRel,3,4,5,6,7,19)) //joint, other 
replace rahomech = 1 if EioHwH4==1 | EioHwH5==1 | EioHwH6==1 | EioHwH7==1 | EioHwH8==1 | EioHwH20==1 | ///
												EioHwH1==0 | (EioHwH1==1 & inlist(EiRRel,3,4,5,6,7,19)) //sole, other

***relative inherited home***
*wave 4 respondent relative inherited home
missing_w4 EiAsCk EiHome EiRRel EiHowH1 EioIn EiOthO1 EioInW1 EioHwH1 EiSp EiSpInH if inw`wv'xt==1, result(rahomerl)
replace rahomerl = .t if EiAsCk==2 & EiHome==-1
replace rahomerl = .x if EiHome==2
replace rahomerl = 0 if EiSp==1 & EiSpInH==1 //only sp inherited
replace rahomerl = 0 if EiHowH9==0 | EiHowH10==0 | EiHowH11==0 | EiHowH12==0 | EiHowH13==0 | EiHowH14==0 | ///
												EiHowH15==0 | EiHowH16==0 | EiHowH17==0 | EiHowH18==0 | EiHowH19==0 | EiHowH21==0 | EiHowH22==0 | ///
												EiHowH1==0 | (EiHowH1==1 & (inrange(EiRRel,1,7) | inlist(EiRRel,19,22))) //w sp, other
replace rahomerl = 0 if EioIn==2 | (EioIn==1 & ((EiOthO9==0 | EiOthO10==0 | EiOthO11==0 | EiOthO12==0 | EiOthO13==0 | EiOthO14==0 | ///
												EiOthO15==0 | EiOthO16==0 | EiOthO17==0 | EiOthO18==0 | EiOthO19==0 | EiOthO21==0 | EiOthO22==0 | EiOthO1==0) | ///
												(EiOthO1==1 & (inrange(EiRRel,1,7) | inlist(EiRRel,19,22))))) //joint, owners
replace rahomerl = 0 if EioInW9==0 | EioInW10==0 | EioInW11==0 | EioInW12==0 | EioInW13==0 | EioInW14==0 | ///
												EioInW15==0 | EioInW16==0 | EioInW17==0 | EioInW18==0 | EioInW19==0 | EioInW21==0 | EioInW22==0 | ///
												EioInW1==0 | (EioInW1==1 & (inrange(EiRRel,1,7) | inlist(EiRRel,19,22))) //joint, other 
replace rahomerl = 0 if EioHwH9==0 | EioHwH10==0 | EioHwH11==0 | EioHwH12==0 | EioHwH13==0 | EioHwH14==0 | ///
												EioHwH15==0 | EioHwH16==0 | EioHwH17==0 | EioHwH18==0 | EioHwH19==0 | EioHwH21==0 | EioHwH22==0 | ///
												EioHwH1==0 | (EioHwH1==1 & (inrange(EiRRel,1,7) | inlist(EiRRel,19,22))) //sole, other
replace rahomerl = 1 if EiHowH9==1 | EiHowH10==1 | EiHowH11==1 | EiHowH12==1 | EiHowH13==1 | EiHowH14==1 | ///
												EiHowH15==1 | EiHowH16==1 | EiHowH17==1 | EiHowH18==1 | EiHowH19==1 | EiHowH21==1 | EiHowH22==1 | ///
												(EiHowH1==1 & (inrange(EiRRel,8,18) | inlist(EiRRel,20,21))) //w sp, other
replace rahomerl = 1 if EioIn==1 & ((EiOthO9==1 | EiOthO10==1 | EiOthO11==1 | EiOthO12==1 | EiOthO13==1 | EiOthO14==1 | ///
												EiOthO15==1 | EiOthO16==1 | EiOthO17==1 | EiOthO18==1 | EiOthO19==1 | EiOthO21==1 | EiOthO22==1) | ///
												(EiOthO1==1 & (inrange(EiRRel,8,18) | inlist(EiRRel,20,21)))) //joint, owners
replace rahomerl = 1 if EioInW9==1 | EioInW10==1 | EioInW11==1 | EioInW12==1 | EioInW13==1 | EioInW14==1 | ///
												EioInW15==1 | EioInW16==1 | EioInW17==1 | EioInW18==1 | EioInW19==1 | EioInW21==1 | EioInW22==1 | ///
												(EioInW1==1 & (inrange(EiRRel,8,18) | inlist(EiRRel,20,21))) //joint, other
replace rahomerl = 1 if EioHwH9==1 | EioHwH10==1 | EioHwH11==1 | EioHwH12==1 | EioHwH13==1 | EioHwH14==1 | ///
												EioHwH15==1 | EioHwH16==1 | EioHwH17==1 | EioHwH18==1 | EioHwH19==1 | EioHwH21==1 | EioHwH22==1 | ///
												(EioHwH1==1 & (inrange(EiRRel,8,18) | inlist(EiRRel,20,21))) //sole, other

***other inherited home***
*wave 4 respondent other inherited home
missing_w4 EiAsCk EiHome EiRRel EiHowH1 EioIn EiOthO1 EioInW1 EioHwH1 EiSp EiSpInH if inw`wv'xt==1, result(rahomeot)
replace rahomeot = .t if EiAsCk==2 & EiHome==-1
replace rahomeot = .x if EiHome==2
replace rahomeot = 0 if EiSp==1 & EiSpInH==1 //only sp inherited
replace rahomeot = 0 if EiHowH23==0 | EiHowH36==0 | EiHowH37==0 | EiHowH1==0 | (EiHowH1==1 & inrange(EiRRel,1,21)) //w sp, other
replace rahomeot = 0 if EioIn==2 | (EioIn==1 & ((EiOthO23==0 | EiOthO1==0) | (EiOthO1==0 & inrange(EiRRel,1,21)))) //joint, owners
replace rahomeot = 0 if EioInW23==0 | EioInW1==0 | (EioInW1==1 & inrange(EiRRel,1,21)) //joint, other
replace rahomeot = 0 if EioHwH23==0 | EioHwH1==0 | (EioHwH1==1 & inrange(EiRRel,1,21)) //sole, other
replace rahomeot = 1 if EiHowH23==1 | EiHowH36==1 | EiHowH37==1 | (EiHowH1==1 & EiRRel==22) //w sp, other 
replace rahomeot = 1 if EioIn==1 & (EiOthO23==1 | (EiOthO1==1 & EiRRel==22)) //joint, owners
replace rahomeot = 1 if EioInW23==1 | (EioInW1==1 & EiRRel==22) //joint, other
replace rahomeot = 1 if EioHwH23==1 | (EioHwH1==1 & EiRRel==22) //sole, other


***whether spouse was beneficiary of pension***
*wave 4 respondent spouse was beneficiary
missing_w4 EiRRel EiPenWho EiPenWh2 EiPenWh3 if inw`wv'xt==1, result(rapensp)
replace rapensp = .d if EiPenM==3 | EiPen96==1 | EiPen98==1 | EiPen100==1
replace rapensp = .n if EiPenM==2 | EiPen5==1 | EiPen10==1 | EiPen15==1
replace rapensp = .o if EiPen95==1 | EiPen97==1 | EiPen99==1
replace rapensp = 0 if EiPenWho==1 | EiPenWh2==1 | EiPenWh3==1 | ///
												inrange(EiPenWho,4,23) | inrange(EiPenWh2,4,23) | inrange(EiPenWh3,4,23) 
replace rapensp = 1 if inlist(EiPenWho,2,3) | inlist(EiPenWh2,2,3) | inlist(EiPenWh3,2,3) | ///
												((EiPenWho==1 | EiPenWh2==1 | EiPenWh3==1) & inlist(EiRRel,1,2)) 

***whether child/grandchild was beneficary of pension***
*wave 4 respondent child/grandchild was beneficiary
missing_w4 EiRRel EiPenWho EiPenWh2 EiPenWh3 if inw`wv'xt==1, result(rapencg)
replace rapencg = .d if EiPenM==3 | EiPen96==1 | EiPen98==1 | EiPen100==1
replace rapencg = .n if EiPenM==2 | EiPen5==1 | EiPen10==1 | EiPen15==1
replace rapencg = .o if EiPen95==1 | EiPen97==1 | EiPen99==1
replace rapencg = 0 if inlist(EiPenWho,1,2,3,21,22,23) | inlist(EiPenWh2,1,2,3,21,22,23) | inlist(EiPenWh3,1,2,3,21,22,23) | ///
												inrange(EiPenWho,9,19) | inrange(EiPenWh2,9,19) | inrange(EiPenWh3,9,19) 
replace rapencg = 1 if inlist(EiPenWho,4,5,6,7,8,20) | inlist(EiPenWh2,4,5,6,7,8,20) | inlist(EiPenWh3,4,5,6,7,8,20) | ///
												((EiPenWho==1 | EiPenWh2==1 | EiPenWh3==1) & inlist(EiRRel,3,4,5,6,7,19)) 
												
***whether relative was beneficiary of pension***
*wave 4 respondent relative was beneficiary
missing_w4 EiRRel EiPenWho EiPenWh2 EiPenWh3 if inw`wv'xt==1, result(rapenrl)
replace rapenrl = .d if EiPenM==3 | EiPen96==1 | EiPen98==1 | EiPen100==1
replace rapenrl = .n if EiPenM==2 | EiPen5==1 | EiPen10==1 | EiPen15==1
replace rapenrl = .o if EiPen95==1 | EiPen97==1 | EiPen99==1
replace rapenrl = 0 if inrange(EiPenWho,1,8) | inrange(EiPenWh2,1,8) | inrange(EiPenWh3,1,8) | ///
												inlist(EiPenWho,20,23) | inlist(EiPenWh2,20,23) | inlist(EiPenWh3,20,23) 
replace rapenrl = 1 if inrange(EiPenWho,9,19) | inrange(EiPenWh2,9,19) | inrange(EiPenWh3,9,19) | ///
												inlist(EiPenWho,21,22) | inlist(EiPenWh2,21,22) | inlist(EiPenWh3,21,22) | ///
												((EiPenWho==1 | EiPenWh2==1 | EiPenWh3==1) & (inrange(EiRRel,8,18) | inlist(EiRRel,20,21))) 

***whether other person was beneficiary of pension***
*wave 4 respondent other person was beneficiary
missing_w4 EiRRel EiPenWho EiPenWh2 EiPenWh3 if inw`wv'xt==1, result(rapenot)
replace rapenot = .d if EiPenM==3 | EiPen96==1 | EiPen98==1 | EiPen100==1
replace rapenot = .n if EiPenM==2 | EiPen5==1 | EiPen10==1 | EiPen15==1
replace rapenot = .o if EiPen95==1 | EiPen97==1 | EiPen99==1
replace rapenot = 0 if inrange(EiPenWho,1,22) | inrange(EiPenWh2,1,22) | inrange(EiPenWh3,1,22) 
replace rapenot = 1 if EiPenWho==23 | EiPenWh2==23 | EiPenWh3==23 | ///
												((EiPenWho==1 | EiPenWh2==1 | EiPenWh3==1) & EiRRel==22) 


***death expenses***
gen oopdeath = .
replace oopdeath = 1400 if DVEidcsta==1
replace oopdeath = 3100 if DVEidcsta==2
replace oopdeath = 4000 if DVEidcsta==3
replace oopdeath = 21300 if DVEidcsta==4
gen insurance = .
replace insurance = 600 if DVEifuins==1
replace insurance = 1700 if DVEifuins==2
replace insurance = 3100 if DVEifuins==3
replace insurance = 12000 if DVEifuins==4

*paid on own
replace selfo = 0 if EiDcstb==2
replace selfo = 1 if inlist(EiDcstb,1,3)

replace self = oopdeath if inrange(oopdeath,0,30000)

*paid by ins
replace inso = 0 if EiDcstb==3
replace inso = 1 if inlist(EiDcstb,1,2)

replace ins = insurance if inrange(insurance,0,20000)


***any costs covered by insurance (excl. life)***
*wave 4 respondent any costs covered by insurance
missing_w4 EiDcstb radexpense if inw`wv'xt==1, result(rainscovr)
replace rainscovr = 0 if EiDcstb==3
replace rainscovr = 1 if inlist(EiDcstb,1,2)


***amount insurance paid out***
*wave 4 respondent amount insurance paid out
drop oopdeath insurance


***has living will***
*wave 4 respondent has living will
replace ralvwill = .q if inw`wv'xt==1


***desire to limit care in certain situations***
*wave 4 respondent desire to limit care in certain situations
replace ralmtcare = .q if inw`wv'xt==1


***whether had a durable power of attorney for healthcare***
*wave 4 respondent whether had a durable power of attorney for healthcare
replace radpoafh = .q if inw`wv'xt==1


***Whether spouse was dpoafh***
*wave 4 respondent spouse was dpoafh
replace radpoasp = .q if inw`wv'xt==1


***Whether child was dpoafh***
*wave 4 respondent child was dpoafh
replace radpoach = .q if inw`wv'xt==1


***Whether relative was dpoafh***
*wave 4 respondent relative was dpoafh
replace radpoarl = .q if inw`wv'xt==1


***Whether friend was dpoafh***
*wave 4 respondent friend was dpoafh
replace radpoafr = .q if inw`wv'xt==1


***Whether non-relative was dpoafh***
*wave 4 respondent non-relative was dpoafh
replace radpoanr = .q if inw`wv'xt==1


***Whether doctor was dpoafh***
*wave 4 respondent doctor was dpoafh
replace radpoadr = .q if inw`wv'xt==1


***Whether religious advisor was dpoafh***
*wave 4 respondent religious advisor was dpoafh
replace radpoara = .q if inw`wv'xt==1


***Whether legal professional was dpoafh***
*wave 4 respondent legal professional was dpoafh
replace radpoalp = .q if inw`wv'xt==1


***Whether social worker was dpoafh***
*wave 4 respondent social worker was dpoafh
replace radpoasw = .q if inw`wv'xt==1


***Whether other was dpoafh***
*wave 4 respondent other was dpoafh
replace radpoaot = .q if inw`wv'xt==1

***whether non-family member was dpoafh***
*wave 4 respondent non-family member was dpoafh
replace radpoanf = .q if inw`wv'xt==1


***any life insurance policies***
*wave 4 respondent any life insurance policies
missing_w4 EiAsCk EiLI if inw`wv'xt==1, result(raxlifeins)
replace raxlifeins = .t if EiAsCk==2 & EiLI==-1
replace raxlifeins = 0 if EiLI==2
replace raxlifeins = 1 if EiLI==1


***whether spouse is beneficiary of life insurance policies***
*wave 4 respondent spouse is beneficiary of life insurance policies
missing_w4 EiAsCk EiLI EiRRel EiLIWh1 EiLIWh2 EiLIWh3 if inw`wv'xt==1, result(ralfinssp)
replace ralfinssp = .t if EiAsCk==2 & EiLI==-1
replace ralfinssp = .n if raxlifeins==0 & inw`wv'xt==1
replace ralfinssp = 0 if EiLIWh1==0 | (EiLIWh1==1 & !inlist(EiRRel,1,2)) | EiLIWh2==0 | EiLIWh3==0
replace ralfinssp = 1 if (EiLIWh1==1 & inlist(EiRRel,1,2)) | EiLIWh2==1 | EiLIWh3==1


***whether child is beneficiary of life insurance policies***
*wave 4 respondent child is beneficiary of life insurance policies
missing_w4 EiAsCk EiLI EiRRel EiLIWh1 EiLIWh4 EiLIWh5 EiLIWh6 EiLIWh7 EiLIWh8 if inw`wv'xt==1, result(ralfinsch)
replace ralfinsch = .t if EiAsCk==2 & EiLI==-1
replace ralfinsch = .n if raxlifeins==0 & inw`wv'xt==1
replace ralfinsch = 0 if EiLIWh1==0 | (EiLIWh1==1 & !inrange(EiRRel,3,7)) | ///
													EiLIWh4==0 | EiLIWh5==0 | EiLIWh6==0 | EiLIWh7==0 | EiLIWh8==0
replace ralfinsch = 1 if (EiLIWh1==1 & inlist(EiRRel,1,2)) | ///
													EiLIWh4==1 | EiLIWh5==1 | EiLIWh6==1 | EiLIWh7==1 | EiLIWh8==1


***whether grandchild is beneficiary of life insurance policies***
*wave 4 respondent grandchild is beneficiary of life insurance policies
missing_w4 EiAsCk EiLI EiRRel EiLIWh1 EiLIWh20 if inw`wv'xt==1, result(ralfinsgk)
replace ralfinsgk = .t if EiAsCk==2 & EiLI==-1
replace ralfinsgk = .n if raxlifeins==0 & inw`wv'xt==1
replace ralfinsgk = 0 if EiLIWh1==0 | (EiLIWh1==1 & EiRRel!=19) | EiLIWh20==0 
replace ralfinsgk = 1 if (EiLIWh1==1 & EiRRel==19) | EiLIWh20==1 


***whether relative is beneficiary of life insurance policies***
*wave 4 respondent relative is beneficiary of life insurance policies
missing_w4 EiAsCk EiLI EiRRel EiLIWh1 EiLIWh9 EiLIWh10 EiLIWh11 EiLIWh12 EiLIWh13 ///
			EiLIWh14 EiLIWh15 EiLIWh16 EiLIWh17 EiLIWh18 EiLIWh19 EiLIWh21 EiLIWh22 if inw`wv'xt==1, result(ralfinsrl)
replace ralfinsrl = .t if EiAsCk==2 & EiLI==-1
replace ralfinsrl = .n if raxlifeins==0 & inw`wv'xt==1
replace ralfinsrl = 0 if EiLIWh1==0 | (EiLIWh1==1 & (!inrange(EiRRel,8,18) | EiRRel!=21)) | ///
													EiLIWh9==0 | EiLIWh10==0 | EiLIWh11==0 | EiLIWh12==0 | EiLIWh13==0 | ///
													EiLIWh14==0 | EiLIWh15==0 | EiLIWh16==0 | EiLIWh17==0 | EiLIWh18==0 | ///
													EiLIWh19==0 | EiLIWh21==0 | EiLIWh22==0
replace ralfinsrl = 1 if (EiLIWh1==1 & (inrange(EiRRel,8,18) | EiRRel==21)) | ///
													EiLIWh9==1 | EiLIWh10==1 | EiLIWh11==1 | EiLIWh12==1 | EiLIWh13==1 | ///
													EiLIWh14==1 | EiLIWh15==1 | EiLIWh16==1 | EiLIWh17==1 | EiLIWh18==1 | ///
													EiLIWh19==1 | EiLIWh21==1 | EiLIWh22==1


***whether other non-relative is beneficiary of life insurance policies***
*wave 4 respondent other non-relative is beneficiary of life insurance policies
missing_w4 EiAsCk EiLI EiRRel EiLIWh1 EiLIWh23 if inw`wv'xt==1, result(ralfinsot)
replace ralfinsot = .t if EiAsCk==2 & EiLI==-1
replace ralfinsot = .n if raxlifeins==0 & inw`wv'xt==1
replace ralfinsot = 0 if EiLIWh1==0 | (EiLIWh1==1 & EiRRel!=22) | EiLIWh23==0 
replace ralfinsot = 1 if (EiLIWh1==1 & EiRRel==22) | EiLIWh23==1 


***value of life insurance policies***
*wave 4 respondent value of life insurance policies
*values are supplied in ranges - midpoint of range is assigned
gen value = .
replace value = 0 if raxlifeins==0 & inw`wv'xt==1
replace value = 900 if DVEiLIa==1 //1-1800
replace value = 2900 if DVEiLIa==2 //1800.01-4000
replace value = 12000 if DVEiLIa==3 //4000.01-20000

replace lifeo = 0 if inlist(raxlifeins,0,.t) & inw`wv'xt==1
replace lifeo = 1 if raxlifeins==1 & inw`wv'xt==1

replace life = value if inrange(value,0,200000)

drop value



***drop H_ELSA wave 4 core file raw variables***
drop `eolxt_w4_exit'



******************************************************************************************


*set wave number
local wv=6
local pre_wv=5

***merge with wave 6 exit data***
local eolxt_w6_exit EiWillA EiProb EiWillB DVEidcsta EiDcstb DVEifuins EiAsCk EiLI EiLIWh1 EiLIWh2 EiLIWh3 ///
										EiLIWh4 EiLIWh5 EiLIWh6 EiLIWh7 EiLIWh8 EiLIWh9 EiLIWh10 EiLIWh11 EiLIWh12 EiLIWh13 EiLIWh14 ///
										EiLIWh15 EiLIWh16 EiLIWh17 EiLIWh18 EiLIWh19 EiLIWh20 EiLIWh21 EiLIWh22 EiLIWh23 ///
										EiRRel DVEiLIa EIHIT EIHIL EIHLA ///
										EIHLN1 EIHLN2 EIHLN3 EIHLN4 EIHLN5 EIHLN6 EIHLN7 EIHLN8 EIHLN9 EIHLN10 EIHLN98 EIHLN99 ///
										EiPenWho EiPenWh2 EiPenWh3 EiPenWh4 EiKin EiBen EiSp EiSp2 EioIn EioIn2 EiSpInH EiSpInH2 EiHome ///
										EiHowH1 EiHowH2 EiHowH3 EiHowH4 EiHowH5 EiHowH6 EiHowH7 EiHowH8 EiHowH9 EiHowH10 EiHowH11 EiHowH12 EiHowH13 ///
										EiHowH14 EiHowH15 EiHowH16 EiHowH17 EiHowH18 EiHowH19 EiHowH20 EiHowH21 EiHowH22 EiHowH23 EiHowH36 EiHowH37 ///
										EiHowH39 EiHowH40 EiHowH41 EiHowH42 EiHowH43 EiHowH44 EiHowH45 EiHowH46 EiHowH47 EiHowH48 EiHowH49 EiHowH50 ///
										EiHowH51 EiHowH52 EiHowH53 EiHowH54 EiHowH55 EiHowH56 EiHowH57 EiHowH58 EiHowH59 EiHowH60 EiHowH61 ///
										EiOthO1 EiOthO2 EiOthO3 EiOthO4 EiOthO5 EiOthO6 EiOthO7 EiOthO8 EiOthO9 EiOthO10 EiOthO11 EiOthO12 EiOthO13 ///
										EiOthO14 EiOthO15 EiOthO16 EiOthO17 EiOthO18 EiOthO19 EiOthO20 EiOthO21 EiOthO22 EiOthO23 ///
										EiOthO24 EiOthO25 EiOthO26 EiOthO27 EiOthO28 EiOthO29 EiOthO30 EiOthO31 EiOthO32 EiOthO33 EiOthO34 EiOthO35 ///
										EiOthO36 EiOthO37 EiOthO38 EiOthO39 EiOthO40 EiOthO41 EiOthO42 EiOthO43 EiOthO44 EiOthO45 EiOthO46 ///
										EioInW1 EioInW2 EioInW3 EioInW4 EioInW5 EioInW6 EioInW7 EioInW8 EioInW9 EioInW10 EioInW11 EioInW12 EioInW13 ///
										EioInW14 EioInW15 EioInW16 EioInW17 EioInW18 EioInW19 EioInW20 EioInW21 EioInW22 EioInW23 ///
										EioInW24 EioInW25 EioInW26 EioInW27 EioInW28 EioInW29 EioInW30 EioInW31 EioInW32 EioInW33 EioInW34 EioInW35 ///
										EioInW36 EioInW37 EioInW38 EioInW39 EioInW40 EioInW41 EioInW42 EioInW43 EioInW44 EioInW45 EioInW46 ///
										EioHwH1 EioHwH2 EioHwH3 EioHwH4 EioHwH5 EioHwH6 EioHwH7 EioHwH8 EioHwH9 EioHwH10 EioHwH11 EioHwH12 EioHwH13 ///
										EioHwH14 EioHwH15 EioHwH16 EioHwH17 EioHwH18 EioHwH19 EioHwH20 EioHwH21 EioHwH22 EioHwH23 ///
										EioHwH24 EioHwH25 EioHwH26 EioHwH27 EioHwH28 EioHwH29 EioHwH30 EioHwH31 EioHwH32 EioHwH33 EioHwH34 EioHwH35 ///
										EioHwH36 EioHwH37 EioHwH38 EioHwH39 EioHwH40 EioHwH41 EioHwH42 EioHwH43 EioHwH44 EioHwH45 EioHwH46 ///
										EIPhyWh1 EIPhyWh2 EIPhyWh3 EIPhyWh4 EIPhyWh5 EIPhyWh6 EIPhyWh7 EIPhyWh8 EIPhyWh9 EIPhyW10 EIPhyW11 EIPhyW12 ///
										EIPhyW13 EIPhyW14 EIPhyW15 EIPhyW16 EIPhyW17 EIPhyW18 EIPhyW19 EIPhyW20 EIPhyW21 EIPhyW22 EIPhyW23 ///
										EiOthAs1 EiOthAs2 EiOthAs3 EiOthAs4 EiOthAs5 EiOthAs6 EiOthAs7 EiOthAs8 EiOthAs9 EiOthA10 EiOthA11 EiOthA12 ///
										EiOthA13 EiOthA14 EiOthA15 EiOthA16 EiOthA17 EiOthA18 EiOthA19 EiOthA20 EiOthA21 EiOthA22 EiOthA23 EiOthA24 ///
										EiPenM EiPen5 EiPen10 EiPen15 EiPen20 EiPen95 EiPen96 EiPen97 EiPen98 EiPen99 EiPen100 EiPen102 EiPen103 ///
										EiHowH1 EiHowH2 EiHowH3 EiHowH4 EiHowH5 EiHowH6 EiHowH7 EiHowH8 EiHowH9 EiHowH10 EiHowH11 EiHowH12 EiHowH13 ///
										EiHowH14 EiHowH15 EiHowH16 EiHowH17 EiHowH18 EiHowH19 EiHowH20 EiHowH21 EiHowH22 EiHowH23 EiHowH36 EiHowH37 ///
										EiOthO1 EiOthO2 EiOthO3 EiOthO4 EiOthO5 EiOthO6 EiOthO7 EiOthO8 EiOthO9 EiOthO10 EiOthO11 EiOthO12 ///
										EiOthO13 EiOthO14 EiOthO15 EiOthO16 EiOthO17 EiOthO18 EiOthO19 EiOthO20 EiOthO21 EiOthO22 EiOthO23 /// 
										EioHwH1 EioHwH2 EioHwH3 EioHwH4 EioHwH5 EioHwH6 EioHwH7 EioHwH8 EioHwH9 EioHwH10 EioHwH11 EioHwH12 ///
										EioHwH13 EioHwH14 EioHwH15 EioHwH16 EioHwH17 EioHwH18 EioHwH19 EioHwH20 EioHwH21 EioHwH22 EioHwH23 ///
										EioInW1 EioInW2 EioInW3 EioInW4 EioInW5 EioInW6 EioInW7 EioInW8 EioInW9 EioInW10 EioInW11 EioInW12 ///
										EioInW13 EioInW14 EioInW15 EioInW16 EioInW17 EioInW18 EioInW19 EioInW20 EioInW21 EioInW22 EioInW23 
merge 1:1 idauniq using "$wave_6_xt", keepusing(`eolxt_w6_exit') nogen




replace notdist = 1 if EiAsCk==2

***whether had a witnessed will***
*wave 6 respondent whether had a witnessed will
missing_w6 EiWillA EiAsCk if inw`wv'xt==1, result(rawitwill)
replace rawitwill = .d if EiWillA==3
replace rawitwill = .t if EiAsCk==2 & EiWillA==-1
replace rawitwill = 0 if EiWillA==2
replace rawitwill = 1 if EiWillA==1


***whether will has been through probate***
*wave 6 respondent whether will has been through probate
missing_w6 EiWillB EiProb rawitwill if inw`wv'xt==1, result(raprobate)
replace raprobate = .d if EiProb==3
replace raprobate = .t if EiAsCk==2 & EiWillA==-1
replace raprobate = .w if rawitwill==0 & inw`wv'xt==1
replace raprobate = 1 if EiProb==2 
replace raprobate = 2 if EiProb==1 & EiWillB==2
replace raprobate = 3 if EiProb==1 & EiWillB==1

***whether proxy was beneficiary of will***
*wave 6 respondent proxy was beneficiary
missing_w6 EiBen rawitwill if inw`wv'xt==1, result(rawillp)
replace rawillp = .d if EiBen==3
replace rawillp = .t if EiAsCk==2 | EiBen==4
replace rawillp = .w if rawitwill==0 & inw`wv'xt==1
replace rawillp = 0 if EiBen==2 //proxy will beneficiary
replace rawillp = 1 if EiBen==1 //proxy will beneficiary


***whether spouse was beneficiary of estate***
*wave 6 respondent spouse was beneficiary
missing_w6 EiRRel EiAsCk EiOthA24 EiOthAs1 EiOthAs2 EiOthAs3 if inw`wv'xt==1, result(rabnfcrsp)
replace rabnfcrsp = .t if EiAsCk==2
replace rabnfcrsp = 0 if EiSp==2 //house: w sp, spouse 
replace rabnfcrsp = 0 if EiHowH2==0 | EiHowH3==0 | EiHowH1==0 | (EiHowH1==1 & inrange(EiRRel,3,22)) //house: w sp, other
replace rabnfcrsp = 0 if EioHwH2==0 | EioHwH3==0 | EioHwH1==0 | (EioHwH1==1 & inrange(EiRRel,3,22)) //house: sole, other
replace rabnfcrsp = 0 if EioIn==2 | (EioIn==1 & ((EiOthO2==0 | EiOthO3==0 | EiOthO1==0) | (EiOthO1==1 & inrange(EiRRel,3,22)))) //house: joint, owners
replace rabnfcrsp = 0 if EioInW2==0 | EioInW3==0 | EioInW1==0 | (EioInW1==1 & inrange(EiRRel,3,22)) //house: joint, other
replace rabnfcrsp = 0 if EiSp2==2 //other prop: w sp, spouse
replace rabnfcrsp = 0 if EiHowH40==0 | EiHowH41==0 | EiHowH39==0 | (EiHowH39==1 & inrange(EiRRel,3,22)) //other prop: w sp, other
replace rabnfcrsp = 0 if EioHwH25==0 | EioHwH26==0 | EioHwH24==0 | (EioHwH24==1 & inrange(EiRRel,3,22)) //other prop: sole, other
replace rabnfcrsp = 0 if EioIn2==2 | (EioIn2==1 & ((EiOthO25==0 | EiOthO26==0 | EiOthO24==0) | (EiOthO24==1 & inrange(EiRRel,3,22)))) //other prop: joint, owners
replace rabnfcrsp = 0 if EioInW25==0 | EioInW26==0 | EioInW24==0 | (EioInW24==1 & inrange(EiRRel,3,22)) //other prop: joint, other
replace rabnfcrsp = 0 if EIPhyWh2==0 | EIPhyWh3==0 | EIPhyWh1==0 | (EIPhyWh1==1 & inrange(EiRRel,3,22)) //business
replace rabnfcrsp = 0 if EiOthA24==1 | EiOthAs2==0 | EiOthAs3==0 | EiOthAs1==0 | (EiOthAs1==1 & inrange(EiRRel,3,22)) //other assets
replace rabnfcrsp = 1 if EiSp==1 //house: w sp, spouse
replace rabnfcrsp = 1 if EiHowH2==1 | EiHowH3==1 | (EiHowH1==1 & inlist(EiRRel,1,2)) //house: w sp, other
replace rabnfcrsp = 1 if EioHwH2==1 | EioHwH3==1 | (EioHwH1==1 & inlist(EiRRel,1,2)) //house: sole, other
replace rabnfcrsp = 1 if EioIn==1 & ((EiOthO2==1 | EiOthO3==1) | (EiOthO1==1 & inlist(EiRRel,1,2))) //house: joint, owners
replace rabnfcrsp = 1 if EioInW2==1 | EioInW3==1 | (EioInW1==1 & inlist(EiRRel,1,2)) //house: joint, other
replace rabnfcrsp = 1 if EiSp2==1 //other prop: w sp, spouse
replace rabnfcrsp = 1 if EiHowH40==1 | EiHowH41==1 | (EiHowH39==1 & inlist(EiRRel,1,2)) //other prop: w sp, other
replace rabnfcrsp = 1 if EioHwH25==1 | EioHwH26==1 | (EioHwH24==1 & inlist(EiRRel,1,2)) //other prop: sole, other
replace rabnfcrsp = 1 if EioIn2==1 & ((EiOthO25==1 | EiOthO26==1) | (EiOthO24==1 & inlist(EiRRel,1,2))) //other prop: joint, owners
replace rabnfcrsp = 1 if EioInW25==1 | EioInW26==1 | (EioInW24==1 & inlist(EiRRel,1,2)) //other prop: joint, other
replace rabnfcrsp = 1 if EIPhyWh2==1 | EIPhyWh3==1 | (EIPhyWh1==1 & inlist(EiRRel,1,2)) //business
replace rabnfcrsp = 1 if EiOthAs2==1 | EiOthAs3==1 | (EiOthAs1==1 & inlist(EiRRel,1,2)) //other assets

***whether child/grandchild was beneficary of estate***
*wave 6 respondent child/grandchild was beneficiary
missing_w6 EiRRel EiAsCk if inw`wv'xt==1, result(rabnfcrcg)
replace rabnfcrcg = .t if EiAsCk==2
replace rabnfcrcg = 0 if EiSp==1 & EiSpInH==1 //house: only sp inherited
replace rabnfcrcg = 0 if EiHowH4==0 | EiHowH5==0 | EiHowH6==0 | EiHowH7==0 | EiHowH8==0 | EiHowH20==0 | ///
												EiHowH1==0 | (EiHowH1==1 & (inlist(EiRRel,1,2,20,21,22) | inrange(EiRRel,8,18))) //house: w sp, other
replace rabnfcrcg = 0 if EioHwH4==0 | EioHwH5==0 | EioHwH6==0 | EioHwH7==0 | EioHwH8==0 | EioHwH20==0 | ///
												EioHwH1==0 | (EioHwH1==1 & (inlist(EiRRel,1,2,20,21,22) | inrange(EiRRel,8,18))) //house: sole, toher
replace rabnfcrcg = 0 if EioIn==2 | (EioIn==1 & ((EiOthO4==0 | EiOthO5==0 | EiOthO6==0 | EiOthO7==0 | EiOthO8==0 | EiOthO20==0 | EiOthO1==0) | ///
												(EiOthO1==1 & (inlist(EiRRel,1,2,20,21,22) | inrange(EiRRel,8,18))))) //house: joint, owners
replace rabnfcrcg = 0 if EioInW4==0 | EioInW5==0 | EioInW6==0 | EioInW7==0 | EioInW8==0 | EioInW20==0 | ///
												EioInW1==0 | (EioInW1==1 & (inlist(EiRRel,1,2,20,21,22) | inrange(EiRRel,8,18))) //house: joint, other
replace rabnfcrcg = 0 if EiSp2==1 & EiSpInH2==1 //other prop: only sp inherited
replace rabnfcrcg = 0 if EiHowH42==0 | EiHowH43==0 | EiHowH44==0 | EiHowH45==0 | EiHowH46==0 | EiHowH58==0 | ///
												EiHowH39==0 | (EiHowH39==1 & (inlist(EiRRel,1,2,20,21,22) | inrange(EiRRel,8,18))) //other prop: w sp, other
replace rabnfcrcg = 0 if EioHwH27==0 | EioHwH28==0 | EioHwH29==0 | EioHwH30==0 | EioHwH31==0 | EioHwH43==0 | ///
												EioHwH24==0 | (EioHwH24==1 & (inlist(EiRRel,1,2,20,21,22) | inrange(EiRRel,8,18))) //other prop: sole, other
replace rabnfcrcg = 0 if EioIn2==2 | (EioIn2==1 & ((EiOthO27==0 | EiOthO28==0 | EiOthO29==0 | EiOthO30==0 | EiOthO31==0 | EiOthO43==0 | EiOthO24==0) | ///
												(EiOthO24==1 & (inlist(EiRRel,1,2,20,21,22) | inrange(EiRRel,8,18))))) //other prop: joint, owners
replace rabnfcrcg = 0 if EioInW27==0 | EioInW28==0 | EioInW29==0 | EioInW30==0 | EioInW31==0 | EioInW43==0 | ///
												EioInW24==0 | (EioInW24==1 & (inlist(EiRRel,1,2,20,21,22) | inrange(EiRRel,8,18))) //other prop: joint, other
replace rabnfcrcg = 0 if EIPhyWh4==0 | EIPhyWh5==0 | EIPhyWh6==0 | EIPhyWh7==0 | EIPhyWh8==0 | EIPhyW20==0 | ///
												EIPhyWh1==0 | (EIPhyWh1==1 & (inlist(EiRRel,1,2,20,21,22) | inrange(EiRRel,8,18))) //business
replace rabnfcrcg = 0 if EiOthA24==1 | EiOthAs4==0 | EiOthAs5==0 | EiOthAs6==0 | EiOthAs7==0 | EiOthAs8==0 | EiOthA20==0 | ///
												EiOthAs1==0 | (EiOthAs1==1 & (inlist(EiRRel,1,2,20,21,22) | inrange(EiRRel,8,18))) //other assets
replace rabnfcrcg = 1 if EiHowH4==1 | EiHowH5==1 | EiHowH6==1 | EiHowH7==1 | EiHowH8==1 | EiHowH20==1 | ///
												EiHowH1==0 | (EiHowH1==1 & inlist(EiRRel,3,4,5,6,7,19)) //house: w sp, other
replace rabnfcrcg = 1 if EioHwH4==1 | EioHwH5==1 | EioHwH6==1 | EioHwH7==1 | EioHwH8==1 | EioHwH20==1 | ///
												EioHwH1==0 | (EioHwH1==1 & inlist(EiRRel,3,4,5,6,7,19)) //house: sole, other
replace rabnfcrcg = 1 if EioIn==1 & ((EiOthO4==1 | EiOthO5==1 | EiOthO6==1 | EiOthO7==1 | EiOthO8==1 | EiOthO20==1) | ///
												(EiOthO1==1 & inlist(EiRRel,3,4,5,6,7,19))) //house: joint, owners
replace rabnfcrcg = 1 if EioInW4==1 | EioInW5==1 | EioInW6==1 | EioInW7==1 | EioInW8==1 | EioInW20==1 | ///
												EioInW1==0 | (EioInW1==1 & inlist(EiRRel,3,4,5,6,7,19)) //house: joint, other						
replace rabnfcrcg = 1 if EiHowH42==1 | EiHowH43==1 | EiHowH44==1 | EiHowH45==1 | EiHowH46==1 | EiHowH58==1 | ///
												EiHowH39==0 | (EiHowH39==1 & inlist(EiRRel,3,4,5,6,7,19)) //other prop: w sp, other
replace rabnfcrcg = 1 if EioHwH27==1 | EioHwH28==1 | EioHwH29==1 | EioHwH30==1 | EioHwH31==1 | EioHwH43==1 | ///
												EioHwH24==0 | (EioHwH24==1 & inlist(EiRRel,3,4,5,6,7,19)) //other prop: sole, other
replace rabnfcrcg = 1 if EioIn2==1 & ((EiOthO27==1 | EiOthO28==1 | EiOthO29==1 | EiOthO30==1 | EiOthO31==1 | EiOthO43==1) | ///
												(EiOthO24==1 & inlist(EiRRel,3,4,5,6,7,19))) //other prop: joint, owners
replace rabnfcrcg = 1 if EioInW27==1 | EioInW28==1 | EioInW29==1 | EioInW30==1 | EioInW31==1 | EioInW43==1 | ///
												EioInW24==0 | (EioInW24==1 & inlist(EiRRel,3,4,5,6,7,19)) //other prop: joint, other					
replace rabnfcrcg = 1 if EIPhyWh4==1 | EIPhyWh5==1 | EIPhyWh6==1 | EIPhyWh7==1 | EIPhyWh8==1 | EIPhyW20==1 | ///
												(EIPhyWh1==1 & inlist(EiRRel,3,4,5,6,7,19)) //business
replace rabnfcrcg = 1 if EiOthAs4==1 | EiOthAs5==1 | EiOthAs6==1 | EiOthAs7==1 | EiOthAs8==1 | EiOthA20==1 | ///
												(EiOthAs1==1 & inlist(EiRRel,3,4,5,6,7,19)) //other assets

***whether relative was beneficiary of estate***
*wave 6 respondent relative was beneficiary
missing_w6 EiRRel EiAsCk if inw`wv'xt==1, result(rabnfcrrl)
replace rabnfcrrl = .t if EiAsCk==2
replace rabnfcrrl = 0 if EiSp==1 & EiSpInH==1 //house: only sp inherited
replace rabnfcrrl = 0 if EiHowH9==0 | EiHowH10==0 | EiHowH11==0 | EiHowH12==0 | EiHowH13==0 | EiHowH14==0 | ///
												EiHowH15==0 | EiHowH16==0 | EiHowH17==0 | EiHowH18==0 | EiHowH19==0 | EiHowH21==0 | EiHowH22==0 | ///
												EiHowH1==0 | (EiHowH1==1 & (inrange(EiRRel,1,7) | inlist(EiRRel,19,22))) //house: w sp, other
replace rabnfcrrl = 0 if EioHwH9==0 | EioHwH10==0 | EioHwH11==0 | EioHwH12==0 | EioHwH13==0 | EioHwH14==0 | ///
												EioHwH15==0 | EioHwH16==0 | EioHwH17==0 | EioHwH18==0 | EioHwH19==0 | EioHwH21==0 | EioHwH22==0 | ///
												EioHwH1==0 | (EioHwH1==1 & (inrange(EiRRel,1,7) | inlist(EiRRel,19,22))) //house: sole, other
replace rabnfcrrl = 0 if EioIn==2 | (EioIn==1 & ((EiOthO9==0 | EiOthO10==0 | EiOthO11==0 | EiOthO12==0 | EiOthO13==0 | EiOthO14==0 | ///
												EiOthO15==0 | EiOthO16==0 | EiOthO17==0 | EiOthO18==0 | EiOthO19==0 | EiOthO21==0 | EiOthO22==0 | EiOthO1==0) | ///
												(EiOthO1==1 & (inrange(EiRRel,1,7) | inlist(EiRRel,19,22))))) //house: joint, owners
replace rabnfcrrl = 0 if EioInW9==0 | EioInW10==0 | EioInW11==0 | EioInW12==0 | EioInW13==0 | EioInW14==0 | ///
												EioInW15==0 | EioInW16==0 | EioInW17==0 | EioInW18==0 | EioInW19==0 | EioInW21==0 | EioInW22==0 | ///
												EioInW1==0 | (EioInW1==1 & (inrange(EiRRel,1,7) | inlist(EiRRel,19,22))) //house: joint, other		
replace rabnfcrrl = 0 if EiSp2==1 & EiSpInH2==1 //other prop: only sp inherited
replace rabnfcrrl = 0 if EiHowH47==0 | EiHowH48==0 | EiHowH49==0 | EiHowH50==0 | EiHowH51==0 | EiHowH52==0 | ///
												EiHowH53==0 | EiHowH54==0 | EiHowH55==0 | EiHowH56==0 | EiHowH57==0 | EiHowH59==0 | EiHowH60==0 | ///
												EiHowH39==0 | (EiHowH39==1 & (inrange(EiRRel,1,7) | inlist(EiRRel,19,22))) //other prop: w sp, other
replace rabnfcrrl = 0 if EioHwH32==0 | EioHwH33==0 | EioHwH34==0 | EioHwH35==0 | EioHwH36==0 | EioHwH37==0 | ///
												EioHwH38==0 | EioHwH39==0 | EioHwH40==0 | EioHwH41==0 | EioHwH42==0 | EioHwH44==0 | EioHwH45==0 | ///
												EioHwH24==0 | (EioHwH24==1 & (inrange(EiRRel,1,7) | inlist(EiRRel,19,22))) //other prop: sole, other
replace rabnfcrrl = 0 if EioIn2==2 | (EioIn2==1 & ((EiOthO32==0 | EiOthO33==0 | EiOthO34==0 | EiOthO35==0 | EiOthO36==0 | EiOthO37==0 | ///
												EiOthO38==0 | EiOthO39==0 | EiOthO40==0 | EiOthO41==0 | EiOthO42==0 | EiOthO44==0 | EiOthO45==0 | EiOthO24==0) | ///
												(EiOthO24==1 & (inrange(EiRRel,1,7) | inlist(EiRRel,19,22))))) //other prop: joint, owners
replace rabnfcrrl = 0 if EioInW32==0 | EioInW33==0 | EioInW34==0 | EioInW35==0 | EioInW36==0 | EioInW37==0 | ///
												EioInW38==0 | EioInW39==0 | EioInW40==0 | EioInW41==0 | EioInW42==0 | EioInW44==0 | EioInW45==0 | ///
												EioInW24==0 | (EioInW24==1 & (inrange(EiRRel,1,7) | inlist(EiRRel,19,22))) //other prop: joint, other	
replace rabnfcrrl = 0 if EIPhyWh9==0 | EIPhyW10==0 | EIPhyW11==0 | EIPhyW12==0 | EIPhyW13==0 | EIPhyW14==0 | ///
												EIPhyW15==0 | EIPhyW16==0 | EIPhyW17==0 | EIPhyW18==0 | EIPhyW19==0 | EIPhyW21==0 | EIPhyW22==0 | ///
												EIPhyWh1==0 | (EIPhyWh1==1 & (inrange(EiRRel,1,7) | inlist(EiRRel,19,22))) //business
replace rabnfcrrl = 0 if EiOthA24==1 | EiOthAs9==0 | EiOthA10==0 | EiOthA11==0 | EiOthA12==0 | EiOthA13==0 | EiOthA14==0 | ///
												EiOthA15==0 | EiOthA16==0 | EiOthA17==0 | EiOthA18==0 | EiOthA19==0 | EiOthA21==0 | EiOthA22==0 | ///
												EiOthAs1==0 | (EiOthAs1==1 & (inrange(EiRRel,1,7) | inlist(EiRRel,19,22))) //other assets
replace rabnfcrrl = 1 if EiHowH9==1 | EiHowH10==1 | EiHowH11==1 | EiHowH12==1 | EiHowH13==1 | EiHowH14==1 | ///
												EiHowH15==1 | EiHowH16==1 | EiHowH17==1 | EiHowH18==1 | EiHowH19==1 | EiHowH21==1 | EiHowH22==1 | ///
												(EiHowH1==1 & (inrange(EiRRel,8,18) | inlist(EiRRel,20,21))) //house: w sp, other
replace rabnfcrrl = 1 if EioHwH9==1 | EioHwH10==1 | EioHwH11==1 | EioHwH12==1 | EioHwH13==1 | EioHwH14==1 | ///
												EioHwH15==1 | EioHwH16==1 | EioHwH17==1 | EioHwH18==1 | EioHwH19==1 | EioHwH21==1 | EioHwH22==1 | ///
												(EioHwH1==1 & (inrange(EiRRel,8,18) | inlist(EiRRel,20,21))) //house: sole, other
replace rabnfcrrl = 1 if EioIn==1 & ((EiOthO9==1 | EiOthO10==1 | EiOthO11==1 | EiOthO12==1 | EiOthO13==1 | EiOthO14==1 | ///
												EiOthO15==1 | EiOthO16==1 | EiOthO17==1 | EiOthO18==1 | EiOthO19==1 | EiOthO21==1 | EiOthO22==1) | ///
												(EiOthO1==1 & (inrange(EiRRel,8,18) | inlist(EiRRel,20,21)))) //house: joint, owners
replace rabnfcrrl = 1 if EioInW9==1 | EioInW10==1 | EioInW11==1 | EioInW12==1 | EioInW13==1 | EioInW14==1 | ///
												EioInW15==1 | EioInW16==1 | EioInW17==1 | EioInW18==1 | EioInW19==1 | EioInW21==1 | EioInW22==1 | ///
												(EioInW1==1 & (inrange(EiRRel,8,18) | inlist(EiRRel,20,21))) //house: joint, other
replace rabnfcrrl = 1 if EiHowH47==1 | EiHowH48==1 | EiHowH49==1 | EiHowH50==1 | EiHowH51==1 | EiHowH52==1 | ///
												EiHowH53==1 | EiHowH54==1 | EiHowH55==1 | EiHowH56==1 | EiHowH57==1 | EiHowH59==1 | EiHowH60==1 | ///
												(EiHowH39==1 & (inrange(EiRRel,8,18) | inlist(EiRRel,20,21))) //other prop: w sp, other
replace rabnfcrrl = 1 if EioHwH32==1 | EioHwH33==1 | EioHwH34==1 | EioHwH35==1 | EioHwH36==1 | EioHwH37==1 | ///
												EioHwH38==1 | EioHwH39==1 | EioHwH40==1 | EioHwH41==1 | EioHwH42==1 | EioHwH44==1 | EioHwH45==1 | ///
												(EioHwH24==1 & (inrange(EiRRel,8,18) | inlist(EiRRel,20,21))) //other prop: sole, other
replace rabnfcrrl = 1 if EioIn2==1 & ((EiOthO32==1 | EiOthO33==1 | EiOthO34==1 | EiOthO35==1 | EiOthO36==1 | EiOthO37==1 | ///
												EiOthO38==1 | EiOthO39==1 | EiOthO40==1 | EiOthO41==1 | EiOthO42==1 | EiOthO44==1 | EiOthO45==1) | ///
												(EiOthO24==1 & (inrange(EiRRel,8,18) | inlist(EiRRel,20,21)))) //other prop: joint, owners
replace rabnfcrrl = 1 if EioInW32==1 | EioInW33==1 | EioInW34==1 | EioInW35==1 | EioInW36==1 | EioInW37==1 | ///
												EioInW38==1 | EioInW39==1 | EioInW40==1 | EioInW41==1 | EioInW42==1 | EioInW44==1 | EioInW45==1 | ///
												(EioInW24==1 & (inrange(EiRRel,8,18) | inlist(EiRRel,20,21))) //other prop: joint, other
replace rabnfcrrl = 1 if EIPhyWh9==1 | EIPhyW10==1 | EIPhyW11==1 | EIPhyW12==1 | EIPhyW13==1 | EIPhyW14==1 | ///
												EIPhyW15==1 | EIPhyW16==1 | EIPhyW17==1 | EIPhyW18==1 | EIPhyW19==1 | EIPhyW21==1 | EIPhyW22==1 | ///
												(EIPhyWh1==1 & (inrange(EiRRel,8,18) | inlist(EiRRel,20,21))) //business
replace rabnfcrrl = 1 if EiOthAs9==1 | EiOthA10==1 | EiOthA11==1 | EiOthA12==1 | EiOthA13==1 | EiOthA14==1 | ///
												EiOthA15==1 | EiOthA16==1 | EiOthA17==1 | EiOthA18==1 | EiOthA19==1 | EiOthA21==1 | EiOthA22==1 | ///
												(EiOthAs1==1 & (inrange(EiRRel,8,18) | inlist(EiRRel,20,21))) //other assets  

***whether other person was beneficiary of estate***
*wave 6 respondent other person was beneficiary
missing_w6 EiRRel EiAsCk if inw`wv'xt==1, result(rabnfcrot)
replace rabnfcrot = .t if EiAsCk==2
replace rabnfcrot = 0 if EiSp==1 & EiSpInH==1 //house: only sp inherited
replace rabnfcrot = 0 if EiHowH23==0 | EiHowH36==0 | EiHowH37==0 | EiHowH1==0 | (EiHowH1==1 & inrange(EiRRel,1,21)) //house: w sp, other
replace rabnfcrot = 0 if EioHwH23==0 | EioHwH1==0 | (EioHwH1==1 & inrange(EiRRel,1,21)) //house: sole, other
replace rabnfcrot = 0 if EioIn==2 | (EioIn==1 & ((EiOthO23==0 | EiOthO1==0) | (EiOthO1==0 & inrange(EiRRel,1,21)))) //house: joint, owners
replace rabnfcrot = 0 if EioInW23==0 | EioInW1==0 | (EioInW1==1 & inrange(EiRRel,1,21)) //house: joint, other
replace rabnfcrot = 0 if EiSp2==1 & EiSpInH2==1 //other prop: only sp inherited
replace rabnfcrot = 0 if EiHowH61==0 | EiHowH39==0 | (EiHowH39==1 & inrange(EiRRel,1,21)) //other prop: w sp, other
replace rabnfcrot = 0 if EioHwH46==0 | EioHwH24==0 | (EioHwH24==1 & inrange(EiRRel,1,21)) //other prop: sole, other
replace rabnfcrot = 0 if EioIn2==2 | (EioIn2==1 & ((EiOthO46==0 | EiOthO24==0) | (EiOthO24==0 & inrange(EiRRel,1,21)))) //other prop: joint, owners
replace rabnfcrot = 0 if EioInW46==0 | EioInW24==0 | (EioInW24==1 & inrange(EiRRel,1,21)) //other prop: joint, other
replace rabnfcrot = 0 if EIPhyW23==0 | EIPhyWh1==0 | (EIPhyWh1==1 & inrange(EiRRel,1,21)) //business
replace rabnfcrot = 0 if EiOthA24==1 | EiOthA23==0 | EiOthAs1==0 | (EiOthAs1==1 & inrange(EiRRel,1,21)) //other assets
replace rabnfcrot = 1 if EiHowH23==1 | EiHowH36==1 | EiHowH37==1 | (EiHowH1==1 & EiRRel==22) //house: w sp, other
replace rabnfcrot = 1 if EioHwH23==1 | (EioHwH1==1 & EiRRel==22) //house: sole, other
replace rabnfcrot = 1 if EioIn==1 & (EiOthO23==1 | (EiOthO1==1 & EiRRel==22)) //house: joint, owners
replace rabnfcrot = 1 if EioInW23==1 | (EioInW1==1 & EiRRel==22) //house: joint, other
replace rabnfcrot = 1 if EiHowH61==1 | (EiHowH39==1 & EiRRel==22) //other prop: w sp, other
replace rabnfcrot = 1 if EioHwH46==1 | (EioHwH24==1 & EiRRel==22) //other prop: sole, other
replace rabnfcrot = 1 if EioIn2==1 & (EiOthO46==1 | (EiOthO24==1 & EiRRel==22)) //other prop: joint, owners
replace rabnfcrot = 1 if EioInW46==1 | (EioInW24==1 & EiRRel==22) //other prop: joint, other
replace rabnfcrot = 1 if EIPhyW23==1 | (EIPhyWh1==1 & EiRRel==22) //business
replace rabnfcrot = 1 if EiOthA23==1 | (EiOthAs1==1 & EiRRel==22) //other assets


***spouse inherited home***
*wave 6 respondent spouse inherited home
missing_w6 EiAsCk EiHome EiSp EiRRel EiHowH1 EioIn EiOthO1 EioInW1 EioHwH1 if inw`wv'xt==1, result(rahomesp)
replace rahomesp = .t if EiAsCk==2 & EiHome==-1
replace rahomesp = .x if EiHome==2
replace rahomesp = 0 if EiSp==2 //w sp, spouse 
replace rahomesp = 0 if EiHowH2==0 | EiHowH3==0 | EiHowH1==0 | (EiHowH1==1 & inrange(EiRRel,3,22)) //w sp, other
replace rahomesp = 0 if EioIn==2 | (EioIn==1 & ((EiOthO2==0 | EiOthO3==0 | EiOthO1==0) | (EiOthO1==1 & inrange(EiRRel,3,22)))) //joint, owners
replace rahomesp = 0 if EioInW2==0 | EioInW3==0 | EioInW1==0 | (EioInW1==1 & inrange(EiRRel,3,22)) //joint, other
replace rahomesp = 0 if EioHwH2==0 | EioHwH3==0 | EioHwH1==0 | (EioHwH1==1 & inrange(EiRRel,3,22)) //sole, other
replace rahomesp = 1 if EiSp==1 //w sp, spouse
replace rahomesp = 1 if EiHowH2==1 | EiHowH3==1 | (EiHowH1==1 & inlist(EiRRel,1,2)) //w sp, other
replace rahomesp = 1 if EioIn==1 & ((EiOthO2==1 | EiOthO3==1) | (EiOthO1==1 & inlist(EiRRel,1,2))) //joint, owners
replace rahomesp = 1 if EioInW2==1 | EioInW3==1 | (EioInW1==1 & inlist(EiRRel,1,2)) //joint, other
replace rahomesp = 1 if EioHwH2==1 | EioHwH3==1 | (EioHwH1==1 & inlist(EiRRel,1,2)) //sole, other

***child/grandchild inherited home***
*wave 6 respondent child/grandchild inherited home
missing_w6 EiAsCk EiHome EiRRel EiHowH1 EioIn EiOthO1 EioInW1 EioHwH1 EiSp EiSpInH if inw`wv'xt==1, result(rahomech)
replace rahomech = .t if EiAsCk==2 & EiHome==-1
replace rahomech = .x if EiHome==2
replace rahomech = 0 if EiSp==1 & EiSpInH==1 //only sp inherited
replace rahomech = 0 if EiHowH4==0 | EiHowH5==0 | EiHowH6==0 | EiHowH7==0 | EiHowH8==0 | EiHowH20==0 | ///
												EiHowH1==0 | (EiHowH1==1 & (inlist(EiRRel,1,2,20,21,22) | inrange(EiRRel,8,18))) //w sp, toher
replace rahomech = 0 if EioIn==2 | (EioIn==1 & ((EiOthO4==0 | EiOthO5==0 | EiOthO6==0 | EiOthO7==0 | EiOthO8==0 | EiOthO20==0 | EiOthO1==0) | ///
												(EiOthO1==1 & (inlist(EiRRel,1,2,20,21,22) | inrange(EiRRel,8,18))))) //joint, owners
replace rahomech = 0 if EioInW4==0 | EioInW5==0 | EioInW6==0 | EioInW7==0 | EioInW8==0 | EioInW20==0 | ///
												EioInW1==0 | (EioInW1==1 & (inlist(EiRRel,1,2,20,21,22) | inrange(EiRRel,8,18))) //joint, other
replace rahomech = 0 if EioHwH4==0 | EioHwH5==0 | EioHwH6==0 | EioHwH7==0 | EioHwH8==0 | EioHwH20==0 | ///
												EioHwH1==0 | (EioHwH1==1 & (inlist(EiRRel,1,2,20,21,22) | inrange(EiRRel,8,18))) //sole, other
replace rahomech = 1 if EiHowH4==1 | EiHowH5==1 | EiHowH6==1 | EiHowH7==1 | EiHowH8==1 | EiHowH20==1 | ///
												EiHowH1==0 | (EiHowH1==1 & inlist(EiRRel,3,4,5,6,7,19)) //w sp, other
replace rahomech = 1 if EioIn==1 & ((EiOthO4==1 | EiOthO5==1 | EiOthO6==1 | EiOthO7==1 | EiOthO8==1 | EiOthO20==1) | ///
												(EiOthO1==1 & inlist(EiRRel,3,4,5,6,7,19))) //joint, owners
replace rahomech = 1 if EioInW4==1 | EioInW5==1 | EioInW6==1 | EioInW7==1 | EioInW8==1 | EioInW20==1 | ///
												EioInW1==0 | (EioInW1==1 & inlist(EiRRel,3,4,5,6,7,19)) //joint, other 
replace rahomech = 1 if EioHwH4==1 | EioHwH5==1 | EioHwH6==1 | EioHwH7==1 | EioHwH8==1 | EioHwH20==1 | ///
												EioHwH1==0 | (EioHwH1==1 & inlist(EiRRel,3,4,5,6,7,19)) //sole, other

***relative inherited home***
*wave 6 respondent relative inherited home
missing_w6 EiAsCk EiHome EiRRel EiHowH1 EioIn EiOthO1 EioInW1 EioHwH1 EiSp EiSpInH if inw`wv'xt==1, result(rahomerl)
replace rahomerl = .t if EiAsCk==2 & EiHome==-1
replace rahomerl = .x if EiHome==2
replace rahomerl = 0 if EiSp==1 & EiSpInH==1 //only sp inherited
replace rahomerl = 0 if EiHowH9==0 | EiHowH10==0 | EiHowH11==0 | EiHowH12==0 | EiHowH13==0 | EiHowH14==0 | ///
												EiHowH15==0 | EiHowH16==0 | EiHowH17==0 | EiHowH18==0 | EiHowH19==0 | EiHowH21==0 | EiHowH22==0 | ///
												EiHowH1==0 | (EiHowH1==1 & (inrange(EiRRel,1,7) | inlist(EiRRel,19,22))) //w sp, other
replace rahomerl = 0 if EioIn==2 | (EioIn==1 & ((EiOthO9==0 | EiOthO10==0 | EiOthO11==0 | EiOthO12==0 | EiOthO13==0 | EiOthO14==0 | ///
												EiOthO15==0 | EiOthO16==0 | EiOthO17==0 | EiOthO18==0 | EiOthO19==0 | EiOthO21==0 | EiOthO22==0 | EiOthO1==0) | ///
												(EiOthO1==1 & (inrange(EiRRel,1,7) | inlist(EiRRel,19,22))))) //joint, owners
replace rahomerl = 0 if EioInW9==0 | EioInW10==0 | EioInW11==0 | EioInW12==0 | EioInW13==0 | EioInW14==0 | ///
												EioInW15==0 | EioInW16==0 | EioInW17==0 | EioInW18==0 | EioInW19==0 | EioInW21==0 | EioInW22==0 | ///
												EioInW1==0 | (EioInW1==1 & (inrange(EiRRel,1,7) | inlist(EiRRel,19,22))) //joint, other 
replace rahomerl = 0 if EioHwH9==0 | EioHwH10==0 | EioHwH11==0 | EioHwH12==0 | EioHwH13==0 | EioHwH14==0 | ///
												EioHwH15==0 | EioHwH16==0 | EioHwH17==0 | EioHwH18==0 | EioHwH19==0 | EioHwH21==0 | EioHwH22==0 | ///
												EioHwH1==0 | (EioHwH1==1 & (inrange(EiRRel,1,7) | inlist(EiRRel,19,22))) //sole, other
replace rahomerl = 1 if EiHowH9==1 | EiHowH10==1 | EiHowH11==1 | EiHowH12==1 | EiHowH13==1 | EiHowH14==1 | ///
												EiHowH15==1 | EiHowH16==1 | EiHowH17==1 | EiHowH18==1 | EiHowH19==1 | EiHowH21==1 | EiHowH22==1 | ///
												(EiHowH1==1 & (inrange(EiRRel,8,18) | inlist(EiRRel,20,21))) //w sp, other
replace rahomerl = 1 if EioIn==1 & ((EiOthO9==1 | EiOthO10==1 | EiOthO11==1 | EiOthO12==1 | EiOthO13==1 | EiOthO14==1 | ///
												EiOthO15==1 | EiOthO16==1 | EiOthO17==1 | EiOthO18==1 | EiOthO19==1 | EiOthO21==1 | EiOthO22==1) | ///
												(EiOthO1==1 & (inrange(EiRRel,8,18) | inlist(EiRRel,20,21)))) //joint, owners
replace rahomerl = 1 if EioInW9==1 | EioInW10==1 | EioInW11==1 | EioInW12==1 | EioInW13==1 | EioInW14==1 | ///
												EioInW15==1 | EioInW16==1 | EioInW17==1 | EioInW18==1 | EioInW19==1 | EioInW21==1 | EioInW22==1 | ///
												(EioInW1==1 & (inrange(EiRRel,8,18) | inlist(EiRRel,20,21))) //joint, other
replace rahomerl = 1 if EioHwH9==1 | EioHwH10==1 | EioHwH11==1 | EioHwH12==1 | EioHwH13==1 | EioHwH14==1 | ///
												EioHwH15==1 | EioHwH16==1 | EioHwH17==1 | EioHwH18==1 | EioHwH19==1 | EioHwH21==1 | EioHwH22==1 | ///
												(EioHwH1==1 & (inrange(EiRRel,8,18) | inlist(EiRRel,20,21))) //sole, other

***other inherited home***
*wave 6 respondent other inherited home
missing_w6 EiAsCk EiHome EiRRel EiHowH1 EioIn EiOthO1 EioInW1 EioHwH1 EiSp EiSpInH if inw`wv'xt==1, result(rahomeot)
replace rahomeot = .t if EiAsCk==2 & EiHome==-1
replace rahomeot = .x if EiHome==2
replace rahomeot = 0 if EiSp==1 & EiSpInH==1 //only sp inherited
replace rahomeot = 0 if EiHowH23==0 | EiHowH36==0 | EiHowH37==0 | EiHowH1==0 | (EiHowH1==1 & inrange(EiRRel,1,21)) //w sp, other
replace rahomeot = 0 if EioIn==2 | (EioIn==1 & ((EiOthO23==0 | EiOthO1==0) | (EiOthO1==0 & inrange(EiRRel,1,21)))) //joint, owners
replace rahomeot = 0 if EioInW23==0 | EioInW1==0 | (EioInW1==1 & inrange(EiRRel,1,21)) //joint, other
replace rahomeot = 0 if EioHwH23==0 | EioHwH1==0 | (EioHwH1==1 & inrange(EiRRel,1,21)) //sole, other
replace rahomeot = 1 if EiHowH23==1 | EiHowH36==1 | EiHowH37==1 | (EiHowH1==1 & EiRRel==22) //w sp, other 
replace rahomeot = 1 if EioIn==1 & (EiOthO23==1 | (EiOthO1==1 & EiRRel==22)) //joint, owners
replace rahomeot = 1 if EioInW23==1 | (EioInW1==1 & EiRRel==22) //joint, other
replace rahomeot = 1 if EioHwH23==1 | (EioHwH1==1 & EiRRel==22) //sole, other



***whether spouse was beneficiary of pension***
*wave 6 respondent spouse was beneficiary
missing_w6 EiRRel EiPenWho EiPenWh2 EiPenWh3 EiPenWh4 if inw`wv'xt==1, result(rapensp)
replace rapensp = .d if EiPenM==3 | EiPen96==1 | EiPen98==1 | EiPen100==1 | EiPen103==1
replace rapensp = .n if EiPenM==2 | EiPen5==1 | EiPen10==1 | EiPen15==1 | EiPen20==1
replace rapensp = .o if EiPen95==1 | EiPen97==1 | EiPen99==1 | EiPen102==1
replace rapensp = 0 if EiPenWho==1 | EiPenWh2==1 | EiPenWh3==1 | EiPenWh4==1 | ///
												inrange(EiPenWho,4,23) | inrange(EiPenWh2,4,23) | inrange(EiPenWh3,4,23) | inrange(EiPenWh4,4,23) 
replace rapensp = 1 if inlist(EiPenWho,2,3) | inlist(EiPenWh2,2,3) | inlist(EiPenWh3,2,3) | inlist(EiPenWh4,2,3) | ///
												((EiPenWho==1 | EiPenWh2==1 | EiPenWh3==1 | EiPenWh4==1) & inlist(EiRRel,1,2)) 

***whether child/grandchild was beneficary of pension***
*wave 6 respondent child/grandchild was beneficiary
missing_w6 EiRRel EiPenWho EiPenWh2 EiPenWh3 EiPenWh4 if inw`wv'xt==1, result(rapencg)
replace rapencg = .d if EiPenM==3 | EiPen96==1 | EiPen98==1 | EiPen100==1 | EiPen103==1
replace rapencg = .n if EiPenM==2 | EiPen5==1 | EiPen10==1 | EiPen15==1 | EiPen20==1
replace rapencg = .o if EiPen95==1 | EiPen97==1 | EiPen99==1 | EiPen102==1
replace rapencg = 0 if inlist(EiPenWho,1,2,3,21,22,23) | inlist(EiPenWh2,1,2,3,21,22,23) | inlist(EiPenWh3,1,2,3,21,22,23) | inlist(EiPenWh4,1,2,3,21,22,23) | ///
												inrange(EiPenWho,9,19) | inrange(EiPenWh2,9,19) | inrange(EiPenWh3,9,19) | inrange(EiPenWh4,9,19) 
replace rapencg = 1 if inlist(EiPenWho,4,5,6,7,8,20) | inlist(EiPenWh2,4,5,6,7,8,20) | inlist(EiPenWh3,4,5,6,7,8,20) | inlist(EiPenWh4,4,5,6,7,8,20) | ///
												((EiPenWho==1 | EiPenWh2==1 | EiPenWh3==1 | EiPenWh4==1) & inlist(EiRRel,3,4,5,6,7,19)) 
												
***whether relative was beneficiary of pension***
*wave 6 respondent relative was beneficiary
missing_w6 EiRRel EiPenWho EiPenWh2 EiPenWh3 EiPenWh4 if inw`wv'xt==1, result(rapenrl)
replace rapenrl = .d if EiPenM==3 | EiPen96==1 | EiPen98==1 | EiPen100==1 | EiPen103==1
replace rapenrl = .n if EiPenM==2 | EiPen5==1 | EiPen10==1 | EiPen15==1 | EiPen20==1
replace rapenrl = .o if EiPen95==1 | EiPen97==1 | EiPen99==1 | EiPen102==1
replace rapenrl = 0 if inrange(EiPenWho,1,8) | inrange(EiPenWh2,1,8) | inrange(EiPenWh3,1,8) | inrange(EiPenWh4,1,8) | ///
												inlist(EiPenWho,20,23) | inlist(EiPenWh2,20,23) | inlist(EiPenWh3,20,23) | inlist(EiPenWh4,20,23) 
replace rapenrl = 1 if inrange(EiPenWho,9,19) | inrange(EiPenWh2,9,19) | inrange(EiPenWh3,9,19) | inrange(EiPenWh4,9,19) | ///
												inlist(EiPenWho,21,22) | inlist(EiPenWh2,21,22) | inlist(EiPenWh3,21,22) | inlist(EiPenWh4,21,22) | ///
												((EiPenWho==1 | EiPenWh2==1 | EiPenWh3==1 | EiPenWh4==1) & (inrange(EiRRel,8,18) | inlist(EiRRel,20,21))) 

***whether other person was beneficiary of pension***
*wave 6 respondent other person was beneficiary
missing_w6 EiRRel EiPenWho EiPenWh2 EiPenWh3 EiPenWh4 if inw`wv'xt==1, result(rapenot)
replace rapenot = .d if EiPenM==3 | EiPen96==1 | EiPen98==1 | EiPen100==1 | EiPen103==1
replace rapenot = .n if EiPenM==2 | EiPen5==1 | EiPen10==1 | EiPen15==1 | EiPen20==1
replace rapenot = .o if EiPen95==1 | EiPen97==1 | EiPen99==1 | EiPen102==1
replace rapenot = 0 if inrange(EiPenWho,1,22) | inrange(EiPenWh2,1,22) | inrange(EiPenWh3,1,22) | inrange(EiPenWh4,1,22) //pension
replace rapenot = 1 if EiPenWho==23 | EiPenWh2==23 | EiPenWh3==23 | EiPenWh4==23 | ///
												((EiPenWho==1 | EiPenWh2==1 | EiPenWh3==1 | EiPenWh4==1) & EiRRel==22) 



***death expenses***
gen oopdeath = .
replace oopdeath = 2000 if DVEidcsta==1
replace oopdeath = 3100 if DVEidcsta==2
replace oopdeath = 4000 if DVEidcsta==3
replace oopdeath = 21300 if DVEidcsta==4
gen insurance = .
replace insurance = 725 if DVEifuins==1
replace insurance = 1700 if DVEifuins==2
replace insurance = 3100 if DVEifuins==3
replace insurance = 12000 if DVEifuins==4

*paid on own
replace selfo = 0 if EiDcstb==2
replace selfo = 1 if inlist(EiDcstb,1,3)

replace self = oopdeath if inrange(oopdeath,0,30000)

*paid by ins
replace inso = 0 if EiDcstb==3
replace inso = 1 if inlist(EiDcstb,1,2)

replace ins = insurance if inrange(insurance,0,20000)


***any costs covered by insurance (excl. life)***
*wave 6 respondent any costs covered by insurance
missing_w4 EiDcstb radexpense if inw`wv'xt==1, result(rainscovr)
replace rainscovr = 0 if EiDcstb==3
replace rainscovr = 1 if inlist(EiDcstb,1,2)


***amount insurance paid out***
*wave 6 respondent amount insurance paid out
drop oopdeath insurance


***has living will***
*wave 6 respondent has living will
missing_w6 EIHIT if inw`wv'xt==1, result(ralvwill)
replace ralvwill = .d if EIHIT==8
replace ralvwill = 0 if EIHIT==2
replace ralvwill = 1 if EIHIT==1


***desire to limit care in certain situations***
*wave 6 respondent desire to limit care in certain situations
missing_w6 EIHIL ralvwill if inw`wv'xt==1, result(ralmtcare)
replace ralmtcare = .n if ralvwill==0 & inw`wv'xt==1
replace ralmtcare = .d if EIHIL==8
replace ralmtcare = 0 if EIHIL==2
replace ralmtcare = 1 if EIHIL==1


***whether had a durable power of attorney for healthcare***
*wave 6 respondent whether had a durable power of attorney for healthcare
missing_w6 EIHLA if inw`wv'xt==1, result(radpoafh)
replace radpoafh = .d if EIHLA==8
replace radpoafh = 0 if EIHLA==2
replace radpoafh = 1 if EIHLA==1


***Whether spouse was dpoafh***
*wave 6 respondent spouse was dpoafh
missing_w6 EIHLA EIHLN1 if inw`wv'xt==1, result(radpoasp)
replace radpoasp = .d if EIHLN98==1 | EIHLA==8
replace radpoasp = .r if EIHLN99==1
replace radpoasp = .n if radpoafh==0 & inw`wv'xt==1
replace radpoasp = 0 if EIHLN1==0
replace radpoasp = 1 if EIHLN1==1


***Whether child was dpoafh***
*wave 6 respondent child was dpoafh
missing_w6 EIHLA EIHLN2 if inw`wv'xt==1, result(radpoach)
replace radpoach = .d if EIHLN98==1 | EIHLA==8
replace radpoach = .r if EIHLN99==1
replace radpoach = .n if radpoafh==0 & inw`wv'xt==1
replace radpoach = 0 if EIHLN2==0
replace radpoach = 1 if EIHLN2==1


***Whether relative was dpoafh***
*wave 6 respondent relative was dpoafh
missing_w6 EIHLA EIHLN3 if inw`wv'xt==1, result(radpoarl)
replace radpoarl = .d if EIHLN98==1 | EIHLA==8
replace radpoarl = .r if EIHLN99==1
replace radpoarl = .n if radpoafh==0 & inw`wv'xt==1
replace radpoarl = 0 if EIHLN3==0
replace radpoarl = 1 if EIHLN3==1


***Whether friend was dpoafh***
*wave 6 respondent friend was dpoafh
missing_w6 EIHLA EIHLN5 if inw`wv'xt==1, result(radpoafr)
replace radpoafr = .d if EIHLN98==1 | EIHLA==8
replace radpoafr = .r if EIHLN99==1
replace radpoafr = .n if radpoafh==0 & inw`wv'xt==1
replace radpoafr = 0 if EIHLN5==0
replace radpoafr = 1 if EIHLN5==1


***Whether non-relative was dpoafh***
*wave 6 respondent non-relative was dpoafh
missing_w6 EIHLA EIHLN4 if inw`wv'xt==1, result(radpoanr)
replace radpoanr = .d if EIHLN98==1 | EIHLA==8
replace radpoanr = .r if EIHLN99==1
replace radpoanr = .n if radpoafh==0 & inw`wv'xt==1
replace radpoanr = 0 if EIHLN4==0
replace radpoanr = 1 if EIHLN4==1


***Whether doctor was dpoafh***
*wave 6 respondent doctor was dpoafh
missing_w6 EIHLA EIHLN6 if inw`wv'xt==1, result(radpoadr)
replace radpoadr = .d if EIHLN98==1 | EIHLA==8
replace radpoadr = .r if EIHLN99==1
replace radpoadr = .n if radpoafh==0 & inw`wv'xt==1
replace radpoadr = 0 if EIHLN6==0
replace radpoadr = 1 if EIHLN6==1


***Whether religious advisor was dpoafh***
*wave 6 respondent religious advisor was dpoafh
missing_w6 EIHLA EIHLN7 if inw`wv'xt==1, result(radpoara)
replace radpoara = .d if EIHLN98==1 | EIHLA==8
replace radpoara = .r if EIHLN99==1
replace radpoara = .n if radpoafh==0 & inw`wv'xt==1
replace radpoara = 0 if EIHLN7==0
replace radpoara = 1 if EIHLN7==1


***Whether legal professional was dpoafh***
*wave 6 respondent legal professional was dpoafh
missing_w6 EIHLA EIHLN8 if inw`wv'xt==1, result(radpoalp)
replace radpoalp = .d if EIHLN98==1 | EIHLA==8
replace radpoalp = .r if EIHLN99==1
replace radpoalp = .n if radpoafh==0 & inw`wv'xt==1
replace radpoalp = 0 if EIHLN8==0
replace radpoalp = 1 if EIHLN8==1


***Whether social worker was dpoafh***
*wave 6 respondent social worker was dpoafh
missing_w6 EIHLA EIHLN9 if inw`wv'xt==1, result(radpoasw)
replace radpoasw = .d if EIHLN98==1 | EIHLA==8
replace radpoasw = .r if EIHLN99==1
replace radpoasw = .n if radpoafh==0 & inw`wv'xt==1
replace radpoasw = 0 if EIHLN9==0
replace radpoasw = 1 if EIHLN9==1


***Whether other was dpoafh***
*wave 6 respondent other was dpoafh
missing_w6 EIHLA EIHLN10 if inw`wv'xt==1, result(radpoaot)
replace radpoaot = .d if EIHLN98==1 | EIHLA==8
replace radpoaot = .r if EIHLN99==1
replace radpoaot = .n if radpoafh==0 & inw`wv'xt==1
replace radpoaot = 0 if EIHLN10==0
replace radpoaot = 1 if EIHLN10==1

***whether non-family member was dpoafh***
*wave 6 respondent non-family member was dpoafh
missing_w6 EIHLA EIHLN4 EIHLN5 EIHLN6 EIHLN7 EIHLN8 EIHLN9 EIHLN10 if inw`wv'xt==1, result(radpoanf)
replace radpoanf = .d if EIHLN98==1 | EIHLA==8
replace radpoanf = .r if EIHLN99==1
replace radpoanf = .n if radpoafh==0 & inw`wv'xt==1
replace radpoanf = 0 if EIHLN4==0 | EIHLN5==0 | EIHLN6==0 | EIHLN7==0 | EIHLN8==0 | EIHLN9==0 | EIHLN10==0
replace radpoanf = 1 if EIHLN4==1 | EIHLN5==1 | EIHLN6==1 | EIHLN7==1 | EIHLN8==1 | EIHLN9==1 | EIHLN10==1


***any life insurance policies***
*wave 6 respondent any life insurance policies
missing_w6 EiAsCk EiLI if inw`wv'xt==1, result(raxlifeins)
replace raxlifeins = .t if EiAsCk==2 & EiLI==-1
replace raxlifeins = 0 if EiLI==2
replace raxlifeins = 1 if EiLI==1


***whether spouse is beneficiary of life insurance policies***
*wave 6 respondent spouse is beneficiary of life insurance policies
missing_w6 EiAsCk EiLI EiRRel EiLIWh1 EiLIWh2 EiLIWh3 if inw`wv'xt==1, result(ralfinssp)
replace ralfinssp = .t if EiAsCk==2 & EiLI==-1
replace ralfinssp = .n if raxlifeins==0 & inw`wv'xt==1
replace ralfinssp = 0 if EiLIWh1==0 | (EiLIWh1==1 & !inlist(EiRRel,1,2)) | EiLIWh2==0 | EiLIWh3==0
replace ralfinssp = 1 if (EiLIWh1==1 & inlist(EiRRel,1,2)) | EiLIWh2==1 | EiLIWh3==1


***whether child is beneficiary of life insurance policies***
*wave 6 respondent child is beneficiary of life insurance policies
missing_w6 EiAsCk EiLI EiRRel EiLIWh1 EiLIWh4 EiLIWh5 EiLIWh6 EiLIWh7 EiLIWh8 if inw`wv'xt==1, result(ralfinsch)
replace ralfinsch = .t if EiAsCk==2 & EiLI==-1
replace ralfinsch = .n if raxlifeins==0 & inw`wv'xt==1
replace ralfinsch = 0 if EiLIWh1==0 | (EiLIWh1==1 & !inrange(EiRRel,3,7)) | ///
													EiLIWh4==0 | EiLIWh5==0 | EiLIWh6==0 | EiLIWh7==0 | EiLIWh8==0
replace ralfinsch = 1 if (EiLIWh1==1 & inlist(EiRRel,1,2)) | ///
													EiLIWh4==1 | EiLIWh5==1 | EiLIWh6==1 | EiLIWh7==1 | EiLIWh8==1


***whether grandchild is beneficiary of life insurance policies***
*wave 6 respondent grandchild is beneficiary of life insurance policies
missing_w6 EiAsCk EiLI EiRRel EiLIWh1 EiLIWh20 if inw`wv'xt==1, result(ralfinsgk)
replace ralfinsgk = .t if EiAsCk==2 & EiLI==-1
replace ralfinsgk = .n if raxlifeins==0 & inw`wv'xt==1
replace ralfinsgk = 0 if EiLIWh1==0 | (EiLIWh1==1 & EiRRel!=19) | EiLIWh20==0 
replace ralfinsgk = 1 if (EiLIWh1==1 & EiRRel==19) | EiLIWh20==1 


***whether relative is beneficiary of life insurance policies***
*wave 6 respondent relative is beneficiary of life insurance policies
missing_w6 EiAsCk EiLI EiRRel EiLIWh1 EiLIWh9 EiLIWh10 EiLIWh11 EiLIWh12 EiLIWh13 ///
			EiLIWh14 EiLIWh15 EiLIWh16 EiLIWh17 EiLIWh18 EiLIWh19 EiLIWh21 EiLIWh22 if inw`wv'xt==1, result(ralfinsrl)
replace ralfinsrl = .t if EiAsCk==2 & EiLI==-1
replace ralfinsrl = .n if raxlifeins==0 & inw`wv'xt==1
replace ralfinsrl = 0 if EiLIWh1==0 | (EiLIWh1==1 & (!inrange(EiRRel,8,18) | EiRRel!=21)) | ///
													EiLIWh9==0 | EiLIWh10==0 | EiLIWh11==0 | EiLIWh12==0 | EiLIWh13==0 | ///
													EiLIWh14==0 | EiLIWh15==0 | EiLIWh16==0 | EiLIWh17==0 | EiLIWh18==0 | ///
													EiLIWh19==0 | EiLIWh21==0 | EiLIWh22==0
replace ralfinsrl = 1 if (EiLIWh1==1 & (inrange(EiRRel,8,18) | EiRRel==21)) | ///
													EiLIWh9==1 | EiLIWh10==1 | EiLIWh11==1 | EiLIWh12==1 | EiLIWh13==1 | ///
													EiLIWh14==1 | EiLIWh15==1 | EiLIWh16==1 | EiLIWh17==1 | EiLIWh18==1 | ///
													EiLIWh19==1 | EiLIWh21==1 | EiLIWh22==1


***whether other non-relative is beneficiary of life insurance policies***
*wave 6 respondent other non-relative is beneficiary of life insurance policies
missing_w6 EiAsCk EiLI EiRRel EiLIWh1 EiLIWh23 if inw`wv'xt==1, result(ralfinsot)
replace ralfinsot = .t if EiAsCk==2 & EiLI==-1
replace ralfinsot = .n if raxlifeins==0 & inw`wv'xt==1
replace ralfinsot = 0 if EiLIWh1==0 | (EiLIWh1==1 & EiRRel!=22) | EiLIWh23==0 
replace ralfinsot = 1 if (EiLIWh1==1 & EiRRel==22) | EiLIWh23==1 


***value of life insurance policies***
*wave 6 respondent value of life insurance policies
*values are supplied in ranges - midpoint of range is assigned
gen value = .
replace value = 0 if raxlifeins==0 & inw`wv'xt==1
replace value = 900 if DVEiLIa==1 //1-1800
replace value = 2900 if DVEiLIa==2 //1800.01-4000
replace value = 12000 if DVEiLIa==3 //4000.01-20000
replace value = 110000 if DVEiLIa==4 //20000.01-200000

replace lifeo = 0 if inlist(raxlifeins,0,.t) & inw`wv'xt==1
replace lifeo = 1 if raxlifeins==1 & inw`wv'xt==1

replace life = value if inrange(value,0,200000)

drop value 



***drop H_ELSA wave 6 core file raw variables***
drop `eolxt_w6_exit'



******************************************************************************************





***death expenses***
*adjust for cpi*
forvalues y = 2002/2012 {
	replace selfmin = ((selfmin*100)/c`y'cpindex) if raxyear==`y' & inrange(selfmin,0,100000)
	replace selfmax = ((selfmax*100)/c`y'cpindex) if raxyear==`y' & inrange(selfmax,0,100000)
	replace self = ((self*100)/c`y'cpindex) if raxyear==`y' & inrange(self,0,100000)
	replace insmin = ((insmin*100)/c`y'cpindex) if raxyear==`y' & inrange(insmin,0,100000)
	replace insmax = ((insmax*100)/c`y'cpindex) if raxyear==`y' & inrange(insmax,0,100000)
	replace ins = ((ins*100)/c`y'cpindex) if raxyear==`y' & inrange(ins,0,100000)
}
*impute missing values*
elsa_eol_impute self, min_var(selfmin) max_var(selfmax) entry_var(selfo)
elsa_eol_impute ins, min_var(insmin) max_var(insmax) entry_var(inso)
*assign to variables*
replace radexpense = self_i + ins_i if !mi(self_i) & !mi(ins_i) & inxt==1
combine_imp_flag self_i_f ins_i_f, result(radexpensef)


***amount insurance paid out***
*assign to variables*
replace rainspaid = ins_i if !mi(ins_i) & inxt==1
replace rainspaid = .x if rainscovr==0 & inxt==1
replace rainspaidf = ins_i_f if !mi(ins_i_f) & inxt==1
replace rainspaidf = .x if rainscovr==0 & inxt==1

drop selfmin selfmax insmin insmax 
drop selfo self self_i self_i_f self_i_neighbor
drop inso ins ins_i ins_i_f ins_i_neighbor


***value life insurance policies***
*adjust for cpi*
forvalues y = 2002/2012 {
	replace lifemin = ((lifemin*100)/c`y'cpindex) if raxyear==`y' & inrange(lifemin,0,200000)
	replace lifemax = ((lifemax*100)/c`y'cpindex) if raxyear==`y' & inrange(lifemax,0,200000)
	replace life = ((life*100)/c`y'cpindex) if raxyear==`y' & inrange(life,0,200000)
}
*impute missing values*
elsa_eol_impute life if inxt == 1, min_var(lifemin) max_var(lifemax) entry_var(lifeo)
*assign to variables*
replace ralfinsv = life_i if !mi(life_i) & inxt==1 
replace ralfinsv = .t if notdist==1
replace ralfinsv = .q if inw2xt==1
replace ralfinsvf = life_i_f if !mi(life_i_f) & inxt==1
replace ralfinsvf = -3 if notdist==1
replace ralfinsvf = .q if inw2xt==1

drop lifemin lifemax
drop lifeo life life_i life_i_f life_i_neighbor

drop notdist




******************************************************************************************


********************************************************************************************************************
********************************************************************************************************************

***drop respondent not in the H_ELSA
drop if in_helsa !=1
drop in_helsa

***drop respondents not in eol data
drop if inw2xt!=1 & inw3xt!=1 & inw4xt!=1 & inw6xt!=1

***drop imputation variables
drop radagecat_i ragender inw1 inw2 inw3 inw4 inw5 inw6 inw7 inw8 inw9 c2013cpindex c2014cpindex c2015cpindex c2016cpindex c2017cpindex

***Update all value labels***
foreach v of var * {
	local vlabel : value label `v'
	if "`vlabel'" != "" {
		label define `vlabel' ///
			.r ".r:Refuse" ///
			.m ".m:Missing" ///
			.d ".d:DK", modify
	}
}

***final sort
sort idauniq

***define variable order
order idauniq ///
			idauniqc ///
			pn ///
			pnc ///
			inxt ///
			raxt ///
			inw2xt ///
			inw3xt ///
			inw4xt ///
			inw6xt ///
			raxtiwm ///
			raxtiwy ///
			ralstcore ///
			ralstcorey ///
			raxprxy ///
			raxseason ///
			raxyear ///
			radage ///
			radagef ///
			radtoivwm ///
			radtoivwy ///
			radtoivwf ///
			radloc_e ///
			radloc ///
			radexpec ///
			racod_e ///
			ragcod ///
			raddur ///
			radmarrp ///
			radlivnh ///
			ramvhlp ///
			ralvhlpd ///
			///
			ralcancre ///
			raxcancr ///
			raxcancre ///
			rallunge ///
			raxlung ///
			raxlunge ///
			ralhearte ///
			raxheart ///
			raxhearte ///
			ralhrtatte ///
			raxhrtatt ///
			raxhrtatte ///
			ralstroke ///
			raxstrok ///
			raxstroke ///
			raldiabe ///
			raxdiab ///
			raxdiabe ///
			ralhibpe ///
			ralmemrye ///
			raxmemry ///
			raxmemrye ///
			///
			raxhosp ///
			raxhsptim ///
			raxhspnitd ///
			raxnrshom ///
			raxnrstim ///
			raxnrsnitd_e ///
			raxhospice ///
			raxhpctim ///
			raxhpcnitd ///
			raxhhnh ///
			raxhhntim ///
			raxhhntimm ///
			raxoophelp ///
			raxoopwho ///
			raxoopsave ///
			raxooploan ///
			raxoopnyet ///
			raxoopothr ///
			///
			radfamf ///
			radevnt ///
			radconv ///
			radaddr ///
			raddymon ///
			radkept ///
			radstry ///
			raddcsn ///
			radfinl ///
			radsurr ///
			radhome ///
			rafqust ///
			radrwrd ///
			raerpwd ///
			raemudl ///
			ramprobgs ///
			raflxatt ///
			///
			c????cpindex ///
			raxahown ///
			raxhomedis_e ///
			raxahous ///
			raxafhous ///
			raxamort ///
			raxafmort ///
			raxatoth ///
			raxaftoth ///
			raxabsns ///
			raxafbsns ///
			raxarles ///
			raxafrles ///
			raxatotf_e ///
			raxaftotf_e ///
			raxatotb ///
			raxaftotb ///
			raxatotn ///
			raxaftotn ///
			raxapenls ///
			raxafpenls ///
			raxapenpy ///
			raxafpenpy ///
			///
			raxchild_e ///
			///
			raxwork ///
			raxjlastm_e ///
			raxjlasty ///
			///
			raxdresshlp ///
			raxwalkhlp ///
			raxbathehlp ///
			raxeathlp ///
			raxbedhlp ///
			raxtoilethlp ///
			raxracany ///
			raxdressage ///
			raxwalkage ///
			raxbatheage ///
			raxeatage ///
			raxbedage ///
			raxtoiletage ///
			raxdressb1y ///
			raxwalkb1y ///
			raxbatheb1y ///
			raxeatb1y ///
			raxbedb1y ///
			raxtoiletb1y ///
			raxracareb ///
			raxmealhlp ///
			raxshophlp ///
			raxphonehlp ///
			raxmedhlp ///
			raxricany ///
			raxmealage ///
			raxshopage ///
			raxphoneage ///
			raxmedage ///
			raxmealb1y ///
			raxshopb1y ///
			raxphoneb1y ///
			raxmedb1y ///
			raxricareb ///
			raxrcareb ///
			raxrcany ///
			raxrcaany ///
			raxrscare ///
			raxrccare ///
			raxrrcare ///
			raxrfcare ///
			raxrfaany ///
			raxrpfcare ///
			raxrufcare ///
			///
			rawitwill ///
			raprobate ///
			rawillp ///
			rabnfcrsp ///
			rabnfcrcg ///
			rabnfcrrl ///
			rabnfcrot ///
			rahomesp ///
			rahomech ///
			rahomerl ///
			rahomeot ///
			rapensp ///
			rapencg ///
			rapenrl ///
			rapenot ///
			radexpense ///
			radexpensef ///
			rainscovr ///
			rainspaid ///
			rainspaidf ///
			ralvwill ///
			ralmtcare ///
			radpoafh ///
			radpoasp ///
			radpoach ///
			radpoarl ///
			radpoafr ///
			radpoanr ///
			radpoadr ///
			radpoara ///
			radpoalp ///
			radpoasw ///
			radpoaot ///
			radpoanf ///
			raxlifeins ///
			ralfinsv ///
			ralfinsvf ///
			ralfinssp ///
			ralfinsch ///
			ralfinsgk ///
			ralfinsrl ///
			ralfinsot 
	
***compress dataset
compress

***add notes
notes drop _dta
note: Harmonized ELSA EOL Ver.A2
note: created July 2021 as part of the Gateway to Globabl Aging Data (www.g2aging.org)
note: see Harmonized ELSA EOL codebook for more information

***remove unused value lables
labelbook, problems
label drop `r(notused)'

***save output dataset
save "`output'/H_ELSA_EOL_a2", replace
