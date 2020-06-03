export ROOT=$(CURDIR)
DATADIR = $(CURDIR)/input_data
BASEDIR = $(CURDIR)/base_data
ESTIMATES = $(CURDIR)/FEM_Stata/Estimates
ESTIMATION = $(CURDIR)/FEM_Stata/Estimation
RAW_ELSA = /home/luke/Documents/E_FEM/UKDA-5050-stata/stata/stata11_se

MAKEDATA = $(CURDIR)/FEM_Stata/Makedata/ELSA

include fem.makefile

STATA = $(CURDIR)/run.stata16.sh
MPI = $(CURDIR)/run.mpi.sh
PYTHON = python
RSCRIPT = Rscript


### Combined rules

full_run: ready_all simulation

transitions_full: transitions estimates summary_out simulation

ready_all: start_data transitions estimates summary_out

ready_new: start_data transitions_base estimates summary_out

start_data: populations projections reweight

populations: $(DATADIR)/ELSA_long.dta $(DATADIR)/ELSA_stock_base.dta $(DATADIR)/ELSA_repl_base.dta $(DATADIR)/ELSA_transition.dta


### Populations

$(DATADIR)/H_ELSA.dta: $(MAKEDATA)/H_ELSA_long.do
	cd $(MAKEDATA) && datain=$(RAW_ELSA) dataout=$(DATADIR) $(STATA) H_ELSA_long.do

$(DATADIR)/ELSA_long.dta: $(DATADIR)/H_ELSA.dta $(MAKEDATA)/reshape_long.do
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR) $(STATA) reshape_long.do

$(DATADIR)/ELSA_stock_base.dta: $(DATADIR)/ELSA_long.dta 
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR) $(STATA) generate_stock_pop.do

$(DATADIR)/ELSA_repl_base.dta: $(DATADIR)/ELSA_stock_base.dta
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR) $(STATA) generate_replenishing_pop.do

$(DATADIR)/ELSA_transition.dta: $(DATADIR)/ELSA_long.dta
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR) $(STATA) generate_transition_pop.do


### Producing the reweighting data (pop. projection and education)

projections: $(DATADIR)/census_pop_estimates_02-18.csv $(DATADIR)/CT0469_2011census_educ.csv $(MAKEDATA)/gen_pop_projections.do $(MAKEDATA)/education_proj.do
	cd $(MAKEDATA) $(STATA) gen_pop_projections.do
	cd $(MAKEDATA) $(STATA) education_proj.do


### Reweighting

reweight: projections $(DATADIR)/ELSA_stock_base.dta $(DATADIR)/ELSA_repl_base.dta
	cd $(MAKEDATA) && scen=base $(STATA) reweight_ELSA_stock.do
	cd $(MAKEDATA) && scen=exercise1 $(STATA) reweight_ELSA_stock.do
	cd $(MAKEDATA) && scen=drink $(STATA) reweight_ELSA_stock.do
	cd $(MAKEDATA) && scen=drinkd $(STATA) reweight_ELSA_stock.do
	cd $(MAKEDATA) && scen=smoken $(STATA) reweight_ELSA_stock.do
	cd $(MAKEDATA) && scen=base $(STATA) reweight_ELSA_repl.do
	cd $(MAKEDATA) && scen=exercise1 $(STATA) reweight_ELSA_repl.do
	cd $(MAKEDATA) && scen=drink $(STATA) reweight_ELSA_repl.do
	cd $(MAKEDATA) && scen=drinkd $(STATA) reweight_ELSA_repl.do
	cd $(MAKEDATA) && scen=smoken $(STATA) reweight_ELSA_repl.do


### Transitions

transitions: $(DATADIR)/ELSA_transition.dta $(ESTIMATION)/ELSA_transition.do
	cd FEM_Stata/Estimation && datain=$(DATADIR) && dataout=$(DATADIR) $(STATA) ELSA_transition.do

transitions_bmi:
	cd $(ESTIMATION) $(STATA) ELSA_bmi_trans.do

transitions_base: $(DATADIR)/ELSA_transition.dta $(ESTIMATION)/ELSA_init_transition.do
	cd $(ESTIMATION) && DATAIN=$(DATADIR) && dataout=$(DATADIR) && SUFFIX=ELSA $(STATA) ELSA_init_transition.do

transitions_CV: $(DATADIR)/ELSA_transition.dta $(ESTIMATION)/ELSA_init_transition.do 
	cd $(ESTIMATION) && DATAIN=$(DATADIR) && dataout=$(DATADIR) && SUFFIX=ELSA_CV $(STATA) ELSA_init_transition.do


### Estimates and Summary

estimates:
	cd $(ESTIMATION) && datain=$(ESTIMATES)/ELSA dataout=$(ROOT)/FEM_CPP_settings/ELSA/models $(STATA) save_est_cpp.do
	cd $(ESTIMATION) && datain=$(ESTIMATES)/HRS dataout=$(ROOT)/FEM_CPP_settings/hrs/models $(STATA) save_est_cpp.do
	cd $(ESTIMATION) && datain=$(ESTIMATES)/ELSA_bmi1 dataout=$(ROOT)/FEM_CPP_settings/ELSA_bmi1/models $(STATA) save_est_cpp.do
	cd $(ESTIMATION) && datain=$(ESTIMATES)/ELSA_bmi2 dataout=$(ROOT)/FEM_CPP_settings/ELSA_bmi2/models $(STATA) save_est_cpp.do

summary_out:
	cd FEM_CPP_settings && measures_suffix=ELSA $(STATA) summary_output_gen.do
	cd FEM_CPP_settings && measures_suffix=validate_ELSA $(STATA) summary_output_gen.do


### FEM Simulation

simulation:
	$(MPI) ELSA_example.settings.txt


### Handovers and Validation

handovers:
	cd analysis/techdoc_ELSA $(STATA) handover_ELSA.do

cross_validation: $(MAKEDATA)/ID_selection_CV.do $(MAKEDATA)/reshape_long_CV.do $(MAKEDATA)/gen_stock_CV.do $(MAKEDATA)/gen_transition_CV.do $(MAKEDATA)/reweight_ELSA_stock_CV.do $(ESTIMATION)/ELSA_transition_CV.do
	# ID selection, gen flags to split the population in half
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR)/cross_validation $(STATA) ID_selection_CV.do
	# Reshape original data 
	cd $(MAKEDATA) && datain=$(DATADIR)/cross_validation dataout=$(DATADIR)/cross_validation $(STATA) reshape_long_CV.do
	# Generate stock and transition populations from separate halves of the original data
	cd $(MAKEDATA) && datain=$(DATADIR)/cross_validation dataout=$(DATADIR)/cross_validation $(STATA) gen_stock_CV.do
	cd $(MAKEDATA) && datain=$(DATADIR)/cross_validation dataout=$(DATADIR)/cross_validation $(STATA) gen_transition_CV.do
	# Gen populations and reweight
	cd $(MAKEDATA) $(STATA) gen_pop_projections.do
	cd $(MAKEDATA) $(STATA) education_proj.do
	cd $(MAKEDATA) && scen=CV $(STATA) reweight_ELSA_stock_CV.do
	# Estimate transition models
	cd $(ESTIMATION) && datain=$(DATADIR)/cross_validation dataout=$(ESTIMATES)/ELSA/crossvalidation $(STATA) ELSA_transition_CV.do
	# Save transition models as .est files to be read by the model
	cd $(ESTIMATION) && datain=$(ESTIMATES)/ELSA/crossvalidation dataout=$(ROOT)/FEM_CPP_settings/ELSA_cross-validation/models $(STATA) save_est_cpp.do
	cd FEM_CPP_settings && measures_suffix=ELSA_CV $(STATA) summary_output_gen.do
	$(MPI) ELSA_cross-validation.settings.txt

minimal2: $(MAKEDATA)/ID_selection_CV.do $(MAKEDATA)/reshape_long_CV.do $(MAKEDATA)/gen_stock_CV.do $(MAKEDATA)/gen_transition_CV.do $(MAKEDATA)/reweight_ELSA_stock_CV.do $(ESTIMATION)/ELSA_transition_CV.do
	# ID selection, gen flags to split the population in half
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR)/cross_validation $(STATA) ID_selection_CV.do
	# Reshape original data 
	cd $(MAKEDATA) && datain=$(DATADIR)/cross_validation dataout=$(DATADIR)/cross_validation $(STATA) reshape_long_CV.do
	# Generate stock and transition populations from separate halves of the original data
	cd $(MAKEDATA) && datain=$(DATADIR)/cross_validation dataout=$(DATADIR)/cross_validation $(STATA) gen_stock_CV.do
	cd $(MAKEDATA) && datain=$(DATADIR)/cross_validation dataout=$(DATADIR)/cross_validation $(STATA) gen_transition_CV.do
	# Gen populations and reweight
	cd $(MAKEDATA) $(STATA) gen_pop_projections.do
	cd $(MAKEDATA) $(STATA) education_proj.do
	cd $(MAKEDATA) && scen=CV $(STATA) reweight_ELSA_stock_CV.do
	# Estimate transition models
	cd $(ESTIMATION) && datain=$(DATADIR)/cross_validation dataout=$(ESTIMATES)/ELSA/crossvalidation $(STATA) ELSA_transition_minimal.do
	# Save transition models as .est files to be read by the model
	cd $(ESTIMATION) && datain=$(ESTIMATES)/ELSA/crossvalidation dataout=$(ROOT)/FEM_CPP_settings/ELSA_cross-validation/models $(STATA) save_est_cpp.do
	cd FEM_CPP_settings && measures_suffix=ELSA_CV $(STATA) summary_output_gen.do
	$(MPI) ELSA_cross-validation.settings.txt


minimal:
	# Reshape original data 
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR) $(STATA) reshape_long.do
	# Generate stock and transition populations from separate halves of the original data
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR) $(STATA) generate_stock_pop.do
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR) $(STATA) generate_transition_pop.do
	# Gen populations and reweight
	cd $(MAKEDATA) $(STATA) gen_pop_projections.do
	cd $(MAKEDATA) $(STATA) education_proj.do
	cd $(MAKEDATA) && scen=base $(STATA) reweight_ELSA_stock.do
	# Estimate transition models
	cd $(ESTIMATION) && datain=$(DATADIR) dataout=$(ESTIMATES)/ELSA/minimal $(STATA) ELSA_transition_minimal.do
	# Save transition models as .est files to be read by the model
	cd $(ESTIMATION) && datain=$(ESTIMATES)/ELSA/minimal dataout=$(ROOT)/FEM_CPP_settings/ELSA_minimal/models $(STATA) save_est_cpp.do
	cd FEM_CPP_settings && measures_suffix=ELSA_minimal $(STATA) summary_output_gen.do
	$(MPI) ELSA_cross-validation.settings.txt

BMI_valid: 
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR)/validate $(STATA) BMI_impute_validate.do

BMI_valid2:
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR)/validate $(STATA) BMI_impute_validate2.do


### Housekeeping and cleaning

clean: clean_log clean_out

clean_log:
	rm -f *.log
	rm -f FEM_Stata/Makedata/ELSA/*.log

clean_out:
	rm -f output/*/*.dta
	rm -f output/*/*/*.dta
	rm -f output/*/*/*.csv
	rm -f output/*/*/*.txt
	rm -f output/graphs/*/*.png
