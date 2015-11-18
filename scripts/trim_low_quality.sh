#!/usr/local/bin/bash

#' -qtrim=rl : quality trim right and left 
#' -trimq=28 : trim if quality < 28 (sanger encoding, illumina 1.9)
#' -minlen=620 : keep only seq with length > 620, after trimming.
#' -Xmx1g : tells bbduk to use 1G of RAM

if [[ -f ../data/untrimmed.fastq && ! -f ../data/trimmed.fastq ]]; then # seulement si les fichiers n'existent pas. 
    ~/.bin/bbmap/bbduk.sh -Xmx1g -in=../data/untrimmed.fastq -out=../data/trimmed.fastq qtrim=rl trimq=28 -minlen=620
else
    rm ../data/trimmed.fastq
    rm ../data/untrimmed.fastq
    ./quality_check # assemble tous les fichiers .fastq de novo
    ~/.bin/bbmap/bbduk.sh -Xmx1g -in=../data/untrimmed.fastq -out=../data/trimmed.fastq qtrim=rl trimq=28 -minlen=620
fi

fastqc trimmed.fastq -o ./tmp
mv ./tmp/trimmed_fastqc.html ../analysis
