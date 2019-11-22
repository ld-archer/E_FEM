/*************************************************
gkcare_tabs.sas

Do some tables on hours taking care of grandkids last 2 years.

**************************************************/

options ls=200 ps=82 compress=yes nocenter replace nodate nonumber mprint nofmterr;

%include "../../../fem_env.sas";  /* file to set up libnames, fmt/mac locations */

libname imp "&outlib";
libname hrs "&hrslib";
libname library "&hrslib";

** file containing wave-specific asset bracket information **;
   
%let pgm=gkcarehours;  /* program name, for lst files,  separated by year */

%include "&maclib.wvlist.mac";
%include "&maclib.wvlabel.mac";

proc format;
   value byrcat
   1850-1919="<1919"
   1920-1929="1920-1929"
   1930-1939="1930-1939"
   1940-1949="1940-1949"
   1950-2000="1950 +"
   ;
   value byrcoh
   1850-1923="<1924"
   1924-1930="1924-1930"
   1931-1935="1931-1935"
   1936-1941="1936-1941"
   1942-1947="1942-1947"
   1948-1953="1948-1953"
   1954-2000="1954 +"
   ;
   value agecat
   1-50="<51"
   51-55="51-55"
   56-60="56-60"
   61-65="61-65"
   66-70="66-70"
   71-75="71-75"
   76-80="76-80"
   81-150=">80"
   ;
   value racer
   1="White"
   2="Black"
   3="Other"
   4="Hispanic"
   ;
data tmp;
   merge imp.gkcarehours (in=_in1)
         hrs.rndhrs_&rndv (keep=hhidpn inw: %wvlist(r,agey_e wtresp) 
                                ragender raracem rahispan raeduc rabyear)
         ;
    by hhidpn;
    if _in1;
    race=raracem;
    if rahispan=1 then race=4;
run;

title Grandkid care hours;
ods html file="gcare_tabs.xls" style=minimal;
proc means data=tmp n mean stddev min p25 median p75 max;
title2 Unweighted;
   class ragender race raeduc rabyear;
   types () ragender race raeduc;
   var %wvlist(r,anygkcare gkcarehrs,begwv=4) aigkcare: ;
format rabyear byrcat. race racer.;
run;
ods html close;

%macro meanit (bw,ew,byear);

%let year=&byear;

%do w=&bw %to &ew;

   title2 for &year;
   proc means data=tmp (where=(inw&w=1)
                        rename=(r&w.anygkcare=anygkcare
                                r&w.gkcarehrs=gkcarehrs
                                r&w.agey_e=age
                                aigkcare%substr(&year,3,2)=gkcarehrs_ifany));
      class ragender race raeduc age;
      types () ragender race raeduc age;
      var anygkcare gkcarehrs gkcarehrs_ifany;
      weight r&w.wtresp;
      format age agecat.;
      format race racer.;
      output out=stats&year mean=anyMN hrMN condhrMN 
                            N=anyN hrN condhrN 
                            stddev=anySD hrSD condhrSD
                            min=anymin hrmin condhrmin
                            max=anymax hrmax condhrmax
                            median=anymed hrmed condhrmed
      ;
   run;
   data stats&year;
      set stats&year;
      length byv $ 10;
      year=&year;
      if max(ragender,race,raeduc,age)=. then byv="All";
      else if ragender ne . then byv="Gender";
      else if race ne . then byv="Race";
      else if raeduc ne . then byv="Education";
      else if age ne . then byv="Age";
      run;
   %let year=%eval(&year+2);
%end;
%mend;

%meanit(4,9,1998)

data tabs;
   set stats1998 stats2000 stats2002 stats2004 stats2006 stats2008;
run;
proc sort data=tabs;
 by byv year ragender race raeduc age;
ods html file="gcare_tabs_yr.xls" style=minimal;
proc print data=tabs noobs label;
   id byv;
   id ragender race raeduc age;
   var year
       anyN anyMN anySD anymin anymed anymax
            hrMN hrSD hrmin hrmed hrmax
       condhrN condhrMN condhrSD condhrmin condhrmed condhrmax
       ;
   format anyN condhrN 6.0 
          anyMN percent8.1 anySD anymin anymed anymax 6.3
          hrMN hrSD condhrMN condhrSD 7.1
       hrmin hrmed hrmax 
       condhrmin condhrmed condhrmax  7.0
    ;
   label anyN="N"
         anyMN="Whether / mean"
         anySD="Whether / SD"
         anymin="Whether / min"
         anymed="Whether / median"
         anymax="Whether / max"
         hrMN="Hours - uncond / mean"
         hrSD="Hours - uncond / SD"
         hrmin="Hours - uncond / min"
         hrmed="Hours - uncond / median"
         hrmax="Hours - uncond / max"
         anyN="N"
         condhrMN="Hours - if any / mean"
         condhrSD="Hours - if any / SD"
         condhrmin="Hours - if any / min"
         condhrmed="Hours - if any / median"
         condhrmax="Hours - if any / max"
      ;
run;
ods html close;