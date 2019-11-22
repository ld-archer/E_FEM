/*
Update the Census immigration projection processing to produce the following:

FEM (51+):
age
year-age
year-age-sex

FAM (25+):
age
year-age
year-age-sex
year-age-sex-hispan

through 2100


Possible files to process: 
NP2012_D4 (the medium immigration forecast file)
NP2012C_D4 (the constant immigration forecast file)
NP2012L_D4 (the low immigration forecast file)
NP2012H_D4 (the high immigration forecast file)

NP2017_D4

*/


* Environmental Parameters 
local imm_file : env INFILE
local imm_dir : env OUTDIR
local minage : env AGEMIN
local groups : env CATS

* Figure out the base year from the path
local refyr = substr("`imm_file'",1,4)


quietly include ../../../fem_env.do

insheet using "$census_dir/`imm_file'"

* 2017 changed the name of the race variable
if `refyr' == 2017 {
	rename race_his race_hisp
}

* Create and impute/extrapolate values for 2004-2011
local expand_factor = `refyr' - 2004 + 1

forvalues x = 0/9 {
	forvalues y = 0/2 {
		expand `expand_factor' if race_hisp == `x' & sex == `y' & year == `refyr'
	}
}

bys year sex race_hisp: replace total_nim = . if _n > 1
forvalues z = 0/85 {
	bys year sex race_hisp: replace nim_`z' = . if _n > 1
}	

bys year sex race_hisp: replace year = `refyr' + 1 - _n if year == `refyr'

sort sex race_hisp
by sex race_hisp: ipolate total_nim year, gen(utot) epolate
replace total_nim = utot if total_nim == .

forvalues z = 0/85 {
	by sex race_hisp: ipolate nim_`z' year, gen(u`z') epolate
	replace nim_`z' = u`z' if nim_`z' == .
}

* Expand observations through 2100, keeping immigration values at 2060 level
forvalues x = 0/9 {
	forvalues y = 0/2 {
		expand 41 if race_hisp == `x' & sex == `y' & year == 2060
	}
}
bys year sex race_hisp: replace year = 2101 - _n if year == 2060

sort year sex race_hisp

* Make sure destination directory exists. If not, create it
capture confirm file `local_root'/`imm_dir'
if _rc > 0 {
	! mkdir `local_root'/`imm_dir'
	! mkdir `local_root'/`imm_dir'/tables
}

*** age only : CATS = a ***
if "`groups'" == "a" {
	* Only want immigration for all races 
	keep if race_hisp == 0
	keep if sex == 0
	
	* Reshape to have a file with age, male, net immigration
	reshape long nim_, i(year) j(age)

	keep if year == `refyr'
	keep age nim_
	rename nim_ net_migration

	keep if age >= `minage'
	sort age
	local j = _N

	file open myfile using `local_root'/`imm_dir'/tables/immigration.txt, write text replace
	#delimit ; 
	file write myfile 
	"|Source: Census projections from `imm_file' for ages over `minage' based on `refyr'" _n
	"age" _n;
	forval i=1/`j' {;
		file write myfile
		(age[`i']) _tab (net_migration[`i']) _n;
	};
	#delimit cr
	file close myfile	
}


*** year - age  : CATS = ya *** 
if "`groups'" == "ya" {
	* Only want immigration for all races 
	keep if race_hisp == 0
	keep if sex == 0

	* Reshape to have a file with age, male, net immigration
	reshape long nim_, i(year) j(age)

	keep year age nim_
	rename nim_ net_migration

	keep if age >= `minage'
	sort year age
	local j = _N

	file open myfile using `local_root'/`imm_dir'/tables/immigration.txt, write text replace
	#delimit ; 
	file write myfile 
	"|Source: Census projections from `imm_file' for ages over `minage'" _n
	"year" _tab "age" _n;
	forval i=1/`j' {;
		file write myfile
		(year[`i']) _tab (age[`i']) _tab (net_migration[`i']) _n;
	};
	#delimit cr
	file close myfile	
}



*** year - age - sex : CATS = ysa ***
if "`groups'" == "ysa" {
	* Only want immigration for all races and then by male and female
	keep if race_hisp == 0
	keep if sex == 1 | sex == 2
	gen male = (sex == 1)

	* Reshape to have a file with age, male, net immigration
	reshape long nim_, i(year male) j(age)

	keep year male age nim_
	rename nim_ net_migration

	keep if age >= `minage'
	sort year male age
	local j = _N

	file open myfile using `local_root'/`imm_dir'/tables/immigration.txt, write text replace
	#delimit ; 
	file write myfile 
	"|Source: Census projections from `imm_file' for ages over `minage'" _n
	"year" _tab "age" _tab "male" _n;
	forval i=1/`j' {;
		file write myfile
		(year[`i']) _tab (age[`i']) _tab (male[`i']) _tab (net_migration[`i']) _n;
	};
	#delimit cr
	file close myfile	
}


*** year - age - sex - hispan : CATS = ysah ***
if "`groups'" == "ysah" {
	* Want immigration for hispanic, non-hispanic black, and all other non-hispanics and then by male and female
	keep if race_hisp == 7 | race_hisp == 8
	keep if sex == 1 | sex == 2
	gen hispan = (race_hisp == 8)
	gen male = (sex == 1)
	

	* Reshape to have a file with age, male, hispan, net immigration
	reshape long nim_, i(year male hispan) j(age)

	keep year male hispan age nim_
	rename nim_ net_migration

	keep if age >= `minage'
	sort year male hispan age
	local j = _N

	file open myfile using `local_root'/`imm_dir'/tables/immigration.txt, write text replace
	#delimit ; 
	file write myfile 
	"|Source: Census projections from `imm_file' for ages over `minage'" _n
	"year" _tab "age" _tab "male" _tab "hispan" _n;
	forval i=1/`j' {;
		file write myfile
		(year[`i']) _tab (age[`i']) _tab (male[`i']) _tab (hispan[`i']) _tab (net_migration[`i']) _n;
	};
	#delimit cr
	file close myfile	
}







capture log close


