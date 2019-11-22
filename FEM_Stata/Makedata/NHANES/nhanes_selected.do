/* This file will construct a cross-sectionatal version of the NHANES 1999-present */

include ../../../fem_env.do

local lastyr 2011

local i = 1
forvalues x = 1999 (2) `lastyr' {
	local y = `x' + 1
	
	if `x' == 1999 {
		local suf 
	}
	else if `x' == 2001 {
		local suf "_b"
	}
	else if `x' == 2003 {
		local suf "_c"
	}
	else if `x' == 2005 {
		local suf "_d"
	}
	else if `x' == 2007 {
		local suf "_e"
	}
	else if `x' == 2009 {
		local suf "_f"
	}
	else if `x' == 2011 {
		local suf "_g"
	}
	
	use $nhanes_dir/stata/`x'-`y'/demo`suf'.dta, replace
	merge 1:1 seqn using $nhanes_dir/stata/`x'-`y'/mcq`suf'.dta, nogen
	merge 1:1 seqn using $nhanes_dir/stata/`x'-`y'/diq`suf'.dta, nogen
	merge 1:1 seqn using $nhanes_dir/stata/`x'-`y'/bpq`suf'.dta, nogen
	merge 1:1 seqn using $nhanes_dir/stata/`x'-`y'/whq`suf'.dta, nogen
	merge 1:1 seqn using $nhanes_dir/stata/`x'-`y'/pfq`suf'.dta, nogen
	merge 1:1 seqn using $nhanes_dir/stata/`x'-`y'/bmx`suf'.dta, nogen
	
	gen source = `i'
	
	rename *, lower  

	tempfile tmp`i'
	save `tmp`i''
	local i = `i' + 1
}

local i = 1
forvalues x = 1999 (2) `lastyr' {
	append using `tmp`i''
	local i = `i' + 1
}

label define source 1 "1999-2000" 2 "2001-2002" 3 "2003-2004" 4 "2005-2006" 5 "2007-2008" 6 "2009-2010" 7 "2011-2012"
label values source source

gen year = 1997 + 2*source


* Clean up variables for interest

* Demographics
recode riagendr (1=1) (2=0), gen(male)

* Age (exact, at examination)
gen age_e = ridageex/12
gen age_y = floor(age_e)

* Cancer
recode mcq220 (1=1) (2=0) (7=.) (9=.), gen(cancre)
* Diabetes: 3 is "borderline", coding as "yes"
recode diq010 (1=1) (2=0) (3=1) (7=.) (9=.), gen(diabe)

* Heart Disease (including heart failure, heart disease, angina, and heart attack)
recode mcq160b (1=1) (2=0) (7=.) (9=.), gen(heart_failure)
recode mcq160c (1=1) (2=0) (7=.) (9=.), gen(coronary_hd)
recode mcq160d (1=1) (2=0) (7=.) (9=.), gen(angina)
recode mcq160e (1=1) (2=0) (7=.) (9=.), gen(heart_attack)
gen hearte = .
replace hearte = (heart_failure == 1) if !missing(heart_failure)
replace hearte = 1 if coronary_hd & !missing(coronary_hd)
replace hearte = 1 if angina & !missing(angina)
replace hearte = 1 if heart_attack & !missing(heart_attack)


* Hypertension
recode bpq020 (1=1) (2=0) (7=.) (9=.), gen(hibpe)

* Lung disease (including: emphysema and chronic bronchitis
recode mcq160g (1=1) (2=0) (7=.) (9=.), gen(emphysema)
recode mcq160k (1=1) (2=0) (7=.) (9=.), gen(chr_bronch)
gen lunge = (emphysema == 1 | chr_bronch == 1) if !missing(emphysema) | !missing(chr_bronch)

* Stroke
recode mcq160f (1=1) (2=0) (7=.) (9=.), gen(stroke)

* Need overweight, obese1, obese2, obese3 
gen overwt = (bmxbmi >= 25 & bmxbmi < 30) & !missing(bmxbmi)
gen obese  = (bmxbmi >= 30) & !missing(bmxbmi)
gen obese1 = (bmxbmi >= 30 & bmxbmi < 35) & !missing(bmxbmi)
gen obese2 = (bmxbmi >= 35 & bmxbmi < 40) & !missing(bmxbmi)
gen obese3 = (bmxbmi >= 40) & !missing(bmxbmi)

label var male "Male"
label var age_e "Exact age at examination"
label var age_y "Age in years at examination"
label var cancre "Ever told had cancer or malignancy"
label var diabe "Ever told diabetes (includes borderline, excludes gestational)"
label var hearte "Ever told have heart failure, heart disease, angina, or heart attack"
label var hibpe "Ever told have high blood pressure"
label var lunge "Ever told have emphysema or chronic bronchitis"
label var stroke "Ever told had a stroke"
label var overwt "25 < BMI < 30"
label var obese "BMI > 30"
label var obese1 "30 < BMI < 35"
label var obese2 "35 < BMI < 40"
label var obese3 "BMI > 40"

save $outdata/nhanes_selected.dta, replace


capture log close
