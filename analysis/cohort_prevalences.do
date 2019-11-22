***=======================================================*	 
* FEM scenario combination - lifetime
* Sep 25, 2008
***=======================================================*	 

capt log close
clear
cap clear mata
set more off
set mem 500m
set linesize 255


* Assume that this script is being executed in the analysis directory

* Load environment variables from the root FEM directory, one level up
* these define important paths, specific to the user
include "../fem_env.do"


global out_path "$local_root/output/JHE"

***=============================*	 
global outdata "$local_root/output/JHE"

global scnr_base "status_quo smk_iom smk_ext whiter intermed_obese extreme_obese higrowth lowgrowth cure_diabe cure_cancre cure_hibpe  workup_mild workdown_mild workup_ext workdown_ext"
global yrs 2030 2050 

global scnr status_quo2004
foreach s in $scnr_base {
	foreach y in $yrs {
			global scnr $scnr `s'`y'
	}
}

* Characteristics to get prevalences for
global vars overwt obese smokev smoken cancre diabe hearte hibpe lunge stroke
global nvars = wordcount("$vars")


set trace off

local i = 0
foreach x in $scnr {
	local i = `i' + 1
}
matrix matr = J(`i',$nvars+1,.)
matrix rownames matr = $scnr
matrix colnames matr = ID $vars

local sorder = 1
foreach scr in $scnr {
	
	matrix matr[rownumb(matr,"`scr'"), colnumb(matr,"ID")] = `sorder'
	local sorder = `sorder' + 1
	
	drop _all
	use "$outdata/`scr'/summary.dta"
	sum year
	keep if year == r(min)
	foreach v in $vars {
		qui sum `v'
		matrix matr[rownumb(matr,"`scr'"), colnumb(matr,"`v'")] =  r(mean)
	}
}

matrix list matr
drop _all
svmat matr, names(col)
sort ID, stable
gen n = _n
local sorder = 1
gen scenario = ""
foreach scr in $scnr {
		replace scenario = "`scr'" if `sorder' == n
		local sorder = `sorder' + 1
	}
drop ID n
	outsheet scenario $vars using "$local_root/analysis/cohort_base_prevalences.csv", replace comma nol
capt log close

	
