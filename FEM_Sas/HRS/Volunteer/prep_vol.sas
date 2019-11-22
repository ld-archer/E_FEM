
/************************************
prep_vol.sas

prepare volunteer hours variables for imputation

pstclair 4/2012, for 1998 thru 2008
pstclair 5/2012, added a "fake" bracket for 2004+, where no continuous
   # of hours is asked.  The imputations tend to be lower than in 2002
   and previous years. The fake bracket will be at 1000.
weihanch 3/2015, update the variables through 2012 HRS data
************************************/
options ls=180 ps=84 compress=yes nocenter replace FORMDLIM=' ' mprint;
options ls=120 ps=58 nocenter replace nofmterr compress=yes mprint;

%include "../../../fem_env.sas";  /* file to set up libnames, fmt/mac locations */

libname hrs "&hrslib";
libname out "&outlib";
libname library "&hrslib";

** ASSET AND WAVE SPECIFIC INFORMATION ON VALUE RANGES AND NUMBERS OF BRACKETS **;

** DEFINING PREPV MACRO **;
        
%macro prepv (type,val,min,max,outval=99999997);  

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
     else if di&type then inf&type = 7;
     else if d_&type = 0 then inf&type = 6; 
       
%mend prepv;


** RUNNING PREPV MACRO **;
%macro prepimp(w,yr,relimport=,
               volany=,volhrs=,vol100=,vol200=,vol50=,volbkt=,volmin=,volmax=,
               hlpany=,hlphrs=,hlp100=,hlp200=,hlp50=,hlpbkt=,hlpmin=,hlpmax=);

%if &yr=98 | &yr=00 | &yr=02 %then %do;
    %include "ranges_9802.inc";
%end;
%else %do;
    %include "ranges_04f.inc";
%end;

%let hrsyr = %sysget(HRS&yr);

/* merge together raw 1st and 2nd home property tax vars from fat files,
         whether own 1st/2nd home and values from imputations,
         covariates for imputation from rand hrs
*/
data out.prep_vol&yr;
   merge hrs.&hrsyr (in=_inf keep=hhidpn &relimport
                                  &volany &volhrs &vol100 &vol200 &vol50 &volbkt &volmin &volmax 
                                  &hlpany &hlphrs &hlp100 &hlp200 &hlp50 &hlpbkt &hlpmin &hlpmax)
         hrsxregion (in=_inur keep=hhidpn urbrur&yr)
         hrs.rndhrs_&rndv (in=_inr keep=hhidpn inw&w h&w.hhid ragender raracem rahispan r&w.agey_e h&w.cpl
                                    raeduc h&w.atotb h&w.itot r&w.cendiv r&w.finr h&w.anyfin 
                                    r&w.work r&w.shlt r&w.adla r&w.iadlza r&w.cesd rarelig 
                                    r&w.sayret r&w.retemp r&w.lbrf
                                    s&w.gender s&w.agey_e s&w.educ s&w.hispan s&w.racem
                                    s&w.finr s&w.hhidpn);
    by hhidpn;
    
    if _inf and inw&w;
    if not missing(r&w.agey_e); *if missing age it will be dropped from the transition, for hhipn=904163021 ;
   
    ** OWNERSHIP **;
    
       if &volany in (1,5) then d_volun=(&volany=1);
       else d_volun=.;
       
    ** AMOUNTS, BRACKETS, FLAGS **;
       
       %let sec=r;
       

       %if &yr=02 %then %do;  %* min/max given;
           volmin=&volmin;
           volmax=&volmax;
           if volmax>201 then volmax=99999996;
           if volmax>0 and volmin=. then volmin=0;
           volhrs=&volhrs;

           /* no explicit question about whehter helped friends/fam
              but split between 0 hrs and non-missing hrs about same as
              in later years when there is an explicit question */
              
           if 0<=&hlphrs<9998 then d_hlpff=(&hlphrs>0);
           else d_hlpff=.;

           hlpmin=&hlpmin;
           hlpmax=&hlpmax;
           if hlpmax>201 then hlpmax=99999996;
           if hlpmax>0 and hlpmin=. then hlpmin=0;
           hlphrs=&hlphrs;
           if hlpmin>0 then d_hlpff=1;
                      
           %let chkvol=&volmin*&volmax;
           %let chkhlp=&hlpmin*&hlpmax;
       %end;
       %else %if &yr=00 | &yr=98 %then %do;  %* hours given +2individual questions ;
           if &volhrs=. or &volhrs>=9998 then select (&volbkt);
              when(1) do; volmin=0; volmax=99; end;
              when(2) do; volmin=100; volmax=100; end;
              when(3) do; volmin=101; volmax=199; end;
              when(4) do; volmin=200; volmax=200; end;
              when(5) do; volmin=201; volmax=99999996; end;
              when(6) do; volmin=101; volmax=99999996; end;
              when(8) do; volmin=0; volmax=99999996; end;
              otherwise;
           end;
           volhrs=&volhrs;

           /* no explicit question about whehter helped friends/fam
              but split between 0 hrs and non-missing hrs about same as
              in later years when there is an explicit question */

           if 0<=&hlphrs<9998 then d_hlpff=(&hlphrs>0);
           else d_hlpff=.;

           if d_hlpff=. then select (&hlpbkt);
              when(1) do; hlpmin=0; hlpmax=99; end;
              when(2) do; hlpmin=100; hlpmax=100; end;
              when(3) do; hlpmin=101; hlpmax=199; end;
              when(4) do; hlpmin=200; hlpmax=200; end;
              when(5) do; hlpmin=201; hlpmax=99999996; end;
              when(6) do; hlpmin=101; hlpmax=99999996; end;
              when(8) do; hlpmin=0; hlpmax=99999996; end;
              otherwise;
           end;
           
           if hlpmin>0 then d_hlpff=1;  /* if >0 hours in bkts, then own */
           
           hlphrs=&hlphrs;

           %let chkvol=&volbkt;
           %let chkhlp=&hlpbkt;
       %end;
       %else %do;
           if d_volun=1 then do;
              volmin=0;
              volmax=99999996;
              if &vol100=3 then do;
                 volmin=100;
                 volmax=100;
              end;
              else if &vol100=1 then volmax=99;
              else if &vol100=5 then volmin=101;
              
              if &vol50=3 then do;  /* about 50 */
                 volmin=50;
                 volmax=50;
              end;
              else if &vol50=1 then volmax=49; /* less than 50 */
              else if &vol50=5 then volmin=51; /* more than 50 */
       
              if &vol200=3 then do;  /* about 200 */
                 volmin=200;
                 volmax=200;
              end;
              else if &vol200=1 then volmax=199; /* less than 200 */
              else if &vol200=5 then volmin=201; /* more than 200 */
           end;
           volhrs=.;  /* no hours asked from 2004 forward */

           if &hlpany in (1,5) then d_hlpff=(&hlpany=1);
           else d_hlpff=.;
           
           if d_hlpff=1 then do;
              hlpmin=0;
              hlpmax=99999996;
              if &hlp100=3 then do;
                 hlpmin=100;
                 hlpmax=100;
              end;
              else if &hlp100=1 then hlpmax=99;
              else if &hlp100=5 then hlpmin=101;
              
              if &hlp50=3 then do;  /* about 50 */
                 hlpmin=50;
                 hlpmax=50;
              end;
              else if &hlp50=1 then hlpmax=49; /* less than 50 */
              else if &hlp50=5 then hlpmin=51; /* more than 50 */
       
              if &hlp200=3 then do;  /* about 200 */
                 hlpmin=200;
                 hlpmax=200;
              end;
              else if &hlp200=1 then hlpmax=199; /* less than 200 */
              else if &hlp200=5 then hlpmin=201; /* more than 200 */
           end;
           hlphrs=.;
           
           %let chkvol=&vol100*&vol200*&vol50;
           %let chkhlp=&hlp100*&hlp200*&hlp50;
           
       %end;

       %prepv (volun, volhrs, volmin, volmax, outval=9997) 
       %prepv (hlpff, hlphrs, hlpmin, hlpmax, outval=9997)

       /* Added May 21,2012: the question asks about hours in the last year.
          The max hours in a year is 365*24 = 8760.  Cap hours at 8760. */

       label volcap="Flag indicating if hrs> max hrs in year";
       label hlpcap="Flag indicating if hrs> max hrs in year";
           
       volcap=0;
       if a_volun>8760 then do;
          _volhrs=a_volun;
          a_volun=8760;
          volcap=1;
       end;

       hlpcap=0;
       if a_hlpff>8760 then do;
          _hlphrs=a_hlpff;
          a_hlpff=8760;
          hlpcap=1;
       end;
 
   /* covariates for imputations */
   /* religion, retired, education, geographic location, city size, health */
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
   
   /* religion */
   rel_someimp=(&relimport=3);
   rel_notimp=(&relimport=5);
   catholic=(rarelig=2);
   jewish=(rarelig=3);
   relnone=(rarelig=4);
   reloth=(rarelig=5);
run;
           
proc freq data=out.prep_vol&yr;
   table d_volun divolun volcap
         d_hlpff dihlpff hlpcap
         i_volun civolun ccvolun civolun*ccvolun divolun*ccvolun*volmin*volmax*abtvolun
         i_hlpff cihlpff cchlpff cihlpff*civolun dihlpff*cchlpff*hlpmin*hlpmax*abthlpff
         infvolun infhlpff infvolun*d_volun*civolun*i_volun
         infhlpff*d_hlpff*cihlpff*i_hlpff
         /missing list;
   table r&w.cendiv*neng*midatl*encent*wncent*satl*escent*wscent*mountain*pacific*notus
         urbrur&yr*urban*suburb*exurb
         &relimport*rel_someimp*rel_notimp
         rarelig*catholic*jewish*relnone*reloth
         volmin*volmax*&chkvol
         hlpmin*hlpmax*&chkhlp
         /missing list;
run;
proc means data=out.prep_vol&yr;
run;
proc contents data=out.prep_vol&yr;
run;
%mend;

%let covar=age agesq cpl male
           hispan black othrace lths hsgrad college
           shltgood shltfpoor anyiadl anyadl work retired disabled
           neng midatl encent wncent satl escent wscent mountain pacific notus
           loginc logwlth_nh
           catholic jewish relnone reloth rel_notimp rel_someimp
           suburb exurb;

data hrsxregion; set hrs.hrsxregion (keep=hhidpn urbrur:) ;

rename urbrur10_2010=urbrur10;

run;

%prepimp(4,98,relimport=F1055,
         volany=F2677,volhrs=F2678,volbkt=F2679B,
         hlpany=F2677,hlphrs=F2681,hlpbkt=F2682B)

%prepimp(5,00,relimport=G1142,
         volany=G2995,volhrs=G2996,volbkt=G2997B,
         hlpany=G2995,hlphrs=G2999,hlpbkt=G3000B)
         
%prepimp(6,02,relimport=HB053,volany=HG086,
         volhrs=hg087,volmin=hg089,volmax=hg090,
         hlphrs=hg092,hlpmin=hg094,hlpmax=hg095)
         
%prepimp(7,04,relimport=JB053,volany=JG086,
         vol100=JG195,vol200=JG196,vol50=JG197,
         hlpany=JG198,hlp100=JG199,hlp200=JG200,hlp50=JG201)

%prepimp(8,06,relimport=KB053,volany=KG086,
         vol100=KG195,vol200=KG196,vol50=KG197,
         hlpany=KG198,hlp100=KG199,hlp200=KG200,hlp50=KG201)

%prepimp(9,08,relimport=LB053,volany=LG086,
         vol100=LG195,vol200=LG196,vol50=LG197,
         hlpany=LG198,hlp100=LG199,hlp200=LG200,hlp50=LG201)

%prepimp(10,10,relimport=MB053,volany=MG086,
         vol100=MG195,vol200=MG196,vol50=MG197,
         hlpany=MG198,hlp100=MG199,hlp200=MG200,hlp50=MG201)

%prepimp(11,12,relimport=NB053,volany=NG086,
         vol100=NG195,vol200=NG196,vol50=NG197,
         hlpany=NG198,hlp100=NG199,hlp200=NG200,hlp50=NG201)
