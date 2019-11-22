/***************************************************************************************/
/***************************************************************************************/
/**                                                                                   **/
/**  program name:   HRS_HOI_Measures_From_CMS.sas                                    **/
/**                                                                                   **/
/**  description:    extract health outcomes of interest from HRS CMS claims          **/
/**                  data.  The measures are defined in                               **/
/**                  EOL_HOI_MEASURES_DB 5-30-12.xslx, received in an e-mail from     **/
/**                  Daniella Meeker in an e-mail dated 11JUN2012.                    **/
/**                                                                                   **/
/**  notes:          if you need to run this program outside of my ISI home           **/
/**                  directory, you would need either to comment out the references   **/
/**                  to my utility macros in Sections 2 and Last, or copy those and   **/
/**                  change the %let MacrosLocation statement in Section 2.           **/
/**                                                                                   **/
/**                  the ISI server doesn't license SAS/Access to PC File formats,    **/
/**                  which I use to read data from Excel.  therefore, I created       **/
/**                  utility data sets on my computer and uploaded them to the ISI    **/
/**                  server (see PROC IMPORT statements in Section 2).                **/
/**                                                                                   **/
/**                  final output is an analysis data set names HOIs.sas7bdat.        **/
/**                  approximate running time:  20 minutes.                           **/
/**                                                                                   **/
/***************************************************************************************/
/***************************************************************************************/
/**                                                                                   **/
/**  history:  |  description of change                                         |     **/
/**  __________|________________________________________________________________|____ **/
/**  23JUL2012 |  initial creation.                                             | dat **/
/**  __________|________________________________________________________________|____ **/
/**                                                                                   **/
/***************************************************************************************/
/***************************************************************************************/
/**                                                                                   **/
/**  written for RAND Corporation.                                                    **/
/**                                                                                   **/
/***************************************************************************************/
/***************************************************************************************/
/**                                                                                   **/
/**  program structure:                                                               **/
/**                                                                                   **/
/**  Section 1:         establish the environment. import code sets from Excel.       **/
/**                                                                                   **/
/**  Section 2:         extract HOI measures from the HRS CMS MedPar data sets        **/
/**                     (HOSPITAL ADMISSION DATE, HOSPITAL DISCHARGE DATE, ICU DAYS,  **/
/**                     ICU ADMISSION).                                               **/
/**                                                                                   **/
/**  Section 3:         exract HOSPICE ADMISSION DATE from hospice data sets.         **/
/**                                                                                   **/
/**  Section 4:         extract SKILLED NURSING FACILITY from snf data sets.          **/
/**                                                                                   **/
/**  Section 5:         extract ER VISITS from professional claims.                   **/
/**                                                                                   **/
/**  Section 6:         extract ICU ADMISSION, ICU DAYS, ACUTE CARE DEATH and         **/
/**                     ER VISITS from MedPar data sets.                              **/ 
/**                                                                                   **/
/**  Section 7:         extract CHEMOTHERAPY from dm, hh, hs, ip, mp, op, bd and sn   **/
/**                     data sets.                                                    **/
/**                                                                                   **/
/**  Section 8:         extract ACUTE RENAL FAILURE from dm, hh, hs, ip, mp, op, pb   **/
/**                     and sn data sets.                                             **/
/**                                                                                   **/
/**  Section 9:         extract RENAL DIALYSIS from dm, hh, hs, ip, mp, op, pb and    **/
/**                     sn data sets.                                                 **/
/**                                                                                   **/
/**  Section 10:        extract ACUTE ORGAN FAILURE from dm, hh, hs, ip, mp, op, pb   **/
/**                     and sn data sets.                                             **/
/**                                                                                   **/
/**  Section 11:        extract SEPSIS from dm, hh, hs, ip, mp, op, pb and sn         **/
/**                     data sets.                                                    **/
/**                                                                                   **/
/**  Section 12:        extract TRACHEOSTOMY from dm, hh, hs, ip, mp, op, pb          **/
/**                     and sn data sets.                                             **/   
/**                                                                                   **/
/**  Section 13:        extract MECHANICAL VENTILATION from dm, hh, hs, ip, mp, op,   **/
/**                     pb and sn data sets.                                          **/
/**                                                                                   **/
/**  Section 14:        extract MEDICARE ENTITLEMENT/BUY-IN INDICATOR and             **/
/**                     TOTAL NUMBER OF MONTHS OF STATE BUY-IN from denominator       **/
/**                     data sets.                                                    **/
/**                                                                                   **/
/**  Section 15:        append all of the data extracted in Sections 2-14 into a      **/
/**                     single analysis data set.                                     **/
/**                                                                                   **/
/**  Section 16:        add classification and id variables from a crosswalk file.    **/
/**                                                                                   **/ 
/**  Section Last:      clean-up.                                                     **/
/**                                                                                   **/
/***************************************************************************************/
/***************************************************************************************/

    /**
        Health Outcomes of Interest Extracted From HRS CMS Claims

1.	Hospital Admission Date:  DATE=ADMSNDT from MedPar data sets (mp*), where SSLSSNF in (‘S’,’L’).  The where filter has the effect of excluding SNF stays, which are captured in #4 below.  Section 2 of SAS program.

2.	Hospital Discharge Date:  DATE=DSCHRGDT from MedPar data sets (mp*), where SSLSSNF in (‘S’,’L’).  Section 2 of SAS program.

3.	MEDICARE ENTITLEMENT/BUY-IN INDICATOR:  BUYIN12 from denominator files (dn*).  Section 14 of SAS program.

4.	TOTAL NUMBER OF MONTHS OF STATE BUY-IN:  BUYIN_MO from denominator files (dn*).  Section 14 of SAS program.

5.	Hospice Admission Date:  DATE=HSPCSTRT from Hospice data sets (hp*).  Section 3 of SAS program.

6.	Skilled Nursing Facility:  DATE=ADMSNDT from MedPar data sets (mp*), where SSLSSNF=’N’.  The where filter separates SNF stays from hospital stays.  Section 4 of SAS program.

7.	ICU Admission:  DATE=ADMSNDT from MedPar data sets (mp*) where SSLSSNF in (‘S’,’L’) and where ICUINDCD is not missing.  Do you want these excluded from #1 and 2 above?  Right now, #3 is a subset of #1.  VARIABLE_VALUE=ICUINDCD.  Section 2 of SAS program.

8.	ICU Days:  DATE=ADMSNDT from MedPar data sets (mp*) where SSLSSNF in (‘S’,’L’) and where ICUINDCD is not missing.  VARIABLE_VALUE=ICARECNT.  Section 2 of SAS program.

9.	ER Visits:  from carrier (based on HCPCS and BETOS codes) and MedPar (SRC_ADMS=’7’ or TYPE_ADM=’1’) data sets.

10.	Acute Care Death:  from MedPar data sets using specified discharge and destination codes.  Section 6 of SAS program.

11.	Chemotherapy:  from any data set where the specified code types occur.  Section 7 of the SAS program.

12.	Acute renal failure:  from any data set having dx codes.  Section 8 of the SAS program.

13.	Renal dialysis:  from any data set having either dx or revenue center codes.  Section 9 of the SAS program.

14.	Acute organ dysfunction.  From any data set having dx codes.  Section 10 of the SAS program.

15.	Sepsis:  from any data set having dx codes.  Section 11 of the SAS program.

16.	Tracheostomy:  from any data set having dx or DRG codes.  Section 12 of the SAS program.

17.	Mechanical ventilation:  from any data set having procedure or DRG codes.  Section 13 of the SAS program.


*/
    
/*******************************/
/*******************************/
/**                           **/
/**  Section  1.              **/
/**                           **/
/*******************************/
/*******************************/

options mprint mlogic symbolgen source source2;
ods escapechar = '^';

%put &sysscp;
%global ListOfYears ListOfMonths NumberOfYears SASProgramsLocation DataLocation MacrosLocation DenomLocation;

%let ClientTitle=             RAND Corporation;
%let ClientName=              RAND;
%let SASProgramName=          HRS_HOI_Measures_From_CMS.sas;
%let Project=                 Extract Dates of HOI Measures from HRS CMS Claims;

%macro Locations();

  %if &sysscp=WIN %then
    %do;
      %include "E:\ClientData\Schaeffer\RANDHRS\SASPrograms\Locations.sas";
    %end;
  %else
    %do;
      options FILELOCKS=NONE;
      %let SASProgramsLocation=     ./;
      %let MacrosLocation=          ./Macros/;
      libname CMSClms               '/sch-stor1-a/data-library/dua-data/HRS/Restricted/Claims/Sas/';
      libname put                   './RANDCMSData';
      libname XWalk                 '/sch-stor1-a/data-library/dua-data/HRS/Restricted/Claims/Sas/';
    %end;

%mend;
%Locations()

%put &SASProgramsLocation;
%put &MacrosLocation;
%include "&MacrosLocation.words.sas";
%include "&MacrosLocation.Timer.sas";
%timer(start,GlobVarName=&ClientName.Time,banner=Starting &SASProgramName);

data _null_;
  call symput('date',trim(left(put(today(),date9.))));
  call symput('time',trim(left(put(time(),timeampm9.))));
  run;

title1 "&ClientTitle";
title2 "&Project";
footnote1 j=r "Generated on &date at &time.."; 
footnote2 j=r "Generated by &SASProgramName.."; 

/**  server doesn't license SAS/Access to PC File Formats.  **/
/**  make these data sets on Windows and then copy to the   **/
/**  server.                                                **/

%macro CodeFmts();

  %if &sysscp=WIN %then
    %do;
      PROC IMPORT OUT=Chemo 
        DATAFILE= "E:\ClientData\Schaeffer\RANDHRS\Data\ChemoCodes.xlsx" 
        DBMS=EXCEL REPLACE;
        RANGE="Chemo$"; 
        GETNAMES=YES;
        MIXED=YES;
        SCANTEXT=YES;
        USEDATE=YES;
        SCANTIME=YES;
        RUN;
      data put.Chemo(drop=Type);
        format Code $10.;
        set Chemo(rename=(Code=OldCode) where=(substr(Type,1,1) ne 'x'));
        code=compress(translate(OldCode,' ','.'));
        run;
      PROC IMPORT OUT=ARF 
        DATAFILE= "E:\ClientData\Schaeffer\RANDHRS\Data\ChemoCodes.xlsx" 
        DBMS=EXCEL REPLACE;
        RANGE="ARF$"; 
        GETNAMES=YES;
        MIXED=YES;
        SCANTEXT=YES;
        USEDATE=YES;
        SCANTIME=YES;
        RUN;
      data put.ARF(drop=Type);
        format Code $10.;
        set ARF(rename=(Code=OldCode) where=(substr(Type,1,1) ne 'x'));
        code=compress(translate(OldCode,' ','.'));
        run;
      PROC IMPORT OUT=RD 
        DATAFILE= "E:\ClientData\Schaeffer\RANDHRS\Data\ChemoCodes.xlsx" 
        DBMS=EXCEL REPLACE;
        RANGE="RD$"; 
        GETNAMES=YES;
        MIXED=YES;
        SCANTEXT=YES;
        USEDATE=YES;
        SCANTIME=YES;
        RUN;
      data put.RD(drop=Type);
        format Code $10.;
        set RD(rename=(Code=OldCode) where=(substr(Type,1,1) ne 'x'));
        code=compress(translate(OldCode,' ','.'));
        run;
      PROC IMPORT OUT=AOD 
        DATAFILE= "E:\ClientData\Schaeffer\RANDHRS\Data\ChemoCodes.xlsx" 
        DBMS=EXCEL REPLACE;
        RANGE="AOD$"; 
        GETNAMES=YES;
        MIXED=YES;
        SCANTEXT=YES;
        USEDATE=YES;
        SCANTIME=YES;
        RUN;
      data put.AOD(drop=Type);
        format Code $10.;
        set AOD(rename=(Code=OldCode) where=(substr(Type,1,1) ne 'x'));
        code=compress(translate(OldCode,' ','.'));
        run;
      PROC IMPORT OUT=SEPSIS 
        DATAFILE= "E:\ClientData\Schaeffer\RANDHRS\Data\ChemoCodes.xlsx" 
        DBMS=EXCEL REPLACE;
        RANGE="SEPSIS$"; 
        GETNAMES=YES;
        MIXED=YES;
        SCANTEXT=YES;
        USEDATE=YES;
        SCANTIME=YES;
        RUN;
      data put.SEPSIS(drop=Type);
        format Code $10.;
        set SEPSIS(rename=(Code=OldCode) where=(substr(Type,1,1) ne 'x'));
        code=compress(translate(OldCode,' ','.'));
        run;
    %end;

%mend CodeFmts;
%CodeFmts()

data ChemoFormat;
  format label $10. start $10. fmtname $8. type $1. ;
  set put.Chemo;
  label = 'CHEMO' ;
  start = Code;
  type = 'C';
  fmtname = 'Chemo';
  run;

proc format cntlin=ChemoFormat library=work;
run;

data ARFFormat;
  format label $10. start $10. fmtname $8. type $1. ;
  set put.ARF;
  label = 'ARF' ;
  start = Code;
  type = 'C';
  fmtname = 'ARF';
  run;

proc format cntlin=ARFFormat library=work;
run;

data RDFormat;
  format label $10. start $10. fmtname $8. type $1. ;
  set put.RD;
  label = 'RD' ;
  start = Code;
  type = 'C';
  fmtname = 'RD';
  run;

proc format cntlin=RDFormat library=work;
run;

data AODFormat;
  format label $10. start $10. fmtname $8. type $1. ;
  set put.AOD;
  label = 'AOD' ;
  start = Code;
  type = 'C';
  fmtname = 'AOD';
  run;

proc format cntlin=AODFormat library=work;
run;

data SEPSISFormat;
  format label $10. start $10. fmtname $8. type $1. ;
  set put.AOD;
  label = 'SEPSIS' ;
  start = Code;
  type = 'C';
  fmtname = 'SEPSIS';
  run;

proc format cntlin=SEPSISFormat library=work;
run;

/*******************************/
/*******************************/
/**                           **/
/**  Section  2.              **/
/**                           **/
/*******************************/
/*******************************/
  
%macro GetMedPar();

  data MedPar(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);
    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.mp_1991(keep=BID_HRS ADMSNDT DSCHRGDT ICUINDCD ICARECNT SSLSSNF where=(SSLSSNF in ('S','L')))
        CMSClms.mp_1992(keep=BID_HRS ADMSNDT DSCHRGDT ICUINDCD ICARECNT SSLSSNF where=(SSLSSNF in ('S','L')))
        %if &sysscp ne WIN %then
          %do x=1993 %to 2008 %by 1;
            CMSClms.mp_&x(keep=BID_HRS ADMSNDT DSCHRGDT ICUINDCD ICARECNT SSLSSNF where=(SSLSSNF in ('S','L')))
          %end;
          ;
      DATE=input(ADMSNDT,julian7.);
      VARIABLE_NAME='HOSPITAL ADMISSION DATE';
      VARIABLE_VALUE='';
      output;
      DATE=input(DSCHRGDT,julian7.);
      VARIABLE_NAME='HOSPITAL DISCHARGE DATE';
      VARIABLE_VALUE='';
      output;
      if ICUINDCD ne ' ' then
        do;
          DATE=input(ADMSNDT,julian7.);
          VARIABLE_NAME='ICU DAYS';
          VARIABLE_VALUE=left(put(ICARECNT,best12.));
          output;
          DATE=input(ADMSNDT,julian7.);
          VARIABLE_NAME='ICU ADMISSION';
          VARIABLE_VALUE=ICUINDCD;
          output;
        end;
    run;
%mend GetMedPar;

%GetMedPar()

/*******************************/
/*******************************/
/**                           **/
/**  Section  3.              **/
/**                           **/
/*******************************/
/*******************************/
  
%macro GetHospice();

  data Hospice(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);
    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.hs_1991(keep=BID_HRS HSPCSTRT)
        CMSClms.hs_1992(keep=BID_HRS HSPCSTRT)
        %if &sysscp ne WIN %then
          %do x=1993 %to 2008 %by 1;
            CMSClms.hs_&x(keep=BID_HRS HSPCSTRT)
          %end;
          ;
      DATE=input(HSPCSTRT,julian7.);
      VARIABLE_NAME='HOSPICE ADMISSION DATE';
      VARIABLE_VALUE='';
    run;

%mend GetHospice;

%GetHospice()

/*******************************/
/*******************************/
/**                           **/
/**  Section  4.              **/
/**                           **/
/*******************************/
/*******************************/

proc freq data=CMSClms.mp_1991;
  tables SSLSSNF;
  run;
  
%macro GetSNF();

  data SNF(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);
    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.mp_1991(keep=BID_HRS ADMSNDT SSLSSNF where=(SSLSSNF='N'))
        CMSClms.mp_1992(keep=BID_HRS ADMSNDT DSCHRGDT SSLSSNF where=(SSLSSNF='N'))
        %if &sysscp ne WIN %then
          %do x=1993 %to 2008 %by 1;
            CMSClms.mp_&x(keep=BID_HRS ADMSNDT SSLSSNF where=(SSLSSNF='N'))
          %end;
          ;
      DATE=input(ADMSNDT,julian7.);
      VARIABLE_NAME='SKILLED NURSING FACILITY';
      VARIABLE_VALUE='';
    run;
%mend GetSNF;

%GetSNF()

/*******************************/
/*******************************/
/**                           **/
/**  Section  5.              **/
/**                           **/
/*******************************/
/*******************************/
  
%macro GetProf();

  data Prof(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);
    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.pb_1991(keep=BID_HRS HCPSCD01-HCPSCD13 EXPDT101-EXPDT113 BETOS:)
        CMSClms.pb_1992(keep=BID_HRS HCPSCD01-HCPSCD13 EXPDT101-EXPDT113 BETOS:)
        %if &sysscp ne WIN %then
          %do x=1993 %to 2008 %by 1;
            CMSClms.pb_&x(keep=BID_HRS HCPSCD01-HCPSCD13 EXPDT101-EXPDT113 BETOS:)
          %end;
          ;
      array Codes{*}  HCPSCD01 HCPSCD02 HCPSCD03 HCPSCD04 HCPSCD05 HCPSCD06 HCPSCD07
                      HCPSCD05 HCPSCD09 HCPSCD10 HCPSCD11 HCPSCD12 HCPSCD13
                      ;
      array Dates{*}  EXPDT101 EXPDT102 EXPDT103 EXPDT104 EXPDT105 EXPDT106 EXPDT107
                      EXPDT108 EXPDT109 EXPDT110 EXPDT111 EXPDT112 EXPDT113
                      ;
      array BCodes{*} BETOS01 BETOS02 BETOS03 BETOS04 BETOS05 BETOS06 BETOS07 BETOS08
                      BETOS09 BETOS10 BETOS11 BETOS12 BETOS13
                      ;
      do i=1 to dim(Codes);
        if  (Codes{i} in ('99281','99282','99283','99284','99285')) or 
            (BCodes{i} in ('99281','99282','99283','99284','99285'))
          then
          do;
            DATE=input(Dates{i},julian7.);
            VARIABLE_NAME='ER VISITS';
            if Codes{i} in ('99281','99282','99283','99284','99285') then VARIABLE_VALUE=Codes{i};
            else if BCodes{i} in ('99281','99282','99283','99284','99285') then VARIABLE_VALUE=BCodes{i};
            output;
          end;
      end;
    run;
%mend GetProf;

%GetProf()

/*******************************/
/*******************************/
/**                           **/
/**  Section  6.              **/
/**                           **/
/*******************************/
/*******************************/
  
%macro GetMoreMedPar();

  data MoreMedPar(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);
    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.mp_1991(keep=BID_HRS ADMSNDT DSCHRGDT DSCHRGCD DSTNTNCD ICUINDCD ICARECNT SSLSSNF SRC_ADMS TYPE_ADM)
        CMSClms.mp_1992(keep=BID_HRS ADMSNDT DSCHRGDT DSCHRGCD DSTNTNCD ICUINDCD ICARECNT SSLSSNF SRC_ADMS TYPE_ADM)
        %if &sysscp ne WIN %then
          %do x=1993 %to 2008 %by 1;
            CMSClms.mp_&x(keep=BID_HRS ADMSNDT DSCHRGDT DSCHRGCD DSTNTNCD SRC_ADMS TYPE_ADM)
          %end;
          ;
      if ICUINDCD ne ' ' then
        do;
          DATE=input(ADMSNDT,julian7.);
          VARIABLE_NAME='ICU DAYS';
          VARIABLE_VALUE=left(put(ICARECNT,best12.));
          output;
          DATE=input(ADMSNDT,julian7.);
          VARIABLE_NAME='ICU ADMISSION';
          VARIABLE_VALUE=ICUINDCD;
          output;
        end;
      if SRC_ADMS='7' or TYPE_ADM='1' then
        do;
          DATE=input(ADMSNDT,julian7.);
          VARIABLE_NAME='ER VISITS';
          if SRC_ADMS='7' then VARIABLE_VALUE=SRC_ADMS;
          else if TYPE_ADM='1' then VARIABLE_VALUE=TYPE_ADM;
          output;
        end;
      if DSCHRGCD='B' then
        do;
          DATE=input(DSCHRGDT,julian7.);
          VARIABLE_NAME='ACUTE CARE DEATH';
          VARIABLE_VALUE=DSCHRGCD;
          output;
        end;
      if DSTNTNCD='20' then
        do;
          DATE=input(DSCHRGDT,julian7.);
          VARIABLE_NAME='ACUTE CARE DEATH';
          VARIABLE_VALUE=DSTNTNCD;
          output;
        end;
    run;
%mend GetMoreMedPar;

%GetMoreMedPar()

/*******************************/
/*******************************/
/**                           **/
/**  Section  7.              **/
/**                           **/
/*******************************/
/*******************************/
  
%macro GetChemo();

  /**  DM data sets.  **/
  data ChemoFromDM(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.dm_1992(keep=BID_HRS FROM_DT DGNS_CD: HCPSCD: EXPDT2: BETOS:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.dm_&x(keep=BID_HRS FROM_DT DGNS_CD: HCPSCD: EXPDT2: BETOS:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNS: ;
    array HCPCs{*] HCPSCD:;
    array ExpDts{*} EXPDT2:;
    array BETOS{*} BETOS:;

    do i=1 to dim (DxCodes);
      if put(DxCodes{i},$Chemo.)='CHEMO' then
        do;
          DATE=input(FROM_DT,yymmdd10.);
          VARIABLE_NAME='CHEMOTHERAPY';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

    do i=1 to dim(HCPCs);
      if put(HCPCS{i},$Chemo.)='CHEMO' then
        do;
          DATE=input(ExpDts{i},yymmdd10.);
          VARIABLE_NAME='CHEMOTHERAPY';
          VARIABLE_VALUE=HCPCs{i};
          output;
        end;
    end;

    do i=1 to dim(BETOS);
      if put(BETOS{i},$Chemo.)='CHEMO' then
        do;
          DATE=input(ExpDts{i},yymmdd10.);
          VARIABLE_NAME='CHEMOTHERAPY';
          VARIABLE_VALUE=BETOS{i};
          output;
        end;
    end;

  run;

  /**  HH data sets.  **/
  data ChemoFromHH(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.hh_1991(keep=BID_HRS FROM_DT DGNSCD: HCPSCD: RVCNTR: REV_DT:)
        CMSClms.hh_1992(keep=BID_HRS FROM_DT DGNSCD: HCPSCD: RVCNTR: REV_DT:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.hh_&x(keep=BID_HRS FROM_DT DGNSCD: HCPSCD: RVCNTR: REV_DT:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNS: ;
    array HCPCs{*] HCPSCD:;
    array RevCds{*} RVCNTR:;
    array RevDts{*} REV_DT:;

    do i=1 to dim (DxCodes);
      if put(DxCodes{i},$Chemo.)='CHEMO' then
        do;
          DATE=input(FROM_DT,yymmdd10.);
          VARIABLE_NAME='CHEMOTHERAPY';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

    do i=1 to dim(HCPCs);
      if put(HCPCS{i},$Chemo.)='CHEMO' then
        do;
          DATE=input(RevDts{i},yymmdd10.);
          VARIABLE_NAME='CHEMOTHERAPY';
          VARIABLE_VALUE=HCPCs{i};
          output;
        end;
    end;

    do i=1 to dim(RevCds);
      if put(RevCds{i},$Chemo.)='CHEMO' then
        do;
          DATE=input(RevDts{i},yymmdd10.);
          VARIABLE_NAME='CHEMOTHERAPY';
          VARIABLE_VALUE=RevCds{i};
          output;
        end;
    end;

  run;

  /**  HS data sets.  **/
  data ChemoFromHS(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.hs_1991(keep=BID_HRS FROM_DT DGNSCD: HCPSCD: RVCNTR: REV_DT:)
        CMSClms.hs_1992(keep=BID_HRS FROM_DT DGNSCD: HCPSCD: RVCNTR: REV_DT:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.hs_&x(keep=BID_HRS FROM_DT DGNSCD: HCPSCD: RVCNTR: REV_DT:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNS: ;
    array HCPCs{*] HCPSCD:;
    array RevCds{*} RVCNTR:;
    array RevDts{*} REV_DT:;

    do i=1 to dim (DxCodes);
      if put(DxCodes{i},$Chemo.)='CHEMO' then
        do;
          DATE=input(FROM_DT,yymmdd10.);
          VARIABLE_NAME='CHEMOTHERAPY';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

    do i=1 to dim(HCPCs);
      if put(HCPCS{i},$Chemo.)='CHEMO' then
        do;
          DATE=input(RevDts{i},yymmdd10.);
          VARIABLE_NAME='CHEMOTHERAPY';
          VARIABLE_VALUE=HCPCs{i};
          output;
        end;
    end;

    do i=1 to dim(RevCds);
      if put(RevCds{i},$Chemo.)='CHEMO' then
        do;
          DATE=input(RevDts{i},yymmdd10.);
          VARIABLE_NAME='CHEMOTHERAPY';
          VARIABLE_VALUE=RevCds{i};
          output;
        end;
    end;

  run;

  /**  IP data sets.  **/
  data ChemoFromIP(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.ip_1991(keep=BID_HRS ADMSN_DT DGNSCD: PRCDRCD: HCPSCD: RVCNTR: PRCDRDT: REV_DT:)
        CMSClms.ip_1992(keep=BID_HRS ADMSN_DT DGNSCD: PRCDRCD: HCPSCD: RVCNTR: PRCDRDT: REV_DT:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.ip_&x(keep=BID_HRS ADMSN_DT DGNSCD: PRCDRCD: HCPSCD: RVCNTR: PRCDRDT: REV_DT:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNS: ;
    array HCPCs{*] HCPSCD:;
    array ProcCds{*} PRCDRCD:;
    array RevCds{*} RVCNTR:;
    array RevDts{*} REV_DT:;
    array ProcDts{*} PRCDRDT:;

    do i=1 to dim (DxCodes);
      if put(DxCodes{i},$Chemo.)='CHEMO' then
        do;
          DATE=input(ADMSN_DT,yymmdd10.);
          VARIABLE_NAME='CHEMOTHERAPY';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

    do i=1 to dim(HCPCs);
      if put(HCPCS{i},$Chemo.)='CHEMO' then
        do;
          if RevDts{i} ne '00000000' then DATE=input(RevDts{i},yymmdd10.);
          VARIABLE_NAME='CHEMOTHERAPY';
          VARIABLE_VALUE=HCPCs{i};
          output;
        end;
    end;

    do i=1 to dim(RevCds);
      if put(RevCds{i},$Chemo.)='CHEMO' then
        do;
          if RevDts{i} ne '00000000' then DATE=input(RevDts{i},yymmdd10.);
          VARIABLE_NAME='CHEMOTHERAPY';
          VARIABLE_VALUE=RevCds{i};
          output;
        end;
    end;

    do i=1 to dim(ProcCds);
      if put(ProcCds{i},$Chemo.)='CHEMO' then
        do;
          DATE=input(ProcDts{i},yymmdd10.);
          VARIABLE_NAME='CHEMOTHERAPY';
          VARIABLE_VALUE=ProcCds{i};
          output;
        end;
    end;

  run;

  /**  MP data sets.  **/
  data ChemoFromMP(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.mp_1991(keep=BID_HRS ADMSNDT DGNS_CD: PRCDR_CD: PRCDR_DT:)
        CMSClms.mp_1992(keep=BID_HRS ADMSNDT DGNS_CD: PRCDR_CD: PRCDR_DT:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.mp_&x(keep=BID_HRS ADMSNDT DGNS_CD: PRCDR_CD: PRCDR_DT:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNS_CD: ;
    array ProcCds{*} PRCDR_CD:;
    array ProcDts{*} PRCDR_DT:;

    do i=1 to dim (DxCodes);
      if put(DxCodes{i},$Chemo.)='CHEMO' then
        do;
          DATE=input(ADMSNDT,julian7.);
          VARIABLE_NAME='CHEMOTHERAPY';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

    do i=1 to dim(ProcCds);
      if put(ProcCds{i},$Chemo.)='CHEMO' then
        do;
          if ProcDts{i} ne '0000000' then DATE=input(ProcDts{i},julian7.);
          VARIABLE_NAME='CHEMOTHERAPY';
          VARIABLE_VALUE=ProcCds{i};
          output;
        end;
    end;

  run;

  /**  OP data sets.  **/
  data ChemoFromOP(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.op_1991(keep=BID_HRS FROM_DT DGNSCD: PRCDRCD: RVCNTR: HCPSCD: PRCDRDT: REV_DT:)
        CMSClms.op_1992(keep=BID_HRS FROM_DT DGNSCD: PRCDRCD: RVCNTR: HCPSCD: PRCDRDT: REV_DT:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.op_&x(keep=BID_HRS FROM_DT DGNSCD: PRCDRCD: RVCNTR: HCPSCD: PRCDRDT: REV_DT:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNSCD: ;
    array ProcCds{*} PRCDRCD:;
    array HCPCs{*] HCPSCD:;
    array RevCds{*} RVCNTR:;

    array RevDts{*} REV_DT:;
    array ProcDts{*} PRCDRDT:;

    do i=1 to dim (DxCodes);
      if put(DxCodes{i},$Chemo.)='CHEMO' then
        do;
          DATE=input(FROM_DT,yymmdd10.);
          VARIABLE_NAME='CHEMOTHERAPY';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

    do i=1 to dim(ProcCds);
      if put(ProcCds{i},$Chemo.)='CHEMO' then
        do;
          if ProcDts{i} ne '00000000' then DATE=input(ProcDts{i},yymmdd10.);
          VARIABLE_NAME='CHEMOTHERAPY';
          VARIABLE_VALUE=ProcCds{i};
          output;
        end;
    end;

    do i=1 to dim(HCPCs);
      if put(HCPCs{i},$Chemo.)='CHEMO' then
        do;
          if RevDts{i} ne '00000000' then DATE=input(RevDts{i},yymmdd10.);
          VARIABLE_NAME='CHEMOTHERAPY';
          VARIABLE_VALUE=HCPCs{i};
          output;
        end;
    end;

    do i=1 to dim(RevCds);
      if put(RevCds{i},$Chemo.)='CHEMO' then
        do;
          if RevDts{i} ne '00000000' then DATE=input(RevDts{i},yymmdd10.);
          VARIABLE_NAME='CHEMOTHERAPY';
          VARIABLE_VALUE=RevCds{i};
          output;
        end;
    end;

  run;

  /**  PB data sets.  **/
  data ChemoFromPB(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.pb_1991(keep=BID_HRS FROM_DT DGNS_CD: HCPSCD: EXPDT2: BETOS:)
        CMSClms.pb_1992(keep=BID_HRS FROM_DT DGNS_CD: HCPSCD: EXPDT2: BETOS:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.pb_&x(keep=BID_HRS FROM_DT DGNS_CD: HCPSCD: EXPDT2: BETOS:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNS: ;
    array HCPCs{*] HCPSCD:;
    array ExpDts{*} EXPDT2:;
    array BETOS{*} BETOS:;

    do i=1 to dim (DxCodes);
      if put(DxCodes{i},$Chemo.)='CHEMO' then
        do;
          DATE=input(FROM_DT,yymmdd10.);
          VARIABLE_NAME='CHEMOTHERAPY';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

    do i=1 to dim(HCPCs);
      if put(HCPCS{i},$Chemo.)='CHEMO' then
        do;
          DATE=input(ExpDts{i},yymmdd10.);
          VARIABLE_NAME='CHEMOTHERAPY';
          VARIABLE_VALUE=HCPCs{i};
          output;
        end;
    end;

    do i=1 to dim(BETOS);
      if put(BETOS{i},$Chemo.)='CHEMO' then
        do;
          DATE=input(ExpDts{i},yymmdd10.);
          VARIABLE_NAME='CHEMOTHERAPY';
          VARIABLE_VALUE=BETOS{i};
          output;
        end;
    end;

  run;

/**  SN data sets.  **/
  data ChemoFromSN(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.sn_1991(keep=BID_HRS ADMSN_DT DGNSCD: PRCDRCD: HCPSCD: RVCNTR: PRCDRDT: REV_DT:)
        CMSClms.sn_1992(keep=BID_HRS ADMSN_DT DGNSCD: PRCDRCD: HCPSCD: RVCNTR: PRCDRDT: REV_DT:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.sn_&x(keep=BID_HRS ADMSN_DT DGNSCD: PRCDRCD: HCPSCD: RVCNTR: PRCDRDT: REV_DT:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNS: ;
    array HCPCs{*] HCPSCD:;
    array ProcCds{*} PRCDRCD:;
    array RevCds{*} RVCNTR:;
    array RevDts{*} REV_DT:;
    array ProcDts{*} PRCDRDT:;

    do i=1 to dim (DxCodes);
      if put(DxCodes{i},$Chemo.)='CHEMO' then
        do;
          DATE=input(ADMSN_DT,yymmdd10.);
          VARIABLE_NAME='CHEMOTHERAPY';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

    do i=1 to dim(HCPCs);
      if put(HCPCS{i},$Chemo.)='CHEMO' then
        do;
          if RevDts{i} ne '00000000' then DATE=input(RevDts{i},yymmdd10.);
          VARIABLE_NAME='CHEMOTHERAPY';
          VARIABLE_VALUE=HCPCs{i};
          output;
        end;
    end;

    do i=1 to dim(RevCds);
      if put(RevCds{i},$Chemo.)='CHEMO' then
        do;
          if RevDts{i} ne '00000000' then DATE=input(RevDts{i},yymmdd10.);
          VARIABLE_NAME='CHEMOTHERAPY';
          VARIABLE_VALUE=RevCds{i};
          output;
        end;
    end;

    do i=1 to dim(ProcCds);
      if put(ProcCds{i},$Chemo.)='CHEMO' then
        do;
          DATE=input(ProcDts{i},yymmdd10.);
          VARIABLE_NAME='CHEMOTHERAPY';
          VARIABLE_VALUE=ProcCds{i};
          output;
        end;
    end;

  run;

%mend GetChemo;

%GetChemo()

/*******************************/
/*******************************/
/**                           **/
/**  Section  8.              **/
/**  Acute renal failure.     **/
/**                           **/
/*******************************/
/*******************************/
  
%macro GetARF();

  /**  DM data sets.  **/
  data ARFFromDM(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.dm_1992(keep=BID_HRS FROM_DT DGNS_CD:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.dm_&x(keep=BID_HRS FROM_DT DGNS_CD:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNS: ;

    do i=1 to dim (DxCodes);
      if put(DxCodes{i},$ARF.)='ARF' then
        do;
          DATE=input(FROM_DT,yymmdd10.);
          VARIABLE_NAME='ACUTE RENAL FAILURE';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

  run;

  /**  HH data sets.  **/
  data ARFFromHH(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.hh_1991(keep=BID_HRS FROM_DT DGNSCD:)
        CMSClms.hh_1992(keep=BID_HRS FROM_DT DGNSCD:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.hh_&x(keep=BID_HRS FROM_DT DGNSCD:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNS: ;

    do i=1 to dim (DxCodes);
      if put(DxCodes{i},$ARF.)='ARF' then
        do;
          DATE=input(FROM_DT,yymmdd10.);
          VARIABLE_NAME='ACUTE RENAL FAILURE';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

  run;

  /**  HS data sets.  **/
  data ARFFromHS(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.hs_1991(keep=BID_HRS FROM_DT DGNSCD:)
        CMSClms.hs_1992(keep=BID_HRS FROM_DT DGNSCD:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.hs_&x(keep=BID_HRS FROM_DT DGNSCD:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNS: ;

    do i=1 to dim (DxCodes);
      if put(DxCodes{i},$ARF.)='ARF' then
        do;
          DATE=input(FROM_DT,yymmdd10.);
          VARIABLE_NAME='ACUTE RENAL FAILURE';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

  run;

  /**  IP data sets.  **/
  data ARFFromIP(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.ip_1991(keep=BID_HRS ADMSN_DT DGNSCD:)
        CMSClms.ip_1992(keep=BID_HRS ADMSN_DT DGNSCD:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.ip_&x(keep=BID_HRS ADMSN_DT DGNSCD:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNS: ;

    do i=1 to dim (DxCodes);
      if put(DxCodes{i},$ARF.)='ARF' then
        do;
          DATE=input(ADMSN_DT,yymmdd10.);
          VARIABLE_NAME='ACUTE RENAL FAILURE';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

  run;

  /**  MP data sets.  **/
  data ARFFromMP(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.mp_1991(keep=BID_HRS ADMSNDT DGNS_CD:)
        CMSClms.mp_1992(keep=BID_HRS ADMSNDT DGNS_CD:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.mp_&x(keep=BID_HRS ADMSNDT DGNS_CD:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNS_CD: ;

    do i=1 to dim (DxCodes);
      if put(DxCodes{i},$ARF.)='ARF' then
        do;
          DATE=input(ADMSNDT,julian7.);
          VARIABLE_NAME='ACUTE RENAL FAILURE';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

  run;

  /**  OP data sets.  **/
  data ARFFromOP(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.op_1991(keep=BID_HRS FROM_DT DGNSCD:)
        CMSClms.op_1992(keep=BID_HRS FROM_DT DGNSCD:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.op_&x(keep=BID_HRS FROM_DT DGNSCD:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNSCD: ;

    do i=1 to dim (DxCodes);
      if put(DxCodes{i},$ARF.)='ARF' then
        do;
          DATE=input(FROM_DT,yymmdd10.);
          VARIABLE_NAME='ACUTE RENAL FAILURE';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;
  run;

  /**  PB data sets.  **/
  data ARFFromPB(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.pb_1991(keep=BID_HRS FROM_DT DGNS_CD:)
        CMSClms.pb_1992(keep=BID_HRS FROM_DT DGNS_CD:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.pb_&x(keep=BID_HRS FROM_DT DGNS_CD:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNS: ;

    do i=1 to dim (DxCodes);
      if put(DxCodes{i},$ARF.)='ARF' then
        do;
          DATE=input(FROM_DT,yymmdd10.);
          VARIABLE_NAME='ACUTE RENAL FAILURE';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

  run;

/**  SN data sets.  **/
  data ARFFromSN(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.sn_1991(keep=BID_HRS ADMSN_DT DGNSCD:)
        CMSClms.sn_1992(keep=BID_HRS ADMSN_DT DGNSCD:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.sn_&x(keep=BID_HRS ADMSN_DT DGNSCD:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNS: ;

    do i=1 to dim (DxCodes);
      if put(DxCodes{i},$ARF.)='ARF' then
        do;
          DATE=input(ADMSN_DT,yymmdd10.);
          VARIABLE_NAME='ACUTE RENAL FAILURE';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

  run;
%mend GetARF;

%GetARF()

/*******************************/
/*******************************/
/**                           **/
/**  Section  9.              **/
/**  Renal dialysis.          **/
/**                           **/
/*******************************/
/*******************************/
  
%macro GetRD();

  /**  DM data sets.  **/
  data RDFromDM(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.dm_1992(keep=BID_HRS FROM_DT DGNS_CD:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.dm_&x(keep=BID_HRS FROM_DT DGNS_CD:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNS: ;

    do i=1 to dim (DxCodes);
      if put(DxCodes{i},$RD.)='RD' then
        do;
          DATE=input(FROM_DT,yymmdd10.);
          VARIABLE_NAME='RENAL DIALYSIS';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

  run;

  /**  HH data sets.  **/
  data RDFromHH(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.hh_1991(keep=BID_HRS FROM_DT DGNSCD: RVCNTR: REV_DT:)
        CMSClms.hh_1992(keep=BID_HRS FROM_DT DGNSCD: RVCNTR: REV_DT:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.hh_&x(keep=BID_HRS FROM_DT DGNSCD: RVCNTR: REV_DT:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNS: ;
    array RevCds{*} RVCNTR:;
    array RevDts{*} REV_DT:;

    do i=1 to dim (DxCodes);
      if put(DxCodes{i},$RD.)='RD' then
        do;
          DATE=input(FROM_DT,yymmdd10.);
          VARIABLE_NAME='RENAL DIALYSIS';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

    do i=1 to dim(RevCds);
      if put(RevCds{i},$RD.)='RD' then
        do;
          DATE=input(RevDts{i},yymmdd10.);
          VARIABLE_NAME='RENAL DIALYSIS';
          VARIABLE_VALUE=RevCds{i};
          output;
        end;
    end;

  run;

  /**  HS data sets.  **/
  data RDFromHS(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.hs_1991(keep=BID_HRS FROM_DT DGNSCD: RVCNTR: REV_DT:)
        CMSClms.hs_1992(keep=BID_HRS FROM_DT DGNSCD: RVCNTR: REV_DT:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.hs_&x(keep=BID_HRS FROM_DT DGNSCD: RVCNTR: REV_DT:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNS: ;
    array RevCds{*} RVCNTR:;
    array RevDts{*} REV_DT:;

    do i=1 to dim (DxCodes);
      if put(DxCodes{i},$RD.)='RD' then
        do;
          DATE=input(FROM_DT,yymmdd10.);
          VARIABLE_NAME='RENAL DIALYSIS';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

    do i=1 to dim(RevCds);
      if put(RevCds{i},$RD.)='RD' then
        do;
          DATE=input(RevDts{i},yymmdd10.);
          VARIABLE_NAME='RENAL DIALYSIS';
          VARIABLE_VALUE=RevCds{i};
          output;
        end;
    end;

  run;

  /**  IP data sets.  **/
  data RDFromIP(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.ip_1991(keep=BID_HRS ADMSN_DT DGNSCD: RVCNTR: REV_DT:)
        CMSClms.ip_1992(keep=BID_HRS ADMSN_DT DGNSCD: RVCNTR: REV_DT:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.ip_&x(keep=BID_HRS ADMSN_DT DGNSCD: RVCNTR: REV_DT:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNS: ;
    array RevCds{*} RVCNTR:;
    array RevDts{*} REV_DT:;

    do i=1 to dim (DxCodes);
      if put(DxCodes{i},$RD.)='RD' then
        do;
          DATE=input(ADMSN_DT,yymmdd10.);
          VARIABLE_NAME='RENAL DIALYSIS';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

    do i=1 to dim(RevCds);
      if put(RevCds{i},$RD.)='RD' then
        do;
          if RevDts{i} ne '00000000' then DATE=input(RevDts{i},yymmdd10.);
          VARIABLE_NAME='RENAL DIALYSIS';
          VARIABLE_VALUE=RevCds{i};
          output;
        end;
    end;

  run;

  /**  MP data sets.  **/
  data RDFromMP(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.mp_1991(keep=BID_HRS ADMSNDT DGNS_CD:)
        CMSClms.mp_1992(keep=BID_HRS ADMSNDT DGNS_CD:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.mp_&x(keep=BID_HRS ADMSNDT DGNS_CD:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNS_CD: ;

    do i=1 to dim (DxCodes);
      if put(DxCodes{i},$RD.)='RD' then
        do;
          DATE=input(ADMSNDT,julian7.);
          VARIABLE_NAME='RENAL DIALYSIS';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

  run;

  /**  OP data sets.  **/
  data RDFromOP(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.op_1991(keep=BID_HRS FROM_DT DGNSCD: RVCNTR: REV_DT:)
        CMSClms.op_1992(keep=BID_HRS FROM_DT DGNSCD: RVCNTR: REV_DT:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.op_&x(keep=BID_HRS FROM_DT DGNSCD:RVCNTR: REV_DT:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNSCD: ;
    array RevCds{*} RVCNTR:;
    array RevDts{*} REV_DT:;

    do i=1 to dim (DxCodes);
      if put(DxCodes{i},$RD.)='RD' then
        do;
          DATE=input(FROM_DT,yymmdd10.);
          VARIABLE_NAME='RENAL DIALYSIS';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

    do i=1 to dim(RevCds);
      if put(RevCds{i},$RD.)='RD' then
        do;
          if RevDts{i} ne '00000000' then DATE=input(RevDts{i},yymmdd10.);
          VARIABLE_NAME='RENAL DIALYSIS';
          VARIABLE_VALUE=RevCds{i};
          output;
        end;
    end;

  run;

  /**  PB data sets.  **/
  data RDFromPB(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.pb_1991(keep=BID_HRS FROM_DT DGNS_CD:)
        CMSClms.pb_1992(keep=BID_HRS FROM_DT DGNS_CD:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.pb_&x(keep=BID_HRS FROM_DT DGNS_CD:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNS: ;

    do i=1 to dim (DxCodes);
      if put(DxCodes{i},$RD.)='RD' then
        do;
          DATE=input(FROM_DT,yymmdd10.);
          VARIABLE_NAME='RENAL DIALYSIS';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

  run;

/**  SN data sets.  **/
  data RDFromSN(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.sn_1991(keep=BID_HRS ADMSN_DT DGNSCD: RVCNTR: REV_DT:)
        CMSClms.sn_1992(keep=BID_HRS ADMSN_DT DGNSCD: RVCNTR: REV_DT:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.sn_&x(keep=BID_HRS ADMSN_DT DGNSCD: RVCNTR: REV_DT:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNS: ;
    array RevCds{*} RVCNTR:;
    array RevDts{*} REV_DT:;

    do i=1 to dim (DxCodes);
      if put(DxCodes{i},$RD.)='RD' then
        do;
          DATE=input(ADMSN_DT,yymmdd10.);
          VARIABLE_NAME='RENAL DIALYSIS';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

    do i=1 to dim(RevCds);
      if put(RevCds{i},$RD.)='RD' then
        do;
          if RevDts{i} ne '00000000' then DATE=input(RevDts{i},yymmdd10.);
          VARIABLE_NAME='RENAL DIALYSIS';
          VARIABLE_VALUE=RevCds{i};
          output;
        end;
    end;

  run;

%mend GetRD;

%GetRD()

/*******************************/
/*******************************/
/**                           **/
/**  Section  10.             **/
/**  Acute organ dysfunction. **/
/**                           **/
/*******************************/
/*******************************/
  
%macro GetAOD();

  /**  DM data sets.  **/
  data AODFromDM(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.dm_1992(keep=BID_HRS FROM_DT DGNS_CD:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.dm_&x(keep=BID_HRS FROM_DT DGNS_CD:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNS: ;

    do i=1 to dim (DxCodes);
      if put(DxCodes{i},$AOD.)='AOD' then
        do;
          DATE=input(FROM_DT,yymmdd10.);
          VARIABLE_NAME='ACUTE ORGAN DYSFUNCTION';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

  run;

  /**  HH data sets.  **/
  data AODFromHH(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.hh_1991(keep=BID_HRS FROM_DT DGNSCD:)
        CMSClms.hh_1992(keep=BID_HRS FROM_DT DGNSCD:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.hh_&x(keep=BID_HRS FROM_DT DGNSCD:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNS: ;

    do i=1 to dim (DxCodes);
      if put(DxCodes{i},$AOD.)='AOD' then
        do;
          DATE=input(FROM_DT,yymmdd10.);
          VARIABLE_NAME='ACUTE ORGAN DYSFUNCTION';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

  run;

  /**  HS data sets.  **/
  data AODFromHS(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.hs_1991(keep=BID_HRS FROM_DT DGNSCD:)
        CMSClms.hs_1992(keep=BID_HRS FROM_DT DGNSCD:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.hs_&x(keep=BID_HRS FROM_DT DGNSCD:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNS: ;

    do i=1 to dim (DxCodes);
      if put(DxCodes{i},$AOD.)='AOD' then
        do;
          DATE=input(FROM_DT,yymmdd10.);
          VARIABLE_NAME='ACUTE ORGAN DYSFUNCTION';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

  run;

  /**  IP data sets.  **/
  data AODFromIP(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.ip_1991(keep=BID_HRS ADMSN_DT DGNSCD:)
        CMSClms.ip_1992(keep=BID_HRS ADMSN_DT DGNSCD:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.ip_&x(keep=BID_HRS ADMSN_DT DGNSCD:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNS: ;

    do i=1 to dim (DxCodes);
      if put(DxCodes{i},$AOD.)='AOD' then
        do;
          DATE=input(ADMSN_DT,yymmdd10.);
          VARIABLE_NAME='ACUTE ORGAN DYSFUNCTION';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

  run;

  /**  MP data sets.  **/
  data AODFromMP(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.mp_1991(keep=BID_HRS ADMSNDT DGNS_CD:)
        CMSClms.mp_1992(keep=BID_HRS ADMSNDT DGNS_CD:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.mp_&x(keep=BID_HRS ADMSNDT DGNS_CD:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNS_CD: ;

    do i=1 to dim (DxCodes);
      if put(DxCodes{i},$AOD.)='AOD' then
        do;
          DATE=input(ADMSNDT,julian7.);
          VARIABLE_NAME='ACUTE ORGAN DYSFUNCTION';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

  run;

  /**  OP data sets.  **/
  data AODFromOP(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.op_1991(keep=BID_HRS FROM_DT DGNSCD: RVCNTR: REV_DT:)
        CMSClms.op_1992(keep=BID_HRS FROM_DT DGNSCD: RVCNTR: REV_DT:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.op_&x(keep=BID_HRS FROM_DT DGNSCD:RVCNTR: REV_DT:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNSCD: ;

    do i=1 to dim (DxCodes);
      if put(DxCodes{i},$AOD.)='AOD' then
        do;
          DATE=input(FROM_DT,yymmdd10.);
          VARIABLE_NAME='ACUTE ORGAN DYSFUNCTION';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

  run;

  /**  PB data sets.  **/
  data AODFromPB(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.pb_1991(keep=BID_HRS FROM_DT DGNS_CD:)
        CMSClms.pb_1992(keep=BID_HRS FROM_DT DGNS_CD:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.pb_&x(keep=BID_HRS FROM_DT DGNS_CD:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNS: ;

    do i=1 to dim (DxCodes);
      if put(DxCodes{i},$AOD.)='AOD' then
        do;
          DATE=input(FROM_DT,yymmdd10.);
          VARIABLE_NAME='ACUTE ORGAN DYSFUNCTION';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

  run;

/**  SN data sets.  **/
  data AODFromSN(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.sn_1991(keep=BID_HRS ADMSN_DT DGNSCD:)
        CMSClms.sn_1992(keep=BID_HRS ADMSN_DT DGNSCD:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.sn_&x(keep=BID_HRS ADMSN_DT DGNSCD:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNS: ;

    do i=1 to dim (DxCodes);
      if put(DxCodes{i},$AOD.)='AOD' then
        do;
          DATE=input(ADMSN_DT,yymmdd10.);
          VARIABLE_NAME='ACUTE ORGAN DYSFUNCTION';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

  run;

%mend GetAOD;

%GetAOD()

/*******************************/
/*******************************/
/**                           **/
/**  Section 11.              **/
/**  Sepsis.                  **/
/**                           **/
/*******************************/
/*******************************/
  
%macro GetSEPSIS();

  /**  DM data sets.  **/
  data SEPSISFromDM(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.dm_1992(keep=BID_HRS FROM_DT DGNS_CD:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.dm_&x(keep=BID_HRS FROM_DT DGNS_CD:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNS: ;

    do i=1 to dim (DxCodes);
      if put(DxCodes{i},$SEPSIS.)='SEPSIS' then
        do;
          DATE=input(FROM_DT,yymmdd10.);
          VARIABLE_NAME='SEPSIS';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

  run;

  /**  HH data sets.  **/
  data SEPSISFromHH(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.hh_1991(keep=BID_HRS FROM_DT DGNSCD:)
        CMSClms.hh_1992(keep=BID_HRS FROM_DT DGNSCD:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.hh_&x(keep=BID_HRS FROM_DT DGNSCD:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNS: ;

    do i=1 to dim (DxCodes);
      if put(DxCodes{i},$SEPSIS.)='SEPSIS' then
        do;
          DATE=input(FROM_DT,yymmdd10.);
          VARIABLE_NAME='SEPSIS';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

  run;

  /**  HS data sets.  **/
  data SEPSISFromHS(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.hs_1991(keep=BID_HRS FROM_DT DGNSCD:)
        CMSClms.hs_1992(keep=BID_HRS FROM_DT DGNSCD:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.hs_&x(keep=BID_HRS FROM_DT DGNSCD:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNS: ;

    do i=1 to dim (DxCodes);
      if put(DxCodes{i},$SEPSIS.)='SEPSIS' then
        do;
          DATE=input(FROM_DT,yymmdd10.);
          VARIABLE_NAME='SEPSIS';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

  run;

  /**  IP data sets.  **/
  data SEPSISFromIP(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.ip_1991(keep=BID_HRS ADMSN_DT DGNSCD:)
        CMSClms.ip_1992(keep=BID_HRS ADMSN_DT DGNSCD:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.ip_&x(keep=BID_HRS ADMSN_DT DGNSCD:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNS: ;

    do i=1 to dim (DxCodes);
      if put(DxCodes{i},$SEPSIS.)='SEPSIS' then
        do;
          DATE=input(ADMSN_DT,yymmdd10.);
          VARIABLE_NAME='SEPSIS';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

  run;

  /**  MP data sets.  **/
  data SEPSISFromMP(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.mp_1991(keep=BID_HRS ADMSNDT DGNS_CD:)
        CMSClms.mp_1992(keep=BID_HRS ADMSNDT DGNS_CD:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.mp_&x(keep=BID_HRS ADMSNDT DGNS_CD:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNS_CD: ;

    do i=1 to dim (DxCodes);
      if put(DxCodes{i},$SEPSIS.)='SEPSIS' then
        do;
          DATE=input(ADMSNDT,julian7.);
          VARIABLE_NAME='SEPSIS';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

  run;

  /**  OP data sets.  **/
  data SEPSISFromOP(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.op_1991(keep=BID_HRS FROM_DT DGNSCD: RVCNTR: REV_DT:)
        CMSClms.op_1992(keep=BID_HRS FROM_DT DGNSCD: RVCNTR: REV_DT:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.op_&x(keep=BID_HRS FROM_DT DGNSCD:RVCNTR: REV_DT:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNSCD: ;

    do i=1 to dim (DxCodes);
      if put(DxCodes{i},$SEPSIS.)='SEPSIS' then
        do;
          DATE=input(FROM_DT,yymmdd10.);
          VARIABLE_NAME='SEPSIS';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

  run;

  /**  PB data sets.  **/
  data SEPSISFromPB(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.pb_1991(keep=BID_HRS FROM_DT DGNS_CD:)
        CMSClms.pb_1992(keep=BID_HRS FROM_DT DGNS_CD:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.pb_&x(keep=BID_HRS FROM_DT DGNS_CD:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNS: ;

    do i=1 to dim (DxCodes);
      if put(DxCodes{i},$SEPSIS.)='SEPSIS' then
        do;
          DATE=input(FROM_DT,yymmdd10.);
          VARIABLE_NAME='SEPSIS';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

  run;

/**  SN data sets.  **/
  data SEPSISFromSN(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.sn_1991(keep=BID_HRS ADMSN_DT DGNSCD:)
        CMSClms.sn_1992(keep=BID_HRS ADMSN_DT DGNSCD:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.sn_&x(keep=BID_HRS ADMSN_DT DGNSCD:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNS: ;

    do i=1 to dim (DxCodes);
      if put(DxCodes{i},$SEPSIS.)='SEPSIS' then
        do;
          DATE=input(ADMSN_DT,yymmdd10.);
          VARIABLE_NAME='SEPSIS';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

  run;

%mend GetSEPSIS;

%GetSEPSIS()

/*******************************/
/*******************************/
/**                           **/
/**  Section  12.             **/
/**  Tracheostomy.            **/
/**                           **/
/*******************************/
/*******************************/
  
%macro GetTRACH();

  /**  DM data sets.  **/
  data TRACHFromDM(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.dm_1992(keep=BID_HRS FROM_DT DGNS_CD:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.dm_&x(keep=BID_HRS FROM_DT DGNS_CD:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNS: ;

    do i=1 to dim (DxCodes);
      if DxCodes{i} in ('9672') then
        do;
          DATE=input(FROM_DT,yymmdd10.);
          VARIABLE_NAME='TRACHEOSTOMY';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

  run;

  /**  HH data sets.  **/
  data TRACHFromHH(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.hh_1991(keep=BID_HRS FROM_DT DGNSCD:)
        CMSClms.hh_1992(keep=BID_HRS FROM_DT DGNSCD:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.hh_&x(keep=BID_HRS FROM_DT DGNSCD:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNS: ;

    do i=1 to dim (DxCodes);
      if DxCodes{i} in ('9672') then
        do;
          DATE=input(FROM_DT,yymmdd10.);
          VARIABLE_NAME='TRACHEOSTOMY';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

  run;

  /**  HS data sets.  **/
  data TRACHFromHS(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.hs_1991(keep=BID_HRS FROM_DT DGNSCD:)
        CMSClms.hs_1992(keep=BID_HRS FROM_DT DGNSCD:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.hs_&x(keep=BID_HRS FROM_DT DGNSCD:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNS: ;

    do i=1 to dim (DxCodes);
      if DxCodes{i} in ('9672') then
        do;
          DATE=input(FROM_DT,yymmdd10.);
          VARIABLE_NAME='TRACHEOSTOMY';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

  run;

  /**  IP data sets.  **/
  data TRACHFromIP(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.ip_1991(keep=BID_HRS ADMSN_DT DRG_CD DGNSCD:)
        CMSClms.ip_1992(keep=BID_HRS ADMSN_DT DRG_CD DGNSCD:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.ip_&x(keep=BID_HRS ADMSN_DT DRG_CD DGNSCD:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNS: ;

    do i=1 to dim (DxCodes);
      if DxCodes{i} in ('9672') then
        do;
          DATE=input(ADMSN_DT,yymmdd10.);
          VARIABLE_NAME='TRACHEOSTOMY';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;
    if DRG_CD in (483) then
      do;
        DATE=input(ADMSN_DT,yymmdd10.);
        VARIABLE_NAME='TRACHEOSTOMY';
        VARIABLE_VALUE=left(put(DRG_CD,3.));
        output;
      end;

  run;

  /**  MP data sets.  **/
  data TRACHFromMP(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.mp_1991(keep=BID_HRS ADMSNDT DGNS_CD: DRG_CD)
        CMSClms.mp_1992(keep=BID_HRS ADMSNDT DGNS_CD: DRG_CD)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.mp_&x(keep=BID_HRS ADMSNDT DGNS_CD: DRG_CD)
            %end;
          %end;
          ;

    array DxCodes{*} DGNS_CD: ;

    do i=1 to dim (DxCodes);
      if DxCodes{i} in ('9672','483') then
        do;
          DATE=input(ADMSNDT,julian7.);
          VARIABLE_NAME='TRACHEOSTOMY';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;
    if DRG_CD in (483) then
      do;
        DATE=input(ADMSNDT,julian7.);
        VARIABLE_NAME='TRACHEOSTOMY';
        VARIABLE_VALUE=left(put(DRG_CD,3.));
        output;
      end;

  run;

  /**  OP data sets.  **/
  data TRACHFromOP(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.op_1991(keep=BID_HRS FROM_DT DGNSCD: RVCNTR: REV_DT:)
        CMSClms.op_1992(keep=BID_HRS FROM_DT DGNSCD: RVCNTR: REV_DT:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.op_&x(keep=BID_HRS FROM_DT DGNSCD:RVCNTR: REV_DT:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNSCD: ;

    do i=1 to dim (DxCodes);
      if DxCodes{i} in ('9672') then
        do;
          DATE=input(FROM_DT,yymmdd10.);
          VARIABLE_NAME='TRACHEOSTOMY';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

  run;

  /**  PB data sets.  **/
  data TRACHFromPB(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.pb_1991(keep=BID_HRS FROM_DT DGNS_CD:)
        CMSClms.pb_1992(keep=BID_HRS FROM_DT DGNS_CD:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.pb_&x(keep=BID_HRS FROM_DT DGNS_CD:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNS: ;

    do i=1 to dim (DxCodes);
      if DxCodes{i} in ('9672') then
        do;
          DATE=input(FROM_DT,yymmdd10.);
          VARIABLE_NAME='TRACHEOSTOMY';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

  run;

/**  SN data sets.  **/
  data TRACHFromSN(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.sn_1991(keep=BID_HRS ADMSN_DT DRG_CD DGNSCD:)
        CMSClms.sn_1992(keep=BID_HRS ADMSN_DT DRG_CD DGNSCD:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.sn_&x(keep=BID_HRS ADMSN_DT DRG_CD DGNSCD:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNS: ;

    do i=1 to dim (DxCodes);
      if DxCodes{i} in ('9672') then
        do;
          DATE=input(ADMSN_DT,yymmdd10.);
          VARIABLE_NAME='TRACHEOSTOMY';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;
    if DRG_CD in (483) then
      do;
        DATE=input(ADMSN_DT,yymmdd10.);
        VARIABLE_NAME='TRACHEOSTOMY';
        VARIABLE_VALUE=left(put(DRG_CD,3.));
        output;
      end;

  run;

%mend GetTRACH;

%GetTRACH()

/*******************************/
/*******************************/
/**                           **/
/**  Section  13.             **/
/**  Mechanical ventilation.  **/
/**                           **/
/*******************************/
/*******************************/
  
%macro GetMV();

  /**  DM data sets.  **/
  data MVFromDM(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.dm_1992(keep=BID_HRS FROM_DT DGNS_CD:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.dm_&x(keep=BID_HRS FROM_DT DGNS_CD:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNS: ;

    do i=1 to dim (DxCodes);
      if DxCodes{i} in ('9672') then
        do;
          DATE=input(FROM_DT,yymmdd10.);
          VARIABLE_NAME='MECHANICAL VENTILATION';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

  run;

  /**  HH data sets.  **/
  data MVFromHH(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.hh_1991(keep=BID_HRS FROM_DT DGNSCD:)
        CMSClms.hh_1992(keep=BID_HRS FROM_DT DGNSCD:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.hh_&x(keep=BID_HRS FROM_DT DGNSCD:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNS: ;

    do i=1 to dim (DxCodes);
      if DxCodes{i} in ('9672') then
        do;
          DATE=input(FROM_DT,yymmdd10.);
          VARIABLE_NAME='MECHANICAL VENTILATION';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

  run;

  /**  HS data sets.  **/
  data MVFromHS(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.hs_1991(keep=BID_HRS FROM_DT DGNSCD:)
        CMSClms.hs_1992(keep=BID_HRS FROM_DT DGNSCD:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.hs_&x(keep=BID_HRS FROM_DT DGNSCD:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNS: ;

    do i=1 to dim (DxCodes);
      if DxCodes{i} in ('9672') then
        do;
          DATE=input(FROM_DT,yymmdd10.);
          VARIABLE_NAME='MECHANICAL VENTILATION';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

  run;

  /**  IP data sets.  **/
  data MVFromIP(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.ip_1991(keep=BID_HRS ADMSN_DT DRG_CD DGNSCD:)
        CMSClms.ip_1992(keep=BID_HRS ADMSN_DT DRG_CD DGNSCD:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.ip_&x(keep=BID_HRS ADMSN_DT DRG_CD DGNSCD:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNS: ;

    do i=1 to dim (DxCodes);
      if DxCodes{i} in ('9672') then
        do;
          DATE=input(ADMSN_DT,yymmdd10.);
          VARIABLE_NAME='MECHANICAL VENTILATION';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

    if DRG_CD in (483,541,542) then
      do; 
        DATE=input(ADMSN_DT,yymmdd10.);
        VARIABLE_NAME='MECHANICAL VENTILATION';
        VARIABLE_VALUE=left(put(DRG_CD,3.));
        output;
      end;

  run;

  /**  MP data sets.  **/
  data MVFromMP(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.mp_1991(keep=BID_HRS ADMSNDT DGNS_CD: DRG_CD)
        CMSClms.mp_1992(keep=BID_HRS ADMSNDT DGNS_CD: DRG_CD)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.mp_&x(keep=BID_HRS ADMSNDT DGNS_CD: DRG_CD)
            %end;
          %end;
          ;

    array DxCodes{*} DGNS_CD: ;

    do i=1 to dim (DxCodes);
      if DxCodes{i} in ('9672') then
        do;
          DATE=input(ADMSNDT,yymmdd10.);
          VARIABLE_NAME='MECHANICAL VENTILATION';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;
    if DRG_CD in (483,541,542) then
      do;
        DATE=input(ADMSNDT,yymmdd10.);
        VARIABLE_NAME='MECHANICAL VENTILATION';
        VARIABLE_VALUE=left(put(DRG_CD,3.));
        output;
      end;

  run;

  /**  OP data sets.  **/
  data MVFromOP(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.op_1991(keep=BID_HRS FROM_DT DGNSCD:)
        CMSClms.op_1992(keep=BID_HRS FROM_DT DGNSCD:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.op_&x(keep=BID_HRS FROM_DT DGNSCD:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNSCD: ;

    do i=1 to dim (DxCodes);
      if DxCodes{i} in ('9672') then
        do;
          DATE=input(FROM_DT,yymmdd10.);
          VARIABLE_NAME='MECHANICAL VENTILATION';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

  run;

  /**  PB data sets.  **/
  data MVFromPB(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.pb_1991(keep=BID_HRS FROM_DT DGNS_CD:)
        CMSClms.pb_1992(keep=BID_HRS FROM_DT DGNS_CD:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.pb_&x(keep=BID_HRS FROM_DT DGNS_CD:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNS: ;

    do i=1 to dim (DxCodes);
      if DxCodes{i} in ('9672') then
        do;
          DATE=input(FROM_DT,yymmdd10.);
          VARIABLE_NAME='MECHANICAL VENTILATION';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

  run;

/**  SN data sets.  **/
  data MVFromSN(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.sn_1991(keep=BID_HRS ADMSN_DT DRG_CD DGNSCD:)
        CMSClms.sn_1992(keep=BID_HRS ADMSN_DT DRG_CD DGNSCD:)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.sn_&x(keep=BID_HRS ADMSN_DT DRG_CD DGNSCD:)
            %end;
          %end;
          ;

    array DxCodes{*} DGNS: ;

    do i=1 to dim (DxCodes);
      if DxCodes{i} in ('9672') then
        do;
          DATE=input(ADMSN_DT,yymmdd10.);
          VARIABLE_NAME='MECHANICAL VENTILATION';
          VARIABLE_VALUE=DxCodes{i};
          output;
        end;
    end;

    if DRG_CD in (483,541,542) then
      do;
        DATE=input(ADMSN_DT,yymmdd10.);
          VARIABLE_NAME='MECHANICAL VENTILATION';
          VARIABLE_VALUE=left(put(DRG_CD,3.));
          output;
      end;

  run;

%mend GetMV;

%GetMV()

/*******************************/
/*******************************/
/**                           **/
/**  Section  14.             **/
/**  denominator metrics.     **/
/**                           **/
/*******************************/
/*******************************/
  
%macro GetDenom();

  /**  DM data sets.  **/
  data Denom(keep=BID_HRS DATE VARIABLE_NAME VARIABLE_VALUE);

    attrib BID_HRS format=$9.;
    attrib DATE format=date9.;
    attrib VARIABLE_NAME format=$40.;
    attrib VARIABLE_VALUE format=$12.;
    set 
        CMSClms.dn_1991(keep=BID_HRS BUYIN12 BUYIN_MO RFRNC_YR)
        CMSClms.dn_1992(keep=BID_HRS BUYIN12 BUYIN_MO RFRNC_YR)
        %if &sysscp ne WIN %then
          %do;
            %do x=1993 %to 2008 %by 1;
              CMSClms.dn_&x(keep=BID_HRS BUYIN12 BUYIN_MO RFRNC_YR)
            %end;
          %end;
          ;

    DATE=mdy(1,1,RFRNC_YR);
    VARIABLE_NAME='MEDICARE ENTITLEMENT/BUY-IN INDICATOR';
    VARIABLE_VALUE=BUYIN12;
    output;

    DATE=mdy(1,1,RFRNC_YR);
    VARIABLE_NAME='TOTAL NUMBER OF MONTHS OF STATE BUY-IN';
    VARIABLE_VALUE=put(BUYIN_MO,best12.);
    output;

  run;

%mend GetDenom;

%GetDenom()

/*******************************/
/*******************************/
/**                           **/
/**  Section 15 .             **/
/**                           **/
/*******************************/
/*******************************/
  
data put.HOIs;
  set Hospice
      Medpar 
      Prof 
      SNF
      MoreMedPar

      ChemoFromDM
      ChemoFromHH
      ChemoFromHS
      ChemoFromIP
      ChemoFromMP
      ChemoFromOP
      ChemoFromPB
      ChemoFromSN

      ARFFromDM
      ARFFromHH
      ARFFromHS
      ARFFromIP
      ARFFromMP
      ARFFromOP
      ARFFromPB
      ARFFromSN

      RDFromDM
      RDFromHH
      RDFromHS
      RDFromIP
      RDFromMP
      RDFromOP
      RDFromPB
      RDFromSN

      AODFromDM
      AODFromHH
      AODFromHS
      AODFromIP
      AODFromMP
      AODFromOP
      AODFromPB
      AODFromSN

      SEPSISFromDM
      SEPSISFromHH
      SEPSISFromHS
      SEPSISFromIP
      SEPSISFromMP
      SEPSISFromOP
      SEPSISFromPB
      SEPSISFromSN

      TRACHFromDM
      TRACHFromHH
      TRACHFromHS
      TRACHFromIP
      TRACHFromMP
      TRACHFromOP
      TRACHFromPB
      TRACHFromSN

      MVFromDM
      MVFromHH
      MVFromHS
      MVFromIP
      MVFromMP
      MVFromOP
      MVFromPB
      MVFromSN

      DENOM
      ;
  run;

proc sort data=put.HOIs nodupkey;
  by BID_HRS DATE VARIABLE_NAME;
  run;

/*proc freq data=put.HOIs;
  tables VARIABLE_NAME;
  run; **/

/*******************************/
/*******************************/
/**                           **/
/**  Section 16 .             **/
/**                           **/
/*******************************/
/*******************************/

proc sort data=XWalk.hrscms2008 out=hrscms2008(rename=(BID_HRS_10=BID_HRS));
  by BID_HRS_10;
  run;

data put.HOIs(label="Created by &SASProgamName");
  merge hrscms2008(in=a)
        put.HOIS(in=b);
  by BID_HRS;
  if b;
  run;

/*data put.HOIs(drop=BID_HRS);
  format DummyID 8.;
  retain DummyID;
  set HOIs;
  by BID_HRS DATE VARIABLE_NAME;
  if _n_=1 then DummyID=0;
  if first.BID_HRS then DummyID+1;
  run;

PROC EXPORT DATA= WORK.HOIs 
            OUTFILE= "%sysfunc(pathname(CMSClms))\HOIs.xls" 
            DBMS=EXCEL REPLACE;
     SHEET="HOIs"; 
RUN; */

/*******************************/
/*******************************/
/**                           **/
/**  Section Last.            **/
/**                           **/
/*******************************/
/*******************************/

%timer(stop,GlobVarName=&ClientName.Time,banner=%str(Finished &SASProgramName))
