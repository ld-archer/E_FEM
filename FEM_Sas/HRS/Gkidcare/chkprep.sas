/* chkprep.sas
   check on _divhr cases.  _divhr provides # years the ref period includes
   This is 2 years for a first interview and # years since last interview 
   otherwise
*/
   
options ls=180 ps=84 compress=yes nocenter replace FORMDLIM=' ' mprint;
options ls=120 ps=58 nocenter replace nofmterr compress=yes mprint ;

%include "../../../fem_env.sas";  /* file to set up libnames, fmt/mac locations */

libname rfam "&dataroot.HRS/Unrestricted/Sas/RANDFAM";
libname hrs "&hrslib";
libname out "&outlib";
libname library "&hrslib";

proc format;
   value anyhrs
   1-9000="any";
   value agecat
   0-49="<50"
   50-59="50s"
   60-69="60s"
   70-79="70s"
   80-150="80+"
   ;

%let maxg=9;  /* max # gkid entries */
%include "&maclib.wvlist.mac";
        
%macro prepimp(w,yr);
title2 prep_gkcare&yr;
proc freq data=out.prep_gkcare&yr;
   table _divhr infgkcare*_divhr i_gkcare*infgkcare
         /missing list;
run;
proc freq data=out.prep_gkcare&yr (where=(infgkcare=2));
title3 cases with proper brackets;
   table infgkcare _divhr _divhr*ccgkcare
         /missprint;
format a_gkcare gkchrs r&w.nkid h&w.child anyhrs8.;
run;
proc means data=out.prep_gkcare&yr n mean stddev min median max;
title3;
   class _divhr;
   var a_gkcare gkchrs;
   run;
%mend;

%prepimp(4,98)
%prepimp(5,00)
%prepimp(6,02)
%prepimp(7,04)
%prepimp(8,06)
%prepimp(9,08)

endsas;
