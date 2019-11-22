/* 
Recode children variables:
Assumes CAH for biological children is complete

to do: explicitly take into account adopted children
*/


%include "setup.inc";
%include "&maclib.psidget.mac";  /* macro to get early release data */ 
%include "&maclib.renyrv.mac";  /* macro to rename variables */

/* macro for age calculation */
%macro age (birthday, interview);
	floor( (intck('month',&birthday,&interview) - (day(&interview) < min(day(&birthday),day(intnx('month',&interview,1) -1)))) /12)
%mend age;

data proj.children;
	set proj.extract_children (keep= id hdwf: hdwfever sex iwmonth: iwday: iwyear: inyr: kidbd: ncurrent fcurrent numkid fertqual kidsinfu: bros: sisters: numbros: numsisters: ) ;
   
   array kidbd(20)  kidbd1-kidbd20;     /* best-guess birth date */
   array birth(20)	birth1-birth20;			/* date of births to be recoded with birth of multiples having one record */
     
   /* Keep track of quality of fertility data */
   length qualfert 4; qualfert=0;
   label qualfert = "Quality of fertility data";

   /* Fill in any missing birth dates from the childbirth and adoption history */
	if (numkid>0) then do;
   		if (kidbd(1)=.) then do;
	 				qualfert+2;
	 				if (kidbd(2)~=.) then kidbd(1)=kidbd(2)-2*365;
      end;
  end;
  else if (numkid>=2) then do;
      do kid=2 to numkid;
	 				if (kidbd(kid)=.) then do;
	    			qualfert+1;
	    			if (kid<numkid & kidbd(kid+1)~=.) then kidbd(kid)=int((kidbd(kid-1)+kidbd(kid+1))/2);
	    			else kidbd(kid)=kidbd(kid-1)+2*365;
	    		end;
	 		end;
  end;
   
  /* copy kidbd variable to birth variable */
  do j=1 to 20;
   	birth(j)=kidbd(j);
  end;

	/* if multiples, leave only one birth */
		do j=2 to 20; /* correction for twins */
			if birth(j) ~= . and birth(j)=birth(j-1) then birth(j) = birth(j+1);
		end;
		do j=2 to 20; /* correction for possibility of triplets, no multiple births per wave higher than 3 in CAH */
			if birth(j) ~= . and birth(j)=birth(j-1) then birth(j) = birth(j+1);
		end;


	/* format and fill in missing interview dates */
	array iwyear_[*] %listyrv(iwyear,begy=1997);
	array iwmonth_[*] %listyrv(iwmonth,begy=1997);
	array iwday_[*] %listyrv(iwday,begy=1997);
	array iwdate_[*] %listyrv(iwdate,begy=1997);
	array meandt_[*] %listyrv(meandt,begy=1997) (13604 14352 15120 15854 16570 17314 18042 18781 19507 20255); 		/* used to set missing interview date to mean date of interview in that wave */
	
  do i=1 to dim(iwdate_);
		  
      /* get year from iwdate varname */
      yr=substr(vname(iwdate_[i]),7);
      if yr>=68 then year=1900+yr;
      else year=2000+yr;		  
		  
		  /* format interview dates 1997 - 2015 */
			if (1<=iwmonth_[i]<=12 & 1<=iwday_[i]<=31 & 1<=iwyear_[i]<=2015) then iwdate_[i]=mdy(iwmonth_[i],iwday_[i],iwyear_[i]);
			else if (1<=iwmonth_[i]<=12 & 1<=iwyear_[i]<=2015) then iwdate_[i]=mdy(iwmonth_[i],15,iwyear_[i]);
			else iwdate_[i] = meandt_[i]; format iwdate97 -- iwdate15 date7.;
			
	end;


	/* count number of births and biological children by wave starting in 1999. assume birth history is complete */	
	array births_[*] _1997 %listyrv(births,begy=1999); 
	array birthse_[*] _1997 %listyrv(birthse,begy=1999);
	array biokids_[*] _1997 %listyrv(biokids,begy=1999); /* count of new biological children by wave */
	array numbirths_[*] _1997 %listyrv(numbirths,begy=1999); /* cumulative count of births by wave */
	array numbiokids_[*] _1997 %listyrv(numbiokids,begy=1999); /* cumulative count of biological children by wave */ 
  array numbiokidslt18_[*] _1997 %listyrv(numbiokidslt18,begy=1999); /* count of biological children under the age of 18 by wave */
   	
   	/* take care of records with missing child information */
 		if numkid = . then do;
 				priorbirths = .;
 				priorbiokids = .;
 				do i=2 to dim(iwdate_); 
 						births_[i] = .; 
 						biokids_[i] = .;
 						numbiokidslt18_[i] = .;
 				end;
 		end;
 		
 		/* initialize records with non-missing child information to zero */
 		else if numkid ~= . then do;
 				priorbirths = 0;
 				priorbiokids = 0;
 				do i=2 to dim(iwdate_); 
 						births_[i] = 0;
 						biokids_[i] = 0;
 						numbiokidslt18_[i] = 0;
 				end;
 		end;
 		
 		/* assign number of births and biological children prior to 1999 and by wave after 1999 */
 		if numkid>0 then do;
    		do j=1 to 20;
 						if birth(j)~=. & birth(j)<=iwdate97 then priorbirths+1;  
						if kidbd(j)~=. & kidbd(j)<=iwdate97 then priorbiokids+1; 
						do i=2 to dim(iwdate_);
   							if iwdate_[i-1]<birth(j)<=iwdate_[i] then births_[i]+1;  
   							if iwdate_[i-1]<kidbd(j)<=iwdate_[i] then biokids_[i]+1;  
   							if kidbd(j)~=. & kidbd(j)<=iwdate_[i] & %age(kidbd(j),iwdate_[i]) < 18 then numbiokidslt18_[i]+1;  
  					end;
   			end;
   	end;
 
 
   /* assign cumulative number of births and biological children by wave */
		numbiokids99 = sum(priorbiokids,biokids99);
		numbirths99 = sum(priorbirths,births99);
		do i=3 to dim(iwdate_);
				numbiokids_[i] = sum(numbiokids_[i-1],biokids_[i]);
				numbirths_[i] = sum(numbirths_[i-1],births_[i]);
    end;
   
  /* assign births ever variable */
  	do i=2 to dim(iwdate_);
  			if numbirths_[i] > 0 then birthse_[i]=1;
  			else if numbirths_[i] = 0 then birthse_[i]=0;
  	end;


	/* count number of years and months between births */
	array kidgapyr(20)  kidgapyr1-kidgapyr20;  
	array kidgapmo(20)  kidgapmo1-kidgapmo20;
	
	do i=2 to 20;
			if birth(i)~=. and birth(i-1)<birth(i) then do;
				kidgapyr(i) = intck('year',birth(i-1),birth(i));
				kidgapmo(i) = intck('month',birth(i-1),birth(i));
			end;
	end;    

	
	/* assign duration since last birth */
  array yrsnclastkid_[*] _1997 %listyrv(yrsnclastkid,begy=1999);
  
  do i=2 to dim(yrsnclastkid_);
  		if numbiokids_[i] > 0 and iwdate_[i]~=. then yrsnclastkid_[i] = intck('year',kidbd(numbiokids_[i]),iwdate_[i]);
  		else if numbiokids_[i] = 0 and iwdate_[i]~=. then yrsnclastkid_[i] = 0;
  end;
  
  
  /* number of siblings */
  array bros_[*] %listyrv(bros,begy=1997);
  array sisters_[*] %listyrv(sisters,begy=1997);
  array numbros_[*] %listyrv(numbros,begy=1997);
  array numsisters_[*] %listyrv(numsisters,begy=1997);
  
  array siblings_[*] %listyrv(siblings,begy=1997);
  
  do i=1 to dim(siblings_);
  	if bros_[i] = 5 and sisters_[i] = 5
  		then siblings_[i] = 0;
  	else if bros_[i] = 1 and sisters_[i] = 1
  		then siblings_[i] = numbros_[i] + numsisters_[i];
  	else if bros_[i] = 1
  		then siblings_[i] = numbros_[i];
  	else if sisters_[i] = 1
  		then siblings_[i] = numsisters_[i];
		  		
  	if bros_[i] in (8,9) or numbros_[i] in (98,99) or sisters_[i] in (8,9) or numsisters_[i] in(98,99)
  		then siblings_[i] = -9; 
  	
  end;
  
  /* if siblings = -9 then fill with non-missing wave if available */
  do i=1 to dim(siblings_);
  	do j=1 to dim(siblings_);
  		if siblings_[i] = -9 and missing(siblings_[j])=0 and siblings_[j] ne -9
  			then siblings_[i] = siblings_[j];
  	end;	
	end;
	
	/* set -9 to missing */
	do i=1 to dim(siblings_);
		if siblings_[i] = -9
			then siblings_[i] = .;
	end;	
	  
   drop yr year i j kid _1997 iwmonth: iwday: iwyear: meandt: ;

run;

