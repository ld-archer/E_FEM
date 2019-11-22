$(ESTIMHRS)/mcare_ptd.xls: $(COMMON) fem_env.do FEM_Stata/Estimation/MedicarePartD.do FEM_Stata/Estimation/mcared_mcbs_covariate_defsHRS.do $(MCBSRESTRICT)/mcbs9212.dta
	cd FEM_Stata/Estimation && suffix=HRS $(STATA) MedicarePartD.do
$(ESTIMATES)/PSID/mcare_ptd.xls: $(COMMON) fem_env.do FEM_Stata/Estimation/MedicarePartD.do FEM_Stata/Estimation/mcared_mcbs_covariate_defsPSID.do $(MCBSRESTRICT)/mcbs9212.dta
	cd FEM_Stata/Estimation && suffix=PSID $(STATA) MedicarePartD.do
$(ESTIMHRS)/mcareb_init.xls: $(COMMON) fem_env.do FEM_Stata/Estimation/InitMedicarePartBEnrollment.do FEM_Stata/Estimation/init_mcareb_mcbs_covariate_defsHRS.do $(MCBSRESTRICT)/mcbs9212.dta
	cd FEM_Stata/Estimation && suffix=HRS $(STATA) InitMedicarePartBEnrollment.do
$(ESTIMATES)/PSID/mcareb_init.xls: $(COMMON) fem_env.do FEM_Stata/Estimation/InitMedicarePartBEnrollment.do FEM_Stata/Estimation/init_mcareb_mcbs_covariate_defsPSID.do $(MCBSRESTRICT)/mcbs9212.dta
	cd FEM_Stata/Estimation && suffix=PSID $(STATA) InitMedicarePartBEnrollment.do
$(ESTIMATES)/PSID/psid_cost_est_mcbs.txt: $(COMMON) fem_env.do FEM_Stata/Estimation/PSID_estimate_medcosts_mcbs.do $(MCBSDIR)/mcbs_cost_est.dta
	cd FEM_Stata/Estimation && $(STATA) PSID_estimate_medcosts_mcbs.do	

$(ESTIMHRS)/mcare_takeup.xls: $(COMMON) fem_env.do FEM_Stata/Estimation/MedicarePartBEnrollment.do FEM_Stata/Estimation/mcareb_mcbs_covariate_defsHRS.do $(MCBSRESTRICT)/mcbs9212.dta
	cd FEM_Stata/Estimation && suffix=HRS $(STATA) MedicarePartBEnrollment.do
$(ESTIMATES)/PSID/mcare_takeup.xls: $(COMMON) fem_env.do FEM_Stata/Estimation/MedicarePartBEnrollment.do FEM_Stata/Estimation/mcareb_mcbs_covariate_defsPSID.do $(MCBSRESTRICT)/mcbs9212.dta
	cd FEM_Stata/Estimation && suffix=PSID $(STATA) MedicarePartBEnrollment.do
### Use the last file for the target for now. Should change this.
$(ESTIMHRS)/cost_est_mcbs.xls: $(COMMON) fem_env.do FEM_Stata/Estimation/estimate_medcosts_mcbs.do $(FRED)/CPIMEDSL.csv $(MCBSDIR)/mcbs_cost_est.dta $(MCBSDIR)/mcbs_drugs.dta
	cd FEM_Stata/Estimation && $(STATA) estimate_medcosts_mcbs.do
