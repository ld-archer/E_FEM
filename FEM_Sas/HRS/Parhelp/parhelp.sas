/* parhelp.sas
   pull variables for hours of help given by R to own parents or inlaws
   sum to total hours helped, all parents
   include also:
   - count of living parents, unmarried parents, parents living within 10 mi or cores
   - parent age
   - whether parents are alive H*PARLIV = count of living parents
   - whether parent married, and whether married to each other.
   - whether co-resident or lives within 10 mi of parent
*2/26 update to year 2012   
*/
options ls=125 ps=58 nocenter replace compress=no mprint; /* FILELOCKS=NONE needed at NBER */

%include "../../../fem_env.sas";  /* file to set up libnames, fmt/mac locations */

/* temporarily set maxwv to maxfamwv, in case the # of waves available 
   on the RAND HRS is more than on the RAND FAM files.
   That way the wvlist/wvlabel macros will work (they use maxwv) */
%let maxwv=&maxfamwv;

libname out "&outlib";
libname library "&hrslib"; /* LIBRARY - default location of formats.sas7bcat */

Options fmtsearch=(library.rndfam_fmts);

%include "&maclib.wvlist.mac";
%include "&maclib.wvlabel.mac";

%let maxhours=17520;  /* max hours in 2 yrs = 24*365*2 */

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
       
/* macro to derive measure for a parent
   p can be rm for R mom, rf for R dad,
     sm for R mom inlaw, sf for R dad inlaw
*/
%macro setpar(p);
   &p.alive_[i]=&p.liv_[i];
   if &p.alive_[i]=1 then do;
      paralive_[i]=paralive_[i]+1;  /* count unmarried parents */
      &p.livage_[i]=&p.age_[i]; /* parent age if alive */
      &p.liv10mi_[i]=(&p.liv10_[i]=1 or &p.livwho_[i]=1); /* is par within 10 mi or cores */
      &p.married_[i]=(&p.mstat_[i] in (1,2)) + 2*(&p.mstat_[i]=3); /* married=1 if married to each other, 2 someone else */
      
      if &p.married_[i]=0 then parnotmar_[i]=parnotmar_[i]+1;  /* count unmarried parents */
      if &p.liv10mi_[i]=1 then par10mi_[i]=par10mi_[i]+1;      /* count parents within 10 mi or cores */
      
   end;
%mend;

data out.parhelp (keep=hhidpn %wvlist(r,parhelphours paralive parnotmar par10mi,begwv=4)
                              %wvlist(rm,alive livage married liv10mi,begwv=4)
                              %wvlist(rf,alive livage married liv10mi,begwv=4)
                              %wvlist(sm,alive livage married liv10mi,begwv=4)
                              %wvlist(sf,alive livage married liv10mi,begwv=4))
     chkparhelp  /* to check fields */
    ;

   merge library.rndfamr_&rfamv (in=_inp keep=hhidpn 
                                              %wvlist(r,momliv momage mmstat mlivwho mlv10mi 
                                                        dadliv dadage fmstat flivwho flv10mi 
                                                        livpar prpcrh prerdh ppcr perd,begwv=4 )
                                              %wvlist(s,momliv momage mmstat mlivwho mlv10mi 
                                                        dadliv dadage fmstat flivwho flv10mi 
                                                        livpar prpcrh prerdh ppcr perd,begwv=4 ))
         library.rndhrs_&rndv (in=_inr keep=hhidpn inw: %wvlist(r,iwendy) %wvlist(h,cpl));
   by hhidpn;
   
   infrom=10*_inr + _inp;
   if max(of inw4-inw&maxwv)=1;
      
   array inw_[*] inw4-inw&maxwv;
   array iwyear_[*] %wvlist(r,iwendy,begwv=4);
   array hcpl_[*] %wvlist(h,cpl,begwv=4);
   
   /**** Parent vars from RAND FAM file *********/
   /* R's mom */
   array rmliv_[*]   %wvlist(r,momliv,begwv=4) ;  
   array rmage_[*]   %wvlist(r,momage,begwv=4);  
   array rmmstat_[*] %wvlist(r,mmstat,begwv=4) ; 
   array rmliv10_[*] %wvlist(r,mlv10mi,begwv=4) ;
   array rmlivwho_[*] %wvlist(r,mlivwho,begwv=4);
   /* R's dad */
   array rfliv_[*]   %wvlist(r,dadliv,begwv=4) ;  
   array rfage_[*]   %wvlist(r,dadage,begwv=4);  
   array rfmstat_[*] %wvlist(r,fmstat,begwv=4) ; 
   array rfliv10_[*] %wvlist(r,flv10mi,begwv=4) ;
   array rflivwho_[*] %wvlist(r,flivwho,begwv=4);
   /* R's mom inlaw */
   array smliv_[*]   %wvlist(s,momliv,begwv=4) ;  
   array smage_[*]   %wvlist(s,momage,begwv=4);  
   array smmstat_[*] %wvlist(s,mmstat,begwv=4) ; 
   array smliv10_[*] %wvlist(s,mliv10,begwv=4) ;
   array smlivwho_[*] %wvlist(s,mlivwho,begwv=4);
   /* R's dad inlaw */
   array sfliv_[*]   %wvlist(s,dadliv,begwv=4) ;  
   array sfage_[*]   %wvlist(s,dadage,begwv=4);  
   array sfmstat_[*] %wvlist(s,fmstat,begwv=4) ; 
   array sfliv10_[*] %wvlist(s,fliv10,begwv=4) ;
   array sflivwho_[*] %wvlist(s,flivwho,begwv=4);
   
   /* living parents count */
   array rlivpar_[*]   %wvlist(r,livpar,begwv=4) ;  
   array slivpar_[*]   %wvlist(s,livpar,begwv=4) ;  

   /* help given to parents (either own or in-laws */
   array rppcare_[*] %wvlist(r,ppcr,begwv=4);  /* who received help with personal care */
   array rperrnd_[*] %wvlist(r,perd,begwv=4);  /* who received help with errands */
   array sppcare_[*] %wvlist(s,ppcr,begwv=4);  /* who received help with personal care */
   array sperrnd_[*] %wvlist(s,perd,begwv=4);  /* who received help with errands */
   
   array rprerrndh_[*] %wvlist(r,prerdh,begwv=4) ; /* hours R helped own parents with errands */
   array rprpcareh_[*] %wvlist(r,prpcrh,begwv=4) ; /* hours R helped own parents with personal care */
   array sprerrndh_[*] %wvlist(s,prerdh,begwv=4) ; /* hours R helped parents inlaw with errands */
   array sprpcareh_[*] %wvlist(s,prpcrh,begwv=4) ; /* hours R helped parents inlaw with personal care */
  
   /*** Vars derived for FEM ***/
   array rparhelphours_[*] %wvlist(r,parhelphours,begwv=4) ; /* hours R helped own parents or inlaws with pers care and errands */
  
   array rmalive_[*] %wvlist(rm,alive,begwv=4); /* r mom whether alive */
   array rfalive_[*] %wvlist(rf,alive,begwv=4); /* r dad whether alive */
   array smalive_[*] %wvlist(sm,alive,begwv=4); /* s mom whether alive */
   array sfalive_[*] %wvlist(sf,alive,begwv=4); /* s dad whether alive */

   array rmlivage_[*] %wvlist(rm,livage,begwv=4); /* r mom age if alive */
   array rflivage_[*] %wvlist(rf,livage,begwv=4); /* r dad age if alive */
   array smlivage_[*] %wvlist(sm,livage,begwv=4); /* s mom age if alive */
   array sflivage_[*] %wvlist(sf,livage,begwv=4); /* s dad age if alive */

   array rmliv10mi_[*] %wvlist(rm,liv10mi,begwv=4); /* r mom whether live within 10 miles or cores */
   array rfliv10mi_[*] %wvlist(rf,liv10mi,begwv=4); /* r dad whether live within 10 miles or cores */
   array smliv10mi_[*] %wvlist(sm,liv10mi,begwv=4); /* s mom whether live within 10 miles or cores */
   array sfliv10mi_[*] %wvlist(sf,liv10mi,begwv=4); /* s dad whether live within 10 miles or cores */

   array rmmarried_[*] %wvlist(rm,married,begwv=4); /* r mom whether married=1, married to each other=2 */
   array rfmarried_[*] %wvlist(rf,married,begwv=4); /* r dad whether married=1, married to each other=2 */
   array smmarried_[*] %wvlist(sm,married,begwv=4); /* s mom whether married=1, married to each other=2 */
   array sfmarried_[*] %wvlist(sf,married,begwv=4); /* s dad whether married=1, married to each other=2 */

   array hparliv_[*] %wvlist(h,parliv,begwv=4); /* count parents alive */
   array paralive_[*] %wvlist(r,paralive,begwv=4); /* count parents alive */
   array parnotmar_[*] %wvlist(r,parnotmar,begwv=4); /* count parents not married */
   array par10mi_[*] %wvlist(r,par10mi,begwv=4); /* count parents within 10 mi */

   do i=1 to dim(inw_);
      if inw_[i]=1 then do;
         paralive_[i]=0;
         parnotmar_[i]=0;
         par10mi_[i]=0;
         hparliv_[i]=sum(rmliv_[i],rfliv_[i],smliv_[i],sfliv_[i]);
         
         /* in rand fam file, personal care hours is set to zero if no parent was helped,
            but for errand hours, these cases are missing hours if no parent was helped.
            Make personal care hours missing if none given */
         if rppcare_[i]=0 and rprpcareh_[i]=0 then rprpcareh_[i]=.N;
         if sppcare_[i]=0 and sprpcareh_[i]=0 then sprpcareh_[i]=.N;
         if rperrnd_[i]=0 and rprerrndh_[i]=0 then rprerrndh_[i]=.N;
         if sperrnd_[i]=0 and sprerrndh_[i]=0 then sprerrndh_[i]=.N;
         
         rparhelphours_[i]=sum(rprpcareh_[i],rprerrndh_[i],
                               sprpcareh_[i],sprerrndh_[i]);
         
         /* there are only so many hours in a day */
         if rparhelphours_[i]>&maxhours then rparhelphours_[i]=&maxhours;
         
         %setpar(rm);
         %setpar(rf);
         if hcpl_[i]=1 then do;
            %setpar(sm);
            %setpar(sf);
            
         end;
         else do;
           smliv10mi_[i]=.U;
           smmarried_[i]=.U;
           sfliv10mi_[i]=.U;
           sfmarried_[i]=.U;
         end;
         
         /* check living parents count */
         if max(hparliv_[i],0) ne paralive_[i] then _chkparct=1;
      end;
   end;

   %wvlabel(r,parhelphours,%str(Total hours helped parents-own and inlaws),begwv=4);
   %wvlabel(r,paralive,%str(Total # living parents-own and inlaws),begwv=4);
   %wvlabel(r,parnotmar,%str(Total # unmarried parents-own and inlaws),begwv=4);
   %wvlabel(r,par10mi,%str(Total # parents living w/in 10 mi-own and inlaws),begwv=4);

   %wvlabel(rm,alive,%str(R mom whether alive ),begwv=4);
   %wvlabel(rf,alive,%str(R dad whether alive ),begwv=4);
   %wvlabel(sm,alive,%str(R mom-inlaw whether alive ),begwv=4);
   %wvlabel(sf,alive,%str(R dad-inlaw whether alive ),begwv=4);
   
   %wvlabel(rm,livage,%str(R mom age if alive ),begwv=4);
   %wvlabel(rf,livage,%str(R dad age if alive ),begwv=4);
   %wvlabel(sm,livage,%str(R mom-inlaw age if alive ),begwv=4);
   %wvlabel(sf,livage,%str(R dad-inlaw age if alive ),begwv=4);

   %wvlabel(rm,married,%str(R mom whether married and to whom),begwv=4);
   %wvlabel(rf,married,%str(R dad whether married and to whom),begwv=4);
   %wvlabel(sm,married,%str(R mom-inlaw whether married and to whom),begwv=4);
   %wvlabel(sf,married,%str(R dad-inlaw whether married and to whom),begwv=4);

   %wvlabel(rm,liv10mi,%str(R mom whether live within 10 mi),begwv=4);
   %wvlabel(rf,liv10mi,%str(R dad whether live within 10 mi),begwv=4);
   %wvlabel(sm,liv10mi,%str(R mom-inlaw whether live within 10 mi),begwv=4);
   %wvlabel(sf,liv10mi,%str(R dad-inlaw whether live within 10 mi),begwv=4);

run;

title2 chkparhelp;
proc freq data=chkparhelp;
   table infrom _chkparct 
         %wvlist(h,parliv,begwv=4)
         %wvlist(r,paralive parnotmar par10mi,begwv=4)
         h4parliv*r4paralive h5parliv*r5paralive
         h6parliv*r6paralive h7parliv*r7paralive h8parliv*r8paralive
         /missing list;
run;
proc means data=chkparhelp;
   var %wvlist(r,parhelphours,begwv=4)
       %wvlist(r,prerdh,begwv=4)
       %wvlist(r,prpcrh,begwv=4)
       %wvlist(s,prerdh,begwv=4)
       %wvlist(s,prpcrh,begwv=4)
    ;
run;
title2 parhelp;
proc freq data=out.parhelp;
   table %wvlist(r,paralive parnotmar par10mi,begwv=4)
         %wvlist(rm,married liv10mi,begwv=4)
         %wvlist(rf,married liv10mi,begwv=4)
         %wvlist(sm,married liv10mi,begwv=4)
         %wvlist(sf,married liv10mi,begwv=4)
         /missing list;
format %wvlist(rm,married,begwv=4)
       %wvlist(rf,married,begwv=4)
       %wvlist(sm,married,begwv=4)
       %wvlist(sf,married,begwv=4) parmar.
       %wvlist(rm,liv10mi,begwv=4)
       %wvlist(rf,liv10mi,begwv=4)
       %wvlist(sm,liv10mi,begwv=4)
       %wvlist(sf,liv10mi,begwv=4) paryn.;
run;
proc means data=out.parhelp;
run;
proc contents data=out.parhelp;
run;
