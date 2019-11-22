include common.do

/*
*Merge PSID indiv file with family file, (wealth file before 2009), (social security file before 2009), selected and renamed variables only
*/


*list of variables for head or wife
#d;
global
	indvars 
	empstat1st  empstat2nd empstat3rd wkfrmoney everwk 

	earninggen
	gardincgen
	laborbzgen
	assetbzgen
	farmincgen 
	ssigen adcgen chdspgen welfgen unempgen wkcmpgen hlprelgen hlpfrdgen othtrgen alimgen vapengen othpengen annuigen retunkgen othretgen
	socsectype ssincgen
	
	anypen pentp cjten nra1age nrafml nra1yr nra2yr nra2age era1age era1yr erafml
	era2yr era2age anyunwc unwcamt gxframt anygxfr
	;
#d cr

*list of variables for head+wife
#d cr
#d;
global fmvars 
	taxincgen
	trsincgen
	ottaxincgen 
	ottrsincgen 
	hatota
	fdstmpgen
	totalfaminc
	;
#d cr

*-------------------------------------------
*First process social security file 94-07
/*
The SOCSECTYPE94_07 file contains information on head’s and wives’ social security income 
type for 1994-2007 survey years (question G33: “First let me ask about Social Security.
 Was that disability, retirement, survivor's benefits, or what?”). 
 1-“Disability”, 2-“Retirement”, 3-  “Survivor's benefits; dependent of deceased recipient “, 
 4-“Any combination of codes 1-3 and 5-7”, 5-“Dependent of disabled recipient “, 
 6-“Dependent of retired recipient”, 7-“Other”, 8-“Do not know”, 
 9-“Not available”, 0-“Inappropriate: received no Social Security/  no wife.” 
*/	
*-------------------------------------------

	use "$psid_dir/Stata/socsectype94_07.dta", clear
	keep if year >= 1999
	ren yrid famfid
	tempfile ssfile
	des
	save `ssfile', replace

* local begyr 1999
* local endyr 2009

forvalues i = $firstyr(2)$lastyr {
	use "$temp_dir/psid_inder_${firstyr}to${lastyr}.dta", clear
	keep if year == `i' 
	ren famnum famfid
	drop if missing(id) | missing(famfid)

	*IF before year 2009, merge with social security type file
	if `i' < 2009 {
		cap drop _merge
		merge n:1 famfid year using `ssfile', keep(master match)
		drop _merge
	}
	*FROM FAMILY FILES
	merge n:1 famfid year using "$temp_dir/psid_fam`i'er_select_rcd"
	drop if _merge ==2
	tab seq _merge
	ren _merge merged_familyfile

	*ASSIGN VARIABLES FROM FAMILY FILE TO INDIVIDUAL FILE DEPENDING ON HEAD/WIFE OR COMBINED VARIABLE
	foreach x in $indvars {
		gen `x' = .
		*for head
		cap confirm var hd`x'
		if _rc==0 {
			replace `x' = hd`x' if head == 1
		}
		*for wife
		cap confirm var wf`x'
		if _rc==0 {
			replace `x' = wf`x' if wife == 1
		}		
	}
	if `i' >= 2009 {
		replace socsectype = sstype
	}
	drop sstype

	foreach x in $fmvars {
		gen `x' = .
		cap confirm var hd`x'
		if _rc==0 {
			replace `x' = hd`x' if head == 1 | wife == 1
		}
	}
	
	*Wealth file if before year 2009
	if `i' < 2009 {
		merge n:1 famfid year using "$temp_dir/wlth`i'_rcd.dta"
		drop if _merge == 2
		replace hatota = hdwlthwteq if _merge == 3
		drop _merge
	}
	
	#d;
	keep id famno68 pn68 hdwfever seq famfid relhd age empstatoth hlins1st hlins2nd hlins3rd hlins4th  hlinsmo head wife year
		merged_familyfile
		curhlins curhlins1st curhlins2nd curhlins3rd
		$indvars $fmvars ; 
	#d cr
	
	*rename some family level variables 
	foreach x in taxincgen trsincgen	ottaxincgen ottrsincgen fdstmpgen {
		ren `x' h`x'
	}

	save "$temp_dir/psid_econ_merged`i'.dta", replace
	sum
}

