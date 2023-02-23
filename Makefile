export ROOT=$(CURDIR)
DATADIR = $(ROOT)/input_data
BASEDIR = $(ROOT)/base_data
ESTIMATES = $(ROOT)/FEM_Stata/Estimates
ESTIMATION = $(ROOT)/FEM_Stata/Estimation
RAW_ELSA = /home/luke/Documents/E_FEM_clean/ELSA/UKDA-5050-stata_09-09-21/stata/stata13_se/
ANALYSIS = $(ROOT)/analysis/techdoc_ELSA
MAKEDATA = $(ROOT)/FEM_Stata/Makedata/ELSA
OUTDATA = $(ROOT)/output
R = $(ROOT)/FEM_R
FEM_CPP_settings = $(ROOT)/FEM_CPP_settings

include fem.makefile

STATA = $(CURDIR)/run.stata16.sh
MPI = $(CURDIR)/run.mpi.sh
PYTHON = python
RSCRIPT = Rscript


### TODO

# Need a target to go through setup for the model, meaning creation of directories, renaming things etc.
# Folders in FEM_Stata/Estimates/
#	ELSA
#	ELSA_core
# 	ELSA_minimal
#		CV1 CV2
# In input_data
#	cross_validation
#	wave_specific (and wave specific files to be added in)
# In FEM_Stata/Makedata
# 	hotdeck_data/


### Help

.phony: help

help: 
	@fgrep -h "###" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/###//'

### Model runs

complete: model_prep base cross-validation minimal

base: model_prep start_data transitions_base est_base summary_out_base simulation_base 

cross-validation: start_data transitions_CV est_CV summary_out_CV simulation_CV1 simulation_CV2 CV2_detailed_append Ttests_CV

minimal: start_data transitions_minimal est_minimal summary_out_minimal simulation_minimal Ttests_minimal

debug: clean_output complete debug_doc

core: core_prep simulation_core

core_complete: ELSA core_complete_prep simulation_core_complete detailed_append_core_CV2 Ttests_core

core_debug: SUBPOP = debug
core_debug: core_complete debug_doc_core

core_scen: core_prep simulation_core_scen detailed_appends scen_doc

roc: SUBPOP = roc
roc: core_prep simulation_core_roc roc_validation

alcohol: SUBPOP = alcohol
alcohol: core_prep cv_prep simulation_alcohol alcohol_doc

alcohol2: SUBPOP = alcohol
alcohol2: core_prep simulation_alcohol2 alcohol_doc

handovers: SUBPOP = handovers
handovers: core_complete handover_plots

everything: core_debug alcohol handovers roc

validation: core_debug handovers roc

lnly_sociso: SUBPOP = lnly_sociso
lnly_sociso: core_prep simulation_lnly_sociso


### Combined rules

## Preparation

model_prep: ELSA stata_extensions.txt
start_data: populations imputation projections reweight

core_prep: start_data transitions_core est_core summary_out_core
cv_prep: transitions_core_CV est_core_CV summary_out_core_CV
minimal_prep: transitions_minimal est_minimal summary_out_minimal
core_complete_prep: core_prep cv_prep minimal_prep

## Utility

retest_CV: Ttests_core debug_doc_core


### Install required Stata extensions

stata_extensions.txt: stata_extensions.do
	$(STATA) stata_extensions.do


### Populations

ELSA: $(DATADIR)/H_ELSA_g2.dta 

ELSA_lifehistory: $(DATADIR)/H_ELSA_LH_a.dta

ELSA_EOL: $(DATADIR)/H_ELSA_EOL_a2.dta

populations: $(DATADIR)/H_ELSA_g2_wv_specific.dta $(DATADIR)/cross_validation/crossvalidation.dta $(DATADIR)/ELSA_long.dta $(DATADIR)/ELSA_stock_base.dta $(DATADIR)/ELSA_stock_base_CV1.dta $(DATADIR)/ELSA_stock_base_CV2.dta $(DATADIR)/ELSA_repl_base.dta $(DATADIR)/ELSA_transition.dta

$(DATADIR)/H_ELSA_g2.dta: $(MAKEDATA)/H_ELSA_long.do
	cd $(MAKEDATA) && datain=$(RAW_ELSA) dataout=$(DATADIR) $(STATA) H_ELSA_long.do

$(DATADIR)/H_ELSA_LH_a.dta: $(MAKEDATA)/H_ELSA_LH_long.do
	cd $(MAKEDATA) && datain=$(RAW_ELSA) dataout=$(DATADIR) $(STATA) H_ELSA_LH_long.do

$(DATADIR)/H_ELSA_EOL_a2.dta: $(MAKEDATA)/h_elsa_eol_long.do
	cd $(MAKEDATA) && datain=$(RAW_ELSA) dataout=$(DATADIR) $(STATA) h_elsa_eol_long.do

$(DATADIR)/H_ELSA_g2_wv_specific.dta: $(MAKEDATA)/wave_specific_data.do $(DATADIR)/H_ELSA_g2.dta
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR) $(STATA) wave_specific_data.do
	
$(DATADIR)/cross_validation/crossvalidation.dta: $(MAKEDATA)/ID_selection_CV.do 
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR)/cross_validation $(STATA) ID_selection_CV.do

$(DATADIR)/ELSA_long.dta: $(MAKEDATA)/reshape_long.do $(DATADIR)/H_ELSA_g2.dta $(MAKEDATA)/wave_specific_data2.do
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

transitions_base: $(ESTIMATES)/ELSA/died.ster

transitions_CV: $(ESTIMATES)/ELSA/crossvalidation1/died.ster $(ESTIMATES)/ELSA/crossvalidation2/died.ster

transitions_core: $(ESTIMATES)/ELSA_core/died.ster

transitions_core_CV: $(ESTIMATES)/ELSA_core/CV1/died.ster $(ESTIMATES)/ELSA_core/CV2/died.ster

transitions_minimal: $(ESTIMATES)/ELSA_minimal/died.ster

$(ESTIMATES)/ELSA/died.est: $(DATADIR)/ELSA_transition.dta $(ESTIMATION)/ELSA_init_transition.do $(ESTIMATION)/ELSA_covariate_definitionsELSA.do $(ESTIMATION)/ELSA_sample_selections.do
	cd $(ESTIMATION) && DATAIN=$(DATADIR) && dataout=$(DATADIR) && SUFFIX=ELSA $(STATA) ELSA_init_transition.do

$(ESTIMATES)/ELSA/crossvalidation1/died.est: $(DATADIR)/ELSA_transition.dta $(ESTIMATION)/ELSA_init_transition.do $(ESTIMATION)/ELSA_covariate_definitionsELSA.do $(ESTIMATION)/ELSA_sample_selections.do
	cd $(ESTIMATION) && DATAIN=$(DATADIR) && dataout=$(DATADIR) && SUFFIX=CV1 $(STATA) ELSA_init_transition.do

$(ESTIMATES)/ELSA/crossvalidation2/died.est: $(DATADIR)/ELSA_transition.dta $(ESTIMATION)/ELSA_init_transition.do $(ESTIMATION)/ELSA_covariate_definitionsELSA.do $(ESTIMATION)/ELSA_sample_selections.do
	cd $(ESTIMATION) && DATAIN=$(DATADIR) && dataout=$(DATADIR) && SUFFIX=CV2 $(STATA) ELSA_init_transition.do

$(ESTIMATES)/ELSA_minimal/died.ster: $(DATADIR)/ELSA_transition.dta $(ESTIMATION)/ELSA_init_transition.do $(ESTIMATION)/ELSA_covariate_definitionsminimal.do $(ESTIMATION)/ELSA_sample_selections.do
	cd $(ESTIMATION) && DATAIN=$(DATADIR) && dataout=$(DATADIR) && SUFFIX=minimal $(STATA) ELSA_init_transition.do

$(ESTIMATES)/ELSA_core/died.ster: $(DATADIR)/ELSA_transition.dta $(ESTIMATION)/ELSA_init_transition.do $(ESTIMATION)/ELSA_covariate_definitionscore.do $(ESTIMATION)/ELSA_sample_selections.do
	cd $(ESTIMATION) && DATAIN=$(DATADIR) && dataout=$(DATADIR) && SUFFIX=core $(STATA) ELSA_init_transition.do

$(ESTIMATES)/ELSA_core/CV1/died.ster: $(DATADIR)/ELSA_transition.dta $(ESTIMATION)/ELSA_init_transition.do $(ESTIMATION)/ELSA_covariate_definitionscore.do $(ESTIMATION)/ELSA_sample_selections.do
	cd $(ESTIMATION) && DATAIN=$(DATADIR) && dataout=$(DATADIR) && SUFFIX=core_CV1 $(STATA) ELSA_init_transition.do

$(ESTIMATES)/ELSA_core/CV2/died.ster: $(DATADIR)/ELSA_transition.dta $(ESTIMATION)/ELSA_init_transition.do $(ESTIMATION)/ELSA_covariate_definitionscore.do $(ESTIMATION)/ELSA_sample_selections.do
	cd $(ESTIMATION) && DATAIN=$(DATADIR) && dataout=$(DATADIR) && SUFFIX=core_CV2 $(STATA) ELSA_init_transition.do


### Estimates and Summary

est_base:
	cd $(ESTIMATION) && datain=$(ESTIMATES)/ELSA dataout=$(FEM_CPP_settings)/ELSA/models $(STATA) save_est_cpp.do
	cd $(ESTIMATION) && datain=$(ESTIMATES)/HRS dataout=$(FEM_CPP_settings)/hrs/models $(STATA) save_est_cpp.do

est_CV:
	cd $(ESTIMATION) && datain=$(ESTIMATES)/ELSA/CV1 dataout=$(FEM_CPP_settings)/ELSA_CV1/models $(STATA) save_est_cpp.do
	cd $(ESTIMATION) && datain=$(ESTIMATES)/ELSA/CV2 dataout=$(FEM_CPP_settings)/ELSA_CV2/models $(STATA) save_est_cpp.do

## Estimates (now adjusted targets so they're not constantly re-running)

est_minimal: $(FEM_CPP_settings)/ELSA_minimal/models/died.est

est_core: $(FEM_CPP_settings)/ELSA_core/models/died.est

est_core_CV: $(FEM_CPP_settings)/ELSA_core_CV2/models/died.est

$(ROOT)/FEM_CPP_settings/ELSA_core/models/died.est: $(ESTIMATES)/ELSA_core/died.ster
	cd $(ESTIMATION) && datain=$(ESTIMATES)/ELSA_core dataout=$(ROOT)/FEM_CPP_settings/ELSA_core/models $(STATA) save_est_cpp.do
	
$(ROOT)/FEM_CPP_settings/ELSA_core_CV2/models/died.est: $(ESTIMATES)/ELSA_core/CV1/died.ster $(ESTIMATES)/ELSA_core/CV2/died.ster
	cd $(ESTIMATION) && datain=$(ESTIMATES)/ELSA_core/CV1 dataout=$(ROOT)/FEM_CPP_settings/ELSA_core_CV1/models $(STATA) save_est_cpp.do
	cd $(ESTIMATION) && datain=$(ESTIMATES)/ELSA_core/CV2 dataout=$(ROOT)/FEM_CPP_settings/ELSA_core_CV2/models $(STATA) save_est_cpp.do

$(ROOT)/FEM_CPP_settings/ELSA_minimal/models/died.est: $(ESTIMATES)/ELSA_minimal/died.ster
	cd $(ESTIMATION) && datain=$(ESTIMATES)/ELSA_minimal dataout=$(ROOT)/FEM_CPP_settings/ELSA_minimal/models $(STATA) save_est_cpp.do

## Summary outputs

# Old targets (base and stuff, none core)
summary_out_base:
	cd FEM_CPP_settings && measures_suffix=ELSA subpops=$(SUBPOP) $(STATA) summary_output_gen.do

summary_out_CV:
	cd FEM_CPP_settings && measures_suffix=ELSA_CV1 subpops=$(SUBPOP) $(STATA) summary_output_gen.do
	cd FEM_CPP_settings && measures_suffix=ELSA_CV2 subpops=$(SUBPOP) $(STATA) summary_output_gen.do

# New targets (core and derivatives)
summary_out_core: $(FEM_CPP_settings)/summary_output_ELSA_core.txt

summary_out_core_CV: $(FEM_CPP_settings)/summary_output_ELSA_core_CV2.txt

summary_out_minimal: $(FEM_CPP_settings)/summary_output_ELSA_minimal.txt

$(FEM_CPP_settings)/summary_output_ELSA_core.txt: $(ROOT)/FEM_CPP_settings/ELSA_core/models/died.est $(FEM_CPP_settings)/summary_output_gen.do $(FEM_CPP_settings)/measures_subpop_ELSA.do
	cd FEM_CPP_settings && measures_suffix=ELSA_core subpops=$(SUBPOP) $(STATA) summary_output_gen.do

$(FEM_CPP_settings)/summary_output_ELSA_core_CV2.txt: $(ROOT)/FEM_CPP_settings/ELSA_core_CV2/models/died.est $(FEM_CPP_settings)/summary_output_gen.do $(FEM_CPP_settings)/measures_subpop_ELSA.do
	cd FEM_CPP_settings && measures_suffix=ELSA_core_CV1 subpops=$(SUBPOP) $(STATA) summary_output_gen.do
	cd FEM_CPP_settings && measures_suffix=ELSA_core_CV2 subpops=$(SUBPOP) $(STATA) summary_output_gen.do

$(FEM_CPP_settings)/summary_output_ELSA_minimal.txt: $(ROOT)/FEM_CPP_settings/ELSA_minimal/models/died.est $(FEM_CPP_settings)/summary_output_gen.do $(FEM_CPP_settings)/measures_subpop_ELSA.do
	cd FEM_CPP_settings && measures_suffix=ELSA_minimal subpops=$(SUBPOP) $(STATA) summary_output_gen.do


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

simulation_core_complete: $(OUTDATA)/COMPLETE/ELSA_core_base/ELSA_core_base_summary.dta 

$(OUTDATA)/COMPLETE/ELSA_core_base/ELSA_core_base_summary.dta: $(ROOT)/ELSA_core_complete.csv $(ROOT)/ELSA_core_complete.settings.txt $(ROOT)/FEM $(FEM_CPP_settings)/ELSA_vars.txt $(DATADIR)/ELSA_stock.dta $(DATADIR)/ELSA_repl.dta
	$(MPI) ELSA_core_complete.settings.txt

simulation_core_scen:
	$(MPI) ELSA_core_scen.settings.txt

simulation_core_roc:
	$(MPI) ELSA_roc_validation.settings.txt

simulation_alcohol:
	$(MPI) ELSA_Alcohol_Intervention.settings.txt

simulation_alcohol2:
	$(MPI) ELSA_Alcohol_Intervention_2.settings.txt

simulation_lnly_sociso: $(OUTDATA)/LNLY_SOCISO/ELSA_core_base/ELSA_core_base_summary.dta

$(OUTDATA)/LNLY_SOCISO/ELSA_core_base/ELSA_core_base_summary.dta: $(ROOT)/ELSA_lonely_sociso.csv $(ROOT)/ELSA_lonely_sociso.settings.txt $(ROOT)/FEM $(FEM_CPP_settings)/ELSA_vars.txt $(DATADIR)/ELSA_stock.dta $(DATADIR)/ELSA_repl.dta
	$(MPI) ELSA_lonely_sociso.settings.txt


### Handovers and Validation

validation: handover_plots roc_validation

handover_plots:
	cd analysis/techdoc_ELSA && datain=$(DATADIR) dataout=$(DATADIR) $(STATA) handover_ELSA.do

Ttests_CV: 
	mkdir -p $(ROOT)/output/ELSA_CV1/T-tests
	cd $(ANALYSIS) && datain=$(DATADIR) dataout=$(ROOT)/output/ scen=CV1 $(STATA) crossvalidation_ELSA.do

Ttests_minimal:
	mkdir -p $(ROOT)/output/ELSA_minimal/T-tests
	cd $(ANALYSIS) && datain=$(DATADIR) dataout=$(ROOT)/output/ scen=minimal $(STATA) crossvalidation_ELSA.do

Ttests_core:
	mkdir -p $(ROOT)/output/COMPLETE/ELSA_CV1/T-tests
	mkdir -p $(ROOT)/output/COMPLETE/ELSA_minimal/T-tests
	cd $(ANALYSIS) && datain=$(DATADIR) dataout=$(ROOT)/output/COMPLETE/ scen=CV1 $(STATA) crossvalidation_ELSA_core.do
	cd $(ANALYSIS) && datain=$(DATADIR) dataout=$(ROOT)/output/COMPLETE/ scen=minimal $(STATA) crossvalidation_ELSA_core.do

roc_validation2: $(MAKEDATA)/roc_validation.do
	mkdir -p $(MAKEDATA)/roc_img/old/
	rm -f $(MAKEDATA)/roc_img/old/*.pdf
	cp -f $(MAKEDATA)/roc_img/*.pdf $(MAKEDATA)/roc_img/old/
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR) $(STATA) roc_validation.do

roc_validation: $(MAKEDATA)/roc_validation.do
	mkdir -p $(OUTDATA)/ROC/roc_img/old/
	rm -f $(OUTDATA)/ROC/old/*.pdf
	cp -f $(OUTDATA)/ROC/roc_img/*.pdf ../ROC_Analysis/old/
	cd $(MAKEDATA) && datain=$(OUTDATA)/ROC dataout=$(OUTDATA)/ROC $(STATA) roc_validation.do


### Dealing with detailed output

detailed_appends: detailed_append_core_cohort detailed_append_core_smok

detailed_append_core_CV2: $(OUTDATA)/COMPLETE/ELSA_CV2/ELSA_CV2_summary.dta $(OUTDATA)/COMPLETE/ELSA_CV2/ELSA_CV2_append.dta

$(OUTDATA)/COMPLETE/ELSA_CV2/ELSA_CV2_append.dta:
	cd $(MAKEDATA) && datain=$(OUTDATA)/COMPLETE dataout=$(DATADIR)/detailed_output scen=CV2 $(STATA) detailed_output_append.do

detailed_append_core_cohort: $(OUTDATA)/SCENARIO/ELSA_core_cohort/ELSA_core_cohort_summary.dta
	cd $(MAKEDATA) && datain=$(OUTDATA)/SCENARIO dataout=$(DATADIR)/detailed_output scen=core_cohort $(STATA) detailed_output_append.do

#detailed_append_core_hearte: $(OUTDATA)/SCENARIO/ELSA_core_remove_hearte_c/ELSA_core_remove_hearte_c_summary.dta
#	cd $(MAKEDATA) && datain=$(OUTDATA)/SCENARIO dataout=$(DATADIR)/detailed_output scen=core_remove_hearte_c $(STATA) detailed_output_append.do

detailed_append_core_smok: $(OUTDATA)/SCENARIO/ELSA_core_remove_smoken/ELSA_core_remove_smoken_summary.dta
	cd $(MAKEDATA) && datain=$(OUTDATA)/SCENARIO dataout=$(DATADIR)/detailed_output scen=core_remove_smoken $(STATA) detailed_output_append.do

detailed_append_alcohol: $(OUTDATA)/ALCOHOL/ELSA_full/ELSA_full_summary.dta $(OUTDATA)/ALCOHOL/ELSA_alcInt_full/ELSA_alcInt_full_summary.dta
	cd $(MAKEDATA) && datain=$(OUTDATA)/ALCOHOL dataout=$(DATADIR)/detailed_output scen=full $(STATA) detailed_output_append.do
	cd $(MAKEDATA) && datain=$(OUTDATA)/ALCOHOL dataout=$(DATADIR)/detailed_output scen=alcInt_full $(STATA) detailed_output_append.do
	cd $(MAKEDATA) && datain=$(OUTDATA)/ALCOHOL dataout=$(DATADIR)/detailed_output scen=cohort $(STATA) detailed_output_append.do
	cd $(MAKEDATA) && datain=$(OUTDATA)/ALCOHOL dataout=$(DATADIR)/detailed_output scen=alcInt_cohort $(STATA) detailed_output_append.do


### Debugging

# assign a time stamp var for naming directories
# This is a bit of an experiment
TIMESTAMP = $(shell date +%m-%d_%T)

debug_doc: Ttests_CV Ttests_minimal $(R)/model_analysis.nb.html 

$(R)/model_analysis.nb.html: output/ELSA_minimal/ELSA_minimal_summary.dta output/ELSA_CV1/ELSA_CV1_summary.dta $(R)/model_analysis.Rmd
	# Knit the document
	cd FEM_R/ && datain=output/COMPLETE && dataout=FEM_R/ Rscript -e "require(rmarkdown); render('model_analysis.Rmd')"
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


debug_doc_core: $(R)/model_analysis_core.nb.html 

$(R)/model_analysis_core.nb.html: output/COMPLETE/ELSA_minimal/ELSA_minimal_summary.dta output/COMPLETE/ELSA_CV1/ELSA_CV1_summary.dta $(R)/model_analysis_core.Rmd
	# Knit the document
	cd FEM_R/ && datain=output/ && dataout=FEM_R/ Rscript -e "require(rmarkdown); render('model_analysis_core.Rmd')"
	# Create debug dir if not already
	mkdir -p $(ROOT)/debug
	mkdir -p $(ROOT)/debug/core
	# Create dir with current time
	mkdir -p debug/core/core_$(TIMESTAMP)/
	# Move the html analysis file as well as all outputs, .ster, .est, logs, 
	mv FEM_R/model_analysis_core.nb.html debug/core/core_$(TIMESTAMP)
	cp -r output/COMPLETE/ debug/core/core_$(TIMESTAMP)
	cp -r $(ESTIMATES)/ELSA/ $(ESTIMATES)/ELSA_minimal/ debug/core/core_$(TIMESTAMP)
	cp -r FEM_CPP_settings/ELSA_core/ FEM_CPP_settings/ELSA_core_CV1/ FEM_CPP_settings/ELSA_core_CV2/ FEM_CPP_settings/ELSA_minimal/ debug/core/core_$(TIMESTAMP)
	mkdir -p debug/core/core_$(TIMESTAMP)/logs/
	cp -r FEM_Stata/Makedata/ELSA/*.log debug/core/core_$(TIMESTAMP)/logs/
	cp -r FEM_Stata/Estimation/*.log debug/core/core_$(TIMESTAMP)/logs/
	cp -r $(ROOT)/log*.txt debug/core/core_$(TIMESTAMP)/logs/
	mkdir -p debug/core/core_$(TIMESTAMP)/settings/
	cp -r FEM_CPP_settings/ debug/core/core_$(TIMESTAMP)/settings/
	# Finally, open html file in firefox
	firefox file:///home/luke/Documents/WORK/E_FEM/E_FEM/debug/core/core_$(TIMESTAMP)/model_analysis_core.nb.html


scen_doc: $(R)/IJM_PAPER1_ALL_ANALYSES.nb.html $(DATADIR)/detailed_output/tot/tot_test_smoken_int[2].do

$(R)/IJM_PAPER1_ALL_ANALYSES.nb.html: output/SCENARIO/ELSA_core_base/ELSA_core_base_summary.dta $(R)/IJM_PAPER1_ALL_ANALYSES.Rmd
	# Run Treatment on Treated script
	cd $(DATADIR)/detailed_output/tot/ && datain=$(DATADIR)/detailed_output/tot/ && dataout=$(DATADIR)/detailed_output/tot/ $(STATA) tot_test_smoken_int[2].do
	# Knit
	cd FEM_R/ && datain=output/SCENARIO/ && dataout=FEM_R/ Rscript -e "require(rmarkdown); render('IJM_PAPER1_ALL_ANALYSES.Rmd')"
	firefox file:///home/luke/Documents/E_FEM_clean/E_FEM/FEM_R/IJM_PAPER1_ALL_ANALYSES.nb.html


alcohol_doc: $(R)/Alcohol/Validation_FEM_vs_HSE.nb.html

$(R)/Alcohol/Validation_FEM_vs_HSE.nb.html: $(OUTDATA)/ALCOHOL/ELSA_full/ELSA_full_summary.dta
	# Run validation script
	cd $(R)/Alcohol/ && datain=output/ && dataout=$(R)/Alcohol/ Rscript -e "require(rmarkdown); render('Validation_FEM_vs_HSE.Rmd')"
	# Create debug dir if not already
	mkdir -p $(ROOT)/debug
	mkdir -p $(ROOT)/debug/alcohol
	# Create dir with current time
	mkdir -p debug/alcohol/alcohol_$(TIMESTAMP)
	# Move the html analysis file as well as all outputs, .ster, .est, logs, 
	mv $(R)/Alcohol/Validation_FEM_vs_HSE.nb.html debug/alcohol/alcohol_$(TIMESTAMP)
	cp -r output/ALCOHOL/ debug/alcohol/alcohol_$(TIMESTAMP)
#	cp -r $(ESTIMATES)/ELSA/ debug/alcohol/alcohol_$(TIMESTAMP)
	cp -r FEM_CPP_settings/ELSA_core/ debug/alcohol/alcohol_$(TIMESTAMP)
	mkdir -p debug/alcohol/alcohol_$(TIMESTAMP)/logs/
	cp -r FEM_Stata/Makedata/ELSA/*.log debug/alcohol/alcohol_$(TIMESTAMP)/logs/
	cp -r FEM_Stata/Estimation/*.log debug/alcohol/alcohol_$(TIMESTAMP)/logs/
	cp -r $(ROOT)/log*.txt debug/alcohol/alcohol_$(TIMESTAMP)/logs/
	mkdir -p debug/alcohol/alcohol_$(TIMESTAMP)/settings/
	cp -r FEM_CPP_settings/ debug/alcohol/alcohol_$(TIMESTAMP)/settings/
	# Finally, open html file in firefox
	firefox file:///home/luke/Documents/E_FEM_clean/E_FEM/debug/alcohol/alcohol_$(TIMESTAMP)/Validation_FEM_vs_HSE.nb.html


### Housekeeping and cleaning

.phony: move_results clean_all clean_logs clean_debug clean_models clean_handovers clean_settings clean_hotdecks clean_output

move_results: 
	rm -rf ../tmp_output/*
	cp -r output/SCENARIO/* ../tmp_output/

clean_all: clean_logs clean_models clean_handovers clean_settings clean_hotdecks

clean_logs:
	rm -f *.log
	rm -f FEM_Stata/Makedata/ELSA/*.log
	rm -f FEM_Stata/Estimation/*.log
	rm -f FEM_R/*.nb.html
	rm -f analysis/techdoc_ELSA/*.log
#	rm -f log_*.txt
	rm -f FEM_CPP_settings/*.log

clean_debug:
	rm -f debug/*

clean_models:
	rm -f FEM_CPP_settings/ELSA/models/*.est
	rm -f FEM_CPP_settings/ELSA_*/models/*.est
	rm -f FEM_Stata/Estimates/ELSA*/*.ster
	rm -f FEM_Stata/Estimates/ELSA*/*/*.ster
	rm -f FEM_Stata/Estimates/ELSA/*/*.ster

clean_handovers:
	rm -f analysis/techdoc_ELSA/*.gph
	rm -f analysis/techdoc_ELSA/*.dta
	rm -f analysis/techdoc_ELSA/FEM/img/*.pdf

clean_settings:
	rm -f FEM_CPP_settings/summary_output_ELSA*.txt

clean_hotdecks:
	rm -f FEM_Stata/Makedata/ELSA/hotdeck_data/*.dta

clean_output:
	rm -rf output/*/*
