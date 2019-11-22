/* 
Recode demographic variables to dummy variables:

x	Race:  hispan, black, white
(Education is now in its own .sas file "recode_education.sas")
x	Gender: male
???	Marital status: married, widowed, single
*/


%include "setup.inc";
%include "&maclib.psidget.mac";  /* macro to get early release data */ 
%include "&maclib.renyrv.mac";  /* macro to rename variables */



data proj.demographics;
	set proj.extract_data (keep= id race: hispan: educyr: sex mstatch: hdwf: wife: mstatalt: rabmonth: rabyear: age: iwmonth: iwday: iwyear: inyr: parpoor: grewup: ) ;

	/* create race dummy variables */
	hispan = .;
	white = .;
	black = .;
	other = .;

	/* Define race arrays */
	array race_[*] %listyrv(race,begy=1999);
	array hispan_[*] %listyrv(hispan,begy=1999);

	/* Assign dummy variables */
	/* hispanic loop */
	do i = dim(hispan_) to 1 by -1 while (hispan = .);
		if hispan_[i] ge 1 and hispan_[i] le 7 then hispan = 1;
		if hispan_[i] = 0 then hispan = 0;
		/* kludge to look at race question for years when hispanic question not asked */
		if i < 4 then do;
			if race_[i] = 5 then hispan = 1;
			if race_[i] ge 1 and race_[i] le 5 then hispan = 0;
			if race_[i] ge 6 and race_[i] le 7 then hispan = 0;
		end;
	end;

	/* set hispan to 0 if missing */
	if hispan = . then do;
		hispan = 0;
		hispan_miss = 1;
	end;

	/* Make sure white, black, and other are non-hispanic only */
	if hispan = 1 then white = 0;
	if hispan = 1 then black = 0;
	if hispan = 1 then other = 0;

	/* race loop */
	do i = dim(race_) to 1 by -1 while (white = .);
		if race_[i] = 1 then white = 1;
		if race_[i] ge 2 and race_[i] le 7 then white = 0;
	end;
	do i = dim(race_) to 1 by -1 while (black = .);
		if race_[i] = 2 then black = 1;
		if race_[i] = 1 then black = 0;
		if race_[i] ge 3 and race_[i] le 7 then black = 0;
	end;
	do i = dim(race_) to 1 by -1 while (other = .);
		if race_[i] ge 3 and race_[i] le 7 then other = 1;
		if race_[i] ge 1 and race_[i] le 2 then other = 0;
	end;

	/* set race to other if missing */
	if white = . and black = . and other = . then do;
		white = 0;
		black = 0;
		other = 1;
		race_miss = 1;
	end;


	/* Male dummy */
	if sex = 1 then male = 1;
	else if sex = 2 then male = 0;


	/* Marital status using "Marital Status - Generated" (married/cohabitating are not distinguished) */
	array mstatalt_[*] %listyrv(mstatalt,begy=1999);	
	array mstath_[*] %listyrv(mstath,begy=1999); 
	array mstatch_[*] %listyrv(mstatch,begy=1999);																											/* add array for marriage change variable */
	array mstat_imp_[*] %listyrv(mstat_imp,begy=1999);																									/* add array for marriage status imputation */
	array mstat_miss_[*] %listyrv(mstat_miss,begy=1999);																									/* add array for marriage status imputation */
		
	/* Need yearly variables for each dummy */
	
	array married_[*] %listyrv(married,begy=1999);
	array widowed_[*] %listyrv(widowed,begy=1999);
	array single_[*] %listyrv(single,begy=1999);

	do i = 1 to dim(mstatalt_);
		if mstatalt_[i] = 1 then do;
			married_[i] = 1;
			widowed_[i] = 0;
			single_[i] = 0;
		end;
		if mstatalt_[i] = 3 then do; 
			married_[i] = 0;
			widowed_[i] = 1;
			single_[i] = 0;
		end;
		if mstatalt_[i] = 2 then do;
			married_[i] = 0;
			widowed_[i] = 0;
			single_[i] = 1;
		end;
		if mstatalt_[i] = 4 then do; 
			married_[i] = 0;
			widowed_[i] = 0;
			single_[i] = 1;
		end;
		if mstatalt_[i] = 5 then do; 	
			married_[i] = 0;
			widowed_[i] = 0;
			single_[i] = 1;
		end;
	end;

/*
marstatch (2009)
1 2007 head and wife/"wife" or head and husband of head remained married to each other in 2009 
2 2007 head remained unmarried (single, separated, widowed, divorced) in 2009. There was no wife,"wife" or husband in FU in either year 
3 2007 head and wife/"wife" or head and husband of head were married in 2007; 2009 head is one of these two individuals and divorced or separated 
4 2007 head and wife/"wife" or head and husband of head were married in 2007; 2009 head is one of these two individuals and is widowed 
5 2007 head was unmarried (i.e. no spouse present) in 2007 but was married by 2009 and has either stayed head or become wife/"wife" or husband of head for 2009 
6 2007 head and wife/"wife" or head and husband of head were married in 2007, became divorced and married someone by 2009 
7 2007 head and wife/"wife" or head and husband of head were married in 2007, became widowed and remarried by 2009 
8 Other, including all splitoffs except those who were either head or wife/"wife" in 2007; recontact family 
*/	

/* correct missing marriage status using change variable */
	do i = 1 to dim(mstatalt_)-1;
		if mstatalt_[i] = 9 or mstatalt_[i] = . then do; 
			if mstatch_[i+1] = 1 then do;
				married_[i] = 1;
				widowed_[i] = 0; 
				single_[i] = 0;
				mstat_imp_[i] = 1;
			end;
			else if mstatch_[i+1] = 2 then do;
				married_[i] = 0; 
				widowed_[i] = 0; 
				single_[i] = 1;
				mstat_imp_[i] = 1;
			end;	
		end;
	end;
	if mstatalt_[7] = 9 then do;
		if 5 le mstatch_[7] le 6 then do;
			married_[7] = 1; 
			widowed_[7] = 0; 
			single_[7] = 0;
			mstat_imp_[7] = 1;
		end;
	end;

/* assign missing marriage status using next or last period */
	do i = 2 to dim(mstatalt_);
		if married_[i] = . and widowed_[i] = . and single_[i] = . then do;
			married_[i] = married_[i-1];
			widowed_[i] = widowed_[i-1];
			single_[i] = single_[i-1];
			mstat_miss_[i] = 1;
		end;
	end;
	do i = dim(mstatalt_)-1 to 1 by -1;
		if married_[i] = . and widowed_[i] = . and single_[i] = . then do;
			married_[i] = married_[i+1];
			widowed_[i] = widowed_[i+1];
			single_[i] = single_[i+1];
			mstat_miss_[i] = 1;
		end;
	end;
	
/* if marriage status is still missing assign to single */
	do i = 1 to dim(mstatalt_);
		if married_[i] = . and widowed_[i] = . and single_[i] = . then do;
			married_[i] = 0;
			widowed_[i] = 0;
			single_[i] = 1;
			mstat_miss_[i] = 1;
		end;
	end;

	/* Assign a 'correct' birth month and birth year */
	array rabmonth_[*] %listyrv(rabmonth,begy=1999);
	array rabyear_[*] %listyrv(rabyear,begy=1999);
	
	bmonth = .;
	byear = .;	

	do i = dim(rabmonth_) to 1 by -1 while (bmonth = .);
		if rabmonth_[i] ge 1 and rabmonth_[i] le 12 then bmonth = rabmonth_[i];
	end;

	do i = dim(rabyear_) to 1 by -1 while (byear = .);
		if rabyear_[i] ge 1870 and rabyear_[i] < 9999 then byear = rabyear_[i];
	end;

birthdt= mdy(bmonth,15,byear);

/* Interview date */
array iwdt_[*] %listyrv(iwdt,begy=1999);
array iwmonth_[*] %listyrv(iwmonth,begy=1999);
array iwday_[*] %listyrv(iwday,begy=1999);
array iwyear_[*] %listyrv(iwyear,begy=1999);

do i = 1 to dim(iwdt_);
		iwdt_[i]=mdy(iwmonth_[i],iwday_[i],iwyear_[i]);
	end;
	
array aged_[*] %listyrv(aged,begy=1999);

do i = 1 to dim(aged_);
		aged_[i]=intck("month",birthdt,iwdt_[i])/12;
	end;

/* impute age if interview was skipped */

array age_[*] %listyrv(age,begy=1999); 
array age_imp_[*] %listyrv(age_imp,begy=1999); 

do i = dim(age_) to 2 by -1;
		if (14 le age_[i] le 120) & (age_[i-1] lt 14 or age_[i-1] gt 120) then do;
			age_[i-1] = age_[i]-2; 
			if age_imp_[i-1] = . then age_imp_[i-1]=1;
		end;
	end;
do i = 1 to dim(age_)-1;
		if (14 le age_[i] le 120) & (age_[i+1] lt 14 or age_[i+1] gt 120) then do; 
			age_[i+1] = age_[i]+2;
			if age_imp_[i+1] = . then age_imp_[i+1] = 1;
		end;
	end;
	
	
	/* Assign economic status when growing up */
	array parpoor_[*] %listyrv(parpoor,begy=1999);
	do i = dim(parpoor_) to 1 by -1 while (childses = .) ;
		if parpoor_[i] = 1 then childses = 1;
		else if parpoor_[i] = 3 then childses = 2;
		else if parpoor_[i] = 5 then childses = 3;
	end;

		/* Assign childhood SES for missing values */
			if childses = . then do;
				childses = 2;
				childses_miss = 1;
			end;	
				
 	/* Location grew up */
 	array grewup_[*] %listyrv(grewup,begy=1999);
 	do i = dim(grewup_) to 1 by -1 while (grewup = .);
 		if grewup_[i] = 0 then grewup = .;
 		else if 1 <= grewup_[i] <= 4 then grewup = grewup_[i] ;
 		else if grewup_[i] = 9 then grewup = .;
 	end;
 		
	
/* Variables to keep */
keep id hispan white black other male married: widowed: single: bmonth byear aged: age: iwdt: inyr: hdwf: mstatalt: mstatch: childses grewup 
		 hispan_miss race_miss mstat_imp: mstat_miss: childses_miss;



run;

proc contents data=proj.demographics;

run;

proc freq data=proj.demographics;
 tables hispan white black other;

 tables married99 widowed99 single99;
 
 tables married09 widowed09 single09;             

run;

