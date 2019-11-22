
/*
*EXTRACT PSID ECON-RELATED VARIABLES FROM PSID FAMILY FILES, INDIVIDUAL FILE, SOCIAL SECURITY FILE, AND WEALTH FILES
*/

include common.do

*---------------------------------------------------
*extract and rename variables from PSID family file
*within this file, also run
* psid_fam_econvars_list.do 
* rename_psidvar.ado
*---------------------------------------------------

do "$wkdir/psid_fam_extract.do" 


*---------------------------------------------------
*recode and annulize econ variables extracted from PSID family file
*within this file, also run
*  annualize_psidvar.ado
*---------------------------------------------------

do "$wkdir/psid_fam_recode.do" 


*---------------------------------------------------
*extract and rename variables from PSID individual file - make it a long format
*within this file, also run
*  rename_psidvar.ado
*---------------------------------------------------

do "$wkdir/psid_ind_extract.do" 


*---------------------------------------------------
*extract and rename variables from PSID wealth file (before 2009)
*---------------------------------------------------
do "$wkdir/psid_wealth_extract.do" 


*---------------------------------------------------
*merge files - individual file, social security claiming type file, family file, and wealth file 
*---------------------------------------------------
do "$wkdir/psid_econ_merge.do" 


*---------------------------------------------------
*recode/rename merged file, and merge with Bryan's file to get demographics and health variables
*---------------------------------------------------
do "$wkdir/psid_econ_recode.do" 
exit
*---------------------------------------------------
*In the end remove intermediate files
*---------------------------------------------------
shell rm "$temp_dir/*.dta"

