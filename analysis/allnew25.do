quietly include ../fem_env.do

forvalues i = 2009 (2) 2069 {
	append using $outdata/new25_`i'_default.dta
}

gen id = mod(-hhidpn,1000)
rename hhidpn hhidpn_yr
rename id hhidpn
sort hhidpn year

label var hhidpn_yr "Year specific id for new25 simulants"
label var hhidpn "Non-year specific id for new25 simulants"

save $outdata/allnew25.dta, replace
















capture log close
