# This script is for development of functions for visualising FEM outputs together

# Set working directory
getwd()
workingDir <- "/home/luke/Documents/E_FEM_clean/E_FEM"
setwd(workingDir)

# Include dependency packages
require(haven)
require(dplyr)

# Show 4 graphs in one image
par(mfrow=c(2,2))

# Function 1
# This is for cohort outputs
cohortVis <- function(cohortOutputList) {
  
  # First read in the baseline cohort output summary
  cohort <- read_dta('output/ELSA_cohort/ELSA_cohort_summary.dta')
  
  # Convert output scenario names in cohortOutputList to full paths to then read in the data
  pathList <- list()
  i <- 1
  for (element in cohortOutputList) {
    pathList[[i]] <- paste0('output/', element, '/', element, '_summary.dta')
    i <- i + 1
  }
  # Now read in datafiles to a list
  dataList <- lapply(pathList, read_dta)
  
  # Check everything is working with the input
  #lapply(dataList, names)
  
  # Now need to calculate survival rates 
  
}


commitList <- list('COMMIT_cSmoken3', 'COMMIT_cSmoken30')

cohortVis(commitList)






















pathList <- list()

i <- 1
for (element in commitList) {
  pathList[[i]] <- paste0('output/', element, '/', element, '_summary.dta')
  i <- i + 1
}

ticker <- 1
for (item in commitList) {
  path <- paste0('output/', item, '/', item, '_summary.dta')
  print(path)
  #varname <- paste0(item, ticker)
  paste0(item, ticker) <- read_dta(path)
  ticker <- ticker + 1
}


