capt log close
log using new_coh_an.log, replace

clear
clear mata
set mem 100m
set more off

**In Sample Simulation*

quietly{
	foreach i in iearn iearnx hatota {
		clear
		use "\\homer\homer_c\Retire\ahg\rdata2\simu_2jul08.dta" if e_`i' == 1
		noi disp ""
		noi disp ""
		noi disp "`i'" 
		noi summ `i', d
		noi summ simu_`i', d
	}
}
log close

capt log close
