# Visualising Freifunk API data by Katrin Leinweber, June 2016
# in response to https://media.ccc.de/v/gpn16-7659-die_freifunk_api
# and https://wiki.freifunk.net/Ideas#Freifunk_API_visualisation_framework

library(ggplot2)
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

# routing protocols
FF_current_protocols <- as.data.frame(colSums(FF_prepareWordcloud(FFDF[, grepl("techDetails.routing", 
                                                                               names(FFDF))], 
                                                                  remPunct = FALSE)))

# expand to proper data frame, instead of named rows
names(FF_current_protocols) <- "used"
FF_current_protocols$protocol <- as.factor(rownames(FF_current_protocols))

# learned from https://trinkerrstuff.wordpress.com/2013/08/14/how-do-i-re-arrange-ordering-a-plot-revisited/
FF_current_protocols$protocol <- factor(FF_current_protocols$protocol, 
                                         levels = FF_current_protocols$protocol[order(FF_current_protocols$used)])
FF_current_protocols$fraction <- FF_current_protocols$used/sum(FF_current_protocols$used)

FFP_current_protocols <- ggplot(data = FF_current_protocols, 
                        mapping = aes(x = protocol, 
                                      y = fraction, 
                                      color = protocol)) + 
  geom_point() + 
  scale_y_continuous(labels = percent_format(), 
                     limits = c(0, # ensure dynamic resizin of y-axis, with...
                                max(FF_current_protocols$fraction)*1.1) # ... upper tick mark
                     ) +
  scale_color_manual(values = FF_wordPal) +
  labs(title = "Fractions of currently used routing protocols", 
       x = NULL, y = NULL, color = NULL) + 
  theme_classic()
FFP_current_protocols

ggsave(filename = "FF_protocols.png", 
       plot = FFP_current_protocols)

# sort protocols by popularity & remove rare for cleaner pie chart
FF_current_protocols <- FF_current_protocols[order(FF_current_protocols$used),] 
FF_current_common_protocols <- subset(FF_current_protocols, 
                                      used > 1)

# plot acceptable pie chart; learned from http://www.randalolson.com/2016/03/24/the-correct-way-to-use-pie-charts/
png(file = "FF_protocols_pie.png", width = 960, height = 960, res = 300)
print(pie(x = FF_current_common_protocols$used, 
          labels = rownames(FF_current_common_protocols),
          col = FF_wordPal,
          clockwise = T))
dev.off()
