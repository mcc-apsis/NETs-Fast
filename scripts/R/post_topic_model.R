rm(list=ls())
library(devtools)
library(bibliometrix)
library(SnowballC)
library(servr)
library(httpuv)
library(ggplot2)
library(tm)
#library(wordcloud)
library(dplyr)
library(tidyr)
library(stringr)
library(topicmodels)
library(igraph)
library(jsonlite)



library(scimetrix)

source("scripts/R/functions.R")

model_name <- "LDA_19_098"

load(paste0("output/",model_name,"/papers.RData"))

load(paste0("output/",model_name,"/model_output.RData"))


# Join new topic names to papers 

topic_terms <- read.csv(paste0("output/",model_name,"/",model_name,"_topic_terms.csv"),header=T,sep=";")



### use topic number instead of names if no names
if (length(topic_terms)==3) {
  topic_terms$topic_name <- topic_terms$topic
}

names(topic_terms) <- c("topic_number","topic_words_all","freq","topic_name")
topic_terms <- subset(topic_terms,select = c("topic_number","topic_name"))

topic_names <- unique(as.character(topic_terms$topic_name))
gamma <- as.data.frame(model@gamma)
names(gamma) <- topic_names

papers <- papers %>%
  left_join(topic_terms)

save(papers,file=paste0("output/",model_name,"/papers.RData"))

#########################################
## Write correlation graphs

g <- topCors(model)
write.graph(g, file=paste0("output/",model_name,"/",model_name,"_topic_correlations.graphml"), format="graphml") 

gg <- docCors(papers,model)
write.graph(gg, file=paste0("output/",model_name,"/",model_name,"_document_correlations.graphml"), format="graphml") 
