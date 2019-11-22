# For some reason, the Makefile cannot use the run.mpi.sh script properly
routput/vObese_80_sq/vObese_80_sq_summary.dta routput/vCrossvalidation/vCrossvalidation_summary.dta routput/vMinimal_sq/vMinimal_sq_summary.dta routput/vNoTrend/vNoTrend_summary.dta routput/vNoFvars/vNoFvars_summary.dta routput/vBaseline_sq/vBaseline_sq_summary.dta : routput/vBaseline/vBaseline_summary.dta 
routput/vBaseline/vBaseline_summary.dta: $(HRSDIR)/stock_hrs_2004.dta FEM $(DATADIR)/new51s_status_quo.dta $(DATADIR)/new51s_obs80.dta $(DATADIR)/new51s_notrend.dta $(HRSDIR)/stock_hrs_1998.dta validation.csv validation.settings.txt
	rm -Rf routput/vBaseline routput/vObese_80_sq routput/vCrossvalidation routput/vMinimal_sq routput/vNoTrend routput/vNoFvars
	mpiexec -n 10 ./FEM validation.settings.txt
	mpiexec -n 10 ./FEM validation_sq.settings.txt
output/vMinimal_sq/vMinimal_sq_summary.dta output/vObese_80_sq/vObese_80_sq_summary.dta: output/vBaseline_sq/vBaseline_sq_summary.dta
output/vBaseline_sq/vBaseline_sq_summary.dta: $(DATADIR)/stock_hrs_2010.dta FEM $(DATADIR)/new51s_status_quo.dta unres_validation_sq.csv unres_validation_sq.settings.txt $(DATADIR)/new51s_obs80.dta
	rm -Rf output/vBaseline_sq output/vObese_80_sq
	mpiexec -n 10 ./FEM unres_validation_sq.settings.txt
output/vObese_80/vObese_80_summary.dta output/vCrossvalidation/vCrossvalidation_summary.dta output/vMinimal/vMinimal_summary.dta output/vNoTrend/vNoTrend_summary.dta output/vNoFvars/vNoFvars_summary.dta: output/vBaseline/vBaseline_summary.dta 
output/vBaseline/vBaseline_summary.dta: $(DATADIR)/stock_hrs_2004.dta FEM $(DATADIR)/new51s_status_quo.dta $(DATADIR)/new51s_obs80.dta $(DATADIR)/new51s_notrend.dta $(DATADIR)/stock_hrs_1998.dta unres_validation.csv unres_validation.settings.txt $(DATADIR)/stock_hrs_2010.dta
	rm -Rf output/vBaseline output/vObese_80 output/vCrossvalidation output/vMinimal output/vNoFvars
	mpiexec -n 10 ./FEM unres_validation.settings.txt
output/example_stock/example_stock_summary.dta: output/example_cohort/example_cohort_summary.dta
output/example_cohort/example_cohort_summary.dta: $(DATADIR)/stock_hrs_2004.dta FEM $(DATADIR)/new51s_status_quo.dta FEM_CPP_settings/vars.txt FEM_CPP_settings/summary_output_example.txt example.csv example.settings.txt
	rm -Rf output/example_stock output/example_cohort
	mpiexec -n 10 ./FEM example.settings.txt


routput/vMultiplier/vMultiplier_summary.dta: $(HRSDIR)/stock_hrs_2004.dta FEM $(DATADIR)/new51s_status_quo.dta multiplier.csv multiplier.settings.txt
	rm -Rf routput/vMultiplier 
	mpiexec -n 10 ./FEM multiplier.settings.txt
output/vMultiplier/vMultiplier_summary.dta: $(DATADIR)/stock_hrs_2004.dta FEM $(DATADIR)/new51s_status_quo.dta unres_multiplier.csv unres_multiplier.settings.txt
	rm -Rf output/vMultiplier 
	mpiexec -n 10 ./FEM unres_multiplier.settings.txt
