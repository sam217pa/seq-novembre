setwd("~/stage/seq_novembre/data/variantCalling")

library(dplyr)
library(ggplot2)
library(extrafont)
library(ggthemes)
library(cowplot)

##

mytheme <- theme(panel.ontop = TRUE,
                 axis.text = element_text(size = 8, colour = "gray"),
                 panel.grid.major.x = element_blank(),
                 panel.grid.minor.x = element_blank(),
                 panel.grid.minor.y = element_blank(),
                 panel.grid.major.y = element_line(colour = "white", size = 1)) 

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

##==============================================================================
## PLOT DISTRIBUTIONS
##==============================================================================
snp_plot <- ggplot(data = snp_data, aes(offset_on_subject)) +
    geom_density(aes(fill = mutant), alpha = 0.2) +
    geom_histogram(aes(fill = mutant),
                   binwidth = 10, position = "dodge") +
    theme_minimal(base_family = "Courier") +
    ## scale_y_tufte() +
    scale_x_continuous(breaks = seq(1, 734, 30)) +
    scale_fill_brewer(palette = "Set1") +
    xlab("Distribution des SNP sur le gene sauvage") +
    ylab("") +
    theme(panel.ontop = TRUE,
          legend.position = c(0.2, 0.6),
          axis.text = element_text(size = 8, colour = "gray"),
          panel.grid.major.x = element_blank(),
          panel.grid.minor.x = element_blank(),
          panel.grid.minor.y = element_blank(),
          panel.grid.major.y = element_line(colour = "white", size = 1)) 


#' une fonction pour déterminer si la substitution est strong ou weak. On peut
#' avoir des substitutions weak chez les strongs
#' @param subject la base sur la séquence de référence
#' @param query la base sur le read.
mutant_caller <- function(subject, query) {
    if (subject == 'A' || subject == 'T') {
        if (query == 'C' || query == 'G' ) {
            'strong'
        } else {
            'weak'
        }
    } else {
        if (query == 'A' || query == 'G') {
            'weak'
        } else {
            'strong'
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


## distribution des SNP
## facétée par type de mutant, couleur = type de mutation
mutation_plot <- ggplot(data = snp_data, aes(offset_on_subject)) +
    geom_histogram(aes(fill = mutation_type), binwidth = 10, position = "dodge") +
    facet_grid(~mutant, labeller = label_both) +
    theme_minimal(base_family = "Courier") +
    ## scale_y_tufte() +
    scale_x_continuous(breaks = seq(1, 734, 60)) +
    scale_fill_brewer(palette = "Set2",
                      name = "Type de mutation",
                      labels = c("AT -> GC", "GC -> AT")) +
    xlab("Distribution des SNP sur le gene sauvage") +
    ylab("") +
    theme(panel.ontop = TRUE,
          legend.position = c(0.6, 0.6),
          axis.text = element_text(size = 8, colour = "gray"),
          panel.grid.major.x = element_blank(),
          panel.grid.minor.x = element_blank(),
          panel.grid.minor.y = element_blank(),
          panel.grid.major.y = element_line(colour = "white", size = 1)) 

## distribution des SNP
## facetée par type de mutation, couleur : type de mutant. 
muttype_plot <- ggplot(data = snp_data, aes(offset_on_subject)) +
    geom_histogram(aes(fill = mutant), binwidth = 10, position = "dodge") +
    facet_grid(~mutation_type, labeller = label_both) +
    theme_minimal(base_family = "Courier") +
    ## scale_y_tufte() +
    scale_x_continuous(breaks = seq(1, 734, 60)) +
    scale_fill_brewer(palette = "Set2",
                      name = "Type de mutant",
                      labels = c("mutant strong", "mutant weak")) +
    xlab("Distribution des SNP sur le gene sauvage") +
    ylab("") +
    theme(panel.ontop = TRUE,
          legend.position = c(0.6, 0.6),
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

multi_plot <- plot_grid(snp_plot, mutation_plot, NULL, muttype_plot, ncol = 2, labels = c("A", "B", " ", "C"))

pdf(file = "../../analysis/snp_resume.pdf", height = 11.69, width = 16.53)
multi_plot
dev.off()

##==============================================================================
## SWITCH INITIAL
##==============================================================================
snp_data %>%
    group_by(name, mutation_type) %>%
    summarise(switch_pos = min(offset_on_subject)) ->
    switch_data_muttype

## la position de switch sans tenir compte de la qualité des mutants
switch_position_globale <- ggplot(switch_data_muttype, aes(switch_pos)) +
    geom_histogram(fill = "black", binwidth = 5) +
    theme_minimal(base_family = "Courier") +
    xlab("") +
    ylab("") +
    annotate("rect", xmin = 160, xmax = 260, ymin = 0, ymax = 10, alpha = 0.4) + 
    annotate("text", x = 220, y = 13, label = "coldspot?", size = 2,  alpha = 0.5) + 
    annotate("rect", xmin = 480, xmax = 620, ymin = 0, ymax = 10, alpha = 0.4) + 
    annotate("text", x = 550, y = 13, label = "coldspot?", size = 2,  alpha = 0.5) + 
    mytheme
switch_position_globale
ggsave(switch_position_globale, file = "../../analysis/switch_position_globale.pdf",
       height = 4, width = 7, units = "cm")

## en tenant compte du type de mutation
switch_pos_by_muttype <- ggplot(switch_data_muttype, aes(switch_pos)) +
    geom_histogram(aes(fill = mutation_type),
                   position = "dodge", 
                   binwidth = 10) +
    scale_x_continuous(breaks = seq(1, 734, 30)) +
    theme_minimal(base_family = "Courier") +
    scale_fill_discrete() +
    xlab("Distribution de la qualite de la premiere substitution") +
    ylab("") +
    theme(legend.position = c(0.8, 0.7)) +
    mytheme
switch_pos_by_muttype
## en tenant compte du type de mutant
snp_data %>%
    group_by(name, mutant) %>%
    summarise(switch_pos = min(offset_on_subject)) ->
    switch_data_mutant
switch_pos_by_mutant <- ggplot(switch_data_mutant, aes(switch_pos)) +
    geom_histogram(aes(fill = mutant),
                   position = "dodge", 
                   binwidth = 10) +
    ## facet_grid(.~mutant) +
    scale_x_continuous(breaks = seq(1, 734, 30)) +
    theme_minimal(base_family = "Courier") +
    scale_fill_discrete() +
    xlab("Distribution de la position de switch en fonction du type de mutant") +
    ylab("") +
    theme(legend.position = c(0.8, 0.5)) +
    mytheme
switch_pos_by_mutant
multi_switch_plot <- plot_grid(switch_pos_by_muttype, switch_pos_by_mutant, ncol = 1, labels = c("A", "B"))
ggsave(multi_switch_plot, file = "../../analysis/switch_pos_by_mutant.pdf",
       height = 21, width = 29.7, units = "cm")

##==============================================================================
## SWITCH TERMINAL
##==============================================================================
snp_data %>%
    group_by(name, mutant) %>%
    summarise(switch_pos = max(offset_on_subject)) ->
    end_data_mutant

pdf(file = "../../analysis/end_switch.pdf", width = 4, height = 4)
print(
    ggplot(end_data_mutant, aes(switch_pos)) +
    geom_histogram(aes(fill = mutant),
                   position = "dodge",
                   binwidth = 1) +
    theme_minimal() +
    xlab("") + ylab("") +
    theme(legend.position = c(0.4, 0.5)) +
    mytheme
)
dev.off()

##============================================================================== 
## OUTLIERS
##==============================================================================

#' find_outlier
#' ============
#' une fonction qui détermine si le SNP en question est un outlier ou nom, c'est
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
    theme(legend.position = c(0.2, 0.7),
          legend.title = element_blank(),
          legend.text = element_text(size = 10)) +
    mytheme 
dev.off()
