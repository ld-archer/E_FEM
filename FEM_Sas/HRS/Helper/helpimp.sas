/** \file helpimp.sas

Imputes days, hours/day, and total hours helped last month

Specifies wave number, directory mapping, 
file references, covariate list, asset list

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

%let selcov=&rcovar &hlpcov;

/* hlpmale - missing if days helped is zero, so not to go into the ownership regression */

%let hlpcovown=helperct kid gkid parsib othrel nonrel;
%let hlpcov=helperct kid gkid parsib othrel nonrel hlpmale;
%let respcov=male hispan black othrace age agesq lths college
             nhmliv adla iadla loginc logwlth_nh cpl spabs;

%let improces =0;       
%let hhid=hhidpn_opn;

%macro impit(yr,w);
title **** HELPER TIME IMPUTED &yr *****;
proc printto print="&pgm&yr..lst" new;
** Get dataset with prepared imputation variables and covariates **;
data workds0;
  set imp.prephelp&yr (keep=hhidpn opn days hours tothr
                            d_days didays a_days i_days abtdays infdays
                            cldays cudays ccdays cidays lodays updays
                            d_hours dihours a_hours i_hours abthours infhours
                            clhours cuhours cchours cihours lohours uphours
                            d_tothr ditothr a_tothr i_tothr abttothr inftothr
                            cltothr cutothr cctothr citothr lotothr uptothr
                            &selcov);

  ** imputation process flag for imputing nonfinr HHs **;
  improces = &improces;
  hhidpn_opn=left(compress(put(hhidpn,z9.0) || opn));
  
run;

** log should indicate 0 observations with duplicate key values **;
proc sort data=workds0 nodupkey;
  by hhidpn opn;
run;

** Generate principal components of covariate list to use as 
   right-hand side variables in imputation models **;
proc princomp data=workds0
  n=&pcn out=workds;
  var &respcov &hlpcovown;
run;

/* ownership for all three variables is imputed by days */
%doasset(impown);	

/* set ownership for hours and tothrs from d_days imputation */
data workds;
   set workds;
   drop prin1-prin&pcn;
run;

/* redo princomp adding sex of helper */
proc princomp data=workds
  n=&pcn out=workds;
  var &respcov &hlpcov;
run;

/** no brackets %doasset(impcat); ***/

%doasset(impamt);

data imp.helpimp&yr workds;
  set workds;
      
  tothr_calc=aidays*aihours;
  
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
  class hlprel;
  types () hlprel;
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

proc printto;
run;

%mend impit;

/**** run for 2000 to 2010 (w5 to w10) ****/
%impit(00,5);
%impit(02,6);
%impit(04,7);
%impit(06,8);
%impit(08,9);
%impit(10,10);
%impit(12,11);
%impit(14,12);
