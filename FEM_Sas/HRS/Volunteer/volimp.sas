/*************************************************
Wave-specific imputation program

Specifies wave number, directory mapping, 
file references, covariate list, asset list

weihanch 3/2015, update the macro to fix the wave-specific imputation through year 2012
**************************************************/

options ls=120 ps=58 nocenter replace nofmterr compress=yes mprint;

%include "../../../fem_env.sas";  /* file to set up libnames, fmt/mac locations */

libname imp "&outlib";
libname hrs "&hrslib";

proc format;
   %include "&fmtlib.wealth.fmt";
   
%include "macros04.inc";

** assets to impute **;

** variable-specific code for any variable with no continuous reporter
   which still needs imputation.  Gets parameters of similar variable 
   and generates normal random variates **;

%let hotcode = no reporters.inc;

** number of principal components to use **;
%let pcn=10;

** number to use with random seed **;
%let seed=1021;

** selected covariates **;

%macro impit(w,yr,yrd=);

   proc printto print="volimp&yr..lst" new;
   
   %if &yr=98 | &yr=00 | &yr=02 %then %do;
      ** file containing wave-specific asset bracket information **;
      %include "ranges_9802.inc";
   %end;
   %else %do;
      ** file containing wave-specific asset bracket information **;
      %include "ranges_04f.inc";
   %end;
   
   title "HRS Volunteer Hours Imputations: HRS&yr";
   
   %let assets= volun hlpff;
   %let selcov=age agesq cpl male
           hispan black othrace lths hsgrad college
           shltgood shltfpoor anyiadl anyadl work retired disabled
           neng midatl encent wncent satl escent wscent mountain pacific notus
           loginc logwlth
           catholic jewish relnone reloth rel_notimp rel_someimp
           suburb exurb;
   
   %let improces =0;       
   
** Get dataset with prepared imputation variables and covariates **;

  %if &yr=98 | &yr=00 | &yr=02 %then %do;

    data workds;
      set imp.prep_vol&yr (keep=hhidpn volcap hlpcap _volhrs _hlphrs
                            d_volun divolun a_volun i_volun abtvolun infvolun
                            clvolun cuvolun ccvolun civolun lovolun upvolun
                            d_hlpff dihlpff a_hlpff i_hlpff abthlpff infhlpff
                            clhlpff cuhlpff cchlpff cihlpff lohlpff uphlpff
                            &selcov);
      improces=0;
      %let hhid=hhidpn;
    run;

  %end;

  %else %do;

    /* for 2004+ we need to have another year provide continuous donors
       workds2 will be used for imputing amounts, with other year donors
       workds will be used for imputing owners, brackets, just within curr year */
    data workds workdonor;  
      set imp.prep_vol&yr (in=_in&yr keep=hhidpn volcap hlpcap _volhrs _hlphrs
                            d_volun divolun a_volun i_volun abtvolun infvolun
                            clvolun cuvolun ccvolun civolun lovolun upvolun
                            d_hlpff dihlpff a_hlpff i_hlpff abthlpff infhlpff
                            clhlpff cuhlpff cchlpff cihlpff lohlpff uphlpff
                            &selcov)
         /* include source from 2002 for hours, not asked in 2004+ */
         imp.volimp&yrd (in=_ind keep=hhidpn volcap hlpcap
                            d_volun divolun a_volun i_volun abtvolun infvolun aivolun
                            clvolun cuvolun ccvolun civolun lovolun upvolun
                            d_hlpff dihlpff a_hlpff i_hlpff abthlpff infhlpff aihlpff
                            clhlpff cuhlpff cchlpff cihlpff lohlpff uphlpff
                            &selcov);

       donorvol=_ind;
       impin=_in&yr;

        /* if from donor year, don't impute. Let it go as is, improces=1 
           Also fake out the cc-brackt category, to include one for a breakpoint of 50
           Originally earlier years just had breakpoints at 100,200 */
       if donorvol=1 then do;
          
          improces=1;
          
          if d_volun=1 then do;
             svccvol=ccvolun;
             i_volun=2;
             a_volun=aivolun;
             infvolun=1;
             if ccvolun in (2,3) then ccvolun=ccvolun+1;
             else if ccvolun in (20,30) then ccvolun=ccvolun+10;
             else if aivolun=50 then ccvolun=20;
             else if aivolun>50 and ccvolun=1 then ccvolun=2;
             
             /* add fake bracket at 1000 hours */
             if aivolun=1000 then ccvolun=50;
             else if aivolun>1000 then ccvolun=5;

             abtvolun=(ccvolun in (20,30,40,50));
             if abtvolun=0 then ccvolun=ccvolun*11;
             
             clvolun=int(ccvolun/10);
             if abtvolun=1 then cuvolun=clvolun;
             else cuvolun=mod(ccvolun,10);
             ** adjust upper and lower bounds of continuous values **;
             lovolun = input(put(ccvolun,volunlo.),9.);                                                             
             upvolun = input(put(ccvolun,volunup.),9.);
             _lovolun = lovolun;
             _upvolun = upvolun;
             
          end;
          if d_hlpff=1 then do;
             svccff =cchlpff;
             i_hlpff=2;
             a_hlpff=aihlpff;
             infhlpff=1;
             if cchlpff in (2,3) then cchlpff=cchlpff+1;
             else if cchlpff in (20,30) then cchlpff=cchlpff+10;
             else if aihlpff=50 then cchlpff=20;
             else if aihlpff>50 and cchlpff=1 then cchlpff=2;

             abthlpff=(cchlpff in (20,30,40,50));
             if abthlpff=0 then cchlpff=cchlpff*11;

             clhlpff=int(cchlpff/10);
             if abthlpff=1 then cuhlpff=clhlpff;
             else cuhlpff=mod(cchlpff,10);
             ** adjust upper and lower bounds of continuous values **;
             lohlpff = input(put(cchlpff,hlpfflo.),9.);                                                             
             uphlpff = input(put(cchlpff,hlpffup.),9.);
             _lohlpff = lohlpff;
             _uphlpff = uphlpff;

             infhlpff=1;
          end;
       end;
       else improces=0;

       hhidpn_vol=hhidpn*10 + donorvol;  /* separate donors from imputees */
     
     %let hhid=hhidpn_vol;
     
       if donorvol=1 then output workdonor;
       else output workds;
    run;
    proc freq data=workdonor;
       title2 workdonor &yr;
       table donorvol*svccvol*ccvolun*abtvolun donorvol*svccff*cchlpff*abthlpff
             donorvol*ccvolun*(clvolun cuvolun ccvolun civolun lovolun upvolun)
          /missing list;
       run;
    proc freq data=workds;
       title2 workds &yr;
       table infvolun donorvol*svccvol*ccvolun*abtvolun donorvol*svccff*cchlpff*abthlpff
          /missing list;
       run;

  %end;


** log should indicate 0 observations with duplicate key values **;
proc sort data=workds nodupkey;
  by &hhid;
run;


/* %let selcov= &fincov &nofincov; */

** Generate principal components of covariate list to use as 
   right-hand side variables in imputation models **;
proc princomp data=workds 
  n=&pcn out=workds;
  var &selcov;
run;


%doasset(impown);	*impute ownership for each asset;

%if &yr=98 | &yr=00 | &yr=02 %then ;
%else %do ;
   data workds;
      set workds workdonor;
    proc freq data=workds;
       title2 workds &yr before amount imputes;
       table donorvol*svccvol*ccvolun*abtvolun donorvol*svccff*cchlpff*abthlpff
             civolun*ccvolun
          /missing list;
       run;
   proc sort data=workds nodupkey;
     by &hhid;
   proc princomp data=workds (drop=prin1-prin10)  
     n=&pcn out=workds;
     var &selcov;
   run;

%end;

%doasset(impcat);	*impute proper bracket for each asset;

proc freq data=workds;
title2 AFTER bracket imputes;
   table civolun*_ccvolun*ccvolun
      /missing list;
      run;

%let donv=;

%if &yr=98 | &yr=00 | &yr=02 %then ;
%else %do ;
/* code continuous values back to continuous */
data workds;
   set workds;
   if donorvol=1 then do;
      i_volun=0;
      i_hlpff=0;
      svccvol2=ccvolun;
      if mod(ccvolun,10)>0 then ccvolun=ccvolun/11;
   end;
run;
%let donv=donorvol*svccvol2* ;
%end;

proc freq data=workds;
   title2 workds &yr before amount imputes;
   table &donv i_volun*ccvolun*abtvolun i_hlpff*cchlpff*abthlpff
      /missing list;
   run;

%doasset(impamt);	*impute amount for each asset;

%if &yr=98 | &yr=00 | &yr=02 %then %do;
	proc freq data=workds;
       title2 workds &yr before amount imputes;
       table i_volun*ccvolun*abtvolun i_hlpff*cchlpff*abthlpff
          /missing list;
       run;
%end;
%else %do; 
    proc freq data=workds;
       title2 workds &yr after amount imputes;
       table donorvol*svccvol*svccvol2*ccvolun*abtvolun 
             i_volun*ccvolun*abtvolun 
             donorvol*svccff*cchlpff*abthlpff
             i_hlpff*cchlpff*abthlpff
          /missing list;
       run;
   
%end;

data volimp&yr workds workdonor2;
  set workds;

%if &yr=98 | &yr=00 | &yr=02 %then ;
%else %do;
  if donorvol=1 then output workds; * workdonor2;
  else do;
     output volimp&yr;
     output workds;
  end;
%end;

run;

/** Run toolkit macro for imputation assessment **/
options ls=84 ps=84 FORMDLIM=' ';

proc printto print="toolkit&yr..lst" new;

proc format;
  value ynfmt 0 = 'no'
              1 = 'yes';
  value amt 1 = 'continuous value'
	    2 = 'complete bracket'
	    3 = 'incomplete bracket'
	    4 = 'range card bracket'
	    5 = 'no value/bracket'
	    6 = 'no asset'
	    7 = 'DK ownership'
	    9 = 'no financial respondent'
	    ;
  value impfmt 0 = 'Reported'
               1 = 'Imputed'
	       ;
  value cap
  0="0.not capped"
  1="1.self-report capped"
  2="2.imputed value capped"
  ;
run;  	

proc univariate data=workds  /* workdonor2 */
%if &yr=98 | &yr=00 | &yr=02 %then ;
%else (where=(donorvol=1));
    ;
   title2 donors from 2002;
   var aivolun aihlpff;
   run;
   
proc datasets library=work;
   delete workdonor;
*   delete workdonor2;

%doasset(tool)      

proc printto print="volimp&yr..cont.txt" new;
run;

data imp.volimp&yr;
  set volimp&yr ;
  r&w.volhrs=aivolun;
  if d_volun=0 and aivolun=. then r&w.volhrs=0;
  r&w.anyvolhrs=d_volun;
  r&w.volhrsf=infvolun;
  
  /* Added May 21,2012: the question asks about hours in the last year.
     The max hours in a year is 365*24 = 8760.  
     Cap hours at 8760 if imputation assigned a bigger number. */
  
  if r&w.volhrs>8760 then do;
     r&w.volhrs=8760;
     _aivolun=aivolun;
     aivolun=8760;
     volcap=2; /* imputed too big.  1=self-report too big */
  end;
  
  r&w.volffhrs=aihlpff;
  if d_hlpff=0 and aihlpff=. then r&w.volffhrs=0;
  r&w.anyvolffhrs=d_hlpff;
  r&w.volffhrsf=infhlpff;
  if r&w.volffhrs>8760 then do;
     r&w.volffhrs=8760;
     _aihlpff=aihlpff;
     aihlpff=8760;
     hlpcap=2; /* imputed too big.  1=self-report too big */
  end;
  
  label r&w.volhrs= 'Volunteer help hours'
  	    r&w.volffhrs= 'Fam/friends help help hours'
  	    r&w.anyvolhrs="Any volunteer help hours"
  	    r&w.volhrsf="Volunteer help hours /imp flag"
  	    r&w.anyvolffhrs="Any fam/friends help hours"
  	    r&w.volffhrsf="Fam/friends hlp hrs /imp flag"
  	    reloth="Other religion"
  	    relnone="No religion"
  	    rel_notimp="Religion not important"
  	    rel_someimp="Religion somewhat important"
  	    aivolun="Volunteer hours, conditional on any"
  	    _aivolun="original imputed vol hours if capped"
  	    aihlpff="Fam/friends help hours, conditional on any"
  	    _aihlpff="original imputed fam/friend help hours if capped"
  	  ;

run;
proc sort data=imp.volimp&yr;
   by hhidpn;
proc freq data=imp.volimp&yr;
   table r&w.anyvolhrs r&w.volhrsf r&w.anyvolffhrs r&w.volffhrsf volcap hlpcap
     /missing list;
format volcap hlpcap cap.;
run;
proc means data=imp.volimp&yr;
  var r&w.anyvolhrs r&w.volhrs r&w.anyvolffhrs r&w.volffhrs
      aivolun _volhrs _aivolun aihlpff _hlphrs _aihlpff;
run;
proc means data=imp.volimp&yr (where=(r&w.anyvolhrs=1));
title2 Volunteer hours conditional on any;
  var r&w.volhrs;
run;
proc means data=imp.volimp&yr (where=(r&w.anyvolffhrs=1));
title2 Hours helping friends/family conditional on any;
  var r&w.volffhrs;
run;

proc contents data=imp.volimp&yr;
run;
proc printto;
run;

%mend impit;

%impit(4,98);
%impit(5,00);
%impit(6,02);

%impit(7,04,yrd=02)
%impit(8,06,yrd=02)
%impit(9,08,yrd=02)
%impit(10,10,yrd=02)
%impit(11,12,yrd=02)
