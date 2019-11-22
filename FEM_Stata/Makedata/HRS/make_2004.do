/** \file

Make stata file of 2004 summary earnings

Original file is: \\homer\c\Retire\SSA\UPD_OCT2007\SumErn\data\ERN1.da

\bug This file will not run as-is
*/
clear
set more off

cd "\\Homer\homer_c\Retire\yuhui"
infile using codes\ERN1_2004.dct 

* Lower cases
renvars, lower
cap confirm numeric variable hhidpn
if _rc{
	destring hhidpn, replace
}

saveold rdata\ern04.dta, replace

* Recode earnings -1 to 50, replace missing with zero
forvalues i = 1951/2003 {
	recode ern`i' (-1 = 50)(missing = 0), gen(rw`i')
	label var rw`i' "earnings for year `i' (-1/50)(./0)"
}

* Total quarters of coverage
gen rq = 0
forvalues i = 1951/2003{
	replace rq = rq + n`i't if inrange(n`i't,0,4)
}

keep hhidpn rq rw*
saveold rdata\ssa_04.dta,replace
exit

