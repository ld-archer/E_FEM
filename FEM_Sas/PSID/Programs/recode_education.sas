/* education.sas
   process raw education variables to make:
   edyrs[yy] = # years of school
   educ[yy] = categorical education
   feduc,meduc = father/mother education
   
   educ_b[yy] = Categorical education with six levels

   For 2005-2009 PSID heads and wives
   input: extract_educ.sas7bdat
   output: education.sas7bdat
*/

%include "setup.inc";
%include "&maclib.psidget.mac";  /* macro to get early release data */ 
%include "&maclib.renyrv.mac";  /* macro to rename variables */

proc format;
  value educ
  1="1.Lt HS"
  2="2.GED"
  3="3.HS"
  4="4.some college"
  5="5.BA+"
  .D=".D-DK"
  .R=".R-Ref"
  .M=".M-Missing"
  .X=".X-NA"
  ;
  value degree
  0="0.no degree"
  1="1.GED"
  2="2.HS"
  3="3.HS/GED"
  4="4.AA"
  5="5.BA"
  6="6.MA/MS/MBA"
  7="7.Law/MD/PhD"
  .D=".D-DK"
  .R=".R-Ref"
  .M=".M-Missing"
  .X=".X-NA"
  ;
  value educ_b
  1="1.Lt HS"
  2="2.GED/HS"
  3="3.some college"
  4="4.AA"
  5="5.BA"
  6="6.MA+"
  .D=".D-DK"
  .R=".R-Ref"
  .M=".M-Missing"
  .X=".X-NA"
  ;
  
/* macro to clean mother/father education */
%macro pareduc(mf,parpre);
&mf.educ=.M;
do i = dim(&parpre.educloc_) to 1 by (-1) while (missing(&mf.educ));
		if inyr_[i]=1 then do;
		    /* recode missings */
		    if &parpre.educ_[i]=98 then &parpre.educ_[i]=.D;
		    else if &parpre.educ_[i] in (9,99) then &parpre.educ_[i]=.X;
		    
		    if &parpre.fgneduc_[i]=98 then &parpre.fgneduc_[i]=.D;
		    else if &parpre.fgneduc_[i]=99 then &parpre.fgneduc_[i]=.X;
		    else if &parpre.fgneduc_[i]=0 then &parpre.fgneduc_[i]=.M; /* Inappropriate ask of question */

		    &mf.educ=&parpre.educ_[i];
    		if &mf.educ=0 then &mf.educ=.M; /* no education=0-5 */
    		else if &mf.educ in (4,5) then &mf.educ=4; /* HS */
    		else if &mf.educ=6 then &mf.educ=5; /* some college */
    		else if &mf.educ in (7,8) then &mf.educ=6; /* BA+ */
        
        if not missing (&parpre.fgneduc_[i]) then do;
    		  select;
    		     when(1<=&parpre.fgneduc_[i]<=5) &mf.educ=max(&mf.educ,1);
    		     when(6<=&parpre.fgneduc_[i]<=8) &mf.educ=max(&mf.educ,2);
    		     when(9<=&parpre.fgneduc_[i]<=11) &mf.educ=max(&mf.educ,3);
    		     when(&parpre.fgneduc_[i]=12) &mf.educ=max(&mf.educ,4);
    		     when(13<=&parpre.fgneduc_[i]<=15) &mf.educ=max(&mf.educ,5);
    		     when(16<=&parpre.fgneduc_[i]<90) &mf.educ=max(&mf.educ,6);
    		     otherwise;
    		  end;
        end;
        
        if &mf.educ=.M then do;
           if &parpre.educloc_[i]=5 then &mf.educ=0;
           else if &parpre.educloc_[i]=8 then &mf.educ=.D;
           else if &parpre.educloc_[i]=9 then &mf.educ=.R;
        end;
        
        if &mf.educ=0 then &mf.educ=1; /* recoding 0 (no education) to lowest category that we've been using */
        
    end;
end;
%mend;

data proj.education;
	set proj.extract_educ (keep= id hdwf: head: wife: inyr: hsgrad: attcoll: educloc: educyrs: fgneducyrs: fgndegree: fthreduc: mthreduc: 
		fthrfgneduc: mthrfgneduc: indyrseduc: occ1st: occ2nd: occ3rd: hsgradyr: gedgradyr: collgradyr: colldegree: ) ;
	
	/* Create education dummy arrays - consistent with FEM*/
	array hsless_[*] %listyrv(hsless,begy=1985);
	array college_[*] %listyrv(college,begy=1985);
	
	/*	 Create education variable for years of education */
	array educ_yrs_[*] %listyrv(educ_yrs,begy=1985);
	array educlvl_[*] %listyrv(educlvl,begy=1985);
	
	/* GED array */
	array ged_[*] %listyrv(ged,begy=1985);
	
	/* Create arrays for source data */
	/* from 1985 through 2009 (potentially with gaps) */
	array inyr_[*] %listyrv(inyr,begy=1985);
	array hsgrad_[*] %listyrv(hsgrad,begy=1985);
	array attcoll_[*] %listyrv(attcoll,begy=1985);
	array educloc_[*] %listyrv(educloc,begy=1985);
	array educyrs_[*] %listyrv(educyrs,begy=1985);
	/* Only exist rom 1997 to 2009 */
	array fgneducyrs_[*] %listyrv(fgneducyrs,begy=1985);
	array fgndegree_[*] %listyrv(fgndegree,begy=1985);
	
	array fthreduc_[*] %listyrv(fthreduc,begy=1985);
	array fthrfgneduc_[*] %listyrv(fthrfgneduc,begy=1985);
	array fthreducloc_[*] %listyrv(fthreducloc,begy=1985);
	array mthreduc_[*] %listyrv(mthreduc,begy=1985);
	array mthrfgneduc_[*] %listyrv(mthrfgneduc,begy=1985);
	array mthreducloc_[*] %listyrv(mthreducloc,begy=1985);
	
	/* Education from individual file instead */
	array indyrseduc_[*] %listyrv(indyrseduc,begy=1985);
	
	array occ1st_[*] %listyrv(occ1st,begy=&minrawyr);
  array occ2nd_[*] %listyrv(occ2nd,begy=&minrawyr);
  array occ3rd_[*] %listyrv(occ3rd,begy=&minrawyr);
  array hsgradyr_[*] %listyrv(hsgradyr,begy=&minrawyr);
  array gedgradyr_[*] %listyrv(gedgradyr,begy=&minrawyr);
  array collgradyr_[*] %listyrv(collgradyr,begy=&minrawyr); /* This does not distinguish between degree type! */
  array colldegree_[*] %listyrv(colldegree,begy=&minrawyr);   

  array insamp_[*] %listyrv(inyr,begy=1985);   
  array edyrs_[*] %listyrv(edyrs,begy=1985);
	array degree_[*] %listyrv(degree,begy=1985);
	array educ_[*] %listyrv(educ,begy=1985);
	
	array educ_b_[*] %listyrv(educ_b,begy=1985);
	
	length _yr 3;
	
  if max(of insamp_[*])=1;  /* keep only those who are present in at least one year 1985?-2011 */

	/* Identify respondents who are "out of labor force" - retired, disabled, keeping house, in school, prison/jail */
	array outoflabor_[*] %listyrv(outoflabor,begy=1985);
	
	do i = 1 to dim(outoflabor_);
			if occ1st_[i] >= 4 and occ1st_[i] <= 8 then outoflabor_[i] = 1; /* look at first response */
			if occ1st_[i] >= 1 and occ1st_[i] <= 3 then outoflabor_[i] = 0; 
			if occ2nd_[i] >= 1 and occ2nd_[i] <= 3 then outoflabor_[i] = 0; /* if 2nd response puts in labor force, put in labor force */
			if occ3rd_[i] >= 1 and occ3rd_[i] <= 3 then outoflabor_[i] = 0; /* if 3rd response puts in labor force, put in labor force */
	end;

	/* Standardize year variables for degree dates - some are in YY format, some are YYYY, but only before 2000 */
	do i = 1 to dim(hsgradyr_);
	  _yr=substr(vname(hsgradyr_[i]),9,2);

	  /* before 1993, missing values are indicated by 99 and are 2-digits */

		if hsgradyr_[i] > 0 and hsgradyr_[i] < 93 then hsgradyr_[i] + 1900;
		if gedgradyr_[i] > 0 and gedgradyr_[i] < 93 then gedgradyr_[i] + 1900;
		if collgradyr_[i] > 0 and collgradyr_[i] < 93 then collgradyr_[i] + 1900;
	  if not(1900<hsgradyr_[i]<2100) then hsgradyr_[i]=.X;
	  if not(1900<gedgradyr_[i]<2100) then gedgradyr_[i]=.X;
	  if not(1900<collgradyr_[i]<2100) then collgradyr_[i]=.X;
	end;

  if hsgradyr09 > 0 & hsgradyr09 < 2100 then hsgradyr = hsgradyr09 ; /* Prefer 2009 value */	
	do i = dim(hsgradyr_) to 1 by (-1) while (hsgradyr = .);
		if hsgradyr_[i] > 0 & hsgradyr_[i] < 2100 then hsgradyr = hsgradyr_[i] ;
	end;
		
  if gedgradyr09 > 0 & gedgradyr09 < 2100 then gedgradyr = gedgradyr09 ; /* Prefer 2009 value */
	do i = dim(gedgradyr_) to 1 by (-1) while (gedgradyr = .);
		if gedgradyr_[i] > 0 & gedgradyr_[i] < 2100 then gedgradyr = gedgradyr_[i] ;
	end;	

  do i = dim(colldegree_) to 1 by (-1);
     
     hsdegyr=min(hsdegyr,hsgradyr_[i]);
     if 1900<hsgradyr09<2100 then hsdegyr=min(hsdegyr,hsgradyr_[i]);
     
     if 2<=colldegree_[i]<=8 then do;
        colldegyr=min(colldegyr, collgradyr_[i]);
        if 2<=colldegree09<=8 and 1900<colldegree09<2100 then colldegyr=min(colldegyr,collgradyr09);
     end;
     else do;
        somecollyr=min(somecollyr,collgradyr_[i]);
        if not (2<=colldegree09<=8) and (1900<colldegree09<2100) then 
           somecollyr=min(somecollyr,collgradyr09);
     end;
	end;
	
	do i = dim(collgradyr_) to 1 by (-1) while (aagradyr = .);
		if colldegree_[i] = 1 & collgradyr_[i] < 2100 then aagradyr = collgradyr_[i];
	end;
	if aagradyr<collgradyr09 and
	   colldegree09=1 and 
	   collgradyr09 > 0 & collgradyr09 < 2100 
	   then aagradyr = collgradyr09 ; /* Prefer 2009 value */

	do i = dim(collgradyr_) to 1 by (-1) while (bsgradyr = .);
	   if colldegree_[i] = 2 & collgradyr_[i] < 2100 then bsgradyr = collgradyr_[i];
	end;
	if bsgradyr<collgradyr09 and
	   colldegree09=2 and 
	   collgradyr09 > 0 & collgradyr09 < 2100 
	   then bsgradyr = collgradyr09 ; /* Prefer 2009 value */
	
	do i = dim(collgradyr_) to 1 by (-1) while (bsplusgradyr = .);
		if colldegree_[i] > 2 & colldegree_[i] <=6  & collgradyr_[i] < 2100 then bsplusgradyr = collgradyr_[i];
	end;
	if bsplusgradyr<collgradyr09 and
	   2<colldegree09<=6 and 
	   collgradyr09 > 0 & collgradyr09 < 2100 
	   then bsplusgradyr = collgradyr09 ; /* Prefer 2009 value */
	
	do i = 1 to dim(collgradyr_) while (bsplusgradyralt = .);
		if colldegree_[i] > 2 & colldegree_[i] <=6  & collgradyr_[i] < 2100 then bsplusgradyralt = collgradyr_[i];
	end;
  	
  /* individual education-by year */
	do i = 1 to dim(educyrs_);
    /* these are set whether or not the family responded */
    if indyrseduc_[i]=99 then indyrseduc_[i]=.X;
    else if indyrseduc_[i]=98 then indyrseduc_[i]=.D;
		
		if inyr_[i]=1 then do;
		   if firstyr=. then firstyr=i;
		   lastyr=i;
		   if i>16 and firstsamp=. then firstsamp=i;
		   
       /* first set missing values missing */
       if educyrs_[i]=99 then educyrs_[i]=.X;
       else if educyrs_[i]=98 then educyrs_[i]=.D;

       if fgneducyrs_[i]=99 then fgneducyrs_[i]=.X;
       else if fgneducyrs_[i]=98 then fgneducyrs_[i]=.D;

       if colldegree_[i]=99 then colldegree_[i]=.X;
       else if colldegree_[i]=98 then colldegree_[i]=.D;
       else if colldegree_[i]=97 then colldegree_[i]=.T; /* other */

       edyrs_[i]=educyrs_[i];
       if edyrs_[i]<=.Z and indyrseduc_[i]>.Z then edyrs_[i]=indyrseduc_[i];
       if edyrs_[i]=. then edyrs_[i]=.M;
       degree_[i] = .M;
       educ_[i] = .M;
       educ_b_[i] = .M;
    		if not missing (hsgrad_[i]) then do; /* HS grad not missing */
    			if hsgrad_[i] = 1 then do;
    			   hsless_[i] = 0; /* graduated from high school */
    			   degree_[i] = 2; /* hs degree */
    			   educ_[i] = 3;
    			   educ_b_[i] = 2; /* graduated high school puts in GED/HS category */
    			end;
    			else if hsgrad_[i] = 2 then do; /* got a ged - need to check if attended college to classify */
    				ged_[i] = 1; 
    				degree_[i] = 1; /* GED */
    				educ_[i] = 2; /* GED */
    				educ_b_[i] = 2; /* GED puts in GED/HS category */
    				if attcoll_[i] = 5 then
    					hsless_[i] = 1; /* GED and no college -> hsless = 1 */
    				if attcoll_[i] = 1 then 
    					hsless_[i] = 0; /* GED and college -> hsless = 0 */
    			end;
    			
    			else if hsgrad_[i] = 3 then do;  /* didn't finish high school or get a ged */
    				hsless_[i] = 1;
    				college_[i] = 0;
    				degree_[i] = 0; /* no degree */
    				educ_[i] = 1; /* lt high school */
    				educ_b_[i] = 1; /* Less than high school */
    			end;
    
    			else if hsgrad_[i] = 9 then do;
    			   hsless_[i] = .D;
    			   if educ_[i] in (.,.M) then educ_[i]=.D;
    			   if educ_b_[i] in (.,.M) then educ_b_[i]=.D;
    			   if degree_[i] in (.,.M) then degree_[i]=.D;
    			end;
    		end; /* not missing hs grad */

    		if not missing (attcoll_[i]) then do; /* not missing whether attend college */
     		  if attcoll_[i] = 1 then do; /* Attended college */
    				college_[i] = 1; 
    				hsless_[i] = 0;
   					educ_[i] = 4; /* some college */
   					educ_b_[i] = 3; /* some college */
   					select (colldegree_[i]);
   					   when (1) degree_[i]=4;  /* AA */
   					   when (2) degree_[i]=5;  /* BA */
   					   when (3) degree_[i]=6;  /* MA,MBA */
   					   when (5,6,7) degree_[i]=7; /* Law, MD, PhD */
   					   when (8) degree_[i]=8; /* other = honorary */
   					   otherwise;
   					end;
   					if degree_[i]>=5 then educ_[i]=5;  /* college or above */
   					if degree_[i] = 4 then educ_b_[i] = 4; /* AA degree */
   					if degree_[i] = 5 then educ_b_[i] = 5; /* BA degree */
   					if degree_[i] >= 6 then educ_b_[i] = 6; /* MA or higher */
   					if educ_[i]=4 and degree_[i] in (.,.M,.D) then degree_[i]=3;
    			end;
    			
    			else if attcoll_[i] = 5 then college_[i] = 0; /* Didn't attend college */
    			else if attcoll_[i] = 9 then do;
    			   college_[i] = .D; /* Don't know if attended college */
    			   if educ_[i] in (.,.M) then educ_[i]=.D;
    			   if educ_b_[i] in (.,.M) then educ_b_[i]=.D;
    			   if degree_[i] in (.,.M) then degree_[i]=.D;
    			end;
    		end; /* not missing attcoll */
    		
    		if id = 10006 then put "Checking educ " educ_[i] = educ_b_[i] = degree_[i] = attcoll_[i] = colldegree_[i] =;	
    		    			
    		if not missing(fgndegree_[i]) then do; /* not missing foreign degree */ 
    		
           select (fgndegree_[i]);
   				   when (1,2) fgndeg=0;  /* no degree */
   				   when (3) fgndeg=2;  /* HS */
   				   when (4) fgndeg=4;  /* AA */
   				   when (5) fgndeg=5;  /* BA */
   				   when (6) fgndeg=6;  /* MA,MBA */
   				   when (7) fgndeg=7; /* Law, MD, PhD */
   				   when (9) fgndeg=.D; /* DK */
   				   otherwise fgndeg=.M;
           end;
           degree_[i]=max(degree_[i],fgndeg);
        end;  /* not missing fgndegree */

        if not missing(fgneducyrs_[i]) then do; /* not missing foreign years educ */
           select (degree_[i]);
              when(0) _educ=1;
              when(1) _educ=2;
              when(2,3) _educ=3;
              when(4) _educ=4;
              when(5,6,7,8) _educ=5;
              otherwise _educ=.M;
           end;
          
           educ_[i]=max(educ_[i],_educ);
           if educ_[i]=. then educ_[i]=.M;
           
           /* Six category degree variable */
           select (degree_[i]);
              when(0) _educ_b=1;
              when(1,2,3) _educ_b=2;
              when(4) _educ_b=4;
              when(5) _educ_b=5;
              when(6,7) _educ_b=6;
              otherwise _educ_b=.M;
           end;
          
           educ_b_[i]=max(educ_b_[i],_educ_b);
           if educ_b_[i]=. then educ_b_[i]=.M;
           
           
           select (educ_[i]);
              when(1,2) _edyrs=11;  /* no degree or GED, less than 12 */
              when(3) _edyrs=12; /* HS - 12 yrs */
              when(4) _edyrs=15; /* some college - max 15 yrs */
              when(5) _edyrs=17; /* college and above, max=17 */
              otherwise _edyrs=.M;
           end;
           if edyrs_[i]<=0 and fgneducyrs_[i]>0 then edyrs_[i]=fgneducyrs_[i];
           else if edyrs_[i]>0 and fgneducyrs_[i]>0 then do;
             _sum=edyrs_[i] + fgneducyrs_[i];
             _max=max(edyrs_[i],fgneducyrs_[i]);
             /* select the educ yrs that makes the most sense given the degree */
             select (degree_[i]);
                when(0) edyrs_[i]=max(_max,min(_sum,_edyrs,11)); /* no degree, cap sum at 11 */
                when(1) edyrs_[i]=max(_max,min(_sum,max(_edyrs,11)));  /* GED cap sum at 11, but allow more if college */
                when(2,3,4) edyrs_[i]=max(_max,min(_sum,_edyrs,15)); /* lt BA, cap at 15 */
                when(5) edyrs_[i]=max(_max,min(_sum,_edyrs,16));   /* BA, cap at 16 */
                when(6,7,8) edyrs_[i]=max(_max,min(_sum,_edyrs));
                otherwise;
             end;
          end;  /* not missing foreign educ years */
          
          if edyrs_[i]>0 then edyrs_[i]=min(edyrs_[i],17);  /* cap years at 17 */
          
    			/* for FEM: Prefer to use years of education instead of degree attained */
    			if (edyrs_[i] >= 1 & edyrs_[i] < 12) then do; /* 1 to 11 years of education */
    				hsless_[i] = 1;
    				college_[i] = 0;
    			end;
    			if (edyrs_[i] =12) then do; /* 12 years of education */
    				hsless_[i] = 0;
    				college_[i] = 0;
    			end;
    			if (edyrs_[i] >= 13 & edyrs_[i] <= 25) then do; /* 13 to 25 years of education */
    				hsless_[i] = 0;
    				college_[i] = 1;
    			end;

          educ_yrs_[i]=edyrs_[i];
          checkfgn=(educloc_[i]=3) + 2*(_sum>0);
          if checkfgn>0 then checkfgnsub=i;
    		end;   

    		/* left this here for FEM logic */
    		if educloc_[i] = 3 then do; /* Educated both in and outside of the U.S. */

    			if (hsgrad_[i] = 1 or (fgneducyrs_[i]>=12 and fgneducyrs_[i]<=25)) then hsless_[i] = 0; /* graduated from high school */
    			else if hsgrad_[i] = 2 then do; /* got a ged - need to check if attended college to classify */
    				ged_[i] = 1; 
    				if (attcoll_[i] = 5) and (fgneducyrs_[i]>=0 & fgneducyrs_[i] < 12) then do ;
    					hsless_[i] = 1; /* GED and no college -> hsless = 1 */
    				end;
    				if attcoll_[i] = 1 then do ;
    					hsless_[i] = 0; /* GED and college -> hsless = 0 */
    				end;
    			end;
    			
    			else if hsgrad_[i] = 3 then do;  /* didn't finish high school or get a ged */
    				hsless_[i] = 1;
    				college_[i] = 0;
    			end;
    
    			else if hsgrad_[i] = 9 then hsless_[i] = .;
    			
    			if attcoll_[i] = 1 then do; /* Attended college */
    				college_[i] = 1; 
    				hsless_[i] = 0;
    			end;
    			
    			else if attcoll_[i] = 5 then college_[i] = 0; /* Didn't attend college */
    			else if attcoll_[i] = 9 then college_[i] = .; /* Don't know if attended college */
    		
    			if max(fgneducyrs_[i], educyrs_[i]) < 12 then educlvl_[i] = 0;
    			else if max(fgneducyrs_[i], educyrs_[i]) = 12 then educlvl_[i] = 1;
    			else if max(fgneducyrs_[i], educyrs_[i]) = 13 then educlvl_[i] = 2;
    			else if 14<= max(fgneducyrs_[i], educyrs_[i]) <= 15  then educlvl_[i] = 3;
    			else if max(fgneducyrs_[i], educyrs_[i]) = 16 then educlvl_[i] = 4;
    			else if 17 <= max(fgneducyrs_[i], educyrs_[i]) <= 30 then educlvl_[i] = 5;
          
          educ_yrs_[i]=max(educyrs_[i],fgneducyrs_[i]);
    		end;
    				
    		if educloc_[i] = 5 then do; /* Reports "had no education" */
    			 if edyrs_[i]<=.Z then edyrs_[i]=0;
    			 else _chkedyrs=i;
    			 if degree_[i]<=.Z then degree_[i]=0;
    			 else _chkdeg=i;
    			 if educ_[i]<=.Z then educ_[i]=1;
    			 else _chkeduc=i;
    			 hsless_[i] = 1; 
    			 college_[i] = 0;
    		end;
    		
        /* use grad yrs to set degree if available */
    	  _yr=substr(vname(educ_[i]),5,2);  /* get current year - 4 digits */
    	  if _yr>=85 then _yr=_yr+1900;
    	  else if 0<=_yr<50 then _yr=_yr+2000;
        
        if missing(degree_[i]) or degree_[i]<lastdeg then do;
           if not missing(bsplusgradyr) and bsplusgradyr<=_yr then degree_[i]=6; /* if adv deg then MA */
           else if not missing(bsgradyr) and bsgradyr<=_yr then degree_[i]=5; /* BA */
           else if not missing(aagradyr) and aagradyr<=_yr then degree_[i]=4; /* AA */
           else if not missing(hsdegyr) and hsdegyr<=_yr then degree_[i]=2; /* HS */
           else if not missing(gedgradyr) and gedgradyr<=_yr then degree_[i]=1; /* GED */
           _filldeg=not missing(degree_[i])*i;
        end;
        
      if id = 10006 then put "Checking educ 2 " educ_[i] = educ_b_[i] = degree_[i] = attcoll_[i] = colldegree_[i] =;
    		
        /* use degree to set educ if available */
        if (missing(educ_[i]) or educ_[i]<lasteduc) and
           not missing(degree_[i]) then do;
           select (degree_[i]);
              when (0) educ_[i]=1;
              when (1) educ_[i]=2;
              when (2,3) educ_[i]=3;
              when (4) educ_[i]=4;
              when (5,6,7,8) educ_[i]=5;
              otherwise;
           end;
           _filleducd=not missing(educ_[i])*i;
        end;
        
        
         /* use degree to set educ if available */
        if (missing(educ_b_[i]) or educ_b_[i]<lasteduc_b) and
           not missing(degree_[i]) then do;
           select (degree_[i]);
              when (0) educ_[i]=1;
              when (1) educ_[i]=2;
              when (2,3) educ_[i]=3;
              when (4) educ_[i]=4;
              when (5,6,7,8) educ_[i]=5;
              otherwise;
           end;
           _filleducd=not missing(educ_[i])*i;
        end;
        

        /* use grad yrs to set educ if available */
        if missing(educ_[i]) or educ_[i]<lasteduc then do;
           if not missing(colldegyr) and colldegyr<=_yr then educ_[i]=5;
           else if not missing(somecollyr) and somecollyr<=_yr then educ_[i]=4;
           else if not missing(hsdegyr) and hsdegyr<=_yr then educ_[i]=3;
           else if not missing(gedgradyr) and gedgradyr<=_yr then educ_[i]=2;
           else if not missing(gedgradyr) and gedgradyr>_yr then educ_[i]=1;
           else if not missing(hsdegyr) and hsdegyr>_yr then educ_[i]=1;
           _filleducg=not missing(educ_[i])*i;
        end;
        
        /* use grad yrs to set educ_b if available */
        if missing(educ_b_[i]) or educ_b_[i]<lasteduc_b then do;
        	 if not missing(colldegyr) and colldegyr<=_yr then educ_b_[i]=5; /* Check this for MA+ individuals */
           else if not missing(somecollyr) and somecollyr<=_yr then educ_b_[i]=3;
           else if not missing(hsdegyr) and hsdegyr<=_yr then educ_b_[i]=2;
           else if not missing(gedgradyr) and gedgradyr<=_yr then educ_b_[i]=2;
           else if not missing(gedgradyr) and gedgradyr>_yr then educ_b_[i]=1;
           else if not missing(hsdegyr) and hsdegyr>_yr then educ_b_[i]=1;
           _filleducg=not missing(educ_[i])*i;
        end;
        
        
    		/* if edyrs is missing, fill from educ, degree */
    		if missing(edyrs_[i]) then do;
    		   if educ_[i] in (1,2) or degree_[i] in (0,1) then edyrs_[i]=11;
    		   else if educ_[i]=3 or degree_[i] in (2,3) then edyrs_[i]=12;
    		   else if educ_[i]=4 or degree_[i]=4 then edyrs_[i]=14;
    		   else if degree_[i]>5 then edyrs_[i]=17;
    		   else if educ_[i]=4 or degree_[i]=5 then edyrs_[i]=16;
    		   _filledyrs=not missing(edyrs_[i])*i;
    		end;

    		/* if educ is still missing, fill from edyrs */
    		if missing(educ_[i]) and not missing(edyrs_[i]) then do;
    		   select;
    		      when (edyrs_[i]<12) educ_[i]=1; /* lt HS */
    		      when (edyrs_[i]=12) educ_[i]=3; /* HS */
    		      when (12<edyrs_[i]<16) educ_[i]=4; /* some college */
    		      when (edyrs_[i]>=16) educ_[i]=5; /* BA+ */
    		      otherwise if educ_[i]=. then educ_[i]=.M;
    		   end;
           _filleducy=not missing(educ_[i])*i;
    		end;
    		
    		/* if educ_b is still missing, fill from edyrs */
    		if missing(educ_b_[i]) and not missing(edyrs_[i]) then do;
    		   select;
    		      when (edyrs_[i]<12) educ_b_[i]=1; /* lt HS */
    		      when (edyrs_[i]=12) educ_b_[i]=2; /* GED/HS */
    		      when (12<edyrs_[i]<16) educ_b_[i]=3; /* some college */
    		      when (edyrs_[i]=16) educ_b_[i]=5; /* BA */
    		      when (edyrs_[i]>16) educ_b_[i]=6; /* MA+ */
    		      otherwise if educ_b_[i]=. then educ_b_[i]=.M;
    		   end;
           _filleducy=not missing(educ_[i])*i;
    		end;
    	 
    		if id = 10006 then put "Checking educ 3 " educ_[i] = educ_b_[i] = degree_[i] = attcoll_[i] = colldegree_[i] =;	
    		
    		lasteduc=educ_[i];
    		lasteduc_b=educ_b_[i];
    		lastdeg=degree_[i];
		end;
	end;
	
	/* XXX in 2009 they asked everyone about their education.
	   if present in 2009 use it to fill missings prior */
	
	/* Assign parents education variables */
	feduc=.M;
	meduc=.M;
	/* derive parent's education */
  %pareduc(f,fthr);
  %pareduc(m,mthr);
	
	/* Reconstruct education history from 2009 questions of all heads wives 
			- Each wave, can tell if respondent is in school based on occupational questions 1-3
			- Can determine exact high school graduation and GED dates from questions
			- Can determine date of HIGHEST college degree from questions
					1 = Associates
					2 = Bachelors
					3 = Masters
					4 = PhD
					5 = JD
					6 = MD
					8 = Honorary degree (how to handle? - none in 2009)
					97 = Other
					98 = Don't know
					99 = NA
					0 = Inappropriate, educated outside the US only or no education, no college, completed less than 1 year, no college degree
					
			Approach - Use 2009 if possible, then 2011, then 2007, 2005, ...				
	*/
	

*	drop educlvl85-educlvl97;
*	drop fthreduc85-fthreduc97;
*	drop mthreduc85-mthreduc97;
		
run;

proc freq data=proj.education;
   table meduc feduc checkfgn: _chk: _fill: 
         colldegyr somecollyr aagradyr bsgradyr bsplusgradyr 
         firstyr firstsamp lastyr 
      /missing list;
%macro tabyr;
   %do yy=05 %to 11 %by 2;
   %if &yy lt 10 %then %let yy=0&yy;
   table inyr&yy * (educ&yy edyrs&yy) educ&yy *hsless&yy * college&yy 
         educ&yy * edyrs&yy
     /missing list;
    %end;
%mend;
    %tabyr;
    table educ09 * educ11 educ09*(educ05 educ07)
     /missing list;
run;
proc means data=proj.education;
run;
