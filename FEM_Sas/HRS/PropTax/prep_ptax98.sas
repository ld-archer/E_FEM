/** \file prep_ptax.sas
    
    prepare property tax variables for imputation
    
    \author pstclair
    \date 02/2012

    for 2002 and 2004
************************************/
options ls=120 ps=58 nocenter replace nofmterr compress=yes mprint;

%include "../../../fem_env.sas";  /* file to set up libnames, fmt/mac locations */

libname hrs "&hrslib";
libname out "&outlib";
libname library "&hrslib";



** ASSET AND WAVE SPECIFIC INFORMATION ON VALUE RANGES AND NUMBERS OF BRACKETS **;

%include "ranges_v198.inc";


** DEFINING PREPV MACRO **;
        
%macro prepv (v,type,val,min,max,outval=99999997);  

title "HRS&yr: Prep Property Tax for imputation";


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
     else if %if &sec=f %then nofindat=1 and d_&type<0 and &v.XMOD_f>0 then inf&type = 9;
             %if &sec=j %then nofindat=1 and d_&type<0 then inf&type = 9;;
     
     else if di&type then inf&type = 7;
     else if d_&type = 0 then inf&type = 6; 
       
%mend prepv;


** RUNNING PREPV MACRO **;
%macro prepimp(w,yr,v);
/* merge together raw 1st and 2nd home property tax vars from fat files,
         whether own 1st/2nd home and values from imputations,
         covariates for imputation from rand hrs
** 3/2015 Add the hrs&yr from 1998 to 2012, the variable name for h075, h076, h077, h186, h187, h188 are different for
year1998, 2000. 
h075 - REAL ESTATE TX - G3127 for 2000, F2809 for 1998
h076 - REAL ESTATE TX - MINIMUM; N/A for 2000 and 1998
h077 - REAL ESTATE TX - MAXIMUM; N/A for 2000 and 1998
h186 - REAL ESTATE TAX - 2ND HOME; G3315 for 2000, F2997 for 1998
h187 - REAL ESTATE TAX - 2ND HOME - MINIMUM; N/A for 2000 and 1998
h188 - REAL ESTATE TAX - 2ND HOME - MAXIMUM; N/A for 2000 and 1998

*/
data prep_ptax&yr;
   merge hrs.hrs&yr (in=_inf keep=hhidpn &v.xmod_f f2809 f2810b f2997 f2998b)
         hrs.incwlth_&rndv (in=_inw keep=hhidpn h&w.aohous h&w.ahous h&w.aohoub h&w.ahoub h&w.aomobl h&w.amobl
                                            h&w.aohou1 h&w.ahou1)
         hrs.rndhrs_&rndv  (in=_inr keep=hhidpn inw&w h&w.hhid ragender raracem rahispan r&w.agey_e h&w.cpl
                                    raeduc h&w.atotn h&w.itot r&w.cendiv r&w.finr h&w.anyfin
                                    s&w.gender s&w.agey_e s&w.educ s&w.hispan s&w.racem
                                    s&w.finr s&w.hhidpn);
    by hhidpn;
    
    if _inf;
    
    /*rename f2809 and f2997 */
    &v.h075 = f2809 ;
    &v.h186 = f2997 ;
    
    /* keep one record per household */
    keepr=(h&w.cpl=0 or (r&w.finr=1 and h&w.cpl=1) or (h&w.cpl=1 and h&w.anyfin=0 and first.hhidpn));
    
    whhid=h&w.hhid; /* wave-specific hhid */
    nofindat=(fxmod_f>0);  /* no finr for housing section */
    
    ** OWNERSHIP **;
    
       d_proptxa=(h&w.aohous=1);
       d_proptxb=(h&w.aohoub=1);      
   
    ** AMOUNTS, BRACKETS, FLAGS **;

           if &v.h075=. or &v.h075>=9999998 then select (F2810b);
              when(1) do; &v.h076=0; &v.h077=499; end;
              when(2) do; &v.h076=500; &v.h077=500; end;
              when(3) do; &v.h076=501; &v.h077=2999; end;
              when(4) do; &v.h076=0; &v.h077=2999; end;
              when(5) do; &v.h076=3000; &v.h077=3000; end;
              when(6) do; &v.h076=3001; &v.h077=9999; end;
              when(7) do; &v.h076=10000; &v.h077=10000; end;
              when(8) do; &v.h076=10001; &v.h077=99999996; end;
              when(9) do; &v.h076=3001; &v.h077=99999996; end;
              when(98) do; &v.h076=0; &v.h077=99999996; end;
              otherwise;
           end;
 
 
           if &v.h186=. or &v.h186>=9999998 then select (F2998b);
              when(1) do; &v.h187=0; &v.h188=499; end;
              when(2) do; &v.h187=500; &v.h188=500; end;
              when(3) do; &v.h187=501; &v.h188=2999; end;
              when(4) do; &v.h187=0; &v.h188=2999; end;
              when(5) do; &v.h187=3000; &v.h188=3000; end;
              when(6) do; &v.h187=3001; &v.h188=9999; end;
              when(7) do; &v.h187=10000; &v.h188=10000; end;
              when(8) do; &v.h187=10001; &v.h188=99999996; end;
              when(9) do; &v.h187=3001; &v.h188=99999996; end;
              when(98) do; &v.h187=0; &v.h188=99999996; end;
              otherwise;
          end;
      
       %let sec=f;
       
       if &v.h077>&bproptxa3 then &v.h077=99999996;
       if &v.h188>&bproptxb3 then &v.h188=99999996;
      
       %prepv (&v,proptxa, &v.h075, &v.h076, &v.h077, outval=999997) 
       %prepv (&v,proptxb, &v.h186, &v.h187, &v.h188, outval=99997)
 
   /* covariates for imputations */
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
   
   mobil=(h&w.aomobl=1);  /* whether its a mobile home */
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
         mobil*h&w.aomobl
         nofindat*&v.xmod_f*h&w.anyfin*r&w.finr*s&w.finr
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

/* Impute only for year 1998 */

%prepimp(4,98,f)

