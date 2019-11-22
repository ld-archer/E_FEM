/* 
Recode ADL/IADL questions to categorical count variables

Derive nursing home living status

Adding physical/nervous condition that limits work

*/

%include "setup.inc";
%include "&maclib.psidget.mac";  /* macro to get early release data */ 
%include "&maclib.renyrv.mac";  /* macro to rename variables */
%include "&maclib.recode_absorb.mac";  /* macro to recode 1,5,8,9 type variables with absorbing state (once 1, always 1) */

data proj.limitations;
	set proj.extract_data (keep=id srh: died: inyr: diedyr: bath: eat: dress: walk: bed: toilet: meals: shop: money: phone: hvyhswrk: lthswrk:
	bathhelp: dresshelp: walkhelp:
	worklimit: );
	
	/* setup ADL arrays */
	array bath_[*] %listyrv(bath,begy=1999);
  array eat_[*] %listyrv(eat,begy=1999);
  array dress_[*] %listyrv(dress,begy=1999);
  array walk_[*] %listyrv(walk,begy=1999);
  array bed_[*] %listyrv(bed,begy=1999);
  array toilet_[*] %listyrv(toilet,begy=1999);
	
	/* setup IADL arrays */
	array meals_[*] %listyrv(meals,begy=1999);
  array shop_[*] %listyrv(shop,begy=1999);
  array money_[*] %listyrv(money,begy=1999);
  array phone_[*] %listyrv(phone,begy=1999);
  array hvyhswrk_[*] %listyrv(hvyhswrk,begy=1999);
  array lthswrk_[*] %listyrv(lthswrk,begy=1999);
  
  /* setup adlstat and iadlstat arrays */
  array adlstat_[*] %listyrv(adlstat,begy=1999);
  array adlstat_miss_[*] %listyrv(adlstat_miss,begy=1999);
	array iadlstat_[*] %listyrv(iadlstat,begy=1999);
	array iadlstat_miss_[*] %listyrv(iadlstat_miss,begy=1999);
	
	/* Requires help with these activities */
	array bathhelp_[*] %listyrv(bathhelp,begy=1999);
	array dresshelp_[*] %listyrv(dresshelp,begy=1999);
	array walkhelp_[*] %listyrv(walkhelp,begy=1999);
	
	/* adlhelp will store any help with: bathing dressing or walking across a room */
	array adlhelp_[*] %listyrv(adlhelp,begy=1999);
	
	/* Physical or nervous condition that limits the type or amount of work */
	array worklimit_[*] %listyrv(worklimit,begy=1999); /* raw variables */
	array limitwrk_[*] %listyrv(limitwrk,begy=1999);
	
	/* Assign adlstat */
	do i = 1 to dim(adlstat_);
		if missing(bath_[i]) then adlstat_[i] = . ;
		else adlstat_[i] = (bath_[i] = 1) + (eat_[i] = 1) + (dress_[i] = 1) + (walk_[i] = 1) + (bed_[i] = 1) + (toilet_[i] = 1);
	end;
	
/* assign missing adlstat using next or last period */
	do i = 2 to dim(adlstat_);
		if adlstat_[i] = . then do;
			adlstat_[i] = adlstat_[i-1];
			adlstat_miss_[i] = 1;
		end;
	end;
	do i = dim(adlstat_)-1 to 1 by -1;
		if adlstat_[i] = . then do;
			adlstat_[i] = adlstat_[i+1];
			adlstat_miss_[i] = 1;
		end;
	end;	
/* set adlstat to 0 if still missing */
	do i = 1 to dim(adlstat_);
		if adlstat_[i] = . then do;
			adlstat_[i] = 0;
			adlstat_miss_[i] = 1;
			end;
	end;	
	
	/* Assign iadlstat */
	do i = 1 to dim(iadlstat_);
		if missing(meals_[i]) then iadlstat_[i] = . ;
		else iadlstat_[i] = (meals_[i] = 1) + (shop_[i] = 1) + (money_[i] = 1) + (phone_[i] = 1) + (hvyhswrk_[i] = 1) + (lthswrk_[i] = 1);
	end;	

/* assign missing iadlstat using next or last period */
	do i = 2 to dim(iadlstat_);
		if iadlstat_[i] = . then do;
			iadlstat_[i] = iadlstat_[i-1];
			iadlstat_miss_[i] = 1;
		end;
	end;
	do i = dim(iadlstat_)-1 to 1 by -1;
		if iadlstat_[i] = . then do;
			iadlstat_[i] = iadlstat_[i+1];
			iadlstat_miss_[i] = 1;
		end;
	end;	
/* set iadlstat to 0 if still missing */
	do i = 1 to dim(iadlstat_);
		if iadlstat_[i] = . then do;
			iadlstat_[i] = 0;
			iadlstat_miss_[i] = 1;
			end;
	end;	
	
	/* Assign adlhelp */
	do i = 1 to dim(adlhelp_);
		if missing(bathhelp_[i]) then adlhelp_[i] = . ;
		else adlhelp_[i] = (bathhelp_[i] = 1) or (dresshelp_[i] = 1) or (walkhelp_[i] = 1);
	end;
	
	
	do i = 1 to dim(limitwrk_);
		if missing(worklimit_[i]) then limitwrk_[i] = .;
		else if worklimit_[i] = 1 then limitwrk_[i] = 1;
		else if worklimit_[i] = 5 then limitwrk_[i] = 0;
		else if worklimit_[i] = 8 then limitwrk_[i] = .;
		else if worklimit_[i] = 9 then limitwrk_[i] = .;
	end;
	

	label %labelyrv(adlstat,Count of ADL,begy=1999);
	label %labelyrv(iadlstat,Count of IADL 2003+,begy=1999);
	label %labelyrv(limitwrk,Physical or nervous condition that limits the type or amount of work, begy=1999);
	
	keep id adlstat: iadlstat: adlhelp: limitwrk:;

run;