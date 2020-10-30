export ROOT=$(CURDIR)
DATADIR = $(CURDIR)/input_data
BASEDIR = $(CURDIR)/base_data
ESTIMATES = $(CURDIR)/FEM_Stata/Estimates
ESTIMATION = $(CURDIR)/FEM_Stata/Estimation
RAW_ELSA = /home/luke/Documents/E_FEM/UKDA-5050-stata/stata/stata11_se
ANALYSIS = $(CURDIR)/analysis/techdoc_ELSA
MAKEDATA = $(CURDIR)/FEM_Stata/Makedata/ELSA

include fem.makefile

STATA = $(CURDIR)/run.stata16.sh
MPI = $(CURDIR)/run.mpi.sh
PYTHON = python
RSCRIPT = Rscript


### Model runs

complete: base cross-validation minimal

old: start_data transitions estimates summary_out

base: start_data transitions_base est_base summary_out_base simulation_base

cross-validation: start_data transitions_CV est_CV summary_out_CV simulation_CV Ttests

minimal: start_data transitions_minimal est_minimal summary_out_minimal


### Combined rules

start_data: populations projections reweight

transitions_est_base: transitions_base est_base summary_out_base


### Populations

ELSA: $(DATADIR)/H_ELSA_f_2002-2016.dta

populations: $(DATADIR)/cross_validation/crossvalidation.dta $(DATADIR)/ELSA_long.dta $(DATADIR)/ELSA_stock_base.dta $(DATADIR)/ELSA_repl_base.dta $(DATADIR)/ELSA_transition.dta

$(DATADIR)/ELSA_long_imputed.dta: $(MAKEDATA)/reshape_long_new.do $(DATADIR)/H_ELSA_f_2002-2016.dta 
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR) $(STATA) reshape_long_new.do

$(DATADIR)/H_ELSA_f_2002-2016.dta: $(MAKEDATA)/H_ELSA_long.do
	cd $(MAKEDATA) && datain=$(RAW_ELSA) dataout=$(DATADIR) $(STATA) H_ELSA_long.do
	
$(DATADIR)/cross_validation/crossvalidation.dta: $(MAKEDATA)/ID_selection_CV.do 
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR)/cross_validation $(STATA) ID_selection_CV.do

$(DATADIR)/ELSA_long.dta: $(MAKEDATA)/reshape_long.do ELSA
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR) $(STATA) reshape_long.do

$(DATADIR)/ELSA_stock_base.dta: $(DATADIR)/ELSA_long.dta $(MAKEDATA)/generate_stock_pop.do $(MAKEDATA)/kludge.do
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR) $(STATA) generate_stock_pop.do

$(DATADIR)/ELSA_repl_base.dta: $(DATADIR)/ELSA_stock_base.dta $(MAKEDATA)/generate_replenishing_pop.do $(MAKEDATA)/kludge.do
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR) $(STATA) generate_replenishing_pop.do

$(DATADIR)/ELSA_transition.dta: $(DATADIR)/ELSA_long.dta $(MAKEDATA)/generate_transition_pop.do
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR) $(STATA) generate_transition_pop.do


### Producing the reweighting data (pop. projection and education)

projections: $(DATADIR)/pop_projections.dta $(DATADIR)/education_data.dta

$(DATADIR)/pop_projections.dta: $(DATADIR)/census_pop_estimates_02-18.csv $(MAKEDATA)/gen_pop_projections.do
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR) $(STATA) gen_pop_projections.do

$(DATADIR)/education_data.dta: $(DATADIR)/CT0469_2011census_educ.csv $(MAKEDATA)/education_proj.do
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR) $(STATA) education_proj.do


### Reweighting

reweight: $(DATADIR)/ELSA_stock.dta $(DATADIR)/ELSA_stock_CV.dta $(DATADIR)/ELSA_repl.dta $(DATADIR)/ELSA_stock_nosmoke.dta $(DATADIR)/ELSA_stock_nodrink.dta $(DATADIR)/ELSA_repl_nosmoke.dta $(DATADIR)/ELSA_repl_nodrink.dta $(DATADIR)/ELSA_stock_noImpute.dta

$(DATADIR)/ELSA_stock.dta: $(DATADIR)/ELSA_stock_base.dta $(DATADIR)/pop_projections.dta $(MAKEDATA)/reweight_ELSA_stock.do
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR) scen=base $(STATA) reweight_ELSA_stock.do

$(DATADIR)/ELSA_stock_CV.dta: $(DATADIR)/ELSA_stock_base_CV.dta $(DATADIR)/pop_projections.dta $(MAKEDATA)/reweight_ELSA_stock.do
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR) scen=base_CV $(STATA) reweight_ELSA_stock.do

$(DATADIR)/ELSA_stock_nosmoke.dta: $(DATADIR)/ELSA_stock_base_nosmoke.dta $(DATADIR)/pop_projections.dta $(MAKEDATA)/reweight_ELSA_stock.do
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR) scen=base_nosmoke $(STATA) reweight_ELSA_stock.do

$(DATADIR)/ELSA_stock_nodrink.dta: $(DATADIR)/ELSA_stock_base_nodrink.dta $(DATADIR)/pop_projections.dta $(MAKEDATA)/reweight_ELSA_stock.do
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR) scen=base_nodrink $(STATA) reweight_ELSA_stock.do

$(DATADIR)/ELSA_repl.dta: $(DATADIR)/ELSA_repl_base.dta $(DATADIR)/pop_projections.dta $(DATADIR)/education_data.dta $(MAKEDATA)/reweight_ELSA_repl.do
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR) scen=base $(STATA) reweight_ELSA_repl.do

$(DATADIR)/ELSA_repl_nosmoke.dta: $(DATADIR)/ELSA_repl_base.dta $(DATADIR)/pop_projections.dta $(DATADIR)/education_data.dta $(MAKEDATA)/reweight_ELSA_repl.do
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR) scen=base_nosmoke $(STATA) reweight_ELSA_repl.do

$(DATADIR)/ELSA_repl_nodrink.dta: $(DATADIR)/ELSA_repl_base.dta $(DATADIR)/pop_projections.dta $(DATADIR)/education_data.dta $(MAKEDATA)/reweight_ELSA_repl.do
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR) scen=base_nodrink $(STATA) reweight_ELSA_repl.do

$(DATADIR)/ELSA_stock_noImpute.dta: $(DATADIR)/ELSA_stock_base_noImpute.dta $(DATADIR)/pop_projections.dta $(MAKEDATA)/reweight_ELSA_stock.do
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR) scen=base_noImpute $(STATA) reweight_ELSA_stock.do


### Transitions

transitions: $(DATADIR)/ELSA_transition.dta $(ESTIMATION)/ELSA_transition.do
	cd FEM_Stata/Estimation && datain=$(DATADIR) && dataout=$(DATADIR) $(STATA) ELSA_transition.do

transitions_bmi:
	cd $(ESTIMATION) $(STATA) ELSA_bmi_trans.do

transitions_base: $(DATADIR)/ELSA_transition.dta $(ESTIMATION)/ELSA_init_transition.do $(ESTIMATION)/ELSA_covariate_definitionsELSA.do
	cd $(ESTIMATION) && DATAIN=$(DATADIR) && dataout=$(DATADIR) && SUFFIX=ELSA $(STATA) ELSA_init_transition.do

transitions_CV: $(DATADIR)/ELSA_transition.dta $(ESTIMATION)/ELSA_init_transition.do $(ESTIMATION)/ELSA_covariate_definitionsELSA.do
	cd $(ESTIMATION) && DATAIN=$(DATADIR) && dataout=$(DATADIR) && SUFFIX=CV $(STATA) ELSA_init_transition.do

transitions_minimal: $(DATADIR)/ELSA_transition.dta $(ESTIMATION)/ELSA_init_transition.do $(ESTIMATION)/ELSA_covariate_definitionsminimal.do
	cd $(ESTIMATION) && DATAIN=$(DATADIR) && dataout=$(DATADIR) && SUFFIX=ELSA_minimal $(STATA) ELSA_init_transition.do


### Estimates and Summary

estimates:
	cd $(ESTIMATION) && datain=$(ESTIMATES)/ELSA dataout=$(ROOT)/FEM_CPP_settings/ELSA/models $(STATA) save_est_cpp.do
	cd $(ESTIMATION) && datain=$(ESTIMATES)/HRS dataout=$(ROOT)/FEM_CPP_settings/hrs/models $(STATA) save_est_cpp.do
	cd $(ESTIMATION) && datain=$(ESTIMATES)/ELSA_bmi1 dataout=$(ROOT)/FEM_CPP_settings/ELSA_bmi1/models $(STATA) save_est_cpp.do
	cd $(ESTIMATION) && datain=$(ESTIMATES)/ELSA_bmi2 dataout=$(ROOT)/FEM_CPP_settings/ELSA_bmi2/models $(STATA) save_est_cpp.do
	cd $(ESTIMATION) && datain=$(ESTIMATES)/ELSA/crossvalidation dataout=$(ROOT)/FEM_CPP_settings/ELSA_cross-validation/models $(STATA) save_est_cpp.do
	cd $(ESTIMATION) && datain=$(ESTIMATES)/ELSA_minimal dataout=$(ROOT)/FEM_CPP_settings/ELSA_minimal/models $(STATA) save_est_cpp.do

est_base:
	cd $(ESTIMATION) && datain=$(ESTIMATES)/ELSA dataout=$(ROOT)/FEM_CPP_settings/ELSA/models $(STATA) save_est_cpp.do
	cd $(ESTIMATION) && datain=$(ESTIMATES)/HRS dataout=$(ROOT)/FEM_CPP_settings/hrs/models $(STATA) save_est_cpp.do

est_CV: 
	cd $(ESTIMATION) && datain=$(ESTIMATES)/ELSA/crossvalidation dataout=$(ROOT)/FEM_CPP_settings/ELSA_cross-validation/models $(STATA) save_est_cpp.do

est_minimal:
	cd $(ESTIMATION) && datain=$(ESTIMATES)/ELSA_minimal dataout=$(ROOT)/FEM_CPP_settings/ELSA_minimal/models $(STATA) save_est_cpp.do

summary_out:
	cd FEM_CPP_settings && measures_suffix=ELSA $(STATA) summary_output_gen.do
	cd FEM_CPP_settings && measures_suffix=validate_ELSA $(STATA) summary_output_gen.do
	cd FEM_CPP_settings && measures_suffix=ELSA_CV $(STATA) summary_output_gen.do
	cd FEM_CPP_settings && measures_suffix=ELSA_minimal $(STATA) summary_output_gen.do

summary_out_base:
	cd FEM_CPP_settings && measures_suffix=ELSA $(STATA) summary_output_gen.do

summary_out_CV:
	cd FEM_CPP_settings && measures_suffix=ELSA_CV $(STATA) summary_output_gen.do

summary_out_minimal:
	cd FEM_CPP_settings && measures_suffix=ELSA_minimal $(STATA) summary_output_gen.do


### FEM Simulation

simulation_base:
	$(MPI) ELSA_example.settings.txt

simulation_CV:
	$(MPI) ELSA_cross-validation.settings.txt


### Handovers and Validation

handovers:
	cd analysis/techdoc_ELSA $(STATA) handover_ELSA.do

BMI_valid: 
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR)/validate $(STATA) BMI_impute_validate.do

BMI_valid2:
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR)/validate $(STATA) BMI_impute_validate2.do

Ttests: 
	cd $(ANALYSIS) && datain=$(DATADIR) dataout=$(ROOT)/output/ $(STATA) crossvalidation_ELSA.do


### 

detailed_append:
	cd $(MAKEDATA) && datain=$(DATADIR) dataout=$(DATADIR)/detailed_output $(STATA) detailed_output_append.do


### Housekeeping and cleaning

clean: clean_log clean_out

clean_log:
	rm -f *.log
	rm -f FEM_Stata/Makedata/ELSA/*.log
	rm -f FEM_Stata/Estimation/*.log

clean_out:
	rm -f output/*/*.dta
	rm -f output/*/*/*.dta
	rm -f output/*/*/*.csv
	rm -f output/*/*/*.txt
	rm -f output/graphs/*/*.png

