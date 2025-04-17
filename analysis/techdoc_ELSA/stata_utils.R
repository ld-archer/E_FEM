# Custom utility functions to replace Stata-specific recodes

# Function to recode ADL and IADL status
recode_adl_iadl <- function(data) {
  data <- data %>%
    mutate(adlstat = case_when(
      adlcount == 0 ~ 1,
      adlcount == 1 ~ 2,
      adlcount == 2 ~ 3,
      adlcount >= 3 ~ 4
    ),
    anyadl = ifelse(adlcount > 0, 1, 0),
    iadlstat = case_when(
      iadlcount == 0 ~ 1,
      iadlcount == 1 ~ 2,
      iadlcount >= 2 ~ 3
    ),
    anyiadl = ifelse(iadlcount > 0, 1, 0))
  return(data)
}

# Function to recode health conditions and mortality
recode_health_mortality <- function(data) {
  data <- data %>%
    mutate(died = case_when(
      riwstat %in% c(0, 7, 9) ~ NA_real_,
      riwstat %in% c(1, 4, 6) ~ 0,
      riwstat == 5 ~ 1
    )) %>%
    rename_at(vars(starts_with("r")), ~sub("r", "", .))
  return(data)
}
