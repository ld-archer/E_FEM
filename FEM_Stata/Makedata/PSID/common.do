clear
clear mata
clear matrix
set more off
set mem 800m
set seed 5243212
set maxvar 20000
set trace off

* Assume that this script is being executed in the FEM_Stata/Makedata/HRS directory

* Load environment variables from the root FEM directory, three levels up
* these define important paths, specific to the user
include "../../../fem_env.do"

global wkdir $local_path/Makedata/PSID
adopath++ "$wkdir"

*Store intermediate files
cap mkdir "$wkdir/Output"
global temp_dir "$wkdir/Output"
