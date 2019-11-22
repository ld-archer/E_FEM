.DELETE_ON_ERROR: 

.PHONY: doc appendix psid_appendix fam_viz fem_viz meps mcbs nhis cps nhanes acs pop hrs psid trends_psid joint_psid ox estimation etimate_psid estimate_psid_minimal claims bootstrap bootstrap_nested psid_bs_test estimation_bootstrap estimation_bootstrapmed estimate_psid_bootstrap estimation_psid_bootstrapmed di ss brfss migration_core migration_all taxsim estimate_cpp estimation_cpp

## Documentation
doc: doc/html/index.html
appendix: analysis/techdoc/latex/FEM/FEM_techdoc.pdf
psid_appendix: analysis/techdoc/latex/FAM/FAM_techdoc.pdf
fam_viz: analysis/graphviz/FAM/png/predictors/Work_category_t.png
fem_viz: analysis/graphviz/FEM/png/predictors/Wealth_tplus1.png

## Datasets
meps: $(DATADIR)/MEPS_EQ5D.dta $(DATADIR)/meps_mean_srh_agecat.dta $(DATADIR)/MEPS_cost_est.dta $(DATADIR)/meps_drugs.dta
mcbs: $(MCBSDIR)/mcbs_bootstrap_weights.dta $(MCBSDIR) $(MCBSDIR)/mcbs_cost_est.dta $(MCBSDIR)/mcbs_drugs.dta
nhis: $(DATADIR)/pred5152.dta
cps: $(DATADIR)/trend_educ.dta $(DATADIR)/cps2009_demog.dta
nhanes: $(DATADIR)/nhanes.dta $(DATADIR)/nhanes_bmi.dta $(DATADIR)/NHANES_bmi_cohort_qtls.dta $(DATADIR)/obs80_adjustments.dta $(DATADIR)/obs80_adj_table.dta $(DATADIR)/obesity_projections_4656.dta
acs: $(DATADIR)/acs2009_demog.dta
pop: $(DATADIR)/pop5152_projection.dta $(DATADIR)/death_counts.dta $(DATADIR)/pop5152_projection_2150.dta $(DATADIR)/immigration_projection.dta $(DATADIR)/immigration_estimates.dta $(DATADIR)/trend_all_status_quo.dta
hrs: $(DATADIR)/new51s_status_quo.dta $(DATADIR)/stock_hrs_2004.dta $(DATADIR)/crossvalidation.dta $(DATADIR)/stock_hrs_1998.dta $(DATADIR)/stock_hrs_2010.dta $(DATADIR)/nh_weights.dta $(DATADIR)/exit_alzhe2010.dta
psid: $(DATADIR)/psid_transition.dta	$(DATADIR)/psid_transition_51plus.dta $(DATADIR)/stock_psid_2009.dta $(DATADIR)/stock_psid_2009_51plus.dta $(DATADIR)/age2530_psid1999.dta $(DATADIR)/age2530_psid2009.dta $(DATADIR)/age2526_psid0709.dta $(DATADIR)/new25s_notrend.dta  $(DATADIR)/new25s_default.dta $(DATADIR)/stock_psid_1999.dta
trends_psid: $(DATADIR)/psid_trend_default.dta
joint_psid: $(DATADIR)/psid_incoming_cut_points.dta

## Executables
ox: $(OX_OUT)

## Statistical Models
estimation: $(ESTIMHRS)/qaly.xls $(ESTIMHRS)/estimatesHRS.xls $(ESTIMHRS)/ghregHRS.xls $(ESTIMHRS)/mcare_ptd.xls $(ESTIMHRS)/mcareb_init.xls $(ESTIMHRS)/mcare_takeup.xls $(ESTIMHRS)/cost_est_mcbs.xls $(ESTIMHRS)/cost_est_meps.xls $(ESTIMHRS)/cogstate_stock.xls $(ESTIMATES)/minimal/estimatesminimal.xls $(ESTIMATES)/nofvars/estimatesnofvars.xls
estimate_psid: $(ESTIMATES)/PSID/died.ster $(ESTIMATES)/PSID/hatota.ster $(ESTIMATES)/PSID/psid_cost_est_meps.txt $(ESTIMATES)/PSID/lniearn_nl.ster $(ESTIMATES)/PSID/psid_cost_est_mcbs.txt $(ESTIMATES)/PSID/qaly.ster $(ESTIMATES)/PSID/mcareb_init.xls $(ESTIMATES)/PSID/mcare_ptd.xls $(ESTIMATES)/PSID/mcare_takeup.xls
estimate_psid_minimal: $(ESTIMATES)/PSID/minimal/lniearn_nl.ster $(ESTIMATES)/PSID/minimal/died.ster $(ESTIMATES)/PSID/minimal/hatota.ster 
claims: $(ESTIMATES)/nvaf/claims.xls


## Bootstrapped Data
bootstrap: $(DATADIR)/hhidb.dta bootstrap_directories.txt FEM_Stata/Makedata/HRS/bootstrap_sample_IDs.txt new51_dependency.txt new51_dependency_bstrend.txt new51_dependency_input_bstrend.txt FEM_Stata/Makedata/HRS/bootstrap_samples.txt ${BTARGET} ${BTARGET2} ${BTARGET3}
bootstrap_nested: bootstrap_directories_nested.txt
psid_bs_test: $(DATADIR)/input_rep1/psid_transition.dta $(DATADIR)/input_rep2/psid_transition.dta $(DATADIR)/input_rep3/psid_transition.dta $(DATADIR)/input_rep4/psid_transition.dta $(DATADIR)/input_rep5/psid_transition.dta

## Bootstrapped Models
estimation_bootstrap:bootstrap_directories.txt FEM_Stata/Makedata/HRS/bootstrap_estimates.txt
estimation_bootstrapmed: bootstrap_directories.txt FEM_Stata/Makedata/HRS/bootstrap_mcbs_estimates.txt 
estimate_psid_bootstrap:FEM_Stata/Makedata/PSID/bootstrap_estimates.txt
estimation_psid_bootstrapmed: FEM_Stata/Makedata/PSID/bootstrap_mcbs_estimates.txt 

## Other
di: $(DATADIR)/ssa_diclaim.dta
ss: $(DATADIR)/ssa_ssclaim.dta
brfss: $(DATADIR)/brfss.dta

## Builds that create datasets, est files, and compile FEM (note: these do not estimate transition models)
hrs_core: FEM $(DATADIR)/stock_hrs_2010.dta $(DATADIR)/new51s_status_quo.dta estimation_cpp
psid_core: FEM $(DATADIR)/stock_psid_2009.dta $(DATADIR)/new25s_default.dta estimate_cpp
