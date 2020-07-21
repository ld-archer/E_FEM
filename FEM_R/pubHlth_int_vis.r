getwd()
workingDir <- "/home/luke/Documents/E_FEM_clean/E_FEM"
setwd(workingDir)

require(haven)
require(dplyr)

par(mfrow=c(2,2))

baseline <- read_dta('output/ELSA_Baseline/ELSA_Baseline_summary.dta')

cohort <- read_dta('output/ELSA_cohort/ELSA_cohort_summary.dta')


### COMMIT INTERVENTION
commit3 <- read_dta('output/COMMIT_cSmoken3/COMMIT_cSmoken3_summary.dta')
## Visualise the 3% intervention
#plot(cohort$year, cohort$n_smoken_all, type='l', col='red')
#lines(commit3$year, commit3$n_smoken_all, col='green')

plot(commit3$year, commit3$p_smoken_all, type='l', col='green')
lines(cohort$year, cohort$p_smoken_all, col='red')

plot(commit3$year, commit3$n_lunge_all, type='l', col='green')
lines(cohort$year, cohort$n_lunge_all, col='red')

plot(commit3$year, commit3$p_lunge_all, type='l', col='green')
lines(cohort$year, cohort$p_lunge_all, col='red')

plot(commit3$year, commit3$p_cancre_all, type='l', col='green')
lines(cohort$year, cohort$p_cancre_all, col='red')

tmp <- commit3$m_endpop_all / commit3$m_endpop_all[1]
tmp2 <- cohort$m_endpop_all / cohort$m_endpop_all[1]

plot(commit3$year, tmp, type='l', col='green')
lines(cohort$year, tmp2, col='red')

## Now work with the PSmoke_stopMult intervention
smoke_stop <- read_dta('output/Smoke_Stop_Cohort200/Smoke_Stop_Cohort200_summary.dta')
## Visualise
#plot(smoke_stop$year, smoke_stop$n_smoken_all, type='l', col='green')
#lines(cohort$year, cohort$n_smoken_all, col='red')

plot(cohort$year, cohort$p_smoken_all, type='l', col='red')
lines(smoke_stop$year, smoke_stop$p_smoken_all, col='green')

plot(cohort$year, cohort$p_lunge_all, type='l', col='red')
lines(smoke_stop$year, smoke_stop$p_lunge_all, col='green')

plot(smoke_stop$year, smoke_stop$p_cancre_all, type='l', col='green')
lines(cohort$year, cohort$p_cancre_all, col='red')

plot(smoke_stop$year, smoke_stop$p_diabe_all, type='l', col='green')
lines(cohort$year, cohort$p_diabe_all, col='red')

plot(smoke_stop$year, smoke_stop$n_smoke_stop_all, type='l', col='green')
lines(cohort$year, cohort$n_smoke_stop_all, col='red')


###########
SmokeStopInt <- read_dta('output/SmokeStopIntervention/SmokeStopIntervention_summary.dta')

#plot(SmokeStopInt$year, SmokeStopInt$n_smoken_all, type='l', col='green')
#lines(cohort$year, cohort$n_smoken_all, col='red')

plot(SmokeStopInt$year, SmokeStopInt$p_smoken_all, type='l', col='green')
lines(cohort$year, cohort$p_smoken_all, col='red')

plot(SmokeStopInt$year, SmokeStopInt$p_lunge_all, type='l', col='green')
lines(cohort$year, cohort$p_lunge_all, col='red')

plot(SmokeStopInt$year, SmokeStopInt$p_cancre_all, type='l', col='green')
lines(cohort$year, cohort$p_cancre_all, col='red')

plot(SmokeStopInt$year, SmokeStopInt$p_diabe_all, type='l', col='green')
lines(cohort$year, cohort$p_diabe_all, col='red')


#################################################
smoke_stop_init <- read_dta('output/Smoke_Stop_Cohort_Init/Smoke_Stop_Cohort_Init_summary.dta')

#plot(smoke_stop_init$year, smoke_stop_init$n_smoken_all, type='l', col='green')
#lines(cohort$year, cohort$n_smoken_all, col='red')

plot(smoke_stop_init$year, smoke_stop_init$p_smoken_all, type='l', col='green')
lines(cohort$year, cohort$p_smoken_all, col='red')

plot(cohort$year, cohort$p_smoken_all, col='red', type='l')
lines(smoke_stop_init$year, smoke_stop_init$p_smoken_all, col='green')

plot(smoke_stop_init$year, smoke_stop_init$p_lunge_all, type='l', col='green')
lines(cohort$year, cohort$p_lunge_all, col='red')

plot(smoke_stop_init$year, smoke_stop_init$p_cancre_all, type='l', col='green')
lines(cohort$year, cohort$p_cancre_all, col='red')

plot(smoke_stop_init$year, smoke_stop_init$p_diabe_all, type='l', col='green')
lines(cohort$year, cohort$p_diabe_all, col='red')
