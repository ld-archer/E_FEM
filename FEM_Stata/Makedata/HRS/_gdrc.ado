/* Function to Get Delayed Retirement Credit for a given
birth cohort 
-----------------------------------------------------*/

program define _gdrc
	version 9, missing
	gettoken type 0 : 0
	gettoken drc 0 : 0
	gettoken eqs 0 : 0			/* "=" */
	gettoken paren 0 : 0, parse("(), ")	/* "(" */
	gettoken byear 0 : 0, parse("(), ")
	gettoken paren 0 : 0, parse("(), ")	/* "(" */
	syntax [if] [in] [, BY(string)]
		marksample touse
		global result `drc'
		global where `byear'
		global selected `touse'
		qui gen $result = . if $selected
		getdrc
end

program define drcfor
	qui replace $result = `2' if $where==`1' & $selected
end

program define getdrc
drcfor	1900	0.035
drcfor	1901	0.035
drcfor	1902	0.035
drcfor	1903	0.035
drcfor	1904	0.035
drcfor	1905	0.035
drcfor	1906	0.035
drcfor	1907	0.035
drcfor	1908	0.035
drcfor	1909	0.035
drcfor	1910	0.035
drcfor	1911	0.035
drcfor	1912	0.035
drcfor	1913	0.035
drcfor	1914	0.035
drcfor	1915	0.035
drcfor	1916	0.035
drcfor	1917	0.035
drcfor	1918	0.035
drcfor	1919	0.035
drcfor	1920	0.035
drcfor	1921	0.035
drcfor	1922	0.035
drcfor	1923	0.035
drcfor	1924	0.035
drcfor	1925	0.035
drcfor	1926	0.035
drcfor	1927	0.04
drcfor	1928	0.04
drcfor	1929	0.045
drcfor	1930	0.045
drcfor	1931	0.05
drcfor	1932	0.05
drcfor	1933	0.055
drcfor	1934	0.055
drcfor	1935	0.06
drcfor	1936	0.06
drcfor	1937	0.065
drcfor	1938	0.065
drcfor	1939	0.07
drcfor	1940	0.07
drcfor	1941	0.075
drcfor	1942	0.075
drcfor	1943	0.08
drcfor	1944	0.08
drcfor	1945	0.08
drcfor	1946	0.08
drcfor	1947	0.08
drcfor	1948	0.08
drcfor	1949	0.08
drcfor	1950	0.08
drcfor	1951	0.08
drcfor	1952	0.08
drcfor	1953	0.08
drcfor	1954	0.08
drcfor	1955	0.08
drcfor	1956	0.08
drcfor	1957	0.08
drcfor	1958	0.08
drcfor	1959	0.08
drcfor	1960	0.08
drcfor	1961	0.08
drcfor	1962	0.08
drcfor	1963	0.08
drcfor	1964	0.08
drcfor	1965	0.08
drcfor	1966	0.08
drcfor	1967	0.08
drcfor	1968	0.08
drcfor	1969	0.08
drcfor	1970	0.08
drcfor	1971	0.08
drcfor	1972	0.08
drcfor	1973	0.08
drcfor	1974	0.08
drcfor	1975	0.08
drcfor	1976	0.08
drcfor	1977	0.08
drcfor	1978	0.08
drcfor	1979	0.08
drcfor	1980	0.08
drcfor	1981	0.08
drcfor	1982	0.08
drcfor	1983	0.08
drcfor	1984	0.08
drcfor	1985	0.08
drcfor	1986	0.08
drcfor	1987	0.08
drcfor	1988	0.08
drcfor	1989	0.08
drcfor	1990	0.08
drcfor	1991	0.08
drcfor	1992	0.08
drcfor	1993	0.08
drcfor	1994	0.08
drcfor	1995	0.08
drcfor	1996	0.08
drcfor	1997	0.08
drcfor	1998	0.08
drcfor	1999	0.08
drcfor	2000	0.08
drcfor	2001	0.08
drcfor	2002	0.08
drcfor	2003	0.08
drcfor	2004	0.08
drcfor	2005	0.08
drcfor	2006	0.08
drcfor	2007	0.08
drcfor	2008	0.08
drcfor	2009	0.08
drcfor	2010	0.08
drcfor	2011	0.08
drcfor	2012	0.08
drcfor	2013	0.08
drcfor	2014	0.08
drcfor	2015	0.08
drcfor	2016	0.08
drcfor	2017	0.08
drcfor	2018	0.08
drcfor	2019	0.08
drcfor	2020	0.08
drcfor	2021	0.08
drcfor	2022	0.08
drcfor	2023	0.08
drcfor	2024	0.08
drcfor	2025	0.08
drcfor	2026	0.08
drcfor	2027	0.08
drcfor	2028	0.08
drcfor	2029	0.08
drcfor	2030	0.08
drcfor	2031	0.08
drcfor	2032	0.08
drcfor	2033	0.08
drcfor	2034	0.08
drcfor	2035	0.08
drcfor	2036	0.08
drcfor	2037	0.08
drcfor	2038	0.08
drcfor	2039	0.08
drcfor	2040	0.08
drcfor	2041	0.08
drcfor	2042	0.08
drcfor	2043	0.08
drcfor	2044	0.08
drcfor	2045	0.08
drcfor	2046	0.08
drcfor	2047	0.08
drcfor	2048	0.08
drcfor	2049	0.08
drcfor	2050	0.08
drcfor	2051	0.08
drcfor	2052	0.08
drcfor	2053	0.08
drcfor	2054	0.08
drcfor	2055	0.08
drcfor	2056	0.08
drcfor	2057	0.08
drcfor	2058	0.08
drcfor	2059	0.08
drcfor	2060	0.08
end
