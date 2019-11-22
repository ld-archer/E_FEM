
/************************************
chkkdcare.sas

check variables related to grand kid care: living near by, living within 10 miles,
grandkid care (any and hours)

pstclair for transfers, 5/2012

************************************/
options ls=180 ps=84 compress=yes nocenter replace FORMDLIM=' ' mprint;
options ls=120 ps=58 nocenter replace nofmterr compress=yes mprint;

%include "../../../fem_env.sas";  /* file to set up libnames, fmt/mac locations */

libname rfam "&dataroot.HRS/Unrestricted/Sas/RANDFAM";
libname hrs "&hrslib";
libname out "&outlib";
proc format;
   value anyhrs
   1-9000="any";

%let maxg=9;
%macro chkliv10(yr,w,lvn=lvnear);
   proc freq data=rfam.count&yr.r;
      table r&w.liv10kn /missing list;
      run;
%if &lvn=lvnear %then %do;
   proc freq data=rfam.count&yr.kr;
      table k&w.liv10 k&w.lvnear k&w.lvnear*k&w.liv10
      /missing list;
      run;
%end;
%else %do;
   proc freq data=rfam.count&yr.kr;
      table k&w.liv10 k&w.lvnrgcd k&w.lvnrgis (k&w.lvnrgcd k&w.lvnrgis)*k&w.liv10
      /missing list;
      run;
%end;
%mend;

%chkliv10(98,4);
%chkliv10(00,5);
%chkliv10(02,6);
%chkliv10(04,7,lvn=lvnr);
%chkliv10(06,8,lvn=lvnr);
%chkliv10(08,9,lvn=lvnr);

%macro tabit (yr,w,anykc,kchrs,kcbkt);
data tmp;
  set rfam.count&yr.kr;
  by hhidpn;
  
  retain anykdcare nkdcare anyresgk anyresgk1 anyresgk2 anykid;
  if first.hhidpn then do;
     anykdcare=0;
     anyresgk1=0;
     anyresgk2=0;
     anyresgk=0;
     nkdcare=0;
     anygkc=0;
     anykid=0;
  end;
  anykid=max(anykid,(krrel in (1,2,6,7,16,21)));
  thiskdcare=(k&w.kdcarea=1 or ku&w.kdcarea=1 or (max(of g&w.kdcare1-g&w.kdcare&maxg))=1);
  anykdcare=max(anykdcare,thiskdcare);
  
  array gkres_[*] g&w.resd1-g&w.resd&maxg;
  array gkage_[*] g&w.agebg1-g&w.agebg&maxg;
  
  /* any resident kids where some gkid is getting care */
  if thiskdcare=1 and k&w.resd=1 then _anyresgk1=2;
  else if k&w.resd=1 and k&w.gkids>0 then _anyresgk1=1;
  anyresgk1=max(anyresgk1,_anyresgk1);
  
  do i=1 to g&w.ct;
     if gkres_[i]=1 and gkage_[i]<18 then _anyresgk2=2;
  end;

  if thiskdcare=0 and anyresgk2=1 then _anyresgk2=1;
  if anyresgk2=0 then anyresgk2=_anyresgk2;
  anyresgk2=max(anyresgk2,_anyresgk2);
  
  anyresgk=max(anyresgk,(anyresgk1>0),(anyresgk2>0));
  
  if last.hhidpn then output;
run;
proc freq data=tmp;
  table anykdcare nkdcare krrel anykid anykid*anykdcare anykid*anyresgk1*anyresgk2
        anyresgk1 anyresgk2 anyresgk
        r&w.resdkn anyresgk*r&w.resdkn 
        anyresgk*anyresgk1*anyresgk2
        anyresgk*anyresgk1*anyresgk2*anykdcare
     /missing list;
     run;
data tmp2;
   merge tmp rfam.count&yr.r;
   by hhidpn;
   
proc means data=tmp2;
   class anyresgk;
   var r&w.kdcarehr;
   run;
proc freq data=tmp2;
  table r&w.kdcarehr*r&w.kdcaremin*r&w.kdcaremax
        r&w.kdcarehr*(anykdcare anyresgk)
        r&w.kdcarehr*anyresgk1*anyresgk2
  /missing list;
  format r&w.kdcarehr anyhrs9.;
  run;
proc freq data=hrs.hrs&yr;
   table &anykc &kchrs &kcbkt
   /missing list;
   format &kchrs anyhrs9.;
   run;
proc freq data=rfam.count&yr.kr;
   table g&w.stat1*g&w.resd1
     /missing list;
     run;
%mend;

%tabit(98,4,f1832,fr1834,fr1835*fr1836 f1834*f1835*f1836);
%tabit(00,5,g2048,gr2050,gr2051*gr2052);
%tabit(02,6,he060,her063 he063 he068,her063*her065*her066 he063*he065*he066 he068*he070*he071);
%tabit(04,7,je060,jer063 je063 je068,jer063*jer065*jer066 je063*je065*je066 je068*je070*je071);
%tabit(06,8,ke060,ker063 ke063 ke068,ker063*ker065*ker066 ke063*ke065*ke066 ke068*ke070*ke071);
%tabit(08,9,le060,ler063 le063 le068,ler063*ler065*ler066 le063*le065*le066 le068*le070*le071);

