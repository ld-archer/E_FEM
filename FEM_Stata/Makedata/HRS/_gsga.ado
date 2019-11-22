/* Function to Get Substantial Gainful Activity in a given Year 
extension to egen 
1980-2060 (extrapolated 2007 onwards)
-----------------------------------------------------*/

program define _gsga
	version 9, missing
	gettoken type 0 : 0
	gettoken sga 0 : 0
	gettoken eqs 0 : 0			/* "=" */
	gettoken paren 0 : 0, parse("(), ")	/* "(" */
	gettoken year 0 : 0, parse("(), ")
	gettoken paren 0 : 0, parse("(), ")	/* "(" */
	syntax [if] [in] [, BY(string)]
		marksample touse
		global result `sga'
		global when `year'
		global selected `touse'
		qui gen $result = . if $selected
		getsga
end

program define sgafor
	qui replace $result = `2' if $when==`1' & $selected
end

program define getsga
sgafor	1980	3600
sgafor	1981	3600
sgafor	1982	3600
sgafor	1983	3600
sgafor	1984	3600
sgafor	1985	3600
sgafor	1986	3600
sgafor	1987	3600
sgafor	1988	3600
sgafor	1989	3600
sgafor	1990	6000
sgafor	1991	6000
sgafor	1992	6000
sgafor	1993	6000
sgafor	1994	6000
sgafor	1995	6000
sgafor	1996	6000
sgafor	1997	6000
sgafor	1998	6000
sgafor	1999	6000
sgafor	2000	8400
sgafor	2001	8880
sgafor	2002	9360
sgafor	2003	9600
sgafor	2004	9720
sgafor	2005	9960
sgafor	2006	10320
sgafor	2007	10800
sgafor	2008	10800
sgafor	2009	10800
sgafor	2010	10800
sgafor	2011	10800
sgafor	2012	10800
sgafor	2013	10800
sgafor	2014	10800
sgafor	2015	10800
sgafor	2016	10800
sgafor	2017	10800
sgafor	2018	10800
sgafor	2019	10800
sgafor	2020	10800
sgafor	2021	10800
sgafor	2022	10800
sgafor	2023	10800
sgafor	2024	10800
sgafor	2025	10800
sgafor	2026	10800
sgafor	2027	10800
sgafor	2028	10800
sgafor	2029	10800
sgafor	2030	10800
sgafor	2031	10800
sgafor	2032	10800
sgafor	2033	10800
sgafor	2034	10800
sgafor	2035	10800
sgafor	2036	10800
sgafor	2037	10800
sgafor	2038	10800
sgafor	2039	10800
sgafor	2040	10800
sgafor	2041	10800
sgafor	2042	10800
sgafor	2043	10800
sgafor	2044	10800
sgafor	2045	10800
sgafor	2046	10800
sgafor	2047	10800
sgafor	2048	10800
sgafor	2049	10800
sgafor	2050	10800
sgafor	2051	10800
sgafor	2052	10800
sgafor	2053	10800
sgafor	2054	10800
sgafor	2055	10800
sgafor	2056	10800
sgafor	2057	10800
sgafor	2058	10800
sgafor	2059	10800
sgafor	2060	10800
end
