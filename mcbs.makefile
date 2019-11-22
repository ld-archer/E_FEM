## MCBS Make Rules
MAX_MCBS_BREP := $(lastword $(sort ${N_HRS_MCBS_BREPS} ${N_PSID_MCBS_BREPS}))
$(MCBSDIR)/mcbs_bootstrap_weights.dta: FEM_Stata/Makedata/MCBS/mcbs_bootstrap_weights.do fem_env.do $(MCBSRESTRICT)/mcbs9212.dta 
	cd FEM_Stata/Makedata/MCBS && MAXBREP=$(MAX_MCBS_BREP) $(STATA) mcbs_bootstrap_weights.do
$(MCBSDIR)/mcbs_cost_est.dta: FEM_Stata/Makedata/MCBS/mcbs_cost_select.do fem_env.do $(FRED)/CPIMEDSL.csv $(MCBSRESTRICT)/mcbs9212.dta $(MCBSDIR)/mcbs_bootstrap_weights.dta
	cd FEM_Stata/Makedata/MCBS && $(STATA) mcbs_cost_select.do
$(MCBSDIR)/mcbs_drugs.dta: fem_env.do FEM_Stata/Makedata/MCBS/mcbs_drugs.do $(FRED)/CPIMEDSL.csv $(wildcard $(MCBSRESTRICT)/rics/ricpme*.dta) $(wildcard $(MCBSRESTRICT)/mcbs*/rics_cleaned/ricpme_c*.dta)
	cd FEM_Stata/Makedata/MCBS && $(STATA) mcbs_drugs.do
