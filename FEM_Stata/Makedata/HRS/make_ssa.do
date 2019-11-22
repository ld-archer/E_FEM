/** \file

\bug This file will not run as-is
*/

* how to do 92, we should put 98 and 04 *

use "rdata\earn92.dta", clear

keep hhidpn a21058-a21098 v21017-v21057 v21099a
order hhidpn v21099a a21058-a21098 v21017-v21057 

foreach num of numlist 51/91 {
local num1 = `num'+7
rename a210`num1' rw19`num'
}

foreach num of numlist 51/91 {
local num1 = `num'-34
rename v210`num1' rq19`num'
}

rename v21099a wgid92

save "rdata\earn92_clean.dta", replace
