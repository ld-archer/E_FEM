
/************************************
prep_gkcare.sas

prepare grand kid care hours for imputation

pstclair 5/2012, for 1998-2008

weihanch 2/2015, update to 2012
************************************/
options ls=180 ps=84 compress=yes nocenter replace FORMDLIM=' ' mprint;
options ls=120 ps=58 nocenter replace nofmterr compress=yes mprint ;

%include "../../../fem_env.sas";  /* file to set up libnames, fmt/mac locations */


/* temporarily set maxwv to maxfamwv, in case the # of waves available 
   on the RAND HRS is more than on the RAND FAM files.
   That way the wvlist/wvlabel macros will work (they use maxwv) */
%let maxwv=&maxfamwv;

libname hrs "&hrslib";
libname out "&outlib";
libname library "&hrslib";

Options fmtsearch=(library.rndfam_fmts);

%include "&maclib.wvlist.mac";

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

%include "&maclib.wvlist.mac";

proc freq data=hrs.hrs98;
title2 hrs98;
   table f1823 /missing list;
   run;

** ASSET AND WAVE SPECIFIC INFORMATION ON VALUE RANGES AND NUMBERS OF BRACKETS **;

%include "ranges_gkidcare.inc";


** DEFINING PREPV MACRO **;
        
%macro prepv (type,val,min,max);  

title "HRS&yr: Prep Hours Caring for Grandkids for imputation";


  ** OWNERSHIP **;
  
     ** Ownership of each individual type of income has been moved outside of this macro, and into WLTHOWN7_V1.INC **;
      
     ** Determining whether ownership must be imputed **;
 
        di&type = (d_&type=.);
   
  ** AMOUNTS **;
  
     if d_&type then do;
     
        a_&type = &val;
        
        ** answered 'about $$val' in bracketing sequence **;    
        if &min=&max and &min>=0 then do;
     
          if a_&type<=.Z or a_&type=&min then do;
     
            abt&type = 1;
            a_&type = &min;
     
          end;
     
        end;
        
        else abt&type=0;
        
        i_&type = (a_&type <=.Z); ** missing value or code **;
   
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
     else if h&w.anyfam=0 and d_&type<0  then inf&type = 9;
     else if di&type then inf&type = 7;
     else if d_&type = 0 then inf&type = 6; 
       
%mend prepv;


** RUNNING PREPV MACRO **;
%macro prepimp(w,yr,ngkid=,gkcany=);

%if %substr(&yr,1,1)=9 %then %let year=19&yr;
%else %let year=20&yr;

/* get max # of gkid occurrences into macro var maxg */
proc sql;
   select max(g&w.ct) into :maxg from 
         (select sum(k&w.gkids) as g&w.ct from hrs.rndfamk group by hhidpn);
%let maxg=%eval(&maxg);  /* remove leading spaces */

/* Identify respondents who have a grandkid co-resident,
   from RAND FAM files.  Also keep # kids and # resident kids */
data kidsum 
       (keep=hhidpn ragender r&w.agey_e anyresgk
             kid_byravg kct kbyrsum gkidct);
  merge rndfamk (keep=hhidpn kabyearbg k&w.gkids k&w.resd)
        rndhrs (keep=hhidpn ragender r&w.agey_e inw&w where=(inw&w=1));
  by hhidpn;
  
  retain kct kbyrsum gkidct anyresgk;

  if first.hhidpn then do;
     kct=0;
     gkidct=0;
     kbyrsum=0;
     anyresgk=0;
  end;

  gkidct=sum(gkidct,k&w.gkids);
  if k&w.resd=1 and k&w.gkids>0 then anyresgk=1;
  
  if kabyearbg>.Z then do;
     kct=kct+1;
     kbyrsum=sum(kbyrsum,kabyearbg);
  end;
  
  if last.hhidpn then do;
     if kct>0 then kid_byravg=kbyrsum / kct;
     output;
  end;
run;
proc freq data=kidsum;
   table anyresgk /missing list;
   run;
   
proc means data=kidsum;
   var gkidct kid_byravg kbyrsum kct ;
   run;

/* get mean kid birthyr by sex and age...will use to fill missings */
proc sql;
   select mean(kid_byravg) into :mnkby4f from kidsum (where=(ragender=2 and r&w.agey_e<50));
   select mean(kid_byravg) into :mnkby5f from kidsum (where=(ragender=2 and 50<=r&w.agey_e<60));
   select mean(kid_byravg) into :mnkby6f from kidsum (where=(ragender=2 and 60<=r&w.agey_e<70));
   select mean(kid_byravg) into :mnkby7f from kidsum (where=(ragender=2 and 70<=r&w.agey_e<80));
   select mean(kid_byravg) into :mnkby8f from kidsum (where=(ragender=2 and 80<=r&w.agey_e));

   select mean(kid_byravg) into :mnkby4m from kidsum (where=(ragender=1 and r&w.agey_e<50));
   select mean(kid_byravg) into :mnkby5m from kidsum (where=(ragender=1 and 50<=r&w.agey_e<60));
   select mean(kid_byravg) into :mnkby6m from kidsum (where=(ragender=1 and 60<=r&w.agey_e<70));
   select mean(kid_byravg) into :mnkby7m from kidsum (where=(ragender=1 and 70<=r&w.agey_e<80));
   select mean(kid_byravg) into :mnkby8m from kidsum (where=(ragender=1 and 80<=r&w.agey_e));
   
%put mnkbyf &mnkby4f &mnkby5f &mnkby6f &mnkby7f &mnkby8f;
%put mnkbym &mnkby4m &mnkby5m &mnkby6m &mnkby7m &mnkby8m;

   
/* merge together any gkid care var from fat files,
         kid chars and # gkids from RAND FAM files,
         covariates for imputation from rand hrs
*/

/* check for 9995/9998/9999 and longer */
data out.prep_gkcare&yr;
   merge rndfamr (in=_inf keep=hhidpn h&w.nkid h&w.kdcarekn h&w.kdcarekf 
                                      r&w.kdcarehr r&w.kdcarmin r&w.kdcarmax)
         hrs.hrs&yr (in=_inc keep=hhidpn &ngkid &gkcany)
         hrsxregion (in=_inur keep=hhidpn urbrur&yr)
         kidsum (in=_ingk drop=ragender r&w.agey_e)
         rndhrs (in=_inr keep=hhidpn inw: ragender raracem rahispan raeduc
                                    h&w.hhid h&w.cpl h&w.atotb h&w.itot h&w.anyfam h&w.child
                                    r&w.cendiv r&w.famr r&w.agey_e r&w.work r&w.shlt 
                                    r&w.adla r&w.iadlza r&w.cesd 
                                    r&w.sayret r&w.retemp r&w.lbrf
                                    s&w.gender s&w.agey_e s&w.educ s&w.hispan s&w.racem s&w.famr s&w.hhidpn
                                    where=(inw&w=1));
             
    by hhidpn;
    
    if _inr=1 and inw&w=1;
    ingk=_ingk;
    
    /*two cases were not on rand family file, we use rndhrs hwchild variable instead of nkid*/
    if _inf=0 and _inr=1  then do ;
    	put "*POSSIBLE issue- not on Randfam " hhidpn= _inf= _inr= h&w.nkid= h&w.child= ; 
    	h&w.nkid=h&w.child ;
    end;
    
    
        
    nofindat=(h&w.anyfam=0);
    
    /* check to see when last interview was.
       question asks since last interview. If last interview 
       was not the most recent wave, adjust hours */
    array inw_[*] inw1-inw&w;
    lastiw=.;
    do i=&w-1 to 1 by -1 while (lastiw=.);
       if inw_[i]=1 then lastiw=i;
    end;
    if lastiw=. then _divhr=1;  /* no prior iw, ref period is 2 yrs */
    else _divhr=&w - lastiw;
    
    /* it appears that some of the care hours include missing values
       e.g., 99998=DK but 9998 shows up in the data
       Set these to the appropriate missing value */
    gkchrs = r&w.kdcarehr;
    if gkchrs in (9998,99998) then gkchrs=.D;
    else if gkchrs in (9999,99999) then gkchrs=.R;
    else if gkchrs in (9995,99995) then gkchrs=.L;
    gkchrs_x=(gkchrs ne r&w.kdcarehr);  /* flag changes */
   
    rescare=(gkchrs = .L);
    anyresgk = max(anyresgk,rescare);
     
    ** OWNERSHIP **;
    
    %* in 98/00 # gkids question skip code is 95, assume none
       from 02 forward the code is 96;
        
       nogk=(&ngkid=0 or (&ngkid in (95,96)));  /* no gkids, or DK if gkids */
       if &ngkid=. and max(h&w.nkid,h&w.child)=0 then nogk=2;
       
       if &gkcany in (1,5) then d_gkcare=(&gkcany=1);
       else if nogk>0 then d_gkcare=0;
       else d_gkcare=.;
       
    ** AMOUNTS, BRACKETS, FLAGS **;
       
       %let sec=r;
       
       %let chkbkt=gkchrs*gkcmin*gkcmax;
           
       gkcmin = r&w.kdcarmin;
       gkcmax = r&w.kdcarmax;
       if d_gkcare=1 and missing(gkchrs) then do;
          if missing(gkcmax) then gkcmax = 99999996;
          if gkcmax>0 and missing(gkcmin) then gkcmin = 0;
       end;
       
       if 0<gkchrs and _divhr>1 then gkchrs=gkchrs/_divhr;
       
       %prepv (gkcare, gkchrs, gkcmin, gkcmax) 

       /* Added May 21,2012: the question asks about hours in the last two years.
          The max hours in a year is 365*24 = 8760.  Cap hours at 2*8760 = 17520. */
       
       label gkccap="Flag indicating if hrs> max hrs in 2 years";
       gkccap=0;
       if a_gkcare>17520 then do;
          _gkchrs=a_gkcare;
          a_gkcare=17520;
          gkccap=1;
       end;
       
   /* covariates for imputations */
   /* retired, education, geographic location, city size, health */
   age=r&w.agey_e; 
   agesq=age*age;
   male=(ragender=1);
   hispan=(rahispan=1);
   white=(raracem=1 and hispan=0);
   black=(raracem=2 and hispan=0);
   othrace=(raracem=3 and hispan=0);
   lths=(raeduc in (1,2)); /* lt high school or GED */
   hsgrad=(raeduc=3);
   college=(raeduc>3);
   cpl=h&w.cpl;  /* whether married partnered */
   shltgood=(r&w.shlt=3);
   shltfpoor=(r&w.shlt in (4,5));
   anyadl=(r&w.adla>0);
   anyiadl=(r&w.iadlza>0);
   
   work=(r&w.work=1);
   retired=(r&w.sayret in (1,2) or r&w.retemp in (1,2));
   disabled=(r&w.lbrf=6);
   
   if h&w.itot<=1 then loginc=0; /* log income */
   else loginc=log(h&w.itot);   
   if h&w.atotb<=1 then logwlth=0;  /* wealth including homes */
   else logwlth=log(h&w.atotb);

   /* Census division of residence */
   array div_[*] neng midatl encent wncent satl escent wscent mountain pacific;
   do i=1 to dim(div_);
      div_[i]=0;
   end;
   if 1<=r&w.cendiv<=dim(div_) then div_[r&w.cendiv]=1;
   notus=(r&w.cendiv=11);

   /* urban rural */
   urban=(urbrur&yr=1); /* ref */
   suburb=(urbrur&yr=2);
   exurb=(urbrur&yr=3);   
   
   /* number kids, average kid age */
   nkids=h&w.nkid;
   kid_mnageF=0;

   if kid_byravg=. then do;  /* if missing fill with age and gender specific mean */
      if ragender=2 then do;
         if r&w.agey_e<50          then kid_byravg=&mnkby4f; 
         else if 50<=r&w.agey_e<60 then kid_byravg=&mnkby5f; 
         else if 60<=r&w.agey_e<70 then kid_byravg=&mnkby6f; 
         else if 70<=r&w.agey_e<80 then kid_byravg=&mnkby7f; 
         else if 80<=r&w.agey_e    then kid_byravg=&mnkby8f; 
      end;
      else do;
         if r&w.agey_e<50          then kid_byravg=&mnkby4m; 
         else if 50<=r&w.agey_e<60 then kid_byravg=&mnkby5m; 
         else if 60<=r&w.agey_e<70 then kid_byravg=&mnkby6m; 
         else if 70<=r&w.agey_e<80 then kid_byravg=&mnkby7m; 
         else if 80<=r&w.agey_e    then kid_byravg=&mnkby8m; 
      end;
      kid_mnageF=1;
   end;

   kid_mnage=&year - kid_byravg; /* calc kid mean age */
   
run;
           
proc freq data=out.prep_gkcare&yr;
   table ingk d_gkcare*&gkcany*nogk nogk*&ngkid gkccap
         d_gkcare*a_gkcare*anyresgk*rescare d_gkcare*a_gkcare*gkchrs*abtgkcare gkcmin*gkcmax
         &chkbkt
    /missing list;
   table d_gkcare digkcare _divhr infgkcare*_divhr
         i_gkcare cigkcare ccgkcare cigkcare*ccgkcare digkcare*ccgkcare*gkcmin*gkcmax*abtgkcare
         infgkcare infgkcare*h&w.anyfam*nogk infgkcare*d_gkcare*cigkcare*i_gkcare
         /missing list;
   table r&w.cendiv*neng*midatl*encent*wncent*satl*escent*wscent*mountain*pacific*notus
         urbrur&yr*urban*suburb*exurb
         kid_mnageF
         /missing list;
format a_gkcare gkchrs h&w.nkid h&w.child anyhrs8.;
run;
proc means data=out.prep_gkcare&&yr (where=(d_gkcare ne 0))
   n mean min p10 p25 median p75 p90;
   class kid_mnageF ragender r&w.agey_e;
   types kid_mnageF kid_mnageF*ragender*r&w.agey_e;
   var age kid_mnage;
   format r&w.agey_e agecat.;
   run;
proc means data=out.prep_gkcare&yr;
   class _divhr;
   var a_gkcare gkchrs;
   run;
proc means data=out.prep_gkcare&yr;
run;
proc contents data=out.prep_gkcare&yr;
run;
%mend;

%let covar=age agesq cpl male
           hispan black othrace lths hsgrad college
           shltgood shltfpoor anyiadl anyadl work retired disabled
           neng midatl encent wncent satl escent wscent mountain pacific notus
           loginc logwlth_nh
           nkids kid_mnage kid_byravg
           suburb exurb;

/* extract data needed from rndhrs */
data rndhrs;
   set hrs.rndhrs_&rndv (in=_inr keep=hhidpn inw1-inw&maxwv ragender raracem rahispan raeduc
                                    %wvlist(h,hhid cpl atotb itot anyfam child,begwv=4)
                                    %wvlist(r,cendiv famr agey_e work shlt adla iadlza cesd 
                                             sayret retemp lbrf,begwv=4) 
                                    %wvlist(s,gender agey_e educ hispan racem famr hhidpn,begwv=4));
   if max(of inw4-inw&maxwv)=1;
run;

data rndfamk;
   set hrs.rndfamk (keep=hhidpn kabyearbg %wvlist(k,gkids resd,begwv=4));
run;

data rndfamr;
   set hrs.rndfamr (in=_inf keep=hhidpn %wvlist(h,nkid kdcarekn kdcarekf,begwv=4)
                                       %wvlist(r,kdcarehr kdcarmin kdcarmax,begwv=4));
run;

/*rename the urbrur10_2010 in hrsxregion data */

data hrsxregion; set hrs.hrsxregion (keep=hhidpn urbrur:) ;

rename urbrur10_2010=urbrur10;

run;
      

%prepimp(4,98,ngkid=F1823,gkcany=F1832)

%prepimp(5,00,ngkid=G2039,gkcany=G2048)
         
%prepimp(6,02,ngkid=HE046,gkcany=he060)
         
%prepimp(7,04,ngkid=JE046,gkcany=je060)

%prepimp(8,06,ngkid=KE046,gkcany=ke060)

%prepimp(9,08,ngkid=LE046,gkcany=le060)

%prepimp(10,10,ngkid=ME046,gkcany=ME060)


endsas;
/* wave 11 not yet available for the rand family data */
%prepimp(11,12,ngkid=ne046,gkcany=ne060)
