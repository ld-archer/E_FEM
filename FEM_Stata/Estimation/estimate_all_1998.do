
clear
cap clear mata
set mem 500m
set more off
set seed 52432
*set maxvar 10000
est drop _all

/*********************************************************************/
*	SEP UP DIRECTORIES
/*********************************************************************/

* Assume that this script is being executed in the FEM_Stata/Estimation directory

* Load environment variables from the root FEM directory, three levels up
* these define important paths, specific to the user
include "../../fem_env.do"

* Define paths
global workdir  			"$local_path/Estimation"

cd "$workdir"
do qaly_estimations.do

cd "$workdir"
*do init_transition.do
* For validation
do init_transition_1998.do

cd "$workdir"
do MedicarePartD.do

cd "$workdir"
do InitMedicarePartBEnrollment.do

cd "$workdir"
do MedicarePartBEnrollment.do


cd "$workdir"
do estimate_medcosts_mcbs.do

cd "$workdir"
do estimate_medcosts_meps.do

exit, clear STATA
