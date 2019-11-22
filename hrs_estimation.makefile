## Rules to run the estimation code
estimation_cpp: $(COMMON)
	cd FEM_Stata/Estimation && datain=$(ESTIMHRS) dataout=$(ROOT)/FEM_CPP_settings/hrs/models $(STATA) save_est_cpp.do
	cd FEM_Stata/Estimation && datain=$(ESTIMATES)/minimal dataout=$(ROOT)/FEM_CPP_settings/minimal/models $(STATA) save_est_cpp.do
	cd FEM_Stata/Estimation && datain=$(ESTIMATES)/nofvars dataout=$(ROOT)/FEM_CPP_settings/nofvars/models $(STATA) save_est_cpp.do
	cd FEM_Stata/Estimation && datain=$(ESTIMHRS)/crossvalidation dataout=$(ROOT)/FEM_CPP_settings/hrs_crossvalidation/models $(STATA) save_est_cpp.do
	cd FEM_Stata/Estimation && datain=$(ESTIMATES)/nvaf dataout=$(ROOT)/FEM_CPP_settings/nvaf/models $(STATA) save_est_cpp.do

### Use the last file as the target for now. Should split this file up at some point
$(ESTIMHRS)/estimatesHRS.xls: $(COMMON) fem_env.do FEM_Stata/Estimation/init_transition.do $(TRANSDATA) $(UTILITIES)/takestring.ado FEM_Stata/Estimation/hrs_covariate_definitionsHRS.do $(DATADIR)/crossvalidation.dta FEM_Stata/Estimation/define_modelsHRS.do 
	cd FEM_Stata/Estimation && USERVARS=$(USERVARS) DATAIN=$(TRANSDATA) suffix=HRS EXTVAL=0 $(STATA) init_transition.do
	
$(ESTIMHRS)/ghregHRS.xls: $(COMMON) fem_env.do FEM_Stata/Estimation/ghreg_estimations.do $(TRANSDATA) $(UTILITIES)/takestring.ado FEM_Stata/Estimation/hrs_covariate_definitionsHRS.do FEM_Stata/Estimation/define_modelsHRS.do $(UTILITIES)/_gh.ado $(GHREG) $(UTILITIES)/_ggh.ado $(UTILITIES)/ghreg_p.ado $(DATADIR)/crossvalidation.dta $(UTILITIES)/opti_unc.mo 
	cd FEM_Stata/Estimation && USERVARS=$(USERVARS) DATAIN=$(TRANSDATA) suffix=HRS EXTVAL=0 $(STATA) ghreg_estimations.do

$(ESTIMATES)/minimal/estimatesminimal.xls: $(COMMON) fem_env.do FEM_Stata/Estimation/init_transition.do $(TRANSDATA) $(UTILITIES)/takestring.ado FEM_Stata/Estimation/hrs_covariate_definitionsminimal.do $(DATADIR)/crossvalidation.dta FEM_Stata/Estimation/define_modelsminimal.do 
	cd FEM_Stata/Estimation && USERVARS=$(USERVARS) DATAIN=$(TRANSDATA) suffix=minimal EXTVAL=0 $(STATA) init_transition.do

$(ESTIMATES)/nofvars/estimatesnofvars.xls: $(COMMON) fem_env.do FEM_Stata/Estimation/init_transition.do $(TRANSDATA) $(UTILITIES)/takestring.ado FEM_Stata/Estimation/hrs_covariate_definitionsnofvars.do $(DATADIR)/crossvalidation.dta FEM_Stata/Estimation/define_modelsnofvars.do 
	cd FEM_Stata/Estimation && USERVARS=$(USERVARS) DATAIN=$(TRANSDATA) suffix=nofvars EXTVAL=0 $(STATA) init_transition.do


$(ESTIMATES)/nvaf/claims.xls: fem_env.do FEM_Stata/Estimation/claims_afibe.do $(DATADIR)/hrs110_transition.dta $(HRSDIR)/hrs19922008_clms_trans.dta
	cd FEM_Stata/Estimation && USERVARS=$(USERVARS) $(STATA) claims_afibe.do
$(ESTIMHRS)/cogstate_stock.xls: $(COMMON) fem_env.do FEM_Stata/Estimation/cogstate_stock_6566.do $(DATADIR)/hrs_selected.dta
	cd FEM_Stata/Estimation && suffix=HRS $(STATA) cogstate_stock_6566.do
