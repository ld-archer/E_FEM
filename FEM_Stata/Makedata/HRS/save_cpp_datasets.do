/** \file save_cpp_datasets.do

\deprecated This file does not seem to serve a function any more
*/

global outdata "\\zeno\zeno_a\FEM\FEM_CPP\runtime\new_input_data"
global indata  "\\zeno\zeno_a\FEM\FEM_1.0\Indata_yh"
global scenarios status_quo

use $indata/simul2004_r1, clear
drop x_*
sort hhidpn
save $outdata/simul2004, replace

foreach scen in $scenarios {
	forvalues yr = 2004(2)2050 {
		use $indata/new51_`yr'_`scen'_r1, clear
		drop x_*
		sort hhidpn
		save $outdata/new51_`yr'_`scen', replace
	}
}
