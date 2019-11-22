## NHIS Make Rules
local_NHIS_SOURCE = nhis_main.do \
nhis97plus_rcd.do \
smoothprevalence.do \
prediction_synthetic.do
NHIS_SOURCE := $(local_NHIS_SOURCE:%=FEM_Stata/Makedata/NHIS/%)

$(DATADIR)/nhis97plus.dta: fem_env.do FEM_Stata/Makedata/NHIS/gen_nhis97plus.do $(wildcard $(NHISDIR)/nhis*/data/personsx.dta)
	cd FEM_Stata/Makedata/NHIS && $(STATA) gen_nhis97plus.do
$(DATADIR)/pred5152.dta: $(DATADIR)/nhis97plus_selected.dta 
$(DATADIR)/nhis97plus_selected.dta : fem_env.do $(NHIS_SOURCE) $(DATADIR)/nhis97plus.dta
	cd FEM_Stata/Makedata/NHIS && $(STATA) nhis_main.do
$(DATADIR)/nhis_smk_projections.dta: fem_env.do FEM_Stata/Makedata/NHIS/smoking_trends.do  $(DATADIR)/nhis97plus_selected.dta
	cd FEM_Stata/Makedata/NHIS/ && $(STATA) smoking_trends.do

$(DATADIR)/nhis_hbp_smk_projections.dta: FEM_Stata/Makedata/NHIS/FAM_hibp_smoking_trends.do $(DATADIR)/FAM_nhis97plus_selected.dta
	cd FEM_Stata/Makedata/NHIS/ && $(STATA) FAM_hibp_smoking_trends.do
$(DATADIR)/FAM_nhis97plus_selected.dta: FEM_Stata/Makedata/NHIS/FAM_nhis_main.do FEM_Stata/Makedata/NHIS/FAM_nhis97plus_rcd.do $(DATADIR)/nhis97plus.dta
	cd FEM_Stata/Makedata/NHIS/ && $(STATA) FAM_nhis_main.do

