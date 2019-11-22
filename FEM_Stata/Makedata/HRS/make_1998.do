/** \file

Make ssa file for 1998 summary earnings.

\bug This file will not run as-is
*/

clear
set more off

cd "\\Homer\homer_c\Retire\yuhui"

use rdata\ern98.dta

* Recode earnings -1 to 50, replace missing with zero
forvalues i = 1951/1997 {
	recode ern`i' (-1 = 50)(missing = 0), gen(rw`i')
	label var rw`i' "earnings for year `i' (-1/50)(./0)"
}

* Total quarters of coverage
gen rq = 0
forvalues i = 1951/1997{
	replace rq = rq + n`i't if inrange(n`i't,0,4)
}

keep hhidpn rq rw*
saveold rdata\ssa_98.dta,replace
exit

