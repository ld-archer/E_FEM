/* 
Assign spouse/partner IDs for each wave so that we can easily link up partners.
Output variable names: sp_id[YEAR]
*/


%include "setup.inc";
*%include "&maclib.psidget.mac";  /* macro to get early release data */ 
%include "&maclib.renyrv.mac";  /* macro to rename variables */

/* Merge on spouse IDs */
proc format;
   value hdwfrel
   1,10="head"
   2,20="wife"
   22="coh wife"
   other="other";
   
proc sql;
%macro getwfrel(begy,endy);
  %global mrgwife;
  %let mrgwife=;
  %global mrghead;
  %let mrghead=;
  
  %do y = &begy %to &endy %by 2;
   %let yy=%substr(&y,3);
   
   create table wife_id&yy as 
      select a.id, a.head&yy, a.inyr&yy, b.relhd&yy as wfrelhd&yy, b.id as wife_id&yy
      from proj.extract_data (keep=id famnum&yy inyr&yy head&yy wife&yy
                              where=(inyr&yy = 1 and head&yy = 1)) a
           left join
           proj.extract_data (keep=id relhd&yy inyr&yy famnum&yy wife&yy
                              where=(inyr&yy = 1 and wife&yy = 1)) b
           on a.famnum&yy = b.famnum&yy
           order a.id;
   %let mrgwife=&mrgwife wife_id&yy ;
   
   create table head_id&yy as 
      select a.id, a.wife&yy, a.inyr&yy, b.relhd&yy as hdrelhd&yy,b.id as head_id&yy
      from proj.extract_data (keep=id famnum&yy inyr&yy head&yy wife&yy
                              where=(inyr&yy = 1 and wife&yy = 1)) a
           left join
           proj.extract_data (keep=id relhd&yy inyr&yy famnum&yy head&yy
                              where=(inyr&yy = 1 and head&yy = 1)) b
           on a.famnum&yy = b.famnum&yy
           order a.id;
   %let mrghead=&mrghead head_id&yy ;
  %end;
%mend;
    
   %getwfrel (1999,&maxyr);
data proj.wfrel;
   merge &mrghead &mrgwife ;
   by id;
   
  array inyr_[*] %listyrv(inyr,begy=1999);
  array wife_[*]  %listyrv(wife,begy=1999);
  array wife_id_[*]  %listyrv(wife_id,begy=1999);
  array head_[*]  %listyrv(head,begy=1999);
  array head_id_[*]  %listyrv(head_id,begy=1999);
  array sp_id_[*]  %listyrv(sp_id,begy=1999);

  do i=1 to dim(inyr_);     
     if inyr_[i]=1 then do;
        if wife_[i]=1 then sp_id_[i]=head_id_[i];
        else if head_[i]=1 then sp_id_[i]=wife_id_[i];
     end;
  end;

run;