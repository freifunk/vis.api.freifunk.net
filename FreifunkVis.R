# Visualising Freifunk API data by Katrin Leinweber, June 2016
# in response to https://media.ccc.de/v/gpn16-7659-die_freifunk_api
# and https://wiki.freifunk.net/Ideas#Freifunk_API_visualisation_framework

library(jsonlite) # fromJSON
library(plyr) # rbind.fill
library(RCurl) # getURL

# read in & clean JSON file (FF = Freifunk, 3rd F = file)
FFF <- getURL("https://api.freifunk.net/data/ffSummarizedDir.json")
FFF <- gsub(pattern = "\r\n", # line-breaks
            replacement = " ", 
            x = FFF)

# basic data frame (DF) cleaning
FF_cleanDF <- function(DF) {
  
  # convert some variables to more useful formats
  DF$mtime <- as.Date(DF$mtime, format = "%F %H:%M:%OS") # %F = %Y-%m-%d (ISO8601)
  DF$state.nodes <- as.numeric(DF$state.nodes)
  DF$timeline.timestamp <- as.Date(DF$timeline.timestamp, format = "%F")
  
  # very noisy time formats, using most common ("%F T%H:%M:%OS" => few more NA's)
  DF$state.lastchange <- as.Date(DF$state.lastchange, format = "%F")
  
  return(DF)
}

# convert JSON to data frame; learned from https://stackoverflow.com/a/27432542
FF_readJSONs = function(JSON) {
  return(rbind.fill( 
    lapply(
      lapply(
        JSON, 
        function(x) unlist(x)), 
      function(x) do.call("data.frame", as.list(x))
    )))
}

# generate basic data frame for testing
FFF <- fromJSON(FFF)
FFDF <- FF_readJSONs(FFF)
FFDF <- FF_cleanDF(FFDF)

# further data processing & visualisations in separate files.
source(file = "FreifunkVis-timeseries.R")
source(file = "FreifunkVis-wordclouds.R")

