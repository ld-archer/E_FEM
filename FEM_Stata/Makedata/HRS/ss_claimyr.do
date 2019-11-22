/* Use SSA benefits history to figure out claiming year for SS benefits

2. What is dual entitlement and how do I find them?
Some workers, especially currently/formerly married women, are entitled to both a worker (primary) benefit 
based on her own covered earnings record and a higher secondary benefit, generally based on her (former) 
husband's earnings record. For them, the program pays the primary benefit in full, but the secondary benefit 
is paid only in the amount by which it exceeds the primary benefit. A value of other than spaces in the Type 
of Dual Entitlement (TOD-1) code in the first part of the record identifies that dual entitlement existed at 
the time that the data was extracted. Information regarding this dual entitlement period can be obtained from 
the variables OTBIC-1, OTDOE-1, OTPIA-1, LFMBA-1, OTRIA-1, LEMBA-1, SFMBA-1, SAMBA-1, DESC-1, and OTOC-1. 
Historical data for the other benefit is in the second part of the record.

*/

quietly include common.do

use $hrs_restrict/ben1A_R.dta
rename *, lower  

gen hhidpn = hhid+pn
destring hhidpn, replace
drop hhid
drop pn

* Date claim filed (primary - own amount, other/secondary - spouses amount)
gen pri_clm_yr = substr(insddcf,-4,.)
gen oth_clm_yr = substr(oinsddcf,-4,.)
destring pri_clm_yr, replace
destring oth_clm_yr, replace


label var pri_clm_yr "Claim year for primary benefit"
label var oth_clm_yr "Claim year for other benefit"

keep hhidpn pri_clm_yr oth_clm_yr


merge 1:m hhidpn using $outdata/hrs_analytic_recoded.dta
save $dua_rand_hrs/ss_claimyr.dta, replace




/*

* If we need to look at benefits by month, this is the file to use ...

use $hrs_restrict/ben1C_R.dta

renvars, lower

gen hhidpn = hhid+pn
destring hhidpn, replace
drop hhid
drop pn


local n = 1
foreach m in 01 02 03 04 05 06 07 08 09  {
	rename mba`m' mba`n'
	rename omba`m' omba`n'
	local n = `n' + 1
}

reshape long mba omba, j(month) i(hhidpn year)
*/











capture log close
