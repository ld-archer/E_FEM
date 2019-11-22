%include "setup.inc";
%include "&maclib.psidget.mac";  /* macro to get early release data */ 
%include "&maclib.renyrv.mac";  /* macro to rename variables */

/* Variable lists are now in separate files */
%include "vars_indiv_file.sas"; /* Variable names on the individual file */
%include "vars_educ.sas"; /* Variables from family file associated with education */


/********************************************************************************
Goal:  Pull education (high school graduate and attended college variables) for 
	heads/wives for the 1999+ PSID.  This involves going back to 1985 when they asked
	all heads/wives their education level.
	
********************************************************************************/

/* Make a list of variable names from the XXXXXin list */

/* Location of education */
%yrmacv(&hdeduclocin,begy=1985);
%yrmacv(&wfeduclocin,begy=1985);

/* High school graduate */
%yrmacv(&hdhsgradin,begy=1985);
%yrmacv(&wfhsgradin,begy=1985);

/* Year finished high school */
%yrmacv(&hdhsgradyrin,begy=1985);                                        
%yrmacv(&wfhsgradyrin,begy=1985);

/* Highest grade level if GED */
%yrmacv(&hdgedgradein,begy=1985); 
%yrmacv(&wfgedgradein,begy=1985); 

/* year last attended grade if GED */
%yrmacv(&hdyearlastschlbin,begy=1985); 
%yrmacv(&wfyearlastschlbin,begy=1985); 

/* Year received GED */
%yrmacv(&hdgedgradyrin,begy=1985);
%yrmacv(&wfgedgradyrin,begy=1985);

/* Highest grade if no GED */
%yrmacv(&hdhslessgradein,begy=1985); 
%yrmacv(&wfhslessgradein,begy=1985); 

/* Year last attended grade if no GED */
%yrmacv(&hdhslessyearin,begy=1985); 
%yrmacv(&wfhslessyearin,begy=1985); 

/* Attend college */
%yrmacv(&hdattcollin,begy=1985);
%yrmacv(&wfattcollin,begy=1985);

/* Year last attended college */
%yrmacv(&hdattcollyrin,begy=1985); 
%yrmacv(&wfattcollyrin,begy=1985); 

/* Highest year of college completed */
%yrmacv(&hdcollyearsin,begy=1985); 
%yrmacv(&wfcollyearsin,begy=1985); 

/* Whether received a college degree */
%yrmacv(&hdearncolldegreein,begy=1985); 
%yrmacv(&wfearncolldegreein,begy=1985); 

/* Highest college degree */
%yrmacv(&hdcolldegreein,begy=1985);
%yrmacv(&wfcolldegreein,begy=1985);

/* Year received highest college degree */
%yrmacv(&hdcollgradyrin,begy=1985);
%yrmacv(&wfcollgradyrin,begy=1985);

/* Years of foreign education */
%yrmacv(&hdfgneducyrsin,begy=1985);
%yrmacv(&wffgneducyrsin,begy=1985);

/* Foreign degrees */
%yrmacv(&hdfgndegreein,begy=1985);
%yrmacv(&wffgndegreein,begy=1985);

/* Parents education */
%yrmacv(&hdfthreducin,begy=1985);
%yrmacv(&hdmthreducin,begy=1985);
%yrmacv(&wffthreducin,begy=1985);
%yrmacv(&wfmthreducin,begy=1985);

%yrmacv(&hdfthrfgneducin,begy=1985);
%yrmacv(&hdmthrfgneducin,begy=1985);
%yrmacv(&wffthrfgneducin,begy=1985);
%yrmacv(&wfmthrfgneducin,begy=1985);
      
%yrmacv(&hdfthreduclocin,begy=1985);
%yrmacv(&hdmthreduclocin,begy=1985);
%yrmacv(&wffthreduclocin,begy=1985);
%yrmacv(&wfmthreduclocin,begy=1985);

/* Occupation of head and wife (three mentions) */
%yrmacv(&hdocc1stin,begy=1985);																				
%yrmacv(&hdocc2ndin,begy=1985);                                        
%yrmacv(&hdocc3rdin,begy=1985);                                        
%yrmacv(&wfocc1stin,begy=1985);                                                  
%yrmacv(&wfocc2ndin,begy=1985);                                        
%yrmacv(&wfocc3rdin,begy=1985);                                        


/* Years of education - PSID Summary variable */
%yrmacv(&hdeducyrsin,begy=1985);
%yrmacv(&wfeducyrsin,begy=1985);
      
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
%chkvars(&minrawyr,&maxyr);


/* make macro variables to list raw variables across all years */

/*** individual file ***/
%let famnum=%selectv(%quote(&famnumin),begy=1968,endy=1968);
%let famnum=&famnum %selectv(%quote(&famnumin),begy=1985);
%let seq=%selectv(%quote(&seqin),begy=1968,endy=1968);
%let seq=&seq %selectv(%quote(&seqin),begy=1985);
%let famfid=%selectv(%quote(&famfidin),begy=1985);
%let relhd=%selectv(%quote(&relhdin),begy=1985);
%let indyrseduc=%selectv(%quote(&indyrseducin),begy=1985);



/*** family file variables ***/
%let hdhsgrad=%selectv(%quote(&hdhsgradin),begy=1985);
%let wfhsgrad=%selectv(%quote(&wfhsgradin),begy=1985);           
%let hdattcoll=%selectv(%quote(&hdattcollin),begy=1985);
%let wfattcoll=%selectv(%quote(&wfattcollin),begy=1985);

%let hdeducloc=dum85-dum96 %selectv(%quote(&hdeduclocin),begy=1997);
%let wfeducloc=dum85-dum96 %selectv(%quote(&wfeduclocin),begy=1997);
%let hdeducyrs=%selectv(%quote(&hdeducyrsin),begy=1985);
%let wfeducyrs=%selectv(%quote(&wfeducyrsin),begy=1985);
%let hdfgneducyrs=dum85-dum96 %selectv(%quote(&hdfgneducyrsin),begy=1997);   
%let wffgneducyrs=dum85-dum96 %selectv(%quote(&wffgneducyrsin),begy=1997);   
%let hdfgndegree=dum85-dum96 %selectv(%quote(&hdfgndegreein),begy=1997);  
%let wffgndegree=dum85-dum96 %selectv(%quote(&wffgndegreein),begy=1997);  

%let hdfthreduc=%selectv(%quote(&hdfthreducin),begy=1985);
%let hdmthreduc=%selectv(%quote(&hdmthreducin),begy=1985);
%let wffthreduc=%selectv(%quote(&wffthreducin),begy=1985);
%let wfmthreduc=%selectv(%quote(&wfmthreducin),begy=1985);

%let hdfthrfgneduc=dum85-dum96 %selectv(%quote(&hdfthrfgneducin),begy=1997);
%let hdmthrfgneduc=dum85-dum96 %selectv(%quote(&hdmthrfgneducin),begy=1997);
%let wffthrfgneduc=dum85-dum96 %selectv(%quote(&wffthrfgneducin),begy=1997);
%let wfmthrfgneduc=dum85-dum96 %selectv(%quote(&wfmthrfgneducin),begy=1997);

%let hdfthreducloc=dum85-dum96 %selectv(%quote(&hdfthreduclocin),begy=1997);
%let hdmthreducloc=dum85-dum96 %selectv(%quote(&hdmthreduclocin),begy=1997);
%let wffthreducloc=dum85-dum96 %selectv(%quote(&wffthreduclocin),begy=1997);
%let wfmthreducloc=dum85-dum96 %selectv(%quote(&wfmthreduclocin),begy=1997);

%let hdocc1st=dum85-dum94 %selectv(%quote(&hdocc1stin),begy=1994);
%let hdocc2nd=dum85-dum94 %selectv(%quote(&hdocc2ndin),begy=1994);
%let hdocc3rd=dum85-dum94 %selectv(%quote(&hdocc3rdin),begy=1994);
%let wfocc1st=dum85-dum94 %selectv(%quote(&wfocc1stin),begy=1994);
%let wfocc2nd=dum85-dum94 %selectv(%quote(&wfocc2ndin),begy=1994);
%let wfocc3rd=dum85-dum94 %selectv(%quote(&wfocc3rdin),begy=1994);
%let hdhsgradyr=%selectv(%quote(&hdhsgradyrin),begy=1985);
%let wfhsgradyr=%selectv(%quote(&wfhsgradyrin),begy=1985);
%let hdgedgradyr=%selectv(%quote(&hdgedgradyrin),begy=1985);
%let wfgedgradyr=%selectv(%quote(&wfgedgradyrin),begy=1985);
%let hdcollgradyr=%selectv(%quote(&hdcollgradyrin),begy=1985);
%let wfcollgradyr=%selectv(%quote(&wfcollgradyrin),begy=1985);
%let hdcolldegree=%selectv(%quote(&hdcolldegreein),begy=1985);
%let wfcolldegree=%selectv(%quote(&wfcolldegreein),begy=1985);

data ind;
   set psid.ind&maxyr.er  ( KEEP = &famnum &seq &relhd ER32000 &indyrseduc RENAME = ( ER32000=sex  ) );
   
   array famnumin_[*] &famnum;
   array famnum_[*]   famnum68 %listyrv(famnum,begy=&minrawyr);
   array seqin_[*]    &seq;
   array seq_[*]      pn68 %listyrv(seq,begy=&minrawyr);
   array relhdin_[*]  _dum &relhd;
   array relhd_[*]    _dum %listyrv(relhd,begy=&minrawyr);
   array indyrseducin_[*] 	_dum &indyrseduc;
   array indyrseduc_[*]	_dum %listyrv(indyrseduc,begy=&minrawyr);

   do i=1 to dim(famnum_);
      famnum_[i]=famnumin_[i];
      seq_[i]=seqin_[i];
      relhd_[i]=relhdin_[i];
      indyrseduc_[i]=indyrseducin_[i];
   end;
   
   id=famnum68*1000 + pn68;
   drop _dum &famnum &seq &relhd;
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



proc sql;

   /* gets variables for requested years and merge to ids in ind1
      by looping through all the family files
      Assumes vars[yy] macro vars have been set up (see yrmacv macro)
   */
   
   %famget(psid,ind1,begy=1985,famid=&famfid);
   
   

/* merge all the parts together. */

data proj.extract_educ probs; /* change proj.tmp to desired output file name */
   merge %listyrv(fam,begy=1985)  /* this lists all the requested fam files */
         ind1 (in=_ini drop=dup)
	 ;  
   by id;

   inind=_ini;  /* flags cases found on individual file - should be all */
   if id=. then output probs;
   dupid=(first.id=0 or last.id=0);
   if dupid=1 then output probs;  /* dups */

   /* raw variables */
   array hdhsgrad_[*] &hdhsgrad;
   array wfhsgrad_[*] &wfhsgrad;
   array hdattcoll_[*] &hdattcoll;
   array wfattcoll_[*] &wfattcoll;
                                         
   array hdeducloc_[*] &hdeducloc;
   array wfeducloc_[*] &wfeducloc;
   array hdeducyrs_[*] &hdeducyrs;
   array wfeducyrs_[*] &wfeducyrs;
   array hdfgneducyrs_[*] &hdfgneducyrs;
   array wffgneducyrs_[*] &wffgneducyrs;
   array hdfgndegree_[*] &hdfgndegree;
   array wffgndegree_[*] &wffgndegree;
   
   array hdfthreduc_[*] &hdfthreduc;
   array hdmthreduc_[*] &hdmthreduc;
   array wffthreduc_[*] &wffthreduc;
   array wfmthreduc_[*] &wfmthreduc;
   
   array hdfthrfgneduc_[*] &hdfthrfgneduc;
   array hdmthrfgneduc_[*] &hdmthrfgneduc;
   array wffthrfgneduc_[*] &wffthrfgneduc;
   array wfmthrfgneduc_[*] &wfmthrfgneduc;
   
   array hdfthreducloc_[*] &hdfthreducloc;
   array hdmthreducloc_[*] &hdmthreducloc;
   array wffthreducloc_[*] &wffthreducloc;
   array wfmthreducloc_[*] &wfmthreducloc;
   
   array hdocc1st_[*] &hdocc1st;
   array hdocc2nd_[*] &hdocc2nd;
   array hdocc3rd_[*] &hdocc3rd;
   array wfocc1st_[*] &wfocc1st;
   array wfocc2nd_[*] &wfocc2nd;
   array wfocc3rd_[*] &wfocc3rd;
   array hdhsgradyr_[*] &hdhsgradyr;
   array wfhsgradyr_[*] &wfhsgradyr;
   array hdgedgradyr_[*] &hdgedgradyr;
   array wfgedgradyr_[*] &wfgedgradyr;
   array hdcollgradyr_[*] &hdcollgradyr;
   array wfcollgradyr_[*] &wfcollgradyr;
   array hdcolldegree_[*] &hdcolldegree;
   array wfcolldegree_[*] &wfcolldegree;
   
  
   /* relhd=1 or 10 for head, 2 or 20 for wife.  2-digit relhd codes begin
      in 1984, i think */

   array relhd_[*] %listyrv(relhd,begy=&minrawyr);
   array seq_[*] %listyrv(seq,begy=&minrawyr);
   array inyr_[*] %listyrv(inyr,begy=&minrawyr);
   array head_[*] %listyrv(head,begy=&minrawyr);
   array wife_[*] %listyrv(wife,begy=&minrawyr);
 /*  array hdwf_[*] %listyrv(hdwf,begy=&minrawyr); */
   array diedyr_[*] %listyrv(diedyr,begy=&minrawyr);
   array died_[*] %listyrv(died,begy=&minrawyr);
   array hsgrad_[*] %listyrv(hsgrad,begy=&minrawyr);
   array attcoll_[*] %listyrv(attcoll,begy=&minrawyr);
   
   array educloc_[*] dum85-dum96 %listyrv(educloc,begy=1997);
   array educyrs_[*] %listyrv(educyrs,begy=&minrawyr);
   array fgneducyrs_[*] dum85-dum96 %listyrv(fgneducyrs,begy=1997);
   array fgndegree_[*] dum85-dum96 %listyrv(fgndegree,begy=1997);
   
   array fthreduc_[*] %listyrv(fthreduc,begy=&minrawyr);
   array mthreduc_[*] %listyrv(mthreduc,begy=&minrawyr);
	 array fthreducloc_[*] %listyrv(fthreducloc,begy=&minrawyr);
   array mthreducloc_[*] %listyrv(mthreducloc,begy=&minrawyr);
   array fthrfgneduc_[*] %listyrv(fthrfgneduc,begy=&minrawyr);
   array mthrfgneduc_[*] %listyrv(mthrfgneduc,begy=&minrawyr);   
   
   array occ1st_[*] %listyrv(occ1st,begy=&minrawyr);
   array occ2nd_[*] %listyrv(occ2nd,begy=&minrawyr);
   array occ3rd_[*] %listyrv(occ3rd,begy=&minrawyr);
   array hsgradyr_[*] %listyrv(hsgradyr,begy=&minrawyr);
   array gedgradyr_[*] %listyrv(gedgradyr,begy=&minrawyr);
   array collgradyr_[*] %listyrv(collgradyr,begy=&minrawyr);
   array colldegree_[*] %listyrv(colldegree,begy=&minrawyr);   
   
    
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
      yr=substr(vname(relhd_[i]),6,2);
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
   	   				head_[i] = 1;
   	   				hdwfever = 1;
   	   				hsgrad_[i] 				= hdhsgrad_[i];
        			attcoll_[i]				=	hdattcoll_[i];
        			educloc_[i]       = hdeducloc_[i];   
        			educyrs_[i]       = hdeducyrs_[i];  
        			fgneducyrs_[i]    = hdfgneducyrs_[i];
        			fgndegree_[i]     = hdfgndegree_[i]; 
        			fthreduc_[i]			= hdfthreduc_[i];
        			mthreduc_[i]			= hdmthreduc_[i];
        			fthrfgneduc_[i]		= hdfthrfgneduc_[i];
        			mthrfgneduc_[i]		= hdmthrfgneduc_[i];
        			fthreducloc_[i]		= hdfthreducloc_[i];
        			mthreducloc_[i]		= hdmthreducloc_[i]; 
         
							occ1st_[i]        = hdocc1st_[i];   
              occ2nd_[i]        = hdocc2nd_[i]; 
              occ3rd_[i]        = hdocc3rd_[i]; 
              hsgradyr_[i]      = hdhsgradyr_[i];
              gedgradyr_[i]     = hdgedgradyr_[i];
              collgradyr_[i]    = hdcollgradyr_[i];
              colldegree_[i]    = hdcolldegree_[i];
         
      		end;

         	else if relhd_[i] in (2,20,22) then do;  /* WIFE */
          	  wife_[i] = 1;
          	  hdwfever = 1;
	      			hsgrad_[i] 				= wfhsgrad_[i];
       				attcoll_[i]				=	wfattcoll_[i];
       				educloc_[i]       = wfeducloc_[i];   
        			educyrs_[i]       = wfeducyrs_[i];  
        			fgneducyrs_[i]    = wffgneducyrs_[i];
        			fgndegree_[i]     = wffgndegree_[i]; 
        			fthreduc_[i]			= wffthreduc_[i];
        			mthreduc_[i]			= wfmthreduc_[i];
							fthrfgneduc_[i]		= wffthrfgneduc_[i];
        			mthrfgneduc_[i]		= wfmthrfgneduc_[i];
        			fthreducloc_[i]		= wffthreducloc_[i];
        			mthreducloc_[i]		= wfmthreducloc_[i];          
							occ1st_[i]        = wfocc1st_[i];   
              occ2nd_[i]        = wfocc2nd_[i]; 
              occ3rd_[i]        = wfocc3rd_[i]; 
              hsgradyr_[i]      = wfhsgradyr_[i];
              gedgradyr_[i]     = wfgedgradyr_[i];
              collgradyr_[i]    = wfcollgradyr_[i];
              colldegree_[i]    = wfcolldegree_[i];

          end;
      end; /* people in FU */
      
      else inyr_[i]=0;
      
      
   end;  /* do i=1 to dim(seq_) */
   
   any_yr=max(of inyr_[*]);
    
   /* Only keep individuals who are ever heads or wives */
  if hdwfever = 1;
  /* Only those individuals who are alive in 99 */
  if died99 = 0;
   
   if first.id then output proj.extract_educ;
   
    drop yr year i _died;
   
run;