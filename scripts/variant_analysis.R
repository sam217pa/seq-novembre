setwd("~/stage/seq_novembre/data/variantCalling")

library(dplyr)

## read the data
snp <- tbl_df(read.table("snp_calling.dat", head = TRUE))
## enlève les colonnes inutiles
snp %>%
    select( -match, -subject_name, -index_of_subject, -length_of_subject,
           -match_direction) ->
    snp
## lit les métadonnées de séquence
id_table <- tbl_df(read.table("../id_table.dat", head = TRUE))

## fait correspondre le read_name avec le nom du clone et le type de mutant W ou S
snp_data <- inner_join(x = snp, y = id_table, by = c("read_name" = "id"))

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
snp_data %>%
    rowwise() %>%
    mutate(mutation_type = mutant_caller(s_base, q_base)) %>%
    ungroup() ->
    snp_data
## conversion en facteur
snp_data$mutation_type = factor(snp_data$mutation_type)

library(ggplot2)
library(ggthemes)

mytheme <- theme(panel.ontop = TRUE,
                 axis.text = element_text(size = 8, colour = "gray"),
                 panel.grid.major.x = element_blank(),
                 panel.grid.minor.x = element_blank(),
                 panel.grid.minor.y = element_blank(),
                 panel.grid.major.y = element_line(colour = "white", size = 1)) 

##==============================================================================
## PLOT DISTRIBUTIONS
##==============================================================================
snp_plot <- ggplot(data = snp_data, aes(offset_on_subject)) +
    geom_density(aes(fill = mutant), alpha = 0.2) +
    geom_histogram(aes(fill = mutant),
                   binwidth = 10, position = "dodge") +
    theme_minimal(base_family = "Courier") +
    scale_x_continuous(breaks = seq(1, 734, 30)) +
    scale_fill_brewer(palette = "Set2", name = "Type de gène\nsynthétique") +
    xlab("Distribution des SNP sur le gene sauvage") +
    ylab("") +
    theme(panel.ontop = TRUE,
          legend.position = c(0.8, 0.8),
          axis.text = element_text(size = 8, colour = "gray"),
          panel.grid.major.x = element_blank(),
          panel.grid.minor.x = element_blank(),
          panel.grid.minor.y = element_blank(),
          panel.grid.major.y = element_line(colour = "white", size = 1)) 

## distribution des SNP
## facétée par type de mutant, couleur = type de mutation
mutation_plot <- ggplot(data = snp_data, aes(offset_on_subject)) +
    geom_histogram(aes(fill = mutation_type), binwidth = 10, position = "dodge") +
    facet_grid(~mutant, labeller = label_both) +
    theme_minimal(base_family = "Courier") +
    scale_x_continuous(breaks = seq(1, 734, 60)) +
    scale_fill_brewer(palette = "Set2",
                      name = "Type de mutation",
                      labels = c("AT -> GC", "GC -> AT")) +
    xlab("Distribution des SNP sur le gene sauvage") +
    ylab("") +
    theme(panel.ontop = TRUE,
          legend.position = c(0.4, 0.8),
          axis.text = element_text(size = 8, colour = "gray"),
          panel.grid.major.x = element_blank(),
          panel.grid.minor.x = element_blank(),
          panel.grid.minor.y = element_blank(),
          panel.grid.major.y = element_line(colour = "white", size = 1)) 

##==============================================================================
## SAVE PLOTS
##==============================================================================
save_to_a5 <- function(output_file, plot)
{
    pdf(file = output_file, height = 5.8, width = 8.3)
    print(plot)
    dev.off()
}

save_to_a3 <- function(output_file, plot)
{
                                        # a3 dimensions : 11.69in x 16.53in
    pdf(file = output_file, height = 11.69, width = 16.53)
    print(plot)
    dev.off()
}

save_to_a5(output_file = "../../analysis/substitution_distribution.pdf",
           plot = mutation_plot)
save_to_a5(output_file = "../../analysis/snp_distribution.pdf",
           plot = snp_plot)
save_to_a5(output_file = "../../analysis/muttype_plot.pdf",
           plot = muttype_plot)

##==============================================================================
## SWITCH INITIAL
##==============================================================================

## en tenant compte du type de mutant
snp_data %>%
    group_by(name, mutant) %>%
    summarise(switch_pos = max(offset_on_subject)) ->
    switch_data_mutant

switch_pos_by_mutant <- ggplot(switch_data_mutant, aes(switch_pos)) +
    geom_histogram(aes(fill = mutant),
                   position = "dodge", 
                   binwidth = 10) +
    ## facet_grid(.~mutant) +
    scale_x_continuous(breaks = seq(1, 734, 30)) +
    theme_minimal(base_family = "Courier") +
    scale_fill_brewer(palette = "Set2") +
    xlab("Distribution de la position de switch en fonction du type de mutant") +
    ylab("") +
    theme(legend.position = c(0.7, 0.5)) +
    mytheme

## sauvegarde du graphique
cowplot::ggsave(switch_pos_by_mutant, file = "../../analysis/switch_pos_by_mutant.pdf",
       height = 21, width = 29.7, units = "cm")

##============================================================================== 
## OUTLIERS
##==============================================================================

#' Détermine si le SNP en question est un outlier ou non, c'est
#' à dire une mutation strong chez un mutant weak ou inversement.
#' @param mutant : le type de mutant
#' @param mutation_type : le type de substitution
find_outlier <- function(mutant, mutation_type)
{
    if (mutant == 'strong' && mutation_type == 'weak') {
        'strong_weak'
    } else if (mutant == 'weak' && mutation_type == 'strong') {
        'weak_strong'
    } else {
        'attendu'
    }
}

snp_data %>%
    rowwise() %>%
    mutate(outlier = find_outlier(mutant, mutation_type)) %>%
    ungroup() ->
    outlier_data

pdf(file = "../../analysis/outliers.pdf", width = 4, height = 2)
outlier_data %>%
    filter(outlier != "attendu") %>%
    qplot(data = ., offset_on_subject, fill = outlier, binwidth = 10) +
    theme_minimal(base_family = "Courier") +
    xlab("") + ylab("") +
    scale_fill_brewer(palette = "Set2",
                      labels = c("S -> W", "W -> S")) +
    theme(legend.position = c(0.8, 0.7),
          legend.title = element_blank(),
          legend.text = element_text(size = 10)) +
    mytheme 
dev.off()

pdf(file = "../../analysis/strong_vs_weak.pdf", width = 4, height = 4)
snp_data %>%
    ggplot(aes(offset_on_subject, fill = mutation_type)) +
    geom_histogram(binwidth = 10) +
    facet_grid(mutation_type ~ .) +
    xlab("") + ylab("") +
    theme_minimal(base_family = "Courier") +
    scale_fill_brewer(palette = "Set2", guide = FALSE) +
    mytheme
dev.off()

snp_data %>% group_by(offset_on_subject) %>%
      summarise(count = n()) %>%
      filter(count > 10) ->
      position_table

  #' détermine si la postion sur la séquence de référence est un SNP artificiel ou
  #' un autre genre de SNP.
  is_a_position <- function(position, table)
  {
      ifelse(position %in% table, 'yes', 'no')
  }

  snp_data %>%
      rowwise() %>%
      mutate(position = is_a_position(offset_on_subject,
                                      position_table$offset_on_subject)) %>%
      ungroup() ->
      snp_data

### work in progress
## snp_data %>%
##     filter(position == "yes") %>%
##     qplot(data = ., offset_on_subject, q_qual, geom = "point", color = mutant) +
##     theme_minimal() +
##     geom_vline(xintercept = snp_data$offset_on_subject, alpha = 0.1)
