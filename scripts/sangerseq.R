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

##' .. content for \description{} (no empty lines) ..
##' Aligne les données de la séquence primaire avec ceux de la séquence
##' secondaire, en utilisant un algorithme TODO de type SM.
##' .. content for \details{} ..
##' @title aligner
##' @param seq l'objet sangerseq d'intérêt.
##' @param name le nom de la séquence, NSE.
##' @return un tableau contenant la position, la base du pic majeur,
##' la base du pic secondaire et le nom de la séquence.
aligner <- function(seq, name)
{
  argname <- deparse(substitute(seq))
  pairwiseAlignment(primarySeq(seq), secondarySeq(seq),
                    type= "global-local") %>%
    mismatchTable() %>%
    ## ne garde que les bases litigieuses et leur position
    select(primaire   = PatternSubstring,
           secondaire = SubjectSubstring,
           position   = PatternStart) %>%
    ## trim les positions de faible qualité
    filter(position > 40, # première position de bonne qualité
           position < length(primarySeq(seq)) - 40) %>% # dernière position de bonne qualité.
    mutate(name = name) # ajoute une colonne avec le nom de la séquence.
}

pW85_mm <- aligner(pW85, "pW85")
pW85_mm

id_table <- tbl_df(read.table("../id_table.dat", stringsAsFactors = FALSE, head = TRUE))
## rebascule les données litigieuses dans les bonnes catégories
## voir les premiers scripts.
id_table$mutant[id_table$name == "pS60-1073"] <- "weak"
id_table$mutant[id_table$name == "pS83-1073"] <- "weak"
id_table$mutant[id_table$name == "pS92-1073"] <- "weak"
id_table$mutant[id_table$name == "pS91-1073"] <- "weak"
id_table$mutant[id_table$name == "pW6-1073" ] <- "strong"
## élimine les fichiers aux données manquantes
id_table <- filter(id_table, name != "pS6-1073", name != "pS9-1073")

##' .. content for \description{} (no empty lines) ..
##' Appelle les bases principales et secondaires par fichier,
##' et aligne avec la séquence de référence.
##' .. content for \details{} ..
##' @title mismatcher
##' @param sequence char, le nom de la séquence.
##' @param ref DNAString, la séquence de référence.
##' @return
mismatcher <- function(sequence, ref)
{
  baseCaller(query = paste0("../spectrograms/", sequence, ".ab1"), ref) %>%
  aligner(., sequence)
}


## baseCaller(query = paste0("../spectrograms/", id_table$name[1], ".ab1"), ref)
## test_id_table <- id_table %>% sample_n(30)

result_table <- do.call(
  rbind,
  lapply(
    lapply(id_table$name, function(x) mismatcher(sequence = x, ref = ref)),
    data.frame
  )
)

write.csv(result_table, file = "result_table")

result_table %>%
  tbl_df() %>%
  inner_join(id_table, by = "name") %>%
  filter(mutant == "strong") %>%
  print()

#+TODO: ?mergeIUPACLetters

  iupac_code <-
  "
  iupac,meaning
  A,A
  C,C
  G,G
  T,T
  M,AC
  R,AG
  W,AT
  S,CG
  Y,CT
  K,GT
  V,ACG
  H,ACT
  D,AGT
  B,CGT
  X,GATC
  N,GATC
  "
  read.csv(text = iupac_code, stringsAsFactors = FALSE) %>% tbl_df() -> iupac

  is_iupac <- function(base) ifelse(base %in% c("A", "T", "C", "G"), FALSE, TRUE)

  iupacker <- function(subject, query)
  {

    lapply(
      str_split(paste0(subject, query), ""),
      sort)
  }

  result_table %>%
    filter( is_iupac(SubjectSubstring)) %>%
    inner_join(y = iupac, by = c("SubjectSubstring" = "iupac"))

peakAmpMatrix(pW85) %>%
  as.data.frame() %>%
  tbl_df() %>%
  mutate(pos = rownames(.)) %>%
  gather(trace, value, V1:V4) -> peakmatrix

traceMatrix(pW85) %>%
  as.data.frame() #%>%
  tbl_df() %>%
  mutate(pos = rownames(.)) %>%
  gather(trace, value, V1:V4) -> tracematrix
