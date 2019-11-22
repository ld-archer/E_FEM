## ACS Make Rules
$(DATADIR)/acs2009_demog.dta: FEM_Stata/Makedata/ACS/acs_demog.do FEM_Stata/Makedata/ACS/acs_define_marstat.do $(ACS)/Stata/population_2009.dta fem_env.do
	cd FEM_Stata/Makedata/ACS && $(STATA) acs_demog.do
$(DATADIR)/acs_trends_forecast_final.dta: FEM_Stata/Makedata/ACS/ACS_trends_final.do
	cd FEM_Stata/Makedata/ACS/ && $(STATA) ACS_trends_final.do
