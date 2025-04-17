# FEM Cross Validation - converted from Stata to R

# Load necessary libraries
library(haven)
library(dplyr)
library(tidyr)

# Load custom utility functions
source("stata_utils.R")

# Define scenario
scen <- Sys.getenv("scen")
#scen <- "CV1"

# Set up logging
log_file <- paste0("crossvalidation_ELSA_", scen, ".log")
log_con <- file(log_file, open = "wt")
sink(log_con, type = "output")

# Define paths
output_dir <- Sys.getenv("output_dir")
input_dir <- Sys.getenv("outdata")

if (scen == "CV1") {
  output <- file.path(output_dir, "COMPLETE", "ELSA_CV1")
} else if (scen == "minimal") {
  output <- file.path(output_dir, "COMPLETE", "ELSA_minimal")
}

# Parameters
iter <- 10
minwave <- 1
maxwave <- 9

# Load data
input_file <- file.path(input_dir, "H_ELSA_g2_wv_specific.dta")
elsa_data <- read_dta(input_file)

# Create hhidpn
elsa_data <- elsa_data %>%
  mutate(hhidpn = idauniq)

# Merge based on scenario
if (scen == "CV1") {
  crossvalidation_file <- file.path(input_dir, "cross_validation/crossvalidation.dta")
  crossvalidation_data <- read_dta(crossvalidation_file)
  
  elsa_data <- elsa_data %>%
    left_join(crossvalidation_data, by = "idauniq") %>%
    filter(simulation == 1) %>%
    select(-simulation)
  
} else if (scen == "minimal") {
  minimal_file <- file.path(input_dir, "ELSA_stock_min_flag.dta")
  minimal_data <- read_dta(minimal_file)
  
  elsa_data <- elsa_data %>%
    inner_join(minimal_data, by = "idauniq")
}

# Keep selected variables
keep_vars <- c("idauniq", "raracem", "ragender", "rabyear", grep("^inw.*sc|^r.*iwindy|^r.*iwstat|^r.*agey|^r.*cancre|^r.*diabe|^r.*hearte|^r.*hibpe|^r.*lunge|^r.*stroke|^r.*asthmae|^r.*smoken|^r.*smokev|^r.*mbmi|^r.*cwtresp|^r.*drink|^r.*psyche|^r.*smokef|^r.*lnlys|^r.*alzhe|^r.*demene|^r.*lbrf_e|^h.*atotb|^h.*itot|^h.*coupid|^r.*ltactx_e|^r.*mdactx_e|^r.*vgactx_e|^r.*jphysl", names(elsa_data), value = TRUE))

elsa_data <- elsa_data %>%
  select(all_of(keep_vars))

# Create new mbmi variable
elsa_data <- elsa_data %>%
  mutate(r9mbmi = r9mweight / (r8mheight^2)) %>%
  select(-starts_with("rmheight"), -starts_with("rmweight"))

# Renaming self-completion flag variables
elsa_data <- elsa_data %>%
  rename_at(vars(matches("^inw[0-9]+sc")), ~paste0("insc", str_extract(., "[0-9]+")))

# Define shapelist with patterns
shapelist <- c("insc", "r*iwindy", "r*iwstat", "r*agey", "r*cancre", "r*diabe", "r*hearte", 
               "r*hibpe", "r*lunge", "r*stroke", "r*asthmae", "r*smoken", "r*smokev", 
               "r*mbmi", "r*cwtresp", "r*drink", "r*psyche", "r*smokef", "r*lnlys", 
               "r*alzhe", "r*demene", "r*lbrf_e", "h*atotb", "h*itot", "h*coupid", 
               "r*ltactx_e", "r*mdactx_e", "r*vgactx_e", "r*jphysl")

# Use grep to select columns that match the shapelist patterns
elsa_data_long <- elsa_data %>%
  pivot_longer(cols = matches(paste(shapelist, collapse = "|")),
               names_to = "wave", values_to = "value")


# Filter based on wave and birth year
elsa_data_long <- elsa_data_long %>%
  filter(wave >= minwave & rabyear <= 1951)

# Recode variables and generate derived columns
elsa_data_long <- elsa_data_long %>%
  mutate(white = raracem == 1,
         male = ifelse(!is.na(ragender), ragender == 1, NA),
         adlcount = rowSums(across(starts_with("rwalkra"):starts_with("rtoilta")), na.rm = TRUE),
         iadlcount = rowSums(across(starts_with("rmapa"):starts_with("rhousewka")), na.rm = TRUE))

# Recode ADL/IADL status
elsa_data_long <- recode_adl_iadl(elsa_data_long)

# Mortality and health conditions
elsa_data_long <- recode_health_mortality(elsa_data_long)

# Close log file
sink()
close(log_con)
