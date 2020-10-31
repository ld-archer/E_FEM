* This script will transform the ukevo2019.xls file into a format that can 
* be used to reweight FEM populations
capture log close

clear all

import excel "/home/luke/Documents/E_FEM_clean/E_FEM/input_data/ukevo2019.xls", sheet("Table 1") cellrange(A5:U62) clear

drop C D E

tempfile male_female
save `male_female'

keep if _n > 21 & _n < 39
drop A

xpose, clear
