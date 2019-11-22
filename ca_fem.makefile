

ca_fem: $(DATADIR)/ca_dof.dta $(DATADIR)/new51s_status_quo_ca.dta $(DATADIR)/stock_hrs_ca_2010.dta

$(DATADIR)/ca_dof.dta: FEM_Stata/Makedata/CA_DOF/process_projections.do $(CA_DOF)/P3_Complete.csv
	cd FEM_Stata/Makedata/CA_DOF && $(STATA) process_projections.do

$(DATADIR)/stock_hrs_ca_2010.dta: $(DATADIR)/new51s_status_quo_ca.dta
$(DATADIR)/new51s_status_quo_ca.dta: $(DATADIR)/stock_hrs_2010.dta $(DATADIR)/new51s_status_quo.dta FEM_Stata/Makedata/HRS/ca_fem_reweight.do
	cd FEM_Stata/Makedata/HRS && $(STATA) ca_fem_reweight.do
	

pop_compare:
	cd analysis && $(STATA) ca_pop_compare.do	
	