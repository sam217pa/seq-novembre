library(dplyr)
library(ggplot2)

read_result <- function(filename){
  readr::read_delim(filename, delim = ";")
}

snp_strong   <- read_result("./data/1369628.SNP.csv")
snp_weak   <- read_result("./data/1369607.SNP.csv")
indel_strong <- read_result("./data/1369628.INDEL.csv")
indel_weak <- read_result("./data/1369607.INDEL.csv")
snp_weak$mutant <- "weak"
snp_strong$mutant <- "strong"
