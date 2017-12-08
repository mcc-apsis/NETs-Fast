rm(list=ls())

library(scimetrix)
library(dplyr)
library(tidyr)

load("output/papers.RData")

#### Annual growth rates
disGrowth2 <- gRate(papers,"OECD",1995,2015)
disGrowth <- gRate(papers,"OECD",1995,2016)

write.csv(disGrowth,file="output/discipline_growth.csv")
