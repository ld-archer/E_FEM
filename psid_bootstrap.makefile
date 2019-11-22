## PSID bootstrap targets
PSID_BS_STERDIRS := $(addprefix $(ESTIMPSID)/models_rep, $(shell seq 1 1 $(N_PSID_BREPS)))
PSID_BS_ESTDIRS := $(addprefix $(ROOT)/FEM_CPP_settings/psid/models/models_rep, $(shell seq 1 1 $(N_PSID_BREPS)))
$(PSID_BS_STERDIRS) $(PSID_BS_ESTDIRS): bootstrap_directories.py bootstrap.makefile
	INPUT=$(DATADIR) STER=$(ESTIMPSID) EST=$(ROOT)/FEM_CPP_settings/psid/models MAXBREP=${N_PSID_BREPS} $(PYTHON) bootstrap_directories.py

$(DATADIR)/psid_hhidb.dta: $(COMMON) FEM_Stata/Makedata/PSID/hhid_map_for_bootstrap.do $(DATADIR)/psid_analytic.dta
	cd FEM_Stata/Makedata/PSID && $(STATA) hhid_map_for_bootstrap.do

FEM_Stata/Makedata/PSID/bootstrap_sample_IDs.txt: $(COMMON) FEM_Stata/Makedata/PSID/bootstrap_samples.do $(PSIDPUB)/Stata/fam2015er.dta bootstrap.makefile bootstrap_directories.txt
	cd FEM_Stata/Makedata/PSID && MAXBREP=${N_PSID_BREPS} $(STATA) bootstrap_samples.do

PSID_BSAMPLESID := $(addsuffix /psid_bootstrap_sample.dta, $(addprefix $(DATADIR)/input_rep,${PSID_BREPS}))
$(PSID_BSAMPLESID): FEM_Stata/Makedata/PSID/bootstrap_sample_IDs.txt

# transition samples
$(DATADIR)/input_rep%/psid_transition.dta: $(COMMON) FEM_Stata/Makedata/PSID/bootstrap_transition_samples.do $(DATADIR)/input_rep%/psid_bootstrap_sample.dta $(DATADIR)/psid_transition.dta $(DATADIR)/psid_hhidb.dta bootstrap.makefile
	cd FEM_Stata/Makedata/PSID && BREP=$* $(STATA) bootstrap_transition_samples.do 
$(DATADIR)/bootstrap_psid_transition_data.txt: $(addsuffix /psid_transition.dta, $(addprefix $(DATADIR)/input_rep,$(BREPS)))
	touch $(DATADIR)/bootstrap_psid_transition_data.txt
