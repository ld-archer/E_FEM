/** \file

\todo Figure out what this file is for

\bug This file will not run as-is
*/
foreach f in status_quo multi_r obese_r shareprev {
use "\\Zeno\zeno_a\zyuhui\DOL\Input\new51_2050_`f'.dta", clear
keep hhidpn *cancre *stroke *lunge
foreach v of valist * {
	if "`v'" != "hhidpn" {
		ren `v' `v'_`f'
	}
}
sort hhidpn , stable

save tmp_`f'.dta, replace
}
drop _all
use tmp_status_quo.dta
merge hhidpn using tmp_multi_r.dta tmp_obese_r.dta tmp_shareprev.dta


