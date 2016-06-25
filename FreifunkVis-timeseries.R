# Visualising Freifunk API data 
# by Katrin Leinweber, June 2016
# companion to FreifunkVis.R

### PREPARATION (naive)
# 1. Download .json.tar.gz & .json files from https://api.freifunk.net/data/history/
# 2. Extract .tar.gz files with `for file in *.tar.gz; do tar -zxf $file; done`
# 3. Scrape node numbers from .json files & clean with `for i in $(ls *-ffSummarizedDir.json) ; do cat $i | jq '..|.nodes?' | sed '/\s*null/d' | sed '/\"/d' | sed '/{/d' | sed '/}/d' | sed '/\[/d' | sed '/\]/d' > $i.csv ; done`

# find CSVs
ff.path <- "~/GitHub/vis.api.freifunk.net/CSVs/"
ff.files <- list.files(path = ff.path, pattern = "*-ffSummarizedDir.json.csv")

# read & sum node numbers for each timestamp
ff.allNodes <- lapply(paste0(ff.path, ff.files), read.csv)
ff.allSums <- lapply(ff.allNodes, sum)

# convert node numbers into into data frame
ff.df <- as.data.frame(unlist(ff.allSums))
colnames(ff.df) <- "Nodes"

# assign timestamps to each sum & convert to useful format
ff.df$DateTime <- ff.files
ff.df$DateTime <- as.Date(
  gsub(
    pattern = "-ffSummarizedDir.json.csv",
    replacement = "",
    x = ff.df$DateTime
    ), format = "%Y%m%d-%H.%M.%S")

# export data
write.csv2(x = ff.df, file = "00000000-ffSummarizedDir.csv", row.names = FALSE)

# plot total node number over time; colors from https://wiki.freifunk.net/Freifunk-Styles
ffp.nodeNumber <- ggplot(data = ff.df, 
                         mapping = aes(x = DateTime,
                                       y = Nodes)) + 
  geom_point(stat = "summary", color = "#ffb400") +
  scale_x_date(date_breaks = "3 months", labels = date_format("%b '%y")) +
  scale_y_continuous(breaks = seq(0, max(ff.df$Nodes)*1.1, 5000)) +
  expand_limits(y = 0) +  # learned from http://stackoverflow.com/a/13701732/4341322
  ggtitle("Number of Freifunk nodes over time") +
  xlab(NULL) + ylab(NULL) +
  theme_minimal() +
  theme(text = element_text(color = "#dc0067"),
        panel.grid.major = element_line(color = "#009ee0"),
        panel.grid.minor = element_blank()
        )
ffp.nodeNumber

ggsave(plot = ffp.nodeNumber, 
       filename = "FF_nodes_timeline.png",
       width = 6,
       height = 3
       )
