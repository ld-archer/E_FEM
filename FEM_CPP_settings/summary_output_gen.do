/*
This file generates the summary_output text file that FEM needs to generate summary measures.  It is designed to generate
prevalence, incidence, total, mean, and percentile summary statistics.  Measures can be reported for the full population ("all") or by 
age ranges, gender, or race.

The user needs to:
	1. Provide a name for their output file (the local is called "filename")
	2. Decide which measure to include.  Knowledge of the variable names in FEM is required.  (the local is named "measures")
	3. Decide what subpopulations to include. (the local is named "subpop")
*/

set more off
quietly include ../fem_env.do

* Name of your input and output files
local scen : env measures_suffix

* Summary output file name
local filename summary_output_`scen'.txt

* Measures and subpopulations are defined here
include measures_subpop_ELSA.do


* Setup the file, header, and required outcomes ...

* Open the file
file open sumfile using "`filename'", write replace
* The header
file write sumfile "| Label,Description,Variable,Summary Type,Factor,Weight,Condition" _n


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
		else if "`b'" == "55p_l" {
			local sel "& age >= 55 & died == 0"
			local samp "age 55 plus living"
		}
		else if "`b'" == "55p_m_l" {
			local sel "& age >= 55 & male == 1 & died == 0"
			local samp "male age 55 plus living"
		}
		else if "`b'" == "55p_f_l" {
			local sel "& age >= 55 & male == 0 & died == 0"
			local samp "female age 55 plus living"
		}
		else if "`b'" == "educ1" {
			local sel "& hsless == 1"
			local samp "Less than HS"
		}
		else if "`b'" == "educ2" {
			local sel "& hsless == 0 & college == 0"
			local samp "High school"
		}
		else if "`b'" == "educ3" {
			local sel "& college == 1"
			local samp "College"
		}
		else if "`b'" == "drinkd1" {
			local sel "& drinkd_stat == 1"
			local samp "Drinkd1"
		}
		else if "`b'" == "drinkd2" {
			local sel "& drinkd_stat == 2"
			local samp "Drinkd2"
		}
		else if "`b'" == "drinkd3" {
			local sel "& drinkd_stat == 3"
			local samp "Drinkd3"
		}
		else if "`b'" == "drinkd4" {
			local sel "& drinkd_stat == 4"
			local samp "Drinkd4"
		}
		else if "`b'" == "exstat1" {
			local sel "& exstat == 1"
			local samp "exstat1"
		}
		else if "`b'" == "exstat2" {
			local sel "& exstat == 2"
			local samp "exstat2"
		}
		else if "`b'" == "exstat3" {
			local sel "& exstat == 3"
			local samp "exstat3"
		}
		else if "`b'" == "obese" {
			local sel "& obese == 1"
			local samp "obese"
		}
		else if "`b'" == "notObese" {
			local sel "& obese == 0"
			local samp "notObese"
		}
		else if "`b'" == "anyadl" {
			local sel "& anyadl == 1"
			local samp "anyadl"
		}
		else if "`b'" == "noadl" {
			local sel "& anyadl == 0"
			local samp "noadl"
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

