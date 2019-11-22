/*************************************************
volhours.sas

Merge total hours helped last month across years.

Make a stata data set.
**************************************************/

options ls=200 ps=82 compress=yes nocenter replace nodate nonumber mprint nofmterr;

%include "../../../fem_env.sas";  /* file to set up libnames, fmt/mac locations */

libname imp "&outlib";
libname hrs "&hrslib";

** file containing wave-specific asset bracket information **;
   
%let pgm=volhours;  /* program name, for lst files,  separated by year */

%include "&maclib.wvlist.mac";
%include "&maclib.wvlabel.mac";

%let var04=catholic jewish relnone reloth 
           rel_notimp rel_someimp
           suburb exurb;

%macro renvyr(yr);
rename=(catholic=catholic&yr jewish=jewish&yr 
   relnone=relnone&yr reloth=reloth&yr
   rel_notimp=rel_notimp&yr rel_someimp=rel_someimp&yr
   suburb=suburb&yr exurb=exurb&yr)
%mend;

%macro fillit(vnm);
    array &vnm._[*]&vnm.04 &vnm.02 &vnm.06 &vnm.00 &vnm.08 &vnm.98 &vnm.10 &vnm.12;
    do i=1 to dim(&vnm._) while (&vnm not in (0,1));
       if &vnm not in (0,1) then &vnm.=&vnm._[i];
    end;

%mend;

         
data imp.volhours (compress=no);
   merge imp.volimp98 (%renvyr(98) drop=ai: _ai: _volhrs _hlphrs volcap hlpcap)
         imp.volimp00 (%renvyr(00) drop=ai: _ai: _volhrs _hlphrs volcap hlpcap)
         imp.volimp02 (%renvyr(02) drop=ai: _ai: _volhrs _hlphrs volcap hlpcap)
         imp.volimp04 (%renvyr(04) drop=ai: _ai: _volhrs _hlphrs volcap hlpcap) 
         imp.volimp06 (%renvyr(06) drop=ai: _ai: _volhrs _hlphrs volcap hlpcap)
         imp.volimp08 (%renvyr(08) drop=ai: _ai: _volhrs _hlphrs volcap hlpcap)
         imp.volimp10 (%renvyr(10) drop=ai: _ai: _volhrs _hlphrs volcap hlpcap)
         imp.volimp12 (%renvyr(12) drop=ai: _ai: _volhrs _hlphrs volcap hlpcap)
         hrs.rndhrs_&rndv (keep=hhidpn inw4-inw&maxwv)
         ;
    by hhidpn;
    
    if max(of inw4-inw&maxwv)=1;
    
    array inw_[4:&maxwv] inw4-inw&maxwv;
    array volhrs_[4:&maxwv] %wvlist(r,volhrs,begwv=4);
    array volhours_[4:&maxwv] %wvlist(r,volhours,begwv=4);
    array volffhrs_[4:&maxwv] %wvlist(r,volffhrs,begwv=4);
    array volffhours_[4:&maxwv] %wvlist(r,volffhours,begwv=4);
    
    /* fill with zeros if no help */
    do i=4 to &maxwv;
       if inw_[i]=1 then do;
          volhours_[i]=2*max(0,volhrs_[i]);
          volffhours_[i]=2*max(0,volffhrs_[i]);
       end;
    end;
    
    /* set religion / urban-rural vars to 2004.  If 2004 missing,
       use data from other years */

    %fillit(catholic);
    %fillit(jewish);
    %fillit(relnone);
    %fillit(reloth);
    %fillit(rel_notimp);
    %fillit(rel_someimp);
    %fillit(suburb);
    %fillit(exurb);
    
    keep hhidpn %wvlist(r,volhours volffhours,begwv=4) &var04;
   
    %wvlabel(r,volhours,Volunteer help hours /2 yrs,begwv=4);
    %wvlabel(r,volffhours,%str(Fam/friends help help hours /2 yrs),begwv=4);
    label
  	    catholic="Catholic"
  	    jewish="Jewish"
  	    reloth="Other religion"
  	    relnone="No religion"
  	    rel_notimp="Religion not important"
  	    rel_someimp="Religion somewhat important"
  	    suburb="Lives in suburbs"
  	    exurb="Lives in exurbs"
        ;
run;
proc means data=imp.volhours;
proc contents data=imp.volhours;
run;
