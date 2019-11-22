/* chkimp.sas
   check imputed values
*/
options ls=180 ps=84 compress=yes nocenter replace FORMDLIM=' ' mprint;
options ls=120 ps=58 nocenter replace nofmterr compress=yes mprint;

%include "../../../fem_env.sas";  /* file to set up libnames, fmt/mac locations */

libname hrs "&hrslib";
libname out "&outlib";
proc format;
   value anyhrs
   1-49="1-49"
   51-99="51-99"
   101-199="101-199"
   201-9000=">200";
   value agegrp
   0-50.5="<51"
   50.501-55.5="51-55"
   55.501-60.5="56-60"
   60.501-65.5="61-65"
   65.501-70.5="66-70"
   70.501-75.5="71-75"
   75.501-80.5="76-80"
   80.501-150="gt 80"
   ;
   value cc04f
   1,2,20,30="100 or less"
   3,40="101-200"
   4=">200";
   value cc02f
   1,20="100 or less"
   2,30="101-200"
   3=">200";
   

proc freq data=out.volimp02;
  table ccvolun cchlpff ccvolun*aivolun cchlpff*aihlpff
  /missing list;
  format aivolun aihlpff anyhrs9. ccvolun cc02f.;
  run;
proc freq data=out.volimp04;
  table ccvolun cchlpff ccvolun*aivolun ccvolun*a_volun cchlpff*aihlpff
  /missing list;
  format aivolun aihlpff anyhrs9. ccvolun cc04f.;
  run;
data tmp;
   merge out.volimp02 (rename=(aivolun=aivolun02 ccvolun=ccvolun02 d_volun=d_volun02))
         out.volimp04 (rename=(aivolun=aivolun04 ccvolun=ccvolun04 d_volun=d_volun04))
         hrs.rndhrs_k (keep=hhidpn hacohort inw6 inw7 where=(inw6=1 or inw7=1))
         ;
   by hhidpn;
   diff0204=(aivolun02-aivolun04);
run;
proc freq data=tmp;
   table d_volun02 d_volun04 
         ccvolun02 ccvolun04 
         ccvolun02*ccvolun04
         hacohort*(d_volun02 d_volun04 ccvolun02 ccvolun04) /missprint;
   format ccvolun02 cc02f. ccvolun04 cc04f.;
   run;
proc means data=tmp;
   class hacohort;
   var aivolun02 aivolun04 diff0204;
   run;
proc means data=out.volimp02 (where=(aivolun<6000));
   title2 volimp02;
   class ccvolun;
   format age agegrp. ccvolun cc02f.;
   var aivolun;
   run;
proc means data=out.volimp04;
   title2 volimp04;
   class ccvolun;
   format age agegrp. ccvolun cc04f.;
   var aivolun;
   run;
