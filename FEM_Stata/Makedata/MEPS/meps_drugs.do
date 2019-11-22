/* This program will generate a file for use in analyzing Rx expenditures in the MEPS */

include "../../../fem_env.do"

local begyr 2000
local endyr 2010

**** Store the medical cpi into a matrix 
insheet using $fred_dir/CPIMEDSL.csv, clear
gen year = substr(date,5,4)
destring year, replace
ren value medcpi
keep year medcpi
mkmat medcpi, matrix(medcpi) rownames(year)

clear

/* MEPS full-year consolidated files
2000 hc-050
2001 hc-060
2002 hc-070
2003 hc-079
2004 hc-089
2005 hc-097
2006 hc-105
2007 hc-113
2008 hc-121
2009 hc-129
2010 hc-138 
*/


local year = `begyr'

foreach file in 50 60 70 79 89 97 105 113 121 129 138 {
					
	use $meps_dir2/h`file'.dta, clear
	
	/*
	Drug-related variables:
	RXTOT00         int     %8.0g                 # PRESC MEDS INCL REFILLS 00
	RXEXP00         int     %8.0g                 TOTAL RX-EXP 00
	RXSLF00         int     %8.0g                 TOTAL RX-SELF/FAMILY AMT 00
	RXMCR00         int     %8.0g                 TOTAL RX--MEDICARE AMT 00
	RXMCD00         int     %8.0g                 TOTAL RX-MEDICAID AMT 00
	RXPRV00         int     %8.0g                 TOTAL RX-PRIVATE INS AMT 00
	RXVA00          int     %8.0g                 TOTAL RX-VA AMT 00
	RXTRI00         int     %8.0g                 TOTAL RX-TRICARE AMT 00
	RXOFD00         int     %8.0g                 TOTAL RX-OTHER FED AMT 00
	RXSTL00         int     %8.0g                 TOTAL RX-OTHER ST/LOCAL AMT 00
	RXWCP00         int     %8.0g                 TOTAL RX-WORKERS COMP AMT 00
	RXOPR00         int     %8.0g                 TOTAL RX - OTH PRIVATE AMT 00
	RXOPU00         int     %8.0g                 TOTAL RX - OTH PUBLIC AMT 00
	RXOSR00         int     %8.0g                 TOT RX-OTH UNCLASS SRCE AMT 00
	
	2007 and later add

	RXPTR09         long    %12.0g                TOTAL RX-PRV & TRI AMT 09
	RXOTH09         int     %8.0g                 TOTAL RX-OTH COMBINED AMT 09

	
	*/

  rename *, lower   
  
  local yy = substr("`year'",3,.) 
  
  rename rxtot`yy' rxtot
  
  * Rename expenditure variables and scale to "endyr" dollars
  foreach var in rxexp rxslf rxmcr rxmcd rxprv rxva rxtri rxofd rxstl rxwcp rxopr rxopu rxosr {
  	* rename
  	rename `var'`yy' `var'
  	* put in "endyr" dollars
  	replace `var' = `var' * medcpi[rownumb(medcpi,"`endyr'"), 1]/( medcpi[rownumb(medcpi,"`year'"),1])
	}       
  
  * Additional RX variables after 2006
  if `year' > 2006 {
		foreach var in rxptr rxoth {
			* rename
  		rename `var'`yy' `var'
  		* put in "endyr" dollars
  		replace `var' = `var' * medcpi[rownumb(medcpi,"`endyr'"), 1]/( medcpi[rownumb(medcpi,"`year'"),1])
		} 
  }

	gen yr = `year'
	keep dupersid yr rx*

	tempfile `year'
	save ``year''

	local year = `year' + 1
}

clear

forvalues yr = `begyr'/`endyr' {
	append using ``yr''
}

* Label variables
label var rxtot "# Presc Meds Incl Refills"
label var rxexp "Total RX-Exp"
label var rxslf "Total RX-Self/Family Amt"
label var rxmcr "Total RX-Medicare Amt"
label var rxmcd "Total RX-Medicaid Amt"
label var rxprv "Total RX-Private Ins Amt"
label var rxva  "Total RX-VA Amt"
label var rxtri "Total RX-Tricare Amt"
label var rxofd "Total RX Other Fed Amt"
label var rxstl "Total RX-St/Local Amt"
label var rxwcp "Total RX-Workers Comp Amt" 
label var rxopr "Total RX-Other Private Amt"
label var rxopu "Total RX-Other Public Amt"
label var rxosr "Total RX-Other Unclass Source Amt"
label var rxptr "Total RX-Private and Tricare Amt 2007+" 
label var rxoth "Total RX-Oth Combined Amt 2007+"
label var yr "year"

compress

label data "MEPS `begyr'-`endyr' drug data"
save $outdata/meps_drugs.dta, replace


capture log close
