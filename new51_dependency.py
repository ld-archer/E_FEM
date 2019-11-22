import os

x_max = int(os.environ["MAXBREP"])

x = 1
with open("new51_dependency.txt","w") as file:
	while (x <= x_max):
		y = 2004
		file.write("\n")
		file.write("BCOHORTSI" + str(x) + " := $(addsuffix _input.dta, $(DATADIR)/input_rep" + str(x) + "/new51s)\n")
		file.write("FEM_Stata/Makedata/HRS/new51s_input_brep_" + str(x) + ".txt: ${BCOHORTSI" + str(x) + "}\n")
		file.write("\n")
		file.write("$(DATADIR)/input_rep" + str(x) + "/new51s_input.dta: $(COMMON) FEM_Stata/Makedata/HRS/new51_simulate.do $(DATADIR)/pop5152_projection_2150.dta $(DATADIR)/age5055_hrs1992.dta $(DATADIR)/age5055_hrs2010.dta $(DATADIR)/input_rep" + str(x) + "/age5055_hrs2010.dta $(DATADIR)/trend_all_status_quo.dta $(BASEDIR)/incoming_vcmatrix.dta $(BASEDIR)/incoming_means_econ_tos.dta $(BASEDIR)/incoming_means.dta $(BASEDIR)/incoming_means_econ.dta $(UTILITIES)/_getestimates.mo $(INIT_EST) $(RESTIMATES)/minit_logtenure $(DATADIR)/minit_deprsymp $(DATADIR)/sinit_deprsymp $(DATADIR)/incoming_base.dta\n")
		file.write("	cd FEM_Stata/Makedata/HRS && SCENARIO=input TREND=status_quo RES=0 BREP=" + str(x) + " FYEAR=$(FYEAR) LYEAR=$(LYEAR) $(STATA) new51_simulate.do\n")
	
		x += 1
