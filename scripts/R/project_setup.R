## This may take a while - we'll install all necessary packages at the 
library(checkpoint)
checkpoint("2017-01-20", checkpointLocation = "scripts/R/pkgs")
devtools::install_github("mcallaghan/scimetrix")
# Install LDAvis as not available in MRAN
install.packages("LDAvis")
library(scimetrix)
library(Rmpfr)
library(pacman)
