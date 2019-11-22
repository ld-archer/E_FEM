include "../../fem_env.do"


* Need first wave to have initial weight ... ugh
use $outdata/hrs_selected.dta, replace

xtset hhidpn wave
sort hhidpn wave, stable


bys hhidpn: gen inwave = wave if iwstat == 1
bys hhidpn: egen firstobs = min(inwave)

by hhidpn: egen first_wave_with_weight = min(cond(weight > 0 & weight < ., wave, .))

gen firstweight = weight if first_wave_with_weight == wave
by hhidpn: egen entry_weight = max(firstweight)

by hhidpn: egen entry_age = min(cond(weight > 0 & weight < ., age, .))

by hhidpn: egen oldest_age = max(age)


keep if wave >= first_wave_with_weight
keep if !missing(died)

* One observation per hhidpn
collapse (max) rbyr entry_weight male died entry_age oldest_age black hispan, by(hhidpn)

/* The following code estimates a Weibull proportional hazard model for mortality that can be used for testing */
stset oldest_age if entry_age > 50 [pw=entry_weight] , id(hhidpn) failure(died) origin(time 50) enter(time entry_age )
streg male black hispan, d(weibull)

file open died using ../../FEM_CPP_settings/survival/models/died.est, write replace
file write died "WeibullPHSurvival" _n
file write died "died" _n
file close died
estout using ../../FEM_CPP_settings/survival/models/died.est, collabels(,none) mlabels(,none) eqlabels(,none) append
file open died using ../../FEM_CPP_settings/survival/models/died.est, write append
file write died "| survival settings" _n
* this should be the lagged version of the time variable used for estimation:
file write died "time_variable lage" _n
file write died "origin `_dta[st_o]'"
file close died

capture log close
