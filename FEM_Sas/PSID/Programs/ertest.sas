options ls=120 ps=58 nocenter compress=yes replace mprint;

libname raw "/sch-stor1-a/data-library/public-data/PSID/Sas/Raw";
libname out ".";

%let maxyr=2009;

%include 'psidget.mac';  /* macro to get early release data */
%include "listyrv.mac";
%include "yrlab.mac";

/************************************************************************************* 
   these are lists of variables from PSID web site
   To find them go to Data Center, Cross year search, then find the 
   variable of interest at the left and click on the small "i" at the end
   of the variable text (following the checkbox)

   This opens a window that shows the codebook entry for the measure,
   and if it's available across years, the list of raw variable names
   corresponding to the measure for all years available.
   
   Copy this cross-year list of variables as in the example below:

%let hdshlthin=[84]V10877 [85]V11991 [86]V13417 [87]V14513 [88]V15993 [89]V17390 
               [90]V18721 [91]V20021 [92]V21321 [93]V23180 [94]ER3853 [95]ER6723 
               [96]ER8969 [97]ER11723 [99]ER15447 [01]ER19612 [03]ER23009 [05]ER26990 
               [07]ER38202 [09]ER44175;

   Note that SAS seems to truncate its program lines at about 230 characters,
   so you'll need to insert returns to break up the one long line if it's longer
   than that.  Otherwise it will truncate the line (and the macro variable)   
****************************************************************************************/
/******** INDIVIDUAL FILE VARIABLES ****************************************************/
/******** Usually needed are famnum, seq, relhd ****************************************/
%let seqin=[68]ER30002 [69]ER30021 [70]ER30044 [71]ER30068 [72]ER30092 [73]ER30118 
           [74]ER30139 [75]ER30161 [76]ER30189 [77]ER30218 [78]ER30247 [79]ER30284 
           [80]ER30314 [81]ER30344 [82]ER30374 [83]ER30400 [84]ER30430 [85]ER30464 
           [86]ER30499 [87]ER30536 [88]ER30571 [89]ER30607 [90]ER30643 [91]ER30690 
           [92]ER30734 [93]ER30807 [94]ER33102 [95]ER33202 [96]ER33302 [97]ER33402 
           [99]ER33502 [01]ER33602 [03]ER33702 [05]ER33802 [07]ER33902 [09]ER34002;

%let famnumin=[68]ER30001 [69]ER30020 [70]ER30043 [71]ER30067 [72]ER30091 
              [73]ER30117 [74]ER30138 [75]ER30160 [76]ER30188 [77]ER30217 [78]ER30246 
              [79]ER30283 [80]ER30313 [81]ER30343 [82]ER30373 [83]ER30399 [84]ER30429 
              [85]ER30463 [86]ER30498 [87]ER30535 [88]ER30570 [89]ER30606 [90]ER30642 
              [91]ER30689 [92]ER30733 [93]ER30806 [94]ER33101 [95]ER33201 [96]ER33301 
              [97]ER33401 [99]ER33501 [01]ER33601 [03]ER33701 [05]ER33801 [07]ER33901 
              [09]ER34001;
/* NOTE: these were not easily listed cross-year wise. 
   If pulling 1968 family data please verify that V2 is the correct famnum to use */
%let famfidin=[68]V2     [69]V442   [70]V1102  [71]V1802  [72]V2402  [73]V3002  
              [74]V3402  [75]V3802  [76]V4302  [77]V5202  [78]V5702  [79]V6302
              [80]V6902  [81]V7502  [82]V8202  [83]V8802  [84]V10002 [85]V11102 
              [86]V12502 [87]V13702 [88]V14802 [89]V16302 [90]V17702 [91]V19002 
              [92]V20302 [93]V21602 [94]ER2002 [95]ER5002 [96]ER7002 [97]ER10002
              [99]ER13002 [01]ER17002 [03]ER21002 [05]ER25002 [07]ER36002 [09]ER42002;

%let relhdin=[68]ER30003 [69]ER30022 [70]ER30045 [71]ER30069 [72]ER30093 
             [73]ER30119 [74]ER30140 [75]ER30162 [76]ER30190 [77]ER30219 [78]ER30248 
             [79]ER30285 [80]ER30315 [81]ER30345 [82]ER30375 [83]ER30401 [84]ER30431 
             [85]ER30465 [86]ER30500 [87]ER30537 [88]ER30572 [89]ER30608 [90]ER30644 
             [91]ER30691 [92]ER30735 [93]ER30808 [94]ER33103 [95]ER33203 [96]ER33303 
             [97]ER33403 [99]ER33503 [01]ER33603 [03]ER33703 [05]ER33803 [07]ER33903 
             [09]ER34003;

/******** FAMILY FILE VARIABLES *******************************************************/
%let hdshlthin=[84]V10877 [85]V11991 [86]V13417 [87]V14513 [88]V15993 [89]V17390 [90]V18721 [91]V20021 [92]V21321 [93]V23180 [94]ER3853 [95]ER6723 [96]ER8969 [97]ER11723 [99]ER15447 [01]ER19612 [03]ER23009 [05]ER26990 [07]ER38202 [09]ER44175;
%let wfshlthin=[84]V10884 [85]V12344 [86]V13452 [87]V14524 [88]V15999 [89]V17396 [90]V18727 [91]V20027 [92]V21328 [93]V23187 [94]ER3858 [95]ER6728 [96]ER8974 [97]ER11727 [99]ER15555 [01]ER19720 [03]ER23136 [05]ER27113 [07]ER39299 [09]ER45272;

/* the following makes a macro variable vars[yy] from the 
   cross-year variable lists copied from the PSID web site.
   
   vars[yy] will be a list of variables for
   year yy separated by spaces, for the selected years
   Arguments are:
      varlist = list of variables by measure across years
      begy = year for first in list (default=1968)
      endy = year for last in list  (default=maxyr)
   This will be used to keep the appropriate variables
   from the yearly fam files 
*/

%yrvlist(&wfshlthin,begy=1999);
%yrvlist(&hdshlthin,begy=1999);

/* this will list the vars[yy] macro variables */
%macro chkvars(begy,endy);
   %do year=&begy %to &endy;
       %let yr=%substr(&year,3);
       %if (&year ge 1968 and &year le 1997) or
           (&year>1997 and %index(13579,%substr(&year,4,1))>0) 
           %then %put vars&yr = &&vars&yr;
   %end;
%mend chkvars;

%chkvars(1999,2009);

/* make macro variables to list raw variables across all years */

/*** individual file ***/
%let famnum=%selectv(%quote(&famnumin),begy=1968,endy=1968);
%let famnum=&famnum %selectv(%quote(&famnumin),begy=1999);
%let seq=%selectv(%quote(&seqin),begy=1968,endy=1968);
%let seq=&seq %selectv(%quote(&seqin),begy=1999);
%let famfid=%selectv(%quote(&famfidin),begy=1999);
%let relhd=%selectv(&relhdin,begy=1999);

/*** family file variables ***/
%let hdshlth=%selectv(%quote(&hdshlthin),begy=1999);
%let wfshlth=%selectv(%quote(&wfshlthin),begy=1999);

/* the following uses the individual file to select the sample
   to match to when processing family files. 
   This is the place to pull needed variables from 
   the individual file, but further processing should
   be done in the data step that merges in the family file
   data, except for famnum, seq, and relhd. */

data ind;
   set raw.ind&maxyr.er (keep=&famnum &seq &relhd);
   
   array famnumin_[*] &famnum;
   array famnum_[*]   famnum68 %listyrv(famnum,begy=1999);
   array seqin_[*]    &seq;
   array seq_[*]      pn68 %listyrv(seq,begy=1999);
   array relhdin_[*]  _dum &relhd;
   array relhd_[*]    _dum %listyrv(relhd,begy=1999);
   
   do i=1 to dim(famnum_);
      famnum_[i]=famnumin_[i];
      seq_[i]=seqin_[i];
      relhd_[i]=relhdin_[i];
   end;
   
   id=famnum68*1000 + pn68;
   drop _dum &famnum &seq &relhd;
run;
proc means ;
  title2 check for missing IDs - does N match nobs on file;
  var id;
  run;
title2;
proc sort data=ind;  by id;
data ind1 dups;
   set ind;
   by id;
   dup=first.id=0 or last.id=0;
   if id=. then output dups;
   if dup=1 then output dups;
   else if first.id then output ind1;
run;
proc freq data=dups;
   table dup /missing list;
proc print data=dups (obs=10);
   title2 duplicates or missing ids - first 10 obs;
run;

proc sql;

   /* gets variables for requested years and merge to ids in ind1
      by looping through all the family files
      Assumes vars[yy] macro vars have been set up (see yrvlist macro)
   */
   
   %famget(raw,ind1,begy=1999,famid=&famfid);

proc print data=fam99 (obs=10);
  title2 fam99;
  id id;
run;

proc print data=fam09 (obs=10);
  title2 fam09;
  id id;
run;

proc print data=fam99 (where=(id=4003) obs=10);
  title2 fam99 - id 4003;
  id id;
run;

proc print data=fam09 (where=(id=4003) obs=10);
  title2 fam09 - id 4003;
  id id;
run;
proc print data=ind1 (where=(id=4003));
   title2 ind1 - id 4003;
   run;

/* merge all the parts together. ***/

data out.tmp probs; /* change out.tmp to desired output file name */
   merge %listyrv(fam,begy=1999)  /* this lists all the requested fam files */
         ind1 (in=_ini drop=dup)
	 ;  
   by id;

   inind=_ini;  /* flags cases found on individual file - should be all */
   if id=. then output probs;
   dupid=(first.id=0 or last.id=0);
   if dupid=1 then output probs;  /* dups */

   /* raw variables */
   array hdshlth_[*] &hdshlth;
   array wfshlth_[*] &wfshlth;
      
   /* relhd=1 or 10 for head, 2 or 20 for wife.  2-digit relhd codes begin
      in 1984, i think */

   array relhd_[*] %listyrv(relhd,begy=1999);
   array seq_[*] %listyrv(seq,begy=1999);
   array inyr_[*] %listyrv(inyr,begy=1999);

   /* other arrays...remember to hold a place for 98, so things
      line up */
   array diedyr_[*] %listyrv(diedyr,begy=1999);
   array died_[*] %listyrv(died,begy=1999);
   array shlth_[*] %listyrv(shlth,begy=1999);

   /* everyone has a seq68>0 so set a dummy to be zero if
      individual not there in 1968, based on relhd68.
      IF INCLUDING 1968 DATA, RUN THIS MACRO */
  %macro if68;
   if relhd68<=0 then _seq68=0;
   else _seq68=seq68;
  %mend;
  
   /* change yr range to process whatever years you want */
   length year yr 3;
   
   _died=0; /* this will keep the deceased dead */
   do i=1 to dim(seq_);
      
      /* get year from relhd varname */
      yr=substr(vname(relhd_[i]),7);
      if yr>=68 then year=1900+yr;
      else year=2000+yr;
      
      /* seq # of 81-89 indicates someone who died since last interview */
      diedyr_[i]=(81<=seq_[i]<=89);
      _died=max(_died,diedyr_[i]);
      died_[i]=_died;
      
      /* note: if seq[yy] is 50-59 then individual is in FU but living
	       away, e.g., away at school or in jail */

      if 0<seq_[i]<50 then do;  /* only do guys who are in FU */
         inyr_[i]=1;
        	 /* what ever processing you want to do by year */
         if relhd_[i] in (1,10) then do;  /* HEADS */
   	       if hdshlth_[i]=8 then shlth_[i]=.D;
   	       else if hdshlth_[i]=9 then shlth_[i]=.R;
   	       else if 1<=hdshlth_[i]<=5 then shlth_[i]=hdshlth_[i];
   	       else shlth_[i]=.M;  /* dont know why missing */
         end;

         else if relhd_[i] in (2,20,22) then do;  /* WIFE */
   	       if wfshlth_[i]=8 then shlth_[i]=.D;
   	       else if wfshlth_[i]=9 then shlth_[i]=.R;
   	       else if 1<=wfshlth_[i]<=5 then shlth_[i]=wfshlth_[i];
   	       else shlth_[i]=.M;  /* dont know why missing */
         end;

         else do;  /* set not head/wife to .H */
           shlth_[i]=.H;
         end;
      end; /* people in FU */
      
      else inyr_[i]=0;
      
   end;  /* do i=1 to dim(seq_) */
   
   any_yr=max(of inyr_[*]);
   
   if first.id then output out.tmp;
   
   label %yrlab(shlth,Self-report of health,begy=1999)
         %yrlab(famnum,Family Number,begy=1999)
         %yrlab(seq,Year-specific sequence num,begy=1999)
         %yrlab(inyr,Whether present in FU,begy=1999)
         %yrlab(relhd,Relation to head,begy=1999)
         %yrlab(diedyr,Died since last intervw,begy=1999)
         %yrlab(died,Died anytime bef interview,begy=1999)
         ;
    drop yr year i _died;
run;
proc print data=probs (obs=10);
title2 problems - missing ID or duplicate ID;
run;
proc means data=out.tmp;
   title2 Checking famnum ids;
   var famnum: &famfid ;
   run;
proc freq data=out.tmp;
   table dupid any_yr relhd99*shlth99 relhd09*shlth09
         inyr: shlth: died: seq:
      /missing list;
run;
proc contents data=out.tmp;
