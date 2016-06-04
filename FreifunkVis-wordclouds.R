# Visualising Freifunk API data by Katrin Leinweber, June 2016
# companion to FreifunkVis.R

library(RColorBrewer)
library(tm)
library(wordcloud)

FF_prepareWordcloud = function(x) {
  df = Corpus(VectorSource(x))
  df = tm_map(df, removePunctuation)
  df = tm_map(df, removeNumbers)
  df = tm_map(df, removeWords, stopwords("de"))
  return(as.data.frame(as.matrix(DocumentTermMatrix(df))))
}

# all RColerBrewer qualitative palettes
FF_wordPal = c(brewer.pal(n = 8, name = "Dark2"),
               brewer.pal(n = 8, name = "Set1"))

# service name cloud; learned from http://stackoverflow.com/a/29852089
FFServices = FFDF[, grepl("services.serviceName", names(FFDF))]
FFServicesTM = FF_prepareWordcloud(x = FFServices)

# description cloud 
FFDescriptionsTM = FF_prepareWordcloud(x = FFDF$state.description)
FFDescriptionsTM = FFDescriptionsTM[, setdiff(names(FFDescriptionsTM), 
                                          c("freifunk", "freifnunk", "freifunker_innen", "freifunkerinnen"))]
