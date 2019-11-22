/*****************************************************************************************
Goal: Pul religious commitment measure.
	Data available from family files: 
	- Religious preference information available from 1970 to 2011, yearly for new head/wife. 
	Answer in categories, but categories available change over time (two questions in later years, 
	first protestant grouped in one category, then asked again about denomination of religion – open question?). 
	As of 1/2014 there is no clear use for this variable in the model, so it isn't pulled.
	- How often attended religious services (respondent and spouse). This information is available for early years 
	for heads (1968-1972), and then in 2003, 2005, and 2011 for heads and wifes.
	Used as religious commitment measure. 
	- Individual level file has questions on type of insitution attended for schooling (public/private – religious if private). Not asked if > 40 – ONLY 1995
	Not used
	- Other information available in CDS and TA questionaires - Not used 

******************************************************************************************/
%include "setup.inc";
%include "&maclib.psidget.mac";  /* macro to get early release data */ 
%include "&maclib.renyrv.mac";  /* macro to rename variables */

/******** INDIVIDUAL FILE VARIABLES ****************************************************/
/******** Usually needed are famnum, seq, relhd ****************************************/
%let seqin=[68]ER30002 [69]ER30021 [70]ER30044 [71]ER30068 [72]ER30092 [73]ER30118 
           [74]ER30139 [75]ER30161 [76]ER30189 [77]ER30218 [78]ER30247 [79]ER30284 
           [80]ER30314 [81]ER30344 [82]ER30374 [83]ER30400 [84]ER30430 [85]ER30464 
           [86]ER30499 [87]ER30536 [88]ER30571 [89]ER30607 [90]ER30643 [91]ER30690 
           [92]ER30734 [93]ER30807 [94]ER33102 [95]ER33202 [96]ER33302 [97]ER33402 
           [99]ER33502 [01]ER33602 [03]ER33702 [05]ER33802 [07]ER33902 [09]ER34002
           [11]ER34102 [13]ER34202 [15]ER34302;

%let famnumin=[68]ER30001 [69]ER30020 [70]ER30043 [71]ER30067 [72]ER30091 
              [73]ER30117 [74]ER30138 [75]ER30160 [76]ER30188 [77]ER30217 [78]ER30246 
              [79]ER30283 [80]ER30313 [81]ER30343 [82]ER30373 [83]ER30399 [84]ER30429 
              [85]ER30463 [86]ER30498 [87]ER30535 [88]ER30570 [89]ER30606 [90]ER30642 
              [91]ER30689 [92]ER30733 [93]ER30806 [94]ER33101 [95]ER33201 [96]ER33301 
              [97]ER33401 [99]ER33501 [01]ER33601 [03]ER33701 [05]ER33801 [07]ER33901 
              [09]ER34001 [11]ER34101 [13]ER34201 [15]ER34301;
/* NOTE: these were not easily listed cross-year wise. 
   If pulling 1968 family data please verify that V2 is the correct famnum to use */
%let famfidin=[68]V2     [69]V442   [70]V1102  [71]V1802  [72]V2402  [73]V3002  
              [74]V3402  [75]V3802  [76]V4302  [77]V5202  [78]V5702  [79]V6302
              [80]V6902  [81]V7502  [82]V8202  [83]V8802  [84]V10002 [85]V11102 
              [86]V12502 [87]V13702 [88]V14802 [89]V16302 [90]V17702 [91]V19002 
              [92]V20302 [93]V21602 [94]ER2002 [95]ER5002 [96]ER7002 [97]ER10002
              [99]ER13002 [01]ER17002 [03]ER21002 [05]ER25002 [07]ER36002 [09]ER42002
              [11]ER47302 [13]ER53002 [15]ER60002;

%let relhdin=[68]ER30003 [69]ER30022 [70]ER30045 [71]ER30069 [72]ER30093 
             [73]ER30119 [74]ER30140 [75]ER30162 [76]ER30190 [77]ER30219 [78]ER30248 
             [79]ER30285 [80]ER30315 [81]ER30345 [82]ER30375 [83]ER30401 [84]ER30431 
             [85]ER30465 [86]ER30500 [87]ER30537 [88]ER30572 [89]ER30608 [90]ER30644 
             [91]ER30691 [92]ER30735 [93]ER30808 [94]ER33103 [95]ER33203 [96]ER33303 
             [97]ER33403 [99]ER33503 [01]ER33603 [03]ER33703 [05]ER33803 [07]ER33903 
             [09]ER34003 [11]ER34103 [13]ER34203 [15]ER34303;

/******** FAMILY FILE VARIABLES *******************************************************/

****** Religious service attendance (years 2003 2005 2011);
** respondant;
%let rrelsrvn=ER23699 ER27708 ER52046; ** # times;
%let rrelsrvt=ER23700 ER27709 ER52047; ** time units;
** spouse;
%let srelsrvn=ER23701 ER27710 ER52064; ** # times;
%let srelsrvt=ER23702 ER27711 ER52065; ** time units;
** head;
%let hdrelsrv=[68]V284 [69]V763 [70]V1430 [71]V2142 [72]V2783;

/*** individual file ***/
%let famnum=%selectv(%quote(&famnumin),begy=1968,endy=1968);
%let famnum=&famnum %selectv(%quote(&famnumin),begy=1969);
%let seq=%selectv(%quote(&seqin),begy=1968,endy=1968);
%let seq=&seq %selectv(%quote(&seqin),begy=1969);
%let famfid=%selectv(%quote(&famfidin),begy=1968);
%let relhd=%selectv(%quote(&relhdin),begy=1968);

** Years with data;
%let yrsl1=1968 1969 1970 1971 1972;
%let yrsl2=2003 2005 2011;

%let vars68=V284;
%let vars69=V763;
%let vars70=V1430;
%let vars71=V2142;
%let vars72=V2783;
%let vars03=ER23699 ER23700 ER23701 ER23702 ;
%let vars05= ER27708 ER27709 ER27710 ER27711;
%let vars11= ER52046 ER52047 ER52064 ER52065;

/***************************************************************************************************************/
/* the following uses the individual file to select the sample
   to match to when processing family files. */


data ind;
   set psid.ind&maxyr.er  ( KEEP = &famnum &seq &relhd );
   
   array famnumin_[*] &famnum;
   array famnum_[*]   famnum68 %listyrv(famnum,begy=&minyr);
   array seqin_[*]    &seq;
   array seq_[*]      pn68 %listyrv(seq,begy=&minyr);
   array relhdin_[*]  &relhd;
   array relhd_[*]    relhd68 %listyrv(relhd,begy=&minyr);

   do i=1 to dim(famnum_);
      famnum_[i]=famnumin_[i];
      seq_[i]=seqin_[i];
      relhd_[i]=relhdin_[i];
   end;
   
   id=famnum68*1000 + pn68;
   drop &famnum &seq &relhd;
run;

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
run;
*************************************************************************************************;

proc sql;
%sqlone(68,psid.fam1968,&vars68.,ind1,famnum=V2);
%sqlone(69,psid.fam1969,&vars69.,ind1,famnum=V442);
%sqlone(70,psid.fam1970,&vars70.,ind1,famnum=V1102);
%sqlone(71,psid.fam1971,&vars71.,ind1,famnum=V1802);
%sqlone(72,psid.fam1972,&vars72.,ind1,famnum=V2402);
%sqlone(03,psid.fam2003er,&vars03.,ind1,famnum=ER21002);
%sqlone(05,psid.fam2005er,&vars05.,ind1,famnum=ER25002);
%sqlone(11,psid.fam2011er,&vars11.,ind1,famnum=ER47302);
quit;

data test;
	merge fam03;
data proj.famrelv;
	merge fam03 fam05 fam11 fam68 fam69 fam70 fam71 fam72 
		ind1(in=a keep=id relhd68 pn68 relhd69 seq69 relhd70 seq70 relhd71 seq71 relhd72 seq72 relhd03 seq03 relhd05 seq05 relhd11 seq11);
	by id;	
	if a ;
	array rreln{3} &rrelsrvn;
	array rrelt{3} &rrelsrvt;
	array sreln{3} &srelsrvn;
	array srelt{3} &srelsrvt;
	array seq{3} seq03 seq05 seq11;
	array relhd{3} relhd03 relhd05 relhd11;
	array relinv{3} relinv03 relinv05 relinv11; 
	array ofch{3} ofch03 ofch05 ofch11;
	do i = 1 to 3;
	if 0 < seq[i] < 50 & relhd[i] in(1,10) then do;
		if rreln[i] in(98,99,.) then relinv[i]=.;
		else if rrelt[i]=0 then relinv[i]=0;
		else if rrelt[i]=2 then relinv[i]=rreln[i]*30;
		else if rrelt[i]=3 then relinv[i]=rreln[i]*4.3;
		else if rrelt[i]=4 then relinv[i]=rreln[i]*4.3/2;
		else if rrelt[i]=5 then relinv[i]=rreln[i];
		else if rrelt[i]=6 then relinv[i]=rreln[i]/12;
		else if rrelt[i] in(8,9) then relinv[i]=.;	
	end;
	else if 0 < seq[i] < 50 & relhd[i] in(2,20,22) then do;
		if sreln[i] in(98,99,.) then relinv[i]=.;
		else if srelt[i]=0 then relinv[i]=0;
		else if srelt[i]=2 then relinv[i]=sreln[i]*30;
		else if srelt[i]=3 then relinv[i]=sreln[i]*4.3;
		else if srelt[i]=4 then relinv[i]=sreln[i]*4.3/2;
		else if srelt[i]=5 then relinv[i]=sreln[i];
		else if srelt[i]=6 then relinv[i]=sreln[i]/12;
		else if srelt[i] in(7,8,9) then relinv[i]=.;	
	end;
	if relinv[i]=. then ofch[i]=.;
	else if relinv[i]=0 then ofch[i]=0;
	else if relinv[i]<1 then ofch[i]=3;/** less than once a month **/
	else if relinv[i]<4 then ofch[i]=2;/** once a month or more, up to 3 times per month **/
	else ofch[i]=1;/** Once a week or more **/
	end;
	array ofchor{5} V284 V763 V1430 V2142 V2783;
	array seq_2{5} pn68 seq69 seq70 seq71 seq72;
	array relhd_2{5} relhd68 relhd69 relhd70 relhd71 relhd72;	 
	array ofch_2{5} ofch68 ofch69 ofch70 ofch71 ofch72;
	do i=1 to dim(ofchor);
		if ofchor[i] in(0,1,2,3) & 0 < seq_2[i] < 50 & relhd_2[i] in(1,10) then ofch_2[i]=ofchor[i];
	end;

	drop i;
	label relinv03= "Number of times attending religious service per month-2003";
	label relinv05= "Number of times attending religious service per month-2005";
	label relinv11= "Number of times attending religious service per month-2011";
	label relhd03 ="Relation to head 2003";
	label relhd05= "Relation to head 2005";
	label relhd11= "Relation to head 2011";
	label ofch68= "How often go to religious services-1968";
	label ofch69= "How often go to religious services-1969";
	label ofch70= "How often go to religious services-1970";
	label ofch71= "How often go to religious services-1971";
	label ofch72= "How often go to religious services-1972";
	label ofch03= "How often go to religious services-2003";
	label ofch05= "How often go to religious services-2005";
	label ofch11= "How often go to religious services-1211";

run;
proc contents data=proj.famrelv;run;
run;

*****************************************************************************;
***** COMBINE INTO ONE MEASURE;
*****************************************************************************;
proc format;
	value ofchv
	0="Never"
	1="Once a week or more"
	2="Once a month or more"
	3="Less than once a month";
run;
data proj.famrelv;
	set proj.famrelv;
	format ofch: ofchv.;
	if relinv03^=. then relinv03=min(relinv03,60);/*Cap at 60, twice a day*/
	if relinv05^=. then relinv05=min(relinv05,60);
	if relinv11^=. then relinv11=min(relinv11,60);
	relinv=mean(relinv03,relinv05,relinv11);
	if relinv=. then ofch=.;
	else if relinv=0 then ofch=0;
	else if relinv<1 then ofch=3;/** less than once a month **/
	else if relinv<4 then ofch=2;/** once a month or more, up to 3 times per month **/
	else ofch=1;/** Once a week or more **/
	if ofch=. then ofch=ofch72;
	if ofch=. then ofch=ofch71;
	if ofch=. then ofch=ofch70;
	if ofch=. then ofch=ofch69;
	if ofch=. then ofch=ofch68;
	label ofch="How often go to religious services (avg 2003,2005,2011 or most recent available)";
	label relinv = "Avg. # of times att. religious service per month-2003,2005,2011";
*	keep id ofch relinv;
run;

title "Religious Involvement - Distribution of Continous Measure";
proc means n nmiss p1 p5 p10 p25 mean median p75 p90 p95 p99 ;
var relinv relinv03 relinv05 relinv11;
run;

title "Religious Involvement - Correlation";
proc corr;
var relinv03 relinv05 relinv11;
run;
title "Religious Involvement - Discrete Measures";
proc freq ;
	table ofch/missing; 
run;
