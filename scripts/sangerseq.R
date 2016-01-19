## ------------------------------------------------------------------------------
##                                   BASE CALLING
## ------------------------------------------------------------------------------

setwd("~/stage/seq_novembre/data/tmp/")
library(dplyr)
library(sangerseqR)
library(Biostrings)

## la deuxième ligne du fichier reference.fasta contient la séquence de
## référence. Elle est convertie en un objet DNA string.
ref <- readLines("../reference.fasta")[2] %>%
  DNAString() %>%
  reverseComplement()

##' .. content for \description{} (no empty lines) ..
##' Call bases on a query, based on primary and secondary traces.
##' .. content for \details{} ..
##' @title baseCaller
##' @param query the ab1 file name.
##' @param ref the reference. a DNAString object.
##' @return a sangerseqR object.
baseCaller <- function(query, ref)
{
  readsangerseq(query) %>%
    makeBaseCalls(ratio = 0.5)#  %>%
    ## setAllelePhase(obj = ., refseq = ref)
}

pW85 <- baseCaller(query = "../spectrograms/pW85-1073.ab1", ref = ref) #TEST:

##' .. content for \description{} (no empty lines) ..
##' Attribue le nom des bases à chaque trace.
##' .. content for \details{} ..
##' @title get_peak_matrix
##' @param  obj un objet sangerseq. 
##' @return tbl_df object
get_peak_matrix <- function(obj)
{
  obj %>%
    peakAmpMatrix() %>%
    as.data.frame() %>%
    select(A = V1, C = V2, G = V3, T = V4) %>%
    tbl_df()
}

##' .. content for \description{} (no empty lines) ..
##' 
##' Une fonction qui permet de déterminer la base qui a le pic le plus haut, la
##' hauteur de son pic, la base avec le second pic le plus haut, la hauteur de
##' ce pic, et le ratio des deux, ainsi que la position dans le référentiel de
##' la séquence.
##' 
##' .. content for \details{} ..
##' @title get_score_matrix
##' @param data typiquement une dataframe crée avec get_peak_matrix()
##' @return une dataframe
get_score_matrix <- function(data)
{
  data.frame(
    ## renvoit un vecteur avec le nom des bases avec le pic le plus haut        
    primaire = apply(data, 1, function(n) which.max(n) %>% names()),
    ## renvoit un vecteur avec le score du pic le plus haut
    prim_score = apply(data, 1, function(n) max(n)),
    ## renvoit un vecteur avec le nom des bases au second pic
    second = apply(data, 1, function(n) which.max(n[n != max(n)]) %>% names()),
    ## renvoit un vecteur avec le score du second pic 
    sec_score = apply(data, 1, function(n) sort(n)[length(n) - 1])
  ) %>%
    mutate(ratio = sec_score / prim_score,
           seq_position = row.names(.) %>% as.numeric())
}

pW85 %>%
  get_peak_matrix() %>%
  get_score_matrix() %>%
  tbl_df() ->
  test_data

theme_set(theme_minimal())

test_data %>%
  ggplot(aes(x = seq_position, y = prim_score)) +
  geom_path(aes(color = primaire)) +
  geom_path(aes(y = sec_score, color = second)) +
  facet_grid(primaire ~ .) 
  ## xlim(c(180, 220))
