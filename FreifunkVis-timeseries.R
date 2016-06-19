# Visualising Freifunk API data 
# by Katrin Leinweber, June 2016
# companion to FreifunkVis.R

library(stringr) # str_extract_all

# enter sub-dir & use random sample of available JSONs
setwd(paste0(getwd(), "/JSONs"))
ffk.JSONs <- sample(x = list.files(pattern = "[0-9]{8}-.*-ffSummarizedDir.json$"), 
                    size = 30)
ffk.days <- as.character(str_extract_all(ffk.JSONs, pattern = "[0-9]{8}"))

if ("00000000-ffSummarizedDir.csv" %in% list.files(getwd())) {
  
  # use summary file if available, instead of reading files individually
  try(ffdf.known <- read.csv2("00000000-ffSummarizedDir.csv", 
                              encoding = "UTF-8"))
  
  # check for existing ffdf date & merge with new
  if (length(unique(ffdf.known$mtime)) < length(ffk.JSONs)) {
    # naive, because single FF_JSON can include several different days
    # tried (unique(gsub("-", "", as.character(ffdf.known$mtime))) %in% ffk.days),
    # but returns list of Booleans => unsuitable for if condition
    
    # read in & generate data frame only from new JSONs
    ffk.knownDays <- gsub(pattern     = "-",
                          replacement = "",
                          x           = unique(ffdf.known$mtime)
    )
    ffk.newDays <- setdiff(ffk.days, ffk.knownDays)
    ffdf.new <- rbind.fill(
      lapply(
        lapply(
          # list all new filenames; learned from http://stackoverflow.com/a/7664655/4341322
          list.files(pattern = paste(ffk.newDays, collapse="|")), 
          fromJSON
        ), 
        ff.readJSONs
      ))
    
    # combine known & new data frames
    ffdf <- rbind.fill(ffdf.known, ffdf.new)  
    # learned from http://stackoverflow.com/a/27313467
  }
} else {
  # combine all JSONs into single data frame
  ffdf <- rbind.fill(lapply(lapply(ffk.JSONs, fromJSON), ff.readJSONs))
  # same as inner else, just to catch edge case of repetive plotting without adding new JSONs
}

ffdf <- ff.cleanDF(ffdf)

# export combined data frame
write.csv2(x = ffdf, file = "00000000-ffSummarizedDir.csv", row.names = FALSE)
setwd(sub("/JSONs", "", getwd()))

# plot timeseries of average node number per community over time
ffp.nodeNumber <- ggplot(data = subset(x = ffdf, 
                                       select = c("name", 
                                                  "mtime", 
                                                  "state.nodes"
                                       )), 
                         mapping = aes(x = mtime,
                                       y = state.nodes)) + 
  geom_point(stat = "summary", color = "#ffb400") +
  stat_smooth(color = "#dc0067", se = FALSE) + 
  scale_x_date(labels = date_format("%b '%y")) +
  expand_limits(y = 0) +  # learned from http://stackoverflow.com/a/13701732/4341322
  ggtitle("Nodes per Community (average) over Time") +
  xlab(NULL) + ylab(NULL) +
  theme_minimal() +
  theme(axis.text.x	= element_text(hjust = 0.8),
        panel.grid.major = element_line(color = "#009ee0"),
        panel.grid.minor = element_blank())
ffp.nodeNumber
# colors from https://wiki.freifunk.net/Freifunk-Styles

ggsave(plot = ffp.nodeNumber, 
       filename = "FF_nodes_per_community.png")
