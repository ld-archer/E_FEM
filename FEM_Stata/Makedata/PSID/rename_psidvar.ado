cap program drop rename_psidvar
program define rename_psidvar

	version 9
	syntax [varlist] [if] [in], rawlist(string) yyyy(int)  naming_yr(int)
	marksample touse
	
	/*

	*"rawlist": name of the global containing names of raw variables by year
	*"yyyy": four digit year
	*"naming_yr": Whether rename variables by year
	*/

	if `naming_yr' == 1 {
		local addname _`yyyy'
	}
	
	local newname = substr("`rawlist'",1,length("`rawlist'")-2)
	local cyr = substr("`yyyy'",3,2)
	
	local yrbrac = "[" + "`cyr'" + "]"
	
	*check each variable in the raw list
	
	local rawvar
	foreach w in ${`rawlist'} {
		local p = strpos("`w'", "`yrbrac'")			
		if `p' > 0 & "`rawvar'" == "" {
			local startpos = `p'
			local rawvar `w'
		}
	}
	
	if "`rawvar'" == "" {
		dis "variable for `newname' doesn't exist in year `yyyy' "
	}
	
	else if "`rawvar'" != "" {
		local oldname = trim(substr("`rawvar'", `startpos'+4,.))
		cap confirm var `oldname'
		if _rc != 0 {
			dis "`rawvar' in `yyyy' - `oldname'"
			
			dis "Old variable name extraction incorrect"
		}
		else {
			ren `oldname' `newname'`addname'
			*dis "`oldname'"
			*dis "`newname'"
		
			**IF THERE IS A JANUARY INDICATOR, NEED TO EXTRACT FEB, MARCH..DEC... TOO
			if substr("`rawlist'",-5,.) == "janin"  {
				local subname = substr("`rawlist'",1,length("`rawlist'")-5)
				local startnum = substr("`oldname'",3,.)
				local k = 0
				foreach m in feb mar apr may jun jul aug sep oct nov dec {
					local k = `k' + 1
					local nextnum = `startnum' + `k'
					local nextnewname = "`subname'" + "`m'"
					local nextoldname = "ER" + "`nextnum'"
					ren `nextoldname' `nextnewname'`addname'
				}
			}
		}
	}

end
