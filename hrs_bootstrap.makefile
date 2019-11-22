## Bootstrap Make Rules
MAXBREPS := $(N_HRS_BREPS)
BTARGET := $(addsuffix .txt, $(addprefix FEM_Stata/Makedata/HRS/new51s_input_brep_,${BREPS}))
BTARGET2 := $(addsuffix .txt, $(addprefix FEM_Stata/Makedata/HRS/new51s_bstrend_brep_,${BREPS}))
BTARGET3 := $(addsuffix .txt, $(addprefix FEM_Stata/Makedata/HRS/new51s_input_bstrend_brep_,${BREPS}))

$(DATADIR)/hhidb.dta: $(COMMON) FEM_Stata/Makedata/HRS/hhid_map_for_bootstrap.do $(RANDHRS)
	cd FEM_Stata/Makedata/HRS && $(STATA) hhid_map_for_bootstrap.do
# set up directory structure
bootstrap_directories.txt: bootstrap_directories.py bootstrap.makefile
	INPUT=$(DATADIR) STER=$(ESTIMHRS) EST=$(ROOT)/FEM_CPP_settings/hrs/models MAXBREP=${MAXBREPS} $(PYTHON) bootstrap_directories.py
bootstrap_directories_nested.txt: bootstrap_directories_nested.py bootstrap.makefile
	INPUT=$(ROOT)/input_data_backup INPUT_NEST=$(ROOT)/input_data EST=$(ROOT)/FEM_CPP_settings/models_backup EST_NEST=$(ROOT)/FEM_CPP_settings/models MAXBREP=${MAXBREPS} $(PYTHON) bootstrap_directories_nested.py
new51_dependency.txt: new51_dependency.py bootstrap.makefile
	MAXYEAR=${LYEAR} MAXBREP=${MAXBREPS} $(PYTHON) new51_dependency.py
new51_dependency_bstrend.txt: new51_dependency_bstrend.py bootstrap.makefile
	MAXYEAR=${LYEAR} MAXBREP=${MAXBREPS} $(PYTHON) new51_dependency_bstrend.py
new51_dependency_input_bstrend.txt: new51_dependency_input_bstrend.py bootstrap.makefile
	MAXYEAR=${LYEAR} MAXBREP=${MAXBREPS} $(PYTHON) new51_dependency_input_bstrend.py
# bootstrap samples of HRS
FEM_Stata/Makedata/HRS/bootstrap_sample_IDs.txt: $(COMMON) FEM_Stata/Makedata/HRS/bootstrap_samples.do $(RANDHRS) bootstrap.makefile
	cd FEM_Stata/Makedata/HRS && MAXBREP=${MAXBREPS} $(STATA) bootstrap_samples.do

BSAMPLES := $(addsuffix /$(TRANSFILE), $(addprefix $(DATADIR)/input_rep,${BREPS})) $(addsuffix /age5055_hrs2010.dta, $(addprefix $(DATADIR)/input_rep,${BREPS})) $(addsuffix /hrs_selected.dta, $(addprefix $(DATADIR)/input_rep,${BREPS})) $(addsuffix /all2010.dta, $(addprefix $(DATADIR)/input_rep,${BREPS})) $(addsuffix /all2010_pop_adjusted.dta, $(addprefix $(DATADIR)/input_rep,${BREPS})) $(addsuffix /stock_hrs_2010.dta, $(addprefix $(DATADIR)/input_rep,${BREPS})) $(addsuffix /incoming_base.dta, $(addprefix $(DATADIR)/input_rep,${BREPS}))
FEM_Stata/Makedata/HRS/bootstrap_samples.txt: ${BSAMPLES}

BSAMPLESID := $(addsuffix /bootstrap_sample.dta, $(addprefix $(DATADIR)/input_rep,${BREPS}))
${BSAMPLESID}: FEM_Stata/Makedata/HRS/bootstrap_sample_IDs.txt


# transition samples
$(DATADIR)/input_rep%/$(TRANSFILE): $(COMMON) FEM_Stata/Makedata/HRS/bootstrap_transition_samples.do $(DATADIR)/input_rep%/bootstrap_sample.dta $(TRANSDATA) $(DATADIR)/hhidb.dta bootstrap.makefile
	cd FEM_Stata/Makedata/HRS && BREP=$* $(STATA) bootstrap_transition_samples.do 
$(DATADIR)/bootstrap_hrs_transition_data.txt: $(addsuffix /$(TRANSFILE), $(addprefix $(DATADIR)/input_rep,$(BREPS)))
	touch $(DATADIR)/bootstrap_hrs_transition_data.txt

# new cohorts
$(DATADIR)/input_rep%/age5055_hrs1992.dta $(DATADIR)/input_rep%/age5055_hrs2010.dta: $(COMMON) FEM_Stata/Makedata/HRS/bootstrap_age5055_samples.do $(DATADIR)/input_rep%/bootstrap_sample.dta $(DATADIR)/hrs_selected.dta $(DATADIR)/hhidb.dta bootstrap.makefile $(DATADIR)/age5055_hrs1992.dta
	cd FEM_Stata/Makedata/HRS && BREP=$* $(STATA) bootstrap_age5055_samples.do 
$(DATADIR)/input_rep%/hrs_selected.dta: $(COMMON) FEM_Stata/Makedata/HRS/bootstrap_transition_samples.do $(DATADIR)/input_rep%/bootstrap_sample.dta $(DATADIR)/hrs_selected.dta $(DATADIR)/hhidb.dta bootstrap.makefile
	cd FEM_Stata/Makedata/HRS && BREP=$* $(STATA) bootstrap_new51_samples.do 
$(DATADIR)/input_rep%/incoming_base.dta: $(COMMON) FEM_Stata/Makedata/HRS/new51_select.do $(DATADIR)/input_rep%/hrs_selected.dta $(DATADIR)/pop5152_projection_2150.dta $(UTILITIES)/multiply_persons.ado expansion.makefile bootstrap.makefile
	cd FEM_Stata/Makedata/HRS && EXPAND=$(EXPANSION_FACTOR) BREP=$* $(STATA) new51_select.do
include new51_dependency.txt
include new51_dependency_bstrend.txt
include new51_dependency_input_bstrend.txt
# simulation samples
$(DATADIR)/input_rep%/all2010.dta: $(COMMON) FEM_Stata/Makedata/HRS/bootstrap_simulation_samples.do $(DATADIR)/input_rep%/bootstrap_sample.dta $(DATADIR)/all2010.dta $(DATADIR)/hhidb.dta bootstrap.makefile
	cd FEM_Stata/Makedata/HRS && BREP=$* $(STATA) bootstrap_simulation_samples.do 
$(DATADIR)/input_rep%/all2004_pop_adjusted.dta: $(COMMON)  FEM_Stata/Makedata/HRS/all2004_weightadjust.do $(DATADIR)/population_projection.dta $(DATADIR)/input_rep%/all2004.dta $(DATADIR)/death_counts.dta bootstrap.makefile
	cd FEM_Stata/Makedata/HRS && BREP=$* $(STATA) all2004_weightadjust.do
$(DATADIR)/input_rep%/all2010_pop_adjusted.dta: $(COMMON)  FEM_Stata/Makedata/HRS/all2010_weightadjust.do $(DATADIR)/population_projection.dta $(DATADIR)/input_rep%/all2010.dta $(DATADIR)/death_counts.dta bootstrap.makefile
	cd FEM_Stata/Makedata/HRS && BREP=$* $(STATA) all2010_weightadjust.do
$(DATADIR)/input_rep%/stock_hrs_2004.dta: $(COMMON) FEM_Stata/Makedata/HRS/save_stock_hrs_2004_faked.do $(RESTIMATES)/fraime2004.ster $(RESTIMATES)/fraime_nonzero2004.ster $(RESTIMATES)/flogq2004.ster $(RESTIMATES)/rpia2004.ster $(DATADIR)/input_rep%/all2004_pop_adjusted.dta $(UTILITIES)/multiply_persons.ado expansion.makefile bootstrap.makefile
	cd FEM_Stata/Makedata/HRS && EXPAND=$(EXPANSION_FACTOR) BREP=$* $(STATA) save_stock_hrs_2004_faked.do
$(DATADIR)/input_rep%/stock_hrs_2010.dta: $(COMMON) FEM_Stata/Makedata/HRS/save_stock_hrs_2010_faked.do $(DATADIR)/input_rep%/all2010_pop_adjusted.dta $(UTILITIES)/multiply_persons.ado expansion.makefile bootstrap.makefile $(DATADIR)/input_rep%/imputed_ssa_notret.dta
	cd FEM_Stata/Makedata/HRS && EXPAND=$(EXPANSION_FACTOR) BREP=$* $(STATA) save_stock_hrs_2010_faked.do
