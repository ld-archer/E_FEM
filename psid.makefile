## PSID
PSIDMACS =  $(PSIDSAS)/setup.inc $(PSIDMAC)/psidget.mac $(PSIDMAC)/renyrv.mac
## PSID - Sas Steps
$(PSIDSAS)/Output/extract_data.sas7bdat: $(PSIDIND) $(PSIDFAM) $(PSIDSAS)/extract_data.sas $(PSIDSAS)/vars_indiv_file.sas $(PSIDSAS)/vars_fam_file.sas $(PSIDSAS)/vars_consumption.sas $(PSIDMACS) $(PSIDSAS)/vars_childhealth.sas $(PSIDSAS)/vars_age_onset.sas $(PSIDSAS)/vars_k6.sas $(PSIDSAS)/vars_educ.sas
	cd $(PSIDSAS) && $(SAS) extract_data.sas
$(PSIDSAS)/Output/demographics.sas7bdat: $(PSIDSAS)/Output/extract_data.sas7bdat $(PSIDSAS)/recode_demographics.sas $(PSIDMACS)
	cd $(PSIDSAS) && $(SAS) recode_demographics.sas
$(PSIDSAS)/Output/health.sas7bdat: $(PSIDSAS)/Output/extract_data.sas7bdat $(PSIDSAS)/recode_health.sas $(PSIDMACS) $(PSIDMAC)/recode_absorb.mac $(PSIDMAC)/severity.mac $(PSIDMAC)/onset.mac
	cd $(PSIDSAS) && $(SAS) recode_health.sas
$(PSIDSAS)/Output/limitations.sas7bdat: $(PSIDSAS)/Output/extract_data.sas7bdat $(PSIDSAS)/recode_limitations.sas $(PSIDMACS) $(PSIDMAC)/recode_absorb.mac
	cd $(PSIDSAS) && $(SAS) recode_limitations.sas
$(PSIDSAS)/Output/extract_educ.sas7bdat: $(PSIDIND) $(PSIDFAM) $(PSIDSAS)/extract_educ.sas
	cd $(PSIDSAS) && $(SAS) extract_educ.sas
$(PSIDSAS)/Output/famrelv.sas7bdat: $(PSIDIND) $(PSIDFAM) $(PSIDSAS)/extract_relig_com.sas $(PSIDMACS)
	cd $(PSIDSAS) && $(SAS) extract_relig_com.sas
$(PSIDSAS)/Output/education.sas7bdat:  $(PSIDSAS)/Output/extract_educ.sas7bdat $(PSIDSAS)/recode_education.sas $(PSIDMACS)
	cd $(PSIDSAS) && $(SAS) recode_education.sas
$(PSIDSAS)/Output/marrvars.sas7bdat: $(PSIDMAR) $(PSIDSAS)/extract_marriage_history.sas $(PSIDSAS)/setup.inc $(PSIDMAC)/psidget.mac $(PSIDSAS)/vars_indiv_file.sas $(PSIDSAS)/vars_fam_file.sas
	cd $(PSIDSAS) && $(SAS) extract_marriage_history.sas
$(PSIDSAS)/Output/extract_children.sas7bdat: $(PSIDMAR) $(PSIDSAS)/extract_children.sas $(PSIDMACS) $(PSIDSAS)/vars_indiv_file.sas $(PSIDSAS)/vars_children.sas
	cd $(PSIDSAS) && $(SAS) extract_children.sas
$(PSIDSAS)/Output/children.sas7bdat:  $(PSIDSAS)/Output/extract_children.sas7bdat $(PSIDSAS)/recode_children.sas $(PSIDMACS)
	cd $(PSIDSAS) && $(SAS) recode_children.sas
$(PSIDSAS)/Output/wfrel.sas7bdat: $(PSIDSAS)/link_spouses.sas $(PSIDSAS)/Output/extract_data.sas7bdat $(PSIDMACS)
	cd $(PSIDSAS) && $(SAS) link_spouses.sas
$(PSIDSAS)/Output/childhealth.sas7bdat: $(PSIDSAS)/Output/extract_data.sas7bdat $(PSIDSAS)/recode_childhealth.sas $(PSIDMACS) $(PSIDMAC)/recode_absorb.mac $(PSIDMAC)/rvar.mac
	cd $(PSIDSAS) && $(SAS) recode_childhealth.sas 
$(PSIDSAS)/Output/k6.sas7bdat: $(PSIDSAS)/Output/extract_data.sas7bdat $(PSIDSAS)/recode_k6.sas $(PSIDMACS)
	cd $(PSIDSAS) && $(SAS) recode_k6.sas 


$(DATADIR)/psid_merge.sas7bdat: $(PSIDSAS)/Output/extract_data.sas7bdat $(PSIDSAS)/Output/demographics.sas7bdat $(PSIDSAS)/Output/health.sas7bdat $(PSIDSAS)/Output/limitations.sas7bdat $(PSIDSAS)/Output/education.sas7bdat $(PSIDSAS)/Output/children.sas7bdat $(PSIDSAS)/psid_merge.sas $(PSIDSAS)/Output/marrvars.sas7bdat $(PSIDSAS)/Output/famrelv.sas7bdat $(PSIDSAS)/Output/wfrel.sas7bdat $(PSIDSAS)/Output/childhealth.sas7bdat $(PSIDSAS)/Output/k6.sas7bdat $(PSIDMACS)
	cd $(PSIDSAS) && $(SAS) psid_merge.sas 

## Stat-transfer to Stata
$(DATADIR)/psid_merge.dta: $(DATADIR)/psid_merge.sas7bdat
	cd $(DATADIR) && st $(DATADIR)/psid_merge.sas7bdat stata/se $(DATADIR)/psid_merge.dta -y

## PSID - Stata steps (pull econ data, merge pieces together, create analytic files)
## PSID - Stata Steps

COMMON2 = FEM_Stata/Makedata/PSID/common.do fem_env.do $(STATA)

$(PSIDSTATA)/Output/psid_fam1999er_select.dta $(PSIDSTATA)/Output/psid_fam2015er_select.dta: $(PSIDSTATA)/psid_fam_extract.do $(COMMON2) $(PSIDPUB)/Stata/fam2015er.dta
	cd FEM_Stata/Makedata/PSID && $(STATA) psid_fam_extract.do 
$(PSIDSTATA)/Output/psid_fam1999er_select_rcd.dta $(PSIDSTATA)/Output/psid_fam2015er_select_rcd.dta: $(PSIDSTATA)/psid_fam_recode.do $(COMMON2) $(PSIDSTATA)/Output/psid_fam1999er_select.dta $(PSIDSTATA)/Output/psid_fam2015er_select.dta
	cd FEM_Stata/Makedata/PSID && $(STATA) psid_fam_recode.do	
$(PSIDSTATA)/Output/psid_inder_1999to2015.dta: $(PSIDSTATA)/psid_ind_extract.do $(COMMON2) $(PSIDPUB)/Stata/ind2015er.dta
	cd FEM_Stata/Makedata/PSID && $(STATA) psid_ind_extract.do
$(PSIDSTATA)/Output/wlth1999_rcd.dta $(PSIDSTATA)/Output/wlth2007_rcd.dta: $(PSIDSTATA)/psid_wealth_extract.do $(COMMON2) $(PSIDPUB)/Stata/wlth1999.dta	$(PSIDPUB)/Stata/wlth2007.dta	
	cd FEM_Stata/Makedata/PSID && $(STATA) psid_wealth_extract.do 
$(PSIDSTATA)/Output/psid_econ_merged1999.dta $(PSIDSTATA)/Output/psid_econ_merged2001.dta $(PSIDSTATA)/Output/psid_econ_merged2003.dta $(PSIDSTATA)/Output/psid_econ_merged2005.dta $(PSIDSTATA)/Output/psid_econ_merged2007.dta $(PSIDSTATA)/Output/psid_econ_merged2009.dta $(PSIDSTATA)/Output/psid_econ_merged2011.dta: $(PSIDSTATA)/Output/psid_econ_merged2015.dta
$(PSIDSTATA)/Output/psid_econ_merged2015.dta: $(PSIDSTATA)/psid_econ_merge.do $(COMMON2) $(PSIDPUB)/Stata/socsectype94_07.dta $(PSIDSTATA)/Output/psid_inder_1999to2015.dta $(PSIDSTATA)/Output/psid_fam1999er_select_rcd.dta $(PSIDSTATA)/Output/wlth1999_rcd.dta
	cd FEM_Stata/Makedata/PSID && $(STATA) psid_econ_merge.do
$(DATADIR)/psid_econ.dta: $(PSIDSTATA)/psid_econ_recode.do $(COMMON2) $(PSIDSTATA)/Output/psid_econ_merged1999.dta $(PSIDSTATA)/Output/psid_econ_merged2015.dta	
	cd FEM_Stata/Makedata/PSID && $(STATA) psid_econ_recode.do
## Prison status
$(DATADIR)/prison.dta: $(PSIDSTATA)/prison_status.do $(PSIDPUB)/Stata/ind2015er.dta
	cd FEM_Stata/Makedata/PSID && $(STATA) prison_status.do

## Consumption for 1999-2013 (after 2013 this is on the family file)
$(DATADIR)/con9913.dta: $(PSIDSTATA)/consumption.do $(PSIDPUB)/Stata/con99.dta $(PSIDPUB)/Stata/con01.dta $(PSIDPUB)/Stata/con03.dta $(PSIDPUB)/Stata/con05.dta $(PSIDPUB)/Stata/con07.dta $(PSIDPUB)/Stata/con09.dta $(PSIDPUB)/Stata/con11.dta $(PSIDPUB)/Stata/con13.dta 
	cd FEM_Stata/Makedata/PSID && $(STATA) consumption.do

$(DATADIR)/psid_analytic.dta: $(PSIDSTATA)/gen_analytic.do $(COMMON2) $(DATADIR)/psid_merge.dta $(DATADIR)/psid_econ.dta $(DATADIR)/prison.dta $(DATADIR)/con9913.dta
	cd FEM_Stata/Makedata/PSID && $(STATA) gen_analytic.do
$(DATADIR)/psid_transition.dta	$(DATADIR)/psid_transition_51plus.dta : $(DATADIR)/psid_hrs_transition.dta
$(DATADIR)/psid_hrs_transition.dta : $(PSIDSTATA)/gen_psid_transition.do $(COMMON2) $(DATADIR)/psid_analytic.dta $(TRANSDATA)
	cd FEM_Stata/Makedata/PSID && $(STATA) gen_psid_transition.do
# Using ACS reweighting. Not using census or CPS reweighting.
#$(DATADIR)/psid_all2009_pop_adjusted.dta: $(PSIDSTATA)/psid_reweight.do $(COMMON2) $(DATADIR)/psid_analytic.dta $(DATADIR)/population_projection.dta expansion.makefile
#	cd FEM_Stata/Makedata/PSID && EXPANDPSID=$(EXPANSION_FACTOR_PSID) $(STATA) psid_reweight.do
#$(DATADIR)/psid_all2009_pop_adjusted_CPS.dta: $(PSIDSTATA)/psid_reweight_CPS.do $(COMMON2) $(DATADIR)/psid_analytic.dta $(DATADIR)/cps2009_demog.dta expansion.makefile
#	cd FEM_Stata/Makedata/PSID && EXPANDPSID=$(EXPANSION_FACTOR_PSID) $(STATA) psid_reweight_CPS.do
$(DATADIR)/psid_all2009_pop_adjusted.dta: $(PSIDSTATA)/psid_reweight_ACS.do $(COMMON2) $(DATADIR)/psid_analytic.dta $(DATADIR)/acs2009_demog.dta expansion.makefile
	cd FEM_Stata/Makedata/PSID && EXPANDPSID=$(EXPANSION_FACTOR_PSID) $(STATA) psid_reweight_ACS.do
$(DATADIR)/psid_all2009_pop_adjusted_2526.dta: $(PSIDSTATA)/psid_reweight_new25.do $(COMMON2) $(DATADIR)/psid_analytic.dta $(DATADIR)/cps2009_demog.dta expansion.makefile $(DATADIR)/pop2526_projection_2081.dta
	cd FEM_Stata/Makedata/PSID && EXPANDPSID=$(EXPANSION_FACTOR_PSID) $(STATA) psid_reweight_new25.do

## gen_stock_psid_2009.do and new25_simulate will all take the reweighted (to 2009) version of psid_analytic.dta as input, psid_all2009_pop_adjusted.dta
$(DATADIR)/stock_psid_2009.dta: $(DATADIR)/stock_psid_2009_51plus.dta
$(DATADIR)/stock_psid_2009_51plus.dta: $(DATADIR)/psid_all2009_pop_adjusted.dta $(PSIDSTATA)/gen_stock_psid_2009.do $(COMMON2) $(PSIDSTATA)/kludge.do $(PSIDSTATA)/drop_vars.do
	cd FEM_Stata/Makedata/PSID && $(STATA) gen_stock_psid_2009.do
$(DATADIR)/psid_crossvalidation.dta: $(PSIDIND) FEM_Stata/Makedata/PSID/crossvalidation_ID_select.do
	cd FEM_Stata/Makedata/PSID && $(STATA) crossvalidation_ID_select.do
$(DATADIR)/stock_psid_1999.dta: FEM_Stata/Makedata/PSID//gen_stock_psid_1999.do $(DATADIR)/psid_crossvalidation.dta $(DATADIR)/psid_analytic.dta $(PSIDSTATA)/drop_vars.do
	cd FEM_Stata/Makedata/PSID && $(STATA) gen_stock_psid_1999.do
$(DATADIR)/age2530_psid1999.dta $(DATADIR)/age2530_psid2009.dta $(DATADIR)/age2530_psid0515.dta: $(DATADIR)/age2526_psid0709.dta
$(DATADIR)/age2526_psid0709.dta: $(PSIDSTATA)/gen_age2530.do $(COMMON2) $(DATADIR)/psid_analytic.dta 	
	cd FEM_Stata/Makedata/PSID && $(STATA) gen_age2530.do
$(DATADIR)/pop2526_projection_2081.dta: $(PSIDSTATA)/psid_proj_2081.do $(COMMON2) $(DATADIR)/pop2526_projection.dta
	cd FEM_Stata/Makedata/PSID && $(STATA) psid_proj_2081.do
$(ESTIMATES)/incoming_separate_psid/laborcat.ster: $(PSIDSTATA)/incoming_separate_estimation.do $(DATADIR)/age2530_psid2009.dta $(UTILITIES)/opti_unc.mo
	cd FEM_Stata/Makedata/PSID && $(STATA) incoming_separate_estimation.do

$(DATADIR)/new25s_default.dta: $(PSIDSTATA)/new25_simulate_development.do $(COMMON2) $(DATADIR)/psid_all2009_pop_adjusted_2526.dta $(PSIDSTATA)/kludge.do $(DATADIR)/pop2526_projection_2081.dta $(ESTIMATES)/incoming_separate_psid/laborcat.ster $(DATADIR)/psid_trend_default.dta expansion.makefile $(PSIDSTATA)/drop_vars.do
	cd FEM_Stata/Makedata/PSID && SCENARIO=default FYEAR=$(FYEAR_PSID) LYEAR=$(LYEAR_PSID) $(STATA) new25_simulate_development.do

$(DATADIR)/new25s_notrend.dta: $(PSIDSTATA)/new25_simulate_development.do $(COMMON2) $(DATADIR)/psid_all2009_pop_adjusted_2526.dta $(PSIDSTATA)/kludge.do $(DATADIR)/pop2526_projection_2081.dta $(ESTIMATES)/incoming_separate_psid/laborcat.ster $(DATADIR)/psid_trend_default.dta expansion.makefile  $(PSIDSTATA)/drop_vars.do
	cd FEM_Stata/Makedata/PSID && SCENARIO=notrend FYEAR=$(FYEAR_PSID) LYEAR=$(LYEAR_PSID) $(STATA) new25_simulate_development.do

$(DATADIR)/new25s_finish_hs.dta: $(PSIDSTATA)/new25_simulate_development.do $(COMMON2) $(DATADIR)/psid_all2009_pop_adjusted_2526.dta $(PSIDSTATA)/kludge.do $(DATADIR)/pop2526_projection_2081.dta $(ESTIMATES)/incoming_separate_psid/laborcat.ster $(DATADIR)/psid_trend_default.dta expansion.makefile 	 $(PSIDSTATA)/drop_vars.do
	cd FEM_Stata/Makedata/PSID && SCENARIO=finish_hs FYEAR=$(FYEAR_PSID) LYEAR=$(LYEAR_PSID) $(STATA) new25_simulate_development.do

$(DATADIR)/new25s_more_coll.dta: $(PSIDSTATA)/new25_simulate_development.do $(COMMON2) $(DATADIR)/psid_all2009_pop_adjusted_2526.dta $(PSIDSTATA)/kludge.do $(DATADIR)/pop2526_projection_2081.dta $(ESTIMATES)/incoming_separate_psid/laborcat.ster $(DATADIR)/psid_trend_default.dta expansion.makefile  $(PSIDSTATA)/drop_vars.do	
	cd FEM_Stata/Makedata/PSID && SCENARIO=more_coll FYEAR=$(FYEAR_PSID) LYEAR=$(LYEAR_PSID)  $(STATA) new25_simulate_development.do

$(DATADIR)/new25s_no_obese.dta: $(PSIDSTATA)/new25_simulate_development.do $(COMMON2) $(DATADIR)/psid_all2009_pop_adjusted_2526.dta $(PSIDSTATA)/kludge.do $(DATADIR)/pop2526_projection_2081.dta $(ESTIMATES)/incoming_separate_psid/laborcat.ster $(DATADIR)/psid_trend_default.dta expansion.makefile 	 $(PSIDSTATA)/drop_vars.do
	cd FEM_Stata/Makedata/PSID && SCENARIO=no_obese FYEAR=$(FYEAR_PSID) LYEAR=$(LYEAR_PSID)  $(STATA) new25_simulate_development.do

taxsim:
	cd FEM_Stata/Makedata/PSID && $(STATA) psid_taxsim_1.do
	cd FEM_Stata/Makedata/PSID && $(STATA) psid_taxsim_2.do
	cd FEM_Stata/Makedata/PSID && $(STATA) psid_taxsim_3.do

## Joint estimation for PSID

$(DATADIR)/psid_incoming_vcmatrix.dta $(DATADIR)/psid_incoming_means.dta: $(DATADIR)/psid_incoming_cut_points.dta
$(DATADIR)/psid_incoming_cut_points.dta: FEM_Stata/Makedata/PSID/joint_initcond.do $(DATADIR)/age2530_psid0515.dta stata_extensions.txt
	cd FEM_Stata/Makedata/PSID/ && $(STATA) joint_initcond.do

## Trends for new 25 year old creation in PSID

$(DATADIR)/psid_trend_default.dta: FEM_Stata/Makedata/POPULATION/psid_generate_trends_final.do $(DATADIR)/obesity_projections_2130_since90_2010.dta $(DATADIR)/acs_trends_forecast_final.dta $(DATADIR)/nhis_hbp_smk_projections.dta
	cd FEM_Stata/Makedata/POPULATION/ && $(STATA) psid_generate_trends_final.do 
