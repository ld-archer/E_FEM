/*
This file generates the summary_output text file that FEM needs to generate summary measures.  It is designed to generate
prevalence, incidence, total, mean, and percentile summary statistics.  Measures can be reported for the full population ("all") or by 
age ranges, gender, or race.

The user needs to:
	1. Provide a name for their output file (the local is called "filename")
	2. Decide which measure to include.  Knowledge of the variable names in FEM is required.  (the local is named "measures")
	3. Decide what subpopulations to include. (the local is named "subpop")
*/

quietly include ../fem_env.do

* File that specifies output file name, measures, and subpopulations
include measures_subpop_psid_validation.do

* Setup the file, header, and required outcomes ...

* Open the file
file open sumfile using "`filename'", write replace
* The header
file write sumfile "| Label,Description,Variable,Summary Type,Factor,Weight,Condition" _n
* The required outcomes
file write sumfile "pop_medicare,Total Medicare Eligible Population (Millions),weight,sum,0.000001,1,l2died==0 & medicare_elig" _n
file write sumfile "mcare_pta,Average Medicare Part A Costs,mcare_pta,mean,1,weight,l2died == 0 & mcare_pta_enroll == 1" _n
file write sumfile "mcare_ptb,Average Medicare Part B Costs,mcare_ptb,mean,1,weight,l2died == 0 & mcare_ptb_enroll == 1" _n


* Generate the length of the lists
local measures_l : word count `measures'
local subpop_l : word count `subpop'


* Now add our measures and subpopulations
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
		di "b is `b'"
		
		*Selection logic
		if "`b'" == "all" {
			local sel
			local samp "all"
		}
		else if "`b'" == "educ1" {
			local sel "& educ1 == 1"
			local samp "Educlvl = 1"
		}
		else if "`b'" == "educ2" {
			local sel "& educ2 == 1"
			local samp "Educlvl = 2"
		}
		else if "`b'" == "educ3" {
			local sel "& educ3 == 1"
			local samp "Educlvl = 3"
		}
		else if "`b'" == "educ4" {
			local sel "& educ4 == 1"
			local samp "Educlvl = 4"
		}
		else if "`b'" == "wht" {
			local sel "& black == 0 & hispan == 0"
			local samp "white"
		}
		else if "`b'" == "his" {
			local sel "& hispan == 1"
			local samp "hispanic"
		}
		else if "`b'" == "blk"{
			local sel "& black == 1"
			local samp "black"
		}
		else if "`b'" == "m" {
			local sel "& male == 1"
			local samp "male"
		}
		else if "`b'" == "f" {
			local sel "& male == 0"
			local samp "female"
		}
		else if "`b'" == "2544" {
			local sel "& age >= 25 & age < 45"
			local samp "age 25 to 44"
		}
		else if "`b'" == "4564" {
			local sel "& age >= 45 & age < 65"
			local samp "age 45 to 64"
		}
		else if "`b'" == "6584" {
			local sel "& age >= 65 & age < 85"
			local samp "age 65 to 84"
		}
		else if "`b'" == "2564" {
			local sel "& age >= 25 & age < 65"
			local samp "age 25 to 64"
		}
		else if "`b'" == "2534" {
			local sel "& age >= 25 & age < 35"
			local samp "age 25 to 34"
		}
		else if "`b'" == "3544" {
			local sel "& age >= 35 & age < 45"
			local samp "age 35 to 44"
		}
		else if "`b'" == "4554" {
			local sel "& age >= 45 & age < 55"
			local samp "age 45 to 54"
		}
		else if "`b'" == "5564" {
			local sel "& age >= 55 & age < 65"
			local samp "age 55 to 64"
		} 
		else if "`b'" == "6574" {
			local sel "& age >= 65 & age < 75"
			local samp "age 65 to 74"
		} 
		else if "`b'" == "7584" {
			local sel "& age >= 75 & age < 85"
			local samp "age 75 to 84"
		} 
		else if "`b'" == "85p" {
			local sel "& age >= 85"
			local samp "age 85 plus"
		} 
		else if "`b'" == "65p" {
			local sel "& age >= 65"
			local samp "age 65 plus"
		}
		else if "`b'" == "35p" {
			local sel "& age >= 35"
			local samp "age 35 plus"
		}
		else if "`b'" == "45p" {
			local sel "& age >= 45"
			local samp "age 45 plus"
		}
		else if "`b'" == "55p" {
			local sel "& age >= 55"
			local samp "age 55 plus"
		}
		else if "`b'" == "75p" {
			local sel "& age >= 75"
			local samp "age 75 plus"
		}
		
		else if "`b'" == "25x" {
			local sel "& age >= 25 & age < 26"
			local samp "age 25 exact"
		}
		
		else if "`b'" == "35x" {
			local sel "& age >= 35 & age < 36"
			local samp "age 35 exact"
		}
		
		else if "`b'" == "45x" {
			local sel "& age >= 45 & age < 46"
			local samp "age 45 exact"
		}
		
		else if "`b'" == "55x" {
			local sel "& age >= 55 & age < 56"
			local samp "age 55 exact"
		}
		
		else if "`b'" == "65x" {
			local sel "& age >= 65 & age < 66"
			local samp "age 65 exact"
		}
		
		else if "`b'" == "2549" {
			local sel "& age >= 25 & age < 50"
			local samp "age 25 to 49"
		}
		else if "`b'" == "5064" {
			local sel "& age >= 50 & age < 65"
			local samp "age 50 to 64"
		}
		else if "`b'" == "2549_m" {
			local sel "& age >= 25 & age < 50 & male == 1"
			local samp "males age 25 to 49"
		}
		else if "`b'" == "5064_m" {
			local sel "& age >= 50 & age < 65 & male == 1"
			local samp "males age 50 to 64"
		}		
		else if "`b'" == "65p_m" {
			local sel "& age >= 65 & male == 1"
			local samp "males age 65 plus"
		}		
		else if "`b'" == "2549_f" {
			local sel "& age >= 25 & age < 50 & male == 0"
			local samp "females age 25 to 49"
		}
		else if "`b'" == "5064_f" {
			local sel "& age >= 50 & age < 65 & male == 0"
			local samp "females age 50 to 64"
		}		
		else if "`b'" == "65p_f" {
			local sel "& age >= 65  & male == 0"
			local samp "females age 65 plus"
		}
		else if "`b'" == "2564_m" {
			local sel "& age >= 25 & age < 65 & male == 1"
			local samp "males age 25 to 64"
		}	
		else if "`b'" == "2564_f" {
			local sel "& age >= 25 & age < 65 & male == 0"
			local samp "females age 25 to 64"
		}		
		else if "`b'" == "e09" {
			local sel "& entry == 2009"
			local samp "2009 entry"
		}
		else if "`b'" == "e19" {
			local sel "& entry == 2019"
			local samp "2019 entry"
		}
		else if "`b'" == "e29" {
			local sel "& entry == 2029"
			local samp "2029 entry"
		}		
		else if "`b'" == "e39" {
			local sel "& entry == 2039"
			local samp "2039 entry"
		}
		else if "`b'" == "e49" {
			local sel "& entry == 2049"
			local samp "2049 entry"
		}
		else if "`b'" == "e11" {
			local sel "& entry == 2011"
			local samp "2011 entry"
		}
		else if "`b'" == "e15" {
			local sel "& entry == 2015"
			local samp "2015 entry"
		}
		else if "`b'" == "e19" {
			local sel "& entry == 2019"
			local samp "2019 entry"
		}		
		else if "`b'" == "e21" {
			local sel "& entry == 2021"
			local samp "2021 entry"
		}
		else if "`b'" == "e23" {
			local sel "& entry == 2023"
			local samp "2023 entry"
		}
		else if "`b'" == "e27" {
			local sel "& entry == 2027"
			local samp "2027 entry"
		}
		
		else if "`b'" == "e31" {
			local sel "& entry == 2031"
			local samp "2031 entry"
		}		
		else if "`b'" == "e35" {
			local sel "& entry == 2035"
			local samp "2035 entry"
		}
		else if "`b'" == "e39" {
			local sel "& entry == 2039"
			local samp "2039 entry"
		}		
		else if "`b'" == "e41" {
			local sel "& entry == 2041"
			local samp "2041 entry"
		}
		else if "`b'" == "e43" {
			local sel "& entry == 2043"
			local samp "2043 entry"
		}		
		else if "`b'" == "e47" {
			local sel "& entry == 2047"
			local samp "2047 entry"
		}		
		else if "`b'" == "e51" {
			local sel "& entry == 2051"
			local samp "2051 entry"
		}		
		
		else if "`b'" == "ft" {
			local sel "& workcat == 4"
			local samp "Full-time"
		}		
		
		else if "`b'" == "pt" {
			local sel "& workcat == 3"
			local samp "Part-time"
		}			
		else if "`b'" == "25p_m_l" {
			local sel "& age >= 25  & male == 1 & died ==0"
			local samp "living males age 25 plus"
		}
		else if "`b'" == "25p_f_l" {
			local sel "& age >= 25  & male == 0 & died ==0"
			local samp "living females age 25 plus"
		}		
		
		
							
		* Prevalence measures
		if substr("`a'",1,1) == "p" {
			file write sumfile "`a'_`b',Prevalence of `vname': Sample= `samp',`vname',mean,1,weight,l2died==0`sel'" _n
		}
		* Incidence measures
		else if substr("`a'",1,1) == "i" {
			file write sumfile "`a'_`b',Incidence of `vname': Sample= `samp',`vname',mean,1,weight,l2died==0&l2`vname'==0`sel'" _n
		}
		* Sum measures (counts)
		else if substr("`a'",1,1) == "n" {
			file write sumfile "`a'_`b',Sum of `vname': Sample= `samp',`vname',sum,1,weight,l2died==0`sel'" _n
		}
		* Sum measures (costs)
		else if substr("`a'",1,1) == "t" {
			file write sumfile "`a'_`b',Sum of `vname': Sample= `samp',`vname',sum,1,weight,l2died==0`sel'" _n
		}
		else if substr("`a'",1,1) == "a" {
			file write sumfile "`a'_`b',Average of `vname': Sample= `samp',`vname',mean,1,weight,l2died==0`sel'" _n
		}
		* Average age at death
		else if substr("`a'",1,1) == "d" {
			file write sumfile "`a'_`b',Average `vname' at death: Sample= `samp',`vname',mean,1,weight,l2died==0&died==1`sel'" _n
		}
		else if substr("`a'",1,1) == "q" {
			local pcnt = substr("`a'",2,2)
			file write sumfile "`a'_`b',`pcnt' percentile of `vname': Sample = `samp',`vname',quantile-.`pcnt',1,weight,l2died==0`sel'" _n
		}
		* Measures only defined for the living
		if substr("`a'",1,1) == "P" {
			file write sumfile "`a'_`b',Prevalence of `vname': Sample= Living & `samp',`vname',mean,1,weight,died==0`sel'" _n
		}
		
		
		else if substr("`a'",1,1) == "m" {
			if "`vname'" == "startpop" {
				file write sumfile "`a'_`b',`vname' (millions): Sample = `samp',weight,sum,0.000001,1,l2died == 0`sel'" _n
			}
			else if "`vname'" == "endpop" {
				file write sumfile "`a'_`b',`vname' (millions): Sample = `samp',weight,sum,0.000001,1,died == 0`sel'" _n
			}
		}
	}
}

file close sumfile


capture log close






/* 
Other measures

file write sumfile "mcare_tot,Total Medicare Costs,mcare,sum,1,weight,ldied==0" _n
file write sumfile "mcare_pta_tot,Total Part A costs,mcare_pta,sum,1,weight,ldied==0" _n
file write sumfile "mcare_ptb_tot,Total Part B costs,mcare_ptb,sum,1,weight,ldied==0" _n
file write sumfile "mcare_ptd_tot,Total Part D costs,mcare_ptd,sum,1,weight,ldied==0" _n
file write sumfile "mcare_pta_tot_enroll,Total Part A costs,mcare_pta_enroll,sum,1,weight,ldied==0" _n
file write sumfile "mcare_ptb_tot_enroll,Total Part B costs,mcare_ptb_enroll,sum,1,weight,ldied==0" _n
file write sumfile "mcare_ptd_tot_enroll,Total Part D costs,mcare_ptd_enroll,sum,1,weight,ldied==0" _n


*/

