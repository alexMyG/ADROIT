library(tm)
library("slam")
library("clValid")
library(caret)
library("fpc")
library(ROCR)
library(data.table)

# Values to manage sparsity when building term document matrix
sparseValues <- c(0.95, 0.96, 0.97, 0.98, 0.99, 0.995, 0.999)

for (sparseValue in sparseValues){
  
  print(paste("SPARSE: ", sparseValue))
  
  res <- fread("FINAL/dataset.csv", sep = ";", showProgress=getOption("datatable.showProgress"))
 
  res <-as.data.frame(as.matrix(res))
  
  res$HasDescription <- res$description != "None"
  
  # Samples without description are removed
  res <- res[res$HasDescription == TRUE,]
  allColumns <- colnames(res)
  allColumns <- allColumns[2:length(allColumns)-1] 
  res <- res[,c("name", "HasDescription", allColumns)]
  res <- as.data.frame(res)
  res$name.1 <- NULL
  
  
  
  ################################
  # Text mining over descriptions
  ################################
  
  
  res$description <-  gsub("[^[:alnum:]///' ]", "", res$description)
  
  descriptionsCorpus <- Corpus(VectorSource(res$description))
  
  descriptionsCorpus <- tm_map(descriptionsCorpus, content_transformer(tolower)) #minuscula
  descriptionsCorpus <- tm_map(descriptionsCorpus, removeNumbers)
  descriptionsCorpus <- tm_map(descriptionsCorpus, removePunctuation)
  descriptionsCorpus <- tm_map(descriptionsCorpus, removeWords, stopwords("english"))
  descriptionsCorpus <- tm_map(descriptionsCorpus, removeWords, stopwords("spanish"))
  descriptionsCorpus <- tm_map(descriptionsCorpus, removeWords, c("rt","amp","will"))
  descriptionsCorpus <- tm_map(descriptionsCorpus,  stripWhitespace)
  
  termDocumentMatrix <- TermDocumentMatrix(descriptionsCorpus, control=list(wordLengths=c(1,Inf)))
  
  # Removing sparse terms
  termDocumentMatrixNoSparse <- removeSparseTerms(termDocumentMatrix,sparse=sparseValue)
  
  # Building matrix 
  m2 <- as.matrix(termDocumentMatrixNoSparse)
  m2DF <- as.data.frame(m2)
  m2DFtransposed <- t(m2DF)
  
  newDataset <- res
  
  # Adding term document matrix to dataset
  newDataset <- cbind(newDataset, m2DFtransposed)
  
  newcolnames <- c(colnames(newDataset)[colnames(newDataset) != "LABEL"],"LABEL")
  
  newDataset <- newDataset[,newcolnames]
  
  newDataset <- newDataset[sample(nrow(newDataset)),]
  newcolnames <- c(colnames(newDataset)[colnames(newDataset) != "description"])
  
  newDataset <- newDataset[,newcolnames]
  newDataset$description <- NULL
  newDataset$...MD5 <- NULL
  
  write.csv(newDataset, file = "aux.csv", row.names = FALSE)

  
  # Data preprocessingr
  a <- read.csv(file = "aux.csv", sep = ",")
  a$X <- NULL
  
  colNames <- colnames(a)
  
  colNames <- gsub("\\.\\.\\.", "", colNames)
  colnames(a) <-colNames
  
  a <- apply(a,2,function (col){
    col[is.na(col)] <- ifelse(class(col)=="numeric",0,"NA")
    col
  })
  
  
  numAttributes <- ncol(a) - 1
  positionLabel <- ncol(a)
  
  a <- as.data.frame(unclass(a))
  
  b <- as.matrix(a[,1:numAttributes])
  
  b[is.na(b)]<-0
  
  c <- as.matrix(a[,positionLabel])
  
  spaceC <- data.frame(c[,1],b)
  colnames(spaceC)[1] <- "Class"
  
  
  spaceC$Class <- as.character(spaceC$Class)
  spaceC$Class[spaceC$Class == "malware"] <- "1"
  spaceC$Class[spaceC$Class == "benignware"] <- "0"
  
  spaceC$Class[spaceC$Class == "malware"] <- "1"
  spaceC$Class[spaceC$Class == "benignware"] <- "0"
  
  spaceC$Class <- as.factor(spaceC$Class)
  
  
  spaceC$name <- NULL
  spaceC$Signature <- NULL
  spaceC$State <- NULL
  
  
  
  #########################################################
  #        generate csv to be used with python sklearn
  #########################################################
  spaceCdatasetCSV <- as.matrix(subset(spaceC, select=c(2:ncol(spaceC),1)))
  for (col_idx in 1:ncol(spaceCdatasetCSV)) {
    spaceCdatasetCSV[,col_idx] <- as.numeric(as.factor(spaceCdatasetCSV[,col_idx]))
  }
  class(spaceCdatasetCSV) <- "numeric"
  
  #Balancing
  
  ind1 <- which(spaceCdatasetCSV[,"Class"]==2)
  ind0 <- which(spaceCdatasetCSV[,"Class"]==1)
  
  sampsize <- min(length(ind1), length(ind0))
  
  sampind1 <- sample(ind1, sampsize)
  sampind2 <- sample(ind0, sampsize)
  
  sampind <- c(sampind1,sampind2)
  
  spaceCdatasetCSVbalanced <- spaceCdatasetCSV[sampind,]
  
  
  
  write.csv(spaceCdatasetCSV, file = paste("datasetSklearn_",sparseValue,"sparse_all_features_non_none_descriptions.csv", sep = ""), row.names = FALSE)
  write.csv(spaceCdatasetCSVbalanced, file = paste("datasetSklearn_",sparseValue,"sparse_balanced_all_features_non_none_descriptions.csv", sep = ""), row.names = FALSE)
  
}
