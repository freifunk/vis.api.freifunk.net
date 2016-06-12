# Visualising Freifunk API data 
# by Katrin Leinweber, June 2016
# companion to FreifunkVis.R

library(RColorBrewer)
library(tm)
library(wordcloud)

ff.prepareWordcloud <- function(x, remPunct = TRUE) {
  df <- Corpus(VectorSource(x))
  if (remPunct == TRUE) { df <- tm_map(df, removePunctuation) }
  df <- tm_map(df, removeWords, stopwords("de"))
  return(as.data.frame(as.matrix(DocumentTermMatrix(df))))
}

# all RColerBrewer qualitative palettes
ffk.palette <- c(brewer.pal(n = 8, name = "Dark2"),
                 brewer.pal(n = 8, name = "Set1"))

ff.plotWordcloud <- function(x, filename = "FF_wordcloud.png") {
  png(file = filename, width = 960, height = 960, res = 300)
  print(
    wordcloud(colnames(x), 
              colSums(x),
              colors       = ffk.palette,
              random.color = T,
              max.words    = length(ffk.palette), 
              min.freq     = 2
    ))
  dev.off()
}

# service name cloud; learned from http://stackoverflow.com/a/29852089
ffdf.services <- ffdf[, grepl("services.serviceName", names(ffdf))]
fftm.services <- ff.prepareWordcloud(x = ffdf.services)
ff.plotWordcloud(x = fftm.services, filename = "FF_service_cloud.png")

# description cloud 
fftm.descriptions <- ff.prepareWordcloud(x = ffdf$state.description)
fftm.descriptions <- fftm.descriptions[, setdiff(names(fftm.descriptions), 
                                                 c("freifunk", "freifnunk", "freifunker_innen", "freifunkerinnen"))]
ff.plotWordcloud(x = fftm.descriptions, filename = "FF_description_cloud.png")

# [ ] uplod PNGs to webserver for static linking
