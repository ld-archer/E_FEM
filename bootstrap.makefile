# If you want to change the number of bootstrap samples, do it here

# Number of bootstrap reps for HRS data set
N_HRS_BREPS = 5

# Number of reps for PSID dataset
N_PSID_BREPS = 5

# Number of reps for MEPS and MCBS datasets in HRS-releated simulations
# unless you are doing a nested bootstrap by data set, the number of bootstrap reps from each data source should be the same as the HRS
N_HRS_MEPS_BREPS := $(N_HRS_BREPS)
N_HRS_MCBS_BREPS := $(N_HRS_BREPS)

# Number of bootstrap reps for MEPS and MCBS in PSID-related simulations
# unless you are doing a nested bootstrap by data set, the number of bootstrap reps from each data source should be the same as the PSID
N_PSID_MEPS_BREPS := $(N_PSID_BREPS)
N_PSID_MCBS_BREPS := $(N_PSID_BREPS)



