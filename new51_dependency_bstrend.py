import os

x_max = int(os.environ["MAXBREP"])

x = 1
with open("new51_dependency_bstrend.txt","w") as file:
	while (x <= x_max):
		y = 2004
		file.write("\n")
		file.write("BCOHORTSB" + str(x) + " := $(addsuffix _bstrend.dta, $(DATADIR)/input_rep" + str(x) + "/new51s)\n")
		file.write("FEM_Stata/Makedata/HRS/new51s_bstrend_brep_" + str(x) + ".txt: ${BCOHORTSB" + str(x) + "}\n")
		file.write("\n")
		file.write("$(DATADIR)/input_rep" + str(x) + "/new51s_bstrend.dta: $(COMMON) FEM_Stata/Makedata/HRS/new51_simulate_bootstrap.do $(DATADIR)/new51s_status_quo.dta $(DATADIR)/input_rep" + str(x) + "/bootstrap_sample.dta $(DATADIR)/pop5152_projection_2150.dta \n")
		file.write("	cd FEM_Stata/Makedata/HRS && SCENARIO=bstrend TREND=status_quo BREP=" + str(x) + " FYEAR=$(FYEAR) LYEAR=$(LYEAR) $(STATA) new51_simulate_bootstrap.do\n")
		
		x += 1
