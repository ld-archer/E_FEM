/***********************************************************************************************
PROGRAM: get_marriage_history.sas
PURPOSE: Generate variables to use in marriage transition models using the Marriage History file 
	(1985-2011 or maxyr).
	
STEPS: - Define macros with variable names to read-in from different source files
	- Read-in from Individuals file id numbers for each year (family and sequence numbers), 
		month and year the individual was born, and year of dead (1985-2009)
	- Read-in interview dates from family files (1999-2009) for individuals above and combine 
		with individuals file data 
	- Read-in Marriage History File 1985-2011 (or maxyr) and combine with data above
	- Compute measures to use in marriage transition models
	- Save file with all individuals in the marriage history file (surveyed indiv from 1985 to 2011 or maxyr),
		with measures for each survey date 1999 to 2011: marrvars.sas7bdat and marrvars.dta
	
************************************************************************************************/

options mprint compress=yes;
*%include "../../../fam_env.sas";
%include "setup.inc";
%let yr=%substr(&maxyr.,3,2);
%let per=%eval((&maxyr.-1999)/2+1);
%include "&maclib.psidget.mac";  /* macro to rename variables */

%include "vars_indiv_file.sas"; /* Variable names on the individual file */
%include "vars_fam_file.sas"; /* Big list of variable names on the family files */



/******************************************************************************************/
/*** Create list of variables to read in from individual file ***/

%let famnum=%selectv(%quote(&famnumin),begy=1968,endy=1968);
%let famnum=&famnum %selectv(%quote(&famnumin),begy=1985);
%let seq=%selectv(%quote(&seqin),begy=1968,endy=1968);
%let seq=&seq %selectv(%quote(&seqin),begy=1985);
%let rabmonth=%selectv(%quote(&rabmonthin),begy=1985);
%let rabyear=%selectv(%quote(&rabyearin),begy=1985);
%let famfid=%selectv(%quote(&famfidin),begy=1999);

/******************************************************************************************/
********** USEFUL MACROS FOR THIS PROGRAM;
*** generate list of family files with infile tags for merging;
%macro famflst;
	%do i= 1999 %to &maxyr. %by 2;
		%let suff=%substr(&i.,3,2);
		fam&suff.(in=_&suff.) 
	%end;
%mend;
*** generate indicator variables of family interview present when merging family files from different years;
%macro iwdummy;
	%do i=1999 %to &maxyr. %by 2;
		%let suff=%substr(&i.,3,2);
		iw&suff.=_&suff.;;
	%end;
%mend;
/* Transform season in month - take mid month */
%macro sstom(var1,var2);
	if &var1 <=12 & &var1 >=1 then &var2=&var1;
	else if &var1=21 then &var2=1;
	else if &var1=22 then &var2=4;
	else if &var1=23 then &var2=7;
	else if &var1=24 then &var2=10;
%mend;
%macro labyr;
	%do i=1999 %to &maxyr. %by 2;
	%let suff=%substr(&i.,3,2);
	label div&suff. = "Divorced by &i. Interview Month";
	label everds&suff. = "Ever Divorced or Separated by &i. Interview Month";
	label everm&suff. = "Ever Married by &i. Interview Month";
	label everw&suff. = "Ever Widow by &i. Interview Month";
	label mar&suff. = "Married by &i. Interview Month";
	label nummar&suff. = "Number of Marriages by &i. Interview Month";
	label sep&suff. = "Separated by &i. Interview Month";
	label sgl&suff. = "Single by &i. Interview Month";	
	label wid&suff. = "Widow by &i. Interview Month";
	label yrlstst&suff. = "Number of Years From Last Status Change and &i. Interview Month";	
	label yrmar&suff. = "Year marriage current in &i. took place";
	%end;
%mend;

/******************************************************************************************/

/* Get Individuals File Data */
data indiv; 
	set psid.ind&maxyr.er (keep=&famnum &seq &rabmonth &rabyear  ER32050);
		/* keep year specific id as indicator of responding during those years*/
	array yb{*} &rabyear;
	array mb{*} &rabmonth;
		
	array famnumin_[*] &famnum;
	array famnum_[*]   famnum68 %listyrv(famnum,begy=1985);
	array seqin_[*]    &seq;
	array seq_[*]      pn68 %listyrv(seq,begy=1985);

	*** Rename yearly id vars;
	cnt=0;
	do i=1 to dim(famnum_);
      		famnum_[i]=famnumin_[i];
      		seq_[i]=seqin_[i];
		cnt+1;
    	end;
   
	id=famnum68*1000 + pn68;
		
	*** Generate year of death, take the minimum point when a range supplied (either dead or missing treat the same);
	dead&maxyr.=(ER32050 ^in(.,0));
	if ER32050 >= 1960 & ER32050<=&maxyr. then deathyr=ER32050;
	yrd1=substr(trim(left(put(ER32050,z4.))),1,2)*1;
	yrd2=substr(trim(left(put(ER32050,z4.))),3,2)*1;
	estyrdead=0;
	if ER32050 ^in(0,.,9999) & deathyr=. then do;
		estyrdead=1;
		if yrd1>10 then deathyr=yrd1+1900;
		if yrd1<10 then deathyr=yrd1+2000;
	end;
	dead99=(deathyr<1999 & deathyr ^=.);

	*** get latest year/month of birth;
	yrbn=.;
	mnbn=.;
	do i=dim(yb) to 1 by -1;
			if yrbn=. & yb[i]^in(0,.) & yb[i]^=9999 then yrbn=yb[i];
			if mnbn=. & mb[i]>0 & mb[i]<13 then mnbn=mb[i];
			if yrbn ^=. & mnbn ^=. then leave;
	end;
	in85on=0;
	do i=2 to dim(seqin_);
		if seqin_[i]>=1 & seqin_[i]<=20 then in85on=1;
		if in85on=1 then leave;
	end;		
	label yrbn="Year Born, from last interview";
	label mnbn="Month Born, from last interview";
	label id="Unique Person Identifier (Interview # *1000+Person # in 1968";
	label in85on = "In the family in any of the 1985-&maxyr. interviews";
	label deathyr = "Year indiv. died (midpoint when range supplied)";
	label dead99 = "Indicator of individual dead in 1999";
	label dead&maxyr. = "Indicator of individual dead in &maxyr.";
	drop i &famnum &seq &rabmonth &rabyear pn68 famnum68;
run;
proc sort data=indiv;
	by id;
run;

/*********************************************************************************************************/
/* Get Family File Data - Interview Dates */

%let iwmonth=%selectv(%quote(&hdiwmonthin),begy=1999);
%let iwyear=%selectv(%quote(&hdiwyearin),begy=1999);
%let iwday=%selectv(%quote(&hdiwdayin),begy=1999);

%yrmacv(&hdiwmonthin,begy=1999);
%yrmacv(&hdiwdayin,begy=1999);
%yrmacv(&hdiwyearin,begy=1999);

/* gets variables for requested years and merge to ids in indiv
   by looping through all the family files
   Assumes vars[yy] macro vars have been set up (see yrmacv macro)
*/
proc sql;   
	%famget(psid,indiv,begy=1999,famid=&famfid);
quit;

data indiv;
	merge indiv %famflst;
	by id;
	array iwmonin_{*} 	&iwmonth;
	array iwyearin_{*}   &iwyear;
	array iwdayin_{*}    &iwday;
	array iwdate{*} %listyrv(iwd,begy=1999);
	array iwdatem{*} %listyrv(iwdm,begy=1999);

	%iwdummy;
	do i=1 to dim(iwmonin_);
		iwdate[i]=mdy(iwmonin_[i],iwdayin_[i],iwyearin_[i]);
		iwdatem[i]=(iwdate[i]=.);
	end;

	drop famnum: seq: &iwmonth &iwyear &iwday i;
run;
 
/*********************************************************************************************************/
/************************** MARRIAGE HISTORY FILE *********************************/
/* 2011 varlist:
MH1             int     %8.0g                 1968 INTERVIEW NUMBER OF INDIVIDUAL
MH2             int     %8.0g                 PERSON NUMBER OF INDIVIDUAL
MH3             byte    %8.0g                 SEX OF INDIVIDUAL
MH4             byte    %8.0g                 MONTH INDIVIDUAL BORN
MH5             int     %8.0g                 YEAR INDIVIDUAL BORN
MH6             int     %8.0g                 1968 INTERVIEW NUMBER OF SPOUSE
MH7             int     %8.0g                 PERSON NUMBER OF SPOUSE
MH8             byte    %8.0g                 ORDER OF THIS MARRIAGE
MH9             byte    %8.0g                 MONTH MARRIED
MH10            int     %8.0g                 YEAR MARRIED
MH11            byte    %8.0g                 STATUS OF THIS MARRIAGE
MH12            byte    %8.0g                 MONTH WIDOWED OR DIVORCED
MH13            int     %8.0g                 YEAR WIDOWED OR DIVORCED
MH14            byte    %8.0g                 MONTH SEPARATED
MH15            int     %8.0g                 YEAR SEPARATED
MH16            int     %8.0g                 YEAR MOST RECENTLY REPORTED MARRIAGE
MH17            byte    %8.0g                 NUMBER OF MARRIAGES OF THIS INDIVIDUAL
MH18            byte    %8.0g                 LAST KNOWN MARITAL STATUS
MH19            byte    %8.0g                 NUMBER OF MARRIAGE RECORDS
MH20            byte    %8.0g                 RELEASE NUMBER

2013 varlist:
MH1             byte    %8.0g                 RELEASE NUMBER
MH2             int     %8.0g                 1968 INTERVIEW NUMBER OF INDIVIDUAL
MH3             double  %12.0g                PERSON NUMBER OF INDIVIDUAL
MH4             double  %12.0g                SEX OF INDIVIDUAL
MH5             int     %8.0g                 MONTH INDIVIDUAL BORN
MH6             int     %8.0g                 YEAR INDIVIDUAL BORN
MH7             int     %8.0g                 1968 INTERVIEW NUMBER OF SPOUSE
MH8             double  %12.0g                PERSON NUMBER OF SPOUSE
MH9             double  %12.0g                ORDER OF THIS MARRIAGE
MH10            int     %8.0g                 MONTH MARRIED
MH11            double  %12.0g                YEAR MARRIED
MH12            double  %12.0g                STATUS OF THIS MARRIAGE
MH13            int     %8.0g                 MONTH WIDOWED OR DIVORCED
MH14            double  %12.0g                YEAR WIDOWED OR DIVORCED
MH15            int     %8.0g                 MONTH SEPARATED
MH16            int     %8.0g                 YEAR SEPARATED
MH17            double  %12.0g                YEAR MOST RECENTLY REPORTED MARRIAGE
MH18            double  %12.0g                NUMBER OF MARRIAGES OF THIS INDIVIDUAL
MH19            double  %12.0g                LAST KNOWN MARITAL STATUS
MH20            double  %12.0g                NUMBER OF MARRIAGE RECORDS
*/


** Are there duplicates in the file? One entry per individual and marriage ;
proc sort data= psid.MH85_&yr. out=marriages nodupkey;
	/* Sort by: interview, person number, order of marriage 
	Note: These variables changed name for 2013! */
	by mh2 mh3 mh9; 
run;

data marriages;
	set marriages;
	id=mh2*1000+mh3;
run;

data marriages (drop= agemack i);
	merge marriages (in=a) indiv (in=b);
	by id;
	format dtmarr dtwiddiv dtsep iwd99 iwd0:  mmddyy8.;
	if in85on=1 & a; /* Only People in Marriage File: Head, Wife and "Wife" of any age & OFUM ages 12-44 */	
	
	/* Generate age at the time of marriage */
	*** Recomendation: use latest survey data from individuals file for yr/month born;
	%sstom(mh10,monm);
	%sstom(mh15,mons);
	%sstom(mh13,monwd);
	
	if mh12 ^in(8,9,.) & monm^=. & mh11^=9998 & mnbn^=. & yrbn^=. then agema = intck("MONTH",mdy(mnbn,15,yrbn),mdy(monm,15,mh11))/12;
	if mh12 ^in(8,9,.) & monm^=. & mh11^= 9998 & mh6^=9998 & mh5 ^=98 then agemack = intck("MONTH",mdy(mh5,15,mh6),mdy(monm,15,mh11))/12;
	if agema<13 & agemack>agema then agema=agemack;
	if mh9=1 then age1ma=agema;
	
	if mh11<9998 & monm^=. then dtmarr = mdy(monm,15,mh11);
	if monwd ^=. & mh14<9998 then dtwiddiv = mdy(monwd,15,mh14);
	if mons^=. & mh16<9998 then dtsep = mdy(mons,15,mh16);
	
	if mh9 in(98,.) then nummar = .;
		else if mh9=99 then nummar = 0;
		else nummar = mh9;	
		
	label monm = "Month married";
	label agema = "Age when Married";
	label age1ma = "Age when First Married";
	label dtwiddiv = "Month Widowed or Divorced";
	label dtsep = "Month Separated";

	array sgl{*} %listyrv(vname=sgl,begy=1999,endy=&maxyr.);
	array mar{*} %listyrv(vname=mar,begy=1999,endy=&maxyr.);
	array wid{*} %listyrv(vname=wid,begy=1999,endy=&maxyr.);
	array div{*} %listyrv(vname=div,begy=1999,endy=&maxyr.);
	array sep{*} %listyrv(vname=sep,begy=1999,endy=&maxyr.);
	array numm{*} %listyrv(vname=nummar,begy=1999, endy=&maxyr.);
	array everm{*} %listyrv(vname=everm,begy=1999, endy=&maxyr.);
	array everw{*} %listyrv(vname=everw,begy=1999, endy=&maxyr.);
	array everds{*} %listyrv(vname=everds, begy=1999, endy=&maxyr.);
	array yrmar{*} %listyrv(vname=yrmar,begy=1999, endy=&maxyr.);
	array age1m{*} %listyrv(vname=fmaage,begy=1999, endy=&maxyr.);
	array yrlstst{*} %listyrv(vname=yrlstst,begy=1999, endy=&maxyr.);
	array iwdate{*} %listyrv(vname=iwd,begy=1999,endy=&maxyr.);
	
	do i=1 to &per.;
		if (deathyr >= 1997+i*2 | deathyr=.) & (mh17 >= 1997+i*2 | iwdate[i]^=.)then do;

			if (mh9=99) then sgl[i]=1;
			else if mh9=1 & iwdate[i]^=. & (dtmarr > iwdate[i]) then sgl[i]=1;
			else if mh9=1 & year(dtmarr)>1997+i*2 then sgl[i]=1;
			else if (dtmarr^=. & (dtmarr <= iwdate[i]) & (mh12=1 | (mh12 in (3,4) & (dtwiddiv > iwdate[i]) & iwdate[i]^=.) | (mh12=5 & (dtsep > iwdate[i]) & iwdate[i]^=.))) 
				then mar[i] = 1;/* Cases with no missing interview date */
			else if (dtmarr^=. & year(dtmarr) < 1997+i*2 ) & (mh12=1 | (mh12 in (3,4) & year(dtwiddiv) > 1997+i*2) | (mh12=5 & year(dtsep) > 1997+i*2)) 
				then mar[i] = 1;/* Cases with missing interview date */
			else if (mh12=3 & (dtwiddiv<iwdate[i] | year(dtwiddiv)<1997+i*2)) then wid[i] = 1;
			else if (mh12=4 & (dtwiddiv<iwdate[i] | year(dtwiddiv)<1997+i*2)) then div[i] = 1;
			else if (mh12=5 & dtsep<iwdate[i]) | (mh12=4 & dtsep<iwdate[i] & dtsep^=. & dtwiddiv>iwdate[i]) then sep[i] = 1;
			else if (mh12=5 & year(dtsep)<1997+i*2) | (mh12=4 & year(dtsep)<1997+i*2 & dtsep^=. & year(dtwiddiv)>1997+i*2) then sep[i] = 1;
			if wid[i]=1 then sgl[i]=1;
			if mar[i]=1 | div[i]=1 | sep[i]=1 then sgl[i]=0;
			if sgl[i]=1 | wid[i]=1 | div[i]=1 | sep[i]=1 then mar[i]=0;
			if (sgl[i]=1 | mar[i]=1 | div[i]=1 | sep[i]=1) & wid[i]^=1 then wid[i]=0;
			if (sgl[i]=1 | mar[i]=1 | wid[i]=1 | sep[i]=1) & div[i]^=1 then div[i]=0;
			if (sgl[i]=1 | mar[i]=1 | wid[i]=1 | div[i]=1) & sep[i]^=1 then sep[i]=0;
			if (iwdate[i]>= dtmarr | 1997+i*2 > year(dtmarr) | dtmarr=.) then numm[i] = nummar;
			if (iwdate[i]>= dtmarr | 1997+i*2 > year(dtmarr)) then age1m[i] = age1ma;
			if (iwdate[i]< dtmarr | 1997+i*2 < year(dtmarr)) then numm[i] = 0;
			if i=1 then do;
				everm[i] = (mar[i]=1) | wid[i]=1 | div[i]=1 | sep[i]=1;
				everw[i] = (wid[i]=1);
				everds[i] = (div[i]=1 | sep[i]=1);
			end;
			else do;
				everm[i] = (mar[i]=1 | div[i]=1 | wid[i]=1 | sep[i]=1 | everm[i-1]=1);
				everw[i] = (wid[i]=1 | everw[i-1]=1);
				everds[i] = (div[i]=1 | sep[i]=1 | everds[i-1]=1);
			end;
			if dtmarr<=iwdate[i] & dtmarr ^=. & ((dtwiddiv^=. & dtwiddiv>iwdate[i] & dtsep=.) | (dtsep^=. & dtsep>iwdate[i]) | mh12=1)then do;
					yrmar[i] = year(dtmarr);			
					yrlstst[i] = intck("MONTH",dtmarr,iwdate[i])/12;
			end;
			if (mh12 in(3,4) & dtwiddiv<iwdate[i] & dtwiddiv ^=.) then yrlstst[i] = intck("MONTH",dtwiddiv,iwdate[i])/12;			
			if (dtsep<iwdate[i] & dtsep ^=. & (dtwiddiv=. | dtwiddiv>iwdate[i])) then	yrlstst[i] = intck("MONTH",dtsep,iwdate[i])/12;
			if (mh12 = 9 | (mh9 = 1 & dtmarr > iwdate[i])) & intck("YEAR",mdy(mnbn,15,yrbn),iwdate[i])>=12 then yrlstst[i] = max(0,intck("MONTH",mdy(mnbn,15,yrbn),iwdate[i])/12-12);
			if i^=1 then do;
				if iwdate[i]=. then yrlstst[i]=yrlstst[i-1]+2;
			end;

				/* 12 years is the minimun years considered for marriage in this survey (see PSID Main Interview User Manual)*/				
		end;
		
	end;
	rename mh4 = gender;
	label mh4 = "Sex of Indiv. 1=Male 2=Female";
	%labyr;
run;

/**********************************************************************************************************************************/
/* Get final measures (wide file - one line per individual, with different vars for each survey year 99 to 09 */
proc means data=marriages noprint;
	by id gender dead99 dead&maxyr.;
	output out=marrvars(drop=_freq_ _type_) min(fmaage: yrlstst:)= max(sgl: mar: wid: div: sep: everm: everw: everds: nummar: yrmar:)=;
run;
title "Frequency from Marital Status Measures Allowing Overlap";
proc freq data=marrvars;
	table sgl99*mar99*wid99*div99*sep99/missing list;
	table sgl01*mar01*wid01*div01*sep01/missing list;
	table sgl03*mar03*wid03*div03*sep03/missing list;
	table sgl05*mar05*wid05*div05*sep05/missing list;
	table sgl07*mar07*wid07*div07*sep07/missing list;
	table sgl09*mar09*wid09*div09*sep09/missing list;
	table sgl11*mar11*wid11*div11*sep11/missing list;
	table sgl13*mar13*wid13*div13*sep13/missing list;
run;

/* The tags widow, divorced and separated where defined in relationship to each marriage before. By taking the maximum we have the "ever before" tag */
/* We now re-define the same tags to define the specific moment in time. We re-define single to account for widows and divorsees as singles */ 
data proj.marrvars(drop=nummar);
	set marrvars;
	array sgl{*} %listyrv(vname=sgl,begy=1999,endy=&maxyr.);
	array mar{*} %listyrv(vname=mar,begy=1999,endy=&maxyr.);
	array wid{*} %listyrv(vname=wid,begy=1999,endy=&maxyr.);
	array div{*} %listyrv(vname=div,begy=1999,endy=&maxyr.);
	array sep{*} %listyrv(vname=sep,begy=1999,endy=&maxyr.);
	array numm{*} %listyrv(vname=nummar,begy=1999, endy=&maxyr.);

	do i=1 to dim(sgl);
		if mar[i]=1 then do;
			sgl[i]=0;wid[i]=0;div[i]=0;sep[i]=0;
		end;
		else if div[i]=1 then do;
			sgl[i]=1;wid[i]=0;sep[i]=0; mar[i]=0;		
		end;
		else if wid[i]=1 then do;
			sgl[i]=0;sep[i]=0;mar[i]=0;
		end;			
	end;
	keep fmaage: yrlstst: sgl: mar: wid: div: sep: everm: everw: everds: nummar: yrmar: id gender dead99 dead&maxyr.;
run;

/**********************************************************************************************************************************/
/****** Final Files Descriptions ******/

title1 "Final Marriage Measures - all individuals with 1+ survey from 1985";
proc contents data=proj.marrvars;run;
proc freq data=proj.marrvars;
	table gender dead99 dead&maxyr. sgl: mar: wid: div: sep: everm: everw: everds: nummar: /missing;
	table everm99*nummar99 everm01*nummar01 everm03*nummar03 everm05*nummar05 everm07*nummar07 everm09*nummar09 everm11*nummar11 everm13*nummar13 /missing;
run;
proc means data=proj.marrvars;
	var fmaage: yrlstst: yrmar:;
run;

x st "&outlib.marrvars.sas7bdat" "&outlib.marrvars.dta" -y;

/* Check changes in recoding marital status flags */
proc compare base=proj.marrvars compare=marrvars;
run;
