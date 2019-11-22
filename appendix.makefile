# Check for restricted data
ifeq ($(findstring XSumErn.dta,$(wildcard $(HRSRESTRICT)/*.dta)), )
USERVARS=0
else
USERVARS=1
endif

## targets for building tables for FEM technical appendix
analysis/techdoc/latex/tables/FEM/svy_disease_prevalence.tex: fem_env.do analysis/techdoc/latex/tables/FEM/table_svy_disease_prevalence.do $(DATADIR)/hrs_analytic_recoded.dta $(DATADIR)/MEPS_cost_est.dta $(DATADIR)/nhis97plus_selected.dta $(MCBSDIR)/mcbs_cost_est.dta
	cd analysis/techdoc/latex/tables/FEM && $(STATA) table_svy_disease_prevalence.do
analysis/techdoc/latex/tables/FEM/baseline_trends.tex: fem_env.do analysis/techdoc/latex/tables/FEM/table_baseline_trends.do $(DATADIR)/trend_all_status_quo.dta
	cd analysis/techdoc/latex/tables/FEM && $(STATA) table_baseline_trends.do
analysis/techdoc/latex/tables/FEM/prevalence_1978_2004.tex: fem_env.do analysis/techdoc/latex/tables/FEM/table_prevalence_1978_2004.do $(DATADIR)/obs80_adj_table.dta
	cd analysis/techdoc/latex/tables/FEM && $(STATA) table_prevalence_1978_2004.do
TRANS_OUTCOME_TYPES := disease smoking logbmi adlstat iadlstat lfpben financial
TRANS_OUTCOME_LABROWS := $(addsuffix _lblrows.csv, $(addprefix analysis/techdoc/latex/tables/FEM/transitioned_outcomes_,${TRANS_OUTCOME_TYPES}))
TRANS_OUTCOME_SUBTABS := $(addsuffix .tex, $(addprefix analysis/techdoc/latex/tables/FEM/transitioned_outcomes_,${TRANS_OUTCOME_TYPES}))
$(TRANS_OUTCOME_SUBTABS): $(TRANSDATA) $(TRANS_OUTCOME_LABROWS) analysis/techdoc/latex/tables/FEM/table_transitioned_outcomes.do
	cd analysis/techdoc/latex/tables/FEM && $(STATA) table_transitioned_outcomes.do

INIT_COND_TYPES := binary bmistat smoking funcstat continuous censcont censdiscrete earlyagedb normalagedb covars
INIT_COND_LABROWS := $(addsuffix _lblrows.csv, $(addprefix analysis/techdoc/latex/tables/FEM/desc_init_conditions_,${INIT_COND_TYPES}))
INIT_COND_SUBTABS := $(addsuffix .tex, $(addprefix analysis/techdoc/latex/tables/FEM/desc_init_conditions_,${INIT_COND_TYPES}))

OBS80_RESULT_TYPES := popsize conditions labor govrev govexp totmd
OBS80_RESULT_LABROWS := $(addsuffix _lblrows.csv, $(addprefix analysis/techdoc/latex/tables/FEM/desc_init_conditions_,${OBS80_RESULT_TYPES}))
STATUSQUO_SUBTABS := $(addsuffix .tex, $(addprefix analysis/techdoc/latex/tables/FEM/statusquo_results_,${OBS80_RESULT_TYPES}))
OBESITY_RESULT_SUBTABS := $(addsuffix .tex, $(addprefix analysis/techdoc/latex/tables/FEM/obesity_results_,${OBS80_RESULT_TYPES}))

ifeq ($(USERVARS), 1)
analysis/techdoc/latex/tables/FEM/controlvar_descs.tex: $(HRSDIR)/stock_hrs_2004.dta analysis/techdoc/latex/tables/FEM/table_controlvar_descs.do
	cd analysis/techdoc/latex/tables/FEM && DATAIN=$(HRSDIR)/stock_hrs_2004.dta $(STATA) table_controlvar_descs.do
$(INIT_COND_SUBTABS): $(ROOT)/input_data/new51s_status_quo.dta $(HRSDIR)/age5055_hrs1992r.dta $(INIT_COND_LABROWS) analysis/techdoc/latex/tables/FEM/table_desc_init_conditions.do
	cd analysis/techdoc/latex/tables/FEM && DATAIN=$(HRSDIR)/age5055_hrs1992r.dta FYEAR=$(FYEAR) $(STATA) table_desc_init_conditions.do
analysis/techdoc/latex/tables/FEM/NHEA_adjustment.tex: fem_env.do analysis/techdoc/latex/tables/FEM/table_NHEA_adjustment.do routput/vMultiplier/vMultiplier_summary.dta
	cd analysis/techdoc/latex/tables/FEM/ && $(STATA) table_NHEA_adjustment.do
$(STATUSQUO_SUBTABS) analysis/techdoc/latex/tables/FEM/status_quo_results.dta: fem_env.do analysis/techdoc/latex/tables/FEM/table_status_quo_results.do routput/vBaseline_sq/vBaseline_sq_summary.dta
	cd analysis/techdoc/latex/tables/FEM && $(STATA) table_status_quo_results.do
$(OBESITY_RESULT_SUBTABS): fem_env.do analysis/techdoc/latex/tables/FEM/table_obesity_results.do routput/vObese_80_sq/vObese_80_sq_summary.dta analysis/techdoc/latex/tables/FEM/status_quo_results.dta
	cd analysis/techdoc/latex/tables/FEM && $(STATA) table_obesity_results.do
# Revised crossvalidation
analysis/techdoc/latex/tables/FEM/crossval_binecon.tex analysis/techdoc/latex/tables/FEM/crossval_cntecon.tex analysis/techdoc/latex/tables/FEM/crossval_demog.tex analysis/techdoc/latex/tables/FEM/crossval_risk.tex: analysis/techdoc/latex/tables/FEM/crossval_unweighted.tex
analysis/techdoc/latex/tables/FEM/crossval_unweighted.tex: fem_env.do analysis/techdoc/latex/tables/FEM/crossvalidation.do $(RANDHRS) routput/vCrossvalidation/vCrossvalidation_summary.dta $(HRSDIR)/stock_hrs_1998.dta
	cd analysis/techdoc/latex/tables/FEM && $(STATA) crossvalidation.do

# Census population comparison
analysis/techdoc/latex/tables/FEM/population_compare_all.csv: fem_env.do analysis/techdoc/latex/tables/FEM/table_population_forecasts.do routput/vBaseline_sq/vBaseline_sq_summary.dta routput/vMinimal_sq/vMinimal_sq_summary.dta
	cd analysis/techdoc/latex/tables/FEM && $(STATA) table_population_forecasts.do

analysis/techdoc/latex/FEM/img/chronic_diseases_male.pdf analysis/techdoc/latex/FEM/img/chronic_diseases_female.pdf analysis/techdoc/latex/FEM/img/adl_iadl_male.pdf: analysis/techdoc/latex/FEM/img/adl_iadl_female.pdf
analysis/techdoc/latex/FEM/img/adl_iadl_female.pdf: analysis/techdoc/latex/tables/FEM/handover.do routput/vBaseline/vBaseline_summary.dta
	cd analysis/techdoc/latex/tables/FEM/ && $(STATA) handover.do
else
analysis/techdoc/latex/tables/FEM/controlvar_descs.tex: $(DATADIR)/stock_hrs_2004.dta analysis/techdoc/latex/tables/FEM/table_controlvar_descs.do
	cd analysis/techdoc/latex/tables/FEM && DATAIN=$(DATADIR)/stock_hrs_2004.dta $(STATA) table_controlvar_descs.do
$(INIT_COND_SUBTABS): $(DATADIR)/new51s_status_quo.dta $(DATADIR)/age5055_hrs1992.dta $(INIT_COND_LABROWS) analysis/techdoc/latex/tables/FEM/table_desc_init_conditions.do
	cd analysis/techdoc/latex/tables/FEM && DATAIN=$(DATADIR)/age5055_hrs1992.dta FYEAR=$(FYEAR) $(STATA) table_desc_init_conditions.do
analysis/techdoc/latex/tables/FEM/NHEA_adjustment.tex: fem_env.do analysis/techdoc/latex/tables/FEM/table_NHEA_adjustment.do output/vMultiplier/vMultiplier_summary.dta
	cd analysis/techdoc/latex/tables/FEM/ && $(STATA) table_NHEA_adjustment.do
$(STATUSQUO_SUBTABS) analysis/techdoc/latex/tables/FEM/status_quo_results.dta: fem_env.do analysis/techdoc/latex/tables/FEM/table_status_quo_results.do output/vBaseline_sq/vBaseline_sq_summary.dta
	cd analysis/techdoc/latex/tables/FEM && $(STATA) table_status_quo_results.do
$(OBESITY_RESULT_SUBTABS): fem_env.do analysis/techdoc/latex/tables/FEM/table_obesity_results.do output/vObese_80_sq/vObese_80_sq_summary.dta analysis/techdoc/latex/tables/FEM/status_quo_results.dta
	cd analysis/techdoc/latex/tables/FEM && $(STATA) table_obesity_results.do

# Revised crossvalidation
analysis/techdoc/latex/tables/FEM/crossval_binecon.tex analysis/techdoc/latex/tables/FEM/crossval_cntecon.tex analysis/techdoc/latex/tables/FEM/crossval_demog.tex analysis/techdoc/latex/tables/FEM/crossval_risk.tex: analysis/techdoc/latex/tables/FEM/crossval_unweighted.tex
analysis/techdoc/latex/tables/FEM/crossval_unweighted.tex: fem_env.do analysis/techdoc/latex/tables/FEM/crossvalidation.do $(RANDHRS) output/vCrossvalidation/vCrossvalidation_summary.dta $(DATADIR)/stock_hrs_1998.dta
	cd analysis/techdoc/latex/tables/FEM && $(STATA) crossvalidation.do

# Census population comparison
analysis/techdoc/latex/tables/FEM/population_compare_all.csv: fem_env.do analysis/techdoc/latex/tables/FEM/table_population_forecasts.do output/vBaseline_sq/vBaseline_sq_summary.dta output/vMinimal_sq/vMinimal_sq_summary.dta
	cd analysis/techdoc/latex/tables/FEM && $(STATA) table_population_forecasts.do

analysis/techdoc/latex/FEM/img/chronic_diseases_male.pdf analysis/techdoc/latex/FEM/img/chronic_diseases_female.pdf analysis/techdoc/latex/FEM/img/adl_iadl_male.pdf: analysis/techdoc/latex/FEM/img/adl_iadl_female.pdf
analysis/techdoc/latex/FEM/img/adl_iadl_female.pdf: analysis/techdoc/latex/tables/FEM/handover.do output/vBaseline/vBaseline_summary.dta
	cd analysis/techdoc/latex/tables/FEM/ && $(STATA) handover.do

endif

analysis/techdoc/latex/tables/FEM/latent_model_mean_est.tex: fem_env.do analysis/techdoc/latex/tables/FEM/table_latent_model_mean_est.do $(BASEDIR)/incoming_means.dta $(TRANSDATA)
	cd analysis/techdoc/latex/tables/FEM && $(STATA) table_latent_model_mean_est.do
analysis/techdoc/latex/tables/FEM/latent_model_vcmat_est.tex: fem_env.do analysis/techdoc/latex/tables/FEM/table_latent_model_vcmat_est.do $(BASEDIR)/incoming_vcmatrix.dta analysis/techdoc/latex/tables/FEM/initcond_labels.csv
	cd analysis/techdoc/latex/tables/FEM && $(STATA) table_latent_model_vcmat_est.do
# Time serie with year as index (medgrowth is excluded here b/c the time series name is medgrowth.yearly):
TS_BY_YEAR := nwi interest_rate cola cpi sga
TS_BY_YEAR_SRC := $(addsuffix .txt, $(addprefix FEM_CPP_settings/timeseries/,${TS_BY_YEAR} medgrowth.yearly))
TS_BY_YEAR_DCT := $(addsuffix .dct, $(addprefix analysis/techdoc/latex/tables/shared/,${TS_BY_YEAR} medgrowth))
analysis/techdoc/latex/tables/FEM/time_series_by_year.tex: $(TS_BY_YEAR_SRC) $(TS_BY_YEAR_DCT) analysis/techdoc/latex/tables/FEM/table_time_series_by_year.do
	cd analysis/techdoc/latex/tables/FEM && $(STATA) table_time_series_by_year.do
# Time serie with birth year as index:
TS_BY_YOB := nra drc
TS_BY_YOB_SRC := $(addsuffix .txt, $(addprefix FEM_CPP_settings/timeseries/,${TS_BY_YOB}))
TS_BY_YOB_DCT := $(addsuffix .dct, $(addprefix analysis/techdoc/latex/tables/shared/,${TS_BY_YOB}))
analysis/techdoc/latex/tables/FEM/time_series_by_yob.tex: $(TS_BY_YOB_SRC) $(TS_BY_YOB_DCT) analysis/techdoc/latex/tables/FEM/table_time_series_by_yob.do
	cd analysis/techdoc/latex/tables/FEM && $(STATA) table_time_series_by_yob.do

TEX_TABLES := analysis/techdoc/latex/tables/FEM/svy_disease_prevalence.tex analysis/techdoc/latex/tables/FEM/baseline_trends.tex analysis/techdoc/latex/tables/FEM/prevalence_1978_2004.tex $(TRANS_OUTCOME_SUBTABS) analysis/techdoc/latex/tables/FEM/controlvar_descs.tex $(INIT_COND_SUBTABS) analysis/techdoc/latex/tables/FEM/latent_model_mean_est.tex analysis/techdoc/latex/tables/FEM/latent_model_vcmat_est.tex analysis/techdoc/latex/tables/FEM/NHEA_adjustment.tex $(STATUSQUO_SUBTABS) $(OBESITY_RESULT_SUBTABS) analysis/techdoc/latex/tables/FEM/time_series_by_year.tex analysis/techdoc/latex/tables/FEM/time_series_by_yob.tex analysis/techdoc/latex/tables/FEM/crossval_binecon.tex analysis/techdoc/latex/tables/FEM/crossval_cntecon.tex analysis/techdoc/latex/tables/FEM/crossval_demog.tex analysis/techdoc/latex/tables/FEM/crossval_risk.tex analysis/techdoc/latex/tables/FEM/crossval_unweighted.tex

## targets for building LaTeX FEM technical appendix .pdf file
SECT_DYNAMIC_MODEL := analysis/techdoc/latex/FEM/dynamic_model.tex analysis/techdoc/latex/FEM/dynamic_model_overview.tex analysis/techdoc/latex/shared/dynamic_model_background.tex analysis/techdoc/latex/FEM/dynamic_model_comparison_with_other_microsims.tex  analysis/techdoc/latex/FEM/img/fem_architecture.png
SECT_DATA_SOURCES_ESTIMATION := analysis/techdoc/latex/FEM/data_sources_estimation.tex analysis/techdoc/latex/FEM/data_sources_estimation_hrs.tex analysis/techdoc/latex/FEM/data_sources_estimation_meps.tex analysis/techdoc/latex/FEM/data_sources_estimation_nhis.tex analysis/techdoc/latex/FEM/data_sources_estimation_ssearnings.tex analysis/techdoc/latex/FEM/data_sources_estimation_mcbs.tex 
SECT_DATA_SOURCES_TRENDS_AND_BASELINE := analysis/techdoc/latex/FEM/data_sources_trends_and_baseline.tex analysis/techdoc/latex/FEM/data_sources_trends_and_baseline_demographic_projections.tex analysis/techdoc/latex/FEM/data_sources_trends_and_baseline_entering_cohorts.tex analysis/techdoc/latex/FEM/data_sources_trends_and_baseline_other_projections.tex
SECT_ESTIMATION := analysis/techdoc/latex/FEM/estimation.tex analysis/techdoc/latex/FEM/estimation_goodness-of-fit.tex analysis/techdoc/latex/FEM/estimation_qalys.tex analysis/techdoc/latex/FEM/estimation_transition_model.tex 
SECT_GOVT_REVENUE_AND_EXPENDITURES := analysis/techdoc/latex/FEM/govt_revenue_and_expenditures.tex analysis/techdoc/latex/FEM/govt_revenue_and_expenditures_DIben.tex analysis/techdoc/latex/FEM/govt_revenue_and_expenditures_medcost_estimation.tex analysis/techdoc/latex/FEM/govt_revenue_and_expenditures_SSben.tex analysis/techdoc/latex/FEM/govt_revenue_and_expenditures_SSIben.tex analysis/techdoc/latex/FEM/govt_revenue_and_expenditures_taxes.tex 
SECT_SCENARIOS_AND_ROBUSTNESS := analysis/techdoc/latex/FEM/scenarios_and_robustness.tex analysis/techdoc/latex/FEM/scenarios_and_robustness_obesity_reduction.tex analysis/techdoc/latex/FEM/scenarios_and_robustness_robustness.tex 
SECT_IMPLEMENTATION := analysis/techdoc/latex/FEM/implementation.tex analysis/techdoc/latex/FEM/implementation_interventions.tex
SECT_MODEL_DEVELOPMENT := analysis/techdoc/latex/FEM/model_development.tex analysis/techdoc/latex/FEM/model_development_transition_model.tex analysis/techdoc/latex/FEM/model_development_qalys.tex analysis/techdoc/latex/FEM/model_development_rxexp.tex
SECT_FEM_TABLES := analysis/techdoc/latex/FEM/FEM_tables.tex $(TEX_TABLES)

SECT_VALIDATION := analysis/techdoc/latex/FEM/validation.tex analysis/techdoc/latex/FEM/validation_crossvalidation.tex analysis/techdoc/latex/FEM/validation_external_validation.tex analysis/techdoc/latex/FEM/validation_external_corroboration.tex analysis/techdoc/latex/tables/FEM/population_compare_all.csv
SECT_ACKNOWLEDGMENTS := analysis/techdoc/latex/FEM/acknowledgments.tex

# \todo Add some latex error checking here (missing references, hboxes, etc.)
analysis/techdoc/latex/FEM/FEM_techdoc.pdf: analysis/techdoc/latex/FEM/FEM_techdoc.tex $(SECT_DYNAMIC_MODEL) $(SECT_DATA_SOURCES_ESTIMATION) $(SECT_DATA_SOURCES_TRENDS_AND_BASELINE) $(SECT_ESTIMATION) $(SECT_GOVT_REVENUE_AND_EXPENDITURES) analysis/techdoc/latex/FEM/new_cohorts_model.tex $(SECT_IMPLEMENTATION) $(SECT_SCENARIOS_AND_ROBUSTNESS) analysis/techdoc/latex/FEM/title.tex $(SECT_MODEL_DEVELOPMENT) $(SECT_FEM_TABLES) $(SECT_VALIDATION) analysis/fem_bibliography.bib analysis/techdoc/latex/FEM/get_estimates_table_url.py analysis/techdoc/latex/FEM/img/chronic_diseases_male.pdf analysis/techdoc/latex/FEM/img/chronic_diseases_female.pdf analysis/techdoc/latex/FEM/img/adl_iadl_male.pdf analysis/techdoc/latex/FEM/img/adl_iadl_female.pdf $(SECT_ACKNOWLEDGMENTS)
	cd analysis/techdoc/latex/FEM && pdflatex FEM_techdoc.tex && bibtex FEM_techdoc.aux && pdflatex FEM_techdoc.tex && pdflatex FEM_techdoc.tex 
