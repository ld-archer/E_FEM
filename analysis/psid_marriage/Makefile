plots: Rplots.pdf

Rplots.pdf: ../../output/psid/psid_summary.Rdata
	Rscript marriage_plots.R

../../output/psid/psid_summary.Rdata: ../../output/psid/psid_summary.dta
	cd ../../output/psid && st psid_summary.dta psid_summary.Rdata -y

