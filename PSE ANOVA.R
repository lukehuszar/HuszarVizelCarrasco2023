# Initialize --------------------------------------------------------------
rm(list = ls())
library('R.matlab')
library('dplyr')
library('ez')
library('formattable')
trace(grDevices:::png, quote({
  if (missing(type) && missing(antialias)) {
    type <- "cairo-png"
    antialias <- "subpixel"
  }
}), print = FALSE)

# Load variables ----------------------------------------------------------
allDat <- readMat('Data/pseRDATA.mat')
# Collapsed across duration data
pseDat <- data.frame(data = allDat$PSEsR)
colnames(pseDat) <- c("subj","cueCond","pse")
pseDat$subj <- as.factor(pseDat$subj)
pseDat$cueCond <- as.factor(pseDat$cueCond)
# Seperated by duration data
pseDurDat <- data.frame(data = allDat$PSEsRDuration)
colnames(pseDurDat) <- c("subj","cueCond","duration","pse")
pseDurDat$subj <- as.factor(pseDurDat$subj)
pseDurDat$cueCond <- as.factor(pseDurDat$cueCond)
pseDurDat$duration <- as.factor(pseDurDat$duration)

# DURATION STATS -------------------------------------------------------------

# ANOVA with separate duration
pseDat_ANOVA <- ezANOVA(pseDurDat,
                        dv = pse,
                        wid = subj,
                        within = .(cueCond,duration),
                        return_aov = TRUE)

# COLLAPSED ACROSS DURATION STATS ---------------------------------------------

# ANOVA
pseDat_ANOVA <- ezANOVA(pseDat,
                           dv = pse,
                           wid = subj,
                           within = .(cueCond),
                           return_aov = TRUE)

# Post-hoc t-test: first-cued vs. both-cued
firstVSbothTTEST <- t.test(pseDat[pseDat$cueCond==1,]$pse, pseDat[pseDat$cueCond==3,]$pse, paired = TRUE)

# Post-hoc t-test: second-cued vs. both-cued
secondVSbothTTEST <- t.test(pseDat[pseDat$cueCond==2,]$pse, pseDat[pseDat$cueCond==3,]$pse, paired = TRUE)

# Post-hoc t-test: both-cued vs. o
bothTTEST <- t.test(pseDat[pseDat$cueCond==3,]$pse)

# Post-hoc t-test: first-cued vs. o
firstTTEST <- t.test(pseDat[pseDat$cueCond==1,]$pse)

