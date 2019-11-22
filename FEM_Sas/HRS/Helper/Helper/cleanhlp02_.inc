
%macro labhlp(pre);
   label &pre&w.days="%upcase(&pre)&W.DAYS: Days helped last month"
         &pre&w.hours="%upcase(&pre)&w.HOURS: Hours/day helped"
         &pre&w.tothrs="%upcase(&pre)&w.tothrs: Total hours helped last month"
         &pre&w.relhp="%upcase(&pre)&w.RELHP: Relationship reported on HP file"
         &pre&w.gkidp="%upcase(&pre)&w.GKIDP: Gkid Parent OPN (Kid OPN)"
         &pre&w.gkpar="%upcase(&pre)&w.GKPAR: Gkid Parent OPN flag"
         &pre&w.sex="%upcase(&pre)&w.SEX: Sex on helper file"
         &pre&w.paid="%upcase(&pre)&w.PAID: Whether paid"
         &pre&w.amt="%upcase(&pre)&w.AMT: Amount paid"
         &pre&w.amtper="%upcase(&pre)&w.AMTPER: Amount paid-period"
         &pre&w.amtmo="%upcase(&pre)&w.AMTMO: Amount paid last month"
         &pre&w.amtmof="%upcase(&pre)&w.AMTMOF: Amount pd last month flag"
         &pre&w.ins="%upcase(&pre)&w.INS: Whether insurance paid"
         &pre&w.payhlp="%upcase(&pre)&w.PAYHLP: Anyone help pay"
         &pre&w.helpr="%upcase(&pre)&w.HELPR: =1 if helper in last month"
         ;
%mend;

/*********************************
  clean up helper data.
*********************************/
data help.helper&yr;
   set h&yr..h&yr.&sect._hp;
   
   length &V.hhid $ 7 ;
   hhidpn=hhid*1000 + pn;
   &V.hhidn=hhid*10 + &V.subhh;
   &V.hhid=put(&V.hhidn,z7.0);
   
   label hhidpn='HHIDPN: individual ID = HHID + PN /num' 
         &V.hhid='FHHID: wave-specific HHold ID = HHID+FSUBHH/char' 
         &V.hhidn='FHHIDN: wave-specific HHold ID = HHID+FSUBHH/num' ;
   
   /* array of helper vars */
   array hlpv_[*] hpk&w.days hpk&w.hours hpk&w.tothrs hpk&w.sex
                  hpk&w.paid hpk&w.ins hpk&w.amt hpk&w.amtmo
                  hpk&w.amtmof hpk&w.payhlp;

   /* helper relationship to R */
   length hpk&w.relhp 3;
   if 2<=&V.G069<=33 or &V.G069 in (90,91) then hpk&w.relhp=put(&V.G069,reltrn.);
   else if &V.G069=98 then hpk&w.relhp=.D;
   else if &V.G069=99 then hpk&w.relhp=.R;
   else hpk&w.relhp=.M;

   /* gkid who helps:
      gkidp = gkid parent OPN
      gkpar = flags whether / type of gkid parent ID info
              1 if grandkid and have parent OPN
              2 if grandkid's parent is deceased kid
              8 if valid OPN but not a grandkid helper
              9 if grandkid but no valid parent OPN
   */
   hpk&w.gkidp=&V.G075;
   if hpk&w.relhp=3 and 0<hpk&w.gkidp<992 then hpk&w.gkpar=1;
   else if hpk&w.relhp=3 and hpk&w.gkidp="992" then hpk&w.gkpar=2; /* deceased child */
   else if 0<hpk&w.gkidp<992 and hpk&w.relhp ne 3 then hpk&w.gkpar=8;
   else if hpk&w.relhp=3 then hpk&w.gkpar=9;
   
   /* days of help given last month
      ADD FLAG FOR SOURCE */
   if 0<=&V.G070<=31 then hpk&w.days=&V.G070;
   else if 1<=&V.G071<=7 then hpk&w.days=&V.G071*4;
   else if &V.G072=1 then hpk&w.days=30;
   else if &V.G070=98 then hpk&w.days=.D;
   else if &V.G070=99 then hpk&w.days=.R;
   else if &V.G071=8 then hpk&w.days=.D;
   else if &V.G071=9 then hpk&w.days=.R;
   else if &V.G072=8 then hpk&w.days=.D;
   else if &V.G072=9 then hpk&w.days=.R;
   else if &V.G069=22 or opn in ("096","998"," ") then hpk&w.days=.S;
   else hpk&w.days=.M;
   
   hpk&w.helpr=(hpk&w.days ne 0);
     
   if hpk&w.helpr=1 then do;
      if 1<=&V.G073<=24 then hpk&w.hours=&V.G073;
      else if &V.G073=98 then hpk&w.hours=.D;
      else if &V.G073=99 then hpk&w.hours=.R;
      else if &V.G069=22 or opn in ("096","998"," ") then hpk&w.hours=.S;
      else hpk&w.hours=.M;
      
      /* calculate total hours last month, days*hours */
      hpk&w.tothrs=hpk&w.days*hpk&w.hours;
      if hpk&w.tothrs=. and hpk&w.days<=.Z then hpk&w.tothrs=hpk&w.days;
      else if hpk&w.tothrs=. then hpk&w.tothrs=hpk&w.hours;
      
      if &V.G074 in (1,2) then hpk&w.sex=&V.G074;
      else if &V.G074=3 then hpk&w.sex=.E; /* employee of institution */
      else if hpk&w.relhp=20 then hpk&w.sex=.S;  /* if spouse Q skipped */
      else if &V.G074=8 then hpk&w.sex=.D;  
      else if &V.G074=9 then hpk&w.sex=.R;  
      else hpk&w.sex=.M;
      
      if &V.G076 in (1,5) then hpk&w.paid=(&V.G076=1);
      else if &V.G076=8 then hpk&w.paid=.D;
      else if &V.G076=9 then hpk&w.paid=.R;
      else if &V.G069=22 or opn in ("096","998"," ") then hpk&w.paid=.S;
      else if hpk&w.relhp=20 then hpk&w.paid=.S;  /* if spouse Q skipped */
      else hpk&w.paid=.M;
      
      if hpk&w.paid=1 then do;
         /* did ins help pay for help */
         if &V.G077 in (1,5) then hpk&w.ins=(&V.G077=1);
         else if &V.G077=8 then hpk&w.ins=.D;
         else if &V.G077=9 then hpk&w.ins=.R;
         else if &V.G069 in (2,22) or opn in ("096","998"," ") then hpk&w.ins=.S;
         else hpk&w.ins=.M;
      
         if 0<=&V.G078<99997 then hpk&w.amt=&V.G078;
         else if &V.G078=99998 then hpk&w.amt=.D;
         else if &V.G078=99999 then hpk&w.amt=.R;
         else hpk&w.amt=.M;
         
         if &V.G079=8 then hpk&w.amtper=.D;
         else if &V.G079=9 then hpk&w.amtper=.R;
         else if 1<=&V.G079<=5 then hpk&w.amtper=&V.G079;
         
         select (&V.G079);
            when(1) /* Month */ hpk&w.amtmo=hpk&w.amt;
            when(2) /* week */  hpk&w.amtmo=hpk&w.amt*4;
            when(3) /* Day */  hpk&w.amtmo=hpk&w.amt*hpk&w.days;
            when(5) /* Year */  hpk&w.amtmo=hpk&w.amt/12;
            when(8) /* DK */  hpk&w.amtmo=.D;
            when(9) /* DK */  hpk&w.amtmo=.R;
            otherwise hpk&w.amtmo=.M;
         end;
         
         if hpk&w.amtmo<=.Z and hpk&w.amt=0 then hpk&w.amtmo=0;
         else if hpk&w.amtmo=. and hpk&w.amt<=.Z then hpk&w.amtmo=hpk&w.amt;
         else if hpk&w.amtmo=. and &V.G079=3 and hpk&w.days<=.Z then hpk&w.amtmo=hpk&w.days;
         else if hpk&w.amtmo=. then hpk&w.amtmo=.M;
         /* amtmoF:
            Flag for amount pd per mo: 0=paid-amount is zero, 1=continuous, 
            2=about 100, 3=lt 100, 4=gt 100, 5=missing amt, 6=not paid, 
            7=paid not asked, 8=missing if paid
         */
         hpk&w.amtmoF=(hpk&w.amtmo>0)+ 5*(hpk&w.amtmo<=.Z);
         
         if hpk&w.amtmo<=.Z then do;
            if &V.G080=3 then hpk&w.amtmo=100;
            else if &V.G080=1 then hpk&w.amtmo=.B;  /* less than 100 */
            else if &V.G080=5 then hpk&w.amtmo=.G;  /* higher than 100 */
            if &V.G080 in (1,3,5) 
               then hpk&w.amtmoF=2*(&V.G080=3) + 3*(&V.G080=1) + 4*(&V.G080=5);
         end;
         
         /* payhlp: any one help pay for R's help
            0=No, 1=yes-not a kid, 2=yes-kid, no OPN, 3=yes-kid, OPN */
         if &V.G081 in (1,5) then hpk&w.payhlp=(&V.G081=1);
         else if &V.G081=8 then hpk&w.payhlp=.D;
         else if &V.G081=9 then hpk&w.payhlp=.R;
         else hpk&w.payhlp=.M;
         if &V.G082=1 and &V.G083 not in ("998" "999" " ") then hpk&w.payhlp=3;
         else if &V.G082=1 then hpk&w.payhlp=2;
      end; /* paid=1 */
      else do;
         hpk&w.ins=.S;
         hpk&w.amt=.S;
         hpk&w.amtmo=.S;
         hpk&w.amtmoF=6*(hpk&w.paid=0) + 7*(hpk&w.paid=.S) +
                      8*(hpk&w.paid not in (.S,0)); /* 8=missing, not skipped */
         hpk&w.payhlp=.S;
      end;

   end;    /* is a helper */
   else do; /* not a helper */
      /* set helper vars to .H */
      do i=1 to dim(hlpv_);
         hlpv_[i]=.H;
      end;
   end;  
   
   %labhlp(hpk);
run;
   
%macro tabday(pre,dayv);
   %let daymo=&v.G&dayv;
   %let daywk=&v.G0%eval(&dayv+1);
   %let evday=&v.G0%eval(&dayv+2);
   
   &pre&w.days*&daymo*&daywk*&evday
%mend;

proc freq data=help.helper&yr;
   table hpk&w.helpr hpk&w.relhp
         hpk&w.gkpar hpk&w.relhp*hpk&w.gkpar
         hpk&w.sex
         hpk&w.paid hpk&w.amtper hpk&w.amtmoF hpk&w.ins hpk&w.payhlp
         hpk&w.days hpk&w.hours
         %tabday(hpk,070) 
         hpk&w.sex*&V.G074
         hpk&w.relhp*&V.G069
         hpk&w.paid*&V.G076
    /missing list;
         
format hpk&w.relhp relk.;
format hpk&w.gkpar gkpar. hpk&w.amtmoF amtmoF.;
run;
proc means data=help.helper&yr;
   class hpk&w.amtmof;
   types () hpk&w.amtmof;
   var hpk&w.paid hpk&w.amtmo;
   run;
proc sort data=help.helper&yr;
   by hhidpn;
run;
proc contents data=help.helper&yr;
run;
proc means data=help.helper&yr;
   run;

endsas;

