clear
capture log close
log using wealth_ahg.log, replace

set more off
set mem 100m

use hatota black hispan male hsless college widowed using \\homer\homer_c\Retire\ahg\age5055_hrs1992r_v9.dta , clear
ghreg hatota black hispan male hsless college widowed

noi disp e(theta)
noi disp e(omega)

predict yhat3, simu


**Compare simulated and actual.**
sum yhat3 hatota, detail

label var yhat3 "Simulated Wealth"
label var hatota "Wealth"

twoway (kdensity yhat3 if yhat3<500) (kdensity hatota if hatota<500), ti("Comparison of Simulated and Actual Wealth") legend(on order(1 "Simulated Wealth" 2 "Wealth"))
graph export simu_wealth.png, as(png) replace


keep hatota yhat3

gen id = _n

rename hatota w1
rename yhat3 w2
reshape long w, i(id) j(source)

ksmirnov w, by(source)

log close

capt log close


 

