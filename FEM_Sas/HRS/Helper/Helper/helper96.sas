/* helper96.sas
   VERSION B of RAND FAM
   October 2011: remove imputations. Replaced amtmoF which was impflag to indicate
      type of information available for amount paid.
*/
options ls=120 ps=58 nocenter replace mprint;

%let w=3;
%let iw=5;
%let V=E;
%let yr=96;
%let yrlib=96;
%let yr4=1996;
%let sect=E;
%include "../setup.inc";

libname library "&fmtlib";
libname help "&randfam/Helperx";

%include "cleanhlp.mac";

proc format;
   %include "&fmtlib.helper.fmt";
   run;


/*********************************
  clean up helper data.
*********************************/
data help.helper&yr;
   set h&yrlib..h&yr.&sect._hp;
   
   length &V.hhid $ 7 ;
   hhidpn=hhid*1000 + pn;
   &V.hhidn=hhid*10 + &V.subhh;
   &V.hhid=put(&V.hhidn,z7.0);
   
   label hhidpn='HHIDPN: individual ID = HHID + PN /num' 
         &V.hhid='FHHID: wave-specific HHold ID = HHID+FSUBHH/char' 
         &V.hhidn='FHHIDN: wave-specific HHold ID = HHID+FSUBHH/num' ;
   
   array hpsv_[*] hps&w.days hps&w.hours hps&w.tothrs hps&w.sex
                  hps&w.paid hps&w.ins hps&w.amt hps&w.amtmo
                  hps&w.amtmof hps&w.payhlp hps&w.helpr hps&w.gkpar;

 length hpk&w.gkidp hps&w.gkidp $ 3;

  
   %cleanhlp(hpk,2123, 2127,marv=2122,relv=2120A,gkpar=N,payopn=N,oop9=999)  /* kid variables */

   if hpk&w.marr=1 then do;
     %cleanhlp(hps,2142, 2146,relraw=2120A,gkpar=N,payopn=N,oop9=999)   /* kid spouse variables */

      /* clean up a few things */
      if hps&w.paid=.M and hpk&w.paid=.S then hps&w.paid=.S;
      if hpk&w.paid=.S then hps&w.amtmoF=7;
   end;

   else do;
      if hpk&w.marr=2 then _miss=.S;
      else _miss=.U;
      do i=1 to dim(hpsv_);
         hpsv_[i]=_miss;
      end;
      if hps&w.amtmoF=. and _miss=.S then hps&w.amtmoF=7;
      else if hps&w.amtmoF=. then hps&w.amtmoF=_miss;
    
   end;
run;

%macro tabday(pre,dayv);
   %let daymo=&v&dayv;
   %let daywk=&v%eval(&dayv+1);
   %let evday=&v%eval(&dayv+2);
   
   &pre&w.days*&daymo*&daywk*&evday
%mend;

proc freq data=help.helper&yr;
   table hpk&w.helpr hpk&w.relhp
        
         hpk&w.sex
         hpk&w.paid hpk&w.amtper hpk&w.ins hpk&w.payhlp
         hpk&w.amtmof
         hpk&w.days hpk&w.hours hpk&w.marr
    /missing list;
   table hps&w.helpr 
         
         hps&w.sex
         hps&w.paid hps&w.amtper hps&w.ins hps&w.payhlp
         hps&w.amtmof
         hps&w.days hps&w.hours
    /missing list;
   table /*hpk&w.sex*E2128 hps&w.sex*F2663
         hpk&w.relhp*F2639A hpk&w.marr*F2641
         hpk&w.paid*F2649 hps&w.paid*F2665*/
        
         hpk&w.helpr*hps&w.helpr
         hpk&w.paid*hps&w.paid
         /*%tabday(hpk,2642) %tabday(hps,2658) */
    /missing list;
         
format hpk&w.relhp relk.;
format hps&w.amtmoF hpk&w.amtmoF amtmoF.;
run;


proc means data=help.helper&yr;
   class hpk&w.amtmof;
   types () hpk&w.amtmof;
   var hpk&w.paid hpk&w.amtmo;
   run;

proc means data=help.helper&yr;
   class hps&w.amtmof;
   types () hps&w.amtmof;
   var hps&w.paid hps&w.amtmo;
   run;

title2 helper&yr ;
proc sort data=help.helper&yr;
   by hhidpn;
run;
proc contents data=help.helper&yr;
run;
proc means data=help.helper&yr;
   run;
