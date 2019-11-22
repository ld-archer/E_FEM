/*************************************************
Wave-specific imputation program

Specifies wave number, directory mapping, 
file references, covariate list, asset list

THis program imputes hours given by HRS respondent
caring for grandchildren in the last 2 yrs.
**************************************************/

options ls=120 ps=58 nocenter replace nofmterr compress=yes mprint;

%include "../../../fem_env.sas";  /* file to set up libnames, fmt/mac locations */

libname imp "&outlib";
libname hrs "&hrslib";

proc format;
   %include "&fmtlib.wealth.fmt";
   
Options fmtsearch=(library.rndfam_fmts);
   
** file containing wave-specific asset bracket information **;
%include "ranges_gkidcare.inc";

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

%let covar=age agesq cpl male
           hispan black othrace lths hsgrad college
           shltgood shltfpoor anyiadl anyadl work retired disabled
           neng midatl encent wncent satl escent wscent mountain pacific notus
           loginc logwlth
           nkids kid_mnage kid_byravg
           suburb exurb
           anyresgk: nofindat;

%macro impit(w,yr);
   
   title "HRS Grandkid Care Hours Imputations: HRS&yr";
   
   %let assets= gkcare;
   %let selcov=age agesq cpl male
           hispan black othrace lths hsgrad college
           shltgood shltfpoor anyiadl anyadl work retired disabled
           neng midatl encent wncent satl escent wscent mountain pacific notus
           loginc logwlth
           nkids kid_mnage 
           suburb exurb;
  
   %let improces =0;       
   
** Get dataset with prepared imputation variables and covariates **;

data workds nofin resgk workres;
  set imp.prep_gkcare&yr (keep=hhidpn gkchrs _divhr _gkchrs
                            d_gkcare digkcare a_gkcare i_gkcare abtgkcare infgkcare
                            clgkcare cugkcare ccgkcare cigkcare logkcare upgkcare
                            &covar );
  
  ** imputation process flag for imputing nonfinr HHs **;
  improces = &improces;
  
  if nofindat=1 then output nofin; /* based on no famr */
  else if d_gkcare=1 and a_gkcare in (.L,.K) and ccgkcare in (13,23,33) then output resgk; /* co-res gkid */
  else output workds;

  if anyresgk=1 then output workres;

run;

%let hhid = hhidpn;

** log should indicate 0 observations with duplicate key values **;
proc sort data=workds nodupkey;
  by &hhid;
run;

/* impute hours for those who did not provide them because
   the grandkid was co-res.  Assign the mean of those with 
   co-res grandkids who did give hours */

proc sql;
   select mean(a_gkcare) into :mngkcareF from workres (where=(male=0 and d_gkcare=1));
   select mean(a_gkcare) into :mngkcareM from workres (where=(male=1 and d_gkcare=1));

data impresgk;
   set resgk;
   if male=0 then aigkcare=&mngkcareF;
   else aigkcare=&mngkcareM;
   infgkcare=8;
   
   if aigkcare>500 then ccgkcare=3;
   else if aigkcare>200 then ccgkcare=2;
   else if aigkcare>0 then ccgkcare=1;
   
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


data gkcareimp&yr workds;
  set finHH (in=_inf)
      impresgk (in=_inr)
      workds (in=_in0 where=(nofindat=1));
  infrom=100*_in0 + 10*_inr + _inf;
run;
proc freq data=workds;
   table infrom infgkcare infrom*infgkcare infrom*d_gkcare
         infrom*digkcare*cigkcare*i_gkcare
         infrom*ccgkcare
         /missing list;
run;
proc means data=workds;
   class infrom d_gkcare;
   var aigkcare;
   run;

/** Run toolkit macro for imputation assessment **/
options ls=84 ps=84 FORMDLIM=' ';

proc printto print="toolkit&yr..lst" new;

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
	    8 = 'co-resident gkid'
	    9 = 'no financial respondent'
	    ;
  value impfmt 0 = 'Reported'
               1 = 'Imputed'
	       ;
  value cap
  0="0.not capped"
  1="1.self-report capped"
  2="2.imputed value capped"
  ;
run;  	

proc datasets library=work;
   delete resgk;
   delete impresgk;
   delete workres;

%doasset(tool)      
proc printto;
run;

proc printto print="gkcareimp&yr..cont.txt" new;
run;

data imp.gkcareimp&yr;
  set gkcareimp&yr ;
  r&w.gkcarehrs=aigkcare;
  if d_gkcare=0 and aigkcare=. then r&w.gkcarehrs=0;
  r&w.anygkcare=d_gkcare;
  r&w.gkcarehrsf=infgkcare;

  /* Added May 21,2012: the question asks about hours in the last year.
     The max hours in a year is 365*24 = 8760.  
     Cap hours at 17520 for 2 years if imputation assigned a bigger number. */
  
  if r&w.gkcarehrs>17520 then do;
     r&w.gkcarehrs=17520;
     _aigkcare=aigkcare;
     aigkcare=17520;
     gkccap=2; /* imputed too big.  1=self-report too big */
  end;
  
  label r&w.gkcarehrs= 'Grandkid care hours / last 2 yrs'
  	    r&w.anygkcare="Any grandkid care last 2 yrs"
  	    r&w.gkcarehrsf="Grandkid care hours /imp flag"
        nkids="Number of kids"
        kid_byravg="Average birth year of kids"
  	    aigkcare="Grandkid care hours, conditional on any"
  	    _aigkcare="original imputed GKid care hours if capped"
  	  ;

run;
proc sort data=imp.gkcareimp&yr;
   by hhidpn;
proc freq data=imp.gkcareimp&yr;
   table r&w.anygkcare r&w.gkcarehrsf gkccap
     /missing list;
format gkccap cap.;
run;
proc means data=imp.gkcareimp&yr;
  class r&w.gkcarehrsf anyresgk;
  types () r&w.gkcarehrsf anyresgk;
  var r&w.anygkcare r&w.gkcarehrs _gkchrs _aigkcare;
run;
proc means data=imp.gkcareimp&yr (where=(r&w.anygkcare=1));
title2 Grandkid care hours conditional on any;
  var r&w.gkcarehrs;
run;

proc contents data=imp.gkcareimp&yr;
run;
proc printto;
run;
%mend impit;

/* run each asset separately so individual house value can be 
   used as covariate.  Then merge */
   
%impit(4,98);
%impit(5,00);
%impit(6,02);

%impit(7,04)
%impit(8,06)
%impit(9,08)
%impit(10,10)

