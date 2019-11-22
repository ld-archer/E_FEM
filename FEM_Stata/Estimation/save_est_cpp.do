/** \file save_est_cpp.do This script loads binary estimation objects from Stata and spits them out in plain text form.

This version of the file relies on two environment variables to determine input and output directories at runtime, so we don't need
to have multiple versions running around.

datain - directory to read all the *.ster files from
dataout - directory to write all the *.est files to

Usage would be something like the following:
datain=../Estimates dataout=../../FEM_CPP_settings/models stata-mp -b do save_est_cpp.do

*/

* Setup some environmental settings
set more off

* Clear anything thats already in memory
clear all

* Assume that this script is being executed in the FEM_Stata/Estimation directory

* Load environment variables from the root FEM directory, two levels up
* these define important paths, specific to the user
adopath ++ ../utilities

local ster : env datain
local est_out_dir : env dataout

noi di "Loading estimates from [`ster']"
	* Loads all estimates
	local all_ests :dir "`ster'" files "*.ster"
	
	foreach est in `all_ests' {
		noi di "Loading estimate: `est'"
		est use "`ster'/`est'"
		
		local test =strpos("`est'","_cond")
		if "`test'"=="0" {
			est use "`ster'/`est'"
			local est_name = substr("`est'",1,length("`est'")-5)
			est store `est_name'
			local cmd = e(cmd)
			local depvar = e(depvar)
			save_eststore_txt `est_name'  using "`est_out_dir'/`est_name'.est" , model_name(`est_name') model_type(`cmd') predicted_var(`depvar')
		}
		else {
			est use "`ster'/`est'"
			local est_name = substr("`est'",1,length("`est'")-5)
			local est_namef = substr("`est_name'",1,strpos("`est_name'","_cond")-1)
			if regexm("`condlist'","`est_namef'")==0 {
				capture rm `est_out_dir'/`est_namef'.txt
				local condlist = "`condlist' `est_namef'"
			}
			est store `est_name'
			local cmd = e(cmd)
			local depvar = e(depvar)
			save_eststore_txt `est_name'  using "`est_out_dir'/`est_name'.est" , model_name(`est_name') model_type(`cmd') predicted_var(`depvar')			
*			save_eststore_txt `est_name'  using "`est_out_dir'/`est_name'_.est" , model_name(`est_name') model_type(`cmd') predicted_var(`depvar')
*			! sed 's/`est_namef'/`est_name'/g' < `est_out_dir'/`est_name'_.est > `est_out_dir'/`est_name'.est
*			rm  `est_out_dir'/`est_name'_.est
			! echo `est_name' >>  `est_out_dir'/`est_namef'.txt
			! cat `ster'/`est_name'.txt >> `est_out_dir'/`est_namef'.txt
		}
	}
		
