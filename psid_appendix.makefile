# Tables for PSID technical appendix.  See "FAM Technical Appendix Outline" for full details

DOCDIR = $(CURDIR)/analysis/techdoc/latex/FAM
TABLEDIR = $(CURDIR)/analysis/techdoc/latex/tables/FAM

analysis/techdoc/latex/FAM/FAM_techdoc.pdf: $(TABLEDIR)/table2_1.csv $(TABLEDIR)/estimates_FAM.xml $(TABLEDIR)/earnings_estimates_psid.xml $(TABLEDIR)/PSID_ghreg_estimates.xml $(TABLEDIR)/cost_est_meps.xls $(TABLEDIR)/cost_est_mcbs.xml $(TABLEDIR)/table9_1.csv $(TABLEDIR)/crossval_unweighted.tex $(TABLEDIR)/external_pop.tex $(TABLEDIR)/latent_model_mean_est.tex $(TABLEDIR)/latent_model_vcmat_est.tex $(TABLEDIR)/new_cohort_trends_health.tex $(TABLEDIR)/svy_disease_prevalence.tex

# Section 1 - Summary stats comparing data sources
# Summary stats of PSID, HRS, NHIS, MEPS, MCBS, NHANES with question wording

## targets for building tables for FAM technical appendix
$(TABLEDIR)/svy_disease_prevalence.tex: fem_env.do analysis/techdoc/latex/tables/FAM/table_svy_disease_prevalence.do $(DATADIR)/hrs_analytic_recoded.dta $(DATADIR)/MEPS_cost_est.dta $(DATADIR)/nhis97plus_selected.dta $(MCBSDIR)/mcbs_cost_est.dta $(DATADIR)/psid_analytic.dta
	cd analysis/techdoc/latex/tables/FAM && $(STATA) table_svy_disease_prevalence.do

# Section 2 - Estimation sample statistics
$(TABLEDIR)/table2_1.csv: fem_env.do $(TABLEDIR)/table2_1.do $(DATADIR)/psid_transition.dta
	cd $(TABLEDIR)/ && $(STATA) table2_1.do

# Section 3 - Transition model schematic - probably not a Stata file	

# Section 4 - Transition models - export models to nice looking tables
$(TABLEDIR)/estimates_FAM.xml: 
	cd FEM_Stata/Estimates/PSID/ && cp estimates_psid.xml $@
$(TABLEDIR)/earnings_estimates_psid.xml: 
	cd FEM_Stata/Estimates/PSID/ && cp earnings_estimates_psid.xml $(TABLEDIR)/earnings_estimates_psid.xml
$(TABLEDIR)/PSID_ghreg_estimates.xml: 
	cd FEM_Stata/Estimates/PSID/ && cp PSID_ghreg_estimates.xml $(TABLEDIR)/PSID_ghreg_estimates.xml


# Section 5 - Cost models - export models to nice looking tables
$(TABLEDIR)/cost_est_meps.xls: FEM_Stata/Estimates/PSID/cost_est_meps.xls
	cd FEM_Stata/Estimates/PSID/ && cp cost_est_meps.xls $(TABLEDIR)/cost_est_meps.xls
$(TABLEDIR)/cost_est_mcbs.xml: FEM_Stata/Estimates/PSID/cost_est_mcbs.xml
	cd FEM_Stata/Estimates/PSID/ && cp cost_est_mcbs.xml $(TABLEDIR)/cost_est_mcbs.xml

# Section 6 - New cohort models, variance covariance matrix
$(TABLEDIR)/latent_model_mean_est.tex: $(TABLEDIR)/table_latent_model_mean_est.do $(DATADIR)/psid_incoming_means.dta $(DATADIR)/psid_transition.dta
	cd $(TABLEDIR) && $(STATA) table_latent_model_mean_est.do
$(TABLEDIR)/latent_model_vcmat_est.tex: $(TABLEDIR)/table_latent_model_vcmat_est.do $(DATADIR)/psid_incoming_vcmatrix.dta $(TABLEDIR)/initcond_labels.csv
	cd $(TABLEDIR) && $(STATA) table_latent_model_vcmat_est.do


# Section 7 - Trends for new cohorts
$(TABLEDIR)/new_cohort_trends_educ.tex $(TABLEDIR)/new_cohort_trends_social.tex: $(TABLEDIR)/new_cohort_trends_health.tex
$(TABLEDIR)/new_cohort_trends_health.tex: $(TABLEDIR)/table_new_cohort_trends.do $(DATADIR)/psid_trend_default.dta
	cd $(TABLEDIR) && $(STATA) table_new_cohort_trends.do


# Section 8 - NHEA calibration of medical costs

# Section 9 - Stats for stock population
$(TABLEDIR)/table9_1.csv: fem_env.do $(TABLEDIR)/table9_1.do $(DATADIR)/stock_psid_2009.dta
	cd $(TABLEDIR) && $(STATA) table9_1.do

# Section 12 - Crossvalidation (1999 through 2013)
output/psid_crossvalidation/psid_crossvalidation_summary.dta: psid_crossvalidation.settings.txt psid_crossvalidation.csv $(DATADIR)/stock_psid_1999.dta FEM
	mpiexec -n 10 ./FEM psid_crossvalidation.settings.txt
$(TABLEDIR)/crossval_binhlth.tex $(TABLEDIR)/crossval_risk.tex $(TABLEDIR)/crossval_binecon.tex $(TABLEDIR)/crossval_cntecon.tex $(TABLEDIR)/crossval_demog.tex: $(TABLEDIR)/crossval_unweighted.tex
$(TABLEDIR)/crossval_unweighted.tex: fem_env.do $(TABLEDIR)/table12_1.do $(DATADIR)/stock_psid_1999.dta $(DATADIR)/psid_analytic.dta output/psid_crossvalidation/psid_crossvalidation_summary.dta
	cd $(TABLEDIR) && $(STATA) table12_1.do

# Section 10 - Internal verification and validation	(full population simulations)
# Population forecasts
$(TABLEDIR)/external_pop.tex: fem_env.do $(TABLEDIR)/table10_1.do output/psid_baseline/psid_baseline_summary.dta output/psid_minimal/psid_minimal_summary.dta
	cd $(TABLEDIR) && $(STATA) table10_1.do

# Disease Prevalence	
analysis/psid_techdoc/table10_2.csv: fem_env.do analysis/psid_techdoc/table10_2.do output/psid_baseline/psid_baseline_summary.dta
	cd analysis/psid_techdoc && $(STATA) table10_2.do
# Obesity Prevalence
analysis/psid_techdoc/table10_3.csv: fem_env.do analysis/psid_techdoc/table10_3.do output/psid_baseline/psid_baseline_summary.dta
	cd analysis/psid_techdoc && $(STATA) table10_3.do	
# ADL/IADL Prevalence 	
analysis/psid_techdoc/table10_4.csv: fem_env.do analysis/psid_techdoc/table10_4.do output/psid_baseline/psid_baseline_summary.dta
	cd analysis/psid_techdoc && $(STATA) table10_4.do	
#	Work status (unemployment rate, labor force participation)
analysis/psid_techdoc/table10_5.csv: fem_env.do analysis/psid_techdoc/table10_5.do output/psid_baseline/psid_baseline_summary.dta
	cd analysis/psid_techdoc && $(STATA) table10_5.do	
#	Marriages (***INCOMPLETE***)
analysis/psid_techdoc/table10_6.csv: fem_env.do analysis/psid_techdoc/table10_6.do output/psid_baseline/psid_baseline_summary.dta
	cd analysis/psid_techdoc && $(STATA) table10_6.do	
# Childbearing (***INCOMPLETE***)
analysis/psid_techdoc/table10_7.csv: fem_env.do analysis/psid_techdoc/table10_7.do output/psid_baseline/psid_baseline_summary.dta
	cd analysis/psid_techdoc && $(STATA) table10_7.do	
# Education
analysis/psid_techdoc/table10_8.csv: fem_env.do analysis/psid_techdoc/table10_8.do output/psid_baseline/psid_baseline_summary.dta
	cd analysis/psid_techdoc && $(STATA) table10_8.do	
#	Earnings, wealth
analysis/psid_techdoc/table10_9.csv: fem_env.do analysis/psid_techdoc/table10_9.do output/psid_baseline/psid_baseline_summary.dta
	cd analysis/psid_techdoc && $(STATA) table10_9.do	
#	Program participation (ss, ssi, di, etc.) 
analysis/psid_techdoc/table10_10.csv: fem_env.do analysis/psid_techdoc/table10_10.do output/psid_baseline/psid_baseline_summary.dta
	cd analysis/psid_techdoc && $(STATA) table10_10.do	
# Health insurance 
analysis/psid_techdoc/table10_11.csv: fem_env.do analysis/psid_techdoc/table10_11.do output/psid_baseline/psid_baseline_summary.dta
	cd analysis/psid_techdoc && $(STATA) table10_11.do	
# Medicaid and Medicare enrollment
analysis/psid_techdoc/table10_12.csv: fem_env.do analysis/psid_techdoc/table10_12.do output/psid_baseline/psid_baseline_summary.dta
	cd analysis/psid_techdoc && $(STATA) table10_12.do	
#	Average Medical costs
analysis/psid_techdoc/table10_13.csv: fem_env.do analysis/psid_techdoc/table10_13.do output/psid_baseline/psid_baseline_summary.dta
	cd analysis/psid_techdoc && $(STATA) table10_13.do	
# Total Medical costs
analysis/psid_techdoc/table10_14.csv: fem_env.do analysis/psid_techdoc/table10_14.do output/psid_baseline/psid_baseline_summary.dta
	cd analysis/psid_techdoc && $(STATA) table10_14.do	
# 2009 Insurance coverage PSID vs MEPS
analysis/psid_techdoc/table10_15.csv: fem_env.do analysis/psid_techdoc/table10_15.do $(DATADIR)/psid_analytic.dta $(DATADIR)/MEPS_cost_est.dta
	cd analysis/psid_techdoc && $(STATA) table10_15.do	
# Smoking status	
analysis/psid_techdoc/table10_16.csv: fem_env.do analysis/psid_techdoc/table10_16.do output/psid_baseline/psid_baseline_summary.dta
	cd analysis/psid_techdoc && $(STATA) table10_16.do	

# Section 11 - cohort simulation showing lifecourse for 2009 (compare to 2029?)


# Section 13 - External Validation


# Baseline forecasts
analysis/techdoc/latex/FAM/img/chronic_diseases_male.pdf analysis/techdoc/latex/FAM/img/chronic_diseases_female.pdf analysis/techdoc/latex/FAM/img/adl_iadl_male.pdf: analysis/techdoc/latex/FAM/img/adl_iadl_female.pdf
analysis/techdoc/latex/FAM/img/adl_iadl_female.pdf: analysis/techdoc/latex/tables/FAM/handover.do output/psid_baseline/psid_baseline_summary.dta
	cd analysis/techdoc/latex/tables/FAM && $(STATA) handover.do

FAM_TRANS_OUTCOME_TYPES := disease smoking logbmi adlstat iadlstat work lfpben mstat birth financial
FAM_TRANS_OUTCOME_LABROWS := $(addsuffix _lblrows.csv, $(addprefix analysis/techdoc/latex/tables/FAM/transitioned_outcomes_,${FAM_TRANS_OUTCOME_TYPES}))
FAM_TRANS_OUTCOME_SUBTABS := $(addsuffix .tex, $(addprefix analysis/techdoc/latex/tables/FAM/transitioned_outcomes_,${FAM_TRANS_OUTCOME_TYPES}))
$(FAM_TRANS_OUTCOME_SUBTABS): $(ROOT)/input_data/psid_transition.dta $(FAM_TRANS_OUTCOME_LABROWS) analysis/techdoc/latex/tables/FAM/table_transitioned_outcomes.do
	cd analysis/techdoc/latex/tables/FAM && $(STATA) table_transitioned_outcomes.do
analysis/techdoc/latex/tables/FAM/controlvar_descs.tex: $(DATADIR)/stock_psid_2009.dta analysis/techdoc/latex/tables/FAM/table_controlvar_descs.do
	cd analysis/techdoc/latex/tables/FAM && $(STATA) table_controlvar_descs.do
#FAM_INIT_COND_TYPES := binary bmistat smoking funcstat continuous censcont censdiscrete earlyagedb normalagedb covars
#FAM_INIT_COND_LABROWS := $(addsuffix _lblrows.csv, $(addprefix analysis/techdoc/latex/tables/FAM/desc_init_conditions_,${FAM_INIT_COND_TYPES}))
#FAM_INIT_COND_SUBTABS := $(addsuffix .tex, $(addprefix analysis/techdoc/latex/tables/FAM/desc_init_conditions_,${FAM_INIT_COND_TYPES}))
#$(FAM_INIT_COND_SUBTABS): $(ROOT)/input_data/new51s_status_quo.dta $(HRSDIR)/age5055_hrs1992r.dta $(FAM_INIT_COND_LABROWS) analysis/techdoc/latex/tables/FAM/table_desc_init_conditions.do
#	cd analysis/techdoc/latex/tables/FAM && $(STATA) table_desc_init_conditions.do


# We don't use either of these at present ... analysis/techdoc/latex/tables/FAM/time_series_by_year.tex analysis/techdoc/latex/tables/FAM/time_series_by_yob.tex
FAM_TEX_TABLES := $(TABLEDIR)/svy_disease_prevalence.tex $(FAM_TRANS_OUTCOME_SUBTABS) analysis/techdoc/latex/tables/FAM/controlvar_descs.tex $(FAM_INIT_COND_SUBTABS) $(TABLEDIR)/latent_model_mean_est.tex $(TABLEDIR)/latent_model_vcmat_est.tex 


## targets for building LaTeX FAM technical appendix .pdf file
FAM_SECT_DYNAMIC_MODEL := analysis/techdoc/latex/FAM/dynamic_model.tex analysis/techdoc/latex/FAM/dynamic_model_overview.tex analysis/techdoc/latex/shared/dynamic_model_background.tex analysis/techdoc/latex/FAM/dynamic_model_comparison_with_other_microsims.tex  analysis/techdoc/latex/FAM/img/fam_architecture.png
FAM_SECT_DATA_SOURCES_ESTIMATION := analysis/techdoc/latex/FAM/data_sources_estimation.tex analysis/techdoc/latex/FAM/data_sources_estimation_hrs.tex analysis/techdoc/latex/FAM/data_sources_estimation_meps.tex analysis/techdoc/latex/FAM/data_sources_estimation_nhis.tex analysis/techdoc/latex/FAM/data_sources_estimation_mcbs.tex 
#FAM_SECT_DATA_SOURCES_TRENDS_AND_BASELINE := analysis/techdoc/latex/FAM/data_sources_trends_and_baseline.tex analysis/techdoc/latex/FAM/data_sources_trends_and_baseline_demographic_projections.tex analysis/techdoc/latex/FAM/data_sources_trends_and_baseline_entering_cohorts.tex analysis/techdoc/latex/FAM/data_sources_trends_and_baseline_other_projections.tex
FAM_SECT_ESTIMATION := analysis/techdoc/latex/FAM/estimation.tex analysis/techdoc/latex/FAM/estimation_transition_model.tex 
FAM_SECT_GOVT_REVENUE_AND_EXPENDITURES := analysis/techdoc/latex/FAM/govt_revenue_and_expenditures.tex analysis/techdoc/latex/FAM/govt_revenue_and_expenditures_medcost_estimation.tex
FAM_SECT_IMPLEMENTATION :- analysis/techdoc/latex/FAM/implementation.tex analysis/techdoc/latex/FAM/implementation_interventions.tex
FAM_SECT_FAM_TABLES := analysis/techdoc/latex/FAM/FAM_tables.tex $(FAM_TEX_TABLES)
FAM_SECT_BASELINE_FORECASTS := analysis/techdoc/latex/FAM/baseline_forecasts.tex analysis/techdoc/latex/FAM/img/chronic_diseases_male.pdf analysis/techdoc/latex/FAM/img/chronic_diseases_female.pdf analysis/techdoc/latex/FAM/img/adl_iadl_male.pdf analysis/techdoc/latex/FAM/img/adl_iadl_female.pdf
FAM_SECT_ACKNOWLEDGMENTS := analysis/techdoc/latex/FAM/acknowledgments.tex 
# \todo Add some latex error checking here (missing references, hboxes, etc.)
analysis/techdoc/latex/FAM/FAM_techdoc.pdf: analysis/techdoc/latex/FAM/FAM_techdoc.tex $(FAM_SECT_DYNAMIC_MODEL) $(FAM_SECT_DATA_SOURCES_ESTIMATION) $(FAM_SECT_DATA_SOURCES_TRENDS_AND_BASELINE) $(FAM_SECT_ESTIMATION) $(FAM_SECT_GOVT_REVENUE_AND_EXPENDITURES) analysis/techdoc/latex/FAM/new_cohorts_model.tex $(FAM_SECT_SCENARIOS_AND_ROBUSTNESS) analysis/techdoc/latex/FAM/title.tex $(FAM_SECT_IMPLEMENTATION) $(FAM_SECT_MODEL_DEVELOPMENT) $(FAM_SECT_ACKNOWLEDGMENTS) $(FAM_SECT_BASELINE_FORECASTS) $(FAM_SECT_FAM_TABLES) analysis/fem_bibliography.bib
	cd analysis/techdoc/latex/FAM && pdflatex FAM_techdoc.tex && bibtex FAM_techdoc.aux && pdflatex FAM_techdoc.tex && pdflatex FAM_techdoc.tex 







# This is all commented out for now ....
ifeq ("x","y")
analysis/techdoc/latex/tables/FAM/NHEA_adjustment.tex: fem_env.do analysis/techdoc/latex/tables/FAM/table_NHEA_adjustment.do routput/vMultiplier/vMultiplier_summary.dta
	cd analysis/techdoc/latex/tables/FAM/ && $(STATA) table_NHEA_adjustment.do
# Time serie with year as index (medgrowth is excluded here b/c the time series name is medgrowth.yearly):
FAM_TS_BY_YEAR := interest_rate
FAM_TS_BY_YEAR_SRC := $(addsuffix .txt, $(addprefix FEM_CPP_settings/timeseries/,${FAM_TS_BY_YEAR} medgrowth.yearly))
FAM_TS_BY_YEAR_DCT := $(addsuffix .dct, $(addprefix analysis/techdoc/latex/tables/shared/,${FAM_TS_BY_YEAR} medgrowth))
analysis/techdoc/latex/tables/FAM/time_series_by_year.tex: $(FAM_TS_BY_YEAR_SRC) $(FAM_TS_BY_YEAR_DCT) analysis/techdoc/latex/tables/FAM/table_time_series_by_year.do
	cd analysis/techdoc/latex/tables/FAM && $(STATA) table_time_series_by_year.do
# Time serie with birth year as index:
FAM_TS_BY_YOB := nra
FAM_TS_BY_YOB_SRC := $(addsuffix .txt, $(addprefix FEM_CPP_settings/timeseries/,${FAM_TS_BY_YOB}))
FAM_TS_BY_YOB_DCT := $(addsuffix .dct, $(addprefix analysis/techdoc/latex/tables/shared/,${FAM_TS_BY_YOB}))
analysis/techdoc/latex/tables/FAM/time_series_by_yob.tex: $(FAM_TS_BY_YOB_SRC) $(FAM_TS_BY_YOB_DCT) analysis/techdoc/latex/tables/FAM/table_time_series_by_yob.do
	cd analysis/techdoc/latex/tables/FAM && $(STATA) table_time_series_by_yob.do
endif

