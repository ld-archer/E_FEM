
require(haven)
require(mice)
require(tidyverse)

H_ELSA_base <- read_dta('H_ELSA_f_2002-2016.dta')

impVars2 <- H_ELSA_base %>% select(matches(c('idauniq', 'r[0-9]iwstat', 'rabyear$', 'radyear', 'ragender$', 'raeducl$', 'r[0-9]walkra$', 'r[0-9]dressa$', 'r[0-9]batha$', 
                                             'r[0-9]eata$', 'r[0-9]beda$', 'r[0-9]toilta$', 'r[0-9]mapa$', 'r[0-9]phonea$', 'r[0-9]moneya$', 'r[0-9]medsa$', 'r[0-9]shopa$', 'r[0-9]mealsa$',
                                             'r[0-9]housewka$', 'r[0-9]hibpe$', 'r[0-9]diabe$', 'r[0-9]cancre$', 'r[0-9]lunge$', 'r[0-9]hearte$', 'r[0-9]stroke$',
                                             'r[0-9]bmi$', 'r[0-9]smokev$', 'r[0-9]smoken$', 'r[0-9]smokef$', 'r[0-9]drink$', 'r[0-9]vgactx_e$', 'r[0-9]mdactx_e$', 'r[0-9]ltactx_e$',
                                             'r[0-9]drinkd_e$')))

impVars2 <- impVars2 %>% select(-matches('s[0-9]idauniq'))

colnames(impVars2)
ncol(impVars2)

# Assign impossible bmi values as missing (values with BMI < 10. Only happens in wave 8, 4 cases)
impVars2$r8bmi[impVars2$r8bmi < 10] <- NA

# Run the imputation
# Tolerance had to be set to low as I kept getting the error:
# Error in solve.default(xtx + diag(pen)) : system is computationally singular: reciprocal condition number = 4.00027e-17 (number changes when different vars are included)
# Removed a number of variables also to try and get around this error, as it is saying that 1 or more of the variables are linearly dependant (or so small they are treated as zero - unlikely)
impData2 <-mice(impVars2, m = 5, maxit=5, seed=500, tol=1e-25)

saveRDS(impData2, file = "/home/luke/Documents/E_FEM_clean/E_FEM/input_data/ELSA_imputed_R.mids")

