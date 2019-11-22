
/* these options statements set up the page size and limits */
/* if you want to avoid page breaks between cases set pagsize very high */
/* e.g. pagesize=2000 otherwise set at 62 to get a new page at every case */
options nocenter linesize=133 pagesize=2000 nodate orientation=landscape;

/* this is the library (path name or folder) where the input data resides */
libname  emrin      "c:\cfmc\emr\input data";

/* this is the path or folder name and file name for the EMR Printout */
/* if you do not change the filename (EMR for test cases) */
/* that filename will be overwritten the next time you run the program */
filename emrprint   "c:\cfmc\emr\printouts\EMR for test cases";

/* the following statements include sas formats for use by the programs */
/* the format files must have the same path and name as in the include statements */
/* or the programs will not run */
/* be sure your format files are the most current and include any local codes, if appropriate */
/* this is particularly importatant for the icd9, cpt4 and hcpcs codes */
%include            "c:\cfmc\emr\formats\cfmcfmts.txt";
%include            "c:\cfmc\emr\formats\icd9dxfmt.txt";
%include            "c:\cfmc\emr\formats\icd9sxfmt.txt";
%include            "c:\cfmc\emr\formats\hcpcsfmt.txt";

/* The following data step */
/* uses the common claim input format created by the project team */
/* to calculate length of stay (los) */
/* days between index event and claim start date (startdys) */
/* days between index event and claim thru date (enddys) */
/* months between index event and claim thru date (enddys/30) rounded to nearest month */
/* NOTE: if the index event is not at the beginning or end of the observation period */
/* some enddys and startdys may be negative and others positive */
/* negative values indicate the care took place before the index event */
/* positive values indicate the care took place after the index event */
/* Each time you run the program be sure the set statement */
/* has the correct name for the EMR input file you intend to use */
/* and change the ie-desc to reflect the appropriate definition for the index event' */
/* for example in ie_desc='Death of Patient' or ie_desc='End of program intervention' */

Data claimsin;
set  emrin.dcinputfile1d2;
format startdys enddys los mofromie 4.0 mosa 4.2
       ie_date from_dt thru_dt yymmdd. stab $stabbr. ;
length startdys los enddys 4.0;
startdys=(from_dt - ie_date);
enddys=(thru_dt - ie_date);
mosa=(startdys/30);
mosaint=int(mosa);
mosarem=mod(startdys,30);
if 
startdys =  0
then mofromie=1;
if   startdys ne 0
then do;
     mofromie = mosaint;
     if mosarem ne 0
     then mofromie = (mosaint + 1);
     end;
los=((thru_dt-from_dt)+1);
/* Be sure to change the following to match your current EMR project */
ie_desc='First Hospital Admission for Heart Condition';
run;

/* The following sort step arranges the input data  */
/* to insure all claims for a given case are together */
/* and in order from most recent care to least recent */
/* and in order by type of claim that seemed most sensible */
/* to clinician reviewers using EMR printouts in prior research */

proc sort  sortsize=6m  data=claimsin out=cohortin nodupkey  ;
BY case_id descending mofromie descending from_dt descending thru_dt clmtype pay_amt;
run;

/* This data step creates the EMR print record from the sort step output */
/* the BY statement in this data step must match */
/* the BY statement in the previous sort step */
/* or the program will not run */
Title ' ';

DATA _NULL_;
SET  cohortin;
BY case_id descending mofromie descending from_dt descending thru_dt clmtype pay_amt;
FORMAT SEX $gend. RACE $rcwbo. age agefmng. pay_amt dollar8.0
       place $plos. clmtype $ctype.
       prindiag diag01-diag05 $icdfmt24. hcpcs01-hcpcs10 $cptfmt24. proc01-proc06 $icdsrg24.
       startdys enddys los enddys 4.0 mofromie $4.
       from_dt thru_dt yymmdd8. physerv $stypeb. provspec $mdspec.;
FILE emrprint PRINT;

/* print the Case Header portion of the EMR */
IF   FIRST.CASE_ID
THEN DO;
PUT _PAGE_;
put    @1   'CFMC Claims-based Electronic Medical Record Project: Test Case Printouts';
PUT    @1   133*'=' ;
PUT    @1   'CASE ID: '        CASE_ID
       @25  'AGE: '            AGE
       @40  'SEX:    '         SEX
       @60  'RACE:  '          RACE
       @74  'MEDICAID: '   MCAID_SW
       @88  'STATE: '      stab;
Put    @1   133*' ';
PUT    @1   'INDEX EVENT DATE: ' IE_DATE
       @40  'INDEX EVENT DESCRIPTION :  ' IE_DESC;
PUT    @1   133*'=';
PUT    @1   'Service'
       @17  'MD'
       @25  'Days Fr Event'
       @39  'Payment';
PUT    @1   'Type'
       @10  'Place'
       @17  'Spec.'
       @25  'Start'
       @32  'End'
       @39  'Amount'
       @48  'Diagnoses '
       @74  'HCPCS/CPT4 Procedures'
       @103 'ICD9 Procedures';
PUT    @1   '-----'
       @10  '-----'
       @17  '-------'
       @25  '-----'
       @32  '-----'
       @39  '--------'
       @48  '------------------------'
       @74  '------------------------'
       @103 '------------------------';
END;

/* Print EMR lines for UB format claims e.g. Inp,Otp,SNF,HHA,Hospice */
IF  (CLMTYPE NE '3')
THEN DO;
PUT  @1   CLMTYPE
     @10  place
     @17  provspec
     @25  startdys
     @32  enddys
     @39  PAY_AMT  DOLLAR8.
     @48  PRINDIAG $ICDFMT.
     @74  hcpcs01  $cptfmt.
     @103 proc01   $icdsrg.;
PUT  @48  diag01   $ICDFMT.
     @74  hcpcs02  $cptfmt.
     @103 proc02   $icdsrg.;
PUT  @48  diag02   $ICDFMT.
     @74  hcpcs03  $cptfmt.
     @103 proc03   $icdsrg.;
PUT  @48  diag03   $ICDFMT.
     @74  hcpcs04  $cptfmt.
     @103 proc04   $icdsrg.;
PUT  @48  diag04   $ICDFMT.
     @74  hcpcs05  $cptfmt.
     @103 proc05   $icdsrg.;
END;

/* print EMR lines for HCFA 1500 format claims e.g. Physician/supplier */;
IF ((clmtype = '3'))
THEN DO;
PUT  @1   physerv  $stypeb.
     @10  place
     @17  provspec
     @25  startdys
     @32  enddys
     @39  PAY_AMT  DOLLAR8.
     @48  Diag01   $ICDFMT.
     @74  hcpcs01  $cptfmt.
     @103 25*' ';
END;

/* print a dotted line to mark boundaries between */
/* 30 periods of care from the index date */
/* Remember the month field is rounded to the nearest 30 days */
if   last.mofromie
then put @1 133*'.';
run;

RUN;

/* these options statements set up the page size and limits */
/* if you want to avoid page breaks between cases set pagsize very high */
/* e.g. pagesize=2000 otherwise set at 62 to get a new page at every case */
options nocenter linesize=133 pagesize=2000 nodate orientation=landscape;
	
/* this is the library (path name or folder) where the input data resides */
libname  emrin      "c:\cfmc\emr\input data";

/* this is the path or folder name and file name for the EMR Printout */
/* if you do not change the filename (EMR for test cases) */
/* that filename will be overwritten the next time you run the program */
filename emrprint   "c:\cfmc\emr\printouts\EMR for test cases";

/* the following statements include sas formats for use by the programs */
/* the format files must have the same path and name as in the include statements */
/* or the programs will not run */
/* be sure your format files are the most current and include any local codes, if appropriate */
/* this is particularly importatant for the icd9, cpt4 and hcpcs codes */
%include            "c:\cfmc\emr\formats\cfmcfmts.txt";
%include            "c:\cfmc\emr\formats\icd9dxfmt.txt";
%include            "c:\cfmc\emr\formats\icd9sxfmt.txt";
%include            "c:\cfmc\emr\formats\hcpcsfmt.txt";

/* The following data step */
/* uses the common claim input format created by the project team */
/* to calculate length of stay (los) */ 
/* days between index event and claim start date (startdys) */
/* days between index event and claim thru date (enddys) */ 
/* months between index event and claim from date (startdys/30) */
/* NOTE: if the index event is not at the beginning or end of the observation period */
/* some enddys and startdys may be negative and others positive */
/* negative values indicate the care took place before the index event */
/* positive values indicate the care took place after the index event */
/* Each time you run the program be sure the set statement */
/* has the correct name for the EMR input file you intend to use */
/* and change the ie_desc to reflect the appropriate definition for the index event' */
/* for example in ie_desc='Death of Patient' or ie_desc='End of program intervention' */

Data claimsin;
set  emrin.dcinputfile1d2;
format startdys enddys los mofromie 4.0 mosa 4.2
       ie_date from_dt thru_dt yymmdd. stab $stabbr. ;
length startdys los enddys 4.0;
startdys=(from_dt - ie_date);
enddys=(thru_dt - ie_date);
mosa=(startdys/30);
mosaint=int(mosa);
mosarem=mod(startdys,30);
if   startdys =  0
then mofromie=1;
if   startdys ne 0
then do;
     mofromie = mosaint;
	 if mosarem ne 0
	 then mofromie = (mosaint + 1);
	 end;
los=((thru_dt-from_dt)+1);
ie_desc='First Hospital Admission for Heart Condition';
run;

/* The following sort step arranges the input data  */
/* to insure all claims for a given case are together */
/* and in order from most recent care to least recent */
/* and in order by type of claim that seemed most sensible */ 
/* to clinician reviewers using EMR printouts in prior research */

proc sort  sortsize=6m  data=claimsin out=cohortin nodupkey  ;
BY case_id descending mofromie descending from_dt descending thru_dt clmtype pay_amt;
run;

/* make sure default Title is blank */
Title ' '; 

/* This data step creates the EMR print record from the sort step output */
/* the BY statement in this data step must match */
/* the BY statement in the previous sort step */
/* or the program will not run */

DATA _NULL_;
SET  cohortin;
BY case_id descending mofromie descending from_dt descending thru_dt clmtype pay_amt;
FORMAT SEX $gend. RACE $rcwbo. age agefmng. pay_amt dollar8.0
       place $plos. clmtype $ctype. 
       prindiag diag01-diag05 $icdfmt24. hcpcs01-hcpcs10 $cptfmt24. proc01-proc06 $icdsrg24.
       startdys enddys los enddys 4.0 
       from_dt thru_dt yymmdd8. physerv $stypeb. provspec $mdspec.;
FILE emrprint PRINT;

/* print the Case Header portion of the EMR */
IF   FIRST.CASE_ID
THEN DO;
PUT _PAGE_;
put    @1   'CFMC Claims-based Electronic Medical Record Project: Test Case Printouts';
PUT    @1   133*'=' ;
PUT    @1   'CASE ID: '        CASE_ID
       @25  'AGE: '            AGE
       @40  'SEX:    '         SEX
       @60  'RACE:  '          RACE
       @74  'MEDICAID: '   MCAID_SW
       @88  'STATE: '      stab;
Put    @1   133*' ';
PUT    @1   'INDEX EVENT DATE: ' IE_DATE
       @40  'INDEX EVENT DESCRIPTION :  ' IE_DESC;
PUT    @1   133*'=';
PUT    @1   'Service'
       @17  'MD'
       @25  'Days Fr Event'
       @39  'Payment';
PUT    @1   'Type'
       @10  'Place'
       @17  'Spec.'
       @25  'Start'
       @32  'End'
       @39  'Amount'
       @48  'Diagnoses '
       @74  'HCPCS/CPT4 Procedures'
       @103 'ICD9 Procedures';
PUT    @1   '-----'
       @10  '-----'
       @17  '-------'
       @25  '-----'
       @32  '-----'
       @39  '--------'
       @48  '------------------------'
       @74  '------------------------'
       @103 '------------------------';
END;

/* Print EMR lines for UB format claims e.g. Inp,Otp,SNF,HHA,Hospice */
IF  (CLMTYPE NE '3')
THEN DO;
PUT  @1   CLMTYPE
     @10  place
     @17  provspec
     @25  startdys
     @32  enddys
     @39  PAY_AMT  DOLLAR8.
     @48  PRINDIAG $ICDFMT.
     @74  hcpcs01  $cptfmt.
     @103 proc01   $icdsrg.;
PUT  @48  diag01   $ICDFMT.
     @74  hcpcs02  $cptfmt.
     @103 proc02   $icdsrg.;
PUT  @48  diag02   $ICDFMT.
     @74  hcpcs03  $cptfmt.
     @103 proc03   $icdsrg.;
PUT  @48  diag03   $ICDFMT.
     @74  hcpcs04  $cptfmt.
     @103 proc04   $icdsrg.;
PUT  @48  diag04   $ICDFMT.
     @74  hcpcs05  $cptfmt.
     @103 proc05   $icdsrg.;
END;

/* print EMR lines for HCFA 1500 format claims e.g. Physician/supplier */;
IF ((clmtype = '3'))
THEN DO;
PUT  @1   physerv  $stypeb.
     @10  place
     @17  provspec
     @25  startdys
     @32  enddys
     @39  PAY_AMT  DOLLAR8.
     @48  Diag01   $ICDFMT.
     @74  hcpcs01  $cptfmt.
     @103 25*' ';
END;

/* print a dotted line to mark boundaries between */
/* 30 periods of care from the index date */
if   last.mofromie 
then put @1 133*'.';
run;

RUN;
