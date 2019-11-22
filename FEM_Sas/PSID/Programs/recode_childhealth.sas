/* 
Recode the responses to age <17 health related questions
*/


%include "setup.inc";
%include "&maclib.psidget.mac";  /* macro to get early release data */ 
%include "&maclib.renyrv.mac";  /* macro to rename variables */
%include "&maclib.recode_absorb.mac";  /* macro to recode 1,5,8,9 type variables with absorbing state (once 1, always 1) */
%include "&maclib.rvar.mac"; /* macro to recode 0,1,5,8,9 type responses */


data proj.childhealth;
	set proj.extract_data (keep=id inyr: 
		chldsrh: chldmissschool: chldmeasles: chldmumps: chldcknpox: chldvision: chldparsmk: chldasthma: chlddiab:
		chldresp: chldspeech: chldallergy: chldheart: chldear: chldszre: chldmgrn: chldstomach: chldhibp: chlddepress: 
		chlddrug: chldpsych:
	 );
	 
	
	/* Setup the arrays */
	 array chldsrh_[*] %listyrv(chldsrh,begy=2007);         
	array chldmissschool_[*] %listyrv(chldmissschool,begy=2007);  
	array chldmeasles_[*] %listyrv(chldmeasles,begy=2007);     
	array chldmumps_[*] %listyrv(chldmumps,begy=2007);       
	array chldcknpox_[*] %listyrv(chldcknpox,begy=2007);      
	array chldvision_[*] %listyrv(chldvision,begy=2007);      
	array chldparsmk_[*] %listyrv(chldparsmk,begy=2007);      
	array chldasthma_[*] %listyrv(chldasthma,begy=2007);      
	array chlddiab_[*] %listyrv(chlddiab,begy=2007);        
	array chldresp_[*] %listyrv(chldresp,begy=2007);        
	array chldspeech_[*] %listyrv(chldspeech,begy=2007);      
	array chldallergy_[*] %listyrv(chldallergy,begy=2007);     
	array chldheart_[*] %listyrv(chldheart,begy=2007);       
	array chldear_[*] %listyrv(chldear,begy=2007);         
	array chldszre_[*] %listyrv(chldszre,begy=2007);        
	array chldmgrn_[*] %listyrv(chldmgrn,begy=2007);        
	array chldstomach_[*] %listyrv(chldstomach,begy=2007);     
	array chldhibp_[*] %listyrv(chldhibp,begy=2007);        
	array chlddepress_[*] %listyrv(chlddepress,begy=2007);     
	array chlddrug_[*] %listyrv(chlddrug,begy=2007);        
	array chldpsych_[*] %listyrv(chldpsych,begy=2007);  
	 
	/* Self-reported health before age 17 */
	do i = 1 to dim(chldsrh_);
		if chldsrh_[i] = 0 then chldsrh_[i] = .;
		else if chldsrh_[i] = 8 then chldsrh_[i] = .;
		else if chldsrh_[i] = 9 then chldsrh_[i] = .;
		else if chldsrh_[i] = 5 then chldsrh_[i] = 1; /* Poor */
		else if chldsrh_[i] = 4 then chldsrh_[i] = 2; /* Fair */
		else if chldsrh_[i] = 3 then chldsrh_[i] = 3; /* Good */
		else if chldsrh_[i] = 2 then chldsrh_[i] = 4; /* Very good */
		else if chldsrh_[i] = 1 then chldsrh_[i] = 5; /* Excellent */
	end;

	/* Miss more than a month of school as a child */
	do i = 1 to dim(chldmissschool_);
		%rvar(chldmissschool chldmeasles chldmumps chldcknpox chldvision  chldasthma chlddiab  
			chldresp chldspeech chldallergy chldheart chldear chldszre chldmgrn chldstomach chldhibp chlddepress
				chlddrug chldpsych
				)
	end;
	
	/* chldparsmk is different ... */
	do i = 1 to dim(chldparsmk_);
		if chldparsmk_[i] = 0 then chldparsmk_[i] = .;
		else if chldparsmk_[i] = 8 then chldparsmk_[i] = .;
		else if chldparsmk_[i] = 9 then chldparsmk_[i] = .;
		else if chldparsmk_[i] = 1 then chldparsmk_[i] = 1; /* Yes, one parent smoked */
		else if chldparsmk_[i] = 2 then chldparsmk_[i] = 1; /* Yes, both */
		else if chldparsmk_[i] = 5 then chldparsmk_[i] = 0; /* No */
	end;
	
	/* Assign childhood self-reported health to respondent - somre respondents are asked multiple times, favor more recent response */
	do i = dim(chldsrh_) to 1 by (-1) while (chldsrh = .);
			if 1 <= chldsrh_[i] <= 5 then chldsrh = chldsrh_[i]; 
	end;	
	
	/* Need to create fixed variables - favor most recent responses.  PSID appears to have reasked the child health questions for those who had a proxy interview*/
	chldmissschool = .;
	chldmeasles = .; 
	chldmumps = .;  
	chldcknpox = .;  
	chldvision = .;  
	chldparsmk = .; 
	chldasthma = .;  
	chlddiab = .; 
	chldresp = .;  
	chldspeech = .;  
	chldallergy = .;  
	chldheart = .;  
	chldear = .;  
	chldszre = .;  
	chldmgrn = .;  
	chldstomach = .;  
	chldhibp = .;  
	chlddepress = .;  
	chlddrug = .;  
	chldpsych = .; 
	
	do i = dim(chldmissschool_) to 1 by (-1) while (chldmissschool = .);
		chldmissschool = chldmissschool_[i]; 
	end;	
	
	do i = dim(chldmeasles_) to 1 by (-1) while (chldmeasles = .);
		chldmeasles = chldmeasles_[i]; 
	end;	
	
	do i = dim(chldmumps_) to 1 by (-1) while (chldmumps = .);
		chldmumps = chldmumps_[i]; 
	end;	
	
	do i = dim(chldcknpox_) to 1 by (-1) while (chldcknpox = .);
		chldcknpox = chldcknpox_[i]; 
	end;	

	do i = dim(chldvision_) to 1 by (-1) while (chldvision = .);
		chldvision = chldvision_[i]; 
	end;	    
	
	do i = dim(chldparsmk_) to 1 by (-1) while (chldparsmk = .);
		chldparsmk = chldparsmk_[i]; 
	end;	  
	
	do i = dim(chldasthma_) to 1 by (-1) while (chldasthma = .);
		chldasthma = chldasthma_[i]; 
	end;	
	
	do i = dim(chlddiab_) to 1 by (-1) while (chlddiab = .);
		chlddiab = chlddiab_[i]; 
	end;	
  
 	do i = dim(chldresp_) to 1 by (-1) while (chldresp = .);
		chldresp = chldresp_[i]; 
	end;	 
   
 	do i = dim(chldspeech_) to 1 by (-1) while (chldspeech = .);
		chldspeech = chldspeech_[i]; 
	end;	 
   
 	do i = dim(chldallergy_) to 1 by (-1) while (chldallergy = .);
		chldallergy = chldallergy_[i]; 
	end;	  

 	do i = dim(chldheart_) to 1 by (-1) while (chldheart = .);
		chldheart = chldheart_[i]; 
	end;	  

 	do i = dim(chldear_) to 1 by (-1) while (chldear = .);
		chldear = chldear_[i]; 
	end;	 

 	do i = dim(chldszre_) to 1 by (-1) while (chldszre = .);
		chldszre = chldszre_[i]; 
	end;	 

 	do i = dim(chldmgrn_) to 1 by (-1) while (chldmgrn = .);
		chldmgrn = chldmgrn_[i]; 
	end;	 

 	do i = dim(chldstomach_) to 1 by (-1) while (chldstomach = .);
		chldstomach = chldstomach_[i]; 
	end;	 	  

 	do i = dim(chldhibp_) to 1 by (-1) while (chldhibp = .);
		chldhibp = chldhibp_[i]; 
	end;		    
	
 	do i = dim(chlddepress_) to 1 by (-1) while (chlddepress = .);
		chlddepress = chlddepress_[i]; 
	end;

 	do i = dim(chlddrug_) to 1 by (-1) while (chlddrug = .);
		chlddrug = chlddrug_[i]; 
	end;

 	do i = dim(chldpsych_) to 1 by (-1) while (chldpsych = .);
		chldpsych = chldpsych_[i]; 
	end;

		 
	keep id chldsrh chldmissschool chldmeasles chldmumps  chldcknpox  chldvision  chldparsmk  chldasthma  chlddiab 
		chldresp  chldspeech  chldallergy  chldheart  chldear  chldszre  chldmgrn  chldstomach  chldhibp  chlddepress  
		chlddrug  chldpsych 
			 ;
  
run;
	 
	 
	 