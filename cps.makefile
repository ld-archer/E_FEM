## CPS Make Rules
$(DATADIR)/trend_educ.dta: FEM_Stata/Makedata/CPS/cps_education.do $(BASEDIR)/CPS.dta fem_env.do
	cd FEM_Stata/Makedata/CPS && $(STATA) cps_education.do
$(DATADIR)/cps2009_demog.dta: FEM_Stata/Makedata/CPS/cps_demog.do $(CPS)/cpsmar09/asec2009_pubuse.dta fem_env.do
	cd FEM_Stata/Makedata/CPS && $(STATA) cps_demog.do
