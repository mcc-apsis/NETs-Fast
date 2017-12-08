rm(list=ls())

library(ggplot2)
library(tm)
#library(wordcloud)
library(dplyr)
library(tidyr)

#devtools::install_github("mcallaghan/scimetrix")
library(scimetrix)

source("/home/apsis/NETs/R/functions.R")
load("output/papers.RData")



#############
## Plot IPCC
ARs <- c("FAR","SAR","TAR","AR4","AR5")

papers$AP <- cut(papers$PY,
                 c(0,1985,1990.1,1995.1,2001.1,2007.1,2013.1,Inf),
                 c(NA,"AR1","AR2","AR3","AR4","AR5","AR6")
)

APsums <- IPCCgraph(papers,100)


#ggsave("~NETs/plots/IPCC_sums.png",width=8,height=5)
#write.csv(APsums,file="results/newQ_08_22data/APsums.csv")

papers$OECD[grep("10.1146/annurev-resource-100815-095548",papers$DI)] <- "Agricultural Sciences"


#############
## Plot disciplines
dsums <- paperNumbers(papers,"OECD","all")

#ggsave("results/newQ_08_22/plots/final/discipline_sums.png",width=8,height=5)

library(grid)
library(gridExtra)

APgraph <- IPCCgraph(papers,90,T,bSize=18) +
  ylim(0,500)
dgraph <- paperNumbers(papers,"OECD","all",graph=T,bSize=18) +
  ylim(0,500)

scimetrix::paperNumbers


png("output/plots/Fig2_2.png",width=1000,height=600)
grid.arrange(APgraph,dgraph,ncol=2)
dev.off()

############################
## Load all climate data
# all_cc <- as.data.frame(data.table::fread("../WoSQuery/WoSqueryPY.txt"))
# names(all_cc) <- c("PY","nClimate","x")
# all_cc <- select(all_cc,-x)
# 
# all_WoS <- as.data.frame(data.table::fread("WoS/the.txt"))
# names(all_WoS) <- c("PY","nWoS","x")
# all_WoS <- select(all_WoS,-x)

all_papers <- papers %>%
  group_by(PY) %>%
  summarise(nNETs = length(PY))

#### compound NET growth
nNET_growth <- 
  ((
    tail(all_papers$nNETs,1)/ #most recent
      head(all_papers$nNETs,1) #earliest
  )^(1/(tail(all_papers$PY,1)-head(all_papers$PY,1)))-1)*100 # to the power of 1/number of years * 100 to obtain pcnt

doubling <- 72/nNET_growth

string <- paste0("NETs literature has grown at an annual rate of ",round(nNET_growth),
                 "%, doubling approximately every ",round(doubling,1)," years")

write(string,file="text_output/NETs_growth.txt")


