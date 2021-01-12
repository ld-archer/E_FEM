export ROOT=$(CURDIR)
DATADIR = $(CURDIR)/input_data
BASEDIR = $(CURDIR)/base_data
ESTIMATES = $(CURDIR)/FEM_Stata/Estimates
ESTIMATION = $(CURDIR)/FEM_Stata/Estimation
RAW_ELSA = /home/luke/Documents/E_FEM/UKDA-5050-stata/stata/stata11_se
ANALYSIS = $(CURDIR)/analysis/techdoc_ELSA
MAKEDATA = $(CURDIR)/FEM_Stata/Makedata/ELSA
R = $(CURDIR)/FEM_R

include fem.makefile

STATA = $(CURDIR)/run.stata16.sh
MPI = $(CURDIR)/run.mpi.sh
PYTHON = python
RSCRIPT = Rscript


### Model runs

complete: ELSA base cross-validation minimal

base: start_data transitions_base est_base summary_out_base simulation_base 

cross-validation: start_data transitions_CV est_CV summary_out_CV simulation_CV1 simulation_CV2 CV2_detailed_append Ttests_CV

minimal: start_data transitions_minimal est_minimal summary_out_minimal simulation_minimal Ttests_minimal

debug: clean_logs clean_output complete debug_doc STYLE=BASE

core: start_data transitions_core est_core summary_out_core simulation_core

core_debug: clean_logs clean_output core debug_doc STYLE=CORE


### Combined rules

start_data: ELSA stata_extensions.txt populations imputation projections reweight

transitions_est_base: transitions_base est_base summary_out_base


### Install required Stata extensions

stata_extensions.txt: stata_extensions.do
	$(STATA) stata_extensions.do


### Populations

ELSA: $(DATADIR)/H_ELSA_f_2002-2016.dta

populations: $(DATADIR)/cross_validation/crossvalidation.dta $(DATADIR)/ELSA_long.dta $(DATADIR)/ELSA_stock_base.dta $(DATADIR)/ELSA_stock_base_CV1.dta $(DATADIR)/ELSA_stock_base_CV2.dta $(DATADIR)/ELSA_repl_base.dta $(DATADIR)/ELSA_transition.dta

$(DATADIR)/H_ELSA_f_2002-2016.dta: $(MAKEDATA)/H_ELSA_long.do
	cd $(MAKEDATA) && datain=$(RAW_ELSA) dataout=$(DATADIR) $(STATA) H_ELSA_long.do
	
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

reweight: $(DATADIR)/ELSA_stock.dta $(DATADIR)/ELSA_stock_CV1.dta $(DATADIR)/ELSA_stock_CV2.dta $(DATADIR)/ELSA_stock_min.dta $(DATADIR)/ELSA_stock_valid.dta $(DATADIR)/ELSA_repl.dta

$(DATADIR)/ELSA_stock.dta $(DATADIR)/ELSA_stock_CV1.dta $(DATADIR)/ELSA_stock_CV2.dta $(DATADIR)/ELSA_stock_min.dta $(DATADIR)/ELSA_stock_valid.dta: $(DATADIR)/ELSA_stock_base.dta $(DATADIR)/pop_projections.dta $(MAKEDATA)/reweight_ELSA_stock.do
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR) scen=base $(STATA) reweight_ELSA_stock.do
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR) scen=CV1 $(STATA) reweight_ELSA_stock.do
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR) scen=CV2 $(STATA) reweight_ELSA_stock.do
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR) scen=min $(STATA) reweight_ELSA_stock.do
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR) scen=valid $(STATA) reweight_ELSA_stock.do

$(DATADIR)/ELSA_repl.dta: $(DATADIR)/ELSA_repl_base.dta $(DATADIR)/pop_projections.dta $(DATADIR)/education_data.dta $(MAKEDATA)/reweight_ELSA_repl.do
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

summary_out_base:
	cd FEM_CPP_settings && measures_suffix=ELSA $(STATA) summary_output_gen.do

summary_out_CV:
	cd FEM_CPP_settings && measures_suffix=ELSA_CV1 $(STATA) summary_output_gen.do
	cd FEM_CPP_settings && measures_suffix=ELSA_CV2 $(STATA) summary_output_gen.do

summary_out_minimal:
	cd FEM_CPP_settings && measures_suffix=ELSA_minimal $(STATA) summary_output_gen.do

summary_out_core:
	cd FEM_CPP_settings && measures_suffix=ELSA_core $(STATA) summary_output_gen.do


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


### Handovers and Validation

handovers:
	cd analysis/techdoc_ELSA $(STATA) handover_ELSA.do

Ttests_CV: 
	mkdir -p $(ROOT)/output/ELSA_CV1/T-tests
	cd $(ANALYSIS) && datain=$(DATADIR) dataout=$(ROOT)/output/ scen=CV1 $(STATA) crossvalidation_ELSA.do

Ttests_minimal:
	mkdir -p $(ROOT)/output/ELSA_minimal/T-tests
	cd $(ANALYSIS) && datain=$(DATADIR) dataout=$(ROOT)/output/ scen=minimal $(STATA) crossvalidation_ELSA.do


### Dealing with detailed output

CV2_detailed_append: $(ROOT)/output/ELSA_CV2/ELSA_CV2_append.dta

$(ROOT)/output/ELSA_CV2/ELSA_CV2_append.dta: $(ROOT)/output/ELSA_CV2/ELSA_CV2_summary.dta
	cd $(MAKEDATA) && datain=output/ dataout=output/ scen=CV2 $(STATA) detailed_output_append.do


### Debugging

# assign a time stamp var for naming directories
# This is a bit of an experiment
TIMESTAMP = $(shell date +%m-%d_%T)

debug_doc: $(R)/model_analysis.nb.html

$(R)/model_analysis.nb.html: output/ELSA_minimal/ELSA_minimal_summary.dta output/ELSA_CV1/ELSA_CV1_summary.dta
	# Knit the document
	cd FEM_R/ && datain=output/ && dataout=FEM_R/ Rscript -e "require(rmarkdown); render('model_analysis.Rmd')"
	# Create debug dir if not already
	mkdir -p $(ROOT)/debug
	# Create dir with current time
	mkdir -p debug/$(STYLE)_$(TIMESTAMP)
	# Move the html analysis file as well as all outputs, .ster, .est, logs, 
	mv FEM_R/model_analysis.nb.html debug/$(STYLE)_$(TIMESTAMP)
	cp -r output/ debug/$(STYLE)_$(TIMESTAMP)
	cp -r $(ESTIMATES)/ELSA/ $(ESTIMATES)/ELSA_minimal/ debug/$(STYLE)_$(TIMESTAMP)
	cp -r FEM_CPP_settings/ELSA/ FEM_CPP_settings/ELSA_CV1/ FEM_CPP_settings/ELSA_CV2/ FEM_CPP_settings/ELSA_minimal/ debug/$(STYLE)_$(TIMESTAMP)
	mkdir -p debug/$(STYLE)_$(TIMESTAMP)/logs/
	cp -r FEM_Stata/Makedata/ELSA/*.log debug/$(STYLE)_$(TIMESTAMP)/logs/
	cp -r FEM_Stata/Estimation/*.log debug/$(STYLE)_$(TIMESTAMP)/logs/
	mkdir -p debug/$(STYLE)_$(TIMESTAMP)/settings/
	cp -r FEM_CPP_settings/ debug/$(STYLE)_$(TIMESTAMP)/settings/
	# Finally, open html file in firefox
	firefox file:///home/luke/Documents/E_FEM_clean/E_FEM/debug/$(STYLE)_$(TIMESTAMP)/model_analysis.nb.html


### Housekeeping and cleaning

clean_all: clean_logs clean_total clean_output clean_models

clean_logs:
	rm -f *.log
	rm -f FEM_Stata/Makedata/ELSA/*.log
	rm -f FEM_Stata/Estimation/*.log
	rm -f FEM_R/*.nb.html

clean_output:
	rm -rf output/*

clean_total:
	rm -f output/*/*.dta
	rm -f output/*/*/*.dta
	rm -f output/*/*/*.csv
	rm -f output/*/*/*.txt
	rm -f output/graphs/*/*.png

clean_debug:
	rm -f debug/*

clean_models:
	rm -f FEM_CPP_settings/ELSA/models/*.est
	rm -f FEM_CPP_settings/ELSA_*/models/*.est
	rm -f FEM_Stata/Estimates/ELSA/*.ster
	rm -f FEM_Stata/Estimates/ELSA/CV1/*.ster
	rm -f FEM_Stata/Estimates/ELSA/CV2/*.ster
	rm -f FEM_Stata/Estimates/ELSA_minimal/*.ster