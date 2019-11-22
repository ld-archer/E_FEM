## SSA Support Files
$(DATADIR)/cnatwage.dta: fem_env.do FEM_Stata/Makedata/SSA/cnatwage.do $(BASEDIR)/AWI_1951_2011.csv
	cd FEM_Stata/Makedata/SSA && $(STATA) cnatwage.do
$(DATADIR)/earnlimit.dta: fem_env.do FEM_Stata/Makedata/SSA/earnlimit.do $(BASEDIR)/SS_max_1950_2013.csv
	cd FEM_Stata/Makedata/SSA && $(STATA) earnlimit.do

## File of historic DI enrollees and average benefits (2005 through 2014).  Useful for validation and assigning age-specific DI benefits
YEARS_DI := $(shell seq 2005 2014)
DI_FILES := $(addsuffix _12.csv, $(addprefix base_data/SSA_DI_,${YEARS_DI}))
$(DATADIR)/ssa_diclaim.dta: $(DI_FILES) FEM_Stata/Makedata/SSA/ssa_diclaim.do
	cd FEM_Stata/Makedata/SSA && $(STATA) ssa_diclaim.do

YEARS_SS := $(shell seq 2005 2014)
SS_FILES := $(addsuffix 12.csv, $(addprefix base_data/ra_age,${YEARS_DI}))
$(DATADIR)/ssa_ssclaim.dta: $(DI_FILES) FEM_Stata/Makedata/SSA/ssa_ssclaim.do
	cd FEM_Stata/Makedata/SSA && $(STATA) ssa_ssclaim.do
