export ROOT=$(CURDIR)
DATADIR = $(CURDIR)/input_data
BASEDIR = $(CURDIR)/base_data
ESTIMATES = $(CURDIR)/FEM_Stata/Estimates
RAW_ELSA = /home/ld-archer/Documents/EFEM/UKDA-5050-stata/stata/stata11-se/

MAKEDATA = $(CURDIR)/FEM_Stata/Makedata/ELSA

include fem.makefile

STATA = $(CURDIR)/run.stata15.sh
PYTHON = python
RSCRIPT = Rscript


### Combined rules

ready_all: start_data transitions estimates summary_out

start_data: populations projections reweight

populations: ELSA_long.dta ELSA_stock_base.dta ELSA_repl_base.dta ELSA_transition.dta

### Populations

H_ELSA.dta: $(DATADIR)/ELSA_long.dta
	cd FEM_Stata/Makedata/ELSA && datain=$(RAW_ELSA) dataout=$(DATADIR) $(STATA) H_ELSA_long.do

ELSA_long.dta: $(DATADIR)/H_ELSA.dta $(MAKEDATA)/reshape_long.do
	cd FEM_Stata/Makedata/ELSA && datain=$(DATADIR) dataout=$(DATADIR) $(STATA) reshape_long.do

ELSA_stock_base.dta: $(DATADIR)/ELSA_long.dta
	cd FEM_Stata/Makedata/ELSA && datain=$(DATADIR) dataout=$(DATADIR) $(STATA) generate_stock_pop.do

ELSA_repl_base.dta: $(DATADIR)/ELSA_stock_base.dta
	cd FEM_Stata/Makedata/ELSA && datain=$(DATADIR) dataout=$(DATADIR) $(STATA) generate_replenishing_pop.do

ELSA_transition.dta: $(DATADIR)/ELSA_long.dta
	cd FEM_Stata/Makedata/ELSA && datain=$(DATADIR) dataout=$(DATADIR) $(STATA) generate_transition_pop.do

### Producing the reweighting data (pop. projection and education)

projections: $(DATADIR)/census_pop_estimates_02-18.csv $(DATADIR)/CT0469_2011census_educ.csv $(MAKEDATA)/gen_pop_projections.do $(MAKEDATA)/education_proj.do
	cd $(MAKEDATA) $(STATA) gen_pop_projections.do
	cd $(MAKEDATA) $(STATA) education_proj.do

### Reweighting

reweight: projections $(DATADIR)/ELSA_stock_base.dta $(DATADIR)/ELSA_repl_base.dta
	cd FEM_Stata/Makedata/ELSA && scen=base $(STATA) reweight_ELSA_stock.do
	cd FEM_Stata/Makedata/ELSA && scen=exercise1 $(STATA) reweight_ELSA_stock.do
	cd FEM_Stata/Makedata/ELSA && scen=drink $(STATA) reweight_ELSA_stock.do
	cd FEM_Stata/Makedata/ELSA && scen=drinkd_e $(STATA) reweight_ELSA_stock.do
	cd FEM_Stata/Makedata/ELSA && scen=smoken $(STATA) reweight_ELSA_stock.do
	cd FEM_Stata/Makedata/ELSA && scen=base $(STATA) reweight_ELSA_repl.do
	cd FEM_Stata/Makedata/ELSA && scen=exercise1 $(STATA) reweight_ELSA_repl.do
	cd FEM_Stata/Makedata/ELSA && scen=drink $(STATA) reweight_ELSA_repl.do
	cd FEM_Stata/Makedata/ELSA && scen=drinkd_e $(STATA) reweight_ELSA_repl.do
	cd FEM_Stata/Makedata/ELSA && scen=smoken $(STATA) reweight_ELSA_repl.do

### Transitions

transitions: $(DATADIR)/ELSA_transition.dta
	cd FEM_Stata/Estimation && datain=$(DATADIR) && dataout=$(DATADIR) $(STATA) ELSA_transition.do

transitions_bmi:
	cd FEM_Stata/Estimation $(STATA) ELSA_bmi_trans.do

### Estimates and Summary

estimates:
	cd FEM_Stata/Estimation && datain=$(ESTIMATES)/ELSA dataout=$(ROOT)/FEM_CPP_settings/ELSA/models $(STATA) save_est_cpp.do
	cd FEM_Stata/Estimation && datain=$(ESTIMATES)/HRS dataout=$(ROOT)/FEM_CPP_settings/hrs/models $(STATA) save_est_cpp.do
	cd FEM_Stata/Estimation && datain=$(ESTIMATES)/ELSA_bmi1 dataout=$(ROOT)/FEM_CPP_settings/ELSA_bmi1/models $(STATA) save_est_cpp.do
	cd FEM_Stata/Estimation && datain=$(ESTIMATES)/ELSA_bmi2 dataout=$(ROOT)/FEM_CPP_settings/ELSA_bmi2/models $(STATA) save_est_cpp.do

summary_out:
	cd FEM_CPP_settings && measures_suffix=ELSA $(STATA) summary_output_gen.do
	cd FEM_CPP_settings && measures_suffix=validate_ELSA $(STATA) summary_output_gen.do

### Handovers and Validation

handovers:
	cd analysis/techdoc_ELSA $(STATA) handover_ELSA.do

### Housekeeping and cleaning

clean:
	rm -r *.log