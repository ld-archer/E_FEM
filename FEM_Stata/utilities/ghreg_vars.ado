
program define ghreg_vars, eclass 
	syntax [anything], vars(str)
	ereturn local vars "`vars'"
end

