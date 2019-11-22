/*
Bryan 12/2013:  SsPIA_v2.ado is a copy of the file previously used in the simulation.  Now, it is
used in the data generation process (in aime_gen_all.do) to calculate PIA values for those who gave
permission to access their Social Security records.  
*/

program define SsPIA_v2,	
	version 9
	syntax varlist [if], gen(namelist)
	marksample touse
	tokenize `varlist'
	#delimit;
	tempvar raime rq rbyr ralive rdthyr; 

	///1. Assign Data to Variables -------------------
	
	qui gen `raime'    = `1'  if `touse';	
	qui gen `rq'       = `2'  if `touse';
	qui gen `rbyr'     = `3'  if `touse';
	qui gen `ralive'   = `4'  if `touse';
	qui gen `rdthyr'   = `5'  if `touse';
	///2. Get Bendpoints for PIA formula 
	///(based on the nwi two years prior to the year reach 62 or died before age 62)

	tempvar yr nwi;
	qui gen `yr' = `ralive'*(`rbyr' + 62) + (1-`ralive')*min(`rbyr' + 62, `rdthyr') if `touse'; 
	egen `nwi' = nwi(`yr'-2) if `touse';
	
	tempname nwi77 b77_1 b77_2 pia_mtr1 pia_mtr2 pia_mtr3 pia_minrate;
	scalar `nwi77' = 9779.44;
	scalar `b77_1' = 180;
	scalar `b77_2' = 1085;	

	tempvar bend1 bend2;
	qui gen `bend1' = (`nwi'/`nwi77')*`b77_1' if `touse';
	qui gen `bend2'  = (`nwi'/`nwi77')*`b77_2' if `touse';
  
	tempvar pia pia_min;
	scalar `pia_mtr1' = 0.9;
	scalar `pia_mtr2' = 0.32;
	scalar `pia_mtr3' = 0.15;
	scalar `pia_minrate' = 11.50;

	qui gen `pia' =  `pia_mtr1'*min(`raime',`bend1')
			+ `pia_mtr2'*min(max(`raime'-`bend1',0),`bend2'-`bend1')
			+ `pia_mtr3'*max(`raime'-`bend2',0) if `touse';

	qui gen `pia_min' = `pia_minrate'*min(max((`rq'/4)-10,0),30)	if `touse';						 	
	qui replace `pia' = max(`pia',`pia_min') if `touse';
	tokenize `gen';
	qui rename `pia' `1';	
end;
