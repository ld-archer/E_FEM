program define taxsim10
/*
** by Jean Roth , jroth@nber.org ;
   Daniel Feenberg updated version 10, feenberg@nber.org
This program uses the NBER TAXSIM model to calculate US and state liability.
*/

display "begin taxsim10.ado on $S_DATE (version 10.0) `c(OS)'"
capture confirm variable mstat
if _rc {
     display "Assume Joint Filing."
     generate mstat = 2
}

capture confirm variable year
if _rc {
     display "Assume tax law for 1960."
     generate year = 1960
}

capture drop _taxsimid
capture confirm variable taxsimid
if _rc {
  gen double _taxsimid = _n
} 
else {
  gen _taxsimid = taxsimid
}
local args `0'
noisily di "`args'"
foreach f in argfile messages txpy.raw ftp results.dta txpy.taxsim {
  capture erase _`f'
}
local debug : list posof "debug" in args

if _N==0 { 
  display "Aborting:  No observations in data set" 
  exit 
}  

local  ///
  datavars  _taxsimid year      state     mstat     depx     agex      ///
  pwages    swages    dividends otherprop pensions  gssi     transfers /// 
  rentpaid  proptax   otheritem childcare ui        depchild           ///
  mortgage  stcg      ltcg      

/* Print list of missing variables, if there are any */
foreach X of local datavars {
  capture confirm var `X'
  if _rc >0 {
     di "Variables not found and treated as zeroes: " _continue
     continue,break
  }
}
foreach X of local datavars { 
  capture confirm var `X' 
  if _rc > 0 { 
     display "`X' " _continue
     generate `X' = 0 
  }
}
/* Print list of variables with missing values */
foreach X of local datavars {
  capture assert missing(`X')
  quietly count if `X' == .
  if r(N) >0 {
     di " "
     di "Missing values treated as zeroes: " _continue
     continue,break
  }
}

preserve

foreach X of local datavars { 
  quietly count if `X' == .
  if r(N) == 0 continue
  display "`X'(" r(N) ") "  _continue
  quietly replace `X' = 0 if `X'==.
}
di " "

foreach X of local datavars {
  confirm numeric variable `X'
  if _rc==7 exit
}

local sent = _N
di `sent' "  taxpayer record(s) sent"
quietly outfile `datavars' using _txpy,replace comma nolabel

local ctime = subinstr("`c(current_time)'",":","",2)
local ftpdir   "`c(username)'`ctime'" 
file open  argfile using _argfile,write
file write argfile "`0'" _n
file close argfile
di "$taxsim10exe"
if "x$taxsim10exe" == "x" {
   di "ftp `sent' records to taxsimftp2.nber.org:/tmp/`ftpdir'/_txpy.raw:"
   file open out using _ftp, write 
   file write out "open taxsimftp2.nber.org" _char(10)
   file write out "user taxsim 02138"        _char(10)
   file write out "cd tmp"                   _char(10)
   file write out "mkdir `ftpdir' "          _char(10) 
   file write out "type ascii"               _char(10)
   file write out "cd    `ftpdir' "          _char(10)
   file write out `" put _txpy.raw "'        _char(10)
   file write out `" put _argfile  "'        _char(10)
   file write out "get _txpy.raw.taxsim _txpy.taxsim" _char(10)
   if "`debug'"=="0" file write out "del _txpy.raw" _char(10)
   file write out "get _messages"            _char(10)
   file write out "quit"                     _char(10)
   file close out
   if "`c(os)'" == "Windows" {
      ! cmd /C ftp -n -s:_ftp -w:12888 
   }
   else {
      ! ftp -n <_ftp
   }
}
else {
   di "output `sent' ASCII records to _txpy.raw for $taxsim10exe.."
   !  $taxsim10exe <_txpy.raw >_txpy.taxsim 
}
noisily type _messages

insheet using "_txpy.taxsim",delimiter(" ") clear nonames
if _N == 0 {
  if "x$taxsim10exe" != "x" {
     !which $taxsim10exe
     di "$taxsim10exe is probably not in the default path"
     exit
  } 
  else {
     di "See http://www.nber.org/taxsim/ftp-problems.html"
     exit
  }
}
if (_N>0 & _N!=51*`sent' & _N!=`sent') {
  di "Consult the Notes and Support section of the help file for "
  di "troubleshooting information http://www.nber.org/taxsim/stata/ "
  exit
}

rename v1 _taxsimid
rename v2 year
rename v3 state
rename v4 fiitax
rename v5 siitax
rename v6 fica
rename v7 frate
rename v8 srate
rename v9 ficar

label variable state  "state id"
label variable fiitax "Federal Income Tax"
label variable siitax "State Income Tax"
label variable fica   "OASDI and HI Payroll Tax"
label variable frate  "IIT marginal rate"
label variable srate  "state marginal rate"
label variable ficar  "SS marginal rate" 
quietly capture confirm variable v10
if _rc == 0 {
  label variable v10 "Federal AGI" 
  label variable v11 "UI in AGI" 
  label variable v12 "Social Security in AGI" 
  label variable v13 "Zero Bracket Amount" 
  label variable v14 "Personal Exemptions" 
  label variable v15 "Exemption Phaseout" 
  label variable v16 "Deduction Phaseout" 
  label variable v17 "Deductions allowed" 
  label variable v18 "Federal Taxable Income" 
  label variable v19 "Federal Regular Tax" 
  label variable v20 "Exemption Surtax" 
  label variable v21 "General Tax Credit" 
  label variable v22 "Child Tax Credit (as adjusted)" 
  label variable v23 "Refundable Part of Child Tax Credit" 
  label variable v24 "Child Care Credit" 
  label variable v25 "Earned Income Credit" 
  label variable v26 "Income for the Alternative Minimum Tax" 
  label variable v27 "AMT Liability (addition to regular tax)" 
  label variable v28 "Income Tax before Credits"
  label variable v29 "FICA" 
  label variable v30 "State Household Income" 
  label variable v31 "State Rent Payments" 
  label variable v32 "State AGI" 
  label variable v33 "State Exemption amount" 
  label variable v34 "State Standard Deduction" 
  label variable v35 "State Itemized Deductions" 
  label variable v36 "State Taxable Income" 
  label variable v37 "State Property Tax Credit" 
  label variable v38 "State Child Care Credit" 
  label variable v39 "State General Credit " 
  label variable v40 "State Total Credits" 
  label variable v41 "State Bracket Rate" 
} 
save _results, replace
restore 
capture drop _merge  
capture drop v10-v41
merge 1:1 _n  using _results,replace update
if "`debug'"=="0" {
  drop _merge
  foreach f in argfile messages txpy.raw ftp results.dta txpy.taxsim {
    capture erase _`f'
  }
}
end
  

