*==========================================================================*
*	Cross validation of RandHRS and FEM results 1998 to 2008
*	
*	Barbara Blaylock
*	12/21/2012
*==========================================================================*

/*********************************************************************/
*	SEP UP DIRECTORIES AND VARIABLES
/*********************************************************************/


* Load environment variables from the root FEM directory, three levels up
* these define important paths, specific to the user
clear all
include "../../../../../fem_env.do"

local output "$routput_dir/vCrossvalidation"

local iter 10
local minwave 4
local maxwave 9

#delimit ; 

	local binvar "adl1 adl2 adl3p anyhi black cancre dbclaim diabe diclaim died  
	hearte hibpe hicap_nonzero hispan iadl1 iadl2p lunge male nhmliv smoken smokev   
	ssiclaim stroke wlth_nonzero work";
	local contvar "age bmi hicap hatotax iearnx";
	local yearvar "1998 2000 2002 2004 2006 2008";
	local varlist "fem_mean fem_n fem_sd hrs_mean hrs_n hrs_sd p_value"; 

#delimit cr

set more off

/*********************************************************************/
* RANDHRS DATA COMPARISON
/*********************************************************************/

forval wave = `minwave'/`maxwave' {

use $rand_hrs, clear

* create variables for summary (alphabetical order)

* DEMOGRAPHIC VARIABLES
**VAR: hispan 
	gen hispan = rahispan
	label var hispan "Hispanic"
**VAR: black
  gen black = 0*raracem
  replace black = 1 if raracem == 2 & hispan == 0
  label var black "Non-hispanic black"
**VAR: hsless
*  gen hsless = 0*raeduc
*  replace hsless = 1 if raeduc == 1
*  label var hsless "Less than high school"
**VAR: college
*  gen college = 0*raeduc
*  replace  college = 1 if raeduc == 4 | raeduc == 5
*  label var college "Some college and above"
**VAR: male
  gen male = 0*ragender
  replace male = 1 if ragender == 1
  label var male "Male"

* BINARY VARIABLES
**VAR: ADL (based on code from recode.do and transition_select.do) //
	recode r`wave'adla (0=1) (1=2) (2=3) (nonmissing=4) (missing=.), gen(adlstat)
	gen adl1 = adlstat==2 if !missing(adlstat)
	gen adl2 = adlstat==3 if !missing(adlstat)
	gen adl3p = adlstat==4 if !missing(adlstat)
	label var adl1 "One ADL limitation"
	label var adl2 "Two ADL limitations"
	label var adl3p "Three or more ADL limitations"
**VAR: ANYHI (based on code from recode.do) //
	gen anyhi = 0
	foreach v in r`wave'higov r`wave'covr r`wave'covs r`wave'hiothp {
		replace anyhi = 1 if inlist(`v',1,.e,.c,.t)
	}
	foreach v in r`wave'higov r`wave'covr r`wave'covs r`wave'hiothp {
		replace anyhi = . if !inlist(`v',0,1,.e,.c,.t) & anyhi == 0
	}
	label var anyhi "Any health insurance coverage (gov/emp/other)"
**VAR: CANCRE //
	gen cancre = r`wave'cancre
	label var cancre "R ever had cancer"
**VAR: DBCLAIM (based on code from gen_analytic_file.do and recode.do) ??
	merge hhidpn using $hrs_sensitive/dbpen_hrs.dta, sort 
	drop dbclaim*
	gen dbclaim = .
	if `wave'<=7 {
		replace dbclaim = dbentitle_c`wave'==2 if _merge==3 & !missing(dbentitle_c`wave') & r`wave'iwstat==1	
		replace dbclaim = 0 if inlist(hacohort,0,1,2) & r`wave'iwstat == 1
	}
	else replace dbclaim=0 
	drop dbentitle*
	drop _merge
*	gen age_iwe = r`wave'agem_e / 12
*	label var age_iwe "exact age at the end of interview"
*	gen anydb = . 
*	label var anydb "Any DB entitlement from current job"
*	replace anydb = dbentitle_c1   == 1 if _merge == 3& !missing(dbentitle_c1) & r1iwstat == 1
*	replace anydb = 0 if inlist(hacohort, 0,1,2)
*	cap replace anydb = 0 if (r1work!= 1 | r1iearn == 0) & r1iwstat == 1 & inlist(hacohort,3)
*	cap replace anydb = 0 if (r4work!= 1 | r4iearn == 0) & r4iwstat == 1 & inlist(hacohort,4)
*	cap replace anydb = 0 if (r7work!= 1 | r7iearn == 0) & r7iwstat == 1 & inlist(hacohort,5)
*	replace dbclaim = 0 if (age_iwe < 53 & rdb_ea_c == 2) | (age_iwe < 58 & rdb_ea_c == 3) | anydb == 0
	label var dbclaim	"Claiming DB waves 4-7"
**VAR: DIABE //
	gen diabe = r`wave'diabe
	label var diabe	"R ever had diabetes"
**VAR: DICLAIM (based on code from gen_analytic_file.do, transition_select.do, and recode.do) //
	gen diclaim	= inlist(r`wave'dstat,20,21,22,200) if r`wave'dstat <=200 & r`wave'iwstat == 1
	replace diclaim = 0 if inlist(hacohort,0,1,2) & r`wave'iwstat == 1 | r`wave'agey_e > 66
	replace diclaim = 0 if r`wave'agey_e >= 65 & r`wave'iwstat == 1
*	replace diclaim = 0 if age_iwe >=65 & wave == firstwave
	label var diclaim "Claiming SSDI"
**VAR: DIED //
	gen died = r`wave'iwstat
	recode died (0 6 9 = .) (1 4 = 0) (2 3 5 = 1) 
	label var died "whether died or not in this wave"
**VAR: HEARTE //
	gen hearte = r`wave'hearte
	label var hearte "R ever had heart disease"
**VAR: HIBPE //
	gen hibpe = r`wave'hibpe
	label var hibpe "R ever had hypertension"
**VAR: HICAP_NONZERO (based on code from hrs_select.do) // 
	gen hicap_nonzero = h`wave'icap != 0 if h`wave'icap < .
	label variable hicap_nonzero "Household Capital Income is not zero"  
**VAR: IADL (based on code from recode.do and transition_select.do) //
	recode r`wave'iadla (0=1) (1=2) (nonmissing=3) (missing=.), gen(iadlstat)
	gen iadl1 = iadlstat==2 if !missing(iadlstat)
	gen iadl2p = iadlstat==3 if !missing(iadlstat)
	label var iadl1 "One IADL limitation"
	label var iadl2p "Two or more IADL limitations"
**VAR: LUNGE //
	gen lunge = r`wave'lunge
	label var lunge	"R ever had lung disease"
**VAR: NHMLIV //
	gen nhmliv = r`wave'nhmliv
	label var nhmliv "R live in nursing home at interview"
**VAR: SMOKING STATUS //
	gen smoken = r`wave'smoken
	gen smokev = r`wave'smokev
	label var smoken "R smokes now"
	label var smokev "R smoke ever"
**VAR: SSCLAIM (based on code from gen_analytic_file.do)
*** SS claiming
*	merge hhidpn using "$indata/ssretclaim.dta", sort
*	tab _merge
*	drop if _merge == 2
*	drop _merge
*	gen clmwv = .
*	forval j = 1/`maxwave' {
*		gen iwyear`j' = year(r`j'iwbeg)
*		gen ssclaim`j' = iwyear`j' >= ssretbegyear if iwyear`j' < . & inlist(finalflag, .v)
*		replace ssclaim`j' = 0 if inlist(finalflag, .n) & r`j'iwstat == 1
*		replace ssclaim`j' = r`j'agey_e >= 65 if inlist(finalflag,.d) & r`j'iwstat == 1
*		replace ssclaim`j' = r`j'agey_e >= 62 if inlist(finalflag,.e)& r`j'iwstat == 1
*		replace ssclaim`j' = r`j'isret > 0 & r`j'agey_e >= 62 if inlist(finalflag,.m) & r`j'iwstat == 1	
*		replace ssclaim`j' = r`j'isret > 0 & r`j'agey_e >= 50 if inlist(finalflag,.w) & r`j'mstat != 1 & r`j'iwstat == 1
*		replace clmwv = `j' if ssclaim`j' == 1 & clmwv == .
		*** Make sure ssclaim is absorbing
*		replace ssclaim`j' = 1 if `j' >= clmwv & r`j'iwstat == 1
*	}
*	gen ssclaim = 1 if clmwv <= `wave'
*	replace ssclaim = 0 if clmwv > `wave'
*	label var ssclaim "Claiming OASI"
**VAR: SSICLAIM (based on code from gen_analytic_file.do) //
	gen ssiclaim = inlist(r`wave'dstat,2,12,22,200) if r`wave'dstat <= 200 & r`wave'iwstat == 1
	replace ssiclaim = 0 if inlist(hacohort,0,1) & inlist(`wave',2,3) & r`wave'iwstat == 1 
	label var ssiclaim "Claiming SSI"
**VAR: STROKE //
	gen stroke = r`wave'stroke
	label var stroke "R ever had stroke"
**VAR: WLTH_NONZERO (based on code from hrs_select.do) // 
	gen wlth_nonzero = h`wave'atota != 0 if h`wave'atota < . 
	label var wlth_nonzero "Non-pension wlth(hatota) not zero"  
**VAR: WORK (based on code from recode.do) //
	gen work = r`wave'work
	replace work = 0 if !inlist(r`wave'work,0,1) & inlist(r`wave'lbrf,5,6,7)
	label var work "R working for pay"

* CONTINUOUS VARIALBES
**VAR: AGE //
*	gen age = r`wave'agey_e
*	label var age "R age in integral years at interview end date"	
**VAR: AGE (based on code from recode.do) //
	gen age = (`wave'-1)*2 + 1992 - rabyear + (7-rabmonth)/12	
	label var age "Exact Age at July 1st"
**VAR: BMI //
	gen bmi = r`wave'bmi
	label var bmi "R Body mass index"
**VAR: HATOTAX (based on code from hrs_select.do) ??
	gen hatotax = h`wave'atota/1000 
	replace hatotax = min(hatotax, 2000) if !missing(h`wave'atota)
	label var hatotax "HH wlth in 1000s if positive-max 2000 zero otherwise"
**VAR: HICAP ??
	gen hicap = h`wave'icap
	label var hicap	"HH capital income"
**VAR: IEARNX (based on code from gen_analytic_file.do, recode.do and hrs_select.do) //
	gen iearn = r`wave'iearn
	* No earnings if not working
	replace iearn = 0 if work == 0
		/* Merge in self-employment income from income files */
		local wave3inc r3osemp ir3semp
		merge hhidpn using "$hrsfat/income95.dta", keep(`wave3inc') sort unique
		drop if _merge == 2
		drop _merge
		* Uses same variable names as income95.dta
		merge hhidpn using "$hrsfat/income96.dta", keep(`wave3inc') sort unique
		drop if _merge == 2
		drop _merge
		local wave4inc "r4osemp ir4semp"
		merge hhidpn using "$hrsfat/income98.dta", keep(`wave4inc') sort unique
		drop if _merge == 2
		drop _merge
		local wave5inc r5osemp ir5semp
		merge hhidpn using "$hrsfat/income00.dta", keep(`wave5inc') sort unique
		drop if _merge == 2
		drop _merge
		local wave6inc r6osemp ir6semp
		merge hhidpn using "$hrsfat/income02.dta", keep(`wave6inc') sort unique
		drop if _merge == 2
		drop _merge
		local wave7inc r7osemp ir7semp
		merge hhidpn using "$hrsfat/income04.dta", keep(`wave7inc') sort unique
		drop if _merge == 2
		drop _merge
		local wave8inc r8osemp ir8semp
		merge hhidpn using "$hrsfat/income06.dta", keep(`wave8inc') sort unique
		drop if _merge == 2
		drop _merge
		local wave9inc r9osemp ir9semp
		merge hhidpn using "$hrsfat/income08.dta", keep(`wave9inc') sort unique
		drop if _merge == 2
		drop _merge
		forval x = 3/`maxwave' {
			ren ir`x'semp r`x'semp
		}
	replace iearn = r`wave'semp if work == 1 & iearn == 0 & r`wave'semp > 0 & r`wave'semp < .
	gen iearnx = iearn/1000
	replace iearnx = min(iearnx,200) if !missing(iearn)
	label var iearnx "Individual earnings in 1000s-max 200"

* get variable labels for later merging
preserve
tempfile varlabs
descsave, list(name varlab) saving(`varlabs', replace)
use `varlabs', clear
rename name variable
* escape out underscore and create math environment for latex compatibility
replace varlab = regexr(varlab,"_","\_")
replace varlab = regexr(varlab,"<=","$<=$")
replace varlab = regexr(varlab," > "," $>$ ")
save `varlabs', replace
restore


* ANALYTIC WEIGHT //
**VAR: WEIGHT
	gen weight = r`wave'wtresp
	label var weight "R person level weight"

drop if age < 51 + ((`wave'-4)*2)


* Compare combined FEM results to HRS population (ttest)
keep hhidpn weight `binvar' `contvar'
local yr = 1998 + ((`wave'-4)*2)
gen rep = .
gen FEM = 0
forval i = 1/`iter' {
append using "`output'/detailed_output/y`yr'_rep`i'.dta", keep(hhidpn weight `binvar' `contvar')
		replace rep = `i' if missing(rep) & FEM!=0
		replace FEM = 1 if missing(FEM)
}
gen reweight = weight/`iter' if FEM==1

file open myfile using "`output'/fem_hrs_ttest_`wave'.txt", write replace
file write myfile "variable" _tab "fem_mean" _tab "fem_n" _tab "fem_sd" _tab "hrs_mean" _tab "hrs_n" _tab "hrs_sd" _tab "p_value" _n

foreach var in `binvar' `contvar' {
	sum `var' if FEM==1 & died == 0 & nhmliv == 0 [aw=reweight] 
	local N1 = r(N)
	local av1 = r(mean)
	local sd1 = r(sd)
	sum `var' if FEM==0 & died == 0 & nhmliv == 0 [aw=weight] 
	local N2 = r(N)
	local av2 = r(mean)
	local sd2 = r(sd)
	ttesti `N1' `av1' `sd1' `N2' `av2' `sd2', unequal
	
 	file write myfile %15s "`var'" _tab %15.5f (`av1') _tab %15f (`N1') _tab %15.5f (`sd1') _tab %15.5f (`av2') _tab %15f (`N2')	_tab %15.5f (`sd2') _tab %15.5f (r(p)) _n
}
file close myfile

}

tempfile wave4

insheet using `output'/fem_hrs_ttest_4.txt, clear

	foreach var in `varlist' {
  	ren `var' `var'_wave4
  	}

save "`wave4'"

tempfile wave7

insheet using `output'/fem_hrs_ttest_7.txt, clear

	foreach var in `varlist' {
  	ren `var' `var'_wave7
  	}

save "`wave7'"

tempfile wave9

insheet using `output'/fem_hrs_ttest_9.txt, clear

	foreach var in `varlist' {
  	ren `var' `var'_wave9
  	}

save "`wave9'"

use "`wave4'", replace
merge 1:1 variable using "`wave7'", nogenerate
merge 1:1 variable using "`wave9'", nogenerate
keep variable fem_mean* hrs_mean* p_value*

* drop outcomes that have no weight
drop if variable == "died" | variable == "nhmliv"

merge 1:1 variable using `varlabs'
drop if _merge==2
drop _merge
replace variable = varlab if varlab != ""
keep variable fem_mean* hrs_mean* p_value*

outsheet using validation_wave_4_7_9.csv, comma replace
*export excel using techappendix.xls, sheetreplace sheet("Table 15") firstrow(varlabels)
clear
insheet using validation_wave_4_7_9.csv, comma

format fem_mean* hrs_mean* p_value* %12.3f

#d ;
listtex using validation_waves_4_7_9.tex, replace rstyle(tabular) 
head(
"\begin{tabular}{|p{1.2in}|*{3}{r}|*{3}{r}|*{3}{r}|}"
" \multicolumn{1}{c}{} & \multicolumn{3}{c}{1998} & \multicolumn{3}{c}{2004} & \multicolumn{3}{c}{2008}\\"
"\hhline{~---------}"
" \multicolumn{1}{c|}{} & FEM & HRS & & FEM & HRS & & FEM & HRS & \\"
" \multicolumn{1}{l|}{Outcome} & mean & mean & \textit{p} & mean & mean & \textit{p} & mean & mean & \textit{p} \\"
"\hline"
)
foot("\hline""\end{tabular}")
;
#d cr


/*
* NOTE: this outputs an incomplete table -- when the output is included in other
* latex code, you will need to add "\end{longtable}" at the end.  This allows 
* you to add a customized caption and label for the table
#d ;
listtex using validation_waves_4_7_9.tex, replace rstyle(tabular) 
head(
"\begin{longtable}{|p{1.2in}|*{3}{r}|*{3}{r}|*{3}{r}|}"
" \multicolumn{1}{c}{} & \multicolumn{3}{c}{1998} & \multicolumn{3}{c}{2004} & \multicolumn{3}{c}{2008}\\"
"\hhline{~---------}"
" \multicolumn{1}{c|}{} & FEM & HRS & & FEM & HRS & & FEM & HRS & \\"
" \multicolumn{1}{l|}{Outcome} & mean & mean & \textit{p} & mean & mean & \textit{p} & mean & mean & \textit{p} \\"
"\hline"
"\endfirsthead"
"\multicolumn{10}{c}{(continued from previous page)}\endhead"
"\multicolumn{10}{c}{(continued on next page)}\endfoot"
"\endlastfoot"
)
;
#d cr
*/

exit, STATA clear
