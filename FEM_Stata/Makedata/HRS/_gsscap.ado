/* Function to Get Cpi index for a given year
extrapolated for 2006 onwards using average last 20 years
Nominal amounts
-----------------------------------------------------*/

program define _gsscap
	version 9, missing
	gettoken type 0 : 0
	gettoken sscap 0 : 0
	gettoken eqs 0 : 0			/* "=" */
	gettoken paren 0 : 0, parse("(), ")	/* "(" */
	gettoken year 0 : 0, parse("(), ")
	gettoken paren 0 : 0, parse("(), ")	/* "(" */
	syntax [if] [in] [, BY(string)]
		marksample touse
		global result `sscap'
		global where `year'
		global selected `touse'
		qui gen $result = . if $selected
		getsscap
end

program define capfor
	qui replace $result = `2' if $where==`1' & $selected
end

program define getsscap
capfor	1950	3000
capfor	1951	3600
capfor	1952	3600
capfor	1953	3600
capfor	1954	3600
capfor	1955	4200
capfor	1956	4200
capfor	1957	4200
capfor	1958	4200
capfor	1959	4800
capfor	1960	4800
capfor	1961	4800
capfor	1962	4800
capfor	1963	4800
capfor	1964	4800
capfor	1965	4800
capfor	1966	6600
capfor	1967	6600
capfor	1968	7800
capfor	1969	7800
capfor	1970	7800
capfor	1971	7800
capfor	1972	9000
capfor	1973	10800
capfor	1974	13200
capfor	1975	14100
capfor	1976	15300
capfor	1977	16500
capfor	1978	17700
capfor	1979	22900
capfor	1980	25900
capfor	1981	29700
capfor	1982	32400
capfor	1983	35700
capfor	1984	37800
capfor	1985	39600
capfor	1986	42000
capfor	1987	43800
capfor	1988	45000
capfor	1989	48000
capfor	1990	51300
capfor	1991	53400
capfor	1992	55500
capfor	1993	57600
capfor	1994	60600
capfor	1995	61200
capfor	1996	62700
capfor	1997	65400
capfor	1998	68400
capfor	1999	72600
capfor	2000	76200
capfor	2001	80400
capfor	2002	84900
capfor	2003	87000
capfor	2004	87900
capfor	2005	95400
capfor	2006	97500
capfor	2007	101693
capfor	2008	106065
capfor	2009	110626
capfor	2010	115383
capfor	2011	120344
capfor	2012	125519
capfor	2013	130917
capfor	2014	136546
capfor	2015	142418
capfor	2016	148541
capfor	2017	154929
capfor	2018	161591
capfor	2019	168539
capfor	2020	175786
capfor	2021	183345
capfor	2022	191229
capfor	2023	199452
capfor	2024	208028
capfor	2025	216973
capfor	2026	226303
capfor	2027	236034
capfor	2028	246184
capfor	2029	256770
capfor	2030	267811
capfor	2031	279327
capfor	2032	291338
capfor	2033	303865
capfor	2034	316931
capfor	2035	330559
capfor	2036	344773
capfor	2037	359599
capfor	2038	375061
capfor	2039	391189
capfor	2040	408010
capfor	2041	425555
capfor	2042	443854
capfor	2043	462939
capfor	2044	482846
capfor	2045	503608
capfor	2046	525263
capfor	2047	547849
capfor	2048	571407
capfor	2049	595978
capfor	2050	621605
capfor	2051	648334
capfor	2052	676212
capfor	2053	705289
capfor	2054	735616
capfor	2055	767248
capfor	2056	800240
capfor	2057	834650
capfor	2058	870540
capfor	2059	907973
capfor	2060	947016
end
