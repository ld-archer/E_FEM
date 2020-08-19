getwd()
FEM_dir <- "/home/luke/Documents/E_FEM_clean/E_FEM/input_data"
setwd(FEM_dir)

require(haven)
require(mice)
require(lattice)
require(tidyverse)

set.seed(500) # Set seed for reproducibility

# Read in the reshaped_data and get a summary
H_ELSA_base <- read_dta('H_ELSA_pre_reshape.dta')
#H_ELSA_base <- read_dta('H_ELSA_f_2002-2016.dta')
summary(H_ELSA_base)

# Select only the vars we want to impute, plus those to use in the imputation
H_ELSA <- H_ELSA_base %>% select(contains(c('idauniq', 'iwindy', 'rabyear', 'radyear', 'ragender', 'raracem', 'raeducl', 'hlthlm', 'work', 'itearn', 'retemp',
                                            'vgactx_e', 'mdactx_e', 'ltactx_e', 'ipubpen', 'drink', 'drinkd', 'bmi', 'smoken', 'smokev', 'smokef')))

# Assign impossible bmi values as missing (values with BMI < 10. Only happens in wave 8, 4 cases)
H_ELSA$bmi8[H_ELSA$bmi8 < 10] <- NA

# Run the imputation
impData <-mice(H_ELSA, m = 5, maxit=5, seed=500, tol=1e-15)

# Now collect all imputed datasets in long format
completedData <- complete(impData, 'long')

# Extract only bmi vars
bmiVars <- completedData %>% select(contains(c('id', 'bmi')))

# Aggregate the data
a<-aggregate(bmiVars , by = list(bmiVars$.id),FUN= mean)

# Remove vars generated in imputation
colnames(a)
final <- a %>% select(-c('Group.1', '.id'))
# Rename bmivars to make it clear these include imputed values
colnames(final)[2:5] <- c('bmi2_imp', 'bmi4_imp', 'bmi6_imp', 'bmi8_imp')

write_path <- '/home/luke/Documents/E_FEM_clean/E_FEM/input_data/bmi_imputed_R.dta'

# Finally, export data as Stata .dta
write_dta(final, write_path)

summary(final)



