
clear
clear mata
set mem 500m
set more off
set seed 52432
*set maxvar 10000
est drop _all
capt log close

log using est_growth_aug19.log, replace

*==========================================================================*
* Estimate New Cohorts - Wealth, DC Wealth, Income
* Jun 23, 2008: For wealth, use generalized inverse hyperbolic sine  transformation
* =========================================================================*

global workdir "\\zeno\zeno_a\ahg\fem\Estimation_2\new_cohorts"
global indata1  "\\homer\homer_c\Retire\ahg\rdata2\age5055_hrs1992r.dta"
global indata2  "\\homer\homer_c\Retire\ahg\rdata2\age5055_hrs2004r.dta"
global outdata "\\zeno\zeno_a\ahg\fem\Input"
global outdir "\\zeno\zeno_a\ahg\fem\Input\new_cohort"
global netdir  "\\homer\homer_c\Retire\ahg\rdata2"

clear
use $indata1
summ hatota, d
local m = r(mean)

clear
use $indata2
summ hatota, d

disp r(mean)/`m'

log close

capt log close
