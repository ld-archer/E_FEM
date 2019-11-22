global dir "T:\vaynman\FEM\current\input_data"
global scens "status_quo smk_ext smk_iom"
global vars "overwt obese_1 obese_2 obese_3 smokev smoken"
global start_yr 2004
global end_yr 2030


tempfile f
global first 1
qui {
forvalues yr = $start_yr(2)$end_yr {
	foreach s in $scens {
	noi di "`s' `yr' ..."
	use "$dir\new51_`yr'_`s'", clear
	collapse $vars [aw=weight]
	gen scen = "`s'"
	gen year = `yr'
	tempfile f2
	save `f2'
	if $first == 1 {
		global first 0
		save `f'
	} 
	else {
		use `f', clear
		append using `f2'	
		save `f', replace
	}
	}
}
}
use `f', clear
	
