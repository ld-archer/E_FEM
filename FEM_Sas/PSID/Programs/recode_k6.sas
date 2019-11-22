/* Recode the Kessler 6 variables as needed */

%include "setup.inc";
%include "&maclib.psidget.mac";  /* macro to get early release data */ 
%include "&maclib.renyrv.mac";  /* macro to rename variables */


data proj.k6;
	set proj.extract_data (keep=id inyr: 
		resp:
		respsadness: respnervous: resprestless: resphopeless: respeffort: respworthless: respk6scale:
	 );

	/* Setup the arrays */
	 array respsadness_[*] %listyrv(respsadness,begy=2001);  
	 array respnervous_[*] %listyrv(respnervous,begy=2001);  
	 array resprestless_[*] %listyrv(resprestless,begy=2001);  
	 array resphopeless_[*] %listyrv(resphopeless,begy=2001);  
	 array respeffort_[*] %listyrv(respeffort,begy=2001);  
	 array respworthless_[*] %listyrv(respworthless,begy=2001);  
	 array respk6scale_[*] %listyrv(respk6scale,begy=2001);  
	 array resp_[*] %listyrv(resp,begy=2001);  
	 
	 
	 
	/* Recode non-respondents to missing, recode missing values to missing	 */
	do i = 1 to dim(respsadness_);
			if resp_[i] ne 1 then respsadness_[i] = .;
			if respsadness_[i] = 0 then respsadness_[i] = .;
			else if respsadness_[i] = 8 then respsadness_[i] = .;
			else if respsadness_[i] = 9 then respsadness_[i] = .;
			
	end;
	
	do i = 1 to dim(respnervous_);
			if resp_[i] ne 1 then respnervous_[i] = .;
			if respnervous_[i] = 0 then respnervous_[i] = .;
			else if respnervous_[i] = 8 then respnervous_[i] = .;
			else if respnervous_[i] = 9 then respnervous_[i] = .;
			
	end;

	do i = 1 to dim(resprestless_);
			if resp_[i] ne 1 then resprestless_[i] = .;
			if resprestless_[i] = 0 then resprestless_[i] = .;
			else if resprestless_[i] = 8 then resprestless_[i] = .;
			else if resprestless_[i] = 9 then resprestless_[i] = .;
			
	end;
	
	do i = 1 to dim(resphopeless_);
			if resp_[i] ne 1 then resphopeless_[i] = .;
			if resphopeless_[i] = 0 then resphopeless_[i] = .;
			else if resphopeless_[i] = 8 then resphopeless_[i] = .;
			else if resphopeless_[i] = 9 then resphopeless_[i] = .;
			
	end;
	
	
	do i = 1 to dim(respeffort_);
			if resp_[i] ne 1 then respeffort_[i] = .;
			if respeffort_[i] = 0 then respeffort_[i] = .;
			else if respeffort_[i] = 8 then respeffort_[i] = .;
			else if respeffort_[i] = 9 then respeffort_[i] = .;
			
	end;
	
	do i = 1 to dim(respworthless_);
			if resp_[i] ne 1 then respworthless_[i] = .;
			if respworthless_[i] = 0 then respworthless_[i] = .;
			else if respworthless_[i] = 8 then respworthless_[i] = .;
			else if respworthless_[i] = 9 then respworthless_[i] = .;
			
	end;
	
		do i = 1 to dim(respk6scale_);
			if resp_[i] ne 1 then respk6scale_[i] = .;
			if respk6scale_[i] = 99 then respk6scale_[i] = .;
	end;
	
		
	
	keep id: respsadness: respnervous: resprestless: resphopeless: respeffort: respworthless: respk6scale: ;
	
run;	



