/** \dir Makedata/SSA This directory holds all the code used in processing the Social Security-related files. */


clear
clear mata
set more off
set mem 800m
set seed 5243212
set maxvar 10000

* Assume that this script is being executed in the FEM_Stata/Makedata/SSA directory

* Load environment variables from the root FEM directory, three levels up
* these define important paths, specific to the user
include "../../../fem_env.do"
