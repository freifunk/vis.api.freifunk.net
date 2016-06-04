# Visualising Freifunk API data by Katrin Leinweber, June 2016
# companion to FreifunkVis.R

library(stringr) # str_extract_all

# prepare timelines
FF_JSONs <- list.files(pattern = "[0-9]{8}-.*-ffSummarizedDir.json$")

# combine all JSONs into single data frame
FFDF <- rbind.fill(lapply(lapply(FF_JSONs, fromJSON), FF_readJSONs))
FFDF <- FF_cleanDF(FFDF)
