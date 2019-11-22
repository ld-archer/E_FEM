/* Function to Get normal retirement age for a given
birth cohort 
-----------------------------------------------------*/

program define _gnra
	version 9, missing
	gettoken type 0 : 0
	gettoken nra 0 : 0
	gettoken eqs 0 : 0			/* "=" */
	gettoken paren 0 : 0, parse("(), ")	/* "(" */
	gettoken byear 0 : 0, parse("(), ")
	gettoken paren 0 : 0, parse("(), ")	/* "(" */
	syntax [if] [in] [, BY(string)]
		marksample touse
		global result `nra'
		global where `byear'
		global selected `touse'
		qui gen $result = . if $selected
		getnra
end

program define nrafor
	qui replace $result = `2' if $where==`1' & $selected
end

program define getnra
nrafor	1900	65
nrafor	1901	65
nrafor	1902	65
nrafor	1903	65
nrafor	1904	65
nrafor	1905	65
nrafor	1906	65
nrafor	1907	65
nrafor	1908	65
nrafor	1909	65
nrafor	1910	65
nrafor	1911	65
nrafor	1912	65
nrafor	1913	65
nrafor	1914	65
nrafor	1915	65
nrafor	1916	65
nrafor	1917	65
nrafor	1918	65
nrafor	1919	65
nrafor	1920	65
nrafor	1921	65
nrafor	1922	65
nrafor	1923	65
nrafor	1924	65
nrafor	1925	65
nrafor	1926	65
nrafor	1927	65
nrafor	1928	65
nrafor	1929	65
nrafor	1930	65
nrafor	1931	65
nrafor	1932	65
nrafor	1933	65
nrafor	1934	65
nrafor	1935	65
nrafor	1936	65
nrafor	1937	65
nrafor	1938	65
nrafor	1939	65
nrafor	1940	65
nrafor	1941	66
nrafor	1942	66
nrafor	1943	66
nrafor	1944	66
nrafor	1945	66
nrafor	1946	66
nrafor	1947	66
nrafor	1948	66
nrafor	1949	66
nrafor	1950	66
nrafor	1951	66
nrafor	1952	66
nrafor	1953	66
nrafor	1954	66
nrafor	1955	66
nrafor	1956	66
nrafor	1957	66
nrafor	1958	67
nrafor	1959	67
nrafor	1960	67
nrafor	1961	67
nrafor	1962	67
nrafor	1963	67
nrafor	1964	67
nrafor	1965	67
nrafor	1966	67
nrafor	1967	67
nrafor	1968	67
nrafor	1969	67
nrafor	1970	67
nrafor	1971	67
nrafor	1972	67
nrafor	1973	67
nrafor	1974	67
nrafor	1975	67
nrafor	1976	67
nrafor	1977	67
nrafor	1978	67
nrafor	1979	67
nrafor	1980	67
nrafor	1981	67
nrafor	1982	67
nrafor	1983	67
nrafor	1984	67
nrafor	1985	67
nrafor	1986	67
nrafor	1987	67
nrafor	1988	67
nrafor	1989	67
nrafor	1990	67
nrafor	1991	67
nrafor	1992	67
nrafor	1993	67
nrafor	1994	67
nrafor	1995	67
nrafor	1996	67
nrafor	1997	67
nrafor	1998	67
nrafor	1999	67
nrafor	2000	67
nrafor	2001	67
nrafor	2002	67
nrafor	2003	67
nrafor	2004	67
nrafor	2005	67
nrafor	2006	67
nrafor	2007	67
nrafor	2008	67
nrafor	2009	67
nrafor	2010	67
nrafor	2011	67
nrafor	2012	67
nrafor	2013	67
nrafor	2014	67
nrafor	2015	67
nrafor	2016	67
nrafor	2017	67
nrafor	2018	67
nrafor	2019	67
nrafor	2020	67
nrafor	2021	67
nrafor	2022	67
nrafor	2023	67
nrafor	2024	67
nrafor	2025	67
nrafor	2026	67
nrafor	2027	67
nrafor	2028	67
nrafor	2029	67
nrafor	2030	67
nrafor	2031	67
nrafor	2032	67
nrafor	2033	67
nrafor	2034	67
nrafor	2035	67
nrafor	2036	67
nrafor	2037	67
nrafor	2038	67
nrafor	2039	67
nrafor	2040	67
nrafor	2041	67
nrafor	2042	67
nrafor	2043	67
nrafor	2044	67
nrafor	2045	67
nrafor	2046	67
nrafor	2047	67
nrafor	2048	67
nrafor	2049	67
nrafor	2050	67
nrafor	2051	67
nrafor	2052	67
nrafor	2053	67
nrafor	2054	67
nrafor	2055	67
nrafor	2056	67
nrafor	2057	67
nrafor	2058	67
nrafor	2059	67
nrafor	2060	67
end
