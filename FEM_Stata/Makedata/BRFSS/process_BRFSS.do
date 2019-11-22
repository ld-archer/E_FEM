/* Prorcess the BRFSS to generate a longitudinal file.  At present, only focused on generating a longitudinal file for validation of diabetes by age 

This was developed to pull data from 1999 through 2016.  If you want earlier years, you'll need to standardize the variables.

*/

quietly include ../../../fem_env.do

local begyr = 1999
local endyr = 2016

forvalues year = `begyr'/`endyr' {
	use $brfss_dir/brfss_`year'.dta, replace
	
	lookfor infar
	
	di "Processing BRFSS for `year'"
	
	rename *, lower
	
	* Keep id, sampling weight, diabetes measure, and age
	if inrange(`year',1999,2003) {
		local weight_var a_finalwt 
		local diab_var diabetes 
		local age_var age 
		if inrange(`year',1999,2000) {
			local heartattack_var cvdinfar
			local cvd_var cvdcorhd
			local stroke_var cvdstrok
			local asthma_var asthma
			local skin_var    
			local cancer_var  
			local emphy_var   
			local arthri_var havarth
			local depress_var 
			local kidn_var    
			local hibp_var bphigh
		}
		else if inrange(`year',2001,2003) {
			local heartattack_var cvdinfr2
			local cvd_var cvdcrhd2
			local stroke_var cvdstrk2
			local asthma_var asthma2
			local skin_var    
			local cancer_var  
			local emphy_var   
			if `year' == 2001 {
				local arthri_var havarth
				local hibp_var bphigh2
			}
			else if inrange(`year',2002,2003) {
				local arthri_var havarth2
				local hibp_var bphigh3
			}
			local depress_var 
			local kidn_var  
		}
		if `year' == 1999 {
			local bmi_var a_bmi
		}
		if inlist(`year',2000,2001,2002) {
			local bmi_var a_bmi2
		}
		if `year' == 2003 {
			local bmi_var a_bmi3
		}
	}
	* New diabetes measure
	else if inrange(`year',2004,2010) {
		local weight_var a_finalwt 
		local diab_var diabete2 
		local age_var age 
		local bmi_var a_bmi4
		if `year' == 2004 {
			local heartattack_var cvdinfr2
			local cvd_var cvdcrhd2
			local stroke_var cvdstrk2
			local asthma_var asthma2
			local skin_var    
			local cancer_var  
			local emphy_var   
			local arthri_var havarth2
			local depress_var 
			local kidn_var  			
			local hibp_var bphigh3
		}
		else if inrange(`year',2005,2006) {
			local heartattack_var cvdinfr3
			local cvd_var cvdcrhd3
			local stroke_var cvdstrk3
			local asthma_var asthma2
			local skin_var    
			local cancer_var  
			local emphy_var   
			if `year' == 2005 {
				local arthri_var havarth2
				local hibp_var bphigh4
			}
			else if `year' == 2006 {
				* not collected in 2006
				local arthri_var 
				local hibp_var 	
			}
			
			local depress_var 
			local kidn_var  	
		}
		else if inrange(`year',2007,2010) {
			local heartattack_var cvdinfr4
			local cvd_var cvdcrhd4
			local stroke_var cvdstrk3
			local asthma_var asthma2
			local skin_var    
			
			if inlist(`year',2007,2008) {
				* not asked
				local cancer_var 
			}
			else if inlist(`year',2009,2010) {
				local cancer_var cncrhave
			}
			local emphy_var   
			if inlist(`year',2007,2009,2010) {
				local arthri_var havarth2
			}
			if `year' == 2008 {
				* not collected in 2008
				local arthri_var 
			}
			if `year' < 2010 {
				* not asked before 2010
				local depress_var
			} 
			if `year' == 2010 {
				local depress_var addepev
				
			}
			local kidn_var  	
			if inlist(`year',2007,2009) {
				local hibp_var bphigh4		
			}
			else if inlist(`year',2008,2010) {
				local hibp_var
			}
		}
		
		
	}
	* New weighting measure, new diabetes measure
	else if inrange(`year',2011,2012) {
		local weight_var a_llcpwt 
		local diab_var diabete3 
		local age_var age 
		local heartattack_var cvdinfr4
		local cvd_var cvdcrhd4
		local stroke_var cvdstrk3
		local asthma_var asthma3
		local skin_var chcscncr
		local cancer_var chcocncr
		local bmi_var a_bmi5 
				
		if `year' == 2011 {
			local emphy_var chccopd
			local hibp_var bphigh4
		}
		else if `year' == 2012 {
			local emphy_var chccopd1
			local hibp_var 
		}
		
		local arthri_var havarth3
		local depress_var addepev2
		local kidn_var chckidny
	}
	* Age capped at 80 after 2013
	else if `year' == 2013 {
		local weight_var a_llcpwt 
		local diab_var diabete3 
		local age_var a_age80
		local heartattack_var cvdinfr4
		local cvd_var cvdcrhd4
		local stroke_var cvdstrk3
		local asthma_var asthma3
		local skin_var chcscncr   
		local cancer_var chcocncr
		local emphy_var chccopd1
		local arthri_var havarth3
		local depress_var addepev2
		local kidn_var chckidny	
		local hibp_var bphigh4
		local bmi_var a_bmi5
	}
	* Renamed weight variable for 2014, renamed age variable
	else if `year' >= 2014 {
		local weight_var _LLCPWT 
		local diab_var diabete3 
		local age_var _AGE80
		local heartattack_var cvdinfr4
		local cvd_var cvdcrhd4
		local stroke_var cvdstrk3
		local asthma_var asthma3
		local skin_var chcscncr    
		local cancer_var chcocncr
		local emphy_var chccopd1  
		local arthri_var havarth3
		local depress_var addepev2
		local kidn_var chckidny		
		local bmi_var _BMI5
		if inlist(`year',2014,2016) {
			local hibp_var
		}
		else if `year' == 2015 {
			local hibp_var bphigh4
		} 
	}
	
	* This is a mixture of common variables and variables with changing names over time (stored in locals)
	#d ;
	keep iyear sex educa
	`age_var' 
	`weight_var' 
	`diab_var' 
	`heartattack_var'
	`cvd_var'
	`stroke_var'
	`asthma_var'
	`skin_var'
	`cancer_var'
	`emphy_var'
	`arthri_var'
	`depress_var'
	`kidn_var'
	`hibp_var'
	`bmi_var'
	;
	#d cr
	
	gen year = `year'
	gen weight_raw = `weight_var'
	gen diab_raw = `diab_var'
	gen age_raw = `age_var'
	gen heartattack_raw = `heartattack_var'
	gen cvd_raw = `cvd_var'
	gen stroke_raw = `stroke_var'
	gen asthma_raw = `asthma_var'
	gen bmi_raw = `bmi_var'
	
	* Some outcomes not collected in all years
	cap gen arthritis_raw = `arthri_var'
	cap gen skincancer_raw = `skin_var'
	cap gen cancer_raw = `cancer_var'	
	cap gen emphy_raw = `emphy_var'
	cap gen depress_raw = `depress_var'
	cap gen kidn_raw = `kidn_var'
	cap gen hibp_raw = `hibp_var'
	
	tempfile brfss_`year'
	save `brfss_`year''
	
}

clear

forvalues year = `begyr'/`endyr' {
	append using `brfss_`year''
}


/* Recode ever-told diabetes (question varies by year)
1 - yes
2 - yes, during pregnancy
3 - no 
4 - pre-diabetes, borderline (added in 2004)
7 - don't know
9 - refused
*/
recode diab_raw (1=1) (2/4=0) (7/9=.), gen(diabe)
label var diabe "ever told diabetes"

recode heartattack_raw (1=1) (2=0) (7/9=.), gen(heartae)
label var heartae "ever told heart attack"

recode cvd_raw (1=1) (2=0) (7/9=.), gen(cvde)
label var cvde "ever told angina or coronary heart disease"

recode stroke_raw (1=1) (2=0) (7/9=.), gen(stroke)
label var stroke "ever told stroke"

recode asthma_raw (1=1) (2=0) (7/9=.), gen(asthmae)
label var asthmae "ever told asthma"

recode arthritis_raw (1=1) (2=0) (7/9=.), gen(arthritise)
label var arthritise "ever told arthritis"

recode skincancer_raw (1=1) (2=0) (7/9=.), gen(skincancer)
label var skincancer "ever told skin cancer (2011+)"

recode emphy_raw (1=1) (2=0) (7/9=.), gen(lunge)
label var lunge "ever told COPD, emphysema, or chronic bronchitis"

recode arthritis_raw  (1=1) (2=0) (7/9=.), gen(arthre)
label var arthre "ever told arthritis (not asked in 2006 and 2008)"

recode depress_raw (1=1) (2=0) (7/9=.), gen(depresse)
label var depresse "ever told depressive disorder (2010+)"

recode kidn_raw (1=1) (2=0) (7/9=.), gen(kidneye)
label var kidneye "ever told kidney disease (2011+)"

recode hibp_raw (1=1) (2/4=0) (7/9=.), gen(hibpe)
label var hibpe "ever told high blood pressure"


* Heart disease (heart attack OR heart disease ... )
egen hearte = rowmax(heartae cvde)
label var hearte "ever angina, coronary heart disease or heart attack/MI"


* BMI has different implied decimal places and missing values
* one implied decimal place
gen bmi = bmi_raw
replace bmi = . if bmi == 999 & inlist(year,1999,2000)
replace bmi = bmi/10 if inlist(year,1999,2000)

* four implied decimal places 
replace bmi = . if bmi == 999999 & inlist(year,2001)
replace bmi = bmi/10000 if inlist(year,2001)

* two implied decimal places (9999 was missing code only through 2010)
replace bmi = . if bmi == 9999 & inrange(year,2002,2010)
replace bmi = bmi/100 if year >= 2002 

label var bmi "BMI derived from self-reported height and weight"


* Demographic recodes
recode age_raw (80/100 = 80), gen(age_yrs)
recode educa (1/3=1) (4=2) (5=3) (6=4) (9=.), gen(educ_lvl)

label var age_yrs "Age capped at 80"
label var educ_lvl "Education completed"

label define educ_lvl 1 "Less than HS" 2 "HS/GED" 3 "Some college (1-3 years)" 4 "College (4 or more years)"
label values educ_lvl educ_lvl

label var cancer_raw "cancer raw variable (includes skin 2009 and 2010)"

recode sex (1=1) (2=0), gen(male)
label var male "Male"

* Keep the demographic variables, weighting variables, and the recoded chronic conditions
#d ;
keep year male age_yrs educ_lvl weight_raw
diabe heartae cvde stroke asthmae arthritise skincancer lunge arthre depresse kidneye hearte hibpe bmi
bmi_raw
hibp_raw
; 
#d cr




save $outdata/brfss.dta, replace





























capture log close

