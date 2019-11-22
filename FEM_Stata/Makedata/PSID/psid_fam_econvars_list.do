
/*-------------------------------------
*DEFINE VARIABLE LISTS TO EXTRACT
-------------------------------------*/

*************************************
*FAMILY INTERVIEW (ID) NUMBER
*************************************

global famfidin 	  [99]ER13002 [01]ER17002 [03]ER21002 [05]ER25002 [07]ER36002 [09]ER42002 [11]ER47302 [13]ER53002 [15]ER60002

*************************************
*Labor income HEAD/WIFE
*************************************
/*
The income reported here was collected in 2009 about tax year 2008. 
It is the sum of several labor income components from the raw data, 
including, in addition to wages and salaries (ER46811), 
any separate reports of bonuses (ER46813), overtime (ER46815), tips (ER46817), 
commissions (ER46819), professional practice or trade (ER46821), 
market gardening (ER46823), additional job income (ER46825), 
and miscellaneous labor income (ER46827).
0 No labor income in 2008 
1 - 9,999,998 Actual amount 
9,999,999 $9,999,999 or more 
*/
global hdearninggenin [99]ER16463 [01]ER20443 [03]ER24116 [05]ER27931 [07]ER40921 [09]ER46829 [11]ER52237 [13]ER58038 [15]ER65216
global wfearninggenin [99]ER16465 [01]ER20447 [03]ER24135 [05]ER27943 [07]ER40933 [09]ER46841 [11]ER52249 [13]ER58050 [15]ER65244

*************************************
*Market Gardening Income - HEAD ONLY
* Eliminated in 2015 (?)
*************************************
global hdgardincgenin [99]ER16505 [01]ER20437 [03]ER24129 [05]ER27925 [07]ER40915 [09]ER46823 [11]ER52231 [13]ER58032

*************************************
*Labor portion of business income HEAD/WIFE
*************************************
/*
If total farm or business income represents a loss (i.e., a negative number), 
then the labor portion equals 0 and the loss is coded in the asset portion.

The income reported here is the labor part of Head's business income in 2008. 
Total business income of the Head is equally split between labor and asset income 
when the Head put in actual work hours in any unincorporated businesses. 
Information on who owns the business(es) and whether Head put in any work hours is 
collected in G9a-G9d. All missing data were assigned.
*/

global hdlaborbzgenin [99]ER16490 [01]ER20422 [03]ER24109 [05]ER27910 [07]ER40900 [09]ER46808 [11]ER52216 [13]ER58017 [15]ER65197
global wflaborbzgenin [99]ER16511 [01]ER20444 [03]ER24111 [05]ER27940 [07]ER40930 [09]ER46838 [11]ER52246 [13]ER58047 [15]ER65225

*************************************
*Asset portion of business income HEAD/WIFE
*************************************
global hdassetbzgenin [99]ER16491 [01]ER20423 [03]ER24110 [05]ER27911 [07]ER40901 [09]ER46809 [11]ER52217 [13]ER58018 [15]ER65198
global wfassetbzgenin [99]ER16512 [01]ER20445 [03]ER24112 [05]ER27941 [07]ER40931 [09]ER46839 [11]ER52247 [13]ER58048 [15]ER65226
 
*************************************
*FARM INCOME HEAD+WIFE
*************************************
global hdfarmincgenin [99]ER16448 [01]ER20420 [03]ER24105 [05]ER27908 [07]ER40898 [09]ER46806 [11]ER52214 [13]ER58015 [15]ER65195

*************************************
*HEAD AND WIFE TOTAL TAXABLE INCOME
*************************************
/*
The income reported here was collected in 2009 about tax year 2008. 
This variable can contain negative values, indicating a net loss from a business or farm. 
This variable includes Head's and Wife's/"Wife's" income from assets, earnings, 
and net profit from farm or business, that is, G4-G25d, G52, and G59a-G59d. All missing data are assigned. 
*/
global hdtaxincgenin [99]ER16452 [01]ER20449 [03]ER24100 [05]ER27953 [07]ER40943 [09]ER46851 [11]ER52259 [13]ER58060 [15]ER65253

*************************************
*HEAD AND WIFE TOTAL TRANSFER INCOME
*************************************
global hdtrsincgenin [99]ER16454 [01]ER20450 [03]ER24101 [05]ER28002 [07]ER40992 [09]ER46900 [11]ER52308 [13]ER58117 [15]ER65314

*************************************
*OTHER FU MEMBER TOTAL TAXABLE INCOME
*************************************
global hdottaxincgenin [99]ER16456 [01]ER20453 [03]ER24102 [05]ER28009 [07]ER40999 [09]ER46907 [11]ER52315 [13]ER58124 [15]ER65321
*************************************
*OTHER FU MEMBER TOTAL TRANSFER INCOME
*************************************
global hdottrsincgenin [99]ER16458 [01]ER20454 [03]ER24103 [05]ER28030 [07]ER41020 [09]ER46928 [11]ER52336 [13]ER58145 [15]ER65342

*************************************
*Supplemental Security Income (SSI) HEAD/WIFE (non-taxable)
*raw variables (whether, amount, unit, and which months received) are available since 1999, 
*but the generated variables for annual amount only available since 2005, same for other income components below
*************************************

**Whether HEAD/WIFE received any SSI
/*
*G25f. Did you (HEAD) receive any income in 1998 from Supplemental Security Income?
Value/Range  Text  
1 Yes 
5 No 
8 DK 
9 NA; refused 
0 Wild code 
*/
/*
G60. Did she receive any (other) income in 1998 from Supplemental Security Income, 
ADC/AFDC, child support or other welfare?--SSI
*/

global hdssianyin [99]ER14553 [01]ER18713 [03]ER22085 [05]ER26066 [07]ER37084 [09]ER43075 [11]ER48397 [13]ER54075 [15]ER61117
global wfssianyin [99]ER14849 [01]ER19029 [03]ER22402 [05]ER26383 [07]ER37401 [09]ER43392 [11]ER48717 [13]ER54412 [15]ER61488

**SSI AMOUNT-HEAD/WIFE
/*
G26f. How much was it?--AMOUNT
*/
/*
G60a. How much did she receive from Supplemental Security Income in 1998?
1 - 99,996 Actual amount 
99,997 $99,997 or more 
99,998 DK 
99,999 NA; refused 
0 Inap.: no wife/"wife" in FU; did not receive any income in 1998; no income from SSI in 1998 
*/
global hdssiamtin [99]ER14555 [01]ER18715 [03]ER22087 [05]ER26068 [07]ER37086 [09]ER43077 [11]ER48399 [13]ER54077 [15]ER61119
global wfssiamtin [99]ER14851 [01]ER19031 [03]ER22404 [05]ER26385 [07]ER37403 [09]ER43394 [11]ER48719 [13]ER54414 [15]ER61490
 
**SSI UNIT -HEAD/WIFE
/*
G26f. How much was it?--TIME UNIT
*/
/*
G60a. How much did she receive from Supplemental Security Income in 1998?--TIME UNIT
3 Week 
4 Two weeks 
5 Month 
6 Year 
7 Other 
8 DK 
9 NA; refused 
0 Inap.: no wife/"wife" in FU; did not receive any income in 1998; no income from SSI in 1998 
*/

global hdssiperin [99]ER14556 [01]ER18716 [03]ER22088 [05]ER26069 [07]ER37087 [09]ER43078 [11]ER48400 [13]ER54078 [15]ER61120
global wfssiperin [99]ER14852 [01]ER19032 [03]ER22405 [05]ER26386 [07]ER37404 [09]ER43395 [11]ER48720 [13]ER54415 [15]ER61491

**SSI WHETHER RECEIVED ANY IN JANUARY (naming numbers are continuous for Feb, March, etc) HEAD/WIFE
**For example, whether head received SSI in 1999 in Jan is ER14557, whether received in Feb is ER14558, March is ER14559, etc, variables for all months need to be extracted.
/*
G27f. During which months of 1998 did you get this income?--SSI IN JANUARY 1998
*/
/*
G60aa. During which months of 1998 did she get this income?--SSI IN JANUARY 1998
1 Was received this month 
9 NA; refused 
0 Inap.: no wife/"wife" in FU; did not receive income from SSI this month; did not receive income from SSI in 1998 
*/

global hdssijanin [99]ER14557 [01]ER18718 [03]ER22090 [05]ER26071 [07]ER37089 [09]ER43080 [11]ER48402 [13]ER54080 [15]ER61122
global wfssijanin [99]ER14853 [01]ER19034 [03]ER22407 [05]ER26388 [07]ER37406 [09]ER43397 [11]ER48722 [13]ER54417 [15]ER61493

**ANNULIZED AND IMPUTED VALUES GENERATED BY PSID
global hdssigenin [05]ER27956 [07]ER40946 [09]ER46854 [11]ER52262 [13]ER58063 [15]ER65256
global wfssigenin [05]ER27984 [07]ER40974 [09]ER46882 [11]ER52290 [13]ER58093 [15]ER65286

*************************************
*ADC/AFDC/TANF INCOME  HEAD/WIFE (non-taxable)
*************************************

**Whether HEAD/WIFE received any ADC/AFDC/TANF
global hdadcanyin [99]ER14538 [01]ER18697 [03]ER22069 [05]ER26050 [07]ER37068 [09]ER43059 [11]ER48381 [13]ER54059 [15]ER61101
global wfadcanyin [99]ER14865 [01]ER19046 [03]ER22419 [05]ER26400 [07]ER37418 [09]ER43409 [11]ER48734 [13]ER54429 [15]ER61505

**ADC AMOUNT HEAD/WIFE
global hdadcamtin [99]ER14539 [01]ER18698 [03]ER22070 [05]ER26051 [07]ER37069 [09]ER43060 [11]ER48382 [13]ER54060 [15]ER61102
global wfadcamtin [99]ER14866 [01]ER19047 [03]ER22420 [05]ER26401 [07]ER37419 [09]ER43410 [11]ER48735 [13]ER54430 [15]ER61506

**ADC UNIT HEAD/WIFE
global hdadcperin [99]ER14540 [01]ER18699 [03]ER22071 [05]ER26052 [07]ER37070 [09]ER43061 [11]ER48383 [13]ER54061 [15]ER61103
global wfadcperin [99]ER14867 [01]ER19048 [03]ER22421 [05]ER26402 [07]ER37420 [09]ER43411 [11]ER48736 [13]ER54431 [15]ER61507

**ADC RECEIVED IN JAN? HEAD/WIFE
global hdadcjanin [99]ER14541 [01]ER18701 [03]ER22073 [05]ER26054 [07]ER37072 [09]ER43063 [11]ER48385 [13]ER54063 [15]ER61105
global wfadcjanin [99]ER14868 [01]ER19050 [03]ER22423 [05]ER26404 [07]ER37422 [09]ER43413 [11]ER48738 [13]ER54433 [15]ER61509

**ANNULIZED AND IMPUTED VALUES GENERATED BY PSID
global hdadcgenin [05]ER27954 [07]ER40944 [09]ER46852 [11]ER52260 [13]ER58061 [15]ER65254
global wfadcgenin [05]ER27982 [07]ER40972 [09]ER46880 [11]ER52288 [13]ER58091 [15]ER65284

*************************************
*CHILD SUPPORT INCOME  HEAD/WIFE (non-taxable)
*************************************

**Whether HEAD/WIFE received any income from CHILD SUPPORT last year
global hdchdspanyin [99]ER14678 [01]ER18846 [03]ER22216 [05]ER26197 [07]ER37215 [09]ER43206 [11]ER48531 [13]ER54225 [15]ER61267
global wfchdspanyin [99]ER14880 [01]ER19062 [03]ER22435 [05]ER26416 [07]ER37434 [09]ER43425 [11]ER48750 [13]ER54445 [15]ER61521

**CHILD SUPPORT AMOUNT HEAD/WIFE
global hdchdspamtin [99]ER14679 [01]ER18847 [03]ER22217 [05]ER26198 [07]ER37216 [09]ER43207 [11]ER48532 [13]ER54226 [15]ER61268
global wfchdspamtin [99]ER14881 [01]ER19063 [03]ER22436 [05]ER26417 [07]ER37435 [09]ER43426 [11]ER48751 [13]ER54446 [15]ER61522

**CHILD SUPPORT UNIT HEAD/WIFE
global hdchdspperin [99]ER14680 [01]ER18848 [03]ER22218 [05]ER26199 [07]ER37217 [09]ER43208 [11]ER48533 [13]ER54227 [15]ER61269
global wfchdspperin [99]ER14882 [01]ER19064 [03]ER22437 [05]ER26418 [07]ER37436 [09]ER43427 [11]ER48752 [13]ER54447 [15]ER61523

**CHILD SUPPORT RECEIVED IN JAN? HEAD/WIFE
global hdchdspjanin [99]ER14681 [01]ER18850 [03]ER22220 [05]ER26201 [07]ER37219 [09]ER43210 [11]ER48535 [13]ER54229 [15]ER61271
global wfchdspjanin [99]ER14883 [01]ER19066 [03]ER22439 [05]ER26420 [07]ER37438 [09]ER43429 [11]ER48754 [13]ER54449 [15]ER61525

**ANNULIZED AND IMPUTED VALUES GENERATED BY PSID
global hdchdspgenin [05]ER27972 [07]ER40962 [09]ER46870 [11]ER52278 [13]ER58081 [15]ER65274
global wfchdspgenin [05]ER27994 [07]ER40984 [09]ER46892 [11]ER52300 [13]ER58109 [15]ER65304

*************************************
*OTHER WELFARE INCOME HEAD/WIFE (non-taxable)
*************************************

**OTHER WELFARE WHETHER ANY HEAD/WIFE
/*G25g. Did you (Head) receive any income in 1998 from other welfare?
*/
global hdwelfanyin [99]ER14569 [01]ER18730 [03]ER22102 [05]ER26083 [07]ER37101 [09]ER43092 [11]ER48414 [13]ER54092 [15]ER61134
global wfwelfanyin [99]ER14895 [01]ER19078 [03]ER22451 [05]ER26432 [07]ER37450 [09]ER43441 [11]ER48766 [13]ER54461 [15]ER61537

**OTHER WELFARE AMOUNT HEAD/WIFE
global hdwelfamtin [99]ER14570 [01]ER18731 [03]ER22103 [05]ER26084 [07]ER37102 [09]ER43093 [11]ER48415 [13]ER54093 [15]ER61135
global wfwelfamtin [99]ER14896 [01]ER19079 [03]ER22452 [05]ER26433 [07]ER37451 [09]ER43442 [11]ER48767 [13]ER54462 [15]ER61538

**OTHER WELFARE UNIT HEAD/WIFE
global hdwelfperin [99]ER14571 [01]ER18732 [03]ER22104 [05]ER26085 [07]ER37103 [09]ER43094 [11]ER48416 [13]ER54094 [15]ER61136
global wfwelfperin [99]ER14897 [01]ER19080 [03]ER22453 [05]ER26434 [07]ER37452 [09]ER43443 [11]ER48768 [13]ER54463 [15]ER61539

**OTHER WELFARE RECEIVED IN JAN? HEAD/WIFE
global hdwelfjanin [99]ER14572 [01]ER18734 [03]ER22106 [05]ER26087 [07]ER37105 [09]ER43096 [11]ER48418 [13]ER54096 [15]ER61138
global wfwelfjanin [99]ER14898 [01]ER19082 [03]ER22455 [05]ER26436 [07]ER37454 [09]ER43445 [11]ER48770 [13]ER54465 [15]ER61541

**ANNULIZED AND IMPUTED VALUES GENERATED BY PSID 
global hdwelfgenin [05]ER27958 [07]ER40948 [09]ER46856 [11]ER52264 [13]ER58065
global wfwelfgenin [05]ER27986 [07]ER40976 [09]ER46884 [11]ER52292 [13]ER58095

*************************************
*Value of food stamps last year for whole household, no generated annual variables
*************************************

*WHETHER
global hdfdstmpanyin [99]ER14255 [01]ER18386 [03]ER21652 [05]ER25654 [07]ER36672 [09]ER42691 [11]ER48007 [13]ER53704 [15]ER65258

*AMOUNT
global hdfdstmpamtin [99]ER14256 [01]ER18387 [03]ER21653 [05]ER25655 [07]ER36673 [09]ER42692 [11]ER48008 [13]ER53705 [15]ER60720

*UNIT
global hdfdstmpperin [99]ER14257 [01]ER18388 [03]ER21654 [05]ER25656 [07]ER36674 [09]ER42693 [11]ER48009 [13]ER53706 [15]ER60721

*RECEIVED IN JAN? 
global hdfdstmpjanin [99]ER14258 [01]ER18390 [03]ER21656 [05]ER25658 [07]ER36676 [09]ER42695 [11]ER48011 [13]ER53708 [15]ER60723

*************************************
*Unemployment compensation HEAD/WIFE (taxable)
*************************************
**WHETHER ANY UNEMPLOYMENT COMPENSATION HEAD/WIFE
/*
G44a. Did you (HEAD) receive any income in 1998 from unemployment compensation?
*/
global hdunempanyin [99]ER14648 [01]ER18814 [03]ER22184 [05]ER26165 [07]ER37183 [09]ER43174 [11]ER48499 [13]ER54193 [15]ER61235
global wfunempanyin [99]ER14759 [01]ER18933 [03]ER22303 [05]ER26284 [07]ER37302 [09]ER43293 [11]ER48618 [13]ER54312 [15]ER61388

*UNEMPLOYMENT COMPENSATION AMOUNT HEAD/WIFE
global hdunempamtin [99]ER14649 [01]ER18815 [03]ER22185 [05]ER26166 [07]ER37184 [09]ER43175 [11]ER48500 [13]ER54194 [15]ER61236
global wfunempamtin [99]ER14760 [01]ER18934 [03]ER22304 [05]ER26285 [07]ER37303 [09]ER43294 [11]ER48619 [13]ER54313 [15]ER61389

**UNEMPLOYMENT COMPENSATION UNIT HEAD/WIFE
global hdunempperin [99]ER14650 [01]ER18816 [03]ER22186 [05]ER26167 [07]ER37185 [09]ER43176 [11]ER48501 [13]ER54195 [15]ER61237
global wfunempperin [99]ER14761 [01]ER18935 [03]ER22305 [05]ER26286 [07]ER37304 [09]ER43295 [11]ER48620 [13]ER54314 [15]ER61390

**UNEMPLOYMENT COMPENSATION WHETHER RECEIVED IN JAN? HEAD/WIFE
global hdunempjanin [99]ER14651 [01]ER18818 [03]ER22188 [05]ER26169 [07]ER37187 [09]ER43178 [11]ER48503 [13]ER54197 [15]ER61239
global wfunempjanin [99]ER14762 [01]ER18937 [03]ER22307 [05]ER26288 [07]ER37306 [09]ER43297 [11]ER48622 [13]ER54316 [15]ER61392

**ANNULIZED AND IMPUTED VALUES GENERATED BY PSID
global hdunempgenin [05]ER27968 [07]ER40958 [09]ER46866 [11]ER52274 [13]ER58077 [15]ER65270
global wfunempgenin [05]ER27990 [07]ER40980 [09]ER46888 [11]ER52296 [13]ER58105 [15]ER65300

*************************************
*Workers' compensation HEAD/WIFE (non-taxable)
*************************************

**WHETHER ANY WORKERS COMP HEAD/WIFE
/*
G44b. Did you (HEAD) receive any income in 1998 from workers' compensation?
*/
global hdwkcmpanyin [99]ER14663 [01]ER18830 [03]ER22200 [05]ER26181 [07]ER37199 [09]ER43190 [11]ER48515 [13]ER54209 [15]ER61251
global wfwkcmpanyin [99]ER14774 [01]ER18949 [03]ER22319 [05]ER26300 [07]ER37318 [09]ER43309 [11]ER48634 [13]ER54328 [15]ER61404

**WORKERS' COMP AMOUNT HEAD/WIFE
global hdwkcmpamtin [99]ER14664 [01]ER18831 [03]ER22201 [05]ER26182 [07]ER37200 [09]ER43191 [11]ER48516 [13]ER54210 [15]ER61252
global wfwkcmpamtin [99]ER14775 [01]ER18950 [03]ER22320 [05]ER26301 [07]ER37319 [09]ER43310 [11]ER48635 [13]ER54329 [15]ER61405

**WORKERS' COMP UNIT HEAD/WIFE
global hdwkcmpperin [99]ER14665 [01]ER18832 [03]ER22202 [05]ER26183 [07]ER37201 [09]ER43192 [11]ER48517 [13]ER54211 [15]ER61253
global wfwkcmpperin [99]ER14776 [01]ER18951 [03]ER22321 [05]ER26302 [07]ER37320 [09]ER43311 [11]ER48636 [13]ER54330 [15]ER61406

**WORKERS' COMP RECEIVED IN JAN? HEAD/WIFE
global hdwkcmpjanin [99]ER14666 [01]ER18834 [03]ER22204 [05]ER26185 [07]ER37203 [09]ER43194 [11]ER48519 [13]ER54213 [15]ER61255
global wfwkcmpjanin [99]ER14777 [01]ER18953 [03]ER22323 [05]ER26304 [07]ER37322 [09]ER43313 [11]ER48638 [13]ER54332 [15]ER61408

**ANNULIZED AND IMPUTED VALUES GENERATED BY PSID
global hdwkcmpgenin [05]ER27970 [07]ER40960 [09]ER46868 [11]ER52276 [13]ER58079 [15]ER65272
global wfwkcmpgenin [05]ER27992 [07]ER40982 [09]ER46890 [11]ER52298 [13]ER58107 [15]ER65302

*************************************
*VA Pension only asked for HEAD (non-taxable)
*************************************
**VA pension ANY and type? 1st mention (2nd, 3rd mention only in 1999 and 2001)
/*
G37. Did you (HEAD) receive any income in 1998 from the Veteran's Administration for a servicemen's, 
(widow's) or survivor's pension, service disability, or the GI bill?--FIRST MENTION
1 Serviceman's 
2 Service disability 
3 GI Bill 
4 Other 
5 No 
8 DK 
9 NA; refused 
*/

global hdvapen1anyin [99]ER14585 [01]ER18747 [03]ER22119 [05]ER26100 [07]ER37118 [09]ER43109
global hdvapen2anyin [99]ER14586 [01]ER18748
global hdvapen3anyin [99]ER14587 [01]ER18749

/* For 2011, PSID moved to asking four questions about VA pension type:  Servicemen, Disability, GI Bill, Other */
global hdvapensvcmenin [11]ER48431 [13]ER54109 [15]ER61151
global hdvapendiin [11]ER48432 [13]ER54110 [15]ER61152
global hdvapengibillin [11]ER48433 [13]ER54111 [15]ER61153
global hdvapen [11]ER48434 [13]ER54112 [15]ER61154
   

**VA PENSION AMOUNT
global hdvapenamtin [99]ER14588 [01]ER18750 [03]ER22120 [05]ER26101 [07]ER37119 [09]ER43110 [11]ER48435 [13]ER54113 [15]ER61155

**VA PENSION UNIT
global hdvapenperin [99]ER14589 [01]ER18751 [03]ER22121 [05]ER26102 [07]ER37120 [09]ER43111 [11]ER48436 [13]ER54114 [15]ER61156

**VA PENSION RECEIVED IN JAN? 
global hdvapenjanin [99]ER14590 [01]ER18753 [03]ER22123 [05]ER26104 [07]ER37122 [09]ER43113 [11]ER48438 [13]ER54116 [15]ER61158

**ANNULIZED AND IMPUTED VALUES GENERATED BY PSID
global hdvapengenin [05]ER27960 [07]ER40950 [09]ER46858 [11]ER52266 [13]ER58067 [15]ER65260

*************************************
*ALIMONY only asked for HEAD (taxable)
*************************************
**WHETHER ANY?
/*
G44d. Did you (HEAD) receive any income in 1998 from alimony or separate maintenance?
*/
global hdalimanyin [99]ER14693 [01]ER18862 [03]ER22232 [05]ER26213 [07]ER37231 [09]ER43222 [11]ER48547 [13]ER54241 [15]ER61283

**ALIMONY AMOUNT
global hdalimamtin [99]ER14694 [01]ER18863 [03]ER22233 [05]ER26214 [07]ER37232 [09]ER43223 [11]ER48548 [13]ER54242 [15]ER61284

**ALIMONY UNIT 
global hdalimperin [99]ER14695 [01]ER18864 [03]ER22234 [05]ER26215 [07]ER37233 [09]ER43224 [11]ER48549 [13]ER54243 [15]ER61285

** ALIMONY RECEIVED IN JAN?
global hdalimjanin [99]ER14696 [01]ER18866 [03]ER22236 [05]ER26217 [07]ER37235 [09]ER43226 [11]ER48551 [13]ER54245 [15]ER61287

**ANNULIZED AND IMPUTED VALUES GENERATED BY PSID
global hdalimgenin [05]ER27974 [07]ER40964 [09]ER46872 [11]ER52280 [13]ER58083 [15]ER65276

*************************************
*HEAD OTHER RETIREMENT INCOME - amount of pension, annuity or IRAs, and other retirement income asked separately (partially taxable,depending on type)
*************************************
**WHETHER ANY OTHER RETIREMENT INCOME HEAD
/*
G40. Did you (HEAD) receive any income in 1998 from other retirement pay, pensions, or annuities? [CHECK ALL THAT APPLY.]
.01 - 999,996.99 Actual amount 
999,997.00 $999,997 or more 
999,998.00 DK 
999,999.00 NA; refused 
00 Inap.: did not receive other non-VA retirement pay or pensions in 1998 
*/
global hdothretanyin [99]ER14602 [01]ER18765 [03]ER22135 [05]ER26116 [07]ER37134 [09]ER43125 [11]ER48450 [13]ER54128 [15]ER61170

*--------------------

**AMOUNT OTHER RETIREMENT INCOME (non-ss pension) HEAD
global hdothpenamtin [99]ER14603 [01]ER18766 [03]ER22136 [05]ER26117 [07]ER37135 [09]ER43126 [11]ER48451 [13]ER54129 [15]ER61171

**UNIT OTHER RETIREMENT INCOME (non-ss pension) HEAD
global hdothpenperin [99]ER14604 [01]ER18767 [03]ER22137 [05]ER26118 [07]ER37136 [09]ER43127 [11]ER48452 [13]ER54130 [15]ER61172

**WHETHER ANY OTHER RETIREMENT INCOME in JAN? (non-ss pension) HEAD
global hdothpenjanin [99]ER14605 [01]ER18769 [03]ER22139 [05]ER26120 [07]ER37138 [09]ER43129 [11]ER48454 [13]ER54132 [15]ER61174

**ANNULIZED AND IMPUTED VALUES GENERATED BY PSID
global hdothpengenin [05]ER27962 [07]ER40952 [09]ER46860 [11]ER52268 [13]ER58069 [15]ER65262
*--------------------

**AMOUNT OTHER RETIREMENT INCOME (annuity) HEAD
global hdannuiamtin [99]ER14618 [01]ER18782 [03]ER22152 [05]ER26133 [07]ER37151 [09]ER43142 [11]ER48467 [13]ER54145 [15]ER61187

**UNIT OTHER RETIREMENT INCOME (annuity) HEAD
global hdannuiperin [99]ER14619 [01]ER18783 [03]ER22153 [05]ER26134 [07]ER37152 [09]ER43143 [11]ER48468 [13]ER54146 [15]ER61188

**WHETHER OTHER RETIREMENT INCOME (annuity) in JAN? HEAD
global hdannuijanin [99]ER14620 [01]ER18785 [03]ER22155 [05]ER26136 [07]ER37154 [09]ER43145 [11]ER48470 [13]ER54148 [15]ER61190

**ANNULIZED AND IMPUTED VALUES GENERATED BY PSID
global hdannuigenin [05]ER27964 [07]ER40954 [09]ER46862 [11]ER52270 [13]ER58073 [15]ER65266
*--------------------

**AMOUNT OTHER RETIREMENT INCOME (non SS,retirement in addition to VA, pensions, annuities and IRAs)HEAD
global hdretunkamtin [99]ER14633 [01]ER18798 [03]ER22168 [05]ER26149 [07]ER37167 [09]ER43158 [11]ER48483 [13]ER54161 [15]ER61203

**UNIT OTHER RETIREMENT INCOME (non SS,retirement in addition to VA, pensions, annuities and IRAs)HEAD
global hdretunkperin [99]ER14634 [01]ER18799 [03]ER22169 [05]ER26150 [07]ER37168 [09]ER43159 [11]ER48484 [13]ER54162 [15]ER61204

**WHETHER OTHER RETIREMENT INCOME in JAN? (non SS,retirement in addition to VA, pensions, annuities and IRAs)HEAD
global hdretunkjanin [99]ER14635 [01]ER18801 [03]ER22171 [05]ER26152 [07]ER37170 [09]ER43161 [11]ER48486 [13]ER54164 [15]ER61206

**ANNULIZED AND IMPUTED VALUES GENERATED BY PSID
global hdretunkgenin [05]ER27966 [07]ER40956 [09]ER46864 [11]ER52272 [13]ER58075 [15]ER65268
*--------------------

*************************************
*WIFE OTHER RETIREMENT INCOME
*************************************
**WHETHER ANY OTHER RETIREMENT INCOME WIFE
/*
G61. Did she receive any (other) income in 1998 from pensions or annuities?
*/
global wfothretanyin [99]ER14910 [01]ER19094 [03]ER22467 [05]ER26448 [07]ER37466 [09]ER43457 [11]ER48782 

**AMOUNT OTHER RETIREMENT INCOME WIFE
/*
.01 - 99,996.99 Actual amount 
99,997.00 $99,997 or more 
99,998.00 DK 
99,999.00 NA; refused 
.00 Inap.: no wife/"wife" in FU; did not receive any income in 1998; did not receive any income from pensions or annuities in 1998 
*/
global wfothretamtin [99]ER14911 [01]ER19095 [03]ER22468 [05]ER26449 [07]ER37467 [09]ER43458 [11]ER48783

**UNIT OTHER RETIREMENT INCOME WIFE
global wfothretperin [99]ER14912 [01]ER19096 [03]ER22469 [05]ER26450 [07]ER37468 [09]ER43459 [11]ER48784

**WHETHER OTHER RETIREMENT INCOME IN JAN? WIFE
global wfothretjanin [99]ER14913 [01]ER19098 [03]ER22471 [05]ER26452 [07]ER37470 [09]ER43461 [11]ER48786

**ANNULIZED AND IMPUTED VALUES GENERATED BY PSID
global wfothretgenin [05]ER27988 [07]ER40978 [09]ER46886 [11]ER52294

*************************************
*HELP FROM RELATIVES HEAD/WIFE (most likely non-taxable)
*************************************
**WHETHER
/*
G44e. Did you (HEAD) receive any help in 1998 from relatives?
*/
global hdhlprelanyin [99]ER14708 [01]ER18878 [03]ER22248 [05]ER26229 [07]ER37247 [09]ER43238 [11]ER48563 [13]ER54257 [15]ER61299
global wfhlprelanyin [99]ER14925 [01]ER19110 [03]ER22483 [05]ER26464 [07]ER37482 [09]ER43473 [11]ER48798 [13]ER54541 [15]ER61652

*AMOUNT
global hdhlprelamtin [99]ER14709 [01]ER18879 [03]ER22249 [05]ER26230 [07]ER37248 [09]ER43239 [11]ER48564 [13]ER54258 [15]ER61300
global wfhlprelamtin [99]ER14926 [01]ER19111 [03]ER22484 [05]ER26465 [07]ER37483 [09]ER43474 [11]ER48799 [13]ER54542 [15]ER61653
 
*UNIT
global hdhlprelperin [99]ER14710 [01]ER18880 [03]ER22250 [05]ER26231 [07]ER37249 [09]ER43240 [11]ER48565 [13]ER54259 [15]ER61301
global wfhlprelperin [99]ER14927 [01]ER19112 [03]ER22485 [05]ER26466 [07]ER37484 [09]ER43475 [11]ER48800 [13]ER54543 [15]ER61654

*WHETHER RECEIVED IN JAN? 
global hdhlpreljanin [99]ER14711 [01]ER18882 [03]ER22252 [05]ER26233 [07]ER37251 [09]ER43242 [11]ER48567 [13]ER54261 [15]ER61303
global wfhlpreljanin [99]ER14928 [01]ER19114 [03]ER22487 [05]ER26468 [07]ER37486 [09]ER43477 [11]ER48802 [13]ER54545 [15]ER61656

**ANNULIZED AND IMPUTED VALUES GENERATED BY PSID
global hdhlprelgenin [05]ER27976 [07]ER40966 [09]ER46874 [11]ER52282 [13]ER58085 [15]ER65278
global wfhlprelgenin [05]ER27996 [07]ER40986 [09]ER46894 [11]ER52302 [13]ER58111 [15]ER65308

*************************************
*HELP FROM OTHERS/NON-RELATIVES HEAD/WIFE (most likely non-taxable)
*************************************
**WHETHER

global hdhlpfrdanyin [99]ER14723 [01]ER18894 [03]ER22264 [05]ER26245 [07]ER37263 [09]ER43254 [11]ER48579 [13]ER54273 [15]ER61315
global wfhlpfrdanyin [99]ER14940 [01]ER19126 [03]ER22499 [05]ER26480 [07]ER37498 [09]ER43489 [11]ER48814 [13]ER54557 [15]ER61668

*AMOUNT
global hdhlpfrdamtin [99]ER14724 [01]ER18895 [03]ER22265 [05]ER26246 [07]ER37264 [09]ER43255 [11]ER48580 [13]ER54274 [15]ER61316
global wfhlpfrdamtin [99]ER14941 [01]ER19127 [03]ER22500 [05]ER26481 [07]ER37499 [09]ER43490 [11]ER48815 [13]ER54558 [15]ER61669

*UNIT
global hdhlpfrdperin [99]ER14725 [01]ER18896 [03]ER22266 [05]ER26247 [07]ER37265 [09]ER43256 [11]ER48581 [13]ER54275 [15]ER61317
global wfhlpfrdperin [99]ER14942 [01]ER19128 [03]ER22501 [05]ER26482 [07]ER37500 [09]ER43491 [11]ER48816 [13]ER54559 [15]ER61670

*WHETHR RECEIVED IN JAN? 
global hdhlpfrdjanin [99]ER14726 [01]ER18898 [03]ER22268 [05]ER26249 [07]ER37267 [09]ER43258 [11]ER48583 [13]ER54277 [15]ER61319
global wfhlpfrdjanin [99]ER14943 [01]ER19130 [03]ER22503 [05]ER26484 [07]ER37502 [09]ER43493 [11]ER48818 [13]ER54561 [15]ER61672

**ANNULIZED AND IMPUTED VALUES GENERATED BY PSID
global hdhlpfrdgenin [05]ER27978 [07]ER40968 [09]ER46876 [11]ER52284 [13]ER58087 [15]ER65280
global wfhlpfrdgenin [05]ER27998 [07]ER40988 [09]ER46896 [11]ER52304 [13]ER58113 [15]ER65310

*************************************
*OTHER MISC TRANSFER INCOME (most likely non-taxable)
*************************************

*WHETHER -HEAD
/*
G44g. Did (you/he) receive any other income in 2004 from anything else?
*/

global hdothtranyin [99]ER14738 [01]ER18910 [03]ER22280 [05]ER26261 [07]ER37279 [09]ER43270 [11]ER48595 [13]ER54289 [15]ER61331
global wfothtranyin [99]ER14955 [01]ER19142 [03]ER22515 [05]ER26496 [07]ER37514 [09]ER43505 [11]ER48830 [13]ER54573 [15]ER61684

*AMOUNT
global hdothtramtin [99]ER14739 [01]ER18911 [03]ER22281 [05]ER26262 [07]ER37280 [09]ER43271 [11]ER48596 [13]ER54290 [15]ER61332
global wfothtramtin [99]ER14956 [01]ER19143 [03]ER22516 [05]ER26497 [07]ER37515 [09]ER43506 [11]ER48831 [13]ER54574 [15]ER61685

*UNIT
global hdothtrperin [99]ER14740 [01]ER18912 [03]ER22282 [05]ER26263 [07]ER37281 [09]ER43272 [11]ER48597 [13]ER54291 [15]ER61333
global wfothtrperin [99]ER14957 [01]ER19144 [03]ER22517 [05]ER26498 [07]ER37516 [09]ER43507 [11]ER48832 [13]ER54575 [15]ER61686

*WHETHER RECEIVED IN JAN?
global hdothtrjanin [99]ER14741 [01]ER18914 [03]ER22284 [05]ER26265 [07]ER37283 [09]ER43274 [11]ER48599 [13]ER54293 [15]ER61335
global wfothtrjanin [99]ER14958 [01]ER19146 [03]ER22519 [05]ER26500 [07]ER37518 [09]ER43509 [11]ER48834 [13]ER54577 [15]ER61688

**ANNULIZED AND IMPUTED VALUES GENERATED BY PSID
global hdothtrgenin [05]ER27980 [07]ER40970 [09]ER46878 [11]ER52286 [13]ER58089 [15]ER65282
global wfothtrgenin [05]ER28000 [07]ER40990 [09]ER46898 [11]ER52306 [13]ER58115 [15]ER65312

*************************************
*LUMP-SUM PAYMENTS FOR INSURANCE OR INHERITANCE FOR THE HOUSEHOLD, ONLY HEAD ASKED
*************************************
*Receive any: Did (you/HEAD) (or anyone else in the family living there) get any other money in 2008--like a big settlement from an insurance company, or an inheritance?
global hdlumpincanyin [99]ER14970 [01]ER19158 [03]ER22531 [05]ER26512 [07]ER37530 [09]ER43521 [11]ER48846 [13]ER54589 [15]ER61700
*Amount - top coded at 9,999,997
global hdlumpincamtin [99]ER14971 [01]ER19159 [03]ER22532 [05]ER26513 [07]ER37531 [09]ER43522 [11]ER48847 [13]ER54590 [15]ER61701

*************************************
*HH wealth, only included in family file in 2009+ (on separate file from PSID in earlier years: [99]S417 [01]S517 [03]S617 [05]S717 [07]S817 )
*************************************
global hdhatotain [09]ER46970 [11]ER52394 [13]ER58211 [15]ER65408

*************************************
*Employment status
*************************************
global hdempstat1stin [99]ER13205 [01]ER17216 [03]ER21123 [05]ER25104 [07]ER36109 [09]ER42140 [11]ER47448 [13]ER53148 [15]ER60163
global hdempstat2ndin [99]ER13206 [01]ER17217 [03]ER21124 [05]ER25105 [07]ER36110 [09]ER42141 [11]ER47449 [13]ER53149 [15]ER60164
global hdempstat3rdin [99]ER13207 [01]ER17218 [03]ER21125 [05]ER25106 [07]ER36111 [09]ER42142 [11]ER47450 [13]ER53150 [15]ER60165

global hdwkfrmoneyin  [99]ER13209 [01]ER17220             [05]ER25108 [07]ER36113 [09]ER42144 [11]ER47452 [13]ER53152 [15]ER60167
global hdeverwkin 	 [99]ER13476 [01]ER17515 [03]ER21357 [05]ER25346 [07]ER36351 [09]ER42376 [11]ER47689 [13]ER53389 [15]ER60404

global wfempstat1stin [99]ER13717 [01]ER17786 [03]ER21373 [05]ER25362 [07]ER36367 [09]ER42392 [11]ER47705 [13]ER53411 [15]ER60426
global wfempstat2ndin [99]ER13718 [01]ER17787 [03]ER21374 [05]ER25363 [07]ER36368 [09]ER42393 [11]ER47706 [13]ER53412 [15]ER60427
global wfempstat3rdin [99]ER13719 [01]ER17788 [03]ER21375 [05]ER25364 [07]ER36369 [09]ER42394 [11]ER47707 [13]ER53413 [15]ER60428

global wfwkfrmoneyin  [99]ER13721 [01]ER17790              [05]ER25366 [07]ER36371 [09]ER42396 [11]ER47709 [13]ER53415 [15]ER60430
global wfeverwkin 	  [99]ER13988 [01]ER18086 [03]ER21607 [05]ER25604 [07]ER36609 [09]ER42628 [11]ER47946 [13]ER53652 [15]ER60667
 

*************************************
*Social security income (available since year 2005)
*************************************
global hdssincgenin [05]ER28031 [07]ER41021 [09]ER46929 [11]ER52337 [13]ER58146 [15]ER65343
global wfssincgenin [05]ER28033 [07]ER41023 [09]ER46931 [11]ER52339 [13]ER58148 [15]ER65345


*************************************
*Pension coverage for current job
*************************************

*YEARS WORKING ON CURRENT JOB (if working for someone else) (valid value 1-65)
global hdcjtenin [99]ER13243 [01]ER17254 [03]ER21171 [05]ER25160 [07]ER36165 [09]ER42200 [11]ER47513 [13]ER53213 [15]ER60228
global wfcjtenin [99]ER13755 [01]ER17824 [03]ER21421 [05]ER25418 [07]ER36423 [09]ER42452 [11]ER47770 [13]ER53476 [15]ER60491

*Main job indicator - only available since year 2003
/*
1 Current main job 
2 Most recent main job 
3 Not employed in past two years
*/
global hdmjindin [03]ER21128 [05]ER25110 [07]ER36115 [09]ER42150 [11]ER47462 [13]ER53162 [15]ER60177
global wfmjindin [03]ER21378 [05]ER25368 [07]ER36373 [09]ER42402 [11]ER47719 [13]ER53425 [15]ER60440

*STARTING YEAR OF CURRENT MAIN JOB OR MOST RECENT JOB - only available since year 2003
global hdmjbyrin [03]ER21130 [05]ER25112 [07]ER36117 [09]ER42152 [11]ER47464 [13]ER53164 [15]ER60179
global wfmjbyrin [03]ER21380 [05]ER25370 [07]ER36375 [09]ER42404 [11]ER47721 [13]ER53427 [15]ER60442

*Head any pension plan at current job
/*
1 Yes 
5 No 
8 DK 
9 NA; refused 
0 Inap.: has never worked for money; not currently employed 
*/
global hdanypenin [99]ER15156 [01]ER19327 [03]ER22722 [05]ER26703 [07]ER37739 [09]ER43712 [11]ER49057 [13]ER54813 [15]ER61933
global wfanypenin [99]ER15302 [01]ER19470 [03]ER22866 [05]ER26847 [07]ER37971 [09]ER43944 [11]ER49276 [13]ER55029 [15]ER62150

*Head type of pension plan at current job
/*
1 Defined benefit formula 
3 Both 
5 Money accumulated in account 
8 DK 
9 NA; refused 
0 Inap.: has never worked for money; not currently employed; not covered by pension or retirement plan on current job and will not be; DK, NA, or RF whether covered by pension/retirement plan on current job 
*/
global hdpentpin  [99]ER15175 [01]ER19343 [03]ER22738 [05]ER26719 [07]ER37755 [09]ER43728 [11]ER49074 [13]ER54828 [15]ER61948
global wfpentpin  [99]ER15321 [01]ER19486 [03]ER22882 [05]ER26863 [07]ER37987 [09]ER43960 [11]ER49293 [13]ER55044 [15]ER62165


*Head/Wife years on current pension plan (valid value 1-65)
global hdpenyrin [99]ER15160 [01]ER19328 [03]ER22723 [05]ER26704 [07]ER37740 [09]ER43713 [11]ER49059 [13]ER54815 [15]ER61935
global wfpenyrin [99]ER15306 [01]ER19471 [03]ER22867 [05]ER26848 [07]ER37972 [09]ER43945 [11]ER49278 [13]ER55031 [15]ER62152

*Head/Wife years first year joining current pension plan (valid value 1901 - 2010)
global hdpenftin [99]ER15161 [01]ER19329 [03]ER22724 [05]ER26705 [07]ER37741 [09]ER43714 [11]ER49060 [13]ER54816 [15]ER61936
global wfpenftin [99]ER15307 [01]ER19472 [03]ER22868 [05]ER26849 [07]ER37973 [09]ER43946 [11]ER49279 [13]ER55032 [15]ER62153

*DB PENSION OR DB/DC COMBO - NORMAL RETIREMENT AGE OR YEARS OF SERVICE ---- BEGIN

*Current DB pension Benefit formula for full benefit
/*
1 Age 
2 Years 
3 Combination 
7 Other 
8 DK 
9 NA; refused 
0 Inap.: has never worked for money; not currently employed; not covered by pension or retirement plan on current job and will not be; NA, DK whether covered by pension/retirement plan on current job; pension based only on money accumulated in account; NA, DK whether defined benefit formula, money accumulated or accrued, or both 
*/
global hdnrafmlin [99]ER15187 [01]ER19355 [03]ER22750 [05]ER26731 [07]ER37771 [09]ER43744
global wfnrafmlin [99]ER15333 [01]ER19498 [03]ER22894 [05]ER26875 [07]ER38003 [09]ER43976

*Age for current DB pension receive full benefits if based on age only (valid 31-100)
global hdnra1agein [99]ER15188 [01]ER19356 [03]ER22751 [05]ER26732 [07]ER37772 [09]ER43745
global wfnra1agein [99]ER15334 [01]ER19499 [03]ER22895 [05]ER26876 [07]ER38004 [09]ER43977

*Year of service for current DB plen full benefits if based on year only (valid 1-50)
global hdnra1yrin [99]ER15189 [01]ER19357 [03]ER22752 [05]ER26733 [07]ER37773 [09]ER43746
global wfnra1yrin [99]ER15335 [01]ER19500 [03]ER22896 [05]ER26877 [07]ER38005 [09]ER43978

*Age for current DB pension receive full benefits if based on age and service (valid 31-100)
global hdnra2agein [99]ER15190 [01]ER19358 [03]ER22753 [05]ER26734 [07]ER37774 [09]ER43747
global wfnra2agein [99]ER15336 [01]ER19501 [03]ER22897 [05]ER26878 [07]ER38006 [09]ER43979

*Year of service for current DB plen full benefits if based on year and service (valid 1-50)
global hdnra2yrin [99]ER15191 [01]ER19359 [03]ER22754 [05]ER26735 [07]ER37775 [09]ER43748
global wfnra2yrin [99]ER15337 [01]ER19502 [03]ER22898 [05]ER26879 [07]ER38007 [09]ER43980
*NORMAL RETIREMENT AGE OR YEARS OF SERVICE ---- END

*WHETHER EARLY RETIREMENT AGE
global hdanyerain [99]ER15192 [01]ER19360 [03]ER22755 [05]ER26736 [07]ER37776 [09]ER43749
global wfanyerain [99]ER15338 [01]ER19503 [03]ER22899 [05]ER26880 [07]ER38008 [09]ER43981

/* They changed the variables in 2011.  It seems to focus on age only, not years of service.
P22 CKPT: TYPE PENSION - HD  [11]ER49086
P22A AGE ELIGIBLE FOR FULL PNSN (YRS)-HD [11]ER49087
P22B AGE ELIGIBLE FOR FULL PNSN (MOS)-HD [11]ER49088
P22C AGE ELIGIBLE FOR ANY PNSN (YRS)-HD [11]ER49089
P22D AGE ELIGIBLE FOR ANY PNSN (MOS)-HD [11]ER49090

P22 CKPT: TYPE PENSION - WF [11]ER49305
P22A AGE ELIGIBLE FOR FULL PNSN (YRS)-WF [11]ER49306
P22B AGE ELIGIBLE FOR FULL PNSN (MOS)-WF [11]ER49307
P22C AGE ELIGIBLE FOR ANY PNSN (YRS)-WF [11]ER49308
P22D AGE ELIGIBLE FOR ANY PNSN (MOS)-WF [11]ER49309
*/



* Age for full benefits

*DB PENSION OR DB/DC COMBO - EARLY RETIREMENT AGE OR YEARS OF SERVICE ---- BEGIN

*Current DB pension Benefit formula for partial benefit
/*
1 Age 
2 Years 
3 Combination 
7 Other 
8 DK 
9 NA; refused 
0 Inap.: has never worked for money; not currently employed; not covered by pension or retirement plan on current job and will not be; NA, DK whether covered by pension/retirement plan on current job; pension based only on money accumulated in account; NA, DK whether defined benefit formula, money accumulated or accrued, or both 
*/
global hderafmlin  [99]ER15193 [01]ER19361 [03]ER22756 [05]ER26737 [07]ER37777 [09]ER43744
global wferafmlin  [99]ER15339 [01]ER19504 [03]ER22900 [05]ER26881 [07]ER38009 [09]ER43982

*Age for current DB pension receive partial benefits if based on age only (valid 31-100)
global hdera1agein [99]ER15194 [01]ER19362 [03]ER22757 [05]ER26738 [07]ER37778 [09]ER43751
global wfera1agein [99]ER15340 [01]ER19505 [03]ER22901 [05]ER26882 [07]ER38010 [09]ER43983

*Year of service for current DB plen partial benefits if based on year only (valid 1-50)
global hdera1yrin [99]ER15195 [01]ER19363 [03]ER22758 [05]ER26739 [07]ER37779 [09]ER43752
global wfera1yrin [99]ER15341 [01]ER19506 [03]ER22902 [05]ER26883 [07]ER38011 [09]ER43984

*Age for current DB pension receive partial benefits if based on age and service (valid 31-100)
global hdera2agein [99]ER15196 [01]ER19364 [03]ER22759 [05]ER26740 [07]ER37780 [09]ER43753
global wfera2agein [99]ER15342 [01]ER19507 [03]ER22903 [05]ER26884 [07]ER38012 [09]ER43985

*Year of service for current DB plen partial benefits if based on year and service (valid 1-50)
global hdera2yrin [99]ER15197 [01]ER19365 [03]ER22760 [05]ER26741 [07]ER37781 [09]ER43754
global wfera2yrin [99]ER15343 [01]ER19508 [03]ER22904 [05]ER26885 [07]ER38013 [09]ER43986

*DB PENSION OR DB/DC COMBO - EARLY RETIREMENT AGE OR YEARS OF SERVICE ---- END



/* Total family income 

2009 (as an example)
The income reported here was collected in 2009 about tax year 2008. Please note that this variable can contain negative values. Negative values indicate a net loss, which in waves prior to 1994 were bottom-coded at $1, as were zero amounts. These losses occur as a result of business or farm losses. 

This variable is the sum of these seven variables:

ER46851 Head and Wife/"Wife" Taxable Income-2008
ER46900 Head and Wife/"Wife" Transfer Income-2008
ER46907 Taxable Income of Other FU Members-2008
ER46928 Transfer Income of OFUMS-2008
ER46929 Head Social Security Income-2008
ER46931 Wife/"Wife" Social Security Income-2008
ER46933 OFUM Social Security Income-2008
*/

global hdtotalfamincin [99]ER16462 [01]ER20456 [03]ER24099 [05]ER28037 [07]ER41027 [09]ER46935 [11]ER52343 [13]ER58152 [15]ER65349

