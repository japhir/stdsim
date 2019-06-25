# constants
kkelvin <- 273.15 # 0 °C
# acid fractionation (0.064 from Meckler et al. 2014, 0.062 from Muller 2017)
kaff <- 0.062
# get average slope from our data, in meas ~ exp
# weighted average etf meas ~ exp from CheckETFs.R
library(dplyr)
load("~/SurfDrive/PhD/programming/long-term-etf/out/ourslope.RData")
kslope <- stretches %>%
  # calculate weighted (by nstd) average
  mutate(multstretch = (nstd * slp) / sum(nstd, na.rm = TRUE)) %>%
  pull(multstretch) %>%
  sum(na.rm = TRUE)
## kslope <- 0.9122016  # manually enter the value for reproducibility
kintercept <- stretches %>%
  mutate(multint = (nstd * int) / sum(nstd, na.rm = TRUE)) %>%
  pull(multint) %>%
  sum(na.rm = TRUE)
## kintercept <- -0.832699
## values before 2018-05-04, reversed wording was confusing
## kslope <- 1.09412
## krev.intercept <- -0.7906195
# convert the slope and intercept to exp ~ raw (x ~ y)
krev.slope <- 1 / kslope
krev.intercept <- -kintercept / kslope
# for easy use in plots
kcols <- c("#3366cc", "#ffcc00", "#6699ff")
ktit_smpid <- "Sample temperature"
klab_smpid <- paste0(c("0", "40"), " \u00B0C")

## setwd("~/SurfDrive/PhD/projects/stdsim")
## usethis::use_data(kkelvin, kaff, kslope, kintercept, krev.slope,
                  ## krev.intercept, kcols, ktit_smpid, klab_smpid, overwrite=TRUE)
