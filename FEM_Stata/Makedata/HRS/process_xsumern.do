/** \file
This file takes the raw HRS SSA Restricted Data and prepares it for use in gen_aime_all

\bug This is not the original method use to generate these files for the FEM. It does not produce the same results.

*/

* log using process_xsumern.log, replace

include common.do

use "$hrs_restrict/XSumErn.dta"

rename *, lower  
rename ern* rw*
ren totwqc51 rq


* Calculate quarters worked through 1991

foreach x of numlist 1989 1990 1991 1992 1993 1994 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 {
	egen rq_`x' = rowtotal(n1951t-n`x't)
	sum rq_`x'
}

keep source rw* rq* hhid* pn
desc

global years 1992 1993 1998 2004 2006
global suffixes 92 93 98 04 06
local llen = wordcount("$years")

tostring source, replace
destring hhid hhidpn, replace

forvalues y = 1/`llen' {
	preserve
	local curyear = word("$years", `y')
	keep if source=="`curyear'"
	local s = word("$suffixes", `y')
	save "$dua_rand_hrs/ssa_`s'", replace
	restore
}

capture log close
exit, STATA clear
