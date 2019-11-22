/* 
Recode health variables to dummy variables:

	Self-reported health: srh (categorical, 1-5), shlt (binary 0 = E/VG/G, 1 = F/P 
	Mortality: died


SEE healtheasurex.xls FOR FULL LIST OF PSID HEALTH MEASURES
 	To be consistent with HRS, eventually want to include: 
		cancre, diabe, hearte, hibpe, lunge, stroke
		variables on ADL and IADL
		smoke now, smoke ever
		obese, overwt, underwt, BMI
		
		1/30/13 -	Recoding died based on death year and sequence number
*/

%include "setup.inc";
%include "&maclib.psidget.mac";  /* macro to get early release data */ 
%include "&maclib.renyrv.mac";  /* macro to rename variables */
%include "&maclib.recode_absorb.mac";  /* macro to recode 1,5,8,9 type variables with absorbing state (once 1, always 1) */
%include "&maclib.severity.mac"; /* macro to recode normal limitations from diseases */
%include "&maclib.onset.mac"; /* Macro to create onset dummy variables - takes condition and age as input, returns dummy variable */

data proj.health;
	set proj.extract_data (keep=id srh: died: inyr: diedyr: cancr: diab: heart: hibp: lung: strok: smoken: smokev: wght: heightft: heightin: seq: deathyr chldhlth: 
	lgtexcfreq: lgtexcunit: hvyexcfreq: hvyexcunit: musclefreq: muscleunit: eatout: numinfu: age:
	numcigsn: numcigse: smokestartn: smokestarte: smokestop:
	cancrloc1: cancrloc2: 
	cancrlimit: diablimit: heartlimit: hibplimit: lunglimit: heartalimit: stroklimit:	
	strokeage: heartattackage: heartdiseaseage: hypertensionage: asthmaage: lungdiseaseage: 
	diabetesage: arthritisage: memorylossage: learningdisorderage: cancerage: psychprobage:
	strokedays: strokemnth: strokeweek: strokeyear:            
	hibpdays: hibpmnth: hibpweek: hibpyear: 
	diabdays: diabmnth: diabweek: diabyear: 
	cancrdays: cancrmnth: cancrweek: cancryear: 
	lungdays: lungmnth: lungweek: lungyear: 
	heartattackdays: heartattackmnth: heartattackweek: heartattackyear: 
	heartdiseasedays: heartdiseasemnth: heartdiseaseweek: heartdiseaseyear: 
	psychprobdays: psychprobmnth: psychprobweek: psychprobyear: 
	arthritisdays: arthritismnth: arthritisweek: arthritisyear: 
	asthmadays: asthmamnth: asthmaweek: asthmayear: 
	memorylossdays: memorylossmnth: memorylossweek: memorylossyear: 
	learningdisorderdays: learningdisordermnth: learningdisorderweek: learningdisorderyear: 
	resp:
	alcohol: alcdrinks: alcfreq: asthm: alcbinge:
	satisfaction:
	);

	array age_[*] %listyrv(age,begy=1999); 
	array age_imp_[*] %listyrv(age_imp,begy=1999); 
	
/* impute age if interview was skipped */
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
	
	array shlt_[*] %listyrv(shlt,begy=1999);
	array srh_[*] %listyrv(srh,begy=1999);
	array inyr_[*] %listyrv(inyr,begy=1999);
	
	/* Self-reported health before age 17 */
	do i = 1 to dim(srh_);
		if srh_[i] = 0 then srh_[i] = .;
		else if srh_[i] = 8 then srh_[i] = .;
		else if srh_[i] = 9 then srh_[i] = .;
		else if srh_[i] = 5 then srh_[i] = 1; /* Poor */
		else if srh_[i] = 4 then srh_[i] = 2; /* Fair */
		else if srh_[i] = 3 then srh_[i] = 3; /* Good */
		else if srh_[i] = 2 then srh_[i] = 4; /* Very good */
		else if srh_[i] = 1 then srh_[i] = 5; /* Excellent */
	end;
	
	
	do i=1 to dim(shlt_);
		if 3 le srh_[i] le 5 then shlt_[i] = 0;
		else if 1 le srh_[i] le 2 then shlt_[i] = 1; 
	end;
	label %labelyrv(srh,Self-report of health 1 = fair 5 = excellent,begy=1999);
	label %labelyrv(shlt,Binary self-report of health 1 = fair/poor,begy=1999);

	/* Generate BMI and obese, overwt, underwt binary variables */
	array bmi_[*] %listyrv(bmi,begy=1999);
	array wght_[*] %listyrv(wght,begy=1999);
	array heightft_[*] %listyrv(heightft,begy=1999);
	array heightin_[*] %listyrv(heightin,begy=1999);
	array totalheight_[*] %listyrv(totalheight,begy=1999);
	array underwt_[*] %listyrv(underwt,begy=1999);
	array overwt_[*] %listyrv(overwt,begy=1999);
	array obese_[*] %listyrv(obese,begy=1999);
	
	/* set up variables for impuation */
	array wght_bwd_[*] %listyrv(wght_bwd,begy=1999);
	array wght_fwd_[*] %listyrv(wght_fwd,begy=1999);
	array wght_imp_[*] %listyrv(wght_imp,begy=1999);
	array totalheight_imp_[*] %listyrv(totalheight_imp,begy=1999);
	array bmi_miss_[*] %listyrv(bmi_miss,begy=1999);

	/*
	do i = 1 to dim(totalheight_);
		if (4 le heightft_[i] le 7) & (0 le heightin_[i] le 11) then totalheight_[i] = 12*heightft_[i]+heightin_[i];
		else totalheight_[i] = .m;
	end;
	*/
	
/* replace missing total height with average total height when respondent older than 20 */
	do i = 1 to dim(totalheight_);
		if (4 le heightft_[i] le 7) & (0 le heightin_[i] le 11) & age_[i] ge 20 then totalheight_[i] = 12*heightft_[i]+heightin_[i];
		else totalheight_[i] = .;
	end;
	totalheight_avg = mean(of totalheight99 -- totalheight11);
	do i = 1 to dim(totalheight_);
		if totalheight_[i] = . & (48 le totalheight_avg le 95) & age_[i] ge 20 then do;
			totalheight_[i] = totalheight_avg;
			totalheight_imp_[i] = 1;
			end;
	end;

/* average if between two values, carry forward or back if not */
	do i = 1 to dim(wght_);
		if (70 le wght_[i] le 500) then do;
			wght_bwd_[i] = wght_[i];
			wght_fwd_[i] = wght_[i];
			end;
		else wght_[i] = .;
	end; 
	/* carry backward */
	do i = dim(wght_) to 2 by -1;
		if wght_bwd_[i-1] = . & (70 le wght_bwd_[i] le 500) then wght_bwd_[i-1] = wght_bwd_[i];
	end;	
	/* carry forward */
	do i = 1 to dim(wght_)-1;
		if wght_fwd_[i+1] = . & (70 le wght_fwd_[i] le 500) then wght_fwd_[i+1] = wght_fwd_[i];
	end;
	/* fill in weight using imputed variables */
	do i = 1 to dim(wght_);
		if wght_[i] = . & (70 le wght_bwd_[i] le 500) & (70 le wght_fwd_[i] le 500) then do;
			wght_[i] = mean(wght_bwd_[i],wght_fwd_[i]);
			wght_imp_[i] = 1;
			end;
		if wght_[i] = . & (70 le wght_bwd_[i] le 500) & wght_fwd_[i] = . then do;
			wght_[i] = wght_bwd_[i];
			wght_imp_[i] = 1;
			end;			
		if wght_[i] = . & wght_bwd_[i] = . & (70 le wght_fwd_[i] le 500) then do;
			wght_[i] = wght_fwd_[i];
			wght_imp_[i] = 1;
			end;		
	end;
	
/* use imputed height and weight to calculate BMI */
		do i = 1 to dim(bmi_);	
		*if (70 le wght_[i] le 500) then bmi_[i] = 703*wght_[i]/(totalheight_[i]*totalheight_[i]);
		*else bmi_[i] = .m;
		if (70 le wght_[i] le 500) then bmi_[i] = 703*wght_[i]/(totalheight_avg*totalheight_avg);
		else if age_[i] ge 20 then do;
			bmi_[i] = 27.593;
			bmi_miss_[i] = 1;
		end;
				
		if  0 < bmi_[i] < 18.5 then underwt_[i] = 1;
		else if (bmi_[i] ge 18.5) then underwt_[i] = 0;
		
		if bmi_[i] ge 25 and bmi_[i] < 30 then overwt_[i] = 1;
		else if (0 le bmi_[i] < 25) or (bmi_[i] ge 30) then overwt_[i] = 0;
		
		if bmi_[i] ge 30 then obese_[i] = 1;
		else if (0 le bmi_[i] < 30) then obese_[i] = 0;
	end;

	
	/* Recode death by using both death year and sequence number */
	array deathyr_[*] %listyrv(deathyr,begy=1999);
	/* initialize zeros */
	do i = 1 to dim(deathyr_);
		deathyr_[i] = 0;
	end;
		
	/* Deal with interview years - if interviewd, death is attributed to next wave */
	if deathyr = 1999 then do;
		if seq99 = 0 then deathyr99 = 1;
		else if (81<=seq99<=89) then deathyr99 = 1;
		else if (0<=seq99<=80) then deathyr01 = 1;
	end;
	if deathyr = 2001 then do;
		if seq01 = 0 then deathyr01 = 1;
		else if (81<=seq01<=89) then deathyr01 = 1;
		else if (0<=seq01<=80) then deathyr03 = 1;
	end; 
	if deathyr = 2003 then do;
		if seq03 = 0 then deathyr03 = 1;
		else if (81<=seq03<=89) then deathyr03 = 1;
		else if (0<=seq03<=80) then deathyr05 = 1;
	end;
	if deathyr = 2005 then do;
		if seq05 = 0 then deathyr05 = 1;
		else if (81<=seq05<=89) then deathyr05 = 1;
		else if (0<=seq05<=80) then deathyr07 = 1;
	end;
	if deathyr = 2007 then do;
		if seq07 = 0 then deathyr07 = 1;
		else if (81<=seq07<=89) then deathyr07 = 1;
		else if (0<=seq07<=80) then deathyr09 = 1;
	end;
	if deathyr = 2009 then do;
		if seq09 = 0 then deathyr09 = 1;
		else if (81<=seq09<=89) then deathyr09 = 1;
		else if (0<=seq09<=80) then deathyr11 = 1;
	end;
	if deathyr = 2011 then do;
		if seq11 = 0 then deathyr11 = 1;
		else if (81<=seq11<=89) then deathyr11 = 1;
		else if (0<=seq11<=80) then deathyr13 = 1;
	end;
	if deathyr = 2013 then do;
		if seq13 = 0 then deathyr13 = 1;
		else if (81<=seq13<=89) then deathyr13 = 1;
		else if (0<=seq13<=80) then deathyr15 = 1;
	end;
	if deathyr = 2015 then do;
		if seq15 = 0 then deathyr13 = 1;
		else if (81<=seq15<=89) then deathyr15 = 1;
	end;
	
	
	
	/* Deal with even years - death is attributed to next wave */	
	if deathyr = 2000 then deathyr01 = 1;
	if deathyr = 2002 then deathyr03 = 1;
	if deathyr = 2004 then deathyr05 = 1;
	if deathyr = 2006 then deathyr07 = 1;
	if deathyr = 2008 then deathyr09 = 1;
	if deathyr = 2010 then deathyr11 = 1;
	if deathyr = 2012 then deathyr13 = 1;
	if deathyr = 2014 then deathyr15 = 1;

	array cancr_[*] %listyrv(cancr,begy=1999);
	array cancre_imp_[*] %listyrv(cancre_imp,begy=1999);
	array cancre_miss_[*] %listyrv(cancre_miss,begy=1999);
	array diab_[*] %listyrv(diab,begy=1999);
	array diabe_imp_[*] %listyrv(diabe_imp,begy=1999);
	array diabe_miss_[*] %listyrv(diabe_miss,begy=1999);
	array heart_[*] %listyrv(heart,begy=1999);	
	array hearta_[*] %listyrv(hearta,begy=1999);																												/* add heart attack variables */
	array heart_old_[*] %listyrv(heart_old,begy=1999);
	array heart_imp_[*] %listyrv(heart_imp,begy=1999);
	array hearte_imp_[*] %listyrv(hearte_imp,begy=1999);
	array hearte_miss_[*] %listyrv(hearte_miss,begy=1999);
	array hibp_[*] %listyrv(hibp,begy=1999);
	array hibpe_imp_[*] %listyrv(hibpe_imp,begy=1999);
	array hibpe_miss_[*] %listyrv(hibpe_miss,begy=1999);
	array lung_[*] %listyrv(lung,begy=1999);
	array lunge_imp_[*] %listyrv(lunge_imp,begy=1999);
	array lunge_miss_[*] %listyrv(lunge_miss,begy=1999);
	array strok_[*] %listyrv(strok,begy=1999);
	array stroke_imp_[*] %listyrv(stroke_imp,begy=1999);
	array stroke_miss_[*] %listyrv(stroke_miss,begy=1999);
	
	array asthm_[*] %listyrv(asthm,begy=1999);
	array asthme_imp_[*] %listyrv(asthme_imp,begy=1999);
	array asthme_miss_[*] %listyrv(asthme_miss,begy=1999);
	
	
	
	 array cancrloc1_[*] _1999 _2001 _2003 %listyrv(cancrloc1,begy=2005); 
	 array cancrloc2_[*] _1999 _2001 _2003 %listyrv(cancrloc2,begy=2005);  
	 array cancrlimit_[*] %listyrv(cancrlimit,begy=1999);          
	 array diablimit_[*] %listyrv(diablimit,begy=1999);                  
	 array heartlimit_[*] %listyrv(heartlimit,begy=1999);       
	 array hibplimit_[*] %listyrv(hibplimit,begy=1999);      
	 array lunglimit_[*] %listyrv(lunglimit,begy=1999);       
	 array heartalimit_[*] %listyrv(heartalimit,begy=1999);       
	 array stroklimit_[*] %listyrv(stroklimit,begy=1999);     
	 
	 array skincanc_[*] %listyrv(skincanc,begy=1999);
		
	array smoken_[*] %listyrv(smoken,begy=1999);
	array smoken_miss_[*] %listyrv(smoken_miss,begy=1999);
	array smokev_[*] %listyrv(smokev,begy=1999);
	array smokev_imp_[*] %listyrv(smokev_imp,begy=1999);
	array smokev_miss_[*] %listyrv(smokev_miss,begy=1999);
	array numcigsn_[*] %listyrv(numcigsn,begy=1999);     
  array numcigse_[*] %listyrv(numcigse,begy=1999);    
  array smokestartn_[*] %listyrv(smokestartn,begy=1999);
	array smokestarte_[*] %listyrv(smokestarte,begy=1999);
	array smokestop_[*] %listyrv(smokestop,begy=1999);
	array yearssmoked_[*] %listyrv(yearssmoked,begy=1999);	
	array numcigs_[*]		%listyrv(numcigs,begy=1999);  
	array packyears_[*] %listyrv(packyears,begy=1999);
		
	do i = 1 to dim(smoken_);
		/* Recode to 0/1 */
		if smoken_[i] = 0 then smoken_[i] = .;
		else if smoken_[i] = 8 then smoken_[i] = .;
		else if smoken_[i] = 9 then smoken_[i] = .;
		else if smoken_[i] = 5 then smoken_[i] = 0;
		
		if smokev_[i] = 0 then smokev_[i] = .;
		else if smokev_[i] = 8 then smokev_[i] = .;
		else if smokev_[i] = 9 then smokev_[i] = .;
		else if smokev_[i] = 5 then smokev_[i] = 0;
		
		/* Fill in Ever smoked if current smoker */
		if smoken_[i] = 1 then smokev_[i] = 1;	 
	end;
	
	/* Number of cigarettes */
	do i = 1 to dim(numcigsn_);
			/* clean up missing values of number of cigarettes for current smokers*/
			if numcigsn_[i] = 0 then numcigsn_[i] = .;
			else if numcigsn_[i] = 998 then numcigsn_[i] = .;
			else if numcigsn_[i] = 999 then numcigsn_[i] = .;
			
			/* clean up missing values of number of cigarettes for former smokers*/
			if numcigse_[i] = 0 then numcigse_[i] = .;
			else if numcigse_[i] = 998 then numcigse_[i] = .;
			else if numcigse_[i] = 999 then numcigse_[i] = .;
	end;
	
	/* Smoking start age */
	do i = 1 to dim(smokestartn_);
			/* clean up missing values of smoking start age for current smokers */
			if smokestartn_[i] = 0 then smokestartn_[i] = .;
			else if smokestartn_[i] = 98 then smokestartn_[i] = .;
			else if smokestartn_[i] = 99 then smokestartn_[i] = .;
			
			/* clean up missing values of smoking start age for former smokers */
			if smokestarte_[i] = 0 then smokestarte_[i] = .;
			else if smokestarte_[i] = 98 then smokestarte_[i] = .;
			else if smokestarte_[i] = 99 then smokestarte_[i] = .;
	end;
	
	/* Smoking stop age */
	do i = 1 to dim(smokestop_);
			/* clean up missing values of smoking stop age for former smokers */
			if smokestop_[i] = 0 then smokestop_[i] = .;
			else if smokestop_[i] = 98 then smokestop_[i] = .;
			else if smokestop_[i] = 99 then smokestop_[i] = .;
	end;
	
	/* Calculate years smoked and average cigarettes */
	do i = 1 to dim(yearssmoked_);
			/* For current smokers */
			if smoken_[i] = 1 then do;
				yearssmoked_[i] = age_[i] - smokestartn_[i];
				numcigs_[i] = numcigsn_[i];
			end;
			
			/* for former smokers */
			if smoken_[i] = 0 and smokev_[i] = 1 then do;
				yearssmoked_[i] = smokestop_[i] - smokestarte_[i];
				numcigs_[i] = numcigse_[i];
			end;
	end;
	
	array smokestartall_[*] %listyrv(smokestarte,begy=1999) %listyrv(smokestartn,begy=1999);
	smokestartmed = median(of smokestartall_[*]);
	
	
	drop numcigse: numcigsn:;
	
	/* Create pack-years measure: 20 cigarettes in a pack
	(1 pack/day for a year is 1 pack year, 2 packs/day for 10 years is 20 pack-years) */
	do i = 1 to dim(packyears_);
			if smokev_[i] = 0 then packyears_[i] = 0;
			else packyears_[i] = (numcigs_[i]/20)*yearssmoked_[i];	
	end;
	
	/* Alcohol use variables:  any use, number of drinks, frequency of drinking */
	
	array alcohol_[*] %listyrv(alcohol,begy=1999);
	array alcdrinks_[*] %listyrv(alcdrinks,begy=1999);
	array alcfreq_[*] _1999 _2001 _2003 %listyrv(alcfreq,begy=2005);	
	array alcbinge_[*] _1999 _2001 _2003 %listyrv(alcbinge,begy=2005);	
	
	do i = 1 to dim(alcohol_);
		/* Recode to 0/1 */
		if alcohol_[i] = 0 then alcohol_[i] = .;
		else if alcohol_[i] = 8 then alcohol_[i] = .;
		else if alcohol_[i] = 9 then alcohol_[i] = .;
		else if alcohol_[i] = 5 then alcohol_[i] = 0;
	end;
	
	do i = 1 to dim(alcdrinks_); 
		/* Recode missing for levels, set zeroes */
		if alcohol_[i] = 0 then alcdrinks_[i] = 0;
		if alcdrinks_[i] = 8 then alcdrinks_[i] = .;
		else if alcdrinks_[i] = 9 then alcdrinks_[i] = .;
	end;	
	
	do i = 1 to dim(alcfreq_); 
		/* Recode missing for levels, set zeroes */
		if alcohol_[i] = 0 then alcfreq_[i] = 0;
		if alcfreq_[i] = 8 then alcfreq_[i] = .;
		else if alcfreq_[i] = 9 then alcfreq_[i] = .;
	end;		
	
	do i = 1 to dim(alcbinge_);
		/* Recode missing */
		if 998 <= alcbinge_[i] <= 999 then alcbinge_[i] = .;		
	end;
	
	
	/* Life satisfaction */
	array satisfaction_[*] %listyrv(satisfaction,begy=2009);
	
	do i = 1 to dim(satisfaction_);
		/* Recode missings, refused, and non-head/wife */
		if satisfaction_[i] = 0 then satisfaction_[i] = .;
		else if satisfaction_[i] = 8 then satisfaction_[i] = .;
		else if satisfaction_[i] = 9 then satisfaction_[i] = .;
	end;
	
	/* Code light exercise, heavy exercise, and strength training */
	
	/* Units: 2 = day, 3 = week, 4 = two weeks, 5 = month, 6 = year, 7 = other, 8 = DK, 9 = NA/Refused */
		
	array lgtexcfreq_[*] %listyrv(lgtexcfreq,begy=&minyr); 
	array lgtexcunit_[*] %listyrv(lgtexcunit,begy=&minyr); 
	array hvyexcfreq_[*] %listyrv(hvyexcfreq,begy=&minyr); 
	array hvyexcunit_[*] %listyrv(hvyexcunit,begy=&minyr); 
	array musclefreq_[*] %listyrv(musclefreq,begy=&minyr); 
	array muscleunit_[*] %listyrv(muscleunit,begy=&minyr);
	
	/* Recode to daily */
	array dlylgtexc_[*] %listyrv(dlylgtexc,begy=&minyr);
	array dlyhvyexc_[*] %listyrv(dlyhvyexc,begy=&minyr);
	array dlymuscle_[*] %listyrv(dlymuscle,begy=&minyr);

	do i = 1 to dim(lgtexcfreq_);
			/* Handle missing/refused */
			if lgtexcfreq_[i] >= 998 then lgtexcfreq_[i] = . ;
			
			if lgtexcunit_[i] = 2 then dlylgtexc_[i] = lgtexcfreq_[i];
			else if lgtexcunit_[i] = 3 then dlylgtexc_[i] = lgtexcfreq_[i]/7;
			else if lgtexcunit_[i] = 4 then dlylgtexc_[i] = lgtexcfreq_[i]/14;
			else if lgtexcunit_[i] = 5 then dlylgtexc_[i] = lgtexcfreq_[i]/30;
			else if lgtexcunit_[i] = 6 then dlylgtexc_[i] = lgtexcfreq_[i]/365;
			else if 7 <= lgtexcunit_[i] <= 9 then dlylgtexc_[i] = .;
			else if lgtexcunit_[i] = 0 then dlylgtexc_[i] = 0;
	end;

	do i = 1 to dim(hvyexcfreq_);
			/* Handle missing/refused */
			if hvyexcfreq_[i] >= 998 then hvyexcfreq_[i] = . ;
		
			if hvyexcunit_[i] = 2 then dlyhvyexc_[i] = hvyexcfreq_[i];
			else if hvyexcunit_[i] = 3 then dlyhvyexc_[i] = hvyexcfreq_[i]/7;
			else if hvyexcunit_[i] = 4 then dlyhvyexc_[i] = hvyexcfreq_[i]/14;
			else if hvyexcunit_[i] = 5 then dlyhvyexc_[i] = hvyexcfreq_[i]/30;
			else if hvyexcunit_[i] = 6 then dlyhvyexc_[i] = hvyexcfreq_[i]/365;
			else if 7 <= hvyexcunit_[i] <= 9 then dlyhvyexc_[i] = .;
			else if hvyexcunit_[i] = 0 then dlyhvyexc_[i] = 0;
	end;

	do i = 1 to dim(musclefreq_);
			/* Handle missing/refused */
			if  musclefreq_[i] >= 998 then musclefreq_[i] = . ;
		
			if muscleunit_[i] = 2 then dlymuscle_[i] = musclefreq_[i];
			else if muscleunit_[i] = 3 then dlymuscle_[i] = musclefreq_[i]/7;
			else if muscleunit_[i] = 4 then dlymuscle_[i] = musclefreq_[i]/14;
			else if muscleunit_[i] = 5 then dlymuscle_[i] = musclefreq_[i]/30;
			else if muscleunit_[i] = 6 then dlymuscle_[i] = musclefreq_[i]/365;
			else if 7 <= muscleunit_[i] <= 9 then dlymuscle_[i] = .;
			else if muscleunit_[i] = 0 then dlymuscle_[i] = 0;
	end;

	/* include possitive responses to heart attack question in heart disease responses */
	do i = 1 to dim(heart_);
		heart_old_[i] = heart_[i]; 
		if heart_[i] ne 1 & 1 le hearta_[i] le 5 then do;
			heart_[i] = hearta_[i];
			if heart_old_[i] ne heart_[i] then heart_imp_[i] = 1;
		end;
	end;
	
	/* Cancer type - find if ONLY skin cancer */
	do i = 1 to dim(cancr_);
			/* skin cancer only - first response is skin cancer, no cancer in second response */
			if cancrloc1_[i] = 7 and cancrloc2_[i] = 0 then skincanc_[i] = 1;
			/* If only skin cancer (melanoma is own category), then set cancer to 0 */
			if skincanc_[i] = 1 then cancr_[i] = 0;
	end;

	/* Recode the "does the disease limit your normal activities" variables */
	do i = 1 to dim(cancrlimit_);
		%severity(cancrlimit diablimit heartlimit hibplimit lunglimit heartalimit stroklimit) /* recodes to 1 = not at all, 2 = just a little, 3 = somewhat, 4 = a lot */
	end;	
		
	/* Deal with individuals who respond that they have lung disease, but it does not impact their life.  We think this is a question wording 
	issue where folks who had bronchitis (not chronic bronchitis) are responding "yes" to having chronic lung problems */
	do i = 1 to dim(lung_);
		if lung_[i] = 1 and lunglimit_[i] = 1 then lung_[i] = 5;
	end;
		
	/* Recode the 0, 1, 5, 8, 9 values for health conditions */
	%recode_absorb(heart lung) /* Do not allow for disputes */
	%recode_absorb_dispute(cancr diab hibp strok asthm) /* Allow for disputes */
	
	/*  Address missing values for absorbed values:
			1. Fill forward if missing and lag is 1 
			2. fill backward if missing and next is 0
			3. set to 0 if still missing */
	%fill_missing(hearte);
	%fill_missing(stroke);
	%fill_missing(cancre);
	%fill_missing(diabe);
	%fill_missing(hibpe);
	%fill_missing(lunge);
	%fill_missing(asthme);
	
	/* fill forward smokev for individuals who changed to 0 */
	do i = 2 to dim(smokev_);
		if smokev_[i-1] = 1 then do;
			smokev_[i] = 1;
		end;
	end; 

	
	/* drop non-absorbed versions of variables */
	drop cancr cancrnow diab diabnow heart heartnow hibp hibpnow lung lungnow strok stroknow deathyr asthm ;
	
	
						
						
	/* Address $ eating out questions, controlling for number of people in FU 
	Units:  2 = day, 3 = week, 4 = two weeks, 5 = month, 6 = year, 7 = other, 8 = DK, 9 = NA/refuse, 0 = inappropriate 
	
	*/					
	 array eatoutfs_[*]			%listyrv(eatoutfs,begy=1999);
   array eatoutfsunit_[*]  %listyrv(eatoutfsunit,begy=1999); 
   array eatout_[*]        %listyrv(eatout,begy=1999);    
   array eatoutunit_[*]    %listyrv(eatoutunit,begy=1999);
   
   array numinfu_[*] %listyrv(numinfu,begy=1999);				
						
	array dineoutcost_[*] %listyrv(dineoutcost,begy=1999);					
		
	do i = 1 to dim(eatoutfs_);
		if 99998 <= eatoutfs_[i] <= 99999 then eatoutfs_[i] = .;
	end;
	do i = 1 to dim(eatout_);
		if 99998 <= eatout_[i] <= 99999 then eatout_[i] = .;
	end;	
	
	do i = 1 to dim(dineoutcost_);
		/* those receiving food stamps */
		if eatoutfsunit_[i] = 2 then dineoutcost_[i] = (eatoutfs_[i]*30)/numinfu_[i];  									/* daily */
		else if eatoutfsunit_[i] = 3 then dineoutcost_[i] = (eatoutfs_[i]*4.29)/numinfu_[i];						/* weekly */
		else if eatoutfsunit_[i] = 4 then dineoutcost_[i] = (eatoutfs_[i]*2.14)/numinfu_[i];						/* semi-weekly */
		else if eatoutfsunit_[i] = 5 then dineoutcost_[i] = (eatoutfs_[i])/numinfu_[i];									/* monthly */
		else if eatoutfsunit_[i] = 6 then dineoutcost_[i] = (eatoutfs_[i] *(1/12) )/numinfu_[i];				/* annual */
		else if 7 <= eatoutfsunit_[i] <= 9 then dineoutcost_[i] = .    ;                                 /* other, don't know, refused */
		
		/* those who do not receive food stamps */
		if eatoutunit_[i] = 2 then dineoutcost_[i] = (eatout_[i]*30)/numinfu_[i];  									/* daily */
		else if eatoutunit_[i] = 3 then dineoutcost_[i] = (eatout_[i]*4.29)/numinfu_[i];						/* weekly */
		else if eatoutunit_[i] = 4 then dineoutcost_[i] = (eatout_[i]*2.14)/numinfu_[i];						/* semi-weekly */
		else if eatoutunit_[i] = 5 then dineoutcost_[i] = (eatout_[i])/numinfu_[i];									/* monthly */
		else if eatoutunit_[i] = 6 then dineoutcost_[i] = (eatout_[i] *(1/12) )/numinfu_[i];				/* annual */
		else if 7 <= eatoutunit_[i] <= 9 then dineoutcost_[i] = .   ;                                  /* other, don't know, refused */
		
	end;				
	
	
	/* Recode the age of onset for diseases of interest.  Create dummy variables for onset by age25, by age30 
	- For 1999-2003 age of onset needs to be calculated from the "how long have you had this condition" question
	- For 2005-present age of onset is asked directly
	*/
	array agecalc_[*] %listyrv(age,begy=1999,endy=2003);

	/* Calculate the onset age for 1999-2003 survey years */		
	%calc_onset(stroke,begy=1999,endy=2003);	
	%calc_onset(heartattack,begy=1999,endy=2003);	
	%calc_onset(heartdisease,begy=1999,endy=2003);	
	%calc_onset(hibp,begy=1999,endy=2003);
	%calc_onset(asthma,begy=1999,endy=2003);
	%calc_onset(lung,begy=1999,endy=2003);
	%calc_onset(diab,begy=1999,endy=2003);
	%calc_onset(arthritis,begy=1999,endy=2003);
	%calc_onset(memoryloss,begy=1999,endy=2003);
	%calc_onset(learningdisorder,begy=1999,endy=2003);
	%calc_onset(cancr,begy=1999,endy=2003);
	%calc_onset(psychprob,begy=1999,endy=2003);
	
	/* Name variables consistently where we haven't */
	hypertensionage99 = hibpage99;
	hypertensionage01 = hibpage01;
	hypertensionage03 = hibpage03;
	lungdiseaseage99 =  lungage99;
	lungdiseaseage01 =  lungage01;
	lungdiseaseage03 =  lungage03;
	diabetesage99 = diabage99;
	diabetesage01 = diabage01;	
	diabetesage03 = diabage03;
	cancerage99 = cancrage99;
	cancerage01 = cancrage01;
	cancerage03 = cancrage03;
			
	/* Create the full arrays 1999-present */
	array strokeage_[*] %listyrv(strokeage,begy=1999);
	array heartattackage_[*] %listyrv(heartattackage,begy=1999);
	array heartdiseaseage_[*] %listyrv(heartdiseaseage,begy=1999);
	array hypertensionage_[*] %listyrv(hypertensionage,begy=1999);
	array asthmaage_[*] %listyrv(asthmaage,begy=1999);
	array lungdiseaseage_[*] %listyrv(lungdiseaseage,begy=1999);
	array diabetesage_[*] %listyrv(diabetesage,begy=1999);
	array arthritisage_[*] %listyrv(arthritisage,begy=1999);
	array memorylossage_[*] %listyrv(memorylossage,begy=1999);
	array learningdisorderage_[*] %listyrv(learningdisorderage,begy=1999);
	array cancerage_[*] %listyrv(cancerage,begy=1999);
	array psychprobage_[*] %listyrv(psychprobage,begy=1999);
	
	/* Array indicating who the respondent was (1 = the person, 5 = proxy ) */
	array resp_[*] %listyrv(resp,begy=1999);

	/* Dummy variables for onset by age 25 */
	%onset(stroke,25);
	%onset(heartattack,25);
	%onset(heartdisease,25);
	%onset(hypertension,25);
	%onset(asthma,25);
	%onset(lungdisease,25);
	%onset(diabetes,25);
	%onset(arthritis,25);
	%onset(memoryloss,25);
	%onset(learningdisorder,25);
	%onset(cancer,25);
	%onset(psychprob,25);
	
	/* Rename */
	fstrok25 = stroke25;
	fheartattack25 = heartattack25;
	fheart25 = heartdisease25;
	fhibp25 = hypertension25;
	fasthma25 = asthma25;
	flung25 = lungdisease25;
	fdiab25 = diabetes25;
	farthritis25 = arthritis25;
	fmemry25 = memoryloss25;
	flearndis25 = learningdisorder25;
	fcancr25 = cancer25;
	fpsych25 = psychprob25; 

	/* Dummy variables for onset by age 30 */
	%onset(stroke,30);
	%onset(heartattack,30);
	%onset(heartdisease,30);
	%onset(hypertension,30);
	%onset(asthma,30);
	%onset(lungdisease,30);
	%onset(diabetes,30);
	%onset(arthritis,30);
	%onset(memoryloss,30);
	%onset(learningdisorder,30);
	%onset(cancer,30);
	%onset(psychprob,30);
	
	/* Rename */
	fstrok30 = stroke30;
	fheartattack30 = heartattack30;
	fheart30 = heartdisease30;
	fhibp30 = hypertension30;
	fasthma30 = asthma30;
	flung30 = lungdisease30;
	fdiab30 = diabetes30;
	farthritis30 = arthritis30;
	fmemry30 = memoryloss30;
	flearndis30 = learningdisorder30;
	fcancr30 = cancer30;
	fpsych30 = psychprob30; 

		
	label %labelyrv(cancre,Doctor ever told you that you have cancer excluding skin cancer,begy=1999);
	label %labelyrv(diabe,Doctor ever told you that you have diabetes,begy=1999);
*	label %labelyrv(hearte,Doctor ever coronary heart disease angina or congestive heart failure,begy=1999);
	label %labelyrv(hearte,Doctor ever heart attack coronary heart disease angina or congestive heart failure,begy=1999);
	label %labelyrv(hibpe,Doctor ever told you that you have high blood pressure,begy=1999);
	label %labelyrv(lunge,Doctor ever told you that you have chronic lung disease,begy=1999);
	label %labelyrv(stroke,Doctor ever told you that you have stroke,begy=1999);
	label %labelyrv(smoken,Do you currently smoke,begy=1999);
	label %labelyrv(smokev,Did you ever smoke,begy=1999);
	label %labelyrv(underwt,18.5<bmi,begy=1999);
	label %labelyrv(overwt,25<bmi<30,begy=1999);
	label %labelyrv(obese,bmi>30,begy=1999);
	label %labelyrv(bmi,Body Mass Index,begy=1999);
	label %labelyrv(totalheight,Height in inches,begy=1999);
	label %labelyrv(dineoutcost,Monthly cost of eating out,begy=1999);
	
	keep id cancre: diabe: hearte: hibpe: lunge: stroke: smoken: smokev: underwt: overwt: obese: bmi: totalheight: srh: shlt: deathyr: dlylgtexc: dlyhvyexc: dlymuscle: dineoutcost: 
			 heart_imp:  
			 cancrlimit: diablimit: heartlimit: hibplimit: lunglimit: heartalimit: stroklimit:
			 yearssmoked: numcigs: packyears:
			 smokestartmed 
			 f:
			 strokeage: heartattackage: heartdiseaseage: hypertensionage: asthmaage: lungdiseaseage: 
			 diabetesage: arthritisage: memorylossage: learningdisorderage: cancerage: psychprobage:
			 resp:
			 alcohol: alcdrinks: alcfreq: alcbinge:
			 asthme:
			 satisfaction:
			 ;
  drop heart_old: wght_bwd: wght_fwd:
		strokedays: strokemnth: strokeweek: strokeyear:            
		hibpdays: hibpmnth: hibpweek: hibpyear: 
		diabdays: diabmnth: diabweek: diabyear: 
		cancrdays: cancrmnth: cancrweek: cancryear: 
		lungdays: lungmnth: lungweek: lungyear: 
		heartattackdays: heartattackmnth: heartattackweek: heartattackyear: 
		heartdiseasedays: heartdiseasemnth: heartdiseaseweek: heartdiseaseyear: 
		psychprobdays: psychprobmnth: psychprobweek: psychprobyear: 
		arthritisdays: arthritismnth: arthritisweek: arthritisyear: 
		asthmadays: asthmamnth: asthmaweek: asthmayear: 
		memorylossdays: memorylossmnth: memorylossweek: memorylossyear: 
		learningdisorderdays: learningdisordermnth: learningdisorderweek: learningdisorderyear: 
		resp:
  	stroke25                
		heartattack25           
		heartdisease25          
		hypertension25          
		asthma25                
		lungdisease25           
		diabetes25              
		arthritis25             
		memoryloss25            
		learningdisorder25      
		cancer25                
		psychprob25             
  	stroke30              
  	heartattack30       
  	heartdisease30      
  	hypertension30      
  	asthma30            
  	lungdisease30       
  	diabetes30          
  	arthritis30         
  	memoryloss30        
  	learningdisorder30  
  	cancer30            
  	psychprob30         
  	;
  
run;




    