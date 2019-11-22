clear
clear mata
clear matrix
set more off
set mem 800m
set seed 5243212
set maxvar 20000
set trace off

quietly include "../fem_env.do"

use $psid_dir/Stata/mh85_09.dta, clear

gen hhidpn = MH1*1000+MH2
* codebook hhidpn

label var MH8 "Order of this marriage"
label var MH10 "Year married"
label var MH11 "Status of this marriage"
label var MH13 "Year widowed or divorced"
label var MH15 "Year separated"
label var MH17 "Number of marriages for this individual"
label var MH18 "Last known marital status"

rename MH8 marriage_order
rename MH10 marry_yr
rename MH11 marriage_status
rename MH13 end_yr
rename MH15 separation_yr
rename MH17 marriage_cnt
rename MH18 last_known_status

save $outdata/marriage_history.dta, replace


* Create a file that has the id and the number of marriages
collapse (mean) marriage_cnt, by(hhidpn)
save $outdata/indiv_marriage_cnt.dta, replace



* Use the transition file
use $outdata/psid_transition.dta, clear

* Merge on the marriage count variable
merge m:1 hhidpn using $outdata/indiv_marriage_cnt.dta, keep(master match)

count if lmarried == 0 & married == 1
tab marriage_cnt


tabstat age if lmarried == 0 & married == 1, stat(N mean median min max) 

* Males
hist age if lmarried == 0 & married == 1 & male == 1, xscale(range(20 70))
graph export marry_age_M.eps, replace
hist age if lmarried == 0 & married == 1 & marriage_cnt == 1 & male == 1, xscale(range(20 70))
graph export first_marry_age_M.eps, replace

* Females
hist age if lmarried == 0 & married == 1  & male == 0, xscale(range(20 70))
graph export marry_age_F.eps, replace
hist age if lmarried == 0 & married == 1 & marriage_cnt == 1 & male == 0, xscale(range(20 70))
graph export first_marry_age_F.eps, replace




* Any trend in marriage age?
bys year: tabstat age if lmarried == 0 & married == 1 [aw=weight], stat(N mean median min max) 

* By gender
bys year male: tabstat age if lmarried == 0 & married == 1 [aw=weight], stat(N mean median min max) 

* By gender and race variables
bys male: tabstat age if lmarried == 0 & married == 1 & white == 1 [aw=weight], stat(N mean median min max) 
bys male: tabstat age if lmarried == 0 & married == 1 & black == 1 [aw=weight], stat(N mean median min max)
bys male: tabstat age if lmarried == 0 & married == 1 & hispan == 1 [aw=weight], stat(N mean median min max)

* By gender and education
bys male: tabstat age if lmarried == 0 & married == 1 & hsless ==1 [aw=weight], stat(N mean median min max)
bys male: tabstat age if lmarried == 0 & married == 1 & college == 0 & hsless == 0 [aw=weight], stat(N mean median min max)
bys male: tabstat age if lmarried == 0 & married == 1 & college == 1 [aw=weight], stat(N mean median min max)



/*** First marriages ***/
* Pooled years
tabstat age if lmarried == 0 & married == 1 & marriage_cnt == 1 [aw=weight], stat(N mean median min max) 

* By year
bys year: tabstat age if lmarried == 0 & married == 1 & marriage_cnt == 1 [aw=weight], stat(N mean median min max) 

* By year/gender
bys year male: tabstat age if lmarried == 0 & married == 1 & marriage_cnt == 1 [aw=weight], stat(N mean median min max) 

* Pooled years, by race variables
bys male: tabstat age if lmarried == 0 & married == 1 & white == 1 & marriage_cnt == 1 [aw=weight], stat(N mean median min max) 
bys male: tabstat age if lmarried == 0 & married == 1 & black == 1 & marriage_cnt == 1 [aw=weight], stat(N mean median min max)
bys male: tabstat age if lmarried == 0 & married == 1 & hispan == 1 & marriage_cnt == 1 [aw=weight], stat(N mean median min max)

* Pooled years, by education
bys male: tabstat age if lmarried == 0 & married == 1 & hsless ==1 & marriage_cnt == 1 [aw=weight], stat(N mean median min max)
bys male: tabstat age if lmarried == 0 & married == 1 & college == 0 & hsless == 0 & marriage_cnt == 1 [aw=weight], stat(N mean median min max)
bys male: tabstat age if lmarried == 0 & married == 1 & college == 1 & marriage_cnt == 1 [aw=weight], stat(N mean median min max)


* tabout male white if lmarried == 0 & married == 1 & hsless ==1 & marriage_cnt == 1 using tabouttest.xls, cells(mean age median age) replace sum oneway

* In fair/poor health
* Getting Married
bys male: tabstat shlt if lmarried == 0 & married == 1 [aw=weight], stat(N mean median min max)
* Remaining single
bys male: tabstat shlt if lmarried == 0 & married == 0 [aw=weight], stat(N mean median min max)

* Earnings

* Getting Married
bys male: tabstat iearn if lmarried == 0 & married == 1 [aw=weight], stat(N mean median min max)
* Remaining Single
bys male: tabstat iearn if lmarried == 0 & married == 0 [aw=weight], stat(N mean median min max)

* Working
* Getting Married
bys male: tabstat work if lmarried == 0 & married == 1 [aw=weight], stat(N mean median min max)
* Remaining Single
bys male: tabstat work if lmarried == 0 & married == 0 [aw=weight], stat(N mean median min max)

capture log close
