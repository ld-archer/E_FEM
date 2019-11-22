/* parhelpf.sas
   Check some things on parhelp.

   pull variables for hours of help given by R to own parents or inlaws
   sum to total hours helped, all parents
   include also:
   - count of living parents, unmarried parents, parents living within 10 mi or cores
   - parent age
   - whether parents are alive H*PARLIV = count of living parents
   - whether parent married, and whether married to each other.
   - whether co-resident or lives within 10 mi of parent
*/
options ls=125 ps=58 nocenter replace compress=no mprint; /* FILELOCKS=NONE needed at NBER */

%include "../../../fem_env.sas";  /* file to set up libnames, fmt/mac locations */

libname par "/sch-data1/projects/public-data-projects/HRS/Datalib/Data/Parents";
libname out "&outlib";
libname library "&hrslib"; /* LIBRARY - default location of formats.sas7bcat */

%include "&maclib.wvlist.mac";
%include "&maclib.wvlabel.mac";

proc format;
   value paryn
   0="0.No"
   1="1.Yes"
   .U=".U: unmarried"
   ;
   value parmar
   0="0.Unmarried"
   1="1.Married to each other"
   2="2.Married to someone else"
   .U=".U: unmarried"
    ;
   value anyhlp
   0="0.none"
   1-4="1-4.someone"
   .A,.D,.M,.R,.S,.V="missing"
   .U="unmarried"
   ;

%macro chkone(rvar,pvar,whov);
      &rvar.x_[i]=1-(&rvar._[i]=&pvar._[i]);
      if &rvar.x_[i]=1 then do;
         if missing(&rvar._[i]) and not missing(&pvar._[i]) then &rvar.x_[i]=2;
         else if not missing(&rvar._[i]) and missing(&pvar._[i]) then &rvar.x_[i]=3;
         else if &rvar._[i]=0 and &pvar._[i]>0 then &rvar.x_[i]=4;
         else if &rvar._[i]>0 and &pvar._[i]=0 then &rvar.x_[i]=5;
         if &rvar.x_[i]=3 and &rvar._[i] ne 0 then &rvar.x_[i]=93;
         else if &rvar.x_[i]=3 and &whov._[i] >0 then &rvar.x_[i]=13;
         else if &rvar.x_[i]=3 and missing(&whov._[i]) then &rvar.x_[i]=23;
      end;
      if &rvar.x_[i]=0 and &rvar._[i]=0 then &rvar.x_[i]=10;
      eles if &rvar.x_[i]=0 and missing(&rvar._[i]) then &rvar.x_[i]=9;
%mend;

data tmp;
   merge par.parents1b (in=_inb keep=hhidpn %wvlist(rp,rerrndh rpcareh,begwv=4) %wvlist(sp,rerrndh rpcareh,begwv=4) %wvlist(h,parliv,begwv=4)
                                            %wvlist(r, momliv dadliv,begwv=4) %wvlist(s, momliv dadliv,begwv=4))
         library.rndfamr_c (in=_inc keep=hhidpn inw: %wvlist(r,ppcr perd prerdh prpcrh livpar,begwv=4) %wvlist(s,ppcr perd prerdh prpcrh livpar,begwv=4) %wvlist(h,cpl,begwv=4))
         ;
   by hhidpn;

   array rppcr_[*] %wvlist(r,ppcr,begwv=4) ; /* who helped with personal care */
   array rperd_[*] %wvlist(r,perd,begwv=4) ; /* who helped with personal care */
   
   array rprerdh_[*] %wvlist(r,prerdh,begwv=4) ; /* hours R helped own parents with errands */
   array rprpcrh_[*] %wvlist(r,prpcrh,begwv=4) ; /* hours R helped own parents with personal care */
   array sprerdh_[*] %wvlist(s,prerdh,begwv=4) ; /* hours R helped parents inlaw with errands */
   array sprpcrh_[*] %wvlist(s,prpcrh,begwv=4) ; /* hours R helped parents inlaw with personal care */
   
   
   array rprerrndh_[*] %wvlist(rp,rerrndh,begwv=4) ;  /* hours R helped own parents with errands */
   array rprpcareh_[*] %wvlist(rp,rpcareh,begwv=4) ; /* hours R helped own parents with personal care */
   array sprerrndh_[*] %wvlist(sp,rerrndh,begwv=4) ; /* hours R helped parents inlaw with errands */
   array sprpcareh_[*] %wvlist(sp,rpcareh,begwv=4) ; /* hours R helped parents inlaw with personal care */

   array rprerdhx_[*] %wvlist(r,prerdhx,begwv=4) ; /* hours R helped own parents with errands */
   array rprpcrhx_[*] %wvlist(r,prpcrhx,begwv=4) ; /* hours R helped own parents with personal care */
   array sprerdhx_[*] %wvlist(s,prerdhx,begwv=4) ; /* hours R helped parents inlaw with errands */
   array sprpcrhx_[*] %wvlist(s,prpcrhx,begwv=4) ; /* hours R helped parents inlaw with personal care */

   array ptothelp_[*] %wvlist(r,ptothelp,begwv=4);
   array rtothelp_[*] %wvlist(r,rtothelp,begwv=4);
   
   array inw_[*] inw4-inw&maxwv;
   
   do i=1 to dim(inw_);
      if inw_[i]=1 then do;
         ptothelp_[i]=sum(rprerrndh_[i],rprpcareh_[i],sprerrndh_[i],sprpcareh_[i]);
         rtothelp_[i]=sum(rprerdh_[i],rprpcrh_[i],sprerdh_[i],sprpcrh_[i]);
         
         %chkone(rprerdh,rprerrndh,rperd);
         %chkone(sprerdh,sprerrndh,rperd);
         %chkone(rprpcrh,rprpcareh,rppcr);
         %chkone(sprpcrh,sprpcareh,rppcr);
      end;
   end;
run;
proc freq data=tmp;
   table r7prpcrhx*r7ppcr h7cpl*s7prpcrhx*r7ppcr
         r7prerdhx*r7perd
         h7parliv*r7livpar*s7livpar
         r7livpar*r7momliv*r7dadliv s7livpar*s7momliv*s7dadliv
         h7cpl*h7parliv*r7momliv*r7dadliv*s7momliv*s7dadliv
         %wvlist(r,prerdhx prpcrhx,begwv=4)
         %wvlist(s,prerdhx prpcrhx,begwv=4)
         /missing list;
run;
proc means data=tmp;
   class r7prpcrhx s7prpcrhx;
   types () r7prpcrhx s7prpcrhx r7prpcrhx*s7prpcrhx;
   var r7prpcrh rp7rpcareh s7prpcrh sp7rpcareh r7ptothelp r7rtothelp
       ;
run;
proc means data=tmp n mean stddev sum min p50 max;
   var %wvlist(r,ptothelp rtothelp,begwv=4);
   run;
proc means data=tmp n mean stddev sum min p50 max missing;
   class r4ppcr r4perd;
   types () r4ppcr*r4perd;
   format r4ppcr r4perd anyhlp.;
   var %wvlist(r,ptothelp rtothelp prpcrh prerdh ,begwv=4,endwv=4)
       %wvlist(rp,rpcareh rerrndh,begwv=4,endwv=4)
       %wvlist(sp,rpcareh rerrndh,begwv=4,endwv=4)
       %wvlist(s,prpcrh prerdh ,begwv=4,endwv=4);
   run;

proc means data=tmp n mean stddev sum min p50 max missing;
   class r7ppcr r7perd;
   types () r7ppcr*r7perd;
   format r7ppcr r7perd anyhlp.;
   var %wvlist(r,ptothelp rtothelp prpcrh prerdh ,begwv=7,endwv=7)
       %wvlist(rp,rpcareh rerrndh,begwv=7,endwv=7)
       %wvlist(sp,rpcareh rerrndh,begwv=7,endwv=7)
       %wvlist(s,prpcrh prerdh ,begwv=7,endwv=7);
   run;
   
proc means data=par.parents1b;
title2 parents1b;
   vars  
        %wvlist(rp,rerrndh,begwv=4)  /* hours R helped own parents with errands */
        %wvlist(rp,rpcareh,begwv=4)  /* hours R helped own parents with personal care */
        %wvlist(sp,rerrndh,begwv=4)  /* hours R helped parents inlaw with errands */
        %wvlist(sp,rpcareh,begwv=4)  /* hours R helped parents inlaw with personal care */
        %wvlist(rp,serrndh,begwv=4)  /* hours R helped own parents with errands */
        %wvlist(rp,spcareh,begwv=4)  /* hours R helped own parents with personal care */
        %wvlist(sp,serrndh,begwv=4)  /* hours R helped parents inlaw with errands */
        %wvlist(sp,spcareh,begwv=4)  /* hours R helped parents inlaw with personal care */
    ;
run;
proc means data=library.rndfamr_c;
title2 rndfamr_c;
   vars
        %wvlist(r,prerdh,begwv=4)  /* hours R helped own parents with errands */
        %wvlist(r,prpcrh,begwv=4)  /* hours R helped own parents with personal care */
        %wvlist(s,prerdh,begwv=4)  /* hours R helped parents inlaw with errands */
        %wvlist(s,prpcrh,begwv=4)  /* hours R helped parents inlaw with personal care */
        %wvlist(r,pserdh,begwv=4)  /* hours R helped own parents with errands */
        %wvlist(r,pspcrh,begwv=4)  /* hours R helped own parents with personal care */
        %wvlist(s,pserdh,begwv=4)  /* hours R helped parents inlaw with errands */
        %wvlist(s,pspcrh,begwv=4)  /* hours R helped parents inlaw with personal care */
    ;


proc freq data=out.parhelp;
  table r4paralive*(r4par10mi r4parnotmar)
        r5paralive*(r5par10mi r5parnotmar)
        r6paralive*(r6par10mi r6parnotmar)
        r7paralive*(r7par10mi r7parnotmar)
        r8paralive*(r8par10mi r8parnotmar)
        r9paralive*(r9par10mi r9parnotmar)
        /missprint list;
        run;
       
endsas;
proc print data=par.parents1b (where=(rp9rpcareh>9000));
   by hhidpn;
run;

proc print data=par.parents1b (where=(p9rahrX1>p9rahrU1 or p9rchrX1>p9rchrU1 or p9rahrX2>p9rahrU2 or p9rchrX2>p9rchrU2));
   by hhidpn;
   var p9: ;
run;

proc print data=par.parents1b (where=(p8rahrX1>p8rahrU1 or p8rchrX1>p8rchrU1 or p8rahrX2>p8rahrU2 or p8rchrX2>p8rchrU2));
   by hhidpn;
   var p8: ;
run;
