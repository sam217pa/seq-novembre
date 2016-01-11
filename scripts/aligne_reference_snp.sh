#!/usr/bin/bash
##
##
cd ~/stage/seq_novembre/data

needle \
    -asequence ./ref/wt.fasta \
    -sformat1 fasta \
    -bsequence ./ref/strong.fasta \
    -sformat2 fasta \
    -outfile ./ref/aln-strong-wt.fasta\
    -aformat3 fasta \
    -gapopen 10.0 \ # pénalité d'ouverture de gap
    -gapextend 0.5 # pénalité d'extension de gap

needle \
    -asequence ./ref/wt.fasta \
    -sformat1 fasta \
    -bsequence ./ref/weak.fasta \
    -sformat2 fasta \
    -outfile ./ref/aln-weak-wt.fasta\
    -aformat3 fasta \
    -gapopen 10.0 \
    -gapextend 0.5
