$(ESTIMHRS)/qaly.xls: fem_env.do FEM_Stata/Estimation/qaly_estimations.do $(DATADIR)/hrs_analytic_recoded.dta $(DATADIR)/MEPS_EQ5D.dta $(DATADIR)/MEPS_cost_est.dta
	cd FEM_Stata/Estimation && $(STATA) qaly_estimations.do
### Use the last file for the target for now. Should change this.
$(ESTIMHRS)/cost_est_meps.xls: $(COMMON) fem_env.do FEM_Stata/Estimation/estimate_medcosts_meps.do $(FRED)/CPIMEDSL.csv $(DATADIR)/MEPS_cost_est.dta $(DATADIR)/meps_drugs.dta
	cd FEM_Stata/Estimation && $(STATA) estimate_medcosts_meps.do

$(ESTIMATES)/PSID/psid_cost_est_meps.txt: $(COMMON) fem_env.do FEM_Stata/Estimation/PSID_estimate_medcosts_meps.do $(DATADIR)/MEPS_cost_est.dta $(DATADIR)/meps_drugs.dta
	cd FEM_Stata/Estimation && $(STATA) PSID_estimate_medcosts_meps.do	
$(ESTIMATES)/PSID/qaly.ster: FEM_Stata/Estimation/PSID_qaly_estimations.do FEM_Stata/Estimation/PSID_qaly_covariate_defs.do $(DATADIR)/MEPS_EQ5D.dta $(DATADIR)/psid_analytic.dta
	cd FEM_Stata/Estimation && CHK_BS=$(CHK_BOOTS) $(STATA) PSID_qaly_estimations.do
