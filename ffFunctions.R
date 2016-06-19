# convert JSON to data frame; learned from https://stackoverflow.com/a/27432542
ff.readJSONs = function(JSONs) {
  return(
    rbind.fill( 
      lapply(
        lapply(
          JSONs, 
          function(x) unlist(x)), 
        function(x) do.call("data.frame", as.list(x))
      )))
}

# basic data frame cleaning
ff.cleanDF <- function(x) {
  
  # convert some variables to more useful formats
  x$mtime <- as.Date(x$mtime, format = "%F %H:%M:%OS") # %F = %Y-%m-%d (ISO8601)
  x$state.nodes <- as.numeric(x$state.nodes)
  x$timeline.timestamp <- as.Date(x$timeline.timestamp, format = "%F")
  
  # very noisy time formats, using most common ("%F T%H:%M:%OS" => few more NA's)
  x$state.lastchange <- as.Date(x$state.lastchange, format = "%F")
  
  return(x)
}

# convert text in data frame to a sparse term matrix
ff.prepareWordcloud <- function(x, remPunct = TRUE) {
  df <- Corpus(VectorSource(x))
  if (remPunct == TRUE) { df <- tm_map(df, removePunctuation) }
  df <- tm_map(df, removeWords, stopwords("de"))
  return(as.data.frame(as.matrix(DocumentTermMatrix(df))))
}

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
