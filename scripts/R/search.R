rm(list=ls())

library(ggplot2)
library(tm)
library(wordcloud)
library(dplyr)
library(tidyr)
library(ggplot2)
library(stringr)
library(topicmodels)

source("scripts/R/functions.R")

model_name <- "LDA_19_098"

load(paste0("output/",model_name,"/model_output.RData"))
load(paste0("output/",model_name,"/papers.RData"))


#########################################
## Define the search term

searchTerm <- ("(integrated assessment) | IAM | GCAM | MESSAGE | IMAGE | REMIND | WITCH | riahi | krey | vuuren | kriegler | luderer" ) ## This can be a regular expression
#searchTerm <- ("enhanced weathering" ) ## This can be a regular expression


## Look for it
papers$search <- ifelse(
  grepl(searchTerm,papers$AB) | 
    grepl(searchTerm,papers$TI),
  1,
  0
)


## Filter docs that match the search term
searchMatches <- filter(papers,search==1)
