include common.do

* Use the RAND tracker file
use $hrsfat/trk2014tr_r.dta

rename *, lower 


* Create hhidpn
gen hhidpn = hhid + pn
destring hhidpn, replace

* Create r#weightnh variables

* Wave 1-4 don't have nursing home weights
forvalues x = 1/4 {
	gen r`x'weightnh = 0
}

* Waves 5-10 currently have nursing home weights (September 2015)
gen r5weightnh = gwgtrnh
gen r6weightnh = hwgtrnh
gen r7weightnh = jwgtrnh
gen r8weightnh = kwgtrnh
gen r9weightnh = lwgtrnh
gen r10weightnh = mwgtrnh
gen r11weightnh = nwgtrnh

keep hhidpn r*weightnh

* Save the data
save $outdata/nh_weights.dta, replace

