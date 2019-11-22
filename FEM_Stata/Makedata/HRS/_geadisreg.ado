/* Function to Get Earning Disregard for a given year
and age extrapolated for 2006 onwards using average last 20 years
Nominal amounts (abolition of portion above NRA implemented)
-----------------------------------------------------*/

program define _geadisreg
	version 9, missing
	gettoken type 0 : 0
	gettoken eadisreg 0 : 0
	gettoken eqs 0 : 0			/* "=" */
	gettoken paren 0 : 0, parse("(), ")	/* "(" */
	gettoken year 0 : 0, parse("(), ")
	gettoken age 0 : 0, parse("(), ")
	gettoken paren 0 : 0, parse("(), ")	/* "(" */
	syntax [if] [in] [, BY(string)]
		marksample touse 
		tempvar nra byr class
		qui gen `byr' = `year'-`age' if `touse'
		qui egen `nra' = nra(`byr') if `touse'
		qui gen `class' = 0 if `age'<62 & `touse'
		qui replace `class' = 1 if `age'>=62 & `age'<`nra' & `touse'
		qui replace `class' = 2 if `age'>=`nra' & `age'<70 & `touse'
		qui replace `class' = 3 if `age'>=70 & `touse'
		global result `eadisreg'
		global when `year'
		global whatage `class'
		global selected `touse'
		qui gen $result = . if $selected
		getdisreg
end

program define disfor
	qui replace $result = `2' if $when==`1' & $whatage==1 & $selected
	qui replace $result = `3' if $when==`1' & $whatage==2 & $selected
end

program define getdisreg
disfor	1950	5400	7230
disfor	1951	5400	7230
disfor	1952	5400	7230
disfor	1953	5400	7230
disfor	1954	5400	7230
disfor	1955	5400	7230
disfor	1956	5400	7230
disfor	1957	5400	7230
disfor	1958	5400	7230
disfor	1959	5400	7230
disfor	1960	5400	7230
disfor	1961	5400	7230
disfor	1962	5400	7230
disfor	1963	5400	7230
disfor	1964	5400	7230
disfor	1965	5400	7230
disfor	1966	5400	7230
disfor	1967	5400	7230
disfor	1968	5400	7230
disfor	1969	5400	7230
disfor	1970	5400	7230
disfor	1971	5400	7230
disfor	1972	5400	7230
disfor	1973	5400	7230
disfor	1974	5400	7230
disfor	1975	5400	7230
disfor	1976	5400	7230
disfor	1977	5400	7230
disfor	1978	5400	7230
disfor	1979	5400	7230
disfor	1980	5400	7230
disfor	1981	5400	7230
disfor	1982	5400	7230
disfor	1983	5400	7230
disfor	1984	5400	7230
disfor	1985	5400	7320
disfor	1986	5760	7800
disfor	1987	6000	8160
disfor	1988	6120	8400
disfor	1989	6480	8880
disfor	1990	6840	9360
disfor	1991	7080	9720
disfor	1992	7440	10200
disfor	1993	7680	10560
disfor	1994	8040	11160
disfor	1995	8160	11280
disfor	1996	8280	12500
disfor	1997	8640	13500
disfor	1998	9120	14500
disfor	1999	9600	15500
disfor	2000	10080 	9999999
disfor	2001	10680 	9999999
disfor	2002	11280 	9999999
disfor	2003	11520 	9999999
disfor	2004	11640 	9999999
disfor	2005	12117 	9999999
disfor	2006	12614 	9999999
disfor	2007	13131 	9999999
disfor	2008	13670 	9999999
disfor	2009	14230 	9999999
disfor	2010	14813 	9999999
disfor	2011	15421 	9999999
disfor	2012	16053 	9999999
disfor	2013	16711 	9999999
disfor	2014	17396 	9999999
disfor	2015	18110 	9999999
disfor	2016	18852 	9999999
disfor	2017	19625 	9999999
disfor	2018	20430 	9999999
disfor	2019	21267 	9999999
disfor	2020	22139 	9999999
disfor	2021	23047 	9999999
disfor	2022	23992 	9999999
disfor	2023	24976 	9999999
disfor	2024	26000 	9999999
disfor	2025	27066 	9999999
disfor	2026	28175 	9999999
disfor	2027	29331 	9999999
disfor	2028	30533 	9999999
disfor	2029	31785 	9999999
disfor	2030	33088 	9999999
disfor	2031	34445 	9999999
disfor	2032	35857 	9999999
disfor	2033	37327 	9999999
disfor	2034	38858 	9999999
disfor	2035	40451 	9999999
disfor	2036	42109 	9999999
disfor	2037	43836 	9999999
disfor	2038	45633 	9999999
disfor	2039	47504 	9999999
disfor	2040	49451 	9999999
disfor	2041	51479 	9999999
disfor	2042	53590 	9999999
disfor	2043	55787 	9999999
disfor	2044	58074 	9999999
disfor	2045	60455 	9999999
disfor	2046	62934 	9999999
disfor	2047	65514 	9999999
disfor	2048	68200 	9999999
disfor	2049	70996 	9999999
disfor	2050	73907 	9999999
disfor	2051	76937 	9999999
disfor	2052	80092 	9999999
disfor	2053	83376 	9999999
disfor	2054	86794 	9999999
disfor	2055	90353 	9999999
disfor	2056	94057 	9999999
disfor	2057	97913 	9999999
disfor	2058	101928 	9999999
disfor	2059	106107 	9999999
disfor	2060	110457 	9999999
end
