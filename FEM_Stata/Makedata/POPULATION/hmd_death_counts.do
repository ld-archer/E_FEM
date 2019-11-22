/******************************************************************************
	Script to create death count datasets for the FEM
	based on Human Mortality Database
	
	This script should be run stand alone and not as part of a larger 
	batch program. 
	
	Changes:
	03/13/2014 - File Created by BBlaylock
*/

clear
set more off

include ../../../fem_env.do

* Change this to the appropriate input directory and file
local death_count_file "Deaths_1x1.txt"

infile using $indata/hmd_death_count.dct, using($hmd_dir/Deaths_1x1.txt)

drop total

gen age_old = age if age~="110+"
replace age_old = "110" if age=="110+"
gen nage = real(age_old)
drop age age_old
ren nage age

ren female count_female
ren male count_male

reshape long count_, i(year age) j(group) string

rename count_ count

gen male = (group=="male")
drop group

save $outdata/death_counts.dta, replace


