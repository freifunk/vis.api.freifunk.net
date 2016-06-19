# convert JSON to data frame; learned from https://stackoverflow.com/a/27432542
ff.readJSONs = function(JSONs) {
  return(
    rbind.fill( 
      lapply(
        lapply(
          JSONs, 
          function(JSON) unlist(JSON)), 
        function(JSON) do.call("data.frame", as.list(JSON))
      )))
}

# basic data frame cleaning
ff.cleanDF <- function(df) {
  
  # convert some variables to more useful formats
  df$mtime <- as.Date(df$mtime, format = "%F %H:%M:%OS") # %F = %Y-%m-%d (ISO8601)
  df$state.nodes <- as.numeric(df$state.nodes)
  df$timeline.timestamp <- as.Date(df$timeline.timestamp, format = "%F")
  
  # very noisy time formats, using most common ("%F T%H:%M:%OS" => few more NA's)
  df$state.lastchange <- as.Date(df$state.lastchange, format = "%F")
  
  return(df)
}

# convert text in data frame to a sparse term matrix
ff.prepareWordcloud <- function(text, remPunct = TRUE) {
  df <- Corpus(VectorSource(text))
  if (remPunct == TRUE) { df <- tm_map(df, removePunctuation) }
  df <- tm_map(df, removeWords, stopwords("de"))
  return(as.data.frame(as.matrix(DocumentTermMatrix(df))))
}

ff.plotWordcloud <- function(terms, filename = "FF_wordcloud.png") {
  png(filename, width = 960, height = 960, res = 300)
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
