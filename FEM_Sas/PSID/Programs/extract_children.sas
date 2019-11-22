%include "setup.inc";
%include "&maclib.psidget.mac";  /* macro to get early release data */ 
%include "&maclib.renyrv.mac";  /* macro to rename variables */

%let yr=%substr(&maxyr.,3,2);

/* Variable lists */
%include "vars_indiv_file.sas"; /* Variable names on the individual file */
%include "vars_children.sas"; /* Variables from the family file */


/********************************************************************************
Goal:  Pull childbirth and adoption information from 1985 forward. Create 
			 fertility history based on Lillard code.
	
********************************************************************************/

/******** CHILDBIRTH AND ADOPTION HISTORY VARIABLES ****************************/

/* For now only deal with biological children.  */
data proj.ferthist;
   set psid.cah85_&yr.  (rename=(
   		/* NOTE: Variable names changed significantly between 2011 and 2013! */ 
      CAH2  = type     /*  Record Type                         */
      CAH3  = famnum68 /*  Parent--68 ID                       */
      CAH4  = pn68     /*  Parent--68 Person number            */
      CAH5  = psex     /*  Parent--sex                         */
      CAH6  = pmob     /*  Parent--month born                  */
      CAH7  = pmyr     /*  Parent--year born                   */
      CAH8  = marstat  /*  Marital status of mom at birth      */
      CAH9  = parity   /*  Birth Order                         */
      CAH10  = childid  /*  Child--68 ID                        */
      CAH11 = childpn  /*  Child--68 Person number             */
      CAH12 = kidsex   /*  Child--sex                          */
      CAH13 = kidmob   /*  Child--month born                   */
      CAH15 = kidyob   /*  Child--year born                    */
		     /*  Birth weight, in oz.                */
		     /*  Where child when report             */
		     /*  Month child split/died              */
		     /*  Year child split/died               */
				 /*  HISPANICITY                         */   
				 /*	 RACE OF CHILD, 1ST MENTION          */ 
				 /*	 RACE OF CHILD, 2ND MENTION          */ 
				 /*	 RACE OF CHILD, 3RD MENTION          */ 
				 /*	 PRIMARY ETHNIC GROUP OF CHILD       */ 
				 /*	 SECONDARY ETHNIC GROUP OF CHILD, 1ST MEN  */ 
				 /*	 SECONDARY ETHNIC GROUP OF CHILD, 2ND MEN  */ 
		  CAH104 = ncurrent   /*  How current # of children rpt - changed in 2015!      */
      CAH105 = fcurrent /*  How current child-specific inf  - changed in 2015!    */
      CAH106 = numchild /*  # Natural/Adopted children - changed in 2015!         */
		  CAH107 = reladopt   /*  Relation to adoptive parent - changed in 2015!        */
		  CAH108 = numadopt   /*  # Birth/Adopt records - changed in 2015!            */
				 /*	RELEASE NUMBER      								 */ 
      ));

   if (type=1); /* biological children only.  */
   label id = "ID = 1000*famnum68+pn68"; /*format id id.;*/
   id = 1000*famnum68+pn68;
run;
proc sort data=proj.ferthist; by id parity; run;

data proj.ferthist (keep = id numkid fertqual ncurrent fcurrent kidtyp1-kidtyp20 kidbd1-kidbd20);
   set proj.ferthist;
   by id;

   /* Create conception windows for natural children only;   */
   /* adoptive children get best-guess birth dates only.     */
   /* kidtype indicates the marital status at birth.         */
   length kidtyp1-kidtyp20 kidbd1-kidbd20 numkid fertqual 4;
   retain kidtyp1-kidtyp20 kidbd1-kidbd20 numkid fertqual;
   format kidbd1-kidbd20 date7.;
   label numkid = "number of children";
   array kidtyp(20) kidtyp1-kidtyp20;   /* kid type */
   array kidbd(20)  kidbd1-kidbd20;     /* best-guess birth date */

   if (first.id) then do;  /* Initialize this record */
      numkid=0;
      fertqual=0; label fertqual = "fertility history quality indicator";
      do i=1 to 20; kidtyp(i)=.; kidbd(i)=.; end;
   end;

   if (numchild=0) then do;
      /* This is a record to note that the respondent did not have children */
      numkid=0;
      output;
      return;
   end;

   /* If numchild (v20) is 98:                                           */
   /* this is to record that no childbirth history could be ascertained  */
   /* There may, however, be valid records.                              */
   /* documentation page 93: "If one or more birth dates contain missing */
   /* data, then missing data are assigned to the order variable (V8)    */
   /* for all births."                                                   */
   if (numchild=98) then fertqual+1;

   numkid+1;
   if (1<=marstat<=5) then kidtyp(numkid)=marstat;  /* There are some 9's */
   if (1<=kidmob<=12 & 0<=kidyob<=fcurrent) then kidbd(numkid)=mdy(kidmob,15,kidyob);
   else if (0<=kidyob<=fcurrent) then kidbd(numkid)=mdy(7,1,kidyob);
   else kidbd(numkid)=.;

   if (last.id) then output;
run;

proc print data=proj.ferthist(obs=40);
   var id numkid fertqual
       kidtyp1 kidbd1
       kidtyp2 kidbd2
       kidtyp3 kidbd3
       kidtyp4 kidbd4
       kidtyp5 kidbd5
       kidtyp6 kidbd6
       kidtyp7 kidbd7
       kidtyp8 kidbd8;
run;
title "Frequencies based on retrospective history";
proc freq data=proj.ferthist; tables numkid fertqual fcurrent; run;
title " ";



							
/* Make a list of variable names from the XXXXXin list */
%yrmacv(&hdintvwdtin,begy=1969);
%yrmacv(&wfintvwdtin,begy=1969);
%yrmacv(&hdiwmonthin,begy=1969);
%yrmacv(&wfiwmonthin,begy=1969);
%yrmacv(&hdiwdayin,begy=1969);
%yrmacv(&wfiwdayin,begy=1969);
%yrmacv(&hdiwyearin,begy=1969);
%yrmacv(&wfiwyearin,begy=1969);

%yrmacv(&hdkidsinfuin,begy=1969);
%yrmacv(&wfkidsinfuin,begy=1969);

%yrmacv(&hdbrosin,begy=1969);
%yrmacv(&wfbrosin,begy=1969);
%yrmacv(&hdsistersin,begy=1969);
%yrmacv(&wfsistersin,begy=1969);
%yrmacv(&hdnumbrosin,begy=1969);
%yrmacv(&wfnumbrosin,begy=1969);
%yrmacv(&hdnumsistersin,begy=1969);
%yrmacv(&wfnumsistersin,begy=1969);

/* make macro variables to list raw variables across all years */

/*** individual file ***/
%let famnum=%selectv(%quote(&famnumin),begy=1968,endy=1968);
%let famnum=&famnum %selectv(%quote(&famnumin),begy=1969);
%let seq=%selectv(%quote(&seqin),begy=1968,endy=1968);
%let seq=&seq %selectv(%quote(&seqin),begy=1969);
%let famfid=%selectv(%quote(&famfidin),begy=1969);
%let relhd=%selectv(%quote(&relhdin),begy=1969);
%let movein=%selectv(%quote(&moveinin),begy=1969);
%let moin=%selectv(%quote(&moinin),begy=1969);
%let yrin=%selectv(%quote(&yrinin),begy=1969);

/*** family file variables ***/
%let hdintvwdt=%selectv(%quote(&hdintvwdtin),begy=1996,endy=1996);
%let wfintvwdt=%selectv(%quote(&wfintvwdtin),begy=1996,endy=1996);
%let hdiwmonth=%selectv(%quote(&hdiwmonthin),begy=1997);
%let wfiwmonth=%selectv(%quote(&wfiwmonthin),begy=1997);
%let hdiwday=%selectv(%quote(&hdiwdayin),begy=1997);
%let wfiwday=%selectv(%quote(&wfiwdayin),begy=1997);
%let hdiwyear=%selectv(%quote(&hdiwyearin),begy=1997);
%let wfiwyear=%selectv(%quote(&wfiwyearin),begy=1997);

%let hdkidsinfu=%selectv(%quote(&hdkidsinfuin),begy=1997);
%let wfkidsinfu=%selectv(%quote(&wfkidsinfuin),begy=1997);

%let hdbros=%selectv(%quote(&hdbrosin),begy=1997);
%let wfbros=%selectv(%quote(&wfbrosin),begy=1997);
%let hdsisters=%selectv(%quote(&hdsistersin),begy=1997);
%let wfsisters=%selectv(%quote(&wfsistersin),begy=1997);
%let hdnumbros=%selectv(%quote(&hdnumbrosin),begy=1997);
%let wfnumbros=%selectv(%quote(&wfnumbrosin),begy=1997);
%let hdnumsisters=%selectv(%quote(&hdnumsistersin),begy=1997);
%let wfnumsisters=%selectv(%quote(&wfnumsistersin),begy=1997);


/* the following uses the individual file to select the sample
   to match to when processing family files. 
   This is the place to pull needed variables from 
   the individual file, but further processing should
   be done in the data step that merges in the family file
   data, except for famnum, seq, and relhd. */

data ind;
   set psid.ind&maxyr.er  ( KEEP = &famnum &seq &relhd &movein &moin &yrin ER32000 ER32050
			     RENAME = ( ER32000=sex ER32050=deathyr ) );
   
   array famnumin_[*] &famnum;
   array famnum_[*]   famnum68 %listyrv(famnum,begy=&minyr);
   array seqin_[*]    &seq;
   array seq_[*]      pn68 %listyrv(seq,begy=&minyr);
   array relhdin_[*]  _dum &relhd;
   array relhd_[*]    _dum %listyrv(relhd,begy=&minyr);
   array moveinin_[*] _dum &movein;
   array movein_[*]   _dum %listyrv(movein,begy=&minyr);
	 array moinin_[*]   _dum &moin;
   array moin_[*]     _dum %listyrv(moin,begy=&minyr);
   array yrinin_[*]   _dum &yrin;
   array yrin_[*]     _dum %listyrv(yrin,begy=&minyr);
   
   do i=1 to dim(famnum_);
      famnum_[i]=famnumin_[i];
      seq_[i]=seqin_[i];
      relhd_[i]=relhdin_[i];
      movein_[i]=moveinin_[i];
      moin_[i]=moinin_[i];
      yrin_[i]=yrinin_[i];
      
   end;
   
   id=famnum68*1000 + pn68;
   drop _dum &famnum &seq &relhd &movein &moin &yrin;
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
      Assumes vars[yy] macro vars have been set up (see yrmacv macro)
   */
   
   %famget(psid,ind1,begy=1969,famid=&famfid);



/* merge all the parts together. ***/

data proj.extract_children probs;
   merge %listyrv(fam,begy=1969)  /* this lists all the requested fam files */
   			ind1 (in=_ini drop=dup)
   			proj.ferthist;
   by id;

   inind=_ini;  /* flags cases found on individual file - should be all */
   if id=. then output probs;
   dupid=(first.id=0 or last.id=0);
   if dupid=1 then output probs;  /* dups */
   
   /* raw variables */
   array hdiwmonth_[*] _1969 - _1996 &hdiwmonth;
   array wfiwmonth_[*] _1969 - _1996 &wfiwmonth;
   array hdiwday_[*] _1969 - _1996 &hdiwday;
   array wfiwday_[*] _1969 - _1996 &wfiwday;
   array hdiwyear_[*] _1969 - _1996 &hdiwyear;
   array wfiwyear_[*] _1969 - _1996 &wfiwyear;
   
   array hdkidsinfu_[*] _1969 - _1996 &hdkidsinfu;
   array wfkidsinfu_[*] _1969 - _1996 &wfkidsinfu;
   
   array hdbros_[*] _1969 - _1996 &hdbros;
   array wfbros_[*] _1969 - _1996 &wfbros;
   array hdsisters_[*] _1969 - _1996 &hdsisters;
   array wfsisters_[*] _1969 - _1996 &wfsisters;
   array hdnumbros_[*] _1969 - _1996 &hdnumbros;
   array wfnumbros_[*] _1969 - _1996 &wfnumbros;
   array hdnumsisters_[*] _1969 - _1996 &hdnumsisters;
   array wfnumsisters_[*] _1969 - _1996 &wfnumsisters;
      
   array relhd_[*] %listyrv(relhd,begy=&minyr);
   array seq_[*] %listyrv(seq,begy=&minyr);
   array cohab_[*] _1969 - _1996 %listyrv(cohab,begy=1997);
   array inyr_[*] _1969 - _1996 %listyrv(inyr,begy=1997);
   array diedyr_[*] _1969 - _1996 %listyrv(diedyr,begy=1997);
   array died_[*] _1969 - _1996 %listyrv(died,begy=1997);   
   array head_[*] _1969 - _1996 %listyrv(head,begy=1997);
   array wife_[*] _1969 - _1996 %listyrv(wife,begy=1997);
   array hdwf_[*] _1969 - _1996 %listyrv(hdwf,begy=1997);

   array iwmonth_[*] _1969 - _1996 %listyrv(iwmonth,begy=1997);
   array iwday_[*] _1969 - _1996 %listyrv(iwday,begy=1997);
   array iwyear_[*] _1969 - _1996 %listyrv(iwyear,begy=1997);
   
   array kidsinfu_[*] _1969 - _1996 %listyrv(kidsinfu,begy=1997);
   
   array bros_[*] _1969 - _1996 %listyrv(bros,begy=1997);
   array sisters_[*] _1969 - _1996 %listyrv(sisters,begy=1997);
   array numbros_[*] _1969 - _1996 %listyrv(numbros,begy=1997);
   array numsisters_[*] _1969 - _1996 %listyrv(numsisters,begy=1997);
      
   _died=0; /* this will keep the deceased dead */

   /* change yr range to process whatever years you want */
   length year yr 3;
   
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

        if relhd_[i] in (1,10) then do;  /* HEADS */
        	head_[i] = 1;
        	hdwf_[i] = 1; 
	      	hdwfever = 1;
	      
        	iwmonth_[i] = hdiwmonth_[i];
		      iwday_[i] = hdiwday_[i];
					iwyear_[i] = hdiwyear_[i];
					
					kidsinfu_[i] = hdkidsinfu_[i];
					
					bros_[i] = hdbros_[i];
					sisters_[i] = hdsisters_[i];
					numbros_[i] = hdnumbros_[i];
					numsisters_[i] = hdnumsisters_[i];
        	        	
      	end;

      	else if relhd_[i] in (2,20,22) then do;  /* WIFE */
        	wife_[i] = 1;
        	if relhd_[i] = 22 then cohab_[i] = 1;
			  	hdwf_[i] = 1;
	    		hdwfever = 1;
				
        	iwmonth_[i] = wfiwmonth_[i];
		      iwday_[i] = wfiwday_[i];
					iwyear_[i] = wfiwyear_[i];
					
					kidsinfu_[i] = wfkidsinfu_[i];
					
					bros_[i] = wfbros_[i];
					sisters_[i] = wfsisters_[i];
					numbros_[i] = wfnumbros_[i];
					numsisters_[i] = wfnumsisters_[i];
					        	        
      	end;                   
			end;
       
      else inyr_[i]=0;
      
   end;  /* do i=1 to dim(seq_) */
             
   any_yr=max(of inyr_[*]);           

   /* Only keep individuals who are ever heads or wives */
   if hdwfever = 1;
  
   if first.id then output proj.extract_children;
   
    drop yr year i _died _1969 - _1996 ;

run;

