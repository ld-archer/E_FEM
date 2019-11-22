cap program drop new_deviation
program define new_deviation

	version 9.0
	syntax [varlist] [if][in], vname(string) vtype(string) cyr(integer) data(string)
	marksample touse
	tempvar newcut newcut2 newcut3 newcut4 newcut5 newbeta prob
	
	if "`vtype'" == "b" {
		* Proportion of the baseyear
		local r = hlthtrend[rownumb(hlthtrend,"yr`cyr'"), colnumb(hlthtrend, "p`vname'")]
		* dis "******** deviation for `vname' is: `r'"
		
		* If proportion is close to 1, then no change
		cap drop `vname'_delta
		if  `r' == 1 {
			gen `vname'_delta = 0
		}
		else{
			gen `vname'_delta = invnorm(min(`r'*normal(`vname'_xb), 0.99999999)) - `vname'_xb
		}
	}
	
	* If ordered, then take the highest category
	else if "`vtype'" == "o"{
		if "`vname'" == "educlvl" {
			local c = 4
		}
		if "`vname'" == "rdb_na_c" {
			local c = 4
		}
		if "`vname'" == "wtstate" & "`data'" == "hrs" {
			local c = 5
		}
		if "`vname'" == "wtstate" & "`data'" == "psid" {
			local c = 5
		}
		if "`vname'" == "numbiokids" {
			local c = 5
		}
		else{
			local c = 3
		}	
		local ovar = "`x'_cat"
		local v = word("$`ovar'", `c') 
		
		local r = hlthtrend[rownumb(hlthtrend,"yr`cyr'"), colnumb(hlthtrend, "p`vname'`c'")]
		if "`vname'" == "wtstate"{
			local r = 1
		}
		if "`vname'" == "smkstat"{
			local r = 1
		}
		if "`vname'" == "educlvl"{
			local r = 1
		}
		if "`vname'" == "numbiokids"{
			local r = 1
		}
		* dis "******** deviation for the highest category of `vname' is: `r'"
		if `r' == 1 {
			gen `vname'_delta = 0
		}
		else {
			local k = `c' - 1
			gen `vname'_delta = `vname'_cut`k' + invnorm(min(`r' * normal(`vname'_xb -`vname'_cut`k'),0.99999999)) - `vname'_xb 
		}
	}
	
	* If continuous outcome (truncated or not)
	else if "`vtype'"  == "c"  {
		local r = hlthtrend[rownumb(hlthtrend,"yr`cyr'"), colnumb(hlthtrend, "p`vname'")]
		if  `r' == 1 {
			gen `vname'_delta = 0
		}	
		else {
			* Cholesky decomposition
			local L11 = L_`vname'[1,1]
			qui gen `vname'_delta = ((`r' - 1) * `vname'_xb)/`L11'
		}		
	}

end
