/* helper04.sas
   clean helper data.
   In helper02A/B, link to KIDID and then link kid spouses and
   grandkids to kids.
   January 28, 2011: changes for RAND FAM project
   
   VERSION B of RAND FAM
   October 2011: remove imputations. Replaced amtmoF which was impflag to indicate
      type of information available for amount paid.
*/
options ls=120 ps=58 nocenter replace nofmterr compress=yes;

%let w=7;
%let V=J;
%let yr=04;
%let sect=G;
%include "../../../../fem_env.sas";  /* file to set up libnames, fmt/mac locations */

libname library "fmtlib";
libname help "&outlib";
libname h04 "&hrslib" ;

proc format;
   %include "&fmtlib.helper.fmt";
   run;

/* cleanhlp02_.inc: reads _HP file and cleans helper variables beginning in 2002 */

%include "cleanhlp02_.inc";
