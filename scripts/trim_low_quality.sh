#!/usr/local/bin/bash

#' -qtrim=rl : quality trim right and left 
#' -trimq=28 : trim if quality < 28 (sanger encoding, illumina 1.9)
#' -minlen=620 : keep only seq with length > 620, after trimming.
#' -Xmx1g : tells bbduk / java to use 1G of RAM

if [[ -f ../data/untrimmed.fastq && ! -f ../data/trim.fastq ]]
then # si les fichiers n'existent pas.
    ~/.bin/bbmap/bbduk.sh -Xmx1g \
                          -in=../data/untrimmed.fastq \
                          -out=../data/trim.fastq \
                          -qtrim=rl \
                          -trimq=28 \
                          -minlen=620

    ## convertit les bases d'une qualité inférieure à 20 en N.
    seqtk seq -q20 -nN ../data/trim.fastq > ../data/trimmed.fastq

    ## convertit le fastq en fasta
    seqret -sformat fastq -osformat fasta -auto -stdout \
           -sequence ../data/trimmed.fastq > ../data/trimmed.fasta

    rm ../data/trim.fastq
else
    printf "Le fichier untrimmed.fastq n'existe pas, ou le fichier trimmed.fastq existe déjà."
fi
