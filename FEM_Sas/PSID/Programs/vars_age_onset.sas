/****************************************************************************************** 	
	PROGRAM: vars_age_onset.sas 
	PURPOSE: The code generates macro variables for variables associated with age of onset of 
	disease.

******************************************************************************************/


/******** FAMILY FILE VARIABLES *****************************************************/

/* How long have you had the condition was asked from 1999-2003 (days, months, weeks, years) */

%let hdstrokedaysin=[99]ER15453 [01]ER19618 [03]ER23018;
%let hdstrokemnthin=[99]ER15454 [01]ER19619 [03]ER23019;
%let hdstrokeweekin=[99]ER15455 [01]ER19620 [03]ER23020;
%let hdstrokeyearin=[99]ER15456 [01]ER19621 [03]ER23021;
%let wfstrokedaysin=[99]ER15561 [01]ER19726 [03]ER23145;
%let wfstrokemnthin=[99]ER15562 [01]ER19727 [03]ER23146;
%let wfstrokeweekin=[99]ER15563 [01]ER19728 [03]ER23147;
%let wfstrokeyearin=[99]ER15564 [01]ER19729 [03]ER23148;

%let hdhibpdaysin=[99]ER15459 [01]ER19624 [03]ER23024;
%let hdhibpmnthin=[99]ER15460 [01]ER19625 [03]ER23025;
%let hdhibpweekin=[99]ER15461 [01]ER19626 [03]ER23026;
%let hdhibpyearin=[99]ER15462 [01]ER19627 [03]ER23027;   
%let wfhibpdaysin=[99]ER15567 [01]ER19732 [03]ER23151;
%let wfhibpmnthin=[99]ER15568 [01]ER19733 [03]ER23152;
%let wfhibpweekin=[99]ER15569 [01]ER19734 [03]ER23153;   
%let wfhibpyearin=[99]ER15570 [01]ER19735 [03]ER23154;   

%let hddiabdaysin=[99]ER15465 [01]ER19630 [03]ER23030;
%let hddiabmnthin=[99]ER15466 [01]ER19631 [03]ER23031;
%let hddiabweekin=[99]ER15467 [01]ER19632 [03]ER23032;
%let hddiabyearin=[99]ER15468 [01]ER19633 [03]ER23033;
%let wfdiabdaysin=[99]ER15573 [01]ER19738 [03]ER23157;
%let wfdiabmnthin=[99]ER15574 [01]ER19739 [03]ER23158;
%let wfdiabweekin=[99]ER15575 [01]ER19740 [03]ER23159;
%let wfdiabyearin=[99]ER15576 [01]ER19741 [03]ER23160;

%let hdcancrdaysin=[99]ER15471 [01]ER19636 [03]ER23036;
%let hdcancrmnthin=[99]ER15472 [01]ER19637 [03]ER23037;
%let hdcancrweekin=[99]ER15473 [01]ER19638 [03]ER23038;
%let hdcancryearin=[99]ER15474 [01]ER19639 [03]ER23039;
%let wfcancrdaysin=[99]ER15579 [01]ER19744 [03]ER23163;
%let wfcancrmnthin=[99]ER15580 [01]ER19745 [03]ER23164;
%let wfcancrweekin=[99]ER15581 [01]ER19746 [03]ER23165;
%let wfcancryearin=[99]ER15582 [01]ER19747 [03]ER23166;

%let hdlungdaysin=[99]ER15477 [01]ER19642 [03]ER23042;
%let hdlungmnthin=[99]ER15478 [01]ER19643 [03]ER23043;
%let hdlungweekin=[99]ER15479 [01]ER19644 [03]ER23044;
%let hdlungyearin=[99]ER15480 [01]ER19645 [03]ER23045;
%let wflungdaysin=[99]ER15585 [01]ER19750 [03]ER23169;
%let wflungmnthin=[99]ER15586 [01]ER19751 [03]ER23170;
%let wflungweekin=[99]ER15587 [01]ER19752 [03]ER23171;
%let wflungyearin=[99]ER15588 [01]ER19753 [03]ER23172;

%let hdheartattackdaysin=[99]ER15483 [01]ER19648 [03]ER23048;
%let hdheartattackmnthin=[99]ER15484 [01]ER19649 [03]ER23049;
%let hdheartattackweekin=[99]ER15485 [01]ER19650 [03]ER23050;
%let hdheartattackyearin=[99]ER15486 [01]ER19651 [03]ER23051;
%let wfheartattackdaysin=[99]ER15591 [01]ER19756 [03]ER23175;
%let wfheartattackmnthin=[99]ER15592 [01]ER19757 [03]ER23176;
%let wfheartattackweekin=[99]ER15593 [01]ER19758 [03]ER23177;
%let wfheartattackyearin=[99]ER15594 [01]ER19759 [03]ER23178;

%let hdheartdiseasedaysin=[99]ER15489 [01]ER19654 [03]ER23054;
%let hdheartdiseasemnthin=[99]ER15490 [01]ER19655 [03]ER23055;
%let hdheartdiseaseweekin=[99]ER15491 [01]ER19656 [03]ER23056;
%let hdheartdiseaseyearin=[99]ER15492 [01]ER19657 [03]ER23057;
%let wfheartdiseasedaysin=[99]ER15597 [01]ER19762 [03]ER23181;
%let wfheartdiseasemnthin=[99]ER15598 [01]ER19763 [03]ER23182;
%let wfheartdiseaseweekin=[99]ER15599 [01]ER19764 [03]ER23183;
%let wfheartdiseaseyearin=[99]ER15600 [01]ER19765 [03]ER23184;

%let hdpsychprobdaysin=[99]ER15495 [01]ER19660 [03]ER23060;
%let hdpsychprobmnthin=[99]ER15496 [01]ER19661 [03]ER23061;
%let hdpsychprobweekin=[99]ER15497 [01]ER19662 [03]ER23062;
%let hdpsychprobyearin=[99]ER15498 [01]ER19663 [03]ER23063;
%let wfpsychprobdaysin=[99]ER15603 [01]ER19768 [03]ER23187;
%let wfpsychprobmnthin=[99]ER15604 [01]ER19769 [03]ER23188;
%let wfpsychprobweekin=[99]ER15605 [01]ER19770 [03]ER23189;
%let wfpsychprobyearin=[99]ER15606 [01]ER19771 [03]ER23190;

%let hdarthritisdaysin=[99]ER15501 [01]ER19666 [03]ER23066;
%let hdarthritismnthin=[99]ER15502 [01]ER19667 [03]ER23067;
%let hdarthritisweekin=[99]ER15503 [01]ER19668 [03]ER23068;
%let hdarthritisyearin=[99]ER15504 [01]ER19669 [03]ER23069;
%let wfarthritisdaysin=[99]ER15609 [01]ER19774 [03]ER23193;
%let wfarthritismnthin=[99]ER15610 [01]ER19775 [03]ER23194;
%let wfarthritisweekin=[99]ER15611 [01]ER19776 [03]ER23195;
%let wfarthritisyearin=[99]ER15612 [01]ER19777 [03]ER23196;

%let hdasthmadaysin=[99]ER15507 [01]ER19672 [03]ER23072;
%let hdasthmamnthin=[99]ER15508 [01]ER19673 [03]ER23073;
%let hdasthmaweekin=[99]ER15509 [01]ER19674 [03]ER23074;
%let hdasthmayearin=[99]ER15510 [01]ER19675 [03]ER23075;
%let wfasthmadaysin=[99]ER15615 [01]ER19780 [03]ER23199;
%let wfasthmamnthin=[99]ER15616 [01]ER19781 [03]ER23200;
%let wfasthmaweekin=[99]ER15617 [01]ER19782 [03]ER23201;
%let wfasthmayearin=[99]ER15618 [01]ER19783 [03]ER23202;

%let hdmemorylossdaysin=[99]ER15513 [01]ER19678 [03]ER23078;
%let hdmemorylossmnthin=[99]ER15514 [01]ER19679 [03]ER23079;
%let hdmemorylossweekin=[99]ER15515 [01]ER19680 [03]ER23080;
%let hdmemorylossyearin=[99]ER15516 [01]ER19681 [03]ER23081;
%let wfmemorylossdaysin=[99]ER15621 [01]ER19786 [03]ER23205;
%let wfmemorylossmnthin=[99]ER15622 [01]ER19787 [03]ER23206;
%let wfmemorylossweekin=[99]ER15623 [01]ER19788 [03]ER23207;
%let wfmemorylossyearin=[99]ER15624 [01]ER19789 [03]ER23208;

%let hdlearningdisorderdaysin=[99]ER15519 [01]ER19684 [03]ER23084;
%let hdlearningdisordermnthin=[99]ER15520 [01]ER19685 [03]ER23085;
%let hdlearningdisorderweekin=[99]ER15521 [01]ER19686 [03]ER23086;
%let hdlearningdisorderyearin=[99]ER15522 [01]ER19687 [03]ER23087;
%let wflearningdisorderdaysin=[99]ER15627 [01]ER19792 [03]ER23211;
%let wflearningdisordermnthin=[99]ER15628 [01]ER19793 [03]ER23212;
%let wflearningdisorderweekin=[99]ER15629 [01]ER19794 [03]ER23213;
%let wflearningdisorderyearin=[99]ER15630 [01]ER19795 [03]ER23214;

/* Age of onset was asked for 2005 on */

%let hdstrokeagein=[05]ER26999 [07]ER38210 [09]ER44183 [11]ER49503 [13]ER55253 [15]ER62375;
%let wfstrokeagein=[05]ER27122 [07]ER39307 [09]ER45280 [11]ER50621 [13]ER56369 [15]ER63491;

%let hdheartattackagein=[05]ER27003 [07]ER38214 [09]ER44187 [11]ER49509 [13]ER55259 [15]ER62381;
%let wfheartattackagein=[05]ER27126 [07]ER39311 [09]ER45284 [11]ER50627 [13]ER56375 [15]ER63497;

%let hdheartdiseaseagein=[05]ER27007 [07]ER38218 [09]ER44191 [11]ER49515 [13]ER55265 [15]ER62387;
%let wfheartdiseaseagein=[05]ER27130 [07]ER39315 [09]ER45288 [11]ER50633 [13]ER56381 [15]ER63503;

%let hdhypertensionagein=[05]ER27011 [07]ER38222 [09]ER44195 [11]ER49520 [13]ER55270 [15]ER62392;
%let wfhypertensionagein=[05]ER27134 [07]ER39319 [09]ER45292 [11]ER50638 [13]ER56386 [15]ER63508;

%let hdasthmaagein=[05]ER27015 [07]ER38226 [09]ER44199 [11]ER49525 [13]ER55275 [15]ER62397;
%let wfasthmaagein=[05]ER27138 [07]ER39323 [09]ER45296 [11]ER50643 [13]ER56391 [15]ER63513;

%let hdlungdiseaseagein=[05]ER27019 [07]ER38230 [09]ER44203 [11]ER49530 [13]ER55280 [15]ER62402;
%let wflungdiseaseagein=[05]ER27142 [07]ER39327 [09]ER45300 [11]ER50648 [13]ER56396 [15]ER63518;

%let hddiabetesagein=[05]ER27023 [07]ER38234 [09]ER44207 [11]ER49535 [13]ER55285 [15]ER62407;
%let wfdiabetesagein=[05]ER27146 [07]ER39331 [09]ER45304 [11]ER50653 [13]ER56401 [15]ER63523;

%let hdarthritisagein=[05]ER27027 [07]ER38238 [09]ER44211 [11]ER49540 [13]ER55290 [15]ER62412;
%let wfarthritisagein=[05]ER27150 [07]ER39335 [09]ER45308 [11]ER50658 [13]ER56406 [15]ER63528;

%let hdmemorylossagein=[05]ER27031 [07]ER38242 [09]ER44215 [11]ER49545 [13]ER55295 [15]ER62417;
%let wfmemorylossagein=[05]ER27154 [07]ER39339 [09]ER45312 [11]ER50663 [13]ER56411 [15]ER63533;

%let hdlearningdisorderagein=[05]ER27035 [07]ER38246 [09]ER44219 [11]ER49550 [13]ER55300 [15]ER62422;
%let wflearningdisorderagein=[05]ER27158 [07]ER39343 [09]ER45316 [11]ER50668 [13]ER56416 [15]ER63538;

%let hdcanceragein=[05]ER27039 [07]ER38250 [09]ER44223 [11]ER49555 [13]ER55304 [15]ER62426;
%let wfcanceragein=[05]ER27162 [07]ER39347 [09]ER45320 [11]ER50673 [13]ER56420 [15]ER63542;

%let hdpsychprobagein=[05]ER27046 [07]ER38257 [09]ER44230 [11]ER49564 [13]ER55312 [15]ER62434;
%let wfpsychprobagein=[05]ER27169 [07]ER39354 [09]ER45327 [11]ER50682 [13]ER56428 [15]ER63550;




