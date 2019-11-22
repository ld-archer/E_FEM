/* Function to Get National Wage Index in a given Year 
extension to egen 
-----------------------------------------------------*/

program define _gnwi
	version 9, missing
	gettoken type 0 : 0
	gettoken nwi 0 : 0
	gettoken eqs 0 : 0			/* "=" */
	gettoken paren 0 : 0, parse("(), ")	/* "(" */
	gettoken year 0 : 0, parse("(), ")
	gettoken paren 0 : 0, parse("(), ")	/* "(" */
	syntax [if] [in] [, BY(string)]
		marksample touse
		global result `nwi'
		global where `year'
		global selected `touse'
		qui gen $result = . if $selected
		getnwi
end

program define nwifor
	qui replace $result = `2' if $where==`1' & $selected
end

program define getnwi
nwifor	1950	2799.16
nwifor	1951	2799.16
nwifor	1952	2973.32
nwifor	1953	3139.44
nwifor	1954	3155.64
nwifor	1955	3301.44
nwifor	1956	3532.36
nwifor	1957	3641.72
nwifor	1958	3673.8
nwifor	1959	3855.8
nwifor	1960	4007.12
nwifor	1961	4086.76
nwifor	1962	4291.4
nwifor	1963	4396.64
nwifor	1964	4576.32
nwifor	1965	4658.72
nwifor	1966	4938.36
nwifor	1967	5213.44
nwifor	1968	5571.76
nwifor	1969	5893.76
nwifor	1970	6186.24
nwifor	1971	6497.08
nwifor	1972	7133.8
nwifor	1973	7580.16
nwifor	1974	8030.76
nwifor	1975	8630.92
nwifor	1976	9226.48
nwifor	1977	9779.44
nwifor	1978	10556.03
nwifor	1979	11479.46
nwifor	1980	12513.46
nwifor	1981	13773.1
nwifor	1982	14531.34
nwifor	1983	15239.24
nwifor	1984	16135.07
nwifor	1985	16822.51
nwifor	1986	17321.82
nwifor	1987	18426.51
nwifor	1988	19334.04
nwifor	1989	20099.55
nwifor	1990	21027.98
nwifor	1991	21811.6
nwifor	1992	22935.42
nwifor	1993	23132.67
nwifor	1994	23753.53
nwifor	1995	24705.66
nwifor	1996	25913.9
nwifor	1997	27426
nwifor	1998	28861.44
nwifor	1999	30469.84
nwifor	2000	32154.82
nwifor	2001	32921.92
nwifor	2002	33514.51
nwifor	2003	34151.29
nwifor	2004	35483.19
nwifor	2005	37044.45
nwifor	2006	38526.228
nwifor	2007	40067.27712
nwifor	2008	41669.9682
nwifor	2009	43336.76693
nwifor	2010	45070.23761
nwifor	2011	46873.04711
nwifor	2012	48747.969
nwifor	2013	50697.88776
nwifor	2014	52725.80327
nwifor	2015	54834.8354
nwifor	2016	57028.22882
nwifor	2017	59309.35797
nwifor	2018	61681.73229
nwifor	2019	64149.00158
nwifor	2020	66714.96164
nwifor	2021	69383.56011
nwifor	2022	72158.90251
nwifor	2023	75045.25861
nwifor	2024	78047.06896
nwifor	2025	81168.95172
nwifor	2026	84415.70978
nwifor	2027	87792.33818
nwifor	2028	91304.0317
nwifor	2029	94956.19297
nwifor	2030	98754.44069
nwifor	2031	102704.6183
nwifor	2032	106812.8031
nwifor	2033	111085.3152
nwifor	2034	115528.7278
nwifor	2035	120149.8769
nwifor	2036	124955.872
nwifor	2037	129954.1068
nwifor	2038	135152.2711
nwifor	2039	140558.362
nwifor	2040	146180.6964
nwifor	2041	152027.9243
nwifor	2042	158109.0413
nwifor	2043	164433.4029
nwifor	2044	171010.739
nwifor	2045	177851.1686
nwifor	2046	184965.2153
nwifor	2047	192363.824
nwifor	2048	200058.3769
nwifor	2049	208060.712
nwifor	2050	216383.1405
nwifor	2051	225038.4661
nwifor	2052	234040.0047
nwifor	2053	243401.6049
nwifor	2054	253137.6691
nwifor	2055	263263.1759
nwifor	2056	273793.7029
nwifor	2057	284745.451
nwifor	2058	296135.2691
nwifor	2059	307980.6798
nwifor	2060	320299.907
end
