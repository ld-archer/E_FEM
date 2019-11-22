## MEPS Make Rules
MAX_MEPS_BREP := $(lastword $(sort ${N_HRS_MEPS_BREPS} ${N_PSID_MEPS_BREPS}))
## Note that the big dataset uses some wildcard expansion, so it many unnecessarily make if someone adds more data, but it should never not make when it should have.
$(DATADIR)/meps_mean_srh_agecat.dta: $(DATADIR)/MEPS_EQ5D.dta
$(DATADIR)/MEPS_EQ5D.dta: fem_env.do FEM_Stata/Makedata/MEPS/EQ5DScoringAlgorithm.do $(MEPS)/csd2001.ssp
	cd FEM_Stata/Makedata/MEPS && $(STATA) EQ5DScoringAlgorithm.do
$(DATADIR)/MEPS_cost_est.dta: fem_env.do FEM_Stata/Makedata/MEPS/meps_selected.do $(wildcard $(MEPS)/csd20*.ssp) $(wildcard $(MEPS)/condition20*.ssp) $(DATADIR)/meps_bootstrap_weights.dta
	cd FEM_Stata/Makedata/MEPS && $(STATA) meps_selected.do
$(DATADIR)/meps_bootstrap_weights.dta: fem_env.do FEM_Stata/Makedata/MEPS/meps_bootstrap_weights.do $(wildcard $(MEPS)/csd20*.ssp)
	cd FEM_Stata/Makedata/MEPS && MAXBREP=$(MAX_MEPS_BREP) $(STATA) meps_bootstrap_weights.do
$(DATADIR)/meps_drugs.dta: fem_env.do FEM_Stata/Makedata/MEPS/meps_drugs.do $(wildcard $(MEPS2)/h*.dta) $(FRED)/CPIMEDSL.csv
	cd FEM_Stata/Makedata/MEPS && $(STATA) meps_drugs.do
