* ************************************************************************* ;
*                               CFMC                                        ;
*  Program Name:  Value to DC Formats YYYY.MM.DD.sas						;
*  Program Location :                                                       ;
*  Purpose of Program: Formats ad hoc data to fit the needs of the Patient- ;
*						Level Longitudinal History Print Program			;
*                                                                           ;
*  Created by: Diane Campbell												;
*			   Jason Mitchell                                    		    ;
*																			;
*  Creation Date: Fall 2007                                                 ;
*                                                                           ;
*  Project Name: VALUE            	                                        ;
*                                                                           ;
*  Input Files: In general, 5 SAS data sets: 								;
*				 1. abase													;
*				 2. arvc													;
*				 3. bbase													;
*				 4. bline													;
*				 5. indexhosp (See notes below.)							;
* ************************************************************************* ;
*  Verified by: Jennifer Regensburger                                       ;
*  Verification date: Winter 2007                                           ;
* ************************************************************************* ;


* PART I:   Defines libnames and datasets.									;
* PART II:  Compiles demographic information for patients of interest.		;
* PART III: Compiles Part A-based patient history data.						;
*		     a:  Inpatient													;
*		     b.  Outpatient													;
*		     c.  Home Health												;
*		     d.  SNF														;
*		     e.  Hospice													;
* PART IV:  Compiles Part B-based patient history data.						;
* PART V:   Merges Part A- and Part B-based data and cleans up HCPCS codes. ; 
*			 a.	 Merge demographic and Part B-based data.					;
*			 b.  Merge demographic and Part A-based data.					;
*			 c.  Clean up HCPCS codes.										;
* PART VI:  Compiles summary statistics.  									;
* PART VII: Print data and make patient histories.							;





* The index table must contain the following info, although much of this	;
* may be omitted.  If omitted, you will need to adjust the code so that		;
* SAS doesn't stall when looking for these demographic variables.			;
*																			;
* finder_claim_num	This is a unique patient identifier.  					;
* bene_sex_ident_cd	This is a sex identifying variable.  					;
* bene_race_cd		This is a race identifying variable.  					;
* index_thru_dt		This is an index event date particular to your study.	;
* bene_birth_dt		This is a birth date.									;
* state_code		This is your state.										;


* Note that this code is variable final_action_sw dependent.  This			;
* variable has not always been present on Part A and Part B data sets.  As	; 
* such, you may need to manipulate the code and/or your older data sets in	; 
* order to utilize this program.  											;


* Note that within the Part A data set, data are restricted via the 		;
* variables nch_clm_type_cd and final_action_sw.  The nch_clm_type_cd		;
* variable identifies the setting in which the claim occurred, e.g., HH,	;
* while the final_action_sw identifies the most recent activity associated	;
* with a claim.  															;
*																			;
* Within the Part B data set, data are restricted via the variables			;
* hse_b_plc_srvc_cd, "The code indicating the place of service, as defined	;
* in the Medicare Carrier manual for the claim." and hse_b_type_srvc_cd,	;
* "The type of service code used for pricing the services reported on the 	;
* claim."  Within this code, we restrict to									;
*																			;
* hse_b_plc_srvc_cd data value '11'	-- Office								;
* hse_b_plc_srvc_cd data value '49'	-- Independent Clinic					;
* hse_b_plc_srvc_cd data value '50'	-- Federally Qualified Health Center	;
* hse_b_plc_srvc_cd data value '71'	-- State or Local Public Health Clinic	;
* hse_b_plc_srvc_cd data value '72'	-- Rural Health Clinic					;
*																			;
* hse_b_type_srvc_cd data value '1' -- Medical Care							;
* hse_b_type_srvc_cd data value '3' -- Consultation.						;
*																			;
* Depending on your work focus, you may choose to change these.  			;


* The VALUE team has been at odds at how best to define a unique patient	;
* physician office visit within the Part B data set.  For now, as 			;
* discussion with IFMC continues, we have made the best with what we have	;
* and have attempted to force uniqueness by concatenating two Part B-based	;
* variables, i.e., hse_b_prvdr_tax_num and physician_upin, both present on	;
* the bline data table.  A unique visit variable is necessary here in order ;
* to identify practice specialties.  As this information is perhaps not so	;
* important, details regarding the history behind the construction of the	;
* upin_taxnum_concat will stop here.  It should be noted however that this	;
* concatenation approach is imperfect.										;


* In dealing with ad hoc data, HCPCS codes are listed between patients (in 	;
* many rows) contrary to the Diag codes, which are listed within patients	;
* (within one row).  As such, HCPCS codes need to be manipulated into one	;
* patient line item so they are not missed.  								;
*																			;
* This gets tricky, as there are blank hcpcs01 line items. 					; 
* 																			;
* Further, with our data we see that we have 1 patient with 36 different	;
* HCPCS codes.  It is thus advantageous to restrict the number of codes		;
* printed to output.  We see with our ad hoc data that roughly 96% or so 	;
* of line items can be numbered 1 through 10 on a per patient, per visit	;
* basis. 																	;  
* 																			;
* I restrict the number of unique HCPCS codes printed per patient per visit ;
* to this number.  Further on, I amend the code to display a message 		;
* if more HCPCS	codes, for a given patient and visit, are in the data set	;
* that don't actually make it into the patient print out, i.e., these		;
* are HCPCS line items 11-xx. This is done so that this information is not 	;
* lost for those patients.  												;
*																			;
* Therefore, in order so that readers of printed output know that some 		;
* patients have	more HCPCS code in the underlying data set for a particular ;
* visit, the data set is manipulated to substitute code '00000' for the 	;
* final (10th) HCPCS code, provided an 11th one exists.  In this way, when 	;
* formats are applied to the printed output, the 10th line item for that 	;
* particular visit will read 'See data set for more detail', thus 			;
* communicating to the investigator that more information for this 			;
* patient's particular physician office visit exists, while at the same		;
* time, allowing for some format control.  The pagination increases 		;
* quickly.  Our 354 index patient data set produces 1,616 pages of output.  ;

* Dollar amounts for Part B data must be summed across records for a 		;
* particular visit.  This is contrary to Part A records, where this step	;
* is not necessary.															;


* ************************************************************************* ;				
* PART I:    Defines libnames and datasets.									;
* ************************************************************************* ;

* If you want to avoid page breaks between cases, set pagesize very high, 	;
* e.g., pagesize=2000.  Otherwise, set at 62 to get a new page at every 	;
* case.																	 	;
options nocenter linesize=128 pagesize=2000 nodate orientation=landscape number;

* These three text descriptors appear on the output.  The first corresponds ;
* to the index event description, the second the left-aligned top margin,	;
* and the third, the date description that appears in the right-aligned top ;
* margin. Change these three statements to title your output as				;
* appropriate for your project.  Note that the third let statement may 		;
* need to change, based on its length, in order to ensure it aligns with    ;
* the right margin.															;
%let ie_desc=The day we went to the zoo.;
%let title=This is where the title goes. You can make it fancy.;
%let datedesc=You can put a date or some other info descriptor here.;

* Wherever your claims reside.												;
libname claims 'S:\VALUE\Data\combined claims';

* Wherever your index set data reside.										;
libname value 'S:\VALUE\Data';

* Wherever you want the output dataset to go.								;
libname emrin 'S:\VALUE\DCampbell Work\Data';

* Wherever you want the output .rtf file to go.  							;
filename emrprint "S:\VALUE\DCampbell Work\Documents\Program Output\PatientHistories.rtf" ;

* Be sure these format files are the most current and include any local		;
* codes, if appropriate.  This is particularly importatant for the ICD-9, 	;
* CPT-4, and HCPCS codes.													;
%include            "S:\VALUE\DCampbell Work\Documents\generalfmts.txt";
%include            "S:\VALUE\DCampbell Work\Documents\icd9dxfmt.txt";
%include            "S:\VALUE\DCampbell Work\Documents\icd9sxfmt.txt";
%include            "S:\VALUE\DCampbell Work\Documents\hcpcsfmt.txt";

* Get abase table.	Change this dataset to whatever you have.				;														;
data abase;
	set claims.abase_subset;
run;

* Get arvc table.  Change this dataset to whatever you have. 				;
data arvc;
	set claims.arvc_subset;
run;

* Get bbase table.  Change this dataset to whatever you have.  				;
data bbase;
	set claims.bbase_subset;
run;

* Get bline table.  Change this dataset to whatever you have.  				;
data bline;
	set claims.bline_subset;
run;

* Get index table.  Change this dataset to whatever you have.  				;
data indextable;
	set value.indextest;
run;



* ************************************************************************* ;				
*  PART II:   Compiles demographic information for patients of interest.	;
* ************************************************************************* ;

data commonarea (keep=case_id hsp_id sex race ie_date dob age stab);
	rename bene_sex_ident_cd = sex
		   bene_race_cd = race
		   bene_birth_dt = dob
		   state_code = stab;
	set indextable;
	case_id = put(finder_claim_num,12.);
	ie_date = index_thru_dt;
	age = intck('year',bene_birth_dt,index_thru_dt)-((month(bene_birth_dt) gt month (index_thru_dt)) or (month(bene_birth_dt) eq month(index_thru_dt) and day(bene_birth_dt) gt day(index_thru_dt)));
	format ie_date dob yymmdd8.;
run;



* ************************************************************************* ;				
* PART III: Compiles Part A-based patient history data.						;
*		     a:  Inpatient													;
*		     b.  Outpatient													;
*		     c.  Home Health												;
*		     d.  SNF														;
*		     e.  Hospice													;
* ************************************************************************* ;

proc sort data=abase; by hse_unique_id; run;
proc sort data=arvc;  by hse_unique_id; run;

data prt_a_mrg;
	merge abase (in = a)
	      arvc  (in = b);
	by hse_unique_id;
	if a and b then output prt_a_mrg;
run;

%macro makesettings(setting, claimtypeold, claimtypenew);

	data &setting (keep=case_id prindiag diag01-diag09 hcpcs01-hcpcs15 proc01-proc06 pay_amt physerv provspec place from_dt thru_dt clmtype);
		rename finder_claim_num = case_id
			   clm_prncpal_dgns_cd = prindiag
			   dgns_cd_1 = diag01
			   dgns_cd_2 = diag02
			   dgns_cd_3 = diag03
			   dgns_cd_4 = diag04
			   dgns_cd_5 = diag05
			   dgns_cd_6 = diag06
			   dgns_cd_7 = diag07
			   dgns_cd_8 = diag08
			   dgns_cd_9 = diag09
			   hcpcs_code = hcpcs01
			   prcdr_cd_1 = proc01 
			   prcdr_cd_2 = proc02 
			   prcdr_cd_3 = proc03 
			   prcdr_cd_4 = proc04 
			   prcdr_cd_5 = proc05
			   prcdr_cd_6 = proc06
			   hse_clm_pym_amt = pay_amt
			   hse_clm_from_dt = from_dt
			   hse_clm_thru_dt = thru_dt
			   nch_clm_type_cd = place;
		set prt_a_mrg;
		clmtype = "&claimtypenew";
		length provspec $2.;
		length physerv $1.;
		length hcpcs02-hcpcs15 $5.;
		where nch_clm_type_cd in ("&claimtypeold") and final_action_sw='Y';
		format from_dt thru_dt yymmdd8. finder_claim_num $12.;
	run;

%mend makesettings;

%makesettings(inpatient,60,1);
%makesettings(outpatient,40,2);
%makesettings(hha,10,4);
%makesettings(snf,20" "30,5);
%makesettings(hospice,50,6);



* ************************************************************************* ;				
*  PART IV:  Compiles Part B-based patient history data.					;
* ************************************************************************* ;

proc sql;
	create table prt_b_mrg as
	select distinct indextable.finder_claim_num, bbase.*, bline.*, 
					strip(bline.hse_b_prvdr_tax_num) || strip(bline.physician_upin) as upin_taxnum_concat
	from indextable, bbase, bline
		where indextable.finder_claim_num =  bbase.finder_claim_num and
		   		      bbase.hse_unique_id =  bline.hse_unique_id and
                  bline.hse_b_plc_srvc_cd in ('11', '49', '50', '71', '72') and
				 bline.hse_b_type_srvc_cd in ('1' , '3') and
		            bbase.final_action_sw =  'Y';
quit;

data physician (keep=case_id prindiag diag01-diag09 hcpcs01-hcpcs15 proc01-proc06 pay_amt physerv provspec place from_dt thru_dt clmtype upin_taxnum_concat);
	rename finder_claim_num = case_id
		   dgns_cd = prindiag
		   dgns_cd_2 = diag01
		   dgns_cd_3 = diag02
		   dgns_cd_4 = diag03
		   hcpcs_code = hcpcs01
		   hse_b_clm_pmt_amt = pay_amt
		   hse_clm_from_dt = from_dt
		   hse_clm_thru_dt = thru_dt
		   hse_b_hcfa_prvdr_spclty_cd = provspec
		   hse_b_plc_srvc_cd = place
		   hse_b_type_srvc_cd = physerv;
	set prt_b_mrg;
	clmtype = '3';
	length hcpcs02-hcpcs15 proc01-proc06 diag04-diag09 $5.;
	format from_dt thru_dt yymmdd8. finder_claim_num $12.;
run;
	
	

* ************************************************************************* ;
* PART V:   Merges Part A- and Part B-based data and cleans up HCPCS codes. ; 
*			 a.	 Merge demographic and Part B-based data.					;
*			 b.  Merge demographic and Part A-based data.					;
*			 c.  Clean up HCPCS codes.										;
* ************************************************************************* ;


*			 a.	 Merge demographic and Part B-based data.					;
data PHYSclaims;
	merge commonarea (in=a)
		  physician  (in=b);
	by case_id;
	if a and b;
run;

proc sort data=PHYSclaims;
	by case_id from_dt thru_dt upin_taxnum_concat;
run;			

data prePHYSclaimsFINAL;
	array hcpcs_codes {*} $ hcpcs_01-hcpcs_11;
	retain hcpcs_01-hcpcs_11;
	set PHYSclaims;
	by case_id from_dt thru_dt upin_taxnum_concat;
	if first.upin_taxnum_concat then 
		do
			count = 0;
			sum_pay_amt = 0;
		end;
	count + 1;
	sum_pay_amt + pay_amt;

	countmin = min(count,11);
	if first.upin_taxnum_concat then
		do i = 1 to 11;
			hcpcs_codes{i} = '';
		end;
	hcpcs_codes(countmin) = hcpcs01;
	drop hcpcs02-hcpcs15;
	if last.upin_taxnum_concat then output prePHYSclaimsFINAL;
run;

data PHYSclaimsFINAL;
	set prePHYSclaimsFINAL;
	call sortc(of hcpcs_11-hcpcs_01);
	do i = 1 to 4;
		if hcpcs_02 = hcpcs_01 then hcpcs_02 = '';
		if hcpcs_04 = hcpcs_03 then hcpcs_04 = '';
		if hcpcs_06 = hcpcs_05 then hcpcs_04 = '';
		if hcpcs_08 = hcpcs_07 then hcpcs_04 = '';
		if hcpcs_10 = hcpcs_09 then hcpcs_04 = '';
		if hcpcs_12 = hcpcs_11 then hcpcs_04 = '';
		call sortc(of hcpcs_11-hcpcs_01);
	end;
	if prindiag = diag01 then diag01 = '';
	if prindiag = diag02 then diag02 = '';
	if prindiag = diag03 then diag03 = '';
	call sortc(of diag03-diag01);
run;


*			 b.  Merge demographic and Part A-based data.					;
data nonPHYSclaims;
	set inpatient outpatient hha snf hospice;
run;

proc sort data=commonarea; 			by case_id; run;
proc sort data=nonPHYSclaims nodup; by case_id; run;

data nonPHYSclaims2;
	merge commonarea 	(in=a)
		  nonPHYSclaims (in=b);
	by case_id;
	if a and b;
run;


*			 c.  Clean up HCPCS codes.										;
proc sort data=nonPHYSclaims2;
	by case_id from_dt thru_dt pay_amt descending hcpcs01;
run;

data nonPHYSclaims3;
	array hcpcs_codes {*} $ hcpcs_01-hcpcs_11;
	retain hcpcs_01-hcpcs_11;
	set nonPHYSclaims2;
	by case_id from_dt thru_dt pay_amt descending hcpcs01;
	if first.pay_amt then 
		do
			count = 0;
		end;
	count + 1;
	countmin = min(count,11);
	if first.pay_amt then
		do i = 1 to 11;
			hcpcs_codes{i} = '';
		end;
	hcpcs_codes(countmin) = hcpcs01;
	drop hcpcs02-hcpcs15;
run;

proc sort data=nonPHYSclaims3 out=nonPHYSclaims4;
	by case_id from_dt thru_dt pay_amt descending countmin;
run;

data nonPHYSclaims5;
	set nonPHYSclaims4;

*      smthg in 10	  and smthg in 11	 then replace 10 with special code.	;
	if hcpcs_10 ne '' and hcpcs_11 ne '' then hcpcs_10 = '00000';
run;

data nonPHYSclaimsFINAL;
	set nonPHYSclaims5;
	by case_id from_dt thru_dt pay_amt descending countmin;
	sum_pay_amt = pay_amt;

	if prindiag = diag01 then diag01 = '';
	call sortc(of diag09-diag01);

	if first.pay_amt then output nonPHYSclaimsFINAL;
	drop hcpcs_11 pay_amt;
	length upin_taxnum_concat $22.;
run;

data almost;
	set nonPHYSclaimsFINAL PHYSclaimsFINAL;
	format dod dob from_dt thru_dt ie_date yymmdd8.;
	call sortc(of diag09-diag01);
	call sortc(of hcpcs_10-hcpcs_01);
	call sortc(of proc06-proc01);
run;

proc sort data=almost;
	by case_id from_dt thru_dt clmtype;
run;



* ************************************************************************* ;
* PART VI:  Compiles summary statistics.  									;
* ************************************************************************* ;

data getdollars;
	set almost;
	by case_id;
	if first.case_id then
		do 
			total_dollars = 0;
		end;
	total_dollars + sum_pay_amt;
	if last.case_id then output getdollars;
run;

data getdollars2;
	set getdollars;
	keep case_id total_dollars;
run;

data thelastset;
	merge almost 	  (in=a)
		  getdollars2 (in=b);
	by case_id;
	if a;
	drop i hcpcs01 count countmin hcpcs_11 hcpcs_12;
run;

proc sort sortsize=6m  data=thelastset out=emrin.claimsin nodupkey;
	by case_id descending from_dt descending thru_dt clmtype sum_pay_amt;
run;

* END data set manipulation for printing patient histories.					;




* START print process for printing patient histories.						;

* ************************************************************************* ;
* PART VII: Print data and make patient histories.							;
* ************************************************************************* ;

* NOTE:  If the index event is not at the beginning or end of the 			;
* observation period, then some enddys and startdys may be negative and 	;
* others positive.  Negative values indicate the care took place before the ;
* index event while positive values indicate care took place after the 		;
* index event.  Be sure to change the ie_desc variable to reflect the		;
* appropriate definition for the index event, e.g., 'Death of Patient'.		;

data claimsin;
	set emrin.claimsin;
	format mosa 4.2
		   stab $stabbr. 
	       ie_date worddate18.
		   from_dt thru_dt yymmdd.
		   startdys enddys los mofromie 4.0 ;
	length startdys los enddys 4.0;
	startdys = (from_dt - ie_date);
	enddys = (thru_dt - ie_date);
	mosa = (startdys / 30);
	mosaint = int(mosa);
	mosarem = mod(startdys,30);
	if startdys =  0 then mofromie=1;
	if startdys ne 0 then do;
		mofromie = mosaint;
		if mosarem ne 0 then 
			mofromie = (mosaint + 1);
   	end;
	los = ((thru_dt - from_dt) + 1);
	ie_desc = "&ie_desc.";
run;

proc sort sortsize=6m  data=claimsin out=cohortin nodupkey;
	by case_id descending mofromie descending from_dt descending thru_dt clmtype sum_pay_amt;
run;

* The BY statement in this data step must match the BY statement in the 	;
* previous sort step or the program will not run.							;
title ' ';
data _null_;
	set cohortin;
	by case_id descending mofromie descending from_dt descending thru_dt clmtype sum_pay_amt;
	format sex $gend. 
		   RACE $rcwbo. 
		   place $plos. 
		   mofromie $4.
		   clmtype $ctype. 
		   physerv $stypeb. 
		   provspec $mdspec.
		   from_dt thru_dt yymmdd8. 
		   proc01-proc06 $icdsrg24.
		   hcpcs_01-hcpcs_09 $cptfmt24.
		   startdys enddys los enddys 4.0
		   prindiag diag01-diag05 $icdfmt24.
		   sum_pay_amt total_dollars dollar8.0;

	file emrprint print;

	* This part prints the case header portion of the record.				;
	if first.case_id then do;
		put  _page_;
		put @1   "&title"
			@75  "&datedesc";
		put @1   128*'=' ;
		if dod = '' then do;
			put @1    'CASE ID: '     case_id
			    @25   'AGE: '         age
			    @38   'SEX:    '      sex
			    @60   'RACE: '        race
				@78   'DEATH DT: n/a'
			    @108  'STATE: '       stab;
		end;
		if dod ne '' then do;
			put @1   'CASE ID: '      case_id
			    @25  'AGE: '          age
			    @38  'SEX:    '       sex
			    @60  'RACE: '         race
				@78  'DEATH DT: '     
			    @108 'STATE: '        stab;
		end;
		put @1   128*' ';
		put @1   'INDEX EVENT DATE: ' ie_date
		    @38  'INDEX EVENT: ' 	  ie_desc
			@108 'CARE COST: ' 		  total_dollars dollar10.;
		put @1   128*'=';
		put @1   'Service'
		    @16  'MD'
		    @24  'Days Fr Event'
		    @38  'Payment';
		put @1   'Type'
		    @9   'Place'
		    @16  'Spec.'
		    @24  'Start'
		    @31  'End'
		    @38  'Amount'
		    @47  'ICD9 Diagnoses '
		    @72  'HCPCS/CPT4 Procs & HIPPS'
		    @101 'ICD9 Procedures';
		put @1   '-------'
		    @9   '------'
		    @16  '-------'
		    @24  '------'
		    @31  '------'
		    @38  '--------'
		    @47  '------------------------'
		    @72  '----------------------------'
		    @101 '----------------------------';
	end;

	* This part prints the actual medical patient history for all 			;
	* Part A claims.														;
	if clmtype ne '3' then do;
		put @1   clmtype
		    @9   place
		    @16  provspec
		    @24  startdys
		    @31  enddys
		    @38  sum_pay_amt dollar8.
		    @47  prindiag    $icdfmt.
		    @72  hcpcs_01    $cptfmt.
		    @101 proc01      $icdsrg.;
		if diag01 ne '' or hcpcs_02 ne '' or proc02 ne '' then do;
			put @47  diag01   $icdfmt.
			    @72  hcpcs_02 $cptfmt.
			    @101 proc02   $icdsrg.;
		end;
		if diag02 ne '' or hcpcs_03 ne '' or proc03 ne '' then do;
			put @47  diag02   $icdfmt.
			    @72  hcpcs_03 $cptfmt.
			    @101 proc03   $icdsrg.;
		end;
		if diag03 ne '' or hcpcs_04 ne '' or proc04 ne '' then do;
			put @47  diag03   $icdfmt.
			    @72  hcpcs_04 $cptfmt.
			    @101 proc04   $icdsrg.;
		end;
		if diag04 ne '' or hcpcs_05 ne '' or proc05 ne '' then do;
			put @47  diag04   $icdfmt.
			    @72  hcpcs_05 $cptfmt.
			    @101 proc05   $icdsrg.;
		end;
		if diag05 ne '' or hcpcs_06 ne '' or proc06 ne '' then do;
			put  @47  diag05   $icdfmt.
				 @72  hcpcs_06 $cptfmt.
				 @101 proc06   $icdsrg.;
		end;
		if diag06 ne '' or hcpcs_07 ne '' then do;
			put  @47  diag06   $icdfmt.
				 @72  hcpcs_07 $cptfmt.;
		end;
		if diag07 ne '' or hcpcs_08 ne '' then do;
			put  @47  diag07   $icdfmt.
				 @72  hcpcs_08 $cptfmt.;
		end;
		if diag08 ne '' or hcpcs_09 ne '' then do;
			put  @47  diag08   $icdfmt.
				 @72  hcpcs_09 $cptfmt.;
		end;
		if diag09 ne '' or hcpcs_10 ne '' then do;
			put  @47  diag09   $icdfmt.
				 @72  hcpcs_10 $cptfmt.;
		end;
	end;

	* This part prints the actual medical patient history for all 			;
	* Part B claims.														;
	if clmtype = '3' then do;
		put @1   physerv  $stypeb.
		    @9   place
		    @16  provspec
		    @24  startdys
		    @31  enddys
		    @38  sum_pay_amt  dollar8.
		    @47  prindiag     $icdfmt.
		    @72  hcpcs_01     $cptfmt.
		    @101 27*' ';
		if diag01 ne '' or hcpcs_02 ne '' then do;
			put @47  diag01   $icdfmt.
				@72  hcpcs_02 $cptfmt.;
		end;
		if diag02 ne '' or hcpcs_03 ne '' then do;
			put @47  diag02   $icdfmt.
			    @72  hcpcs_03 $cptfmt.;
		end;
		if diag03 ne '' or hcpcs_04 ne '' then do;
			put @47  diag03   $icdfmt.
			    @72  hcpcs_04 $cptfmt.;
		end;
		if diag04 ne '' or hcpcs_05 ne '' then do;
			put @47  diag04   $icdfmt.
			    @72  hcpcs_05 $cptfmt.;
		end;
		if diag05 ne '' or hcpcs_06 ne '' then do;
			put @47  diag05   $icdfmt.
			    @72  hcpcs_06 $cptfmt.;
		end;
		if diag06 ne '' or hcpcs_07 ne '' then do;
			put @47  diag06   $icdfmt.
			    @72  hcpcs_07 $cptfmt.;
		end;
		if diag07 ne '' or hcpcs_08 ne '' then do;
			put @47  diag07   $icdfmt.
			    @72  hcpcs_08 $cptfmt.;
		end;
		if diag08 ne '' or hcpcs_09 ne '' then do;
			put @47  diag08   $icdfmt.
			    @72  hcpcs_09 $cptfmt.;
		end;
		if diag09 ne '' or hcpcs_10 ne '' then do;
			put @47  diag09   $icdfmt.
			    @72  hcpcs_10 $cptfmt.;
		end;
	end;

	* This prints a dotted line across the page.  It marks every 30 days	;
	* of history.  															;
	if last.mofromie then put @1 128*'.';
run;
