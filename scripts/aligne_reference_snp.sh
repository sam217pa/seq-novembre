#!/usr/bin/bash
##
##
cd ~/stage/seq_novembre/data

needle \
    -asequence ./ref/wt_corrected.fst \
    -sformat1 fasta \
    -bsequence ./ref/strong.fst \
    -sformat2 fasta \
    -outfile ./ref/aln-strong-wt.fst\
    -aformat3 fasta \
    -gapopen 10.0 \
    -gapextend 0.5

needle \
    -asequence ./ref/wt_corrected.fst \
    -sformat1 fasta \
    -bsequence ./ref/weak.fst \
    -sformat2 fasta \
    -outfile ./ref/aln-weak-wt.fst\
    -aformat3 fasta \
    -gapopen 10.0 \
    -gapextend 0.5
