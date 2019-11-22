cap program drop calc_cut_point
program define calc_cut_point

	version 10.0

	syntax varlist(min=1 max=2 numeric) [if] [in], prob(real) prev_cut(real)
	marksample touse
	tempvar x
	cap drop _mu
	gen _mu = `varlist'

	gen `x' = normal(`prev_cut' - _mu)
	sum `x' [aw=weight], meanonly
	
	scalar target = `prob' + r(mean)
	
	ml model d0 calc_cut_point_ml / cut, technique(nr) 
	ml search
	ml maximize , iter(20) novce 
	cap drop _mu
end
