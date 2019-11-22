import os

x_max = int(os.environ["MAXBREP"])

x = 1
with open("new51_dependency_input_bstrend.txt","w") as file:
	while (x <= x_max):
		y = 2004
		file.write("\n")
		file.write("BCOHORTSIB" + str(x) + " := $(addsuffix _input_bstrend.dta, $(DATADIR)/input_rep" + str(x) + "/new51s)\n")
		file.write("FEM_Stata/Makedata/HRS/new51s_input_bstrend_brep_" + str(x) + ".txt: ${BCOHORTSIB" + str(x) + "}\n")
		file.write("\n")
		file.write("$(DATADIR)/input_rep" + str(x) + "/new51s_input_bstrend.dta: $(COMMON) FEM_Stata/Makedata/HRS/new51_simulate_bootstrap.do $(DATADIR)/input_rep" + str(x) +"/new51s_input.dta $(DATADIR)/input_rep" + str(x) + "/bootstrap_sample.dta $(BASEDIR)/pop5152_projection_2080.dta \n")
		file.write("	cd FEM_Stata/Makedata/HRS && SCENARIO=input_bstrend TREND=status_quo BREP=" + str(x) + " FYEAR=$(FYEAR) LYEAR=$(LYEAR) $(STATA) new51_simulate_bootstrap.do\n")
		
		x += 1
