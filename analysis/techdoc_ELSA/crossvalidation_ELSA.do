/* 

This script runs the cross-validation for the English Future Elderly Model

Components this script needs to run for cross-validation:

1. Split the original population in 2
	- One half is for estimating transition models
	- Other half is simulated using the transition models produced previously

2. Generate stock population from simulate half
	- reshape_long
	- generate_stock_pop
	
3. Estimate transition models from transitions half

4. Simulate the stock pop using transitions from wave 3 -> 8

*/

quietly include ../../fem_env.do

*use $outdata/H_ELSA_f_2002-2016.dta, clear
*use ../../input_data/H_ELSA_f_2002-2016.dta, clear

* Run script to split the original population in 2
do ID_selection_CV.do
* output saved in /input_data/cross_validation/crossvalidation.dta


