setwd("./data/snp-calling")
library(dplyr)
library(ggplot2)
library(viridis)

theme_set(theme_gray(base_size = 9, base_family = "Courier") +
          theme(panel.grid.major.y = element_line(size = 1, color = "white"),
                panel.grid.major.x = element_blank(),
                panel.grid.minor.x = element_blank()))

read_polysnp <- function(filename)
{
  read.csv(filename, stringsAsFactors = FALSE) %>%
    tbl_df() %>%
    select(
      -datum,
      -analysis,
      -corrected.proportion.A,
      -corrected.proportion.B,
      -uncorrected.proportion.B,
      name   = file,
      refpos = reference.position,
      qpos   = SCF.position,
      wt     = A.base,
      snp    = B.base,
      first  = first.call,
      second = second.call,
      ratioA = uncorrected.proportion.A,
      farea  = first.area,
      sarea  = second.area
    ) %>%
    mutate(name = gsub("-1073.ab1", "", x = name),
           comments = factor(comments))
}

## combine les données en une table unique, ajoute l'info du type de mutant.
## TODO corriger les mutants dans la mauvaise catégorie.
snp <- rbind(
  read_polysnp("weak.csv") %>% mutate(mutant = "weak") %>% tbl_df(),
  read_polysnp("strong.csv") %>% mutate(mutant = "strong") %>% tbl_df()
)

## réaffecte les niveaux de facteur. 
##
## +---------+-------------------------------------------------------+
## | facteur | commentaire                                           |
## |---------+-------------------------------------------------------|
## | D       | WARNING: bases could not be matched                   |
## | C       | WARNING: multiple peak span, data are not trustworthy |
## | B       | WARNING: primary peak does not match the reference    |
## | A       | processed normally                                    |
## +---------+-------------------------------------------------------+

## il n'y a pas dans les données de facteur C. d'où les trois niveaux de
## facteur. sensible aux variations de paramètre polySNP à mon avis. à
## surveiller.
snp$comments <- plyr::mapvalues(snp$comments,
                                from = levels(snp$comments),
                                to = c("D", "A", "B"))

## correct NA symbol
snp$second[snp$second == "-"] <- NA

## corrige les erreurs de SNP. 
snp$mutant[snp$name == "pS60"] <- "weak"
snp$mutant[snp$name == "pS83"] <- "weak"
snp$mutant[snp$name == "pS92"] <- "weak"
snp$mutant[snp$name == "pS91"] <- "weak"
snp$mutant[snp$name == "pW6" ] <- "strong"
