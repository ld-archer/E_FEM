cap program drop save_eststore_txt
program define save_eststore_txt
	syntax [newvarname]  [using/] , model_name(string) model_type(string) predicted_var(string)
	if "`using'" != "" {
		local using = "using `using'"
	}
		
	* Handle regression models
	if "`model_type'" == "regress" {
		if inlist("`model_name'", "logbmi", "ln_iearn", "helphoursyr", "helphoursyr_nonsp", "helphoursyr_sp", "hicap", "igxfr", "logproptax", "proptax")  {
			qui estout `newvarname' `using', prehead("`model_type'" "`predicted_var'") collabels(,none) mlabels(,none) eqlabels(,none) prefoot("| Root Mean Square Error") stats(rmse, label("_rmse")) replace	
		} 
		else if "`model_type'" == "regress" & inlist("`model_name'", "tcamt_cpl","ihs_tcamt_cpl", "lniearn_ft", "lniearn_pt", "lniearn_ue", "lniearn_nl")  {
			qui estout `newvarname' `using', prehead("`model_type'" "`predicted_var'") collabels(,none) mlabels(,none) eqlabels(,none) prefoot("| Root Mean Square Error") stats(rmse, label("_rmse")) replace	
		} 
		* HRS biomarkers
		else if "`model_type'" == "regress" & inlist("`model_name'", "a1c_adj", "hdl_adj", "tc_adj", "logcysc_adj", "logcrp_adj")  {
			qui estout `newvarname' `using', prehead("`model_type'" "`predicted_var'") collabels(,none) mlabels(,none) eqlabels(,none) prefoot("| Root Mean Square Error") stats(rmse, label("_rmse")) replace	
		} 
		else if "`model_type'" == "regress" & inlist("`model_name'", "smokef", "alcbase")  {
			qui estout `newvarname' `using', prehead("`model_type'" "`predicted_var'") collabels(,none) mlabels(,none) eqlabels(,none) prefoot("| Root Mean Square Error") stats(rmse, label("_rmse")) replace	
		} 
		else {
			qui estout `newvarname' `using', prehead("`model_type'" "`predicted_var'") collabels(,none) mlabels(,none) eqlabels(,none) replace	
		}
	}	
	
	* Handle probit models
	else if "`model_type'" == "probit" {
		if "`model_name'" == "mcare_ptd_enroll" {
			qui estout `newvarname' `using', prehead("shifted_probit" "`predicted_var'") collabels(,none) mlabels(,none) eqlabels(,none) replace	
			file open outfile `using', write text append
			file write outfile "| The shifts, by year. These create an average probability of ~65% in 2006, increasing to 75% in 2012 and after." _n		
			file write outfile "2006	0.23" _n
			file write outfile "2007	0.28" _n
			file write outfile "2008	0.34" _n
			file write outfile "2009	0.39" _n
			file write outfile "2010	0.45" _n
			file write outfile "2011	0.50" _n
			forvalues i = 2012(1)2150 {
		 		file write outfile "`i'	0.56" _n	
			}
			file close outfile
		}
                else if inlist("`model_name'", "cancre", "diabe", "hearte", "hibpe", "lunge", "memrye", "stroke", "chfe","died") {
                  qui estout `newvarname' `using', prehead("time_scaled_probit" "`predicted_var'" "2") collabels(,none) mlabels(,none) eqlabels(,none) replace
                }
		else {
			qui estout `newvarname' `using', prehead("`model_type'" "`predicted_var'") collabels(,none) mlabels(,none) eqlabels(,none) replace	
		}
	}
	
	* Handle ghreg models
	else if "`model_type'" == "ghreg" {
		qui file open outfile `using', write text replace
		file write outfile "`model_type'" _n
		file write outfile "`model_name'" _n
		file write outfile "theta" _column(25) %9.5f (`e(theta)') _n
		file write outfile "omega" _column(25) %9.5f (`e(omega)') _n
		file write outfile "ssr" _column(25) %9.5f (`e(ssr)') _n
		matrix x = e(b)
		matrix colnames x = `e(vars)'
		local ncols = colsof(x)
		forvalues i = 1/`ncols' {
			matrix y = x[1..1, `i'..`i']
			local var : colnames(y)
			local val = x[1,`i']
			file write outfile "`var'" _column(25) %9.5f (`val') _n	
		}
		file close outfile		
	}
	
	* Handle ordered probit models
	else if "`model_type'" == "oprobit" {
		qui file open outfile `using', write text replace
	  if "`model_name'" == "cogstate_stock" {
	     local vname "`predicted_var'"
       dis "vname is `vname'"
	     }
	  else {
	     local vname "`model_name'"
	     }
		file write outfile "`model_type'" _n
		file write outfile "`vname'" _n
		matrix x = e(b)
		matrix coleq x = ""
		local ncols = colsof(x)
		local cur_cut = 1
		forvalues i = 1/`ncols' {
			matrix y = x[1..1, `i'..`i']
			local var : colnames(y)
			local val = x[1,`i']
			if "`var'" == "_cons" {
				local var _cut`cur_cut'
				local cur_cut = `cur_cut' + 1
			}
			file write outfile "`var'" _column(25) %9.5f (`val') _n	
		}
		file close outfile		
	}
	
	* Handle logit and mlogit models
	else if "`model_type'" == "logit" | "`model_type'" == "mlogit" {
  	qui file open outfile `using', write text replace
    file write outfile "`model_type'" _n
		file write outfile "`model_name'" _n
		matrix x = e(b)
    matrix coleq x = ""
		local ncols = colsof(x)
    forvalues i= 1/`ncols' {
    	matrix y = x[1..1,`i'..`i']
      local var : colnames(y)
      local val = x[1, `i']
			file write outfile "`var'" _column(25) %9.5f (`val') _n
		}
		file close outfile
	}
	
  /* Handle two part models */      
  else if "`model_type'" == "twopm" {
		/* Details about the two models */
  	local models = e(eqnames)
  	tokenize `models'
  	* models might take the following forms: 1. probit or logit 2. regress, regress_log, or glm 
  	* Throw an error if glm, as we don't simulate GLM yet
  	if "`2'" == "glm" {
  		di "We don't simulate glm models yet"
  		exit(333)
  	}
  	
  	* The covariates list of the regress_log model is referred to as regress
  	if "`2'" == "regress_log" | "`2'" == "regress" {
  		local model2stem = "regress"
  	}
  	  	
  	qui file open outfile `using', write text replace
   	
   	* The two model types
   	file write outfile "`1'_`2'" _n
    file write outfile "`model_name'_stg1" _n
      
		* Setup the matrix with all of the coefficients
		matrix x = e(b)
    matrix coleq x = ""
    	
    * Number of regressors in first model
    local a = e(covariates_`1')
    local a_cnt : word count `a'
    * Don't forget the constant
    local a_cnt = `a_cnt' + 1
    	
    * Number of regressors in second model
    local b = e(covariates_`model2stem')
    local b_cnt : word count `b'
    * Don't forget the constant
    local b_cnt = `b_cnt' + 1
    
		* Output the first model
		forvalues i= 1/`a_cnt' {
    	matrix y = x[1..1,`i'..`i']
      local var : colnames(y)
    	local val = x[1, `i']
      file write outfile "`var'" _column(25) %9.5f (`val') _n
		}
			
		* Output the second model details
		file write outfile "| Stage 2" _n
		file write outfile "`model_name'_stg2" _n
			
		* Starting point for next model
		local c_cnt = `a_cnt' + 1
		local d_cnt = `a_cnt' + `b_cnt'
			
		* Output the second model
		forvalues i= `c_cnt'/`d_cnt' {
     	matrix y = x[1..1,`i'..`i']
      local var : colnames(y)
      local val = x[1, `i']
      file write outfile "`var'" _column(25) %9.5f (`val') _n
		}	
		* Add rmse if this is a regression model
		if "`2'" == "regress" {
			file write outfile "| Root Mean Square Error" _n
			local rmse = e(rmse_regress)
			file write outfile "_rmse `rmse'" _n
		}
		* Add Duan parameter if this is a log OLS model
		if "`2'" == "regress_log" {
			file write outfile "| Duan parameter" _n
			local duan = e(duan)
			file write outfile "_duan `duan'" _n
		}
		
		file close outfile
	}
  		        
	else {
		qui estout `newvarname' `using', prehead("`model_type'" "`predicted_var'") collabels(,none) mlabels(,none) eqlabels(,none) replace	
	}
end
