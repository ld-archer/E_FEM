/*
Produce plots of main PSID outcomes
*/

#d ;
local measures 	
			m_startpop
			m_endpop
			a_iearnx
			a_hatotax
			p_workcat1 	p_workcat2	p_workcat3	p_workcat4
			p_cancre p_diabe p_hearte p_hibpe p_lunge p_stroke											
;
#d cr

local subpop e11 e15 e19 e23 e27 e31 e35 e39 e43 e47 e51

local measures_l : word count `measures'
local subpop_l : word count `subpop'


local scen psid_notrend psid_default

foreach s of local scen {
	use ../output/`s'/`s'_summary.dta, clear
	
	drop *sd
	forvalues x = 1/`measures_l' {
		local a : word `x' of `measures'
	
		* Deal with particulars of prefixes	
		if substr("`a'",1,1) == "q" {
			local vname = substr("`a'",5,.)
		}
		else {
			local vname = substr("`a'",3,.)
		}
		
		* For subpopulation
		forvalues y = 1/`subpop_l' {
			local b : word `y' of `subpop'
			if `y' < `subpop_l' {
				local cmd "`cmd' line `a'_`b' year ||" 
			}
			else if `y' == `subpop_l' {
		 	 local cmd "`cmd' line `a'_`b' year"			
			}
		
			di "`cmd'"
			graph twoway `cmd', legend(size(tiny))
			* graph twoway `cmd', legend(rows(`subpop_l') size(small))
			graph save psid_plots/`s'/`a'.gph, replace
		}
		local cmd 
	}
}





capture log close
