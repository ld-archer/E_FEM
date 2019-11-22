/** \file

Make stata file of AHEAD summary earnings.

Original file is: \\Homer\homer_c\Retire\SSA\AHEAD\DATA\ERN1.da

\bug This file will not run as-is
*/
clear
set more off

cd "\\Homer\homer_c\Retire\yuhui"
infile using codes\ERN1_1993.dct 
* Lower cases
renvars, lower
* If ID not numeric
cap confirm numeric variable hhidpn
if _rc{
	destring hhidpn, replace
}
saveold rdata\ern93.dta, replace

* Recode earnings -1 to 50, replace missing with zero
forvalues i = 1951/1992 {
	recode ern`i' (-1 = 50)(missing = 0), gen(rw`i')
	label var rw`i' "earnings for year `i' (-1/50)(./0)"
}

* Total quarters of coverage
gen rq = 0
forvalues i = 1951/1992{
	replace rq = rq + qc`i' if inrange(qc`i',0,4)
}

keep hhidpn rq rw*
saveold rdata\ssa_93.dta,replace
exit
