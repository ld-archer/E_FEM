/** \file proptximp.sas
    
    Wave-specific imputation program

Specifies wave number, directory mapping, 
file references, covariate list, asset list
**************************************************/

options ls=120 ps=58 nocenter replace nofmterr compress=yes mprint;

%include "../../../fem_env.sas";  /* file to set up libnames, fmt/mac locations */

libname imp "&outlib";
libname hrs "&hrslib";

proc format;
   %include "&fmtlib.wealth.fmt";
   
** file containing wave-specific asset bracket information **;
%include "ranges_v1.inc";

** file containing main imputation macros **;
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

%let covar=age agesq cpl 
           m_hispan m_black m_othrace m_lths m_hsgrad m_college
           neng midatl encent wncent satl escent wscent mountain pacific notus
           mobil loginc logwlth_nh
           housa housb;
           
%macro impit(w,yr,v,hous=a);
   %if &hous=a %then %let htype=Primary Residence;
   %if &hous=b %then %let htype=Second Home;
   %else %let htype=;
   
   title "HRS &htype Property Tax Imputations: HRS&yr";
   
   %let assets= proptx&hous;
   %let selcov=age agesq cpl 
              m_hispan m_black m_othrace m_lths m_hsgrad m_college
              neng midatl encent wncent satl escent wscent mountain pacific notus
              mobil loginc logwlth_nh
              hous&hous;
             /*  housa housb */
   
   
   %let improces =0;       
   
** Get dataset with prepared imputation variables and covariates **;

data workds nofin;
  set imp.prep_ptax&yr (drop=i &v.h:);
  
  if hous&hous<=1 then loghous&hous=0;
  else loghous&hous=log(hous&hous);
  
  
  ** imputation process flag for imputing nonfinr HHs **;
  improces = &improces;
  if nofindat=1 then output nofin;
  else output workds;
run;

%let hhid = whhid;

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

%doasset(impcat);	*impute proper bracket for each asset;

%doasset(impamt);	*impute amount for each asset;


%let improces=1;
data finHH;
  set workds;
  improces = &improces;
run;

/*********************************************************
Impute HHs with no financial respondents
Use non-financial, non-gender-specific covariates 
Use newly imputed HHs
**********************************************************/
** number to use with random seed **;
%let seed=1022;

data workds (drop=prin1-prin&pcn);
  set finHH
      nofin;
run;


** log should indicate 0 observations with duplicate key values **;
proc sort nodupkey;
  by &hhid;
run;

/* %let selcov = &nofincov; */

proc princomp data=workds 
  n=&pcn out=workds;
  var &selcov;
run;

%doasset(impown);	

%doasset(impcat);	

%doasset(impamt);	



data proptximp&hous&yr workds;
  set finHH
      workds (where=(nofindat=1));
run;

/** Run toolkit macro for imputation assessment **/
options ls=84 ps=84 FORMDLIM=' ';

proc printto print="toolkit&hous&yr..lst" new;

proc format;
  value ynfmt 0 = 'no'
  	      1 = 'yes'
  	      ;
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
run;  	

%doasset(tool)      
proc printto;
run;
%mend impit;

%macro mrgit(w,yr);
proc sort data=proptximpa&yr;
   by whhid;
proc sort data=proptximpb&yr;
   by whhid;
data imp.proptximp&yr;
  merge proptximpa&yr (keep=whhid ai: d_: inf:)
        proptximpb&yr (keep=whhid ai: d_: inf:)
        ;
  by whhid;
  h&w.proptxa=aiproptxa;
  if d_proptxa=0 and aiproptxa=. then h&w.proptxa=0;
  h&w.anyproptxa=d_proptxa;
  h&w.proptxaf=infproptxa;
  
  h&w.proptxb=aiproptxb;
  if d_proptxb=0 and aiproptxb=. then h&w.proptxb=0;
  h&w.anyproptxb=d_proptxb;
  h&w.proptxbf=infproptxb;
  
  label h&w.proptxa= 'Property tax - primary residence'
  	    h&w.proptxb= 'Property tax - second home'
  	    h&w.anyproptxa="Any property tax - primary residence"
  	    h&w.proptxaf="Property tax - prim res /imputation flag"
  	    h&w.anyproptxb="Any property tax - second home"
  	    h&w.proptxbf="Property tax - 2nd home /imputation flag"
  	  ;
run;
proc freq data=imp.proptximp&yr;
   table h&w.anyproptxa h&w.proptxaf h&w.anyproptxb h&w.proptxbf
     /missing list;
run;
proc means data=imp.proptximp&yr;
  var h&w.anyproptxa h&w.proptxa h&w.anyproptxb h&w.proptxb;
run;
proc contents data=imp.proptximp&yr;
run;
%mend mrgit;

/* run each asset separately so individual house value can be 
   used as covariate.  Then merge */
   
%impit(6,02,h,hous=a)
%impit(6,02,h,hous=b)
%mrgit(6,02);

%impit(7,04,j,hous=a)
%impit(7,04,j,hous=b)
%mrgit(7,04);

%impit(8,06,k,hous=a)
%impit(8,06,k,hous=b)
%mrgit(8,06);

%impit(9,08,l,hous=a)
%impit(9,08,l,hous=b)
%mrgit(9,08);

%impit(10,10,m,hous=a)
%impit(10,10,m,hous=b)
%mrgit(10,10);

%impit(11,12,n,hous=a)
%impit(11,12,n,hous=b)
%mrgit(11,12);

%impit(12,14,o,hous=a)
%impit(12,14,o,hous=b)
%mrgit(12,14)

/* macro to add HHIDPN back on to make respondent level file */
%macro addid(w,yr);
   create table proptximpr&yr as select r.hhidpn,i.*
      from imp.proptximp&yr i 
      left join hrs.rndhrs_&rndv (keep=hhidpn h&w.hhid) r
      on r.h&w.hhid=i.whhid
      order r.hhidpn;
%mend;

proc sql;
   %addid(6,02)
   %addid(7,04)
   %addid(8,06)
   %addid(9,08)
   %addid(10,10)
   %addid(11,12)
   %addid(12,14)

/* merge together waves of data */
data imp.proptximp (compress=no) lost;
   merge imp.proptximpr98 (in=_in98 keep=hhidpn h4:)
         imp.proptximpr00 (in=_in00 keep=hhidpn h5:)
         proptximpr02 (in=_in02 keep=hhidpn h6:) 
         proptximpr04 (in=_in04 keep=hhidpn h7:)
         proptximpr06 (in=_in06 keep=hhidpn h8:)
         proptximpr08 (in=_in08 keep=hhidpn h9:)
         proptximpr10 (in=_in10 keep=hhidpn h10:)
         proptximpr12 (in=_in12 keep=hhidpn h11:)
         proptximpr14 (in=_in14 keep=hhidpn h12:)
         hrs.rndhrs_&rndv (keep=hhidpn inw4 inw5 inw6 inw7 inw8 inw9 inw10 inw11 inw12
                            where=(inw4=1 or inw5=1 or inw6=1 or inw7=1 or inw8=1 or inw9=1 or inw10=1 or inw11=1 or inw12=1))
         ;
   by hhidpn;
   in98=_in98;
   in00=_in00;
   in02=_in02;
   in04=_in04;
   in06=_in06;
   in08=_in08;
   in10=_in10;
   in12=_in12;
   in14=_in14;
   
   if in98 ne inw4 or in00 ne inw5 or in02 ne inw6 or in04 ne inw7 or in06 ne inw8 or in08 ne inw9 or in10 ne inw10 or in12 ne inw11 or in14 ne inw12 then output lost;
   else output imp.proptximp;
   drop inw4 inw5 inw6 inw7 inw8 inw9 inw10 inw11 inw12;
run;
proc print data=lost (obs=20);

proc printto print="proptximp.cont.txt" new;
title2 property tax imputations 2006-2008;
proc freq data=imp.proptximp;
   table in98 in00 in02 in04 in06 in08 in10 in12 in14/missing ;
   table h4anyproptxa h4proptxaf h4anyproptxb h4proptxbf
     /missing list;
   format h4proptxaf h4proptxbf assetf.;
   
   table h5anyproptxa h5proptxaf h5anyproptxb h5proptxbf
     /missing list;
   format h5proptxaf h5proptxbf assetf.;
   
   table h6anyproptxa h6proptxaf h6anyproptxb h6proptxbf
     /missing list;
   format h6proptxaf h6proptxbf assetf.;
   
   table h7anyproptxa h7proptxaf h7anyproptxb h7proptxbf
     /missing list;
   format h7proptxaf h7proptxbf assetf.;

   table h8anyproptxa h8proptxaf h8anyproptxb h8proptxbf
     /missing list;
   format h8proptxaf h8proptxbf assetf.;
   
   table h9anyproptxa h9proptxaf h9anyproptxb h9proptxbf
     /missing list;
   format h9proptxaf h9proptxbf assetf.;
   
   table h10anyproptxa h10proptxaf h10anyproptxb h10proptxbf
     /missing list;
   format h10proptxaf h10proptxbf assetf.;
   
   table h11anyproptxa h11proptxaf h11anyproptxb h11proptxbf
     /missing list;
   format h11proptxaf h11proptxbf assetf.;
   
   table h12anyproptxa h12proptxaf h12anyproptxb h12proptxbf
     /missing list;
   format h12proptxaf h12proptxbf assetf.;

run;
proc means data=imp.proptximp;
  var h4anyproptxa h4proptxa h4anyproptxb h4proptxb
      h5anyproptxa h5proptxa h5anyproptxb h5proptxb
      h6anyproptxa h6proptxa h6anyproptxb h6proptxb
      h7anyproptxa h7proptxa h7anyproptxb h7proptxb
      h8anyproptxa h8proptxa h8anyproptxb h8proptxb
      h9anyproptxa h9proptxa h9anyproptxb h9proptxb
      h10anyproptxa h10proptxa h10anyproptxb h10proptxb
      h11anyproptxa h11proptxa h11anyproptxb h11proptxb
      h12anyproptxa h12proptxa h12anyproptxb h12proptxb ;
run;
proc contents data=imp.proptximp;
run;
title2;
