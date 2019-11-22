# These are our main configuration variables, like where data are stored
export ROOT=$(CURDIR)/../..
DATADIR = $(ROOT)/input_data
BASEDIR = $(ROOT)/base_data
ESTIMATES = $(ROOT)/FEM_Stata/Estimates
RESTIMATES = $(ESTIMATES)/restrictedvars

include ../../locale.makefile

STATA = $(ROOT)/run.stata13.sh 

chf_summary.dta: $(DATADIR)/nhanes.dta $(DATADIR)/hrs_analytic_recoded.dta gen_chf_summaries.do $(DATADIR)/hrs19_transition.dta ../../output/chfe_full_model/chfe_full_model_summary.dta ../../output/chfe_cons_model/chfe_cons_model_summary.dta
	$(STATA) gen_chf_summaries.do

Rplots.dta: chf_summary.dta plot_chf_summary.R
	Rscript plot_chf_summary.R

plots: Rplots.dta

