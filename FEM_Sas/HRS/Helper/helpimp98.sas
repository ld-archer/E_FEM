/** \file helpimp98.sas

Imputes days, hours/day, and total hours helped last month

Specifies wave number, directory mapping, 
file references, covariate list, asset list

FOR 1998: if spouse was helper, no hours-helped was obtained.
   Use 2000 spouses as donors.

July 2012: reorganized to make helpimpR file in another program.
   Imputations are done at resp-helper level.  
   helpimpR collapses to Resp level.
   new program helpimpR will collapse. This allows collapsing
   separately based on helper relationship. We will then separate
   spouse help hours from all other help hours. 
   Having spouse help hours separate allows us to assign these hours
   to the spouse later, as hours given.
**************************************************/

options ls=200 ps=82 compress=yes nocenter replace nodate nonumber mprint nofmterr;

%include "../../../fem_env.sas";  /* file to set up libnames, fmt/mac locations */

libname imp "&outlib";

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
   
%include "helprange.inc";

** file containing main imputation macros **;
%include "helpimp.mac";

%let pgm=helpimp;  /* program name, for lst files,  separated by year */

** what to impute **;
%let helpv=days hours tothr;
%let assets= &helpv;

** variable-specific code for any variable with no continuous reporter
   which still needs imputation.  Gets parameters of similar variable 
   and generates normal random variates **;
   
%let hotcode = no reporters.inc;

** number of principal components to use **;
%let pcn=10;

** number to use with random seed **;
%let seed=1003;


** selected covariates **;
%let rcovar=male hispan white black othrace age agesq lths hsgrad college
            nhmliv adla iadla loginc logwlth_nh logwlth cpl spabs nkids;
%let hlpcov=helperct hlpmale 
            spouse kid gkid parsib othrel nonrel ;

/* hlpmale - missing if days helped is zero, so not to go into the ownership regression */

%let hlpcovown=helperct kid gkid parsib othrel nonrel;
%let hlpcov=helperct kid gkid parsib othrel nonrel hlpmale;
%let respcov=male hispan black othrace age agesq lths college
             nhmliv adla iadla loginc logwlth_nh cpl spabs;
%let hlpcovsp=helperct 
            ;

%let improces =1;
%let hhid=hhidpn_opn_sp;

%macro impit(yr,w,yrsp=);

%if %length(&yrsp)=0 %then %do;
    %if &yr lt 92 %then %let yr4=20&yr;
    %else %let yr4=19&yr;
    %if %eval(&yr4+2) ge 2000 %then %let yrsp=%eval(&yr4+2);
    %else %let yrsp=2000;
%end;

proc sql;
   title2 count of respondents helped;
   create table ctR as select distinct hhidpn from imp.prephelp&yr;
   select count(hhidpn) from ctR;
quit;

title **** HELPER TIME IMPUTED &yr *****;
proc printto print="&pgm&yr..lst" new;
** Get dataset with prepared imputation variables and covariates **;
data worksp worknonsp;
  set imp.prephelp&yr (in=_in&yr keep=hhidpn opn days hours tothr
                            d_days didays a_days i_days abtdays infdays
                            cldays cudays ccdays cidays lodays updays
                            d_hours dihours a_hours i_hours abthours infhours
                            clhours cuhours cchours cihours lohours uphours
                            d_tothr ditothr a_tothr i_tothr abttothr inftothr
                            cltothr cutothr cctothr citothr lotothr uptothr
                            &rcovar &hlpcov spouse)
                     /* include source for spouse donors */
      imp.helpimp&yrsp (in=_insp keep=hhidpn opn days hours tothr
                            d_days didays a_days i_days abtdays infdays aidays
                            cldays cudays ccdays cidays lodays updays
                            d_hours dihours a_hours i_hours abthours infhours aihours
                            clhours cuhours cchours cihours lohours uphours
                            d_tothr ditothr a_tothr i_tothr abttothr inftothr aitothr
                            cltothr cutothr cctothr citothr lotothr uptothr
                            &rcovar &hlpcov spouse
                            where=(spouse=1));

  spdonor=_insp;
  impin=_in&yr;
  
  ** imputation process flag for imputing nonfinr HHs **;
  improces = 0;  /* impute 1998 variables */

  /* if using spdonor, do not impute. Use as is */
  if spdonor=1 then improces=1;
  
  /* include whether donor spouse as part of ID to keep imp file ids separate
     from spouse donors from a different wave. */
  hhidpn_opn_sp=left(compress(put(hhidpn,z9.0) || opn || put(spdonor,z1.) ));
  
  if spouse=1 then output worksp;
  else output worknonsp;
run;

title **** HELPER TIME IMPUTED &yr - SPOUSES ONLY *****;
/*** first impute spouses only ***/
** log should indicate 0 observations with duplicate key values **;
proc sort data=worksp nodupkey;
  by hhidpn opn spdonor;
run;

** Generate principal components of covariate list to use as 
   right-hand side variables in imputation models **;
%let selcov=&respcov &hlpcovsp;
proc princomp data=worksp
  n=&pcn out=workds;
  var &selcov;
run;

/* ownership for all three variables is imputed by days */
%doasset(impown);	

/** no brackets %doasset(impcat); ***/

%doasset(impamt);

data helpimpsp&yr;
  set workds;
      
  tothr_calc=aidays*aihours;
run;
proc means data=helpimpsp&yr;
   class improces;
   var d_days a_days aidays a_hours aihours a_tothr aitothr tothr_calc;
   run;
   
title **** HELPER TIME IMPUTED &yr -IMPUTE NON-SPOUSES *****;
data workds0;
   set helpimpsp&yr (in=_insp where=(improces=0))
       worknonsp;
   if _insp=1 then improces=1;
run;
proc freq data=workds0;
   table spouse improces spouse*improces
         didays d_days
         spouse*didays*d_days
         /missing list;
run;

** log should indicate 0 observations with duplicate key values **;
proc sort data=workds0 nodupkey;
  by &hhid;
run;

** Generate principal components of covariate list to use as 
   right-hand side variables in imputation models **;
%let selcov=&respcov &hlpcovown;
proc princomp data=workds0
  n=&pcn out=workds;
  var &selcov;
run;

/* ownership for all three variables is imputed by days */
%doasset(impown);	

/* set ownership for hours and tothrs from d_days imputation */
data workds;
   set workds;
   drop prin1-prin&pcn;
run;

/* redo princomp adding sex of helper */
%let selcov=&respcov &hlpcov;
proc princomp data=workds
  n=&pcn out=workds;
  var &selcov;
run;

/** no brackets %doasset(impcat); ***/

%doasset(impamt);

data imp.helpimp&yr workds;
  set workds workds0 (where=(spdonor=1));
      
  if spdonor ne 1 then tothr_calc=aidays*aihours;
  
  output workds;
  
    label           
    aidays="# days helped /imputed"
    aihours="Hours/day helped /imputed"
    aitothr="Total hours helped last month /imputed"
    tothr_calc="Days x hours helped last month /imputed"
    hlprel="Relationship of helper"
    ;
    array rel_[*] spouse kid gkid parsib othrel nonrel;
    hlprel=.;
    do i=1 to dim(rel_);
       if rel_[i]=1 then hlprel=i;
    end;
    
    output imp.helpimp&yr;

run;
proc freq data=imp.helpimp&yr;
   table hlprel
   /missing list;
   format hlprel relimp.;
   run;

title2 'Income Components - Imputed and Reported';
proc means data=imp.helpimp&yr;
  class hlprel spdonor;
  types () hlprel spdonor;
  var days hours tothr aidays aihours aitothr tothr_calc;
  format hlprel relimp.;
run;

title2;
proc contents data=imp.helpimp&yr;
run;


/** Run toolkit macro for imputation assessment **/
options ls=84 ps=84 FORMDLIM=' ';

proc printto print="toolinc&yr..lst" new;

proc format;
  value ynfmt 0 = 'no'
  	      1 = 'yes'
  	      ;
  value amt 1 = 'continuous value'
	    2 = 'complete bracket'
	    3 = 'incomplete bracket'
	    4 = 'range card bracket'
	    5 = 'no value/bracket'
	    6 = 'no income'
	    7 = 'DK/RF income receipt'
	    8 = ' (no spouse/partner)'
	    9 = 'no financial respondent'
	    ;
  value impfmt 0 = 'Reported'
               1 = 'Imputed'
	       ;
run;  	

%let assets= &helpv;
%doasset(tool)      

%mend impit;

%impit(98,4,yrsp=00);
 