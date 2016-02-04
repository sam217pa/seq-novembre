source("scripts/polysnip-read.R")

snp %>%
  filter(!is.na(second)) %>%
  ## rowwise() %>%
  ## filter(first == snp) %>%
  ## ungroup() %>%
  group_by(name, mutant) %>%
  summarise(count = n()) %>%
  filter(count > 10)


  ggplot(aes(x = count)) +
  geom_histogram(binwidth = 1) +
  facet_grid(mutant~.)

snp %>%
  filter(name == "pS96")

## charge le dataset avec les snp, nettoie les données.
source("scripts/polysnip-read.R")

#' Cette fonction transforme deux bases accolées dans le code IUPAC d'ambiguité
#' de séquence.
#' @param first la base du pic majoritaire
#' @param second la base du pic majoritaire.
mergeiupac <- function(first, second)
{
  if(is.na(second)) { Biostrings::mergeIUPACLetters(paste0(first, "" )) }
  else { Biostrings::mergeIUPACLetters(paste0(first, second)) %>% tolower() }
}

## prend les données où l'alignement s'est fait de façon normale
snp %>%
  filter(comments == "A") %>%
  rowwise() %>%
  mutate(type = mergeiupac(first, second)) %>%
  ungroup() ->
snp

## définit le thème par défault des plots
theme_set(theme_minimal(base_size = 8, base_family = "Courier") +
  theme(panel.grid.major.y = element_line(colour = "gray", linetype = "dotted"),
        panel.grid.minor.y = element_line(colour = "gray", linetype = "dotted"),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank())
)

#' cette fonction définit si une base est strong ou weak. Si la base en question
#' est NA, alors renvoit un charactere vide.
#' @param base : une base d'ADN.
base_caller <- function(base)
{
  if (is.na(base)) { "" }
  else if (base == "A" || base == "T") { "W" }
  else { "S" }
}


## détermine dans une colonne `longueur` la longueur de la trace de conversion.
snp %>%
  rowwise() %>%
  filter(first == snp) %>%
  ungroup() %>%
  group_by(name, mutant) %>%
  summarise(debut = min(refpos), fin = max(refpos), longueur = fin - debut) %>%
  inner_join(x = snp, y = .) ->
snp

snp %>%
  filter(mutant == "weak") %>%
  arrange(longueur) %>%
  {.$name %>% unique()} ->
weak_by_length

snp %>%
  filter(mutant == "strong") %>%
  arrange(longueur) %>%
  {.$name %>% unique()} ->
strong_by_length

snp %>%
  filter(mutant == "strong") %>%
  rowwise() %>%
  mutate(firsttype  = base_caller(first),
         secondtype = base_caller(second)) %>%
  ungroup() %>%
  ggplot(aes(x     = factor(refpos),
             y     = factor(name, levels = strong_by_length),
             label = paste0(firsttype, secondtype),
             fill = firsttype)) +
  geom_tile(alpha = 0.2) +
  geom_text(aes(
    color = factor(paste0(firsttype, secondtype))),
    size = 2,
    family = "Courier",
    fontface = "bold") +
  scale_fill_brewer(palette = "Dark2") +
  scale_color_brewer(palette = "Dark2") +
  xlab("Position sur la sequence de reference") +
  ylab("") +
  ggtitle("Constructions Strong") +
  guides(colour = "none", fill = guide_legend(title = "")) +
  theme(legend.position = "bottom")

ggsave("../../analysis/alignement_pics_strong.pdf")

snp %>%
  filter(mutant == "weak") %>%
  rowwise() %>%
  mutate(firsttype  = base_caller(first),
         secondtype = base_caller(second)) %>%
  ungroup() %>%
  ggplot(aes(x     = factor(refpos),
             y     = factor(name, levels = weak_by_length),
             label = paste0(firsttype, secondtype),
             fill = firsttype)) +
  geom_tile(alpha = 0.2) +
  geom_text(aes(
    color = factor(paste0(firsttype, secondtype))),
    size = 2,
    family = "Courier",
    fontface = "bold") +
  scale_fill_brewer(palette = "Dark2") +
  scale_color_brewer(palette = "Dark2") +
  xlab("Position sur la sequence de reference") +
  ylab("") +
  ggtitle("Constructions Weak") +
  guides(colour = "none", fill = guide_legend(title = "")) +
  theme(legend.position = "bottom")

ggsave("../../analysis/alignement_pics_weak.pdf")
