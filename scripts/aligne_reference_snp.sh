#!/bin/bash
##
##
cd ~/stage/seq_novembre/data

needle                                \
    -asequence ./ref/wt_corrected.fst \
    -sformat1 fasta                   \
    -sreverse1                        \
    -bsequence ./ref/strong.fst       \
    -sformat2 fasta                   \
    -sreverse2                        \
    -outfile ./ref/aln-strong-wt.fst  \
    -aformat3 fasta                   \
    -gapopen 10.0                     \
    -gapextend 0.5

needle                                \
    -asequence ./ref/wt_corrected.fst \
    -sformat1 fasta                   \
    -sreverse1                        \
    -bsequence ./ref/weak.fst         \
    -sformat2 fasta                   \
    -sreverse2                        \
    -outfile ./ref/aln-weak-wt.fst    \
    -aformat3 fasta                   \
    -gapopen 10.0                     \
    -gapextend 0.5
