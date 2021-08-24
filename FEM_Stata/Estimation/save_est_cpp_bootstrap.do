/** \file save_est_cpp.do This script loads binary estimation objects from Stata and spits them out in plain text form.

This version of the file relies on two environment variables to determine input and output directories at runtime, so we don't need
to have multiple versions running around.

datain - directory to read all the *.ster files from
dataout - directory to write all the *.est files to

Usage would be something like the following:
datain=../Estimates/models_rep dataout=../../FEM_CPP_settings/models_rep stata-mp -b do save_est_cpp_bootstrap.do
datain=../Estimates dataout=../../FEM_CPP_settings/models_rep stata-mp -b do save_est_cpp_bootstrap.do

*/

* Setup some environmental settings
set more off

* Clear anything thats already in memory
clear all

cap ssc install estout

* Assume that this script is being executed in the FEM_Stata/Estimation directory

* Load environment variables from the root FEM directory, two levels up
* these define important paths, specific to the user
include "../../fem_env.do"

log using "../../FEM_CPP_settings/ELSA_core_bootstrap/save_est_cpp_bootstrap.log", replace

local ster : env datain
local est_out_dir : env dataout
local maxbsamp : env MAXBREP

*di `ster'
di `maxbsamp'

forval i = 1/`maxbsamp' {

di `i'

noi di "Loading estimates from [`ster']"
	* Loads all estimates
		local all_ests :dir "`ster'" files "*.ster"

		di `all_ests'
	
	foreach est in `all_ests' {
		noi di "Loading estimate: `est'"
		est use "`ster'/`est'"
		local est_name = substr("`est'",1,length("`est'")-5)
		est store `est_name'
		local cmd = e(cmd)
		local depvar = e(depvar)
		save_eststore_txt `est_name'  using "`est_out_dir'/models_rep`i'/`est_name'.est" , model_name(`est_name') model_type(`cmd') predicted_var(`depvar')
	}

noi di "Loading estimates from [`ster']/models_rep`i'"
	* Loads all estimates
	local all_ests :dir "`ster'/models_rep`i'" files "*.ster"
	*local all_ests :dir "`ster'" files "*.ster"
	
	foreach est in `all_ests' {
		noi di "Loading estimate: `est'"
		est use "`ster'/models_rep`i'/`est'"
		*est use "`ster'/`est'"
		local est_name = substr("`est'",1,length("`est'")-5)
		est store `est_name'
		local cmd = e(cmd)
		local depvar = e(depvar)
		save_eststore_txt `est_name'  using "`est_out_dir'/models_rep`i'/`est_name'.est" , model_name(`est_name') model_type(`cmd') predicted_var(`depvar')
	}
	
	** explicitly copy admin_ssi.est and isret_wd.est to models_rep folders
	*cp `est_out_dir'/admin_ssi.est `est_out_dir'/models_rep`i'/admin_ssi.est, replace
	*cp `est_out_dir'/isret_wd.est `est_out_dir'/models_rep`i'/isret_wd.est, replace
}
