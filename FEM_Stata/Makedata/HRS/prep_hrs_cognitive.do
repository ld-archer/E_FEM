/** \file
*************************************
* Process the HRS Cognitive Measures (TICS score and IQCODE)
* outputs tics.dta which is merged in later by hrs_select.do
*************************************
*/
display "*** prep_hrs_cognitive.do ***"

  include common.do


**********
** TICS SCORE - FOR THOSE AGED 65 AND OLDER
** SEE PAGE 17 OF 
**"Documentation of Cognitive Functioning Measures in the Health and Retirement Study"
** HRS Documentation Report DR-006, March, 2005
** USE RAND HRS Version K which has the imputed cognition variables
** Weihanch - The impuated cognition variables are now updated to 2010, update to RAND HRS Version M
** variables used for cog stat - r*tr20, r*ser7, r*bwc20 r*iadlza r*slfmem D501
***********

use $rand_hrs, clear
keep hhidpn hacohort inw* r*wtresp r*proxy r*iadlza r*bwc20 r*fbwc20 r*fimrc r*fdlrc r*tr20 r*fser7 r*ser7 r*atr20 r*slfmem

ren r2atr20 r2tr20
drop r1proxy r1wtresp inw1 r1fimrc r1fdlrc

* RESHAPE
#d ;
foreach var in wtresp proxy iadlza bwc20 tr20 ser7 fbwc20 fimrc fdlrc fser7 slfmem { ; 
			forvalues i = 1(1)11{ ; 
				cap confirm var r`i'`var'; 
				if !_rc{;
					ren r`i'`var' `var'`i' ; 
				};
			} ; 
	} ; 
	#d cr 	


reshape long inw wtresp proxy iadlza bwc20 tr20 ser7 fbwc20 fimrc fdlrc fser7 slfmem, i(hhidpn hacohort) j(wave)

* Generate the self-rating memory
recode slfmem (1 2 3 = 1 "Exc/VG/Good") (4 = 2 "Fair") (5 = 3 "Poor") (.c .s .x = .), generate(selfmem)
tab slfmem selfmem
drop slfmem

* besides using the imputed variables, make a version that is missing if >2 measures were imputed

gen totcog = bwc20 + ser7 + tr20 if inw==1 
gen totcog_imp = fimrc + fdlrc + fser7 + fbwc20

* version with totcog set to missing if mor than 2 measures were imputed.
gen totcogA = totcog
replace totcogA = . if totcog_imp > 2

sum totcog if proxy==0 & inw==1
sum totcog if proxy==1 & inw==1

sum totcogA if proxy==0 & inw==1
sum totcogA if proxy==1 & inw==1

sort hhidpn wave
save "$outdata/tics_imputed.dta", replace

clear

* USE DATA FROM 1995-2006
* weihanch - update to 2010

* List of years for each file 
global yrlist 93 95 96 98 00 02 04 06 08 10 12

* List of files 
global filelist ad93f2a ad95f2a h96f4a hd98f2b h00f1c h02f2b h04f1a h06f2a h08f1b hrs10 hrs12

* List of waves for each file
global wavelist 2 3 3 4 5 6 7 8 9 10 11

* List of the variables for proxy memory assessment
global proxy_memvars b323 d1056 e1056 f1373 g1527 hd501 jd501 kd501 ld501 MD501 nd501

* List of the variables for interviewer assesment of cognitive limitations
global inter_cogvars none none none none g517 ha011 ja011 ka011 la011 MA011 na011

/* Jorm IQCODE Scoring */
* For each wave, we create a list of variables

* 1993 variables
global base95   d1072 d1077 d1082 d1087 d1092 d1097 d1102 d1107 d1112 d1117 d1122 d1127 d1132 d1135 d1138 d1141
global better95 d1073 d1078 d1083 d1088 d1093 d1098 d1103 d1108 d1113 d1118 d1123 d1128 d1133 d1136 d1139 d1142
global worse95  d1074 d1079 d1084 d1089 d1094 d1099 d1104 d1109 d1114 d1119 d1124 d1129 d1134 d1137 d1140 d1143

* 1995 variables
global base95   d1072 d1077 d1082 d1087 d1092 d1097 d1102 d1107 d1112 d1117 d1122 d1127 d1132 d1135 d1138 d1141
global better95 d1073 d1078 d1083 d1088 d1093 d1098 d1103 d1108 d1113 d1118 d1123 d1128 d1133 d1136 d1139 d1142
global worse95  d1074 d1079 d1084 d1089 d1094 d1099 d1104 d1109 d1114 d1119 d1124 d1129 d1134 d1137 d1140 d1143
        
* 1996 variables        
global base96   e1072 e1077 e1082 e1087 e1092 e1097 e1102 e1107 e1112 e1117 e1122 e1127 e1132 e1135 e1138 e1141
global better96 e1073 e1078 e1083 e1088 e1093 e1098 e1103 e1108 e1113 e1118 e1123 e1128 e1133 e1136 e1139 e1142
global worse96  e1074 e1079 e1084 e1089 e1094 e1099 e1104 e1109 e1114 e1119 e1124 e1129 e1134 e1137 e1140 e1143
   
* 1998 variables            
global base98   f1389 f1394 f1399 f1404 f1409 f1414 f1419 f1424 f1429 f1434 f1439 f1444 f1448 f1451 f1454 f1457
global better98 f1390 f1395 f1400 f1405 f1410 f1415 f1420 f1425 f1430 f1435 f1440 f1445 f1449 f1452 f1455 f1458
global worse98  f1391 f1396 f1401 f1406 f1411 f1416 f1421 f1426 f1431 f1436 f1441 f1446 f1450 f1453 f1456 f1459

* 2000 variables               
global base00   g1543 g1548 g1553 g1558 g1563 g1568 g1573 g1578 g1583 g1588 g1593 g1598 g1602 g1605 g1608 g1611
global better00 g1544 g1549 g1554 g1559 g1564 g1569 g1574 g1579 g1584 g1589 g1594 g1599 g1603 g1606 g1609 g1612
global worse00  g1545 g1550 g1555 g1560 g1565 g1570 g1575 g1580 g1585 g1590 g1595 g1600 g1604 g1607 g1610 g1613
    
* 2002 variables            
global base02   hd506 hd509 hd512 hd515 hd518 hd521 hd524 hd527 hd530 hd533 hd536 hd539 hd542 hd545 hd548 hd551
global better02 hd507 hd510 hd513 hd516 hd519 hd522 hd525 hd528 hd531 hd534 hd537 hd540 hd543 hd546 hd549 hd552
global worse02  hd508 hd511 hd514 hd517 hd520 hd523 hd526 hd529 hd532 hd535 hd538 hd541 hd544 hd547 hd550 hd553

* 2004 variables              
global base04   jd506 jd509 jd512 jd515 jd518 jd521 jd524 jd527 jd530 jd533 jd536 jd539 jd542 jd545 jd548 jd551
global better04 jd507 jd510 jd513 jd516 jd519 jd522 jd525 jd528 jd531 jd534 jd537 jd540 jd543 jd546 jd549 jd552
global worse04  jd508 jd511 jd514 jd517 jd520 jd523 jd526 jd529 jd532 jd535 jd538 jd541 jd544 jd547 jd550 jd553

* 2006 variables               
global base06   kd506 kd509 kd512 kd515 kd518 kd521 kd524 kd527 kd530 kd533 kd536 kd539 kd542 kd545 kd548 kd551
global better06 kd507 kd510 kd513 kd516 kd519 kd522 kd525 kd528 kd531 kd534 kd537 kd540 kd543 kd546 kd549 kd552
global worse06  kd508 kd511 kd514 kd517 kd520 kd523 kd526 kd529 kd532 kd535 kd538 kd541 kd544 kd547 kd550 kd553

* 2008 variables               
global base08   ld506 ld509 ld512 ld515 ld518 ld521 ld524 ld527 ld530 ld533 ld536 ld539 ld542 ld545 ld548 ld551
global better08 ld507 ld510 ld513 ld516 ld519 ld522 ld525 ld528 ld531 ld534 ld537 ld540 ld543 ld546 ld549 ld552
global worse08  ld508 ld511 ld514 ld517 ld520 ld523 ld526 ld529 ld532 ld535 ld538 ld541 ld544 ld547 ld550 ld553

* 2010 variables               
global base10   MD506 MD509 MD512 MD515 MD518 MD521 MD524 MD527 MD530 MD533 MD536 MD539 MD542 MD545 MD548 MD551
global better10 MD507 MD510 MD513 MD516 MD519 MD522 MD525 MD528 MD531 MD534 MD537 MD540 MD543 MD546 MD549 MD552
global worse10  MD508 MD511 MD514 MD517 MD520 MD523 MD526 MD529 MD532 MD535 MD538 MD541 MD544 MD547 MD550 MD553

* 2012 variables               
global base12   nd506 nd509 nd512 nd515 nd518 nd521 nd524 nd527 nd530 nd533 nd536 nd539 nd542 nd545 nd548 nd551
global better12 nd507 nd510 nd513 nd516 nd519 nd522 nd525 nd528 nd531 nd534 nd537 nd540 nd543 nd546 nd549 nd552
global worse12  nd508 nd511 nd514 nd517 nd520 nd523 nd526 nd529 nd532 nd535 nd538 nd541 nd544 nd547 nd550 nd553



clear
set obs 1
gen nonsense = 1
save tics_temp,replace

local i = 1

foreach f in $filelist {
	local wave = word("$wavelist", `i')
	local yr = word("$yrlist", `i')
	
	local basevars  base`yr'
	local basevars  $`basevars'
	
	local bettervars  better`yr'
	local bettervars  $`bettervars'
	
	local worsevars  worse`yr'
	local worsevars  $`worsevars'

	noi di "Processing $hrsfat/`f'.dta"
	use "$hrsfat/`f'.dta", clear
	

	cap drop iqcode
	gen iqcode = .
	gen nmiss_iqcode = .
	* Process IQCODE for 1995 +
	if `yr' != 93 {
		cap drop miss iqtot
		gen miss = 0
		gen iqtot = 0
		forvalues j = 1/16 {
			cap drop base better worse
		
			local base = word("`basevars'", `j')
			gen base = `base'
		
			local better = word("`bettervars'", `j')
			gen better = `better'
		
			local worse = word("`worsevars'", `j')
			gen worse = `worse'
		
		
			
			cap drop delta_iq
			gen delta_iq = 0
			replace delta_iq = better if base == 1 & inlist(better, 1, 2)
			replace delta_iq = 3 if base == 2
			replace delta_iq = worse if base == 3 & inlist(worse, 4,5)
			replace iqtot = iqtot + delta_iq
			replace miss = miss + 1 if delta_iq == 0
		}
		
		replace iqcode = iqtot / (16 - miss)
		replace nmiss_iqcode = miss
		replace iqcode = . if nmiss_iqcode > 7
	}


        /* Eileen's replacements for IQCODE aka Jorg Score */
          local memvar = word("$proxy_memvars", `i')
        gen proxy_mem = `memvar' - 1 if `memvar' <= 5
        local intervar = word("$inter_cogvars", `i')
        if ("`intervar'" != "none") {
          recode `intervar' (1=0) (2=1) (3/4=2) (nonmiss=.), gen(inter_cogstate)
        }
        else {
          gen inter_cogstate = .
        }

        tab proxy_mem `memvar', missing
        if ("`intervar'" != "none") {
            tab inter_cogstate `intervar' , missing
        }
	
	gen wave = `wave'
	gen yr = "`yr'"

	keep hhidpn wave iqcode yr nmiss_iqcode proxy_mem inter_cogstate
	append using tics_temp
	save tics_temp,replace
	local i = `i' + 1
}

tab nonsense
list hhidpn wave if nonsense == 1
drop if nonsense == 1
drop nonsense

sort hhidpn wave
merge 1:1 hhidpn wave using "$outdata/tics_imputed.dta"
tab _merge
gen mrgtics = _merge
drop _merge

erase tics_temp.dta

ren wtresp weight

gen proxy_nonmissB = 0
gen proxy_nonmissx = 0 /* used to make proxy_nonmiss */
gen nmiss_proxy = 0
gen nmiss_proxyB = 0
gen maxpcog = 9

/* if iadlza or inter_cogstate is missing use recoded proxy_mem */
/* the recode takes proxy_mem from 0-4 to 0-2 collapsing exc/vg/good to 0 */

recode proxy_mem (0 1 2 = 0 "Exc/VG/Good") (3 = 1 "Fair") (4 = 2 "Poor") (missing = .), generate(proxy_memA)
tab proxy_memA proxy_mem

/* Replace the self-rating memory for proxy respondents */

recode proxy_mem (0 1 2 = 1 "Exc/VG/Good") (3 = 2 "Fair") (4 = 3 "Poor") (missing = .), generate(proxy_selfmem)
tab proxy_selfmem proxy_mem
replace selfmem = proxy_selfmem if proxy==1 

/* the old way yielding proxy_nonmiss which will recode to cogstate_proxy */
foreach cvar of varlist iadlza proxy_mem inter_cogstate {
  replace nmiss_proxyB = nmiss_proxyB + 1 if missing(`cvar')
  replace proxy_nonmissB = proxy_nonmissB + `cvar' if !missing(`cvar')
}
tab proxy_nonmissB nmiss_proxyB, missing

/* the new way using proxy_memA when any missing measures */
/*     yielding proxy_nonmiss which will recode to cogstate_proxy */
foreach cvar of varlist iadlza proxy_memA inter_cogstate {
  replace nmiss_proxy = nmiss_proxy + 1 if missing(`cvar')
  replace maxpcog = maxpcog - 5 if missing(`cvar') & "`cvar'" == "iadlza"
  replace maxpcog = maxpcog - 2 if missing(`cvar') & "`cvar'" == "proxy_memA"
  replace maxpcog = maxpcog - 2 if missing(`cvar') & "`cvar'" == "inter_cogstate"
  replace proxy_nonmissx = proxy_nonmissx + `cvar' if !missing(`cvar')
}
tab maxpcog nmiss_proxy

/* use adjusted sum of non-missing values if any of iadlza, proxy_memA, or inter_cogstate are missing */
/* otherwise add the three values together, NOT using the recoded proxy_mem */

gen proxy_nonmiss = iadlza + proxy_mem + inter_cogstate
replace proxy_nonmiss = round(proxy_nonmissx * (11/maxpcog),1.0) if nmiss_proxy > 0 /* missing values: adjust to make scale 0-11 */
tab proxy_nonmiss nmiss_proxy, missing

tab nmiss_proxy nmiss_proxyB

tab proxy_nonmiss proxy_nonmiss if nmiss_proxy == 0
tab proxy_nonmiss proxy_nonmiss if nmiss_proxy > 0

cap drop cogstate_self cogstate_selfA
recode totcog (0/6=1) (7/11=2) (12/27=3) (miss=.) (nonmiss=3), gen(cogstate_self)	
recode totcogA (0/6=1) (7/11=2) (12/27=3) (miss=.) (nonmiss=3), gen(cogstate_selfA)	

tab totcog cogstate_self, missing
tab totcogA cogstate_selfA, missing
tab totcogA cogstate_self, missing

cap drop cogstate_iq
gen cogstate_iq = 1 if iqcode > 4 & iqcode <= 5
replace cogstate_iq = 2 if iqcode > 3.5 & iqcode <= 4
replace cogstate_iq = 3 if iqcode <= 3.5

cap drop cogstate_proxy cogstate_proxyA
recode proxy_nonmiss (0/2=3) (3/5=2) (6/11=1) (miss=.) (nonmiss=3), gen(cogstate_proxy)
replace cogstate_proxy = . if nmiss_proxy > 2

* this version uses sum of measures adjusted to total of 11 if any part is missing
*
recode proxy_nonmissB (0/2=3) (3/5=2) (6/11=1) (miss=.) (nonmiss=3), gen(cogstate_proxyB)
replace cogstate_proxyB = . if nmiss_proxy > 2

tab cogstate_proxy inter_cogstate, missing
tab cogstate_proxy iadlza, missing
tab cogstate_proxy proxy_mem, missing
 
* are there ever both proxy and self measures? if so this code has self-report taking precedence
tab cogstate_self cogstate_proxy, missing

cap drop cogstateB
gen cogstateB = cogstate_proxyB if !missing(cogstate_proxyB)
replace cogstateB = cogstate_self if !missing(cogstate_self)

* Flag for imputed proxy cogstate
gen proxy_cogX = (nmiss_proxy>0) if !missing(cogstate_proxy)
replace proxy_cogX = 0 if !missing(cogstate_self)
tab proxy_cogX

tab cogstateB cogstate_self

cap drop cogstate
gen cogstate = cogstate_proxy if !missing(cogstate_proxy)
replace cogstate = cogstate_self if !missing(cogstate_self)

tab cogstate cogstate_self

tab cogstate cogstateB, missing
tab cogstate cogstateB if proxy_cogX==0
tab cogstate cogstateB if proxy_cogX==1

/* cases where cogstate is normal and cogstateA is demented */
list cogstate cogstateB proxy nmiss_proxy proxy_nonmiss proxy_nonmiss proxy_mem proxy_memA inter_cogstate iadlza ser7 tr20 bwc20 if cogstate == 1 & cogstateB == 3

sort inter_cogstate
/* cases where cogstateB is CIND and cogstate is demented */
by inter_cogstate: tab iadlza proxy_mem if cogstateB==2 & cogstate==1 & proxy==1 , missing

/* cases where cogstate is normal and cogstateA is CIND */
by inter_cogstate: tab iadlza proxy_mem if cogstateB==3 & cogstate==2 & proxy==1, missing

sort hhidpn wave
* Fill in missing cogstate values

label define cogstate_lbl 1 "Demented" 2 "Congnitive Impairment, No Dementia" 3 "Normal"
label variable cogstateB "Cognitive Ability (old)"
label values cogstate cogstate_lbl

label variable cogstate "Cognitive Ability / proxy adj if miss"
label values cogstate cogstate_lbl

label variable cogstate_self "Cognitive Ability, Self Respondents"
label values cogstate_self cogstate_lbl

label variable cogstate_selfA "Cognitive Ability, Self Respondents/=. if >2 imputes"
label values cogstate_selfA cogstate_lbl

label variable cogstate_iq "Cognitive Ability, IQCODE"
label values cogstate_iq cogstate_lbl

label variable cogstate_proxyB "Cognitive Ability, Proxy Respondents (old)"
label values cogstate_proxyB cogstate_lbl

label variable cogstate_proxy "Cognitive Ability, Proxy Respondents / adj if any miss"
label values cogstate_proxy cogstate_lbl

label variable proxy_cogX "Whether any missing part of cogstate_proxy"

label define selfmem_lbl 1 "Excellent/VG/Good" 2 "Fair" 3 "Poor"
label variable selfmem "Self-rating overall memory status"
label values selfmem selfmemlbl

label data "TICS Score Count 1998-2012"
save "$outdata/tics.dta", replace

exit, STATA

