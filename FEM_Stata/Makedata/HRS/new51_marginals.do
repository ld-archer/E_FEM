/** \file

\todo Figure out what on earth this file does and decide what to do about it.
*/
  
clear
global margin_list csmoker csmoker_n fsmoker under_30 over_30  over_30_n nsmoker
	
use "$outdata/new51_2004_status_quo.dta"
summ bmi if bmi < 30 [aweight = weight]
local blah = r(mean)

summ bmi if bmi >= 30  [aweight = weight]
local ratio = `blah'/r(mean)


foreach scr in $margin_list{
	
	clear
		if "`scr'" == "under_30"{
       		use "$outdata/new51_2004_status_quo.dta"
			gen under_30 = bmi < 30
         	bys hhid: egen inc = total(under_30 == 1)
        	keep if inc == 1 | inc == 2
        	replace weight = 0 if !(under_30 == 1)
       	} 

		else if "`scr'" == "over_30"{
       		use "$outdata/new51_2004_status_quo.dta"
			gen over_30 = bmi >= 30 & bmi !=.
        	bys hhid: egen inc = total(over_30 == 1)
        	keep if inc == 1 | inc == 2
        	replace weight = 0 if !(over_30 == 1)
       	}        	

		else if "`scr'" == "over_35"{
       		use "$outdata/new51_2004_status_quo.dta"
			gen over_35 = bmi >= 35 & bmi !=.
        	bys hhid: egen inc = total(over_35 == 1)
        	keep if inc == 1 | inc == 2
        	replace weight = 0 if !(over_35 == 1)
       	} 
		
        else if "`scr'" == "over_30_n"{
       		use "$outdata/new51_2004_status_quo.dta"
			gen over_30 = bmi > 30 & bmi!=.
        	bys hhid: egen inc = total(over_30 == 1)
        	keep if inc == 1 | inc == 2
        	replace weight = 0 if !(over_30 == 1)

			replace bmi = bmi*`ratio'
			replace logbmi = ln(bmi)
			
			replace overwt = 1 if bmi >= 25 & bmi < 30 
			replace obese_1 = 1 if bmi >= 30 & bmi < 35 
			replace obese_2 = 1 if bmi >= 35 & bmi < 40
			replace obese_3 = 1 if bmi >= 40 & bmi < .			
			
			replace wtstate = 1 if bmi < 25
			replace wtstate = 2 if overwt == 1
			replace wtstate = 3 if obese_1 == 1
			replace wtstate = 4 if obese_2 == 1
			replace wtstate = 5 if obese_3 == 1
			
			replace llogbmi = logbmi
			replace flogbmi = logbmi
			
		} 
		
        else if "`scr'" == "over_30_n_nof"{
       		use "$outdata/new51_2004_status_quo.dta"
			gen over_30 = bmi > 30 & bmi!=.
        	bys hhid: egen inc = total(over_30 == 1)
        	keep if inc == 1 | inc == 2
        	replace weight = 0 if !(over_30 == 1)

			replace bmi = bmi*`ratio'
			replace logbmi = ln(bmi)
			
			replace overwt = 1 if bmi >= 25 & bmi < 30 
			replace obese_1 = 1 if bmi >= 30 & bmi < 35 
			replace obese_2 = 1 if bmi >= 35 & bmi < 40
			replace obese_3 = 1 if bmi >= 40 & bmi < .			
			
			replace wtstate = 1 if bmi < 25
			replace wtstate = 2 if overwt == 1
			replace wtstate = 3 if obese_1 == 1
			replace wtstate = 4 if obese_2 == 1
			replace wtstate = 5 if obese_3 == 1
			
			replace llogbmi = logbmi
			*replace flogbmi = logbmi
			
		} 
		
         else if "`scr'" == "bmi_35_red"{
       		use "$outdata/new51_2004_status_quo.dta"
			gen over_35 = bmi > 35 & bmi!=.
        	bys hhid: egen inc = total(over_35 == 1)
        	keep if inc == 1 | inc == 2
        	replace weight = 0 if !(over_35 == 1)
			
			replace bmi = bmi*0.2
			replace logbmi = ln(bmi)
			
			replace overwt = 1 if bmi >= 25 & bmi < 30 
			replace obese_1 = 1 if bmi >= 30 & bmi < 35 
			replace obese_2 = 1 if bmi >= 35 & bmi < 40
			replace obese_3 = 1 if bmi >= 40 & bmi < .			
			
			replace wtstate = 1 if bmi < 25
			replace wtstate = 2 if overwt == 1
			replace wtstate = 3 if obese_1 == 1
			replace wtstate = 4 if obese_2 == 1
			replace wtstate = 5 if obese_3 == 1
			
			replace llogbmi = logbmi
			replace flogbmi = logbmi
		}
		
		
		
        else if "`scr'" == "nsmoker"{
       		use "$outdata/new51_2004_status_quo.dta"
         	bys hhid: egen inc = total(smokev == 0 & smoken == 0)
        	keep if inc == 1 | inc == 2
        	replace weight = 0 if !(smokev == 0 & smoken == 0)
       	} 
        else if "`scr'" == "fsmoker"{
       		use "$outdata/new51_2004_status_quo.dta"
         	bys hhid: egen inc = total(smokev == 1 & smoken == 0)
        	keep if inc == 1 | inc == 2
        	replace weight = 0 if !(smokev == 1 & smoken == 0)
       	} 
        else if "`scr'" == "csmoker"{
       		use "$outdata/new51_2004_status_quo.dta"
         	bys hhid: egen inc = total(smokev == 1 & smoken == 1)
        	keep if inc == 1 | inc == 2
        	replace weight = 0 if !(smokev == 1 & smoken == 1)
       	}  
       	
        else if "`scr'" == "csmoker_n"{
       		use "$outdata/new51_2004_status_quo.dta"
         	bys hhid: egen inc = total(smokev == 1 & smoken == 1)
        	keep if inc == 1 | inc == 2
        	replace weight = 0 if !(smokev == 1 & smoken == 1)
        	replace fsmokev = 0
			replace smokev = 0
        	replace fsmoken = 0
        	replace lsmoken = 0
        	replace smoken = 0
			replace smkstat = 1
			replace lsmkstat = 1
			replace fsmkstat = 1
       	}  


	
	else if "`scr'" == "cure_v_prev"{

		clear
		use "$outdata/new51_2050_status_quo.dta"
		**Identify Surgery
		**Identify Co-Morbidities**
		gen comorbid = cancre == 1 | lunge == 1 | stroke == 1 | hibpe == 1 | diabe == 1 | hearte == 1 | adl12 == 1 | adl3 == 1
		assert logbmi!=.
		gen surgery = (comorbid == 1 & inrange(logbmi,log(30),log(35))) | (logbmi >= log(35))
		gen pill = logbmi > log(25)
			
		keep if pill == 1 | surgery == 1
		
		save "$outdata/new51_2050_status_quo_treated.dta", replace
		
	clear
		use "$outdata/new51_2010_status_quo.dta"
		**Identify Surgery
		**Identify Co-Morbidities**
		gen comorbid = cancre == 1 | lunge == 1 | stroke == 1 | hibpe == 1 | diabe == 1 | hearte == 1 | adl12 == 1 | adl3 == 1
		assert logbmi!=.
		gen surgery = (comorbid == 1 & inrange(logbmi,log(30),log(35))) | (logbmi >= log(35))
		gen pill = logbmi > log(25)
			
		keep if pill == 1 | surgery == 1
		
		save "$outdata/new51_2010_status_quo_treated.dta", replace
		
		tempfile temp
		save `temp'
			
		gen ratio = 1
		replace ratio = 0.8 if surgery == 1 & pill == 0
		replace ratio = 0.75 if surgery == 1 & pill == 1
		replace ratio = 0.95 if surgery == 0 & pill == 1
		
		replace bmi = bmi*ratio
		replace logbmi = ln(bmi)
		
		replace overwt = 1 if bmi >= 25 & bmi < 30 
		replace obese_1 = 1 if bmi >= 30 & bmi < 35 
		replace obese_2 = 1 if bmi >= 35 & bmi < 40
		replace obese_3 = 1 if bmi >= 40 & bmi < .			
			
		replace wtstate = 1 if bmi < 25
		replace wtstate = 2 if overwt == 1
		replace wtstate = 3 if obese_1 == 1
		replace wtstate = 4 if obese_2 == 1
		replace wtstate = 5 if obese_3 == 1
		
		drop ratio
		
		save "$outdata/new51_2010_obs_cure", replace
		
		
		forvalues portion = 0(10)100{
			clear
			use `temp'		
			gen ratio = 1
			replace ratio = 0.8 if surgery == 1 & pill == 0
			replace ratio = 0.75 if surgery == 1 & pill == 1
			replace ratio = 0.95 if surgery == 0 & pill == 1
			
			local rate = 100-`portion'
			
			replace bmi = bmi*(1-(1-ratio)*(1-`rate'/100))
			replace logbmi = ln(bmi)
			
			replace overwt = 1 if bmi >= 25 & bmi < 30 
			replace obese_1 = 1 if bmi >= 30 & bmi < 35 
			replace obese_2 = 1 if bmi >= 35 & bmi < 40
			replace obese_3 = 1 if bmi >= 40 & bmi < .			
			
			replace wtstate = 1 if bmi < 25
			replace wtstate = 2 if overwt == 1
			replace wtstate = 3 if obese_1 == 1
			replace wtstate = 4 if obese_2 == 1
			replace wtstate = 5 if obese_3 == 1
			
			foreach k in logbmi overwt obese_1 obese_2 obese_3 wtstate{
			replace l`k' = `k'
			replace f`k' = `k'
			}
			save "$outdata/new51_2010_obs_prev_`portion'", replace
		}
		forvalues portion = 60(1)80{
			clear
			use `temp'		
			gen ratio = 1
			replace ratio = 0.8 if surgery == 1 & pill == 0
			replace ratio = 0.75 if surgery == 1 & pill == 1
			replace ratio = 0.95 if surgery == 0 & pill == 1
			
			local rate = 100-`portion'
			
			replace bmi = bmi*(1-(1-ratio)*(1-`rate'/100))
			replace logbmi = ln(bmi)
			
			replace overwt = 1 if bmi >= 25 & bmi < 30 
			replace obese_1 = 1 if bmi >= 30 & bmi < 35 
			replace obese_2 = 1 if bmi >= 35 & bmi < 40
			replace obese_3 = 1 if bmi >= 40 & bmi < .			
			
			replace wtstate = 1 if bmi < 25
			replace wtstate = 2 if overwt == 1
			replace wtstate = 3 if obese_1 == 1
			replace wtstate = 4 if obese_2 == 1
			replace wtstate = 5 if obese_3 == 1
			
			foreach k in logbmi overwt obese_1 obese_2 obese_3 wtstate{
			replace l`k' = `k'
			replace f`k' = `k'
			}
			save "$outdata/new51_2010_obs_prev_`portion'", replace
		}

	}
	if "`scr'" != "cure_v_prev"{
	save "$outdata/new51_2004_`scr'", replace
	}
}
