local path T:\vaynman\FEM\current\output

local vars spline year end_pop end_pop65p obese obese_1 obese_2 obese_3 death_rate cancre diabe iadl1 adl12 adl3 hearte hibpe lunge smoken stroke

forvalues i = 0/4 {
	use `path'\bmi_spline`i'\summary, clear
	gen spline = `i'
	foreach yr in 2030 2050 2080 {
		mkmat `vars' if year == `yr', mat(results`yr')
	}

	matrix results`i' = results2030 \ results2050 \ results2080
}
matrix results = results0
forvalues i = 1/4 {
	matrix results = results \ results`i'
}