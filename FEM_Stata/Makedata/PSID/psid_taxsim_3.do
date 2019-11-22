include common.do


* Enter the date:
global datestamp 102517

***********************

clear all
set more off


*RUNNING THROUGH TAXSIM

foreach X in 1999 2001 2003 2005 2007 2009 2011 {
foreach Y in head wife joint ofum simple {

use "$outdata/taxes_posttaxsim_$datestamp", clear

keep t`X'var1 t`X'var2 t`X'var3 ///
t`X'var4`Y' t`X'var5`Y' t`X'var6`Y' t`X'var7`Y' t`X'var8`Y' t`X'var9`Y' ///
t`X'var10`Y' t`X'var11`Y' t`X'var12`Y' t`X'var13`Y' t`X'var14`Y' t`X'var15`Y' ///
t`X'var16 ///
t`X'var17`Y' t`X'var18`Y' t`X'var19`Y' t`X'var20`Y' ///
t`X'var21 t`X'var22 ///

rename t`X'var1 personid
rename t`X'var2 year
rename t`X'var3 state
rename t`X'var4`Y' mstat
rename t`X'var5`Y' depx
rename t`X'var6`Y' agex
rename t`X'var7`Y' pwages
rename t`X'var8`Y' swages
rename t`X'var9`Y' dividends
rename t`X'var10`Y' otherprop
rename t`X'var11`Y' pensions
rename t`X'var12`Y' gssi
rename t`X'var13`Y' transfers
rename t`X'var14`Y' rentpaid
rename t`X'var15`Y' proptax
rename t`X'var16 otheritem
rename t`X'var17`Y' childcare
rename t`X'var18`Y' ui
rename t`X'var19`Y' depchild
rename t`X'var20`Y' mortgage
rename t`X'var21 stcg
rename t`X'var22 ltcg

save "$outdata/taxsim_`X'`Y'_$datestamp", replace

taxsim9, full replace

keep personid fiitax siitax frate srate fica v22 v23 v24 v25 v28 v38 v39 v40 // could include more TAXSIM output variables here -- see list at http://users.nber.org/~taxsim/taxsim9/

rename fiitax t`X'`Y'_fiitax
rename siitax t`X'`Y'_siitax
rename frate t`X'`Y'_frate
rename srate t`X'`Y'_srate
rename fica t`X'`Y'_fica
rename v22 t`X'`Y'_ctc
rename v23 t`X'`Y'_ctcref
rename v24 t`X'`Y'_ccc
rename v25 t`X'`Y'_eic
rename v28 t`X'`Y'_fiibc
rename v38 t`X'`Y'_sccc
rename v39 t`X'`Y'_seic
rename v40 t`X'`Y'_siicred

*Labeling individual-level variables
label var t`X'`Y'_fiitax "Federal income tax liability - ind `Y' `X'"
label var t`X'`Y'_siitax "State income tax liability - ind `Y' `X'"
label var t`X'`Y'_frate "Marginal federal tax rate - ind `Y' `X'"
label var t`X'`Y'_srate "Marginal state tax rate - ind `Y' `X'"
label var t`X'`Y'_fica "FICA payroll tax - ind `Y' `X'"
label var t`X'`Y'_ctc "Child Tax Credit - ind `Y' `X'"
label var t`X'`Y'_ctcref "Additional Child Tax Credit (refundable) - ind `Y' `X'"
label var t`X'`Y'_ccc "Child and Dependent Care Credit (federal) - ind `Y' `X'"
label var t`X'`Y'_eic "Earned Income Credit (total federal) - ind `Y' `X'"
label var t`X'`Y'_fiibc "Federal income tax before credits - ind `Y' `X'"
label var t`X'`Y'_sccc "State Child Care Credit - ind `Y' `X'"
label var t`X'`Y'_seic "State EIC - ind `Y' `X'"
label var t`X'`Y'_siicred "State total credits - ind `Y' `X'"

save "$outdata/taxsim_`X'`Y'_$datestamp", replace

merge 1:1 personid using "$outdata/taxes_posttaxsim_$datestamp"
drop _merge
save "$outdata/taxes_posttaxsim_$datestamp", replace

}
}

* ADJUSTMENTS TO TAXSIM CALCULATIONS

* Recalculating payroll tax for cases where business/farm loss results in incorrect payroll tax calculated for labor income that is *not* from unincorporated business/farm.

* Maximum earnings subject to Social Security (OASDI) tax (for tax year n-1), from http://www.ssa.gov/OACT/COLA/cbb.html
gen socsecmax1999 = 68400
gen socsecmax2001 = 76200
gen socsecmax2003 = 84900
gen socsecmax2005 = 87900
gen socsecmax2007 = 94200
gen socsecmax2009 = 102000
gen socsecmax2011 = 106800

foreach X in 1999 2001 2003 2005 2007 2009 2011 {

replace t`X'head_fica = 0.0765 * laborhd`X' if busassethd`X' <0 | farm`X' <0
replace t`X'head_fica = (0.0145 * laborhd`X') + (0.062 * socsecmax`X') if (busassethd`X' <0 | farm`X' <0) & laborhd`X' >socsecmax`X'

replace t`X'wife_fica = 0.0765 * laborwf`X' if busassetwf`X' <0
replace t`X'wife_fica = (0.0145 * laborwf`X') + (0.062 * socsecmax`X') if busassetwf`X' <0 & laborwf`X' >socsecmax`X'
}

* Recalculating payroll tax for cases where additional employer portion of self-employment tax is owed on profit from unincorporated business/farm.

foreach X in 1999 2001 2003 2005 2007 2009 2011 {

gen headselfemp`X' = buslabhd`X' + farm`X'
replace headselfemp`X' = 0 if headselfemp`X'<0
gen t`X'head_se = 0.0765 * headselfemp`X' if headselfemp`X'>0
replace t`X'head_se = (0.0145 * headselfemp`X') + (0.062 * socsecmax`X') if headselfemp`X' >socsecmax`X'

*discounting by marginal federal + state tax rate, as approximate adjustment for allowed deduction of employer portion of self-employment tax
gen t`X'head_fsrate = t`X'head_frate + t`X'head_srate if inlist(marstat`X',2,4,5)
replace t`X'head_fsrate = t`X'joint_frate + t`X'joint_srate if inlist(marstat`X',1,3)
replace t`X'head_fsrate = 0 if t`X'head_fsrate<0
replace t`X'head_fsrate = t`X'head_fsrate /100

replace t`X'head_se = t`X'head_se * (1- t`X'head_fsrate) 
replace t`X'head_se = 0 if missing(t`X'head_se)
replace t`X'head_fica = t`X'head_fica + t`X'head_se

gen wifeselfemp`X' = buslabwf`X'
replace wifeselfemp`X' = 0 if wifeselfemp`X'<0
gen t`X'wife_se = 0.0765 * wifeselfemp`X' if wifeselfemp`X'>0
replace t`X'wife_se = (0.0145 * wifeselfemp`X') + (0.062 * socsecmax`X') if wifeselfemp`X' >socsecmax`X'

gen t`X'wife_fsrate = t`X'wife_frate + t`X'wife_srate if inlist(marstat`X',2,4,5) // discounting by marginal federal + state tax rate
replace t`X'wife_fsrate = t`X'joint_frate + t`X'joint_srate if inlist(marstat`X',1,3)
replace t`X'wife_fsrate = 0 if t`X'wife_fsrate<0
replace t`X'wife_fsrate = t`X'wife_fsrate /100

replace t`X'wife_se = t`X'wife_se * (1- t`X'wife_fsrate) 
replace t`X'wife_se = 0 if missing(t`X'wife_se)
replace t`X'wife_fica = t`X'wife_fica + t`X'wife_se
}

save "$outdata/taxes_posttaxsim_$datestamp", replace

* Setting EITC to zero for ineligible immigrants.

* Coding head and wife/"wife" as eligible for EITC (i.e. not an ineligible immigrant who is undocumented or not legally allowed to work).
* 	Immigrant legal status of head and wife/"wife" collected in 1997 and 1999 only, when "immigrant refresher sample" families were added to PSID. 
*   Assuming immigrant is not eligible if legal status is missing.
* 	Note only have information about legal status of head and wife/"wife" from "immigrant refresher sample" - so all individuals not added through that sample and all ofum adults are assumed eligible for EITC.

gen c1999zheligeitc = 1
replace c1999zheligeitc = 0 if inlist(immleghd1997,2,3,5,6,7,8,11,97) | inlist(immleghd1999,2,3,5,6,7,8,11,97) // immigrants not legally allowed to work = ineligible
replace c1999zheligeitc = 0 if missing(immleghd1997) | missing(immleghd1999) // assume not eligible if legal status is missing
replace c1999zheligeitc = 1 if (ER30001 < 3000 | ER30001 > 3512) // individuals not from immigrant sample families assumed eligible

gen c1999zweligeitc = 1
replace c1999zweligeitc = 0 if inlist(immlegwf1997,2,3,5,6,7,8,11,97) | inlist(immlegwf1999,2,3,5,6,7,8,11,97) // immigrants not legally allowed to work = ineligible
replace c1999zweligeitc = 0 if missing(immlegwf1997) | missing(immlegwf1999) // assume not eligible if legal status is missing
replace c1999zweligeitc = 1 if (ER30001 < 3000 | ER30001 > 3512) // individuals not from immigrant sample families assumed eligible

*Creating variables for EITC amounts and total income taxes that ineligible immigrants would have been assigned, if eligible for the EITC.
foreach X in 1999 2001 2003 2005 2007 2009 2011 {
gen t`X'himm_eic = t`X'head_eic if c1999zheligeitc ==0
gen t`X'himm_fiitax = t`X'head_fiitax if c1999zheligeitc ==0

gen t`X'wimm_eic = t`X'wife_eic if c1999zweligeitc ==0
gen t`X'wimm_fiitax = t`X'wife_fiitax if c1999zweligeitc ==0

gen t`X'jimm_eic = t`X'joint_eic if c1999zheligeitc ==0 & c1999zweligeitc ==0
gen t`X'jimm_fiitax = t`X'joint_fiitax if c1999zheligeitc ==0 & c1999zweligeitc ==0

gen t`X'fuimm_eic = t`X'himm_eic
replace t`X'fuimm_eic = t`X'jimm_eic if inlist(marstat`X',1,3) 
replace t`X'fuimm_eic = t`X'himm_eic + t`X'wimm_eic if marstat`X'==2
replace t`X'fuimm_eic = t`X'fuimm_eic + t`X'ofum_eic if !missing(t`X'fuimm_eic) // family unit totals

gen t`X'fuimm_fiitax = t`X'himm_fiitax
replace t`X'fuimm_fiitax = t`X'jimm_fiitax if inlist(marstat`X',1,3) 
replace t`X'fuimm_fiitax = t`X'himm_fiitax + t`X'wimm_fiitax if marstat`X'==2
replace t`X'fuimm_fiitax = t`X'fuimm_fiitax + t`X'ofum_fiitax if !missing(t`X'fuimm_fiitax) // family unit totals

*Labeling variables
label var t`X'himm_eic "Disallowed imm EIC - ind head `X'"
label var t`X'himm_fiitax "Fed tax with disallowed imm EIC - ind head `X'"
label var t`X'wimm_eic "Disallowed imm EIC - ind wife `X'"
label var t`X'wimm_fiitax "Fed tax with disallowed imm EIC - ind wife `X'"
label var t`X'jimm_eic "Disallowed imm EIC - ind joint `X'"
label var t`X'jimm_fiitax "Fed tax with disallowed imm EIC - ind joint `X'"
label var t`X'fuimm_eic "Disallowed imm EIC - famunit `X'"
label var t`X'fuimm_fiitax "Fed tax with disallowed imm EIC - famunit `X'"
}


*Setting federal EITC value to zero if head or "wife" ineligible (by adding amount of refundable EITC credit to tax liability). Retaining eligibility for married joint filers if either head or wife is eligible.
foreach X in 1999 2001 2003 2005 2007 2009 2011 {
replace t`X'head_fiitax = t`X'head_fiitax + t`X'head_eic if c1999zheligeitc ==0
replace t`X'joint_fiitax = t`X'joint_fiitax + t`X'joint_eic if c1999zheligeitc ==0 & c1999zweligeitc ==0
replace t`X'wife_fiitax = t`X'wife_fiitax + t`X'wife_eic if c1999zweligeitc ==0
}

*Doing the same for state EITC (as generally set as a percentage of the federal EITC).
foreach X in 1999 2001 2003 2005 2007 2009 2011 {
replace t`X'head_siitax = t`X'head_siitax + t`X'head_seic if c1999zheligeitc ==0
replace t`X'joint_siitax = t`X'joint_siitax + t`X'joint_seic if c1999zheligeitc ==0 & c1999zweligeitc ==0
replace t`X'wife_siitax = t`X'wife_siitax + t`X'wife_seic if c1999zweligeitc ==0
}


save "$outdata/taxes_posttaxsim_$datestamp", replace

*CALCULATING TOTAL FAMILY UNIT TAXES 

*Summing payroll taxes for each tax unit to arrive at family unit tax totals:
*	Head with no wife/"wife" = head fica + ofum fica
*	Head with wife or "wife" = head fica + wife/"wife" fica + ofum fica

foreach X in 1999 2001 2003 2005 2007 2009 2011 {

gen t`X'fu_fica = t`X'head_fica
replace t`X'fu_fica = t`X'head_fica + t`X'wife_fica if marstat`X'==2 | marstat`X'==1 // only marstat 1 & 2 have non-zero values for wife/"wife" variables in PSID
replace t`X'fu_fica = t`X'fu_fica + t`X'ofum_fica
replace t`X'fu_fica = t`X'fu_fica / 2 // divided by 2 because TAXSIM output is total FICA paid by employer + employee
}


*Summing income taxes from each tax unit to arrive at family unit tax totals:
* 	Head with no wife/"wife" = head taxes + ofum taxes
* 	Head married to wife = joint taxes + ofum taxes
*	Head with "wife" (cohabitor) = head taxes + "wife" taxes + ofum taxes

foreach X in 1999 2001 2003 2005 2007 2009 2011 {
foreach Y in fiitax eic ctc ctcref ccc fiibc siitax sccc seic siicred {

gen t`X'fu_`Y' = t`X'head_`Y'
replace t`X'fu_`Y' = t`X'joint_`Y' if inlist(marstat`X',1,3) 
replace t`X'fu_`Y' = t`X'head_`Y' + t`X'wife_`Y' if marstat`X'==2
replace t`X'fu_`Y' = t`X'fu_`Y' + t`X'ofum_`Y' 
}
}


*"Simple" taxes available for comparison to total family unit taxes (t99simple_fiitax etc),
*	to show effect of creating multiple tax units within PSID families and using more 
*	detailed income/expense and dependent data.


*Labeling family-level variables
foreach X in 1999 2001 2003 2005 2007 2009 2011 {
label var t`X'fu_fiitax "Federal income tax liability - famunit `X'"
label var t`X'fu_eic "Earned Income Credit (total federal) - famunit `X'"
label var t`X'fu_ctc "Child Tax Credit - famunit `X'"
label var t`X'fu_ctcref "Additional Child Tax Credit (refundable) - famunit `X'"
label var t`X'fu_ccc "Child and Dependent Care Credit (federal) - famunit `X'"
label var t`X'fu_fiibc "Federal income tax before credits - famunit `X'"
label var t`X'fu_siitax "State income tax liability - famunit `X'"
label var t`X'fu_sccc "State Child Care Credit - famunit `X'"
label var t`X'fu_seic "State EIC - famunit `X'"
label var t`X'fu_siicred "State total credits - famunit `X'"
label var t`X'fu_fica "FICA payroll tax - famunit `X'"
}

save "$outdata/taxes_posttaxsim_$datestamp", replace

*SAVING FILE WITH FAMILY UNIT TAXES ONLY
keep ER30001 ER30002 personid ///
t1999fu_fiitax t1999fu_eic t1999fu_ctc t1999fu_ctcref t1999fu_ccc t1999fu_fiibc t1999fu_siitax t1999fu_sccc t1999fu_seic t1999fu_siicred t1999fu_fica ///
t2001fu_fiitax t2001fu_eic t2001fu_ctc t2001fu_ctcref t2001fu_ccc t2001fu_fiibc t2001fu_siitax t2001fu_sccc t2001fu_seic t2001fu_siicred t2001fu_fica ///
t2003fu_fiitax t2003fu_eic t2003fu_ctc t2003fu_ctcref t2003fu_ccc t2003fu_fiibc t2003fu_siitax t2003fu_sccc t2003fu_seic t2003fu_siicred t2003fu_fica ///
t2005fu_fiitax t2005fu_eic t2005fu_ctc t2005fu_ctcref t2005fu_ccc t2005fu_fiibc t2005fu_siitax t2005fu_sccc t2005fu_seic t2005fu_siicred t2005fu_fica ///
t2007fu_fiitax t2007fu_eic t2007fu_ctc t2007fu_ctcref t2007fu_ccc t2007fu_fiibc t2007fu_siitax t2007fu_sccc t2007fu_seic t2007fu_siicred t2007fu_fica ///
t2009fu_fiitax t2009fu_eic t2009fu_ctc t2009fu_ctcref t2009fu_ccc t2009fu_fiibc t2009fu_siitax t2009fu_sccc t2009fu_seic t2009fu_siicred t2009fu_fica ///
t2011fu_fiitax t2011fu_eic t2011fu_ctc t2011fu_ctcref t2011fu_ccc t2011fu_fiibc t2011fu_siitax t2011fu_sccc t2011fu_seic t2011fu_siicred t2011fu_fica

save "$outdata/taxes_output_$datestamp", replace

use "$outdata/taxes_output_$datestamp", clear

*RESHAPE LONG

foreach X in 1999 2001 2003 2005 2007 2009 2011 {
rename t`X'fu_fiitax fu_fiitax`X'
rename t`X'fu_eic fu_eic`X' 
rename t`X'fu_ctc fu_ctc`X'
rename t`X'fu_ctcref fu_ctcref`X'
rename t`X'fu_ccc fu_ccc`X' 
rename t`X'fu_fiibc fu_fiibc`X' 
rename t`X'fu_siitax fu_siitax`X' 
rename t`X'fu_sccc fu_sccc`X' 
rename t`X'fu_seic fu_seic`X'
rename t`X'fu_siicred fu_siicred`X'
rename t`X'fu_fica fu_fica`X'
}

reshape long fu_fiitax fu_eic fu_ctc fu_ctcref fu_ccc fu_fiibc fu_siitax fu_sccc fu_seic fu_siicred fu_fica, i(personid ER30001 ER30002) j(year)

label var fu_fiitax "Federal income tax liability - famunit"
label var fu_eic "Earned Income Credit (total federal) - famunit"
label var fu_ctc "Child Tax Credit - famunit"
label var fu_ctcref "Additional Child Tax Credit (refundable) - famunit"
label var fu_ccc "Child and Dependent Care Credit (federal) - famunit"
label var fu_fiibc "Federal income tax before credits - famunit"
label var fu_siitax "State income tax liability - famunit"
label var fu_sccc "State Child Care Credit - famunit"
label var fu_seic "State EIC - famunit"
label var fu_siicred "State total credits - famunit"
label var fu_fica "FICA payroll tax - famunit"

rename personid hhidpn

save $indata/psid_taxsim_1999_2011.dta, replace

