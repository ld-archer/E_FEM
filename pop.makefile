## POPULATION Make Rules
## This is one of those files that is hand-modified to produce different outputs. As such, not great for automated builds, but I'm working on it.
$(DATADIR)/trend_all_status_quo.dta: FEM_Stata/Makedata/POPULATION/generate_trends.do $(DATADIR)/obesity_projections_4656.dta $(DATADIR)/nhis_smk_projections.dta $(DATADIR)/pred5152.dta $(BASEDIR)/legacy_smkscr.dta $(BASEDIR)/census5152_byrace.dta $(DATADIR)/trend_educ.dta
	cd FEM_Stata/Makedata/POPULATION && $(STATA) generate_trends.do
$(DATADIR)/pop5152_projection.dta $(DATADIR)/population_projection.dta: $(DATADIR)/pop2526_projection.dta
$(DATADIR)/pop2526_projection.dta: FEM_Stata/Makedata/POPULATION/census_pop_projection.do $(CENSUS)/2012_Pop_Projection/NP2012_D1.csv $(DATADIR)/population_estimates_2012.dta
	cd FEM_Stata/Makedata/POPULATION && $(STATA) census_pop_projection.do
$(DATADIR)/death_counts.dta: FEM_Stata/Makedata/POPULATION/hmd_death_counts.do $(HMD)/Deaths_1x1.txt
	cd FEM_Stata/Makedata/POPULATION && $(STATA) hmd_death_counts.do
$(DATADIR)/population_estimates_2000_2009.dta $(DATADIR)/population_estimates_2010.dta $(DATADIR)/population_estimates_2011.dta $(DATADIR)/population_estimates_2012.dta: FEM_Stata/Makedata/POPULATION/census_pop_estimates.do $(CENSUS)/2000_2010_Intercensal_Estimates/US-EST00INT-ALLDATA.csv $(CENSUS)/2012_Pop_Estimates/NC-EST2012-ALLDATA-R-File02.csv $(CENSUS)/2012_Pop_Estimates/NC-EST2012-ALLDATA-R-File04.csv $(CENSUS)/2012_Pop_Estimates/NC-EST2012-ALLDATA-R-File06.csv
	cd FEM_Stata/Makedata/POPULATION && $(STATA) census_pop_estimates.do
$(DATADIR)/pop5152_projection_2150.dta: FEM_Stata/Makedata/POPULATION/proj_2150.do $(DATADIR)/pop5152_projection.dta
	cd FEM_Stata/Makedata/POPULATION && $(STATA) proj_2150.do
$(DATADIR)/immigration_projection.dta: FEM_Stata/Makedata/POPULATION/census_immigration_projection.do $(DATADIR)/immigration_estimates.dta $(CENSUS)/2012_Pop_Projection/NP2012_D4.csv $(CENSUS)/2000_Pop_Projection/pmigdet.a.txt
	cd FEM_Stata/Makedata/POPULATION && $(STATA) census_immigration_projection.do
$(DATADIR)/immigration_estimates.dta: FEM_Stata/Makedata/POPULATION/census_immigration_estimates.do $(CENSUS)/2013_Pop_Estimates/NST_EST2013_ALLDATA.csv $(CENSUS)/2009_Pop_Estimates/NST_EST2009_ALLDATA.csv
	cd FEM_Stata/Makedata/POPULATION && $(STATA) census_immigration_estimates.do
# For crossvalidation
$(DATADIR)/pop5152_projection_1998.dta $(DATADIR)/population_projection_1998.dta: FEM_Stata/Makedata/POPULATION/census_pop_projection_1998.do $(BASEDIR)/census_projections_1998.csv
	cd FEM_Stata/Makedata/POPULATION && $(STATA) census_pop_projection_1998.do

migration_core:
	cd FEM_Stata/Makedata/POPULATION && INFILE=2012_Pop_Projection/NP2012_D4.csv OUTDIR=FEM_CPP_settings/psid AGEMIN=25 CATS=ysah $(STATA) census_immigration_projection_rev.do
	cd FEM_Stata/Makedata/POPULATION && INFILE=2012_Pop_Projection/NP2012_D4.csv OUTDIR=FEM_CPP_settings AGEMIN=51 CATS=ysah $(STATA) census_immigration_projection_rev.do

migration_all:
	cd FEM_Stata/Makedata/POPULATION && INFILE=2017_Pop_Projection/np2017_d4.csv OUTDIR=FEM_CPP_settings/immigration_NP2017_ysah_25p AGEMIN=25 CATS=ysah $(STATA) census_immigration_projection_rev.do
	cd FEM_Stata/Makedata/POPULATION && INFILE=2017_Pop_Projection/np2017_d4.csv OUTDIR=FEM_CPP_settings/immigration_NP2017_ysah_51p AGEMIN=51 CATS=ysah $(STATA) census_immigration_projection_rev.do
	cd FEM_Stata/Makedata/POPULATION && INFILE=2012_Pop_Projection/NP2012_D4.csv OUTDIR=FEM_CPP_settings/immigration_NP2012_a_25p AGEMIN=25 CATS=a $(STATA) census_immigration_projection_rev.do
	cd FEM_Stata/Makedata/POPULATION && INFILE=2012_Pop_Projection/NP2012_D4.csv OUTDIR=FEM_CPP_settings/immigration_NP2012_ya_25p AGEMIN=25 CATS=ya $(STATA) census_immigration_projection_rev.do
	cd FEM_Stata/Makedata/POPULATION && INFILE=2012_Pop_Projection/NP2012_D4.csv OUTDIR=FEM_CPP_settings/immigration_NP2012_ysa_25p AGEMIN=25 CATS=ysa $(STATA) census_immigration_projection_rev.do
	cd FEM_Stata/Makedata/POPULATION && INFILE=2012_Pop_Projection/NP2012_D4.csv OUTDIR=FEM_CPP_settings/immigration_NP2012_ysah_25p AGEMIN=25 CATS=ysah $(STATA) census_immigration_projection_rev.do
	cd FEM_Stata/Makedata/POPULATION && INFILE=2012_Pop_Projection/NP2012_D4.csv OUTDIR=FEM_CPP_settings/immigration_NP2012_a_51p AGEMIN=51 CATS=a $(STATA) census_immigration_projection_rev.do
	cd FEM_Stata/Makedata/POPULATION && INFILE=2012_Pop_Projection/NP2012_D4.csv OUTDIR=FEM_CPP_settings/immigration_NP2012_ya_51p AGEMIN=51 CATS=ya $(STATA) census_immigration_projection_rev.do
	cd FEM_Stata/Makedata/POPULATION && INFILE=2012_Pop_Projection/NP2012_D4.csv OUTDIR=FEM_CPP_settings/immigration_NP2012_ysa_51p AGEMIN=51 CATS=ysa $(STATA) census_immigration_projection_rev.do
	cd FEM_Stata/Makedata/POPULATION && INFILE=2012_Pop_Projection/NP2012_D4.csv OUTDIR=FEM_CPP_settings/immigration_NP2012_ysah_51p AGEMIN=51 CATS=ysah $(STATA) census_immigration_projection_rev.do
	cd FEM_Stata/Makedata/POPULATION && INFILE=2012_Pop_Projection/NP2012C_D4.csv OUTDIR=FEM_CPP_settings/immigration_NP2012C_ysah_25p AGEMIN=25 CATS=ysah $(STATA) census_immigration_projection_rev.do
	cd FEM_Stata/Makedata/POPULATION && INFILE=2012_Pop_Projection/NP2012L_D4.csv OUTDIR=FEM_CPP_settings/immigration_NP2012L_ysah_25p AGEMIN=25 CATS=ysah $(STATA) census_immigration_projection_rev.do
	cd FEM_Stata/Makedata/POPULATION && INFILE=2012_Pop_Projection/NP2012H_D4.csv OUTDIR=FEM_CPP_settings/immigration_NP2012H_ysah_25p AGEMIN=25 CATS=ysah $(STATA) census_immigration_projection_rev.do
	cd FEM_Stata/Makedata/POPULATION && INFILE=2012_Pop_Projection/NP2012C_D4.csv OUTDIR=FEM_CPP_settings/immigration_NP2012C_ysah_51p AGEMIN=51 CATS=ysah $(STATA) census_immigration_projection_rev.do
	cd FEM_Stata/Makedata/POPULATION && INFILE=2012_Pop_Projection/NP2012L_D4.csv OUTDIR=FEM_CPP_settings/immigration_NP2012L_ysah_51p AGEMIN=51 CATS=ysah $(STATA) census_immigration_projection_rev.do
	cd FEM_Stata/Makedata/POPULATION && INFILE=2012_Pop_Projection/NP2012H_D4.csv OUTDIR=FEM_CPP_settings/immigration_NP2012H_ysah_51p AGEMIN=51 CATS=ysah $(STATA) census_immigration_projection_rev.do
