*PSID_TAXSIM_2of2 - Creating inputs, running TAXSIM, post-TAXSIM adjustments (dofile 2 of 2)

********************************************************************************
*This program is the second of two Stata programs used to calculate income and payroll taxes
*from Panel Survey of Income Dynamics data using the NBER's Internet TAXSIM version 9
*(http://users.nber.org/~taxsim/taxsim9/), for PSID survey years 1999, 2001, 2003, 2005,
*2007, 2009, and 2011 (tax years n-1).

*This main program (PSID_TAXSIM_2of2) was written by Sara Kimberlin (skimberlin@berkeley.edu)
*and generates all TAXSIM input variables, runs TAXSIM, adjusts tax estimates using additional
*information available in PSID data, and calculates total PSID family unit taxes. 

*A separate program (PSID_TAXSIM_1of2) was written by Jiyoon (June) Kim (junekim@umich.edu)
*in collaboration with Luke Shaefer (lshaefer@umich.edu) to calculate mortgage interest for 
*itemized deductions; that program needs to be run first, before this main program.

*A more complete description of the overall method for calculating taxes from PSID data 
*using TAXSIM is included below and in an accompanying memo.

********************************************************************************
*The program below was written by Sara Kimberlin (skimberlin@berkeley.edu), last revised May 2015.

*Special thanks to Jonathan Latner for the code to use this program with the zipped PSID data files.
 
*Note that mortgage interest (for itemized deduction) is calculated in a separate dofile 
*	(PSID_TAXSIM_1of2) that should be run first.

********************************************************************************

*The methods below largely follow those described by Butrica & Burkhauser (1997), with 
*some simplifications and modifications. A more detailed description can be found in the
*memo that accompanies this dofile, but briefly:
 
*Multiple tax units are identified within each PSID family unit (e.g. cohabiting
*	partners with their children are treated as separate tax units, as are "other 
*	family unit member" (OFUM) sub-households).
*To be counted as dependents, individuals must be living in the PSID family unit 
*	during some part of the tax year.
*The most detailed income data available in the PSID is used to generate TAXSIM input
*	variables. Labor, unincorporated business, and farm income are included in earned
*	income. A variety of property income and transfer income items are incorporated
*	into the relevant TAXSIM input variables.
*TAXSIM tax estimates are adjusted afterwards to correct payroll tax calculations
*	for individuals with self-employment profits (TAXSIM does not calculate self-employment tax)
*	and losses. Also EITC amounts are eliminated for immigrants who are not eligible
*	for legal employment (as indicated in PSID immigrant legal status variables).

*Note that the program is designed to prioritize accuracy of income taxes calculated
*	for low-income households, particularly the EITC.
*		TAXSIM uses the -depx- input variable to calculate both the dependent
*			exemption AND the EITC. To ensure the most accurate EITC calculations, 
*			only individuals who could be EITC "qualifying children" are counted
*			as dependents in the code below (adult relatives are not counted).
*		If accuracy of EITC is less of a priority, adult dependents could be added
*			using variables generated below for more accurate dependent exemption amounts
*			(with the caveat that EITC amounts would then be somewhat skewed).

*Capital gains are set to zero in this program as data are not available in
*	the PSID (and they generally have minimal impact on tax liabilities/credits 
*	for low-income households). Deductions with preference for the AMT (e.g. local
*	income tax) are also set to zero (as they have minimal impact on low-income
*	households).

*Item-missing values for income and expense items are generally imputed below by 
*	substituting the median non-zero value by family unit. 
*		This follows the convention for PSID-provided imputed values for most income
*			items from 2005 on (except labor income, for which PSID uses a more 
*			complex imputation strategy).
*		Exception: missing values for property tax paid, charitable gift
*			deduction, and medical expense deduction are not imputed - instead they
*			are set to zero in the TAXSIM input variables (these items are generally
*			small for low-income households and do not substantially impact their
*			tax liabilities/credits. Missing values for mortgage interest deduction are also 
*			effectively set to zero (no value calculated in the other dofile)
*			if any components required to calculate total mortgage interest are missing.

*Note that code below uses a user-generated command -carryforward- (can be downloaded by 
*	typing "findit carryforward").

********************************************************************************
********************************************************************************

*This program is designed to be used with the PSID zipped public use Main Interview data files available for 
*download from the PSID website at http://simba.isr.umich.edu/Zips/ZipMain.aspx.
*	Files needed to run the program include:
*		*	the Family data files for years 1999, 2001, 2003, 2005, 2007, 2009, and 2011, and
*		*   the Cross-Year Individual data file (labeled with the most recent year, i.e. 2011)
* 	Family data files should be saved in the following format: FAMXXXX.dta, where XXXX is year.
* 	The Individual data file should be saved in the following format: indxxxxer.dta, where XXXX is year. 

include common.do


* Enter the date:
global datestamp 102517

***********************

clear all
set more off

/*INDIVIDUAL DATA*/
u $psid_dir/Stata/ind2011er, clear

#delimit;
keep 
ER30001 /*FAMNO FROM 1968*/
ER30002 /*PERSONNO FROM 1968*/
/*1999	2001	2003	2005	2007	2009	2011	*/
ER33401 ER33501 ER33601 ER33701 ER33801 ER33901 ER34001 ER34101 /*INTERVIEW NUMBER (first year 1997)*/
ER33502 ER33602 ER33702 ER33802 ER33902 ER34002 ER34102 /*SEQUENCE NUMBER*/
ER33503 ER33603 ER33703 ER33803 ER33903 ER34003 ER34103 /*RELATIONSHIP TO HEAD*/ 
ER33506 ER33606 ER33706 ER33806 ER33906 ER34006 ER34106 /*YEAR BORN*/ 
ER33504 ER33604 ER33704 ER33804 ER33904 ER34004 ER34104 /*AGE AT INTERVIEW*/
ER33510 ER33610 ER33710 ER33810 ER33910 ER34010 ER34110 /*YEAR MOVED IN/OUT*/ 

; 
#delimit cr     

* Creating unique person id
gen personid= (ER30001*1000) + ER30002
sort personid

rename ER33401 famno1997
rename ER33501 famno1999
rename ER33601 famno2001
rename ER33701 famno2003
rename ER33801 famno2005
rename ER33901 famno2007
rename ER34001 famno2009
rename ER34101 famno2011

rename ER33502 seqno1999
rename ER33602 seqno2001
rename ER33702 seqno2003
rename ER33802 seqno2005
rename ER33902 seqno2007
rename ER34002 seqno2009
rename ER34102 seqno2011

rename ER33503 reltohd1999
rename ER33603 reltohd2001
rename ER33703 reltohd2003
rename ER33803 reltohd2005
rename ER33903 reltohd2007
rename ER34003 reltohd2009
rename ER34103 reltohd2011

rename ER33506 yearborn1999
rename ER33606 yearborn2001
rename ER33706 yearborn2003
rename ER33806 yearborn2005
rename ER33906 yearborn2007
rename ER34006 yearborn2009
rename ER34106 yearborn2011

rename ER33504 intage1999
rename ER33604 intage2001
rename ER33704 intage2003
rename ER33804 intage2005
rename ER33904 intage2007
rename ER34004 intage2009
rename ER34104 intage2011

rename ER33510 moveyr1999
rename ER33610 moveyr2001
rename ER33710 moveyr2003
rename ER33810 moveyr2005
rename ER33910 moveyr2007
rename ER34010 moveyr2009
rename ER34110 moveyr2011

save        $outdata/ind.dta, replace

/* MERGING IN FAMILY DATA */

*1997
u  ER10002 ER11979 ER12061 using $psid_dir/Stata/fam1997er,clear
rename ER10002 famno1997
rename ER11979 immleghd1997 
rename ER12061 immlegwf1997
/*MERGE FAMILY DATA AND INDIVIDUAL DATA*/
merge 1:m famno1997 using $outdata/ind, keep ( using matched )
drop _m
sort personid
/*SAVE*/
save        $outdata/fam1997,replace

*1999
u  ER13002 ER13008 ER13004 ER13065 ER13066 ER13013 ER16425 ER13010 ER13012 ER16463 ER16490 ER16491 ER16448 ER16465 ER16511 ER16512 ER16452 ER16456 ER14987 ER16460 ER13042 ER14232 ER14974 ER14975 ER14973 ER16067 ER16154 ER14481 ER14482 ER14483 ER14484 ER14485 ER14486 ER14487 ER14488 ER14489 ER14490 ER14491 ER14492 ER14479 ER14480 ER14496 ER14497 ER14498 ER14499 ER14500 ER14501 ER14502 ER14503 ER14504 ER14505 ER14506 ER14507 ER14494 ER14495 ER14511 ER14512 ER14513 ER14514 ER14515 ER14516 ER14517 ER14518 ER14519 ER14520 ER14521 ER14522 ER14509 ER14510 ER14526 ER14527 ER14528 ER14529 ER14530 ER14531 ER14532 ER14533 ER14534 ER14535 ER14536 ER14537 ER14524 ER14525 ER14541 ER14542 ER14543 ER14544 ER14545 ER14546 ER14547 ER14548 ER14549 ER14550 ER14551 ER14552 ER14539 ER14540 ER14557 ER14558 ER14559 ER14560 ER14561 ER14562 ER14563 ER14564 ER14565 ER14566 ER14567 ER14568 ER14555 ER14556 ER14572 ER14573 ER14574 ER14575 ER14576 ER14577 ER14578 ER14579 ER14580 ER14581 ER14582 ER14583 ER14570 ER14571 ER14590 ER14591 ER14592 ER14593 ER14594 ER14595 ER14596 ER14597 ER14598 ER14599 ER14600 ER14601 ER14588 ER14589 ER14605 ER14606 ER14607 ER14608 ER14609 ER14610 ER14611 ER14612 ER14613 ER14614 ER14615 ER14616 ER14603 ER14604 ER14620 ER14621 ER14622 ER14623 ER14624 ER14625 ER14626 ER14627 ER14628 ER14629 ER14630 ER14631 ER14618 ER14619 ER14635 ER14636 ER14637 ER14638 ER14639 ER14640 ER14641 ER14642 ER14643 ER14644 ER14645 ER14646 ER14633 ER14634 ER14651 ER14652 ER14653 ER14654 ER14655 ER14656 ER14657 ER14658 ER14659 ER14660 ER14661 ER14662 ER14649 ER14650 ER14666 ER14667 ER14668 ER14669 ER14670 ER14671 ER14672 ER14673 ER14674 ER14675 ER14676 ER14677 ER14664 ER14665 ER14681 ER14682 ER14683 ER14684 ER14685 ER14686 ER14687 ER14688 ER14689 ER14690 ER14691 ER14692 ER14679 ER14680 ER14696 ER14697 ER14698 ER14699 ER14700 ER14701 ER14702 ER14703 ER14704 ER14705 ER14706 ER14707 ER14694 ER14695 ER14762 ER14763 ER14764 ER14765 ER14766 ER14767 ER14768 ER14769 ER14770 ER14771 ER14772 ER14773 ER14760 ER14761 ER14777 ER14778 ER14779 ER14780 ER14781 ER14782 ER14783 ER14784 ER14785 ER14786 ER14787 ER14788 ER14775 ER14776 ER14792 ER14793 ER14794 ER14795 ER14796 ER14797 ER14798 ER14799 ER14800 ER14801 ER14802 ER14803 ER14790 ER14791 ER14807 ER14808 ER14809 ER14810 ER14811 ER14812 ER14813 ER14814 ER14815 ER14816 ER14817 ER14818 ER14805 ER14806 ER14822 ER14823 ER14824 ER14825 ER14826 ER14827 ER14828 ER14829 ER14830 ER14831 ER14832 ER14833 ER14820 ER14821 ER14853 ER14854 ER14855 ER14856 ER14857 ER14858 ER14859 ER14860 ER14861 ER14862 ER14863 ER14864 ER14851 ER14852 ER14868 ER14869 ER14870 ER14871 ER14872 ER14873 ER14874 ER14875 ER14876 ER14877 ER14878 ER14879 ER14866 ER14867 ER14883 ER14884 ER14885 ER14886 ER14887 ER14888 ER14889 ER14890 ER14891 ER14892 ER14893 ER14894 ER14881 ER14882 ER14898 ER14899 ER14900 ER14901 ER14902 ER14903 ER14904 ER14905 ER14906 ER14907 ER14908 ER14909 ER14896 ER14897 ER14913 ER14914 ER14915 ER14916 ER14917 ER14918 ER14919 ER14920 ER14921 ER14922 ER14923 ER14924 ER14911 ER14912 using $psid_dir/Stata/fam1999er,clear
foreach X in 1999 {
rename ER13002 famno`X'
rename ER13008 intyr`X'
rename ER13004 state`X'
rename ER13065  rentpdamt`X'
rename ER13066 rentpdper`X'
rename ER13013 intnumchd`X'
rename ER16425 marstat`X'
rename ER13010 agehead`X'
rename ER13012 agewife`X'
rename ER16463 laborhd`X'
rename ER16490 buslabhd`X'
rename ER16491 busassethd`X'
rename ER16448 farm`X'
rename ER16465 laborwf`X'
rename ER16511 buslabwf`X'
rename ER16512 busassetwf`X'
rename ER16452 taxableinchdwf`X'
rename ER16456 taxableincofum`X'
rename ER14987 alimpdhd`X'
rename ER16460 socsecfam`X'
rename ER13042 proptx`X'
rename ER14232 c`X'childcaretotal
rename ER14974 chardeduc`X'
rename ER14975 meddeduc`X'
rename ER14973 itemize`X'
rename ER16067 immleghd1999
rename ER16154 immlegwf1999

*1999 summing annual income amounts  
rename ER14481 hrnjan`X'
rename ER14482 hrnfeb`X'
rename ER14483 hrnmar`X'
rename ER14484 hrnapr`X'
rename ER14485 hrnmay`X'
rename ER14486 hrnjun`X'
rename ER14487 hrnjul`X'
rename ER14488 hrnaug`X'
rename ER14489 hrnsep`X'
rename ER14490 hrnoct`X'
rename ER14491 hrnnov`X'
rename ER14492 hrndec`X'
rename ER14479 hrnamount`X'
rename ER14480 hrnper`X'
rename ER14496 hdvjan`X'
rename ER14497 hdvfeb`X'
rename ER14498 hdvmar`X'
rename ER14499 hdvapr`X'
rename ER14500 hdvmay`X'
rename ER14501 hdvjun`X'
rename ER14502 hdvjul`X'
rename ER14503 hdvaug`X'
rename ER14504 hdvsep`X'
rename ER14505 hdvoct`X'
rename ER14506 hdvnov`X'
rename ER14507 hdvdec`X'
rename ER14494 hdvamount`X'
rename ER14495 hdvper`X'
rename ER14511 hinjan`X'
rename ER14512 hinfeb`X'
rename ER14513 hinmar`X'
rename ER14514 hinapr`X'
rename ER14515 hinmay`X'
rename ER14516 hinjun`X'
rename ER14517 hinjul`X'
rename ER14518 hinaug`X'
rename ER14519 hinsep`X'
rename ER14520 hinoct`X'
rename ER14521 hinnov`X'
rename ER14522 hindec`X'
rename ER14509 hinamount`X'
rename ER14510 hinper`X'
rename ER14526 htfjan`X'
rename ER14527 htffeb`X'
rename ER14528 htfmar`X'
rename ER14529 htfapr`X'
rename ER14530 htfmay`X'
rename ER14531 htfjun`X'
rename ER14532 htfjul`X'
rename ER14533 htfaug`X'
rename ER14534 htfsep`X'
rename ER14535 htfoct`X'
rename ER14536 htfnov`X'
rename ER14537 htfdec`X'
rename ER14524 htfamount`X'
rename ER14525 htfper`X'
rename ER14541 htnjan`X'
rename ER14542 htnfeb`X'
rename ER14543 htnmar`X'
rename ER14544 htnapr`X'
rename ER14545 htnmay`X'
rename ER14546 htnjun`X'
rename ER14547 htnjul`X'
rename ER14548 htnaug`X'
rename ER14549 htnsep`X'
rename ER14550 htnoct`X'
rename ER14551 htnnov`X'
rename ER14552 htndec`X'
rename ER14539 htnamount`X'
rename ER14540 htnper`X'
rename ER14557 hsijan`X'
rename ER14558 hsifeb`X'
rename ER14559 hsimar`X'
rename ER14560 hsiapr`X'
rename ER14561 hsimay`X'
rename ER14562 hsijun`X'
rename ER14563 hsijul`X'
rename ER14564 hsiaug`X'
rename ER14565 hsisep`X'
rename ER14566 hsioct`X'
rename ER14567 hsinov`X'
rename ER14568 hsidec`X'
rename ER14555 hsiamount`X'
rename ER14556 hsiper`X'
rename ER14572 howjan`X'
rename ER14573 howfeb`X'
rename ER14574 howmar`X'
rename ER14575 howapr`X'
rename ER14576 howmay`X'
rename ER14577 howjun`X'
rename ER14578 howjul`X'
rename ER14579 howaug`X'
rename ER14580 howsep`X'
rename ER14581 howoct`X'
rename ER14582 hownov`X'
rename ER14583 howdec`X'
rename ER14570 howamount`X'
rename ER14571 howper`X'
rename ER14590 hvajan`X'
rename ER14591 hvafeb`X'
rename ER14592 hvamar`X'
rename ER14593 hvaapr`X'
rename ER14594 hvamay`X'
rename ER14595 hvajun`X'
rename ER14596 hvajul`X'
rename ER14597 hvaaug`X'
rename ER14598 hvasep`X'
rename ER14599 hvaoct`X'
rename ER14600 hvanov`X'
rename ER14601 hvadec`X'
rename ER14588 hvaamount`X'
rename ER14589 hvaper`X'
rename ER14605 hrtjan`X'
rename ER14606 hrtfeb`X'
rename ER14607 hrtmar`X'
rename ER14608 hrtapr`X'
rename ER14609 hrtmay`X'
rename ER14610 hrtjun`X'
rename ER14611 hrtjul`X'
rename ER14612 hrtaug`X'
rename ER14613 hrtsep`X'
rename ER14614 hrtoct`X'
rename ER14615 hrtnov`X'
rename ER14616 hrtdec`X'
rename ER14603 hrtamount`X'
rename ER14604 hrtper`X'
rename ER14620 hanjan`X'
rename ER14621 hanfeb`X'
rename ER14622 hanmar`X'
rename ER14623 hanapr`X'
rename ER14624 hanmay`X'
rename ER14625 hanjun`X'
rename ER14626 hanjul`X'
rename ER14627 hanaug`X'
rename ER14628 hansep`X'
rename ER14629 hanoct`X'
rename ER14630 hannov`X'
rename ER14631 handec`X'
rename ER14618 hanamount`X'
rename ER14619 hanper`X'
rename ER14635 hopjan`X'
rename ER14636 hopfeb`X'
rename ER14637 hopmar`X'
rename ER14638 hopapr`X'
rename ER14639 hopmay`X'
rename ER14640 hopjun`X'
rename ER14641 hopjul`X'
rename ER14642 hopaug`X'
rename ER14643 hopsep`X'
rename ER14644 hopoct`X'
rename ER14645 hopnov`X'
rename ER14646 hopdec`X'
rename ER14633 hopamount`X'
rename ER14634 hopper`X'
rename ER14651 hunjan`X'
rename ER14652 hunfeb`X'
rename ER14653 hunmar`X'
rename ER14654 hunapr`X'
rename ER14655 hunmay`X'
rename ER14656 hunjun`X'
rename ER14657 hunjul`X'
rename ER14658 hunaug`X'
rename ER14659 hunsep`X'
rename ER14660 hunoct`X'
rename ER14661 hunnov`X'
rename ER14662 hundec`X'
rename ER14649 hunamount`X'
rename ER14650 hunper`X'
rename ER14666 hwcjan`X'
rename ER14667 hwcfeb`X'
rename ER14668 hwcmar`X'
rename ER14669 hwcapr`X'
rename ER14670 hwcmay`X'
rename ER14671 hwcjun`X'
rename ER14672 hwcjul`X'
rename ER14673 hwcaug`X'
rename ER14674 hwcsep`X'
rename ER14675 hwcoct`X'
rename ER14676 hwcnov`X'
rename ER14677 hwcdec`X'
rename ER14664 hwcamount`X'
rename ER14665 hwcper`X'
rename ER14681 hcsjan`X'
rename ER14682 hcsfeb`X'
rename ER14683 hcsmar`X'
rename ER14684 hcsapr`X'
rename ER14685 hcsmay`X'
rename ER14686 hcsjun`X'
rename ER14687 hcsjul`X'
rename ER14688 hcsaug`X'
rename ER14689 hcssep`X'
rename ER14690 hcsoct`X'
rename ER14691 hcsnov`X'
rename ER14692 hcsdec`X'
rename ER14679 hcsamount`X'
rename ER14680 hcsper`X'
rename ER14696 haljan`X'
rename ER14697 halfeb`X'
rename ER14698 halmar`X'
rename ER14699 halapr`X'
rename ER14700 halmay`X'
rename ER14701 haljun`X'
rename ER14702 haljul`X'
rename ER14703 halaug`X'
rename ER14704 halsep`X'
rename ER14705 haloct`X'
rename ER14706 halnov`X'
rename ER14707 haldec`X'
rename ER14694 halamount`X'
rename ER14695 halper`X'
rename ER14762 wunjan`X'
rename ER14763 wunfeb`X'
rename ER14764 wunmar`X'
rename ER14765 wunapr`X'
rename ER14766 wunmay`X'
rename ER14767 wunjun`X'
rename ER14768 wunjul`X'
rename ER14769 wunaug`X'
rename ER14770 wunsep`X'
rename ER14771 wunoct`X'
rename ER14772 wunnov`X'
rename ER14773 wundec`X'
rename ER14760 wunamount`X'
rename ER14761 wunper`X'
rename ER14777 wwcjan`X'
rename ER14778 wwcfeb`X'
rename ER14779 wwcmar`X'
rename ER14780 wwcapr`X'
rename ER14781 wwcmay`X'
rename ER14782 wwcjun`X'
rename ER14783 wwcjul`X'
rename ER14784 wwcaug`X'
rename ER14785 wwcsep`X'
rename ER14786 wwcoct`X'
rename ER14787 wwcnov`X'
rename ER14788 wwcdec`X'
rename ER14775 wwcamount`X'
rename ER14776 wwcper`X'
rename ER14792 wdvjan`X'
rename ER14793 wdvfeb`X'
rename ER14794 wdvmar`X'
rename ER14795 wdvapr`X'
rename ER14796 wdvmay`X'
rename ER14797 wdvjun`X'
rename ER14798 wdvjul`X'
rename ER14799 wdvaug`X'
rename ER14800 wdvsep`X'
rename ER14801 wdvoct`X'
rename ER14802 wdvnov`X'
rename ER14803 wdvdec`X'
rename ER14790 wdvamount`X'
rename ER14791 wdvper`X'
rename ER14807 winjan`X'
rename ER14808 winfeb`X'
rename ER14809 winmar`X'
rename ER14810 winapr`X'
rename ER14811 winmay`X'
rename ER14812 winjun`X'
rename ER14813 winjul`X'
rename ER14814 winaug`X'
rename ER14815 winsep`X'
rename ER14816 winoct`X'
rename ER14817 winnov`X'
rename ER14818 windec`X'
rename ER14805 winamount`X'
rename ER14806 winper`X'
rename ER14822 wtfjan`X'
rename ER14823 wtffeb`X'
rename ER14824 wtfmar`X'
rename ER14825 wtfapr`X'
rename ER14826 wtfmay`X'
rename ER14827 wtfjun`X'
rename ER14828 wtfjul`X'
rename ER14829 wtfaug`X'
rename ER14830 wtfsep`X'
rename ER14831 wtfoct`X'
rename ER14832 wtfnov`X'
rename ER14833 wtfdec`X'
rename ER14820 wtfamount`X'
rename ER14821 wtfper`X'
rename ER14853 wsijan`X'
rename ER14854 wsifeb`X'
rename ER14855 wsimar`X'
rename ER14856 wsiapr`X'
rename ER14857 wsimay`X'
rename ER14858 wsijun`X'
rename ER14859 wsijul`X'
rename ER14860 wsiaug`X'
rename ER14861 wsisep`X'
rename ER14862 wsioct`X'
rename ER14863 wsinov`X'
rename ER14864 wsidec`X'
rename ER14851 wsiamount`X'
rename ER14852 wsiper`X'
rename ER14868 wtnjan`X'
rename ER14869 wtnfeb`X'
rename ER14870 wtnmar`X'
rename ER14871 wtnapr`X'
rename ER14872 wtnmay`X'
rename ER14873 wtnjun`X'
rename ER14874 wtnjul`X'
rename ER14875 wtnaug`X'
rename ER14876 wtnsep`X'
rename ER14877 wtnoct`X'
rename ER14878 wtnnov`X'
rename ER14879 wtndec`X'
rename ER14866 wtnamount`X'
rename ER14867 wtnper`X'
rename ER14883 wcsjan`X'
rename ER14884 wcsfeb`X'
rename ER14885 wcsmar`X'
rename ER14886 wcsapr`X'
rename ER14887 wcsmay`X'
rename ER14888 wcsjun`X'
rename ER14889 wcsjul`X'
rename ER14890 wcsaug`X'
rename ER14891 wcssep`X'
rename ER14892 wcsoct`X'
rename ER14893 wcsnov`X'
rename ER14894 wcsdec`X'
rename ER14881 wcsamount`X'
rename ER14882 wcsper`X'
rename ER14898 wowjan`X'
rename ER14899 wowfeb`X'
rename ER14900 wowmar`X'
rename ER14901 wowapr`X'
rename ER14902 wowmay`X'
rename ER14903 wowjun`X'
rename ER14904 wowjul`X'
rename ER14905 wowaug`X'
rename ER14906 wowsep`X'
rename ER14907 wowoct`X'
rename ER14908 wownov`X'
rename ER14909 wowdec`X'
rename ER14896 wowamount`X'
rename ER14897 wowper`X'
rename ER14913 wpajan`X'
rename ER14914 wpafeb`X'
rename ER14915 wpamar`X'
rename ER14916 wpaapr`X'
rename ER14917 wpamay`X'
rename ER14918 wpajun`X'
rename ER14919 wpajul`X'
rename ER14920 wpaaug`X'
rename ER14921 wpasep`X'
rename ER14922 wpaoct`X'
rename ER14923 wpanov`X'
rename ER14924 wpadec`X'
rename ER14911 wpaamount`X'
rename ER14912 wpaper`X'
}
/*MERGE FAMILY DATA AND INDIVIDUAL DATA*/
merge 1:m famno1999 using $outdata/ind, keep ( using matched )
drop _m
sort personid
/*SAVE*/
save        $outdata/fam1999,replace

*2001
u ER17002 ER17011 ER17004 ER17074 ER17075 ER17016 ER20371 ER17013 ER17015 ER20443 ER20422 ER20423 ER20420 ER20447 ER20444 ER20445 ER20449 ER20453 ER19183 ER20455 ER17046 ER18362 ER19162 ER19167 ER19161 ER18637 ER18638 ER18639 ER18640 ER18641 ER18642 ER18643 ER18644 ER18645 ER18646 ER18647 ER18648 ER18634 ER18635 ER18653 ER18654 ER18655 ER18656 ER18657 ER18658 ER18659 ER18660 ER18661 ER18662 ER18663 ER18664 ER18650 ER18651 ER18669 ER18670 ER18671 ER18672 ER18673 ER18674 ER18675 ER18676 ER18677 ER18678 ER18679 ER18680 ER18666 ER18667 ER18685 ER18686 ER18687 ER18688 ER18689 ER18690 ER18691 ER18692 ER18693 ER18694 ER18695 ER18696 ER18682 ER18683 ER18701 ER18702 ER18703 ER18704 ER18705 ER18706 ER18707 ER18708 ER18709 ER18710 ER18711 ER18712 ER18698 ER18699 ER18718 ER18719 ER18720 ER18721 ER18722 ER18723 ER18724 ER18725 ER18726 ER18727 ER18728 ER18729 ER18715 ER18716 ER18734 ER18735 ER18736 ER18737 ER18738 ER18739 ER18740 ER18741 ER18742 ER18743 ER18744 ER18745 ER18731 ER18732 ER18753 ER18754 ER18755 ER18756 ER18757 ER18758 ER18759 ER18760 ER18761 ER18762 ER18763 ER18764 ER18750 ER18751 ER18769 ER18770 ER18771 ER18772 ER18773 ER18774 ER18775 ER18776 ER18777 ER18778 ER18779 ER18780 ER18766 ER18767 ER18785 ER18786 ER18787 ER18788 ER18789 ER18790 ER18791 ER18792 ER18793 ER18794 ER18795 ER18796 ER18782 ER18783 ER18801 ER18802 ER18803 ER18804 ER18805 ER18806 ER18807 ER18808 ER18809 ER18810 ER18811 ER18812 ER18798 ER18799 ER18818 ER18819 ER18820 ER18821 ER18822 ER18823 ER18824 ER18825 ER18826 ER18827 ER18828 ER18829 ER18815 ER18816 ER18834 ER18835 ER18836 ER18837 ER18838 ER18839 ER18840 ER18841 ER18842 ER18843 ER18844 ER18845 ER18831 ER18832 ER18850 ER18851 ER18852 ER18853 ER18854 ER18855 ER18856 ER18857 ER18858 ER18859 ER18860 ER18861 ER18847 ER18848 ER18866 ER18867 ER18868 ER18869 ER18870 ER18871 ER18872 ER18873 ER18874 ER18875 ER18876 ER18877 ER18863 ER18864 ER18937 ER18938 ER18939 ER18940 ER18941 ER18942 ER18943 ER18944 ER18945 ER18946 ER18947 ER18948 ER18934 ER18935 ER18953 ER18954 ER18955 ER18956 ER18957 ER18958 ER18959 ER18960 ER18961 ER18962 ER18963 ER18964 ER18950 ER18951 ER18969 ER18970 ER18971 ER18972 ER18973 ER18974 ER18975 ER18976 ER18977 ER18978 ER18979 ER18980 ER18966 ER18967 ER18985 ER18986 ER18987 ER18988 ER18989 ER18990 ER18991 ER18992 ER18993 ER18994 ER18995 ER18996 ER18982 ER18983 ER19001 ER19002 ER19003 ER19004 ER19005 ER19006 ER19007 ER19008 ER19009 ER19010 ER19011 ER19012 ER18998 ER18999 ER19034 ER19035 ER19036 ER19037 ER19038 ER19039 ER19040 ER19041 ER19042 ER19043 ER19044 ER19045 ER19031 ER19032 ER19050 ER19051 ER19052 ER19053 ER19054 ER19055 ER19056 ER19057 ER19058 ER19059 ER19060 ER19061 ER19047 ER19048 ER19066 ER19067 ER19068 ER19069 ER19070 ER19071 ER19072 ER19073 ER19074 ER19075 ER19076 ER19077 ER19063 ER19064 ER19082 ER19083 ER19084 ER19085 ER19086 ER19087 ER19088 ER19089 ER19090 ER19091 ER19092 ER19093 ER19079 ER19080 ER19098 ER19099 ER19100 ER19101 ER19102 ER19103 ER19104 ER19105 ER19106 ER19107 ER19108 ER19109 ER19095 ER19096 using $psid_dir/Stata/fam2001er,clear
foreach X in 2001 {
rename ER17002 famno`X'
rename ER17011 intyr`X'
rename ER17004 state`X'
rename ER17074 rentpdamt`X'
rename ER17075 rentpdper`X'
rename ER17016 intnumchd`X'
rename ER20371 marstat`X'
rename ER17013 agehead`X'
rename ER17015 agewife`X'
rename ER20443 laborhd`X'
rename ER20422 buslabhd`X'
rename ER20423 busassethd`X'
rename ER20420 farm`X'
rename ER20447 laborwf`X'
rename ER20444 buslabwf`X'
rename ER20445 busassetwf`X'
rename ER20449 taxableinchdwf`X'
rename ER20453 taxableincofum`X'
rename ER19183 alimpdhd`X'
rename ER20455 socsecfam`X'
rename ER17046 proptx`X'
rename ER18362 c`X'childcaretotal
rename ER19162 chardeduc`X'
rename ER19167 meddeduc`X'
rename ER19161 itemize`X'

*2001 summing annual income amounts  
rename ER18637 hrnjan`X'
rename ER18638 hrnfeb`X'
rename ER18639 hrnmar`X'
rename ER18640 hrnapr`X'
rename ER18641 hrnmay`X'
rename ER18642 hrnjun`X'
rename ER18643 hrnjul`X'
rename ER18644 hrnaug`X'
rename ER18645 hrnsep`X'
rename ER18646 hrnoct`X'
rename ER18647 hrnnov`X'
rename ER18648 hrndec`X'
rename ER18634 hrnamount`X'
rename ER18635 hrnper`X'
rename ER18653 hdvjan`X'
rename ER18654 hdvfeb`X'
rename ER18655 hdvmar`X'
rename ER18656 hdvapr`X'
rename ER18657 hdvmay`X'
rename ER18658 hdvjun`X'
rename ER18659 hdvjul`X'
rename ER18660 hdvaug`X'
rename ER18661 hdvsep`X'
rename ER18662 hdvoct`X'
rename ER18663 hdvnov`X'
rename ER18664 hdvdec`X'
rename ER18650 hdvamount`X'
rename ER18651 hdvper`X'
rename ER18669 hinjan`X'
rename ER18670 hinfeb`X'
rename ER18671 hinmar`X'
rename ER18672 hinapr`X'
rename ER18673 hinmay`X'
rename ER18674 hinjun`X'
rename ER18675 hinjul`X'
rename ER18676 hinaug`X'
rename ER18677 hinsep`X'
rename ER18678 hinoct`X'
rename ER18679 hinnov`X'
rename ER18680 hindec`X'
rename ER18666 hinamount`X'
rename ER18667 hinper`X'
rename ER18685 htfjan`X'
rename ER18686 htffeb`X'
rename ER18687 htfmar`X'
rename ER18688 htfapr`X'
rename ER18689 htfmay`X'
rename ER18690 htfjun`X'
rename ER18691 htfjul`X'
rename ER18692 htfaug`X'
rename ER18693 htfsep`X'
rename ER18694 htfoct`X'
rename ER18695 htfnov`X'
rename ER18696 htfdec`X'
rename ER18682 htfamount`X'
rename ER18683 htfper`X'
rename ER18701 htnjan`X'
rename ER18702 htnfeb`X'
rename ER18703 htnmar`X'
rename ER18704 htnapr`X'
rename ER18705 htnmay`X'
rename ER18706 htnjun`X'
rename ER18707 htnjul`X'
rename ER18708 htnaug`X'
rename ER18709 htnsep`X'
rename ER18710 htnoct`X'
rename ER18711 htnnov`X'
rename ER18712 htndec`X'
rename ER18698 htnamount`X'
rename ER18699 htnper`X'
rename ER18718 hsijan`X'
rename ER18719 hsifeb`X'
rename ER18720 hsimar`X'
rename ER18721 hsiapr`X'
rename ER18722 hsimay`X'
rename ER18723 hsijun`X'
rename ER18724 hsijul`X'
rename ER18725 hsiaug`X'
rename ER18726 hsisep`X'
rename ER18727 hsioct`X'
rename ER18728 hsinov`X'
rename ER18729 hsidec`X'
rename ER18715 hsiamount`X'
rename ER18716 hsiper`X'
rename ER18734 howjan`X'
rename ER18735 howfeb`X'
rename ER18736 howmar`X'
rename ER18737 howapr`X'
rename ER18738 howmay`X'
rename ER18739 howjun`X'
rename ER18740 howjul`X'
rename ER18741 howaug`X'
rename ER18742 howsep`X'
rename ER18743 howoct`X'
rename ER18744 hownov`X'
rename ER18745 howdec`X'
rename ER18731 howamount`X'
rename ER18732 howper`X'
rename ER18753 hvajan`X'
rename ER18754 hvafeb`X'
rename ER18755 hvamar`X'
rename ER18756 hvaapr`X'
rename ER18757 hvamay`X'
rename ER18758 hvajun`X'
rename ER18759 hvajul`X'
rename ER18760 hvaaug`X'
rename ER18761 hvasep`X'
rename ER18762 hvaoct`X'
rename ER18763 hvanov`X'
rename ER18764 hvadec`X'
rename ER18750 hvaamount`X'
rename ER18751 hvaper`X'
rename ER18769 hrtjan`X'
rename ER18770 hrtfeb`X'
rename ER18771 hrtmar`X'
rename ER18772 hrtapr`X'
rename ER18773 hrtmay`X'
rename ER18774 hrtjun`X'
rename ER18775 hrtjul`X'
rename ER18776 hrtaug`X'
rename ER18777 hrtsep`X'
rename ER18778 hrtoct`X'
rename ER18779 hrtnov`X'
rename ER18780 hrtdec`X'
rename ER18766 hrtamount`X'
rename ER18767 hrtper`X'
rename ER18785 hanjan`X'
rename ER18786 hanfeb`X'
rename ER18787 hanmar`X'
rename ER18788 hanapr`X'
rename ER18789 hanmay`X'
rename ER18790 hanjun`X'
rename ER18791 hanjul`X'
rename ER18792 hanaug`X'
rename ER18793 hansep`X'
rename ER18794 hanoct`X'
rename ER18795 hannov`X'
rename ER18796 handec`X'
rename ER18782 hanamount`X'
rename ER18783 hanper`X'
rename ER18801 hopjan`X'
rename ER18802 hopfeb`X'
rename ER18803 hopmar`X'
rename ER18804 hopapr`X'
rename ER18805 hopmay`X'
rename ER18806 hopjun`X'
rename ER18807 hopjul`X'
rename ER18808 hopaug`X'
rename ER18809 hopsep`X'
rename ER18810 hopoct`X'
rename ER18811 hopnov`X'
rename ER18812 hopdec`X'
rename ER18798 hopamount`X'
rename ER18799 hopper`X'
rename ER18818 hunjan`X'
rename ER18819 hunfeb`X'
rename ER18820 hunmar`X'
rename ER18821 hunapr`X'
rename ER18822 hunmay`X'
rename ER18823 hunjun`X'
rename ER18824 hunjul`X'
rename ER18825 hunaug`X'
rename ER18826 hunsep`X'
rename ER18827 hunoct`X'
rename ER18828 hunnov`X'
rename ER18829 hundec`X'
rename ER18815 hunamount`X'
rename ER18816 hunper`X'
rename ER18834 hwcjan`X'
rename ER18835 hwcfeb`X'
rename ER18836 hwcmar`X'
rename ER18837 hwcapr`X'
rename ER18838 hwcmay`X'
rename ER18839 hwcjun`X'
rename ER18840 hwcjul`X'
rename ER18841 hwcaug`X'
rename ER18842 hwcsep`X'
rename ER18843 hwcoct`X'
rename ER18844 hwcnov`X'
rename ER18845 hwcdec`X'
rename ER18831 hwcamount`X'
rename ER18832 hwcper`X'
rename ER18850 hcsjan`X'
rename ER18851 hcsfeb`X'
rename ER18852 hcsmar`X'
rename ER18853 hcsapr`X'
rename ER18854 hcsmay`X'
rename ER18855 hcsjun`X'
rename ER18856 hcsjul`X'
rename ER18857 hcsaug`X'
rename ER18858 hcssep`X'
rename ER18859 hcsoct`X'
rename ER18860 hcsnov`X'
rename ER18861 hcsdec`X'
rename ER18847 hcsamount`X'
rename ER18848 hcsper`X'
rename ER18866 haljan`X'
rename ER18867 halfeb`X'
rename ER18868 halmar`X'
rename ER18869 halapr`X'
rename ER18870 halmay`X'
rename ER18871 haljun`X'
rename ER18872 haljul`X'
rename ER18873 halaug`X'
rename ER18874 halsep`X'
rename ER18875 haloct`X'
rename ER18876 halnov`X'
rename ER18877 haldec`X'
rename ER18863 halamount`X'
rename ER18864 halper`X'
rename ER18937 wunjan`X'
rename ER18938 wunfeb`X'
rename ER18939 wunmar`X'
rename ER18940 wunapr`X'
rename ER18941 wunmay`X'
rename ER18942 wunjun`X'
rename ER18943 wunjul`X'
rename ER18944 wunaug`X'
rename ER18945 wunsep`X'
rename ER18946 wunoct`X'
rename ER18947 wunnov`X'
rename ER18948 wundec`X'
rename ER18934 wunamount`X'
rename ER18935 wunper`X'
rename ER18953 wwcjan`X'
rename ER18954 wwcfeb`X'
rename ER18955 wwcmar`X'
rename ER18956 wwcapr`X'
rename ER18957 wwcmay`X'
rename ER18958 wwcjun`X'
rename ER18959 wwcjul`X'
rename ER18960 wwcaug`X'
rename ER18961 wwcsep`X'
rename ER18962 wwcoct`X'
rename ER18963 wwcnov`X'
rename ER18964 wwcdec`X'
rename ER18950 wwcamount`X'
rename ER18951 wwcper`X'
rename ER18969 wdvjan`X'
rename ER18970 wdvfeb`X'
rename ER18971 wdvmar`X'
rename ER18972 wdvapr`X'
rename ER18973 wdvmay`X'
rename ER18974 wdvjun`X'
rename ER18975 wdvjul`X'
rename ER18976 wdvaug`X'
rename ER18977 wdvsep`X'
rename ER18978 wdvoct`X'
rename ER18979 wdvnov`X'
rename ER18980 wdvdec`X'
rename ER18966 wdvamount`X'
rename ER18967 wdvper`X'
rename ER18985 winjan`X'
rename ER18986 winfeb`X'
rename ER18987 winmar`X'
rename ER18988 winapr`X'
rename ER18989 winmay`X'
rename ER18990 winjun`X'
rename ER18991 winjul`X'
rename ER18992 winaug`X'
rename ER18993 winsep`X'
rename ER18994 winoct`X'
rename ER18995 winnov`X'
rename ER18996 windec`X'
rename ER18982 winamount`X'
rename ER18983 winper`X'
rename ER19001 wtfjan`X'
rename ER19002 wtffeb`X'
rename ER19003 wtfmar`X'
rename ER19004 wtfapr`X'
rename ER19005 wtfmay`X'
rename ER19006 wtfjun`X'
rename ER19007 wtfjul`X'
rename ER19008 wtfaug`X'
rename ER19009 wtfsep`X'
rename ER19010 wtfoct`X'
rename ER19011 wtfnov`X'
rename ER19012 wtfdec`X'
rename ER18998 wtfamount`X'
rename ER18999 wtfper`X'
rename ER19034 wsijan`X'
rename ER19035 wsifeb`X'
rename ER19036 wsimar`X'
rename ER19037 wsiapr`X'
rename ER19038 wsimay`X'
rename ER19039 wsijun`X'
rename ER19040 wsijul`X'
rename ER19041 wsiaug`X'
rename ER19042 wsisep`X'
rename ER19043 wsioct`X'
rename ER19044 wsinov`X'
rename ER19045 wsidec`X'
rename ER19031 wsiamount`X'
rename ER19032 wsiper`X'
rename ER19050 wtnjan`X'
rename ER19051 wtnfeb`X'
rename ER19052 wtnmar`X'
rename ER19053 wtnapr`X'
rename ER19054 wtnmay`X'
rename ER19055 wtnjun`X'
rename ER19056 wtnjul`X'
rename ER19057 wtnaug`X'
rename ER19058 wtnsep`X'
rename ER19059 wtnoct`X'
rename ER19060 wtnnov`X'
rename ER19061 wtndec`X'
rename ER19047 wtnamount`X'
rename ER19048 wtnper`X'
rename ER19066 wcsjan`X'
rename ER19067 wcsfeb`X'
rename ER19068 wcsmar`X'
rename ER19069 wcsapr`X'
rename ER19070 wcsmay`X'
rename ER19071 wcsjun`X'
rename ER19072 wcsjul`X'
rename ER19073 wcsaug`X'
rename ER19074 wcssep`X'
rename ER19075 wcsoct`X'
rename ER19076 wcsnov`X'
rename ER19077 wcsdec`X'
rename ER19063 wcsamount`X'
rename ER19064 wcsper`X'
rename ER19082 wowjan`X'
rename ER19083 wowfeb`X'
rename ER19084 wowmar`X'
rename ER19085 wowapr`X'
rename ER19086 wowmay`X'
rename ER19087 wowjun`X'
rename ER19088 wowjul`X'
rename ER19089 wowaug`X'
rename ER19090 wowsep`X'
rename ER19091 wowoct`X'
rename ER19092 wownov`X'
rename ER19093 wowdec`X'
rename ER19079 wowamount`X'
rename ER19080 wowper`X'
rename ER19098 wpajan`X'
rename ER19099 wpafeb`X'
rename ER19100 wpamar`X'
rename ER19101 wpaapr`X'
rename ER19102 wpamay`X'
rename ER19103 wpajun`X'
rename ER19104 wpajul`X'
rename ER19105 wpaaug`X'
rename ER19106 wpasep`X'
rename ER19107 wpaoct`X'
rename ER19108 wpanov`X'
rename ER19109 wpadec`X'
rename ER19095 wpaamount`X'
rename ER19096 wpaper`X'
}
/*MERGE FAMILY DATA AND INDIVIDUAL DATA*/
merge 1:m famno2001 using $outdata/ind, keep ( using matched )
drop _m
sort personid
/*SAVE*/
save        $outdata/fam2001,replace

*2003
u ER21002 ER21014 ER21003 ER21072 ER21073 ER21020 ER24152 ER21017 ER21019 ER24116 ER24109 ER24110 ER24105 ER24135 ER24111 ER24112 ER24100 ER24102 ER22548 ER24104 ER21045 ER21628 ER22535 ER22536 ER22534 ER22007 ER22008 ER22009 ER22010 ER22011 ER22012 ER22013 ER22014 ER22015 ER22016 ER22017 ER22018 ER22003 ER22004 ER22024 ER22025 ER22026 ER22027 ER22028 ER22029 ER22030 ER22031 ER22032 ER22033 ER22034 ER22035 ER22020 ER22021 ER22041 ER22042 ER22043 ER22044 ER22045 ER22046 ER22047 ER22048 ER22049 ER22050 ER22051 ER22052 ER22037 ER22038 ER22057 ER22058 ER22059 ER22060 ER22061 ER22062 ER22063 ER22064 ER22065 ER22066 ER22067 ER22068 ER22054 ER22055 ER22073 ER22074 ER22075 ER22076 ER22077 ER22078 ER22079 ER22080 ER22081 ER22082 ER22083 ER22084 ER22070 ER22071 ER22090 ER22091 ER22092 ER22093 ER22094 ER22095 ER22096 ER22097 ER22098 ER22099 ER22100 ER22101 ER22087 ER22088 ER22106 ER22107 ER22108 ER22109 ER22110 ER22111 ER22112 ER22113 ER22114 ER22115 ER22116 ER22117 ER22103 ER22104 ER22123 ER22124 ER22125 ER22126 ER22127 ER22128 ER22129 ER22130 ER22131 ER22132 ER22133 ER22134 ER22120 ER22121 ER22139 ER22140 ER22141 ER22142 ER22143 ER22144 ER22145 ER22146 ER22147 ER22148 ER22149 ER22150 ER22136 ER22137 ER22155 ER22156 ER22157 ER22158 ER22159 ER22160 ER22161 ER22162 ER22163 ER22164 ER22165 ER22166 ER22152 ER22153 ER22171 ER22172 ER22173 ER22174 ER22175 ER22176 ER22177 ER22178 ER22179 ER22180 ER22181 ER22182 ER22168 ER22169 ER22188 ER22189 ER22190 ER22191 ER22192 ER22193 ER22194 ER22195 ER22196 ER22197 ER22198 ER22199 ER22185 ER22186 ER22204 ER22205 ER22206 ER22207 ER22208 ER22209 ER22210 ER22211 ER22212 ER22213 ER22214 ER22215 ER22201 ER22202 ER22220 ER22221 ER22222 ER22223 ER22224 ER22225 ER22226 ER22227 ER22228 ER22229 ER22230 ER22231 ER22217 ER22218 ER22236 ER22237 ER22238 ER22239 ER22240 ER22241 ER22242 ER22243 ER22244 ER22245 ER22246 ER22247 ER22233 ER22234 ER22307 ER22308 ER22309 ER22310 ER22311 ER22312 ER22313 ER22314 ER22315 ER22316 ER22317 ER22318 ER22304 ER22305 ER22323 ER22324 ER22325 ER22326 ER22327 ER22328 ER22329 ER22330 ER22331 ER22332 ER22333 ER22334 ER22320 ER22321 ER22357 ER22358 ER22359 ER22360 ER22361 ER22362 ER22363 ER22364 ER22365 ER22366 ER22367 ER22368 ER22353 ER22354 ER22374 ER22375 ER22376 ER22377 ER22378 ER22379 ER22380 ER22381 ER22382 ER22383 ER22384 ER22385 ER22370 ER22371 ER22390 ER22391 ER22392 ER22393 ER22394 ER22395 ER22396 ER22397 ER22398 ER22399 ER22400 ER22401 ER22387 ER22388 ER22407 ER22408 ER22409 ER22410 ER22411 ER22412 ER22413 ER22414 ER22415 ER22416 ER22417 ER22418 ER22404 ER22405 ER22423 ER22424 ER22425 ER22426 ER22427 ER22428 ER22429 ER22430 ER22431 ER22432 ER22433 ER22434 ER22420 ER22421 ER22439 ER22440 ER22441 ER22442 ER22443 ER22444 ER22445 ER22446 ER22447 ER22448 ER22449 ER22450 ER22436 ER22437 ER22455 ER22456 ER22457 ER22458 ER22459 ER22460 ER22461 ER22462 ER22463 ER22464 ER22465 ER22466 ER22452 ER22453 ER22471 ER22472 ER22473 ER22474 ER22475 ER22476 ER22477 ER22478 ER22479 ER22480 ER22481 ER22482 ER22468 ER22469 ER22340 ER22341 ER22342 ER22343 ER22344 ER22345 ER22346 ER22347 ER22348 ER22349 ER22350 ER22351 ER22336 ER22337 using  $psid_dir/Stata/fam2003er,clear
foreach X in 2003 {
rename ER21002 famno`X'
rename ER21014 intyr`X'
rename ER21003 state`X'
rename ER21072 rentpdamt`X'
rename ER21073 rentpdper`X'
rename ER21020 intnumchd`X'
rename ER24152 marstat`X'
rename ER21017 agehead`X'
rename ER21019 agewife`X'
rename ER24116 laborhd`X'
rename ER24109 buslabhd`X'
rename ER24110 busassethd`X'
rename ER24105 farm`X'
rename ER24135 laborwf`X'
rename ER24111 buslabwf`X'
rename ER24112 busassetwf`X'
rename ER24100 taxableinchdwf`X'
rename ER24102 taxableincofum`X'
rename ER22548 alimpdhd`X'
rename ER24104 socsecfam`X'
rename ER21045 proptx`X'
rename ER21628 c`X'childcaretotal
rename ER22535 chardeduc`X'
rename ER22536 meddeduc`X'
rename ER22534 itemize`X'

*2003 summing annual income amounts  
rename ER22007 hrnjan`X'
rename ER22008 hrnfeb`X'
rename ER22009 hrnmar`X'
rename ER22010 hrnapr`X'
rename ER22011 hrnmay`X'
rename ER22012 hrnjun`X'
rename ER22013 hrnjul`X'
rename ER22014 hrnaug`X'
rename ER22015 hrnsep`X'
rename ER22016 hrnoct`X'
rename ER22017 hrnnov`X'
rename ER22018 hrndec`X'
rename ER22003 hrnamount`X'
rename ER22004 hrnper`X'
rename ER22024 hdvjan`X'
rename ER22025 hdvfeb`X'
rename ER22026 hdvmar`X'
rename ER22027 hdvapr`X'
rename ER22028 hdvmay`X'
rename ER22029 hdvjun`X'
rename ER22030 hdvjul`X'
rename ER22031 hdvaug`X'
rename ER22032 hdvsep`X'
rename ER22033 hdvoct`X'
rename ER22034 hdvnov`X'
rename ER22035 hdvdec`X'
rename ER22020 hdvamount`X'
rename ER22021 hdvper`X'
rename ER22041 hinjan`X'
rename ER22042 hinfeb`X'
rename ER22043 hinmar`X'
rename ER22044 hinapr`X'
rename ER22045 hinmay`X'
rename ER22046 hinjun`X'
rename ER22047 hinjul`X'
rename ER22048 hinaug`X'
rename ER22049 hinsep`X'
rename ER22050 hinoct`X'
rename ER22051 hinnov`X'
rename ER22052 hindec`X'
rename ER22037 hinamount`X'
rename ER22038 hinper`X'
rename ER22057 htfjan`X'
rename ER22058 htffeb`X'
rename ER22059 htfmar`X'
rename ER22060 htfapr`X'
rename ER22061 htfmay`X'
rename ER22062 htfjun`X'
rename ER22063 htfjul`X'
rename ER22064 htfaug`X'
rename ER22065 htfsep`X'
rename ER22066 htfoct`X'
rename ER22067 htfnov`X'
rename ER22068 htfdec`X'
rename ER22054 htfamount`X'
rename ER22055 htfper`X'
rename ER22073 htnjan`X'
rename ER22074 htnfeb`X'
rename ER22075 htnmar`X'
rename ER22076 htnapr`X'
rename ER22077 htnmay`X'
rename ER22078 htnjun`X'
rename ER22079 htnjul`X'
rename ER22080 htnaug`X'
rename ER22081 htnsep`X'
rename ER22082 htnoct`X'
rename ER22083 htnnov`X'
rename ER22084 htndec`X'
rename ER22070 htnamount`X'
rename ER22071 htnper`X'
rename ER22090 hsijan`X'
rename ER22091 hsifeb`X'
rename ER22092 hsimar`X'
rename ER22093 hsiapr`X'
rename ER22094 hsimay`X'
rename ER22095 hsijun`X'
rename ER22096 hsijul`X'
rename ER22097 hsiaug`X'
rename ER22098 hsisep`X'
rename ER22099 hsioct`X'
rename ER22100 hsinov`X'
rename ER22101 hsidec`X'
rename ER22087 hsiamount`X'
rename ER22088 hsiper`X'
rename ER22106 howjan`X'
rename ER22107 howfeb`X'
rename ER22108 howmar`X'
rename ER22109 howapr`X'
rename ER22110 howmay`X'
rename ER22111 howjun`X'
rename ER22112 howjul`X'
rename ER22113 howaug`X'
rename ER22114 howsep`X'
rename ER22115 howoct`X'
rename ER22116 hownov`X'
rename ER22117 howdec`X'
rename ER22103 howamount`X'
rename ER22104 howper`X'
rename ER22123 hvajan`X'
rename ER22124 hvafeb`X'
rename ER22125 hvamar`X'
rename ER22126 hvaapr`X'
rename ER22127 hvamay`X'
rename ER22128 hvajun`X'
rename ER22129 hvajul`X'
rename ER22130 hvaaug`X'
rename ER22131 hvasep`X'
rename ER22132 hvaoct`X'
rename ER22133 hvanov`X'
rename ER22134 hvadec`X'
rename ER22120 hvaamount`X'
rename ER22121 hvaper`X'
rename ER22139 hrtjan`X'
rename ER22140 hrtfeb`X'
rename ER22141 hrtmar`X'
rename ER22142 hrtapr`X'
rename ER22143 hrtmay`X'
rename ER22144 hrtjun`X'
rename ER22145 hrtjul`X'
rename ER22146 hrtaug`X'
rename ER22147 hrtsep`X'
rename ER22148 hrtoct`X'
rename ER22149 hrtnov`X'
rename ER22150 hrtdec`X'
rename ER22136 hrtamount`X'
rename ER22137 hrtper`X'
rename ER22155 hanjan`X'
rename ER22156 hanfeb`X'
rename ER22157 hanmar`X'
rename ER22158 hanapr`X'
rename ER22159 hanmay`X'
rename ER22160 hanjun`X'
rename ER22161 hanjul`X'
rename ER22162 hanaug`X'
rename ER22163 hansep`X'
rename ER22164 hanoct`X'
rename ER22165 hannov`X'
rename ER22166 handec`X'
rename ER22152 hanamount`X'
rename ER22153 hanper`X'
rename ER22171 hopjan`X'
rename ER22172 hopfeb`X'
rename ER22173 hopmar`X'
rename ER22174 hopapr`X'
rename ER22175 hopmay`X'
rename ER22176 hopjun`X'
rename ER22177 hopjul`X'
rename ER22178 hopaug`X'
rename ER22179 hopsep`X'
rename ER22180 hopoct`X'
rename ER22181 hopnov`X'
rename ER22182 hopdec`X'
rename ER22168 hopamount`X'
rename ER22169 hopper`X'
rename ER22188 hunjan`X'
rename ER22189 hunfeb`X'
rename ER22190 hunmar`X'
rename ER22191 hunapr`X'
rename ER22192 hunmay`X'
rename ER22193 hunjun`X'
rename ER22194 hunjul`X'
rename ER22195 hunaug`X'
rename ER22196 hunsep`X'
rename ER22197 hunoct`X'
rename ER22198 hunnov`X'
rename ER22199 hundec`X'
rename ER22185 hunamount`X'
rename ER22186 hunper`X'
rename ER22204 hwcjan`X'
rename ER22205 hwcfeb`X'
rename ER22206 hwcmar`X'
rename ER22207 hwcapr`X'
rename ER22208 hwcmay`X'
rename ER22209 hwcjun`X'
rename ER22210 hwcjul`X'
rename ER22211 hwcaug`X'
rename ER22212 hwcsep`X'
rename ER22213 hwcoct`X'
rename ER22214 hwcnov`X'
rename ER22215 hwcdec`X'
rename ER22201 hwcamount`X'
rename ER22202 hwcper`X'
rename ER22220 hcsjan`X'
rename ER22221 hcsfeb`X'
rename ER22222 hcsmar`X'
rename ER22223 hcsapr`X'
rename ER22224 hcsmay`X'
rename ER22225 hcsjun`X'
rename ER22226 hcsjul`X'
rename ER22227 hcsaug`X'
rename ER22228 hcssep`X'
rename ER22229 hcsoct`X'
rename ER22230 hcsnov`X'
rename ER22231 hcsdec`X'
rename ER22217 hcsamount`X'
rename ER22218 hcsper`X'
rename ER22236 haljan`X'
rename ER22237 halfeb`X'
rename ER22238 halmar`X'
rename ER22239 halapr`X'
rename ER22240 halmay`X'
rename ER22241 haljun`X'
rename ER22242 haljul`X'
rename ER22243 halaug`X'
rename ER22244 halsep`X'
rename ER22245 haloct`X'
rename ER22246 halnov`X'
rename ER22247 haldec`X'
rename ER22233 halamount`X'
rename ER22234 halper`X'
rename ER22307 wunjan`X'
rename ER22308 wunfeb`X'
rename ER22309 wunmar`X'
rename ER22310 wunapr`X'
rename ER22311 wunmay`X'
rename ER22312 wunjun`X'
rename ER22313 wunjul`X'
rename ER22314 wunaug`X'
rename ER22315 wunsep`X'
rename ER22316 wunoct`X'
rename ER22317 wunnov`X'
rename ER22318 wundec`X'
rename ER22304 wunamount`X'
rename ER22305 wunper`X'
rename ER22323 wwcjan`X'
rename ER22324 wwcfeb`X'
rename ER22325 wwcmar`X'
rename ER22326 wwcapr`X'
rename ER22327 wwcmay`X'
rename ER22328 wwcjun`X'
rename ER22329 wwcjul`X'
rename ER22330 wwcaug`X'
rename ER22331 wwcsep`X'
rename ER22332 wwcoct`X'
rename ER22333 wwcnov`X'
rename ER22334 wwcdec`X'
rename ER22320 wwcamount`X'
rename ER22321 wwcper`X'
rename ER22357 wdvjan`X'
rename ER22358 wdvfeb`X'
rename ER22359 wdvmar`X'
rename ER22360 wdvapr`X'
rename ER22361 wdvmay`X'
rename ER22362 wdvjun`X'
rename ER22363 wdvjul`X'
rename ER22364 wdvaug`X'
rename ER22365 wdvsep`X'
rename ER22366 wdvoct`X'
rename ER22367 wdvnov`X'
rename ER22368 wdvdec`X'
rename ER22353 wdvamount`X'
rename ER22354 wdvper`X'
rename ER22374 winjan`X'
rename ER22375 winfeb`X'
rename ER22376 winmar`X'
rename ER22377 winapr`X'
rename ER22378 winmay`X'
rename ER22379 winjun`X'
rename ER22380 winjul`X'
rename ER22381 winaug`X'
rename ER22382 winsep`X'
rename ER22383 winoct`X'
rename ER22384 winnov`X'
rename ER22385 windec`X'
rename ER22370 winamount`X'
rename ER22371 winper`X'
rename ER22390 wtfjan`X'
rename ER22391 wtffeb`X'
rename ER22392 wtfmar`X'
rename ER22393 wtfapr`X'
rename ER22394 wtfmay`X'
rename ER22395 wtfjun`X'
rename ER22396 wtfjul`X'
rename ER22397 wtfaug`X'
rename ER22398 wtfsep`X'
rename ER22399 wtfoct`X'
rename ER22400 wtfnov`X'
rename ER22401 wtfdec`X'
rename ER22387 wtfamount`X'
rename ER22388 wtfper`X'
rename ER22407 wsijan`X'
rename ER22408 wsifeb`X'
rename ER22409 wsimar`X'
rename ER22410 wsiapr`X'
rename ER22411 wsimay`X'
rename ER22412 wsijun`X'
rename ER22413 wsijul`X'
rename ER22414 wsiaug`X'
rename ER22415 wsisep`X'
rename ER22416 wsioct`X'
rename ER22417 wsinov`X'
rename ER22418 wsidec`X'
rename ER22404 wsiamount`X'
rename ER22405 wsiper`X'
rename ER22423 wtnjan`X'
rename ER22424 wtnfeb`X'
rename ER22425 wtnmar`X'
rename ER22426 wtnapr`X'
rename ER22427 wtnmay`X'
rename ER22428 wtnjun`X'
rename ER22429 wtnjul`X'
rename ER22430 wtnaug`X'
rename ER22431 wtnsep`X'
rename ER22432 wtnoct`X'
rename ER22433 wtnnov`X'
rename ER22434 wtndec`X'
rename ER22420 wtnamount`X'
rename ER22421 wtnper`X'
rename ER22439 wcsjan`X'
rename ER22440 wcsfeb`X'
rename ER22441 wcsmar`X'
rename ER22442 wcsapr`X'
rename ER22443 wcsmay`X'
rename ER22444 wcsjun`X'
rename ER22445 wcsjul`X'
rename ER22446 wcsaug`X'
rename ER22447 wcssep`X'
rename ER22448 wcsoct`X'
rename ER22449 wcsnov`X'
rename ER22450 wcsdec`X'
rename ER22436 wcsamount`X'
rename ER22437 wcsper`X'
rename ER22455 wowjan`X'
rename ER22456 wowfeb`X'
rename ER22457 wowmar`X'
rename ER22458 wowapr`X'
rename ER22459 wowmay`X'
rename ER22460 wowjun`X'
rename ER22461 wowjul`X'
rename ER22462 wowaug`X'
rename ER22463 wowsep`X'
rename ER22464 wowoct`X'
rename ER22465 wownov`X'
rename ER22466 wowdec`X'
rename ER22452 wowamount`X'
rename ER22453 wowper`X'
rename ER22471 wpajan`X'
rename ER22472 wpafeb`X'
rename ER22473 wpamar`X'
rename ER22474 wpaapr`X'
rename ER22475 wpamay`X'
rename ER22476 wpajun`X'
rename ER22477 wpajul`X'
rename ER22478 wpaaug`X'
rename ER22479 wpasep`X'
rename ER22480 wpaoct`X'
rename ER22481 wpanov`X'
rename ER22482 wpadec`X'
rename ER22468 wpaamount`X'
rename ER22469 wpaper`X'
rename ER22340 wrnjan`X'
rename ER22341 wrnfeb`X'
rename ER22342 wrnmar`X'
rename ER22343 wrnapr`X'
rename ER22344 wrnmay`X'
rename ER22345 wrnjun`X'
rename ER22346 wrnjul`X'
rename ER22347 wrnaug`X'
rename ER22348 wrnsep`X'
rename ER22349 wrnoct`X'
rename ER22350 wrnnov`X'
rename ER22351 wrndec`X'
rename ER22336 wrnamount`X'
rename ER22337 wrnper`X'
}
/*MERGE FAMILY DATA AND INDIVIDUAL DATA*/
merge 1:m famno2003 using $outdata/ind, keep ( using matched )
drop _m
sort personid
/*SAVE*/
save        $outdata/fam2003,replace

*2005
u ER25002 ER25014 ER25003 ER25063 ER25064 ER25020 ER28051 ER25017 ER25019 ER27931 ER27910 ER27911 ER27908 ER27943 ER27940 ER27941 ER27953 ER28009 ER28005 ER28007 ER27936 ER27932 ER27938 ER27974 ER27964 ER27934 ER26529 ER27949 ER27945 ER27951 ER27947 ER27962 ER27966 ER27988 ER28018 ER28031 ER28033 ER28035 ER27954 ER27956 ER27958 ER27960 ER27970 ER27972 ER27982 ER27984 ER27986 ER27992 ER27994 ER25036 ER25628 ER27968 ER27990 ER28020 ER26516 ER26517 ER26515 using  $psid_dir/Stata/fam2005er,clear
foreach X in 2005 {
rename ER25002 famno`X'
rename ER25014 intyr`X'
rename ER25003 state`X'
rename ER25063 rentpdamt`X'
rename ER25064 rentpdper`X'
rename ER25020 intnumchd`X'
rename ER28051 marstat`X'
rename ER25017 agehead`X'
rename ER25019 agewife`X'
rename ER27931 laborhd`X'
rename ER27910 buslabhd`X'
rename ER27911 busassethd`X'
rename ER27908 farm`X'
rename ER27943 laborwf`X'
rename ER27940 buslabwf`X'
rename ER27941 busassetwf`X'
rename ER27953 taxableinchdwf`X'
rename ER28009 taxableincofum`X'
rename ER28005 labincofum`X'
rename ER28007 assetincofum`X'
rename ER27936 c`X'hintotal
rename ER27932 c`X'hrntotal
rename ER27938 c`X'htftotal
rename ER27974 c`X'haltotal
rename ER27964 c`X'hantotal
rename ER27934 c`X'hdvtotal
rename ER26529 alimpdhd`X'
rename ER27949 c`X'wintotal
rename ER27945 c`X'wrntotal
rename ER27951 c`X'wtftotal
rename ER27947 c`X'wdvtotal
rename ER27962 c`X'hrttotal
rename ER27966 c`X'hoptotal
rename ER27988 c`X'wpatotal
rename ER28018 retirofum`X'
rename ER28031 socsechd`X'
rename ER28033 socsecwf`X'
rename ER28035 socsecofum`X'
rename ER27954 c`X'htntotal
rename ER27956 c`X'hsitotal
rename ER27958 c`X'howtotal
rename ER27960 c`X'hvatotal
rename ER27970 c`X'hwctotal
rename ER27972 c`X'hcstotal
rename ER27982 c`X'wtntotal
rename ER27984 c`X'wsitotal
rename ER27986 c`X'wowtotal
rename ER27992 c`X'wwctotal
rename ER27994 c`X'wcstotal
rename ER25036 proptx`X'
rename ER25628 c`X'childcaretotal
rename ER27968 c`X'huntotal
rename ER27990 c`X'wuntotal
rename ER28020 unempofum`X'
rename ER26516 chardeduc`X'
rename ER26517 meddeduc`X'
rename ER26515 itemize`X'
}
/*MERGE FAMILY DATA AND INDIVIDUAL DATA*/
merge 1:m famno2005 using $outdata/ind, keep ( using matched )
drop _m
sort personid
/*SAVE*/
save        $outdata/fam2005,replace

*2007
u ER36002 ER36014 ER36003 ER36065 ER36066 ER36020 ER41041 ER36017 ER36019 ER40921 ER40900 ER40901 ER40898 ER40933 ER40930 ER40931 ER40943 ER40999 ER40995 ER40997 ER40926 ER40922 ER40928 ER40964 ER40954 ER40924 ER37547 ER40939 ER40935 ER40941 ER40937 ER40952 ER40956 ER40978 ER41008 ER41021 ER41023 ER41025 ER40944 ER40946 ER40948 ER40950 ER40960 ER40962 ER40972 ER40974 ER40976 ER40982 ER40984 ER36036 ER36633 ER36634 ER40958 ER40980 ER41010 ER37534 ER37535 ER37533 using  $psid_dir/Stata/fam2007er,clear
foreach X in 2007 {
rename ER36002 famno`X'
rename ER36014 intyr`X'
rename ER36003 state`X'
rename ER36065 rentpdamt`X'
rename ER36066 rentpdper`X'
rename ER36020 intnumchd`X'
rename ER41041 marstat`X'
rename ER36017 agehead`X'
rename ER36019 agewife`X'
rename ER40921 laborhd`X'
rename ER40900 buslabhd`X'
rename ER40901 busassethd`X'
rename ER40898 farm`X'
rename ER40933 laborwf`X'
rename ER40930 buslabwf`X'
rename ER40931 busassetwf`X'
rename ER40943 taxableinchdwf`X'
rename ER40999 taxableincofum`X'
rename ER40995 labincofum`X'
rename ER40997 assetincofum`X'
rename ER40926 c`X'hintotal
rename ER40922 c`X'hrntotal
rename ER40928 c`X'htftotal
rename ER40964 c`X'haltotal
rename ER40954 c`X'hantotal
rename ER40924 c`X'hdvtotal
rename ER37547 alimpdhd`X'
rename ER40939 c`X'wintotal
rename ER40935 c`X'wrntotal
rename ER40941 c`X'wtftotal
rename ER40937 c`X'wdvtotal
rename ER40952 c`X'hrttotal
rename ER40956 c`X'hoptotal
rename ER40978 c`X'wpatotal
rename ER41008 retirofum`X'
rename ER41021 socsechd`X'
rename ER41023 socsecwf`X'
rename ER41025 socsecofum`X'
rename ER40944 c`X'htntotal
rename ER40946 c`X'hsitotal
rename ER40948 c`X'howtotal
rename ER40950 c`X'hvatotal
rename ER40960 c`X'hwctotal
rename ER40962 c`X'hcstotal
rename ER40972 c`X'wtntotal
rename ER40974 c`X'wsitotal
rename ER40976 c`X'wowtotal
rename ER40982 c`X'wwctotal
rename ER40984 c`X'wcstotal
rename ER36036 proptx`X'
rename ER36633 childcare`X'
rename ER36634 childcareper`X'
rename ER40958 c`X'huntotal
rename ER40980 c`X'wuntotal
rename ER41010 unempofum`X'
rename ER37534 chardeduc`X'
rename ER37535 meddeduc`X'
rename ER37533 itemize`X'
}
/*MERGE FAMILY DATA AND INDIVIDUAL DATA*/
merge 1:m famno2007 using $outdata/ind, keep ( using matched )
drop _m
sort personid
/*SAVE*/
save        $outdata/fam2007,replace

*2009
u ER42002 ER42014 ER42003 ER42080 ER42081 ER42020 ER46985 ER42017 ER42019 ER46829 ER46808 ER46809 ER46806 ER46841 ER46838 ER46839 ER46851 ER46907 ER46903 ER46905 ER46834 ER46830 ER46836 ER46872 ER46862 ER46832 ER43538 ER46847 ER46843 ER46849 ER46845 ER46860 ER46864 ER46886 ER46916 ER46929 ER46931 ER46933 ER46852 ER46854 ER46856 ER46858 ER46868 ER46870 ER46880 ER46882 ER46884 ER46890 ER46892 ER42037 ER42652 ER42653 ER46866 ER46888 ER46918 ER43525 ER43526 ER43524 using  $psid_dir/Stata/fam2009er,clear
foreach X in 2009 {
rename ER42002 famno`X'
rename ER42014 intyr`X'
rename ER42003 state`X'
rename ER42080 rentpdamt`X'
rename ER42081 rentpdper`X'
rename ER42020 intnumchd`X'
rename ER46985 marstat`X'
rename ER42017 agehead`X'
rename ER42019 agewife`X'
rename ER46829 laborhd`X'
rename ER46808 buslabhd`X'
rename ER46809 busassethd`X'
rename ER46806 farm`X'
rename ER46841 laborwf`X'
rename ER46838 buslabwf`X'
rename ER46839 busassetwf`X'
rename ER46851 taxableinchdwf`X'
rename ER46907 taxableincofum`X'
rename ER46903 labincofum`X'
rename ER46905 assetincofum`X'
rename ER46834 c`X'hintotal
rename ER46830 c`X'hrntotal
rename ER46836 c`X'htftotal
rename ER46872 c`X'haltotal
rename ER46862 c`X'hantotal
rename ER46832 c`X'hdvtotal
rename ER43538 alimpdhd`X'
rename ER46847 c`X'wintotal
rename ER46843 c`X'wrntotal
rename ER46849 c`X'wtftotal
rename ER46845 c`X'wdvtotal
rename ER46860 c`X'hrttotal
rename ER46864 c`X'hoptotal
rename ER46886 c`X'wpatotal
rename ER46916 retirofum`X'
rename ER46929 socsechd`X'
rename ER46931 socsecwf`X'
rename ER46933 socsecofum`X'
rename ER46852 c`X'htntotal
rename ER46854 c`X'hsitotal
rename ER46856 c`X'howtotal
rename ER46858 c`X'hvatotal
rename ER46868 c`X'hwctotal
rename ER46870 c`X'hcstotal
rename ER46880 c`X'wtntotal
rename ER46882 c`X'wsitotal
rename ER46884 c`X'wowtotal
rename ER46890 c`X'wwctotal
rename ER46892 c`X'wcstotal
rename ER42037 proptx`X'
rename ER42652 childcare`X'
rename ER42653 childcareper`X'
rename ER46866 c`X'huntotal
rename ER46888 c`X'wuntotal
rename ER46918 unempofum`X'
rename ER43525 chardeduc`X'
rename ER43526 meddeduc`X'
rename ER43524 itemize`X'
}
/*MERGE FAMILY DATA AND INDIVIDUAL DATA*/
merge 1:m famno2009 using $outdata/ind, keep ( using matched )
drop _m
sort personid
/*SAVE*/
save        $outdata/fam2009,replace

*2011
u ER47302 ER47314 ER47303 ER47387 ER47388 ER47320 ER52409 ER47317 ER47319 ER52237 ER52216 ER52217 ER52214 ER52249 ER52246 ER52247 ER52259 ER52315 ER52311 ER52313 ER52242 ER52238 ER52244 ER52280 ER52270 ER52240 ER48863 ER52255 ER52251 ER52257 ER52253 ER52268 ER52272 ER52294 ER52324 ER52337 ER52339 ER52341 ER52260 ER52262 ER52264 ER52266 ER52276 ER52278 ER52288 ER52290 ER52292 ER52298 ER52300 ER47342 ER47970 ER47971 ER52274 ER52296 ER52326 ER48850 ER48851 ER48849 using  $psid_dir/Stata/fam2011er,clear
foreach X in 2011 {
rename ER47302 famno`X'
rename ER47314 intyr`X'
rename ER47303 state`X'
rename ER47387 rentpdamt`X'
rename ER47388 rentpdper`X'
rename ER47320 intnumchd`X'
rename ER52409 marstat`X'
rename ER47317 agehead`X'
rename ER47319 agewife`X'
rename ER52237 laborhd`X'
rename ER52216 buslabhd`X'
rename ER52217 busassethd`X'
rename ER52214 farm`X'
rename ER52249 laborwf`X'
rename ER52246 buslabwf`X'
rename ER52247 busassetwf`X'
rename ER52259 taxableinchdwf`X'
rename ER52315 taxableincofum`X'
rename ER52311 labincofum`X'
rename ER52313 assetincofum`X'
rename ER52242 c`X'hintotal
rename ER52238 c`X'hrntotal
rename ER52244 c`X'htftotal
rename ER52280 c`X'haltotal
rename ER52270 c`X'hantotal
rename ER52240 c`X'hdvtotal
rename ER48863 alimpdhd`X'
rename ER52255 c`X'wintotal
rename ER52251 c`X'wrntotal
rename ER52257 c`X'wtftotal
rename ER52253 c`X'wdvtotal
rename ER52268 c`X'hrttotal
rename ER52272 c`X'hoptotal
rename ER52294 c`X'wpatotal
rename ER52324 retirofum`X'
rename ER52337 socsechd`X'
rename ER52339 socsecwf`X'
rename ER52341 socsecofum`X'
rename ER52260 c`X'htntotal
rename ER52262 c`X'hsitotal
rename ER52264 c`X'howtotal
rename ER52266 c`X'hvatotal
rename ER52276 c`X'hwctotal
rename ER52278 c`X'hcstotal
rename ER52288 c`X'wtntotal
rename ER52290 c`X'wsitotal
rename ER52292 c`X'wowtotal
rename ER52298 c`X'wwctotal
rename ER52300 c`X'wcstotal
rename ER47342 proptx`X'
rename ER47970 childcare`X'
rename ER47971 childcareper`X'
rename ER52274 c`X'huntotal
rename ER52296 c`X'wuntotal
rename ER52326 unempofum`X'
rename ER48850 chardeduc`X'
rename ER48851 meddeduc`X'
rename ER48849 itemize`X'
}

/*MERGE FAMILY DATA AND INDIVIDUAL DATA*/
merge 1:m famno2011 using $outdata/ind, keep ( using matched )
drop _m
sort personid
/*SAVE*/
save        $outdata/fam2011,replace

/*MERGE FAMILY DATA*/
use $outdata/fam1997, clear
foreach i in 1999 2001 2003 2005 2007 2009 2011 {
merge 1:1 personid using $outdata/fam`i', nogen
}

/*DELETE OLD FAMILY DATA*/
foreach i in 1997 1999 2001 2003 2005 2007 2009 2011 {
rm $outdata/fam`i'.dta
}

/*SAVE FAMILY AND INDIVIDUAL DATA*/
save "$outdata/taxes_var_$datestamp", replace

* Merging in mortgage interest deduction values and personid from other dofile
merge 1:1 ER30001 ER30002 using "$outdata/mortint_output_111814"
drop _merge
save "$outdata/taxes_var_$datestamp", replace

*SETTING MISSING VALUES

*1999 ֠2001 ֠2003 ֠2005 ֠2007 ֠2009 - 2011

foreach X in 1999 2001 2003 2005 2007 2009 2011 {

* Missing = 8 or 9
mvdecode rentpdper`X' itemize`X', ///
mv(8=. \ 9=.)

* Missing = 98 or 99
mvdecode immleghd1997 immleghd1999 immlegwf1997 immlegwf1999, ///
mv(98=. \ 99=.)

* Missing = 99
mvdecode state`X', /// 
mv(99=.)

*Missing = 999
mvdecode agehead`X' agewife`X' intage`X', ///
mv(999=.)

*Missing = 9999
mvdecode yearborn`X' moveyr`X', ///
mv(9999=.)

* Missing = 99,998 or 99,999 (99K)
mvdecode rentpdamt`X' proptx`X', ///
mv(99998=. \ 99999=.)

* Missing = 999,998 or 999,999 (999K)
mvdecode  chardeduc`X' meddeduc`X', /// 
mv(999998=. \ 999999=.)

*Missing = 9,999,998 or 9,999,999 (9M)
mvdecode alimpdhd`X', /// 
mv(9999998=. \ 9999999=.)
}

*1999 ֠2001 - 2003 only
foreach X in 1999 2001 2003 {

* Missing =9
mvdecode hrnjan`X' hrnfeb`X' hrnmar`X' hrnapr`X' hrnmay`X' hrnjun`X' hrnjul`X' hrnaug`X' hrnsep`X' hrnoct`X' hrnnov`X' hrndec`X' ///
hdvjan`X' hdvfeb`X' hdvmar`X' hdvapr`X' hdvmay`X' hdvjun`X' hdvjul`X' hdvaug`X' hdvsep`X' hdvoct`X' hdvnov`X' hdvdec`X' ///
hinjan`X' hinfeb`X' hinmar`X' hinapr`X' hinmay`X' hinjun`X' hinjul`X' hinaug`X' hinsep`X' hinoct`X' hinnov`X' hindec`X' ///
htfjan`X' htffeb`X' htfmar`X' htfapr`X' htfmay`X' htfjun`X' htfjul`X' htfaug`X' htfsep`X' htfoct`X' htfnov`X' htfdec`X' ///
htnjan`X' htnfeb`X' htnmar`X' htnapr`X' htnmay`X' htnjun`X' htnjul`X' htnaug`X' htnsep`X' htnoct`X' htnnov`X' htndec`X' ///
hsijan`X' hsifeb`X' hsimar`X' hsiapr`X' hsimay`X' hsijun`X' hsijul`X' hsiaug`X' hsisep`X' hsioct`X' hsinov`X' hsidec`X' ///
howjan`X' howfeb`X' howmar`X' howapr`X' howmay`X' howjun`X' howjul`X' howaug`X' howsep`X' howoct`X' hownov`X' howdec`X' ///
hvajan`X' hvafeb`X' hvamar`X' hvaapr`X' hvamay`X' hvajun`X' hvajul`X' hvaaug`X' hvasep`X' hvaoct`X' hvanov`X' hvadec`X' ///
hrtjan`X' hrtfeb`X' hrtmar`X' hrtapr`X' hrtmay`X' hrtjun`X' hrtjul`X' hrtaug`X' hrtsep`X' hrtoct`X' hrtnov`X' hrtdec`X' ///
hanjan`X' hanfeb`X' hanmar`X' hanapr`X' hanmay`X' hanjun`X' hanjul`X' hanaug`X' hansep`X' hanoct`X' hannov`X' handec`X' ///
hopjan`X' hopfeb`X' hopmar`X' hopapr`X' hopmay`X' hopjun`X' hopjul`X' hopaug`X' hopsep`X' hopoct`X' hopnov`X' hopdec`X' ///
hunjan`X' hunfeb`X' hunmar`X' hunapr`X' hunmay`X' hunjun`X' hunjul`X' hunaug`X' hunsep`X' hunoct`X' hunnov`X' hundec`X' ///
hwcjan`X' hwcfeb`X' hwcmar`X' hwcapr`X' hwcmay`X' hwcjun`X' hwcjul`X' hwcaug`X' hwcsep`X' hwcoct`X' hwcnov`X' hwcdec`X' ///
hcsjan`X' hcsfeb`X' hcsmar`X' hcsapr`X' hcsmay`X' hcsjun`X' hcsjul`X' hcsaug`X' hcssep`X' hcsoct`X' hcsnov`X' hcsdec`X' ///
haljan`X' halfeb`X' halmar`X' halapr`X' halmay`X' haljun`X' haljul`X' halaug`X' halsep`X' haloct`X' halnov`X' haldec`X' ///
wunjan`X' wunfeb`X' wunmar`X' wunapr`X' wunmay`X' wunjun`X' wunjul`X' wunaug`X' wunsep`X' wunoct`X' wunnov`X' wundec`X' ///
wwcjan`X' wwcfeb`X' wwcmar`X' wwcapr`X' wwcmay`X' wwcjun`X' wwcjul`X' wwcaug`X' wwcsep`X' wwcoct`X' wwcnov`X' wwcdec`X' ///
wdvjan`X' wdvfeb`X' wdvmar`X' wdvapr`X' wdvmay`X' wdvjun`X' wdvjul`X' wdvaug`X' wdvsep`X' wdvoct`X' wdvnov`X' wdvdec`X' ///
winjan`X' winfeb`X' winmar`X' winapr`X' winmay`X' winjun`X' winjul`X' winaug`X' winsep`X' winoct`X' winnov`X' windec`X' ///
wtfjan`X' wtffeb`X' wtfmar`X' wtfapr`X' wtfmay`X' wtfjun`X' wtfjul`X' wtfaug`X' wtfsep`X' wtfoct`X' wtfnov`X' wtfdec`X' ///
wsijan`X' wsifeb`X' wsimar`X' wsiapr`X' wsimay`X' wsijun`X' wsijul`X' wsiaug`X' wsisep`X' wsioct`X' wsinov`X' wsidec`X' ///
wtnjan`X' wtnfeb`X' wtnmar`X' wtnapr`X' wtnmay`X' wtnjun`X' wtnjul`X' wtnaug`X' wtnsep`X' wtnoct`X' wtnnov`X' wtndec`X' ///
wcsjan`X' wcsfeb`X' wcsmar`X' wcsapr`X' wcsmay`X' wcsjun`X' wcsjul`X' wcsaug`X' wcssep`X' wcsoct`X' wcsnov`X' wcsdec`X' ///
wowjan`X' wowfeb`X' wowmar`X' wowapr`X' wowmay`X' wowjun`X' wowjul`X' wowaug`X' wowsep`X' wowoct`X' wownov`X' wowdec`X' ///
wpajan`X' wpafeb`X' wpamar`X' wpaapr`X' wpamay`X' wpajun`X' wpajul`X' wpaaug`X' wpasep`X' wpaoct`X' wpanov`X' wpadec`X', ///
mv(9=.)

* Missing = 8 or 9
mvdecode hrnper`X' hdvper`X' hinper`X' htfper`X' htnper`X' hsiper`X' howper`X' hvaper`X' hrtper`X' hanper`X' hopper`X' hunper`X' hwcper`X' hcsper`X' halper`X' ///
wunper`X' wwcper`X' wdvper`X' winper`X' wtfper`X' wsiper`X' wtnper`X' wcsper`X' wowper`X' wpaper`X', ///
mv(8=. \ 9=.)

* Missing = 999,998 or 999,999 (999K)
mvdecode hrnamount`X' hdvamount`X' hinamount`X' htfamount`X' htnamount`X' hsiamount`X' howamount`X' hrtamount`X' hanamount`X' hopamount`X' ///
wdvamount`X' winamount`X' wtfamount`X' wsiamount`X' wtnamount`X' wowamount`X' wpaamount`X', /// 
mv(999998=. \ 999999=.)
}

*1999 ֠2001 only
foreach X in 1999 2001 {

* Missing = 99,998 or 99,999 (99K)
mvdecode hvaamount`X' hunamount`X' hwcamount`X' hcsamount`X' halamount`X' /// 
wunamount`X' wwcamount`X' wcsamount`X', ///
mv(99998=. \ 99999=.)
}

*2003 only
foreach X in 2003 {

* Missing = 999,998 or 999,999 (999K)
mvdecode hvaamount`X' hunamount`X' hwcamount`X' hcsamount`X' halamount`X' ///
wunamount`X' wwcamount`X' wcsamount`X' ///
wrnamount`X', ///
mv(999998=. \ 999999=.)

* Missing =9
mvdecode wrnjan`X' wrnfeb`X' wrnmar`X' wrnapr`X' wrnmay`X' wrnjun`X' wrnjul`X' wrnaug`X' wrnsep`X' wrnoct`X' wrnnov`X' wrndec`X', ///
mv(9=.)

* Missing = 8 or 9
mvdecode wrnper`X', ///
mv(8=. \ 9=.)
}

*1999 ֠2001 ֠2003 - 2005 only
foreach X in 1999 2001 2003 2005 {

* Missing = 999,998 or 999,999 (999K)
mvdecode  c`X'childcaretotal, /// 
mv(999998=. \ 999999=.)
}

*2007 ֠2009 - 2011 only
foreach X in 2007 2009 2011 {

* Missing = 8 or 9
mvdecode childcareper`X', ///
mv(8=. \ 9=.)

* Missing = 999,998 or 999,999 (999K)
mvdecode  childcare`X', /// 
mv(999998=. \ 999999=.)
}

/* Creating unique person id -- merged this variable in above with mortgage interest deduction file
gen personid= (ER30001*1000) + ER30002
*/
sort personid
save "$outdata/taxes_var_$datestamp", replace

* CREATING COMPONENTS OF LATER TAXSIM INPUT VARIABLES

save "$outdata/taxes_all_$datestamp", replace

* Tax year
foreach X in 1999 2001 2003 2005 2007 2009 2011 {
gen t`X'taxyr = intyr`X' - 1
}

*SOI state codes for TAXSIM
foreach X in 1999 2001 2003 2005 2007 2009 2011 {
gen t`X'state = .
replace t`X'state = 1 if state`X'==1
replace t`X'state = 2 if state`X' ==50
replace t`X'state = 3 if state`X' ==2
replace t`X'state = 4 if state`X' ==3
replace t`X'state = 5 if state`X' ==4
replace t`X'state = 6 if state`X' ==5
replace t`X'state = 7 if state`X' ==6
replace t`X'state = 8 if state`X' ==7
replace t`X'state = 9 if state`X' ==8
replace t`X'state = 10 if state`X' ==9
replace t`X'state = 11 if state`X' ==10
replace t`X'state = 12 if state`X' ==51
replace t`X'state = 13 if state`X' ==11
replace t`X'state = 14 if state`X' ==12
replace t`X'state = 15 if state`X' ==13
replace t`X'state = 16 if state`X' ==14
replace t`X'state = 17 if state`X' ==15
replace t`X'state = 18 if state`X' ==16
replace t`X'state = 19 if state`X' ==17
replace t`X'state = 20 if state`X' ==18
replace t`X'state = 21 if state`X' ==19
replace t`X'state = 22 if state`X' ==20
replace t`X'state = 23 if state`X' ==21
replace t`X'state = 24 if state`X' ==22
replace t`X'state = 25 if state`X' ==23
replace t`X'state = 26 if state`X' ==24
replace t`X'state = 27 if state`X' ==25
replace t`X'state = 28 if state`X' ==26
replace t`X'state = 29 if state`X' ==27
replace t`X'state = 30 if state`X' ==28
replace t`X'state = 31 if state`X' ==29
replace t`X'state = 32 if state`X' ==30
replace t`X'state = 33 if state`X' ==31
replace t`X'state = 34 if state`X' ==32
replace t`X'state = 35 if state`X' ==33
replace t`X'state = 36 if state`X' ==34
replace t`X'state = 37 if state`X' ==35
replace t`X'state = 38 if state`X' ==36
replace t`X'state = 39 if state`X' ==37
replace t`X'state = 40 if state`X' ==38
replace t`X'state = 41 if state`X' ==39
replace t`X'state = 42 if state`X' ==40
replace t`X'state = 43 if state`X' ==41
replace t`X'state = 44 if state`X' ==42
replace t`X'state = 45 if state`X' ==43
replace t`X'state = 46 if state`X' ==44
replace t`X'state = 47 if state`X' ==45
replace t`X'state = 48 if state`X' ==46
replace t`X'state = 49 if state`X' ==47
replace t`X'state = 50 if state`X' ==48
replace t`X'state = 51 if state`X' ==49
replace t`X'state = 0 if missing(state`X') // set to zero if state is missing (then TAXSIM does not calc state taxes). Tiny amount of missing data.
}

*SUMMING ANNUAL INCOME AMOUNTS FOR 1999, 2001, 2003
* Head: dividends, interest income, rent income, trust fund income, alimony received (head only), annuities (head only), retirement (head only), other pensions
*       TANF, SSI, other welfare, VA pension (head only), workers comp, child support recӤ, unemployment
* Wife: dividends, interest income, rent income (not avail for wife pre-2003), trust fund income, pensions/annuities
*		TANF, SSI, other welfare, workers comp, child support recӤ
* If month is missing, assume not rec'd that month. If time unit is missing, assume annual amount.

* Code below substitutes median non-zero value by family unit if amount is missing (consistent with PSID convention for imputation of missing values from 2005 on).
*	Very small number of missing values in these variables (generally <1%). 
* Note that by PSID default, cases with missing "whether rec'd" have amount = zero.

foreach X in 1999 2001 2003 {
foreach Y in hdv hin hrn htf hal han hrt hop htn hsi how hva hwc hcs hun ///
wdv win wtf wpa wtn wsi wow wwc wcs wun {

egen c`X'`Y'mo = rsum(`Y'jan`X' `Y'feb`X' `Y'mar`X' `Y'apr`X' `Y'may`X' `Y'jun`X' `Y'jul`X' `Y'aug`X' `Y'sep`X' `Y'oct`X' `Y'nov`X' `Y'dec`X')

gen c`X'`Y'total = .
replace c`X'`Y'total = `Y'amount`X' if (`Y'per`X' ==6)
replace c`X'`Y'total = `Y'amount`X' if (`Y'per`X' ==7)
replace c`X'`Y'total = `Y'amount`X' if missing(`Y'per`X')
replace c`X'`Y'total = `Y'amount`X' if (`Y'per`X' ==0)
replace c`X'`Y'total = `Y'amount`X' * c`X'`Y'mo if (`Y'per`X' ==5)
replace c`X'`Y'total = `Y'amount`X' *( c`X'`Y'mo /12)*26 if (`Y'per`X' ==4)
replace c`X'`Y'total = `Y'amount`X'*( c`X'`Y'mo /12)*52 if (`Y'per`X' ==3)
}
}

*Marking cases with missing amount, and substituting median non-zero value by family unit.
foreach X in 1999 2001 2003 {
foreach Y in hdv hin hrn htf hal han hrt hop htn hsi how hva hwc hcs hun ///
wdv win wtf wpa wtn wsi wow wwc wcs wun {

gen c`X'`Y'_miss = (missing(`Y'amount`X') & !missing(famno`X')) 

egen `Y'median`X' = median(c`X'`Y'total) if c`X'`Y'total>0 & !missing(c`X'`Y'total) & !missing(famno`X') & seqno`X'<21 & seqno`X'!=0 & reltohd`X'==10
sort `Y'median`X'
carryforward `Y'median`X', replace // using user-generated command carryforward (download thru "findit carryforward") to copy median value to all obs in data year 
tab `Y'median`X' if !missing(famno`X'), missing
sort famno`X'

replace c`X'`Y'total = `Y'median`X' if c`X'`Y'_miss ==1
}
}

foreach X in 2003 { // wife rent income for 2003 (not avail pre-2003)
foreach Y in wrn {

egen c`X'`Y'mo = rsum(`Y'jan`X' `Y'feb`X' `Y'mar`X' `Y'apr`X' `Y'may`X' `Y'jun`X' `Y'jul`X' `Y'aug`X' `Y'sep`X' `Y'oct`X' `Y'nov`X' `Y'dec`X')

gen c`X'`Y'total = .
replace c`X'`Y'total = `Y'amount`X' if (`Y'per`X' ==6)
replace c`X'`Y'total = `Y'amount`X' if (`Y'per`X' ==7)
replace c`X'`Y'total = `Y'amount`X' if missing(`Y'per`X')
replace c`X'`Y'total = `Y'amount`X' if (`Y'per`X' ==0)
replace c`X'`Y'total = `Y'amount`X' * c`X'`Y'mo if (`Y'per`X' ==5)
replace c`X'`Y'total = `Y'amount`X' *( c`X'`Y'mo /12)*26 if (`Y'per`X' ==4)
replace c`X'`Y'total = `Y'amount`X'*( c`X'`Y'mo /12)*52 if (`Y'per`X' ==3)
}
}
*Marking cases with missing amount, and substituting median non-zero value by family unit.
foreach X in 2003 {
foreach Y in wrn {

gen c`X'`Y'_miss = (missing(`Y'amount`X') & !missing(famno`X')) 

egen `Y'median`X' = median(c`X'`Y'total) if c`X'`Y'total>0 & !missing(c`X'`Y'total) & !missing(famno`X') & seqno`X'<21 & seqno`X'!=0 & reltohd`X'==10
sort `Y'median`X'
carryforward `Y'median`X', replace // using user-generated command carryforward (download thru "findit carryforward") to copy median value to all obs in data year 
tab `Y'median`X' if !missing(famno`X'), missing
sort famno`X'

replace c`X'`Y'total = `Y'median`X' if c`X'`Y'_miss ==1
}
}

*RENT PAID. 
foreach X in 1999 2001 2003 2005 2007 2009 2011 {
gen t`X'rentpaid = .
replace t`X'rentpaid = (rentpdamt`X' * 12) if !missing(rentpdamt`X') // assume monthly rent if time unit is missing
replace t`X'rentpaid = rentpdamt`X' if (rentpdper`X' == 6 & !missing(rentpdamt`X') )
replace t`X'rentpaid = (rentpdamt`X' * 26) if (rentpdper`X' == 4 & !missing(rentpdamt`X') )
replace t`X'rentpaid = (rentpdamt`X' * 52) if (rentpdper`X' == 3 & !missing(rentpdamt`X') )
replace t`X'rentpaid = (rentpdamt`X' * 365) if (rentpdper`X' == 2 & !missing(rentpdamt`X') )
}

*For renters with missing values, substituting median non-zero value by family unit.
foreach X in 1999 2001 2003 2005 2007 2009 2011 {
gen rentpd`X'_miss = (missing(t`X'rentpaid) & !missing(famno`X'))

egen rentpdmedian`X' = median(t`X'rentpaid) if t`X'rentpaid>0 & !missing(t`X'rentpaid) & !missing(famno`X') & seqno`X'<21 & seqno`X'!=0 & reltohd`X'==10
sort rentpdmedian`X'
carryforward rentpdmedian`X', replace // using user-generated command carryforward (download thru "findit carryforward") to copy median value to all obs in data year 
tab rentpdmedian`X' if !missing(famno`X'), missing
sort famno`X'

replace t`X'rentpaid = rentpdmedian`X' if rentpd`X'_miss ==1
}

*ALIMONY PAID. For cases with alimony paid? = yes but missing amount, substituting median non-zero value by family unit.
foreach X in 1999 2001 2003 2005 2007 2009 2011 {

gen alimpdhd`X'_miss = (missing(alimpdhd`X') & !missing(famno`X'))

egen alimpdmedian`X' = median(alimpdhd`X') if alimpdhd`X'>0 & !missing(alimpdhd`X') & !missing(famno`X') & seqno`X'<21 & seqno`X'!=0 & reltohd`X'==10
sort alimpdmedian`X'
carryforward alimpdmedian`X', replace // using user-generated command carryforward (download thru "findit carryforward") to copy median value to all obs in data year 
tab alimpdmedian`X' if !missing(famno`X'), missing
sort famno`X'

replace alimpdhd`X' = alimpdmedian`X' if alimpdhd`X'_miss ==1
}

save "$outdata/taxes_all_$datestamp", replace

* TAX UNITS

*ASSIGNING DEPENDENTS 

*Strategy ֠categorize each OFUM as adult or child. Assign children/stepchildren/foster children to head or "wife".
* In cases where there are no OFUM adults, or where OFUM labor income = 0 (so OFUM tax unit is not eligible for EITC), assign additional related children to head or "wife".

*Categorizing by age
foreach X in 1999 2001 2003 2005 2007 2009 2011 {

*SENIOR HEAD OR WIFE for calcs below
gen c`X'headwife65 = ((agehead`X'>=65 & !missing(agehead`X')) | (agewife`X' >=65 & !missing(agewife`X')))

*AGE CALCS
gen c`X'child0to18 = (((t`X'taxyr - yearborn`X') >=0) & ((t`X'taxyr - yearborn`X') <=18))
gen c`X'child0to16 = (((t`X'taxyr - yearborn`X') >=0) & ((t`X'taxyr - yearborn`X') <=16))
gen c`X'child0to4 = (((t`X'taxyr - yearborn`X') >=0) & ((t`X'taxyr - yearborn`X') <=4))
gen c`X'adult19plus = (((t`X'taxyr - yearborn`X') >=19) & ((t`X'taxyr - yearborn`X') <=120))
gen c`X'senior65 = (((t`X'taxyr - yearborn`X') >=65) & ((t`X'taxyr - yearborn`X') <=120))

*Imputing age for those with missing yearborn - first using age at interview
replace c`X'child0to18 = 1 if missing(yearborn`X') & intage`X'>=1 & intage`X' <=18 // min reported age is 1
replace c`X'child0to16 = 1 if missing(yearborn`X') & intage`X'>=1 & intage`X' <=16
replace c`X'child0to4 = 1 if missing(yearborn`X') & intage`X'>=1 & intage`X' <=4
replace c`X'adult19plus = 1 if missing(yearborn`X') & intage`X' >=19 & intage`X' <=120
replace c`X'senior65 = 1 if missing(yearborn`X') & intage`X' >=65 & intage`X' <=120

*Imputing age for those with missing yearborn - next using relationship to head
replace c`X'child0to18 = 1 if missing(yearborn`X') & missing(intage`X') & inlist(reltohd`X',60,65) // assume grandchildren of head are children
replace c`X'child0to16 = 1 if missing(yearborn`X') & missing(intage`X') & inlist(reltohd`X',60,65)

replace c`X'adult19plus = 1 if missing(yearborn`X') & missing(intage`X') & inlist(reltohd`X',10,20,22,37,40,47,48,50,57,58,66,67,68,69,72,73,74,75,88,90,95,96,97,98) // assume peers and parents of head are adults

replace c`X'child0to18 = 1 if missing(yearborn`X') & missing(intage`X') & inlist(reltohd`X',30,33,35,38,70,71,83) & c`X'headwife65==0 // assume children of head/peers are children if head/wife is not a senior
replace c`X'child0to16 = 1 if missing(yearborn`X') & missing(intage`X') & inlist(reltohd`X',30,33,35,38,70,71,83) & c`X'headwife65==0

replace c`X'adult19plus = 1 if missing(yearborn`X') & missing(intage`X') & inlist(reltohd`X',30,33,35,38,70,71,83) & c`X'headwife65==1 // assume children of head/peers are adults if head/wife is a senior

replace c`X'senior65 = 1 if missing(yearborn`X') & missing(intage`X') & inlist(reltohd`X',66,67,68,69) // assume grandparents of head are seniors
replace c`X'senior65 = 1 if missing(yearborn`X') & missing(intage`X') & inlist(reltohd`X',10,20,22,37,40,47,48,50,57,58,72,73,74,75,88,90,95,96,97,98) & c`X'headwife65==1 // assume peers and parents of head are seniors if head/wife is a senior
}

*Excluding individuals not present during the income year.
foreach X in 1999 2001 2003 2005 2007 2009 2011 {
* Individuals who were in the family for income year and for interview (didn't move in or out).
gen c`X'present = 1 if moveyr`X' <t`X'taxyr & seqno`X' <21 & seqno`X'  !=0 // no move, or moved in before income year --> present
replace c`X'present = 1 if missing(moveyr`X') & seqno`X'  <21 & seqno`X'  !=0 // move-in year unknown, present at interview --> assume present

* Individuals who moved in before interview.
replace c`X'present = 1 if moveyr`X'==t`X'taxyr & seqno`X'  <21 & seqno`X'  !=0 // moved in during income year --> present
replace c`X'present = 0 if moveyr`X'==(t`X'taxyr +1) & seqno`X'  <21 & seqno`X'  !=0 // moved in after income year --> absent

* Current head and wife count as present regardless of move-in year since their income is always included in PSID.
replace c`X'present = 1 if seqno`X' <21 & seqno`X' !=0 & inlist(reltohd`X',10,20,22)

* Individuals who moved out before interview.
replace c`X'present = 0 if moveyr`X'>0 & moveyr`X' <t`X'taxyr & seqno`X'  >50 & !missing(seqno`X') // moved out before income year --> absent
replace c`X'present = 1 if moveyr`X' ==t`X'taxyr & seqno`X'  >50 & !missing(seqno`X' ) // moved out during income year --> present
replace c`X'present = 1 if moveyr`X' ==(t`X'taxyr +1) & seqno`X'  >50 & !missing(seqno`X' ) // moved out after income year --> present
replace c`X'present = 1 if missing(moveyr`X') & seqno`X'  >50 & !missing(seqno`X' ) // move-out year unknown, not present at interview --> assume present

* Individuals in institutions and splitoffs
replace c`X'present = 0 if moveyr`X'==0 & seqno`X'  >50 & !missing(seqno`X') // stayed in institution since prior interview, or moved out of institution to non-followed FU, or splitoff so income goes with new FU
}

foreach X in 1999 2001 2003 2005 2007 2009 2011 {
foreach Y in child0to18 child0to16 child0to4 adult19plus senior65 {
replace c`X'`Y' = 0 if c`X'present ==0
}
}

*Assigning dependents to head and "wife".
foreach X in 1999 2001 2003 2005 2007 2009 2011 {
gen str14 c`X'indivdep = ""
replace c`X'indivdep = "ofumchild" if (c`X'child0to18 == 1)
replace c`X'indivdep = "headchild" if (c`X'child0to18 == 1) & inlist(reltohd`X',30,33,38)
replace c`X'indivdep = "headmorechild" if (c`X'child0to18 == 1) & inlist(reltohd`X',37,40,47,60,65,70,72,74,95,71,73,75,96,90) // will be counted as head dependents only if no ofum adults or no ofum taxable income 
replace c`X'indivdep = "cohabchild" if (c`X'child0to18 == 1) &  inlist(reltohd`X',35) 
replace c`X'indivdep = "cohabmorechild" if (c`X'child0to18 == 1) & inlist(reltohd`X',48,97) & marstat`X' == 2 // will be counted as "wife" dependents only if no ofum adults or no ofum taxable income

replace c`X'indivdep = "ofumadult" if (c`X'adult19plus == 1) 
replace c`X'indivdep = "headadult" if (c`X'adult19plus == 1) & inlist(reltohd`X',30,33,37,40,47,50,57,60,65,66,67,68,69,70,71,72,73,74,75,90,95,96) // could use this variable to count adult dependents of head, but not done in this program
replace c`X'indivdep= "cohabadult" if (c`X'adult19plus == 1) & inlist(reltohd`X',35) // could use this variable to count adult dependents of "wife", but not done in this program
replace c`X'indivdep= "cohabadult" if (c`X'adult19plus == 1) & inlist(reltohd`X',48,58,97) & marstat`X' == 2

replace c`X'indivdep = "currhdwfco" if inlist(reltohd`X',10,20,22) & seqno`X'  <21 & seqno`X'  !=0 // excluding current head, wife/"wife" from dependents and ofum tax units

gen c`X'headchild18 = (c`X'indivdep == "headchild")
gen c`X'headmorechild18 = (c`X'indivdep == "headmorechild")
gen c`X'cohabchild18 = (c`X'indivdep == "cohabchild")
gen c`X'cohabmorechild18 = (c`X'indivdep == "cohabmorechild")
gen c`X'ofumchild = (c`X'indivdep == "ofumchild")
gen c`X'ofumadult = (c`X'indivdep == "ofumadult")
gen c`X'headadult = (c`X'indivdep=="headadult")
gen c`X'cohabadult = (c`X'indivdep=="cohabadult")
}

*Summing by family id
foreach X in 1999 2001 2003 2005 2007 2009 2011 {
foreach Y in headchild18 headmorechild18 cohabchild18 cohabmorechild18 ofumchild ofumadult headadult cohabadult child0to4 {
egen c`X'sum`Y' = sum(c`X'`Y'), by (famno`X')
}
}

*Identifying dependents age 16 and younger (for child tax credit)
foreach X in 1999 2001 2003 2005 2007 2009 2011 {
foreach Y in headchild headmorechild cohabchild cohabmorechild {
gen c`X'`Y'16 = (c`X'`Y'18==1 & c`X'child0to16 == 1)
}
}

*Summing by family id
foreach X in 1999 2001 2003 2005 2007 2009 2011 {
foreach Y in headchild16 headmorechild16 cohabchild16 cohabmorechild16 {
egen c`X'sum`Y' = sum(c`X'`Y'), by (famno`X')
}
}

* OFUM TAX HOUSEHOLDS
foreach X in 1999 2001 2003 2005 2007 2009 2011 {
gen c`X'ofumtaxadult = (inlist(c`X'indivdep,"ofumadult","headadult","cohabadult"))
gen c`X'ofumtaxsenior = (c`X'ofumtaxadult == 1 & c`X'senior65==1)
gen c`X'ofumtaxchild18 = (inlist(c`X'indivdep,"ofumchild","headmorechild","cohabmorechild"))
gen c`X'ofumtaxchild16 = (c`X'ofumtaxchild18 == 1 & c`X'child0to16 ==1)
}

*Summing by family id
foreach X in 1999 2001 2003 2005 2007 2009 2011 {
foreach Y in ofumtaxadult ofumtaxsenior ofumtaxchild18 ofumtaxchild16 {
egen c`X'sum`Y' = sum(c`X'`Y'), by (famno`X')
}
}


*Creating comparision variable without reassignment of dependents
foreach X in 1999 2001 2003 2005 2007 2009 2011 {
foreach Y in sumheadchild18 sumcohabchild18 sumofumtaxchild18 sumheadchild16 sumcohabchild16 sumofumtaxchild16 {

gen c`X'`Y'_norsmt = c`X'`Y'
}
}


*Reassigning additional related dependents to head/"wife"  in cases where there are no ofum adults or no ofum taxable income (pre-2005) / ofum labor income (2005 on) -- switching headmorechild and cohabmorechild from ofum tax unit to head/"wife" dependents
foreach X in 1999 2001 2003 { // pre-2005 only OFUM taxable income available - assuming taxable income is labor income

gen reassigndep`X' = (c`X'sumofumtaxchild18>0 & (c`X'sumofumtaxadult==0 | taxableincofum`X' ==0))
replace c`X'sumheadchild18 = c`X'sumheadchild18 + c`X'sumheadmorechild18 if reassigndep`X'==1
replace c`X'sumcohabchild18 = c`X'sumcohabchild18 + c`X'sumcohabmorechild18 if reassigndep`X'==1
replace c`X'sumofumtaxchild18 = c`X'sumofumtaxchild18 - c`X'sumheadmorechild18 - c`X'sumcohabmorechild18 if reassigndep`X'==1

replace c`X'sumheadchild16 = c`X'sumheadchild16 + c`X'sumheadmorechild16 if reassigndep`X'==1
replace c`X'sumcohabchild16 = c`X'sumcohabchild16 + c`X'sumcohabmorechild16 if reassigndep`X'==1
replace c`X'sumofumtaxchild16 = c`X'sumofumtaxchild16 - c`X'sumheadmorechild16 - c`X'sumcohabmorechild16 if reassigndep`X'==1
}

foreach X in 2005 2007 2009 2011 { // from 2005 on OFUM labor income is available
gen reassigndep`X' = (c`X'sumofumtaxchild18>0 & (c`X'sumofumtaxadult==0 | labincofum`X' ==0))
replace c`X'sumheadchild18 = c`X'sumheadchild18 + c`X'sumheadmorechild18 if reassigndep`X'==1
replace c`X'sumcohabchild18 = c`X'sumcohabchild18 + c`X'sumcohabmorechild18 if reassigndep`X'==1
replace c`X'sumofumtaxchild18 = c`X'sumofumtaxchild18 - c`X'sumheadmorechild18 - c`X'sumcohabmorechild18 if reassigndep`X'==1

replace c`X'sumheadchild16 = c`X'sumheadchild16 + c`X'sumheadmorechild16 if reassigndep`X'==1
replace c`X'sumcohabchild16 = c`X'sumcohabchild16 + c`X'sumcohabmorechild16 if reassigndep`X'==1
replace c`X'sumofumtaxchild16 = c`X'sumofumtaxchild16 - c`X'sumheadmorechild16 - c`X'sumcohabmorechild16 if reassigndep`X'==1
}


save "$outdata/taxes_all_$datestamp", replace

*CHILD CARE. Code below uses tax unit variables generated above.
*Summing annual amount for years 2007-2011
foreach X in 2007 2009 2011 {

gen c`X'childcaretotal = .
replace c`X'childcaretotal = childcare`X' if (childcareper`X' ==6)
replace c`X'childcaretotal = childcare`X' if (childcareper`X' ==7)
replace c`X'childcaretotal = childcare`X' if missing(childcareper`X')
replace c`X'childcaretotal = childcare`X' if (childcareper`X' ==0)
replace c`X'childcaretotal = childcare`X' * 12 if (childcareper`X' ==5)
replace c`X'childcaretotal = childcare`X' *26 if (childcareper`X' ==4)
replace c`X'childcaretotal = childcare`X' *52 if (childcareper`X' ==3)
}

* Imputing missing values for working families with youngest child <5yo. All other missing values set to zero.
* Note there is no "whether any child care expenses" variable.
* If amount is missing and all adults working and youngest child <5yo, substitute median value by family unit for working families with youngest child <5yo.
* For working families with youngest child >=5 yo, median value is zero so set missing values to zero. If at least one adult not working, set missing values to zero.
* (Note that only marstat 1 & 2 have non-zero values for wife/"wife" variables in PSID.) 

foreach X in 1999 2001 2003 { // pre-2005 only OFUM taxable income variable available - assuming that if an OFUM adult has taxable income then working

gen c`X'alladwk = ((laborhd`X'>0 | buslabhd`X'>0 | farm`X'>0) & (laborwf`X'>0 | buslabwf`X'>0) & marstat`X'<=2 & c`X'sumofumtaxadult==0)  // head + wife/"wife" and no ofum adults
replace c`X'alladwk = 1 if (laborhd`X'>0 | buslabhd`X'>0 | farm`X'>0) & marstat`X'>2 & !missing(marstat`X') & c`X'sumofumtaxadult==0  // head without wife/"wife" and no ofum adults
replace c`X'alladwk = 1 if (laborhd`X'>0 | buslabhd`X'>0 | farm`X'>0) & (laborwf`X'>0 | buslabwf`X'>0) & (taxableincofum`X'>0) & marstat`X'<=2 & c`X'sumofumtaxadult>0 // head + wife/"wife" with ofum adults
replace c`X'alladwk = 1 if (laborhd`X'>0 | buslabhd`X'>0 | farm`X'>0) & (taxableincofum`X'>0) & marstat`X'>2 & !missing(marstat`X') & c`X'sumofumtaxadult>0  // head without wife/"wife" with ofum adults

gen c`X'childcare_miss = (missing(c`X'childcaretotal) & c`X'alladwk==1 & c`X'sumchild0to4>0)

egen c`X'childcaremed = median(c`X'childcaretotal) if c`X'alladwk==1 & c`X'sumchild0to4>0 & seqno`X'<21 & seqno`X'!=0 & reltohd`X'==10
sort c`X'childcaremed
carryforward c`X'childcaremed, replace // using user-generated command carryforward (download thru "findit carryforward") to copy median value to all obs in data year 
tab c`X'childcaremed if !missing(famno`X'), missing
sort famno`X'

replace c`X'childcaretotal = c`X'childcaremed if c`X'childcare_miss==1
replace c`X'childcaretotal = 0 if missing(c`X'childcaretotal) & c`X'childcare_miss==0
}

foreach X in 2005 2007 2009 2011 { // from 2005 on OFUM labor income variable available

gen c`X'alladwk = ((laborhd`X'>0 | buslabhd`X'>0 | farm`X'>0) & (laborwf`X'>0 | buslabwf`X'>0) & marstat`X'<=2 & c`X'sumofumtaxadult==0)  // head + wife/"wife" and no ofum adults
replace c`X'alladwk = 1 if (laborhd`X'>0 | buslabhd`X'>0 | farm`X'>0) & marstat`X'>2 & !missing(marstat`X') & c`X'sumofumtaxadult==0  // head without wife/"wife" and no ofum adults
replace c`X'alladwk = 1 if (laborhd`X'>0 | buslabhd`X'>0 | farm`X'>0) & (laborwf`X'>0 | buslabwf`X'>0) & (labincofum`X'>0) & marstat`X'<=2 & c`X'sumofumtaxadult>0 // head + wife/"wife" with ofum adults
replace c`X'alladwk = 1 if (laborhd`X'>0 | buslabhd`X'>0 | farm`X'>0) & (labincofum`X'>0) & marstat`X'>2 & !missing(marstat`X') & c`X'sumofumtaxadult>0 // head without wife/"wife" with ofum adults

gen c`X'childcare_miss = (missing(c`X'childcaretotal) & c`X'alladwk==1 & c`X'sumchild0to4>0)

egen c`X'childcaremed = median(c`X'childcaretotal) if c`X'alladwk==1 & c`X'sumchild0to4>0 & seqno`X'<21 & seqno`X'!=0 & reltohd`X'==10
sort c`X'childcaremed
carryforward c`X'childcaremed, replace // using user-generated command carryforward (download thru "findit carryforward") to copy median value to all obs in data year 
tab c`X'childcaremed if !missing(famno`X'), missing
sort famno`X'

replace c`X'childcaretotal = c`X'childcaremed if c`X'childcare_miss==1
replace c`X'childcaretotal = 0 if missing(c`X'childcaretotal) & c`X'childcare_miss==0
}

save "$outdata/taxes_all_$datestamp", replace

* CALCULATIONS OF TAXSIM INPUT VARIABLES
*Creating variables for four potential tax units within the PSID family unit: head only, "wife" only, joint married, ofum.
* Also creating "simple" version -- single set of variables per FU using the most basic information from the family file (PSID-generated # of children, family unit taxable income, etc.).

* Created one version of variable where the same for all tax units (e.g. tax year). 
* Created multiple versions of variable where different for different tax units (e.g. number of dependents).


* TAXSIM variables that are same for head, wife, joint, and ofum.  As well as simple.
foreach X in 1999 2001 2003 2005 2007 2009 2011 {
gen t`X'var1 = personid
gen t`X'var2 = t`X'taxyr // missing for those not in sample for the year --> TAXSIM will not calculate taxes for those individuals

gen t`X'var3 = t`X'state
replace t`X'var3 = 0 if missing(t`X'var3)

gen t`X'var16 = 0 // other itemized deductions (for AMT) set to zero
gen t`X'var21 = 0 // short-term capital gains set to zero
gen t`X'var22 = 0 // long-term capital gains set to zero
}

* TAXSIM filing status.  No missing values in sumchild variables or simple variables.
foreach X in 1999 2001 2003 2005 2007 2009 2011 {
gen t`X'var4head = 1
replace t`X'var4head = 3 if c`X'sumheadchild18 >=1 & !missing(c`X'sumheadchild18)

gen t`X'var4wife = 1
replace t`X'var4wife = 3 if c`X'sumcohabchild18 >=1 & !missing(c`X'sumcohabchild18)

gen t`X'var4joint = 2

gen t`X'var4ofum = 1
replace t`X'var4ofum = 3 if c`X'sumofumtaxchild18 >=1 & !missing(c`X'sumofumtaxchild18)
replace t`X'var4ofum = 2 if c`X'sumofumtaxadult >1 & !missing(c`X'sumofumtaxadult) // assuming joint filing status for ofum tax unit if more than one ofum adult

gen t`X'var4simple = 1
replace t`X'var4simple = 3 if intnumchd`X' >=1 & !missing(intnumchd`X') 
replace t`X'var4simple = 2 if (marstat`X' == 1 | marstat`X' == 3)
}

* TAXSIM dependent exemptions.  No missing values in sumchild variables or simple variables.
* 	TAXSIM uses this variable for dependent exemptions and also for the number of "qualifying children" for the EITC. 
*	Prioritizing correct calculation of EITC here, so not including any dependent adults in this variable.
*	(Adult children/grandchildren/siblings/cousins/etc. can count as "qualifying children" for EITC, but only if full-time student up to age 24 or disabled of any age, and don't have that information.)
foreach X in 1999 2001 2003 2005 2007 2009 2011 {
gen t`X'var5head = c`X'sumheadchild18
replace t`X'var5head = 0 if missing(t`X'var5head)

gen t`X'var5wife = c`X'sumcohabchild18
replace t`X'var5wife = 0 if missing(t`X'var5wife)

gen t`X'var5joint = t`X'var5head + t`X'var5wife

gen t`X'var5ofum = c`X'sumofumtaxchild18
replace t`X'var5ofum = 0 if missing(t`X'var5ofum)

gen t`X'var5simple = intnumchd`X'
replace t`X'var5simple = 0 if missing(t`X'var5simple)
}

* TAXSIM over 65yo.
foreach X in 1999 2001 2003 2005 2007 2009 2011 {
gen t`X'var6head = 1 if agehead`X' >=65 & agehead`X' <120
replace t`X'var6head = 0 if missing(t`X'var6head)

gen t`X'var6wife = 1 if agewife`X' >=65 & agewife`X' <120
replace t`X'var6wife = 0 if missing(t`X'var6wife)

gen t`X'var6joint = t`X'var6head + t`X'var6wife

gen t`X'var6ofum = c`X'sumofumtaxsenior
replace t`X'var6ofum = 2 if c`X'sumofumtaxsenior >1 & !missing(c`X'sumofumtaxsenior)
replace t`X'var6ofum = 0 if missing(t`X'var6ofum)

gen t`X'var6simple = t`X'var6head
replace t`X'var6simple = t`X'var6joint if t`X'var4simple == 2
}

* TAXSIM wages/salary taxfiler.  No missing values in any of these components as PSID imputes missing values.
*	Including both business-labor income and business-asset income here. 
*	If individual actively participates in the business, PSID assigns half of income to labor and half to asset. 
*   If individual does not actively participate, PSID assigns all income to asset. If business had a loss, PSID assigns the loss to asset and 0 to labor.
*	Negative values (due to business losses) recoded as zero (TAXSIM does not accept negative values for this variable).

foreach X in 1999 2001 2003 {
egen t`X'var7head = rsum(laborhd`X' busassethd`X' buslabhd`X' farm`X')
replace t`X'var7head = 0 if t`X'var7head <0

egen t`X'var7wife = rsum(laborwf`X' busassetwf`X' buslabwf`X')
replace t`X'var7wife = 0 if t`X'var7wife <0

egen t`X'var7joint = rsum(laborhd`X' busassethd`X' buslabhd`X' farm`X')
replace t`X'var7joint = 0 if t`X'var7joint <0

gen t`X'var7ofum = taxableincofum`X' // before 2005 only "taxable income" available for OFUMs (no separate reporting of labor vs asset income). Assuming all is labor income.
replace t`X'var7ofum = 0 if taxableincofum`X' < 0 | missing(taxableincofum`X') // only missing for those not in sample for the year

gen t`X'var7simple = taxableinchdwf`X' + taxableincofum`X'
replace t`X'var7simple = 0 if t`X'var7simple <0 | missing(t`X'var7simple) // only missing for those not in sample for the year
}

foreach X in 2005 2007 2009 2011 {
egen t`X'var7head = rsum(laborhd`X' busassethd`X' buslabhd`X' farm`X')
replace t`X'var7head = 0 if t`X'var7head <0

egen t`X'var7wife = rsum(laborwf`X' busassetwf`X' buslabwf`X')
replace t`X'var7wife = 0 if t`X'var7wife <0

egen t`X'var7joint = rsum(laborhd`X' busassethd`X' buslabhd`X' farm`X')
replace t`X'var7joint = 0 if t`X'var7joint <0

gen t`X'var7ofum = labincofum`X' // from 2005 on OFUM labor income variable is available
replace t`X'var7ofum = 0 if labincofum`X' < 0 | missing(labincofum`X') // only missing for those not in sample for the year

gen t`X'var7simple = taxableinchdwf`X' + taxableincofum`X'
replace t`X'var7simple = 0 if t`X'var7simple <0 | missing(t`X'var7simple) // only missing for those not in sample for the year
}

* TAXSIM wages/salary spouse.  No missing values in any of these components as PSID imputes missing values.
foreach X in 1999 2001 2003 2005 2007 2009 2011 {
gen t`X'var8head = 0

gen t`X'var8wife = 0

egen t`X'var8joint = rsum(laborwf`X' busassetwf`X' buslabwf`X')
replace t`X'var8joint = 0 if t`X'var8joint <0

gen t`X'var8ofum = 0

gen t`X'var8simple = 0
}
* TAXSIM dividends ֠from 2003 onwards supposed to be qualified dividends only.
*	PSID doesn't have information about whether dividends are qualified, so 2003 on set this variable to zero and include dividends in "other property income" below.
*	For missing values, median non-zero amount by family unit substituted (manually imputed above pre-2005, PSID provided from 2005 on).
foreach X in 1999 2001  {
gen t`X'var9head = c`X'hdvtotal
replace t`X'var9head = 0 if missing(t`X'var9head) // only missing for those not in sample for the year

gen t`X'var9wife = c`X'wdvtotal
replace t`X'var9wife = 0 if missing(t`X'var9wife) // only missing for those not in sample for the year

gen t`X'var9joint = t`X'var9head + t`X'var9wife

gen t`X'var9ofum = 0

gen t`X'var9simple = 0
}

foreach X in 2003 2005 2007 2009 2011 {
gen t`X'var9head = 0

gen t`X'var9wife = 0

gen t`X'var9joint = 0

gen t`X'var9ofum = 0

gen t`X'var9simple = 0
}
* TAXSIM other property income (interest income, rent income [missing for wife pre-2003], trust fund income, head alimony received, head annuities, dividends 2003 onwards) minus head alimony paid.
*	For missing values, median non-zero amount by family unit substituted (manually imputed above pre-2005, PSID provided from 2005 on).
foreach X in 1999 2001 {
egen t`X'var10head = rsum(c`X'hintotal c`X'hrntotal c`X'htftotal c`X'haltotal c`X'hantotal)
replace t`X'var10head = (t`X'var10head - alimpdhd`X') if !missing(alimpdhd`X')
replace t`X'var10head = 0 if t`X'var10head <0

egen t`X'var10wife = rsum(c`X'wintotal c`X'wtftotal)

gen t`X'var10joint = t`X'var10head + t`X'var10wife

gen t`X'var10ofum = 0 // pre-2005 only OFUM taxable income available, so this variable set to zero

gen t`X'var10simple = 0
}

foreach X in 2003 {
egen t`X'var10head = rsum(c`X'hintotal c`X'hrntotal c`X'htftotal c`X'haltotal c`X'hantotal c`X'hdvtotal)
replace t`X'var10head = (t`X'var10head - alimpdhd`X') if !missing(alimpdhd`X')
replace t`X'var10head = 0 if t`X'var10head <0

egen t`X'var10wife = rsum(c`X'wintotal c`X'wrntotal c`X'wtftotal c`X'wdvtotal)

gen t`X'var10joint = t`X'var10head + t`X'var10wife

gen t`X'var10ofum = 0

gen t`X'var10simple = 0
}

foreach X in 2005 2007 2009 2011 {
egen t`X'var10head = rsum(c`X'hintotal c`X'hrntotal c`X'htftotal c`X'haltotal c`X'hantotal c`X'hdvtotal)
replace t`X'var10head = (t`X'var10head - alimpdhd`X') if !missing(alimpdhd`X')
replace t`X'var10head = 0 if t`X'var10head <0

egen t`X'var10wife = rsum(c`X'wintotal c`X'wrntotal c`X'wtftotal c`X'wdvtotal)

gen t`X'var10joint = t`X'var10head + t`X'var10wife

gen t`X'var10ofum = assetincofum`X' - retirofum`X' // 2005 on OFUM asset income available. Includes OFUM retirement (counted below), so subtracting that.
replace t`X'var10ofum = 0 if missing(t`X'var10ofum) // only missing for those not in sample for the year

gen t`X'var10simple = 0
}
* TAXSIM taxable pensions.
*	For missing values, median non-zero amount by family unit substituted (manually imputed above pre-2005, PSID provided from 2005 on).
foreach X in 1999 2001 2003 {
egen t`X'var11head = rsum(c`X'hrttotal c`X'hoptotal)

gen t`X'var11wife = c`X'wpatotal
replace t`X'var11wife = 0 if missing(t`X'var11wife) // only missing for those not in sample for the year

gen t`X'var11joint = t`X'var11head + t`X'var11wife

gen t`X'var11ofum = 0 // pre-2005 no OFUM retirement available.

gen t`X'var11simple = 0
}

foreach X in 2005 2007 2009 2011 {
egen t`X'var11head = rsum(c`X'hrttotal c`X'hoptotal)

gen t`X'var11wife = c`X'wpatotal
replace t`X'var11wife = 0 if missing(t`X'var11wife) // only missing for those not in sample for the year

gen t`X'var11joint = t`X'var11head + t`X'var11wife

gen t`X'var11ofum = retirofum`X' // 2005 on OFUM retirement available.
replace t`X'var11ofum = 0 if missing(t`X'var11ofum) // only missing for those not in sample for the year

gen t`X'var11simple = 0
}
* TAXSIM Soc Sec. No missing values as PSID imputes missing values. 
foreach X in 1999 2001 2003 {
gen t`X'var12head = socsecfam`X' // pre-2005 only whole family amt available.
replace t`X'var12head = 0 if missing(t`X'var12head) // only missing for those not in sample for the year

gen t`X'var12wife = 0

gen t`X'var12joint = t`X'var12head

gen t`X'var12ofum = 0

gen t`X'var12simple = 0
}

foreach X in 2005 2007 2009 2011 {
gen t`X'var12head = socsechd`X' // 2005 on separate amounts for head, wife, OFUM
replace t`X'var12head = 0 if missing(t`X'var12head) // only missing for those not in sample for the year

gen t`X'var12wife = socsecwf`X'
replace t`X'var12wife = 0 if missing(t`X'var12wife) // only missing for those not in sample for the year

gen t`X'var12joint = t`X'var12head + t`X'var12wife

gen t`X'var12ofum = socsecofum`X'
replace t`X'var12ofum = 0 if missing(t`X'var12ofum) // only missing for those not in sample for the year

gen t`X'var12simple = 0
}
* TAXSIM nontaxable transfer income (TANF, SSI, other welfare, VA pension (head only), workers comp, child support recӤ).
*	For missing values, median non-zero amount by family unit substituted (manually imputed above pre-2005, PSID provided from 2005 on).
foreach X in 1999 2001 2003 2005 2007 2009 2011 {
egen t`X'var13head = rsum(c`X'htntotal c`X'hsitotal c`X'howtotal c`X'hvatotal c`X'hwctotal c`X'hcstotal)

egen t`X'var13wife = rsum(c`X'wtntotal c`X'wsitotal c`X'wowtotal c`X'wwctotal c`X'wcstotal)

gen t`X'var13joint = t`X'var13head + t`X'var13wife

gen t`X'var13ofum = 0 // Setting to zero for OFUMs because only affects state property tax rebate, and no property tax assigned to OFUMs.

gen t`X'var13simple = 0
}

* TAXSIM rent paid (head only). Renters with missing data assigned median non-zero value by family unit.
foreach X in 1999 2001 2003 2005 2007 2009 2011 {
gen t`X'var14head = t`X'rentpaid
replace t`X'var14head = 0 if missing(t`X'var14head) // only missing for those not in sample for the year

gen t`X'var14wife = 0

gen t`X'var14joint = t`X'var14head

gen t`X'var14ofum = 0

gen t`X'var14simple = 0
}
* TAXSIM real estate taxes paid (head only). Set to zero if missing (not imputed).
foreach X in 1999 2001 2003 2005 2007 2009 2011 {
gen t`X'var15head = proptx`X' 
replace t`X'var15head = 0 if missing(t`X'var15head)

gen t`X'var15wife = 0

gen t`X'var15joint = t`X'var15head

gen t`X'var15ofum = 0

gen t`X'var15simple = 0
}
* TAXSIM childcare expenses -- divided between head, wife, and ofum based on proportion of children under age 17 assigned to each.
foreach X in 1999 2001 2003 2005 2007 2009 2011 {
gen t`X'var17head = c`X'childcaretotal * (c`X'sumheadchild16 / (c`X'sumheadchild16 + c`X'sumcohabchild16 + c`X'sumofumtaxchild16))
replace t`X'var17head = 0 if missing(t`X'var17head) // only missing for those not in sample for the year

gen t`X'var17wife = c`X'childcaretotal * (c`X'sumcohabchild16 / (c`X'sumheadchild16 + c`X'sumcohabchild16 + c`X'sumofumtaxchild16))
replace t`X'var17wife = 0 if missing(t`X'var17wife) // only missing for those not in sample for the year

gen t`X'var17joint = t`X'var17head

gen t`X'var17ofum = c`X'childcaretotal * (c`X'sumofumtaxchild16 / (c`X'sumheadchild16 + c`X'sumcohabchild16 + c`X'sumofumtaxchild16))
replace t`X'var17ofum = 0 if missing(t`X'var17ofum) // only missing for those not in sample for the year

gen t`X'var17simple = 0
}
* TAXSIM unemployment comp.
*	For missing values, median non-zero amount by family unit substituted (manually imputed above pre-2005, PSID provided from 2005 on).
foreach X in 1999 2001 2003 {
gen t`X'var18head = c`X'huntotal
replace t`X'var18head = 0 if missing(t`X'var18head) // only missing for those not in sample for the year

gen t`X'var18wife = c`X'wuntotal
replace t`X'var18wife = 0 if missing(t`X'var18wife) // only missing for those not in sample for the year

gen t`X'var18joint = t`X'var18head + t`X'var18wife

gen t`X'var18ofum = 0 // pre-2005 no unempl for OFUM

gen t`X'var18simple = 0
}
foreach X in 2005 2007 2009 2011 {
gen t`X'var18head = c`X'huntotal
replace t`X'var18head = 0 if missing(t`X'var18head) // only missing for those not in sample for the year

gen t`X'var18wife = c`X'wuntotal
replace t`X'var18wife = 0 if missing(t`X'var18wife) // only missing for those not in sample for the year

gen t`X'var18joint = t`X'var18head + t`X'var18wife

gen t`X'var18ofum = unempofum`X' // 2005 on OFUM unempl is available
replace t`X'var18ofum = 0 if missing(t`X'var18ofum) // only missing for those not in sample for the year

gen t`X'var18simple = 0
}
* TAXSIM dependents under age 17. No missing values in sumchild variables.
foreach X in 1999 2001 2003 2005 2007 2009 2011 {
gen t`X'var19head = c`X'sumheadchild16
replace t`X'var19head = 0 if missing(t`X'var19head)

gen t`X'var19wife = c`X'sumcohabchild16
replace t`X'var19wife = 0 if missing(t`X'var19wife)

gen t`X'var19joint = t`X'var19head + t`X'var19wife

gen t`X'var19ofum = c`X'sumofumtaxchild16
replace t`X'var19ofum = 0 if missing(t`X'var19ofum)

gen t`X'var19simple = intnumchd`X'
replace t`X'var19simple = 0 if missing(t`X'var19simple)
}
* TAXSIM itemized deductions (head only). Mortgage interest calculation in separate dofile.
*	Missing values for charitable gifts and medical expense deduction set to zero (not imputed).
*	Missing values for mortgage interest also effectively set to zero if any components used to
*		calculate are missing.

foreach X in 1999 2001 2003 2005 2007 2009 2011 {
egen t`X'var20head = rsum(m`X'intdeduc chardeduc`X' meddeduc`X')
replace t`X'var20head = 0 if itemize`X' != 1

gen t`X'var20wife = 0

gen t`X'var20joint = t`X'var20head

gen t`X'var20ofum = 0

gen t`X'var20simple = 0
}


*SAVING FILE BEFORE RUNNING TAXSIM
sort personid
save "$outdata/taxes_all_$datestamp", replace

*drop _merge
save "$outdata/taxes_posttaxsim_$datestamp", replace


