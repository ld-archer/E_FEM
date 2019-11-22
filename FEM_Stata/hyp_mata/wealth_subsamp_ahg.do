clear
capture log close
log using wealth_subsamp_ahg.log, replace

set more off
set mem 100m

use hatota black hispan male hsless college widowed using \\homer\homer_c\Retire\ahg\age5055_hrs1992r_v9.dta , clear
drop if hatota > 500 | hatota < -100
ghreg_ahg2 hatota black hispan male hsless college widowed


predict yhat3, simu


**Compare simulated and actual.**
summ hatota, d
drop if yhat3 >= r(p99)

sum yhat3 hatota, detail

twoway (kdensity yhat3 if yhat3<500) (kdensity hatota if hatota<500), ti("Comparison of Simulated and Actual Wealth")
graph export simu_subsamp_wealth.png, as(png) replace


keep hatota yhat3



gen id = _n

rename hatota w1
rename yhat3 w2
reshape long w, i(id) j(source)

ksmirnov w, by(source)

log close

capt log close


 

