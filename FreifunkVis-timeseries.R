# Visualising Freifunk API data by Katrin Leinweber, June 2016
# companion to FreifunkVis.R

library(ggplot2)
library(scales) # date_format
library(stringr) # str_extract_all

# prepare timelines
FF_JSONs <- list.files(pattern = "[0-9]{8}-.*-ffSummarizedDir.json$")
FF_days <- as.character(str_extract_all(FF_JSONs, pattern = "[0-9]{8}"))

if ("00000000-ffSummarizedDir.csv" %in% list.files(getwd())) {
  
  # use summary file if available, instead of reading files individually
  try(known_FFDF <- read.csv2("00000000-ffSummarizedDir.csv", 
                              encoding = "UTF-8"))
  
  # check for existing FFDF date & merge with new
  if (length(unique(known_FFDF$mtime)) < length(FF_JSONs)) {
  # naive, because single FF_JSON can include several different days
  # tried (unique(gsub("-", "", as.character(known_FFDF$mtime))) %in% FF_days),
  # but returns list of Booleans => unsuitable for if condition

    # read in & generate data frame only from new JSONs
    known_days <- gsub(pattern = "-",
                       replacement = "",
                       x = unique(known_FFDF$mtime))
    new_days <- setdiff(FF_days, known_days)
    new_FFDF <- rbind.fill(
      lapply(
        lapply(list.files(pattern = new_days), # [ ] get this to return list of all new file**names**, not just the 1st new file
               fromJSON), 
        FF_readJSONs))
    
    # combine known & new data frames
    FFDF <- rbind.fill(known_FFDF, new_FFDF)  
    # learned from http://stackoverflow.com/a/27313467
  }
} else {
  # combine all JSONs into single data frame
  FFDF <- rbind.fill(lapply(lapply(FF_JSONs, fromJSON), FF_readJSONs))
  # same as inner else, just to catch edge case of repetive plotting without adding new JSONs
}

FFDF <- FF_cleanDF(FFDF)

# export combined data frame
write.csv2(x = FFDF, file = "00000000-ffSummarizedDir.csv", row.names = FALSE)

# plot timeseries of average node number per community over time
FFP_nodeNumber <- ggplot(data = subset(x = FFDF, 
                                       select = c("name", 
                                                  "mtime", 
                                                  "state.nodes")), 
                         mapping = aes(x = mtime,
                                       y = state.nodes)) + 
  geom_point(stat = "summary", color = "#ffb400") +
  stat_smooth(color = "#dc0067", se = FALSE) + 
  scale_x_date(labels = date_format("%b '%y")) +
  expand_limits(y = 0) +  # learned from http://stackoverflow.com/a/13701732/4341322
  ggtitle("Nodes per Community (average) over Time") +
  xlab(NULL) +  ylab(NULL) +
  theme_minimal() +
  theme(panel.grid.major = element_line(color = "#009ee0"),
        panel.grid.minor = element_blank())
FFP_nodeNumber
# colors from https://wiki.freifunk.net/Freifunk-Styles

ggsave(plot = FFP_nodeNumber, 
       filename = "FF_nodes_per_community.png")
