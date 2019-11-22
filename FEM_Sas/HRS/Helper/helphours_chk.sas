/*************************************************
helphours_chk.sas

check that spouse hours and non-spouse hours total helphours

**************************************************/

options ls=200 ps=82 compress=yes nocenter replace nodate nonumber mprint nofmterr;

%include "../../../fem_env.sas";  /* file to set up libnames, fmt/mac locations */

libname imp "&outlib";
libname hrs "&hrslib";

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

%include "&maclib.wvlist.mac";
title "Helper Hours per Year 20&yr";
data helphours;
   set imp.helphours;

    array hours_[4:&maxwv] %wvlist(r,helphoursyr,begwv=4);
    array hourscalc_[4:&maxwv] %wvlist(r,helphoursyr_calc,begwv=4);
    array helperct_[4:&maxwv] %wvlist(r,helperct,begwv=4);

    array sphours_[4:&maxwv] %wvlist(r,helphoursyr_sp,begwv=4);
    array sphourscalc_[4:&maxwv] %wvlist(r,helphoursyr_calc_sp,begwv=4);

    array nonsphours_[4:&maxwv] %wvlist(r,helphoursyr_nonsp,begwv=4);
    array nonsphourscalc_[4:&maxwv] %wvlist(r,helphoursyr_calc_nonsp,begwv=4);
    array nonsphelperct_[4:&maxwv] %wvlist(r,helperct_nonsp,begwv=4);

    array smhours_[4:&maxwv] smhours4-smhours&maxwv;

    anydif=0;
    do i=4 to &maxwv;
       if hours_[i] ne . then do;
          smhours_[i]=(sum(sphours_[i],nonsphours_[i]) = hours_[i]);
          if smhours_[i]=0 then anydif=1;
       end;
    end;    
run;
proc freq data=helphours;
   table anydif smhours4-smhours&maxwv
      /missing list;
      run;
proc print data=helphours (where=(anydif=1) obs=20);
   id hhidpn;
   var anydif smhours4-smhours&maxwv 
       %wvlist(r,helphoursyr helphoursyr_sp helphoursyr_nonsp,begwv=4);
run;