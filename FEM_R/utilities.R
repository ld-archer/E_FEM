
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

