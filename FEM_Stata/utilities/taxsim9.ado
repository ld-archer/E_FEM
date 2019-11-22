program define taxsim9
version 9.1
/*
** by Jean Roth , jroth@nber.org
This program uses the NBER TAXSIM model to calculate US and state
income tax liabilities. It calls an external program nc send 
data (in ASCII) to the NBER server and obtain the calculated liabilities.

net from http://www.nber.org/stata
net describe taxsim9
net install taxsim9

*/
display "begin taxsim9.ado on $S_DATE (version 9.0)"
syntax [, Full Secondary Wages Interest Long Output(string) Debug X51 PLAN(integer 0) PLANVal(real 0) Replace local]
if `"`replace'"' == `"replace"' {
     display "TAXSIM results will be merged to original file"
}
** If state doesn't exist, add to original dataset for later merging.
capture confirm variable state
if _rc {
     display "Variable state not found in dataset." 
     display "Generating state = 0 to return federal taxes only."
     generate state = 0
}
if `"`x51'"' == `"x51"' {
     display "Setting state identifier to -1 for confidentiality"
     display "Returning 51 records for every record received"
     capture drop statet
     generate statet = state 
     replace state = -1 
}
*preserve 
if `"`debug'"' != `"debug"' {
     tempfile outfile infile ftp msg
}
else {
     display "Saving input to FORTRAN TAXSIM as txpydata.raw "
     local outfile txpydata.raw 
     display "Saving output from FORTRAN TAXSIM as results.raw "
     local infile results.raw    
     capture erase txpydata.raw
     capture erase results.raw
}
capture { rm `outfile' }
capture { rm `infile'  }
capture { rm ftp.txt   }
capture ( rm msg.txt   }
if length(`"`output'"') == 0 { 
     local output taxsim_out 
} 
display "TAXSIM results will be saved in `output'.dta"
capture drop taxsimid 
if _rc==0 {
   display "Dropping taxsim id."   
}
preserve
capture generate taxsimid = _n

**  mtr is marginal is tax rate.  
local mtr 85           
**  idtl is output. 0 is basic
local idtl 0                   

#delimit ;
**  marginal tax rate options ;
if `"`secondary'"' == `"secondary"' { ;
     local mtr 86 ; 
     display "Marginal rate with respect to secondary earner";
} ;                               
if `"`wages'"' == `"wages"' { ;
     local mtr 11 ;
     display "Marginal rate with respect to overall earnings";
} ;                                
if `"`interest'"' == `"interest"' { ;
     local mtr 14 ;
     display "Marginal rate with respect to interest income";
} ;
if `"`long'"' == `"long"' { ;
     local mtr 70 ;
     display "Marginal rate with respect to long term gains";
} ;

if `"`full'"' == `"full"' { ;
     local idtl 2 ;
     local addvars v10 v11 v12 v13 v14 v15 v16 v17 v18 v19 
                        v20 v21 v22 v23 v24 v25 v26 v27 v28 v29 
                        v30 v31 v32 v33 v34 v35 v36 v37 v38 v39 
                        v40 v41 ;
     display "Full Intermediate Calculations Requested";
} ;
if "`mtr'" == "85" { ;
     display "Marginal rate with respect to primary earner";
} ;
if "`idtl'" == "0" { ;
     display "Basic output";
} ;

if `plan' != 0 {;
   display "Tax law modified according to TAXSIM plan " `plan';
};
if `planval' != 0 {;
   display "Modified tax parameter is " `planval';
};

#delimit cr
** Checking data sent to taxsim for validity
** Checking for observations prior to variables for better error message.
if _N==0 { 
  display "Aborting:  No observations in data set" 
  exit 
}  
local must_exist year mstat  
foreach X of local must_exist { 
  capture confirm var `X' 
  if _rc > 0 { 
       display "Aborting:  Variable `X' not found in data file" 
       exit 
  } 
  capture assert missing(`X') 
  if _rc == 0 { 
     display "Aborting:  All values of variable `X' are missing." 
     exit
  } 
}
#delimit ;
local invars year state mstat depx agex pwages swages dividends otherprop
pensions gssi transfers rentpaid proptax otheritem childcare ui depchild
mortgage ltcg stcg;
#delimit cr

foreach X of local invars { 
  capture confirm var `X' 
  if _rc > 0 { 
     display "Variable `X' is not in the dataset.  Generating `X' = 0 " 
     generate `X' = 0 
  } 
  capture assert missing(`X') 
  if _rc == 0 { 
     display "All values of variable `X' are missing.  Replacing `X' = 0 " 
     replace `X' = 0 
  } 
} 
*display "Checking variables are numeric"
foreach X of local invars {
     capture confirm numeric variable `X'
     if _rc > 0 {
          display "Aborting:  Variable `X' is not numeric.  See help tostring."
          exit 
     }
}
scalar startobs = _N
scalar obs0=_N
quietly drop if year<1960 | year>2013 | year==. 
drop_message obs0-_N year
quietly drop if state<-1 | state > 51 | missing(state)
drop_message obs0-_N state
** The maximum value of year will need updating annually 
quietly drop if (year<1977|year>2011) & state !=0
drop_message obs0-_N state-and-year-combination
quietly drop if depx<0 | depx>999
drop_message obs0-_N depx
quietly drop if mstat<1 | ( mstat>4 & mstat<7 ) | mstat>8
drop_message obs0-_N mstat
quietly drop if agex<0 | agex>2
drop_message obs0-_N agex
quietly drop if depchild<0|depchild>depx 
drop_message obs0-_N depchild
** Replacing spouses wage=0 if not filing jointly
quietly replace swages=0 if mstat!=2
#delimit ;
local positive_items                    dividends pensions  gssi transfers rentpaid
                     proptax otheritem  childcare ui mortgage;
#delimit cr
scalar obs0=_N
foreach X of local positive_items {
   quietly drop if `X'<0 |  `X' >=99999999 | `X'==.
   if (obs0>_N) {
      display obs0-_N " records droped for out of range `X'  
   }
   scalar obs0=_N
}
** display "Checking there is at least 1 observation is left after the final drop"
if _N==0 { 
  display "Aborting:  No observations in data set" 
  exit 
}  

/*
*display "Eliminating scientific notation format in outfile" 
foreach X of local invars {
     format %15.2f `X'
}*/

if `"`debug'"' == `"debug"' {
   display "Here are the variable counts and means after cleaning:"
   summarize `invars'
}

capture describe
di _N " records out of " startobs " are left for taxsim to process"
local sent=_N
** Handling the case of state=-1
local sent51=`sent'*51
quietly tostring taxsimid,replace
quietly replace taxsimid ="9 `mtr' `idtl' `plan' `planval' /" + char(10) + taxsimid in 1

local obs=r(N)
outfile taxsimid `invars' using `outfile',noquote nolabel 

if `"`local'"' == `"local"' {
   ! taxsim9 <`outfile' >`infile'
}
else {
   local servername= "`c(current_time)'"
   local servername = subinstr("`servername'",":","",2)
   di "server filename is `servername'"
   di "         infile is `infile'"
   di "        outfile is `outfile'"
   file open out using ftp.txt, write replace
   local slashck "/C"
   if `"`debug'"' == `"debug"' {
      local slashck "/K"
      di "Type EXIT in DOS window to return to stata."
      file write out "debug" _n
   }
   file write out "open taxsimftp.nber.org" _char(10)
   file write out "user taxsim 02138" _char(10)
   file write out "cd tmp" _char(10)
   file write out "type ascii" _char(10)
   file write out "put `outfile' `servername'" _char(10)
   file write out "get `servername'.taxsim `infile'" _char(10)
   file write out "get `servername'.msg msg.txt" _char(10)
   if _n > 10000 { 
       file write out "del `servername'" _char(10)
   }
   file write out "quit" _char(10)
   file close out
   capture { rm msg.txt }
   di "`c(os)`"
   if "`c(os)'" == "Windows" {
      ! cmd `slashck' ftp -n -s:ftp.txt -w:12888 
   }
   else {
      ! ftp -n <ftp.txt 
   }
   type msg.txt
}
local results taxsimid year state fiitax siitax fica frate srate ficar `addvars'
** The state option can generate many 'cannot be read' errors for non-matching states ;
quietly infile `results' using "`infile'",clear
quietly describe
if ( `r(N)'==0 ) {
   display "This machine may have had trouble communicating with our server"
   display "Consult the Notes and Support section of the help file to begin troubleshooting."
   exit
}
if ( `r(N)'-`sent'>1 & `r(N)'-`sent51'>=1 ) {
   display "This machine may have had trouble communicating with our server"
   display "Check the size and content of the result file (results.raw, by default)" 
   display "If processing stopped midway, the results file may be large"
   display "but if not, the top of the file may include a message from our webserver"
   display "that would be helpful for debugging"
   display "Consult the Notes and Support section of the help file for troubleshooting info"
   display "http://www.nber.org/taxsim/stata/ "
   display "`r(N)'!=`sent' & `r(N)'!=`sent51'"
   exit
}
label variable state  "state id"
label variable fiitax "Federal Income Tax"
label variable siitax "State Income Tax"
label variable fica   "OASDI and HI Payroll Tax"
label variable frate  "IIT marginal rate"
label variable srate  "state marginal rate"
label variable ficar  "SS marginal rate" 
if `"`full'"' == `"full"' { 
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
label variable v39 "State EITC "
label variable v40 "State Total Credits" 
label variable v41 "State Bracket Rate" 
} 
sort taxsimid state  
capture save `output', replace 
restore 
display " "
if `"`replace'"' != `"replace"' {
   display "TAXSIM results are saved in `output'" 
   display " "
   display "To merge the TAXSIM results to the current dataset, run the commands below." 
   display " "
   if `"`x51'"' == `"x51"' {
      display "generate taxsimid = _n" 
      display "replace state=statet"
      display "sort taxsimid state"
      display "merge taxsimid state using `output', nokeep replace update"
      display "drop statet _merge"
   }
   else {
      display "generate taxsimid = _n"
      display "sort taxsimid"
      display "merge taxsimid using `output',replace update"
   }
   display " "
   display "To avoid merging by hand, rerun with the replace option "
   display "to automatically merge the datasets."
}
else {
   capture drop taxsimid _merge
   capture generate taxsimid = _n
   if `"`x51'"' == `"x51"' {
      display "TAXSIM results are being merged with workspace by taxsimid state"
      replace state = statet
      sort taxsimid state
      merge taxsimid state using `output',replace update
      display "Keeping only matching state data"
      drop if statet==.
      drop statet _merge
   }
   else {
      display "TAXSIM results are being merged with workspace by taxsimid"
      sort taxsimid 
      merge taxsimid using `output',replace update
      drop _merge
   }
}
display " "
end
  
program define drop_message, rclass 
version 8.0
args dropped varname
if (`dropped'>0) {
   display `dropped' %8.0g " records dropped for out of range `varname'"
}
scalar obs0 =_N
end
 
