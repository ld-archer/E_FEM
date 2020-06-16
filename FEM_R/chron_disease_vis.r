getwd()
workingDir <- "/home/luke/Documents/E_FEM_clean/E_FEM"
setwd(workingDir)

require(haven)
require(dplyr)

baseline <- read_dta('output/ELSA_Baseline/ELSA_Baseline_summary.dta')

pCancer10 <- read_dta('output/ELSA_pCancer10/ELSA_pCancer10_summary.dta')

baseCancer <- baseline %>% select(contains(c('year', 'cancre')))

plot(baseCancer$year, baseCancer$p_cancre_all, type='l', col='red')
lines(pCancer10$year, pCancer10$p_cancre_all, col='green')
legend(2012, 0.18,legend=c("Year", "Prevalence of Cancer"), col=c("red", "green"))
