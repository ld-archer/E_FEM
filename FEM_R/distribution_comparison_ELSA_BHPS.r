
require(haven)
require(dplyr)
#require(ggplot2)

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



# Read in wave 4 of Understanding Society survey
surveyDir <- "/home/luke/Documents/E_FEM_clean/Understanding_Society/UKDA-6614-stata/stata/stata11_se/ukhls_w2/"
ind_name <- paste0(surveyDir, "b_indresp.dta")
US_w2 <- read_dta(ind_name)
#names(US_w2)

# Remove anyone under 50
US_w2 <- filter(US_w2, b_dvage>49)
# Keep only those who live in England (1==England)
US_w2 <- filter(US_w2, b_country=='1')

# Get table showing original values (including negatives/missing)
US_smok <- table(US_w2$b_smnow)

# Replace all negative values with NA
US_w2$b_smnow[US_w2$b_smnow < 0] <- NA

# Calculate proportion of smokers in wave 2 (binary smoke/no smoke)
US_smok_prop <- prop.table(table(US_w2$b_smnow))

US_smok_norm <- US_smok / max(US_smok)
boxplot(US_smok_norm)
barplot(US_smok_norm)


# Read in Harmonized ELSA
ELSA_dir <- "/home/luke/Documents/E_FEM/UKDA-5050-stata/stata/stata11_se/"
ELSA_name <- paste0(ELSA_dir, "h_elsa.dta")
H_ELSA <- read_dta(ELSA_name)
names(H_ELSA)











lookfor(US_w2, "age")
lookfor(H_ELSA, "smoke")
lookfor(H_ELSA, "year")

boxplot(H_ELSA$r5smokef, horizontal=TRUE, main='Smoking Now in ELSA')
hist(H_ELSA$r5smoken, breaks=10)

table(H_ELSA$r5smoken)
table(US_w2$b_smnow)
summary(US_w2$b_smnow)

barplot(table(H_ELSA$r5smoken))

chisq.test(H_ELSA$r5smoken, US_w2$b_smnow)


smoke_df <- data.frame()