setwd("~/stage/seq_novembre/data/snp-calling")

library(dplyr)
library(ggplot2)

weak   <- read.csv("weak.csv")   %>% tbl_df()
strong <- read.csv("strong.csv") %>% tbl_df()

read_data <- function(filename)
{
  read.csv(filename) %>%
    tbl_df() %>%
    select(
      -datum, -analysis, 
    )
}
