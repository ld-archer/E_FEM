/*************************************************
helpimpR.sas

summarizes hours of help last month to the respondent level, 
from respondent-helper level.

July 2012: reorganized to make helpimpR file in this program,
   separating this from the actual imputatons.

   Imputations are done at resp-helper level.  
   helpimpR collapses to Resp level.
   Separating out this function into this program allows collapsing
   separately based on helper relationship. We will then separate
   spouse help hours from all other help hours. 
   Having spouse help hours separate allows us to assign these hours
   to the spouse later, as hours given.

   total help hours is retained. New variables (_sp, _nonsp) are made
   to separate spouse from non-spouse helper hours.
**************************************************/

options ls=200 ps=82 compress=yes nocenter replace nodate nonumber mprint nofmterr;

%include "../../../fem_env.sas";  /* file to set up libnames, fmt/mac locations */

%let pgm=helpimp;  /* program name, for lst files,  separated by year */

libname imp "&outlib";

** file containing wave-specific asset bracket information **;
proc format;
   value relimp
   1="1.spouse"
   2="2.kid"
   3="3.grandkid"
   4="4.parent/sibling"
   5="5.other rel"
   6="6.nonrel"
   ;


%macro helpimpR(yr,w);

/* sum to respondent level and make annual estimate */

data imp.helpimpR&yr (compress=no);
   set imp.helpimp&yr;
   by hhidpn;
   
   retain r&w.helpdaysmo r&w.helphoursmo r&w.helphoursmo_calc
          r&w.helpdaysmo_sp r&w.helphoursmo_sp r&w.helphoursmo_calc_sp
          r&w.helpdaysmo_nonsp r&w.helphoursmo_nonsp r&w.helphoursmo_calc_nonsp
          r&w.helperct r&w.helperct_nonsp;
   
   array setv_[*] r&w.helpdaysmo r&w.helphoursmo r&w.helphoursmo_calc
          r&w.helpdaysmo_sp r&w.helphoursmo_sp r&w.helphoursmo_calc_sp
          r&w.helpdaysmo_nonsp r&w.helphoursmo_nonsp r&w.helphoursmo_calc_nonsp
          r&w.helperct r&w.helperct_nonsp;
   
   if first.hhidpn then do;
      do i=1 to dim(setv_);
         setv_[i]=0;
      end;
   end;
   
   r&w.helpdaysmo=sum(r&w.helpdaysmo,aidays);
   r&w.helphoursmo=sum(r&w.helphoursmo,aitothr);
   r&w.helphoursmo_calc=sum(r&w.helphoursmo_calc,tothr_calc);
   r&w.helperct=r&w.helperct+1;
   
   if hlprel=1 then do;  /* spouse help hours */
      r&w.helpdaysmo_sp = sum(r&w.helpdaysmo_sp,aidays);
      r&w.helphoursmo_sp = sum(r&w.helphoursmo_sp,aitothr);
      r&w.helphoursmo_calc_sp = sum(r&w.helphoursmo_calc_sp,tothr_calc);
   end;
   
   else do;  /* non-spouse help hours */      
      r&w.helpdaysmo_nonsp = sum(r&w.helpdaysmo_nonsp,aidays);
      r&w.helphoursmo_nonsp = sum(r&w.helphoursmo_nonsp,aitothr);
      r&w.helphoursmo_calc_nonsp = sum(r&w.helphoursmo_calc_nonsp,tothr_calc);
      r&w.helperct_nonsp=r&w.helperct_nonsp+1;
   end;
   if last.hhidpn then do;
      r&w.helpdaysyr=max(0,12*r&w.helpdaysmo);
      r&w.helphoursyr=max(0,12*r&w.helphoursmo);
      r&w.helphoursyr_calc=max(0,12*r&w.helphoursmo_calc);

      r&w.helpdaysyr_sp = max(0,12*r&w.helpdaysmo_sp);
      r&w.helphoursyr_sp = max(0,12*r&w.helphoursmo_sp);
      r&w.helphoursyr_calc_sp = max(0,12*r&w.helphoursmo_calc_sp);

      r&w.helpdaysyr_nonsp = max(0,12*r&w.helpdaysmo_nonsp);
      r&w.helphoursyr_nonsp = max(0,12*r&w.helphoursmo_nonsp);
      r&w.helphoursyr_calc_nonsp = max(0,12*r&w.helphoursmo_calc_nonsp);

      output;
   end;
   
   label
   R&w.helpdaysmo="Total person-days help received/month"
   R&w.helphoursmo="Total person-hours help (days x hours imputed) received/month"
   R&w.helphoursmo_calc="Total person-hours help (days, hours imp sep) received/month"
   R&w.helpdaysyr="Total person-days help ([days*hours] imputed) received/year"
   R&w.helphoursyr="Total person-hours help received/year"
   R&w.helphoursyr_calc="Total person-hours help (days, hours imp sep) received/year"
   r&w.helperct="# of helpers"

   R&w.helpdaysmo_sp = "Total person-days help received/month from spouse"
   R&w.helphoursmo_sp = "Total person-hours help (days x hours imputed) received/month from spouse"
   R&w.helphoursmo_calc_sp = "Total person-hours help (days, hours imp sep) received/month from spouse"
   R&w.helpdaysyr_sp = "Total person-days help ([days*hours] imputed) received/year from spouse"
   R&w.helphoursyr_sp = "Total person-hours help received/year from spouse"
   R&w.helphoursyr_calc_sp = "Total person-hours help (days, hours imp sep) received/year from spouse"

   R&w.helpdaysmo_nonsp = "Total person-days help received/month from non-spouse"
   R&w.helphoursmo_nonsp = "Total person-hours help (days x hours imputed) received/month from non-spouse"
   R&w.helphoursmo_calc_nonsp = "Total person-hours help (days, hours imp sep) received/month from non-spouse"
   R&w.helpdaysyr_nonsp = "Total person-days help ([days*hours] imputed) received/year from non-spouse"
   R&w.helphoursyr_nonsp = "Total person-hours help received/year from non-spouse"
   R&w.helphoursyr_calc_nonsp = "Total person-hours help (days, hours imp sep) received/year from non-spouse"
   r&w.helperct_nonsp="# of non-spouse helpers"
   ;
   keep hhidpn r&w.helpdaysmo r&w.helphoursmo r&w.helphoursmo_calc
               r&w.helpdaysyr r&w.helphoursyr r&w.helphoursyr_calc
               r&w.helpdaysmo_sp r&w.helphoursmo_sp r&w.helphoursmo_calc_sp
               r&w.helpdaysmo_nonsp r&w.helphoursmo_nonsp r&w.helphoursmo_calc_nonsp
               r&w.helpdaysyr_sp r&w.helphoursyr_sp r&w.helphoursyr_calc_sp
               r&w.helpdaysyr_nonsp r&w.helphoursyr_nonsp r&w.helphoursyr_calc_nonsp
               r&w.helperct r&w.helperct_nonsp helperct;
run;
proc means data=imp.helpimpR&yr n mean std p10 min p25 p50 p75 p90 max;
   var R&w.helpdaysmo r&w.helphoursmo r&w.helphoursmo_calc
       r&w.helpdaysyr r&w.helphoursyr r&w.helphoursyr_calc
       r&w.helperct helperct;
run;
proc means data=imp.helpimpR&yr (where=(r&w.helpdaysmo>0))
   n mean std p10 min p25 p50 p75 p90 max;
   title2 conditional on any help;
   var R&w.helpdaysmo r&w.helphoursmo r&w.helphoursmo_calc
       r&w.helpdaysyr r&w.helphoursyr r&w.helphoursyr_calc
       r&w.helperct helperct;
run;

proc printto print="helpimpR&yr..cont.txt" new;
proc contents data=imp.helpimpR&yr;
run;
proc means;
run;
proc printto;
run;

%mend;

%helpimpR(98,4);
%helpimpR(00,5);
%helpimpR(02,6);
%helpimpR(04,7);
%helpimpR(06,8);
%helpimpR(08,9);
%helpimpR(10,10);
%helpimpR(12,11);
%helpimpR(14,12);
