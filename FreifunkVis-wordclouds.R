# Visualising Freifunk API data 
# by Katrin Leinweber, June 2016
# companion to FreifunkVis.R

library(RColorBrewer)
library(tm)
library(wordcloud)

# all RColerBrewer qualitative palettes
ffk.palette <- c(brewer.pal(n = 8, name = "Dark2"),
                 brewer.pal(n = 8, name = "Set1"))

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
