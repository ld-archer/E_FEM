cap program drop intervention
program define intervention

	
	syntax [varlist] [if] [in], cyr(integer) scenario(string)

	*** Implement intervention scenarios
	*** cyr: current year
	*** scenario: intervention scenario
	*** revised on Dec 19, 2007
	*** Aug 30, 2008 - change the intervention scenarios    

	marksample touse
    
    noi tab `touse'
	****************************
	* SET RELEVANT PARAMETERS
	****************************
	
	*** Default parameters
 	scalar aoverwt = 1
 	scalar aobese  = 1
 	scalar adiabe  = 1
 	scalar ahibpe  = 1
 	scalar ahibpe_hearte = 1
 	scalar ahibpe_stroke = 1
 	scalar asmoken = 1
 	scalar amemrye = 1
 	
 	*** Parameters for specific scenarios
 	
	if "`scenario'" == "Obs_R" {
		scalar aobese  = 0.75
	}
	
	else if "`scenario'" == "Obs_J" {
		scalar aobese  = 0.50
	}
	
 	else if  "`scenario'" == "Obs_E" {
 		scalar aobese  = 0
  }

 	else if  "`scenario'" == "Hbp_R" {
 		scalar ahibpe  = 0.58
  }
 	else if  "`scenario'" == "Hbp_J" {
 		scalar ahibpe  = 0.5
  }
  else if  "`scenario'" == "Hbp_E" {
 		scalar ahibpe  = 0.0
  }
  
 	else if  "`scenario'" == "Diabetes_R" {
 		scalar adiabe  = 0.51
 	}

 	else if  "`scenario'" == "Diabetes_J" {
 		scalar adiabe  = 0.50
 	}

 	else if  "`scenario'" == "Diabetes_E" {
 		scalar adiabe  = 0.0
 	}
 	 	
 	* Ratio of new quitting rate relative to old quitting rate
  else if  "`scenario'" == "Smoking_R" {
 		scalar asmoken = 1.50
 	}
  else if  "`scenario'" == "Smoking_J" {
 		scalar asmoken = 0.50
 	}
  else if  "`scenario'" == "Smoking_E" {
 		scalar asmoken = 0.00
 	}
 	 		
	*****************************************
	* Record status before intervention - Aug 31,2008
	*****************************************
 	foreach x in smoken diabe hibpe obese {  
        noi dis "******* RECORD OLD ********"
 		cap drop old_`x'
 		gen old_`x' = `x'
 	}
	
	*****************************************
	* Update treatment status
	*****************************************
	cap drop ltreat_now
	gen ltreat_now = treat_now
	replace ltreat_ever = treat_ever
    
    replace ltreat_hibpe = treat_hibpe
    replace ltreat_diabe = treat_diabe
    replace ltreat_hibpe_evr = treat_hibpe_evr
    replace ltreat_diabe_evr = treat_diabe_evr
	
    if "`scenario'" == "Hbp_R"  {
		* replace treat_now = (((lobese == 1 | loverwt == 1 ) & hibpdraw <= 0.5) | treat_ever == 1) & lhibpe == 0 & died == 0 if `touse'
		* Treat those who would have developed hypertension between 51 to 70 under status-quo
		replace treat_now = hbp_treat == 1 & died == 0 & lhibpe == 0 
		replace treat_effective = 0  if `touse'
	}
	
	else if "`scenario'" == "Diabetes_R" {
		replace treat_now = (((lobese == 1 | loverwt == 1 ) & diabdraw <= 0.25) | treat_ever == 1) & ldiabe == 0 & died == 0 if `touse'
		replace treat_effective = 0  if `touse'
	}

	else if "`scenario'" == "Obs_R"  {
		replace treat_now = (lobese == 1) & died == 0  if `touse'
		replace  treat_effective = 0  if `touse'
	}

	else if "`scenario'" == "Smoking_R"{
		replace  treat_now = (lsmoken == 1) & died == 0  if `touse'
		replace  treat_effective = 0  if `touse'
	}
		
	else if "`scenario'" == "Hbp_J" | "`scenario'" == "Hbp_E"{
		replace treat_now = hibpe == 1 & died == 0 & ltreat_ever == 0 if `touse'
	}
	else if "`scenario'" == "Diabetes_J" | "`scenario'" == "Diabetes_E"{
		replace treat_now = diabe == 1 & died == 0 & ltreat_ever == 0 if `touse'
	}		
	else if "`scenario'" == "Smoking_J" | "`scenario'" == "Smoking_E"{
		replace treat_now = smoken == 1 & died == 0 & ltreat_ever == 0 if `touse'		
	}
	else if "`scenario'" == "Obs_J" | "`scenario'" == "Obs_E"{
		replace treat_now = obese == 1 & died == 0 & ltreat_ever == 0 if `touse'		
	}

	else if "`scenario'" == "Diab_Hibpe"{   
		replace treat_hibpe = hibpe == 1 & died == 0 & ltreat_hibpe_evr == 0 if `touse'		
		replace treat_diabe = diabe == 1 & died == 0 & ltreat_diabe_evr == 0 if `touse'		
	}
	
	replace treat_ever = 1 if treat_now == 1
    replace treat_hibpe_evr = 1 if treat_hibpe == 1
    replace treat_diabe_evr = 1 if treat_diabe == 1
    
	*****************************************
	* Generate a random draw - for intervention
	*****************************************
	sort entry hhid hhidpn, stable
	cap drop intdraw
	gen intdraw = uniform()
	
	*********************
	*** IMPLEMENT INTERVENTION
	********************* 

	********************************************************* 
	*EBM SCENARIOS
	*********************************************************     

	*** HYPERTENSION PREVENTION
	if strpos("`scenario'", "Hbp") > 0 {
		replace phibpe  = (phibpe) * ahibpe if treat_now
		gen hibpe_new  = hibpe
		replace hibpe_new = phibpe > normal(-x_hibpe`cyr') if treat_now
		replace treat_effective = 1 if hibpe == 1 & hibpe_new == 0 & treat_now
		replace hibpe = 0 if treat_effective
		drop hibpe_new
	}

	*** DIABETES PREVENTION
	else if strpos("`scenario'", "Diabetes") > 0 {	
		replace pdiabe  = (pdiabe) * adiabe if treat_now
		gen diabe_new  = diabe
		replace diabe_new = pdiabe > normal(-x_diabe`cyr') if treat_now		
		replace treat_effective = 1 if diabe == 1 & diabe_new == 0 & treat_now
		replace diabe = 0 if treat_effective
		drop diabe_new
  }

	*** SMOKING CESSATION
	else if strpos("`scenario'", "Smoking") > 0 {	
		foreach v in smkstat {
			* Update the probabilities
			
			if "`scenario'"== "Smoking_R" {
				replace p`v'3 = 1 - min((1 - p`v'3)*asmoken, 1) if d_`v' & treat_now
			}
			else {
				replace p`v'3 = p`v'3 * asmoken
			}
			
			replace treat_effective = 1 if normal(x_`v'`cyr') < 1 - p`v'3 & treat_now
		}
			replace smoken = 0 if treat_effective == 1
	}

  *** OBESITY REDUCTION
	else if strpos("`scenario'", "Obs_R") > 0 {
		foreach v in wtstate {
		  dis "Obesity reduction"
			* Update the probabilities
			forvalues i = 1/3{
				cap drop p`v'`i'_old
				gen p`v'`i'_old = p`v'`i'
			}

			/* Aug 2008*/
			replace p`v'3 = p`v'3 * aobese if d_`v' & treat_now
			replace p`v'2 = (p`v'2_old /(p`v'1_old + p`v'2_old)) * (1 - p`v'3) if d_`v' & treat_now
			replace p`v'1 = (p`v'1_old /(p`v'1_old + p`v'2_old)) * (1 - p`v'3) if d_`v' & treat_now
			
			cap drop `v'_old		
			ren `v' `v'_old
			local numcut = 2
			local lastc = `numcut' + 1
			gen `v' = `lastc' if normal(x_`v'`cyr') >= 1 - p`v'`lastc' & d_`v'
			forvalues j = `numcut'(-1)2 {
				local k = `j'-1
				replace `v' = `j' if (normal(x_`v'`cyr') >= p`v'`k') & (normal(x_`v'`cyr') < p`v'`k' + p`v'`j') & d_`v'
			}
			replace `v' = 1 if normal(x_`v'`cyr') < p`v'1 & d_`v'

			* replace `v' = 1 if treat_effective == 1 
			replace `v' = `v'_old if treat_effective == 1
			replace treat_effective = 1 if `v' < `v'_old

			* Dummies for categories
			forvalues j = 1/2{
					local ovar = "`v'_cat"
					local catvar = word("$`ovar'", `j')
					cap drop `catvar'
					gen `catvar' = `v' == `j' + 1 if d_`v'
			}		
		}
	} 
	
	*** OBESITY TO NORMAL WEIGHT
	else if strpos("`scenario'", "Obs_J") > 0 | strpos("`scenario'", "Obs_E") > 0 {
		replace treat_effective = 1 if treat_now & normal(x_wtstate2004) >= aobese
		replace obese = 0 if treat_effective
	}
	
	********************************************************* 
	*CURE SCENARIOS
	********************************************************* 
	
	/********************* Reduction scenarios **************************/
	*** Hypertension

	else if "`scenario'" == "Hbp_J" |  "`scenario'" == "Hbp_E"  {
		replace ltreat_ever = treat_ever
		if "`scenario'" == "Hbp_J" {
			local rd = 0.5
		}
		else {
			local rd = 0
		}
		replace treat_ever = 1 if hibpe == 1 & died == 0 & `touse'
		replace treat_now = hibpe == 1 & died == 0 & ltreat_ever == 0 & normal(x_hibpe2004) >= `rd' if `touse'
		replace hibpe = 0 if (treat_now | treat_effective) & `touse'
		replace treat_effective = old_hibpe == 1 & hibpe == 0 if `touse'
	}	

	*** Diabetes
	else if "`scenario'" == "Diabetes_J" |  "`scenario'" == "Diabetes_E"  {
		replace ltreat_ever = treat_ever	
		if "`scenario'" == "Diabetes_J" {
			local rd = 0.5
		}
		else {
			local rd = 0
		}
		replace treat_ever = 1 if diabe == 1 & died == 0 & `touse'
		replace treat_now = diabe == 1 & died == 0 & ltreat_ever == 0 & normal(x_diabe2004) >= `rd' if `touse'
		replace diabe = 0 if (treat_now | treat_effective) & `touse'
		replace treat_effective = old_diabe == 1 & diabe == 0 if `touse'
	}	
	
	*** Smoking
	else if "`scenario'" == "Smoking_J" |  "`scenario'" == "Smoking_E"  {
		replace ltreat_ever = treat_ever
		if "`scenario'" == "Smoking_J" {
			local rd = 0.5
		}
		else {
			local rd = 0
		}
		replace treat_ever = 1 if smoken == 1 & died == 0 & `touse'
		replace treat_now = smoken == 1 & died == 0 & ltreat_ever == 0 & normal(x_smkstat2004) > `rd' if `touse'
		replace smoken = 0 if (treat_now | treat_effective) & `touse'
		replace treat_effective = old_smoken == 1 & smoken == 0 if `touse'
	}		
	
	*** Obesity
	else if "`scenario'" == "Obs_J" |  "`scenario'" == "Obs_E"  {
		if "`scenario'" == "Obs_J" {
			local rd = 0.5
		}
		else {
			local rd = 0
		}
		replace treat_ever = 1 if obese == 1 & died == 0 & `touse'
		replace treat_now = (obese == 1) & died == 0 & ltreat_ever == 0 & normal(x_wtstate2004) > `rd' if `touse'
		replace obese = 0 if (treat_now | treat_effective) & `touse'
		replace treat_effective = old_obese == 1 & obese == 0 if `touse'
	}  


	else if "`scenario'" == "Diab_Hibpe"  {    

        local rd = 0.75
		replace treat_hibpe_evr = 1 if hibpe == 1 & died == 0 & `touse'
		replace treat_hibpe = hibpe == 1 & died == 0 & ltreat_hibpe_evr == 0 & normal(x_hibpe2004) >= `rd' if `touse'
		replace hibpe = 0 if (treat_hibpe | treat_hibpe_eff) & `touse'
		replace treat_hibpe_eff = 1 if old_hibpe == 1 & hibpe == 0 & `touse'  

        local rd = 0.75   
		replace treat_diabe_evr = 1 if diabe == 1 & died == 0 & `touse'
		replace treat_diabe = diabe == 1 & died == 0 & ltreat_diabe_evr == 0 & normal(x_diabe2004) >= `rd' if `touse'
		replace diabe = 0 if (treat_diabe | treat_diabe_eff) & `touse'
		replace treat_diabe_eff = 1 if old_diabe == 1 & diabe == 0 & `touse'
	}	
	

	********************************************************* 
	*OBESITY SCENARIOS - reduce obesity prevalence
	*********************************************************
		
    #d;
	if 
        ($simutype ==3 & ("`scenario'" == "obese_r" | "`scenario'" == "invobese_r"))|
        ($simutype ==2 & ("`scenario'" == "obese_r04" | "`scenario'" == "obese_r30" | "`scenario'" == "obese_r50" )) | 
        ($simutype ==2 & ("`scenario'" == "invobese_r04" | "`scenario'" == "invobese_r30" | "`scenario'" == "invobese_r50" )) 
        {;
    #d cr
        if ($simutype ==3 & ("`scenario'" == "obese_r" | "`scenario'" == "invobese_r")){
            local cht = `cyr' - 2
        }
        else {
            local cht = 2004
        }
        local v wtstate	
        if "`v'" == "funcstat" {
			local numcut = 3
		} 
		else {
			local numcut = 2
		}
		* Get cutoff and betas
		local coln = colsof(coef_`v')-`numcut' 
		matrix c`v' = coef_`v'[1...,1..`coln']
		forvalues j = 1/`numcut'{
			local cut`j' = coef_`v'[1,`coln'+`j']
		}

	    forvalues i = 1/3{
			cap drop p`v'`i'_old
			gen p`v'`i'_old = p`v'`i'
		}
        cap drop wtstate_old
        gen wtstate_old = wtstate
        forvalues i = 2004(2)`cht'{
            * Baseline obesity rate at entry
            local o_base = base_obese[rownumb(base_obese,"y`i'"), colnumb(base_obese,"y`i'")]
           * Intervention scenario obesity rate at entry            
            local o_scr = scr_obese[rownumb(base_obese,"y`i'"), colnumb(scr_obese,"y`i'")]
           * Current obesity rate for certain cohort under baseline
            local o_base_c = base_obese[rownumb(base_obese,"y`i'"), colnumb(base_obese,"y`cyr'")]
           * Current obesity rate for certain cohort under intervension
            qui sum p`v'3 [aw = weight] if entry == `i' & died == 0
            local o_scr_c = r(mean)
            cap drop `v'_delta    
            gen `v'_delta = 0 if d_`v'        
            if `o_scr_c' > `o_base_c' * `o_scr' / `o_base'{
                * Deviation of the constant
                local k = `numcut'
                local r = (`o_base_c' * `o_scr' / `o_base')/`o_scr_c'
                replace `v'_delta = `v'_cut`k' + invnorm(min(`r' * normal(`v'_xb -`v'_cut`k'),0.99999999)) - `v'_xb if entry == `i' & d_`v'
            }
       }  

        replace `v'_xb = `v'_xb + `v'_delta
 		* Probabilities for each category
		cap drop p`v'1
		gen p`v'1 = normal(`cut1'-`v'_xb) if d_`v'
		forvalues j = 2/`numcut'{
			local k = `j'-1
			cap drop p`v'`j' 
			gen p`v'`j' = normal(`cut`j''-`v'_xb) - normal(`cut`k''-`v'_xb) if d_`v'
		}		
		local lastc = `numcut' + 1
		cap drop p`v'`lastc'
		gen p`v'`lastc' = 1 -  normal(`cut`numcut'' - `v'_xb) if d_`v'
			
		cap drop `v'_old		
		ren `v' `v'_old

		local lastc = `numcut' + 1
		gen `v' = `lastc' if normal(x_`v'`cyr') >= 1 - p`v'`lastc' & d_`v'
		forvalues j = `numcut'(-1)2 {
			local k = `j'-1
			replace `v' = `j' if (normal(x_`v'`cyr') >= p`v'`k') & (normal(x_`v'`cyr') < p`v'`k' + p`v'`j') & d_`v'
		}
		replace `v' = 1 if normal(x_`v'`cyr') < p`v'1 & d_`v'

		* Dummies for categories
		forvalues j = 1/2{
			local ovar = "`v'_cat"
			local catvar = word("$`ovar'", `j')
			cap drop `catvar'
			gen `catvar' = `v' == `j' + 1 if d_`v'
		}	
    }

    
	****************************
	* Aug 30, 2008 - update cases of diseases, quiting smoking or becoming obese
	****************************	
	/* Aug 31, Ever conditions for the summary of cases averted */
	quietly{
		foreach x in smoken diabe hibpe obese {
		  cap drop llf`x'
			gen llf`x' = lf`x'
			replace lf`x' = lf`x' + 1 if old_`x'== 1 & `x' == 0 
			* If relapse, for EBM scenarios
			* replace lf`x' = 0 if `x' == 1
		}
 	}

end
             
