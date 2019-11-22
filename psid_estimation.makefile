## PSID Transition model estimation
$(ESTIMATES)/PSID/died.ster: FEM_Stata/Estimation/PSID_transition.do $(DATADIR)/psid_transition.dta $(DATADIR)/psid_crossvalidation.dta $(DATADIR)/psid_hrs_transition.dta FEM_Stata/Estimation/psid_covariate_definitions.do FEM_Stata/Estimation/psid_define_models.do
	cd FEM_Stata/Estimation/ && CHK_BS=$(CHK_BOOTS) $(STATA) PSID_transition.do
$(ESTIMATES)/PSID/hatota.ster: FEM_Stata/Estimation/PSID_ghreg_estimations.do $(DATADIR)/psid_transition.dta $(UTILITIES)/opti.mo FEM_Stata/Estimation/psid_covariate_definitions.do FEM_Stata/Estimation/psid_define_models.do
	cd FEM_Stata/Estimation/ && CHK_BS=$(CHK_BOOTS) $(STATA) PSID_ghreg_estimations.do	
$(ESTIMATES)/PSID/lniearn_nl.ster: FEM_Stata/Estimation/psid_earnings.do $(DATADIR)/psid_transition.dta FEM_Stata/Estimation/psid_covariate_definitions.do FEM_Stata/Estimation/psid_define_models.do
	cd FEM_Stata/Estimation/ && CHK_BS=$(CHK_BOOTS) $(STATA) psid_earnings.do	

## PSID minimal Transition model estimation
$(ESTIMATES)/PSID/minimal/died.ster: FEM_Stata/Estimation/PSID_transition.do $(DATADIR)/psid_transition.dta $(DATADIR)/psid_transition.dta $(DATADIR)/psid_hrs_transition.dta FEM_Stata/Estimation/psid_covariate_definitionsminimal.do FEM_Stata/Estimation/psid_define_modelsminimal.do
	cd FEM_Stata/Estimation/ && suffix=minimal $(STATA) PSID_transition.do
$(ESTIMATES)/PSID/minimal/hatota.ster: FEM_Stata/Estimation/PSID_ghreg_estimations.do $(DATADIR)/psid_transition.dta $(UTILITIES)/opti.mo FEM_Stata/Estimation/psid_covariate_definitionsminimal.do FEM_Stata/Estimation/psid_define_modelsminimal.do
	cd FEM_Stata/Estimation/ && suffix=minimal $(STATA) PSID_ghreg_estimations.do	
$(ESTIMATES)/PSID/minimal/lniearn_nl.ster: FEM_Stata/Estimation/psid_earnings.do $(DATADIR)/psid_transition.dta FEM_Stata/Estimation/psid_covariate_definitionsminimal.do FEM_Stata/Estimation/psid_define_modelsminimal.do
	cd FEM_Stata/Estimation/ && suffix=minimal $(STATA) psid_earnings.do	



estimate_cpp:
	cd FEM_Stata/Estimation && datain=$(ESTIMHRS) dataout=$(ROOT)/FEM_CPP_settings/hrs/models $(STATA) save_est_cpp.do
	cd FEM_Stata/Estimation && datain=$(ESTIMATES)/minimal dataout=$(ROOT)/FEM_CPP_settings/minimal/models $(STATA) save_est_cpp.do
	cd FEM_Stata/Estimation && datain=$(ESTIMHRS)/crossvalidation dataout=$(ROOT)/FEM_CPP_settings/hrs_crossvalidation/models $(STATA) save_est_cpp.do
	cd FEM_Stata/Estimation && datain=$(ESTIMATES)/nvaf dataout=$(ROOT)/FEM_CPP_settings/nvaf/models $(STATA) save_est_cpp.do
	cd FEM_Stata/Estimation && datain=$(ESTIMPSID) dataout=$(ROOT)/FEM_CPP_settings/psid/models $(STATA) save_est_cpp.do
	cd FEM_Stata/Estimation && datain=$(ESTIMPSID)/crossvalidation dataout=$(ROOT)/FEM_CPP_settings/psid_crossvalidation/models $(STATA) save_est_cpp.do
	cd FEM_Stata/Estimation && datain=$(ESTIMPSID)/minimal dataout=$(ROOT)/FEM_CPP_settings/psid_minimal/models $(STATA) save_est_cpp.do
