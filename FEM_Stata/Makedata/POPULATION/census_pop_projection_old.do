* March 2007
clear 
set more off
set mem 400m	
cap log close

	/*
	* Current census projection doesn't have full-span of race/ethnicity category
	RAT = Asian alone
	RBT = Black alone
	ROT = All other races alone and Two or More Races
	RTH = Hispanic origin (of any race)
	RTN = Non-Hispanic origin (of any race)
	RTT = Total resident population
	RWH = White alone, Hispanic
	RWN = White alone, non-Hispanic
	RWT = White alone
	*/
	* No info on non-hispanic black. Using Census 1990 projection, about 5% black are hispanic
	* Non-hispanic black = black * 0.95
	* Non-hispanic non-black = total - hispanic - non-hispanic-black
	* Aug 2004
	*=================================================*
	* Census population projection file
	*=================================================*
	drop _all
	global datadir "C:\Documents and Settings\zheng\My Documents\FEM_INS\Input"

	use "$datadir\usproj2000-2050.dta", clear

	* keep hispanic origin; non-hispanic; total
	* keep if inlist(grp, "RTH", "RWN", "RBT", "RTT" ) & inrange(year,2000,2050)
		keep if inlist(grp, "RTH", "RBT", "RWN", "RTT" ) & inrange(year,2000,2050)
	forvalues i = 0/100{
		ren _`i' age`i'p
	}
	
	* Replace black with "non-hispanic black"
	forvalues i = 0/100{
		qui replace age`i'p = int(age`i'p *0.95) if grp == "RBT"  
	}

	* Get the Hispanic, non-hispanic white, Non-hispanic black, and other	
	gen racegrp = 1 if grp == "RTH"
	replace racegrp = 2 if grp == "RWN"
	replace racegrp = 3 if grp == "RBT"
	replace racegrp = 4 if grp == "RTT"
	drop grp total
	
	reshape wide age*p, i(year sex) j(racegrp)
	
	forvalues i = 0/100{
		qui replace age`i'p4 = max(0,age`i'p4 - age`i'p1 - age`i'p2 - age`i'p3)
	}	
	
	global plist 
	forvalues i = 0/100 {
		global plist $plist age`i'p
	}
	reshape long $plist, i(year sex) j(racegrp)

	forvalues i = 0/100{
		qui ren age`i'p  pop`i'
	}
	
	reshape long pop, i(year sex racegrp) j(age)
	
	gen male =  sex == "M"
	gen black = racegrp == 3
	gen hispan = racegrp == 1
	gen white = racegrp == 2
	
	exit
	
	save "$datadir/population_projection", replace
