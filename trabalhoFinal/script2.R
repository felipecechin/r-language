data <- read.csv(file="papers_data_noise.csv", header=TRUE, sep=",")
data <- subset(data, select = -X)

subt <- read.csv(file="papers_subt_noise.csv", header=TRUE, sep=",")
subt <- subset(subt, select = -X)

data<- data[(!is.na(data$paper)),]
subt<- subt[(!is.na(subt$paper)),]

subtopics <- subt$subtopics
dataFrame <- data.frame(data, subtopics)

dataFrame <- dataFrame[(dataFrame$year >= 2000),]

subt <- read.csv(file="topics.csv", header=TRUE, sep=";")

idSubtopics <- subt$subtopic
length(idSubtopics)

idSubtopics <- append(idSubtopics, "aceito", after = length(idSubtopics))

library(BBmisc)

dados <- setNames(data.frame(matrix(ncol = length(idSubtopics), nrow = 0)), idSubtopics)

#install.packages("BBmisc")

for (i in 1:nrow(dataFrame)) {
  ids <- dataFrame[i, "subtopics"]
  ids <- as.character(ids)
  ids <- explode(ids, "-")
  for (j in 1:length(ids)) {
    dados[i, ids[j]] = 1
  }
  if (dataFrame[i, "status"] == "accepted") {
    dados[i, "aceito"] = 1
  }
}

dados[is.na(dados)] = 0

library(arules)
dados <- as.matrix(dados)


#Ha um padrao aqui, todos os artigos com o subtopico 67, tambem tem o subtopico 9
select <- dados[dados[, "67"] == 1,]

varApriori <- apriori(dados, parameter = list(sup = 0.01, conf = 1))
inspect(sort(varApriori, decreasing = TRUE, by="confidence"))
