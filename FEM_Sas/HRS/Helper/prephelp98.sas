/** \file prephelp98.sas
   prepare helper files for imputation of total hours helped last month
   For 1998 we need to identify respondents who have a spouse helping
   from the fat files instead of the helper files.
   They will all be missing hours helped.  We will use 2000 data for the
   donor pool in the imputations.
*/
options ls=120 ps=58 nocenter replace nofmterr compress=yes mprint;

%include "../../../fem_env.sas";  /* file to set up libnames, fmt/mac locations */

libname helper "&outlib";
libname hrs "&hrslib";
libname out "&outlib";
libname library "&hrslib";

proc format;
  %include "&fmtlib.helper.fmt";
  %include "&fmtlib.rkid.fmt";
  
  value hrs
  0="0 hours"
  1-900="1-900 hrs"
  ;
  value days
  1-29="1-29 days"
  ;
  value hours
  1-23="1-23 hrs"
  ;
  value tothr
  1-719="1-719 hrs"
  ;
  value $anyopn
   "030"-"049"="030-049"
   "050"-"095","101"-"899"="Other Person Number"
   "096"="096. EMPLOYEE"
   ;
   value rawrelA
   10="Spouse"
   11-15="Kid"
   21-22="Gkid"
   31-41="Par/sib"
   51-52="othrel"
   61-62="other ind"
   71-73="emp/org";
   
   value rawrelB
   2="spouse"
   26-27="ex-/deceased sp"
   3-8,28="Kid"
   30-31="former kid"
   9,33="Gkid"
   10-18="Par/sib"
   19="othrel"
   20="other ind"
   21-25="emp/org"
   ;
  %include "helprange.inc";

%include "prephelp98.mac";   /* has prepv and prephelp macros */

%let rawopn98= F2502 F2516 F2525 F2529 F2533 F2537 F2541 
               F2582 F2591 F2596 F2602 F2608 
               F2614 F2621 
               ;
%prephelp(4,98,sp=Y,rawrel=f2639a,rawopn=&rawopn98,rawopnn=F2624,opnsp=036)

endsas; 

