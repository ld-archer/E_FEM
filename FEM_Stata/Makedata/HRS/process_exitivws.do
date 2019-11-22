** This file is used to process the HRS exit interview data for year 2010. 
** We will introduce the response for Alzheimer's Disease from the exit interview to those who died in wave 10


include common.do

* Use the RAND 2010 ExitIvws file
use $hrsexit/X10C_R.dta

* Create hhidpn
gen hhidpn = HHID + PN
destring hhidpn, replace

* Create year
gen wave = 10

* Recode the diagnosis of memory-related problem variable and create the AD variable

recode WC209M1M (1=1) (2 3 6 7 = 0 ) (8 = .)

gen alzhe_ex = WC209M1M

keep hhidpn wave alzhe_ex

* Save the data
save $outdata/exit_alzhe2010.dta, replace

