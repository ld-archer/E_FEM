/* Process the consumption variables for 1999-2013 (after 2015 they are on the PSID family file) */

quietly include common.do

* Process the files (1999-2013)
local files 99 01 03 05 07 09 11 13
foreach file of local files {
	use $psid_dir/Stata/con`file'.dta, replace

	* drop release number variable
	drop rel`file'
	
	* file is at the family id  level
	rename con`file'_id famnum
	
	if `file' == 99 {
		gen year = 1999
	}
	else {
		gen year = "20`file'"
		destring year, replace
	}
	
	#d ;
	local convars food fdhm fdout fddel hous mort rent prptax hmeins util heat electr water outil telint tran vehln vehpay vehls autoin vehadd vehrep
		gas park bus cab otran ed child health hos doctor prescr hins hhrep furn cloth trips othrec;
	#d cr
	
	foreach convar of local convars {
		capture confirm variable `convar'`file'
		if _rc > 0 {
			di "`convar'`file' does not exist"
		}
		if _rc == 0 {
			rename `convar'`file' `convar'
		}
	}	

	
	tempfile `file'
	save ``file''
}

clear

foreach file of local files {
	append using ``file''
}


save $outdata/con9913.dta, replace






capture log close
