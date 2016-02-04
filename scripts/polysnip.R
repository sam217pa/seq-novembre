snp %>%
  filter(!is.na(second)) %>%
  ggplot(aes(x = refpos, fill = mutant)) +
  geom_histogram(binwidth = 10) +
    facet_grid(mutant~.) +
    scale_fill_discrete(guide = FALSE) +
    xlab("Position sur la sequence de reference") + 
    ylab("")
ggsave("../../analysis/mutant-count.pdf")

snp %>%
  filter(!is.na(second)) %>%
  filter(comments == "A") %>%
  group_by(refpos, mutant, second) %>%
  summarise(count =n()) %>%
  ggplot(aes(x = refpos, y = count, color = second, fill = second)) +
  geom_point() +
  geom_bar(stat = "identity", alpha = 0.2) +
  facet_grid(mutant~second) +
  xlab("Position sur la sequence de reference") +
  ylab("Nombre de sequence") +
  scale_fill_discrete(guide = FALSE) +
  scale_colour_discrete(guide = FALSE) 
ggsave("../../analysis/mutant-second.pdf")

snp %>%
  filter(!is.na(second)) %>%
  filter(comments == "A") %>%
  filter(ratioA > 0.2) %>%
  group_by(refpos, mutant, second) %>%
  summarise(count =n()) %>%
  ggplot(aes(x = refpos, y = count, color = second, fill = second)) +
  geom_point() +
  geom_bar(stat = "identity", alpha = 0.2) +
  facet_grid(mutant~second) +
  xlab("Position sur la sequence de reference") +
  ylab("Nombre de sequence") +
  scale_fill_discrete(guide = FALSE) +
  scale_colour_discrete(guide = FALSE) 
ggsave("../../analysis/mutant-second-filter.pdf")

snp %>%
  rowwise() %>%
  filter(first == snp) %>%
  ungroup() %>%
  group_by(name, mutant) %>%
  summarise(debut = min(refpos), fin = max(refpos), longueur = fin - debut) %>%
## print() %>%
inner_join(x = snp, y = .)

  ggplot(aes(x = longueur, fill = mutant)) +
  geom_histogram(binwidth = 10) +
  facet_grid(mutant~.) +
  theme_minimal(base_family = "Courier") +
  theme(panel.ontop = TRUE,
        panel.grid.major.y = element_line(size = 1, color = "white"),
        panel.grid.minor.y = element_line(size = 0.5, color = "white")) +
  xlab("Distribution de la longueur de la tract de conversion") +
  ylab("")

snp %>%
  group_by(name) %>%
  summarise(max = max(qpos)) %>%
  qplot(data =., max, binwidth = 1) +
  xlab("Distribution de la longueur des séquences")

mergeiupac <- function(first, second)
{
  if(is.na(second)) { Biostrings::mergeIUPACLetters(paste0(first, "" )) }
  else { Biostrings::mergeIUPACLetters(paste0(first, second)) }
}

snp %>%
  filter(comments == "A") %>%
  rowwise() %>%
  mutate(type = mergeiupac(first, second)) %>%
  select(name, type) %>% 
  ungroup() -> seqlist 

lapply(
  split(seqlist, seqlist$name), # split by name
  function(x) { 
    paste0( 
      ">", x$name[1], "\n", # copie le nom de la sequence avec le fasta sep
      gsub(x = toString(x$type), # et la sequence iupac
           pattern = ", ",
           replace = "" ))
  }
) %>%
  unlist() ->
  seqlist


## 1. concatenate sequence
## 2. prepend sequence name.

snp %>%
  select(wt, refpos) %>%
  arrange(refpos) %>%
  unique() %>%
  {
    toString(.$wt) %>% gsub(x = ., pattern = ", ", replace = "")
  } %>%
  paste0(">wt", "\n", .) ->
  refsnp

cat(c(refsnp, seqlist), sep = "\n",
    file = "iupac_seqlist.fasta")

snp %>% filter(qpos == "457")

snp %>%
  rowwise() %>%
  filter(first != snp & first != wt) %>%
  qplot(data = ., refpos, geom = "histogram")

  select(first) %>%
  {
    as.factor(.$first) %>% levels()
  }
