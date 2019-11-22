%include "setup.inc";
%include "&maclib.psidget.mac";  /* macro to get early release data */ 
%include "&maclib.renyrv.mac";  /* macro to rename variables */

/* Variable lists are now in separate files */
%include "vars_indiv_file.sas"; /* Variable names on the individual file */
%include "vars_fam_file.sas"; /* Big list of variable names on the family files */
%include "vars_childhealth.sas"; /* Variables for childhood health questions */
%include "vars_age_onset.sas"; /* Variables for age of onset for diseases */
%include "vars_k6.sas"; /* Variables for Kessler psychological distress questions */
%include "vars_consumption.sas"; /* Variables for household consumption */

/* Options symbolgen mlogic mprint mfile; */

/********************************************************************************
Goal:  Pull race (head and wife) and marital status (head) from PSID family files
New goal: Pull:
			x	age, (ind)
			x	birth year, (ind)
			x	birth month, (ind)
			x	sex, (ind)  -  ER32000 for all years
			x	race, (fam)
			x	hispanic, (fam)
			x	education,  (ind)
			x	head/wife,  (ind)
				year became head/wife?
			x	sequence, (ind)
			x	fam#, (ind)
			x	cross-sectional weight, (ind)
			/	in_yr, ()
			/ 	died flag (derived from sequence)
			x	health status
			x health conditions
			x	marital status of head, (fam)
			x 	marital status of head (does not distinguish between married and cohabitating), (fam)
				Interview day, month, year		
			x region	
				
			x ADL-related variables (following RAND HRS) - bathing, eating, dressing, walking across a room, getting in/out of bed
			x IADL-related variables (following RAND HRS) - using a telephone, taking medication, handling money
			Nursing home
			
			x death year - from individual file, variable ER32050
	
********************************************************************************/


/* Make a list of variable names from the XXXXXin list */
%yrmacv(&hdracein,begy=1999);
%yrmacv(&wfracein,begy=1999);
%yrmacv(&hdhispanin,begy=1999);
%yrmacv(&wfhispanin,begy=1999);
%yrmacv(&hdmarrin,begy=1999);
%yrmacv(&hdmarrgen,begy=1999);
%yrmacv(&hdmarrch,begy=1999); 																																				/* add marriage change variable */
%yrmacv(&hdshlthin,begy=1999);
%yrmacv(&wfshlthin,begy=1999);
%yrmacv(&hdcancrin,begy=1999);
%yrmacv(&wfcancrin,begy=1999);
%yrmacv(&hddiabin,begy=1999);
%yrmacv(&wfdiabin,begy=1999);
%yrmacv(&hdheartin,begy=1999);
%yrmacv(&wfheartin,begy=1999);																																				/* add heart attack variables */
%yrmacv(&hdheartain,begy=1999);																																				/* add heart attack variables */
%yrmacv(&wfheartain,begy=1999);
%yrmacv(&hdhibpin,begy=1999);
%yrmacv(&wfhibpin,begy=1999);
%yrmacv(&hdlungin,begy=1999);
%yrmacv(&wflungin,begy=1999);
%yrmacv(&hdstrokin,begy=1999);
%yrmacv(&wfstrokin,begy=1999);

%yrmacv(&hdasthmin,begy=1999);
%yrmacv(&wfasthmin,begy=1999);


%yrmacv(&hdcancrloc1in,begy=2005);
%yrmacv(&hdcancrloc2in,begy=2005);
%yrmacv(&wfcancrloc1in,begy=2005);
%yrmacv(&wfcancrloc2in,begy=2005);
%yrmacv(&hdcancrlimitin,begy=1999);
%yrmacv(&wfcancrlimitin,begy=1999);
%yrmacv(&hddiablimitin,begy=1999);
%yrmacv(&wfdiablimitin,begy=1999);
%yrmacv(&hdheartlimitin,begy=1999);
%yrmacv(&wfheartlimitin,begy=1999);
%yrmacv(&hdhibplimitin,begy=1999);
%yrmacv(&wfhibplimitin,begy=1999);
%yrmacv(&hdlunglimitin,begy=1999);
%yrmacv(&wflunglimitin,begy=1999);
%yrmacv(&hdheartalimitin,begy=1999);
%yrmacv(&wfheartalimitin,begy=1999);
%yrmacv(&hdstroklimitin,begy=1999);
%yrmacv(&wfstroklimitin,begy=1999);

/* Smoking-related variables */
%yrmacv(&hdsmokenin,begy=1999);
%yrmacv(&wfsmokenin,begy=1999);
%yrmacv(&hdsmokevin,begy=1999);
%yrmacv(&wfsmokevin,begy=1999);
%yrmacv(&hdnumcigsnin,begy=1999);
%yrmacv(&hdnumcigsein,begy=1999);
%yrmacv(&hdsmokestartnin,begy=1999);
%yrmacv(&hdsmokestartein,begy=1999);
%yrmacv(&hdsmokestopin,begy=1999);
%yrmacv(&wfnumcigsnin,begy=1999);
%yrmacv(&wfnumcigsein,begy=1999);
%yrmacv(&wfsmokestartnin,begy=1999);
%yrmacv(&wfsmokestartein,begy=1999);
%yrmacv(&wfsmokestopin,begy=1999);
%yrmacv(&hdwghtin,begy=1999);
%yrmacv(&wfwghtin,begy=1999);
%yrmacv(&hdheightftin,begy=1999);
%yrmacv(&wfheightftin,begy=1999);
%yrmacv(&hdheightinin,begy=1999);
%yrmacv(&wfheightinin,begy=1999);

%yrmacv(&hdiwmonthin,begy=1999);
%yrmacv(&wfiwmonthin,begy=1999);
%yrmacv(&hdiwdayin,begy=1999);
%yrmacv(&wfiwdayin,begy=1999);
%yrmacv(&hdiwyearin,begy=1999);
%yrmacv(&wfiwyearin,begy=1999);

/* ADL-related variables */
%yrmacv(&hdbathin,begy=1999);
%yrmacv(&wfbathin,begy=1999);
%yrmacv(&hdeatin,begy=1999);
%yrmacv(&wfeatin,begy=1999);
%yrmacv(&hddressin,begy=1999);
%yrmacv(&wfdressin,begy=1999);
%yrmacv(&hdwalkin,begy=1999);
%yrmacv(&wfwalkin,begy=1999);
%yrmacv(&hdbedin,begy=1999);
%yrmacv(&wfbedin,begy=1999);
%yrmacv(&hdtoiletin,begy=1999);
%yrmacv(&wftoiletin,begy=1999);
%yrmacv(&hdbathhelpin,begy=1999);
%yrmacv(&wfbathhelpin,begy=1999);
%yrmacv(&hdeathelpin,begy=1999);
%yrmacv(&wfeathelpin,begy=1999);
%yrmacv(&hddresshelpin,begy=1999);
%yrmacv(&wfdresshelpin,begy=1999);
%yrmacv(&hdwalkhelpin,begy=1999);
%yrmacv(&wfwalkhelpin,begy=1999);
%yrmacv(&hdbedhelpin,begy=1999);
%yrmacv(&wfbedhelpin,begy=1999);
%yrmacv(&hdtoilethelpin,begy=1999);
%yrmacv(&wftoilethelpin,begy=1999);

/* IADL-related variables */
%yrmacv(&hdmealsin,begy=2003);
%yrmacv(&hdshopin,begy=2003);
%yrmacv(&hdmoneyin,begy=2003);
%yrmacv(&hdphonein,begy=2003);
%yrmacv(&hdhvyhswrkin,begy=2003);
%yrmacv(&hdlthswrkin,begy=2003);
%yrmacv(&wfmealsin,begy=2003);
%yrmacv(&wfshopin,begy=2003);
%yrmacv(&wfmoneyin,begy=2003);
%yrmacv(&wfphonein,begy=2003);
%yrmacv(&wfhvyhswrkin,begy=2003);
%yrmacv(&wflthswrkin,begy=2003);
%yrmacv(&hdmealstpin,begy=2003);
%yrmacv(&hdshoptpin,begy=2003);
%yrmacv(&hdmoneytpin,begy=2003);
%yrmacv(&hdphonetpin,begy=2003);
%yrmacv(&hdhvyhswrktpin,begy=2003);
%yrmacv(&hdlthswrktpin,begy=2003);
%yrmacv(&wfmealstpin,begy=2003);
%yrmacv(&wfshoptpin,begy=2003);
%yrmacv(&wfmoneytpin,begy=2003);
%yrmacv(&wfphonetpin,begy=2003);
%yrmacv(&wfhvyhswrktpin,begy=2003);
%yrmacv(&wflthswrktpin,begy=2003);

/* Nursing home related variables */
%yrmacv(&elderhomein,begy=1999);
%yrmacv(&eldertypein,begy=1999);

/* Region */
%yrmacv(&regionin,begy=1999);

/* Alternate education source */
%yrmacv(&hdeducaltin,begy=1999);
%yrmacv(&wfeducaltin,begy=1999);

/* Parents poor or what */
%yrmacv(&hdparpoorin,begy=1969);
%yrmacv(&wfparpoorin,begy=1969);

/* Health status as child */
%yrmacv(&hdchldhlthin,begy=2007);
%yrmacv(&wfchldhlthin,begy=2007);

/* Grew up in farm/country, small town/suburb, large city, etc. */
%yrmacv(&hdgrewupin, begy=1999);
%yrmacv(&wfgrewupin, begy=2009);

/* Light exercise, heavy exercise, strength training (frequency and units) */
%yrmacv(&hdlgtexcfreqin, begy=1999);
%yrmacv(&wflgtexcfreqin, begy=1999);
%yrmacv(&hdlgtexcunitin, begy=1999);
%yrmacv(&wflgtexcunitin, begy=1999);
%yrmacv(&hdhvyexcfreqin, begy=1999);
%yrmacv(&wfhvyexcfreqin, begy=1999);
%yrmacv(&hdhvyexcunitin, begy=1999);
%yrmacv(&wfhvyexcunitin, begy=1999);
%yrmacv(&hdmusclefreqin, begy=2005);
%yrmacv(&hdmuscleunitin, begy=2005);
%yrmacv(&wfmusclefreqin, begy=2005);
%yrmacv(&wfmuscleunitin, begy=2005);


/* Spending on eating out and units.  "fs" refers to being on food stamps */
%yrmacv(&eatoutfsin, begy=1999);
%yrmacv(&eatoutfsunitin, begy=1999);
%yrmacv(&eatoutin, begy=1999);
%yrmacv(&eatoutunitin, begy=1999);

%yrmacv(&numinfuin, begy=1999);

%yrmacv(&hproptaxin, begy=1999);

/* Work related variables: weeks worked, hours per week, overtime, total hours per year */
%yrmacv (&hdworkweeksin,begy=1999);
%yrmacv (&wfworkweeksin,begy=1999);
%yrmacv (&hdweekworkhrin,begy=1999);
%yrmacv (&wfweekworkhrin,begy=1999);
%yrmacv (&hdovertimehrin,begy=1999);
%yrmacv (&wfovertimehrin,begy=1999);
%yrmacv (&hdyrworkhrin,begy=1999);
%yrmacv (&wfyrworkhrin,begy=1999);


/* For health conditions before age 17 */
%yrmacv(&hdchldsrhin,begy=2007);
%yrmacv(&wfchldsrhin,begy=2007);
%yrmacv(&hdchldmissschoolin,begy=2007);
%yrmacv(&wfchldmissschoolin,begy=2007);
%yrmacv(&hdchldmeaslesin,begy=2007);
%yrmacv(&wfchldmeaslesin,begy=2007);
%yrmacv(&hdchldmumpsin,begy=2007);
%yrmacv(&wfchldmumpsin,begy=2007);
%yrmacv(&hdchldcknpoxin,begy=2007);
%yrmacv(&wfchldcknpoxin,begy=2007);
%yrmacv(&hdchldvisionin,begy=2007);
%yrmacv(&wfchldvisionin,begy=2007);
%yrmacv(&hdchldparsmkin,begy=2007);
%yrmacv(&wfchldparsmkin,begy=2007);
%yrmacv(&hdchldasthmain,begy=2007);
%yrmacv(&wfchldasthmain,begy=2007);
%yrmacv(&hdchlddiabin,begy=2007);
%yrmacv(&wfchlddiabin,begy=2007);
%yrmacv(&hdchldrespin,begy=2007);
%yrmacv(&wfchldrespin,begy=2007);
%yrmacv(&hdchldspeechin,begy=2007);
%yrmacv(&wfchldspeechin,begy=2007);
%yrmacv(&hdchldallergyin,begy=2007);
%yrmacv(&wfchldallergyin,begy=2007);
%yrmacv(&hdchldheartin,begy=2007);
%yrmacv(&wfchldheartin,begy=2007);
%yrmacv(&hdchldearin,begy=2007);
%yrmacv(&wfchldearin,begy=2007);
%yrmacv(&hdchldszrein,begy=2007);
%yrmacv(&wfchldszrein,begy=2007);
%yrmacv(&hdchldmgrnin,begy=2007);
%yrmacv(&wfchldmgrnin,begy=2007);
%yrmacv(&hdchldstomachin,begy=2007);
%yrmacv(&wfchldstomachin,begy=2007);
%yrmacv(&hdchldhibpin,begy=2007);
%yrmacv(&wfchldhibpin,begy=2007);
%yrmacv(&hdchlddepressin,begy=2007);
%yrmacv(&wfchlddepressin,begy=2007);
%yrmacv(&hdchlddrugin,begy=2007);
%yrmacv(&wfchlddrugin,begy=2007);
%yrmacv(&hdchldpsychin,begy=2007);
%yrmacv(&wfchldpsychin,begy=2007);


/* Time with diseases */
%yrmacv(&hdstrokedaysin,begy=1999);
%yrmacv(&hdstrokemnthin,begy=1999);
%yrmacv(&hdstrokeweekin,begy=1999);
%yrmacv(&hdstrokeyearin,begy=1999);
%yrmacv(&wfstrokedaysin,begy=1999);
%yrmacv(&wfstrokemnthin,begy=1999);
%yrmacv(&wfstrokeweekin,begy=1999);
%yrmacv(&wfstrokeyearin,begy=1999);
%yrmacv(&hdhibpdaysin,begy=1999);
%yrmacv(&hdhibpmnthin,begy=1999);
%yrmacv(&hdhibpweekin,begy=1999);
%yrmacv(&hdhibpyearin,begy=1999);
%yrmacv(&wfhibpdaysin,begy=1999);
%yrmacv(&wfhibpmnthin,begy=1999);
%yrmacv(&wfhibpweekin,begy=1999);
%yrmacv(&wfhibpyearin,begy=1999);
%yrmacv(&hddiabdaysin,begy=1999);
%yrmacv(&hddiabmnthin,begy=1999);
%yrmacv(&hddiabweekin,begy=1999);
%yrmacv(&hddiabyearin,begy=1999);
%yrmacv(&wfdiabdaysin,begy=1999);
%yrmacv(&wfdiabmnthin,begy=1999);
%yrmacv(&wfdiabweekin,begy=1999);
%yrmacv(&wfdiabyearin,begy=1999);
%yrmacv(&hdcancrdaysin,begy=1999);
%yrmacv(&hdcancrmnthin,begy=1999);
%yrmacv(&hdcancrweekin,begy=1999);
%yrmacv(&hdcancryearin,begy=1999);
%yrmacv(&wfcancrdaysin,begy=1999);
%yrmacv(&wfcancrmnthin,begy=1999);
%yrmacv(&wfcancrweekin,begy=1999);
%yrmacv(&wfcancryearin,begy=1999);
%yrmacv(&hdlungdaysin,begy=1999);
%yrmacv(&hdlungmnthin,begy=1999);
%yrmacv(&hdlungweekin,begy=1999);
%yrmacv(&hdlungyearin,begy=1999);
%yrmacv(&wflungdaysin,begy=1999);
%yrmacv(&wflungmnthin,begy=1999);
%yrmacv(&wflungweekin,begy=1999);
%yrmacv(&wflungyearin,begy=1999);
%yrmacv(&hdheartattackdaysin,begy=1999);
%yrmacv(&hdheartattackmnthin,begy=1999);
%yrmacv(&hdheartattackweekin,begy=1999);
%yrmacv(&hdheartattackyearin,begy=1999);
%yrmacv(&wfheartattackdaysin,begy=1999);
%yrmacv(&wfheartattackmnthin,begy=1999);
%yrmacv(&wfheartattackweekin,begy=1999);
%yrmacv(&wfheartattackyearin,begy=1999);
%yrmacv(&hdheartdiseasedaysin,begy=1999);
%yrmacv(&hdheartdiseasemnthin,begy=1999);
%yrmacv(&hdheartdiseaseweekin,begy=1999);
%yrmacv(&hdheartdiseaseyearin,begy=1999);
%yrmacv(&wfheartdiseasedaysin,begy=1999);
%yrmacv(&wfheartdiseasemnthin,begy=1999);
%yrmacv(&wfheartdiseaseweekin,begy=1999);
%yrmacv(&wfheartdiseaseyearin,begy=1999);
%yrmacv(&hdpsychprobdaysin,begy=1999);
%yrmacv(&hdpsychprobmnthin,begy=1999);
%yrmacv(&hdpsychprobweekin,begy=1999);
%yrmacv(&hdpsychprobyearin,begy=1999);
%yrmacv(&wfpsychprobdaysin,begy=1999);
%yrmacv(&wfpsychprobmnthin,begy=1999);
%yrmacv(&wfpsychprobweekin,begy=1999);
%yrmacv(&wfpsychprobyearin,begy=1999);
%yrmacv(&hdarthritisdaysin,begy=1999);
%yrmacv(&hdarthritismnthin,begy=1999);
%yrmacv(&hdarthritisweekin,begy=1999);
%yrmacv(&hdarthritisyearin,begy=1999);
%yrmacv(&wfarthritisdaysin,begy=1999);
%yrmacv(&wfarthritismnthin,begy=1999);
%yrmacv(&wfarthritisweekin,begy=1999);
%yrmacv(&wfarthritisyearin,begy=1999);
%yrmacv(&hdasthmadaysin,begy=1999);
%yrmacv(&hdasthmamnthin,begy=1999);
%yrmacv(&hdasthmaweekin,begy=1999);
%yrmacv(&hdasthmayearin,begy=1999);
%yrmacv(&wfasthmadaysin,begy=1999);
%yrmacv(&wfasthmamnthin,begy=1999);
%yrmacv(&wfasthmaweekin,begy=1999);
%yrmacv(&wfasthmayearin,begy=1999);
%yrmacv(&hdmemorylossdaysin,begy=1999);
%yrmacv(&hdmemorylossmnthin,begy=1999);
%yrmacv(&hdmemorylossweekin,begy=1999);
%yrmacv(&hdmemorylossyearin,begy=1999);
%yrmacv(&wfmemorylossdaysin,begy=1999);
%yrmacv(&wfmemorylossmnthin,begy=1999);
%yrmacv(&wfmemorylossweekin,begy=1999);
%yrmacv(&wfmemorylossyearin,begy=1999);
%yrmacv(&hdlearningdisorderdaysin,begy=1999);
%yrmacv(&hdlearningdisordermnthin,begy=1999);
%yrmacv(&hdlearningdisorderweekin,begy=1999);
%yrmacv(&hdlearningdisorderyearin,begy=1999);
%yrmacv(&wflearningdisorderdaysin,begy=1999);
%yrmacv(&wflearningdisordermnthin,begy=1999);
%yrmacv(&wflearningdisorderweekin,begy=1999);
%yrmacv(&wflearningdisorderyearin,begy=1999);

/* Age of onset for diseases */
%yrmacv(&hdstrokeagein,begy=2005);
%yrmacv(&wfstrokeagein,begy=2005);
%yrmacv(&hdheartattackagein,begy=2005);
%yrmacv(&wfheartattackagein,begy=2005);
%yrmacv(&hdheartdiseaseagein,begy=2005);
%yrmacv(&wfheartdiseaseagein,begy=2005);
%yrmacv(&hdhypertensionagein,begy=2005);
%yrmacv(&wfhypertensionagein,begy=2005);
%yrmacv(&hdasthmaagein,begy=2005);
%yrmacv(&wfasthmaagein,begy=2005);
%yrmacv(&hdlungdiseaseagein,begy=2005);
%yrmacv(&wflungdiseaseagein,begy=2005);
%yrmacv(&hddiabetesagein,begy=2005);
%yrmacv(&wfdiabetesagein,begy=2005);
%yrmacv(&hdarthritisagein,begy=2005);
%yrmacv(&wfarthritisagein,begy=2005);
%yrmacv(&hdmemorylossagein,begy=2005);
%yrmacv(&wfmemorylossagein,begy=2005);
%yrmacv(&hdlearningdisorderagein,begy=2005);
%yrmacv(&wflearningdisorderagein,begy=2005);
%yrmacv(&hdcanceragein,begy=2005);
%yrmacv(&wfcanceragein,begy=2005);
%yrmacv(&hdpsychprobagein,begy=2005);
%yrmacv(&wfpsychprobagein,begy=2005);

%yrmacv(&hdworklimitin,begy=1972);
%yrmacv(&wfworklimitin,begy=1972);

/* Kessler 6 related variables */
%yrmacv(&respsadnessin,begy=2001);
%yrmacv(&respnervousin,begy=2001); 
%yrmacv(&resprestlessin,begy=2001); 
%yrmacv(&resphopelessin,begy=2001);
%yrmacv(&respeffortin,begy=2001); 
%yrmacv(&respworthlessin,begy=2001); 
%yrmacv(&respk6scalein,begy=2001); 

/* Alcohol-related variables */
%yrmacv(&hdalcoholin,begy=1999);
%yrmacv(&wfalcoholin,begy=1999);
%yrmacv(&hdalcdrinksin,begy=1999);
%yrmacv(&wfalcdrinksin,begy=1999);
%yrmacv(&hdalcfreqin,begy=2005);
%yrmacv(&wfalcfreqin,begy=2005);
%yrmacv(&hdalcbingein,begy=2005);
%yrmacv(&wfalcbingein,begy=2005);

/* State codes */
%yrmacv(&hdstatecodein,begy=1999); 
%yrmacv(&wfstatecodein,begy=1999); 

/* Life satisfaction */
%yrmacv(&hdsatisfactionin,begy=2009);
%yrmacv(&wfsatisfactionin,begy=2009);

/* Respondent */
%yrmacv(&hdrespondentin,begy=1999); 
%yrmacv(&wfrespondentin,begy=1999); 

/* Consumption variables - prior to 2015 these are on a separate file */
%yrmacv(&hdhousin,begy=2015);
%yrmacv(&hdfoodin,begy=2015);
%yrmacv(&hdtranin,begy=2015);
%yrmacv(&hdhealthin,begy=2015);
%yrmacv(&hdtripsin,begy=2015);
%yrmacv(&hdedin,begy=2015);
%yrmacv(&hdclothin,begy=2015);
%yrmacv(&hdothrecin,begy=2015);
%yrmacv(&hdchildin,begy=2015);
%yrmacv(&wfhousin,begy=2015);
%yrmacv(&wffoodin,begy=2015);
%yrmacv(&wftranin,begy=2015);
%yrmacv(&wfhealthin,begy=2015);
%yrmacv(&wftripsin,begy=2015);
%yrmacv(&wfedin,begy=2015);
%yrmacv(&wfclothin,begy=2015);
%yrmacv(&wfothrecin,begy=2015);
%yrmacv(&wfchildin,begy=2015);



/* this macro will list the vars[yy] macro variables */
%macro chkvars(begy,endy);
   %do year=&begy %to &endy;
       %let yr=%substr(&year,3);
       %if (&year ge 1968 and &year le 1997) or
           (&year>1997 and %index(13579,%substr(&year,4,1))>0) 
           %then %put vars&yr = &&vars&yr;
   %end;
%mend chkvars;

/* Display the vars[yy] macro variables */
%chkvars(&minyr,&maxyr);

/* make macro variables to list raw variables across all years */

/*** individual file ***/
%let famnum=%selectv(%quote(&famnumin),begy=1968,endy=1968);
%let famnum=&famnum %selectv(%quote(&famnumin),begy=1969);
%let seq=%selectv(%quote(&seqin),begy=1968,endy=1968);
%let seq=&seq %selectv(%quote(&seqin),begy=1969);
%let famfid=%selectv(%quote(&famfidin),begy=1969);
%let relhd=%selectv(%quote(&relhdin),begy=1969);
%let age=%selectv(%quote(&agein),begy=1999);
%let rabmonth=%selectv(%quote(&rabmonthin),begy=1999);
%let rabyear=%selectv(%quote(&rabyearin),begy=1999);
%let educ=%selectv(%quote(&educin),begy=1999);

/* reduc is not on the 2011 file */
%let reduc=%selectv(%quote(&reducin),begy=1999,endy=2009);
%let lastat=%selectv(%quote(&lastatin),begy=1999);

%let crswght=%selectv(%quote(&crswghtin),begy=1999);

%let resp=%selectv(%quote(&respin),begy=1999);


/*** family file variables ***/
%let hdrace=%selectv(%quote(&hdracein),begy=1999);
%let wfrace=%selectv(%quote(&wfracein),begy=1999);
%let hdhispan=%selectv(%quote(&hdhispanin),begy=1999);
%let wfhispan=%selectv(%quote(&wfhispanin),begy=1999);
%let hdmarr=%selectv(%quote(&hdmarrin),begy=1999);
%let hdmarrgen=%selectv(%quote(&hdmarrgen),begy=1999);
%let hdmarrch=%selectv(%quote(&hdmarrch),begy=1999);																									/* add marriage change variable */
%let hdshlth=%selectv(%quote(&hdshlthin),begy=1999);
%let wfshlth=%selectv(%quote(&wfshlthin),begy=1999);


%let hdcancr=%selectv(%quote(&hdcancrin),begy=1999);
%let wfcancr=%selectv(%quote(&wfcancrin),begy=1999);
%let hddiab=%selectv(%quote(&hddiabin),begy=1999);
%let wfdiab=%selectv(%quote(&wfdiabin),begy=1999);
%let hdheart=%selectv(%quote(&hdheartin),begy=1999);
%let wfheart=%selectv(%quote(&wfheartin),begy=1999);
%let hdhearta=%selectv(%quote(&hdheartain),begy=1999);																								/* add heart attack variables */
%let wfhearta=%selectv(%quote(&wfheartain),begy=1999);																								/* add heart attack variables */
%let hdhibp=%selectv(%quote(&hdhibpin),begy=1999);
%let wfhibp=%selectv(%quote(&wfhibpin),begy=1999);
%let hdlung=%selectv(%quote(&hdlungin),begy=1999);
%let wflung=%selectv(%quote(&wflungin),begy=1999);
%let hdstrok=%selectv(%quote(&hdstrokin),begy=1999);
%let wfstrok=%selectv(%quote(&wfstrokin),begy=1999);

%let hdasthm=%selectv(%quote(&hdasthmin),begy=1999);
%let wfasthm=%selectv(%quote(&wfasthmin),begy=1999);



%let hdcancrloc1=%selectv(%quote(&hdcancrloc1in),begy=2005);
%let hdcancrloc2=%selectv(%quote(&hdcancrloc2in),begy=2005);
%let wfcancrloc1=%selectv(%quote(&wfcancrloc1in),begy=2005);
%let wfcancrloc2=%selectv(%quote(&wfcancrloc2in),begy=2005);
                 								
%let hdcancrlimit=%selectv(%quote(&hdcancrlimitin),begy=1999);
%let wfcancrlimit=%selectv(%quote(&wfcancrlimitin),begy=1999);
%let hddiablimit=%selectv(%quote(&hddiablimitin),begy=1999);
%let wfdiablimit=%selectv(%quote(&wfdiablimitin),begy=1999);
%let hdheartlimit=%selectv(%quote(&hdheartlimitin),begy=1999);
%let wfheartlimit=%selectv(%quote(&wfheartlimitin),begy=1999);
%let hdhibplimit=%selectv(%quote(&hdhibplimitin),begy=1999);
%let wfhibplimit=%selectv(%quote(&wfhibplimitin),begy=1999);
%let hdlunglimit=%selectv(%quote(&hdlunglimitin),begy=1999);
%let wflunglimit=%selectv(%quote(&wflunglimitin),begy=1999);
%let hdheartalimit=%selectv(%quote(&hdheartalimitin),begy=1999);
%let wfheartalimit=%selectv(%quote(&wfheartalimitin),begy=1999);
%let hdstroklimit=%selectv(%quote(&hdstroklimitin),begy=1999);
%let wfstroklimit=%selectv(%quote(&wfstroklimitin),begy=1999);


/* Smoking-related variables */
%let hdsmoken=%selectv(%quote(&hdsmokenin),begy=1999);
%let wfsmoken=%selectv(%quote(&wfsmokenin),begy=1999);
%let hdsmokev=%selectv(%quote(&hdsmokevin),begy=1999);
%let wfsmokev=%selectv(%quote(&wfsmokevin),begy=1999);

%let hdnumcigsn=%selectv(%quote(&hdnumcigsnin),begy=1999);
%let hdnumcigse=%selectv(%quote(&hdnumcigsein),begy=1999);
%let hdsmokestartn=%selectv(%quote(&hdsmokestartnin),begy=1999);
%let hdsmokestarte=%selectv(%quote(&hdsmokestartein),begy=1999);
%let hdsmokestop=%selectv(%quote(&hdsmokestopin),begy=1999);
%let wfnumcigsn=%selectv(%quote(&wfnumcigsnin),begy=1999);
%let wfnumcigse=%selectv(%quote(&wfnumcigsein),begy=1999);
%let wfsmokestartn=%selectv(%quote(&wfsmokestartnin),begy=1999);
%let wfsmokestarte=%selectv(%quote(&wfsmokestartein),begy=1999);
%let wfsmokestop=%selectv(%quote(&wfsmokestopin),begy=1999);


%let hdwght=%selectv(%quote(&hdwghtin),begy=1999);
%let wfwght=%selectv(%quote(&wfwghtin),begy=1999);
%let hdheightft=%selectv(%quote(&hdheightftin),begy=1999);
%let wfheightft=%selectv(%quote(&wfheightftin),begy=1999);
%let hdheightin=%selectv(%quote(&hdheightinin),begy=1999);
%let wfheightin=%selectv(%quote(&wfheightinin),begy=1999);

%let hdiwmonth=%selectv(%quote(&hdiwmonthin),begy=1999);
%let wfiwmonth=%selectv(%quote(&wfiwmonthin),begy=1999);
%let hdiwday=%selectv(%quote(&hdiwdayin),begy=1999);
%let wfiwday=%selectv(%quote(&wfiwdayin),begy=1999);
%let hdiwyear=%selectv(%quote(&hdiwyearin),begy=1999);
%let wfiwyear=%selectv(%quote(&wfiwyearin),begy=1999);


%let hdbath=%selectv(%quote(&hdbathin),begy=1999);
%let wfbath=%selectv(%quote(&wfbathin),begy=1999);
%let hdeat=%selectv(%quote(&hdeatin),begy=1999);
%let wfeat=%selectv(%quote(&wfeatin),begy=1999);
%let hddress=%selectv(%quote(&hddressin),begy=1999);
%let wfdress=%selectv(%quote(&wfdressin),begy=1999);
%let hdwalk=%selectv(%quote(&hdwalkin),begy=1999);
%let wfwalk=%selectv(%quote(&wfwalkin),begy=1999);
%let hdbed=%selectv(%quote(&hdbedin),begy=1999);
%let wfbed=%selectv(%quote(&wfbedin),begy=1999);
%let hdtoilet=%selectv(%quote(&hdtoiletin),begy=1999);
%let wftoilet=%selectv(%quote(&wftoiletin),begy=1999);
%let hdbathhelp=%selectv(%quote(&hdbathhelpin),begy=1999);
%let wfbathhelp=%selectv(%quote(&wfbathhelpin),begy=1999);
%let hdeathelp=%selectv(%quote(&hdeathelpin),begy=1999);
%let wfeathelp=%selectv(%quote(&wfeathelpin),begy=1999);
%let hddresshelp=%selectv(%quote(&hddresshelpin),begy=1999);
%let wfdresshelp=%selectv(%quote(&wfdresshelpin),begy=1999);
%let hdwalkhelp=%selectv(%quote(&hdwalkhelpin),begy=1999);
%let wfwalkhelp=%selectv(%quote(&wfwalkhelpin),begy=1999);
%let hdbedhelp=%selectv(%quote(&hdbedhelpin),begy=1999);
%let wfbedhelp=%selectv(%quote(&wfbedhelpin),begy=1999);
%let hdtoilethelp=%selectv(%quote(&hdtoilethelpin),begy=1999);
%let wftoilethelp=%selectv(%quote(&wftoilethelpin),begy=1999);


%let hdmeals=%selectv(%quote(&hdmealsin),begy=2003);            
%let hdshop=%selectv(%quote(&hdshopin),begy=2003);             
%let hdmoney=%selectv(%quote(&hdmoneyin),begy=2003);            
%let hdphone=%selectv(%quote(&hdphonein),begy=2003);            
%let hdhvyhswrk=%selectv(%quote(&hdhvyhswrkin),begy=2003);         
%let hdlthswrk=%selectv(%quote(&hdlthswrkin),begy=2003);          
%let wfmeals=%selectv(%quote(&wfmealsin),begy=2003);            
%let wfshop=%selectv(%quote(&wfshopin),begy=2003);             
%let wfmoney=%selectv(%quote(&wfmoneyin),begy=2003);            
%let wfphone=%selectv(%quote(&wfphonein),begy=2003);            
%let wfhvyhswrk=%selectv(%quote(&wfhvyhswrkin),begy=2003);         
%let wflthswrk=%selectv(%quote(&wflthswrkin),begy=2003);          
%let hdmealstp=%selectv(%quote(&hdmealstpin),begy=2003);          
%let hdshoptp=%selectv(%quote(&hdshoptpin),begy=2003);           
%let hdmoneytp=%selectv(%quote(&hdmoneytpin),begy=2003);          
%let hdphonetp=%selectv(%quote(&hdphonetpin),begy=2003);          
%let hdhvyhswrktp=%selectv(%quote(&hdhvyhswrktpin),begy=2003);       
%let hdlthswrktp=%selectv(%quote(&hdlthswrktpin),begy=2003);        
%let wfmealstp=%selectv(%quote(&wfmealstpin),begy=2003);          
%let wfshoptp=%selectv(%quote(&wfshoptpin),begy=2003);           
%let wfmoneytp=%selectv(%quote(&wfmoneytpin),begy=2003);          
%let wfphonetp=%selectv(%quote(&wfphonetpin),begy=2003);          
%let wfhvyhswrktp=%selectv(%quote(&wfhvyhswrktpin),begy=2003);       
%let wflthswrktp=%selectv(%quote(&wflthswrktpin),begy=2003);      

%let hdelderhome=%selectv(%quote(&elderhomein),begy=1999);
%let hdeldertype=%selectv(%quote(&eldertypein),begy=1999);
%let wfelderhome=%selectv(%quote(&elderhomein),begy=1999);
%let wfeldertype=%selectv(%quote(&eldertypein),begy=1999);

%let hdregion=%selectv(%quote(&regionin),begy=1999);  
%let wfregion=%selectv(%quote(&regionin),begy=1999);                

%let hdeducalt=%selectv(%quote(&hdeducaltin),begy=1999);
%let wfeducalt=%selectv(%quote(&wfeducaltin),begy=1999);       

%let hdparpoor=%selectv(%quote(&hdparpoorin),begy=1969);
%let wfparpoor=%selectv(%quote(&wfparpoorin),begy=1969);   

%let hdchldhlth=%selectv(%quote(&hdchldhlthin),begy=2007);
%let wfchldhlth=%selectv(%quote(&wfchldhlthin),begy=2007);   

%let hdgrewup=%selectv(%quote(&hdgrewupin),begy=1999);
%let wfgrewup=%selectv(%quote(&wfgrewupin),begy=2009);   

%let hdlgtexcfreq=%selectv(%quote(&hdlgtexcfreqin),begy=1999);     
%let wflgtexcfreq=%selectv(%quote(&wflgtexcfreqin),begy=1999);     
%let hdlgtexcunit=%selectv(%quote(&hdlgtexcunitin),begy=1999);     
%let wflgtexcunit=%selectv(%quote(&wflgtexcunitin),begy=1999);     
%let hdhvyexcfreq=%selectv(%quote(&hdhvyexcfreqin),begy=1999);     
%let wfhvyexcfreq=%selectv(%quote(&wfhvyexcfreqin),begy=1999);     
%let hdhvyexcunit=%selectv(%quote(&hdhvyexcunitin),begy=1999);     
%let wfhvyexcunit=%selectv(%quote(&wfhvyexcunitin),begy=1999);     
%let hdmusclefreq=%selectv(%quote(&hdmusclefreqin),begy=2005);     
%let hdmuscleunit=%selectv(%quote(&hdmuscleunitin),begy=2005);     
%let wfmusclefreq=%selectv(%quote(&wfmusclefreqin),begy=2005);     
%let wfmuscleunit=%selectv(%quote(&wfmuscleunitin),begy=2005);     

%let hdeatoutfs=%selectv(%quote(&eatoutfsin),begy=1999);
%let hdeatoutfsunit=%selectv(%quote(&eatoutfsunitin),begy=1999);
%let hdeatout=%selectv(%quote(&eatoutin),begy=1999);
%let hdeatoutunit=%selectv(%quote(&eatoutunitin),begy=1999);
%let wfeatoutfs=%selectv(%quote(&eatoutfsin),begy=1999);
%let wfeatoutfsunit=%selectv(%quote(&eatoutfsunitin),begy=1999);
%let wfeatout=%selectv(%quote(&eatoutin),begy=1999);
%let wfeatoutunit=%selectv(%quote(&eatoutunitin),begy=1999);

%let hdnuminfu=%selectv(%quote(&numinfuin),begy=1999);
%let wfnuminfu=%selectv(%quote(&numinfuin),begy=1999);

%let hproptax=%selectv(%quote(&hproptaxin),begy=1999);

%let hdworkweeks=%selectv(%quote(&hdworkweeksin),begy=1999);
%let wfworkweeks=%selectv(%quote(&wfworkweeksin),begy=1999);
%let hdweekworkhr=%selectv(%quote(&hdweekworkhrin),begy=1999);
%let wfweekworkhr=%selectv(%quote(&wfweekworkhrin),begy=1999);
%let hdovertimehr=%selectv(%quote(&hdovertimehrin),begy=1999);
%let wfovertimehr=%selectv(%quote(&wfovertimehrin),begy=1999);
%let hdyrworkhr=%selectv(%quote(&hdyrworkhrin),begy=1999);
%let wfyrworkhr=%selectv(%quote(&wfyrworkhrin),begy=1999);

%let hdchldsrh=%selectv(%quote(&hdchldsrhin),begy=2007);
%let wfchldsrh=%selectv(%quote(&wfchldsrhin),begy=2007);
%let hdchldmissschool=%selectv(%quote(&hdchldmissschoolin),begy=2007);
%let wfchldmissschool=%selectv(%quote(&wfchldmissschoolin),begy=2007);
%let hdchldmeasles=%selectv(%quote(&hdchldmeaslesin),begy=2007);
%let wfchldmeasles=%selectv(%quote(&wfchldmeaslesin),begy=2007);
%let hdchldmumps=%selectv(%quote(&hdchldmumpsin),begy=2007);
%let wfchldmumps=%selectv(%quote(&wfchldmumpsin),begy=2007);
%let hdchldcknpox=%selectv(%quote(&hdchldcknpoxin),begy=2007);
%let wfchldcknpox=%selectv(%quote(&wfchldcknpoxin),begy=2007);
%let hdchldvision=%selectv(%quote(&hdchldvisionin),begy=2007);
%let wfchldvision=%selectv(%quote(&wfchldvisionin),begy=2007);
%let hdchldparsmk=%selectv(%quote(&hdchldparsmkin),begy=2007);
%let wfchldparsmk=%selectv(%quote(&wfchldparsmkin),begy=2007);
%let hdchldasthma=%selectv(%quote(&hdchldasthmain),begy=2007);
%let wfchldasthma=%selectv(%quote(&wfchldasthmain),begy=2007);
%let hdchlddiab=%selectv(%quote(&hdchlddiabin),begy=2007);
%let wfchlddiab=%selectv(%quote(&wfchlddiabin),begy=2007);
%let hdchldresp=%selectv(%quote(&hdchldrespin),begy=2007);
%let wfchldresp=%selectv(%quote(&wfchldrespin),begy=2007);
%let hdchldspeech=%selectv(%quote(&hdchldspeechin),begy=2007);
%let wfchldspeech=%selectv(%quote(&wfchldspeechin),begy=2007);
%let hdchldallergy=%selectv(%quote(&hdchldallergyin),begy=2007);
%let wfchldallergy=%selectv(%quote(&wfchldallergyin),begy=2007);
%let hdchldheart=%selectv(%quote(&hdchldheartin),begy=2007);
%let wfchldheart=%selectv(%quote(&wfchldheartin),begy=2007);
%let hdchldear=%selectv(%quote(&hdchldearin),begy=2007);
%let wfchldear=%selectv(%quote(&wfchldearin),begy=2007);
%let hdchldszre=%selectv(%quote(&hdchldszrein),begy=2007);
%let wfchldszre=%selectv(%quote(&wfchldszrein),begy=2007);
%let hdchldmgrn=%selectv(%quote(&hdchldmgrnin),begy=2007);
%let wfchldmgrn=%selectv(%quote(&wfchldmgrnin),begy=2007);
%let hdchldstomach=%selectv(%quote(&hdchldstomachin),begy=2007);
%let wfchldstomach=%selectv(%quote(&wfchldstomachin),begy=2007);
%let hdchldhibp=%selectv(%quote(&hdchldhibpin),begy=2007);
%let wfchldhibp=%selectv(%quote(&wfchldhibpin),begy=2007);
%let hdchlddepress=%selectv(%quote(&hdchlddepressin),begy=2007);
%let wfchlddepress=%selectv(%quote(&wfchlddepressin),begy=2007);
%let hdchlddrug=%selectv(%quote(&hdchlddrugin),begy=2007);
%let wfchlddrug=%selectv(%quote(&wfchlddrugin),begy=2007);
%let hdchldpsych=%selectv(%quote(&hdchldpsychin),begy=2007);
%let wfchldpsych=%selectv(%quote(&wfchldpsychin),begy=2007);


%let hdstrokedays=%selectv(%quote(&hdstrokedaysin),begy=1999,endy=2003);
%let hdstrokemnth=%selectv(%quote(&hdstrokemnthin),begy=1999,endy=2003);
%let hdstrokeweek=%selectv(%quote(&hdstrokeweekin),begy=1999,endy=2003);
%let hdstrokeyear=%selectv(%quote(&hdstrokeyearin),begy=1999,endy=2003);
%let wfstrokedays=%selectv(%quote(&wfstrokedaysin),begy=1999,endy=2003);
%let wfstrokemnth=%selectv(%quote(&wfstrokemnthin),begy=1999,endy=2003);
%let wfstrokeweek=%selectv(%quote(&wfstrokeweekin),begy=1999,endy=2003);
%let wfstrokeyear=%selectv(%quote(&wfstrokeyearin),begy=1999,endy=2003);
%let hdhibpdays=%selectv(%quote(&hdhibpdaysin),begy=1999,endy=2003);
%let hdhibpmnth=%selectv(%quote(&hdhibpmnthin),begy=1999,endy=2003);
%let hdhibpweek=%selectv(%quote(&hdhibpweekin),begy=1999,endy=2003);
%let hdhibpyear=%selectv(%quote(&hdhibpyearin),begy=1999,endy=2003);
%let wfhibpdays=%selectv(%quote(&wfhibpdaysin),begy=1999,endy=2003);
%let wfhibpmnth=%selectv(%quote(&wfhibpmnthin),begy=1999,endy=2003);
%let wfhibpweek=%selectv(%quote(&wfhibpweekin),begy=1999,endy=2003);
%let wfhibpyear=%selectv(%quote(&wfhibpyearin),begy=1999,endy=2003);
%let hddiabdays=%selectv(%quote(&hddiabdaysin),begy=1999,endy=2003);
%let hddiabmnth=%selectv(%quote(&hddiabmnthin),begy=1999,endy=2003);
%let hddiabweek=%selectv(%quote(&hddiabweekin),begy=1999,endy=2003);
%let hddiabyear=%selectv(%quote(&hddiabyearin),begy=1999,endy=2003);
%let wfdiabdays=%selectv(%quote(&wfdiabdaysin),begy=1999,endy=2003);
%let wfdiabmnth=%selectv(%quote(&wfdiabmnthin),begy=1999,endy=2003);
%let wfdiabweek=%selectv(%quote(&wfdiabweekin),begy=1999,endy=2003);
%let wfdiabyear=%selectv(%quote(&wfdiabyearin),begy=1999,endy=2003);
%let hdcancrdays=%selectv(%quote(&hdcancrdaysin),begy=1999,endy=2003);
%let hdcancrmnth=%selectv(%quote(&hdcancrmnthin),begy=1999,endy=2003);
%let hdcancrweek=%selectv(%quote(&hdcancrweekin),begy=1999,endy=2003);
%let hdcancryear=%selectv(%quote(&hdcancryearin),begy=1999,endy=2003);
%let wfcancrdays=%selectv(%quote(&wfcancrdaysin),begy=1999,endy=2003);
%let wfcancrmnth=%selectv(%quote(&wfcancrmnthin),begy=1999,endy=2003);
%let wfcancrweek=%selectv(%quote(&wfcancrweekin),begy=1999,endy=2003);
%let wfcancryear=%selectv(%quote(&wfcancryearin),begy=1999,endy=2003);
%let hdlungdays=%selectv(%quote(&hdlungdaysin),begy=1999,endy=2003);
%let hdlungmnth=%selectv(%quote(&hdlungmnthin),begy=1999,endy=2003);
%let hdlungweek=%selectv(%quote(&hdlungweekin),begy=1999,endy=2003);
%let hdlungyear=%selectv(%quote(&hdlungyearin),begy=1999,endy=2003);
%let wflungdays=%selectv(%quote(&wflungdaysin),begy=1999,endy=2003);
%let wflungmnth=%selectv(%quote(&wflungmnthin),begy=1999,endy=2003);
%let wflungweek=%selectv(%quote(&wflungweekin),begy=1999,endy=2003);
%let wflungyear=%selectv(%quote(&wflungyearin),begy=1999,endy=2003);
%let hdheartattackdays=%selectv(%quote(&hdheartattackdaysin),begy=1999,endy=2003);
%let hdheartattackmnth=%selectv(%quote(&hdheartattackmnthin),begy=1999,endy=2003);
%let hdheartattackweek=%selectv(%quote(&hdheartattackweekin),begy=1999,endy=2003);
%let hdheartattackyear=%selectv(%quote(&hdheartattackyearin),begy=1999,endy=2003);
%let wfheartattackdays=%selectv(%quote(&wfheartattackdaysin),begy=1999,endy=2003);
%let wfheartattackmnth=%selectv(%quote(&wfheartattackmnthin),begy=1999,endy=2003);
%let wfheartattackweek=%selectv(%quote(&wfheartattackweekin),begy=1999,endy=2003);
%let wfheartattackyear=%selectv(%quote(&wfheartattackyearin),begy=1999,endy=2003);
%let hdheartdiseasedays=%selectv(%quote(&hdheartdiseasedaysin),begy=1999,endy=2003);
%let hdheartdiseasemnth=%selectv(%quote(&hdheartdiseasemnthin),begy=1999,endy=2003);
%let hdheartdiseaseweek=%selectv(%quote(&hdheartdiseaseweekin),begy=1999,endy=2003);
%let hdheartdiseaseyear=%selectv(%quote(&hdheartdiseaseyearin),begy=1999,endy=2003);
%let wfheartdiseasedays=%selectv(%quote(&wfheartdiseasedaysin),begy=1999,endy=2003);
%let wfheartdiseasemnth=%selectv(%quote(&wfheartdiseasemnthin),begy=1999,endy=2003);
%let wfheartdiseaseweek=%selectv(%quote(&wfheartdiseaseweekin),begy=1999,endy=2003);
%let wfheartdiseaseyear=%selectv(%quote(&wfheartdiseaseyearin),begy=1999,endy=2003);
%let hdpsychprobdays=%selectv(%quote(&hdpsychprobdaysin),begy=1999,endy=2003);
%let hdpsychprobmnth=%selectv(%quote(&hdpsychprobmnthin),begy=1999,endy=2003);
%let hdpsychprobweek=%selectv(%quote(&hdpsychprobweekin),begy=1999,endy=2003);
%let hdpsychprobyear=%selectv(%quote(&hdpsychprobyearin),begy=1999,endy=2003);
%let wfpsychprobdays=%selectv(%quote(&wfpsychprobdaysin),begy=1999,endy=2003);
%let wfpsychprobmnth=%selectv(%quote(&wfpsychprobmnthin),begy=1999,endy=2003);
%let wfpsychprobweek=%selectv(%quote(&wfpsychprobweekin),begy=1999,endy=2003);
%let wfpsychprobyear=%selectv(%quote(&wfpsychprobyearin),begy=1999,endy=2003);
%let hdarthritisdays=%selectv(%quote(&hdarthritisdaysin),begy=1999,endy=2003);
%let hdarthritismnth=%selectv(%quote(&hdarthritismnthin),begy=1999,endy=2003);
%let hdarthritisweek=%selectv(%quote(&hdarthritisweekin),begy=1999,endy=2003);
%let hdarthritisyear=%selectv(%quote(&hdarthritisyearin),begy=1999,endy=2003);
%let wfarthritisdays=%selectv(%quote(&wfarthritisdaysin),begy=1999,endy=2003);
%let wfarthritismnth=%selectv(%quote(&wfarthritismnthin),begy=1999,endy=2003);
%let wfarthritisweek=%selectv(%quote(&wfarthritisweekin),begy=1999,endy=2003);
%let wfarthritisyear=%selectv(%quote(&wfarthritisyearin),begy=1999,endy=2003);
%let hdasthmadays=%selectv(%quote(&hdasthmadaysin),begy=1999,endy=2003);
%let hdasthmamnth=%selectv(%quote(&hdasthmamnthin),begy=1999,endy=2003);
%let hdasthmaweek=%selectv(%quote(&hdasthmaweekin),begy=1999,endy=2003);
%let hdasthmayear=%selectv(%quote(&hdasthmayearin),begy=1999,endy=2003);
%let wfasthmadays=%selectv(%quote(&wfasthmadaysin),begy=1999,endy=2003);
%let wfasthmamnth=%selectv(%quote(&wfasthmamnthin),begy=1999,endy=2003);
%let wfasthmaweek=%selectv(%quote(&wfasthmaweekin),begy=1999,endy=2003);
%let wfasthmayear=%selectv(%quote(&wfasthmayearin),begy=1999,endy=2003);
%let hdmemorylossdays=%selectv(%quote(&hdmemorylossdaysin),begy=1999,endy=2003);
%let hdmemorylossmnth=%selectv(%quote(&hdmemorylossmnthin),begy=1999,endy=2003);
%let hdmemorylossweek=%selectv(%quote(&hdmemorylossweekin),begy=1999,endy=2003);
%let hdmemorylossyear=%selectv(%quote(&hdmemorylossyearin),begy=1999,endy=2003);
%let wfmemorylossdays=%selectv(%quote(&wfmemorylossdaysin),begy=1999,endy=2003);
%let wfmemorylossmnth=%selectv(%quote(&wfmemorylossmnthin),begy=1999,endy=2003);
%let wfmemorylossweek=%selectv(%quote(&wfmemorylossweekin),begy=1999,endy=2003);
%let wfmemorylossyear=%selectv(%quote(&wfmemorylossyearin),begy=1999,endy=2003);
%let hdlearningdisorderdays=%selectv(%quote(&hdlearningdisorderdaysin),begy=1999,endy=2003);
%let hdlearningdisordermnth=%selectv(%quote(&hdlearningdisordermnthin),begy=1999,endy=2003);
%let hdlearningdisorderweek=%selectv(%quote(&hdlearningdisorderweekin),begy=1999,endy=2003);
%let hdlearningdisorderyear=%selectv(%quote(&hdlearningdisorderyearin),begy=1999,endy=2003);
%let wflearningdisorderdays=%selectv(%quote(&wflearningdisorderdaysin),begy=1999,endy=2003);
%let wflearningdisordermnth=%selectv(%quote(&wflearningdisordermnthin),begy=1999,endy=2003);
%let wflearningdisorderweek=%selectv(%quote(&wflearningdisorderweekin),begy=1999,endy=2003);
%let wflearningdisorderyear=%selectv(%quote(&wflearningdisorderyearin),begy=1999,endy=2003);


%let hdstrokeage=%selectv(%quote(&hdstrokeagein),begy=2005);          
%let wfstrokeage=%selectv(%quote(&wfstrokeagein),begy=2005);          
%let hdheartattackage=%selectv(%quote(&hdheartattackagein),begy=2005);     
%let wfheartattackage=%selectv(%quote(&wfheartattackagein),begy=2005);     
%let hdheartdiseaseage=%selectv(%quote(&hdheartdiseaseagein),begy=2005);    
%let wfheartdiseaseage=%selectv(%quote(&wfheartdiseaseagein),begy=2005);    
%let hdhypertensionage=%selectv(%quote(&hdhypertensionagein),begy=2005);    
%let wfhypertensionage=%selectv(%quote(&wfhypertensionagein),begy=2005);    
%let hdasthmaage=%selectv(%quote(&hdasthmaagein),begy=2005);          
%let wfasthmaage=%selectv(%quote(&wfasthmaagein),begy=2005);          
%let hdlungdiseaseage=%selectv(%quote(&hdlungdiseaseagein),begy=2005);     
%let wflungdiseaseage=%selectv(%quote(&wflungdiseaseagein),begy=2005);     
%let hddiabetesage=%selectv(%quote(&hddiabetesagein),begy=2005);        
%let wfdiabetesage=%selectv(%quote(&wfdiabetesagein),begy=2005);        
%let hdarthritisage=%selectv(%quote(&hdarthritisagein),begy=2005);       
%let wfarthritisage=%selectv(%quote(&wfarthritisagein),begy=2005);       
%let hdmemorylossage=%selectv(%quote(&hdmemorylossagein),begy=2005);      
%let wfmemorylossage=%selectv(%quote(&wfmemorylossagein),begy=2005);      
%let hdlearningdisorderage=%selectv(%quote(&hdlearningdisorderagein),begy=2005);
%let wflearningdisorderage=%selectv(%quote(&wflearningdisorderagein),begy=2005);
%let hdcancerage=%selectv(%quote(&hdcanceragein),begy=2005);          
%let wfcancerage=%selectv(%quote(&wfcanceragein),begy=2005);          
%let hdpsychprobage=%selectv(%quote(&hdpsychprobagein),begy=2005);       
%let wfpsychprobage=%selectv(%quote(&wfpsychprobagein),begy=2005);       

%let hdworklimit=%selectv(%quote(&hdworklimitin),begy=1999);
%let wfworklimit=%selectv(%quote(&wfworklimitin),begy=1999);


/* Populate Kessler 6 variables */
%let respsadness=%selectv(%quote(&respsadnessin),begy=2001);
%let respnervous=%selectv(%quote(&respnervousin),begy=2001); 
%let resprestless=%selectv(%quote(&resprestlessin),begy=2001); 
%let resphopeless=%selectv(%quote(&resphopelessin),begy=2001);
%let respeffort=%selectv(%quote(&respeffortin),begy=2001); 
%let respworthless=%selectv(%quote(&respworthlessin),begy=2001); 
%let respk6scale=%selectv(%quote(&respk6scalein),begy=2001); 

%let hdalcohol=%selectv(%quote(&hdalcoholin),begy=1999);
%let wfalcohol=%selectv(%quote(&wfalcoholin),begy=1999);
%let hdalcdrinks=%selectv(%quote(&hdalcdrinksin),begy=1999);
%let wfalcdrinks=%selectv(%quote(&wfalcdrinksin),begy=1999);
%let hdalcfreq=%selectv(%quote(&hdalcfreqin),begy=2005);
%let wfalcfreq=%selectv(%quote(&wfalcfreqin),begy=2005);
%let hdalcbinge=%selectv(%quote(&hdalcbingein),begy=2005);
%let wfalcbinge=%selectv(%quote(&wfalcbingein),begy=2005);

/* Populate State variables */
%let hdstatecode=%selectv(%quote(&hdstatecodein),begy=1999); 
%let wfstatecode=%selectv(%quote(&wfstatecodein),begy=1999); 

%let hdsatisfaction=%selectv(%quote(&hdsatisfactionin),begy=2009);
%let wfsatisfaction=%selectv(%quote(&wfsatisfactionin),begy=2009);

%let hdhous=%selectv(%quote(&hdhousin),begy=2015);
%let hdfood=%selectv(%quote(&hdfoodin),begy=2015);
%let hdtran=%selectv(%quote(&hdtranin),begy=2015);
%let hdhealth=%selectv(%quote(&hdhealthin),begy=2015);
%let hdtrips=%selectv(%quote(&hdtripsin),begy=2015);
%let hded=%selectv(%quote(&hdedin),begy=2015);
%let hdcloth=%selectv(%quote(&hdclothin),begy=2015);
%let hdothrec=%selectv(%quote(&hdothrecin),begy=2015);
%let hdchild=%selectv(%quote(&hdchildin),begy=2015);

%let wfhous=%selectv(%quote(&wfhousin),begy=2015);
%let wffood=%selectv(%quote(&wffoodin),begy=2015);
%let wftran=%selectv(%quote(&wftranin),begy=2015);
%let wfhealth=%selectv(%quote(&wfhealthin),begy=2015);
%let wftrips=%selectv(%quote(&wftripsin),begy=2015);
%let wfed=%selectv(%quote(&wfedin),begy=2015);
%let wfcloth=%selectv(%quote(&wfclothin),begy=2015);
%let wfothrec=%selectv(%quote(&wfothrecin),begy=2015);
%let wfchild=%selectv(%quote(&wfchildin),begy=2015);


/* Populate respondent variable */ 
%let hdrespondent=%selectv(%quote(&hdrespondentin),begy=1999); 
%let wfrespondent=%selectv(%quote(&wfrespondentin),begy=1999); 

/* the following uses the individual file to select the sample
   to match to when processing family files. 
   This is the place to pull needed variables from 
   the individual file, but further processing should
   be done in the data step that merges in the family file
   data, except for famnum, seq, and relhd. */

data ind;
   set psid.ind&maxyr.er  ( KEEP = &famnum &seq &relhd &age &rabmonth &rabyear &educ &reduc &lastat &crswght ER31996 ER31997 ER32000 ER32050 &resp
			     RENAME = ( %renyrv(age,&age,begy=1999) %renyrv(educyr,&educ,begy=1999,endy=2009) %renyrv(reduc,&reduc,begy=1999,endy=2009) 
			     %renyrv(lastat,&lastat,begy=1999) %renyrv(crswght,&crswght,begy=1999) ER31996=sestrat ER31997=seclust ER32000=sex ER32050=deathyr %renyrv(rabmonth,&rabmonth,begy=1999) 
			     %renyrv(rabyear,&rabyear,begy=1999) %renyrv(resp,&resp,begy=1999)  ) );
   
   array famnumin_[*] &famnum;
   array famnum_[*]   famnum68 %listyrv(famnum,begy=&minyr);
   array seqin_[*]    &seq;
   array seq_[*]      pn68 %listyrv(seq,begy=&minyr);
   array relhdin_[*]  _dum &relhd;
   array relhd_[*]    _dum %listyrv(relhd,begy=&minyr);

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
      Assumes vars[yy] macro vars have been set up (see yrmacv macro)
   */
   
   %famget(psid,ind1,begy=1969,famid=&famfid);

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

data proj.extract_data probs; /* change proj.tmp to desired output file name */
   merge %listyrv(fam,begy=1969)  /* this lists all the requested fam files */
         ind1 (in=_ini drop=dup)
	 ;  
   by id;

   inind=_ini;  /* flags cases found on individual file - should be all */
   if id=. then output probs;
   dupid=(first.id=0 or last.id=0);
   if dupid=1 then output probs;  /* dups */

   /* raw variables */
   array hdshlth_[*] _1969 - _1997 &hdshlth;
   array wfshlth_[*] _1969 - _1997 &wfshlth;
   array hdrace_[*] _1969 - _1997 &hdrace;
   array wfrace_[*] _1969 - _1997 &wfrace;
   array hdhispan_[*] _1969 - _1997 _1999 _2001 _2003 &hdhispan;
   array wfhispan_[*] _1969 - _1997 _1999 _2001 _2003 &wfhispan;
   array hdmarr_[*] _1969 - _1997 &hdmarr;   
   array hdmarrgen_[*] _1969 - _1997 &hdmarrgen;   
   array hdmarrch_[*] _1969 - _1997 &hdmarrch;																			/* add marriage change variable */

   array hdiwmonth_[*] _1969 - _1997 &hdiwmonth;
   array wfiwmonth_[*] _1969 - _1997 &wfiwmonth;
   array hdiwday_[*] _1969 - _1997 &hdiwday;
   array wfiwday_[*] _1969 - _1997 &wfiwday;
   array hdiwyear_[*] _1969 - _1997 &hdiwyear;
   array wfiwyear_[*] _1969 - _1997 &wfiwyear;

   array hdcancr_[*] _1969 - _1997 &hdcancr;
   array wfcancr_[*] _1969 - _1997 &wfcancr;
   array hddiab_[*] _1969 - _1997 &hddiab;
   array wfdiab_[*] _1969 - _1997 &wfdiab;
   array hdheart_[*] _1969 - _1997 &hdheart;
   array wfheart_[*] _1969 - _1997 &wfheart;   
   array hdhearta_[*] _1969 - _1997 &hdhearta;																			/* add heart attack variables */
   array wfhearta_[*] _1969 - _1997 &wfhearta;																			/* add heart attack variables */
   array hdhibp_[*] _1969 - _1997 &hdhibp;
   array wfhibp_[*] _1969 - _1997 &wfhibp;
   array hdlung_[*] _1969 - _1997 &hdlung;
   array wflung_[*] _1969 - _1997 &wflung;
   array hdstrok_[*] _1969 - _1997 &hdstrok;
   array wfstrok_[*] _1969 - _1997 &wfstrok;
   
   array hdasthm_[*] _1969 - _1997 &hdasthm;
   array wfasthm_[*] _1969 - _1997 &wfasthm;
     
   
	 array hdcancrloc1_[*] _1969 - _1997 _1999 _2001 _2003 &hdcancrloc1;  
	 array hdcancrloc2_[*] _1969 - _1997 _1999 _2001 _2003 &hdcancrloc2;  
	 array wfcancrloc1_[*] _1969 - _1997 _1999 _2001 _2003 &wfcancrloc1;  
	 array wfcancrloc2_[*] _1969 - _1997 _1999 _2001 _2003 &wfcancrloc2;  
	 array hdcancrlimit_[*] _1969 - _1997   &hdcancrlimit;            
	 array wfcancrlimit_[*] _1969 - _1997   &wfcancrlimit;                 
	 array hddiablimit_[*] _1969 - _1997    &hddiablimit;                  
	 array wfdiablimit_[*] _1969 - _1997    &wfdiablimit;                  
	 array hdheartlimit_[*] _1969 - _1997   &hdheartlimit;                 
	 array wfheartlimit_[*] _1969 - _1997   &wfheartlimit;                 
	 array hdhibplimit_[*] _1969 - _1997    &hdhibplimit;                  
	 array wfhibplimit_[*] _1969 - _1997    &wfhibplimit;                  
	 array hdlunglimit_[*] _1969 - _1997    &hdlunglimit;                  
	 array wflunglimit_[*] _1969 - _1997    &wflunglimit;                  
	 array hdheartalimit_[*] _1969 - _1997  &hdheartalimit;                
	 array wfheartalimit_[*] _1969 - _1997  &wfheartalimit;                
	 array hdstroklimit_[*] _1969 - _1997   &hdstroklimit;                 
	 array wfstroklimit_[*] _1969 - _1997   &wfstroklimit;                 
   
   array hdsmoken_[*] _1969 - _1997 &hdsmoken;
   array wfsmoken_[*] _1969 - _1997 &wfsmoken;
   array hdsmokev_[*] _1969 - _1997 &hdsmokev;
   array wfsmokev_[*] _1969 - _1997 &wfsmokev;
   
   array hdnumcigsn_[*] _1969 - _1997 &hdnumcigsn;      
   array hdnumcigse_[*] _1969 - _1997 &hdnumcigse;     
   array hdsmokestartn_[*] _1969 - _1997 &hdsmokestartn;
   array hdsmokestarte_[*] _1969 - _1997 &hdsmokestarte;
   array hdsmokestop_[*] _1969 - _1997 &hdsmokestop;
   array wfnumcigsn_[*] _1969 - _1997 &wfnumcigsn;
   array wfnumcigse_[*] _1969 - _1997 &wfnumcigse;
   array wfsmokestartn_[*] _1969 - _1997 &wfsmokestartn;
   array wfsmokestarte_[*] _1969 - _1997 &wfsmokestarte;
   array wfsmokestop_[*] _1969 - _1997 &wfsmokestop;
   
   
   array hdwght_[*] _1969 - _1997 &hdwght;
   array wfwght_[*] _1969 - _1997 &wfwght;
   array hdheightft_[*] _1969 - _1997 &hdheightft;
   array wfheightft_[*] _1969 - _1997 &wfheightft;
   array hdheightin_[*] _1969 - _1997 &hdheightin;
   array wfheightin_[*] _1969 - _1997 &wfheightin;
   
   /* ADL raw variable arrays */
   array hdbath_[*] _1969 - _1997 &hdbath;        
   array wfbath_[*] _1969 - _1997 &wfbath; 
   array hdeat_[*] _1969 - _1997 &hdeat;
   array wfeat_[*] _1969 - _1997 &wfeat; 
   array hddress_[*] _1969 - _1997 &hddress;       
   array wfdress_[*] _1969 - _1997 &wfdress;       
   array hdwalk_[*] _1969 - _1997 &hdwalk;        
   array wfwalk_[*] _1969 - _1997 &wfwalk;
   array hdbed_[*] _1969 - _1997 &hdbed; 
   array wfbed_[*] _1969 - _1997 &wfbed; 
   array hdtoilet_[*] _1969 - _1997 &hdtoilet;  
   array wftoilet_[*] _1969 - _1997 &wftoilet;      
   array hdbathhelp_[*] _1969 - _1997 &hdbathhelp;    
   array wfbathhelp_[*] _1969 - _1997 &wfbathhelp;    
   array hdeathelp_[*] _1969 - _1997 &hdeathelp;     
   array wfeathelp_[*] _1969 - _1997 &wfeathelp;     
   array hddresshelp_[*] _1969 - _1997 &hddresshelp;   
   array wfdresshelp_[*] _1969 - _1997 &wfdresshelp;   
   array hdwalkhelp_[*] _1969 - _1997 &hdwalkhelp;    
   array wfwalkhelp_[*] _1969 - _1997 &wfwalkhelp;    
   array hdbedhelp_[*] _1969 - _1997 &hdbedhelp;     
   array wfbedhelp_[*] _1969 - _1997 &wfbedhelp;     
   array hdtoilethelp_[*] _1969 - _1997 &hdtoilethelp;  
   array wftoilethelp_[*] _1969 - _1997 &wftoilethelp;  
   
   /* IADL raw variable arrays */
   array hdmeals_[*]  _1969 - _1997 _1999 _2001 &hdmeals;       
   array hdshop_[*]  _1969 - _1997 _1999 _2001 &hdshop;        
   array hdmoney_[*]  _1969 - _1997 _1999 _2001 &hdmoney; 
   array hdphone_[*]  _1969 - _1997 _1999 _2001 &hdphone;       
   array hdhvyhswrk_[*]  _1969 - _1997 _1999 _2001 &hdhvyhswrk;    
   array hdlthswrk_[*]  _1969 - _1997 _1999 _2001 &hdlthswrk;     
   array wfmeals_[*]  _1969 - _1997 _1999 _2001 &wfmeals;       
   array wfshop_[*]  _1969 - _1997 _1999 _2001 &wfshop;        
   array wfmoney_[*]  _1969 - _1997 _1999 _2001 &wfmoney;       
   array wfphone_[*]  _1969 - _1997 _1999 _2001 &wfphone;       
   array wfhvyhswrk_[*]  _1969 - _1997 _1999 _2001 &wfhvyhswrk;    
   array wflthswrk_[*]  _1969 - _1997 _1999 _2001 &wflthswrk;     
   array hdmealstp_[*]  _1969 - _1997 _1999 _2001 &hdmealstp;     
   array hdshoptp_[*]  _1969 - _1997 _1999 _2001 &hdshoptp;      
   array hdmoneytp_[*]  _1969 - _1997 _1999 _2001 &hdmoneytp;     
   array hdphonetp_[*]  _1969 - _1997 _1999 _2001 &hdphonetp;     
   array hdhvyhswrktp_[*]  _1969 - _1997 _1999 _2001 &hdhvyhswrktp;  
   array hdlthswrktp_[*]  _1969 - _1997 _1999 _2001 &hdlthswrktp;   
   array wfmealstp_[*]  _1969 - _1997 _1999 _2001 &wfmealstp;     
   array wfshoptp_[*]  _1969 - _1997 _1999 _2001 &wfshoptp;      
   array wfmoneytp_[*]  _1969 - _1997 _1999 _2001 &wfmoneytp;     
   array wfphonetp_[*]  _1969 - _1997 _1999 _2001 &wfphonetp;     
   array wfhvyhswrktp_[*]  _1969 - _1997 _1999 _2001 &wfhvyhswrktp;  
   array wflthswrktp_[*]  _1969 - _1997 _1999 _2001 &wflthswrktp; 
   
   array hdelderhome_[*] _1969 - _1997 &hdelderhome;
   array hdeldertype_[*] _1969 - _1997 &hdeldertype;
   array wfelderhome_[*] _1969 - _1997 &wfelderhome;
   array wfeldertype_[*] _1969 - _1997 &wfeldertype;
   
   array hdregion_[*] _1969 - _1997 &hdregion;
   array wfregion_[*] _1969 - _1997 &wfregion;
   
   array hdeducalt_[*] _1969 - _1997 &hdeducalt;
   array wfeducalt_[*] _1969 - _1997 &wfeducalt;   
   
   array hdparpoor_[*] &hdparpoor;
   array wfparpoor_[*] &wfparpoor;   
   
   array hdchldhlth_[*] _1969 - _1997 _1999 _2001 _2003 _2005 &hdchldhlth;
   array wfchldhlth_[*] _1969 - _1997 _1999 _2001 _2003 _2005 &wfchldhlth;
   
   array hdgrewup_[*] _1969 - _1997 _1999 _2001 _2003 _2005 _2007 &hdgrewup;
   array wfgrewup_[*] _1969 - _1997 _1999 _2001 _2003 _2005 _2007 &wfgrewup;
  
		array	hdlgtexcfreq_[*]	_1969 - _1997 &hdlgtexcfreq;
    array wflgtexcfreq_[*]	_1969 - _1997 &wflgtexcfreq;
    array hdlgtexcunit_[*]	_1969 - _1997 &hdlgtexcunit;
    array wflgtexcunit_[*]	_1969 - _1997 &wflgtexcunit;
    array hdhvyexcfreq_[*]	_1969 - _1997 &hdhvyexcfreq;
    array wfhvyexcfreq_[*]	_1969 - _1997 &wfhvyexcfreq;
    array hdhvyexcunit_[*]	_1969 - _1997 &hdhvyexcunit;
    array wfhvyexcunit_[*]	_1969 - _1997 &wfhvyexcunit;
    array hdmusclefreq_[*]	 _1969 - _1997 _1999 _2001 _2003 &hdmusclefreq;
    array hdmuscleunit_[*]	 _1969 - _1997 _1999 _2001 _2003 &hdmuscleunit;
    array wfmusclefreq_[*]	 _1969 - _1997 _1999 _2001 _2003 &wfmusclefreq;
    array wfmuscleunit_[*]	 _1969 - _1997 _1999 _2001 _2003 &wfmuscleunit;
    
    array hdeatoutfs_[*]			_1969 - _1997 &hdeatoutfs;
    array hdeatoutfsunit_[*]  _1969 - _1997 &hdeatoutfsunit; 
    array hdeatout_[*]        _1969 - _1997 &hdeatout;    
    array hdeatoutunit_[*]    _1969 - _1997 &hdeatoutunit;   
    array wfeatoutfs_[*]      _1969 - _1997 &wfeatoutfs;     
    array wfeatoutfsunit_[*]  _1969 - _1997 &wfeatoutfsunit; 
    array wfeatout_[*]        _1969 - _1997 &wfeatout;    
    array wfeatoutunit_[*]    _1969 - _1997 &wfeatoutunit;    
    array hdnuminfu_[*] _1969 - _1997 &hdnuminfu;
    array wfnuminfu_[*] _1969 - _1997 &wfnuminfu;
  	array hproptax_[*] _1969 - _1997 &hproptax;
  
  	  
		array hdworkweeks_[*] _1969 - _1997 &hdworkweeks;
		array hdweekworkhr_[*] _1969 - _1997 &hdweekworkhr;
		array hdovertimehr_[*] _1969 - _1997 &hdovertimehr;
		array hdyrworkhr_[*] _1969 - _1997 &hdyrworkhr;	
  
		array wfworkweeks_[*] _1969 - _1997 &wfworkweeks;
		array wfweekworkhr_[*] _1969 - _1997 &wfweekworkhr;
		array wfovertimehr_[*] _1969 - _1997 &wfovertimehr;
		array wfyrworkhr_[*] _1969 - _1997 &wfyrworkhr;
		
		array hdchldsrh_[*] _1969 - _1997 _1999 _2001 _2003 _2005 &hdchldsrh;         
		array wfchldsrh_[*] _1969 - _1997 _1999 _2001 _2003 _2005 &wfchldsrh;        
		array hdchldmissschool_[*] _1969 - _1997 _1999 _2001 _2003 _2005 &hdchldmissschool;  
		array wfchldmissschool_[*] _1969 - _1997 _1999 _2001 _2003 _2005 &wfchldmissschool;  
		array hdchldmeasles_[*] _1969 - _1997 _1999 _2001 _2003 _2005 &hdchldmeasles;     
		array wfchldmeasles_[*] _1969 - _1997 _1999 _2001 _2003 _2005 &wfchldmeasles;     
		array hdchldmumps_[*] _1969 - _1997 _1999 _2001 _2003 _2005 &hdchldmumps;       
		array wfchldmumps_[*] _1969 - _1997 _1999 _2001 _2003 _2005 &wfchldmumps;       
		array hdchldcknpox_[*] _1969 - _1997 _1999 _2001 _2003 _2005 &hdchldcknpox;      
		array wfchldcknpox_[*] _1969 - _1997 _1999 _2001 _2003 _2005 &wfchldcknpox;      
		array hdchldvision_[*] _1969 - _1997 _1999 _2001 _2003 _2005 &hdchldvision;      
		array wfchldvision_[*] _1969 - _1997 _1999 _2001 _2003 _2005 &wfchldvision;      
		array hdchldparsmk_[*] _1969 - _1997 _1999 _2001 _2003 _2005 &hdchldparsmk;      
		array wfchldparsmk_[*] _1969 - _1997 _1999 _2001 _2003 _2005 &wfchldparsmk;      
		array hdchldasthma_[*] _1969 - _1997 _1999 _2001 _2003 _2005 &hdchldasthma;      
		array wfchldasthma_[*] _1969 - _1997 _1999 _2001 _2003 _2005 &wfchldasthma;      
		array hdchlddiab_[*] _1969 - _1997 _1999 _2001 _2003 _2005 &hdchlddiab;        
		array wfchlddiab_[*] _1969 - _1997 _1999 _2001 _2003 _2005 &wfchlddiab;        
		array hdchldresp_[*] _1969 - _1997 _1999 _2001 _2003 _2005 &hdchldresp;        
		array wfchldresp_[*] _1969 - _1997 _1999 _2001 _2003 _2005 &wfchldresp;        
		array hdchldspeech_[*] _1969 - _1997 _1999 _2001 _2003 _2005 &hdchldspeech;      
		array wfchldspeech_[*] _1969 - _1997 _1999 _2001 _2003 _2005 &wfchldspeech;      
		array hdchldallergy_[*] _1969 - _1997 _1999 _2001 _2003 _2005 &hdchldallergy;     
		array wfchldallergy_[*] _1969 - _1997 _1999 _2001 _2003 _2005 &wfchldallergy;     
		array hdchldheart_[*] _1969 - _1997 _1999 _2001 _2003 _2005 &hdchldheart;       
		array wfchldheart_[*] _1969 - _1997 _1999 _2001 _2003 _2005 &wfchldheart;       
		array hdchldear_[*] _1969 - _1997 _1999 _2001 _2003 _2005 &hdchldear;         
		array wfchldear_[*] _1969 - _1997 _1999 _2001 _2003 _2005 &wfchldear;         
		array hdchldszre_[*] _1969 - _1997 _1999 _2001 _2003 _2005 &hdchldszre;        
		array wfchldszre_[*] _1969 - _1997 _1999 _2001 _2003 _2005 &wfchldszre;        
		array hdchldmgrn_[*] _1969 - _1997 _1999 _2001 _2003 _2005 &hdchldmgrn;        
		array wfchldmgrn_[*] _1969 - _1997 _1999 _2001 _2003 _2005 &wfchldmgrn;        
		array hdchldstomach_[*] _1969 - _1997 _1999 _2001 _2003 _2005 &hdchldstomach;     
		array wfchldstomach_[*] _1969 - _1997 _1999 _2001 _2003 _2005 &wfchldstomach;     
		array hdchldhibp_[*] _1969 - _1997 _1999 _2001 _2003 _2005 &hdchldhibp;        
		array wfchldhibp_[*] _1969 - _1997 _1999 _2001 _2003 _2005 &wfchldhibp;        
		array hdchlddepress_[*] _1969 - _1997 _1999 _2001 _2003 _2005 &hdchlddepress;     
		array wfchlddepress_[*] _1969 - _1997 _1999 _2001 _2003 _2005 &wfchlddepress;     
		array hdchlddrug_[*] _1969 - _1997 _1999 _2001 _2003 _2005 &hdchlddrug;        
		array wfchlddrug_[*] _1969 - _1997 _1999 _2001 _2003 _2005 &wfchlddrug;        
		array hdchldpsych_[*] _1969 - _1997 _1999 _2001 _2003 _2005 &hdchldpsych;       
		array wfchldpsych_[*] _1969 - _1997 _1999 _2001 _2003 _2005 &wfchldpsych;       

		array hdstrokeage_[*] _1969 - _1997 _1999 _2001 _2003             &hdstrokeage;
		array wfstrokeage_[*] _1969 - _1997 _1999 _2001 _2003             &wfstrokeage;
		array hdheartattackage_[*] _1969 - _1997 _1999 _2001 _2003        &hdheartattackage;
		array wfheartattackage_[*] _1969 - _1997 _1999 _2001 _2003        &wfheartattackage;
		array hdheartdiseaseage_[*] _1969 - _1997 _1999 _2001 _2003       &hdheartdiseaseage;
		array wfheartdiseaseage_[*] _1969 - _1997 _1999 _2001 _2003       &wfheartdiseaseage;
		array hdhypertensionage_[*] _1969 - _1997 _1999 _2001 _2003       &hdhypertensionage;
		array wfhypertensionage_[*] _1969 - _1997 _1999 _2001 _2003       &wfhypertensionage;
		array hdasthmaage_[*] _1969 - _1997 _1999 _2001 _2003             &hdasthmaage;
		array wfasthmaage_[*] _1969 - _1997 _1999 _2001 _2003             &wfasthmaage;
		array hdlungdiseaseage_[*] _1969 - _1997 _1999 _2001 _2003        &hdlungdiseaseage;
		array wflungdiseaseage_[*] _1969 - _1997 _1999 _2001 _2003        &wflungdiseaseage;
		array hddiabetesage_[*] _1969 - _1997 _1999 _2001 _2003           &hddiabetesage;
		array wfdiabetesage_[*] _1969 - _1997 _1999 _2001 _2003           &wfdiabetesage;
		array hdarthritisage_[*] _1969 - _1997 _1999 _2001 _2003          &hdarthritisage;
		array wfarthritisage_[*] _1969 - _1997 _1999 _2001 _2003          &wfarthritisage;
		array hdmemorylossage_[*] _1969 - _1997 _1999 _2001 _2003         &hdmemorylossage;
		array wfmemorylossage_[*] _1969 - _1997 _1999 _2001 _2003         &wfmemorylossage;
		array hdlearningdisorderage_[*] _1969 - _1997 _1999 _2001 _2003   &hdlearningdisorderage;
		array wflearningdisorderage_[*] _1969 - _1997 _1999 _2001 _2003   &wflearningdisorderage;
		array hdcancerage_[*] _1969 - _1997 _1999 _2001 _2003             &hdcancerage;
		array wfcancerage_[*] _1969 - _1997 _1999 _2001 _2003             &wfcancerage;
		array hdpsychprobage_[*] _1969 - _1997 _1999 _2001 _2003          &hdpsychprobage;
		array wfpsychprobage_[*] _1969 - _1997 _1999 _2001 _2003          &wfpsychprobage;

		array hdstrokedays_[*] _1969 - _1997            	&hdstrokedays _2005 _2007 _2009 _2011 _2013 _2015;          
		array hdstrokemnth_[*] _1969 - _1997              &hdstrokemnth _2005 _2007 _2009 _2011 _2013 _2015;          
		array hdstrokeweek_[*] _1969 - _1997              &hdstrokeweek _2005 _2007 _2009 _2011 _2013 _2015;          
		array hdstrokeyear_[*] _1969 - _1997              &hdstrokeyear _2005 _2007 _2009 _2011 _2013 _2015;          
		array wfstrokedays_[*] _1969 - _1997              &wfstrokedays _2005 _2007 _2009 _2011 _2013 _2015;          
		array wfstrokemnth_[*] _1969 - _1997              &wfstrokemnth _2005 _2007 _2009 _2011 _2013 _2015;          
		array wfstrokeweek_[*] _1969 - _1997              &wfstrokeweek _2005 _2007 _2009 _2011 _2013 _2015;          
		array wfstrokeyear_[*] _1969 - _1997              &wfstrokeyear _2005 _2007 _2009 _2011 _2013 _2015;          
		array hdhibpdays_[*] _1969 - _1997                &hdhibpdays   _2005 _2007 _2009 _2011 _2013 _2015;          
		array hdhibpmnth_[*] _1969 - _1997                &hdhibpmnth   _2005 _2007 _2009 _2011 _2013 _2015;          
		array hdhibpweek_[*] _1969 - _1997                &hdhibpweek   _2005 _2007 _2009 _2011 _2013 _2015;          
		array hdhibpyear_[*] _1969 - _1997                &hdhibpyear   _2005 _2007 _2009 _2011 _2013 _2015;          
		array wfhibpdays_[*] _1969 - _1997                &wfhibpdays   _2005 _2007 _2009 _2011 _2013 _2015;          
		array wfhibpmnth_[*] _1969 - _1997                &wfhibpmnth   _2005 _2007 _2009 _2011 _2013 _2015;          
		array wfhibpweek_[*] _1969 - _1997                &wfhibpweek   _2005 _2007 _2009 _2011 _2013 _2015;          
		array wfhibpyear_[*] _1969 - _1997                &wfhibpyear   _2005 _2007 _2009 _2011 _2013 _2015;          
		array hddiabdays_[*] _1969 - _1997                &hddiabdays   _2005 _2007 _2009 _2011 _2013 _2015;          
		array hddiabmnth_[*] _1969 - _1997                &hddiabmnth   _2005 _2007 _2009 _2011 _2013 _2015;          
		array hddiabweek_[*] _1969 - _1997                &hddiabweek   _2005 _2007 _2009 _2011 _2013 _2015;          
		array hddiabyear_[*] _1969 - _1997                &hddiabyear   _2005 _2007 _2009 _2011 _2013 _2015;          
		array wfdiabdays_[*] _1969 - _1997                &wfdiabdays   _2005 _2007 _2009 _2011 _2013 _2015;          
		array wfdiabmnth_[*] _1969 - _1997                &wfdiabmnth   _2005 _2007 _2009 _2011 _2013 _2015;          
		array wfdiabweek_[*] _1969 - _1997                &wfdiabweek   _2005 _2007 _2009 _2011 _2013 _2015;          
		array wfdiabyear_[*] _1969 - _1997                &wfdiabyear   _2005 _2007 _2009 _2011 _2013 _2015;          
		array hdcancrdays_[*] _1969 - _1997               &hdcancrdays  _2005 _2007 _2009 _2011 _2013 _2015;          
		array hdcancrmnth_[*] _1969 - _1997               &hdcancrmnth  _2005 _2007 _2009 _2011 _2013 _2015;          
		array hdcancrweek_[*] _1969 - _1997               &hdcancrweek  _2005 _2007 _2009 _2011 _2013 _2015;          
		array hdcancryear_[*] _1969 - _1997               &hdcancryear  _2005 _2007 _2009 _2011 _2013 _2015;          
		array wfcancrdays_[*] _1969 - _1997               &wfcancrdays  _2005 _2007 _2009 _2011 _2013 _2015;          
		array wfcancrmnth_[*] _1969 - _1997               &wfcancrmnth  _2005 _2007 _2009 _2011 _2013 _2015;          
		array wfcancrweek_[*] _1969 - _1997               &wfcancrweek  _2005 _2007 _2009 _2011 _2013 _2015;          
		array wfcancryear_[*] _1969 - _1997               &wfcancryear  _2005 _2007 _2009 _2011 _2013 _2015;          
		array hdlungdays_[*] _1969 - _1997                &hdlungdays   _2005 _2007 _2009 _2011 _2013 _2015;          
		array hdlungmnth_[*] _1969 - _1997                &hdlungmnth   _2005 _2007 _2009 _2011 _2013 _2015;          
		array hdlungweek_[*] _1969 - _1997                &hdlungweek   _2005 _2007 _2009 _2011 _2013 _2015;          
		array hdlungyear_[*] _1969 - _1997                &hdlungyear   _2005 _2007 _2009 _2011 _2013 _2015;          
		array wflungdays_[*] _1969 - _1997                &wflungdays   _2005 _2007 _2009 _2011 _2013 _2015;          
		array wflungmnth_[*] _1969 - _1997                &wflungmnth   _2005 _2007 _2009 _2011 _2013 _2015;          
		array wflungweek_[*] _1969 - _1997                &wflungweek   _2005 _2007 _2009 _2011 _2013 _2015;          
		array wflungyear_[*] _1969 - _1997                &wflungyear   _2005 _2007 _2009 _2011 _2013 _2015;          
		array hdheartattackdays_[*] _1969 - _1997         &hdheartattackdays     _2005 _2007 _2009 _2011 _2013 _2015; 
		array hdheartattackmnth_[*] _1969 - _1997         &hdheartattackmnth     _2005 _2007 _2009 _2011 _2013 _2015; 
		array hdheartattackweek_[*] _1969 - _1997         &hdheartattackweek     _2005 _2007 _2009 _2011 _2013 _2015; 
		array hdheartattackyear_[*] _1969 - _1997         &hdheartattackyear     _2005 _2007 _2009 _2011 _2013 _2015; 
		array wfheartattackdays_[*] _1969 - _1997         &wfheartattackdays     _2005 _2007 _2009 _2011 _2013 _2015; 
		array wfheartattackmnth_[*] _1969 - _1997         &wfheartattackmnth     _2005 _2007 _2009 _2011 _2013 _2015; 
		array wfheartattackweek_[*] _1969 - _1997         &wfheartattackweek     _2005 _2007 _2009 _2011 _2013 _2015; 
		array wfheartattackyear_[*] _1969 - _1997         &wfheartattackyear     _2005 _2007 _2009 _2011 _2013 _2015; 
		array hdheartdiseasedays_[*] _1969 - _1997        &hdheartdiseasedays    _2005 _2007 _2009 _2011 _2013 _2015; 
		array hdheartdiseasemnth_[*] _1969 - _1997        &hdheartdiseasemnth    _2005 _2007 _2009 _2011 _2013 _2015; 
		array hdheartdiseaseweek_[*] _1969 - _1997        &hdheartdiseaseweek    _2005 _2007 _2009 _2011 _2013 _2015; 
		array hdheartdiseaseyear_[*] _1969 - _1997        &hdheartdiseaseyear    _2005 _2007 _2009 _2011 _2013 _2015; 
		array wfheartdiseasedays_[*] _1969 - _1997        &wfheartdiseasedays    _2005 _2007 _2009 _2011 _2013 _2015; 
		array wfheartdiseasemnth_[*] _1969 - _1997        &wfheartdiseasemnth    _2005 _2007 _2009 _2011 _2013 _2015; 
		array wfheartdiseaseweek_[*] _1969 - _1997        &wfheartdiseaseweek    _2005 _2007 _2009 _2011 _2013 _2015; 
		array wfheartdiseaseyear_[*] _1969 - _1997        &wfheartdiseaseyear    _2005 _2007 _2009 _2011 _2013 _2015; 
		array hdpsychprobdays_[*] _1969 - _1997           &hdpsychprobdays       _2005 _2007 _2009 _2011 _2013 _2015; 
		array hdpsychprobmnth_[*] _1969 - _1997           &hdpsychprobmnth       _2005 _2007 _2009 _2011 _2013 _2015; 
		array hdpsychprobweek_[*] _1969 - _1997           &hdpsychprobweek       _2005 _2007 _2009 _2011 _2013 _2015; 
		array hdpsychprobyear_[*] _1969 - _1997           &hdpsychprobyear       _2005 _2007 _2009 _2011 _2013 _2015; 
		array wfpsychprobdays_[*] _1969 - _1997           &wfpsychprobdays       _2005 _2007 _2009 _2011 _2013 _2015; 
		array wfpsychprobmnth_[*] _1969 - _1997           &wfpsychprobmnth       _2005 _2007 _2009 _2011 _2013 _2015; 
		array wfpsychprobweek_[*] _1969 - _1997           &wfpsychprobweek       _2005 _2007 _2009 _2011 _2013 _2015; 
		array wfpsychprobyear_[*] _1969 - _1997           &wfpsychprobyear       _2005 _2007 _2009 _2011 _2013 _2015; 
		array hdarthritisdays_[*] _1969 - _1997           &hdarthritisdays       _2005 _2007 _2009 _2011 _2013 _2015; 
		array hdarthritismnth_[*] _1969 - _1997           &hdarthritismnth       _2005 _2007 _2009 _2011 _2013 _2015; 
		array hdarthritisweek_[*] _1969 - _1997           &hdarthritisweek       _2005 _2007 _2009 _2011 _2013 _2015; 
		array hdarthritisyear_[*] _1969 - _1997           &hdarthritisyear       _2005 _2007 _2009 _2011 _2013 _2015; 
		array wfarthritisdays_[*] _1969 - _1997           &wfarthritisdays       _2005 _2007 _2009 _2011 _2013 _2015; 
		array wfarthritismnth_[*] _1969 - _1997           &wfarthritismnth       _2005 _2007 _2009 _2011 _2013 _2015; 
		array wfarthritisweek_[*] _1969 - _1997           &wfarthritisweek       _2005 _2007 _2009 _2011 _2013 _2015; 
		array wfarthritisyear_[*] _1969 - _1997           &wfarthritisyear       _2005 _2007 _2009 _2011 _2013 _2015; 
		array hdasthmadays_[*] _1969 - _1997              &hdasthmadays          _2005 _2007 _2009 _2011 _2013 _2015; 
		array hdasthmamnth_[*] _1969 - _1997              &hdasthmamnth          _2005 _2007 _2009 _2011 _2013 _2015; 
		array hdasthmaweek_[*] _1969 - _1997              &hdasthmaweek          _2005 _2007 _2009 _2011 _2013 _2015; 
		array hdasthmayear_[*] _1969 - _1997              &hdasthmayear          _2005 _2007 _2009 _2011 _2013 _2015; 
		array wfasthmadays_[*] _1969 - _1997              &wfasthmadays           	_2005 _2007 _2009 _2011 _2013 _2015;
		array wfasthmamnth_[*] _1969 - _1997              &wfasthmamnth             _2005 _2007 _2009 _2011 _2013 _2015;
		array wfasthmaweek_[*] _1969 - _1997              &wfasthmaweek             _2005 _2007 _2009 _2011 _2013 _2015;
		array wfasthmayear_[*] _1969 - _1997              &wfasthmayear             _2005 _2007 _2009 _2011 _2013 _2015;
		array hdmemorylossdays_[*] _1969 - _1997          &hdmemorylossdays         _2005 _2007 _2009 _2011 _2013 _2015;
		array hdmemorylossmnth_[*] _1969 - _1997          &hdmemorylossmnth         _2005 _2007 _2009 _2011 _2013 _2015;
		array hdmemorylossweek_[*] _1969 - _1997          &hdmemorylossweek         _2005 _2007 _2009 _2011 _2013 _2015;
		array hdmemorylossyear_[*] _1969 - _1997          &hdmemorylossyear         _2005 _2007 _2009 _2011 _2013 _2015;
		array wfmemorylossdays_[*] _1969 - _1997          &wfmemorylossdays         _2005 _2007 _2009 _2011 _2013 _2015;
		array wfmemorylossmnth_[*] _1969 - _1997          &wfmemorylossmnth         _2005 _2007 _2009 _2011 _2013 _2015;
		array wfmemorylossweek_[*] _1969 - _1997          &wfmemorylossweek         _2005 _2007 _2009 _2011 _2013 _2015;
		array wfmemorylossyear_[*] _1969 - _1997          &wfmemorylossyear         _2005 _2007 _2009 _2011 _2013 _2015;
		array hdlearningdisorderdays_[*] _1969 - _1997    &hdlearningdisorderdays   _2005 _2007 _2009 _2011 _2013 _2015;
		array hdlearningdisordermnth_[*] _1969 - _1997    &hdlearningdisordermnth   _2005 _2007 _2009 _2011 _2013 _2015;
		array hdlearningdisorderweek_[*] _1969 - _1997    &hdlearningdisorderweek   _2005 _2007 _2009 _2011 _2013 _2015;
		array hdlearningdisorderyear_[*] _1969 - _1997    &hdlearningdisorderyear   _2005 _2007 _2009 _2011 _2013 _2015;
		array wflearningdisorderdays_[*] _1969 - _1997    &wflearningdisorderdays   _2005 _2007 _2009 _2011 _2013 _2015;
		array wflearningdisordermnth_[*] _1969 - _1997    &wflearningdisordermnth   _2005 _2007 _2009 _2011 _2013 _2015;
		array wflearningdisorderweek_[*] _1969 - _1997    &wflearningdisorderweek   _2005 _2007 _2009 _2011 _2013 _2015;
		array wflearningdisorderyear_[*] _1969 - _1997    &wflearningdisorderyear   _2005 _2007 _2009 _2011 _2013 _2015;

		array hdworklimit_[*] _1969 - _1997 &hdworklimit;
		array wfworklimit_[*] _1969 - _1997 &wfworklimit;
		
		/* Arrays for Kessler 6 variables (respondent specific) */
		array hdrespsadness_[*]	_1969 - _1997 _1999 &respsadness;
		array wfrespsadness_[*]	_1969 - _1997 _1999 &respsadness;
		array hdrespnervous_[*] _1969 - _1997 _1999 &respnervous; 
		array wfrespnervous_[*] _1969 - _1997 _1999 &respnervous; 
		array hdresprestless_[*] _1969 - _1997 _1999 &resprestless; 
		array wfresprestless_[*] _1969 - _1997 _1999 &resprestless; 
		array hdresphopeless_[*] _1969 - _1997 _1999 &resphopeless; 
		array wfresphopeless_[*] _1969 - _1997 _1999 &resphopeless; 
		array hdrespeffort_[*] _1969 - _1997 _1999 &respeffort; 
		array wfrespeffort_[*] _1969 - _1997 _1999 &respeffort; 
		array hdrespworthless_[*] _1969 - _1997 _1999 &respworthless; 
		array wfrespworthless_[*] _1969 - _1997 _1999 &respworthless; 
		array hdrespk6scale_[*] _1969 - _1997 _1999 &respk6scale; 
		array wfrespk6scale_[*] _1969 - _1997 _1999 &respk6scale; 
		
		array hdalcohol_[*] 	_1969 - _1997 &hdalcohol;
		array hdalcdrinks_[*] _1969 - _1997 &hdalcdrinks;		
		array hdalcfreq_[*] 	_1969 - _1997 _1999 _2001 _2003 &hdalcfreq;
		array hdalcbinge_[*] 	_1969 - _1997 _1999 _2001 _2003 &hdalcbinge;
		
		
		array wfalcohol_[*] 	_1969 - _1997 &wfalcohol;
		array wfalcdrinks_[*] _1969 - _1997 &wfalcdrinks;		
		array wfalcfreq_[*] 	_1969 - _1997 _1999 _2001 _2003 &wfalcfreq;		
		array wfalcbinge_[*] 	_1969 - _1997 _1999 _2001 _2003 &wfalcbinge;		

		array hdsatisfaction_[*] 	_1969 - _1997 _1999 _2001 _2003 _2005 _2007 &hdsatisfaction;
		array wfsatisfaction_[*] 	_1969 - _1997 _1999 _2001 _2003 _2005 _2007 &wfsatisfaction;		
		
		array hdhous_[*] _1969 - _1997 _1999 _2001 _2003 _2005 _2007 _2009 _2011 _2013 &hdhous;
		array hdfood_[*] _1969 - _1997 _1999 _2001 _2003 _2005 _2007 _2009 _2011 _2013 &hdfood;
		array hdtran_[*] _1969 - _1997 _1999 _2001 _2003 _2005 _2007 _2009 _2011 _2013 &hdtran;
		array hdhealth_[*] _1969 - _1997 _1999 _2001 _2003 _2005 _2007 _2009 _2011 _2013 &hdhealth;
		array hdtrips_[*] _1969 - _1997 _1999 _2001 _2003 _2005 _2007 _2009 _2011 _2013 &hdtrips;
		array hded_[*] _1969 - _1997 _1999 _2001 _2003 _2005 _2007 _2009 _2011 _2013 &hded;
		array hdcloth_[*] _1969 - _1997 _1999 _2001 _2003 _2005 _2007 _2009 _2011 _2013 &hdcloth;
		array hdothrec_[*] _1969 - _1997 _1999 _2001 _2003 _2005 _2007 _2009 _2011 _2013 &hdothrec;
		array hdchild_[*] _1969 - _1997 _1999 _2001 _2003 _2005 _2007 _2009 _2011 _2013 &hdchild;
		
		array wfhous_[*] _1969 - _1997 _1999 _2001 _2003 _2005 _2007 _2009 _2011 _2013 &wfhous;
		array wffood_[*] _1969 - _1997 _1999 _2001 _2003 _2005 _2007 _2009 _2011 _2013 &wffood;
		array wftran_[*] _1969 - _1997 _1999 _2001 _2003 _2005 _2007 _2009 _2011 _2013 &wftran;
		array wfhealth_[*] _1969 - _1997 _1999 _2001 _2003 _2005 _2007 _2009 _2011 _2013 &wfhealth;
		array wftrips_[*] _1969 - _1997 _1999 _2001 _2003 _2005 _2007 _2009 _2011 _2013 &wftrips;
		array wfed_[*] _1969 - _1997 _1999 _2001 _2003 _2005 _2007 _2009 _2011 _2013 &wfed;
		array wfcloth_[*] _1969 - _1997 _1999 _2001 _2003 _2005 _2007 _2009 _2011 _2013 &wfcloth;
		array wfothrec_[*] _1969 - _1997 _1999 _2001 _2003 _2005 _2007 _2009 _2011 _2013 &wfothrec;
		array wfchild_[*] _1969 - _1997 _1999 _2001 _2003 _2005 _2007 _2009 _2011 _2013 &wfchild;
		
	 /* Arrays for state codes */
  	array hdstatecode_[*] _1969 - _1997 &hdstatecode; 
		array wfstatecode_[*] _1969 - _1997 &wfstatecode; 
		
		/* Arrays for respondent */
		array hdrespondent_[*] _1969 - _1997 &hdrespondent; 
		array wfrespondent_[*] _1969 - _1997 &wfrespondent; 
		

   /* relhd=1 or 10 for head, 2 or 20 for wife.  2-digit relhd codes begin
      in 1984, i think */

	 array resp_[*} _1969 - _1997  %listyrv(resp,begy=1999);

   array relhd_[*] %listyrv(relhd,begy=&minyr);
   array seq_[*] %listyrv(seq,begy=&minyr);
   array cohab_[*] _1969 - _1997 %listyrv(cohab,begy=1999);
   array inyr_[*] _1969 - _1997 %listyrv(inyr,begy=1999);
   array diedyr_[*] _1969 - _1997 %listyrv(diedyr,begy=1999);
   array died_[*] _1969 - _1997 %listyrv(died,begy=1999);
   array srh_[*] _1969 - _1997 %listyrv(srh,begy=1999);  
   array cancr_[*] _1969 - _1997 %listyrv(cancr,begy=1999);
   array diab_[*] _1969 - _1997 %listyrv(diab,begy=1999);
   array heart_[*] _1969 - _1997 %listyrv(heart,begy=1999);     
   array hearta_[*] _1969 - _1997 %listyrv(hearta,begy=1999);   																			/* add heart attack variables */ 
   array hibp_[*] _1969 - _1997 %listyrv(hibp,begy=1999);
   array lung_[*] _1969 - _1997 %listyrv(lung,begy=1999);
   array strok_[*] _1969 - _1997 %listyrv(strok,begy=1999);
   array smoken_[*] _1969 - _1997 %listyrv(smoken,begy=1999);
   array smokev_[*] _1969 - _1997 %listyrv(smokev,begy=1999);
   
   array asthm_[*] _1969 - _1997 %listyrv(asthm,begy=1999);
      
   array cancrloc1_[*] _1969 - _1997 _1999 _2001 _2003 %listyrv(cancrloc1,begy=2005); 
	 array cancrloc2_[*] _1969 - _1997 _1999 _2001 _2003 %listyrv(cancrloc2,begy=2005);  
	 array cancrlimit_[*] _1969 - _1997   %listyrv(cancrlimit,begy=1999);          
	 array diablimit_[*] _1969 - _1997    %listyrv(diablimit,begy=1999);                  
	 array heartlimit_[*] _1969 - _1997   %listyrv(heartlimit,begy=1999);       
	 array hibplimit_[*] _1969 - _1997    %listyrv(hibplimit,begy=1999);      
	 array lunglimit_[*] _1969 - _1997    %listyrv(lunglimit,begy=1999);       
	 array heartalimit_[*] _1969 - _1997  %listyrv(heartalimit,begy=1999);       
	 array stroklimit_[*] _1969 - _1997   %listyrv(stroklimit,begy=1999);     
      
   array numcigsn_[*] _1969 - _1997 %listyrv(numcigsn,begy=1999);     
   array numcigse_[*] _1969 - _1997 %listyrv(numcigse,begy=1999);    
   array smokestartn_[*] _1969 - _1997 %listyrv(smokestartn,begy=1999);
   array smokestarte_[*] _1969 - _1997 %listyrv(smokestarte,begy=1999);
   array smokestop_[*] _1969 - _1997 %listyrv(smokestop,begy=1999);
     
   array wght_[*] _1969 - _1997 %listyrv(wght,begy=1999);
   array heightft_[*] _1969 - _1997 %listyrv(heightft,begy=1999);
   array heightin_[*] _1969 - _1997 %listyrv(heightin,begy=1999);
   array race_[*] _1969 - _1997 %listyrv(race,begy=1999);
   array hispan_[*] _1969 - _1997 %listyrv(hispan,begy=1999);
   array head_[*] _1969 - _1997 %listyrv(head,begy=1999);
   array wife_[*] _1969 - _1997 %listyrv(wife,begy=1999);
   array hdwf_[*] _1969 - _1997 %listyrv(hdwf,begy=1999);
   array mstath_[*] _1969 - _1997 %listyrv(mstath,begy=1999);
   array mstatalt_[*] _1969 - _1997 %listyrv(mstatalt,begy=1999);   
	 array mstatch_[*] _1969 - _1997 %listyrv(mstatch,begy=1999);																				/* add marriage change variable */

   array iwmonth_[*] _1969 - _1997 %listyrv(iwmonth,begy=1999);
   array iwday_[*] _1969 - _1997 %listyrv(iwday,begy=1999);
   array iwyear_[*] _1969 - _1997 %listyrv(iwyear,begy=1999);
   
   
   array bath_[*] _1969 - _1997 %listyrv(bath,begy=1999);
   array eat_[*] _1969 - _1997 %listyrv(eat,begy=1999);
   array dress_[*] _1969 - _1997 %listyrv(dress,begy=1999);
   array walk_[*] _1969 - _1997 %listyrv(walk,begy=1999);
   array bed_[*] _1969 - _1997 %listyrv(bed,begy=1999);
   array toilet_[*] _1969 - _1997 %listyrv(toilet,begy=1999);
   array bathhelp_[*] _1969 - _1997 %listyrv(bathhelp,begy=1999);
   array eathelp_[*] _1969 - _1997 %listyrv(eathelp,begy=1999);
   array dresshelp_[*] _1969 - _1997 %listyrv(dresshelp,begy=1999);
   array walkhelp_[*] _1969 - _1997 %listyrv(walkhelp,begy=1999);
   array bedhelp_[*] _1969 - _1997 %listyrv(bedhelp,begy=1999);
   array toilethelp_[*] _1969 - _1997 %listyrv(toilethelp,begy=1999);
   
   array meals_[*] _1969 - _1997 %listyrv(meals,begy=1999);
   array shop_[*] _1969 - _1997 %listyrv(shop,begy=1999);
   array money_[*] _1969 - _1997 %listyrv(money,begy=1999);
   array phone_[*] _1969 - _1997 %listyrv(phone,begy=1999);
   array hvyhswrk_[*] _1969 - _1997 %listyrv(hvyhswrk,begy=1999);
   array lthswrk_[*] _1969 - _1997 %listyrv(lthswrk,begy=1999);
   array mealstp_[*] _1969 - _1997 %listyrv(mealstp,begy=1999);
   array shoptp_[*] _1969 - _1997 %listyrv(shoptp,begy=1999);
   array moneytp_[*] _1969 - _1997 %listyrv(moneytp,begy=1999);
   array phonetp_[*] _1969 - _1997 %listyrv(phonetp,begy=1999);
   array hvyhswrktp_[*] _1969 - _1997 %listyrv(hvyhswrktp,begy=1999);
   array lthswrktp_[*] _1969 - _1997 %listyrv(lthswrktp,begy=1999);
   
   array elderhome_[*] _1969 - _1997 %listyrv(elderhome,begy=1999);
   array eldertype_[*] _1969 - _1997 %listyrv(eldertype,begy=1999);
   array region_[*] _1969 - _1997 %listyrv(region,begy=1999);
   
   array educalt_[*] _1969 - _1997 %listyrv(educalt,begy=1999);
   
   array parpoor_[*] %listyrv(parpoor,begy=1969);
   
   array chldhlth_[*] _1969 - _1997 %listyrv(chldhlth,begy=1999);
   array grewup_[*]  _1969 - _1997 %listyrv(grewup,begy=1999);
      
   array lgtexcfreq_[*] _1969 - _1997 %listyrv(lgtexcfreq,begy=1999);
   array lgtexcunit_[*] _1969 - _1997 %listyrv(lgtexcunit,begy=1999);
   array hvyexcfreq_[*] _1969 - _1997 %listyrv(hvyexcfreq,begy=1999);
   array hvyexcunit_[*] _1969 - _1997 %listyrv(hvyexcunit,begy=1999);
   array musclefreq_[*] _1969 - _1997 %listyrv(musclefreq,begy=1999);
   array muscleunit_[*] _1969 - _1997 %listyrv(muscleunit,begy=1999);
   
    array eatoutfs_[*]			_1969 - _1997 %listyrv(eatoutfs,begy=1999);
    array eatoutfsunit_[*]  _1969 - _1997 %listyrv(eatoutfsunit,begy=1999); 
    array eatout_[*]        _1969 - _1997 %listyrv(eatout,begy=1999);    
    array eatoutunit_[*]    _1969 - _1997 %listyrv(eatoutunit,begy=1999);
   
   array numinfu_[*] _1969 - _1997 %listyrv(numinfu,begy=1999);
   array proptax_[*] _1969 - _1997 %listyrv(proptax,begy=1999);
  
	array workweeks_[*] _1969 - _1997 %listyrv(workweeks,begy=1999);
	array weekworkhr_[*] _1969 - _1997 %listyrv(weekworkhr,begy=1999);
	array overtimehr_[*] _1969 - _1997 %listyrv(overtimehr,begy=1999);
	array yrworkhr_[*] _1969 - _1997 %listyrv(yrworkhr,begy=1999);	
  
  array chldsrh_[*] _1969 - _1997 _1999 _2001 _2003 _2005 %listyrv(chldsrh,begy=2007);         
	array chldmissschool_[*] _1969 - _1997 _1999 _2001 _2003 _2005 %listyrv(chldmissschool,begy=2007);  
	array chldmeasles_[*] _1969 - _1997 _1999 _2001 _2003 _2005 %listyrv(chldmeasles,begy=2007);     
	array chldmumps_[*] _1969 - _1997 _1999 _2001 _2003 _2005 %listyrv(chldmumps,begy=2007);       
	array chldcknpox_[*] _1969 - _1997 _1999 _2001 _2003 _2005 %listyrv(chldcknpox,begy=2007);      
	array chldvision_[*] _1969 - _1997 _1999 _2001 _2003 _2005 %listyrv(chldvision,begy=2007);      
	array chldparsmk_[*] _1969 - _1997 _1999 _2001 _2003 _2005 %listyrv(chldparsmk,begy=2007);      
	array chldasthma_[*] _1969 - _1997 _1999 _2001 _2003 _2005 %listyrv(chldasthma,begy=2007);      
	array chlddiab_[*] _1969 - _1997 _1999 _2001 _2003 _2005 %listyrv(chlddiab,begy=2007);        
	array chldresp_[*] _1969 - _1997 _1999 _2001 _2003 _2005 %listyrv(chldresp,begy=2007);        
	array chldspeech_[*] _1969 - _1997 _1999 _2001 _2003 _2005 %listyrv(chldspeech,begy=2007);      
	array chldallergy_[*] _1969 - _1997 _1999 _2001 _2003 _2005 %listyrv(chldallergy,begy=2007);     
	array chldheart_[*] _1969 - _1997 _1999 _2001 _2003 _2005 %listyrv(chldheart,begy=2007);       
	array chldear_[*] _1969 - _1997 _1999 _2001 _2003 _2005 %listyrv(chldear,begy=2007);         
	array chldszre_[*] _1969 - _1997 _1999 _2001 _2003 _2005 %listyrv(chldszre,begy=2007);        
	array chldmgrn_[*] _1969 - _1997 _1999 _2001 _2003 _2005 %listyrv(chldmgrn,begy=2007);        
	array chldstomach_[*] _1969 - _1997 _1999 _2001 _2003 _2005 %listyrv(chldstomach,begy=2007);     
	array chldhibp_[*] _1969 - _1997 _1999 _2001 _2003 _2005 %listyrv(chldhibp,begy=2007);        
	array chlddepress_[*] _1969 - _1997 _1999 _2001 _2003 _2005 %listyrv(chlddepress,begy=2007);     
	array chlddrug_[*] _1969 - _1997 _1999 _2001 _2003 _2005 %listyrv(chlddrug,begy=2007);        
	array chldpsych_[*] _1969 - _1997 _1999 _2001 _2003 _2005 %listyrv(chldpsych,begy=2007);  
  
  
  array strokeage_[*] _1969 - _1997 _1999 _2001 _2003             %listyrv(strokeage,begy=2005);
	array heartattackage_[*] _1969 - _1997 _1999 _2001 _2003        %listyrv(heartattackage,begy=2005);
	array heartdiseaseage_[*] _1969 - _1997 _1999 _2001 _2003       %listyrv(heartdiseaseage,begy=2005);
	array hypertensionage_[*] _1969 - _1997 _1999 _2001 _2003       %listyrv(hypertensionage,begy=2005);
	array asthmaage_[*] _1969 - _1997 _1999 _2001 _2003             %listyrv(asthmaage,begy=2005);
	array lungdiseaseage_[*] _1969 - _1997 _1999 _2001 _2003        %listyrv(lungdiseaseage,begy=2005);
	array diabetesage_[*] _1969 - _1997 _1999 _2001 _2003           %listyrv(diabetesage,begy=2005);
	array arthritisage_[*] _1969 - _1997 _1999 _2001 _2003          %listyrv(arthritisage,begy=2005);
	array memorylossage_[*] _1969 - _1997 _1999 _2001 _2003         %listyrv(memorylossage,begy=2005);
	array learningdisorderage_[*] _1969 - _1997 _1999 _2001 _2003   %listyrv(learningdisorderage,begy=2005);
	array cancerage_[*] _1969 - _1997 _1999 _2001 _2003             %listyrv(cancerage,begy=2005);
	array psychprobage_[*] _1969 - _1997 _1999 _2001 _2003          %listyrv(psychprobage,begy=2005);
	
	
	
	array strokedays_[*] _1969 - _1997            	%listyrv(strokedays,begy=1999,endy=2003) _2005 _2007 _2009 _2011 _2013 _2015;          
	array strokemnth_[*] _1969 - _1997              %listyrv(strokemnth,begy=1999,endy=2003) _2005 _2007 _2009 _2011 _2013 _2015;          
	array strokeweek_[*] _1969 - _1997              %listyrv(strokeweek,begy=1999,endy=2003) _2005 _2007 _2009 _2011 _2013 _2015;          
	array strokeyear_[*] _1969 - _1997              %listyrv(strokeyear,begy=1999,endy=2003) _2005 _2007 _2009 _2011 _2013 _2015;          
	array hibpdays_[*] _1969 - _1997                %listyrv(hibpdays,begy=1999,endy=2003)   _2005 _2007 _2009 _2011 _2013 _2015;          
	array hibpmnth_[*] _1969 - _1997                %listyrv(hibpmnth,begy=1999,endy=2003)   _2005 _2007 _2009 _2011 _2013 _2015;          
	array hibpweek_[*] _1969 - _1997                %listyrv(hibpweek,begy=1999,endy=2003)   _2005 _2007 _2009 _2011 _2013 _2015;          
	array hibpyear_[*] _1969 - _1997                %listyrv(hibpyear,begy=1999,endy=2003)   _2005 _2007 _2009 _2011 _2013 _2015;          
	array diabdays_[*] _1969 - _1997                %listyrv(diabdays,begy=1999,endy=2003)   _2005 _2007 _2009 _2011 _2013 _2015;          
	array diabmnth_[*] _1969 - _1997                %listyrv(diabmnth,begy=1999,endy=2003)   _2005 _2007 _2009 _2011 _2013 _2015;          
	array diabweek_[*] _1969 - _1997                %listyrv(diabweek,begy=1999,endy=2003)   _2005 _2007 _2009 _2011 _2013 _2015;          
	array diabyear_[*] _1969 - _1997                %listyrv(diabyear,begy=1999,endy=2003)   _2005 _2007 _2009 _2011 _2013 _2015;          
	array cancrdays_[*] _1969 - _1997               %listyrv(cancrdays,begy=1999,endy=2003)  _2005 _2007 _2009 _2011 _2013 _2015;          
	array cancrmnth_[*] _1969 - _1997               %listyrv(cancrmnth,begy=1999,endy=2003)  _2005 _2007 _2009 _2011 _2013 _2015;          
	array cancrweek_[*] _1969 - _1997               %listyrv(cancrweek,begy=1999,endy=2003)  _2005 _2007 _2009 _2011 _2013 _2015;          
	array cancryear_[*] _1969 - _1997               %listyrv(cancryear,begy=1999,endy=2003)  _2005 _2007 _2009 _2011 _2013 _2015;          
	array lungdays_[*] _1969 - _1997                %listyrv(lungdays,begy=1999,endy=2003)   _2005 _2007 _2009 _2011 _2013 _2015;          
	array lungmnth_[*] _1969 - _1997                %listyrv(lungmnth,begy=1999,endy=2003)   _2005 _2007 _2009 _2011 _2013 _2015;          
	array lungweek_[*] _1969 - _1997                %listyrv(lungweek,begy=1999,endy=2003)   _2005 _2007 _2009 _2011 _2013 _2015;          
	array lungyear_[*] _1969 - _1997                %listyrv(lungyear,begy=1999,endy=2003)   _2005 _2007 _2009 _2011 _2013 _2015;          
	array heartattackdays_[*] _1969 - _1997         %listyrv(heartattackdays,begy=1999,endy=2003)     _2005 _2007 _2009 _2011 _2013 _2015; 
	array heartattackmnth_[*] _1969 - _1997         %listyrv(heartattackmnth,begy=1999,endy=2003)     _2005 _2007 _2009 _2011 _2013 _2015; 
	array heartattackweek_[*] _1969 - _1997         %listyrv(heartattackweek,begy=1999,endy=2003)     _2005 _2007 _2009 _2011 _2013 _2015; 
	array heartattackyear_[*] _1969 - _1997         %listyrv(heartattackyear,begy=1999,endy=2003)     _2005 _2007 _2009 _2011 _2013 _2015; 
	array heartdiseasedays_[*] _1969 - _1997        %listyrv(heartdiseasedays,begy=1999,endy=2003)    _2005 _2007 _2009 _2011 _2013 _2015; 
	array heartdiseasemnth_[*] _1969 - _1997        %listyrv(heartdiseasemnth,begy=1999,endy=2003)    _2005 _2007 _2009 _2011 _2013 _2015; 
	array heartdiseaseweek_[*] _1969 - _1997        %listyrv(heartdiseaseweek,begy=1999,endy=2003)    _2005 _2007 _2009 _2011 _2013 _2015; 
	array heartdiseaseyear_[*] _1969 - _1997        %listyrv(heartdiseaseyear,begy=1999,endy=2003)    _2005 _2007 _2009 _2011 _2013 _2015; 
	array psychprobdays_[*] _1969 - _1997           %listyrv(psychprobdays,begy=1999,endy=2003)       _2005 _2007 _2009 _2011 _2013 _2015; 
	array psychprobmnth_[*] _1969 - _1997           %listyrv(psychprobmnth,begy=1999,endy=2003)       _2005 _2007 _2009 _2011 _2013 _2015; 
	array psychprobweek_[*] _1969 - _1997           %listyrv(psychprobweek,begy=1999,endy=2003)       _2005 _2007 _2009 _2011 _2013 _2015; 
	array psychprobyear_[*] _1969 - _1997           %listyrv(psychprobyear,begy=1999,endy=2003)       _2005 _2007 _2009 _2011 _2013 _2015; 
	array arthritisdays_[*] _1969 - _1997           %listyrv(arthritisdays,begy=1999,endy=2003)       _2005 _2007 _2009 _2011 _2013 _2015; 
	array arthritismnth_[*] _1969 - _1997           %listyrv(arthritismnth,begy=1999,endy=2003)       _2005 _2007 _2009 _2011 _2013 _2015; 
	array arthritisweek_[*] _1969 - _1997           %listyrv(arthritisweek,begy=1999,endy=2003)       _2005 _2007 _2009 _2011 _2013 _2015; 
	array arthritisyear_[*] _1969 - _1997           %listyrv(arthritisyear,begy=1999,endy=2003)       _2005 _2007 _2009 _2011 _2013 _2015; 
	array asthmadays_[*] _1969 - _1997              %listyrv(asthmadays,begy=1999,endy=2003)          _2005 _2007 _2009 _2011 _2013 _2015; 
	array asthmamnth_[*] _1969 - _1997              %listyrv(asthmamnth,begy=1999,endy=2003)          _2005 _2007 _2009 _2011 _2013 _2015; 
	array asthmaweek_[*] _1969 - _1997              %listyrv(asthmaweek,begy=1999,endy=2003)          _2005 _2007 _2009 _2011 _2013 _2015; 
	array asthmayear_[*] _1969 - _1997              %listyrv(asthmayear,begy=1999,endy=2003)          _2005 _2007 _2009 _2011 _2013 _2015; 
	array memorylossdays_[*] _1969 - _1997          %listyrv(memorylossdays,begy=1999,endy=2003)         _2005 _2007 _2009 _2011 _2013 _2015;
	array memorylossmnth_[*] _1969 - _1997          %listyrv(memorylossmnth,begy=1999,endy=2003)         _2005 _2007 _2009 _2011 _2013 _2015;
	array memorylossweek_[*] _1969 - _1997          %listyrv(memorylossweek,begy=1999,endy=2003)         _2005 _2007 _2009 _2011 _2013 _2015;
	array memorylossyear_[*] _1969 - _1997          %listyrv(memorylossyear,begy=1999,endy=2003)         _2005 _2007 _2009 _2011 _2013 _2015;
	array learningdisorderdays_[*] _1969 - _1997    %listyrv(learningdisorderdays,begy=1999,endy=2003)   _2005 _2007 _2009 _2011 _2013 _2015;
	array learningdisordermnth_[*] _1969 - _1997    %listyrv(learningdisordermnth,begy=1999,endy=2003)   _2005 _2007 _2009 _2011 _2013 _2015;
	array learningdisorderweek_[*] _1969 - _1997    %listyrv(learningdisorderweek,begy=1999,endy=2003)   _2005 _2007 _2009 _2011 _2013 _2015;
	array learningdisorderyear_[*] _1969 - _1997    %listyrv(learningdisorderyear,begy=1999,endy=2003)   _2005 _2007 _2009 _2011 _2013 _2015;
	array worklimit_[*] _1969 - _1997 %listyrv(worklimit,begy=1999,endy=2015);	
	
	array respsadness_[*]	_1969 - _1997 _1999 %listyrv(respsadness,begy=2001);
	array respnervous_[*]	_1969 - _1997 _1999 %listyrv(respnervous,begy=2001);
	array resprestless_[*]	_1969 - _1997 _1999 %listyrv(resprestless,begy=2001);
	array resphopeless_[*]	_1969 - _1997 _1999 %listyrv(resphopeless,begy=2001);
	array respeffort_[*]	_1969 - _1997 _1999 %listyrv(respeffort,begy=2001);
	array respworthless_[*]	_1969 - _1997 _1999 %listyrv(respworthless,begy=2001);
	array respk6scale_[*]	_1969 - _1997 _1999 %listyrv(respk6scale,begy=2001);
	
	array statecode_[*]	_1969 - _1997 %listyrv(statecode,begy=1999);		
	
	array respondent_[*] _1969 - _1997 %listyrv(respondent,begy=1999); 
	
	array alcohol_[*] _1969 - _1997 %listyrv(alcohol,begy=1999);
	array alcdrinks_[*] _1969 - _1997 %listyrv(alcdrinks,begy=1999);
	array alcfreq_[*] _1969 - _1997 _1999 _2001 _2003 %listyrv(alcfreq,begy=2005);
	array alcbinge_[*] _1969 - _1997 _1999 _2001 _2003 %listyrv(alcbinge,begy=2005);
	
	array satisfaction_[*] _1969 - _1997 _1999 _2001 _2003 _2005 _2007 %listyrv(satisfaction,begy=2009);	
	
	array conhous_[*] _1969 - _1997 _1999 _2001 _2003 _2005 _2007 _2009 _2011 _2013 %listyrv(conhous,begy=2015);
	array confood_[*] _1969 - _1997 _1999 _2001 _2003 _2005 _2007 _2009 _2011 _2013 %listyrv(confood,begy=2015); 
	array contran_[*] _1969 - _1997 _1999 _2001 _2003 _2005 _2007 _2009 _2011 _2013 %listyrv(contran,begy=2015);
	array conhealth_[*] _1969 - _1997 _1999 _2001 _2003 _2005 _2007 _2009 _2011 _2013 %listyrv(conhealth,begy=2015); 
	array contrips_[*] _1969 - _1997 _1999 _2001 _2003 _2005 _2007 _2009 _2011 _2013 %listyrv(contrips,begy=2015); 
	array coned_[*] _1969 - _1997 _1999 _2001 _2003 _2005 _2007 _2009 _2011 _2013 %listyrv(coned,begy=2015); 
	array concloth_[*] _1969 - _1997 _1999 _2001 _2003 _2005 _2007 _2009 _2011 _2013 %listyrv(concloth,begy=2015); 
	array conothrec_[*] _1969 - _1997 _1999 _2001 _2003 _2005 _2007 _2009 _2011 _2013 %listyrv(conothrec,begy=2015); 
	array conchild_[*] _1969 - _1997 _1999 _2001 _2003 _2005 _2007 _2009 _2011 _2013 %listyrv(conchild,begy=2015); 
       
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
   	      /* THIS IS WHERE WE ASSIGN VARS TO HEAD OR WIFE */
	      mstath_[i] = hdmarr_[i]; 
	      mstatalt_[i] = hdmarrgen_[i];	      
	      mstatch_[i] = hdmarrch_[i];																																		/* add marriage change variable */
        head_[i] = 1;
        hdwf_[i] = 1;
	      hdwfever = 1;

	      iwmonth_[i] = hdiwmonth_[i];
	      iwday_[i] = hdiwday_[i];
             iwyear_[i] = hdiwyear_[i];
		
	      race_[i] = hdrace_[i];
	      hispan_[i] = hdhispan_[i];	
	      cancr_[i] = hdcancr_[i];
	      diab_[i] = hddiab_[i];
        heart_[i] = hdheart_[i];        
        hearta_[i] = hdhearta_[i];																																	/* add heart attack variables */
        hibp_[i] = hdhibp_[i];
	      lung_[i] = hdlung_[i];
        strok_[i] = hdstrok_[i];
        
        asthm_[i] = hdasthm_[i];
        
   			cancrloc1_[i]   =  hdcancrloc1_[i] ; 
	 			cancrloc2_[i]   =  hdcancrloc2_[i]  ;
	 			cancrlimit_[i]  =  hdcancrlimit_[i] ;
	 			diablimit_[i]   =  hddiablimit_[i]  ;
	 			heartlimit_[i]  =  hdheartlimit_[i] ;
	 			hibplimit_[i]   =  hdhibplimit_[i]  ;
	 			lunglimit_[i]   =  hdlunglimit_[i]  ;
	 			heartalimit_[i] =  hdheartalimit_[i];
	 			stroklimit_[i]  =  hdstroklimit_[i] ;
               
        smoken_[i] = hdsmoken_[i];
        smokev_[i] = hdsmokev_[i];
        numcigsn_[i] =     hdnumcigsn_[i]; 
				numcigse_[i] =     hdnumcigse_[i]; 
				smokestartn_[i] =  hdsmokestartn_[i];
				smokestarte_[i] =  hdsmokestarte_[i];
				smokestop_[i] =    hdsmokestop_[i];
               
        wght_[i] = hdwght_[i];
        heightft_[i] = hdheightft_[i];
        heightin_[i] = hdheightin_[i];
        
        bath_[i] =        hdbath_[i];     
        eat_[i] =         hdeat_[i];
        dress_[i] =       hddress_[i];
        walk_[i] =        hdwalk_[i];
        bed_[i] =         hdbed_[i];
        toilet_[i] =      hdtoilet_[i];
        bathhelp_[i] =    hdbathhelp_[i];
        eathelp_[i] =     hdeathelp_[i];
        dresshelp_[i] =   hddresshelp_[i];
        walkhelp_[i] =    hdwalkhelp_[i];
        bedhelp_[i] =     hdbedhelp_[i];
        toilethelp_[i] =  hdtoilethelp_[i];
                                           
        meals_[i] =       hdmeals_[i];
        shop_[i] =        hdshop_[i];
        money_[i] =       hdmoney_[i];
        phone_[i] =       hdphone_[i];
        hvyhswrk_[i] =    hdhvyhswrk_[i];
        lthswrk_[i] =     hdlthswrk_[i];
        mealstp_[i] =     hdmealstp_[i];
        shoptp_[i] =      hdshoptp_[i];
        moneytp_[i] =     hdmoneytp_[i];
        phonetp_[i] =     hdphonetp_[i];
        hvyhswrktp_[i] =  hdhvyhswrktp_[i];
        lthswrktp_[i] =   hdlthswrktp_[i];
        
        elderhome_[i]		=	hdelderhome_[i];
        eldertype_[i] 	=	hdeldertype_[i];
        region_[i]			=	hdregion_[i];
        
        educalt_[i]				=	hdeducalt_[i];
        
        parpoor_[i] 		=	hdparpoor_[i];
        
        chldhlth_[i] 	= hdchldhlth_[i];
        grewup_[i] = hdgrewup_[i];
        
        lgtexcfreq_[i] = hdlgtexcfreq_[i];
        lgtexcunit_[i] = hdlgtexcunit_[i];
        hvyexcfreq_[i] = hdhvyexcfreq_[i];
        hvyexcunit_[i] = hdhvyexcunit_[i];
        musclefreq_[i] = hdmusclefreq_[i];
        muscleunit_[i] = hdmuscleunit_[i];
        
        eatoutfs_[i] 			= hdeatoutfs_[i];
        eatoutfsunit_[i]	=	hdeatoutfsunit_[i];
        eatout_[i]				=	hdeatout_{i];
        eatoutunit_[i]		=	hdeatoutunit_[i];   
        
        workweeks_[i]			=  hdworkweeks_[i];	
        weekworkhr_[i]    =  hdweekworkhr_[i]; 
        overtimehr_[i]    =  hdovertimehr_[i];
        yrworkhr_[i]      =  hdyrworkhr_[i];   
        
        chldsrh_[i]         = hdchldsrh_[i]         ;
				chldmissschool_[i]  = hdchldmissschool_[i]  ;
				chldmeasles_[i]     = hdchldmeasles_[i]     ;
				chldmumps_[i]       = hdchldmumps_[i]       ;
				chldcknpox_[i]      = hdchldcknpox_[i]      ;
				chldvision_[i]      = hdchldvision_[i]      ;
				chldparsmk_[i]      = hdchldparsmk_[i]      ;
				chldasthma_[i]      = hdchldasthma_[i]      ;
				chlddiab_[i]        = hdchlddiab_[i]        ;
				chldresp_[i]        = hdchldresp_[i]        ;
				chldspeech_[i]      = hdchldspeech_[i]      ;
				chldallergy_[i]     = hdchldallergy_[i]     ;
				chldheart_[i]       = hdchldheart_[i]       ;
				chldear_[i]         = hdchldear_[i]         ;
				chldszre_[i]        = hdchldszre_[i]        ;
				chldmgrn_[i]        = hdchldmgrn_[i]        ;
				chldstomach_[i]     = hdchldstomach_[i]     ;
				chldhibp_[i]        = hdchldhibp_[i]        ;
				chlddepress_[i]     = hdchlddepress_[i]     ;
				chlddrug_[i]        = hdchlddrug_[i]        ;
				chldpsych_[i]       = hdchldpsych_[i]       ;
        
        strokeage_[i]							= hdstrokeage_[i]						 ;
        heartattackage_[i]        = hdheartattackage_[i]       ;
        heartdiseaseage_[i]       = hdheartdiseaseage_[i]      ;
        hypertensionage_[i]       = hdhypertensionage_[i]      ;
        asthmaage_[i]             = hdasthmaage_[i]            ;
        lungdiseaseage_[i]        = hdlungdiseaseage_[i]       ;
        diabetesage_[i]           = hddiabetesage_[i]          ;
        arthritisage_[i]          = hdarthritisage_[i]         ;
        memorylossage_[i]         = hdmemorylossage_[i]        ;
        learningdisorderage_[i]   = hdlearningdisorderage_[i]  ;
        cancerage_[i]             = hdcancerage_[i]            ;
        psychprobage_[i]          = hdpsychprobage_[i]          ;
        
        strokedays_[i]           =    hdstrokedays_[i]             ;
				strokemnth_[i]           =    hdstrokemnth_[i]             ;
				strokeweek_[i]           =    hdstrokeweek_[i]             ;
				strokeyear_[i]           =    hdstrokeyear_[i]             ;
				hibpdays_[i]             =    hdhibpdays_[i]               ;
				hibpmnth_[i]             =    hdhibpmnth_[i]               ;
				hibpweek_[i]             =    hdhibpweek_[i]               ;
				hibpyear_[i]             =    hdhibpyear_[i]               ;
				diabdays_[i]             =    hddiabdays_[i]               ;
				diabmnth_[i]             =    hddiabmnth_[i]               ;
				diabweek_[i]             =    hddiabweek_[i]               ;
				diabyear_[i]             =    hddiabyear_[i]               ;
				cancrdays_[i]            =    hdcancrdays_[i]              ;
				cancrmnth_[i]            =    hdcancrmnth_[i]              ;
				cancrweek_[i]            =    hdcancrweek_[i]              ;
				cancryear_[i]            =    hdcancryear_[i]              ;
				lungdays_[i]             =    hdlungdays_[i]               ;
				lungmnth_[i]             =    hdlungmnth_[i]               ;
				lungweek_[i]             =    hdlungweek_[i]               ;
				lungyear_[i]             =    hdlungyear_[i]               ;
				heartattackdays_[i]      =    hdheartattackdays_[i]        ;
				heartattackmnth_[i]      =    hdheartattackmnth_[i]        ;
				heartattackweek_[i]      =    hdheartattackweek_[i]        ;
				heartattackyear_[i]      =    hdheartattackyear_[i]        ;
				heartdiseasedays_[i]     =    hdheartdiseasedays_[i]       ;
				heartdiseasemnth_[i]     =    hdheartdiseasemnth_[i]       ;
				heartdiseaseweek_[i]     =    hdheartdiseaseweek_[i]       ;
				heartdiseaseyear_[i]     =    hdheartdiseaseyear_[i]       ;
				psychprobdays_[i]        =    hdpsychprobdays_[i]          ;
				psychprobmnth_[i]        =    hdpsychprobmnth_[i]          ;
				psychprobweek_[i]        =    hdpsychprobweek_[i]          ;
				psychprobyear_[i]        =    hdpsychprobyear_[i]          ;
				arthritisdays_[i]        =    hdarthritisdays_[i]          ;
				arthritismnth_[i]        =    hdarthritismnth_[i]          ;
				arthritisweek_[i]        =    hdarthritisweek_[i]          ;
				arthritisyear_[i]        =    hdarthritisyear_[i]          ;
				asthmadays_[i]           =    hdasthmadays_[i]             ;
				asthmamnth_[i]           =    hdasthmamnth_[i]             ;
				asthmaweek_[i]           =    hdasthmaweek_[i]             ;
				asthmayear_[i]           =    hdasthmayear_[i]             ;
				memorylossdays_[i]       =    hdmemorylossdays_[i]         ;
				memorylossmnth_[i]       =    hdmemorylossmnth_[i]         ;
				memorylossweek_[i]       =    hdmemorylossweek_[i]         ;
				memorylossyear_[i]       =    hdmemorylossyear_[i]         ;
				learningdisorderdays_[i] =    hdlearningdisorderdays_[i]   ;
				learningdisordermnth_[i] =    hdlearningdisordermnth_[i]   ;
				learningdisorderweek_[i] =    hdlearningdisorderweek_[i]   ;
				learningdisorderyear_[i] =    hdlearningdisorderyear_[i]   ;
        
        worklimit_[i] = hdworklimit_[i];
        
        respsadness_[i] = hdrespsadness_[i];
        respnervous_[i] = hdrespnervous_[i];
        resprestless_[i] = hdresprestless_[i];
        resphopeless_[i] = hdresphopeless_[i];
        respeffort_[i] = hdrespeffort_[i];
        respworthless_[i] = hdrespworthless_[i];
        respk6scale_[i] = hdrespk6scale_[i];
        
        statecode_[i] = hdstatecode_[i]; 
        
        respondent_[i] = hdrespondent_[i]; 
        
        alcohol_[i] = hdalcohol_[i];
        alcdrinks_[i] = hdalcdrinks_[i];        
        alcfreq_[i] = hdalcfreq_[i];
        alcbinge_[i] = hdalcbinge_[i];
             
        if resp_[i] = 1 then satisfaction_[i] = hdsatisfaction_[i];    
        
        conhous_[i] =        hdhous_[i];      
        confood_[i] =        hdfood_[i];      
        contran_[i] =        hdtran_[i];      
        conhealth_[i] =      hdhealth_[i];    
        contrips_[i] =       hdtrips_[i];     
        coned_[i] =          hded_[i];        
        concloth_[i] =       hdcloth_[i];     
        conothrec_[i] =      hdothrec_[i];    
        conchild_[i] =       hdchild_[i];     
         
             
        numinfu_[i] = hdnuminfu_[i];
        proptax_[i] = hproptax_[i];
        if 99998 <= proptax_[i] <= 99999 then proptax_[i] =.;
        
        
             if hdshlth_[i]=8 then srh_[i]=.D;
   	       else if hdshlth_[i]=9 then srh_[i]=.R;
   	       else if 1<=hdshlth_[i]<=5 then srh_[i]=hdshlth_[i];
   	       else srh_[i]=.M;  /* dont know why missing */  
             
         end;

         else if relhd_[i] in (2,20,22,88) then do;  /* WIFE */
             wife_[i] = 1;
             if relhd_[i] in (22,88) then do; 
             		cohab_[i] = 1;
             	end;
        
	      /* All wives/"wives" are either married or cohabitating */
             mstatalt_[i] = 1;
	      hdwf_[i] = 1;
             hdwfever = 1;

	      iwmonth_[i] = wfiwmonth_[i];
	      iwday_[i] = wfiwday_[i];
             iwyear_[i] = wfiwyear_[i];
		

        race_[i] = wfrace_[i];
 	      hispan_[i] = wfhispan_[i];
	      cancr_[i] = wfcancr_[i];
	      diab_[i] = wfdiab_[i];
        heart_[i] = wfheart_[i];        
        hearta_[i] = wfhearta_[i];																																		/* add heart attack variables */
        hibp_[i] = wfhibp_[i];
	      lung_[i] = wflung_[i];
        strok_[i] = wfstrok_[i];
        
        asthm_[i] = wfasthm_[i];
        
        
        cancrloc1_[i]   =  wfcancrloc1_[i] ; 
	 			cancrloc2_[i]   =  wfcancrloc2_[i]  ;
	 			cancrlimit_[i]  =  wfcancrlimit_[i] ;
	 			diablimit_[i]   =  wfdiablimit_[i]  ;
	 			heartlimit_[i]  =  wfheartlimit_[i] ;
	 			hibplimit_[i]   =  wfhibplimit_[i]  ;
	 			lunglimit_[i]   =  wflunglimit_[i]  ;
	 			heartalimit_[i] =  wfheartalimit_[i];
	 			stroklimit_[i]  =  wfstroklimit_[i] ;
               
        smoken_[i] = wfsmoken_[i];
        smokev_[i] = wfsmokev_[i];
        numcigsn_[i] =     wfnumcigsn_[i]; 
				numcigse_[i] =     wfnumcigse_[i]; 
				smokestartn_[i] =  wfsmokestartn_[i];
				smokestarte_[i] =  wfsmokestarte_[i];
				smokestop_[i] =    wfsmokestop_[i];
        wght_[i] = wfwght_[i];
        heightft_[i] = wfheightft_[i];
        heightin_[i] = wfheightin_[i];
             
             
        bath_[i] =        wfbath_[i];
        eat_[i] =         wfeat_[i];
        dress_[i] =       wfdress_[i];
        walk_[i] =        wfwalk_[i];
        bed_[i] =         wfbed_[i];
        toilet_[i] =      wftoilet_[i];
        bathhelp_[i] =    wfbathhelp_[i];
        eathelp_[i] =     wfeathelp_[i];
        dresshelp_[i] =   wfdresshelp_[i];
        walkhelp_[i] =    wfwalkhelp_[i];
        bedhelp_[i] =     wfbedhelp_[i];
        toilethelp_[i] =  wftoilethelp_[i];
                                           
        meals_[i] =       wfmeals_[i];
        shop_[i] =        wfshop_[i];
        money_[i] =       wfmoney_[i];
        phone_[i] =       wfphone_[i];
        hvyhswrk_[i] =    wfhvyhswrk_[i];
        lthswrk_[i] =     wflthswrk_[i];
        mealstp_[i] =     wfmealstp_[i];
        shoptp_[i] =      wfshoptp_[i];
        moneytp_[i] =     wfmoneytp_[i];
        phonetp_[i] =     wfphonetp_[i];
        hvyhswrktp_[i] =  wfhvyhswrktp_[i];
        lthswrktp_[i] =   wflthswrktp_[i];
             
        elderhome_[i]		=	wfelderhome_[i];
        eldertype_[i] 	=	wfeldertype_[i];
        region_[i]			=	wfregion_[i];     
        
       	educalt_[i]				=	wfeducalt_[i];
  			parpoor_[i] 			=	wfparpoor_[i];
       	chldhlth_[i] 			=	wfchldhlth_[i];
        grewup_[i] 				= wfgrewup_[i];      
        
        lgtexcfreq_[i] = wflgtexcfreq_[i];  
        lgtexcunit_[i] = wflgtexcunit_[i];  
        hvyexcfreq_[i] = wfhvyexcfreq_[i];  
        hvyexcunit_[i] = wfhvyexcunit_[i];  
        musclefreq_[i] = wfmusclefreq_[i];  
        muscleunit_[i] = wfmuscleunit_[i];  
        
        eatoutfs_[i] 			= wfeatoutfs_[i];
        eatoutfsunit_[i]	=	wfeatoutfsunit_[i];
        eatout_[i]				=	wfeatout_{i];
        eatoutunit_[i]		=	wfeatoutunit_[i];  
        
        workweeks_[i]			=  wfworkweeks_[i];	
        weekworkhr_[i]    =  wfweekworkhr_[i]; 
        overtimehr_[i]    =  wfovertimehr_[i]; 
        yrworkhr_[i]      =  wfyrworkhr_[i];   
        
        chldsrh_[i]         = wfchldsrh_[i]         ;
				chldmissschool_[i]  = wfchldmissschool_[i]  ;
				chldmeasles_[i]     = wfchldmeasles_[i]     ;
				chldmumps_[i]       = wfchldmumps_[i]       ;
				chldcknpox_[i]      = wfchldcknpox_[i]      ;
				chldvision_[i]      = wfchldvision_[i]      ;
				chldparsmk_[i]      = wfchldparsmk_[i]      ;
				chldasthma_[i]      = wfchldasthma_[i]      ;
				chlddiab_[i]        = wfchlddiab_[i]        ;
				chldresp_[i]        = wfchldresp_[i]        ;
				chldspeech_[i]      = wfchldspeech_[i]      ;
				chldallergy_[i]     = wfchldallergy_[i]     ;
				chldheart_[i]       = wfchldheart_[i]       ;
				chldear_[i]         = wfchldear_[i]         ;
				chldszre_[i]        = wfchldszre_[i]        ;
				chldmgrn_[i]        = wfchldmgrn_[i]        ;
				chldstomach_[i]     = wfchldstomach_[i]     ;
				chldhibp_[i]        = wfchldhibp_[i]        ;
				chlddepress_[i]     = wfchlddepress_[i]     ;
				chlddrug_[i]        = wfchlddrug_[i]        ;
				chldpsych_[i]       = wfchldpsych_[i]       ;
        
        strokeage_[i]							= wfstrokeage_[i]						 ;
        heartattackage_[i]        = wfheartattackage_[i]       ;
        heartdiseaseage_[i]       = wfheartdiseaseage_[i]      ;
        hypertensionage_[i]       = wfhypertensionage_[i]      ;
        asthmaage_[i]             = wfasthmaage_[i]            ;
        lungdiseaseage_[i]        = wflungdiseaseage_[i]       ;
        diabetesage_[i]           = wfdiabetesage_[i]          ;
        arthritisage_[i]          = wfarthritisage_[i]         ;
        memorylossage_[i]         = wfmemorylossage_[i]        ;
        learningdisorderage_[i]   = wflearningdisorderage_[i]  ;
        cancerage_[i]             = wfcancerage_[i]            ;
        psychprobage_[i]          = wfpsychprobage_[i]          ;
        
        strokedays_[i]           =    wfstrokedays_[i]             ;
				strokemnth_[i]           =    wfstrokemnth_[i]             ;
				strokeweek_[i]           =    wfstrokeweek_[i]             ;
				strokeyear_[i]           =    wfstrokeyear_[i]             ;
				hibpdays_[i]             =    wfhibpdays_[i]               ;
				hibpmnth_[i]             =    wfhibpmnth_[i]               ;
				hibpweek_[i]             =    wfhibpweek_[i]               ;
				hibpyear_[i]             =    wfhibpyear_[i]               ;
				diabdays_[i]             =    wfdiabdays_[i]               ;
				diabmnth_[i]             =    wfdiabmnth_[i]               ;
				diabweek_[i]             =    wfdiabweek_[i]               ;
				diabyear_[i]             =    wfdiabyear_[i]               ;
				cancrdays_[i]            =    wfcancrdays_[i]              ;
				cancrmnth_[i]            =    wfcancrmnth_[i]              ;
				cancrweek_[i]            =    wfcancrweek_[i]              ;
				cancryear_[i]            =    wfcancryear_[i]              ;
				lungdays_[i]             =    wflungdays_[i]               ;
				lungmnth_[i]             =    wflungmnth_[i]               ;
				lungweek_[i]             =    wflungweek_[i]               ;
				lungyear_[i]             =    wflungyear_[i]               ;
				heartattackdays_[i]      =    wfheartattackdays_[i]        ;
				heartattackmnth_[i]      =    wfheartattackmnth_[i]        ;
				heartattackweek_[i]      =    wfheartattackweek_[i]        ;
				heartattackyear_[i]      =    wfheartattackyear_[i]        ;
				heartdiseasedays_[i]     =    wfheartdiseasedays_[i]       ;
				heartdiseasemnth_[i]     =    wfheartdiseasemnth_[i]       ;
				heartdiseaseweek_[i]     =    wfheartdiseaseweek_[i]       ;
				heartdiseaseyear_[i]     =    wfheartdiseaseyear_[i]       ;
				psychprobdays_[i]        =    wfpsychprobdays_[i]          ;
				psychprobmnth_[i]        =    wfpsychprobmnth_[i]          ;
				psychprobweek_[i]        =    wfpsychprobweek_[i]          ;
				psychprobyear_[i]        =    wfpsychprobyear_[i]          ;
				arthritisdays_[i]        =    wfarthritisdays_[i]          ;
				arthritismnth_[i]        =    wfarthritismnth_[i]          ;
				arthritisweek_[i]        =    wfarthritisweek_[i]          ;
				arthritisyear_[i]        =    wfarthritisyear_[i]          ;
				asthmadays_[i]           =    wfasthmadays_[i]             ;
				asthmamnth_[i]           =    wfasthmamnth_[i]             ;
				asthmaweek_[i]           =    wfasthmaweek_[i]             ;
				asthmayear_[i]           =    wfasthmayear_[i]             ;
				memorylossdays_[i]       =    wfmemorylossdays_[i]         ;
				memorylossmnth_[i]       =    wfmemorylossmnth_[i]         ;
				memorylossweek_[i]       =    wfmemorylossweek_[i]         ;
				memorylossyear_[i]       =    wfmemorylossyear_[i]         ;
				learningdisorderdays_[i] =    wflearningdisorderdays_[i]   ;
				learningdisordermnth_[i] =    wflearningdisordermnth_[i]   ;
				learningdisorderweek_[i] =    wflearningdisorderweek_[i]   ;
				learningdisorderyear_[i] =    wflearningdisorderyear_[i]   ;
        
        worklimit_[i] = wfworklimit_[i];
  
        alcohol_[i] = wfalcohol_[i];
        alcdrinks_[i] = wfalcdrinks_[i];        
        alcfreq_[i] = wfalcfreq_[i];        
        alcbinge_[i] = wfalcbinge_[i];
        
        respsadness_[i] = wfrespsadness_[i];
        respnervous_[i] = wfrespnervous_[i];        
        resprestless_[i] = wfresprestless_[i];        
        resphopeless_[i] = wfresphopeless_[i];
        respeffort_[i] = wfrespeffort_[i];        
        respworthless_[i] = wfrespworthless_[i];
        respk6scale_[i] = wfrespk6scale_[i];      
        
        statecode_[i] = wfstatecode_[i]; 

				respondent_[i] = wfrespondent_[i]; 
          
        if resp_[i] = 1 then satisfaction_[i] = wfsatisfaction_[i];  
        
        conhous_[i] =        wfhous_[i];      
        confood_[i] =        wffood_[i];      
        contran_[i] =        wftran_[i];      
        conhealth_[i] =      wfhealth_[i];    
        contrips_[i] =       wftrips_[i];     
        coned_[i] =          wfed_[i];        
        concloth_[i] =       wfcloth_[i];     
        conothrec_[i] =      wfothrec_[i];    
        conchild_[i] =       wfchild_[i];       
        
        numinfu_[i] = wfnuminfu_[i];
        proptax_[i] = hproptax_[i];
        if 99998 <= proptax_[i] <= 99999 then proptax_[i] =.;
             
        if wfshlth_[i]=8 then srh_[i]=.D;
   	       else if wfshlth_[i]=9 then srh_[i]=.R;
   	       else if 1<=wfshlth_[i]<=5 then srh_[i]=wfshlth_[i];
   	       else srh_[i]=.M;  /* dont know why missing */    
          
      end;

      	

         else do;  /* set not head/wife to .H */
           srh_[i]=.H;
         end;
      end; /* people in FU */
      
      else inyr_[i]=0;
      
      
   end;  /* do i=1 to dim(seq_) */
   
   any_yr=max(of inyr_[*]);
    
   /* Only keep individuals who are ever heads or wives */
   if hdwfever = 1;
   
   if first.id then output proj.extract_data;
   
   label %labelyrv(srh,Self-report of health,begy=1999)
	  %labelyrv(head,Head in year,begy=1999)
	  %labelyrv(wife,Wife in year,begy=1999)
	  %labelyrv(cohab,Indicates wife is cohabitating in year,begy=1999)
	  %labelyrv(hdwf,Head or wife in year,begy=1999)
	  %labelyrv(race,Race of individual,begy=1999)
	  %labelyrv(hispan,Spanish descent,begy=1999)
    %labelyrv(mstath,marital status of head,begy=1999)
	  %labelyrv(famnum,Family Number,begy=1999)
    %labelyrv(seq,Year-specific sequence num,begy=1999)
    %labelyrv(inyr,Whether present in FU,begy=1999)
    %labelyrv(relhd,Relation to head,begy=1999)
    %labelyrv(diedyr,Died since last intervw,begy=1999)
    %labelyrv(died,Died anytime bef interview,begy=1999)
	  %labelyrv(mstatalt,Marital status - generated,begy=1999)	  
	  %labelyrv(mstatch,Change in marital status from previous period,begy=1999)												/* add marriage change variable */
    %labelyrv(cancr,Doctor told has/had cancer,begy=1999) 
	  %labelyrv(diab,Doctor told has/had diabetes,begy=1999) 
    %labelyrv(heart,Doctor told has/had heart disease angina or congestive heart failure,begy=1999)     
    %labelyrv(hearta,Doctor told has/had heart attack,begy=1999) 																			/* add heart attack variables */
    %labelyrv(hibp,Doctor told has/had high blood pressure,begy=1999) 
    %labelyrv(lung,Doctor told has/had chronic lung disease,begy=1999) 
    %labelyrv(strok,Doctor told has/had stroke,begy=1999) 
    %labelyrv(asthm,Doctor told has/had asthma,begy=1999) 
    
    %labelyrv(cancrloc1,Cancer location 1,begy=2005)
		%labelyrv(cancrloc2,Cancer location 2,begy=2005)
		%labelyrv(cancrlimit,Cancer limits normal activities,begy=1999)
		%labelyrv(diablimit,Diabetes limits normal activities,begy=1999)
		%labelyrv(heartlimit,Heart disease limits normal activities,begy=1999)
		%labelyrv(hibplimit,Hypertesion limits normal activities,begy=1999)
		%labelyrv(lunglimit,Lung disease limits normal activities,begy=1999)
		%labelyrv(heartalimit,Heart attack limits normal activities,begy=1999)
		%labelyrv(stroklimit,Stroke limits normal activities,begy=1999)
        
    %labelyrv(smoken,Current smoker,begy=1999) 
    %labelyrv(smokev,Ever smoked cigarettes,begy=1999) 
    %labelyrv(numcigsn,Average daily cigarettes for current smokers,begy=1999)
    %labelyrv(numcigse,Average daily cigarettes for former smokers,begy=1999)
    %labelyrv(smokestartn,Age started smoking for current smokers,begy=1999)
    %labelyrv(smokestarte,Age started smoking for former smokers,begy=1999)
    %labelyrv(smokestop,Age stopped smoking for former smokers,begy=1999)
    %labelyrv(wght,wght in pounds,begy=1999) 
    %labelyrv(heightft,Height - ft. portion,begy=1999) 
    %labelyrv(heightin,Height - in. portion,begy=1999) 
	  %labelyrv(iwmonth,Interview month,begy=1999)
	  %labelyrv(iwday,Interview day,begy=1999)
	  %labelyrv(iwyear,Interview year,begy=1999)     
	  %labelyrv(rabyear,Birth year,begy=1999)
	  %labelyrv(rabmonth,Birth month,begy=1999)
	  %labelyrv(crswght,Individual cross-sectional weight,begy=1999)
	  %labelyrv(resp,Respondent in year,begy=1999)
	  	  
	   %labelyrv(bath,ADL - trouble bathing,begy=1999)
	   %labelyrv(eat,ADL - trouble eating,begy=1999)
	   %labelyrv(dress,ADL - trouble dressing,begy=1999)
	   %labelyrv(walk,ADL - trouble walking,begy=1999)
	   %labelyrv(bed,ADL - trouble out of bed,begy=1999)
	   %labelyrv(toilet,ADL - trouble using toilet,begy=1999)
	   %labelyrv(bathhelp,gets help bathing,begy=1999)
	   %labelyrv(eathelp,gets help eating,begy=1999)
	   %labelyrv(dresshelp,gets help dressing,begy=1999)
	   %labelyrv(walkhelp,gets help walking,begy=1999)
	   %labelyrv(bedhelp,gets help out of bed,begy=1999)
	   %labelyrv(toilethelp,gets help with toilet,begy=1999)
	   %labelyrv(meals,IADL - trouble preparing meals,begy=1999)
	   %labelyrv(shop,IADL - trouble shopping for personal items or medicines,begy=1999)
	   %labelyrv(money,IADL - trouble managing money,begy=1999)
	   %labelyrv(phone,IADL - trouble using telephone,begy=1999)
	   %labelyrv(hvyhswrk,IADL - trouble with heavy housework,begy=1999)
	   %labelyrv(lthswrk,IADL - troublw with light housework,begy=1999)
	   %labelyrv(mealstp,is meal issue due to health/physical problem,begy=1999)
	   %labelyrv(shoptp,is shopping issue due to health/physical problem,begy=1999)
	   %labelyrv(moneytp,is money issue due to health/physical problem,begy=1999)
	   %labelyrv(phonetp,is telephone issue due to health/physical problem,begy=1999)
	   %labelyrv(hvyhswrktp,is heavy housework issue due to health/physical problem,begy=1999)
	   %labelyrv(lthswrktp,is light housework issue due to health/physical problem,begy=1999)
	   %labelyrv(parpoor,when you were growing up were your parents poor or well off,begy=1969)
	   %labelyrv(chldhlth,1-5 scale for self-reported health as a child starts in 2007,begy=1999)
	   %labelyrv(grewup,categorical variable of where head grew up - wife starts in 2009,begy=1999)
	   	%labelyrv(lgtexcfreq,Frequency of light exercise,begy=1999)  
			%labelyrv(lgtexcunit,Units for light exercise,begy=1999)  
			%labelyrv(hvyexcfreq,Frequency of heavy exercise,begy=1999)  
			%labelyrv(hvyexcunit,Units of heavy exercise,begy=1999)  
			%labelyrv(musclefreq,Frequency of strength exercise,begy=1999)  
			%labelyrv(muscleunit,Units of strength exercise,begy=1999)  
			%labelyrv(eatoutfs,Spending on eating out if on food stamps,begy=1999) 
			%labelyrv(eatoutfsunit,Time units for spending on eating out if on food stamps,begy=1999)
			%labelyrv(eatout,Spending on eating out,begy=1999)
			%labelyrv(eatoutunit,Time units for spending on eating out,begy=1999)
			%labelyrv(numinfu,Number of persons in the family unit,begy=1999)
			%labelyrv(proptax,Total household property tax,begy=1999)
			%labelyrv(workweeks,Total Weeks worked in previous year,begy=1999)
			%labelyrv(weekworkhr,Hours worked per week in previous year,begy=1999)
			%labelyrv(overtimehr,Total overtime hours in previous year,begy=1999)
			%labelyrv(yrworkhr,Total hours worked (includes overtime) in previous year,begy=1999)
			%labelyrv(strokeage,Age of stroke onset,begy=2005)
			%labelyrv(heartattackage,Age of heart attack onset,begy=2005)
			%labelyrv(heartdiseaseage,Age of heart disease onset,begy=2005)
			%labelyrv(hypertensionage,Age of hypertension onset,begy=2005)
			%labelyrv(asthmaage,Age of asthma onset,begy=2005)
			%labelyrv(lungdiseaseage,Age of lung disease onset,begy=2005)
			%labelyrv(diabetesage,Age of diabetes onset,begy=2005)
			%labelyrv(arthritisage,Age of arthritis onset,begy=2005)
			%labelyrv(memorylossage,Age of memory loss onset,begy=2005)
			%labelyrv(learningdisorderage,Age of learning disorder onset,begy=2005)
			%labelyrv(cancerage,Age of cancer onset,begy=2005)
			%labelyrv(psychprobage,Age of psychological problem onset,begy=2005)
			%labelyrv(worklimit,Physical or nervous condition that limits the type or amount of work,begy=1999)
			%labelyrv(respsadness,Sadness in last 30 days,begy=2001)
			%labelyrv(respnervous,Nervous in last 30 days,begy=2001)
			%labelyrv(resprestless,Restless in last 30 days,begy=2001)
			%labelyrv(resphopeless,Hopeless in last 30 days,begy=2001)
			%labelyrv(respeffort,Everything was an effort in last 30 days,begy=2001)
			%labelyrv(respworthless,Worthless in last 30 days,begy=2001)
			%labelyrv(respk6scale,K6 Scale,begy=2001)
			%labelyrv(statecode,State,begy=1999)
			%labelyrv(respondent,Respondent,begy=1999)
			%labelyrv(alcohol,Drinks alcoholic beverages,begy=1999)
			%labelyrv(alcdrinks,Number of alcoholic beverages,begy=1999)
			%labelyrv(alcfreq,Frequency of alcoholic beverages,begy=2005)
			%labelyrv(alcbinge,Days with 5 (male) or 4 (female) drinks in past year,begy=2005)
			%labelyrv(conhous,Household housing expenditures in past year,begy=2015)
			%labelyrv(confood,Household food expenditures in past year,begy=2015)
			%labelyrv(contran,Household transportation expenditures in past year,begy=2015)
			%labelyrv(conhealth,Household health expenditures in past year,begy=2015)
			%labelyrv(contrips,Household trip expenditures in past year,begy=2015)
			%labelyrv(coned,Household education expenditures in past year,begy=2015)
			%labelyrv(concloth,Household clothing expenditures in past year,begy=2015)
			%labelyrv(conothrec,Household other recreation expenditures in past year,begy=2015)
			%labelyrv(conchild,Household childcare expenditures in past year,begy=2015)
						   
	  ;
    drop yr year i _died _1969 - _1997 _1999 _2001 _2003 _2005 _2007;
   rename crswght99=weight99 crswght01=weight01 crswght03=weight03 crswght05=weight05 crswght07=weight07 crswght09=weight09 crswght11=weight11 crswght13=weight13 crswght15=weight15; 
   
run;

proc print data=probs (obs=10);
title2 problems - missing ID or duplicate ID;
run;
proc means data=proj.extract_data;
   title2 Checking famnum ids;
   var famnum: &famfid ;
   run;
proc freq data=proj.extract_data;
   table dupid any_yr relhd99*srh99 relhd09*srh09
         inyr: srh: died: seq:
      /missing list;
run;
proc contents data=proj.extract_data;

run;

proc means data=proj.extract_data;
   run;

endsas;







