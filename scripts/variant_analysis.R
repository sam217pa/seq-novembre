setwd("~/stage/seq_novembre/data/variantCalling")

library(dplyr)

## read the data
snp <- tbl_df(read.table("snp_calling.dat", head = TRUE))
## enlève les colonnes inutiles
snp %>%
    select(
        -match, -subject_name, -index_of_subject, -length_of_subject,
        -match_direction, -contains("_of_read"), -contains("on_read"),
        -contains("_of_snp"), -s_qual
    ) -> snp
 
## lit les métadonnées de séquence
id_table <- tbl_df(read.table("../id_table.dat", head = TRUE))

## fait correspondre le read_name avec le nom du clone et le type de mutant W ou S
snp <- inner_join(x = snp, y = id_table, by = c("read_name" = "id"))

## suppress tmp var
rm(id_table)

## bascule les contaminants mysterieux dans la bonne catégorie
## TESTE ET APPROUVE
snp$mutant[snp$name == "pS60-1073"] <- "weak"
snp$mutant[snp$name == "pS83-1073"] <- "weak"
snp$mutant[snp$name == "pS92-1073"] <- "weak"
snp$mutant[snp$name == "pS91-1073"] <- "weak"
snp$mutant[snp$name == "pW6-1073" ] <- "strong"

#' une fonction pour déterminer si la substitution est strong ou weak. On peut
#' avoir des substitutions weak chez les strongs
#' @param subject la base sur la séquence de référence
#' @param query la base sur le read.
mutant_caller <- function(subject, query)
{
    if (subject == 'A' || subject == 'T') {
        if (query == 'C' || query == 'G' ) {
            'WS'
        } else {
            'WW'
        }
    } else if (subject == 'C' || subject == 'G') {
        if (query == 'A' || query == 'T') {
            'SW'
        } else {
            'SS'
        }
    }
}

## on applique la fonction rowwise, ie ligne par ligne, via `mutate`, puis on
## dégroupe.
snp %>%
    rowwise() %>%
    mutate(mutation_type = mutant_caller(s_base, q_base)) %>%
    ungroup() ->
    snp
## conversion en facteur
snp$mutation_type = factor(snp$mutation_type)

##==============================================================================
## SHORTCUT PLOT FUNCTION
##==============================================================================

library(ggplot2)

##' .. content for \description{} (no empty lines) ..
##' 
##' Une fonction qui permet de court-circuiter ggplot : représente en ordonnée
##' la distribution des positions de snp, en abscisse la position des SNPs, par
##' défault la couleur repéresente le type de mutant, peut être également
##' attribuée à mutation_type. Respecte les critères visuels de tufte. Nécessite
##' ggplot2 1.02 si je ne m'abuse, avec l'option panel.ontop en tout cas.
##' 
##' .. content for \details{} ..
##' @title plot_snp
##' @param snp les données de snp
##' @param fill la couleur par laquelle on color les barres
##' @param legend_position la position de la légende sur le graphe
##' @param legend_name le titre de la légende. rien par défault
##' @return un graphique
plot_snp <- function(data, fill_by = "mutant",
                                  legend_position = c(0.2, 0.8),
                                  legend_name = "")
{
    plot <- ggplot(data = data, aes(offset_on_subject)) +
        theme_minimal(base_family = "Courier") +
        scale_x_continuous(breaks = seq(1, 734, 30)) +
        scale_fill_brewer(palette = "Set2", name = legend_name) +
        xlab("") +
        ylab("") +
        theme(panel.ontop = TRUE, legend.position = legend_position,
              axis.text = element_text(size = 8, colour = "gray"),
              panel.grid.major.x = element_blank(),
              panel.grid.minor.x = element_blank(),
              panel.grid.minor.y = element_blank(),
              panel.grid.major.y = element_line(colour = "white", size = 1))

    if (fill_by == "mutation_type")
    {
        plot + geom_histogram(aes(fill = mutation_type), binwidth = 10,
                              position = "dodge")
    } else {
        plot + geom_histogram(aes(fill = mutant), binwidth = 10,
                              position = "dodge")
    }
}

##==============================================================================
## PLOT DISTRIBUTIONS
##==============================================================================

pdf(file = "../../analysis/snp_distribution.pdf", height = 5.8, width = 8.3)

## distribution des SNP
## facétée par type de mutant, couleur = type de mutation
snp %>%
    plot_snp(legend_name = "Exogene", legend_pos= c(.2, .8))

dev.off()

#-------------------------------------------------------------------------------
pdf(file = "../../analysis/mutant_snp_distribution.pdf", height = 5.8, width = 8.3)

snp %>%
    plot_snp(fill_by = "mutation_type", legend_name = "Type de Mutation" ) +
    facet_grid(mutant ~ .)

dev.off()

## =============================================================================
## OBSERVATIONS GÉNÉRALES
## =============================================================================
 
sink(file = "../../analysis/observations.tex")
snp %>%
    group_by(mutant, name) %>%
    summarise(count = n()) %>%
    summarise(mean = mean(count), med = median(count), sd = sd(count) ) %>%
    knitr::kable( align = 'c', digits = 2, booktabs = TRUE, format = "latex")
sink()

sink(file = "../../analysis/count_by_mutant.tex")
snp %>%
    group_by(mutant) %>%
    summarise(count = n()) %>%
    knitr::kable( align = 'c', booktabs = TRUE, format = "latex")
sink()

sink(file = "../../analysis/count_by_muttype.tex")
snp %>%
    group_by(mutation_type) %>%
    summarise(count = n()) %>%
    knitr::kable(col.names = c("Type de mutation", "nombre"),
                 align = 'c',
                 booktabs = TRUE, format = "latex")
sink()

sink(file = "../../analysis/seq_by_mutant.tex")
distinct(snp, name, mutant) %>%
    group_by(mutant) %>%
    summarise(count = n()) %>%
    knitr::kable( align = 'c', booktabs = TRUE, format = "latex")
sink()

## ==============================================================================
## SNP ATTENDUS OU NON
## ==============================================================================
##

## compte le nombre de SNP par position. hypothèse : un SNP `calibré' génère au
## moins 5 SNP parmi toutes les séquences. sortie dans une table qui sert de
## query à la fonction =is_position=
snp %>%
    group_by(offset_on_subject) %>%
    summarise(count = n()) %>%
    ## qplot(data = ., offset_on_subject, count)
    filter(count > 5) %>%
    select(offset_on_subject) %>%
    unlist() %>%
    as.vector() ->
    position_table

##' .. content for \description{} (no empty lines) ..
##' détermine si la postion sur la séquence de référence est un SNP artificiel
##' ou un autre genre de SNP.
##' .. content for \details{} ..
##' @title is_position
##' @param position 
##' @param table 
##' @return "oui" ou "non"
is_position <- function(position, table) ifelse(position %in% table, 'oui', 'non')


snp %>%
    rowwise() %>%
    mutate(position = is_position(offset_on_subject, position_table)) %>%
    ungroup() ->
    snp

pdf(file = "../../analysis/bgc_en_action.pdf", height = 5.8, width = 8.3)
snp %>%
    filter(position == "non") %>%
    plot_snp(fill_by = "mutation_type") +
    scale_y_continuous(breaks = c(1, 2)) +
    scale_x_continuous(breaks = position_table, name = waiver()) +
    ggtitle("Substitution aux positions inattendues : biaisees vers GC ?") +
    theme(panel.grid.major.x = element_line(colour = "gray"))
dev.off()

sink(file = "../../analysis/bgc_en_action.tex")
snp %>%
    filter(position == "non") %>%
    group_by(mutation_type) %>%
    summarise(count = n()) ->
    bgc_en_action
colnames(bgc_en_action) <- c("Type de Substitution", "Nombre")
print(xtable::xtable( bgc_en_action, align = 'ccc'), include.rownames = FALSE)
sink()

##==============================================================================
## POSITION DE SWITCH
##==============================================================================

pdf(file = "../../analysis/switch_distrib.pdf", height = 5.8, width = 8.3)

snp %>%
    ## par plasmide -- et par type de mutant
    group_by(name, mutant) %>%
    ## garde seulement les positions calibrées
    filter(position == "oui") %>% 
    ## cherche la postion minimale de SNP
    summarise(offset_on_subject = min(offset_on_subject)) %>% 
    ## represente la distribution
    plot_snp(legend_position = c(0.8, 0.8)) +
    ggtitle("Distribution de la position de switch en fonction du type de mutant") +
    ## superpose les deux distribution pour comparer
    facet_grid( mutant ~ .) 

dev.off()

##============================================================================== 
## OUTLIERS
##==============================================================================
##
##' .. content for \description{} (no empty lines) ..
##' 
##' Détermine si le SNP en question est un outlier ou non, c'est à dire une
##' mutation strong chez un mutant weak ou inversement.
##' 
##' .. content for \details{} ..
##' @title is_outlier
##' @param mutant : le type de mutant
##' @param mutation_type : le type de substitution
##' @return 
is_outlier <- function(mutant, mutation_type)
{
    if (mutant == 'strong' && mutation_type == 'SW') {
        "non"
    } else if (mutant == 'weak' && mutation_type == 'WS') {
        "non"
    } else {
        'oui'
    }
}

snp %>%
    ## par ligne, determine si la position est inattendue
    rowwise() %>%
    mutate(attendu = is_outlier(mutant, mutation_type)) %>%
    ungroup() %>%
    ## garde les positions calibree
    filter(position == "oui") %>% 
    ## sur lesquelles le résultat est inattendu
    filter(attendu == "non") %>%
    plot_snp(legend_position = c(0.2, 0.9)) +
    geom_text(aes(label = name, y = 0.5), check_overlap = TRUE,
              position = "dodge") +
    coord_flip() +
    theme(panel.ontop = FALSE)

## sortie des résultats dans un joli tableau latex
sink( file = "../../analysis/outlier.tex", append = FALSE)
snp %>%
    rowwise() %>%
    mutate(attendu = is_outlier(mutant, mutation_type)) %>%
    ungroup() %>%
    filter(attendu == "non") %>%
    mutate(position = offset_on_subject, ref = s_base, read = q_base) %>%
    select(-read_name, -offset_on_subject, -s_base, -q_base) %>%
    knitr::kable(format = "latex", booktabs = TRUE)
sink()

## pdf(file = "../../analysis/outliers.pdf", width = 4, height = 2)

snp %>%
    ## par exogene
    group_by(name) %>%
    ## garde seulement les positions attendues
    filter(position == "oui") %>%
    ## cherche la borne supérieure et inférieure
    summarise(min = min(offset_on_subject), max = max(offset_on_subject)) %>%
    ## combine avec la table mère
    inner_join(snp, by = "name") ->
    snp
 
##' .. content for \description{} (no empty lines) ..
##' détermine si le SNP est dans la conversion tract ou non. 
##' .. content for \details{} ..
##' @title 
##' @param query la position requête
##' @param min la borne inférieure de la conversion tract
##' @param max la borne supérieure de la conversion tract
##' @return oui ou non
is_inside_conv <- function(query, min, max)
{
    ifelse(min <= query & query <= max, "oui", "non")
}

sink(file = "../../analysis/inside_conv.tex")
snp %>%
    rowwise() %>%
    ## détermine si on est dans la conversion tract ou non
    mutate(inside_conv = is_inside_conv(offset_on_subject, min, max)) %>%
    ungroup() %>%
    ## filtre pour avoir les snp non attendus
    filter(position == "non") %>%
    ## groupe selon qu'on est dans ou en dehors de la CT
    group_by(inside_conv) %>%
    ## compte le nombre de snp par cas
    summarise(count = n()) %>%
    ## format en .tex
    knitr::kable(format = "latex", booktabs = TRUE)
sink()

pdf(file = "../../analysis/qualite_distrib.pdf", height = 5.8, width = 8.3)
snp %>%
    filter(position == "oui") %>%
    qplot(data = ., x = offset_on_subject, y = q_qual, color = mutant,
          alpha = 0.1) +
    theme_minimal(base_family = "Courier") +
    scale_color_brewer(palette = "Set2", name = "") +
    scale_alpha_continuous(guide = FALSE, name = "") + 
    xlab("Position") + ylab("qualite") +
    scale_x_continuous(breaks = position_table) +
    theme(legend.position = c(0.5, 0.2),
          axis.text = element_text(size = 8, colour = "gray"))
dev.off()

sink("../../analysis/freq_polymorphism.tex")
snp %>%
    filter(position == "oui", q_qual < 40, offset_on_subject < 600) %>%
    group_by(mutant) %>%
    summarise(count = n()) %>%
    knitr::kable(format = "latex", booktabs = TRUE)
sink()

snp %>%
    filter(position == "non", q_qual < 40, offset_on_subject < 600) #%>%
    group_by(mutant) %>%
    summarise(count = n())# %>%
    knitr::kable(format = "latex", booktabs = TRUE)

snp %>%
  mutate(name = gsub("-1073", "", x = name)) %>%
  filter(position == "oui", q_qual < 40, offset_on_subject < 600) %>%
  group_by(name) %>%
  summarise(count = n()) -> #%>%
  ## filter(count > 1) ->
  candidats

snp %>%
  filter(name == "pW6-1073") %>%
  qplot(data = .,
        x = offset_on_subject,
        y = q_qual,
        geom = "line",
        xlim = c(0, 750)) +
  geom_vline( xintercept = 456, color = "red") +
  geom_vline(xintercept = position_table,
             color = "blue",
             alpha = 0.2)

snp %>%
  mutate(name = gsub("-1073", "", x = name)) %>%
  filter(name %in% candidats$name) %>%
  ggplot(data = .,
         aes(x = offset_on_subject, y = q_qual,
             colour = name)) +
  geom_line() +
  facet_grid(name~mutant) +
  theme_minimal() +
  theme(text = element_text(size = 6))

ggsave(filename = "~/stage/seq_novembre/analysis/candidats_heterozygotes.pdf",
       width = 29.7, height = 21, units = "cm")

write.csv(snp, file = "snp_table.csv", quote = FALSE)
