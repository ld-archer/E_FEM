GVDIR=analysis/graphviz


$(GVDIR)/FAM/files/fam_edges_nodes.dta: $(GVDIR)/process_ster.do	
	cd analysis/graphviz && simtype=FAM sterdir=$(ESTIMPSID) fileout=FAM/files/fam_edges_nodes $(STATA) process_ster.do 
analysis/graphviz/FAM/png/predictors/Work_category_t.png: $(GVDIR)/FAM/files/fam_edges_nodes.dta $(GVDIR)/make_figures.do
	cd analysis/graphviz && simtype=FAM filein=FAM/files/fam_edges_nodes $(STATA) make_figures.do


$(GVDIR)/FEM/files/fem_edges_nodes.dta: $(GVDIR)/process_ster.do		
	cd analysis/graphviz && simtype=FEM sterdir=$(ESTIMHRS) fileout=FEM/files/fem_edges_nodes $(STATA) process_ster.do 
analysis/graphviz/FEM/png/predictors/Wealth_tplus1.png: $(GVDIR)/FEM/files/fem_edges_nodes.dta $(GVDIR)/make_figures.do	
	cd analysis/graphviz && simtype=FEM filein=FEM/files/fem_edges_nodes $(STATA) make_figures.do

