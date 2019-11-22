cap program drop calc_cut_point_ml
program define calc_cut_point_ml
	args todo b lnf 
	tempvar y
	local cut = `b'[1,1]

	gen `y' = normal(`cut'-_mu)
  sum `y' [aw=weight], meanonly
  mlsum  `lnf' = -(target - r(mean))^2
end
