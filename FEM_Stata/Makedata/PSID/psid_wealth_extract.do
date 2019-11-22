include common.do


/*
PSID IMPUTED WEALTH COMPONENTS, NOT AVAILABLE IN MAIN FAMILY FILE BEFORE 2009, LOCATED IN "SUPPLEMENTAL" DATA ON PSID WEBSITE
*/
 

local m 4
forvalues i = 1999(2)2007 {
	use "$psid_dir/Stata/wlth`i'.dta", clear
	ren S`m'01 famfid
	ren S`m'16 hdwlthnoeq
	ren S`m'16A hdwlthnoeqf
	ren S`m'17 hdwlthwteq
	ren S`m'17A hdwlthwteqf
	local m = `m' + 1
	cap drop year
	gen year = `i'
	drop S*
	saveold "$temp_dir/wlth`i'_rcd",replace
	des
}


