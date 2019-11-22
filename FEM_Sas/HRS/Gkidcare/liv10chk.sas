/*************************************************
liv10chk.sas

check source file variables on kids living within 10 miles
or co-resident.
    
**************************************************/

options ls=200 ps=82 compress=yes nocenter replace nodate nonumber mprint nofmterr;

%include "../../../fem_env.sas";  /* file to set up libnames, fmt/mac locations */

libname imp "&outlib";
libname hrs "&hrslib";
libname fam "&dataroot.HRS/Unrestricted/Sas/RANDFAM";

%let pgm=gkcarehours;  /* program name, for lst files,  separated by year */

%include "&maclib.wvlist.mac";
%include "&maclib.wvlabel.mac";

proc format;
   value resdn
   1-9=">0";
proc freq data=fam.count04r;
  table r7liv10kn r7liv10kf*r7liv10kn r7resdkn r7resdkn*r7liv10kn /missing list;
  format r7resdkn resdn.;
  run;
proc freq data=fam.count04kr;
   table k7liv10*k7resd /missing list;
   run;
proc print data=fam.count04r (where=(r7resdkn>0) obs=10);
   id hhidpn;
   var r7liv10kn r7resdkn r7liv10kf;
   run;
proc print data=fam.count04kr (where=(hhidpn in (10063010,10075020 )));
   id hhidpn kidid;
   var k7liv10 k7resd;
   run;

run;
endsas;

/* macro to rename variables to be year specific */
%macro renvyr(yr);
rename=(kid_mnage=kid_mnage&yr 
        kid_byravg=kid_byravg&yr 
        nkids=nkids&yr
        aigkcare=aigkcare&yr
        )
%mend;
         
data imp.gkcarehours (compress=no);
   merge imp.gkcareimp98 (%renvyr(98) drop=_ai: _gkchrs gkccap)
         imp.gkcareimp00 (%renvyr(00) drop=_ai: _gkchrs gkccap)
         imp.gkcareimp02 (%renvyr(02) drop=_ai: _gkchrs gkccap)
         imp.gkcareimp04 (%renvyr(04) drop=_ai: _gkchrs gkccap) 
         imp.gkcareimp06 (%renvyr(06) drop=_ai: _gkchrs gkccap)
         imp.gkcareimp08 (%renvyr(08) drop=_ai: _gkchrs gkccap)
         fam.count98R (keep=hhidpn r4liv10kn)
         fam.count00R (keep=hhidpn r5liv10kn)
         fam.count02R (keep=hhidpn r6liv10kn)
         fam.count04R (keep=hhidpn r7liv10kn)
         fam.count06R (keep=hhidpn r8liv10kn)
         fam.count08R (keep=hhidpn r9liv10kn)
         hrs.rndhrs_&rndv (keep=hhidpn inw4-inw&maxwv)
         ;
    by hhidpn;
    
    if max(of inw4-inw&maxwv)=1;
    
    kid_byravg=kid_byravg04;
    nkids=nkids04;
    
    array liv10_[*] %wvlist(r,liv10kn,begwv=4);
    
    do i=1 to dim(liv10_);
       if liv10_[i]<0 then do;
       end;
       else svliv10=liv10_[i];
    end;
    liv10kn=r7liv10kn;
    
            
    keep hhidpn %wvlist(r,gkcarehrs anygkcare gkcarehrsf liv10kn,begwv=4) 
         kid_byravg: nkids: kid_mnage: aigkcare: 
         kid_byravg nkids liv10kn;
   
    label
  	    kid_byravg="Average birth year of kids/stock"
  	    nkids="# of kids/stock"
  	    liv10kn="# of kids who live within 10 mi/stock"
  	    aigkcare98="Grandkid care hours /conditional on any"
  	    aigkcare00="Grandkid care hours /conditional on any"
  	    aigkcare02="Grandkid care hours /conditional on any"
  	    aigkcare04="Grandkid care hours /conditional on any"
  	    aigkcare06="Grandkid care hours /conditional on any"
  	    aigkcare08="Grandkid care hours /conditional on any"
        ;
  	    %wvlabel(R,LIV10KN,%str(# of kids who live within 10 mi),begwv=4);
run;

proc means data=imp.gkcarehours n mean stddev min p25 median p75 max;
   var %wvlist(r,anygkcare gkcarehrs,begwv=4) aigkcare: ;
proc means data=imp.gkcarehours n mean stddev min median max;
proc contents data=imp.gkcarehours;
run;
