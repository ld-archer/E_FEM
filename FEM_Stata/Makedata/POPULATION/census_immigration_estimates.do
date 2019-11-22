/******************************************************************************
	Script to create immigration estimate datasets for the FEM
	based on Census immigration estimates found here:
	http://www.census.gov/population/intmigration/data/popestprog.html
	
	Changes:
	6/12/2014 - File Created
*/
clear
set memory 100m
set more off

include ../../../fem_env.do

* Change this to the appropriate input directory and file
global immig_est_2013 "2013_Pop_Estimates/NST_EST2013_ALLDATA.csv"
global immig_est_2009 "2009_Pop_Estimates/NST_EST2009_ALLDATA.csv"

** Format data 2010 - 2011 **

insheet using $census_dir/$immig_est_2013, clear

/* Codes in the file 
	Annual Population Estimates, Estimated Components of Resident Population Change, and Rates of the Components of Resident Population Change for the United States, States, and Puerto Rico: April 1, 2010 to July 1, 2013
	File: 7/1/2013 National and State Population Estimates
	Source: U.S. Census Bureau, Population Division
	Release Date: January 2014
	Sort order of observations: States in FIPS code sort
	Data fields (in order of appearance):
		VARIABLE DESCRIPTION .
		SUMLEV Geographic summary level
		REGION Census Region code
		DIVISION Census Division code
		STATE State FIPS code
		NAME State name
		CENSUS2010POP 4/1/2010 resident total Census 2010 population
		ESTIMATESBASE2010 4/1/2010 resident total population estimates base
		POPESTIMATE2010 7/1/2010 resident total population estimate
		POPESTIMATE2011 7/1/2011 resident total population estimate
		POPESTIMATE2012 7/1/2012 resident total population estimate
		POPESTIMATE2013 7/1/2013 resident total population estimate
		NPOPCHG_2010 Numeric change in resident total population 4/1/2010 to 7/1/2010
		NPOPCHG_2011 Numeric change in resident total population 7/1/2010 to 7/1/2011
		NPOPCHG_2012 Numeric change in resident total population 7/1/2011 to 7/1/2012
		NPOPCHG_2013 Numeric change in resident total population 7/1/2012 to 7/1/2013
		BIRTHS2010 Births in period 4/1/2010 to 6/30/2010
		BIRTHS2011 Births in period 7/1/2010 to 6/30/2011
		BIRTHS2012 Births in period 7/1/2011 to 6/30/2012
		BIRTHS2013 Births in period 7/1/2012 to 6/30/2013
		DEATHS2010 Deaths in period 4/1/2010 to 6/30/2010
		DEATHS2011 Deaths in period 7/1/2010 to 6/30/2011
		DEATHS2012 Deaths in period 7/1/2011 to 6/30/2012
		DEATHS2013 Deaths in period 7/1/2012 to 6/30/2013
		NATURALINC2010 Natural increase in period 4/1/2010 to 6/30/2010
		NATURALINC2011 Natural increase in period 7/1/2010 to 6/30/2011
		NATURALINC2012 Natural increase in period 7/1/2011 to 6/30/2012
		NATURALINC2013 Natural increase in period 7/1/2012 to 6/30/2013
		INTERNATIONALMIG2010 Net international migration in period 4/1/2010 to 6/30/2010
		INTERNATIONALMIG2011 Net international migration in period 7/1/2010 to 6/30/2011
		INTERNATIONALMIG2012 Net international migration in period 7/1/2011 to 6/30/2012
		INTERNATIONALMIG2013 Net international migration in period 7/1/2012 to 6/30/2013
		DOMESTICMIG2010 Net domestic migration in period 4/1/2010 to 6/30/2010
		DOMESTICMIG2011 Net domestic migration in period 7/1/2010 to 6/30/2011
		DOMESTICMIG2012 Net domestic migration in period 7/1/2011 to 6/30/2012
		DOMESTICMIG2013 Net domestic migration in period 7/1/2012 to 6/30/2013
		NETMIG2010 Net migration in period 4/1/2010 to 6/30/2010
		NETMIG2011 Net migration in period 7/1/2010 to 6/30/2011
		NETMIG2012 Net migration in period 7/1/2011 to 6/30/2012
		NETMIG2013 Net migration in period 7/1/2012 to 6/30/2013
		RESIDUAL2010 Residual for period 4/1/2010 to 6/30/2010
		RESIDUAL2011 Residual for period 7/1/2010 to 6/30/2011
		RESIDUAL2012 Residual for period 7/1/2011 to 6/30/2012
		RESIDUAL2013 Residual for period 7/1/2012 to 6/30/2013
		RBIRTH2011 Birth rate in period 7/1/2010 to 6/30/2011
		RBIRTH2012 Birth rate in period 7/1/2011 to 6/30/2012
		RBIRTH2013 Birth rate in period 7/1/2012 to 6/30/2013
		RDEATH2011 Death rate in period 7/1/2010 to 6/30/2011
		RDEATH2012 Death rate in period 7/1/2011 to 6/30/2012
		RDEATH2013 Death rate in period 7/1/2012 to 6/30/2013
		RNATURALINC2011 Natural increase rate in period 7/1/2010 to 6/30/2011
		RNATURALINC2012 Natural increase rate in period 7/1/2011 to 6/30/2012
		RNATURALINC2013 Natural increase rate in period 7/1/2012 to 6/30/2013
		RINTERNATIONALMIG2011 Net international migration rate in period 7/1/2010 to 6/30/2011
		RINTERNATIONALMIG2012 Net international migration rate in period 7/1/2011 to 6/30/2012
		RINTERNATIONALMIG2013 Net international migration rate in period 7/1/2012 to 6/30/2013
		RDOMESTICMIG2011 Net domestic migration rate in period 7/1/2010 to 6/30/2011
		RDOMESTICMIG2012 Net domestic migration rate in period 7/1/2011 to 6/30/2012
		RDOMESTICMIG2013 Net domestic migration rate in period 7/1/2012 to 6/30/2013
		RNETMIG2011 Net migration rate in period 7/1/2010 to 6/30/2011
		RNETMIG2012 Net migration rate in period 7/1/2011 to 6/30/2012
		RNETMIG2013 Net migration rate in period 7/1/2012 to 6/30/2013
	X = Not Applicable
	The key for SUMLEV is as follows:
		010 = Nation
		040 = State and/or Statistical Equivalent
	The key for REGION is as follows:
		1 = Northeast
		2 = Midwest
		3 = South
		4 = West
	The key for DIVISION is as follows:
		1 = New England
		2 = Middle Atlantic
		3 = East North Central
		4 = West North Central
		5 = South Atlantic
		6 = East South Central
		7 = West South Central
		8 = Mountain
		9 = Pacific
	*/

* Keep if national summary level
keep if sumlev == 10
* Keep net international migration columns
keep internationalmig2010 internationalmig2011

* Reshape the data
xpose, varname clear
ren v1 tot_nim
gen year = 2010 if _varname == "internationalmig2010"
replace year = 2011 if _varname == "internationalmig2011"
drop _varname

* Multiply 2010 estimate by 4 to get annual number
replace tot_nim = tot_nim * 4 if year == 2010

save $outdata/immigration_estimates_2013.dta, replace


** Format data 2000 - 2009 **

insheet using $census_dir/$immig_est_2009, clear

/* Codes in the file 
	Annual Population Estimates, Estimated Components of Resident Population
	Change, and Rates of the Components of Resident Population Change for the United States, States, and
	Puerto Rico: April 1, 2000 to July 1, 2009
	File: 7/1/2009 National and State Population Estimates
	Source: U.S. Census Bureau, Population Division
	Release date: December 2009
	Sort order of observations: States in FIPS code sort.
	Data fields (in order of which they appear):
		VARIABLE DESCRIPTION
		SUMLEV Geographic Summary Level
		REGION Census Region code
		DIVISION Census Division code
		STATE State FIPS code
		NAME State name
		CENSUS2000POP 4/1/2000 resident total Census 2000 population
		ESTIMATESBASE2000 4/1/2000 resident total population estimates base
		POPESTIMATE2000 7/1/2000 resident total population estimate
		POPESTIMATE2001 7/1/2001 resident total population estimate
		POPESTIMATE2002 7/1/2002 resident total population estimate
		POPESTIMATE2003 7/1/2003 resident total population estimate
		POPESTIMATE2004 7/1/2004 resident total population estimate
		POPESTIMATE2005 7/1/2005 resident total population estimate
		POPESTIMATE2006 7/1/2006 resident total population estimate
		POPESTIMATE2007 7/1/2007 resident total population estimate
		POPESTIMATE2008 7/1/2008 resident total population estimate
		POPESTIMATE2009 7/1/2009 resident total population estimate
		NPOPCHG_2000 Numeric Change in resident total population 4/1/2000 to 7/1/2000
		NPOPCHG_2001 Numeric Change in resident total population 7/1/2000 to 7/1/2001
		NPOPCHG_2002 Numeric Change in resident total population 7/1/2001 to 7/1/2002
		NPOPCHG_2003 Numeric Change in resident total population 7/1/2002 to 7/1/2003
		NPOPCHG_2004 Numeric Change in resident total population 7/1/2003 to 7/1/2004
		NPOPCHG_2005 Numeric Change in resident total population 7/1/2004 to 7/1/2005
		NPOPCHG_2006 Numeric Change in resident total population 7/1/2005 to 7/1/2006
		NPOPCHG_2007 Numeric Change in resident total population 7/1/2006 to 7/1/2007
		NPOPCHG_2008 Numeric Change in resident total population 7/1/2007 to 7/1/2008
		NPOPCHG_2009 Numeric Change in resident total population 7/1/2008 to 7/1/2009
		BIRTHS2000 Births in period 4/1/2000 to 6/30/2000
		BIRTHS2001 Births in period 7/1/2000 to 6/30/2001
		BIRTHS2002 Births in period 7/1/2001 to 6/30/2002
		BIRTHS2003 Births in period 7/1/2002 to 6/30/2003
		BIRTHS2004 Births in period 7/1/2003 to 6/30/2004
		BIRTHS2005 Births in period 7/1/2004 to 6/30/2005
		BIRTHS2006 Births in period 7/1/2005 to 6/30/2006
		BIRTHS2007 Births in period 7/1/2006 to 6/30/2007
		BIRTHS2008 Births in period 7/1/2007 to 6/30/2008
		BIRTHS2009 Births in period 7/1/2008 to 6/30/2009
		DEATHS2000 Deaths in period 4/1/2000 to 6/30/2000
		DEATHS2001 Deaths in period 7/1/2000 to 6/30/2001
		DEATHS2002 Deaths in period 7/1/2001 to 6/30/2002
		DEATHS2003 Deaths in period 7/1/2002 to 6/30/2003
		DEATHS2004 Deaths in period 7/1/2003 to 6/30/2004
		DEATHS2005 Deaths in period 7/1/2004 to 6/30/2005
		DEATHS2006 Deaths in period 7/1/2005 to 6/30/2006
		DEATHS2007 Deaths in period 7/1/2006 to 6/30/2007
		DEATHS2008 Deaths in period 7/1/2007 to 6/30/2008
		DEATHS2009 Deaths in period 7/1/2008 to 6/30/2009
		NATURALINC2000 Natural increase in period 4/1/2000 to 6/30/2000
		NATURALINC2001 Natural increase in period 7/1/2000 to 6/30/2001
		NATURALINC2002 Natural increase in period 7/1/2001 to 6/30/2002
		NATURALINC2003 Natural increase in period 7/1/2002 to 6/30/2003
		NATURALINC2004 Natural increase in period 7/1/2003 to 6/30/2004
		NATURALINC2005 Natural increase in period 7/1/2004 to 6/30/2005
		NATURALINC2006 Natural increase in period 7/1/2005 to 6/30/2006
		NATURALINC2007 Natural increase in period 7/1/2006 to 6/30/2007
		NATURALINC2008 Natural increase in period 7/1/2007 to 6/30/2008
		NATURALINC2009 Natural increase in period 7/1/2008 to 6/30/2009
		INTERNATIONALMIG2000 Net international migration in period 4/1/2000 to 6/30/2000
		INTERNATIONALMIG2001 Net international migration in period 7/1/2000 to 6/30/2001
		INTERNATIONALMIG2002 Net international migration in period 7/1/2001 to 6/30/2002
		INTERNATIONALMIG2003 Net international migration in period 7/1/2002 to 6/30/2003
		INTERNATIONALMIG2004 Net international migration in period 7/1/2003 to 6/30/2004
		INTERNATIONALMIG2005 Net international migration in period 7/1/2004 to 6/30/2005
		INTERNATIONALMIG2006 Net international migration in period 7/1/2005 to 6/30/2006
		INTERNATIONALMIG2007 Net international migration in period 7/1/2006 to 6/30/2007
		INTERNATIONALMIG2008 Net international migration in period 7/1/2007 to 6/30/2008
		INTERNATIONALMIG2009 Net international migration in period 7/1/2008 to 6/30/2009
		DOMESTICMIG2000 Net domestic migration in period 4/1/2000 to 6/30/2000
		DOMESTICMIG2001 Net domestic migration in period 7/1/2000 to 6/30/2001
		DOMESTICMIG2002 Net domestic migration in period 7/1/2001 to 6/30/2002
		DOMESTICMIG2003 Net domestic migration in period 7/1/2002 to 6/30/2003
		DOMESTICMIG2004 Net domestic migration in period 7/1/2003 to 6/30/2004
		DOMESTICMIG2005 Net domestic migration in period 7/1/2004 to 6/30/2005
		DOMESTICMIG2006 Net domestic migration in period 7/1/2005 to 6/30/2006
		DOMESTICMIG2007 Net domestic migration in period 7/1/2006 to 6/30/2007
		DOMESTICMIG2008 Net domestic migration in period 7/1/2007 to 6/30/2008
		DOMESTICMIG2009 Net domestic migration in period 7/1/2008 to 6/30/2009
		NETMIG2000 Net migration in period 4/1/2000 to 6/30/2000
		NETMIG2001 Net migration in period 7/1/2000 to 6/30/2001
		NETMIG2002 Net migration in period 7/1/2001 to 6/30/2002
		NETMIG2003 Net migration in period 7/1/2002 to 6/30/2003
		NETMIG2004 Net migration in period 7/1/2003 to 6/30/2004
		NETMIG2005 Net migration in period 7/1/2004 to 6/30/2005
		NETMIG2006 Net migration in period 7/1/2005 to 6/30/2006
		NETMIG2007 Net migration in period 7/1/2006 to 6/30/2007
		NETMIG2008 Net migration in period 7/1/2007 to 6/30/2008
		NETMIG2009 Net migration in period 7/1/2008 to 6/30/2009
		RESIDUAL2000 Residual for period 4/1/2000 to 6/30/2000
		RESIDUAL2001 Residual for period 7/1/2000 to 6/30/2001
		RESIDUAL2002 Residual for period 7/1/2001 to 6/30/2002
		RESIDUAL2003 Residual for period 7/1/2002 to 6/30/2003
		RESIDUAL2004 Residual for period 7/1/2003 to 6/30/2004
		RESIDUAL2005 Residual for period 7/1/2004 to 6/30/2005
		RESIDUAL2006 Residual for period 7/1/2005 to 6/30/2006
		RESIDUAL2007 Residual for period 7/1/2006 to 6/30/2007
		RESIDUAL2008 Residual for period 7/1/2007 to 6/30/2008
		RESIDUAL2009 Residual for period 7/1/2008 to 6/30/2009
		RBIRTH2001 Birth rate in period 7/1/2000 to 6/30/2001
		RBIRTH2002 Birth rate in period 7/1/2001 to 6/30/2002
		RBIRTH2003 Birth rate in period 7/1/2002 to 6/30/2003
		RBIRTH2004 Birth rate in period 7/1/2003 to 6/30/2004
		RBIRTH2005 Birth rate in period 7/1/2004 to 6/30/2005
		RBIRTH2006 Birth rate in period 7/1/2005 to 6/30/2006
		RBIRTH2007 Birth rate in period 7/1/2006 to 6/30/2007
		RBIRTH2008 Birth rate in period 7/1/2007 to 6/30/2008
		RBIRTH2009 Birth rate in period 7/1/2008 to 6/30/2009
		RDEATH2001 Death rate in period 7/1/2000 to 6/30/2001
		RDEATH2002 Death rate in period 7/1/2001 to 6/30/2002
		RDEATH2003 Death rate in period 7/1/2002 to 6/30/2003
		RDEATH2004 Death rate in period 7/1/2003 to 6/30/2004
		RDEATH2005 Death rate in period 7/1/2004 to 6/30/2005
		RDEATH2006 Death rate in period 7/1/2005 to 6/30/2006
		RDEATH2007 Death rate in period 7/1/2006 to 6/30/2007
		RDEATH2008 Death rate in period 7/1/2007 to 6/30/2008
		RDEATH2009 Death rate in period 7/1/2008 to 6/30/2009
		RNATURALINC2001 Natural increase rate in period 7/1/2000 to 6/30/2001
		RNATURALINC2002 Natural increase rate in period 7/1/2001 to 6/30/2002
		RNATURALINC2003 Natural increase rate in period 7/1/2002 to 6/30/2003
		RNATURALINC2004 Natural increase rate in period 7/1/2003 to 6/30/2004
		RNATURALINC2005 Natural increase rate in period 7/1/2004 to 6/30/2005
		RNATURALINC2006 Natural increase rate in period 7/1/2005 to 6/30/2006
		RNATURALINC2007 Natural increase rate in period 7/1/2006 to 6/30/2007
		RNATURALINC2008 Natural increase rate in period 7/1/2007 to 6/30/2008
		RNATURALINC2009 Natural increase rate in period 7/1/2008 to 6/30/2009
		RINTERNATIONALMIG2001 Net international migration rate in period 7/1/2000 to 6/30/2001
		RINTERNATIONALMIG2002 Net international migration rate in period 7/1/2001 to 6/30/2002
		RINTERNATIONALMIG2003 Net international migration rate in period 7/1/2002 to 6/30/2003
		RINTERNATIONALMIG2004 Net international migration rate in period 7/1/2003 to 6/30/2004
		RINTERNATIONALMIG2005 Net international migration rate in period 7/1/2004 to 6/30/2005
		RINTERNATIONALMIG2006 Net international migration rate in period 7/1/2005 to 6/30/2006
		RINTERNATIONALMIG2007 Net international migration rate in period 7/1/2006 to 6/30/2007
		RINTERNATIONALMIG2008 Net international migration rate in period 7/1/2007 to 6/30/2008
		RINTERNATIONALMIG2009 Net international migration rate in period 7/1/2008 to 6/30/2009
		RDOMESTICMIG2001 Net domestic migration rate in period 7/1/2000 to 6/30/2001
		RDOMESTICMIG2002 Net domestic migration rate in period 7/1/2001 to 6/30/2002
		RDOMESTICMIG2003 Net domestic migration rate in period 7/1/2002 to 6/30/2003
		RDOMESTICMIG2004 Net domestic migration rate in period 7/1/2003 to 6/30/2004
		RDOMESTICMIG2005 Net domestic migration rate in period 7/1/2004 to 6/30/2005
		RDOMESTICMIG2006 Net domestic migration rate in period 7/1/2005 to 6/30/2006
		RDOMESTICMIG2007 Net domestic migration rate in period 7/1/2006 to 6/30/2007
		RDOMESTICMIG2008 Net domestic migration rate in period 7/1/2007 to 6/30/2008
		RDOMESTICMIG2009 Net domestic migration rate in period 7/1/2008 to 6/30/2009
		RNETMIG2001 Net migration rate in period 7/1/2000 to 6/30/2001
		RNETMIG2002 Net migration rate in period 7/1/2001 to 6/30/2002
		RNETMIG2003 Net migration rate in period 7/1/2002 to 6/30/2003
		RNETMIG2004 Net migration rate in period 7/1/2003 to 6/30/2004
		RNETMIG2005 Net migration rate in period 7/1/2004 to 6/30/2005
		RNETMIG2006 Net migration rate in period 7/1/2005 to 6/30/2006
		RNETMIG2007 Net migration rate in period 7/1/2006 to 6/30/2007
		RNETMIG2008 Net migration rate in period 7/1/2007 to 6/30/2008
		RNETMIG2009 Net migration rate in period 7/1/2008 to 6/30/2009
	X = Not Applicable
	The key for SUMLEV is as follows:
		010 = Nation
		040 = State and/or Statistical Equivalent or Puerto Rico Commonwealth
	The key for REGION is as follows:
		0 = United States Total
		1 = Northeast
		2 = Midwest
		3 = South
		4 = West
		X = Not Applicable
	The key for DIVISION is as follows:
		0 = United States Total
		1 = New England
		2 = Middle Atlantic
		3 = East North Central
		4 = West North Central
		5 = South Atlantic
		6 = East South Central
		7 = West South Central
		8 = Mountain
		9 = Pacific
		X = Not Applicable
	*/

* Keep if national summary level
keep if sumlev == 10
* Keep net international migration columns
keep internationalmig*

* Reshape the data
xpose, varname clear
ren v1 tot_nim
gen year = 2009 if _varname == "internationalmig2009"
replace year = 2008 if _varname == "internationalmig2008"
replace year = 2007 if _varname == "internationalmig2007"
replace year = 2006 if _varname == "internationalmig2006"
replace year = 2005 if _varname == "internationalmig2005"
replace year = 2004 if _varname == "internationalmig2004"
replace year = 2003 if _varname == "internationalmig2003"
replace year = 2002 if _varname == "internationalmig2002"
replace year = 2001 if _varname == "internationalmig2001"
replace year = 2000 if _varname == "internationalmig2000"
drop _varname

* Multiply 2000 estimate by 4 to get annual number
replace tot_nim = tot_nim * 4 if year == 2000

*save $outdata/immigration_estimates_2009.dta, replace

append using $outdata/immigration_estimates_2013.dta


save $outdata/immigration_estimates.dta, replace

exit, STATA
