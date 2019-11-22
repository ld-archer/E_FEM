*****SSI suggested by Erik ******
/*
1) change interview date in HRS file to match date format in administrative file 
2) should get interview date from public HRS file, and compare interview date with record establishment date(RESTDAT) 
and CRELGDAT  DATE OF CURRENT ELIGIBILITY (CRELGDAT)
3) Since permission is for use of adm data prior to 2004, we don't have data in 2004, so compare "2002HRS data with 2002 administrative data" */
4) r_issi_ssa: ssi recipient at interview month
5) r_ssi_ssa: ssi amount recieved in 2002
*/

use "hrs02.dta", clear
*** end of interview date ***
gen iwe_year=year(riwend)
gen iwe_mon=month(riwend)
gen iwe_day=day(riwend)
gen iwe_ymd = iwe_year*10000 + iwe_mon*100 + iwe_day
gen iwe_ym = iwe_year*100 + iwe_mon
tostring iwe_ymd, replace
tostring iwe_ym, replace
gen iwe_ymd6=iwe_ymd if time==6
gen iwe_ym6=iwe_ym if time==6
keep if time==6
keep hhidpn iwe_ymd6 iwe_ym6 iwe_year iwe_mon
sort hhidpn
save "iwym.dta", replace

use SSI2004.dta, clear
destring HHIDPN, gen(hhidpn)
sort hhidpn 
merge hhidpn using "iwym.dta", nokeep
drop _merge
keep if DSPFLAG==0
**RESTDAT:RECORD ESTABLISHMENT DATE
**use the latest info before interview date
keep if RESTDAT<="iwe_ymd6" & CRELGDAT <="iwe_ymd6"
sort HHIDPN RESTDAT
by HHIDPN, sort: gen REC02=_n
by HHIDPN, sort: egen LAST_REC = max(REC) 
keep if REC02==LAST_REC

/* compare eligibility at interview month and PSTA0201~PSTA0212 */
gen r_issi_ssa=0
foreach num of numlist 1/9{
replace r_issi_ssa=1 if PSTA020`num'=="01"&iwe_mon==`num'
}
foreach num of numlist 10/12{
replace r_issi_ssa=1 if PSTA02`num'=="01"&iwe_mon==`num'
}
gen r_ssi_ssa=FEDP0201+FEDP0202+FEDP0203+FEDP0204+FEDP0205+FEDP0206+FEDP0207+FEDP0208+FEDP0209+FEDP0210+FEDP0211+FEDP0212
keep hhidpn r_issi_ssa r_ssi_ssa
sort hhidpn
save ssi_e.dta, replace
