# Visualising Freifunk API data by Katrin Leinweber, June 2016
# companion to FreifunkVis.R

library(RColorBrewer)
library(tm)
library(wordcloud)

FF_prepareWordcloud = function(x, remPunct = TRUE) {
  df = Corpus(VectorSource(x))
  if (remPunct == TRUE) {df = tm_map(df, removePunctuation)}
  df = tm_map(df, removeWords, stopwords("de"))
  return(as.data.frame(as.matrix(DocumentTermMatrix(df))))
}

# all RColerBrewer qualitative palettes
FF_wordPal = c(brewer.pal(n = 8, name = "Dark2"),
               brewer.pal(n = 8, name = "Set1"))

FF_plotWordcloud = function(x, filename = "FF_wordcloud.png") {
  png(file = filename, width = 960, height = 960, res = 300)
  print(wordcloud(colnames(x), 
                  colSums(x),
                  colors = FF_wordPal,
                  random.color = T,
                  max.words = length(FF_wordPal), 
                  min.freq = 2)
        )
  dev.off()
}

# service name cloud; learned from http://stackoverflow.com/a/29852089
FFServices = FFDF[, grepl("services.serviceName", names(FFDF))]
FFServicesTM = FF_prepareWordcloud(x = FFServices)
FF_plotWordcloud(x = FFServicesTM, filename = "FF_service_cloud.png")

# description cloud 
FFDescriptionsTM = FF_prepareWordcloud(x = FFDF$state.description)
FFDescriptionsTM = FFDescriptionsTM[, setdiff(names(FFDescriptionsTM), 
                                          c("freifunk", "freifnunk", "freifunker_innen", "freifunkerinnen"))]
FF_plotWordcloud(x = FFDescriptionsTM, filename = "FF_description_cloud.png")

# [ ] uplod PNGs to webserver for static linking
