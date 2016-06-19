# Visualising Freifunk API data 
# by Katrin Leinweber, June 2016
# in response to https://media.ccc.de/v/gpn16-7659-die_freifunk_api
# and https://wiki.freifunk.net/Ideas#Freifunk_API_visualisation_framework

library(ggplot2)
library(jsonlite)  # fromJSON
library(plyr)      # rbind.fill
library(RCurl)     # getURL
library(scales)    # percent_format

# load functions
source("ffFunctions.R")

# read in JSON & remove line breaks
# prevents "lexical error: invalid character inside string." in fromJSON
ffk.currentJSON <- gsub(
  x = getURL("https://api.freifunk.net/data/ffSummarizedDir.json"),
  pattern = "\r\n",
  replacement = " "
)

# generate basic data frame for testing
ffk.fromCurrentJSON <- fromJSON(ffk.currentJSON)
ffdf <- ff.readJSONs(ffk.fromCurrentJSON)
ffdf <- ff.cleanDF(ffdf)


# further data processing & visualisations in separate files.
source(file = "FreifunkVis-timeseries.R")
source(file = "FreifunkVis-wordclouds.R")


# routing protocols
ffdf.currentProtcols <- as.data.frame(
  colSums(
    ff.prepareWordcloud(
      ffdf[ , grepl("techDetails.routing", 
                    names(ffdf))], 
      remPunct = FALSE)
  ))

# expand to proper data frame, instead of named rows
names(ffdf.currentProtcols) <- "used"
ffdf.currentProtcols$protocol <- as.factor(rownames(ffdf.currentProtcols))

# learned from https://trinkerrstuff.wordpress.com/2013/08/14/how-do-i-re-arrange-ordering-a-plot-revisited/
ffdf.currentProtcols$protocol <- factor(
  x      = ffdf.currentProtcols$protocol, 
  levels = ffdf.currentProtcols$protocol[order(ffdf.currentProtcols$used)])
ffdf.currentProtcols$fraction <- ffdf.currentProtcols$used/sum(ffdf.currentProtcols$used)

ffp.currentProtcols <- ggplot(
  data = ffdf.currentProtcols, 
  mapping = aes(x     = protocol, 
                y     = fraction, 
                color = protocol)
) + 
  geom_point(show.legend = FALSE) + 
  scale_y_continuous(labels = percent_format(), 
                     limits = c(0, # ensure dynamic resizin of y-axis, with...
                                max(ffdf.currentProtcols$fraction)*1.1) # ... upper tick mark
  ) +
  scale_color_manual(values = ffk.palette) +
  labs(title = "Fractions of currently used routing protocols", 
       x = NULL, y = NULL, color = NULL) + 
  theme_classic()
ffp.currentProtcols

ggsave(filename = "FF_protocols.png", 
       plot = ffp.currentProtcols)


# sort protocols by popularity & remove rare for cleaner pie chart
ffdf.currentProtcols <- ffdf.currentProtcols[order(ffdf.currentProtcols$used),] 
ffdf.currentCommonProtocols <- subset(ffdf.currentProtcols, used > 1)

# plot acceptable pie chart; learned from http://www.randalolson.com/2016/03/24/the-correct-way-to-use-pie-charts/
png(file = "FF_protocols_pie.png", width = 960, height = 960, res = 300)
print(pie(x         = ffdf.currentCommonProtocols$used, 
          labels    = rownames(ffdf.currentCommonProtocols),
          col       = ffk.palette,
          clockwise = T
))
dev.off()
