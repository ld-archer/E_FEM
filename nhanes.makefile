## NHANES Make Rules
$(DATADIR)/nhanes.dta: fem_env.do FEM_Stata/Makedata/NHANES/gen_nhanes_analytic.do
	cd FEM_Stata/Makedata/NHANES && $(STATA) gen_nhanes_analytic.do
$(DATADIR)/nhanes_bmi.dta: $(DATADIR)/nhanes.dta fem_env.do FEM_Stata/Makedata/NHANES/create_bmi_dataset.do
	cd FEM_Stata/Makedata/NHANES && $(STATA) create_bmi_dataset.do
$(DATADIR)/NHANES_bmi_cohort_qtls.dta: fem_env.do FEM_Stata/Makedata/NHANES/bmi_distribution_by_age_cohort.do fem_env.do $(DATADIR)/nhanes_bmi.dta
	cd FEM_Stata/Makedata/NHANES && $(STATA) bmi_distribution_by_age_cohort.do
$(DATADIR)/obs80_adjustments.dta $(DATADIR)/obs80_adj_table.dta: $(DATADIR)/nhanes.dta FEM_Stata/Makedata/NHANES/gen_obs80_adj.do
	cd FEM_Stata/Makedata/NHANES && $(STATA) gen_obs80_adj.do
$(DATADIR)/obesity_projections_4656.dta: FEM_Stata/Makedata/NHANES/obesity_projections_4656.do $(DATADIR)/nhanes_bmi.dta
	cd FEM_Stata/Makedata/NHANES/ && $(STATA) obesity_projections_4656.do

$(DATADIR)/obesity_projections_2130_since90_2010.dta: FEM_Stata/Makedata/NHANES/obesity_projections_2130_since90.do $(DATADIR)/nhanes.dta
	cd FEM_Stata/Makedata/NHANES/ && $(STATA) obesity_projections_2130_since90.do
