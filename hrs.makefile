## HRS Make Rules
## These rules include a dummy file called new51s_complete.txt so we don't have to rely on knowing the last new5152 file created.
COMMON = FEM_Stata/Makedata/HRS/common.do fem_env.do stata_extensions.txt
INIT_EST = $(RESTIMATES)/minit_diclaim $(RESTIMATES)/minit_hatota $(RESTIMATES)/minit_ssiclaim $(RESTIMATES)/sinit_diclaim $(RESTIMATES)/sinit_hatota $(RESTIMATES)/sinit_logtenure $(RESTIMATES)/sinit_ssiclaim 

## Install any of the needed Stata extensions
stata_extensions.txt: stata_extensions.do
	$(STATA) stata_extensions.do

$(DATADIR)/hrs_analytic_recoded.dta: $(COMMON)  FEM_Stata/Makedata/HRS/recode.do $(DATADIR)/hrs_analytic.dta
	cd FEM_Stata/Makedata/HRS && $(STATA) recode.do

$(DATADIR)/nh_weights.dta: $(COMMON) FEM_Stata/Makedata/HRS/process_tracker.do  $(HRSPUB)/Stata/trk2014tr_r.dta
	cd FEM_Stata/Makedata/HRS && $(STATA) process_tracker.do

$(DATADIR)/hrs_analytic.dta: $(COMMON)  FEM_Stata/Makedata/HRS/gen_analytic_file.do FEM_Stata/Makedata/HRS/fatvars.do $(RANDHRS) $(DATADIR)/gkcarehours.dta $(DATADIR)/helphours.dta $(DATADIR)/parhelp.dta $(DATADIR)/volhours.dta $(HRSPUB)/Stata/rndfamr.dta $(DATADIR)/proptximp.dta $(BASEDIR)/lbrf.dta $(BASEDIR)/ipw.dta $(HRSSENSITIVE)/Stata/dbpen_hrs.dta $(DATADIR)/nh_weights.dta
	cd FEM_Stata/Makedata/HRS && $(STATA) gen_analytic_file.do

$(DATADIR)/BMI_initial_values.dta: $(COMMON) FEM_Stata/Makedata/HRS/BMI_initial_values.do $(HRSPUB)/RAND-HRS/rndhrs_$(RANDVER).dta $(DATADIR)/NHANES_bmi_cohort_qtls.dta
	cd FEM_Stata/Makedata/HRS && $(STATA) BMI_initial_values.do

$(DATADIR)/tics_imputed.dta $(DATADIR)/tics.dta: $(COMMON)  FEM_Stata/Makedata/HRS/prep_hrs_cognitive.do $(RANDHRS) 
	cd FEM_Stata/Makedata/HRS && $(STATA) prep_hrs_cognitive.do

$(DATADIR)/hrs_selected.dta: $(COMMON)  FEM_Stata/Makedata/HRS/hrs_select.do $(DATADIR)/hrs_analytic_recoded.dta $(DATADIR)/BMI_initial_values.dta $(DATADIR)/tics.dta
	cd FEM_Stata/Makedata/HRS && $(STATA) hrs_select.do

$(DATADIR)/hrs112_transition.dta: $(DATADIR)/hrs112.dta
$(DATADIR)/hrs112.dta: $(COMMON) $(DATADIR)/hrs_selected.dta  FEM_Stata/Makedata/HRS/transition_select.do
	cd FEM_Stata/Makedata/HRS && $(STATA) transition_select.do

$(DATADIR)/exit_alzhe2010.dta: $(COMMON) FEM_Stata/Makedata/HRS/process_exitivws.do  $(HRSPUB)/ExitIvws/X2010/Stata/X10C_R.dta
	cd FEM_Stata/Makedata/HRS && $(STATA) process_exitivws.do

$(DATADIR)/all2004.dta: $(COMMON) $(DATADIR)/hrs_selected.dta  FEM_Stata/Makedata/HRS/all2004_select.do
	cd FEM_Stata/Makedata/HRS && $(STATA) all2004_select.do

$(DATADIR)/all1998.dta: $(COMMON) $(DATADIR)/hrs_selected.dta  FEM_Stata/Makedata/HRS/all1998_select.do
	cd FEM_Stata/Makedata/HRS && $(STATA) all1998_select.do

$(DATADIR)/all2010.dta: $(COMMON) $(DATADIR)/hrs_selected.dta $(DATADIR)/exit_alzhe2010.dta  FEM_Stata/Makedata/HRS/all2010_select.do
	cd FEM_Stata/Makedata/HRS && $(STATA) all2010_select.do


$(DATADIR)/age5055_hrs1998.dta $(DATADIR)/age5055_hrs2004.dta $(DATADIR)/age5055_hrs2010.dta: $(DATADIR)/age5055_hrs1992.dta
$(DATADIR)/age5055_hrs1992.dta: $(COMMON) $(DATADIR)/hrs_selected.dta  FEM_Stata/Makedata/HRS/initial1992_select.do
	cd FEM_Stata/Makedata/HRS && $(STATA) initial1992_select.do

$(HRSDIR)/aime_all.dta: $(COMMON) $(HRSDIR)/ssa_92.dta $(HRSDIR)/ssa_93.dta $(HRSDIR)/ssa_98.dta $(HRSDIR)/ssa_04.dta  $(UTILITIES)/aimeUS_v3.ado  FEM_Stata/Makedata/HRS/aime_gen_all.do $(DATADIR)/hrs_analytic_recoded.dta $(DATADIR)/cnatwage.dta $(DATADIR)/earnlimit.dta
	cd FEM_Stata/Makedata/HRS && $(STATA) aime_gen_all.do

#### Start of conditional check for restricted data
ifneq ($(findstring XSumErn.dta,$(wildcard $(HRSRESTRICT)/*.dta)), )
$(HRSDIR)/ssa_93.dta $(HRSDIR)/ssa_98.dta $(HRSDIR)/ssa_04.dta: $(HRSDIR)/ssa_92.dta 
$(HRSDIR)/ssa_92.dta : $(COMMON) FEM_Stata/Makedata/HRS/process_xsumern.do $(HRSRESTRICT)/XSumErn.dta
	cd FEM_Stata/Makedata/HRS && $(STATA) process_xsumern.do
$(HRSDIR)/age5055_hrs1992r.dta: $(COMMON)  FEM_Stata/Makedata/HRS/merge_aime_age5055.do $(HRSDIR)/aime_all.dta $(DATADIR)/age5055_hrs1992.dta
	cd FEM_Stata/Makedata/HRS && YEAR=1992 $(STATA) merge_aime_age5055.do
$(HRSDIR)/age5055_hrs1998r.dta: $(COMMON)  FEM_Stata/Makedata/HRS/merge_aime_age5055.do $(HRSDIR)/aime_all.dta $(DATADIR)/age5055_hrs1998.dta
	cd FEM_Stata/Makedata/HRS && YEAR=1998 $(STATA) merge_aime_age5055.do
$(HRSDIR)/age5055_hrs2004r.dta: $(COMMON)  FEM_Stata/Makedata/HRS/merge_aime_age5055.do $(HRSDIR)/aime_all.dta $(DATADIR)/age5055_hrs2004.dta
	cd FEM_Stata/Makedata/HRS && YEAR=2004 $(STATA) merge_aime_age5055.do
$(HRSDIR)/all2004r.dta: $(COMMON)  FEM_Stata/Makedata/HRS/merge_aime_all.do $(HRSDIR)/aime_all.dta $(DATADIR)/all2004.dta
	cd FEM_Stata/Makedata/HRS && YEAR=2004 $(STATA) merge_aime_all.do
$(HRSDIR)/all1998r.dta: $(COMMON)  FEM_Stata/Makedata/HRS/merge_aime_all.do $(HRSDIR)/aime_all.dta $(DATADIR)/all1998.dta
	cd FEM_Stata/Makedata/HRS && YEAR=1998 $(STATA) merge_aime_all.do
$(HRSDIR)/hrs112r.dta: $(COMMON)  FEM_Stata/Makedata/HRS/merge_aime_hrs.do $(HRSDIR)/aime_all.dta $(DATADIR)/hrs112.dta
	cd FEM_Stata/Makedata/HRS && $(STATA) merge_aime_hrs.do
$(HRSDIR)/hrs112r_transition.dta.dta: $(COMMON)  FEM_Stata/Makedata/HRS/merge_aime_transition.do $(HRSDIR)/aime_all.dta $(DATADIR)/hrs112_transition.dta
	cd FEM_Stata/Makedata/HRS && $(STATA) merge_aime_transition.do
$(HRSDIR)/all1998r_pop_adjusted.dta: $(COMMON)  FEM_Stata/Makedata/HRS/all1998_weightadjust.do $(DATADIR)/population_projection_1998.dta $(HRSDIR)/all1998r.dta $(DATADIR)/death_counts.dta
	cd FEM_Stata/Makedata/HRS && DATAIN=$(HRSDIR)/all1998r.dta DATAOUT=$(HRSDIR)/all1998r_pop_adjusted.dta $(STATA) all1998_weightadjust.do

$(HRSDIR)/all2004r_pop_adjusted.dta: $(COMMON)  FEM_Stata/Makedata/HRS/all2004_weightadjust.do $(DATADIR)/population_projection.dta $(HRSDIR)/all2004r.dta $(DATADIR)/death_counts.dta
	cd FEM_Stata/Makedata/HRS && DATAIN=$(HRSDIR)/all2004r.dta DATAOUT=$(HRSDIR)/all2004r_pop_adjusted.dta $(STATA) all2004_weightadjust.do

$(RESTIMATES)/fraime2004.ster $(RESTIMATES)/fraime_nonzero2004.ster $(RESTIMATES)/flogq2004.ster $(RESTIMATES)/rpia2004.ster: $(HRSDIR)/stock_hrs_2004.dta
$(HRSDIR)/stock_hrs_2004.dta: $(COMMON)  FEM_Stata/Makedata/HRS/save_stock_hrs_2004.do $(HRSDIR)/all2004r_pop_adjusted.dta $(UTILITIES)/multiply_persons.ado expansion.makefile
	cd FEM_Stata/Makedata/HRS && EXPAND=$(EXPANSION_FACTOR) $(STATA) save_stock_hrs_2004.do

$(RESTIMATES)/fraime1998.ster $(RESTIMATES)/fraime_nonzero1998.ster $(RESTIMATES)/flogq1998.ster $(RESTIMATES)/rpia1998.ster: $(HRSDIR)/stock_hrs_1998.dta
$(HRSDIR)/stock_hrs_1998.dta: $(COMMON) FEM_Stata/Makedata/HRS/save_stock_hrs_1998.do $(HRSDIR)/all1998r_pop_adjusted.dta $(DATADIR)/crossvalidation.dta
	cd FEM_Stata/Makedata/HRS && $(STATA) save_stock_hrs_1998.do

$(INIT_EST) $(DATADIR)/new51_wlth2004.dta: $(RESTIMATES)/minit_logtenure
$(RESTIMATES)/minit_logtenure: $(COMMON) $(HRSDIR)/age5055_hrs1992r.dta $(DATADIR)/age5055_hrs2004.dta $(DATADIR)/age5055_hrs2010.dta FEM_Stata/Makedata/HRS/incoming_separate_estimation.do $(UTILITIES)/_putestimates.mo
	cd FEM_Stata/Makedata/HRS && $(STATA) incoming_separate_estimation.do

endif
#### End of conditional check for restricted data

$(DATADIR)/all2004_pop_adjusted.dta: $(COMMON) FEM_Stata/Makedata/HRS/all2004_weightadjust.do $(DATADIR)/population_projection.dta $(DATADIR)/all2004.dta $(DATADIR)/death_counts.dta
	cd FEM_Stata/Makedata/HRS && DATAIN=$(DATADIR)/all2004.dta DATAOUT=$(DATADIR)/all2004_pop_adjusted.dta $(STATA) all2004_weightadjust.do

$(DATADIR)/all2010_pop_adjusted.dta: $(COMMON) FEM_Stata/Makedata/HRS/all2010_weightadjust.do $(DATADIR)/population_projection.dta $(DATADIR)/all2010.dta $(DATADIR)/death_counts.dta
	cd FEM_Stata/Makedata/HRS && DATAIN=$(DATADIR)/all2010.dta DATAOUT=$(DATADIR)/all2010_pop_adjusted.dta $(STATA) all2010_weightadjust.do

$(DATADIR)/stock_hrs_2004.dta: $(COMMON) $(RESTIMATES)/fraime2004.ster $(RESTIMATES)/fraime_nonzero2004.ster $(RESTIMATES)/flogq2004.ster $(RESTIMATES)/rpia2004.ster FEM_Stata/Makedata/HRS/save_stock_hrs_2004_faked.do $(DATADIR)/all2004_pop_adjusted.dta $(UTILITIES)/multiply_persons.ado expansion.makefile
	cd FEM_Stata/Makedata/HRS && EXPAND=$(EXPANSION_FACTOR) $(STATA) save_stock_hrs_2004_faked.do

$(DATADIR)/imputed_ssa_ret.dta: $(DATADIR)/imputed_ssa_notret.dta
$(DATADIR)/imputed_ssa_notret.dta: FEM_Stata/Makedata/HRS/assign_ssa.do $(RESTIMATES)/ret/ssa_means.dta $(RESTIMATES)/ret/ssa_vcmatrix.dta $(RESTIMATES)/ret/ssa_cut_points.dta $(RESTIMATES)/notret/ssa_means.dta $(RESTIMATES)/notret/ssa_vcmatrix.dta $(RESTIMATES)/notret/ssa_cut_points.dta $(DATADIR)/all2010_pop_adjusted.dta $(RESTIMATES)/ret/anyrq.ster $(RESTIMATES)/notret/anyrq.ster
	cd FEM_Stata/Makedata/HRS && $(STATA) assign_ssa.do

$(DATADIR)/input_rep%/imputed_ssa_notret.dta: FEM_Stata/Makedata/HRS/assign_ssa.do $(RESTIMATES)/ret/ssa_means.dta $(RESTIMATES)/ret/ssa_vcmatrix.dta $(RESTIMATES)/ret/ssa_cut_points.dta $(RESTIMATES)/notret/ssa_means.dta $(RESTIMATES)/notret/ssa_vcmatrix.dta $(RESTIMATES)/notret/ssa_cut_points.dta $(DATADIR)/input_rep%/all2010_pop_adjusted.dta $(RESTIMATES)/ret/anyrq.ster $(RESTIMATES)/notret/anyrq.ster
	cd FEM_Stata/Makedata/HRS && BREP=$* $(STATA) assign_ssa.do

$(DATADIR)/stock_hrs_2010.dta: $(COMMON) $(RESTIMATES)/fraime2004.ster $(RESTIMATES)/fraime_nonzero2004.ster $(RESTIMATES)/flogq2004.ster $(RESTIMATES)/rpia2004.ster FEM_Stata/Makedata/HRS/save_stock_hrs_2010_faked.do $(DATADIR)/all2010_pop_adjusted.dta $(UTILITIES)/multiply_persons.ado expansion.makefile $(DATADIR)/imputed_ssa_ret.dta $(DATADIR)/imputed_ssa_notret.dta
	cd FEM_Stata/Makedata/HRS && EXPAND=$(EXPANSION_FACTOR) $(STATA) save_stock_hrs_2010_faked.do

$(DATADIR)/crossvalidation.dta: $(COMMON)  FEM_Stata/Makedata/HRS/ID_selection_for_crossvalidation.do 
	cd FEM_Stata/Makedata/HRS && $(STATA) ID_selection_for_crossvalidation.do 

$(DATADIR)/all1998_pop_adjusted.dta: $(COMMON)  FEM_Stata/Makedata/HRS/all1998_weightadjust.do $(DATADIR)/population_projection_1998.dta $(DATADIR)/all1998.dta $(DATADIR)/death_counts.dta
	cd FEM_Stata/Makedata/HRS && DATAIN=$(DATADIR)/all1998.dta DATAOUT=$(DATADIR)/all1998_pop_adjusted.dta $(STATA) all1998_weightadjust.do

$(DATADIR)/stock_hrs_1998.dta: $(COMMON)  FEM_Stata/Makedata/HRS/save_stock_hrs_1998_faked.do $(DATADIR)/all1998_pop_adjusted.dta $(RESTIMATES)/fraime1998.ster $(RESTIMATES)/fraime_nonzero1998.ster $(RESTIMATES)/flogq1998.ster $(RESTIMATES)/rpia1998.ster $(DATADIR)/crossvalidation.dta
	cd FEM_Stata/Makedata/HRS && $(STATA) save_stock_hrs_1998_faked.do

$(DATADIR)/sinit_deprsymp $(DATADIR)/new51_painstat.ster $(DATADIR)/new51_adlstat.ster $(DATADIR)/new51_iadlstat.ster: $(DATADIR)/minit_deprsymp
$(DATADIR)/minit_deprsymp: $(COMMON) $(DATADIR)/age5055_hrs2004.dta  FEM_Stata/Makedata/HRS/incoming_separate_estimation_deprsymp.do $(UTILITIES)/_putestimates.mo
	cd FEM_Stata/Makedata/HRS && $(STATA) incoming_separate_estimation_deprsymp.do

$(DATADIR)/incoming_base.dta: $(COMMON) $(DATADIR)/hrs_selected.dta $(DATADIR)/pop5152_projection_2150.dta  FEM_Stata/Makedata/HRS/new51_select.do $(UTILITIES)/multiply_persons.ado expansion.makefile
	cd FEM_Stata/Makedata/HRS && EXPAND=$(EXPANSION_FACTOR) DATAIN=$(DATADIR)/hrs_selected.dta DATAOUT=$(DATADIR)/incoming_base.dta $(STATA) new51_select.do

ifneq ($(findstring XSumErn.dta,$(wildcard $(HRSRESTRICT)/*.dta)), )

$(DATADIR)/new51s_status_quo.dta: $(COMMON) $(DATADIR)/pop5152_projection_2150.dta $(DATADIR)/age5055_hrs1992.dta $(DATADIR)/age5055_hrs2004.dta $(DATADIR)/trend_all_status_quo.dta $(BASEDIR)/incoming_vcmatrix.dta $(BASEDIR)/incoming_means_econ_tos.dta $(BASEDIR)/incoming_means.dta $(BASEDIR)/incoming_means_econ.dta $(UTILITIES)/_getestimates.mo $(INIT_EST) $(RESTIMATES)/minit_logtenure $(DATADIR)/minit_deprsymp $(DATADIR)/sinit_deprsymp $(DATADIR)/new51_painstat.ster $(DATADIR)/new51_adlstat.ster $(DATADIR)/new51_iadlstat.ster $(DATADIR)/incoming_base.dta  FEM_Stata/Makedata/HRS/new51_simulate.do  $(BASEDIR)/incoming_cut_points.dta $(UTILITIES)/calc_cut_point.ado $(UTILITIES)/calc_cut_point_ml.ado $(UTILITIES)/new_deviation.ado $(RESTIMATES)/ssa_means.dta $(RESTIMATES)/ssa_vcmatrix.dta
	cd FEM_Stata/Makedata/HRS && SCENARIO=status_quo TREND=status_quo BREP=0 RES=1 FYEAR=$(FYEAR) LYEAR=$(LYEAR) $(STATA) new51_simulate.do
else
$(DATADIR)/new51s_status_quo.dta: $(COMMON) $(DATADIR)/pop5152_projection_2150.dta $(DATADIR)/age5055_hrs1992.dta $(DATADIR)/age5055_hrs2004.dta $(DATADIR)/trend_all_status_quo.dta $(BASEDIR)/incoming_vcmatrix.dta $(BASEDIR)/incoming_means_econ_tos.dta $(BASEDIR)/incoming_means.dta $(BASEDIR)/incoming_means_econ.dta $(UTILITIES)/_getestimates.mo $(INIT_EST) $(RESTIMATES)/minit_logtenure $(DATADIR)/minit_deprsymp $(DATADIR)/sinit_deprsymp $(DATADIR)/new51_painstat.ster $(DATADIR)/new51_adlstat.ster $(DATADIR)/new51_iadlstat.ster $(DATADIR)/incoming_base.dta  FEM_Stata/Makedata/HRS/new51_simulate.do  $(BASEDIR)/incoming_cut_points.dta $(UTILITIES)/calc_cut_point.ado $(UTILITIES)/calc_cut_point_ml.ado $(UTILITIES)/new_deviation.ado $(RESTIMATES)/ssa_means.dta $(RESTIMATES)/ssa_vcmatrix.dta
	cd FEM_Stata/Makedata/HRS && SCENARIO=status_quo TREND=status_quo BREP=0 RES=0 FYEAR=$(FYEAR) LYEAR=$(LYEAR) $(STATA) new51_simulate.do
endif

## Rules for the SAS programs used in Makedata
## Six sets of files:  Gkidcare, Helper, Parhelp, PropTax, Volunteer, transfers_tokids

$(DATADIR)/gkcarehours.sas7bdat: fem_env.sas FEM_Sas/HRS/Gkidcare/gkcarehours.sas $(DATADIR)/gkcareimp98.sas7bdat $(DATADIR)/gkcareimp00.sas7bdat $(DATADIR)/gkcareimp02.sas7bdat $(DATADIR)/gkcareimp04.sas7bdat $(DATADIR)/gkcareimp06.sas7bdat $(DATADIR)/gkcareimp08.sas7bdat $(DATADIR)/gkcareimp10.sas7bdat $(HRSPUB)/SAS/rndhrs_$(RANDVER).sas7bdat 
	cd FEM_Sas/HRS/Gkidcare && $(SAS) gkcarehours.sas

ifeq ($(SASSTAT), 1)
$(DATADIR)/gkcareimp00.sas7bdat $(DATADIR)/gkcareimp02.sas7bdat $(DATADIR)/gkcareimp04.sas7bdat $(DATADIR)/gkcareimp06.sas7bdat $(DATADIR)/gkcareimp08.sas7bdat $(DATADIR)/gkcareimp10.sas7bdat: $(DATADIR)/gkcareimp98.sas7bdat
$(DATADIR)/gkcareimp98.sas7bdat: fem_env.sas FEM_Sas/HRS/Gkidcare/gkcareimp.sas $(DATADIR)/prep_gkcare98.sas7bdat $(DATADIR)/prep_gkcare00.sas7bdat $(DATADIR)/prep_gkcare02.sas7bdat $(DATADIR)/prep_gkcare04.sas7bdat $(DATADIR)/prep_gkcare06.sas7bdat $(DATADIR)/prep_gkcare08.sas7bdat
	cd FEM_Sas/HRS/Gkidcare && $(SAS) gkcareimp.sas  
endif

$(DATADIR)/prep_gkcare00.sas7bdat $(DATADIR)/prep_gkcare02.sas7bdat $(DATADIR)/prep_gkcare04.sas7bdat $(DATADIR)/prep_gkcare06.sas7bdat $(DATADIR)/prep_gkcare08.sas7bdat: $(DATADIR)/prep_gkcare98.sas7bdat
$(DATADIR)/prep_gkcare98.sas7bdat: fem_env.sas FEM_Sas/HRS/Gkidcare/prep_gkcare.sas $(HRSPUB)/SAS/rndfamr.sas7bdat $(HRSPUB)/SAS/rndhrs_$(RANDVER).sas7bdat $(HRSPUB)/SAS/hrs98.sas7bdat $(HRSPUB)/SAS/hrs00.sas7bdat $(HRSPUB)/SAS/hrs02.sas7bdat $(HRSPUB)/SAS/hrs04.sas7bdat $(HRSPUB)/SAS/hrs06.sas7bdat $(HRSPUB)/SAS/hrs08.sas7bdat $(HRSPUB)/SAS/hrs10.sas7bdat $(HRSPUB)/SAS/hrsxregion.sas7bdat $(HRSPUB)/SAS/formats.sas7bcat
	cd FEM_Sas/HRS/Gkidcare && $(SAS) prep_gkcare.sas 

$(DATADIR)/helphours.sas7bdat: fem_env.sas FEM_Sas/HRS/Helper/helphours.sas $(DATADIR)/helpimpr98.sas7bdat $(DATADIR)/helpimpr00.sas7bdat $(DATADIR)/helpimpr02.sas7bdat $(DATADIR)/helpimpr04.sas7bdat $(DATADIR)/helpimpr06.sas7bdat $(DATADIR)/helpimpr08.sas7bdat $(DATADIR)/helpimpr08.sas7bdat $(DATADIR)/helpimpr10.sas7bdat $(DATADIR)/helpimpr12.sas7bdat $(DATADIR)/helpimpr14.sas7bdat $(HRSPUB)/SAS/rndhrs_$(RANDVER).sas7bdat $(HRSPUB)/SAS/formats.sas7bcat
	cd FEM_Sas/HRS/Helper && $(SAS) helphours.sas

ifeq ($(SASSTAT), 1)
$(DATADIR)/helpimpr00.sas7bdat $(DATADIR)/helpimpr02.sas7bdat $(DATADIR)/helpimpr04.sas7bdat $(DATADIR)/helpimpr06.sas7bdat $(DATADIR)/helpimpr08.sas7bdat $(DATADIR)/helpimpr10.sas7bdat $(DATADIR)/helpimpr12.sas7bdat $(DATADIR)/helpimpr14.sas7bdat: $(DATADIR)/helpimpr98.sas7bdat
$(DATADIR)/helpimpr98.sas7bdat: fem_env.sas FEM_Sas/HRS/Helper/helpimpR.sas $(DATADIR)/helpimp98.sas7bdat $(DATADIR)/helpimp00.sas7bdat $(DATADIR)/helpimp02.sas7bdat $(DATADIR)/helpimp04.sas7bdat $(DATADIR)/helpimp06.sas7bdat $(DATADIR)/helpimp08.sas7bdat $(DATADIR)/helpimp10.sas7bdat $(DATADIR)/helpimp12.sas7bdat 
	cd FEM_Sas/HRS/Helper && $(SAS) helpimpR.sas

$(DATADIR)/helpimp98.sas7bdat: fem_env.sas FEM_Sas/HRS/Helper/helpimp98.sas $(DATADIR)/prephelp98.sas7bdat $(DATADIR)/helpimp00.sas7bdat FEM_Sas/HRS/Helper/helprange.inc FEM_Sas/HRS/Helper/helpimp.mac
	cd FEM_Sas/HRS/Helper && $ /usr/local/bin/sas helpimp98.sas

$(DATADIR)/helpimp02.sas7bdat $(DATADIR)/helpimp04.sas7bdat $(DATADIR)/helpimp06.sas7bdat $(DATADIR)/helpimp08.sas7bdat $(DATADIR)/helpimp10.sas7bdat $(DATADIR)/helpimp12.sas7bdat: $(DATADIR)/helpimp00.sas7bdat
$(DATADIR)/helpimp00.sas7bdat: fem_env.sas FEM_Sas/HRS/Helper/helpimp.sas $(DATADIR)/prephelp00.sas7bdat $(DATADIR)/prephelp02.sas7bdat $(DATADIR)/prephelp04.sas7bdat $(DATADIR)/prephelp06.sas7bdat $(DATADIR)/prephelp08.sas7bdat $(DATADIR)/prephelp10.sas7bdat $(DATADIR)/prephelp12.sas7bdat $(DATADIR)/prephelp14.sas7bdat
	cd FEM_Sas/HRS/Helper && $ /usr/local/bin/sas helpimp.sas

endif

$(DATADIR)/prephelp98.sas7bdat: fem_env.sas FEM_Sas/HRS/Helper/prephelp98.sas $(DATADIR)/helper98.sas7bdat $(HRSPUB)/SAS/rndhrs_$(RANDVER).sas7bdat $(HRSPUB)/SAS/formats.sas7bcat
	cd FEM_Sas/HRS/Helper && $(SAS) prephelp98.sas 

$(DATADIR)/prephelp02.sas7bdat $(DATADIR)/prephelp04.sas7bdat $(DATADIR)/prephelp06.sas7bdat $(DATADIR)/prephelp08.sas7bdat $(DATADIR)/prephelp10.sas7bdat $(DATADIR)/prephelp12.sas7bdat $(DATADIR)/prephelp14.sas7bdat: $(DATADIR)/prephelp00.sas7bdat
$(DATADIR)/prephelp00.sas7bdat: fem_env.sas FEM_Sas/HRS/Helper/prephelp.sas $(DATADIR)/helper00.sas7bdat $(DATADIR)/helper02.sas7bdat $(DATADIR)/helper04.sas7bdat $(DATADIR)/helper06.sas7bdat $(DATADIR)/helper08.sas7bdat $(DATADIR)/helper10.sas7bdat $(DATADIR)/helper12.sas7bdat $(DATADIR)/helper14.sas7bdat $(HRSPUB)/SAS/rndhrs_$(RANDVER).sas7bdat $(HRSPUB)/SAS/formats.sas7bcat	
	cd FEM_Sas/HRS/Helper && $(SAS) prephelp.sas

$(DATADIR)/helper14.sas7bdat: fem_env.sas FEM_Sas/HRS/Helper/Helper/helper14.sas $(HRSPUB)/SAS/h14g_hp.sas7bdat FEM_Sas/HRS/Fmt/helper.fmt FEM_Sas/HRS/Helper/Helper/cleanhlp02_.inc 
	cd FEM_Sas/HRS/Helper/Helper && $(SAS) helper14.sas

$(DATADIR)/helper12.sas7bdat: fem_env.sas FEM_Sas/HRS/Helper/Helper/helper12.sas $(HRSPUB)/SAS/h12g_hp.sas7bdat FEM_Sas/HRS/Fmt/helper.fmt FEM_Sas/HRS/Helper/Helper/cleanhlp02_.inc 
	cd FEM_Sas/HRS/Helper/Helper && $(SAS) helper12.sas

$(DATADIR)/helper10.sas7bdat: fem_env.sas FEM_Sas/HRS/Helper/Helper/helper10.sas $(HRSPUB)/SAS/h10g_hp.sas7bdat FEM_Sas/HRS/Fmt/helper.fmt FEM_Sas/HRS/Helper/Helper/cleanhlp02_.inc
	cd FEM_Sas/HRS/Helper/Helper && $(SAS) helper10.sas

$(DATADIR)/helper08.sas7bdat: fem_env.sas FEM_Sas/HRS/Helper/Helper/helper08.sas $(HRSPUB)/SAS/h08g_hp.sas7bdat FEM_Sas/HRS/Fmt/helper.fmt FEM_Sas/HRS/Helper/Helper/cleanhlp02_.inc
	cd FEM_Sas/HRS/Helper/Helper && $(SAS) helper08.sas

$(DATADIR)/helper06.sas7bdat: fem_env.sas FEM_Sas/HRS/Helper/Helper/helper06.sas $(HRSPUB)/SAS/h06g_hp.sas7bdat FEM_Sas/HRS/Fmt/helper.fmt FEM_Sas/HRS/Helper/Helper/cleanhlp02_.inc
	cd FEM_Sas/HRS/Helper/Helper && $(SAS) helper06.sas

$(DATADIR)/helper04.sas7bdat: fem_env.sas FEM_Sas/HRS/Helper/Helper/helper04.sas $(HRSPUB)/SAS/h04g_hp.sas7bdat FEM_Sas/HRS/Fmt/helper.fmt FEM_Sas/HRS/Helper/Helper/cleanhlp02_.inc
	cd FEM_Sas/HRS/Helper/Helper && $(SAS) helper04.sas

$(DATADIR)/helper02.sas7bdat: fem_env.sas FEM_Sas/HRS/Helper/Helper/helper02.sas $(HRSPUB)/SAS/h02g_hp.sas7bdat FEM_Sas/HRS/Fmt/helper.fmt FEM_Sas/HRS/Helper/Helper/cleanhlp02_.inc
	cd FEM_Sas/HRS/Helper/Helper && $(SAS) helper02.sas

$(DATADIR)/helper00.sas7bdat: fem_env.sas FEM_Sas/HRS/Helper/Helper/helper00.sas $(HRSPUB)/SAS/h00e_hp.sas7bdat FEM_Sas/HRS/Fmt/helper.fmt FEM_Sas/HRS/Fmt/rkid.fmt FEM_Sas/HRS/Helper/Helper/cleanhlp.mac
	cd FEM_Sas/HRS/Helper/Helper && $(SAS) helper00.sas

$(DATADIR)/helper98.sas7bdat: fem_env.sas FEM_Sas/HRS/Helper/Helper/helper98.sas $(HRSPUB)/SAS/h98e_hp.sas7bdat FEM_Sas/HRS/Fmt/helper.fmt FEM_Sas/HRS/Fmt/rkid.fmt FEM_Sas/HRS/Helper/Helper/cleanhlp.mac
	cd FEM_Sas/HRS/Helper/Helper && $(SAS) helper98.sas

$(DATADIR)/parhelp.sas7bdat: fem_env.sas $(SAS) FEM_Sas/HRS/Parhelp/parhelp.sas $(HRSPUB)/SAS/rndhrs_$(RANDVER).sas7bdat $(HRSPROJECTS)/Datalib/Data/Parents/parents1b.sas7bdat
	cd FEM_Sas/HRS/Parhelp && $(SAS) parhelp.sas 

$(DATADIR)/volhours.sas7bdat: fem_env.sas FEM_Sas/HRS/Volunteer/volhours.sas $(DATADIR)/volimp98.sas7bdat $(DATADIR)/volimp00.sas7bdat $(DATADIR)/volimp02.sas7bdat $(DATADIR)/volimp04.sas7bdat $(DATADIR)/volimp06.sas7bdat $(DATADIR)/volimp08.sas7bdat $(DATADIR)/volimp10.sas7bdat $(DATADIR)/volimp12.sas7bdat $(HRSPUB)/SAS/rndhrs_$(RANDVER).sas7bdat
	cd FEM_Sas/HRS/Volunteer && $(SAS) volhours.sas

ifeq ($(SASSTAT), 1)
$(DATADIR)/volimp00.sas7bdat $(DATADIR)/volimp02.sas7bdat $(DATADIR)/volimp04.sas7bdat $(DATADIR)/volimp06.sas7bdat $(DATADIR)/volimp08.sas7bdat $(DATADIR)/volimp10.sas7bdat $(DATADIR)/volimp12.sas7bdat: $(DATADIR)/volimp98.sas7bdat
$(DATADIR)/volimp98.sas7bdat: fem_env.sas FEM_Sas/HRS/Volunteer/volimp.sas $(DATADIR)/prep_vol98.sas7bdat $(DATADIR)/prep_vol00.sas7bdat $(DATADIR)/prep_vol02.sas7bdat $(DATADIR)/prep_vol04.sas7bdat $(DATADIR)/prep_vol06.sas7bdat $(DATADIR)/prep_vol08.sas7bdat $(DATADIR)/prep_vol10.sas7bdat $(DATADIR)/prep_vol12.sas7bdat
	cd FEM_Sas/HRS/Volunteer && /usr/local/bin/sas volimp.sas 
endif

$(DATADIR)/prep_vol00.sas7bdat $(DATADIR)/prep_vol02.sas7bdat $(DATADIR)/prep_vol04.sas7bdat $(DATADIR)/prep_vol06.sas7bdat $(DATADIR)/prep_vol08.sas7bdat $(DATADIR)/prep_vol10.sas7bdat $(DATADIR)/prep_vol12.sas7bdat: $(DATADIR)/prep_vol98.sas7bdat
$(DATADIR)/prep_vol98.sas7bdat: fem_env.sas FEM_Sas/HRS/Volunteer/prep_vol.sas $(HRSPUB)/SAS/rndhrs_$(RANDVER).sas7bdat $(HRSPUB)/SAS/hrs98.sas7bdat $(HRSPUB)/SAS/hrs00.sas7bdat $(HRSPUB)/SAS/hrs02.sas7bdat $(HRSPUB)/SAS/hrs04.sas7bdat $(HRSPUB)/SAS/hrs06.sas7bdat $(HRSPUB)/SAS/hrs08.sas7bdat $(HRSPUB)/SAS/hrs10.sas7bdat $(HRSPUB)/SAS/hrs12.sas7bdat $(HRSPUB)/SAS/hrsxregion.sas7bdat
	cd FEM_Sas/HRS/Volunteer && $(SAS) prep_vol.sas  

ifeq ($(SASSTAT), 1)
$(DATADIR)/proptximp04.sas7bdat $(DATADIR)/proptximp06.sas7bdat $(DATADIR)/proptximp08.sas7bdat $(DATADIR)/proptximp10.sas7bdat $(DATADIR)/proptximp12.sas7bdat $(DATADIR)/proptximp.sas7bdat: $(DATADIR)/proptximp02.sas7bdat
$(DATADIR)/proptximp02.sas7bdat: fem_env.sas FEM_Sas/HRS/PropTax/proptximp.sas $(DATADIR)/prep_ptax02.sas7bdat $(DATADIR)/prep_ptax04.sas7bdat $(DATADIR)/prep_ptax06.sas7bdat $(DATADIR)/prep_ptax08.sas7bdat $(DATADIR)/prep_ptax10.sas7bdat $(DATADIR)/prep_ptax12.sas7bdat $(DATADIR)/prep_ptax14.sas7bdat $(HRSPUB)/SAS/rndhrs_$(RANDVER).sas7bdat $(DATADIR)/proptximpr98.sas7bdat $(DATADIR)/proptximpr00.sas7bdat 
	cd FEM_Sas/HRS/PropTax && $(SAS) proptximp.sas

$(DATADIR)/proptximpr00.sas7bdat $(DATADIR)/proptximp00.sas7bdat: fem_env.sas FEM_Sas/HRS/PropTax/proptximp00.sas $(DATADIR)/prep_ptax00.sas7bdat $(HRSPUB)/SAS/rndhrs_$(RANDVER).sas7bdat 
	cd FEM_Sas/HRS/PropTax && $(SAS) proptximp00.sas

$(DATADIR)/proptximpr98.sas7bdat $(DATADIR)/proptximp98.sas7bdat: fem_env.sas FEM_Sas/HRS/PropTax/proptximp98.sas $(DATADIR)/prep_ptax98.sas7bdat $(HRSPUB)/SAS/rndhrs_$(RANDVER).sas7bdat 
	cd FEM_Sas/HRS/PropTax && $(SAS) proptximp98.sas
endif

$(DATADIR)/prep_ptax04.sas7bdat $(DATADIR)/prep_ptax06.sas7bdat $(DATADIR)/prep_ptax08.sas7bdat $(DATADIR)/prep_ptax10.sas7bdat $(DATADIR)/prep_ptax12.sas7bdat $(DATADIR)/prep_ptax14.sas7bdat: $(DATADIR)/prep_ptax02.sas7bdat
$(DATADIR)/prep_ptax02.sas7bdat: fem_env.sas FEM_Sas/HRS/PropTax/prep_ptax.sas $(HRSPUB)/SAS/rndhrs_$(RANDVER).sas7bdat $(HRSPUB)/SAS/hrs02.sas7bdat $(HRSPUB)/SAS/hrs04.sas7bdat $(HRSPUB)/SAS/hrs06.sas7bdat $(HRSPUB)/SAS/hrs08.sas7bdat $(HRSPUB)/SAS/hrs10.sas7bdat $(HRSPUB)/SAS/hrs12.sas7bdat $(HRSPUB)/SAS/hrs14.sas7bdat $(HRSPUB)/SAS/incwlth_$(RANDVER).sas7bdat
	cd FEM_Sas/HRS/PropTax && $(SAS) prep_ptax.sas 

$(DATADIR)/prep_ptax00.sas7bdat: fem_env.sas FEM_Sas/HRS/PropTax/prep_ptax.sas $(HRSPUB)/SAS/rndhrs_$(RANDVER).sas7bdat $(HRSPUB)/SAS/hrs00.sas7bdat $(HRSPUB)/SAS/incwlth_$(RANDVER).sas7bdat 
	cd FEM_Sas/HRS/PropTax && $(SAS) prep_ptax00.sas 

$(DATADIR)/prep_ptax98.sas7bdat: fem_env.sas FEM_Sas/HRS/PropTax/prep_ptax.sas $(HRSPUB)/SAS/rndhrs_$(RANDVER).sas7bdat $(HRSPUB)/SAS/hrs98.sas7bdat $(HRSPUB)/SAS/incwlth_$(RANDVER).sas7bdat 
	cd FEM_Sas/HRS/PropTax && $(SAS) prep_ptax98.sas 

## Restricted SAS data processing
$(HRSDIR)/hrs19922008_clms_trans.sas7bdat: FEM_Sas/HRS_Claims/hrs_selected_claims.sas FEM_Sas/HRS_Claims/process_clmyr.sas fem_env.sas
	cd FEM_Sas/HRS_Claims && $(SAS) hrs_selected_claims.sas
$(HRSDIR)/hrs19922008_clms_trans.dta: $(HRSDIR)/hrs19922008_clms_trans.sas7bdat
	st $< $@ -y -q

## VC Matrix
## This code will estimate the variance-covariance matrix if age5055_hrs1992r.dta has changed or if the Stata do file has changed
vcmatrix: $(COMMON) $(HRSDIR)/age5055_hrs1992r.dta FEM_Stata/Makedata/HRS/VC_est_all_ihs.do $(GHREG) $(UTILITIES)/_ggh.ado
	cd FEM_Stata/Makedata/HRS && $(STATA) VC_est_all_ihs.do

## Some particular sets of results
$(DATADIR)/new51s_obs80.dta: $(COMMON) $(DATADIR)/pop5152_projection_2150.dta $(DATADIR)/age5055_hrs1992.dta $(DATADIR)/age5055_hrs2004.dta $(BASEDIR)/trend_all*.dta $(BASEDIR)/incoming_vcmatrix.dta $(BASEDIR)/incoming_means_econ_tos.dta $(BASEDIR)/incoming_means.dta $(BASEDIR)/incoming_means_econ.dta $(UTILITIES)/_getestimates.mo $(INIT_EST) $(DATADIR)/incoming_base.dta $(DATADIR)/obs80_adjustments.dta FEM_Stata/Makedata/HRS/new51_simulate.do
	cd FEM_Stata/Makedata/HRS && SCENARIO=obs80 TREND=status_quo BREP=0 RES=0 FYEAR=$(FYEAR) LYEAR=$(LYEAR) $(STATA) new51_simulate.do

$(DATADIR)/new51s_notrend.dta: $(COMMON) $(DATADIR)/pop5152_projection_2150.dta $(DATADIR)/age5055_hrs1992.dta $(DATADIR)/age5055_hrs2004.dta $(BASEDIR)/trend_all*.dta $(BASEDIR)/incoming_vcmatrix.dta $(BASEDIR)/incoming_means_econ_tos.dta $(BASEDIR)/incoming_means.dta $(BASEDIR)/incoming_means_econ.dta $(UTILITIES)/_getestimates.mo $(INIT_EST) $(DATADIR)/incoming_base.dta FEM_Stata/Makedata/HRS/new51_simulate.do
	cd FEM_Stata/Makedata/HRS && SCENARIO=notrend TREND=status_quo BREP=0 RES=0 FYEAR=$(FYEAR) LYEAR=$(LYEAR) $(STATA) new51_simulate.do

