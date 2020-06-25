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


cohort <- read_dta('output/ELSA_cohort/ELSA_cohort_summary.dta')

commit <- read_dta('output/COMMIT_cSmoken/COMMIT_cSmoken_summary.dta')

plot(cohort$year, cohort$n_smoken_all, type='l', col='red')
lines(commit$year, commit$n_smoken_all, col='green')

plot(commit$year, commit$p_smoken_all, type='l', col='green')
lines(cohort$year, cohort$p_smoken_all, col='red')

plot(commit$year, commit$n_lunge_all, type='l', col='green')
lines(cohort$year, cohort$n_lunge_all, col='red')

plot(commit$year, commit$p_cancre_all, type='l', col='green')
lines(cohort$year, cohort$p_cancre_all, col='red')

plot(commit$year, commit$p_diabe_all, type='l', col='green')
lines(cohort$year, cohort$p_diabe_all, col='red')

