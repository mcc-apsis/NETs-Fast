top_topic_papers <- function(papers,model,nosum=F) {
  topics <- unlist(terms(model,10)[1:10,])
  topics <- paste0(topics[1,],", ",topics[2,],", ",topics[3,],", ",topics[4,],", ",topics[5,])
  
  gamma <- as.data.frame(model@gamma)
  names(gamma) <- topics
  
  paper_topics <- papers %>%
    select(TI,AU,AB,TC,UT,PY) %>%
    cbind(gamma) %>%
    gather_("topic","p",topics) 
  
  if (nosum==T) {
    return(paper_topics)
  }
  
  n_papers <- paper_topics %>%
    group_by(UT) %>%
    summarise(topic = topic[which.max(p)]) %>%
    group_by(topic) %>%
    summarise(n=length(topic)) %>%
    ungroup()
  
  topic_groups <- paper_topics %>%
    left_join(n_papers) %>%
    group_by(topic) %>%
    arrange(-p) %>%
    top_n(10,p) 
  
  return(topic_groups)
}

IPCCgraph <- function(df,offset,graph=F,bSize=12) {
  
  apCounts <- df %>%
    group_by(AP) %>%
    summarise(
      total = formatC(length(AP),format="d", big.mark=',',preserve.width="none"),
      midY = median(unique(PY)),
      maxV = length(AP)/length(unique(PY))
    ) %>%
    ungroup() %>%
    filter(AP %in% c("AR1","AR2","AR3","AR4","AR5","AR6")) %>%
    mutate(
      total = paste0("[",total,"]")
    )
  
  apCounts[apCounts$AP=="AR5",]$midY <- apCounts[apCounts$AP=="AR5",]$midY - 0.7
  
  p <- ggplot() +
    geom_bar(
      data = filter(df,PY>=1985),
      aes(PY,fill=AP),
      #stat="identity",
      colour="grey22"
    ) +
    geom_text(
      data=apCounts,
      aes(label=total,x=midY,y=maxV+offset),
      hjust = 0.7,
      size=6
    ) +
    scale_fill_brewer(palette="Spectral",name="Assessment Period") +
    guides(fill = guide_legend(reverse = TRUE)) +
    labs(x="Year",y="Number of Publications") +
    theme_classic(base_size = bSize) +
    theme(
      legend.position=c(0.01,0.99),
      legend.justification=c(0,1),
      #legend.direction="horizontal",
      panel.grid.major.y=element_line(size=0.2,colour="grey22"),
      panel.border=element_rect(size=0.2,colour="grey22",fill=NA)
    ) 
  
  print(p)
  
  if (graph==T) {
    return(p)
  }
  
  APsums <- df %>%
    group_by(AP,PY) %>%
    summarise(
      n=length(PY)
    ) %>%
    spread(AP,n)
}


docCors <- function(papers,model) {
  ############## compute and visualize document correlations ###############
  papers$topic <- topics(model,1)
  
  # papers$topic_name <- paste0(
  #   terms(model,10)[1,papers$topic],",",
  #   terms(model,10)[2,papers$topic],",",
  #   terms(model,10)[3,papers$topic]
  # )
  
  topics <- unlist(terms(model,10)[1:2,])
  
  topics <- paste0(topics[1,],", ",topics[2,])
  
  gamma <- as.data.frame(model@gamma)
  
  names(gamma) <- topics
  #### Document correlations ####
  # Now calculate document correlations (leave out first col with doc names)
  cors <- cor(t(gamma[,]))
  # set bottom half to zero
  cors[ lower.tri(cors, diag=TRUE) ] <- 0
  # keep only +ve and big correlations (ie. r > 0.8)
  cors[cors < 0.6] <- 0
  # put topic names back on
  colnames(cors) <- papers$TI
  
  
  g <- as.undirected(graph.adjacency(cors,  weighted=TRUE, mode = "upper"))
  # define layout
  layout1 <- layout.fruchterman.reingold(g, niter=500)
  # use degree to control vertex and font size
  b1 <- unname(degree(g))
  
  papers$b1 <- b1
  
  cNodes <- papers %>%
    group_by(topic_name) %>%
    top_n(1,b1)
  
  cNodes <- cNodes[!duplicated(cNodes[,c("topic","b1")]),]
  
  papers$label_gname <- ifelse(
    papers$UT %in% cNodes$UT,
    papers$topic_name,
    ""
  )
  
  V(g)$label.cex <-  b1 * 2  / max(b1) # label text size
  V(g)$size      <-  b1  / max(b1)        # node size
  V(g)$g_name <- papers$topic_name
  V(g)$g_label <- papers$label_gname
  # plot(g, layout=layout1, edge.curved = TRUE, 
  #      vertex.color= "white", 
  #      edge.arrow.size = 0, 
  #      vertex.label.family = 'sans'
  # )
  return(g)
}
