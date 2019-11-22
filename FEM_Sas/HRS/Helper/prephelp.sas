/** \file prephelp.sas
   prepare helper files for imputation of total hours helped last month
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

%include "prephelp.mac";   /* has prepv and prephelp macros */
 
%prephelp(5,00,sp=Y,rawrel=g2947a)
%prephelp(6,02,rawrel=hg069)
%prephelp(7,04,rawrel=jg069)
%prephelp(8,06,rawrel=kg069)
%prephelp(9,08,rawrel=lg069)
%prephelp(10,10,rawrel=mg069)
%prephelp(11,12,rawrel=ng069)
%prephelp(12,14,rawrel=og069)

endsas; 
