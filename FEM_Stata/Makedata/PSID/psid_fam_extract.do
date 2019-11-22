include common.do
dis "$wkdir"
dis "`local_path'"
dis "`local_root'"

***************************************************
*EXTRACT AND RENAME VARIABLES FROM PSID FAMILY YEARLY FILES
***************************************************


*RUN THE DO FILE THAT DEFINE ALL THE GLOBALS FOR VARIABLE LISTS
do "$wkdir/psid_fam_econvars_list.do"
*RUN THE ADO FILE THAT RENAME RAW VARIABLES
run "$wkdir/rename_psidvar.ado"

*EXPANDED LISTS OF VARIABLES RELATED TO DIFFERENT INCOME COMPONENTS

*type of income
*for head
global hdlist_short ssi adc chdsp welf fdstmp unemp wkcmp vapen alim othret othpen annui retunk hlprel hlpfrd othtr
*for wife
global wflist_short ssi adc chdsp welf        unemp wkcmp      othret                    hlprel hlpfrd othtr

foreach p in hd wf {
	local lshort `p'list_short
	local llong `p'list_long
	global `llong' 
	foreach x in $`lshort' {
		
		if "`p'" == "hd" & "`x'" == "othret" {
			foreach s in any {
				global `llong' $`llong' `p'`x'`s'in
			}
		} 
		else if "`x'" != "vapen" & "`x'" != "fdstmp" {
			foreach s in any amt per jan gen {
				global `llong' $`llong' `p'`x'`s'in
			}
		}
		else if "`x'" == "vapen" {
			foreach s in 1any 2any 3any amt per jan gen {
				global `llong' $`llong' `p'`x'`s'in
			}		
		}
		else if "`x'" == "fdstmp" {
			foreach s in any amt per jan {
				global `llong' $`llong' `p'`x'`s'in
			}		
		}		
	}
}
*dis "$hdlist_long"
*dis "$wflist_long"

*INDICATE WHAT VARIABLE LISTS TO EXTRACT
set trace off
#d;
	global allvars famfidin 
	hdearninggenin  wfearninggenin 
hdgardincgenin hdlaborbzgenin wflaborbzgenin hdassetbzgenin wfassetbzgenin hdfarmincgenin hdtaxincgenin hdtrsincgenin
hdssincgenin wfssincgenin
hdottaxincgenin hdottrsincgenin
hdempstat1stin  hdempstat2ndin hdempstat3rdin hdwkfrmoneyin hdeverwkin
wfempstat1stin  wfempstat2ndin wfempstat3rdin wfwkfrmoneyin wfeverwkin
hdcjtenin wfcjtenin hdmjindin wfmjindin hdmjbyrin wfmjbyrin
hdanypenin wfanypenin hdpentpin wfpentpin hdpenyrin wfpenyrin hdpenftin wfpenftin
hdnrafmlin wfnrafmlin hdnra1agein wfnra1agein  hdnra1yrin  wfnra1yrin hdnra2agein wfnra2agein hdnra2yrin wfnra2yrin 
hderafmlin wferafmlin hdera1agein wfera1agein  hdera1yrin  wfera1yrin hdera2agein wfera2agein hdera2yrin wfera2yrin 
hdhatotain
hdtotalfamincin

$hdlist_long
$wflist_long ;
#d cr

dis "$allvars"

* local begyr = 1999
* local endyr = 2009

forvalues i = $firstyr(2)$lastyr {
	cap log close
	log using "$wkdir/psid_econvars_fam`i'.log", replace
	use "$psid_dir/Stata/fam`i'er.dta", clear	

	foreach x in $allvars {
		rename_psidvar, rawlist("`x'")  yyyy(`i') naming_yr(0)
	}
	drop ER*
	cap drop year
	gen year = `i'
	save "$temp_dir/psid_fam`i'er_select", replace
	des
	*sum
}
exit

*Stack family files
clear
forvalues i = $lastyr(-2)$firstyr {
	append using "$temp_dir/fam`i'er_select"
	compress
	save "$temp_dir/famer_`begyr'to`endyr'.dta",replace
}

