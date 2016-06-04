# Visualising Freifunk API data by Katrin Leinweber, June 2016
# companion to FreifunkVis.R

library(ggplot2)
library(scales) # date_format
library(stringr) # str_extract_all

# prepare timelines
FF_JSONs <- list.files(pattern = "[0-9]{8}-.*-ffSummarizedDir.json$")

# combine all JSONs into single data frame
FFDF <- rbind.fill(lapply(lapply(FF_JSONs, fromJSON), FF_readJSONs))
FFDF <- FF_cleanDF(FFDF)

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
