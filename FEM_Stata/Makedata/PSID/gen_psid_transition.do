include common.do

use "$outdata/psid_analytic.dta", clear


* Drop first year (we require lagged variables)
drop if year == 1999

* Drop if new repondent in subsequent year
drop if newobservation == 1
	
* A little data cleaning that should be done at an earlier stage of the process
drop if age == 999 /*| lage == 999*/
drop if l2age == 999

* Recode adlstat and iadlstat to dummy variables (index starts at 1 for zero adl or iadl)
foreach var in adl l2adl fadl {
	gen `var'1 = (`var'stat == 2)
	gen `var'2 = (`var'stat == 3)
	gen `var'3p = (`var'stat >= 4 & `var'stat < .)
	replace `var'1 = . if `var'stat == .
	replace `var'2 = . if `var'stat == .
	replace `var'3p = . if `var'stat == .
}

label var adl1 "One ADL"
label var adl2 "Two ADLs"
label var adl3p "Three or more ADLs"
label var l2adl1 "Lag of one ADL"
label var l2adl2 "Lag of two ADLs"
label var l2adl3p "Lag of three or more ADLs"
label var fadl1 "Init. of one ADL"
label var fadl2 "Init. of two ADLs"
label var fadl3p "Init. of three or more ADLs"


foreach var in iadl l2iadl fiadl {	
 	gen `var'1 = (`var'stat == 2)
	gen `var'2p = (`var'stat >= 3 & `var'stat < .)
	replace `var'1 = . if `var'stat == .
	replace `var'2p = . if `var'stat == .
}

label var iadl1 "One IADL"
label var iadl2p "Two or more IADLs"
label var l2iadl1 "Lag of one IADL"
label var l2iadl2p "Lag of two or more IADLs"
label var fiadl1 "Init. of one IADL"
label var fiadl2 "Init. of two or more IADLs"


* Recode child SRH to dummy variables
foreach var in chldsrh {
	gen chldsrh1 = (`var' == 1) if !missing(`var')
	gen chldsrh2 = (`var' == 2) if !missing(`var')
	gen chldsrh3 = (`var' == 3) if !missing(`var')
	gen chldsrh4 = (`var' == 4)	if !missing(`var')
	gen chldsrh5 = (`var' == 5) if !missing(`var')
}

label var chldsrh1 "Childhood health - poor"
label var chldsrh2 "Childhood health - fair"
label var chldsrh3 "Childhood health - good"
label var chldsrh4 "Childhood health - very good"
label var chldsrh5 "Childhood health - excellent"


* Recode births to dummy variables
foreach var in births l2births {
	gen `var'1 = (`var' == 2) if !missing(`var')
	gen `var'2p = (`var' >= 3) if !missing(`var')
}

label var births1 "One birth"
label var births2p "Two births"
label var l2births1 "Lag of one birth"
label var l2births2p "Lag of two births"


* Recode yrsnclastkid lyrsnclastkid to dummy variables and create quadratic term
gen l2yrsnclastkid2 = l2yrsnclastkid*l2yrsnclastkid if l2yrsnclastkid < .
label var l2yrsnclastkid2 "Lag years since last kid squared"

foreach var in yrsnclastkid l2yrsnclastkid {

	gen `var'lt4 = (`var' < 4)
	gen `var'4p = (`var' >= 4)
	replace `var'lt4 = . if `var' == .
	replace `var'4p = . if `var' == .
}


* Recode kidsinfu, numbiokids, and numbiokidslt18 to dummy variables
foreach var in kidsinfu l2kidsinfu numbiokids l2numbiokids numbiokidslt18 l2numbiokidslt18 {
	gen `var'1 = (`var' == 1)
	gen `var'2 = (`var' == 2)
	gen `var'2p = (`var' >= 2)
	gen `var'3p = (`var' >= 3)
	replace `var'1 = . if `var' == .
	replace `var'2 = . if `var' == .
	replace `var'2p = . if `var' == .
	replace `var'3p = . if `var' == .
}

label var kidsinfu1 "1 kids in family unit"
label var kidsinfu2 "2 kids in family unit"
label var kidsinfu2p "2+ kids in family unit"
label var kidsinfu3p "3+ kids in family unit"

label var l2kidsinfu1 "Lag of 1 kids in family unit"
label var l2kidsinfu2 "Lag of 2 kids in family unit"
label var l2kidsinfu2p "Lag of 2+ kids in family unit"
label var l2kidsinfu3p "Lag of 3+ kids in family unit"

label var numbiokids1 "1 biological child" 
label var numbiokids2 "2 biological children"
label var numbiokids2p "2 or more biological children"
label var numbiokids3p "3 or more biological children"

label var l2numbiokids1 "Lag of 1 biological child" 
label var l2numbiokids2 "Lag of 2 biological children"
label var l2numbiokids2p "Lag of 2 or more biological children"
label var l2numbiokids3p "Lag of 3 or more biological children"

label var numbiokidslt181 "1 biological child under 18" 
label var numbiokidslt182 "2 biological children under 18"
label var numbiokidslt182p "2 or more biological children under 18"
label var numbiokidslt183p "3 or more biological children under 18"

label var l2numbiokidslt181 "Lag of 1 biological child under 18" 
label var l2numbiokidslt182 "Lag of 2 biological children under 18"
label var l2numbiokidslt182p "Lag of 2 or more biological children under 18"
label var l2numbiokidslt183p "Lag of 3 or more biological children under 18"


* Four levels of work categorical variable
foreach var in workcat l2workcat {
	gen `var'1 = (`var' == 1)
	gen `var'2 = (`var' == 2)
	gen `var'3 = (`var' == 3)
	gen `var'4 = (`var' == 4)
}

label var workcat1 "Out of labor force"
label var workcat2 "Unemployed"
label var workcat3 "Part-time"
label var workcat4 "Full-time"

label var l2workcat1 "Lag of Out of labor force"
label var l2workcat2 "Lag of Unemployed"
label var l2workcat3 "Lag of Part-time"
label var l2workcat4 "Lag of Full-time"


* Generate age spline variables
local age_var aged
	gen l2age24l = min(22,l2`age_var') if l2`age_var' < .
	label var l2age24l "Age spline, less than 24"
	gen l2age2529 = min(max(0,l2`age_var'-23),28-23)
	label var l2age2529 "Age spline, 25 to 29"
	gen l2age3034 = min(max(0,l2`age_var'-28),33-28)
	label var l2age3034 "Age spline, 30 to 34"
	gen l2age35l = min(33,l2`age_var') if l2`age_var' < .
	label var l2age35l "Age spline, less than 35"
	gen l2age3544 = min(max(0,l2`age_var'-33),43-33) if l2`age_var' < .
	label var l2age3544 "Age spline, 35 to 44"
	gen l2age4554 = min(max(0,l2`age_var'-43),53-43) if l2`age_var' < .
	label var l2age4554 "Age spline, 45 to 54"
	gen l2age5564 = min(max(0,l2`age_var'-53),63-53) if l2`age_var' < .	
	label var l2age5564 "Age spline, 55 to 64"
	gen l2age55p = max(0,l2`age_var'-53) if l2`age_var' < .
	label var l2age55p "Age spline, more than 55"
	gen l2age65l  = min(63,l2`age_var') if l2`age_var' < .
	label var l2age65l "Age spline, less than 65"
	gen l2age65p = max(0, l2`age_var'-63) if l2`age_var' < .
	label var l2age65p "Age spline, more than 65"
	gen l2age6574 = min(max(0,l2`age_var'-63),73-63) if l2`age_var' < .
	label var l2age6574 "Age spline, 65 to 74"
	gen l2age75p = max(0, l2`age_var'-73) if l2`age_var' < . 
	label var l2age75p "Age spline, more than 75"
	

	
	
	gen agesq = `age_var'*`age_var'

gen over65 = (l2`age_var' >= 63) if l2`age_var' < . 

* Generate age spline * gender interactions
gen male_l2age65l =  male*l2age65l 
gen male_l2age6574 = male*l2age6574
gen male_l2age75p = male*l2age75p 

label var male_l2age65l "Male, less than 65"
label var male_l2age6574 "Male, age 65 to 74"
label var male_l2age75p "Male, age more than 75"

* Generate squared lag of age
gen l2agesq = l2`age_var' * l2`age_var'
label var l2agesq "l2age^2"

foreach var in educ1 educ2 educ3 educ4 {
	gen l2age_`var' = l2`age_var' * `var'
	gen l2agesq_`var' = l2agesq * `var'
}

* Spline for above age 65 (for use in earnings models)
foreach var in male educ1 educ2 educ3 educ4 {
	gen l2age65p_`var' = l2age65p * `var'
}

* Generate age dummies
gen l2age2529d = 23 <= l2`age_var' & l2`age_var' < 28
gen l2age3034d = 28 <= l2`age_var' & l2`age_var' < 33
gen l2age30pd	 = 28 <= l2`age_var'
gen l2age3539d = 33 <= l2`age_var' & l2`age_var' < 38
gen l2age35pd	 = 33 <= l2`age_var'
gen l2age4049d = 38 <= l2`age_var' & l2`age_var' < 48
gen l2age40pd	 = 38 <= l2`age_var'
gen l2age5059d = 48 <= l2`age_var' & l2`age_var' < 58
gen l2age50pd  = 48 <= l2`age_var'
gen l2age6064d = 58 <= l2`age_var' & l2`age_var' < 63
gen l2age60pd  = 58 <= l2`age_var'
gen l2age62pd  = 60 <= l2`age_var'
gen l2age65pd  = 63 <= l2`age_var'
gen l2age6069d = 58 <= l2`age_var' & l2`age_var' < 68
gen l2age70pd  = 68 <= l2`age_var'

label var l2age2529d "Age 25 to 29"
label var l2age3034d "Age 30 to 34"
label var l2age30pd	 "Age more than 30"
label var l2age3539d "Age 35 to 39"
label var l2age35pd	 "Age more than 35"
label var l2age4049d "Age 40 to 49"
label var l2age40pd	 "Age more than 40"
label var l2age5059d "Age 50 to 59"
label var l2age50pd  "Age more than 50"
label var l2age6064d "Age 60 to 64"
label var l2age60pd  "Age more than 60"
label var l2age62pd  "Age more than 62"
label var l2age65pd  "Age more than 65"
label var l2age6069d "Age 60 to 69"
label var l2age70pd  "Age more than 70"

gen l2age6061 = floor(l2age) == 58 | floor(l2age) == 59 
gen l2age6263 = floor(l2age) == 60 | floor(l2age) == 61 
gen l2age6566 = floor(l2age) == 63 | floor(l2age) == 64 
gen l2age6770 = floor(l2age) >= 65 & floor(l2age) <= 68

label var l2age6061 "Age 60 to 61"
label var l2age6263 "Age 62 to 63"
label var l2age6566 "Age 65 to 66"
label var l2age6770 "Age 67 to 70"

gen male_l2age2529d = male & l2age2529d
gen male_l2age3034d = male & l2age3034d
gen male_l2age3539d = male & l2age3539d
gen male_l2age4049d = male & l2age4049d
gen male_l2age5059d = male & l2age5059d
gen male_l2age6064d = male & l2age6064d 
gen male_l2age65pd  = male & l2age65pd  
gen male_l2age6069d = male & l2age6069d
gen male_l2age70pd  = male & l2age70pd 

label var male_l2age2529d "Male, age 25 to 29"
label var male_l2age3034d "Male, age 30 to 34"
label var male_l2age3539d "Male, age 35 to 39"
label var male_l2age4049d "Male, age 40 to 49"
label var male_l2age5059d "Male, age 50 to 59"
label var male_l2age6064d "Male, age 60 to 64"
label var male_l2age65pd  "Male, age more than 65"
label var male_l2age6069d "Male, age 60 to 69"
label var male_l2age70pd  "Male, age more than 70"


gen black_l2age2529d  = black & l2age2529d
gen black_l2age3034d  = black & l2age3034d
gen black_l2age3539d  = black & l2age3539d
gen black_l2age4049d  = black & l2age4049d
gen black_l2age40pd		= black & l2age4049d
gen black_l2age5059d  = black & l2age5059d
gen black_l2age50pd	  = black & l2age50pd
gen black_l2age6064d  = black & l2age6064d 
gen black_l2age60pd   = black & l2age60pd
gen black_l2age65pd   = black & l2age65pd  
gen black_l2age6069d  = black & l2age6069d
gen black_l2age70pd   = black & l2age70pd 

label var black_l2age2529d "Black, age 25 to 29"
label var black_l2age3034d "Black, age 30 to 34"
label var black_l2age3539d "Black, age 35 to 39"
label var black_l2age4049d "Black, age 40 to 49"
label var black_l2age40pd	 "Black, age more than 40"
label var black_l2age5059d "Black, age 50 to 59"
label var black_l2age50pd	 "Black, age more than 50"
label var black_l2age6064d "Black, age 60 to 64"
label var black_l2age60pd  "Black, age more than 60"
label var black_l2age65pd  "Black, age more than 65"
label var black_l2age6069d "Black, age 60 to 69"
label var black_l2age70pd  "Black, age more than 70"


gen hispan_l2age2529d = hispan & l2age2529d
gen hispan_l2age3034d = hispan & l2age3034d
gen hispan_l2age30pd  = hispan & l2age30pd
gen hispan_l2age3539d = hispan & l2age3539d
gen hispan_l2age35pd  = hispan & l2age35pd
gen hispan_l2age4049d = hispan & l2age4049d
gen hispan_l2age40pd 	= hispan & l2age40pd
gen hispan_l2age5059d = hispan & l2age5059d
gen hispan_l2age50pd  = hispan & l2age50pd
gen hispan_l2age6064d = hispan & l2age6064d 
gen hispan_l2age60pd  = hispan & l2age60pd
gen hispan_l2age65pd  = hispan & l2age65pd  
gen hispan_l2age6069d = hispan & l2age6069d
gen hispan_l2age70pd  = hispan & l2age70pd 

label var hispan_l2age2529d "Hispanic, age 25 to 29"
label var hispan_l2age3034d "Hispanic, age 30 to 34"
label var hispan_l2age30pd "Hispanic, age more than 30"
label var hispan_l2age3539d "Hispanic, age 35 to 39"
label var hispan_l2age35pd "Hispanic, age more than 35"
label var hispan_l2age4049d "Hispanic, age 40 to 49"
label var hispan_l2age40pd	 "Hispanic, age more than 40"
label var hispan_l2age5059d "Hispanic, age 50 to 59"
label var hispan_l2age50pd	 "Hispanic, age more than 50"
label var hispan_l2age6064d "Hispanic, age 60 to 64"
label var hispan_l2age60pd  "Hispanic, age more than 60"
label var hispan_l2age65pd  "Hispanic, age more than 65"
label var hispan_l2age6069d "Hispanic, age 60 to 69"
label var hispan_l2age70pd  "Hispanic, age more than 70"


gen black_male_l2age2529d  = male & black & l2age2529d
gen black_male_l2age3034d  = male & black & l2age3034d
gen black_male_l2age3539d  = male & black & l2age3539d
gen black_male_l2age4049d  = male & black & l2age4049d
gen black_male_l2age5059d  = male & black & l2age5059d
gen black_male_l2age6064d  = male & black & l2age6064d 
gen black_male_l2age65pd   = male & black & l2age65pd  
gen black_male_l2age6069d  = male & black & l2age6069d
gen black_male_l2age70pd   = male & black & l2age70pd 
gen hispan_male_l2age2529d = male & hispan & l2age2529d
gen hispan_male_l2age3034d = male & hispan & l2age3034d
gen hispan_male_l2age3539d = male & hispan & l2age3539d
gen hispan_male_l2age4049d = male & hispan & l2age4049d
gen hispan_male_l2age5059d = male & hispan & l2age5059d
gen hispan_male_l2age6064d = male & hispan & l2age6064d 
gen hispan_male_l2age65pd  = male & hispan & l2age65pd  
gen hispan_male_l2age6069d = male & hispan & l2age6069d
gen hispan_male_l2age70pd  = male & hispan & l2age70pd 


foreach var in educ1 educ2 educ3 educ4 {
	gen `var'_l2age2529d = `var' & l2age2529d
	gen `var'_l2age3034d = `var' & l2age3034d
	gen `var'_l2age30pd  = `var' & l2age30pd
	gen `var'_l2age3539d = `var' & l2age3539d
	gen `var'_l2age35pd  = `var' & l2age35pd
	gen `var'_l2age4049d = `var' & l2age4049d
	gen `var'_l2age40pd  = `var' & l2age40pd
	gen `var'_l2age5059d = `var' & l2age5059d
	gen `var'_l2age50pd  = `var' & l2age50pd
	gen `var'_l2age6064d = `var' & l2age6064d 
	gen `var'_l2age60pd  = `var' & l2age60pd
	gen `var'_l2age65pd  = `var' & l2age65pd  
	gen `var'_l2age6069d = `var' & l2age6069d
	gen `var'_l2age70pd  = `var' & l2age70pd
}

/* Generate mother education level dummies  base= 0, Less than high school
gen mthred_1=(mthreduclvl==1) if mthreduclvl!=.
gen mthred_2=(mthreduclvl==2) if mthreduclvl!=.
gen mthred_3=(mthreduclvl==3) if mthreduclvl!=.
gen mthred_4=(mthreduclvl==4) if mthreduclvl!=.

gen mthrcollege=(mthred_2==1 | mthred_3==1 | mthred_4==1) if mthreduclvl!=.
gen mthrhsless=(mthreduclvl==0) if mthreduclvl!=. 

label var mthred_1 "Mother educ - HS"
label var mthred_2 "Mother educ - Some College/Assoc"
label var mthred_3 "Mother educ - BA/BS"
label var mthred_4 "Mother educ - Grad school"
*/

	* Generate obestiy splines
*	gen llogbmi = log(lbmi)
*	gen flogbmi = log(fbmi)	
	local log_30 = log(30)
	mkspline l2logbmi_l30 `log_30' l2logbmi_30p = l2logbmi
	mkspline flogbmi_l30 `log_30' flogbmi_30p = flogbmi
	
	label var l2logbmi_l30 "Log(BMI) spline, BMI < 30"
	label var l2logbmi_30p "Log(BMI) spline, BMI > 30"
	
	gen male_l2logbmi_l30 = male*l2logbmi_l30
	gen male_l2logbmi_30p = male*l2logbmi_30p
	
	
	* Generate logbmi outcome variable
*	gen logbmi = log(bmi) if bmi > 0 & bmi < .
	* Generate indicator of obesity
gen l2obes_ind = (l2bmi >= 30) if l2bmi !=.
label var l2obes_ind "Indicator of Obesity"

/*	
	* To be consistent with FEM: Transform earnings and wealth into $thousands, cap earnings at 200K and wealth at 2 million
	foreach var in iearn fiearn liearn {
		replace `var' = `var'/1000
		gen `var'x = min(`var',200)
	}
	
	foreach var in hatota fhatota lhatota {
		replace `var' = `var'/1000
		gen `var'x = min(`var',2000)
	}
		
	foreach i in hatota hatotax iearn iearnx {
		egen flog`i' = h(f`i')
		replace flog`i' = flog`i'/100
		egen llog`i' = h(l`i')
		replace llog`i' = llog`i'/100
	}
	
	* Generate "nonzero" variables 
	gen wlth_nonzero = hatota != 0 if hatota < .
	gen fwlth_nonzero = fhatota != 0 if fhatota < .
	gen lwlth_nonzero = lhatota != 0 if lhatota < .
	*/
	
	
	* Using uncapped earnings
gen iearn_ft = iearn if workcat == 4
gen iearn_pt = iearn if workcat == 3
gen iearn_ue = iearn if workcat == 2
gen iearn_nl = iearn if workcat == 1

label var iearn_ft "Earnings if working full-time"
label var iearn_pt "Earnings if working part-time"
label var iearn_ue "Earnings if unemployed"
label var iearn_nl "Earnings if out of labor force"

gen lniearn_ft = log(iearn_ft) if iearn_ft > 0 & iearn_ft < .
gen lniearn_pt = log(iearn_pt) if iearn_pt > 0 & iearn_pt < .
gen lniearn_ue = log(iearn_ue) if iearn_ue > 0 & iearn_ue < .
gen lniearn_nl = log(iearn_nl) if iearn_nl > 0 & iearn_nl < .

label var lniearn_ft "Log(earnings) if working full-time"
label var lniearn_pt "Log(earnings) if working part-time"
label var lniearn_ue "Log(earnings) if unemployed"
label var lniearn_nl "Log(earnings) if out of labor force"

gen any_iearn_ft = (iearn_ft > 0) if !missing(iearn_ft)
gen any_iearn_pt = (iearn_pt > 0) if !missing(iearn_pt)
gen any_iearn_ue = (iearn_ue > 0) if !missing(iearn_ue)
gen any_iearn_nl = (iearn_nl > 0) if !missing(iearn_nl)

label var any_iearn_ft "Any earnings if full-time"
label var any_iearn_pt "Any earnings if part-time"
label var any_iearn_ue "Any earnings if unemployed"
label var any_iearn_nl "Any earnings if out of labor force"

* Need IHS earnings for lags (like a log, but handles zeroes)
gen l2ihsiearn = log(l2iearn+sqrt(1+l2iearn^2))

label var l2ihsiearn "Lag of IHS(earnings)"

foreach var in l2workcat1 l2workcat2 l2workcat3 l2workcat4 {
	gen l2ihsiearn_`var' = l2ihsiearn * `var'
}

label var l2ihsiearn_l2workcat1	"Lag of IHS(earnings), lag of out of labor force"
label var l2ihsiearn_l2workcat2 "Lag of IHS(earnings), lag of unemployed"
label var l2ihsiearn_l2workcat3 "Lag of IHS(earnings), lag of part-time"
label var l2ihsiearn_l2workcat4 "Lag of IHS(earnings), lag of full-time"
	

* Marriage additional vars
gen more1mb = (l2nummar>1) if l2nummar !=. 
label var more1mb "More than one marriage before" /* Includes current marriage if married in previous period */

* for transitions, married and cohab are determined by mstat. drop previous versions.
drop l2cohab l2married
gen l2cohab = (l2mstat_new ==2)
gen l2married = (l2mstat_new ==3)
label var l2cohab "Lag of cohab"
label var l2married "Lag of married from marriage history"

gen male_l2cohab = male*l2cohab
gen male_l2married = male*l2married

label var male_l2cohab "Male, previously cohabitating"
label var male_l2married "Male, previously married"

gen male_cohab = male*cohab
gen male_married = male*married

label var male_cohab "Male, cohabitating"
label var male_married "Male, married"

/******* variables for 2-stage marriage transition model *******/
gen exitsingle = mstat_new!=1 if l2mstat_new==1
label var exitsingle "lag single, now not single"
gen single2married = mstat_new==3 if exitsingle==1
label var single2married "lag single, now married"

gen exitcohab = mstat_new!=2 if l2mstat_new==2
label var exitcohab "lag cohab, now not cohab"
gen cohab2married = mstat_new==3 if exitcohab==1
label var cohab2married "lag cohab, now married"

gen exitmarried = mstat_new!=3 if l2mstat_new==3
label var exitmarried "lag married, now not married"
gen married2cohab = mstat_new==2 if exitmarried==1
label var married2cohab "lag married, now cohab"

foreach v in exitsingle single2married exitcohab cohab2married exitmarried married2cohab {
	gen `v'_m = `v' if male==1
	gen `v'_f = `v' if male==0
}
/***************************************************************/

* Age spline interactions
foreach var in black hispan l2iearnx l2hatotax educ1 educ2 educ3 educ4 l2married l2cohab male {
	gen l2age35l_`var' = l2age35l*`var'
	gen l2age3544_`var' = l2age3544*`var' 
	gen l2age4554_`var' = l2age4554*`var' 
	gen l2age5564_`var' = l2age5564*`var'
	gen l2age65l_`var' = l2age65l*`var'
	gen l2age6574_`var' = l2age6574*`var' 
	gen l2age75p_`var'  = l2age75p*`var' 
}

gen l2age55p_male = l2age55p*male

label var l2age35l_black "Black, age spline less than 35"
label var l2age3544_black "Black, age spline 35 to 44"
label var l2age4554_black "Black, age spline 45 to 54"
label var l2age5564_black "Black, age spline 55 to 64"
label var l2age65l_black "Black, age spline less than 65"
label var l2age6574_black "Black, age spline 65 to 74"
label var l2age75p_black "Black, age spline over 75"

label var l2age35l_hispan "Hispanic, age spline less than 35"
label var l2age3544_hispan "Hispanic, age spline 35 to 44"
label var l2age4554_hispan "Hispanic, age spline 45 to 54"
label var l2age5564_hispan "Hispanic, age spline 55 to 64"
label var l2age65l_hispan "Hispanic, age spline less than 65"
label var l2age6574_hispan "Hispanic, age spline 65 to 74"
label var l2age75p_hispan "Hispanic, age spline over 75"

label var l2age35l_educ1 "Less than HS, age spline less than 35"
label var l2age3544_educ1 "Less than HS, age spline 35 to 44"
label var l2age4554_educ1 "Less than HS, age spline 45 to 54"
label var l2age5564_educ1 "Less than HS, age spline 55 to 64"
label var l2age65l_educ1 "Less than HS, age spline less than 65"
label var l2age6574_educ1 "Less than HS, age spline 65 to 74"
label var l2age75p_educ1 "Less than HS, age spline over 75"

label var l2age35l_educ2 "High School, age spline less than 35"
label var l2age3544_educ2 "High School, age spline 35 to 44"
label var l2age4554_educ2 "High School, age spline 45 to 54"
label var l2age5564_educ2 "High School, age spline 55 to 64"
label var l2age65l_educ2 "High School, age spline less than 65"
label var l2age6574_educ2 "High School, age spline 65 to 74"
label var l2age75p_educ2 "High School, age spline over 75"

label var l2age35l_educ3 "College, age spline less than 35"
label var l2age3544_educ3 "College, age spline 35 to 44"
label var l2age4554_educ3 "College, age spline 45 to 54"
label var l2age5564_educ3 "College, age spline 55 to 64"
label var l2age65l_educ3 "College, age spline less than 65"
label var l2age6574_educ3 "College, age spline 65 to 74"
label var l2age75p_educ3 "College, age spline over 75"

label var l2age35l_educ4 "Beyond College, age spline less than 35"
label var l2age3544_educ4 "Beyond College, age spline 35 to 44"
label var l2age4554_educ4 "Beyond College, age spline 45 to 54"
label var l2age5564_educ4 "Beyond College, age spline 55 to 64"
label var l2age65l_educ4 "Beyond College, age spline less than 65"
label var l2age6574_educ4 "Beyond College, age spline 65 to 74"
label var l2age75p_educ4 "Beyond College, age spline over 75"

label var l2age35l_male "Male, age spline less than 35"
label var l2age3544_male "Male, age spline 35 to 44"
label var l2age4554_male "Male, age spline 45 to 54"
label var l2age5564_male "Male, age spline 55 to 64"
label var l2age55p_male "Male, age spline over 55"
label var l2age65l_male "Male, age spline less than 65"
label var l2age6574_male "Male, age spline 65 to 74"
label var l2age75p_male "Male, age spline over 75"

label var l2age35l_l2married "Lag of Married, age spline less than 35"
label var l2age3544_l2married "Lag of Married, age spline 35 to 44"
label var l2age4554_l2married "Lag of Married, age spline 45 to 54"
label var l2age5564_l2married "Lag of Married, age spline 55 to 64"
label var l2age65l_l2married "Lag of Married, age spline less than 65"
label var l2age6574_l2married "Lag of Married, age spline 65 to 74"
label var l2age75p_l2married "Lag of Married, age spline over 75"

label var l2age35l_l2cohab "Lag of Cohabitating, age spline less than 35"
label var l2age3544_l2cohab "Lag of Cohabitating, age spline 35 to 44"
label var l2age4554_l2cohab "Lag of Cohabitating, age spline 45 to 54"
label var l2age5564_l2cohab "Lag of Cohabitating, age spline 55 to 64"
label var l2age65l_l2cohab "Lag of Cohabitating, age spline less than 65"
label var l2age6574_l2cohab "Lag of Cohabitating, age spline 65 to 74"
label var l2age75p_l2cohab "Lag of Cohabitating, age spline over 75"

* Education-earnings interactions
foreach var in educ1 educ2 educ3 educ4 {
	gen l2logiearnx_`var' = l2logiearnx*`var'
}

* Earnings-work interactions
foreach var in l2workcat1 l2workcat2 l2workcat3 l2workcat4 {
	gen l2logiearnx_`var' = l2logiearnx*`var'
}

/*
gen male_l2age35l = male*l2age35l
gen male_l2age3544 = male*l2age3544
gen male_l2age4554 = male*l2age4554
gen male_l2age5564 = male*l2age5564
*/

* interact age splines with race and gender
gen male_l2age65l_black = male*l2age65l*black
gen male_l2age6574_black = male*l2age6574*black 
gen male_l2age75p_black  = male*l2age75p*black 
gen male_l2age65l_hispan = male*l2age65l*hispan
gen male_l2age6574_hispan = male*l2age6574*hispan 
gen male_l2age75p_hispan  = male*l2age75p*hispan  

label var male_l2age65l_black  "Black male, less than 65"
label var male_l2age6574_black "Black male, 65 to 74"
label var male_l2age75p_black  "Black male, over 75"
label var male_l2age65l_hispan "Hispanic male, less than 65"
label var male_l2age6574_hispan "Hispanic male, 65 to 74"
label var male_l2age75p_hispan  "Hispanic male, over 75"


* Sex - education interactions
forvalues x = 1/4 {
	gen male_educ`x' = male * educ`x'
	label var male_educ`x' "Male * educ`x'"
}

label var male_educ1 "Male, Less than HS"
label var male_educ2 "Male, High school/GED/some college/AA"
label var male_educ3 "Male, College"
label var male_educ4 "Male, Beyond College"

* Race - education interactions
forvalues x = 1/4 {
	gen black_educ`x' = black * educ`x'
	gen hispan_educ`x' = hispan * educ`x'
}

label var black_educ1 "Black, Less than HS"
label var black_educ2 "Black, High school/GED/some college/AA"
label var black_educ3 "Black, College"
label var black_educ4 "Black, Beyond College"

label var hispan_educ1 "Hispanic, Less than HS"
label var hispan_educ2 "Hispanic, High school/GED/some college/AA"
label var hispan_educ3 "Hispanic, College"
label var hispan_educ4 "Hispanic, Beyond College"



foreach var of varlist cancre diabe hearte hibpe lunge stroke smoken smokev {
	gen over65_l2`var' = over65 * l2`var'
}

* Incident Disease
foreach var of varlist cancre diabe hearte hibpe lunge stroke {
	gen i`var' = (`var' == 1 & l2`var' == 0) if !missing(`var') & !missing(l2`var')
}

label var icancre "Incident cancer"
label var idiabe "Incident diabetes"
label var ihearte "Incident heart disease"
label var ihibpe "Incident hypertension"
label var ilunge "Incident lung disease"
label var istroke "Incident stroke"

** GENERATE VARIABLES FOR ECON MODELS
*** generate age splines
gen l2age5561 = min(max(0,l2`age_var'-53),60-53) if l2`age_var' < .
gen l2age6264 = min(max(0,l2`age_var'-60),63-60) if l2`age_var' < .

label var l2age5561 "Age spline, 55 to 61"
label var l2age6264 "Age spline, 62 to 64"


*** GENERATE WAVE DUMMIES
	gen w99 = year == 1999
	gen w01 = year == 2001
	gen w03 = year == 2003
	gen w05 = year == 2005
	gen w07 = year == 2007
	gen w09 = year == 2009
	gen w11 = year == 2011
	
	gen male_hsless = male*hsless
	gen male_black = male*black
	gen male_hispan = male*hispan
	
	label var male_hsless "Male with less than HS education"
	label var male_black "Black male"
	label var male_hispan "Hispanic male"
	
*** generate normal retirement age dummies (HRS transition select)
	gen ss_nra = .
	replace ss_nra = 65 if rbyr <= 1937
	replace ss_nra = 65 + 2/12 if rbyr == 1938
	replace ss_nra = 65 + 4/12 if rbyr == 1939
	replace ss_nra = 65 + 6/12 if rbyr == 1940
	replace ss_nra = 65 + 8/12 if rbyr == 1941
	replace ss_nra = 65 + 10/12 if rbyr == 1942
	replace ss_nra = 66 if rbyr >= 1943 & rbyr < 1955
	replace ss_nra = 66 + 2/12 if rbyr == 1955
	replace ss_nra = 66 + 4/12 if rbyr == 1956
	replace ss_nra = 66 + 6/12 if rbyr == 1957
	replace ss_nra = 66 + 8/12 if rbyr == 1958
	replace ss_nra = 66 + 10/12 if rbyr == 1959
	replace ss_nra = 67 if rbyr >= 1960	
	
	gen yrs_to_nra = ss_nra - age
	gen nra_elig = (age - ss_nra >= 0)
	
*** Years to NRA dummy variables (10+ years to NRA is reference group)
*	gen nraplus10 	= (yrs_to_nra >= 10 )
	gen nraplus9 		= (yrs_to_nra >= 9 & yrs_to_nra < 10)
	gen nraplus8 		= (yrs_to_nra >= 8 & yrs_to_nra < 9)
	gen nraplus7 		= (yrs_to_nra >= 7 & yrs_to_nra < 8)
	gen nraplus6 		= (yrs_to_nra >= 6 & yrs_to_nra < 7)
	gen nraplus5 		= (yrs_to_nra >= 5 & yrs_to_nra < 6)
	gen nraplus4 		= (yrs_to_nra >= 4 & yrs_to_nra < 5)
	gen nraplus3 		= (yrs_to_nra >= 3 & yrs_to_nra < 4)
	gen nraplus2 		= (yrs_to_nra >= 2 & yrs_to_nra < 3)
	gen nraplus1 		= (yrs_to_nra >= 1 & yrs_to_nra < 2)
	gen nraplus0		=	(yrs_to_nra >= 0 & yrs_to_nra < 1)
	gen nramin0 		= (yrs_to_nra >= -1 & yrs_to_nra < 0)
	gen nramin1 		= (yrs_to_nra >= -2 & yrs_to_nra < -1)
	gen nramin2 		= (yrs_to_nra >= -3 & yrs_to_nra < -2)
	gen nramin3 		= (yrs_to_nra >= -4 & yrs_to_nra < -3)
	gen nramin4 		= (yrs_to_nra >= -5 & yrs_to_nra < -4)
	gen nramin5 		= (yrs_to_nra >= -6 & yrs_to_nra < -5)
	gen nramin6 		= (yrs_to_nra >= -7 & yrs_to_nra < -6)
	gen nramin7 		= (yrs_to_nra >= -8 & yrs_to_nra < -7)
	gen nramin8 		= (yrs_to_nra >= -9 & yrs_to_nra < -8)
	gen nramin9 	 	= (yrs_to_nra >= -10 & yrs_to_nra < -9)
	gen nramin10 		= (yrs_to_nra < -10)	
	
	* Race group categorical variable
gen racegroup = .
replace racegroup = 1 if black == 0 & hispan == 0
replace racegroup = 2 if black == 1
replace racegroup = 3 if hispan == 1

label var racegroup "Categorical race"
label define racegroup 1 "Non-His White" 2 "Non-His Black" 3 "Hispanic"
label values racegroup racegroup	

* Health insurance dummies
forvalues x = 1/3 {
	gen inscat`x' = (inscat ==`x') if !missing(inscat)
	gen l2inscat`x' = (l2inscat ==`x') if !missing(l2inscat)
}

label var inscat1 "Uninsured"
label var inscat2 "Public Insurance Only"
label var inscat3 "Any Private Insurance"

label var l2inscat1 "Lag of Uninsured"
label var l2inscat2 "Lag of Public Insurance Only"
label var l2inscat3 "Lag of Any Private Insurance"


* Smoking status interaction
gen l2smokev_l2smoken = l2smokev * l2smoken

gen l2age_l2smokev = l2age*l2smokev
gen l2age_l2smoken = l2age*l2smoken

foreach var in l2age35l l2age3544 l2age4554 l2age5564 l2age6574 l2age75p {
	gen `var'_l2smoken = `var' * l2smoken
} 
		
gen smoke_start = (smoken == 1 & l2smoken == 0)
gen smoke_stop = (smoken == 0 & l2smoken	== 1)	

label var smoke_start "Started smoking"
label var smoke_stop "Stopped smoking"

*** K6 vars (including interactions); 
label var k6score "K6 score"
label var l2k6score "Lagged K6 score"

mkspline l2k6lt9 9 l2k6913 13 l2k613p = l2k6score
label var l2k6lt9 "Lagged K6 lt 9 spline"
label var l2k6913 "Lagged K6 9-13 spline"
label var l2k613p "Lagged K6 gt 13 spline"

gen male_l2k6 = male*l2k6score
gen hisp_l2k6 = hispan*l2k6score
gen black_l2k6 = black*l2k6score 


* Standardize measure
gen bingeannual = alcbinge
gen l2bingeannual = l2alcbinge 

* Roughly weekly binge (3+ times per month) that is consistent with ABC data
gen binge_3permo = (bingeannual >= 36) if !missing(bingeannual)
gen l2binge_3permo = (l2bingeannual >= 36) if !missing(l2bingeannual)

gen y1999 = year == 1999
gen y2001 = year == 2001
gen y2003 = year == 2003
gen y2005 = year == 2005
gen y2007 = year == 2007
gen y2009 = year == 2009
gen y2011 = year == 2011
gen y2013 = year == 2013
gen y2015 = year >= 2015


		
save "$outdata/psid_transition.dta", replace

* Save the 51+ file for comparison to HRS
keep if age >= 51
save "$outdata/psid_transition_51plus.dta", replace



*** Need to prep PSID-HRS file for use in mortality estimation ***
use "$outdata/psid_transition.dta", clear

gen source = "psid"

append using $outdata/hrs112_transition.dta

drop if wave < 5 & source != "psid"
replace aged = age_iwe if source != "psid"
replace l2aged = l2age_iwe if source != "psid"
tab source, m

* Generate age dummy variables
local age_var aged

replace hsless = educ_fam == 1 if source != "psid"
replace college = educ_fam == 3 if source != "psid"


	replace l2age35l = min(33,l2`age_var') if l2`age_var' < .
	replace l2age3544 = min(max(0,l2`age_var'-33),43-33) if l2`age_var' < .
	replace l2age4554 = min(max(0,l2`age_var'-43),53-43) if l2`age_var' < .
	replace l2age5564 = min(max(0,l2`age_var'-53),63-53) if l2`age_var' < .	
*	replace l2age65l  = min(63,l2`age_var') if l2`age_var' < .
	replace l2age6574 = min(max(0,l2`age_var'-63),73-63) if l2`age_var' < .
	replace l2age75p = max(0, l2`age_var'-73) if l2`age_var' < . 
	
	* Interact age splines with race
foreach var in black hispan male {
	replace l2age35l_`var' = l2age35l*`var' if l2age35l_`var' == .
	replace l2age3544_`var' = l2age3544*`var' if l2age3544_`var' == .
	replace l2age4554_`var' = l2age4554*`var' if l2age4554_`var' == .
	replace l2age5564_`var' = l2age5564*`var' if l2age5564_`var' == .
	replace l2age65l_`var' = l2age65l*`var'  if  l2age65l_`var' == . 
	replace l2age6574_`var' = l2age6574*`var' if l2age6574_`var' == .
	replace l2age75p_`var'  = l2age75p*`var' if  l2age75p_`var' == .
}


replace over65 = (l2`age_var' >= 63) if l2`age_var' < .

foreach var of varlist cancre diabe hearte hibpe lunge stroke smoken smokev {
	replace over65_l2`var' = over65 * l2`var'
}

drop male_hsless
gen male_hsless = male*hsless
label var male_hsless "Male, less than high school"

gen male_college = male*college
label var male_college "Male, college or more"

drop if l2age == 999

* Standardize measure
* annualize HRS measure
replace l2bingeannual = 4*l2binge if missing(source)

* Weekly binge
drop l2binge_3permo
gen l2binge_3permo = (l2bingeannual >= 36) if !missing(l2bingeannual)

save $outdata/psid_hrs_transition.dta, replace







capture log close
