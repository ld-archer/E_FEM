/* This is Lillard's program race.sas.

   PSID
   Program Name: race.sas
=========================================================================
   This program produces race.ssd01 with individual race.  If an individual
      is head or wife, race is taken from the most recent year he/she is
      head/wife and race/span is not missing.  If an individual is never
      head or wife, race/span is taken from head's or wife's race/span in
      the most recent year head/wife race/span is not missing.  Finally if
      race is still missing, and span=1 then race is set to 1.  spand
      provides detail on hispanic origin.

      race and span codes are:
	 race   1=white, 2=black, 3=other
	 span   0=not hispanic, 1=hispanic
	 spand  1 = Mexican
		2 = Mexican American
		3 = Chicano
		4 = Puerto Rican
		5 = Cuban
		6 = Combination; more than 1 mention
		7 = Other Spanish
		    In 90-92: Other Spanish; Hispanic; Latino
		8 = SPECIFIED HISPANICITY IN RACE CODE
		    Puerto Rican, Mexican (1968)
		    Puerto Rican, Mexican, Cuban (1969)
		    Spanish American, Puerto Rican, Mexican, Cuban (70-72)
		    Spanish-American (1973-84)
		    Mentions Latino origin or descent (added in 1990)
		9 = NA; DK
		0 = Inap; is not Spanish/Hispanic

      racefl and spanfl are variables that flag where the race/span values
      came from:
	 0=from head/wife in year R was head/wife
	 1=from head race/span in year R was not head/wife
	 2=from wife race/span in year R was not head/wife
	 3=race set to white (=1) from span=1
	 9=missing

      raceyr and spanyr are set to the year in which R's race and span
	 are taken
*/

options pagesize=58 linesize=132 nocenter replace compress=yes;

libname base '/homer/d/PSID/Base/Data';
libname clean '/homer/d/PSID/Clean/Data';


/* Create sample data set: all individuals */
data sample;
   set clean.ind1 (keep = id famnum68-famnum94 relhd68-relhd94
			     seq69-seq94);
   pn68=mod(id,1000);
run;
/* macro to attach head race and wife race to each family, and then to each
	 individual  */

%macro hwrace(begy,endy);
%do yr=&begy %to &endy;
   create table hdrace&yr as
      select famnum&yr,race as hdrace&yr,
		       span as hdspan&yr,
		       spand as hdspnd&yr
	 from clean.hwrace
   %if &yr =68 %then %do;
	 where relhd&yr in (1,10) and 0<pn68<20
   %end;
   %else %do;
	 where relhd&yr in (1,10) and 0<seq&yr<50
   %end;
	 order famnum&yr;

   create table wfrace&yr as
      select famnum&yr,race as wfrace&yr,
		       span as wfspan&yr,
		       spand as wfspnd&yr
	 from clean.hwrace
   %if &yr =68 %then %do;
	 where relhd&yr in (2,20,22) and 0<pn68<20
   %end;
   %else %do;
	 where relhd&yr in (2,20,22) and 0<seq&yr<50
   %end;
	 order famnum&yr;
%end;
%mend;

%macro irace(begy,endy);
%do yr=&begy %to &endy;
    create table irace&yr as
       select fam.*,i.id
	  from sample i,
	 (select *
	     from hdrace&yr hd left join wfrace&yr wf
	     on hd.famnum&yr=wf.famnum&yr) fam
	  where i.famnum&yr=fam.famnum&yr
	  order id;
%end;
%mend;

proc sql;
%hwrace(68,94);
proc sql;
%irace(68,94);
data clean.race
     dupid;
   merge irace68 irace69
	 irace70 irace71 irace72 irace73 irace74 irace75
	 irace76 irace77 irace78 irace79
	 irace80 irace81 irace82 irace83 irace84 irace85 irace86 irace87
	 irace88 irace89 irace90 irace91 irace92 irace93 irace94
	 clean.hwrace (keep=id race span spand racefl spanfl raceyr spanyr
			    in=inhw)
	 sample (in=insamp);
   by id;

   if first.id=0 or last.id=0 then do;
      put 'Duplicate ID' id=;
      output dupid;
   end;
   if first.id=0 then delete;

   if insamp;

   array seq{68:94} pn68 seq69-seq94;
   array hrace{68:94} hdrace68-hdrace94;
   array wrace{68:94} wfrace68-wfrace94;
   array hspan{68:94} hdspan68-hdspan94;
   array wspan{68:94} wfspan68-wfspan94;
   array hspand{68:94} hdspnd68-hdspnd94;
   array wspand{68:94} wfspnd68-wfspnd94;

   /* still missing race or span. Try using head's race/ethnicity,
	then wife's  */

   if racefl=. then racefl=9;
   if spanfl=. then spanfl=9;

   if race=. or span=. then do i=94 to 68 by -1 while (race=. or span=.);
      if seq{i}>0 then do;  /* R in household */
	 if race=. and hrace{i}>0 then do;
	    race=hrace{i};
	    raceyr=i;
	 end;
	 if span=. and hspan{i} ne . then do;
	    span=hspan{i};
	    spand=hspand{i};
	    spanyr=i;
	 end;

	  /* flags for how got information. =1 means from head */
	 if racefl=9 then racefl=1+8*(race=.);
	 if spanfl=9 then spanfl=1+8*(span=.);

	 if i=>85 then do;  /* if have wife data, check wife race */
	    if race=. and wrace{i}>0 then do;
	       race=wrace{i};
	       raceyr=i;
	    end;
	    if span=. and wspan{i} ne . then do;
	       span=wspan{i};
	       spand=wspand{i};
	       spanyr=i;
	    end;
	     /* flags for how got information. =2 means from head */
	    if racefl=9 then racefl=2+7*(race=.);
	    if spanfl=9 then spanfl=2+7*(span=.);
	 end;

      end; /* if seq{i}>0 */
   end;  /* do i=94 to 68 */

   /* if still missing race, and hispanic, then set race to white */

   /* flags for how got information.  =3 means assumed white if hispanic */
   /* if flag is still =9 then race/span is missing */

   if span=1 and race=. then do;
      race=1;
      raceyr=spanyr;
   end;
   if racefl=9 then racefl=3+6*(race=.);
   output clean.race;
run;

%macro tabit(pre1,pre2,begyr,endyr);
   %do i=&begyr %to &endyr;
       &pre1&i*&pre2&i
   %end;
%mend;

proc format;
  value sourc 0='as head/wife'
	      1='from head'
	      2='from wife'
	      3='hispanic=white'
	      9='DK';
  value race 1='1:white'
	     2='2:black'
	     3='3:other';
  value spand 0='0:Non-hispanic'
	      1='1:Mexican'
	      2='2:Mexican Amer'
	      3='3:Chicano'
	      4='4:Puerto Rican'
	      5='5:Cuban'
	      6='6:Combination'
	      7='7:Other Spanish'
	      8='8:from race code'
	      9='9:NA,DK';
run;
proc contents data=clean.race;
proc freq data=clean.race;
   table race span spand race*span spand*span racefl spanfl
	 raceyr spanyr
   /missing ;
format racefl spanfl sourc. race race. spand spand.;
run;
proc printto print="race.lst.chk" new;
proc freq data=clean.race;
   table race*span race*racefl span*spanfl race*span*racefl raceyr spanyr
	 hdrace68-hdrace94
	 hdspan68-hdspan94
	 hdspnd68-hdspnd94
	 wfrace68-wfrace94
	 wfspan68-wfspan94
	 wfspnd68-wfspnd94
       /missing list;
run;
proc print data=dupid;
