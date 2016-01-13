setwd("~/stage/seq_novembre/data/snp-calling")

library(dplyr)
library(ggplot2)

read_polysnp <- function(filename)
{
  read.csv(filename, stringsAsFactors = FALSE) %>%
    tbl_df() %>%
    select(
      -datum,
      -analysis,
      -corrected.proportion.A,
      -corrected.proportion.B,
      name   = file,
      refpos = reference.position,
      qpos   = SCF.position,
      wt     = A.base,
      snp    = B.base,
      first  = first.call,
      second = second.call,
      uncorA = uncorrected.proportion.A,
      uncorB = uncorrected.proportion.B,
      farea  = first.area,
      sarea  = second.area
    ) %>%
    mutate(name = gsub("-1073.ab1", "", x = name))
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
snp$comments <- plyr::mapvalues(snp$comments,
                                from = levels(snp$comments),
                                to = c("D", "C", "B", "A"))

## correct NA symbol
snp$second[snp$second == "-"] <- NA

## corrige les erreurs de SNP. 
snp$mutant[snp$name == "pS60"] <- "weak"
snp$mutant[snp$name == "pS83"] <- "weak"
snp$mutant[snp$name == "pS92"] <- "weak"
snp$mutant[snp$name == "pS91"] <- "weak"
snp$mutant[snp$name == "pW6" ] <- "strong"

library(ggplot2)
theme_set(theme_minimal(base_size = 9, base_family = "Courier"))

snp %>%
  filter(comments == "B") %>%
  ggplot(aes(x = refpos, fill = mutant)) +
  geom_histogram(binwidth = 10) +
  facet_grid(mutant~.)

snp %>%
  filter(!is.na(second)) %>%
  ggplot(aes(x = refpos, fill = mutant)) +
  geom_histogram(binwidth = 1) +
  facet_grid(mutant~.)
