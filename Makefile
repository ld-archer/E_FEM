export ROOT=$(CURDIR)
DATADIR = $(CURDIR)/input_data
BASEDIR = $(CURDIR)/base_data
ESTIMATES = $(CURDIR)/FEM_Stata/Estimates
ESTIMATION = $(CURDIR)/FEM_Stata/Estimation
RAW_ELSA = /home/luke/Documents/E_FEM_clean/ELSA/UKDA-5050-stata/stata/stata13_se/
ANALYSIS = $(CURDIR)/analysis/techdoc_ELSA
MAKEDATA = $(CURDIR)/FEM_Stata/Makedata/ELSA
OUTDATA = $(CURDIR)/output
R = $(CURDIR)/FEM_R

include fem.makefile

STATA = $(CURDIR)/run.stata16.sh
MPI = $(CURDIR)/run.mpi.sh
PYTHON = python
RSCRIPT = Rscript


### Model runs

complete: model_prep base cross-validation minimal

base: model_prep start_data transitions_base est_base summary_out_base simulation_base 

cross-validation: start_data transitions_CV est_CV summary_out_CV simulation_CV1 simulation_CV2 CV2_detailed_append Ttests_CV

minimal: start_data transitions_minimal est_minimal summary_out_minimal simulation_minimal Ttests_minimal

debug: clean_logs clean_output complete debug_doc 

core_prep: start_data transitions_core est_core summary_out_core
core: core_prep simulation_core

core_complete_prep: core_prep transitions_minimal est_minimal summary_out_minimal
core_complete: ELSA core_complete_prep simulation_core_complete detailed_append_core_CV2 Ttests_core

core_debug: clean_logs clean_output core_complete debug_doc_core

core_scen: clean_logs clean_output core_prep simulation_core_scen move_results

roc: core_prep simulation_core_roc roc_validation


### Combined rules

model_prep: ELSA stata_extensions.txt 

start_data: populations imputation projections reweight

transitions_est_base: transitions_base est_base summary_out_base


### Install required Stata extensions

stata_extensions.txt: stata_extensions.do
	$(STATA) stata_extensions.do


### Populations

ELSA: $(DATADIR)/H_ELSA_f_2002-2016.dta

ELSA_lifehistory: $(DATADIR)/H_ELSA_LH_a.dta

populations: $(DATADIR)/cross_validation/crossvalidation.dta $(DATADIR)/ELSA_long.dta $(DATADIR)/ELSA_stock_base.dta $(DATADIR)/ELSA_stock_base_CV1.dta $(DATADIR)/ELSA_stock_base_CV2.dta $(DATADIR)/ELSA_repl_base.dta $(DATADIR)/ELSA_transition.dta

$(DATADIR)/H_ELSA_f_2002-2016.dta: $(MAKEDATA)/H_ELSA_long.do
	cd $(MAKEDATA) && datain=$(RAW_ELSA) dataout=$(DATADIR) $(STATA) H_ELSA_long.do

$(DATADIR)/H_ELSA_LH_a.dta: $(MAKEDATA)/H_ELSA_LH_long.do
	cd $(MAKEDATA) && datain=$(RAW_ELSA) dataout=$(DATADIR) $(STATA) H_ELSA_LH_long.do
	
$(DATADIR)/cross_validation/crossvalidation.dta: $(MAKEDATA)/ID_selection_CV.do 
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR)/cross_validation $(STATA) ID_selection_CV.do

$(DATADIR)/ELSA_long.dta: $(MAKEDATA)/reshape_long.do $(DATADIR)/H_ELSA_f_2002-2016.dta
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR) $(STATA) reshape_long.do

$(DATADIR)/ELSA_stock_base.dta $(DATADIR)/ELSA_stock_base_CV1.dta $(DATADIR)/ELSA_stock_base_CV2.dta: $(DATADIR)/ELSA_long.dta $(MAKEDATA)/generate_stock_pop.do $(MAKEDATA)/kludge.do
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR) $(STATA) generate_stock_pop.do

$(DATADIR)/ELSA_repl_base.dta: $(DATADIR)/ELSA_stock_base.dta $(MAKEDATA)/generate_replenishing_pop.do
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR) $(STATA) generate_replenishing_pop.do

$(DATADIR)/ELSA_transition.dta: $(DATADIR)/ELSA_long.dta $(MAKEDATA)/generate_transition_pop.do
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR) $(STATA) generate_transition_pop.do


### Imputation (Imputing educ variable in GlobalPreInitializationModule, this rule produces the oprobit model for imputing)

imputation: $(ESTIMATES)/ELSA/educ.ster

$(ESTIMATES)/ELSA/educ.ster: $(ESTIMATION)/ELSA_estimate_missing_educ.do $(DATADIR)/ELSA_long.dta
	cd $(ESTIMATION) && datain=$(DATADIR) $(STATA) ELSA_estimate_missing_educ.do


### Producing the reweighting data (pop. projection and education)

projections: $(DATADIR)/pop_projections.dta $(DATADIR)/education_data.dta

$(DATADIR)/pop_projections.dta: $(DATADIR)/census_pop_estimates_02-18.csv $(MAKEDATA)/gen_pop_projections.do
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR) $(STATA) gen_pop_projections.do

$(DATADIR)/education_data.dta: $(DATADIR)/CT0469_2011census_educ.csv $(MAKEDATA)/education_proj.do
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR) $(STATA) education_proj.do


### Reweighting

reweight: $(DATADIR)/ELSA_stock.dta $(DATADIR)/ELSA_stock_CV1.dta $(DATADIR)/ELSA_stock_CV2.dta $(DATADIR)/ELSA_stock_min.dta $(DATADIR)/ELSA_stock_valid.dta $(DATADIR)/ELSA_repl.dta $(MAKEDATA)/gen_bmi_repls.do $(DATADIR)/ELSA_stock_ROC.dta

$(DATADIR)/ELSA_stock.dta $(DATADIR)/ELSA_stock_CV1.dta $(DATADIR)/ELSA_stock_CV2.dta $(DATADIR)/ELSA_stock_min.dta $(DATADIR)/ELSA_stock_valid.dta $(DATADIR)/ELSA_stock_ROC.dta: $(DATADIR)/ELSA_stock_base.dta  $(DATADIR)/pop_projections.dta $(MAKEDATA)/reweight_ELSA_stock.do
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR) scen=base $(STATA) reweight_ELSA_stock.do
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR) scen=CV1 $(STATA) reweight_ELSA_stock.do
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR) scen=CV2 $(STATA) reweight_ELSA_stock.do
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR) scen=min $(STATA) reweight_ELSA_stock.do
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR) scen=valid $(STATA) reweight_ELSA_stock.do
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR) scen=ROC $(STATA) reweight_ELSA_stock.do

$(DATADIR)/ELSA_repl.dta: $(DATADIR)/ELSA_repl_base.dta $(DATADIR)/pop_projections.dta $(DATADIR)/education_data.dta $(MAKEDATA)/reweight_ELSA_repl.do $(MAKEDATA)/gen_bmi_repls.do
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR) scen=base $(STATA) reweight_ELSA_repl.do


### Transitions
# Use the died.est model as the target for the transitions rules, as this model is always required and won't be removed by accident

transitions_base: $(ESTIMATES)/ELSA/died.est

transitions_CV: $(ESTIMATES)/ELSA/crossvalidation1/died.est $(ESTIMATES)/ELSA/crossvalidation2/died.est

$(ESTIMATES)/ELSA/died.est: $(DATADIR)/ELSA_transition.dta $(ESTIMATION)/ELSA_init_transition.do $(ESTIMATION)/ELSA_covariate_definitionsELSA.do $(ESTIMATION)/ELSA_sample_selections.do
	cd $(ESTIMATION) && DATAIN=$(DATADIR) && dataout=$(DATADIR) && SUFFIX=ELSA $(STATA) ELSA_init_transition.do

$(ESTIMATES)/ELSA/crossvalidation1/died.est: $(DATADIR)/ELSA_transition.dta $(ESTIMATION)/ELSA_init_transition.do $(ESTIMATION)/ELSA_covariate_definitionsELSA.do $(ESTIMATION)/ELSA_sample_selections.do
	cd $(ESTIMATION) && DATAIN=$(DATADIR) && dataout=$(DATADIR) && SUFFIX=CV1 $(STATA) ELSA_init_transition.do

$(ESTIMATES)/ELSA/crossvalidation2/died.est: $(DATADIR)/ELSA_transition.dta $(ESTIMATION)/ELSA_init_transition.do $(ESTIMATION)/ELSA_covariate_definitionsELSA.do $(ESTIMATION)/ELSA_sample_selections.do
	cd $(ESTIMATION) && DATAIN=$(DATADIR) && dataout=$(DATADIR) && SUFFIX=CV2 $(STATA) ELSA_init_transition.do

transitions_minimal: $(DATADIR)/ELSA_transition.dta $(ESTIMATION)/ELSA_init_transition.do $(ESTIMATION)/ELSA_covariate_definitionsminimal.do $(ESTIMATION)/ELSA_sample_selections.do
	cd $(ESTIMATION) && DATAIN=$(DATADIR) && dataout=$(DATADIR) && SUFFIX=minimal $(STATA) ELSA_init_transition.do

transitions_core: $(DATADIR)/ELSA_transition.dta $(ESTIMATION)/ELSA_init_transition.do $(ESTIMATION)/ELSA_covariate_definitionscore.do $(ESTIMATION)/ELSA_sample_selections.do
	cd $(ESTIMATION) && DATAIN=$(DATADIR) && dataout=$(DATADIR) && SUFFIX=core $(STATA) ELSA_init_transition.do
	cd $(ESTIMATION) && DATAIN=$(DATADIR) && dataout=$(DATADIR) && SUFFIX=core_CV1 $(STATA) ELSA_init_transition.do
	cd $(ESTIMATION) && DATAIN=$(DATADIR) && dataout=$(DATADIR) && SUFFIX=core_CV2 $(STATA) ELSA_init_transition.do
	


### Estimates and Summary

est_base:
	cd $(ESTIMATION) && datain=$(ESTIMATES)/ELSA dataout=$(ROOT)/FEM_CPP_settings/ELSA/models $(STATA) save_est_cpp.do
	cd $(ESTIMATION) && datain=$(ESTIMATES)/HRS dataout=$(ROOT)/FEM_CPP_settings/hrs/models $(STATA) save_est_cpp.do

est_CV:
	cd $(ESTIMATION) && datain=$(ESTIMATES)/ELSA/CV1 dataout=$(ROOT)/FEM_CPP_settings/ELSA_CV1/models $(STATA) save_est_cpp.do
	cd $(ESTIMATION) && datain=$(ESTIMATES)/ELSA/CV2 dataout=$(ROOT)/FEM_CPP_settings/ELSA_CV2/models $(STATA) save_est_cpp.do

est_minimal:
	cd $(ESTIMATION) && datain=$(ESTIMATES)/ELSA_minimal dataout=$(ROOT)/FEM_CPP_settings/ELSA_minimal/models $(STATA) save_est_cpp.do

est_core:
	cd $(ESTIMATION) && datain=$(ESTIMATES)/ELSA_core dataout=$(ROOT)/FEM_CPP_settings/ELSA_core/models $(STATA) save_est_cpp.do
	cd $(ESTIMATION) && datain=$(ESTIMATES)/ELSA_core/CV1 dataout=$(ROOT)/FEM_CPP_settings/ELSA_core_CV1/models $(STATA) save_est_cpp.do
	cd $(ESTIMATION) && datain=$(ESTIMATES)/ELSA_core/CV2 dataout=$(ROOT)/FEM_CPP_settings/ELSA_core_CV2/models $(STATA) save_est_cpp.do


summary_out_base:
	cd FEM_CPP_settings && measures_suffix=ELSA $(STATA) summary_output_gen.do

summary_out_CV:
	cd FEM_CPP_settings && measures_suffix=ELSA_CV1 $(STATA) summary_output_gen.do
	cd FEM_CPP_settings && measures_suffix=ELSA_CV2 $(STATA) summary_output_gen.do

summary_out_minimal:
	cd FEM_CPP_settings && measures_suffix=ELSA_minimal $(STATA) summary_output_gen.do

summary_out_core:
	cd FEM_CPP_settings && measures_suffix=ELSA_core $(STATA) summary_output_gen.do
	cd FEM_CPP_settings && measures_suffix=ELSA_core_CV1 $(STATA) summary_output_gen.do
	cd FEM_CPP_settings && measures_suffix=ELSA_core_CV2 $(STATA) summary_output_gen.do


### FEM Simulation

simulation_base:
	$(MPI) ELSA_example.settings.txt

simulation_CV1:
	$(MPI) ELSA_cross-validation1.settings.txt

simulation_CV2:
	$(MPI) ELSA_cross-validation2.settings.txt

simulation_minimal:
	$(MPI) ELSA_minimal.settings.txt

simulation_core:
	$(MPI) ELSA_core.settings.txt

simulation_core_complete:
	$(MPI) ELSA_core_complete.settings.txt

simulation_core_scen:
	$(MPI) ELSA_core_scen.settings.txt

simulation_core_roc:
	$(MPI) ELSA_roc_validation.settings.txt


### Handovers and Validation

validation: handovers roc_validation

handovers:
	cd analysis/techdoc_ELSA && datain=$(DATADIR) dataout=$(DATADIR) $(STATA) handover_ELSA.do

Ttests_CV: 
	mkdir -p $(ROOT)/output/ELSA_CV1/T-tests
	cd $(ANALYSIS) && datain=$(DATADIR) dataout=$(ROOT)/output/ scen=CV1 $(STATA) crossvalidation_ELSA.do

Ttests_minimal:
	mkdir -p $(ROOT)/output/ELSA_minimal/T-tests
	cd $(ANALYSIS) && datain=$(DATADIR) dataout=$(ROOT)/output/ scen=minimal $(STATA) crossvalidation_ELSA.do

Ttests_core:
	mkdir -p $(ROOT)/output/ELSA_CV1/T-tests
	mkdir -p $(ROOT)/output/ELSA_minimal/T-tests
	cd $(ANALYSIS) && datain=$(DATADIR) dataout=$(ROOT)/output/ scen=CV1 $(STATA) crossvalidation_ELSA_core.do
	cd $(ANALYSIS) && datain=$(DATADIR) dataout=$(ROOT)/output/ scen=minimal $(STATA) crossvalidation_ELSA_core.do

roc_validation: $(MAKEDATA)/roc_validation.do
	mkdir -p $(MAKEDATA)/roc_img/old/
	rm -f $(MAKEDATA)/roc_img/old/*.pdf
	cp -f $(MAKEDATA)/roc_img/*.pdf $(MAKEDATA)/roc_img/old/
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR) $(STATA) roc_validation.do


### Dealing with detailed output

detailed_appends: detailed_append_core_cohort detailed_append_core_hearte detailed_append_core_smok

detailed_append_core_CV2: $(OUTDATA)/ELSA_CV2/ELSA_CV2_summary.dta
	cd $(MAKEDATA) && datain=$(OUTDATA) dataout=$(DATADIR)/detailed_output scen=CV2 $(STATA) detailed_output_append.do

detailed_append_core_cohort: $(OUTDATA)/ELSA_core_cohort/ELSA_core_cohort_summary.dta
	cd $(MAKEDATA) && datain=$(OUTDATA) dataout=$(DATADIR)/detailed_output scen=core_cohort $(STATA) detailed_output_append.do

detailed_append_core_hearte: $(OUTDATA)/ELSA_core_remove_hearte_c/ELSA_core_remove_hearte_c_summary.dta
	cd $(MAKEDATA) && datain=$(OUTDATA) dataout=$(DATADIR)/detailed_output scen=core_remove_hearte_c $(STATA) detailed_output_append.do

detailed_append_core_smok: $(OUTDATA)/ELSA_core_remove_smoken/ELSA_core_remove_smoken_summary.dta
	cd $(MAKEDATA) && datain=$(OUTDATA) dataout=$(DATADIR)/detailed_output scen=core_remove_smoken $(STATA) detailed_output_append.do


### Debugging

# assign a time stamp var for naming directories
# This is a bit of an experiment
TIMESTAMP = $(shell date +%m-%d_%T)

debug_doc: Ttests_CV Ttests_minimal $(R)/model_analysis.nb.html 

$(R)/model_analysis.nb.html: output/ELSA_minimal/ELSA_minimal_summary.dta output/ELSA_CV1/ELSA_CV1_summary.dta $(R)/model_analysis.Rmd
	# Knit the document
	cd FEM_R/ && datain=output/ && dataout=FEM_R/ Rscript -e "require(rmarkdown); render('model_analysis.Rmd')"
	# Create debug dir if not already
	mkdir -p $(ROOT)/debug
	# Create dir with current time
	mkdir -p debug/base_$(TIMESTAMP)
	# Move the html analysis file as well as all outputs, .ster, .est, logs, 
	mv FEM_R/model_analysis.nb.html debug/base_$(TIMESTAMP)
	cp -r output/ debug/base_$(TIMESTAMP)
	cp -r $(ESTIMATES)/ELSA/ $(ESTIMATES)/ELSA_minimal/ debug/base_$(TIMESTAMP)
	cp -r FEM_CPP_settings/ELSA/ FEM_CPP_settings/ELSA_CV1/ FEM_CPP_settings/ELSA_CV2/ FEM_CPP_settings/ELSA_minimal/ debug/base_$(TIMESTAMP)
	mkdir -p debug/base_$(TIMESTAMP)/logs/
	cp -r FEM_Stata/Makedata/ELSA/*.log debug/base_$(TIMESTAMP)/logs/
	cp -r FEM_Stata/Estimation/*.log debug/base_$(TIMESTAMP)/logs/
	mkdir -p debug/base_$(TIMESTAMP)/settings/
	cp -r FEM_CPP_settings/ debug/base_$(TIMESTAMP)/settings/
	# Finally, open html file in firefox
	firefox file:///home/luke/Documents/E_FEM_clean/E_FEM/debug/base_$(TIMESTAMP)/model_analysis.nb.html


debug_doc_core: Ttests_core $(R)/model_analysis_core.nb.html 

$(R)/model_analysis_core.nb.html: output/ELSA_minimal/ELSA_minimal_summary.dta output/ELSA_CV1/ELSA_CV1_summary.dta $(R)/model_analysis_core.Rmd
	# Knit the document
	cd FEM_R/ && datain=output/ && dataout=FEM_R/ Rscript -e "require(rmarkdown); render('model_analysis_core.Rmd')"
	# Create debug dir if not already
	mkdir -p $(ROOT)/debug
	# Create dir with current time
	mkdir -p debug/core_$(TIMESTAMP)
	# Move the html analysis file as well as all outputs, .ster, .est, logs, 
	mv FEM_R/model_analysis_core.nb.html debug/core_$(TIMESTAMP)
	cp -r output/ debug/core_$(TIMESTAMP)
	cp -r $(ESTIMATES)/ELSA/ $(ESTIMATES)/ELSA_minimal/ debug/core_$(TIMESTAMP)
	cp -r FEM_CPP_settings/ELSA_core/ FEM_CPP_settings/ELSA_CV1/ FEM_CPP_settings/ELSA_CV2/ FEM_CPP_settings/ELSA_minimal/ debug/core_$(TIMESTAMP)
	mkdir -p debug/core_$(TIMESTAMP)/logs/
	cp -r FEM_Stata/Makedata/ELSA/*.log debug/core_$(TIMESTAMP)/logs/
	cp -r FEM_Stata/Estimation/*.log debug/core_$(TIMESTAMP)/logs/
	mkdir -p debug/core_$(TIMESTAMP)/settings/
	cp -r FEM_CPP_settings/ debug/core_$(TIMESTAMP)/settings/
	# Finally, open html file in firefox
	firefox file:///home/luke/Documents/E_FEM_clean/E_FEM/debug/core_$(TIMESTAMP)/model_analysis_core.nb.html


### Housekeeping and cleaning

move_results: 
	rm -rf ../tmp_output/*
	cp -r output/* ../tmp_output/

clean_all: clean_logs clean_output clean_models

clean_logs:
	rm -f *.log
	rm -f FEM_Stata/Makedata/ELSA/*.log
	rm -f FEM_Stata/Estimation/*.log
	rm -f FEM_R/*.nb.html

clean_output:
	rm -rf output/*

clean_debug:
	rm -f debug/*

clean_models:
	rm -f FEM_CPP_settings/ELSA/models/*.est
	rm -f FEM_CPP_settings/ELSA_*/models/*.est
	rm -f FEM_Stata/Estimates/ELSA*/*.ster
	rm -f FEM_Stata/Estimates/ELSA/*/*.ster
	#rm -f FEM_Stata/Estimates/ELSA/CV2/*.ster
	#rm -f FEM_Stata/Estimates/ELSA_minimal/*.ster