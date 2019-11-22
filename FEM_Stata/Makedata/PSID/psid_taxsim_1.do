*PSID_TAXSIM_1of2 -- Mortgage interest for itemized deduction (dofile 1 of 2)

********************************************************************************
*This program is the first of two Stata programs used to calculate income and payroll taxes
*from Panel Survey of Income Dynamics data using the NBER's Internet TAXSIM version 9
*(http://users.nber.org/~taxsim/taxsim9/), for PSID survey years 1999, 2001, 2003, 2005,
*2007, 2009, and 2011 (tax years n-1).

*The main program (PSID_TAXSIM_2of2) was written by Sara Kimberlin (skimberlin@berkeley.edu)
*and generates all TAXSIM input variables, runs TAXSIM, adjusts tax estimates using additional
*information available in PSID data, and calculates total PSID family unit taxes. 

*The program below (PSID_TAXSIM_1of2) was written by Jiyoon (June) Kim (junekim@umich.edu)
*in collaboration with Luke Shaefer (lshaefer@umich.edu) to calculate mortgage interest for 
*itemized deductions; this program needs to be run first, before the main program.

*A more complete description of the overall method for calculating taxes from PSID data 
*using TAXSIM is included in the main program and in an accompanying memo.

********************************************************************************
*The program below was written by Jiyoon (June) Kim (junekim@umich.edu), in collaboration
*	with Luke Shaefer (lshaefer@umich.edu), and slightly modified by Sara Kimberlin. Special 
*	thanks to Jonathan Latner for the code to use this program with the zipped PSID data files. 
*	Last updated May 2015.

*Calculates mortgage interest for itemized deduction. Accounts for both first and
*	second mortgages. Assumes all mortgages are fixed-rate. A more detailed description
*	can be found in the accompanying memo.

*For PSID survey years 1999, 2001, 2003, 2005, 2007, 2009, 2011 (tax years n-1).
********************************************************************************
********************************************************************************

*This program is designed to be used with the PSID zipped public use Main Interview data files available for 
*download from the PSID website at http://simba.isr.umich.edu/Zips/ZipMain.aspx.
*	Files needed to run the program include:
*		*	the Family data files for years 1999, 2001, 2003, 2005, 2007, 2009, and 2011, and
*		*   the Cross-Year Individual data file (labeled with the most recent year, i.e. 2011)
* 	Family data files should be saved in the following format: FAMXXXX.dta, where XXXX is year.
* 	The Individual data file should be saved in the following format: indxxxxer.dta, where XXXX is year. 


include common.do


* Enter the date:
global datestamp 102517

***********************

clear all
set more off

/*INDIVIDUAL DATA*/
use "$psid_dir/Stata/ind${lastyr}er.dta", clear	


#delimit;
keep 
ER30001 /*FAMNO FROM 1968*/
ER30002 /*PERSONNO FROM 1968*/
/*1999	2001	2003	2005	2007	2009	2011	*/
ER33501 ER33601 ER33701 ER33801 ER33901 ER34001 ER34101 /*INTERVIEW NUMBER*/
;
#delimit cr     

* Creating unique person id
gen personid= (ER30001*1000) + ER30002
sort personid

rename ER33501 famno1999
rename ER33601 famno2001
rename ER33701 famno2003
rename ER33801 famno2005
rename ER33901 famno2007
rename ER34001 famno2009
rename ER34101 famno2011

save $outdata/ind.dta, replace

/* MERGING IN FAMILY DATA */

/*1999*/
u ER13002 ER13042 ER13043 ER13044 ER13045 ER13048 ER13049 ER13050 ER13051 ER13052 ER13053 ER13054 ER13057 ER13058 ER13059 ER13060 ER13061 ER13063 ER13064 ER13006 using $psid_dir/Stata/fam1999er,clear

rename ER13002  famno1999        
rename ER13042  yrproptax1999
rename ER13043  insprm1999
rename ER13044  mort1_1999                        
rename ER13045  mortype1_1999                         
rename ER13048  mthpmt1_1999
rename ER13049  intr1_1999
rename ER13050  intrdec1_1999
rename ER13051  yrobt1_1999
rename ER13052  yrstopay1_1999                 
rename ER13053  mort2_1999                         
rename ER13054  mortype2_1999                                     
rename ER13057  mthpmt2_1999                   
rename ER13058  intr2_1999  
rename ER13059  intrdec2_1999   
rename ER13060  yrobt2_1999
rename ER13061  yrstopay2_1999                                    
rename ER13063  proptaxincl_1999   
rename ER13064  insprmincl_1999              
rename ER13006  intv1999
/*MERGE FAMILY DATA AND INDIVIDUAL DATA*/
merge 1:m famno1999 using $outdata/ind, keep ( using matched )
drop _m
sort personid
/*SAVE*/
save        $outdata/fam1999,replace

/*2001*/
u ER17002 ER17046 ER17048 ER17049 ER17050 ER17054 ER17056 ER17057 ER17058 ER17059 ER17060 ER17061 ER17065 ER17067 ER17068 ER17069 ER17070 ER17072 ER17073 ER17009 using $psid_dir/Stata/fam2001er,clear
rename ER17002  famno2001               
rename ER17046  yrproptax2001 
rename ER17048  insprm2001             
rename ER17049  mort1_2001                                             
rename ER17050  mortype1_2001                               
rename ER17054  mthpmt1_2001                   
rename ER17056  intr1_2001
rename ER17057  intrdec1_2001 
rename ER17058  yrobt1_2001
rename ER17059  yrstopay1_2001                                      
rename ER17060  mort2_2001                                                  
rename ER17061  mortype2_2001                                                               
rename ER17065  mthpmt2_2001                                
rename ER17067  intr2_2001  
rename ER17068  intrdec2_2001     
rename ER17069  yrobt2_2001
rename ER17070  yrstopay2_2001                                                                
rename ER17072  proptaxincl_2001    
rename ER17073  insprmincl_2001                         
rename ER17009  intv2001     
/*MERGE FAMILY DATA AND INDIVIDUAL DATA*/
merge 1:m famno2001 using $outdata/ind, keep ( using matched )
drop _m
sort personid
/*SAVE*/
save        $outdata/fam2001,replace

/*2003*/
u ER21002 ER21045 ER21047 ER21048 ER21049 ER21053 ER21055 ER21056 ER21057 ER21058 ER21059 ER21060 ER21064 ER21066 ER21067 ER21068 ER21069 ER21070 ER21071 ER21012 using $psid_dir/Stata/fam2003er,clear
rename ER21002  famno2003                
rename ER21045  yrproptax2003  
rename ER21047  insprm2003               
rename ER21048  mort1_2003                                                
rename ER21049  mortype1_2003                                                               
rename ER21053  mthpmt1_2003                   
rename ER21055  intr1_2003
rename ER21056  intrdec1_2003   
rename ER21057  yrobt1_2003
rename ER21058  yrstopay1_2003                                                
rename ER21059  mort2_2003                                                 
rename ER21060  mortype2_2003                                                                    
rename ER21064  mthpmt2_2003                                    
rename ER21066  intr2_2003    
rename ER21067  intrdec2_2003   
rename ER21068  yrobt2_2003
rename ER21069  yrstopay2_2003                                                                
rename ER21070  proptaxincl_2003   
rename ER21071  insprmincl_2003                         
rename ER21012  intv2003  
/*MERGE FAMILY DATA AND INDIVIDUAL DATA*/
merge 1:m famno2003 using $outdata/ind, keep ( using matched )
drop _m
sort personid
/*SAVE*/
save        $outdata/fam2003,replace

/*2005*/
u ER25002 ER25036 ER25038 ER25039 ER25040 ER25044 ER25046 ER25047 ER25048 ER25049 ER25050 ER25051 ER25055 ER25057 ER25058 ER25059 ER25060 ER25061 ER25062 ER25012 using $psid_dir/Stata/fam2005er,clear
rename ER25002  famno2005                 
rename ER25036  yrproptax2005  
rename ER25038  insprm2005               
rename ER25039  mort1_2005                                            
rename ER25040  mortype1_2005                                                         
rename ER25044  mthpmt1_2005                  
rename ER25046  intr1_2005
rename ER25047  intrdec1_2005    
rename ER25048  yrobt1_2005
rename ER25049  yrstopay1_2005                                  
rename ER25050  mort2_2005                                                 
rename ER25051  mortype2_2005                                                               
rename ER25055  mthpmt2_2005                                   
rename ER25057  intr2_2005   
rename ER25058  intrdec2_2005      
rename ER25059  yrobt2_2005
rename ER25060  yrstopay2_2005                                                                  
rename ER25061  proptaxincl_2005      
rename ER25062  insprmincl_2005                             
rename ER25012  intv2005  
/*MERGE FAMILY DATA AND INDIVIDUAL DATA*/
merge 1:m famno2005 using $outdata/ind, keep ( using matched )
drop _m
sort personid
/*SAVE*/
save        $outdata/fam2005,replace

/*2007*/
u ER36002 ER36036 ER36038 ER36039 ER36040 ER36044 ER36046 ER36047 ER36049 ER36050 ER36051 ER36052 ER36056 ER36058 ER36059 ER36061 ER36062 ER36063 ER36064 ER36012 using $psid_dir/Stata/fam2007er,clear
rename ER36002  famno2007              
rename ER36036  yrproptax2007      
rename ER36038  insprm2007        
rename ER36039  mort1_2007                                            
rename ER36040  mortype1_2007                                                          
rename ER36044  mthpmt1_2007             
rename ER36046  intr1_2007 
rename ER36047  intrdec1_2007  
rename ER36049  yrobt1_2007
rename ER36050  yrstopay1_2007                                        
rename ER36051  mort2_2007                                                   
rename ER36052  mortype2_2007                                                                   
rename ER36056  mthpmt2_2007                                      
rename ER36058  intr2_2007   
rename ER36059  intrdec2_2007          
rename ER36061  yrobt2_2007
rename ER36062  yrstopay2_2007                                                               
rename ER36063  proptaxincl_2007  
rename ER36064  insprmincl_2007                              
rename ER36012  intv2007  
/*MERGE FAMILY DATA AND INDIVIDUAL DATA*/
merge 1:m famno2007 using $outdata/ind, keep ( using matched )
drop _m
sort personid
/*SAVE*/
save        $outdata/fam2007,replace

/*2009*/
u ER42002 ER42037 ER42039 ER42040 ER42041 ER42045 ER42047 ER42048 ER42050 ER42051 ER42059 ER42060 ER42064 ER42066 ER42067 ER42069 ER42070 ER42078 ER42079 ER42012 using $psid_dir/Stata/fam2009er,clear
rename ER42002  famno2009                      
rename ER42037  yrproptax2009 
rename ER42039  insprm2009                                 
rename ER42040  mort1_2009                                                               
rename ER42041  mortype1_2009                                                                                             
rename ER42045  mthpmt1_2009                             
rename ER42047  intr1_2009 
rename ER42048  intrdec1_2009   
rename ER42050  yrobt1_2009
rename ER42051  yrstopay1_2009                                                                              
rename ER42059  mort2_2009                                                                          
rename ER42060  mortype2_2009                                                                                                   
rename ER42064  mthpmt2_2009                                                         
rename ER42066  intr2_2009   
rename ER42067  intrdec2_2009             
rename ER42069  yrobt2_2009
rename ER42070  yrstopay2_2009                                                                                            
rename ER42078  proptaxincl_2009     
rename ER42079  insprmincl_2009                                           
rename ER42012  intv2009  
/*MERGE FAMILY DATA AND INDIVIDUAL DATA*/
merge 1:m famno2009 using $outdata/ind, keep ( using matched )
drop _m
sort personid
/*SAVE*/
save        $outdata/fam2009,replace

/*2011*/
u ER47302 ER47342 ER47344 ER47345 ER47346 ER47350 ER47352 ER47353 ER47355 ER47356 ER47357 ER47358 ER47366 ER47367 ER47371 ER47376 ER47377 ER47378 ER47379 ER47312 using $psid_dir/Stata/fam2011er,clear
rename ER47302  famno2011                       
rename ER47342  yrproptax2011    
rename ER47344  insprm2011                            
rename ER47345  mort1_2011                                                                   
rename ER47346  mortype1_2011                                                                                            
rename ER47350  mthpmt1_2011                                
rename ER47352  proptaxinc1_2011  
rename ER47353  insprminc1_2011                                             
rename ER47355  intr1_2011 
rename ER47356  intrdec1_2011   
rename ER47357  yrobt1_2011
rename ER47358  yrstopay1_2011                                                                        
rename ER47366  mort2_2011                                                                   
rename ER47367  mortype2_2011                                                                                             
rename ER47371  mthpmt2_2011                                                                                                 
rename ER47376  intr2_2011      
rename ER47377  intrdec2_2011       
rename ER47378  yrobt2_2011
rename ER47379  yrstopay2_2011                                           
rename ER47312  intv2011
/*MERGE FAMILY DATA AND INDIVIDUAL DATA*/
merge 1:m famno2011 using $outdata/ind, keep ( using matched )
drop _m
sort personid
/*SAVE*/
save        $outdata/fam2011,replace

/*MERGE FAMILY DATA*/
use $outdata/fam1999, clear
foreach i in 2001 2003 2005 2007 2009 2011 {
merge 1:1 personid using $outdata/fam`i', nogen
}

/*DELETE OLD FAMILY DATA*/
foreach i in 1999 2001 2003 2005 2007 2009 2011 {
rm $outdata/fam`i'.dta
}

/*SAVE FAMILY AND INDIVIDUAL DATA*/
save "$outdata/mortint_vargen_$datestamp", replace


/* CLEANSE VARIABLES */

clear all
set more off
use "$outdata/mortint_vargen_$datestamp", clear

codebook yrproptax1999
codebook mthpmt1_1999

forvalues i=1999(2)2011 {
replace yrproptax`i'=. if yrproptax`i'>99996
replace mort1_`i'=. if mort1_`i'>5
replace mort1_`i'=0 if mort1_`i'==5
replace mort2_`i'=. if mort2_`i'>5
replace mort2_`i'=0 if mort2_`i'==5
replace mortype1_`i'=. if mortype1_`i'>=7
replace mortype2_`i'=. if mortype2_`i'>=7
replace mthpmt1_`i'=. if mthpmt1_`i'>99997
replace mthpmt2_`i'=. if mthpmt2_`i'>99997
replace intr1_`i'=. if intr1_`i'>97
replace intrdec1_`i'=. if intrdec1_`i'>990
replace intr2_`i'=. if intr2_`i'>97
replace intrdec2_`i'=. if intrdec2_`i'>990
replace yrobt1_`i'=. if yrobt1_`i'>9990|yrobt1_`i'==1919|yrobt1_`i'==0
replace yrobt2_`i'=. if yrobt2_`i'>9990|yrobt2_`i'==1919|yrobt2_`i'==0
replace yrstopay1_`i'=. if yrstopay1_`i'>97
replace yrstopay2_`i'=. if yrstopay2_`i'>97
replace insprm`i'=. if insprm`i'>9997
}

forvalues i=1999(2)2011 {
gen monintr1_`i'=(intr1_`i'+intrdec1_`i'/1000)/12/100
gen monintr2_`i'=(intr2_`i'+intrdec2_`i'/1000)/12/100
gen montopay1_`i'=yrstopay1_`i'*12
gen montopay2_`i'=yrstopay2_`i'*12
}

forvalues i=1999(2)2009 {
replace insprmincl_`i'=. if insprmincl_`i'>5
replace proptaxincl_`i'=. if proptaxincl_`i'>5
}

forvalues i=2011/2011 {
replace insprminc1_`i'=. if insprminc1_`i'>5
replace proptaxinc1_`i'=. if proptaxinc1_`i'>5
}


forvalues i=1999(2)2009 {
replace mthpmt1_`i' = mthpmt1_`i' *12 if !missing(mthpmt1_`i') & mthpmt1_`i' !=0
replace mthpmt1_`i' = mthpmt1_`i' - insprm`i' if insprmincl_`i' ==1 & !missing(insprm`i')
replace mthpmt1_`i' = mthpmt1_`i' - yrproptax`i' if proptaxincl_`i' ==1 & !missing(yrproptax`i')
replace mthpmt1_`i' = . if missing(insprmincl_`i') | missing(proptaxincl_`i') | (missing(insprm`i') & insprmincl_`i' ==1) | (missing(yrproptax`i') & proptaxincl_`i' ==1)
replace mthpmt1_`i' = . if mthpmt1_`i' <0
replace mthpmt1_`i' = mthpmt1_`i' / 12
}

forvalues i=2011/2011 {
replace mthpmt1_`i' = mthpmt1_`i' *12 if !missing(mthpmt1_`i') & mthpmt1_`i' !=0
replace mthpmt1_`i' = mthpmt1_`i' - insprm`i' if insprminc1_`i' ==1 & !missing(insprm`i')
replace mthpmt1_`i' = mthpmt1_`i' - yrproptax`i' if proptaxinc1_`i' ==1 & !missing(yrproptax`i')
replace mthpmt1_`i' = . if missing(insprminc1_`i') | missing(proptaxinc1_`i') | (missing(insprm`i') & insprminc1_`i' ==1) | (missing(yrproptax`i') & proptaxinc1_`i' ==1)
replace mthpmt1_`i' = . if mthpmt1_`i' <0
replace mthpmt1_`i' = mthpmt1_`i' / 12
}

forvalues i=1999(2)2011 {
replace mthpmt2_`i' = mthpmt2_`i' *12 if !missing(mthpmt2_`i') & mthpmt2_`i' !=0
replace mthpmt2_`i' = . if mthpmt2_`i' <0
replace mthpmt2_`i' = mthpmt2_`i' / 12
}


save "$outdata/mortint_vargen_$datestamp", replace


/*estimate the amount of interest accrued in each month of the previous year  */

/* mortgage 1 */

forvalues i=1999(2)2011 {

clear all
set more off
use  "$outdata/mortint_vargen_$datestamp", clear
keep if intv`i'!=.
keep if mort1_`i'==1 & mortype1_`i'==1
gen diff=`i'-yrobt1_`i'
gen r=1+monintr1_`i'

forvalues b=1/12 {
local a=`i'-1
gen n=.
replace n=12-`b'+intv`i'+ montopay1_`i' if (diff>=2) | (diff==1 & `b'>6)

gen p`b'_no1_`a' = mthpmt1_`i' * (r^n-1)/(monintr1_`i'*(r^n)) if (diff>=2) | (diff==1 & `b'>6)
replace  p`b'_no1_`a'=0 if (diff==0) | (diff==1 & `b'<=6)

gen int`b'_no1_`a'=p`b'_no1_`a'*(r-1)

drop n
}


save "$outdata/mortint`i'_1_$datestamp.dta", replace

}


/* mortgage 2 */

forvalues i=1999(2)2011 {

clear all
set more off
use  "$outdata/mortint_vargen_$datestamp", clear
keep if intv`i'!=.
keep if mort2_`i'==1 & mortype2_`i'==1
gen diff=`i'-yrobt2_`i'
gen r=1+monintr2_`i'

forvalues b=1/12 {
local a=`i'-1
gen n=.
replace n=12-`b'+intv`i'+ montopay2_`i' if (diff>=2) | (diff==1 & `b'>6)

gen p`b'_no2_`a' = mthpmt2_`i' * (r^n-1)/(monintr2_`i'*(r^n)) if (diff>=2) | (diff==1 & `b'>6)
replace  p`b'_no2_`a'=0 if (diff==0) | (diff==1 & `b'<=6)

gen int`b'_no2_`a'=p`b'_no2_`a'*(r-1)


drop n
}


save "$outdata/mortint`i'_2_$datestamp.dta", replace

}

/* merge data sets */
/* sum that up for an annual total */

forvalues i=1999(2)2011 {
clear all 
set more off
use "$outdata/mortint`i'_1_$datestamp", clear  // var=236, obs=2784
merge 1:1 personid using "$outdata/mortint`i'_2_$datestamp"  // var=236, obs=73
drop _merge
local a=`i'-1
egen interestsum=rowtotal(int1_no1_`a' int2_no1_`a' int3_no1_`a' int4_no1_`a' int5_no1_`a' int6_no1_`a' int7_no1_`a' int8_no1_`a' int9_no1_`a' int10_no1_`a' int11_no1_`a' int12_no1_`a' int1_no2_`a' int2_no2_`a' int3_no2_`a' int4_no2_`a' int5_no2_`a' int6_no2_`a' int7_no2_`a' int8_no2_`a' int9_no2_`a' int10_no2_`a' int11_no2_`a' int12_no2_`a')
sum interestsum, d

save "$outdata/mortint`i'_sum_$datestamp", replace


}

/*Creating output file with all annual totals */

use "$outdata/mortint_vargen_$datestamp", clear

keep personid ER30001 ER30002
save "$outdata/mortint_output_$datestamp", replace

forvalues i=1999(2)2011 {

merge 1:1 personid using "$outdata/mortint`i'_sum_$datestamp", keepusing(interestsum)
drop _merge
rename interestsum m`i'intdeduc

save "$outdata/mortint_output_$datestamp", replace
}

save "$outdata/mortint_output_$datestamp", replace
