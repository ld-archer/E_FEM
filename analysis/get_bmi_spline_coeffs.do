

local ndefs 7
local depvars hearte stroke cancre hibpe diabe lunge logbmi smkstat funcstat
local wtcats1 lnormwt loverwt lobese_1 lobese_2 lobese_3 fnormwt foverwt fobese_1 fobese_2 fobese_3
local wtcats2 lnormwt loverwt lobese_1 lobese_2 fnormwt foverwt fobese_1 fobese_2
local wtcats3 llogbmi_l30 llogbmi_30p flogbmi
local wtcats4 llogbmi flogbmi
local wtcats5 lbmi_l30 lbmi_30p fbmi_l30 fbmi_30p
local wtcats6 lbmi_l30 lbmi_30p fbmi
local wtcats7 lbmi fbmi

local path "\\zeno\zeno_a\vaynman\FEM\current\FEM_Stata\Estimates"

forvalues d = 1/`ndefs' {
	matrix splines`d' = J(wordcount("`depvars'")*2, wordcount("`wtcats`d''"), .)

	local rownames 
	foreach v in `depvars' {
		local rownames  `rownames' `v'_b `v'_sd
	}

	matrix rownames splines`d' = `rownames'

	local colnames 

	foreach c in `wtcats`d'' {
		local colnames  `colnames' `c'
	}

	matrix colnames splines`d' = `colnames'

	foreach v in `depvars' {
		est use "`path'\bmi_spline`d'\\`v'.ster"
		matrix b = e(b)
		matrix v = e(V)
		foreach c in `wtcats`d'' {
			matrix splines`d'[rownumb(splines`d', "`v'_b"), colnumb(splines`d', "`c'")] = b[1, colnumb(b, "`c'")]
			
			matrix splines`d'[rownumb(splines`d', "`v'_sd"), colnumb(splines`d', "`c'")] = sqrt( v[rownumb(v, "`c'"), colnumb(v, "`c'")])
		}
	}
	
}


/*
			
*/			
