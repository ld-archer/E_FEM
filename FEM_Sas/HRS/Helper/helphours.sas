/** \file helphours.sas

Merge total hours helped last month across years.

Make a stata data set.

July 2012: added help hours separated by spouse and non-spouse.

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
   
%let pgm=helphours;  /* program name, for lst files,  separated by year */

%include "&maclib.wvlist.mac";

data imp.helphours (compress=no);
   merge imp.helpimpR98
         imp.helpimpR00
         imp.helpimpR02
         imp.helpimpR04
         imp.helpimpR06
         imp.helpimpR08
         imp.helpimpR10
         imp.helpimpR12
         imp.helpimpR14
         hrs.rndhrs_&rndv (keep=hhidpn inw4-inw&maxwv)
         ;
    by hhidpn;
    
    if max(of inw4-inw&maxwv)=1;
    
    array inw_[4:&maxwv] inw4-inw&maxwv;
    array hours_[4:&maxwv] %wvlist(r,helphoursyr,begwv=4);
    array hourscalc_[4:&maxwv] %wvlist(r,helphoursyr_calc,begwv=4);
    array helperct_[4:&maxwv] %wvlist(r,helperct,begwv=4);

    array sphours_[4:&maxwv] %wvlist(r,helphoursyr_sp,begwv=4);
    array sphourscalc_[4:&maxwv] %wvlist(r,helphoursyr_calc_sp,begwv=4);

    array nonsphours_[4:&maxwv] %wvlist(r,helphoursyr_nonsp,begwv=4);
    array nonsphourscalc_[4:&maxwv] %wvlist(r,helphoursyr_calc_nonsp,begwv=4);
    array nonsphelperct_[4:&maxwv] %wvlist(r,helperct_nonsp,begwv=4);
    
    /* fill with zeros if no help */
    do i=4 to &maxwv;
       if inw_[i]=1 then do;
          hours_[i]=max(0,hours_[i]);
          hourscalc_[i]=max(0,hourscalc_[i]);
          helperct_[i]=max(0,helperct_[i]);

          sphours_[i]=max(0,sphours_[i]);
          sphourscalc_[i]=max(0,sphourscalc_[i]);

          nonsphours_[i]=max(0,nonsphours_[i]);
          nonsphourscalc_[i]=max(0,nonsphourscalc_[i]);
          nonsphelperct_[i]=max(0,nonsphelperct_[i]);
       end;
    end;
    keep hhidpn %wvlist(r,helphoursyr helphoursyr_calc 
                          helphoursyr_sp helphoursyr_calc_sp 
                          helphoursyr_nonsp helphoursyr_calc_nonsp 
                          helperct helperct_nonsp,begwv=4);
run;
proc means data=imp.helphours;
proc contents data=imp.helphours;
run;
