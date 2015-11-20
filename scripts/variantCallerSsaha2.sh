#!/bin/bash
cd ~/stage/seq_novembre/scripts
# variant calling using ssaha2 and ssaha2SNP

cd ../data

## prend le reverse complement de la séquence de référence
fastx_reverse_complement -i reference.fasta -o reference_reverse.fasta

mkdir variantCalling
cd variantCalling

## place les séquences nécessaires pour l'analyse dans le dossier. 
ln -s ../trimmed.fastq .
ln -s ../reference_reverse.fasta ./reference_reverse.fasta

## alignement à la séquence de référence
#' -output psl :             format de sortie psl
#' reference_reverse.fasta : séquence de référence
#' trimmed.fastq :           séquence à aligner
#' output.psl :              fichier de sortie
~/.bin/ssahaSNP/ssaha2 -output psl reference_reverse.fasta trimmed.fastq > output.psl

## polymorphism detection tool
~/.bin/ssahaSNP/ssaahaSNP reference_reverse.fasta trimmed.fastq > SNP.txt

## computer readable format conversion
# egrep trouve les lignes où sont indiquées les données concernant les SNP
# awk extrait les champs en question dans un fichier SNP.dat
egrep ssaha:SNP SNP.txt | \
    awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15}' > SNP.dat

## column annotation based on
## ftp://ftp.sanger.ac.uk/pub/resources/software/ssahasnp/readme,
## part (6) some further information
# la première ligne du fichier .dat, afin d'être lu dans R
echo " match subject_name index_of_subject read_name s_base q_base s_qual q_qual offset_on_subject offset_on_read length_of_snp start_match_of_read end_match_of_read match_direction length_of_subject " > head.dat
# into final document
cat head.dat SNP.dat > snp_calling.dat
