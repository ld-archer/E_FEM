# Make targets for analysis of disease survival

CONDS := change cancre diabe hearte hibpe stroke lunge
COND_RDATA := $(addsuffix _survival.Rdata, $(addprefix no_,${CONDS}))
COND_STATADATA := $(addsuffix _survival.dta, $(addprefix no_,${CONDS}))

no_%_survival.dta: disease_survival.do ../../output/no_%/detailed_output/y2010_rep1.dta
	stata-mp -b do disease_survival.do

no_%_survival.Rdata: no_%_survival.dta
	st no_$*_survival.dta no_$*_survival.Rdata -y


disease_survival_plots.pdf disease_survival_estimates.xlsx: make_survival_plots.R ggkm.R ggkm_nostrat.R ${COND_RDATA}
	Rscript make_survival_plots.R
	
disease_survival_data.zip: ${COND_STATADATA}
	rm -f disease_survival_data.zip && zip disease_survival_data.zip ${COND_STATADATA}
	
plots: disease_survival_plots.pdf

table: disease_survival_estimates.xlsx

all: plots table disease_survival_data.zip
