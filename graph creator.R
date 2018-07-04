#------------------------------------------------------
# Part of InstaCrawlR
# GitHub: https://github.com/JonasSchroeder/InstaCrawlR
# Code by Jonas Schröder
# See ReadME for instructions and examples
#------------------------------------------------------

library(igraph)
library(stringi)
library(tidyr)

#------------------------------
#Create Edgelist from Hashtags
#------------------------------
elist <- c()
ht <- read.csv("ht_unsort_HASHTAG.csv", sep = ",", stringsAsFactors = FALSE, header = T, fileEncoding = "UTF-8")
matrix <- as.matrix(ht[-1])
#nrow(matrix)
for(i in 1:nrow(matrix)){
    temp <- na.omit(as.character(matrix[i,]))
    #if necessary; check matrix for "NA"
    #temp <- temp[-which(temp == "NA")]
    if(length(temp)>1){
        elist <- c(elist, combn(temp,2))
    }
}

#-----------------
#Export Edge List
#-----------------
elist_m <- as.matrix(elist)
write.csv(elist_m, "edgelist_HASHTAG.csv", fileEncoding = "UTF-8", row.names=F)

#---------------
#Load Edge List
#---------------
imp_matrix <- as.matrix(read.csv("edgelist_HASHTAG.csv", sep = ";"))
elist_imp <- as.character(imp_matrix)
elist <- c(elist, elist_imp)

#---------------------
#Create Basic Networks
#---------------------
graph2 <- graph(edges=elist, directed=F)
graph2 <- simplify(graph2)

#Degree
dgr <- as.matrix(degree(graph2))
plot(dgr, type="l")

#Subgraph
graph3 <- induced.subgraph(graph2, which(dgr>80))
