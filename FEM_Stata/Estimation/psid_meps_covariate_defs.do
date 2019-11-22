*** Define all covariates used in cost models
global cov_medicaid_elig = "male male_black male_hispan male_hsless black hispan hsless college widowed single cancre logiearnx adl1p"


global cov_meps = "age3034 age3539 age4044 age4549 age5054 age5559 age6064 age6569 male male_black male_hispan male_hsless black hispan hsless college widowed single logiearnx cancre diabe hibpe hearte lunge stroke"
global cov_meps_more = "age45p_cancre age45p_diabe age45p_hibpe age45p_hearte age45p_lunge age45p_stroke"
global cov_hlthinscat = "hicat1 hicat2 hicat3 hicat4 hicat5 hicat6 hicat7 hicat8"
global cov_inscat = "inscat1 inscat2"

* For Rx models
global cov_rx = "age3034 age3539 age4044 age4549 age5054 age5559 age6064 age6569 male black hispan hsless college male_black male_hispan male_hsless widowed single k6severe cancre diabe hibpe hearte lunge stroke overwt obese"
