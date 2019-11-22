/*************************************************
gkcarehours.sas

Merge total hours taking care of grandkids last 2 years across years.

Make a stata data set.

July 2012: add the count of kids living within 10 miles which will
   be used as a covariate in modeling gkid care hours.
   
**************************************************/

options ls=200 ps=82 compress=yes nocenter replace nodate nonumber mprint nofmterr;

%include "../../../fem_env.sas";  /* file to set up libnames, fmt/mac locations */

/* temporarily set maxwv to maxfamwv, in case the # of waves available 
   on the RAND HRS is more than on the RAND FAM files.
   That way the wvlist/wvlabel macros will work (they use maxwv) */
%let maxwv=&maxfamwv;

libname imp "&outlib";
libname hrs "&hrslib";
libname fam "&hrslib/RANDFAM";
libname library "&hrslib";

Options fmtsearch=(library.rndfam_fmts);

%let pgm=gkcarehours;  /* program name, for lst files,  separated by year */

%include "&maclib.wvlist.mac";
%include "&maclib.wvlabel.mac";

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
         imp.gkcareimp10 (%renvyr(10) drop=_ai: _gkchrs gkccap)
         /* probably replace these:
         fam.count98R (keep=hhidpn r4liv10kn r4resdkn)
         fam.count00R (keep=hhidpn r5liv10kn r5resdkn)
         fam.count02R (keep=hhidpn r6liv10kn r6resdkn)
         fam.count04R (keep=hhidpn r7liv10kn r7resdkn)
         fam.count06R (keep=hhidpn r8liv10kn r8resdkn)
         fam.count08R (keep=hhidpn r9liv10kn r9resdkn)
         with */
         hrs.rndfamr_&rfamv (keep=hhidpn %wvlist(h,liv10kn resdkn,begwv=4))
         hrs.rndhrs_&rndv (keep=hhidpn inw4-inw&maxwv)
         ;
    by hhidpn;
    
    if max(of inw4-inw&maxwv)=1;
    
    kid_byravg=kid_byravg10;
    nkids=nkids10;
    
    array liv10_[*] %wvlist(h,liv10kn,begwv=4);
    array resd_[*] %wvlist(h,resdkn,begwv=4);
    array nkid_liv10_[*] %wvlist(r,nkid_liv10mi,begwv=4);
    
    do i=1 to dim(liv10_);
       if liv10_[i] ne . then do;
          nkid_liv10_[i]=sum(liv10_[i],resd_[i]);
          if nkid_liv10_[i]<0 then nkid_liv10_[i]=0;
       end;
    end;
    nkid_liv10mi=r10nkid_liv10mi;
    
            
    keep hhidpn %wvlist(r,gkcarehrs anygkcare gkcarehrsf nkid_liv10mi,begwv=4) 
         kid_byravg: nkids: kid_mnage: aigkcare: 
         kid_byravg nkids nkid_liv10mi ;
   
    label
  	    kid_byravg="Average birth year of kids/stock"
  	    nkids="# of kids/stock"
  	    nkid_liv10mi="# of kids who live within 10 mi/stock"
  	    aigkcare98="Grandkid care hours /conditional on any"
  	    aigkcare00="Grandkid care hours /conditional on any"
  	    aigkcare02="Grandkid care hours /conditional on any"
  	    aigkcare04="Grandkid care hours /conditional on any"
  	    aigkcare06="Grandkid care hours /conditional on any"
  	    aigkcare08="Grandkid care hours /conditional on any"
            aigkcare10="Grandkid care hours /conditional on any"
        ;
  	    %wvlabel(R,nkid_liv10mi,%str(# of kids who live within 10 mi),begwv=4);
run;

proc means data=imp.gkcarehours n mean stddev min p25 median p75 max;
   var %wvlist(r,anygkcare gkcarehrs,begwv=4) aigkcare: ;
proc means data=imp.gkcarehours n mean stddev min median max;
proc contents data=imp.gkcarehours;
run;
