
/************************************
chkvol.sas

check raw variables used to derive volunteer hours 

pstclair 4/2012, for 1998 thru 2008
************************************/
options ls=180 ps=84 compress=yes nocenter replace FORMDLIM=' ' mprint;
options ls=120 ps=58 nocenter replace nofmterr compress=yes mprint;

%include "../../../fem_env.sas";  /* file to set up libnames, fmt/mac locations */

libname hrs "&hrslib";
libname out "&outlib";
proc format;
   value anyhrs
   1-9000="any";
proc freq data=hrs.hrs98;
  table f2677*f2679b*f2679*f2680
        f2681
  /missing list;
  format f2681 anyhrs9.;
  run;

proc freq data=hrs.hrs00;
  table g2995*g2997b*g2997*g2998
        g2999
  /missing list;
  format g2999 anyhrs9.;
  run;

proc freq data=hrs.hrs02;
  table hg086*hg089*hg090
        hg092
  /missing list;
  format hg092 anyhrs9.;
  run;

proc freq data=hrs.hrs04;
  table jg086*jg195*jg196*jg197
  /missing list;
  run;
proc freq data=hrs.hrs06;
  table kg086*kg195*kg196*kg197
  /missing list;
  run;
  
proc freq data=hrs.hrs08;
  table lg086*lg195*lg196*lg197
  /missing list;
  run;
  
endsas;

** ASSET AND WAVE SPECIFIC INFORMATION ON VALUE RANGES AND NUMBERS OF BRACKETS **;

%include "ranges_v1.inc";


** DEFINING PREPV MACRO **;
        
%macro prepv (v,type,val,min,max,outval=99999997);  

title "HRS&yr: Prep Volunteer hours for imputation";


  ** OWNERSHIP **;
  
     ** Ownership of each individual type of income has been moved outside of this macro, and into WLTHOWN7_V1.INC **;
      
     ** Determining whether ownership must be imputed **;
 
        di&type = (d_&type=.);
   
  ** AMOUNTS **;
  
     if d_&type then do;
     
        if &val<&outval then a_&type = &val;               
        else if &val = %eval(&outval+1) then a_&type = .D;          
        else if &val = %eval(&outval+2) then a_&type = .R;                                                         
     
        ** answered 'about $$val' in bracketing sequence **;    
        if &min=&max and &min>=0 then do;
     
          if a_&type<=.Z or a_&type=&min then do;
     
            abt&type = 1;
            a_&type = &min;
     
          end;
     
        end;
        
        else abt&type=0;
        
        i_&type = (a_&type in (.,.D,.R)); ** missing value or code **;
   
        ** Bracket variables **;
  
           if i_&type then do;
              
              cl&type = input(put(&min,&type.bnd.),1.);
              cu&type = input(put(&max,&type.bnd.),1.);
              if &min=. then cl&type=1;
              if &max=. then cu&type=&&prp&type;
              cc&type = input(compress(cl&type||cu&type),2.);
              lo&type=input(put(cl&type,&type.lo.),9.);
              up&type=input(put(cu&type,&type.up.),9.);
           end;
           else do;
              cc&type= input(put(a_&type,&type.rng.),2.);
              lo&type=input(put(cc&type,&type.lo.),9.);
              up&type=input(put(cc&type,&type.up.),9.);
           end;   
      
     end;
       
     else if d_&type<1 then i_&type=0;
     
     ci&type = (i_&type and cl&type<cu&type);	
       
  ** CREATE VARIABLE INDICATING ORIGINAL INFORMATION GIVEN **;
  
     if d_&type then do;
        if a_&type>=0 and abt&type ne 1 then inf&type = 1;
        else if ci&type=0 then inf&type = 2;                                     
        else if cl&type=1 and cu&type=&&prp&type then inf&type = 5;
        else inf&type = 3;
     end; 
     else if %if &sec=h %then nofindat=1 and d_&type<0 and &v.XMOD_HH>0 then inf&type = 9;
             %if &sec=q %then nofindat=1 and d_&type<0 then inf&type = 9;;
     
     else if di&type then inf&type = 7;
     else if d_&type = 0 then inf&type = 6; 
       
%mend prepv;


** RUNNING PREPV MACRO **;
%macro prepimp(w,yr,relimport=,
               volany=,volhrs=,vol100=,vol200=,vol50=,
               hlpany=,hlphrs=,hlp100=,hlp200=,hlp50=);

/* merge together raw 1st and 2nd home property tax vars from fat files,
         whether own 1st/2nd home and values from imputations,
         covariates for imputation from rand hrs
*/
data prep_vol&yr;
   merge hrs.hrs&yr (in=_inf keep=hhidpn &relimport
                                  &volany &volhrs &vol100 &vol200 &vol50 &volmin &volmax 
                                  &hlpany &hlphrs &hlp100 &hlp200 &hlp50 &hlpmin &hlpmax)
         hrs.hrsxregion (in=_inur keep=hhidpn urbrur&yr)
         hrs.rndhrs_k (in=_inr keep=hhidpn inw&w h&w.hhid ragender raracem rahispan r&w.agey_e h&w.cpl
                                    raeduc h&w.atotb h&w.itot r&w.cendiv r&w.finr h&w.anyfin 
                                    r&w.work r&w.shlt r&w.adlcta r&w.iadlcta r&w.cesd rarelig 
                                    r&w.sayret r&w.retemp
                                    s&w.gender s&w.agey_e s&w.educ s&w.hispan s&w.racem
                                    s&w.finr s&w.hhidpn);
    by hhidpn;
    
    if _inf and inw&w;
    
   
    ** OWNERSHIP **;
    
       if &volany in (1,5) then d_volun=(&volany=1);
       else d_volun=.;
       
       if &hlpany in (1,5) then d_hlpff=(&hlpany=1);
       else d_hlpff=.;
       
    ** AMOUNTS, BRACKETS, FLAGS **;
       
       %let sec=r;
       
       if d_volun=1 and 
       %if %length(&volmin)>0 %then %do;  %* min/max given;
           volmin=&volmin;
           volmax=&volmax;
       %end;
       %else %do;  %* individual questions given;
           %if %length(&vol50)>0 %then %do;
              if &vol50=3 then do;  /* about 50 */
                 volmin=50;
                 volmax=50;
              end;
              else if &vol50=1 then do; /* less than 50 */
                 volmin=0;
                 volmax=49;
              end;
              else if &vol50 in (5,8,9) then volmin=0; /* more than 50 */
       
           if &vol100=3 then do;  /* about 100 */
              volmin=100;
              volmax=100;
           end;
           else if &vol100=1 then do;
              volmax=99;
           end;
       %end;
       if &v.h077>&bproptxa3 then &v.h077=99999996;
       if &v.h188>&bproptxb3 then &v.h188=99999996;
       
       %prepv (&v,proptxa, &v.h075, &v.h076, &v.h077, outval=999997) 
       %prepv (&v,proptxb, &v.h186, &v.h187, &v.h188, outval=99997)
 
   /* covariates for imputations */
   /* religion, retired, education, geographic location, city size, health */
   age=max(r&w.agey_e,s&w.agey_e); /* age of oldest in couple */
   agesq=age*age;
   if ragender=1 then do;
      m_hispan=(rahispan=1);
      m_white=(raracem=1 and m_hispan=0);
      m_black=(raracem=2 and m_hispan=0);
      m_othrace=(raracem=3 and m_hispan=0);
      m_lths=(raeduc in (1,2)); /* lt high school or GED */
      m_hsgrad=(raeduc=3);
      m_college=(raeduc>3);

      /* spouse covars */
      f_hispan=(s&w.hispan=1);
      f_white=(s&w.racem=1 and f_hispan=0);
      f_black=(s&w.racem=2 and f_hispan=0);
      f_othrace=(s&w.racem=3 and f_hispan=0);
      f_lths=(s&w.educ in (1,2)); /* lt high school or GED */
      f_hsgrad=(s&w.educ=3);
      f_college=(s&w.educ>3);
   end;
   else do;
      f_hispan=(rahispan=1);
      f_white=(raracem=1 and f_hispan=0);
      f_black=(raracem=2 and f_hispan=0);
      f_othrace=(raracem=3 and f_hispan=0);
      f_lths=(raeduc in (1,2)); /* lt high school or GED */
      f_hsgrad=(raeduc=3);
      f_college=(raeduc>3);

      /* spouse covars */
      m_hispan=(s&w.hispan=1);
      m_white=(s&w.racem=1 and m_hispan=0);
      m_black=(s&w.racem=2 and m_hispan=0);
      m_othrace=(s&w.racem=3 and m_hispan=0);
      m_lths=(s&w.educ in (1,2)); /* lt high school or GED */
      m_hsgrad=(s&w.educ=3);
      m_college=(s&w.educ>3);
   end;
   cpl=h&w.cpl;  /* whether married partnered */
   
   mobil=(i&w.aomobl=1);  /* whether its a mobile home */
   housa=h&w.ahous;  /* home value-primary */
   housb=h&w.ahoub;  /* home value-2nd home */
   if h&w.itot<=1 then loginc=0; /* log income */
   else loginc=log(h&w.itot);   
   if h&w.atotn<=1 then logwlth_nh=0;  /* non housing wealth */
   else logwlth_nh=log(h&w.atotn);

   /* Census division of residence */
   array div_[*] neng midatl encent wncent satl escent wscent mountain pacific;
   do i=1 to dim(div_);
      div_[i]=0;
   end;
   if 1<=r&w.cendiv<=dim(div_) then div_[r&w.cendiv]=1;
   notus=(r&w.cendiv=11);
   
run;
           
/* for checking N of hholds we should wind up with when we select on keepr */
proc sql;
   create table hholds as select distinct whhid from prep_ptax&yr;
   select count(whhid) from hholds;
proc sort data=prep_ptax&yr (where=(keepr=1))
          out=out.prep_ptax&yr;
   by whhid;
proc sort data=out.prep_ptax&yr nodupkey;  /* shouldn't see any dropped */
   by whhid;
proc freq data=out.prep_ptax&yr;
   table d_proptxa h&w.aohous diproptxa
         d_proptxb h&w.aohoub diproptxb
         i_proptxa ciproptxa ccproptxa ccproptxa*&v.h076*&v.h077
         i_proptxb ciproptxb ccproptxb ccproptxb*&v.h187*&v.h188
         infproptxa infproptxb
         /missing list;
   table r&w.cendiv*neng*midatl*encent*wncent*satl*escent*wscent*mountain*pacific*notus
         mobil*i&w.aomobl
         nofindat*&v.xmod_hh*h&w.anyfin*r&w.finr*s&w.finr
         /missing list;
run;
proc means data=out.prep_ptax&yr;
run;
proc contents data=out.prep_ptax&yr;
run;
%mend;

%let covar=age agesq cpl 
           m_hispan m_black m_othrace m_lths m_hsgrad m_college
           neng midatl encent wncent satl escent wscent mountain pacific notus
           mobil loginc logwlth_nh
           housa housb;

%prepimp(6,02,h)
%prepimp(7,04,j)
