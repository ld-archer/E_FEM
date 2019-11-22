/*************************************************
helphoursM.sas

Make some tables of hours by age for 2004 (Wave 7)

For MacArthur meetings Feb 2012.
**************************************************/

options ls=200 ps=82 compress=yes nocenter replace nodate nonumber mprint nofmterr;

%include "../../../fem_env.sas";  /* file to set up libnames, fmt/mac locations */

libname imp "&outlib";
libname hrs "&hrslib";
libname library "&hrslib";

** file containing wave-specific asset bracket information **;
proc format;
   value relimp
   1="1.spouse"
   2="2.kid"
   3="3.grandkid"
   4="4.parent/sibling"
   5="5.other rel"
   6="6.nonrel"
   ;
   value agecat
   51-60="51-60"
   61-70="61-70"
   71-80="71-80"
   81-120="81+"
   ;
%let pgm=helphoursM;  /* program name, for lst files,  separated by year */
%let yr=04;
%let w=7;

%include "&maclib.wvlist.mac";
title "Helper Hours per Year 20&yr";
data helphours;
   merge imp.helphours (in=_inh keep=hhidpn r&w.helphoursyr r&w.helperct 
                        where=(r&w.helperct ge 0))
         hrs.rndhrs_&rndv (keep=hhidpn inw&w r&w.agey_e r&w.wtresp 
                                ragender raracem raeduc h&w.cpl
                           where=(inw&w=1))
   ;
    by hhidpn;
    inhlp=_inh;
run;
proc freq data=helphours;
   table inw&w inhlp
      /missing list;
      run;
title2 Weighted distribution by age, unconditional;
proc means data=helphours
   n sumwgt stdev min p25 median p75 max;
   class r&w.agey_e;
   format r&w.agey_e agecat.;
   var r&w.helphoursyr;
   weight r&w.wtresp;
run;

title2 Weighted distribution by age, conditional on getting help;
proc means data=helphours
   n sumwgt stdev min p25 median p75 max;
   class r&w.agey_e;
   format r&w.agey_e agecat.;
   var r&w.helphoursyr;
   weight r&w.wtresp;
run;
