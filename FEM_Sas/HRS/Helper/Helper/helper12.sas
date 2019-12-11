/* helper10.sas
   clean helper data.
   VERSION C of RAND FAM
   October 2011: remove imputations. Replaced amtmoF which was impflag to indicate
      type of information available for amount paid.
   Feb 2015: update to 2010 RAND FAM version C
*/
options ls=120 ps=58 nocenter replace nofmterr compress=yes;

%let w=11;
%let V=N;
%let yr=12;
%let sect=G;
%include "../../../../fem_env.sas";  /* file to set up libnames, fmt/mac locations */

libname library "&fmtlib";
libname help "&outlib";
libname h12 "&hrslib" ;

proc format;
   %include "&fmtlib.helper.fmt";
   run;



/* cleanhlp02_.inc: reads _HP file and cleans helper variables beginning in 2002 */

%include "cleanhlp02_.inc";