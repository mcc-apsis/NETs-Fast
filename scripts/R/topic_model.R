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

##########################################################################
## Load results & generate corpus

papers <- readWoS("input/queries/NETS_query_v7/results.txt") %>%
  mergeOECD()

# remove duplicated papers
papers <- papers[!duplicated(papers$UT),]

# make a corpus
corpus <- corporate(papers)

# make a doc-term matrix and refresh the corpus to reflect any docs removed in the process
dtm <- makeDTM(corpus,0.98,papers$UT,0.05,0)

rem <- filter(papers,UT %in% dtm$removed)
papers_used <- subset(papers, !(UT %in% dtm$removed))
corpus_used <- refresh_corp(dtm$dtm)

# save data
papers <- papers_used
corpus <- corpus_used
save(papers,corpus,dtm,file="output/papers.RData")

rm(papers_used,corpus_used,rem)


##########################################################################
# Topic model

load("output/papers.RData")

# What's the optimal K?
#optimal_k(dtm$dtm, 40)

SEED <- 2016

system.time({
  LDA_19_098 = LDA(dtm$dtm,k=19,method="VEM",
                   control=list(seed=SEED))
})

# saves the results into the working dir

visualise(LDA_19_098,corpus,dtm$dtm,dir="output/LDA_19_098")

#########################################
# Assign topics to papers

load("output/LDA_19_098/papers.RData")

model_name <- "LDA_19_098"

load(paste0("output/",model_name,"/model_output.RData"))

papers$topic_number <- paste0("Topic ",topics(model,1))
papers$topic_words <- paste0(
  terms(model,10)[1,papers$topic_number],", ",
  terms(model,10)[2,papers$topic_number],", ",
  terms(model,10)[3,papers$topic_number]
)

# make a summary of topics and frequency
json <- fromJSON(paste0("output/",model_name,"/lda.json"))
tfreq <- data.frame(topic = paste0("Topic ",json$topic.order),
                    freq=json$mdsDat$Freq)

t <- as.data.frame(terms(model,10)) %>%
  gather(topic,keywords) %>%
  mutate(topic = factor(topic,levels=unique(topic))) %>%
  group_by(topic) %>%
  summarise(
    keywords=paste0(keywords,collapse=", ")
  ) %>%
  left_join(tfreq)
write.table(t,file=paste0("output/",model_name,"/",model_name,"_topic_terms.csv"),sep=";",row.names = F)

# generate a list of top correlating papers for each topic
top_papers <- top_topic_papers(papers,model)
write.table(top_papers,file=paste0("output/",model_name,"/",model_name,"_top_correlating_papers.csv"),sep=";",row.names = F)

save(papers,file=paste0("output/",model_name,"/papers.RData"))

rm(t,tfreq,top_papers,dtm,json)


#########################################
###### NOW READ SPREADSHEET /output/modelname/modelname_topic_terms.csv
###### AND MANUALLY ASSIGN TOPIC NAMES IN LAST COLUMN
#########################################


