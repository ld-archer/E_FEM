

########## LOOKFOR ##########

lookfor <- function(data,
                    keywords = "weight|sample",
                    labels = TRUE,
                    ignore.case = TRUE) {
  # search scope
  n <- names(data)
  if(!length(n)) stop("there are no names to search in that object")
  # search function
  look <- function(x) { grep(paste(keywords, collapse="|"), x, ignore.case = ignore.case) }
  # names search
  x <- look(n)
  variable <- n[x]
  # foreign objects
  l <- attr(data, "variable.labels")
  if(is.null(l)) l <- attr(data, "var.labels")
  # memisc objects
  if(grepl("data.set|importer", class(data))) {
    suppressMessages(suppressWarnings(require(memisc)))
    l <- as.vector(description(data))
  }
  if(length(l) & labels) {
    # search labels
    y <- look(l)
    # remove duplicates, reorder
    x <- sort(c(x, y[!(y %in% x)]))
    # add variable labels
    variable <- n[x]
    label <- l[x]
    variable <- cbind(variable, label)
  }
  # output
  if(length(x)) return(as.data.frame(variable, x))
  else message("Nothing found. Sorry.")
}

########## PREPARING SUMMARY OUTPUT FILE ##########

prepare_ELSA <- function(elsa_long, 
                         wave_start = 1, 
                         wave_end = 6, 
                         print_counts = TRUE) {
  
  # Get important variables
  # Select waves 1-6
  # Check if present in both first and last
  subset <- elsa_long %>% dplyr::select(idauniq, wave, died,
                                        age, male, white,                    # demographics
                                        educ, hsless, college,               # demographics
                                        smokev, smoken, smokef,              # smoking status
                                        hibpe, bmi, stroke, hearte, diabe,   # health measures
                                        atotb, itot,                         # wealth/income
                                        lnly, sociso,                        # loneliness/social isolation
                                        cwtresp, inw, insc) %>%                    # survey stuff
    filter(wave >= wave_start, wave <= wave_end) %>%
    group_by(idauniq) %>%
    mutate(n = n(),
           in_first = ((dplyr::first(inw) == 1) & (dplyr::first(wave) == 1)),
           first_age = dplyr::first(age),
           died_wave_2 = ((wave == 2) & (died == 1)),
           age_group = cut(x = first_age, 
                           breaks = c(50, 60, 70, 80, 90, 100),
                           labels = c('50-60', '60-70', '70-80', '80-90', '90-100'), 
                           include.lowest = TRUE)) %>%
    filter((in_first == TRUE), 
           (first_age >= 50),
           ((n > 1)  | (died_wave_2 == 1))) %>% # Make sure they were in for more than 1 wave (or died in second)
    dplyr::select(-in_first, -n)
  
  # check and change var types
  subset$idauniq <- as.factor(subset$idauniq)
  subset$wave <- as.numeric(subset$wave)
  subset$died <- as.numeric(subset$died)
  subset$age <- as.numeric(subset$age)
  subset$age_group <- as.factor(subset$age_group)
  subset$male <- as.factor(subset$male)
  subset$white <- as.factor(subset$white)
  subset$educ <- as.factor(subset$educ)
  subset$smokev <- as.factor(subset$smokev)
  subset$smoken <- as.factor(subset$smoken)
  subset$smokef <- as.factor(subset$smokef)
  subset$hibpe <- as.factor(subset$hibpe)
  subset$bmi <- as.numeric(subset$bmi)
  subset$stroke <- as.factor(subset$stroke)
  subset$hearte <- as.factor(subset$hearte)
  subset$diabe <- as.factor(subset$diabe)
  subset$atotb <- as.numeric(subset$atotb)
  subset$itot <- as.numeric(subset$itot)
  subset$cwtresp <- as.numeric(subset$cwtresp)
  subset$lnly <- as.factor(subset$lnly)
  subset$sociso <- as.factor(subset$sociso)
  
  if(print_counts) {
    # How many people in the dataset?
    counts <- n_distinct(subset$idauniq)
    print(paste0("There are ", counts, " individuals in the prepared dataset."))
    print('-------------------')
  }
  
  return(subset)
}

########## DETAILED OUTPUT APPEND ##########

detailed_output_append <- function(base.out.dir, scenario) {
  ## function to read in all files in a detailed output and collect into 1 object
  path <- paste0(base.out.dir, scenario, '/detailed_output/')
  filelist <- list.files(path,
                         full.names = TRUE)
  return(do.call(rbind, lapply(filelist, read_dta)))
}

########## SAMPLE STATISTICS ##########


weighted.survey.means <- function(init.pop, transition=FALSE) {
  
  require(survey)
  
  if(!transition) {
    design <- svydesign(id = ~idauniq,
                        weights = ~weight,
                        data = init.pop)
  } else if(transition) {
    # Error from missing cwtresp var - drop all that are missing to solve
    init.pop <- init.pop[complete.cases(init.pop$cwtresp),]
    design <- svydesign(id = ~idauniq,
                        weights = ~cwtresp,
                        data = init.pop)
  }
  print(svymean(~age, design, na.rm=TRUE))
  print(svyvar(~age, design, na.rm=TRUE))
  print(svymean(~male, design, na.rm=TRUE))
  print(svymean(~bmi, design, na.rm=TRUE))
  print(svyvar(~bmi, design, na.rm=TRUE))
  print(svymean(~smoken, design, na.rm=TRUE))
  print(svymean(~smokev, design, na.rm=TRUE))
  print(svymean(~hsless, design, na.rm=TRUE))
  print(svymean(~college, design, na.rm=TRUE))
  print('---------------------')
  print(svymean(~cancre, design, na.rm=TRUE))
  print(svymean(~diabe, design, na.rm=TRUE))
  print(svymean(~hearte, design, na.rm=TRUE))
  print(svymean(~stroke, design, na.rm=TRUE))
  print(svymean(~lunge, design, na.rm=TRUE))
  print(svymean(~hibpe, design, na.rm=TRUE))
  print(svymean(~alzhe, design, na.rm=TRUE))
  print(svymean(~demene, design, na.rm=TRUE))
  print(svymean(~hchole, design, na.rm=TRUE))
}

########## Life Years and DFLYs ##########

ly_outcomes_from_detailed_output <- function(coh) {
  
  # generate lifeyear for people who have not died
  coh$lifeyear <- 1 - coh$died
  # generate the number of repetitions for each person
  coh$nreps <- max(coh$mcrep) + 1
  
  # now the giant pipeline to calculate LYs, DFLYs (both) and confidence intervals
  coh.sum <- coh %>%
    group_by(hhidpn, year) %>%
    mutate(nreps = n()) %>%
    group_by(hhidpn, mcrep) %>%
    summarise(n = n(),
              n_LY = sum(lifeyear),
              n_DiseaseFLY = sum(nodisease),
              n_DisabilityFLY = sum(nodisability),
              two_yr_LY = n_LY * 2,
              two_yr_DiseaseFLY = n_DiseaseFLY * 2,
              two_yr_DisabilityFLY = n_DisabilityFLY * 2,
              weight_intermed = sum(weight) / n) %>%
    group_by(hhidpn) %>%
    summarise(mean_LY_ind = mean(two_yr_LY),
              mean_DiseaseFLY_ind = mean(two_yr_DiseaseFLY),
              mean_DisabilityFLY_ind = mean(two_yr_DisabilityFLY),
              weight = mean(weight_intermed)) %>%
    summarise(n = n(),
              LY_mean = weighted.mean(mean_LY_ind, w = weight),
              LY_sd = sd(mean_LY_ind),
              DiseaseFLY_mean = weighted.mean(mean_DiseaseFLY_ind, w = weight),
              DiseaseFLY_sd = sd(mean_DiseaseFLY_ind),
              DisabilityFLY_mean = weighted.mean(mean_DisabilityFLY_ind, w = weight),
              DisabilityFLY_sd = sd(mean_DisabilityFLY_ind),
              LY_margin = qt(p=0.975, df=n-1) * (LY_sd / sqrt(n)),
              LY_min = LY_mean - LY_margin,
              LY_max = LY_mean + LY_margin,
              DiseaseFLY_margin = qt(p=0.975, df=n-1) * (DiseaseFLY_sd / sqrt(n)),
              DiseaseFLY_min = DiseaseFLY_mean - DiseaseFLY_margin,
              DiseaseFLY_max = DiseaseFLY_mean + DiseaseFLY_margin,
              DisabilityFLY_margin = qt(p=0.975, df=n-1) * (DisabilityFLY_sd / sqrt(n)),
              DisabilityFLY_min = DisabilityFLY_mean - DisabilityFLY_margin,
              DisabilityFLY_max = DisabilityFLY_mean + DisabilityFLY_margin) %>%
    select(-n) %>%
    pivot_longer(cols = everything(),
                 names_sep = '_',
                 names_to = c('outcome', 'statistic')) %>%
    filter(statistic %in% c('mean', 'min', 'max', 'margin')) %>%
    pivot_wider(values_from = 'value',
                names_from = 'statistic')
  
  return(coh.sum)
}


########## ALCOHOL CALCULATIONS ##########

# Function to calculate AUDIT-C scores and the accompanying AUDIT-C group in
# Understanding Society data. This function is specific to the COVID-19 dataset.
calc_audit_C19 <- function(indresp_data, wave_letter) {

  # generate the variable namesf (all follow naming convention 'c{wave_letter}_audit#')
  abst <- paste0('c', wave_letter, '_auditc1_cv')
  q1 <- paste0('c', wave_letter, '_auditc3_cv')
  q2 <- paste0('c', wave_letter, '_auditc4')
  q3 <- paste0('c', wave_letter, '_auditc5_cv')

  dat <- indresp_data %>% select(pidp, all_of(abst), all_of(q1), all_of(q2), all_of(q3))

  # 2. Generate new audit_score var
  dat$audit_score <- 0

  # 2.5. Check for nullness in audit vars and set score to 0 if all vars are present
  dat$audit_score[dat[[q1]] < 0] <- NA
  dat$audit_score[dat[[q2]] < 0] <- NA
  dat$audit_score[dat[[q3]] < 0] <- NA

  # 3. Populate new variable
  # Abstainers
  dat$audit_score[dat[[abst]] == 2] <- 0
  # Q1
  dat$audit_score[which(dat[[q1]] == 1)] <- 0
  dat$audit_score[which(dat[[q1]] == 2)] <- 1
  dat$audit_score[which(dat[[q1]] == 3)] <- 2
  dat$audit_score[which(dat[[q1]] == 4)] <- 3
  dat$audit_score[which(dat[[q1]] == 5)] <- 4
  dat$audit_score[which(dat[[q1]] == 6)] <- 4
  # Q2
  dat$audit_score[which(dat[[q2]] == 1)] <- dat$audit_score[which(dat[[q2]] == 1)] + 0
  dat$audit_score[which(dat[[q2]] == 2)] <- dat$audit_score[which(dat[[q2]] == 2)] + 1
  dat$audit_score[which(dat[[q2]] == 3)] <- dat$audit_score[which(dat[[q2]] == 3)] + 2
  dat$audit_score[which(dat[[q2]] == 4)] <- dat$audit_score[which(dat[[q2]] == 4)] + 3
  dat$audit_score[which(dat[[q2]] == 5)] <- dat$audit_score[which(dat[[q2]] == 5)] + 4
  # Q3
  dat$audit_score[which(dat[[q3]] == 1)] <- dat$audit_score[which(dat[[q3]] == 1)] + 0
  dat$audit_score[which(dat[[q3]] == 2)] <- dat$audit_score[which(dat[[q3]] == 2)] + 2
  dat$audit_score[which(dat[[q3]] == 3)] <- dat$audit_score[which(dat[[q3]] == 3)] + 3
  dat$audit_score[which(dat[[q3]] == 4)] <- dat$audit_score[which(dat[[q3]] == 4)] + 4

  # Audit Category
  dat$audit_cat <- NA
  dat$audit_cat[dat$audit_score == 0] <- 'abstainer'
  dat$audit_cat[dat$audit_score %in% (1:4)] <- 'low'
  dat$audit_cat[dat$audit_score %in% (5:7)] <- 'increasing'
  dat$audit_cat[dat$audit_score %in% (8:10)] <- 'high'
  dat$audit_cat[dat$audit_score %in% (11:12)] <- 'dependent'

  dat <- dat %>% select(pidp, audit_score, audit_cat)

  new.indresp <- merge(indresp_data, dat, by='pidp')

  return(new.indresp)
}

calc_audit_mainstage <- function(indresp_data_mainstage) {

  # generate the variable namesf (all follow naming convention 'c{wave_letter}_audit#')
  abst <- paste0('jk_auditc1')
  q1 <- paste0('jk_auditc3')
  q2 <- paste0('jk_auditc4')
  q3 <- paste0('jk_auditc5')

  dat <- indresp_data_mainstage %>% select(pidp, all_of(abst), all_of(q1), all_of(q2), all_of(q3))

  # 2. Generate new audit_score var
  dat$audit_score <- 0

  # 2.5. Check for nullness in audit vars and set score to 0 if all vars are present
  dat$audit_score[dat[[q1]] < 0] <- NA
  dat$audit_score[dat[[q2]] < 0] <- NA
  dat$audit_score[dat[[q3]] < 0] <- NA

  # 3. Populate new variable
  # Abstainers
  dat$audit_score[dat[[abst]] == 2] <- 0
  # Q1
  dat$audit_score[which(dat[[q1]] == 1)] <- 0
  dat$audit_score[which(dat[[q1]] == 2)] <- 1
  dat$audit_score[which(dat[[q1]] == 3)] <- 2
  dat$audit_score[which(dat[[q1]] == 4)] <- 3
  dat$audit_score[which(dat[[q1]] == 5)] <- 4
  dat$audit_score[which(dat[[q1]] == 6)] <- 4
  # Q2
  dat$audit_score[which(dat[[q2]] == 1)] <- dat$audit_score[which(dat[[q2]] == 1)] + 0
  dat$audit_score[which(dat[[q2]] == 2)] <- dat$audit_score[which(dat[[q2]] == 2)] + 1
  dat$audit_score[which(dat[[q2]] == 3)] <- dat$audit_score[which(dat[[q2]] == 3)] + 2
  dat$audit_score[which(dat[[q2]] == 4)] <- dat$audit_score[which(dat[[q2]] == 4)] + 3
  dat$audit_score[which(dat[[q2]] == 5)] <- dat$audit_score[which(dat[[q2]] == 5)] + 4
  # Q3
  dat$audit_score[which(dat[[q3]] == 1)] <- dat$audit_score[which(dat[[q3]] == 1)] + 0
  dat$audit_score[which(dat[[q3]] == 2)] <- dat$audit_score[which(dat[[q3]] == 2)] + 2
  dat$audit_score[which(dat[[q3]] == 3)] <- dat$audit_score[which(dat[[q3]] == 3)] + 3
  dat$audit_score[which(dat[[q3]] == 4)] <- dat$audit_score[which(dat[[q3]] == 4)] + 4

  # Audit Category
  dat$audit_cat <- NA
  dat$audit_cat[dat$audit_score == 0] <- 'abstainer'
  dat$audit_cat[dat$audit_score %in% (1:4)] <- 'low'
  dat$audit_cat[dat$audit_score %in% (5:7)] <- 'increasing'
  dat$audit_cat[dat$audit_score %in% (8:10)] <- 'high'
  dat$audit_cat[dat$audit_score %in% (11:12)] <- 'dependent'

  dat <- dat %>% select(pidp, audit_score, audit_cat)

  new.indresp <- merge(indresp_data_mainstage, dat, by='pidp')

  return(new.indresp)
}

